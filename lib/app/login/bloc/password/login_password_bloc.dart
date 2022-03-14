import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:keylol_flutter/api/models/sec_code.dart';
import 'package:keylol_flutter/common/log.dart';

part 'login_password_event.dart';

part 'login_password_state.dart';

class LoginPasswordBloc extends Bloc<LoginPasswordEvent, LoginPasswordState> {
  final _logger = Log();
  final KeylolApiClient client;

  LoginPasswordBloc({
    required this.client,
  }) : super(LoginPasswordState(status: LoginPasswordStatus.initial)) {
    on<LoginPasswordSubmitted>(_onSubmitted);
    on<LoginPasswordSecCodeLoaded>(_onSecCodeLoaded);
  }

  Future<void> _onSubmitted(
    LoginPasswordSubmitted event,
    Emitter<LoginPasswordState> emit,
  ) async {
    try {
      if (state.status == LoginPasswordStatus.initial ||
          state.status == LoginPasswordStatus.failure) {
        final secCodeParam = await client.loginWithPassword(
          username: event.username,
          password: event.password,
        );
        if (secCodeParam == null) {
          emit(state.copyWith(status: LoginPasswordStatus.success));
        } else {
          final secCode = await client.fetchPasswordSecCode(
            update: secCodeParam.update,
            idHash: secCodeParam.getIdHash(),
          );
          emit(state.copyWith(
            status: LoginPasswordStatus.withSecCodeParam,
            secCodeParam: secCodeParam,
            secCode: secCode,
          ));
        }
        return;
      } else {
        final secCodeParam = state.secCodeParam;
        if (secCodeParam == null || event.secCode == null) {
          return;
        }
        await client.loginWithPasswordSecCode(
          auth: secCodeParam.auth,
          formHash: secCodeParam.formHash,
          loginHash: secCodeParam.loginHash,
          idHash: secCodeParam.currentIdHash,
          secVerify: event.secCode!,
        );
        emit(state.copyWith(status: LoginPasswordStatus.success));
      }
    } catch (error) {
      _logger.e('密码登录错误', error);
      emit(state.copyWith(status: LoginPasswordStatus.failure));
    }
  }

  Future<void> _onSecCodeLoaded(
    LoginPasswordEvent event,
    Emitter<LoginPasswordState> emit,
  ) async {
    try {
      final secCodeParam = state.secCodeParam;
      if (secCodeParam == null) {
        return;
      }
      final secCode = await client.fetchPasswordSecCode(
        update: secCodeParam.update,
        idHash: secCodeParam.getIdHash(),
      );
      emit(state.copyWith(
        status: LoginPasswordStatus.withSecCodeParam,
        secCodeParam: secCodeParam,
        secCode: secCode,
      ));
    } catch (error) {
      _logger.e('密码登录获取验证码错误', error);
      emit(state.copyWith(status: LoginPasswordStatus.failure));
    }
  }
}
