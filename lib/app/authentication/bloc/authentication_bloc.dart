import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:logger/logger.dart';

part 'authentication_event.dart';

part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final _logger = Logger();
  final KeylolApiClient _client;

  AuthenticationBloc({
    required KeylolApiClient client,
  })  : _client = client,
        super(AuthenticationState.unauthenticated()) {
    on<AuthenticationLoaded>(_onLoaded);
    on<AuthenticationLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoaded(
    AuthenticationLoaded event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      final profile = await _client.fetchProfile();

      _logger.d('${profile.memberUsername} 已登录');

      emit(AuthenticationState.authenticated(profile));
    } catch (error) {
      _logger.d('[授权] 获取用户信息出错', error);

      emit(AuthenticationState.unauthenticated());
    }
  }

  Future<void> _onLogoutRequested(
    AuthenticationEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    _client.clearCookies();
    emit(AuthenticationState.unauthenticated());
  }
}
