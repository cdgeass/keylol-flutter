import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/authentication/authentication.dart';
import 'package:keylol_flutter/app/notice/bloc/notice_bloc.dart';
import 'package:keylol_flutter/common/keylol_client.dart';

import 'notice_list.dart';

class NoticePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NoticeBloc(client: KeylolClient().dio)..add(NoticeReloaded()),
      child: BlocBuilder<NoticeBloc, NoticeState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text('提醒'),
              centerTitle: true,
            ),
            drawer: DrawerWidget(),
            body: RefreshIndicator(
              onRefresh: () async {
                context.read<NoticeBloc>().add(NoticeReloaded());
              },
              child: Builder(
                builder: (context) {
                  switch (state.status) {
                    case NoticeStatus.success:
                      return NoticeList();
                    default:
                      return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
