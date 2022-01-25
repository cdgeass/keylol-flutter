part of 'login_password_bloc.dart';

enum LoginPasswordStatus { initial }

class LoginPasswordState extends Equatable {
  final LoginPasswordStatus status;
  final SecCode? secCodeParam;
  final Uint8List? secCode;

  LoginPasswordState({required this.status, this.secCodeParam, this.secCode});

  @override
  List<Object?> get props => [status];
}
