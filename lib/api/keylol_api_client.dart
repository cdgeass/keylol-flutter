import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:html/parser.dart';
import 'package:keylol_flutter/common/keylol_client.dart';
import 'package:keylol_flutter/common/provider.dart';
import 'package:path_provider/path_provider.dart';

import './models/models.dart';

class KeylolApiClient {
  final CookieJar _cj;
  final Dio _dio;

  static const _baseUrl = 'https://keylol.com';

  KeylolApiClient._internal(this._cj, this._dio);

  static Future<KeylolApiClient> create() async {
    // 初始化 dio client
    final dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      queryParameters: {
        'version': 4,
      },
    ));

    // app 目录
    final appDocDir = await getApplicationDocumentsDirectory();
    final appDocPath = appDocDir.path;

    // cookie持久化
    // final cj = PersistCookieJar(
    //     ignoreExpires: false, storage: FileStorage(appDocPath + "/.cookies/"));
    final cj = KeylolClient().cj;
    dio.interceptors.add(CookieManager(cj));

    return KeylolApiClient._internal(cj, dio);
  }

  /// 获取首页信息
  Future<Index> fetchIndex() async {
    var res = await _dio.get("");
    var document = parse(res.data);
    return Index.fromDocument(document);
  }

  // 一次性获取所有收藏帖子
  Future<List<FavThread>> fetchFavThreads() async {
    List<FavThread> favoriteThreads = [];

    var page = 1;
    while (true) {
      final list = await _fetchFavThreads(page++);
      if (list.isEmpty || list.length < 20) {
        break;
      }
      favoriteThreads.addAll(list);
    }
    return favoriteThreads;
  }

  // 收藏的帖子
  Future<List<FavThread>> _fetchFavThreads(int page) async {
    final res = await _dio.post(
      '/api/mobile/index.php',
      queryParameters: {
        'module': 'myfavthread',
        'page': page,
      },
    );

    if (res.data['Message'] != null) {
      return Future.error(res.data['Message']!['messagestr']);
    }

    return (res.data['Variables']['list'] as List)
        .map((e) => FavThread.fromJson(e))
        .toList();
  }

  // 收藏帖子
  Future<void> favThread(String tid, String description) async {
    final res = await _dio.post('/api/mobile/index.php',
        queryParameters: {
          'module': 'favthread',
          'type': 'thread',
          'id': tid,
          'formhash': ProfileProvider().profile?.formHash,
        },
        data: FormData.fromMap({'description': description}));

    if (res.data['Message']?['messageval'] != 'do_success') {
      final error = res.data['Message']?['messagestr'];
      return Future.error(error);
    }
  }

  // 删除收藏的帖子
  Future<void> deleteFavThread(String favId) async {
    final res = await _dio.post('/api/mobile/index.php', queryParameters: {
      'module': 'favthread',
      'op': 'delete',
      'deletesubmit': 'true',
      'favid': favId,
      'formhash': ProfileProvider().profile?.formHash
    });

    if (res.data['Message']?['messageval'] != 'do_success') {
      final error = res.data['Message']?['messagestr'];
      return Future.error(error);
    }
  }

  // 获取帖子信息
  Future<ViewThread> fetchThread({required String tid, int page = 1}) async {
    var res = await _dio.get("/api/mobile/index.php", queryParameters: {
      'version': null,
      'module': 'viewthread',
      'tid': tid,
      'cp': 'all',
      'page': page
    });

    if (res.data['Message'] != null) {
      return Future.error(res.data['Message']?['messagestr']);
    }
    return ViewThread.fromJson(res.data['Variables']);
  }
}
