part of 'login_bloc.dart';

enum LoginType { sms, password }

enum LoginStatus { initial, withSmsParam, smsSent, needSecCode, failure }

class LoginState extends Equatable {
  final LoginType type;
  final LoginStatus status;
  final SecCode? secCodeParam;
  final Uint8List? secCode;

  final String? auth;
  final String? formHash;

  LoginState({
    this.type = LoginType.sms,
    this.status = LoginStatus.initial,
    this.secCodeParam,
    this.secCode,
    this.auth,
    this.formHash,
  });

  LoginState copyWith({
    LoginType? type,
    LoginStatus? status,
    SecCode? secCodeParam,
    Uint8List? secCode,
    String? auth,
    String? formHash,
  }) {
    return LoginState(
      type: type ?? this.type,
      status: status ?? this.status,
      secCodeParam: secCodeParam ?? this.secCodeParam,
      secCode: secCode ?? this.secCode,
      auth: auth ?? this.auth,
      formHash: formHash ?? this.formHash,
    );
  }

  @override
  List<Object?> get props => [type, status, secCodeParam, auth, formHash];
}
