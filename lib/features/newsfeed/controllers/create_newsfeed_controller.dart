import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kairete/components/action_item.dart';
import 'package:kairete/components/kairete_bottom_sheet.dart';
import 'package:kairete/components/kairete_popup.dart';
import 'package:kairete/constants/key_constant.dart';
import 'package:kairete/features/newsfeed/usecase/newsfeed_usecase.dart';
import 'package:kairete/helper/image_picker.dart';
import 'package:kairete/local/data_local.dart';

import '../../../components/kairete_icon.dart';
import '../../../constants/size.dart';
import '../../../helper/multipart.dart';
import '../../blogs/screens/blog_create_screen.dart';
import 'newsfeed_controller.dart';

class CreateNewsfeedController extends GetxController {
  NewsFeedUsecase usecase = INewsFeedUsecase();
  TextEditingController textController = TextEditingController();
  var isEnable = false.obs;
  var paths = [].obs;
  List<String> tempFile = [];

  @override
  void onInit() {
    if (Get.arguments != null) {
      usecase = Get.arguments['usecase'];
    }
    super.onInit();
  }

  void textOnChanged({required String text}) {
    isEnable.value = text.isNotEmpty;
  }

  void onCreate() async {
    final id = await LocalManager.instance.read(key: PreferencesKey.token);
    final body = {
      'user_id': id,
      'message': textController.text,
    };
    if (tempFile.isNotEmpty) {
      body['attachment_key'] = tempFile.first;
    }
    print(body);
    final json = await usecase.create(body: body);
    if (json != null) {
      showKairetePopup(
        onTapDone: () {
          final newFeedController = Get.find<NewsFeedController>();
          newFeedController.fechItems();
          Get.back(result: true);
        },
        content: 'Create successfuly',
      );
    }
  }

  void uploadFile({required XFile item}) async {
    final body = await getMultipartFilesNew(files: [item]);
    final json = await usecase.uploadFile(body: body);
    tempFile.clear();
    tempFile.add(json['key']);
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
                  uploadFile(item: file);
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

  void toPostBlog() {
    Get.to(() => BlogCreateScreen(), fullscreenDialog: true);
  }
}
