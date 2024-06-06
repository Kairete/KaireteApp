import 'package:get/get.dart';
import 'package:kairete/features/notice/models/notice_model.dart';
import 'package:kairete/features/notice/usecase/notice_usecase.dart';

class NoticeController extends GetxController {
  NoticeUsecase usecase = INoticeUsecase();

  var notices = <NoticeModel>[].obs;
  int? count;

  @override
  void onInit() {
    if (Get.arguments['count'] != null) {
      count = Get.arguments['count'];
    }
    fetchItems();
    super.onInit();
  }

  void fetchItems() async {
    final json = await usecase.fetchItems();
    notices.value = json['alerts']
        .map<NoticeModel>((e) => NoticeModel.fromJson(e))
        .toList();
  }
}
