import 'package:kairete/constants/api_routes.dart';
import 'package:kairete/data/base_client.dart';
import 'package:kairete/data/rest_client_gen.dart';

abstract class NewsFeedUsecase {
  Future fetchItems({dynamic body});
  Future create({dynamic body});
}

class INewsFeedUsecase extends BaseClient implements NewsFeedUsecase {
  @override
  Future fetchItems({body}) async {
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.newsfeed,
      body: body,
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
}
