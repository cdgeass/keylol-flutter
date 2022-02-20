import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:html/parser.dart';
import 'package:keylol_flutter/common/keylol_client.dart';
import 'package:keylol_flutter/model/profile.dart';
import 'package:keylol_flutter/repository/repository.dart';
import 'package:path_provider/path_provider.dart';

import './models/models.dart';

// 统一拦截 keylol mobile 请求
abstract class _KeylolMobileInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (isSupported(response)) {
      doIntercept(response);
    }
    handler.next(response);
  }

  bool isSupported(Response response) {
    final uri = response.realUri;
    if (!uri.path.contains('/api/mobile/index.php')) {
      return false;
    }

    final queryParameters = response.requestOptions.queryParameters;
    if (queryParameters['module'] == 'profile' &&
        queryParameters['uid'] != null) {
      return false;
    }
    return true;
  }

  void doIntercept(Response response);
}

// profile 拦截器, 获取 profile 信息
class _ProfileInterceptor extends _KeylolMobileInterceptor {
  _ProfileInterceptor({required ProfileRepository profileRepository})
      : _profileRepository = profileRepository;

  final ProfileRepository _profileRepository;

  @override
  void doIntercept(Response<dynamic> response) {
    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final profileJson = data['Variables'];
        if (profileJson != null) {
          final profile = Profile.fromJson(profileJson);
          _profileRepository.profile = profile;
        }
      }
    }
  }
}

class KeylolApiClient {
  final CookieJar _cj;
  final Dio _dio;
  final ProfileRepository _profileRepository;

  static const _baseUrl = 'https://keylol.com';

  KeylolApiClient._internal(this._cj, this._dio, this._profileRepository);

  static Future<KeylolApiClient> create({
    required ProfileRepository profileRepository,
  }) async {
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

    // 解析返回里profile信息
    final profileInterceptor = _ProfileInterceptor(
      profileRepository: profileRepository,
    );
    dio.interceptors.add(profileInterceptor);

    return KeylolApiClient._internal(cj, dio, profileRepository);
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
      favoriteThreads.addAll(list);
      if (list.isEmpty || list.length < 20) {
        break;
      }
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
          'formhash': _profileRepository.profile?.formHash,
        },
        data: FormData.fromMap({'description': description}));

    if (res.data['Message']?['messageval'] != 'favorite_do_success') {
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
      'formhash': _profileRepository.profile?.formHash
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

  // 回复
  Future<void> sendReply({
    required String tid,
    required String message,
    List<String> aids = const [],
  }) async {
    final res = await _dio.post("/api/mobile/index.php",
        queryParameters: {
          'module': 'sendreply',
          'replysubmit': 'yes',
          'action': 'reply',
          'tid': tid
        },
        data: FormData.fromMap({
          'formhash': _profileRepository.profile?.formHash,
          'message': message,
          'posttime': '${DateTime.now().millisecondsSinceEpoch}',
          'usesig': 1,
          for (final aid in aids) 'attachnew[$aid][description]': aid,
        }));
    if (res.data['Message']?['messageval'] != 'post_reply_succeed') {
      final error = res.data['Message']?['messagestr'];
      return Future.error(error);
    }
  }

  // 回复回复
  Future<void> sendReplyForPost({
    required Post post,
    required String message,
    List<String> aids = const [],
  }) async {
    final dateTime = DateTime.now();

    final res = await _dio.post('/api/mobile/index.php',
        queryParameters: {
          'module': 'sendreply',
          'replysubmit': 'yes',
          'action': 'reply',
          'tid': post.tid,
          'reppid': post.pid,
        },
        data: FormData.fromMap({
          'formhash': _profileRepository.profile?.formHash,
          'message': message,
          'noticetrimstr':
              '[quote][size=2][url=forum.php?mod=redirect&goto=findpost&pid=${post.pid}&ptid=${post.tid}][color=#999999]${post.author} 发表于 ${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute}[/color][/url][/size]${post.pureMessage()}[/quote]',
          'posttime': '${dateTime.millisecondsSinceEpoch}',
          'usesig': 1,
          for (final aid in aids) 'attachnew[$aid][description]': aid,
        }));

    if (res.data['Message']?['messageval'] != 'post_reply_succeed') {
      final error = res.data['Message']?['messagestr'];
      return Future.error(error);
    }
  }
}
