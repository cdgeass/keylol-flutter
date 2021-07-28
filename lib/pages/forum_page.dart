import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/global.dart';
import 'package:keylol_flutter/model/forum.dart';
import 'package:keylol_flutter/model/profile.dart';

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
            final forumThreads = snapshot.data!;

            return ListView(
              children: [
                for (final forumThread in forumThreads)
                  _ForumThreadItem(forumThread: forumThread)
              ],
            );
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
    return InkWell(
      child: Column(
        children: [
          ListTile(
            title: Text(forumThread.subject!),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ForumThreadAuthorItem(
                    authorId: forumThread.authorId!,
                    author: forumThread.author!),
                Text(forumThread.dateLine!.replaceFirst('&nbsp;', ' '))
              ],
            ),
          ),
          Divider()
        ],
      ),
      onTap: () {
        Navigator.of(context).pushNamed('/thread', arguments: forumThread.tid);
      },
    );
  }
}

class _ForumThreadAuthorItem extends StatefulWidget {
  final String authorId;
  final String author;

  const _ForumThreadAuthorItem(
      {Key? key, required this.authorId, required this.author})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ForumThreadAuthorItemState();
}

class _ForumThreadAuthorItemState extends State<_ForumThreadAuthorItem> {
  late Future<Profile> _future;

  @override
  void initState() {
    super.initState();

    _future = Global.keylolClient.fetchProfile(uid: widget.authorId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<Profile> snapshot) {
        // if (snapshot.hasData) {
        //   final profile = snapshot.data!;
        //   return Row(
        //     mainAxisAlignment: MainAxisAlignment.start,
        //     children: [
        //       ClipOval(
        //         child: FadeInImage.assetNetwork(
        //             height: 16.0,
        //             placeholder: 'images/unknown_avatar.jpg',
        //             image: profile.memberAvatar!),
        //       ),
        //       SizedBox(
        //         width: 4.0,
        //       ),
        //       Text(profile.memberUsername!)
        //     ],
        //   );
        // }

        return Text(widget.author);
      },
    );
  }
}
