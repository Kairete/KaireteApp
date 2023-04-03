import 'package:kairete/constants/api_routes.dart';
import 'package:kairete/data/base_client.dart';
import 'package:kairete/data/rest_client_gen.dart';

abstract class NewsFeedUsecase {
  Future fetchItems({dynamic body});
  Future create({dynamic body});
  Future uploadFile({dynamic body});
  Future search({dynamic body});
  Future filter({dynamic body});
  Future reactions({dynamic body});
  Future comments({
    dynamic body,
    required int id,
  });
  Future postCommentsLv1({dynamic body});
  Future commentsLv2({dynamic body});
  Future postComments({dynamic body});
  Future reactionsComment({dynamic body});
}

class INewsFeedUsecase extends BaseClient implements NewsFeedUsecase {
  @override
  Future fetchItems({body}) async {
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.newsfeed,
      // body: body,
      method: HttpMethodCustom.GET,
    );
    return json;
  }

  @override
  Future create({body}) async {
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.createNews,
      body: body,
      method: HttpMethodCustom.POST,
    );
    return json;
  }

  @override
  Future uploadFile({body}) async {
    final json = await appApiService.client
        ?.uploadFile(path: ApiRoutes.newAttachKey, body: body);
    return json;
  }

  @override
  Future search({body}) async {
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.searchNews,
      body: body,
      method: HttpMethodCustom.GET,
    );
    return json;
  }

  @override
  Future filter({body}) async {
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.filter,
      body: body,
      method: HttpMethodCustom.POST,
    );
    return json;
  }

  @override
  Future reactions({dynamic body}) async {
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.reactions + '${body['id']}' + '/react',
      method: HttpMethodCustom.POST,
      body: body,
    );
    return json;
  }

  @override
  Future comments({
    dynamic body,
    required int id,
  }) async {
    final path = '$id/comments';
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.commentsLv1 + path,
      method: HttpMethodCustom.GET,
      body: body,
    );
    return json;
  }

  @override
  Future commentsLv2({dynamic body}) async {
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.commentsLv2 + '${body['id']}' + '/replies',
      method: HttpMethodCustom.GET,
      body: body,
    );
    return json;
  }

  @override
  Future postComments({body}) async {
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.commentsLv2 + '${body['id']}' + '/replies',
      method: HttpMethodCustom.POST,
      body: body,
    );
    return json;
  }

  @override
  Future postCommentsLv1({body}) async {
    final path = '${body['id']}/comments';
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.commentsLv1 + path,
      method: HttpMethodCustom.POST,
      body: body,
    );
    return json;
  }

  @override
  Future reactionsComment({body}) async {
    final path = '${body['id']}/react';
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.commentsLv2 + path,
      method: HttpMethodCustom.POST,
      body: body,
    );
    return json;
  }
}
