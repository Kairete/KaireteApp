import 'package:kairete/data/base_client.dart';
import 'package:kairete/data/rest_client_gen.dart';

abstract class ConversationUsecase {
  Future fetch({dynamic body});
  Future post({dynamic body});
  Future message({dynamic body});
  Future postMessage({dynamic body});
}

class IConversationUsecase extends BaseClient implements ConversationUsecase {
  @override
  Future fetch({body}) async {
    final path = 'api/conversations';
    final json = await appApiService.client?.requestApi(
      path: path,
      method: HttpMethodCustom.GET,
      body: body,
    );
    return json;
  }

  @override
  Future post({body}) async {
    final path = 'api/conversations';
    final json = await appApiService.client?.requestApi(
      path: path,
      method: HttpMethodCustom.POST,
      body: body,
    );
    return json;
  }

  @override
  Future message({body}) async {
    final path = 'api/conversations/${body['id']}/messages';
    final json = await appApiService.client?.requestApi(
      path: path,
      method: HttpMethodCustom.GET,
      body: body,
    );
    return json;
  }

  @override
  Future postMessage({body}) async {
    final path = 'api/conversation-messages';
    final json = await appApiService.client?.requestApi(
      path: path,
      method: HttpMethodCustom.POST,
      body: body,
    );
    return json;
  }
}
