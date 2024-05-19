import 'package:get/get.dart';
import 'package:kairete/features/notice/models/notice_model.dart';
import 'package:kairete/features/notice/usecase/notice_usecase.dart';

class NoticeController extends GetxController {
  NoticeUsecase usecase = INoticeUsecase();

  var notices = <NoticeModel>[].obs;

  @override
  void onInit() {
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
