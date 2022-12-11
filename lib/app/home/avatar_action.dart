import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/authentication/bloc/authentication_bloc.dart';
import 'package:keylol_flutter/components/avatar.dart';
import 'package:keylol_flutter/repository/repository.dart';

class AvatarAction extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
      final profile = context.read<AuthenticationRepository>().profile;
      if (profile == null || profile.memberUid == '0') {
        return InkWell(
          onTap: () {
            Navigator.of(context).pushNamed('/login');
          },
          child: Container(
            child: ClipOval(
              child: Image.asset(
                'images/unknown_avatar.jpg',
              ),
            ),
          ),
        );
      } else {
        return InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(
              '/space',
              arguments: profile.memberUid!,
            );
          },
          child: Avatar(
            uid: profile.memberUid!,
            width: 48.0,
            height: 48.0,
          ),
        );
      }
    });
  }
}
