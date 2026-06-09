import 'package:kairete/config/api_paths.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/profile/models/user_profile.dart';

class ProfileService {
  XenforoApi get _api => AppApi.instance.xenforo;

  Future<UserProfile> fetchUser(int userId) async {
    await AppApi.instance.applySession();
    final json = await _api.get('${ApiPaths.users}/$userId');
    _throwIfError(json);
    return UserProfile.fromJson(json);
  }

  Future<OmnifeedFeed> fetchUserFeed({
    required int userId,
    int page = 1,
    String sort = 'post_date',
  }) async {
    await AppApi.instance.applySession();
    final json = await _api.get(
      ApiPaths.newsfeedUserFeed,
      query: {
        'id': userId,
        'page': page,
        'limit': 20,
        'sort': sort,
      },
    );
    _throwIfError(json);
    return OmnifeedFeed.fromJson(json);
  }

  Future<bool> followUser(int userId, {required bool stop}) async {
    await AppApi.instance.applySession();
    final json = await _api.post(
      '${ApiPaths.users}/$userId/follow',
      body: stop ? {'stop': true} : {},
    );
    _throwIfError(json);
    final action = json['action']?.toString() ?? '';
    if (action == 'follow') return true;
    if (action == 'unfollow') return false;
    return !stop;
  }

  void _throwIfError(Map<String, dynamic> json) {
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null) throw ProfileException(err);
  }
}

class ProfileException implements Exception {
  ProfileException(this.message);
  final String message;

  @override
  String toString() => message;
}
