import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:keylol_flutter/app/login/bloc/password/login_password_bloc.dart';
import 'package:keylol_flutter/app/login/bloc/sms/login_sms_bloc.dart';
import 'package:keylol_flutter/app/login/view/login_password_view.dart';

import 'login_sms_view.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: EdgeInsets.only(left: 16.0, top: 32.0, right: 16.0),
        child: Column(
          children: [
            CachedNetworkImage(
              width: 200.0,
              imageUrl:
                  'https://keylol.com/template/steamcn_metro/src/img/common/icon_with_text_256h.png',
            ),
            SizedBox(
              height: 16.0,
            ),
            Expanded(
              child: PageView(
                children: [
                  // 短信登录
                  BlocProvider(
                    create: (_) => LoginSmsBloc(
                      client: context.read<KeylolApiClient>(),
                    ),
                    child: LoginSmsView(),
                  ),
                  // 密码登录
                  BlocProvider(
                    create: (_) => LoginPasswordBloc(
                      client: context.read<KeylolApiClient>(),
                    ),
                    child: LoginPasswordView(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
