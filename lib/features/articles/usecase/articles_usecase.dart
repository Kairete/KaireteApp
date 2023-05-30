import 'package:kairete/constants/api_routes.dart';
import 'package:kairete/data/base_client.dart';
import 'package:kairete/data/rest_client_gen.dart';

abstract class ArticlesUsecase {
  Future fetItems({dynamic body});
  Future fetItem({dynamic body});
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
}
