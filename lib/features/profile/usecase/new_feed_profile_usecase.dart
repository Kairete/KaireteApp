import 'package:kairete/data/base_client.dart';
import 'package:kairete/features/newsfeed/usecase/newsfeed_usecase.dart';

import '../../../data/rest_client_gen.dart';

abstract class NewFeedProfileUsecase {
  Future profilePost({dynamic body});
}

class INewFeedProfileUsecase extends BaseClient
    implements NewFeedProfileUsecase {
  final int? id;

  INewFeedProfileUsecase(this.id);

  @override
  void onCreate({userId, bool isShowloading = true}) {
    super.onCreate(userId: id.toString());
  }

  @override
  Future profilePost({body}) async {
    final json = await appApiService.client?.requestApi(
      path: 'api/newsfeed/user-feed',
      body: body,
      method: HttpMethodCustom.GET,
    );
    return json;
  }
}
