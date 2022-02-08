import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/authentication/authentication.dart';
import 'package:keylol_flutter/app/login/bloc/sms/login_sms_bloc.dart';
import 'package:keylol_flutter/app/login/widgets/widgets.dart';

class LoginSmsView extends StatelessWidget {
  final _cellphoneController = TextEditingController();
  final _secCodeController = TextEditingController();
  final _smsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginSmsBloc, LoginSmsState>(
      listener: (context, state) {
        if (state.status == LoginSmsStatus.succeed) {
          context.read<AuthenticationBloc>().add(AuthenticationLoaded());

          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return Form(
          child: Column(
            children: [
              // 手机号
              CellphoneInput(cellphoneController: _cellphoneController),
              // 图形验证码
              if (state.secCode != null)
                SecCodeInput(
                  secCode: state.secCode!,
                  secCodeController: _secCodeController,
                ),
              // 短信验证码
              SmsInput(
                smsController: _smsController,
                sendSms: () {
                  final cellphone = _cellphoneController.text;
                  final secCode = _secCodeController.text;

                  final bloc = context.read<LoginSmsBloc>();
                  if (state.status != LoginSmsStatus.waitSmsSend) {
                    bloc.add(LoginSmsSecCodeParamFetched(cellphone));
                  } else if (state.status == LoginSmsStatus.waitSmsSend) {
                    bloc.add(LoginSmsSent(cellphone, secCode));
                  }
                },
              ),
              // 登录框
              ElevatedButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text('登录')],
                ),
                onPressed: () {
                  final cellphone = _cellphoneController.text;
                  final sms = _smsController.text;
                  context
                      .read<LoginSmsBloc>()
                      .add(LoginSmsSubmitted(cellphone, sms));
                },
              )
            ],
          ),
        );
      },
    );
  }
}
