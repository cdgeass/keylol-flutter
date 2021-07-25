import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/global.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('登陆'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _UsernameInput(usernameController: _usernameController),
            _PasswordInput(passwordController: _passwordController),
            _LoginButton(onTap: () {
              Global.keylolClient
                  .login(_usernameController.text, _passwordController.text)
                  .then((value) => Navigator.pop(context));
            })
          ],
        ),
      ),
    );
  }
}

class _UsernameInput extends StatelessWidget {
  const _UsernameInput({Key? key, required this.usernameController})
      : super(key: key);

  final TextEditingController usernameController;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        child: TextField(
          textInputAction: TextInputAction.next,
          controller: usernameController,
          decoration: InputDecoration(labelText: '用户名'),
        ),
      ),
    );
  }
}

class _PasswordInput extends StatelessWidget {
  const _PasswordInput({Key? key, required this.passwordController})
      : super(key: key);

  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        child: TextField(
          textInputAction: TextInputAction.next,
          controller: passwordController,
          decoration: InputDecoration(labelText: '密码'),
          obscureText: true,
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({Key? key, required this.onTap}) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        primary: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onTap,
      child: Row(
        children: [
          const Icon(Icons.lock),
          const SizedBox(width: 6),
          Text('登陆'),
        ],
      ),
    );
  }
}
