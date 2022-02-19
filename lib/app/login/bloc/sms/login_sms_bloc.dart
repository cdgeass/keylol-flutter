import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html/parser.dart';
import 'package:keylol_flutter/common/keylol_client.dart';
import 'package:keylol_flutter/common/log.dart';
import 'package:keylol_flutter/common/provider.dart';
import 'package:keylol_flutter/model/profile.dart';
import 'package:keylol_flutter/model/sec_code.dart';

part 'login_sms_event.dart';

part 'login_sms_state.dart';

class LoginSmsBloc extends Bloc<LoginSmsEvent, LoginSmsState> {
  final _logger = Log();
  final Dio client;

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
      final secCodeParam = await _fetchSecCodeParam(event.cellphone);
      final secCode = await _fetchSecCode(
        secCodeParam.update,
        secCodeParam.getIdHash(),
      );
      emit(state.copyWith(
        status: LoginSmsStatus.waitSmsSend,
        secCodeParam: secCodeParam,
        secCode: secCode,
      ));
    } catch (error) {
      _logger.e('获取图形验证码参数错误', error);
      // TODO
    }
  }

  // 获取图形验证码参数
  Future<SecCode> _fetchSecCodeParam(String cellphone) async {
    var res = await client.get('/member.php',
        queryParameters: {'mod': 'logging', 'action': 'login'});

    var document = parse(res.data);
    final inputs = document.getElementsByTagName('input');
    late String formHash;
    for (var input in inputs) {
      if (input.attributes['name'] == 'formhash') {
        formHash = input.attributes['value'] ?? '';
        break;
      }
    }
    late String loginHash;
    final pwLoginTypes = document.getElementsByClassName('pwLogintype');
    final actionExp = pwLoginTypes.first
            .getElementsByTagName('li')
            .first
            .attributes['_action'] ??
        '';
    if (actionExp.isNotEmpty) {
      final lastIndexOfEqual = actionExp.lastIndexOf('=');
      loginHash = actionExp.substring(lastIndexOfEqual + 1);
    }

    res = await client.post('/plugin.php',
        queryParameters: {
          'id': 'duceapp_smsauth',
          'ac': 'sendcode',
          'handlekey': 'sendsmscode',
          'smscodesubmit': 'login',
          'inajax': 1,
          'loginhash': loginHash
        },
        data: FormData.fromMap({
          'duceapp': 'yes',
          'formhash': formHash,
          'referer': 'https://keylol.com',
          'lssubmit': 'yes',
          'loginfield': 'auto',
          'cellphone': cellphone,
        }));

    document = parse(res.data);
    final secCode = SecCode.fromDocument(document);
    secCode.formHash = formHash;
    return secCode;
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
      final secCode =
          await _fetchSecCode(secCodeParam.update, secCodeParam.getIdHash());
      emit(state.copyWith(
        status: LoginSmsStatus.waitSmsSend,
        secCode: secCode,
      ));
    } catch (error) {
      _logger.e('获取图形验证码错误', error);
      // TODO
    }
  }

  Future<Uint8List> _fetchSecCode(String update, String idHash) async {
    final res = await client.get('/misc.php',
        options: Options(responseType: ResponseType.bytes, headers: {
          'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
          'Accept-Encoding': 'gzip, deflate, br',
          'Accept-Language': 'zh-CN,zh;q=0.9',
          'Connection': 'keep-alive',
          'hostname': 'https://keylol.com',
          'Referer': 'https://keylol.com/member.php?mod=logging&action=login',
          'Sec-Fetch-Mode': 'no-cors',
          'Sec-Fetch-Site': 'same-origin',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36'
        }),
        queryParameters: {
          'mod': 'seccode',
          'update': update,
          'idhash': idHash
        });

    return Uint8List.fromList(res.data);
  }

  Future<void> _onSmsSent(
    LoginSmsSent event,
    Emitter<LoginSmsState> emit,
  ) async {
    try {
      final secCodeParam = state.secCodeParam!;
      await _sendSms(secCodeParam, event.cellphone, event.secCode);
      emit(state.copyWith(status: LoginSmsStatus.smsSent));
    } catch (error) {
      _logger.e('发送验证码错误', error);
      // TODO
    }
  }

  Future<void> _sendSms(
    SecCode secCodeParam,
    String cellphone,
    String secCodeVerify,
  ) async {
    final res = await client.post('/plugin.php',
        queryParameters: {
          'id': 'duceapp_smsauth',
          'ac': 'sendcode',
          'handlekey': 'sendsmscode',
          'smscodesubmit': 'login',
          'inajax': 1,
          'loginhash': secCodeParam.loginHash
        },
        data: FormData.fromMap({
          'formhash': secCodeParam.formHash,
          'smscodesubmit': 'login',
          'cellphone': cellphone,
          'smsauth': 'yes',
          'seccodehash': secCodeParam.currentIdHash,
          'seccodeverify': secCodeVerify
        }));
    _logger.d('${res.data}');
  }

  Future<void> _onSmsSubmitted(
    LoginSmsSubmitted event,
    Emitter<LoginSmsState> emit,
  ) async {
    try {
      final secCodeParam = state.secCodeParam!;
      final profile = await _login(secCodeParam, event.cellphone, event.sms);
      emit(state.copyWith(status: LoginSmsStatus.succeed, profile: profile));
    } catch (error) {
      _logger.e('短信登录错误', error);
      // TODO
    }
  }

  Future<Profile> _login(
      SecCode secCodeParam, String cellphone, String sms) async {
    final res = await client.post('/plugin.php',
        queryParameters: {
          'id': 'duceapp_smsauth',
          'ac': 'login',
          'loginsubmit': 'yes',
          'loginhash': secCodeParam.loginHash,
          'inajax': 1
        },
        data: FormData.fromMap({
          'duceapp': 'yes',
          'formhash': secCodeParam.formHash,
          'referer': 'https://keylol.com',
          'lssubmit': 'yes',
          'loginfield': 'auto',
          'cellphone': cellphone,
          'smscode': sms
        }));

    final data = res.data as String;
    if (data.contains('succeedhandle_login')) {
      // TODO 登录成功
      return KeylolClient()
          .fetchProfile()
          .then((_) => ProfileProvider().profile!);
    }
    // TODO 登录失败
    return Future.error('登录失败');
  }
}
