import 'package:kairete/constants/api_routes.dart';
import 'package:kairete/data/base_client.dart';
import 'package:kairete/data/rest_client_gen.dart';

abstract class GroupUsecase {
  Future fetchItems({dynamic body});
  Future join({dynamic body});
  Future leave({dynamic body});
  Future fetchFeed({dynamic body});
  Future fetchGoups({dynamic body});
  Future reactions({dynamic body});
}

class IGroupUsecase extends BaseClient implements GroupUsecase {
  @override
  Future fetchItems({body}) async {
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.group,
      method: HttpMethodCustom.GET,
    );
    return json;
  }

  @override
  Future join({body}) async {
    final json = await appApiService.client?.requestApi(
      path: 'api/groups/${body['id']}/join',
      method: HttpMethodCustom.POST,
    );
    return json;
  }

  @override
  Future leave({body}) async {
    final json = await appApiService.client?.requestApi(
      path: 'api/groups/${body['id']}/leave',
      method: HttpMethodCustom.POST,
    );
    return json;
  }

  @override
  Future fetchFeed({body}) async {
    final json = await appApiService.client?.requestApi(
      path: 'api/newsfeed/group-feed',
      method: HttpMethodCustom.GET,
      body: body,
    );
    return json;
  }

  @override
  Future fetchGoups({body}) async {
    final json = await appApiService.client?.requestApi(
      path: 'api/groups/${body['id']}/posts',
      method: HttpMethodCustom.GET,
      body: body,
    );
    return json;
  }

  @override
  Future reactions({body}) async {
    final json = await appApiService.client?.requestApi(
      path: 'api/group-posts/${body['id']}/react',
      method: HttpMethodCustom.POST,
      body: body,
    );
    return json;
  }
}
