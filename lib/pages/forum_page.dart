import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/global.dart';
import 'package:keylol_flutter/model/forum.dart';
import 'package:keylol_flutter/pages/thread_author.dart';

class ForumPage extends StatefulWidget {
  final String fid;

  const ForumPage({Key? key, required this.fid}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  var _page = 1;
  late Future<List<ForumThread>> _future;

  @override
  void initState() {
    super.initState();

    _future = Global.keylolClient.fetchForum(widget.fid, _page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future: _future,
        builder:
            (BuildContext context, AsyncSnapshot<List<ForumThread>> snapshot) {
          if (snapshot.hasData) {
            final forumThreads = snapshot.data!
                .map(
                    (forumThread) => _ForumThreadItem(forumThread: forumThread))
                .toList();

            return ListView.builder(
                itemCount: forumThreads.length,
                itemBuilder: (context, index) {
                  return forumThreads[index];
                });
          } else if (snapshot.hasError) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class _ForumThreadItem extends StatelessWidget {
  final ForumThread forumThread;

  const _ForumThreadItem({Key? key, required this.forumThread})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final threadWidget = InkWell(
      child: Column(
        children: [
          ListTile(
            title: Text(forumThread.subject!),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ThreadAuthor(
                  uid: forumThread.authorId!,
                  username: forumThread.author!,
                  size: Size(24.0, 24.0),
                ),
                Text(forumThread.dateLine!.replaceFirst('&nbsp;', ' '))
              ],
            ),
          ),
          Divider(
            thickness: 1.0,
            height: 1.0,
          )
        ],
      ),
      onTap: () {
        Navigator.of(context).pushNamed('/thread', arguments: forumThread.tid);
      },
    );

    if (forumThread.displayOrder == 1) {
      return ClipRect(
          child: Banner(
              location: BannerLocation.topStart,
              message: '置顶',
              color: Color(0xFF81C784),
              child: threadWidget));
    }
    return threadWidget;
  }
}
