import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/constants.dart';
import 'package:keylol_flutter/common/keylol_client.dart';
import 'package:keylol_flutter/common/notifiers.dart';
import 'package:keylol_flutter/common/styling.dart';
import 'package:keylol_flutter/components/post_card.dart';
import 'package:keylol_flutter/components/refreshable_list_view.dart';
import 'package:keylol_flutter/components/rich_text.dart';
import 'package:keylol_flutter/components/sliver_tab_bar_delegate.dart';
import 'package:keylol_flutter/components/throwable_future_builder.dart';
import 'package:keylol_flutter/models/view_thread.dart';
import 'package:url_launcher/url_launcher.dart';

class ThreadPage extends StatefulWidget {
  final String tid;

  const ThreadPage({Key? key, required this.tid}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ThreadPageState();
}

class _ThreadPageState extends State<ThreadPage> {
  var _page = 1;
  late Future<ViewThread> _future;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _future = KeylolClient().fetchThread(widget.tid, _page);
  }

  @override
  Widget build(BuildContext context) {
    return ThrowableFutureBuilder(
        future: _future,
        builder: (context, ViewThread viewThread) {
          final appBar = AppBar(
            title: Text(viewThread.subject!),
            actions: [
              PopupMenuButton(
                icon: Icon(Icons.more_vert),
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem(
                      child: Text('在浏览器中打开'),
                      onTap: () {
                        launch('https://keylol.com/t${widget.tid}-1-1');
                      },
                    )
                  ];
                },
              )
            ],
          );
          final reply = _Reply(
            fid: viewThread.fid!,
            tid: widget.tid,
            onSuccess: () {
              setState(() {
                _scrollController.animateTo(0.0,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.decelerate);
                _page = 1;
                _future = KeylolClient().fetchThread(widget.tid, _page);
              });
            },
          );
          final body = Stack(children: [
            _PostList(
              tid: widget.tid,
              scrollController: _scrollController,
            ),
            Positioned(bottom: 0.0, left: 0.0, right: 0.0, child: reply)
          ]);

          return Scaffold(
              backgroundColor: Theme.of(context).backgroundColor,
              appBar: appBar,
              body: body);
        });
  }
}

// 帖子内回复列表
class _PostList extends StatefulWidget {
  final String tid;
  final ScrollController scrollController;

  const _PostList({Key? key, required this.tid, required this.scrollController})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PostListState();
}

class _PostListState extends State<_PostList> {
  int _page = 1;
  int _total = 0;
  List<ViewThreadPost> _posts = [];

  @override
  void initState() {
    super.initState();

    _onRefresh();
  }

  Future<void> _onRefresh() async {
    final viewThread = await KeylolClient().fetchThread(widget.tid, 1);
    setState(() {
      _page = 1;
      _total = (viewThread.replies ?? 0) + 1;
      _posts = viewThread.posts ?? [];
    });
  }

  Future<void> _loadMore() async {
    final page = _page + 1;
    final viewThread = await KeylolClient().fetchThread(widget.tid, page);
    final posts = viewThread.posts;
    setState(() {
      _total = (viewThread.replies ?? 0) + 1;
      if (posts != null && posts.isNotEmpty) {
        for (final post in posts) {
          if (post.position! > _posts[_posts.length - 1].position!) {
            _posts.add(post);
            _page = page;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshableListView(
        onRefresh: _onRefresh,
        loadMore: _loadMore,
        controller: widget.scrollController,
        list: _posts,
        total: _total,
        itemBuilder: (item) {
          return _PostItem(post: item);
        });
  }
}

class _PostItem extends StatefulWidget {
  final ViewThreadPost post;

  const _PostItem({Key? key, required this.post}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PostItemState();
}

class _PostItemState extends State<_PostItem> {
  @override
  Widget build(BuildContext context) {
    return PostCard(
      authorId: widget.post.authorId!,
      author: widget.post.author!,
      dateline: widget.post.dateline!,
      pid: widget.post.pid!,
      content: _PostContent(
        post: widget.post,
      ),
      first: widget.post.first == '1',
      tid: widget.post.tid!,
    );
  }
}

class _Reply extends StatefulWidget {
  final String fid;
  final String tid;
  final Function onSuccess;

  const _Reply(
      {Key? key, required this.fid, required this.tid, required this.onSuccess})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ReplyState();
}

class _ReplyState extends State<_Reply> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final profile = ProfileNotifier().profile;
    if (profile != null) {
      final formHash = profile.formHash!;
      return Material(
          child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.emoji_emotions_outlined),
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  builder: (_) {
                    return _buildEmojiPicker();
                  });
            },
          ),
          Expanded(
              child: Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: TextField(
              controller: _controller,
            ),
          )),
          IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                final message = _controller.text;
                if (message.isNotEmpty) {
                  final replyFuture = KeylolClient()
                      .sendReply(widget.fid, widget.tid, formHash, message);
                  replyFuture.then((_) {
                    _controller.clear();
                    showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(title: Text('回复成功'), actions: [
                            TextButton(
                                onPressed: () {
                                  widget.onSuccess.call();
                                  Navigator.pop(context);
                                },
                                child: Text('确定'))
                          ]);
                        });
                  }).onError((error, _) {
                    showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                              title: Text('回复失败'),
                              content: Text(error as String),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('确定'))
                              ]);
                        });
                  });
                }
              })
        ],
      ));
    } else {
      return Container(
        height: 0.0,
      );
    }
  }

  Widget _buildEmojiPicker() {
    return DefaultTabController(
      length: EMOJI_MAP.keys.length,
      child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverPersistentHeader(
                  pinned: true,
                  floating: true,
                  delegate: SliverTabBarDelegate(
                      tabBar: TabBar(
                          isScrollable: true,
                          tabs: EMOJI_MAP.keys
                              .map((key) => Tab(
                                  child: Text(key, style: AppTheme.subtitle)))
                              .toList()))),
            ];
          },
          body: TabBarView(
              children: EMOJI_MAP.keys.map((key) {
            var emojis = EMOJI_MAP[key]!;
            return GridView.count(
              crossAxisCount: 5,
              children: emojis.map((pair) {
                var url = pair.keys.first;
                var alt = pair[url]!;
                return GestureDetector(
                  onTap: () {
                    var text = _controller.text;
                    _controller.text = text + alt;
                  },
                  child: CachedNetworkImage(
                    imageUrl: url,
                  ),
                );
              }).toList(),
            );
          }).toList())),
    );
  }
}

class _PostContent extends StatelessWidget {
  final ViewThreadPost post;

  const _PostContent({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    children.add(KRichText(message: post.message ?? ""));
    if (post.imageList != null && post.attachments != null) {
      post.imageList!.forEach((imageId) {
        var attachment = post.attachments![imageId];
        children.add(Container(
            padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
            child: CachedNetworkImage(
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) =>
                    CircularProgressIndicator(),
                imageUrl: attachment!.url! + attachment.attachment!)));
      });
    }
    if (post.specialPoll != null) {
      children.add(Poll(specialPoll: post.specialPoll!));
    }

    return Column(children: children);
  }
}
