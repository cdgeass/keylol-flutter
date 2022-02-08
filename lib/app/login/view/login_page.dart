import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/login/bloc/password/login_password_bloc.dart';
import 'package:keylol_flutter/app/login/bloc/sms/login_sms_bloc.dart';
import 'package:keylol_flutter/app/login/view/login_password_view.dart';
import 'package:keylol_flutter/common/keylol_client.dart';

import 'login_sms_view.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: PageView(
        children: [
          // 短信登录
          BlocProvider(
            create: (_) => LoginSmsBloc(client: KeylolClient().dio),
            child: LoginSmsView(),
          ),
          // 密码登录
          BlocProvider(
            create: (_) => LoginPasswordBloc(client: KeylolClient().dio),
            child: LoginPasswordView(),
          ),
        ],
      ),
    );
  }
}
