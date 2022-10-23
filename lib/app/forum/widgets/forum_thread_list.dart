import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/forum/bloc/forum/thread_list_bloc.dart';
import 'package:keylol_flutter/app/forum/widgets/forum_thread_item.dart';

import 'bottom_loader.dart';

class DefaultForumThreadList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DefaultForumThreadListState();
}

class _DefaultForumThreadListState extends State<DefaultForumThreadList> {
  final _controller = ScrollController();

  @override
  void initState() {
    _controller.addListener(_onScroll);

    super.initState();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();

    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _controller.position.maxScrollExtent;
    final pixels = _controller.position.pixels;

    if (maxScroll == pixels) {
      context.read<ThreadListBloc>().add(ThreadListLoaded());
    }
  }

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
            case ThreadListStatus.success:
              return ListView.builder(
                padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
                controller: _controller,
                itemCount: state.hasReachedMax
                    ? state.threads.length + 1
                    : state.threads.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _builderFilterButtons(context, state.filter);
                  }
                  return index >= state.threads.length + 1
                      ? BottomLoader()
                      : ForumThreadItem(thread: state.threads[index - 1]);
                },
              );
            default:
              return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _builderFilterButtons(BuildContext context, String? filter) {
    final selectedStyle = null;

    final unselectedStyle = ButtonStyle(
      foregroundColor: MaterialStateProperty.all(Colors.grey),
      backgroundColor:
          MaterialStateProperty.all<Color>(Theme.of(context).backgroundColor),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          child: Text('默认'),
          style: (filter == null || filter == 'typeid')
              ? selectedStyle
              : unselectedStyle,
          onPressed: () {
            context.read<ThreadListBloc>().add(ThreadListReloaded());
          },
        ),
        ElevatedButton(
          child: Text('最新'),
          style: filter == 'dateline' ? selectedStyle : unselectedStyle,
          onPressed: () {
            context.read<ThreadListBloc>().add(ThreadListReloaded(
                filter: 'dateline', param: {'orderby': 'dateline'}));
          },
        ),
        ElevatedButton(
          child: Text('热门'),
          style: filter == 'heat' ? selectedStyle : unselectedStyle,
          onPressed: () {
            context.read<ThreadListBloc>().add(ThreadListReloaded(
                filter: 'heat', param: {'orderby': 'heats'}));
          },
        ),
        ElevatedButton(
          child: Text('热帖'),
          style: filter == 'hot' ? selectedStyle : unselectedStyle,
          onPressed: () {
            context
                .read<ThreadListBloc>()
                .add(ThreadListReloaded(filter: 'hot'));
          },
        ),
        ElevatedButton(
          child: Text('精华'),
          style: filter == 'digest' ? selectedStyle : unselectedStyle,
          onPressed: () {
            context.read<ThreadListBloc>().add(
                ThreadListReloaded(filter: 'digest', param: {'digest': '1'}));
          },
        ),
      ],
    );
  }
}

class TypedForumThreadList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TypedForumThreadList();
}

class _TypedForumThreadList extends State<TypedForumThreadList> {
  final _controller = ScrollController();

  @override
  void initState() {
    _controller.addListener(_onScroll);

    super.initState();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();

    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _controller.position.maxScrollExtent;
    final pixels = _controller.position.pixels;

    if (maxScroll == pixels) {
      context.read<ThreadListBloc>().add(ThreadListLoaded());
    }
  }

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
            case ThreadListStatus.success:
              return ListView.builder(
                padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
                controller: _controller,
                itemCount: state.hasReachedMax
                    ? state.threads.length
                    : state.threads.length + 1,
                itemBuilder: (context, index) {
                  return index >= state.threads.length
                      ? BottomLoader()
                      : ForumThreadItem(thread: state.threads[index]);
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
