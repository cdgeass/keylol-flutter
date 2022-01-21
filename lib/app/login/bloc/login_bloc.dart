import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html/parser.dart';
import 'package:keylol_flutter/common/log.dart';
import 'package:keylol_flutter/models/sec_code.dart';

part 'login_event.dart';

part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final _logger = Log();
  final Dio client;

  LoginBloc({required this.client}) : super(LoginState()) {
    on<LoginSmsFetched>(_onSmsFetched);
    on<LoginSecCodeFetched>(_onSecCodeFetched);
  }

  Future<void> _onSmsFetched(
    LoginSmsFetched event,
    Emitter<LoginState> emit,
  ) async {
    if (state.type == LoginType.password) {
      return;
    }
    switch (state.status) {
      case LoginStatus.initial:
      case LoginStatus.failure:
        // 未拿到短信参数，需要先获取图形验证码
        try {
          final smsParam = await _fetchSmsParam(event.cellphone);
          emit(state.copyWith(
            status: LoginStatus.withSmsParam,
            secCodeParam: smsParam,
          ));
        } catch (error) {
          _logger.e('获取短信验证码参数错误', error);
          emit(state.copyWith(status: LoginStatus.failure));
        }
        break;
      case LoginStatus.withSmsParam:
      case LoginStatus.smsSent:
        // 已拿到短信参数可以发送短信
        try {
          await _postSms(
              state.secCodeParam!, event.cellphone, event.secCodeVerify);
          emit(state.copyWith(
            status: LoginStatus.smsSent,
            secCodeParam: state.secCodeParam,
          ));
        } catch (error) {
          _logger.e('获取短信验证码错误', error);
          emit(state.copyWith(status: LoginStatus.failure));
        }
        break;
      default:
    }
  }

  Future<SecCode> _fetchSmsParam(String cellphone) async {
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

  Future<void> _postSms(
    SecCode secCode,
    String cellphone,
    String secCodeVerify,
  ) async {
    await client.post('/plugin.php',
        queryParameters: {
          'id': 'duceapp_smsauth',
          'ac': 'sendcode',
          'handlekey': 'sendsmscode',
          'smscodesubmit': 'login',
          'inajax': 1,
          'loginhash': secCode.loginHash
        },
        data: FormData.fromMap({
          'formhash': secCode.formHash,
          'smscodesubmit': 'login',
          'cellphone': cellphone,
          'smsauth': 'yes',
          'seccodehash': secCode.currentIdHash,
          'seccodeverify': secCodeVerify
        }));
  }

  Future<void> _onSecCodeFetched(
    LoginEvent event,
    Emitter<LoginState> emit,
  ) async {
    if (state.status != LoginStatus.needSecCode) {
      return;
    }
  }

  Future<SecCode> _fetchSecCodeParam(String auth, String formHash) async {
    final res = await client.get('/member.php', queryParameters: {
      'mod': 'logging',
      'action': 'login',
      'auth': auth,
      'refer': 'https://keylol.com',
      'cookietime': 1
    });

    final document = parse(res.data);
    final secCode = SecCode.fromDocument(document);
    secCode.auth = auth;
    secCode.formHash = formHash;
    return secCode;
  }

  Future<Uint8List> fetchSecCode(String update, String idHash) async {
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
}
