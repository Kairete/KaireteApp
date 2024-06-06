import 'package:kairete/constants/api_routes.dart';
import 'package:kairete/data/base_client.dart';
import 'package:kairete/data/rest_client_gen.dart';

abstract class MasterDataUsecase {
  Future fetchReactionIcons({dynamic body});
  Future fetchStyle();
  Future fetchWidget({dynamic body});
  Future fetchUser();
}

class IMasterDataUsecase extends BaseClient implements MasterDataUsecase {
  @override
  Future fetchReactionIcons({body}) async {
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.reactionIcons,
      method: HttpMethodCustom.GET,
    );
    return json;
  }

  @override
  Future fetchStyle({body}) async {
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.style,
      method: HttpMethodCustom.GET,
    );
    return json;
  }

  @override
  Future fetchWidget({body}) async {
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.widget,
      method: HttpMethodCustom.GET,
      parameters: body,
    );
    return json;
  }

  @override
  Future fetchUser() async {
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.user + '500',
      method: HttpMethodCustom.GET,
    );
    return json;
  }
}
