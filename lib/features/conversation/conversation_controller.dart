import 'package:get/get.dart';
import 'package:kairete/features/conversation/conversation_model.dart';
import 'package:kairete/features/conversation/conversation_usecase.dart';

class ConversationController extends GetxController {
  ConversationUsecase usecase = IConversationUsecase();

  var conversations = <ConversationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchConversation();
  }

  void fetchConversation() async {
    final json = await usecase.fetch();
    conversations.value = json['conversations']
        .map<ConversationModel>((e) => ConversationModel.fromJson(e))
        .toList();
  }
}
