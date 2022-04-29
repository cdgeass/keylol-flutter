import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:keylol_flutter/app/login/bloc/password/login_password_bloc.dart';
import 'package:keylol_flutter/app/login/bloc/sms/login_sms_bloc.dart';
import 'package:keylol_flutter/app/login/view/login_sms_view.dart';
import 'package:keylol_flutter/app/login/view/login_password_view.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _controller = PageController();
  int _index = 0;

  @override
  void initState() {
    _controller.addListener(() {
      if (_controller.page != null) {
        setState(() {
          _index = _controller.page!.round() % 2;
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

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
            Container(
              height: 250.0,
              child: PageView(
                controller: _controller,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: _index == 0
                        ? Border(
                            bottom: BorderSide(
                              width: 2.0,
                              color: Theme.of(context).primaryColor,
                            ),
                          )
                        : null,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.phone_android_outlined),
                    onPressed: () {
                      _controller.animateToPage(
                        0,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.decelerate,
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: 16.0,
                ),
                Container(
                  decoration: BoxDecoration(
                    border: _index == 1
                        ? Border(
                            bottom: BorderSide(
                              width: 2.0,
                              color: Theme.of(context).primaryColor,
                            ),
                          )
                        : null,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.password_outlined),
                    onPressed: () {
                      _controller.animateToPage(
                        1,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.decelerate,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
