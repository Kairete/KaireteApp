import 'package:kairete/data/base_client.dart';
import 'package:kairete/data/rest_client_gen.dart';
import 'package:kairete/helper/user.dart';

abstract class ActivityUsecase {
  Future follower();
  Future following();
  Future bookmark();
}

class IActivityUsecase extends BaseClient implements ActivityUsecase {
  @override
  Future follower() async {
    final id = UserManager.instance.userId ?? '';
    final json = await appApiService.client?.requestApi(
      path: 'api/users/$id/followers',
      method: HttpMethodCustom.GET,
    );
    return json;
  }

  @override
  Future following() async {
    final id = UserManager.instance.userId ?? '';
    final json = await appApiService.client?.requestApi(
      path: 'api/users/$id/followings',
      method: HttpMethodCustom.GET,
    );
    return json;
  }

  @override
  Future bookmark() async {
    final json = await appApiService.client?.requestApi(
      path: 'api/me/bookmarks',
      method: HttpMethodCustom.GET,
    );
    return json;
  }
}
