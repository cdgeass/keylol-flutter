import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/thread/bloc/thread_bloc.dart';
import 'package:keylol_flutter/app/thread/view/thread_list.dart';
import 'package:keylol_flutter/common/keylol_client.dart';

class ThreadPage extends StatelessWidget {
  final String tid;
  final String? pid;

  const ThreadPage({
    Key? key,
    required this.tid,
    this.pid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThreadBloc(client: KeylolClient().dio, tid: tid)
        ..add(ThreadReloaded()),
      child: BlocBuilder<ThreadBloc, ThreadState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {},
            child: Builder(
              builder: (context) {
                switch (state.status) {
                  case ThreadStatus.failure:
                    return Center(child: Text('出错啦！！！'));
                  case ThreadStatus.success:
                    return ThreadList();
                  default:
                    return Center(child: CircularProgressIndicator());
                }
              },
            ),
          );
        },
      ),
    );
  }
}
