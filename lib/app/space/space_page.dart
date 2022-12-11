import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:keylol_flutter/api/keylol_api.dart';

import 'package:keylol_flutter/app/space/bloc/space_bloc.dart';
import 'package:keylol_flutter/app/space/label.dart';
import 'package:keylol_flutter/components/avatar.dart';

class SpacePage extends StatelessWidget {
  final String uid;

  const SpacePage({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SpaceBloc(
        client: context.read<KeylolApiClient>(),
        uid: uid,
      )..add(SpaceReloaded()),
      child: _SpacePageView(),
    );
  }
}

class _SpacePageView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SpacePageViewState();
}

class _SpacePageViewState extends State<_SpacePageView> {
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

  // 勋章
  Widget _buildMedals(List<Medal> medals) {
    if (medals.isEmpty) {
      return Container();
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: medals.length,
      itemBuilder: (context, index) {
        final medal = medals[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(medal.name),
            Text(medal.description),
            Row(children: [
              CachedNetworkImage(
                  height: 30.0,
                  imageUrl:
                      'https://keylol.com/static/image/common/${medal.image}'),
              Expanded(child: Container()),
            ]),
            if (index != medals.length - 1)
              SizedBox(
                height: 8.0,
              )
          ],
        );
      },
    );
  }

  // 活跃概况
  Widget _buildActivity(Space space) {
    return ListView(
      shrinkWrap: true,
      children: [
        Row(
          children: [
            Text('用户组'),
            if (space.group.groupTitle != null)
              SizedBox(
                width: 8.0,
              ),
            if (space.group.groupTitle != null)
              Text('${space.group.groupTitle}'),
            if (space.group.icon != null)
              SizedBox(
                width: 8.0,
              ),
            if (space.group.icon != null)
              CachedNetworkImage(imageUrl: space.group.icon!)
          ],
        ),
        SizedBox(height: 8.0),
        Row(
          children: [
            Text('在线时间'),
            SizedBox(width: 8.0),
            Text('${space.olTime}小时')
          ],
        ),
        SizedBox(
          height: 8.0,
        ),
        Row(
          children: [
            Text('注册时间'),
            SizedBox(
              width: 8.0,
            ),
            Text('${space.regDate}')
          ],
        ),
        SizedBox(
          height: 8.0,
        ),
        Row(
          children: [
            Text('最后访问'),
            SizedBox(width: 8.0),
            Text('${space.lastVisit}')
          ],
        ),
        SizedBox(
          height: 8.0,
        ),
        Row(
          children: [
            Text('上次活动'),
            SizedBox(width: 8.0),
            Text('${space.lastActivity}')
          ],
        ),
        SizedBox(
          height: 8.0,
        ),
        Row(
          children: [
            Text('上次发表'),
            SizedBox(width: 8.0),
            Text('${space.lastPost}')
          ],
        ),
      ],
    );
  }

  // 统计信息
  Widget _buildStatistics(Space space) {
    return ListView(
      shrinkWrap: true,
      children: [
        Row(
          children: [
            Text('已用空间'),
            SizedBox(
              width: 8.0,
            ),
            Text('${space.attachSize.trim()}')
          ],
        ),
        SizedBox(
          height: 8.0,
        ),
        Row(
          children: [
            Text('积分'),
            SizedBox(
              width: 8.0,
            ),
            Text('${space.credits}')
          ],
        ),
        SizedBox(
          height: 8.0,
        ),
        Row(
          children: [
            Text('体力'),
            SizedBox(
              width: 8.0,
            ),
            Text('${space.extCredits1}点')
          ],
        ),
        SizedBox(
          height: 8.0,
        ),
        Row(
          children: [
            Text('蒸汽'),
            SizedBox(
              width: 8.0,
            ),
            Text('${space.extCredits3}克')
          ],
        ),
        SizedBox(
          height: 8.0,
        ),
        Row(
          children: [
            Text('动力'),
            SizedBox(
              width: 8.0,
            ),
            Text('${space.extCredits4}点')
          ],
        ),
        SizedBox(
          height: 8.0,
        ),
        Row(
          children: [
            Text('绿意'),
            SizedBox(
              width: 8.0,
            ),
            Text('${space.extCredits6}')
          ],
        ),
        SizedBox(
          height: 8.0,
        ),
        Row(
          children: [
            Text('可用改名次数'),
            SizedBox(
              width: 8.0,
            ),
            Text('${space.extCredits8}')
          ],
        ),
        SizedBox(
          height: 8.0,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpaceBloc, SpaceState>(
      builder: (context, state) {
        if (state.space == null || state.status != SpaceStatus.success) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final space = state.space!;
        return Scaffold(
          appBar: AppBar(),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      ListTile(
                        leading: Avatar(
                          uid: space.uid,
                          username: space.username,
                          width: 56.0,
                          height: 56.0,
                        ),
                        title: Text(space.username),
                        subtitle: Text('ID: ${space.uid}'),
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(width: 16.0),
                          InkWell(
                            child:
                                Label(label: '好友数', value: '${space.friends}'),
                            onTap: () {
                              Navigator.of(context).pushNamed('/space/friend',
                                  arguments: space.uid);
                            },
                          ),
                          VerticalDivider(),
                          InkWell(
                              child: Label(
                                  label: '主题数', value: '${space.threads}'),
                              onTap: () {
                                Navigator.of(context).pushNamed('/space/thread',
                                    arguments: space.uid);
                              }),
                          VerticalDivider(),
                          InkWell(
                              child:
                                  Label(label: '回复数', value: '${space.posts}'),
                              onTap: () {
                                Navigator.of(context).pushNamed('/space/reply',
                                    arguments: space.uid);
                              }),
                          SizedBox(width: 16.0),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      if (space.sigHtml != null && space.sigHtml!.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(
                              left: 16.0, right: 16.0, bottom: 8.0),
                          child: Text('个人签名'),
                        ),
                      if (space.sigHtml != null && space.sigHtml!.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(
                              left: 16.0, right: 16.0, bottom: 16.0),
                          child: Html(
                            data: space.sigHtml,
                            style: {
                              'body': Style(
                                margin: EdgeInsets.zero,
                                padding: EdgeInsets.zero,
                              )
                            },
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.only(left: 16.0, right: 16.0),
                        child: SegmentedButton(
                          showSelectedIcon: false,
                          selected: Set<int>.of([_currentIndex]),
                          onSelectionChanged: (Set<int> set) {
                            setState(() {
                              _currentIndex = set.first;
                            });
                            _pageController.animateToPage(
                              _currentIndex,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.linear,
                            );
                          },
                          segments: [
                            ButtonSegment(value: 0, label: Text('勋章')),
                            ButtonSegment(value: 1, label: Text('活跃概况')),
                            ButtonSegment(value: 2, label: Text('统计信息')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
            body: Padding(
              padding: EdgeInsets.fromLTRB(28.0, 16.0, 28.0, 0.0),
              child: PageView(
                physics: NeverScrollableScrollPhysics(),
                controller: _pageController,
                children: [
                  _buildMedals(space.medals),
                  _buildActivity(space),
                  _buildStatistics(space)
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
