part of 'login_sms_bloc.dart';

enum LoginSmsStatus { initial, withSecCodeParam, waitSmsSend, smsSent }

class LoginSmsState extends Equatable {
  final LoginSmsStatus status;
  final SecCode? secCodeParam;
  final Uint8List? secCode;

  LoginSmsState({
    this.status = LoginSmsStatus.initial,
    this.secCodeParam,
    this.secCode,
  });

  LoginSmsState copyWith({
    LoginSmsStatus? status,
    SecCode? secCodeParam,
    Uint8List? secCode,
  }) {
    return LoginSmsState(
      status: status ?? this.status,
      secCodeParam: secCodeParam ?? this.secCodeParam,
      secCode: secCode ?? this.secCode,
    );
  }

  @override
  List<Object?> get props => [];
}
