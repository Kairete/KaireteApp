import 'package:kairete/constants/api_routes.dart';
import 'package:kairete/data/base_client.dart';

abstract class ResgiterUsecase {
  Future register({dynamic body});
}

class IResgiterUsecase extends BaseClient implements ResgiterUsecase {
  @override
  Future register({body}) async {
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.register,
      body: body,
    );
    return json;
  }
}
