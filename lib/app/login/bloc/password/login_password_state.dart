part of 'login_password_bloc.dart';

enum LoginPasswordStatus { initial, withSecCodeParam, success, failure }

class LoginPasswordState extends Equatable {
  final LoginPasswordStatus status;
  final SecCode? secCodeParam;
  final Uint8List? secCode;

  LoginPasswordState({
    required this.status,
    this.secCodeParam,
    this.secCode,
  });

  LoginPasswordState copyWith({
    LoginPasswordStatus? status,
    SecCode? secCodeParam,
    Uint8List? secCode,
  }) {
    return LoginPasswordState(
      status: status ?? this.status,
      secCodeParam: secCodeParam ?? this.secCodeParam,
      secCode: secCode ?? this.secCode,
    );
  }

  @override
  List<Object?> get props => [status];
}
