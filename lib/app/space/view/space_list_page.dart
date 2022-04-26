import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:keylol_flutter/app/space/bloc/space_friend_bloc.dart';
import 'package:keylol_flutter/app/space/bloc/space_reply_bloc.dart';
import 'package:keylol_flutter/app/space/bloc/space_thread_bloc.dart';
import 'package:keylol_flutter/components/avatar.dart';

class SpaceListPage extends StatelessWidget {
  final String uid;
  final int initialIndex;

  const SpaceListPage({
    Key? key,
    required this.uid,
    required this.initialIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final client = context.read<KeylolApiClient>();

    return DefaultTabController(
      length: 3,
      initialIndex: initialIndex,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [Tab(text: '好友'), Tab(text: '主题'), Tab(text: '回复')],
          ),
        ),
        body: TabBarView(
          children: [
            BlocProvider(
              create: (_) => SpaceFriendBloc(client: client, uid: uid)
                ..add(SpaceFriendReloaded()),
              child: _SpaceFriendList(),
            ),
            BlocProvider(
              create: (_) => SpaceThreadBloc(client: client, uid: uid)
                ..add(SpaceThreadReloaded()),
              child: _SpaceThreadList(),
            ),
            BlocProvider(
              create: (_) => SpaceReplyBloc(client: client, uid: uid)
                ..add(SpaceReplyReloaded()),
              child: _SpaceReplyList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpaceFriendList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SpaceFriendListState();
}

class _SpaceFriendListState extends State<_SpaceFriendList> {
  late final ScrollController _controller;

  @override
  void initState() {
    _controller = ScrollController();
    _controller.addListener(() {
      final maxScroll = _controller.position.maxScrollExtent;
      final pixels = _controller.position.pixels;
      if (maxScroll == pixels) {
        context.read<SpaceFriendBloc>().add(SpaceFriendLoaded());
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpaceFriendBloc, SpaceFriendState>(
      builder: (context, state) {
        late Widget child;
        if (state.status != SpaceFriendStatus.initial) {
          final list = state.friends;
          final hasReachedMax = state.hasReachedMax;

          child = ListView.separated(
            controller: _controller,
            itemCount: list.length + 1,
            itemBuilder: (context, index) {
              if (index == list.length) {
                return Opacity(
                    opacity: hasReachedMax ? 0.0 : 1.0,
                    child: Center(child: CircularProgressIndicator()));
              }
              final friend = list[index];
              return ListTile(
                leading: Avatar(
                  uid: friend.uid,
                  size: AvatarSize.middle,
                  width: 40.0,
                ),
                title: Text(friend.username),
                onTap: () {
                  Navigator.of(context)
                      .pushNamed('/profile', arguments: friend.uid);
                },
              );
            },
            separatorBuilder: (context, index) => Divider(),
          );
        } else {
          child = Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<SpaceFriendBloc>().add(SpaceFriendReloaded());
          },
          child: child,
        );
      },
    );
  }
}

class _SpaceThreadList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SpaceThreadListState();
}

class _SpaceThreadListState extends State<_SpaceThreadList> {
  late final ScrollController _controller;

  @override
  void initState() {
    _controller = ScrollController();
    _controller.addListener(() {
      final maxScroll = _controller.position.maxScrollExtent;
      final pixels = _controller.position.pixels;
      if (maxScroll == pixels) {
        context.read<SpaceThreadBloc>().add(SpaceThreadLoaded());
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpaceThreadBloc, SpaceThreadState>(
      builder: (context, state) {
        late Widget child;
        if (state.status != SpaceThreadStatus.initial) {
          final list = state.threads;
          final hasReachedMax = state.hasReachedMax;

          child = ListView.separated(
            controller: _controller,
            itemCount: list.length + 1,
            itemBuilder: (context, index) {
              if (index == list.length) {
                return Opacity(
                    opacity: hasReachedMax ? 0.0 : 1.0,
                    child: Center(child: CircularProgressIndicator()));
              }
              final thread = list[index];
              return ListTile(
                title: Text(thread.subject),
                onTap: () {
                  Navigator.of(context)
                      .pushNamed('/thread', arguments: thread.tid);
                },
              );
            },
            separatorBuilder: (context, index) => Divider(),
          );
        } else {
          child = Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<SpaceThreadBloc>().add(SpaceThreadReloaded());
          },
          child: child,
        );
      },
    );
  }
}

class _SpaceReplyList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SpaceReplyListState();
}

class _SpaceReplyListState extends State<_SpaceReplyList> {
  late final ScrollController _controller;

  @override
  void initState() {
    _controller = ScrollController();
    _controller.addListener(() {
      final maxScroll = _controller.position.maxScrollExtent;
      final pixels = _controller.position.pixels;
      if (maxScroll == pixels) {
        context.read<SpaceReplyBloc>().add(SpaceReplyLoaded());
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpaceReplyBloc, SpaceReplyState>(
      builder: (context, state) {
        late Widget child;
        if (state.status != SpaceReplyStatus.initial) {
          final list = state.replies;
          final hasReachedMax = state.hasReachedMax;

          child = ListView.separated(
            controller: _controller,
            itemCount: list.length + 1,
            itemBuilder: (context, index) {
              if (index == list.length) {
                return Opacity(
                    opacity: hasReachedMax ? 0.0 : 1.0,
                    child: Center(child: CircularProgressIndicator()));
              }
              final reply = list[index];

              return ListTile(
                title: Text(reply.message),
                subtitle: Text(reply.subject),
                onTap: () {
                  Navigator.of(context)
                      .pushNamed('/thread', arguments: [reply.tid, reply.pid]);
                },
              );
            },
            separatorBuilder: (context, index) => Divider(),
          );
        } else {
          child = Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<SpaceReplyBloc>().add(SpaceReplyReloaded());
          },
          child: child,
        );
      },
    );
  }
}
