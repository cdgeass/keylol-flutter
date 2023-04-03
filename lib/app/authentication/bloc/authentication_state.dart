part of 'authentication_bloc.dart';

class AuthenticationState extends Equatable {
  final AuthenticationStatus status;
  final Profile? profile;

  const AuthenticationState._({
    this.status = AuthenticationStatus.unknown,
    this.profile,
  });

  const AuthenticationState.unknown() : this._();

  const AuthenticationState.authenticated(Profile profile)
      : this._(status: AuthenticationStatus.authenticated, profile: profile);

  const AuthenticationState.unauthenticated()
      : this._(status: AuthenticationStatus.unauthenticated);

  @override
  List<Object?> get props => [status, profile];
}
