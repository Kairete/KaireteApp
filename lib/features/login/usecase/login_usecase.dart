import 'package:kairete/constants/api_routes.dart';
import 'package:kairete/data/base_client.dart';

abstract class LoginUsecase {
  Future login({dynamic body});
}

class ILoginUsecase extends BaseClient implements LoginUsecase {
  @override
  Future login({body}) async {
    final json = await appApiService.client
        ?.requestApi(path: ApiRoutes.login, body: body);
    return json;
  }
}
