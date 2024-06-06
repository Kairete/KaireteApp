import 'package:kairete/constants/api_routes.dart';
import 'package:kairete/data/base_client.dart';
import 'package:kairete/data/rest_client_gen.dart';

abstract class BlogUsecase {
  Future fetItems({dynamic body});
  Future fetchItemsFromCate({dynamic body});
  Future reactions({dynamic body});
  Future myBlogs({dynamic body});
  Future myBlog({dynamic body});
  Future blogDetail({dynamic body});
  Future createBlog({dynamic body});
  Future updateWatch({dynamic body});
  Future updateWatchBlogs({dynamic body});
}

class IBlogUsecase extends BaseClient implements BlogUsecase {
  @override
  Future fetItems({body}) async {
    final json = await appApiService.client?.requestApi(
        path: ApiRoutes.blogs, body: body, method: HttpMethodCustom.GET);
    return json;
  }

  @override
  Future fetchItemsFromCate({body}) async {
    final json = await appApiService.client?.requestApi(
        path: ApiRoutes.blogsCate, body: body, method: HttpMethodCustom.GET);
    return json;
  }

  @override
  Future reactions({body}) async {
    final path = '/${body['id']}/react}';
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.blogs + path,
      body: body,
      method: HttpMethodCustom.POST,
    );
    return json;
  }

  @override
  Future myBlogs({body}) async {
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.myBlogs,
      body: body,
      method: HttpMethodCustom.GET,
    );
    return json;
  }

  @override
  Future myBlog({body}) async {
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.myBlogs + body['id'],
      body: body,
      method: HttpMethodCustom.GET,
    );
    return json;
  }

  @override
  Future blogDetail({body}) async {
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.blogs + '/' + body['id'],
      method: HttpMethodCustom.GET,
    );
    return json;
  }

  @override
  Future createBlog({body}) async {
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.blogs,
      method: HttpMethodCustom.POST,
      body: body,
    );
    return json;
  }

  @override
  Future updateWatch({body}) async {
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.blogs + '/${body['id']}/watch',
      method: HttpMethodCustom.POST,
      body: body,
    );
    return json;
  }

  @override
  Future updateWatchBlogs({body}) async {
    final json = await appApiService.client?.requestApi(
      path: ApiRoutes.myBlogs + '/${body['id']}/watch',
      method: HttpMethodCustom.POST,
      body: body,
    );
    return json;
  }
}
