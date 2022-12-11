import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';

class CheckVersion {
  final _url =
      'https://api.github.com/repos/cdgeass/keylol_flutter/releases/latest';
  final _dio = Dio();

  Future<String?> checkVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final version = packageInfo.version.split('.');

    try {
      final res = await _dio.get(_url);
      final tag = res.data['tag_name'] as String;
      final newVersion = tag.replaceFirst('v', '').split('.');

      for (var i = 0; i < 3; i++) {
        final i1 = int.parse(version[i]);
        final i2 = int.parse(newVersion[i]);
        if (i1 < i2) {
          return 'https://github.com/cdgeass/keylol-flutter/releases/latest';
        } else if (i1 > i2) {
          return null;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
