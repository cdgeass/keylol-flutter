import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:logger/logger.dart';

part 'login_password_event.dart';

part 'login_password_state.dart';

class LoginPasswordBloc extends Bloc<LoginPasswordEvent, LoginPasswordState> {
  final _logger = Logger();

  final KeylolApiClient _client;

  LoginPasswordBloc({
    required KeylolApiClient client,
  })  : _client = client,
        super(LoginPasswordState(status: LoginPasswordStatus.initial)) {
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
        final secCodeParam = await _client.loginWithPassword(
          username: event.username,
          password: event.password,
        );
        if (secCodeParam == null) {
          emit(state.copyWith(status: LoginPasswordStatus.success));
        } else {
          final secCode = await _client.fetchPasswordSecCode(
            update: secCodeParam.update,
            idHash: secCodeParam.getIdHash(),
          );
          emit(state.copyWith(
            status: LoginPasswordStatus.withSecCodeParam,
            secCodeParam: secCodeParam,
            secCode: secCode,
          ));
        }
      } else {
        final secCodeParam = state.secCodeParam;
        if (secCodeParam == null || event.secCode == null) {
          return;
        }
        await _client.loginWithPasswordSecCode(
          auth: secCodeParam.auth,
          formHash: secCodeParam.formHash,
          loginHash: secCodeParam.loginHash,
          idHash: secCodeParam.currentIdHash,
          secVerify: event.secCode!,
        );
        emit(state.copyWith(status: LoginPasswordStatus.success));
      }
    } catch (error) {
      _logger.e('[登录] 密码登录出错', error);

      if (error is DioError) {
        emit(state.copyWith(error: '网络异常, 登录失败'));
      } else {
        emit(state.copyWith(error: error.toString()));
      }
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
      final secCode = await _client.fetchPasswordSecCode(
        update: secCodeParam.update,
        idHash: secCodeParam.getIdHash(),
      );
      emit(state.copyWith(
        status: LoginPasswordStatus.withSecCodeParam,
        secCodeParam: secCodeParam,
        secCode: secCode,
      ));
    } catch (error) {
      _logger.e('[登录] 密码登录获取验证吗出错', error);

      if (error is DioError) {
        emit(state.copyWith(error: '网络异常, 获取验证码失败'));
      } else {
        emit(state.copyWith(error: error.toString()));
      }
    }
  }
}
