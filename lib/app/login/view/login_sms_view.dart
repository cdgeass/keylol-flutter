import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/login/bloc/sms/login_sms_bloc.dart';
import 'package:keylol_flutter/app/login/widgets/widgets.dart';

class LoginSmsView extends StatelessWidget {
  final _cellphoneController = TextEditingController();
  final _secCodeController = TextEditingController();
  final _smsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginSmsBloc, LoginSmsState>(
      builder: (context, state) {
        return Form(
          child: Column(
            children: [
              CellphoneInput(cellphoneController: _cellphoneController),
              if (state.secCode != null)
                SecCodeInput(
                  secCode: state.secCode!,
                  secCodeController: _secCodeController,
                ),
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
