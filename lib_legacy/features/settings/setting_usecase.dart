import 'package:kairete/data/base_client.dart';
import 'package:kairete/data/rest_client_gen.dart';

abstract class SettingUsecase {
  Future updateFullName({dynamic body});
  Future updateUserName({dynamic body});
  Future updateEmail({dynamic body});
  Future updatePass({dynamic body});
}

class ISettingUsecase extends BaseClient implements SettingUsecase {
  @override
  Future updateFullName({body}) async {
    final json = await appApiService.client?.requestApi(
      path: 'api/me/full-name',
      body: body,
      method: HttpMethodCustom.POST,
    );
    return json;
  }

  @override
  Future updateUserName({body}) async {
    final json = await appApiService.client?.requestApi(
      path: 'api/me/username',
      body: body,
      method: HttpMethodCustom.POST,
    );
    return json;
  }

  @override
  Future updateEmail({body}) async {
    final json = await appApiService.client?.requestApi(
      path: 'api/me/email',
      body: body,
      method: HttpMethodCustom.POST,
    );
    return json;
  }

  @override
  Future updatePass({body}) async {
    final json = await appApiService.client?.requestApi(
      path: 'api/me/password',
      body: body,
      method: HttpMethodCustom.POST,
    );
    return json;
  }
}
