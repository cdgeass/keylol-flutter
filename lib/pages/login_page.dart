import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/global.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('登录'),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _UsernameInput(usernameController: _usernameController),
              _PasswordInput(passwordController: _passwordController),
              ElevatedButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text('登录')],
                ),
                onPressed: () {
                  _login(context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  void _login(BuildContext context) {
    if (_formKey.currentState?.validate() == true) {
      Global.keylolClient
          .login(_usernameController.text, _passwordController.text)
          .then((value) => Navigator.pop(context))
          .onError((error, _) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(content: Text(error as String), actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('确定'))
              ]);
            });
      });
    }
  }
}

class _UsernameInput extends StatelessWidget {
  const _UsernameInput({Key? key, required this.usernameController})
      : super(key: key);

  final TextEditingController usernameController;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: true,
      controller: usernameController,
      decoration: InputDecoration(labelText: '用户名'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '用户名不能为空';
        }
        return null;
      },
    );
  }
}

class _PasswordInput extends StatefulWidget {
  const _PasswordInput({Key? key, required this.passwordController})
      : super(key: key);

  final TextEditingController passwordController;

  @override
  State<StatefulWidget> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<_PasswordInput> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = true;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.passwordController,
      decoration: InputDecoration(
          labelText: '密码',
          suffix: IconButton(
            padding: EdgeInsets.only(left: 16.0, right: 16.0),
            iconSize: 16.0,
            constraints: BoxConstraints(
              maxHeight: 16.0
            ),
            icon: _obscure
                ? Icon(Icons.remove_red_eye)
                : Icon(Icons.remove_red_eye_outlined),
            onPressed: () {
              setState(() {
                _obscure = !_obscure;
              });
            },
          )),
      obscureText: _obscure,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '密码不能为空';
        }
        return null;
      },
    );
  }
}
