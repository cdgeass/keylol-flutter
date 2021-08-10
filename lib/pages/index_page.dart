import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/global.dart';
import 'package:keylol_flutter/models/index.dart';
import 'package:keylol_flutter/pages/thread_author.dart';
import 'package:keylol_flutter/pages/user_account_drawer.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  late Future<Index> _indexFuture;

  @override
  void initState() {
    super.initState();

    _indexFuture = Global.keylolClient.fetchIndex();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        notificationPredicate: (notification) {
          if (notification is OverscrollNotification || Platform.isIOS) {
            return notification.depth == 2;
          }
          return notification.depth == 0;
        },
        onRefresh: () {
          setState(() {
            _indexFuture = Global.keylolClient.fetchIndex();
          });
          return Future.value();
        },
        child: FutureBuilder(
          future: _indexFuture,
          builder: (BuildContext context, AsyncSnapshot<Index> snapshot) {
            if (snapshot.hasData) {
              var index = snapshot.data!;
              // 轮播图
              final slideView = CarouselSlider(
                options: CarouselOptions(
                  height: 300.0,
                  enableInfiniteScroll: true,
                  viewportFraction: 1.0,
                  autoPlay: true,
                ),
                items: index.slideViewItems
                    ?.map((slideViewItem) =>
                        _SlideViewItem(slideViewItem: slideViewItem))
                    .toList(),
              );

              return DefaultTabController(
                  length: index.tabThreadsMap!.keys.length,
                  child: Scaffold(
                      drawer: UserAccountDrawer(),
                      backgroundColor: Color(0xFFEEEEEE),
                      body: NestedScrollView(
                        headerSliverBuilder: (context, innerBoxIsScrolled) {
                          return [
                            SliverAppBar(
                              expandedHeight: 275.0,
                              flexibleSpace: slideView,
                            ),
                            SliverPersistentHeader(
                                delegate: _SliverTabBarDelegate(TabBar(
                                    indicatorColor: Colors.blueAccent,
                                    labelColor: Colors.blueAccent,
                                    unselectedLabelColor: Colors.black,
                                    isScrollable: true,
                                    tabs: index.tabThreadsMap!.keys
                                        .map((key) => Tab(text: key.name))
                                        .toList())))
                          ];
                        },
                        body: TabBarView(
                          children: index.tabThreadsMap!.keys.map((key) {
                            final threads = index.tabThreadsMap![key]!;
                            return ListView.builder(
                              padding: EdgeInsets.zero,
                              addAutomaticKeepAlives: true,
                              addRepaintBoundaries: true,
                              itemCount: threads.length,
                              itemBuilder: (context, index) {
                                return _ThreadItem(thread: threads[index]);
                              },
                            );
                          }).toList(),
                        ),
                      )));
            }

            return Scaffold(
                appBar: AppBar(),
                drawer: UserAccountDrawer(),
                body: Center(
                  child: CircularProgressIndicator(),
                ));
          },
        ));
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
      child: Container(
        child: FadeInImage(
          image: CachedNetworkImageProvider(slideViewItem.img),
          placeholder: AssetImage("images/slide_view_placeholder.jpg"),
          fit: BoxFit.cover,
        ),
      ),
    );
    // 页脚
    final footer = Material(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                  title: Text(thread.title),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ThreadAuthor(
                              uid: thread.memberUid,
                              username: thread.memberUsername,
                              size: Size(24.0, 24.0)),
                          Text(thread.dateLine)
                        ]),
                  )),
              Divider(
                thickness: 1.0,
                height: 1.0,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
