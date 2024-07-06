import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hashtagable/hashtagable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kairete/components/action_item.dart';
import 'package:kairete/components/kairete_bottom_sheet.dart';
import 'package:kairete/components/kairete_checkbox.dart';
import 'package:kairete/components/kairete_icon.dart';
import 'package:kairete/components/kairete_popup.dart';
import 'package:kairete/constants/size.dart';
import 'package:kairete/features/media/models/media_model.dart';
import 'package:kairete/features/media/usecase/media_uscase.dart';
import 'package:kairete/features/newsfeed/usecase/newsfeed_usecase.dart';
import 'package:kairete/helper/image_picker.dart';
import 'package:kairete/helper/multipart.dart';

import 'media_controller.dart';

class MediaCreateController extends GetxController {
  MediaUsecase usecase = IMediaUsecase();
  NewsFeedUsecase newFeedUsecase = INewsFeedUsecase();

  List<MediaCategoryModel> categories = [];
  List<MediaAlbumModel> albums = [];
  var selectedCategory = MediaCategoryModel().obs;
  var selectedAlbum = MediaAlbumModel().obs;
  var isEnable = false.obs;
  var isSelectedItem = false.obs;
  var tags = '';

  TextEditingController embedEditingController = TextEditingController();

  XFile? selectedItem;

  var paths = [].obs;
  List<String> tempFile = [];

  @override
  void onInit() {
    fetchAlbums();
    fetchCategories();
    super.onInit();
  }

  void onCreate() async {
    if (selectedItem == null && embedEditingController.text.isEmpty) {
      return;
    }
    final partFiles = await creatPartFiles(files: [selectedItem!]);

    final tag = extractHashTags(tags.replaceAll(',', ' '))
        .map((e) => e.replaceAll('#', ''))
        .toList();

    Map<String, dynamic> body = {
      'category_id': selectedCategory.value.categoryId,
      'album_id': selectedAlbum.value.albumId,
      'file': partFiles,
    };

    if (tags != '') {
      body['tags[]'] = tag;
    }

    if (selectedItem == null && embedEditingController.text.isNotEmpty) {
      body['embed_url'] = embedEditingController.text;
    }

    final formData = await getMultipartFilesNew(
      files: [],
      body: body,
    );

    final json = await usecase.add(body: formData);
    if (json != null) {
      showKairetePopup(
        onTapDone: () {
          final controller = Get.find<MediaController>();
          controller.fetchItems();
          Get.back(result: true);
        },
        content: 'Create successfuly',
      );
    }
  }

  void fetchAlbums() async {
    final json = await usecase.getMediaAlbum();
    albums = json['albums']
        .map<MediaAlbumModel>((e) => MediaAlbumModel.fromJson(e))
        .toList();
  }

  void fetchCategories() async {
    final json = await usecase.getMediaCategories();
    categories = json['categories']
        .map<MediaCategoryModel>((e) => MediaCategoryModel.fromJson(e))
        .toList();
  }

  void showCategory() async {
    showKaireteBottomSheet(
        title: 'Categories',
        customContent: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            kBottomSafea,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: categories
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: KaireteCheckBox(
                      title: e.title,
                      value: e.categoryId == selectedCategory.value.categoryId,
                      onChanged: (value) {
                        selectedCategory.value =
                            value == true ? e : MediaCategoryModel();
                        Get.back();
                        checkData();
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        onComplete: () {
          // if (onChangeFilter) {
          //   filter();
          // }
        });
  }

  void showAlbums() async {
    showKaireteBottomSheet(
        title: 'Albums',
        customContent: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            kBottomSafea,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: albums
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: KaireteCheckBox(
                      title: e.title,
                      value: e.albumId == selectedAlbum.value.albumId,
                      onChanged: (value) {
                        selectedAlbum.value =
                            value == true ? e : MediaAlbumModel();
                        Get.back();
                        checkData();
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        onComplete: () {
          // if (onChangeFilter) {
          //   filter();
          // }
        });
  }

  void checkData() {
    isEnable.value = selectedAlbum.value.albumId != null ||
        selectedCategory.value.categoryId != null;
  }

  void onSelectedImage() async {
    showKaireteBottomSheet(
        title: 'Select images',
        customContent: Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, kBottomSafea),
          child: Column(children: [
            KaireteActionItem(
              onTap: () async {
                Get.back();
                final file = await ImagePickerManager.instance
                    .pickImage(source: ImageSource.gallery);
                if (file != null) {
                  // uploadFile(item: file);
                  selectedItem = file;
                  isSelectedItem.value = true;

                  paths.clear();
                  paths.add(file.path);
                }
              },
              title: 'Library',
              suffixIcon: const SvgIcon(name: 'ic_image_picker'),
              margin: const EdgeInsets.only(bottom: 16),
              isHaveBorder: true,
            ),
            KaireteActionItem(
              onTap: () async {
                Get.back();
                final file = await ImagePickerManager.instance
                    .pickImage(source: ImageSource.camera);
                if (file != null) {
                  selectedItem = file;
                  isSelectedItem.value = true;
                  paths.clear();
                  paths.add(file.path);
                }
              },
              title: 'Camera',
              suffixIcon: const SvgIcon(name: 'ic_camera_picker'),
              margin: const EdgeInsets.only(bottom: 16),
              isHaveBorder: true,
            )
          ]),
        ),
        onComplete: () {});
  }

  void uploadFile({required XFile item}) async {
    final body = await getMultipartFilesNew(files: [item]);
    final json = await newFeedUsecase.uploadFile(body: body);
    tempFile.clear();
    tempFile.add(json['key']);
  }
}
