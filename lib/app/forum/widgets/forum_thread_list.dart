import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/forum/bloc/forum/thread_list_bloc.dart';
import 'package:keylol_flutter/app/forum/widgets/forum_thread_item.dart';
import 'package:keylol_flutter/components/list_divider.dart';

import 'bottom_loader.dart';

class ForumThreadList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ForumThreadListState();
}

class _ForumThreadListState extends State<ForumThreadList> {
  late String _currentSort;
  late ScrollController _controller;

  @override
  void initState() {
    _currentSort = '默认';
    _controller = ScrollController();
    _controller.addListener(() {
      final maxScroll = _controller.position.maxScrollExtent;
      final pixels = _controller.position.pixels;

      if (maxScroll == pixels) {
        context.read<ThreadListBloc>().add(ThreadListLoaded());
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  Widget _buildFilterMenu(BuildContext context, String? filter) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        PopupMenuButton(
          child: TextButton.icon(
            onPressed: null,
            style: ButtonStyle(
                foregroundColor: MaterialStateProperty.resolveWith((state) {
              return Theme.of(context).colorScheme.onSurface;
            })),
            icon: Icon(Icons.align_horizontal_left),
            label: Text(_currentSort),
          ),
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                child: Text('默认'),
                onTap: () {
                  setState(() {
                    _currentSort = '默认';
                  });
                  context.read<ThreadListBloc>().add(ThreadListReloaded());
                },
              ),
              PopupMenuItem(
                child: Text('最新'),
                onTap: () {
                  setState(() {
                    _currentSort = '最新';
                  });
                  context.read<ThreadListBloc>().add(ThreadListReloaded(
                      filter: 'dateline', param: {'orderby': 'dateline'}));
                },
              ),
              PopupMenuItem(
                child: Text('热门'),
                onTap: () {
                  setState(() {
                    _currentSort = '热门';
                  });
                  context.read<ThreadListBloc>().add(ThreadListReloaded(
                      filter: 'heat', param: {'orderby': 'heats'}));
                },
              ),
              PopupMenuItem(
                child: Text('热帖'),
                onTap: () {
                  setState(() {
                    _currentSort = '热帖';
                  });
                  context
                      .read<ThreadListBloc>()
                      .add(ThreadListReloaded(filter: 'hot'));
                },
              ),
              PopupMenuItem(
                child: Text('精华'),
                onTap: () {
                  setState(() {
                    _currentSort = '精华';
                  });
                  context.read<ThreadListBloc>().add(ThreadListReloaded(
                      filter: 'digest', param: {'digest': '1'}));
                },
              ),
            ];
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ThreadListBloc>().add(ThreadListReloaded());
      },
      child: BlocBuilder<ThreadListBloc, ThreadListState>(
        builder: (context, state) {
          if (state.status != ThreadListStatus.success) {
            return Center(child: CircularProgressIndicator());
          }

          final threads = state.threads;
          final itemCount = state.threads.length + 2;
          return ListView.separated(
            padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
            controller: _controller,
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildFilterMenu(context, state.filter);
              }
              return index == itemCount - 1
                  ? (state.hasReachedMax ? Container() : BottomLoader())
                  : ForumThreadItem(thread: threads[index - 1]);
            },
            separatorBuilder: (context, index) {
              return ListDivider(isLast: index == 0 || index == itemCount - 1);
            },
          );
        },
      ),
    );
  }
}
