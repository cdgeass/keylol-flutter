part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthenticationLoaded extends AuthenticationEvent {}

class AuthenticationLogoutRequested extends AuthenticationEvent {}
