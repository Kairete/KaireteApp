import 'package:kairete/constants/api_routes.dart';
import 'package:kairete/data/base_client.dart';
import 'package:kairete/data/rest_client_gen.dart';

import '../../../constants/key_constant.dart';
import '../../../local/data_local.dart';

abstract class UserProfileUsecase {
  Future fetchData({dynamic body});
  Future fetchUser({dynamic body});
}

abstract class FCMUsecase {
  Future pushFCM({dynamic body});
}

abstract class UserUsecase {
  Future fetchData({dynamic body});
  Future fetchUser({dynamic body});
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

  @override
  Future fetchUser({body}) async {
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.user + '${body['id']}',
      body: body,
      method: HttpMethodCustom.GET,
    );
    return json;
  }
}

class IFCMUsecase extends BaseClient implements FCMUsecase {
  @override
  bool get isShowPopupError => false;

  @override
  Future pushFCM({body}) async {
    final id =
        await LocalManager.instance.read(key: PreferencesKey.token) ?? '1';
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.pushFCM + '$id/firebase-device-token',
      body: body,
      method: HttpMethodCustom.POST,
    );
    return json;
  }

  @override
  void onCreate({userId}) {
    appApiService.create(isShowErrorPopup: isShowPopupError, userId: '1');
  }
}
