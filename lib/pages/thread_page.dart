import 'dart:async';

import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/keylol_client.dart';
import 'package:keylol_flutter/common/provider.dart';
import 'package:keylol_flutter/components/avatar.dart';
import 'package:keylol_flutter/components/reply_modal.dart';
import 'package:keylol_flutter/components/post_card.dart';
import 'package:keylol_flutter/components/rich_text.dart';
import 'package:keylol_flutter/components/throwable_future_builder.dart';
import 'package:keylol_flutter/models/favorite_thread.dart';
import 'package:keylol_flutter/models/post.dart';
import 'package:keylol_flutter/models/thread.dart';
import 'package:keylol_flutter/models/view_thread.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
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
  final _controller = AutoScrollController();

  String? error;

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
              floatingActionButton: FloatingActionButton(
                  child: Icon(Icons.add),
                  onPressed: () {
                    Navigator.of(context)
                        .push(ReplyRoute(viewThread.thread, null, () {}));
                  }),
              body: ListView.builder(
                  addAutomaticKeepAlives: true,
                  controller: _controller,
                  itemCount: _widgets.length,
                  itemBuilder: (context, index) {
                    return AutoScrollTag(
                      key: ValueKey(index),
                      controller: _controller,
                      index: index,
                      child: _widgets[index],
                    );
                  }));
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
      // 异常
      if (error != null) Center(child: Text(error!)),
      // loading
      if (error == null)
        Center(
            child: Opacity(
          opacity: _total > _posts.length ? 1.0 : 0.0,
          child: CircularProgressIndicator(),
        ))
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
        _controller.scrollToIndex(index);
        return;
      }
      index++;
    }
    _loadMore().then((value) => _scrollTo(pid));
  }
}
