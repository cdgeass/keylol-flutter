import 'dart:async';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:keylol_flutter/common/global.dart';
import 'package:keylol_flutter/model/index.dart';
import 'package:keylol_flutter/model/profile.dart';
import 'package:path_provider/path_provider.dart';
import 'package:html/parser.dart' as parser;

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
  Future<Profile> fetchProfile() async {
    try {
      var res = await _dio
          .get("/api/mobile/index.php", queryParameters: {'module': 'profile'});
      return Profile.fromJson(res.data['Variables']);
    } on DioError catch (e) {
      throw e;
    }
  }

  // 首页
  Future<Index> fetchIndex() async {
    var res = await _dio.get("");

    var document = parser.parse(res.data as String);

    return Index.fromDocument(document);
  }
}
