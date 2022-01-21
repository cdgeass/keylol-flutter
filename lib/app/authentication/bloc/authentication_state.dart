part of 'authentication_bloc.dart';

enum AuthenticationStatus { unauthenticated, authenticated }

class AuthenticationState extends Equatable {
  final AuthenticationStatus status;
  final Profile? profile;

  const AuthenticationState._({
    this.status = AuthenticationStatus.unauthenticated,
    this.profile,
  });

  const AuthenticationState.authenticated(Profile profile)
      : this._(status: AuthenticationStatus.authenticated, profile: profile);

  const AuthenticationState.unauthenticated()
      : this._(status: AuthenticationStatus.unauthenticated);

  @override
  List<Object?> get props => throw UnimplementedError();
}
