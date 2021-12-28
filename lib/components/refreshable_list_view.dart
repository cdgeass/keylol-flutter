import 'package:flutter/material.dart';

typedef ItemWidgetBuilder<T> = Widget Function(T t);

typedef LoadMoreCallback = Future<void> Function();

class RefreshableListView<T> extends StatefulWidget {
  final RefreshCallback onRefresh;
  final LoadMoreCallback loadMore;
  final int total;
  final List<T> list;
  final ItemWidgetBuilder itemBuilder;
  final ScrollController? controller;

  const RefreshableListView(
      {Key? key,
      required this.onRefresh,
      required this.loadMore,
      this.total = 0,
      required this.list,
      required this.itemBuilder,
      this.controller})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _RefreshableListViewState();
}

class _RefreshableListViewState extends State<RefreshableListView> {
  String? error;
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? ScrollController();

    _controller.addListener(() {
      final maxScroll = _controller.position.maxScrollExtent;
      final pixels = _controller.position.pixels;
      if (maxScroll == pixels) {
        setState(() {
          _loadMore();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView.builder(
          controller: _controller,
          itemCount: widget.list.length + 1,
          itemBuilder: (context, index) {
            if (index == widget.list.length) {
              return Center(child: _loadingWidget());
            }
            return widget.itemBuilder.call(widget.list[index]);
          },
        ));
  }

  Future<void> _onRefresh() async {
    try {
      await widget.onRefresh.call();
      error = null;
    } catch (e) {
      error = e.toString();
    }
  }

  void _loadMore() async {
    try {
      await widget.loadMore.call();
      setState(() {
        error = null;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  Widget _loadingWidget() {
    if (error != null) {
      return Center(child: Text(error!));
    }

    return Opacity(
      opacity: widget.total >= widget.list.length ? 0.0 : 1.0,
      child: CircularProgressIndicator(),
    );
  }
}
