import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:html/parser.dart' as parser;
import 'package:keylol_flutter/common/notifiers.dart';
import 'package:keylol_flutter/models/cat.dart';
import 'package:keylol_flutter/models/favorite_thread.dart';
import 'package:keylol_flutter/models/forum_display.dart';
import 'package:keylol_flutter/models/index.dart';
import 'package:keylol_flutter/models/notice.dart';
import 'package:keylol_flutter/models/profile.dart';
import 'package:keylol_flutter/models/sec_code.dart';
import 'package:keylol_flutter/models/space.dart';
import 'package:keylol_flutter/models/thread.dart';
import 'package:keylol_flutter/models/view_thread.dart';
import 'package:path_provider/path_provider.dart';

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
  _ProfileInterceptor();

  @override
  void doIntercept(Response<dynamic> response) {
    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final profileJson = data['Variables'];
        if (profileJson != null) {
          final profile = Profile.fromJson(profileJson);

          ProfileNotifier().update(profile);
        }
      }
    }
  }
}

// 通知拦截器, 获取 notice 信息
class _NoticeInterceptor extends _KeylolMobileInterceptor {
  _NoticeInterceptor();

  @override
  void doIntercept(Response<dynamic> response) {
    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final noticeJson = data['Variables']?['notice'];
        if (noticeJson != null) {
          final notice = Notice.fromJson(noticeJson);

          NoticeNotifier().update(notice);
        }
      }
    }
  }
}

// 访问 keylol.com dio 单例
class KeylolClient {
  late Dio _dio;
  late CookieJar _cj;

  KeylolClient._internal();

  static late final _instance = KeylolClient._internal();

  factory KeylolClient() => _instance;

  Future<void> init() async {
    // 初始化 dio client
    _dio = Dio(BaseOptions(
        baseUrl: "https://keylol.com", queryParameters: {'version': 4}));

    // app 目录
    final appDocDir = await getApplicationDocumentsDirectory();
    final appDocPath = appDocDir.path;

    // cookie持久化
    _cj = PersistCookieJar(
        ignoreExpires: false, storage: FileStorage(appDocPath + "/.cookies/"));
    _dio.interceptors.add(CookieManager(_cj));

    // 缓存
    _dio.interceptors.add(
        DioCacheManager(CacheConfig(baseUrl: 'https://keylol.com'))
            .interceptor);
    // 解析返回里profile信息
    _dio.interceptors.add(_ProfileInterceptor());
    // 解析返回里通知信息
    _dio.interceptors.add(_NoticeInterceptor());
  }

  void clearCookies() {
    _cj.deleteAll();
  }

  Future<List<Cookie>> getCookies() {
    return _cj.loadForRequest(Uri.parse('https://keylol.com'));
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

    if (res.data['Message']?['messageval'] == 'login_succeed') {
      return fetchProfile();
    } else if (res.data['Message']?['messageval'] == 'login_seccheck2') {
      // 需要验证码 走网页验证码登录
      final auth = res.data['Variables']!['auth'];
      final formHash = res.data['Variables']!['formhash'];
      return fetchSecCodeParam(auth, formHash);
    } else {
      // 登录失败
      return Future.error(res.data['Message']?['messagestr']);
    }
  }

  // 验证码页面
  Future<SecCode> fetchSecCodeParam(String? auth, String formHash) async {
    final res = await _dio.get('/member.php', queryParameters: {
      'mod': 'logging',
      'action': 'login',
      'auth': auth,
      'refer': 'https://keylol.com',
      'cookietime': 1
    });

    final document = parser.parse(res.data);
    final secCode = SecCode.fromDocument(document);
    if (auth != null) {
      secCode.auth = auth;
    }
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
      return fetchProfile();
    } else {
      return Future.error('登录出错');
    }
  }

  // 获取短信发送验证码参数
  Future<SecCode> fetchSmsSecCodeParam(String cellphone) async {
    var res = await _dio.get('/member.php',
        queryParameters: {'mod': 'logging', 'action': 'login'});

    var document = parser.parse(res.data);
    final inputs = document.getElementsByTagName('input');
    late String formHash;
    for (var input in inputs) {
      if (input.attributes['name'] == 'formhash') {
        formHash = input.attributes['value'] ?? '';
        break;
      }
    }
    late String loginHash;
    final pwLoginTypes = document.getElementsByClassName('pwLogintype');
    final actionExp = pwLoginTypes.first
            .getElementsByTagName('li')
            .first
            .attributes['_action'] ??
        '';
    if (actionExp.isNotEmpty) {
      final lastIndexOfEqual = actionExp.lastIndexOf('=');
      loginHash = actionExp.substring(lastIndexOfEqual + 1);
    }

    res = await _dio.post('/plugin.php',
        queryParameters: {
          'id': 'duceapp_smsauth',
          'ac': 'sendcode',
          'handlekey': 'sendsmscode',
          'smscodesubmit': 'login',
          'inajax': 1,
          'loginhash': loginHash
        },
        data: FormData.fromMap({
          'duceapp': 'yes',
          'formhash': formHash,
          'referer': 'https://keylol.com',
          'lssubmit': 'yes',
          'loginfield': 'auto',
          'cellphone': cellphone,
        }));

    document = parser.parse(res.data);
    final secCode = SecCode.fromDocument(document);
    secCode.formHash = formHash;
    return secCode;
  }

  // 发送验证码
  Future sendSmsCode(String loginHash, String formHash, String cellphone,
      String secCodeHash, String secCodeVerify) async {
    await _dio.post('/plugin.php',
        queryParameters: {
          'id': 'duceapp_smsauth',
          'ac': 'sendcode',
          'handlekey': 'sendsmscode',
          'smscodesubmit': 'login',
          'inajax': 1,
          'loginhash': loginHash
        },
        data: FormData.fromMap({
          'formhash': formHash,
          'smscodesubmit': 'login',
          'cellphone': cellphone,
          'smsauth': 'yes',
          'seccodehash': secCodeHash,
          'seccodeverify': secCodeVerify
        }));
  }

  // 短信验证码登录
  Future loginWithSms(String loginHash, String formHash, String cellphone,
      String smsCode) async {
    final res = await _dio.post('/plugin.php',
        queryParameters: {
          'id': 'duceapp_smsauth',
          'ac': 'login',
          'loginsubmit': 'yes',
          'loginhash': loginHash,
          'inajax': 1
        },
        data: FormData.fromMap({
          'duceapp': 'yes',
          'formhash': formHash,
          'referer': 'https://keylol.com',
          'lssubmit': 'yes',
          'loginfield': 'auto',
          'cellphone': cellphone,
          'smscode': smsCode
        }));

    final data = res.data as String;
    if (data.contains('succeedhandle_login')) {
      return fetchProfile();
    } else {
      return Future.error('登录出错');
    }
  }

  // 用户信息
  Future<Space> fetchProfile({String? uid, bool cached = true}) async {
    final queryParameters = {'module': 'profile'};
    if (uid != null) {
      queryParameters['uid'] = uid;
    }
    final res = await _dio.get("/api/mobile/index.php",
        queryParameters: queryParameters,
        options: uid != null && cached
            ? buildCacheOptions(Duration(days: 1))
            : null);
    if (res.data['Message'] != null) {
      return Future.error(res.data['Message']!['messagestr']);
    }
    return Space.fromJson(res.data['Variables']?['space']);
  }

  // 首页
  Future<Index> fetchIndex() async {
    var res = await _dio.get("");

    var document = parser.parse(res.data);

    return Index.fromDocument(document);
  }

  // 版块列表
  Future<List<Cat>> fetchForumIndex() async {
    var res = await _dio.get("/api/mobile/index.php",
        queryParameters: {'module': 'forumindex'});

    var variables = res.data['Variables'];

    var forumMap = new HashMap<String, CatForum>();
    for (var forumJson in (variables['forumlist'] as List<dynamic>)) {
      final forum = CatForum.fromJson(forumJson);
      forumMap[forum.fid] = forum;
    }

    if (res.data['Message'] != null) {
      return Future.error(res.data['Message']!['messagestr']);
    }
    return (variables['catlist'] as List<dynamic>).map((catJson) {
      final cat = Cat.fromJson(catJson);
      List<CatForum> forums = (catJson['forums'] as List<dynamic>)
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

    if (res.data['Message'] != null) {
      return Future.error(res.data['Message']!['messagestr']);
    }
    return ForumDisplay.fromJson(res.data['Variables']);
  }

  // 帖子详情
  Future<ViewThread> fetchThread(String tid, int page) async {
    var res = await _dio.get("/api/mobile/index.php",
        queryParameters: {'module': 'viewthread', 'tid': tid, 'page': page});

    if (res.data['Message'] != null) {
      return Future.error(res.data['Message']!['messagestr']);
    }
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

  // 提醒列表
  Future<NoteList> fetchNoteList({int page = 1}) async {
    final res = await _dio.post('/api/mobile/index.php',
        queryParameters: {'module': 'mynotelist', 'page': page});

    if (res.data['Message'] != null) {
      return Future.error(res.data['Message']!['messagestr']);
    }
    return NoteList.fromJson(res.data['Variables']);
  }

  // 表情
  Future<List<dynamic>> fetchSmiley() async {
    final res = await _dio
        .post('/api/mobile/index.php', queryParameters: {'module': 'smiley'});

    if (res.data['Message'] != null) {
      return Future.error(res.data['Message']!['messagestr']);
    }
    return res.data['Variables'];
  }

  // 热帖
  Future<List<Thread>> fetchHotThread({int page = 1}) async {
    final res = await _dio.post('/api/mobile/index.php',
        queryParameters: {'module': 'hotthread', 'page': page});

    if (res.data['Message'] != null) {
      return Future.error(res.data['Message']!['messagestr']);
    }
    return (res.data['Variables']['data'] as List)
        .map((e) => Thread.fromJson(e))
        .toList();
  }

  // 收藏帖子
  Future<void> favoriteThread(String tid, String description) async {
    final res = await _dio.post('/api/mobile/index.php',
        queryParameters: {
          'module': 'favthread',
          'type': 'thread',
          'formhash': ProfileNotifier().profile?.formHash,
          'id': tid,
        },
        data: FormData.fromMap({'description': description}));

    // if (res.data['Message'] != null) {
    //   return Future.error(res.data['Message']!['messagestr']);
    // }
  }

  // 一次性获取所有收藏帖子
  Future<List<FavoriteThread>> fetchAllFavoriteThreads() async {
    List<FavoriteThread> favoriteThreads = [];

    var page = 1;
    while (true) {
      final list = await fetchFavoriteThreads(page++);
      if (list.isEmpty) {
        break;
      }
      favoriteThreads.addAll(list);
    }

    return favoriteThreads;
  }

  // 收藏的帖子
  Future<List<FavoriteThread>> fetchFavoriteThreads(int page) async {
    final res = await _dio.post('/api/mobile/index.php',
        queryParameters: {'module': 'myfavthread', 'page': page});

    if (res.data['Message'] != null) {
      return Future.error(res.data['Message']!['messagestr']);
    }

    return (res.data['Variables']['list'] as List)
        .map((e) => FavoriteThread.fromJson(e))
        .toList();
  }
}
