import 'package:flutter/material.dart';

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
      Tab(text: '最新发表'),
      Tab(text: '最新回复'),
      Tab(text: '抢沙发')
    ];

    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          tabs: tabs,
        ),
      ),
      body: TabBarView(
        children: [
          _ThreadList(module: 'newhot'),
        ],
      ),
    );
  }
}

class _ThreadList extends StatefulWidget {
  final String module;

  const _ThreadList({Key? key, required this.module}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ThreadListState();
}

class _ThreadListState extends State<_ThreadList> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}