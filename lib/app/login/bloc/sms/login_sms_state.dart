part of 'login_sms_bloc.dart';

enum LoginSmsStatus { initial, withSecCodeParam, waitSmsSend, smsSent, success }

class LoginSmsState extends Equatable {
  final LoginSmsStatus status;
  final SecCode? secCodeParam;
  final Uint8List? secCode;

  final String? error;

  LoginSmsState({
    this.status = LoginSmsStatus.initial,
    this.secCodeParam,
    this.secCode,
    this.error,
  });

  LoginSmsState copyWith({
    LoginSmsStatus? status,
    SecCode? secCodeParam,
    Uint8List? secCode,
    String? error,
  }) {
    return LoginSmsState(
      status: status ?? this.status,
      secCodeParam: secCodeParam ?? this.secCodeParam,
      secCode: secCode ?? this.secCode,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, secCodeParam, secCode];
}
