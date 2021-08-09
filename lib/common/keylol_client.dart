import 'dart:collection';
import 'dart:typed_data';

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
import 'package:keylol_flutter/models/sec_code.dart';
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

  /// 登录
  Future login(String username, String password) async {
    final res = await _dio.post("/api/mobile/index.php",
        queryParameters: {
          'module': 'login',
          'action': 'login',
          'loginsubmit': 'yes',
        },
        data: FormData.fromMap({
          'username': username,
          'password': password,
          'answer': '',
          'questionid': '0'
        }));
    if (res.data['Message']!['messageval'] == 'login_succeed') {
      return fetchProfile()
          .then((profile) => Global.profileHolder.setProfile(profile));
    } else if (res.data['Message']!['messageval'] == 'login_seccheck2') {
      final auth = res.data['Variables']!['auth'];
      final formHash = res.data['Variables']!['formhash'];
      return fetchSecCodeParam(auth, formHash);
    } else {
      return Future.error(res.data['Message']!['messagestr']);
    }
  }

  // 验证码页面
  Future<SecCode> fetchSecCodeParam(String auth, String formHash) async {
    final res = await _dio.get('/member.php', queryParameters: {
      'mod': 'logging',
      'action': 'login',
      'auth': auth,
      'refer': 'https://keylol.com',
      'cookietime': 1
    });

    final document = parser.parse(res.data);
    final secCode = SecCode.fromDocument(document);
    secCode.auth = auth;
    secCode.formHash = formHash;
    return secCode;
  }

  // 获取验证码
  Future<Uint8List> fetchSecCode(String update, String idHash) async {
    final res = await _dio.get('/misc.php',
        options: Options(responseType: ResponseType.bytes, headers: {
          'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
          'Accept-Encoding': 'gzip, deflate, br',
          'Accept-Language': 'zh-CN,zh;q=0.9',
          'Connection': 'keep-alive',
          'hostname': 'https://keylol.com',
          'Referer': 'https://keylol.com/member.php?mod=logging&action=login',
          'Sec-Fetch-Mode': 'no-cors',
          'Sec-Fetch-Site': 'same-origin',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36'
        }),
        queryParameters: {
          'mod': 'seccode',
          'update': update,
          'idhash': idHash
        });

    return Uint8List.fromList(res.data);
  }

  // 验证码校验
  Future checkSecCode(String auth, String idHash, String secVerify) async {
    final res = await _dio.get('/misc.php', queryParameters: {
      'mod': 'seccode',
      'action': 'check',
      'inajax': 1,
      'idhash': idHash,
      'secverify': secVerify
    });

    if (!(res.data as String).contains('succeed')) {
      return Future.error('验证码错误');
    }
  }

  // 验证码登录
  Future loginWithSecCode(String auth, String formHash, String loginHash,
      String idHash, String secVerify) async {
    final res = await _dio.post('/member.php',
        queryParameters: {
          'mod': 'logging',
          'action': 'login',
          'loginsubmit': 'yes',
          'loginhash': loginHash,
          'inajax': 1
        },
        data: FormData.fromMap({
          'duceapp': 'yes',
          'formhash': formHash,
          'referer': 'https://keylol.com/',
          'handlekey': 'login',
          'auth': auth,
          'seccodehash': idHash,
          'seccodeverify': secVerify,
          'cookietime': 2592000
        }));

    final data = res.data as String;
    if (data.contains('succeedhandle_login')) {
      return fetchProfile()
          .then((profile) => Global.profileHolder.setProfile(profile));
    } else {
      return Future.error('登录出错');
    }
  }

  // 用户信息
  Future<Profile> fetchProfile({String? uid}) async {
    final queryParameters = {'module': 'profile'};
    if (uid != null) {
      queryParameters['uid'] = uid;
    }
    final res = await _dio.get(
      "/api/mobile/index.php",
      queryParameters: queryParameters,
    );
    if (res.data['Message'] != null) {
      return Future.error(res.data['Message']!['messagestr']);
    }
    return Profile.fromJson(res.data['Variables']);
  }

  // 首页
  Future<Index> fetchIndex() async {
    var res =
        await _dio.get("", options: buildCacheOptions(Duration(minutes: 1)));

    var document = parser.parse(res.data);

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

  // 回复
  Future sendReply(
      String fid, String tid, String formHash, String message) async {
    final res = await _dio.post("/api/mobile/index.php",
        queryParameters: {
          'module': 'sendreply',
          'replysubmit': 'yes',
          'action': 'reply',
          'fid': fid,
          'tid': tid
        },
        data: FormData.fromMap({
          'formhash': formHash,
          'message': message,
          'posttime': '${DateTime.now().millisecondsSinceEpoch}',
          'usesig': 1
        }));
    if (res.data['Message']!['messageval'] == 'post_reply_succeed') {
      return;
    } else {
      return Future.error(res.data['Message']!['messagestr']);
    }
  }

  // 投票
  Future sendPoll(String fid, String tid, String formHash,
      List<String> pollOptionIds) async {
    var res = await _dio.post("/api/mobile/index.php",
        queryParameters: {
          'module': 'pollvote',
          'pollsubmit': 'yes',
          'action': 'votepoll',
          'fid': fid,
          'tid': tid,
        },
        data: FormData.fromMap(
            {'formhash': formHash, 'pollanswers': pollOptionIds}));
  }
}
