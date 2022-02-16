import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/authentication/authentication.dart';
import 'package:keylol_flutter/app/notice/bloc/notice_bloc.dart';

class NoticePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NoticeBloc(),
      child: BlocBuilder<NoticeBloc, NoticeState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text('提醒'),
              centerTitle: true,
            ),
            drawer: DrawerWidget(),
          );
        },
      ),
    );
  }
}
