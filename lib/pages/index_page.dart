import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/global.dart';
import 'package:keylol_flutter/model/index.dart';
import 'package:keylol_flutter/pages/user_account_drawer.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage>
    with SingleTickerProviderStateMixin {
  late Future<Index> _indexFuture;

  @override
  void initState() {
    super.initState();

    _indexFuture = Global.keylolClient.fetchIndex();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: UserAccountDrawer(),
      backgroundColor: Color(0xFFEEEEEE),
      body: SafeArea(
        child: FutureBuilder(
          future: _indexFuture,
          builder: (BuildContext context, AsyncSnapshot<Index> snapshot) {
            if (snapshot.hasData) {
              var index = snapshot.data!;

              // 轮播图
              final slideView = CarouselSlider(
                options: CarouselOptions(
                  height: 276.0,
                  enableInfiniteScroll: true,
                  autoPlay: true,
                ),
                items: index.slideViewItems
                    ?.map((slideViewItem) =>
                        _SlideViewItem(slideViewItem: slideViewItem))
                    .toList(),
              );

              //  tab 页
              final threads = index.tabThreadsMap!.keys.map((header) {
                final threads = index.tabThreadsMap![header]!;
                return _ThreadListItem(header: header, threads: threads);
              }).toList();

              return ListView(
                children: [
                  slideView,
                  for (final thread in threads) thread,
                ],
              );
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}

class _SlideViewItem extends StatelessWidget {
  final IndexSlideViewItem slideViewItem;

  const _SlideViewItem({Key? key, required this.slideViewItem})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 图片
    final img = Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 200.0,
        child: FadeInImage(
          image: CachedNetworkImageProvider(slideViewItem.img),
          placeholder: AssetImage("images/slide_view_placeholder.jpg"),
          fit: BoxFit.cover,
        ),
      ),
    );
    // 页脚
    final footer = Material(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10.0))),
      clipBehavior: Clip.antiAlias,
      color: Colors.transparent,
      child: GridTileBar(
        backgroundColor: Colors.black45,
        title: Text(
          slideViewItem.title,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          // 跳转到帖子页面
          Navigator.of(context)
              .pushNamed("/thread", arguments: slideViewItem.tid);
        },
        child: GridTile(
          footer: footer,
          child: img,
        ),
      ),
    );
  }
}

typedef _ThreadListHeaderTapCallback = Function(bool shouldOpenList);

class _ThreadListItem extends StatefulWidget {
  final IndexTabTitleItem header;
  final List<IndexTabThreadItem> threads;
  final _ThreadListHeaderTapCallback? onTap;

  _ThreadListItem(
      {Key? key, required this.header, required this.threads, this.onTap})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ThreadListItemState();
}

class _ThreadListItemState extends State<_ThreadListItem>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _easeTween = CurveTween(curve: Curves.easeIn);
  static const _expandDuration = Duration(microseconds: 200);

  late AnimationController _controller;
  late Animation<double> _childrenHeightFactor;
  late Animation<double> _headerChevronOpacity;
  late Animation<double> _headerHeight;
  late Animation<EdgeInsetsGeometry> _headerMargin;
  late Animation<EdgeInsetsGeometry> _childrenPadding;
  late Animation<BorderRadius> _headerBorderRadius;

  @override
  void initState() {
    super.initState();

    _controller =
        new AnimationController(duration: _expandDuration, vsync: this);
    _controller.addStatusListener((status) {
      setState(() {});
    });

    _childrenHeightFactor = _controller.drive(_easeTween);
    _headerChevronOpacity = _controller.drive(_easeTween);
    _headerHeight = Tween<double>(
      begin: 80.0,
      end: 96.0,
    ).animate(_controller);
    _headerMargin = EdgeInsetsGeometryTween(
            begin: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0),
            end: EdgeInsets.zero)
        .animate(_controller);
    _childrenPadding = EdgeInsetsGeometryTween(
      begin: const EdgeInsets.symmetric(horizontal: 32.0),
      end: EdgeInsets.zero,
    ).animate(_controller);
    _headerBorderRadius = BorderRadiusTween(
      begin: BorderRadius.circular(10.0),
      end: BorderRadius.zero,
    ).animate(_controller);
  }

  bool _shouldOpenList() {
    switch (_controller.status) {
      case AnimationStatus.completed:
      case AnimationStatus.forward:
        return false;
      case AnimationStatus.dismissed:
      case AnimationStatus.reverse:
        return true;
    }
  }

  void _handleTap() {
    if (_shouldOpenList()) {
      _controller.forward();
      if (widget.onTap != null) {
        widget.onTap!(true);
      }
    } else {
      _controller.reverse();
      if (widget.onTap != null) {
        widget.onTap!(false);
      }
    }
  }

  Widget _buildHeaderWithChildren(BuildContext context, Widget? child) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ThreadListHeader(
          margin: _headerMargin.value,
          borderRadius: _headerBorderRadius.value,
          height: _headerHeight.value,
          chevronOpacity: _headerChevronOpacity.value,
          header: widget.header,
          onTap: _handleTap,
        ),
        Padding(
          padding: _childrenPadding.value,
          child: ClipRect(
            child: Align(
              heightFactor: _childrenHeightFactor.value,
              child: child,
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildHeaderWithChildren,
      child: !_shouldOpenList()
          ? _ExpandedThreadList(header: widget.header, threads: widget.threads)
          : null,
    );
  }
}

class _ThreadListHeader extends StatelessWidget {
  final EdgeInsetsGeometry margin;
  final double height;
  final BorderRadiusGeometry borderRadius;
  final IndexTabTitleItem header;
  final double chevronOpacity;
  final GestureTapCallback onTap;

  const _ThreadListHeader(
      {Key? key,
      required this.margin,
      required this.height,
      required this.borderRadius,
      required this.header,
      required this.chevronOpacity,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Material(
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: InkWell(
            onTap: onTap,
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 8.0),
                        child: SizedBox(
                          height: 40,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 8.0),
                        child: Text(
                          header.name,
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      )
                    ],
                  ),
                ),
                Opacity(
                  opacity: chevronOpacity,
                  child: chevronOpacity != 0
                      ? Padding(
                          padding: const EdgeInsetsDirectional.only(
                              start: 8, end: 32),
                          child: Icon(Icons.keyboard_arrow_up),
                        )
                      : Padding(
                          padding: const EdgeInsetsDirectional.only(
                              start: 8, end: 32),
                          child: Icon(Icons.keyboard_arrow_down),
                        ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpandedThreadList extends StatelessWidget {
  final IndexTabTitleItem header;
  final List<IndexTabThreadItem> threads;

  const _ExpandedThreadList(
      {Key? key, required this.header, required this.threads})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final thread in threads) _ThreadItem(thread: thread),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _ThreadItem extends StatelessWidget {
  final IndexTabThreadItem thread;

  const _ThreadItem({Key? key, required this.thread}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: MergeSemantics(
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushNamed("/thread", arguments: thread.tid);
          },
          child: Padding(
            padding:
                EdgeInsetsDirectional.only(start: 32.0, top: 20.0, end: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(thread.title),
                Text(thread.memberUsername),
                const SizedBox(height: 20.0),
                Divider(
                  thickness: 1.0,
                  height: 1.0,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
