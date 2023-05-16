import 'package:kairete/constants/api_routes.dart';
import 'package:kairete/data/base_client.dart';
import 'package:kairete/data/rest_client_gen.dart';

abstract class GroupUsecase {
  Future fetchItems({dynamic body});
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
}
