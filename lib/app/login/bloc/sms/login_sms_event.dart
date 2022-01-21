part of 'login_sms_bloc.dart';

abstract class LoginSmsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginSmsSecCodeParamFetched extends LoginSmsEvent {
  final String cellphone;

  LoginSmsSecCodeParamFetched(this.cellphone);
}

class LoginSmsSecCodeFetched extends LoginSmsEvent {}

class LoginSmsSent extends LoginSmsEvent {
  final String cellphone;
  final String secCode;

  LoginSmsSent(this.cellphone, this.secCode);
}

class LoginSmsSubmitted extends LoginSmsEvent {
  final String cellphone;
  final String sms;

  LoginSmsSubmitted(this.cellphone, this.sms);
}
