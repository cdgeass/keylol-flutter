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
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot<ViewThread> snapshot) {
          if (snapshot.hasData) {
            final viewThread = snapshot.data!;
            final posts = viewThread.posts!;
            return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return _PostItem(post: post);
                });
          }

          return Center(
            child: CircularProgressIndicator(),
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
