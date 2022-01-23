part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthenticationSucceed extends AuthenticationEvent {
  final Profile profile;

  AuthenticationSucceed(this.profile);
}

class AuthenticationLogoutRequested extends AuthenticationEvent {}
