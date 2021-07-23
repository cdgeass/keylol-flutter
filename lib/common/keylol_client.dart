import 'dart:async';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:keylol_flutter/common/global.dart';
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
  }

  Future<Profile> fetchProfile() async {
    var res = await _dio
        .get("/api/mobile/index.php", queryParameters: {'module': 'profile'});
    if (res.statusCode != 200) {
      Future.error(res.data);
    }
    return Profile.fromJson(res.data['Variables']);
  }

  Future login(String username, String password) async {
    var formData = FormData.fromMap({
      'username': username,
      'password': password,
      'answer': '',
      'cookietime': '2592000',
      'handlekey': 'ls',
      'questionid': '0'
    });
    var res = await _dio.post("/api/mobile/index.php",
        queryParameters: {
          'module': 'login',
          'action': 'login',
          'loginsubmit': 'yes',
          'infloat': 'yes',
          'inajax': 1
        },
        data: formData);
    if (res.statusCode == 200) {
      var profile = await fetchProfile();
      Global.profileHolder.setProfile(profile);
    }
  }
}
