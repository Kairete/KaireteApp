import 'package:kairete/data/base_client.dart';
import 'package:kairete/data/rest_client_gen.dart';

abstract class TearmAndPolicyUsecase {
  Future getTearm({dynamic body});
  Future getPolicy({dynamic body});
}

class ITearmAndPolicyUsecase extends BaseClient
    implements TearmAndPolicyUsecase {
  @override
  Future getTearm({body}) async {
    final json = await appApiService.client?.requestApi(
      path: 'api/extra/terms',
      body: body,
      method: HttpMethodCustom.GET,
    );
    return json;
  }

  @override
  Future getPolicy({body}) async {
    final json = await appApiService.client?.requestApi(
      path: 'api/extra/policy',
      body: body,
      method: HttpMethodCustom.GET,
    );
    return json;
  }
}
