import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/forum/bloc/forum/thread_list_bloc.dart';
import 'package:keylol_flutter/app/forum/widgets/forum_thread_item.dart';

class DefaultForumThreadList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ThreadListBloc>().add(ThreadListReloaded());
      },
      child: BlocBuilder<ThreadListBloc, ThreadListState>(
        builder: (context, state) {
          switch (state.status) {
            case ThreadListStatus.failure:
              return Center(child: Text('出错啦!!!'));
            case ThreadListStatus.loaded:
              final threads = state.threads;
              return ListView.builder(
                itemCount: threads.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Row(
                      children: _builderFilterButtons(''),
                    );
                  }
                  return ForumThreadItem(thread: threads[index - 1]);
                },
              );
            default:
              return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  List<Widget> _builderFilterButtons(String filter) {
    // TODO
    return [
      ElevatedButton(
        child: Text('默认'),
        onPressed: () {},
      ),
      ElevatedButton(
        child: Text('最新'),
        onPressed: () {},
      ),
      ElevatedButton(
        child: Text('热门'),
        onPressed: () {},
      ),
      ElevatedButton(
        child: Text('热帖'),
        onPressed: () {},
      ),
      ElevatedButton(
        child: Text('精华'),
        onPressed: () {},
      ),
    ];
  }
}

class TypedForumThreadList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ThreadListBloc>().add(ThreadListReloaded());
      },
      child: BlocBuilder<ThreadListBloc, ThreadListState>(
        builder: (context, state) {
          switch (state.status) {
            case ThreadListStatus.failure:
              return Center(child: Text('出错啦!!!'));
            case ThreadListStatus.loaded:
              final threads = state.threads;
              return ListView.builder(
                itemCount: threads.length,
                itemBuilder: (context, index) {
                  return ForumThreadItem(thread: threads[index]);
                },
              );
            default:
              return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
