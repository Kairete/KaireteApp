import 'package:get/get.dart';
import 'package:kairete/features/settings/tearm/tearm_policy_usecase.dart';

class TermsAndPolicyController extends GetxController {
  var htmlData = ''.obs;
  TearmAndPolicyUsecase usecase = ITearmAndPolicyUsecase();

  String? type;

  @override
  void onInit() {
    if (Get.arguments['type'] != null) {
      type = Get.arguments['type'];
    }
    super.onInit();
    loadHtmlData();
  }

  void loadHtmlData() async {
    if (type == 'tearm') {
      final json = await usecase.getTearm();
      htmlData.value = json['terms'];
    } else {
      final json = await usecase.getPolicy();
      htmlData.value = json['policy'];
    }
  }
}
