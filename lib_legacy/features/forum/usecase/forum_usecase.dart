import 'package:kairete/constants/api_routes.dart';
import 'package:kairete/data/base_client.dart';
import 'package:kairete/data/rest_client_gen.dart';

abstract class ForumUsecase {
  Future nodeList({dynamic body});
  Future nodeDetail({dynamic body});
  Future createThread({dynamic body});
  Future reactions({dynamic body});
  Future updateWatch({dynamic body});
}

class IForumUsecase extends BaseClient implements ForumUsecase {
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

  @override
  Future createThread({body}) async {
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.createThread,
      body: body,
      method: HttpMethodCustom.POST,
    );
    return json;
  }

  @override
  Future reactions({body}) async {
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.reactionThread + body['id'].toString() + '/react',
      body: body,
      method: HttpMethodCustom.POST,
    );
    return json;
  }

  @override
  Future updateWatch({body}) async {
    final json = await appApiService.client?.requestApi(
      path: 'api/forums/${body['id']}/watch',
      body: body,
      method: HttpMethodCustom.POST,
    );
    return json;
  }
}
