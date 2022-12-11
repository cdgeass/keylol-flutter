import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:keylol_flutter/app/home/avatar_action.dart';
import 'package:keylol_flutter/app/home/bloc/index/index_bloc.dart';
import 'package:keylol_flutter/components/authentication_bloc_provider.dart';
import 'package:keylol_flutter/components/list_divider.dart';
import 'package:keylol_flutter/components/thread_item.dart';
import 'package:skeletons/skeletons.dart';

class IndexView extends StatefulWidget {
  final GlobalKey<ScaffoldState> homeKey;

  const IndexView({Key? key, required this.homeKey}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _IndexViewState();
}

class _IndexViewState extends State<IndexView>
    with AutomaticKeepAliveClientMixin {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    _currentIndex = 0;
    _pageController = PageController();

    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  ListView _buildIndexSkeleton(double sliderHeight) {
    final listTiles = [];
    for (var i = 0; i < 10; i++) {
      final listTile = SkeletonItem(
        child: ListTile(
          leading: SkeletonAvatar(
            style: SkeletonAvatarStyle(
              shape: BoxShape.circle,
              width: 40.0,
              height: 40.0,
            ),
          ),
          title: SkeletonParagraph(
            style: SkeletonParagraphStyle(
              padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
              lines: 1,
              lineStyle: SkeletonLineStyle(
                height: 26.0,
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
          subtitle: SkeletonParagraph(
            style: SkeletonParagraphStyle(
              padding: EdgeInsets.only(top: 4.0, bottom: 8.0),
              lines: 1,
              lineStyle: SkeletonLineStyle(
                height: 20.0,
                width: 120.0,
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
        ),
      );
      listTiles.add(listTile);
      listTiles.add(
        Padding(
          padding: EdgeInsets.only(left: 16.0, right: 16.0),
          child: Divider(
            color: Theme.of(context).colorScheme.surfaceVariant,
          ),
        ),
      );
    }

    return ListView(
      physics: NeverScrollableScrollPhysics(),
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
          child: SkeletonItem(
            child: SkeletonAvatar(
              style: SkeletonAvatarStyle(
                width: double.infinity,
                height: sliderHeight,
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
        ),
        Padding(
            padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
            child: SkeletonItem(
              child: SkeletonParagraph(
                style: SkeletonParagraphStyle(
                  padding: EdgeInsets.zero,
                  lines: 1,
                  lineStyle: SkeletonLineStyle(
                    width: 96.0,
                    height: 32.0,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            )),
        SizedBox(
          height: 8.0,
        ),
        for (final listTile in listTiles) listTile,
      ],
    );
  }

  Widget? _buildThreadItems(BuildContext context, List<Thread>? threads) {
    List<Widget> threadItems = [];
    threads?.asMap().forEach((index, thread) {
      final threadItem = ThreadItem(thread: thread);
      threadItems.add(threadItem);
    });
    if (threadItems.isEmpty) {
      return null;
    }
    return ListView.separated(
      padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
      physics: NeverScrollableScrollPhysics(),
      itemCount: threadItems.length,
      itemBuilder: (context, index) {
        return threadItems[index];
      },
      separatorBuilder: (context, index) {
        return ListDivider(
          isLast: index == threadItems.length - 1,
          padding: EdgeInsets.only(left: 16.0, right: 16.0),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AuthenticationBlocProvider(
      create: (_) => IndexBloc(client: context.read<KeylolApiClient>())
        ..add(IndexReloaded()),
      event: IndexReloaded(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text('聚焦'),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              widget.homeKey.currentState?.openDrawer();
            },
          ),
          actions: [
            Container(
              margin: EdgeInsets.fromLTRB(0.0, 4.0, 7.0, 4.0),
              padding: EdgeInsets.all(9.0),
              child: AvatarAction(),
              width: 48.0,
              height: 48.0,
            ),
          ],
        ),
        body: BlocBuilder<IndexBloc, IndexState>(
          builder: (context, state) {
            final screenWidth = MediaQuery.of(context).size.width;
            final sliderHeight = ((screenWidth - 32.0) / 16 * 9).abs();

            return RefreshIndicator(
              notificationPredicate: (notification) {
                return true;
              },
              onRefresh: () async {
                context.read<IndexBloc>().add(IndexReloaded());
              },
              child: Builder(
                builder: (context) {
                  if (state.index == null ||
                      state.status == IndexStatus.initial) {
                    return _buildIndexSkeleton(sliderHeight);
                  }

                  final index = state.index!;

                  final threadMap = index.tabThreadsMap;
                  late List<Thread> newThreads;
                  List<Thread>? newReplies;
                  threadMap.forEach((tab, threads) {
                    if (tab.name == '最新主题') {
                      newThreads = threads;
                    } else if (tab.name == '最新回复') {
                      newReplies = threads;
                    }
                  });

                  final newThreadItems = _buildThreadItems(context, newThreads);
                  final newReplyItems = _buildThreadItems(context, newReplies);

                  final firstNewThreadsTab = InkWell(
                    onTap: () {
                      if (newReplyItems != null) {
                        _pageController.animateToPage(
                          0,
                          duration: Duration(microseconds: 500),
                          curve: Curves.linear,
                        );
                      }
                    },
                    child: Text(
                      '最新主题',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  );
                  final secondNewThreadsTab = InkWell(
                    onTap: () {
                      if (newReplyItems != null) {
                        _pageController.animateToPage(
                          0,
                          duration: Duration(microseconds: 500),
                          curve: Curves.linear,
                        );
                      }
                    },
                    child: Text(
                      '最新主题',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  );

                  final firstNewRepliesTab = InkWell(
                    onTap: () {
                      _pageController.animateToPage(
                        1,
                        duration: Duration(microseconds: 500),
                        curve: Curves.linear,
                      );
                    },
                    child: Text(
                      '最新回复',
                      style: _currentIndex == 1
                          ? Theme.of(context).textTheme.headlineSmall
                          : Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                    ),
                  );
                  final secondNewRepliesTab = InkWell(
                    onTap: () {
                      _pageController.animateToPage(
                        1,
                        duration: Duration(microseconds: 500),
                        curve: Curves.linear,
                      );
                    },
                    child: Text(
                      '最新回复',
                      style: _currentIndex == 1
                          ? Theme.of(context).textTheme.headlineSmall
                          : Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                    ),
                  );

                  return NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        SliverList(
                          delegate: SliverChildListDelegate([
                            Padding(
                              padding:
                                  EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                              child: Card(
                                elevation: 0,
                                margin: EdgeInsets.zero,
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceVariant,
                                clipBehavior: Clip.antiAlias,
                                child: CarouselSlider(
                                  options: CarouselOptions(
                                    height: sliderHeight,
                                    enableInfiniteScroll: true,
                                    viewportFraction: 1.0,
                                    autoPlay: true,
                                  ),
                                  items: index.slideViewItems
                                      .map((slideViewItem) => _SlideViewItem(
                                          slideViewItem: slideViewItem))
                                      .toList(),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  AnimatedCrossFade(
                                    firstChild: firstNewThreadsTab,
                                    secondChild: secondNewThreadsTab,
                                    crossFadeState: _currentIndex == 0
                                        ? CrossFadeState.showFirst
                                        : CrossFadeState.showSecond,
                                    duration: const Duration(microseconds: 200),
                                  ),
                                  SizedBox(
                                    width: 8.0,
                                  ),
                                  if (newReplies != null)
                                    AnimatedCrossFade(
                                      firstChild: firstNewRepliesTab,
                                      secondChild: secondNewRepliesTab,
                                      crossFadeState: _currentIndex == 1
                                          ? CrossFadeState.showFirst
                                          : CrossFadeState.showSecond,
                                      duration:
                                          const Duration(microseconds: 200),
                                    )
                                ],
                              ),
                            ),
                          ]),
                        ),
                      ];
                    },
                    body: newReplyItems == null
                        ? newThreadItems!
                        : PageView(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentIndex = index;
                              });
                            },
                            children: [
                              newThreadItems!,
                              newReplyItems,
                            ],
                          ),
                  );
                },
              ),
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
      child: Container(
        child: FadeInImage(
          image: CachedNetworkImageProvider(slideViewItem.img),
          placeholder: AssetImage("images/slide_view_placeholder.jpg"),
          fit: BoxFit.cover,
        ),
      ),
    );

    // 页脚
    final footer = Container(
      color: Colors.transparent,
      child: GridTileBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        title: Text(
          slideViewItem.title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
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
              .pushNamed('/thread', arguments: {'tid': slideViewItem.tid});
        },
        child: GridTile(
          footer: footer,
          child: img,
        ),
      ),
    );
  }
}
