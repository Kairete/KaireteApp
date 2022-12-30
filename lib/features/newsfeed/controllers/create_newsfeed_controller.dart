import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kairete/components/action_item.dart';
import 'package:kairete/components/kairete_bottom_sheet.dart';
import 'package:kairete/components/kairete_popup.dart';
import 'package:kairete/constants/key_constant.dart';
import 'package:kairete/features/newsfeed/controllers/newsfeed_controller.dart';
import 'package:kairete/features/newsfeed/usecase/newsfeed_usecase.dart';
import 'package:kairete/helper/image_picker.dart';
import 'package:kairete/helper/user.dart';
import 'package:kairete/local/data_local.dart';

import '../../../components/kairete_icon.dart';
import '../../../constants/size.dart';
import '../../../helper/multipart.dart';

class CreateNewsfeedController extends GetxController {
  NewsFeedUsecase usecase = INewsFeedUsecase();
  TextEditingController textController = TextEditingController();
  var isEnable = false.obs;
  var paths = [].obs;

  @override
  void onInit() {
    super.onInit();
  }

  void textOnChanged({required String text}) {
    isEnable.value = text.isNotEmpty;
  }

  void onCreate() async {
    final body = {
      'user_id': LocalManager.instance.read(key: PreferencesKey.token),
      'message': textController.text,
    };
    final json = await usecase.create(body: body);
    if (json != null) {
      showKairetePopup(
        onTapDone: () {
          final newFeedController = Get.find<NewsFeedController>();
          newFeedController.fechItems();
          Get.back();
        },
        content: 'Create successfuly',
      );
    }
  }

  void uploadFile({required String path}) async {
    final image = await getMultipartFile(path: path);
    final body = {'type': 'post', 'attachment': image};
    final json = await usecase.uploadFile(body: body);
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
                  paths.add(file.path);
                  // uploadFile(path: file.path);
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
}
