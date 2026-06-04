import 'package:kairete/constants/api_routes.dart';
import 'package:kairete/data/base_client.dart';
import 'package:kairete/data/rest_client_gen.dart';
import 'package:kairete/helper/user.dart';

abstract class MediaUsecase {
  Future get({dynamic body});
  Future add({dynamic body});
  Future getAlbum({required int id});
  Future getCategory({required int id});
  Future reactions({required int id, dynamic body});
  Future comments({dynamic body});
  Future getComments({required int id});
  Future getMediaAlbum({dynamic body});
  Future getMediaCategories({dynamic body});
}

class IMediaUsecase extends BaseClient implements MediaUsecase {
  @override
  Future add({body}) async {
    final json = await appApiService.client?.uploadFile(
      path: ApiRoutes.media,
      body: body,
    );
    return json;
  }

  @override
  Future get({body}) async {
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.media,
      body: body,
      method: HttpMethodCustom.GET,
    );
    return json;
  }

  @override
  Future getAlbum({required int id}) async {
    final json = await appApiService.client?.requestApi(
      path: 'api/media-albums/$id',
      body: {
        'with_media': true,
      },
      method: HttpMethodCustom.GET,
    );
    return json;
  }

  @override
  Future getCategory({required int id}) async {
    final json = await appApiService.client?.requestApi(
      path: 'api/media-categories/$id',
      body: {
        'with_content': true,
      },
      method: HttpMethodCustom.GET,
    );
    return json;
  }

  @override
  Future reactions({required int id, dynamic body}) async {
    final json = await appApiService.client?.requestApi(
      path: 'api/media/$id/react',
      method: HttpMethodCustom.POST,
      body: body,
    );
    return json;
  }

  @override
  Future comments({body}) async {
    final json = await appApiService.client?.requestApi(
      path: 'api/media-comments',
      body: body,
      method: HttpMethodCustom.POST,
    );
    return json;
  }

  @override
  Future getComments({required int id}) async {
    final json = await appApiService.client?.requestApi(
      path: 'api/media/$id/comments',
      method: HttpMethodCustom.GET,
    );
    return json;
  }

  @override
  Future getMediaAlbum({body}) async {
    final json = await appApiService.client?.requestApi(
        path: 'api/media-albums',
        method: HttpMethodCustom.GET,
        body: {
          'user_id': UserManager.instance.userId,
        });
    return json;
  }

  @override
  Future getMediaCategories({body}) async {
    final json = await appApiService.client?.requestApi(
      path: 'api/media-categories',
      method: HttpMethodCustom.GET,
    );
    return json;
  }
}
