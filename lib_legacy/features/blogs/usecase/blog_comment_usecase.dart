import '../../../data/base_client.dart';
import '../../../data/rest_client_gen.dart';

abstract class BlogCommentUsecase {
  Future commentLv1({dynamic body});
  Future commentLv2({dynamic body});
  Future postCommentLv1({dynamic body});
  Future postCommentLv2({dynamic body});
  Future reactions({dynamic body});
}

class IBlogCommentUsecase extends BaseClient implements BlogCommentUsecase {
  @override
  Future commentLv1({body}) async {
    final json = await appApiService.client?.requestApi(
      path: 'api/blog-entries/${body['id']}/comments',
      body: body,
      method: HttpMethodCustom.GET,
    );
    return json;
  }

  @override
  Future commentLv2({body}) async {
    final json = await appApiService.client?.requestApi(
      path: 'api/blog-entry-comments/${body['id']}/replies',
      body: body,
      method: HttpMethodCustom.GET,
    );
    return json;
  }

  @override
  Future postCommentLv1({body}) async {
    final json = await appApiService.client?.requestApi(
      path: 'api/blog-entries/${body['id']}/comments',
      body: body,
      method: HttpMethodCustom.POST,
    );
    return json;
  }

  @override
  Future postCommentLv2({body}) async {
    final json = await appApiService.client?.requestApi(
      path: 'api/blog-entry-comments/${body['id']}/replies',
      body: body,
      method: HttpMethodCustom.POST,
    );
    return json;
  }

  @override
  Future reactions({body}) async {
    final json = await appApiService.client?.requestApi(
      path: 'api/blog-entry-comments/${body['id']}/react',
      body: body,
      method: HttpMethodCustom.POST,
    );
    return json;
  }
}
