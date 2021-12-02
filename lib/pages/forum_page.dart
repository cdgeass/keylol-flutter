import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/keylol_client.dart';
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

    _future = KeylolClient().fetchForum(widget.fid, 1, 'typeid', {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<ForumDisplay> snapshot) {
        if (snapshot.hasData) {
          final forumDisplay = snapshot.data!;
          final forum = forumDisplay.forum!;
          var threadTypes = forumDisplay.threadTypes ?? [];
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
  String? _filter;
  Map<String, String>? _param;
  bool _hasMore = true;
  List<ForumDisplayThread> _threads = [];

  final ScrollController _scrollController = ScrollController();

  final _selectedStyle = ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
      foregroundColor: MaterialStateProperty.all<Color>(Colors.white));
  final _unselectedStyle = ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
      foregroundColor: MaterialStateProperty.all<Color>(Colors.black));
  String? _selectedButton;

  @override
  void initState() {
    super.initState();

    if (_filter == null) {
      _filter = 'typeid';
    }
    if (_param == null) {
      _param = {'typeid': widget.typeId.toString()};
    }

    _onRefresh();

    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final pixels = _scrollController.position.pixels;

      if (maxScroll == pixels) {
        _loadMore();
      }
    });
  }

  Future<void> _onRefresh() async {
    final threads = await _fetchThreads();
    setState(() {
      _page = 1;
      _threads = threads;
      if (threads.length >= 20) {
        _hasMore = true;
      } else {
        _hasMore = false;
      }
    });
  }

  void _loadMore() async {
    _page++;
    final threads = await _fetchThreads();
    setState(() {
      _threads.addAll(threads);
      if (threads.length >= 20) {
        _hasMore = true;
      } else {
        _hasMore = false;
      }
    });
  }

  Future<List<ForumDisplayThread>> _fetchThreads() async {
    final forumDisplay = await KeylolClient()
        .fetchForum(widget.fid, _page, _filter!, _param!);
    return forumDisplay.threads ?? [];
  }

  List<Widget> _filterButtons() {
    return [
      ElevatedButton(
        child: Text('默认'),
        style: _selectedButton == null || _selectedButton == '默认'
            ? _selectedStyle
            : _unselectedStyle,
        onPressed: () {
          setState(() {
            _selectedButton = '默认';
            _filter = 'typeid';
            _param = {'typeid': widget.typeId.toString()};
            _onRefresh();
          });
        },
      ),
      ElevatedButton(
        child: Text('最新'),
        style: _selectedButton == '最新' ? _selectedStyle : _unselectedStyle,
        onPressed: () {
          setState(() {
            _selectedButton = '最新';
            _filter = 'dateline';
            _param = {'orderby': 'dateline'};
            _page = 1;
            _onRefresh();
          });
        },
      ),
      ElevatedButton(
        child: Text('热门'),
        style: _selectedButton == '热门' ? _selectedStyle : _unselectedStyle,
        onPressed: () {
          setState(() {
            _selectedButton = '热门';
            _filter = 'heat';
            _param = {'orderby': 'heats'};
            _page = 1;
            _onRefresh();
          });
        },
      ),
      ElevatedButton(
        child: Text('热帖'),
        style: _selectedButton == '热帖' ? _selectedStyle : _unselectedStyle,
        onPressed: () {
          setState(() {
            _selectedButton = '热帖';
            _filter = 'hot';
            _param = {};
            _page = 1;
            _onRefresh();
          });
        },
      ),
      ElevatedButton(
        child: Text('精华'),
        style: _selectedButton == '精华' ? _selectedStyle : _unselectedStyle,
        onPressed: () {
          setState(() {
            _selectedButton = '精华';
            _filter = 'digest';
            _param = {'digest': '1'};
            _page = 1;
            _onRefresh();
          });
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (widget.typeId != null) {
      child = ListView.builder(
          controller: _scrollController,
          itemCount: _threads.length + 1,
          itemBuilder: (context, index) {
            if (index == _threads.length) {
              return Center(
                  child: Opacity(
                opacity: _hasMore ? 1.0 : 0.0,
                child: CircularProgressIndicator(),
              ));
            } else {
              return _ForumThreadItem(forumThread: _threads[index]);
            }
          });
    } else {
      child = CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsetsDirectional.only(start: 8.0, end: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _filterButtons(),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index == _threads.length) {
                return Center(
                    child: Opacity(
                  opacity: _hasMore ? 1.0 : 0.0,
                  child: CircularProgressIndicator(),
                ));
              } else {
                return _ForumThreadItem(forumThread: _threads[index]);
              }
            }, childCount: _threads.length + 1),
          )
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: child,
    );
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
                Text(forumThread.dateline!.replaceFirst('&nbsp;', ' '))
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
