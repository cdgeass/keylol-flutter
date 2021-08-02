import 'dart:collection';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:html/parser.dart' as parser;
import 'package:keylol_flutter/common/global.dart';
import 'package:keylol_flutter/models/cat.dart';
import 'package:keylol_flutter/models/forum_display.dart';
import 'package:keylol_flutter/models/index.dart';
import 'package:keylol_flutter/models/profile.dart';
import 'package:keylol_flutter/models/view_thread.dart';
import 'package:path_provider/path_provider.dart';

class KeylolClient {
  late Dio _dio;
  late CookieJar cj;

  Future<void> init() async {
    _dio = Dio(BaseOptions(
        baseUrl: "https://keylol.com", queryParameters: {'version': 4}));

    var appDocDir = await getApplicationDocumentsDirectory();
    var appDocPath = appDocDir.path;

    cj = PersistCookieJar(
        ignoreExpires: false, storage: FileStorage(appDocPath + "/.cookies/"));
    _dio.interceptors.add(CookieManager(cj));
    _dio.interceptors.add(
        DioCacheManager(CacheConfig(baseUrl: 'https://keylol.com'))
            .interceptor);
  }

  /// 登陆
  Future login(String username, String password) {
    var formData = FormData.fromMap({
      'username': username,
      'password': password,
      'answer': '',
      'questionid': '0'
    });
    var resFuture = _dio.post("/api/mobile/index.php",
        queryParameters: {
          'module': 'login',
          'action': 'login',
          'loginsubmit': 'yes'
        },
        data: formData);
    return resFuture.then((res) {
      return fetchProfile()
          .then((profile) => Global.profileHolder.setProfile(profile));
    });
  }

  // 用户信息
  Future<Profile> fetchProfile({String? uid}) async {
    final queryParameters = {'module': 'profile'};
    if (uid != null) {
      queryParameters['uid'] = uid;
    }
    var res = await _dio.get(
      "/api/mobile/index.php",
      queryParameters: queryParameters,
    );
    return Profile.fromJson(res.data['Variables']);
  }

  // 首页
  Future<Index> fetchIndex() async {
    var res =
        await _dio.get("", options: buildCacheOptions(Duration(minutes: 1)));

    var document = parser.parse(res.data as String);

    return Index.fromDocument(document);
  }

  // 版块列表
  Future<List<Cat>> fetchForumIndex() async {
    var res = await _dio.get("/api/mobile/index.php",
        queryParameters: {'module': 'forumindex'},
        options: buildCacheOptions(Duration(days: 7)));

    var variables = res.data['Variables'];
    var forumMap = new HashMap<String, CatForum>();
    for (var forumJson in (variables['forumlist'] as List<dynamic>)) {
      final forum = CatForum.fromJson(forumJson);
      forumMap[forum.fid!] = forum;
    }

    return (variables['catlist'] as List<dynamic>).map((catJson) {
      final cat = Cat.fromJson(catJson);
      final forums = (catJson['forums'] as List<dynamic>)
          .map((fid) => forumMap[fid]!)
          .toList();
      cat.forums = forums;
      return cat;
    }).toList();
  }

  // 板块帖子列表
  Future<ForumDisplay> fetchForum(
      String fid, int page, String filter, Map<String, String> param) async {
    final queryParameters = {
      'module': 'forumdisplay',
      'fid': fid,
      'page': page,
      'filter': filter,
    };
    queryParameters.addAll(param);
    var res = await _dio.get("/api/mobile/index.php",
        queryParameters: queryParameters);

    return ForumDisplay.fromJson(res.data['Variables']);
  }

  // 帖子详情
  Future<ViewThread> fetchThread(String tid, int page) async {
    var res = await _dio.get("/api/mobile/index.php",
        queryParameters: {'module': 'viewthread', 'tid': tid, 'page': page});

    return ViewThread.fromJson(res.data['Variables']);
  }
}
