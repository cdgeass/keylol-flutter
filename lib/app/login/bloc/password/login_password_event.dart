part of 'login_password_bloc.dart';

abstract class LoginPasswordEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginPasswordSecCodeLoaded extends LoginPasswordEvent {}

class LoginPasswordSubmitted extends LoginPasswordEvent {
  final String username;
  final String password;
  final String? secCode;

  LoginPasswordSubmitted(this.username, this.password, this.secCode);
}
