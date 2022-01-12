import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/keylol_client.dart';
import 'package:keylol_flutter/components/thread_card.dart';
import 'package:keylol_flutter/components/user_account_drawer.dart';
import 'package:keylol_flutter/models/guide.dart';

class GuidePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GuidPageState();
}

class _GuidPageState extends State<GuidePage> {
  @override
  Widget build(BuildContext context) {
    final tabs = [
      Tab(text: '最新热门'),
      Tab(text: '最新精华'),
      Tab(text: '最新回复'),
      Tab(text: '最新发表'),
      Tab(text: '抢沙发')
    ];

    return DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text('导读'),
            centerTitle: true,
            bottom: TabBar(
              isScrollable: true,
              tabs: tabs,
            ),
          ),
          drawer: UserAccountDrawer(),
          body: TabBarView(
            children: [
              _ThreadList(view: 'hot'),
              _ThreadList(view: 'digest'),
              _ThreadList(view: 'new'),
              _ThreadList(view: 'newthread'),
              _ThreadList(view: 'sofa'),
            ],
          ),
        ));
  }
}

class _ThreadList extends StatefulWidget {
  final String view;

  const _ThreadList({Key? key, required this.view}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ThreadListState();
}

class _ThreadListState extends State<_ThreadList> {
  int _page = 1;
  Guide? _guide;

  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      final maxScroll = _controller.position.maxScrollExtent;
      final pixels = _controller.position.pixels;

      if (maxScroll == pixels) {
        _loadMore();
      }
    });

    _onRefresh();
  }

  Future<void> _onRefresh() async {
    _page = 1;
    _guide = await KeylolClient().fetchGuide(widget.view, page: _page);
    setState(() {});
  }

  void _loadMore() async {
    _page += 1;
    final guide = await KeylolClient().fetchGuide(widget.view, page: _page);
    if (_guide != null) {
      _guide!.totalPage = guide.totalPage;
      _guide!.threadList.addAll(guide.threadList);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () async {
          _onRefresh();
        },
        child: _guide == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                controller: _controller,
                itemCount: _guide!.threadList.length + 1,
                itemBuilder: (context, index) {
                  if (index < _guide!.threadList.length) {
                    return ThreadCard(thread: _guide!.threadList[index]);
                  } else {
                    return Opacity(
                      opacity: _page < _guide!.totalPage ? 1.0 : 0.0,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                }));
  }
}
