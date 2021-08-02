import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:keylol_flutter/common/global.dart';
import 'package:keylol_flutter/models/view_thread.dart';
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
          Widget body;
          if (snapshot.hasData) {
            final viewThread = snapshot.data!;
            body = _PostList(tid: widget.tid, posts: viewThread.posts ?? []);
          } else {
            body = Center(
              child: CircularProgressIndicator(),
            );
          }

          return Scaffold(
            appBar: AppBar(),
            body: body,
          );
        });
  }
}

class _PostList extends StatefulWidget {
  final String tid;
  final List<ViewThreadPost> posts;

  const _PostList({Key? key, required this.tid, required this.posts})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PostListState();
}

class _PostListState extends State<_PostList> {
  var _page = 1;
  late List<ViewThreadPost> _posts;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();
  final StreamController<List<ViewThreadPost>> _streamController =
      StreamController();

  @override
  void initState() {
    super.initState();
    _init();
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final pixels = _scrollController.position.pixels;
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
      if (posts[1].position! > _posts[_posts.length - 1].position!) {
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
            return ListView.builder(
                controller: _scrollController,
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return _PostItem(post: post);
                });
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ThreadAuthor(
                uid: widget.post.authorId!,
                username: widget.post.author!,
                size: Size(24.0, 24.0)),
            Text(widget.post.dateline!.replaceAll('&nbsp;', ''))
          ],
        ),
        Divider(
          thickness: 1.0,
          height: 1.0,
        ),
        Html(
          data: widget.post.message!,
        )
      ],
    );
  }
}
