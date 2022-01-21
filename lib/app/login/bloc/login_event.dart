part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoginRequested extends LoginEvent {}

class LoginSmsFetched extends LoginEvent {
  final String cellphone;
  final String secCodeVerify;

  LoginSmsFetched(this.cellphone, this.secCodeVerify);
}

class LoginSecCodeFetched extends LoginEvent {}
