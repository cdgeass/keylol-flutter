import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/common/log.dart';
import 'package:keylol_flutter/models/profile.dart';

part 'authentication_event.dart';

part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final _logger = Log();

  AuthenticationBloc() : super(AuthenticationState.unauthenticated()) {
    on<AuthenticationSucceed>(_onSucceed);
  }

  Future<void> _onSucceed(
    AuthenticationSucceed event,
    Emitter<AuthenticationState> emit,
  ) async {
    final profile = event.profile;

    _logger.d('${profile.memberUsername} 登录');

    emit(AuthenticationState.authenticated(profile));
  }
}
