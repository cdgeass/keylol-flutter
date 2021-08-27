import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/constants.dart';
import 'package:keylol_flutter/common/global.dart';
import 'package:keylol_flutter/models/view_thread.dart';
import 'package:keylol_flutter/pages/avatar.dart';
import 'package:keylol_flutter/pages/post_content.dart';
import 'package:keylol_flutter/pages/thread_author.dart';

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
    _future = Global.keylolClient.fetchThread(widget.tid, _page);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot<ViewThread> snapshot) {
          if (snapshot.hasError) {
            final error = snapshot.error!;
            return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Text(error as String),
              ),
            );
          }
          if (snapshot.hasData) {
            final viewThread = snapshot.data!;
            return Scaffold(
              appBar: AppBar(),
              body: _PostList(
                tid: widget.tid,
                posts: viewThread.posts ?? [],
                scrollController: _scrollController,
              ),
              bottomNavigationBar: _Reply(
                fid: viewThread.fid!,
                tid: widget.tid,
                onSuccess: () {
                  setState(() {
                    _scrollController.animateTo(0.0,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.decelerate);
                    _page = 1;
                    _future =
                        Global.keylolClient.fetchThread(widget.tid, _page);
                  });
                },
              ),
            );
          } else {
            return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }
}

class _PostList extends StatefulWidget {
  final String tid;
  final List<ViewThreadPost> posts;
  final ScrollController scrollController;

  const _PostList(
      {Key? key,
      required this.tid,
      required this.posts,
      required this.scrollController})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PostListState();
}

class _PostListState extends State<_PostList> {
  late int _page;
  late List<ViewThreadPost> _posts;
  late bool _hasMore;
  final StreamController<List<ViewThreadPost>> _streamController =
      StreamController();

  @override
  void initState() {
    super.initState();
    _init();
    widget.scrollController.addListener(() {
      final maxScroll = widget.scrollController.position.maxScrollExtent;
      final pixels = widget.scrollController.position.pixels;
      if (maxScroll == pixels) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _streamController.close();
  }

  void _init() {
    _page = 1;
    _posts = List.from(widget.posts);
    _hasMore = true;
    _streamController.sink.add(_posts);
  }

  void _loadMore() async {
    if (!_hasMore) {
      return;
    }
    _page++;
    final viewThread = await Global.keylolClient.fetchThread(widget.tid, _page);
    final posts = viewThread.posts;
    if (posts != null && posts.isNotEmpty) {
      if (posts[0].position! > _posts[_posts.length - 1].position!) {
        _hasMore = true;
        _posts.addAll(posts);
      } else {
        _hasMore = false;
      }
    }
    _streamController.sink.add(_posts);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () {
          _init();
          return Future.value();
        },
        child: StreamBuilder(
          stream: _streamController.stream,
          builder: (context, AsyncSnapshot<List<ViewThreadPost>> snapshot) {
            final posts = snapshot.data ?? [];
            return ListView.separated(
              controller: widget.scrollController,
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return _PostItem(post: post);
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider(
                  thickness: 1.0,
                  height: 1.0,
                );
              },
            );
          },
        ));
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
    return Column(
      children: [
        ListTile(
          leading: Avatar(
            avatarUrl: avatarUrl + widget.post.authorId!,
            size: Size(40.0, 40.0),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ThreadAuthor(
                uid: widget.post.authorId!,
                username: widget.post.author!,
                size: Size(1.0, 1.0),
                needAvatar: false,
              ),
              Text(widget.post.number.toString() + '楼')
            ],
          ),
          subtitle: Text(widget.post.dateline!.replaceAll('&nbsp;', '')),
        ),
        PostContent(
          message: widget.post.message!,
          specialPoll: widget.post.specialPoll,
        ),
      ],
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
    final profile = Global.profileHolder.profile;
    if (profile != null) {
      final formHash = profile.formHash!;
      return Row(
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
                  final replyFuture = Global.keylolClient
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
      );
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
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverTabBarDelegate(TabBar(
                      indicatorColor: Colors.blueAccent,
                      labelColor: Colors.blueAccent,
                      unselectedLabelColor: Colors.black,
                      isScrollable: true,
                      tabs: EMOJI_MAP.keys
                          .map((key) => Tab(text: key))
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

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
