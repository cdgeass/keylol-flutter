import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/keylol_client.dart';
import 'package:keylol_flutter/components/avatar.dart';
import 'package:keylol_flutter/components/throwable_future_builder.dart';
import 'package:keylol_flutter/models/space.dart';
import 'package:keylol_flutter/app/thread/models/thread.dart';

class SpaceThreadPage extends StatelessWidget {
  final Space space;
  final int initialIndex;

  const SpaceThreadPage(
      {Key? key, required this.space, required this.initialIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              _SpaceFriendList(uid: space.uid),
              _SpaceThreadList(uid: space.uid),
              _SpaceReplyList(uid: space.uid),
            ],
          ),
        ));
  }
}

// 好友
class _SpaceFriendList extends StatefulWidget {
  final String uid;

  const _SpaceFriendList({Key? key, required this.uid}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SpaceFriendListState();
}

class _SpaceFriendListState extends State<_SpaceFriendList> {
  late Future<SpaceFriend> _future;
  final ScrollController _controller = ScrollController();

  int _page = 1;
  List<Friend> _list = [];
  int _count = 0;

  @override
  void initState() {
    super.initState();

    _onRefresh();

    _controller.addListener(() {
      final maxScroll = _controller.position.maxScrollExtent;
      final pixels = _controller.position.pixels;
      if (maxScroll == pixels) {
        _loadMore();
      }
    });
  }

  Future<void> _onRefresh() async {
    _future = KeylolClient().fetchFriend(widget.uid, page: 1);
    _page = 1;
    _list = [];
    _count = 0;
    setState(() {});
  }

  void _loadMore() async {
    _page += 1;
    final spaceFriend =
        await KeylolClient().fetchFriend(widget.uid, page: _page);

    _count = spaceFriend.count;
    final friendList = spaceFriend.friendList;

    if (friendList.isNotEmpty) {
      _list.addAll(friendList);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: _onRefresh,
        child: ThrowableFutureBuilder(
          future: _future,
          builder: (context, SpaceFriend spaceFriend) {
            final friendList = spaceFriend.friendList;

            _count = spaceFriend.count;
            if (_list.isEmpty) {
              _list.addAll(friendList);
            }

            return ListView.separated(
                itemCount: _list.length + 1,
                itemBuilder: (context, index) {
                  if (index == _list.length) {
                    return Opacity(
                        opacity: _list.length < _count ? 1.0 : 0.0,
                        child: Center(child: CircularProgressIndicator()));
                  }
                  final friend = _list[index];
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
                separatorBuilder: (context, index) => Divider());
          },
        ));
  }
}

// 主题
class _SpaceThreadList extends StatefulWidget {
  final String uid;

  const _SpaceThreadList({Key? key, required this.uid}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SpaceThreadListState();
}

class _SpaceThreadListState extends State<_SpaceThreadList> {
  late Future<SpaceThread> _future;
  final ScrollController _controller = ScrollController();

  int _page = 1;
  List<Thread> _list = [];
  bool _haseMore = true;

  @override
  void initState() {
    super.initState();

    _onRefresh();

    _controller.addListener(() {
      final maxScroll = _controller.position.maxScrollExtent;
      final pixels = _controller.position.pixels;
      if (maxScroll == pixels) {
        _loadMore();
      }
    });
  }

  Future<void> _onRefresh() async {
    _future = KeylolClient().fetchSpaceThread(widget.uid, page: 1);
    _page = 1;
    _list = [];
    setState(() {});
  }

  void _loadMore() async {
    _page += 1;
    final spaceThread =
        await KeylolClient().fetchSpaceThread(widget.uid, page: _page);

    final threadList = spaceThread.threadList;

    bool changed = false;
    if (_list.isEmpty) {
      _list.addAll(threadList);
      changed = true;
    } else {
      final lastThread = _list[_list.length - 1];

      for (final thread in threadList) {
        if (thread.tid != lastThread.tid) {
          _list.add(thread);
          changed = true;
        }
      }
    }

    if (changed) {
      if (threadList.length < 20) {
        _haseMore = false;
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: _onRefresh,
        child: ThrowableFutureBuilder(
          future: _future,
          builder: (context, SpaceThread spaceThread) {
            final threadList = spaceThread.threadList;

            if (_list.isEmpty) {
              _list.addAll(threadList);
            }
            if (threadList.length < 20) {
              _haseMore = false;
            }

            return ListView.separated(
                controller: _controller,
                itemCount: _list.length + 1,
                itemBuilder: (context, index) {
                  if (index == _list.length) {
                    return Opacity(
                        opacity: _haseMore ? 1.0 : 0.0,
                        child: Center(child: CircularProgressIndicator()));
                  }
                  final thread = _list[index];
                  return ListTile(
                    title: Text(thread.subject),
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed('/thread', arguments: thread.tid);
                    },
                  );
                },
                separatorBuilder: (context, index) => Divider());
          },
        ));
  }
}

// 回复
class _SpaceReplyList extends StatefulWidget {
  final String uid;

  const _SpaceReplyList({Key? key, required this.uid}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SpaceReplyListState();
}

class _SpaceReplyListState extends State<_SpaceReplyList> {
  late Future<SpaceReply> _future;
  final ScrollController _controller = ScrollController();

  int _page = 1;
  List<SpaceReplyItem> _list = [];
  bool _haseMore = true;

  @override
  void initState() {
    super.initState();

    _onRefresh();

    _controller.addListener(() {
      final maxScroll = _controller.position.maxScrollExtent;
      final pixels = _controller.position.pixels;
      if (maxScroll == pixels) {
        _loadMore();
      }
    });
  }

  Future<void> _onRefresh() async {
    _future = KeylolClient().fetchSpaceReply(widget.uid, page: 1);
    _page = 1;
    _list = [];
    setState(() {});
  }

  void _loadMore() async {
    _page += 1;
    final spaceReply =
        await KeylolClient().fetchSpaceReply(widget.uid, page: _page);

    final replyList = spaceReply.replyList;

    bool changed = false;
    if (_list.isEmpty) {
      _list.addAll(replyList);
      changed = true;
    } else {
      final lastReply = _list[_list.length - 1];

      for (final reply in replyList) {
        if (reply.pid != lastReply.tid) {
          _list.add(reply);
          changed = true;
        }
      }
    }

    if (changed) {
      if (replyList.length < 20) {
        _haseMore = false;
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: _onRefresh,
        child: ThrowableFutureBuilder(
          future: _future,
          builder: (context, SpaceReply spaceReply) {
            final replyList = spaceReply.replyList;

            if (_list.isEmpty) {
              _list.addAll(replyList);
            }
            if (replyList.length < 20) {
              _haseMore = false;
            }

            return ListView.separated(
                controller: _controller,
                itemCount: _list.length + 1,
                itemBuilder: (context, index) {
                  if (index == _list.length) {
                    return Opacity(
                        opacity: _haseMore ? 1.0 : 0.0,
                        child: Center(child: CircularProgressIndicator()));
                  }
                  final reply = _list[index];

                  return ListTile(
                      title: Text(reply.message),
                      subtitle: Text(reply.subject),
                      onTap: () {
                        Navigator.of(context).pushNamed('/thread',
                            arguments: [reply.tid, reply.pid]);
                      });
                },
                separatorBuilder: (context, index) => Divider());
          },
        ));
  }
}
