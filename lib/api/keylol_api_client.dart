import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:html/parser.dart';
import 'package:image_picker/image_picker.dart';
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
    if (queryParameters['module'] == 'space' &&
        queryParameters['uid'] != null) {
      return false;
    }
    return true;
  }

  void doIntercept(Response response);
}

// space 拦截器, 获取 space 信息
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
          _profileRepository.update(profile);
        }
      }
    }
  }
}

// 通知拦截器, 获取 notice 信息
class _NoticeInterceptor extends _KeylolMobileInterceptor {
  _NoticeInterceptor({required NoticeRepository noticeRepository})
      : _noticeRepository = noticeRepository;

  final NoticeRepository _noticeRepository;

  @override
  void doIntercept(Response<dynamic> response) {
    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final noticeJson = data['Variables']?['notice'];
        if (noticeJson != null) {
          final notice = Notice.fromJson(noticeJson);
          _noticeRepository.update(notice);
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

  KeylolApiClient._internal(
    this._cj,
    this._dio,
    this._profileRepository,
  );

  static Future<KeylolApiClient> create({
    required ProfileRepository profileRepository,
    required NoticeRepository noticeRepository,
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
    final cj = PersistCookieJar(
        ignoreExpires: false, storage: FileStorage(appDocPath + "/.cookies/"));
    dio.interceptors.add(CookieManager(cj));

    // 解析返回里profile信息
    final profileInterceptor = _ProfileInterceptor(
      profileRepository: profileRepository,
    );
    dio.interceptors.add(profileInterceptor);

    // 解析返回里notice信息
    final noticeInterceptor = _NoticeInterceptor(
      noticeRepository: noticeRepository,
    );
    dio.interceptors.add(noticeInterceptor);

    return KeylolApiClient._internal(cj, dio, profileRepository);
  }

  // 获取首页信息
  Future<Index> fetchIndex() async {
    var res = await _dio.get("");
    var document = parse(res.data);
    return Index.fromDocument(document);
  }

  // 获取个人信息
  Future<Profile> fetchProfile() async {
    final res = await _dio.get(
      "/api/mobile/index.php",
      queryParameters: {
        'module': 'profile',
      },
    );
    if (res.data['Message'] != null) {
      return Future.error(res.data['Message']?['messagestr']);
    }
    return Profile.fromJson(res.data['Variables']);
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

  // 权限
  Future<AllowPerm> checkPost() async {
    final res = await _dio.post('/api/mobile/index.php',
        queryParameters: {'module': 'checkpost'});

    if (res.data['Message'] != null) {
      return Future.error(res.data['Message']?['messagestr']);
    }
    return AllowPerm.fromJson(res.data['Variables']['allowperm']);
  }

  // 图片上传
  Future<String> fileUpload(XFile image) async {
    return await checkPost().then((allowPerm) async {
      final res = await _dio.post('/api/mobile/index.php',
          queryParameters: {'module': 'forumupload', 'type': 'image'},
          data: FormData.fromMap({
            // 'uid': ProfileProvider().profile!.memberUid,
            'hash': allowPerm.uploadHash,
            'Filedata':
            await MultipartFile.fromFile(image.path, filename: image.name)
          }));
      return res.data;
    });
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
              '[quote][size=2][url=forum.php?mod=redirect&goto=findpost&pid=${post.pid}&ptid=${post.tid}][color=#999999]${post.author} 发表于 ${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute}[/color][/url][/size]<br/>${post.pureMessage()}[/quote]',
          'posttime': '${dateTime.millisecondsSinceEpoch}',
          'usesig': 1,
          for (final aid in aids) 'attachnew[$aid][description]': aid,
        }));

    if (res.data['Message']?['messageval'] != 'post_reply_succeed') {
      final error = res.data['Message']?['messagestr'];
      return Future.error(error);
    }
  }

  // 投票
  Future<void> pollVote(String tid, List<String> pollAnswers) async {
    final res = await _dio.post('/api/mobile/index.php',
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
}

extension CookieModule on KeylolApiClient {

  void clearCookies() {
    _cj.deleteAll();
  }

  Future<List<Cookie>> getCookies() async {
    return await _cj.loadForRequest(Uri.parse('https://keylol.com'));
  }
}

extension LoginModuleWithSms on KeylolApiClient {
  // 获取图形验证码参数
  Future<SecCode> fetchSmsSecCodeParam(String cellphone) async {
    var res = await _dio.get('/member.php',
        queryParameters: {'mod': 'logging', 'action': 'login'});

    var document = parse(res.data);
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

    document = parse(res.data);
    final secCode = SecCode.fromDocument(document);
    secCode.formHash = formHash;
    return secCode;
  }

  // 获取图形验证码
  Future<Uint8List> fetchSmsSecCode({
    required String update,
    required String idHash,
  }) async {
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

  // 发送登录短信
  Future<void> sendSms(
    SecCode secCodeParam,
    String cellphone,
    String secCodeVerify,
  ) async {
    final res = await _dio.post('/plugin.php',
        queryParameters: {
          'id': 'duceapp_smsauth',
          'ac': 'sendcode',
          'handlekey': 'sendsmscode',
          'smscodesubmit': 'login',
          'inajax': 1,
          'loginhash': secCodeParam.loginHash
        },
        data: FormData.fromMap({
          'formhash': secCodeParam.formHash,
          'smscodesubmit': 'login',
          'cellphone': cellphone,
          'smsauth': 'yes',
          'seccodehash': secCodeParam.currentIdHash,
          'seccodeverify': secCodeVerify
        }));

    final data = res.data as String;
    if (data.contains('errorhandle_sendsmscode')) {
      return Future.error('抱歉，验证码填写错误');
    }
  }

  // 登录
  Future<Profile> loginWithSms({
    required SecCode secCodeParam,
    required String cellphone,
    required String sms,
  }) async {
    final res = await _dio.post('/plugin.php',
        queryParameters: {
          'id': 'duceapp_smsauth',
          'ac': 'login',
          'loginsubmit': 'yes',
          'loginhash': secCodeParam.loginHash,
          'inajax': 1
        },
        data: FormData.fromMap({
          'duceapp': 'yes',
          'formhash': secCodeParam.formHash,
          'referer': 'https://keylol.com',
          'lssubmit': 'yes',
          'loginfield': 'auto',
          'cellphone': cellphone,
          'smscode': sms
        }));

    final data = res.data as String;
    if (data.contains('succeedhandle_login')) {
      // 登录成功
      return fetchProfile()
          .then((_) => _profileRepository.profile!);
    }
    // 登录失败
    return Future.error('登录失败');
  }
}

extension LoginModuleWithPassword on KeylolApiClient {
  // 登录
  Future<SecCode?> loginWithPassword({
    required String username,
    required String password,
  }) async {
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
      return Future.value(null);
    } else if (res.data['Message']?['messageval'] == 'login_seccheck2') {
      // 需要验证码 走网页验证码登录
      final auth = res.data['Variables']!['auth'];
      final formHash = res.data['Variables']!['formhash'];
      return fetchPasswordSecCodeParam(auth: auth, formHash: formHash);
    } else {
      // 登录失败
      return Future.error(res.data['Message']?['messagestr']);
    }
  }

  // 验证码页面
  Future<SecCode> fetchPasswordSecCodeParam({
    String? auth,
    required String formHash,
  }) async {
    final res = await _dio.get('/member.php', queryParameters: {
      'mod': 'logging',
      'action': 'login',
      'auth': auth,
      'refer': 'https://keylol.com',
      'cookietime': 1
    });

    final document = parse(res.data);
    final secCode = SecCode.fromDocument(document);
    if (auth != null) {
      secCode.auth = auth;
    }
    secCode.formHash = formHash;
    return secCode;
  }

  // 获取验证码
  Future<Uint8List> fetchPasswordSecCode({
    required String update,
    required String idHash,
  }) async {
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
  Future<void> checkSecCode({
    required String auth,
    required String idHash,
    required String secVerify,
  }) async {
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
  Future<void> loginWithPasswordSecCode({
    required String auth,
    required String formHash,
    required String loginHash,
    required String idHash,
    required String secVerify,
  }) async {
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
      return;
    } else {
      return Future.error('登录出错');
    }
  }
}

extension GuideModule on KeylolApiClient {
  Future<Guide> fetchGuide({required String type, int page = 1}) async {
    final res = await _dio.get('/forum.php',
        queryParameters: {'mod': 'guide', 'view': type, 'page': page});
    final document = parse(res.data);
    return Guide.fromDocument(document);
  }
}

extension ForumModule on KeylolApiClient {
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

  Future<ForumDisplay> fetchForum({
    required String fid,
    int page = 0,
    String? filter,
    String? typeId,
    Map<String, String>? param,
  }) async {
    final queryParameters = {
      'module': 'forumdisplay',
      'fid': fid,
      'page': page,
    };

    if (typeId != null) {
      queryParameters.addAll({'filter': 'typeid', 'typeid': typeId});
    } else if (filter != null && param != null) {
      queryParameters['filter'] = filter;
      queryParameters.addAll(param);
    }

    var res = await _dio.get("/api/mobile/index.php",
        queryParameters: queryParameters);

    if (res.data['Message'] != null) {
      return Future.error(res.data['Message']!['messagestr']);
    }
    return ForumDisplay.fromJson(res.data['Variables']);
  }
}

extension NoticeModuel on KeylolApiClient {

  Future<NoteList> fetchNoteList({required int page}) async {
    final res = await _dio.post('/api/mobile/index.php',
        queryParameters: {'module': 'mynotelist', 'page': page});

    if (res.data['Message'] != null) {
      return Future.error(res.data['Message']?['messagestr']);
    }
    return NoteList.fromJson(res.data['Variables']);
  }
}

extension SpaceModule on KeylolApiClient {
  // 用户信息
  Future<Space> fetchSpace({String? uid, bool cached = true}) async {
    final res = await _dio.get("/api/mobile/index.php",
        queryParameters: {
          'module': 'profile',
          'uid': uid,
        },
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
    final res = await _dio.get('/api/mobile/index.php',
        queryParameters: {'module': 'friend', 'uid': uid, 'page': page});

    if (res.data['Message'] != null) {
      return Future.error(res.data['Message']?['messagestr']);
    }

    return SpaceFriend.fromJson(res.data['Variables']);
  }

  // 主题
  Future<SpaceThread> fetchSpaceThread(String uid, {int page = 1}) async {
    final res = await _dio.get('/home.php', queryParameters: {
      'mod': 'space',
      'uid': uid,
      'do': 'thread',
      'view': 'me',
      'from': 'space',
      'type': 'thread',
      'page': page
    });

    final document = parse(res.data);

    return SpaceThread.fromDocument(document);
  }

  // 回复
  Future<SpaceReply> fetchSpaceReply(String uid, {int page = 1}) async {
    final res = await _dio.get('/home.php', queryParameters: {
      'mod': 'space',
      'uid': uid,
      'do': 'thread',
      'view': 'me',
      'from': 'space',
      'type': 'reply',
      'order': 'dateline',
      'page': page
    });

    final document = parse(res.data);

    return SpaceReply.fromDocument(document);
  }
}
