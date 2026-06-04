import 'package:kairete/data/base_client.dart';

import '../../../data/rest_client_gen.dart';

abstract class ThreadUsecase {
  Future commentLv1({dynamic body});
  Future commentLv2({dynamic body});
  Future postCommentLv1({dynamic body});
  Future postCommentLv2({dynamic body});
  Future fetchItem({dynamic body});
}

class IThreadUsecase extends BaseClient implements ThreadUsecase {
  @override
  Future commentLv1({body}) async {
    final json = await appApiService.client?.requestApi(
      path: 'api/threads/${body['id']}/posts',
      body: body,
      method: HttpMethodCustom.GET,
    );
    return json;
  }

  @override
  Future commentLv2({body}) async {
    final json = await appApiService.client?.requestApi(
      path: 'api/posts/${body['id']}/replies',
      body: body,
      method: HttpMethodCustom.GET,
    );
    return json;
  }

  @override
  Future postCommentLv1({body}) async {
    final json = await appApiService.client?.requestApi(
      path: 'api/posts/',
      body: body,
      method: HttpMethodCustom.POST,
    );
    return json;
  }

  @override
  Future postCommentLv2({body}) async {
    final json = await appApiService.client?.requestApi(
      path: 'api/posts/${body['id']}/replies',
      body: body,
      method: HttpMethodCustom.POST,
    );
    return json;
  }

  @override
  Future fetchItem({body}) async {
    final json = await appApiService.client?.requestApi(
      path: 'api/posts/${body['id']}',
      body: body,
      method: HttpMethodCustom.GET,
    );
    return json;
  }
}
