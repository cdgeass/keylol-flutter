import 'dart:async';

import 'package:keylol_flutter/api/keylol_api.dart';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class AuthenticationRepository {
  final _controller = StreamController<AuthenticationStatus>();
  final KeylolApiClient _client;

  Profile? _profile;

  AuthenticationRepository({required KeylolApiClient client})
      : _client = client;

  Stream<AuthenticationStatus> get status async* {
    yield AuthenticationStatus.unauthenticated;
    yield* _controller.stream;
  }

  Profile? get profile => _profile;

  set profile(Profile? profile) {
    _profile = profile;
    if (_profile?.memberUid == null || _profile?.memberUid == '0') {
      logOut();
    } else {
      _controller.add(AuthenticationStatus.authenticated);
    }
  }

  Future<void> logIn() async {
    Profile? profile;
    try {
      profile = await _client.fetchProfile();
    } catch (e) {
      profile = null;
    }
    _profile = profile;
    if (_profile?.memberUid == null || _profile?.memberUid == '0') {
      _controller.add(AuthenticationStatus.unauthenticated);
    } else {
      _controller.add(AuthenticationStatus.authenticated);
    }
  }

  void logOut() {
    _profile = null;
    _client.clearCookies();
    _controller.add(AuthenticationStatus.unauthenticated);
  }

  void dispose() {
    _controller.close();
  }
}
