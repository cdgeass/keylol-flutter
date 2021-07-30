import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/global.dart';
import 'package:keylol_flutter/models/forum_display.dart';
import 'package:keylol_flutter/pages/thread_author.dart';

class ForumPage extends StatefulWidget {
  final String fid;

  const ForumPage({Key? key, required this.fid}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage>
    with SingleTickerProviderStateMixin {
  late Future<ForumDisplay> _future;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _future = Global.keylolClient.fetchForum(widget.fid, 1, null);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<ForumDisplay> snapshot) {
        if (snapshot.hasData) {
          final forumDisplay = snapshot.data!;
          final forum = forumDisplay.forum!;
          var threadTypes = forumDisplay.threadTypes!;
          _tabController =
              TabController(length: threadTypes.length + 1, vsync: this);

          return Scaffold(
              appBar: AppBar(
                title: Text(forum.name!),
                centerTitle: true,
                bottom: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: [
                    Tab(text: '全部'),
                    for (final threadType in threadTypes)
                      Tab(text: threadType.name)
                  ],
                ),
              ),
              body: TabBarView(
                controller: _tabController,
                children: [
                  _ForumThreadList(fid: forum.fid!),
                  for (final threadType in threadTypes)
                    _ForumThreadList(fid: forum.fid!, typeId: threadType.id)
                ],
              ));
        }

        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

class _ForumThreadList extends StatefulWidget {
  final String fid;
  final int? typeId;

  const _ForumThreadList({Key? key, required this.fid, this.typeId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ForumThreadListState();
}

class _ForumThreadListState extends State<_ForumThreadList> {
  var _page = 1;
  late Future<ForumDisplay> _future;
  final _digests = [
    OutlinedButton(
      child: Text('默认'),
      onPressed: () {},
    ),
    OutlinedButton(
      child: Text('最新'),
      onPressed: () {},
    ),
    OutlinedButton(
      child: Text('热门'),
      onPressed: () {},
    ),
    OutlinedButton(
      child: Text('热帖'),
      onPressed: () {},
    ),
    OutlinedButton(
      child: Text('精华'),
      onPressed: () {},
    ),
  ];

  @override
  void initState() {
    super.initState();

    _future = Global.keylolClient.fetchForum(widget.fid, _page, widget.typeId);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.typeId != null) {
      return FutureBuilder(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<ForumDisplay> snapshot) {
          if (snapshot.hasData) {
            final forumDisplay = snapshot.data!;
            final forumThreads = forumDisplay.threads!
                .map(
                    (forumThread) => _ForumThreadItem(forumThread: forumThread))
                .toList();
            return ListView.builder(
              itemCount: forumThreads.length,
              itemBuilder: (context, index) {
                return forumThreads[index];
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );
    } else {
      return FutureBuilder(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<ForumDisplay> snapshot) {
          if (snapshot.hasData) {
            final forumDisplay = snapshot.data!;
            final forumThreads = forumDisplay.threads!
                .map(
                    (forumThread) => _ForumThreadItem(forumThread: forumThread))
                .toList();

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(start: 8.0, end: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _digests,
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return forumThreads[index];
                  }, childCount: forumThreads.length),
                )
              ],
            );
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );
    }
  }
}

class _ForumThreadItem extends StatelessWidget {
  final ForumDisplayThread forumThread;

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
    } else if (forumThread.displayOrder == 3) {
      return ClipRect(
          child: Banner(
              location: BannerLocation.topStart,
              message: '置顶',
              color: Color(0xFFFFD54F),
              child: threadWidget));
    }
    return threadWidget;
  }
}
