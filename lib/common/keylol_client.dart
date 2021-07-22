import 'dart:async';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:keylol_flutter/model/profile.dart';
import 'package:path_provider/path_provider.dart';

class KeylolClient {
  static late Dio _dio;

  static Future<void> init() async {
    _dio = Dio(BaseOptions(
        baseUrl: "https://keylol.com", queryParameters: {'version': 4}));

    var appDocDir = await getApplicationDocumentsDirectory();
    var appDocPath = appDocDir.path;

    var cj = PersistCookieJar(
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
}
