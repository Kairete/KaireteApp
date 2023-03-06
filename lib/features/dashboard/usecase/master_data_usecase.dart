import 'package:kairete/constants/api_routes.dart';
import 'package:kairete/data/base_client.dart';
import 'package:kairete/data/rest_client_gen.dart';

abstract class MasterDataUsecase {
  Future fetchReactionIcons({dynamic body});
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
}
