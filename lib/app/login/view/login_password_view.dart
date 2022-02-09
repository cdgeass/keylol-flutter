import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/login/bloc/password/login_password_bloc.dart';
import 'package:keylol_flutter/app/login/widgets/widgets.dart';

import '../../authentication/bloc/authentication_bloc.dart';

class LoginPasswordView extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _secCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginPasswordBloc, LoginPasswordState>(
      listener: (context, state) {
        if (state.status == LoginPasswordStatus.success) {
          context.read<AuthenticationBloc>().add(AuthenticationLoaded());

          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return AutofillGroup(
          child: Form(
            child: Column(
              children: [
                UsernameInput(usernameController: _usernameController),
                PasswordInput(passwordController: _passwordController),
                if (state.secCode != null)
                  SecCodeInput(
                    secCode: state.secCode!,
                    secCodeController: _secCodeController,
                  ),
                ElevatedButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text('登录')],
                  ),
                  onPressed: () {
                    context
                        .read<LoginPasswordBloc>()
                        .add(LoginPasswordSubmitted(
                          _usernameController.text,
                          _passwordController.text,
                          _secCodeController.text,
                        ));
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
