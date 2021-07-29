import 'dart:collection';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:html/parser.dart' as parser;
import 'package:keylol_flutter/common/global.dart';
import 'package:keylol_flutter/model/forum.dart';
import 'package:keylol_flutter/model/index.dart';
import 'package:keylol_flutter/model/profile.dart';
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
    var res = await _dio.get("/api/mobile/index.php",
        queryParameters: {'module': 'profile', 'uid': uid},
        options: buildCacheOptions(Duration(days: 1)));
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
    var forumMap = new HashMap<String, Forum>();
    for (var forumJson in (variables['forumlist'] as List<dynamic>)) {
      final forum = Forum.fromJson(forumJson);
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
  Future<List<ForumThread>> fetchForum(String fid, int page) async {
    var res = await _dio.get("/api/mobile/index.php",
        queryParameters: {'module': 'forumdisplay', 'fid': fid, 'page': page});

    var forumThreadList = res.data['Variables']['forum_threadlist'];

    return (forumThreadList as List<dynamic>)
        .map((forumThreadJson) => ForumThread.fromJson(forumThreadJson))
        .toList();
  }
}
