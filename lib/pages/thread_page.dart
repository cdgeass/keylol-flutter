import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/constants.dart';
import 'package:keylol_flutter/common/keylol_client.dart';
import 'package:keylol_flutter/common/provider.dart';
import 'package:keylol_flutter/components/avatar.dart';
import 'package:keylol_flutter/components/smiley_modal.dart';
import 'package:keylol_flutter/components/post_card.dart';
import 'package:keylol_flutter/components/rich_text.dart';
import 'package:keylol_flutter/components/sliver_tab_bar_delegate.dart';
import 'package:keylol_flutter/components/throwable_future_builder.dart';
import 'package:keylol_flutter/models/favorite_thread.dart';
import 'package:keylol_flutter/models/post.dart';
import 'package:keylol_flutter/models/thread.dart';
import 'package:keylol_flutter/models/view_thread.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:url_launcher/url_launcher.dart';

class ThreadPage extends StatefulWidget {
  final String tid;

  const ThreadPage({Key? key, required this.tid}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ThreadPageState();
}

class _ThreadPageState extends State<ThreadPage> {
  late Future<ViewThread> _future;
  List<Widget> _widgets = [];

  var _page = 1;
  var _total = 0;
  List<Post> _posts = [];
  final _controller = ItemScrollController();
  final _listener = ItemPositionsListener.create();

  String? error;

  @override
  void initState() {
    super.initState();
    _onRefresh();

    _listener.itemPositions.addListener(() {
      final max = _listener.itemPositions.value
          .where((position) => position.itemLeadingEdge < 1)
          .reduce((max, position) =>
              position.itemLeadingEdge > max.itemLeadingEdge ? position : max)
          .index;
      if (max == _widgets.length - 1) {
        _loadMore();
      }
    });
  }

  Future<void> _onRefresh() async {
    final future = KeylolClient().fetchThread(widget.tid, 1);
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
      final posts = viewThread.postList;
      setState(() {
        error = null;
        _total = viewThread.thread.replies + 1;
        if (posts.isNotEmpty) {
          for (final post in posts) {
            if (post.number > _posts[_posts.length - 1].number) {
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
        builder: (context, ViewThread viewThread) {
          if (_posts.isEmpty) {
            _page = 1;
            _total = viewThread.thread.replies + 1;
            _posts = viewThread.postList;
          }

          _buildList(context, viewThread.thread);

          return Scaffold(
              appBar: AppBar(
                actions: _buildActions(context, viewThread),
              ),
              body: Stack(children: [
                ScrollablePositionedList.builder(
                    addAutomaticKeepAlives: true,
                    itemScrollController: _controller,
                    itemPositionsListener: _listener,
                    itemCount: _widgets.length,
                    itemBuilder: (context, index) {
                      return _widgets[index];
                    }),
                Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: _Reply(
                      fid: viewThread.fid,
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

  void _buildList(
    BuildContext context,
    Thread thread,
  ) {
    final title = thread.subject;
    // 拆分 html 延迟加载 iframe
    _widgets =
        KRichTextBuilder(_posts[0].message, attachments: _posts[0].attachments)
            .splitBuild();
    // merge thread and posts
    _widgets = [
      // 标题
      Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(title, style: Theme.of(context).textTheme.headline6),
      ),
      // 帖子作者
      Material(
          color: Theme.of(context).cardColor,
          child: _buildFirstHeader(_posts[0])),
      // 帖子
      for (var widget in _widgets)
        Material(color: Theme.of(context).cardColor, child: widget),
      // 帖子操作
      Material(
          color: Theme.of(context).cardColor,
          elevation: 1.0,
          shadowColor: Theme.of(context).cardTheme.shadowColor,
          child: _buildFirstBottom(_posts[0])),
      // 回复
      for (var post in _posts.sublist(1))
        PostCard(
            post: post,
            builder: (post) {
              return KRichTextBuilder(post.message,
                      attachments: post.attachments, scrollTo: _scrollTo)
                  .build();
            }),
      // loading error
      _buildLoading()
    ];
  }

  Widget _buildFirstHeader(Post post) {
    return ListTile(
      leading: Avatar(
        uid: post.authorId,
        size: AvatarSize.middle,
        width: 40.0,
      ),
      title: Text(post.author),
      subtitle: Text(post.dateline),
    );
  }

  Widget _buildFirstBottom(Post post) {
    return ButtonBar(
      alignment: MainAxisAlignment.start,
      children: [
        IconButton(
            onPressed: () {
              // TODO 评分
            },
            icon: Icon(Icons.thumb_up_outlined)),
        IconButton(
            onPressed: () {
              KeylolClient()
                  .recommend(widget.tid)
                  .then((value) => _onRefresh());
            },
            icon: Icon(Icons.plus_one_outlined)),
      ],
    );
  }

  Widget _buildLoading() {
    return ValueListenableBuilder<Iterable<ItemPosition>>(
        valueListenable: _listener.itemPositions,
        builder: (context, positions, child) {
          if (positions.isNotEmpty) {
            final max = positions
                .where((position) => position.itemLeadingEdge < 1)
                .reduce((max, position) =>
                    position.itemLeadingEdge > max.itemLeadingEdge
                        ? position
                        : max)
                .index;
            if (max == _widgets.length - 1) {
              // 异常
              if (error != null) return Center(child: Text(error!));
              // loading
              if (error == null)
                return Center(
                    child: Opacity(
                  opacity: _total > _posts.length ? 1.0 : 0.0,
                  child: CircularProgressIndicator(),
                ));
            }
          }
          return Container();
        });
  }

  List<Widget> _buildActions(BuildContext context, ViewThread viewThread) {
    FavoriteThread? favoriteThread;
    for (var value
        in Provider.of<FavoriteThreadsProvider>(context).favoriteThreads) {
      if (value.idType == 'tid' && value.id == widget.tid) {
        favoriteThread = value;
        break;
      }
    }
    return [
      if (favoriteThread == null)
        IconButton(
            onPressed: () {
              _favoriteThread(context);
            },
            icon: Icon(Icons.favorite_outline)),
      if (favoriteThread != null)
        IconButton(
            onPressed: () {
              final favId = favoriteThread!.favId;
              KeylolClient()
                  .deleteFavoriteThread(favId)
                  .then((value) => FavoriteThreadsProvider().delete(favId));
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

  void _scrollTo(String pid) {
    var index = 0;
    for (final widget in _widgets) {
      if (widget is PostCard && widget.post.pid == pid) {
        _controller.scrollTo(index: index, duration: Duration(seconds: 1));
        return;
      }
      index++;
    }
    _loadMore().then((value) => _scrollTo(pid));
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
    final profile = Provider.of<ProfileProvider>(context).profile;
    if (profile != null) {
      return Material(
          child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.emoji_emotions_outlined),
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  builder: (_) {
                    return SmileyModal(onSelect: (smiley) {
                      _controller.text = _controller.text + smiley;
                    });
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
                  final replyFuture =
                      KeylolClient().sendReply(widget.tid, message);
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
}
