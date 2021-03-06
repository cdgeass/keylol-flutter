import 'package:keylol_flutter/api/keylol_api.dart';

class FavThreadRepository {
  FavThreadRepository({required KeylolApiClient client}) : _client = client;

  final KeylolApiClient _client;

  List<FavThread>? _favThreads;

  // 加载收藏的帖子
  Future<List<FavThread>> load() async {
    if (_favThreads == null) {
      final favThreads = await _client.fetchFavThreads();
      _favThreads = favThreads;
    }
    return _favThreads!;
  }

  // 加载收藏的帖子
  Future<List<FavThread>> forceLoad() async {
    final favThreads = await _client.fetchFavThreads();
    _favThreads = favThreads;
    return _favThreads!;
  }

  // 收藏帖子
  Future<List<FavThread>> add({
    required Thread thread,
    required String description,
  }) async {
    if (fetchFavId(tid: thread.tid) != null) {
      return _favThreads!;
    }
    await _client.favThread(thread.tid, description);
    _favThreads = await _client.fetchFavThreads();
    return _favThreads!;
  }

  // 删除收藏
  Future<List<FavThread>> delete({required String favId}) async {
    await _client.deleteFavThread(favId);
    _favThreads = await _client.fetchFavThreads();
    return _favThreads!;
  }

  // 获取收藏帖子 favId
  String? fetchFavId({required String tid}) {
    for (final favThread in _favThreads!) {
      if (favThread.id == tid) {
        return favThread.favId;
      }
    }
    return null;
  }
}
