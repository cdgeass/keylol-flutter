import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html/parser.dart';
import 'package:keylol_flutter/common/log.dart';
import 'package:keylol_flutter/model/sec_code.dart';

part 'login_password_event.dart';

part 'login_password_state.dart';

class LoginPasswordBloc extends Bloc<LoginPasswordEvent, LoginPasswordState> {
  final _logger = Log();
  final Dio client;

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
        final secCodeParam = await _login(event.username, event.password);
        if (secCodeParam == null) {
          emit(state.copyWith(status: LoginPasswordStatus.success));
        } else {
          final secCode = await _fetchSecCode(
              secCodeParam.update, secCodeParam.getIdHash());
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
        await _loginWithSecCode(
          secCodeParam.auth,
          secCodeParam.formHash,
          secCodeParam.loginHash,
          secCodeParam.currentIdHash,
          event.secCode!,
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
      final secCode =
          await _fetchSecCode(secCodeParam.update, secCodeParam.getIdHash());
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

  /// 登录
  Future<SecCode?> _login(String username, String password) async {
    final res = await client.post("/api/mobile/index.php",
        queryParameters: {
          'module': 'login',
          'action': 'login',
          'loginsubmit': 'yes',
        },
        data: FormData.fromMap({
          'username': username,
          'password': password,
          'answer': '',
          'questionid': '0'
        }));

    if (res.data['Message']?['messageval'] == 'login_succeed') {
      return Future.value(null);
    } else if (res.data['Message']?['messageval'] == 'login_seccheck2') {
      // 需要验证码 走网页验证码登录
      final auth = res.data['Variables']!['auth'];
      final formHash = res.data['Variables']!['formhash'];
      return _fetchSecCodeParam(auth, formHash);
    } else {
      // 登录失败
      return Future.error(res.data['Message']?['messagestr']);
    }
  }

  // 验证码页面
  Future<SecCode> _fetchSecCodeParam(String? auth, String formHash) async {
    final res = await client.get('/member.php', queryParameters: {
      'mod': 'logging',
      'action': 'login',
      'auth': auth,
      'refer': 'https://keylol.com',
      'cookietime': 1
    });

    final document = parse(res.data);
    final secCode = SecCode.fromDocument(document);
    if (auth != null) {
      secCode.auth = auth;
    }
    secCode.formHash = formHash;
    return secCode;
  }

  // 获取验证码
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

  // 验证码校验
  Future _checkSecCode(String auth, String idHash, String secVerify) async {
    final res = await client.get('/misc.php', queryParameters: {
      'mod': 'seccode',
      'action': 'check',
      'inajax': 1,
      'idhash': idHash,
      'secverify': secVerify
    });

    if (!(res.data as String).contains('succeed')) {
      return Future.error('验证码错误');
    }
  }

  // 验证码登录
  Future<void> _loginWithSecCode(String auth, String formHash, String loginHash,
      String idHash, String secVerify) async {
    final res = await client.post('/member.php',
        queryParameters: {
          'mod': 'logging',
          'action': 'login',
          'loginsubmit': 'yes',
          'loginhash': loginHash,
          'inajax': 1
        },
        data: FormData.fromMap({
          'duceapp': 'yes',
          'formhash': formHash,
          'referer': 'https://keylol.com/',
          'handlekey': 'login',
          'auth': auth,
          'seccodehash': idHash,
          'seccodeverify': secVerify,
          'cookietime': 2592000
        }));

    final data = res.data as String;
    if (data.contains('succeedhandle_login')) {
      return;
    } else {
      return Future.error('登录出错');
    }
  }
}
