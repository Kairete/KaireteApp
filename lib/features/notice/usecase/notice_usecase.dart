import 'package:kairete/constants/api_routes.dart';
import 'package:kairete/data/base_client.dart';
import 'package:kairete/data/rest_client_gen.dart';

abstract class NoticeUsecase {
  Future fetchItems();
}

class INoticeUsecase extends BaseClient implements NoticeUsecase {
  @override
  Future fetchItems() async {
    final path = ApiRoutes.notice;
    final json = await appApiService.client?.requestApi(
      path: path,
      method: HttpMethodCustom.GET,
    );
    return json;
  }
}
