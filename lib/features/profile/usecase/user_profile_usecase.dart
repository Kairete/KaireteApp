import 'package:kairete/constants/api_routes.dart';
import 'package:kairete/data/base_client.dart';
import 'package:kairete/data/rest_client_gen.dart';

abstract class UserProfileUsecase {
  Future fetchData({dynamic body});
}

class IUserProfileUsecase extends BaseClient implements UserProfileUsecase {
  @override
  Future fetchData({body}) async {
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.me,
      body: body,
      method: HttpMethodCustom.GET,
    );
    return json;
  }
}
