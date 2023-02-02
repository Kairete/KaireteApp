import 'package:kairete/constants/api_routes.dart';
import 'package:kairete/data/base_client.dart';
import 'package:kairete/data/rest_client_gen.dart';

abstract class ForumUsecase {
  Future nodeList({dynamic body});
  Future nodeDetail({dynamic body});
}

class IForumUsecase extends BaseClient implements ForumUsecase {
  @override
  void onCreate({userId}) {
    appApiService.create(isShowErrorPopup: isShowPopupError, userId: '1');
  }

  @override
  Future nodeList({body}) async {
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.nodeList,
      body: body,
      method: HttpMethodCustom.GET,
    );
    return json;
  }

  @override
  Future nodeDetail({body}) async {
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.nodeDetail + body['id'].toString() + '/threads',
      body: body,
      method: HttpMethodCustom.GET,
    );
    return json;
  }
}
