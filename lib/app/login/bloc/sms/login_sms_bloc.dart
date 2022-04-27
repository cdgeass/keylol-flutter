import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:logger/logger.dart';

part 'login_sms_event.dart';

part 'login_sms_state.dart';

class LoginSmsBloc extends Bloc<LoginSmsEvent, LoginSmsState> {
  final _logger = Logger();
  final KeylolApiClient _client;

  LoginSmsBloc({required KeylolApiClient client})
      : _client = client,
        super(LoginSmsState()) {
    on<LoginSmsSecCodeParamFetched>(_onSecCodeParamFetched);
    on<LoginSmsSecCodeFetched>(_onSmsSecCodeFetched);
    on<LoginSmsSent>(_onSmsSent);
    on<LoginSmsSubmitted>(_onSmsSubmitted);
  }

  Future<void> _onSecCodeParamFetched(
    LoginSmsSecCodeParamFetched event,
    Emitter<LoginSmsState> emit,
  ) async {
    try {
      final secCodeParam = await _client.fetchSmsSecCodeParam(event.cellphone);
      final secCode = await _client.fetchSmsSecCode(
        update: secCodeParam.update,
        idHash: secCodeParam.getIdHash(),
      );
      emit(state.copyWith(
        status: LoginSmsStatus.waitSmsSend,
        secCodeParam: secCodeParam,
        secCode: secCode,
      ));
    } catch (error) {
      _logger.e('[登录] 手机号登录获取图形验证码参数出错', error);

      if (error is DioError) {
        emit(state.copyWith(error: '网络异常, 获取图形验证码失败'));
      } else {
        emit(state.copyWith(error: error.toString()));
      }
    }
  }

  Future<void> _onSmsSecCodeFetched(
    LoginSmsEvent event,
    Emitter<LoginSmsState> emit,
  ) async {
    try {
      final secCodeParam = state.secCodeParam!;
      emit(state.copyWith(
        status: LoginSmsStatus.withSecCodeParam,
        secCodeParam: secCodeParam,
      ));
      final secCode = await _client.fetchSmsSecCode(
        update: secCodeParam.update,
        idHash: secCodeParam.getIdHash(),
      );
      emit(state.copyWith(
        status: LoginSmsStatus.waitSmsSend,
        secCode: secCode,
      ));
    } catch (error) {
      _logger.e('[登录] 手机号登录获取图形验证码出错', error);

      if (error is DioError) {
        emit(state.copyWith(error: '网络异常, 获取图形验证码失败'));
      } else {
        emit(state.copyWith(error: error.toString()));
      }
    }
  }

  Future<void> _onSmsSent(
    LoginSmsSent event,
    Emitter<LoginSmsState> emit,
  ) async {
    try {
      final secCodeParam = state.secCodeParam!;
      await _client.sendSms(secCodeParam, event.cellphone, event.secCode);
      emit(state.copyWith(status: LoginSmsStatus.smsSent));
    } catch (error) {
      _logger.e('[登录] 手机号登录发送短信验证码出错', error);

      if (error is DioError) {
        emit(state.copyWith(error: '网络异常, 发送短信验证码失败'));
      } else {
        emit(state.copyWith(error: error.toString()));
      }
    }
  }

  Future<void> _onSmsSubmitted(
    LoginSmsSubmitted event,
    Emitter<LoginSmsState> emit,
  ) async {
    try {
      final secCodeParam = state.secCodeParam!;
      final profile = await _client.loginWithSms(
        secCodeParam: secCodeParam,
        cellphone: event.cellphone,
        sms: event.sms,
      );
      emit(state.copyWith(status: LoginSmsStatus.succeed, profile: profile));
    } catch (error) {
      _logger.e('[登录] 手机号登录登录出错', error);

      if (error is DioError) {
        emit(state.copyWith(error: '网络异常, 登录失败'));
      } else {
        emit(state.copyWith(error: error.toString()));
      }
    }
  }
}
