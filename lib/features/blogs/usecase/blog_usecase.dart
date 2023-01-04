import 'package:kairete/constants/api_routes.dart';
import 'package:kairete/data/base_client.dart';
import 'package:kairete/data/rest_client_gen.dart';

abstract class BlogUsecase {
  Future fetItems({dynamic body});
  Future fetchItemsFromCate({dynamic body});
}

class IBlogUsecase extends BaseClient implements BlogUsecase {
  @override
  Future fetItems({body}) async {
    final json = await appApiService.client?.requestApi(
        path: ApiRoutes.blogs, body: body, method: HttpMethodCustom.GET);
    return json;
  }

  @override
  Future fetchItemsFromCate({body}) async {
    final json = await appApiService.client?.requestApi(
        path: ApiRoutes.blogsCate, body: body, method: HttpMethodCustom.GET);
    return json;
  }
}
