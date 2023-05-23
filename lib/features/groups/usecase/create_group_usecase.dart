import 'package:kairete/features/newsfeed/usecase/newsfeed_usecase.dart';

import '../../../data/rest_client_gen.dart';

class ICreateGroupUsecaseImpl extends INewsFeedUsecase {
  final int? groupId;

  ICreateGroupUsecaseImpl(this.groupId);

  @override
  Future create({body}) async {
    body['group_id'] = groupId;
    final json = await appApiService.client?.requestApi(
      path: 'api/group-posts/',
      body: body,
      method: HttpMethodCustom.POST,
    );
    return json;
  }
}

class ICreateGroupNormalUsecaseImpl extends INewsFeedUsecase {
  final int? groupId;

  ICreateGroupNormalUsecaseImpl(this.groupId);

  @override
  Future create({body}) async {
    final json = await appApiService.client?.requestApi(
      path: 'api/group-posts/$groupId/comments',
      body: body,
      method: HttpMethodCustom.POST,
    );
    return json;
  }
}
