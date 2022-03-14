import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:keylol_flutter/common/log.dart';
import 'package:keylol_flutter/model/profile.dart';

part 'login_sms_event.dart';
part 'login_sms_state.dart';

class LoginSmsBloc extends Bloc<LoginSmsEvent, LoginSmsState> {
  final _logger = Log();
  final KeylolApiClient client;

  LoginSmsBloc({required this.client}) : super(LoginSmsState()) {
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
      final secCodeParam = await client.fetchSmsSecCodeParam(event.cellphone);
      final secCode = await client.fetchSmsSecCode(
        update: secCodeParam.update,
        idHash: secCodeParam.getIdHash(),
      );
      emit(state.copyWith(
        status: LoginSmsStatus.waitSmsSend,
        secCodeParam: secCodeParam,
        secCode: secCode,
      ));
    } catch (error) {
      _logger.e('获取图形验证码参数错误', error);
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
      final secCode = await client.fetchSmsSecCode(
        update: secCodeParam.update,
        idHash: secCodeParam.getIdHash(),
      );
      emit(state.copyWith(
        status: LoginSmsStatus.waitSmsSend,
        secCode: secCode,
      ));
    } catch (error) {
      _logger.e('获取图形验证码错误', error);
    }
  }

  Future<void> _onSmsSent(
    LoginSmsSent event,
    Emitter<LoginSmsState> emit,
  ) async {
    try {
      final secCodeParam = state.secCodeParam!;
      await client.sendSms(secCodeParam, event.cellphone, event.secCode);
      emit(state.copyWith(status: LoginSmsStatus.smsSent));
    } catch (error) {
      _logger.e('发送验证码错误', error);
    }
  }

  Future<void> _onSmsSubmitted(
    LoginSmsSubmitted event,
    Emitter<LoginSmsState> emit,
  ) async {
    try {
      final secCodeParam = state.secCodeParam!;
      final profile = await client.loginWithSms(
        secCodeParam: secCodeParam,
        cellphone: event.cellphone,
        sms: event.sms,
      );
      emit(state.copyWith(status: LoginSmsStatus.succeed, profile: profile));
    } catch (error) {
      _logger.e('短信登录错误', error);
    }
  }
}
