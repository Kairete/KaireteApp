import 'package:kairete/constants/api_routes.dart';
import 'package:kairete/data/base_client.dart';
import 'package:kairete/data/rest_client_gen.dart';

abstract class ArticlesUsecase {
  Future fetItems({dynamic body});
  Future fetItem({dynamic body});
  Future updateWatch({dynamic body});
  Future fetchNewfeedItem({required int id});
}

class IArticlesUsecase extends BaseClient implements ArticlesUsecase {
  @override
  Future fetItems({body}) async {
    final json = await appApiService.client?.requestApi(
        path: ApiRoutes.articles, body: body, method: HttpMethodCustom.GET);
    return json;
  }

  @override
  Future fetItem({body}) async {
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.articles + '/' + body['id'],
      body: body,
      method: HttpMethodCustom.GET,
    );
    return json;
  }

  @override
  Future updateWatch({body}) async {
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.articles + '/' + body['id'] + '/watch',
      body: body,
      method: HttpMethodCustom.POST,
    );
    return json;
  }

  @override
  Future fetchNewfeedItem({required int id}) async {
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.reactions + '$id',
      method: HttpMethodCustom.GET,
    );
    return json;
  }
}
