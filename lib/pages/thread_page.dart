import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/constants.dart';
import 'package:keylol_flutter/common/keylol_client.dart';
import 'package:keylol_flutter/common/notifiers.dart';
import 'package:keylol_flutter/common/styling.dart';
import 'package:keylol_flutter/components/post_card.dart';
import 'package:keylol_flutter/components/rich_text.dart';
import 'package:keylol_flutter/components/sliver_tab_bar_delegate.dart';
import 'package:keylol_flutter/components/throwable_future_builder.dart';
import 'package:keylol_flutter/models/favorite_thread.dart';
import 'package:keylol_flutter/models/view_thread.dart';
import 'package:url_launcher/url_launcher.dart';

class ThreadPage extends StatefulWidget {
  final String tid;

  const ThreadPage({Key? key, required this.tid}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ThreadPageState();
}

class _ThreadPageState extends State<ThreadPage> {
  late Future<List<Object>> _future;

  var _page = 1;
  var _total = 0;
  List<ViewThreadPost> _posts = [];
  final _controller = ScrollController();

  String? error;

  @override
  void initState() {
    super.initState();
    _onRefresh();

    _controller.addListener(() {
      final maxScroll = _controller.position.maxScrollExtent;
      final pixels = _controller.position.pixels;
      if (maxScroll == pixels) {
        setState(() {
          _loadMore();
        });
      }
    });
  }

  Future<void> _onRefresh() async {
    final future = Future.wait([
      KeylolClient().fetchThread(widget.tid, 1),
      KeylolClient().fetchAllFavoriteThreads()
    ]);
    setState(() {
      _future = future;
      _page = 1;
      _total = 0;
      _posts = [];
    });
  }

  Future<void> _loadMore() async {
    try {
      final page = _page + 1;
      final viewThread = await KeylolClient().fetchThread(widget.tid, page);
      final posts = viewThread.posts ?? [];
      setState(() {
        error = null;
        _total = (viewThread.replies ?? 0) + 1;
        if (posts.isNotEmpty) {
          for (final post in posts) {
            if (post.position! > _posts[_posts.length - 1].position!) {
              _posts.add(post);
              _page = page;
            }
          }
        }
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ThrowableFutureBuilder(
        future: _future,
        builder: (context, List<Object> results) {
          final viewThread = (results[0] as ViewThread);
          final favoriteThreads = (results[1] as List<FavoriteThread>);

          if (_posts.isEmpty) {
            _page = 1;
            _total = (viewThread.replies ?? 0) + 1;
            _posts = viewThread.posts ?? [];
          }

          final title = viewThread.subject ?? '';

          // TODO material 长标题需展开，官方没有实现, FlexibleSpaceBar 效果不行
          // final mediaQuery = MediaQuery.of(context);
          // final availableWidth = mediaQuery.size.width - 72.0 - 88.0;
          // final textSize = calTextSize(context, title,
          //     style: Theme.of(context).textTheme.headline6,
          //     maxWidth: availableWidth);

          return Scaffold(
              body: Stack(children: [
            CustomScrollView(
              controller: _controller,
              slivers: [
                SliverAppBar(
                  forceElevated: true,
                  // expandedHeight: textSize.height,
                  actions: _buildActions(context, viewThread, favoriteThreads),
                  // title: Text(title),
                  // flexibleSpace: FlexibleSpaceBar(
                  //   titlePadding: EdgeInsetsDirectional.only(
                  //       start: 72, bottom: 16.0, end: 88.0),
                  //   title: RichText(
                  //     text: TextSpan(
                  //         text: title,
                  //         style: Theme.of(context).textTheme.headline6),
                  //   ),
                  // ),
                ),
                SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                  final i = index - 1;
                  if (i == _posts.length) {
                    if (error != null) {
                      return Center(child: Text(error!));
                    }
                    return Center(
                        child: Opacity(
                      opacity: _total > _posts.length ? 1.0 : 0.0,
                      child: CircularProgressIndicator(),
                    ));
                  }
                  if (i == -1) {
                    return Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Material(
                          child: Text(title, style: AppTheme.title),
                        ));
                  }

                  final post = _posts[i];
                  return PostCard(
                      authorId: post.authorId!,
                      author: post.author!,
                      dateline: post.dateline!,
                      pid: post.pid!,
                      content: KRichText(
                        message: post.message!,
                        attachments: post.attachments ?? {},
                      ),
                      tid: post.tid!);
                }, childCount: _posts.length + 2))
              ],
            ),
            Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: _Reply(
                  fid: viewThread.fid!,
                  tid: widget.tid,
                  onSuccess: () {
                    _onRefresh();
                  },
                ))
          ]));
        },
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context, ViewThread viewThread,
      List<FavoriteThread> favoriteThreads) {
    // TODO 优化
    final isFavored = favoriteThreads.any((favoriteThread) =>
        favoriteThread.idType == 'tid' && favoriteThread.id == widget.tid);
    return [
      if (!isFavored)
        IconButton(
            onPressed: () {
              _favoriteThread(context);
            },
            icon: Icon(Icons.favorite_outline)),
      if (isFavored)
        IconButton(
            onPressed: () {
              // 取消收藏
            },
            icon: Icon(Icons.favorite)),
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
    ];
  }

  void _favoriteThread(BuildContext context) {
    final controller = TextEditingController();
    final dialog = AlertDialog(
      title: Text('收藏备注'),
      content: TextField(
        controller: controller,
      ),
      actions: [
        ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('取消')),
        ElevatedButton(
            onPressed: () async {
              await KeylolClient().favoriteThread(widget.tid, '1');
              Navigator.pop(context);
            },
            child: Text('确认'))
      ],
    );

    showDialog(context: context, builder: (context) => dialog);
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
