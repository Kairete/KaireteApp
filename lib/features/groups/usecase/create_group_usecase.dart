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

class IGroupNormalUsecaseImpl extends INewsFeedUsecase {
  IGroupNormalUsecaseImpl();

  @override
  Future fetchItems({body}) async {
    final json = await appApiService.client?.requestApi(
      path: 'api/group-posts/${body['id']}/comments',
      method: HttpMethodCustom.GET,
    );
    return json;
  }

  @override
  Future reactionsComment({body}) async {
    final json = await appApiService.client?.requestApi(
      path: 'api/group-comments/${body['id']}/react',
      method: HttpMethodCustom.POST,
      parameters: body,
    );
    return json;
  }

  @override
  Future postCommentsLv1({body}) async {
    final json = await appApiService.client?.requestApi(
      path: 'api/group-posts/${body['id']}/comments',
      method: HttpMethodCustom.POST,
      body: body,
    );
    return json;
  }
}
