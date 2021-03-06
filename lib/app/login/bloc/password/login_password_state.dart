part of 'login_password_bloc.dart';

enum LoginPasswordStatus { initial, withSecCodeParam, success, failure }

class LoginPasswordState extends Equatable {
  final LoginPasswordStatus status;
  final SecCode? secCodeParam;
  final Uint8List? secCode;

  final String? error;

  LoginPasswordState({
    required this.status,
    this.secCodeParam,
    this.secCode,
    this.error,
  });

  LoginPasswordState copyWith({
    LoginPasswordStatus? status,
    SecCode? secCodeParam,
    Uint8List? secCode,
    String? error,
  }) {
    return LoginPasswordState(
      status: status ?? this.status,
      secCodeParam: secCodeParam ?? this.secCodeParam,
      secCode: secCode ?? this.secCode,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status];
}
