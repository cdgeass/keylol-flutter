import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:keylol_flutter/app/login/bloc/password/login_password_bloc.dart';
import 'package:keylol_flutter/app/login/bloc/sms/login_sms_bloc.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late PageController _controller;
  late int _selected;

  @override
  void initState() {
    _controller = PageController();
    _selected = 0;

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
      body: Padding(
        padding: EdgeInsets.only(left: 16.0, right: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: CachedNetworkImage(
                width: 200.0,
                imageUrl:
                    'https://keylol.com/template/steamcn_metro/src/img/common/icon_with_text_256h.png',
              ),
            ),
            Container(
              height: 360.0,
              child: PageView(
                physics: NeverScrollableScrollPhysics(),
                controller: _controller,
                children: [
                  _PasswordLoginWidget(),
                  _SmsLoginWidget(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: SegmentedButton(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(value: 0, icon: Icon(Icons.password)),
                  ButtonSegment(value: 1, icon: Icon(Icons.sms)),
                ],
                selected: Set.of([_selected]),
                onSelectionChanged: (Set<int> sets) {
                  setState(() {
                    _selected = sets.first;
                  });
                  _controller.animateToPage(
                    _selected,
                    duration: Duration(milliseconds: 200),
                    curve: Curves.linear,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordLoginWidget extends StatefulWidget with PreferredSizeWidget {
  @override
  State<StatefulWidget> createState() => _PasswordLoginWidgetState();

  @override
  Size get preferredSize => Size.fromHeight(224);
}

class _PasswordLoginWidgetState extends State<_PasswordLoginWidget> {
  late TextEditingController _usernameController;
  late bool _passwordVisible;
  late TextEditingController _passwordController;
  late TextEditingController _secCodeController;

  @override
  void initState() {
    _usernameController = TextEditingController();
    _passwordVisible = false;
    _passwordController = TextEditingController();
    _secCodeController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _secCodeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginPasswordBloc(client: context.read<KeylolApiClient>()),
      child: BlocConsumer<LoginPasswordBloc, LoginPasswordState>(
        listener: (context, state) {
          if (state.status == LoginPasswordStatus.success) {
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          return AutofillGroup(
            child: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text('账号'),
                      ),
                      autofillHints: [AutofillHints.username],
                      controller: _usernameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '账号不能为空';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: TextFormField(
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text('密码'),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                      autofillHints: [AutofillHints.password],
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '密码不能为空';
                        }
                        return null;
                      },
                    ),
                  ),
                  if (state.secCode != null)
                    Padding(
                      padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                label: Text('图形验证码'),
                              ),
                              controller: _secCodeController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '图形验证码不能为空';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 8.0),
                          InkWell(
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4.0)),
                              child: Image.memory(
                                state.secCode!,
                                height: 64.0,
                                fit: BoxFit.fill,
                              ),
                            ),
                            onTap: () {
                              context
                                  .read<LoginPasswordBloc>()
                                  .add(LoginPasswordSecCodeLoaded());
                            },
                          ),
                        ],
                      ),
                    ),
                  Container(
                    padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                    width: double.infinity,
                    child: FilledButton(
                      child: Text('登陆'),
                      onPressed: () {
                        context.read<LoginPasswordBloc>().add(
                              LoginPasswordSubmitted(
                                _usernameController.text,
                                _passwordController.text,
                                _secCodeController.text,
                              ),
                            );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SmsLoginWidget extends StatefulWidget with PreferredSizeWidget {
  @override
  State<StatefulWidget> createState() => _SmsLoginWidgetState();

  @override
  Size get preferredSize => Size.fromHeight(224.0);
}

class _SmsLoginWidgetState extends State<_SmsLoginWidget> {
  late TextEditingController _phoneController;
  late TextEditingController _secCodeController;
  late TextEditingController _smsCodeController;

  @override
  void initState() {
    _phoneController = TextEditingController();
    _secCodeController = TextEditingController();
    _smsCodeController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _secCodeController.dispose();
    _smsCodeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginSmsBloc(client: context.read<KeylolApiClient>()),
      child: BlocConsumer<LoginSmsBloc, LoginSmsState>(
        listener: (context, state) {
          if (state.status == LoginSmsStatus.success) {
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          return Form(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text('手机号'),
                    ),
                    controller: _phoneController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '手机号不能为空';
                      }
                      return null;
                    },
                  ),
                ),
                if (state.secCode != null)
                  Padding(
                    padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              label: Text('图形验证码'),
                            ),
                            controller: _secCodeController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '图形验证码不能为空';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 8.0),
                        InkWell(
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.all(Radius.circular(4.0)),
                            child: Image.memory(
                              state.secCode!,
                              height: 64.0,
                              fit: BoxFit.fill,
                            ),
                          ),
                          onTap: () {
                            context.read<LoginSmsBloc>().add(
                                LoginSmsSecCodeParamFetched(
                                    _phoneController.text));
                          },
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            label: Text('短信验证码'),
                          ),
                          controller: _smsCodeController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '短信验证码不能为空';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 16.0),
                      _SmsCountDownButton(
                        onPressed: () {
                          final phone = _phoneController.text;
                          final secCode = _secCodeController.text;

                          final bloc = context.read<LoginSmsBloc>();
                          if (state.status != LoginSmsStatus.waitSmsSend) {
                            bloc.add(LoginSmsSecCodeParamFetched(phone));
                          } else if (state.status ==
                              LoginSmsStatus.waitSmsSend) {
                            bloc.add(LoginSmsSent(phone, secCode));
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      context.read<LoginSmsBloc>().add(
                            LoginSmsSubmitted(
                              _phoneController.text,
                              _smsCodeController.text,
                            ),
                          );
                    },
                    child: Text('登陆'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SmsCountDownButton extends StatefulWidget {
  final Function? onPressed;

  const _SmsCountDownButton({Key? key, this.onPressed}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SmsCountDownButtonState();
}

class _SmsCountDownButtonState extends State<_SmsCountDownButton> {
  late StreamController<int> _controller;
  Timer? _timer;

  @override
  void initState() {
    _controller = StreamController();

    super.initState();
  }

  @override
  void dispose() {
    _controller.close();
    _timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _controller.stream,
      initialData: 0,
      builder: (context, snapshot) {
        final leftSecond = snapshot.data ?? 0;
        return ElevatedButton(
          child:
              leftSecond == 0 ? Text('获取短信验证码') : Text('重新获取(${leftSecond}s)'),
          onPressed: leftSecond != 0
              ? null
              : () {
                  final state = context.read<LoginSmsBloc>().state;
                  if (state.status == LoginSmsStatus.waitSmsSend ||
                      state.status == LoginSmsStatus.smsSent) {
                    var second = 60;
                    _timer?.cancel();
                    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
                      second--;
                      _controller.sink.add(second);
                      if (second == 0) {
                        timer.cancel();
                      }
                    });
                  }

                  widget.onPressed?.call();
                },
        );
      },
    );
  }
}
