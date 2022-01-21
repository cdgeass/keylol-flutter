part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoginSmsRequested extends LoginEvent {}

class LoginSmsFetched extends LoginEvent {
  final String cellphone;
  final String secCodeVerify;

  LoginSmsFetched({required this.cellphone, required this.secCodeVerify});
}

class LoginPasswordRequested extends LoginEvent {}

class LoginSecCodeFetched extends LoginEvent {}
