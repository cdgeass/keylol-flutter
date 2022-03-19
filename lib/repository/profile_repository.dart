import 'package:keylol_flutter/api/models/profile.dart';

class ProfileRepository {
  Profile? profile;

  List<Function(Profile? profile)> callbacks = [];

  void registerCallback(Function(Profile? profile) function) {
    callbacks.add(function);
  }

  void update(Profile? profile) {
    if (profile != this.profile) {
      this.profile = profile;
      for (var callback in callbacks) {
        callback.call(this.profile);
      }
    }
  }
}
