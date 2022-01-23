import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:image_picker/image_picker.dart';
import 'package:keylol_flutter/common/log.dart';
import 'package:keylol_flutter/common/provider.dart';
import 'package:keylol_flutter/models/allow_perm.dart';
import 'package:keylol_flutter/models/cat.dart';
import 'package:keylol_flutter/models/favorite_thread.dart';
import 'package:keylol_flutter/models/forum_display.dart';
import 'package:keylol_flutter/models/guide.dart';
import 'package:keylol_flutter/models/index.dart';
import 'package:keylol_flutter/models/notice.dart';
import 'package:keylol_flutter/models/post.dart';
import 'package:keylol_flutter/models/profile.dart';
import 'package:keylol_flutter/models/sec_code.dart';
import 'package:keylol_flutter/models/space.dart';
import 'package:keylol_flutter/models/view_thread.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_json/pretty_json.dart';

class _LoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final path = options.baseUrl + options.path;
    final parameters = options.queryParameters;
    Log().d('request => url: $path, parameters: $parameters');

    final data = options.data;
    if (data != null) {
      Log().d(
          'request => data: ${(data as FormData).fields.map((e) => '${e.key}: ${e.value}').toList()}');
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;
    final path = options.baseUrl + options.path;
    Log().d('response => url: $path');

    final statusCode = response.statusCode;
    var data = response.data;
    Log().d(
        'response => statusCode: $statusCode, data: ${(data is Map<String, dynamic>) ? prettyJson(data) : data}');

    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final path = options.baseUrl + options.path;

    Log().e('error => url: $path', err.error);

    handler.next(err);
  }
}

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

          ProfileProvider().update(profile);
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

          NoticeProvider().update(notice);
        }
      }
    }
  }
}

// 访问 keylol.com dio 单例
class KeylolClient {
  Dio dio = Dio();
  late CookieJar _cj;

  KeylolClient._internal();

  static late final _instance = KeylolClient._internal();

  factory KeylolClient() => _instance;

  Future<void> init() async {
    // 初始化 dio client
    dio = Dio(BaseOptions(
        baseUrl: "https://keylol.com", queryParameters: {'version': 4}));

    // app 目录
    final appDocDir = await getApplicationDocumentsDirectory();
    final appDocPath = appDocDir.path;

    // cookie持久化
    // _cj = PersistCookieJar(
    //     ignoreExpires: false, storage: FileStorage(appDocPath + "/.cookies/"));
    _cj = DefaultCookieJar();
    dio.interceptors.add(CookieManager(_cj));

    // 日志
    // dio.interceptors.add(_LoggerInterceptor());
    // 缓存
    dio.interceptors.add(
        DioCacheManager(CacheConfig(baseUrl: 'https://keylol.com'))
            .interceptor);
    // 解析返回里profile信息
    dio.interceptors.add(_ProfileInterceptor());
    // 解析返回里通知信息
    dio.interceptors.add(_NoticeInterceptor());
  }

  void clearCookies() {
    _cj.deleteAll();
  }

  Future<List<Cookie>> getCookies() {
    return _cj.loadForRequest(Uri.parse('https://keylol.com'));
  }

  // 首页
  Future<Index> fetchIndex() async {
    var res = await dio.get("");

    var document = parser.parse(res.data);

    return Index.fromDocument(document);
  }

  // 提醒列表
  Future<NoteList> fetchNoteList({int page = 1}) async {
    final res = await dio.post('/api/mobile/index.php',
        queryParameters: {'module': 'mynotelist', 'page': page});

    if (res.data['Message'] != null) {
      return Future.error(res.data['Message']?['messagestr']);
    }
    return NoteList.fromJson(res.data['Variables']);
  }

  // 权限
  Future<AllowPerm> checkPost() async {
    final res = await dio.post('/api/mobile/index.php',
        queryParameters: {'module': 'checkpost'});

    if (res.data['Message'] != null) {
      return Future.error(res.data['Message']?['messagestr']);
    }
    return AllowPerm.fromJson(res.data['Variables']['allowperm']);
  }
}

extension SpaceMod on KeylolClient {
  // 用户信息
  Future<Space> fetchProfile({String? uid, bool cached = true}) async {
    final queryParameters = {'module': 'profile'};
    if (uid != null) {
      queryParameters['uid'] = uid;
    }
    final res = await dio.get("/api/mobile/index.php",
        queryParameters: queryParameters,
        options: uid != null && cached
            ? buildCacheOptions(Duration(days: 1))
            : null);
    if (res.data['Message'] != null) {
      return Future.error(res.data['Message']?['messagestr']);
    }
    return Space.fromJson(res.data['Variables']?['space']);
  }

  // 好友
  Future<SpaceFriend> fetchFriend(String uid, {int page = 1}) async {
    final res = await dio.get('/api/mobile/index.php',
        queryParameters: {'module': 'friend', 'uid': uid, 'page': page});

    if (res.data['Message'] != null) {
      return Future.error(res.data['Message']?['messagestr']);
    }

    return SpaceFriend.fromJson(res.data['Variables']);
  }

  // 主题
  Future<SpaceThread> fetchSpaceThread(String uid, {int page = 1}) async {
    final res = await dio.get('/home.php', queryParameters: {
      'mod': 'space',
      'uid': uid,
      'do': 'thread',
      'view': 'me',
      'from': 'space',
      'type': 'thread',
      'page': page
    });

    final document = parser.parse(res.data);

    return SpaceThread.fromDocument(document);
  }

  // 回复
  Future<SpaceReply> fetchSpaceReply(String uid, {int page = 1}) async {
    final res = await dio.get('/home.php', queryParameters: {
      'mod': 'space',
      'uid': uid,
      'do': 'thread',
      'view': 'me',
      'from': 'space',
      'type': 'reply',
      'order': 'dateline',
      'page': page
    });

    final document = parser.parse(res.data);

    return SpaceReply.fromDocument(document);
  }
}

extension LoginMod on KeylolClient {
  /// 登录
  Future login(String username, String password) async {
    final res = await dio.post("/api/mobile/index.php",
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
    final res = await dio.get('/member.php', queryParameters: {
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
    final res = await dio.get('/misc.php',
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
    final res = await dio.get('/misc.php', queryParameters: {
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
    final res = await dio.post('/member.php',
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
    var res = await dio.get('/member.php',
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

    res = await dio.post('/plugin.php',
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
    await dio.post('/plugin.php',
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
    final res = await dio.post('/plugin.php',
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
}

extension ForumMod on KeylolClient {
  // 版块列表
  Future<List<Cat>> fetchForumIndex() async {
    var res = await dio.get("/api/mobile/index.php",
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
    var res = await dio.get("/api/mobile/index.php",
        queryParameters: queryParameters);

    if (res.data['Message'] != null) {
      return Future.error(res.data['Message']!['messagestr']);
    }
    return ForumDisplay.fromJson(res.data['Variables']);
  }
}

extension ThreadMod on KeylolClient {
  // 帖子详情
  Future<ViewThread> fetchThread(String tid, int page) async {
    var res = await dio.get("/api/mobile/index.php", queryParameters: {
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
  Future<void> sendReply(String tid, String message,
      {List<String> aidList = const []}) async {
    final res = await dio.post("/api/mobile/index.php",
        queryParameters: {
          'module': 'sendreply',
          'replysubmit': 'yes',
          'action': 'reply',
          'tid': tid
        },
        data: FormData.fromMap({
          'formhash': ProfileProvider().profile!.formHash,
          'message': message,
          'posttime': '${DateTime.now().millisecondsSinceEpoch}',
          'usesig': 1,
          for (final aid in aidList) 'attachnew[$aid][description]': aid,
        }));
    if (res.data['Message']?['messageval'] != 'post_reply_succeed') {
      final error = res.data['Message']?['messagestr'];
      return Future.error(error);
    }
  }

  // 回复回复
  Future<void> sendReplyForPost(Post post, String message,
      {List<String> aidList = const []}) async {
    final dateTime = DateTime.now();

    final res = await dio.post('/api/mobile/index.php',
        queryParameters: {
          'module': 'sendreply',
          'replysubmit': 'yes',
          'action': 'reply',
          'tid': post.tid,
          'reppid': post.pid,
        },
        data: FormData.fromMap({
          'formhash': ProfileProvider().profile!.formHash,
          'message': message,
          'noticetrimstr':
              '[quote][size=2][url=forum.php?mod=redirect&goto=findpost&pid=${post.pid}&ptid=${post.tid}][color=#999999]${post.author} 发表于 ${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute}[/color][/url][/size]${post.pureMessage()}[/quote]',
          'posttime': '${dateTime.millisecondsSinceEpoch}',
          'usesig': 1,
          for (final aid in aidList) 'attachnew[$aid][description]': aid,
        }));

    if (res.data['Message']?['messageval'] != 'post_reply_succeed') {
      final error = res.data['Message']?['messagestr'];
      return Future.error(error);
    }
  }

  // 投票
  Future<void> pollVote(String tid, List<String> pollAnswers) async {
    final res = await dio.post('/api/mobile/index.php',
        queryParameters: {
          'module': 'pollvote',
          'pollsubmit': 'yes',
          'action': 'votepoll',
          'tid': tid
        },
        data: FormData.fromMap({'pollanswers[]': pollAnswers}));

    if (res.data['Message']?['messageval'] != 'thread_poll_succeed') {
      final error = res.data['Message']?['messagestr'];
      return Future.error(error);
    }
  }

  // +1
  Future<void> recommend(String tid) async {
    final res = await dio.post('/api/mobile/index.php', queryParameters: {
      'module': 'recommend',
      'do': 'add',
      'tid': tid,
      'hash': ProfileProvider().profile?.formHash
    });
    if (res.data['Message']?['messageval'] != 'recommend_succeed') {
      final error = res.data['Message']?['messagestr'];
      return Future.error(error);
    }
  }

  // 加体力
  Future<void> rate(String tid, String pid, String score, String reason) async {
    await dio.post('/forum.php',
        queryParameters: {
          'mod': 'misc',
          'action': 'rate',
          'ratesubmit': 'yes',
          'infloat': 'yes',
          'inajax': '1'
        },
        data: FormData.fromMap({
          'tid': tid,
          'pid': pid,
          'handlekey': 'rate',
          'formhash': ProfileProvider().profile!.formHash,
          'referer':
              'https://keylol.com/forum.php?mod=viewthread&tid=$tid&page=0#pid$pid',
          'score1': score,
          'reason': reason
        }));
  }

  // 图片上传
  Future<String> fileUpload(XFile image) async {
    return await checkPost().then((allowPerm) async {
      final res = await dio.post('/api/mobile/index.php',
          queryParameters: {'module': 'forumupload', 'type': 'image'},
          data: FormData.fromMap({
            'uid': ProfileProvider().profile!.memberUid,
            'hash': allowPerm.uploadHash,
            'Filedata':
                await MultipartFile.fromFile(image.path, filename: image.name)
          }));
      return res.data;
    });
  }
}

extension FavoriteMod on KeylolClient {
  // 收藏帖子
  Future<void> favoriteThread(String tid, String description) async {
    final res = await dio.post('/api/mobile/index.php',
        queryParameters: {
          'module': 'favthread',
          'type': 'thread',
          'id': tid,
          'formhash': ProfileProvider().profile?.formHash,
        },
        data: FormData.fromMap({'description': description}));

    final messageStr = res.data['Message']?['messagestr'];
    if (messageStr != null) {
      if (messageStr.contains('成功')) {
        await fetchAllFavoriteThreads();
      } else {
        return Future.error(messageStr);
      }
    } else {
      return Future.error('出错啦');
    }
  }

  // 一次性获取所有收藏帖子
  Future<List<FavoriteThread>> fetchAllFavoriteThreads() async {
    List<FavoriteThread> favoriteThreads = [];

    var page = 1;
    while (true) {
      final list = await fetchFavoriteThreads(page++);
      if (list.isEmpty || list.length < 20) {
        break;
      }
      favoriteThreads.addAll(list);
    }

    FavoriteThreadsProvider().update(favoriteThreads);
    return favoriteThreads;
  }

  // 收藏的帖子
  Future<List<FavoriteThread>> fetchFavoriteThreads(int page) async {
    final res = await dio.post('/api/mobile/index.php',
        queryParameters: {'module': 'myfavthread', 'page': page});

    if (res.data['Message'] != null) {
      return Future.error(res.data['Message']!['messagestr']);
    }

    return (res.data['Variables']['list'] as List)
        .map((e) => FavoriteThread.fromJson(e))
        .toList();
  }

  // 删除收藏的帖子
  Future<void> deleteFavoriteThread(String favId) async {
    final res = await dio.post('/api/mobile/index.php', queryParameters: {
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
}

extension GuideMod on KeylolClient {
  Future<Guide> fetchGuide(String view, {int page = 1}) async {
    final res = await dio.get('/forum.php',
        queryParameters: {'mod': 'guide', 'view': view, 'page': page});

    final document = parser.parse(res.data);

    return Guide.fromDocument(document);
  }
}
