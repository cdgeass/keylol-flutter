import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/constants.dart';
import 'package:keylol_flutter/common/global.dart';
import 'package:keylol_flutter/models/view_thread.dart';
import 'package:keylol_flutter/pages/avatar.dart';
import 'package:keylol_flutter/pages/rich_text.dart';
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
              appBar: AppBar(
                title: Text(viewThread.subject!),
              ),
              body: _PostList(
                tid: widget.tid,
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

    widget.scrollController.addListener(() {
      final maxScroll = widget.scrollController.position.maxScrollExtent;
      final pixels = widget.scrollController.position.pixels;
      if (maxScroll == pixels) {
        setState(() {
          _loadMore();
        });
      }
    });
  }

  Future<void> _onRefresh() async {
    final viewThread = await Global.keylolClient.fetchThread(widget.tid, 1);
    setState(() {
      _page = 1;
      _total = (viewThread.replies ?? 0) + 1;
      _posts = viewThread.posts ?? [];
    });
  }

  void _loadMore() async {
    final page = _page + 1;
    final viewThread = await Global.keylolClient.fetchThread(widget.tid, page);
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
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.separated(
        controller: widget.scrollController,
        itemCount: _posts.length + 1,
        itemBuilder: (context, index) {
          if (index == _posts.length) {
            return Center(
                child: Opacity(
              opacity: _total > _posts.length ? 1.0 : 0.0,
              child: CircularProgressIndicator(),
            ));
          } else {
            return _PostItem(post: _posts[index]);
          }
        },
        separatorBuilder: (context, index) {
          return Divider(
            thickness: 1.0,
            height: 1.0,
          );
        },
      ),
    );
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
        _PostContent(
          post: widget.post,
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
