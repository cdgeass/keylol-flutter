import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/authentication/bloc/authentication_bloc.dart';
import 'package:provider/provider.dart';

class AuthenticationBlocProvider<T extends Bloc> extends StatelessWidget {
  final Create<T> create;
  final dynamic event;
  final Widget child;

  const AuthenticationBlocProvider({
    Key? key,
    required this.create,
    required this.child,
    required this.event,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<T>(
      create: create,
      child: BlocConsumer<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          context.read<T>().add(event);
        },
        builder: (context, state) {
          return child;
        },
      ),
    );
  }
}
