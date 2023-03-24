import 'package:kairete/constants/api_routes.dart';
import 'package:kairete/data/base_client.dart';
import 'package:kairete/data/rest_client_gen.dart';

abstract class NewsFeedUsecase {
  Future fetchItems({dynamic body});
  Future create({dynamic body});
  Future uploadFile({dynamic body});
  Future search({dynamic body});
  Future filter({dynamic body});
  Future reactions({dynamic body});
  Future comments({dynamic body, required String path});
}

class INewsFeedUsecase extends BaseClient implements NewsFeedUsecase {
  @override
  Future fetchItems({body}) async {
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.newsfeed,
      // body: body,
      method: HttpMethodCustom.GET,
    );
    return json;
  }

  @override
  Future create({body}) async {
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.createNews,
      body: body,
      method: HttpMethodCustom.POST,
    );
    return json;
  }

  @override
  Future uploadFile({body}) async {
    final json = await appApiService.client
        ?.uploadFile(path: ApiRoutes.newAttachKey, body: body);
    return json;
  }

  @override
  Future search({body}) async {
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.searchNews,
      body: body,
      method: HttpMethodCustom.GET,
    );
    return json;
  }

  @override
  Future filter({body}) async {
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.filter,
      body: body,
      method: HttpMethodCustom.POST,
    );
    return json;
  }

  @override
  Future reactions({dynamic body}) async {
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.reactions + '${body['id']}' + '/react',
      method: HttpMethodCustom.POST,
      body: body,
    );
    return json;
  }

  @override
  Future comments({dynamic body, required String path}) async {
    final json = await appApiService.client?.requestApi(
      path: 'api/' + path,
      method: HttpMethodCustom.GET,
      body: body,
    );
    return json;
  }
}
