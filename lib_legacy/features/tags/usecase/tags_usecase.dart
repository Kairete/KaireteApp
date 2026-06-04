import 'package:kairete/constants/api_routes.dart';
import 'package:kairete/data/base_client.dart';
import 'package:kairete/data/rest_client_gen.dart';

abstract class TagsUsecase {
  Future fetchItems({required String id});
}

class ITagsUsecaseUsecase extends BaseClient implements TagsUsecase {
  @override
  Future fetchItems({required String id}) async {
    final path = ApiRoutes.tags + id;
    final json = await appApiService.client?.requestApi(
      path: path,
      method: HttpMethodCustom.GET,
    );
    return json;
  }
}
