import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/keylol_client.dart';
import 'package:keylol_flutter/models/profile.dart';

class Global {
  static final keylolClient = KeylolClient();

  // 用户信息
  static final profileHolder = ProfileHolder();

  static Future init() async {
    await keylolClient.init();

    var profile = await keylolClient.fetchProfile();
    profileHolder.setProfile(profile);
  }

  static logout() {
    keylolClient.cj.deleteAll();
    profileHolder.setProfile(null);
  }
}

class ProfileHolder extends ChangeNotifier {
  Profile? profile;

  void setProfile(Profile? profile) {
    // auth 为空则未成功登录
    this.profile = profile?.auth == null ? null : profile;
    notifyListeners();
  }
}
