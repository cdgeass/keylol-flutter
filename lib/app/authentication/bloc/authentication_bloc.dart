import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/common/keylol_client.dart';
import 'package:keylol_flutter/common/log.dart';
import 'package:keylol_flutter/model/profile.dart';

part 'authentication_event.dart';

part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final _logger = Log();
  final Dio client;

  AuthenticationBloc({
    required this.client,
  }) : super(AuthenticationState.unauthenticated()) {
    on<AuthenticationLoaded>(_onLoaded);
    on<AuthenticationLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoaded(
    AuthenticationLoaded event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      final profile = await _fetchProfile();

      _logger.d('${profile.memberUsername} 已登录');

      emit(AuthenticationState.authenticated(profile));
    } catch (error) {
      _logger.d('获取用户信息错误', error);
      emit(AuthenticationState.unauthenticated());
    }
  }

  Future<void> _onLogoutRequested(
    AuthenticationEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    KeylolClient().clearCookies();
    emit(AuthenticationState.unauthenticated());
  }

  Future<Profile> _fetchProfile() async {
    final res = await client.get(
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
}
