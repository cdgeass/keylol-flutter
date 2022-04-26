import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:keylol_flutter/app/space/bloc/space_bloc.dart';
import 'package:keylol_flutter/app/space/widgets/widgets.dart';
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

class _SpacePageViewState extends State<_SpacePageView>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    _controller = TabController(length: 3, vsync: this);

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpaceBloc, SpaceState>(
      builder: (context, state) {
        late Widget body;
        if (state.status == SpaceStatus.initial || state.space == null) {
          body = Center(
            child: CircularProgressIndicator(),
          );
        } else {
          body = Column(
            children: [
              _buildProfileCard(state.space!),
              Container(
                  color: Theme.of(context).primaryColor,
                  padding: EdgeInsets.only(left: 32.0, right: 32.0),
                  child: TabBar(
                    controller: _controller,
                    tabs: [
                      Tab(text: '勋章'),
                      Tab(text: '活跃概况'),
                      Tab(text: '统计信息')
                    ],
                  )),
              _buildTabBarView(state.space!)
            ],
          );
        }
        return Scaffold(
          appBar: AppBar(),
          body: RefreshIndicator(
            onRefresh: () async {
              context.read<SpaceBloc>().add(SpaceReloaded());
            },
            child: body,
          ),
        );
      },
    );
  }

  Widget _buildProfileCard(Space space) {
    return Material(
        child: Container(
      padding: EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Avatar(
                uid: space.uid,
                size: AvatarSize.large,
                width: 42.0,
                clip: false,
              ),
              Padding(
                padding: EdgeInsets.only(left: 16.0, right: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      space.username,
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text('ID: ${space.uid}')
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 16.0),
          Text('个人签名'),
          if (space.sigHtml != null)
            ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 125.0),
                child: SingleChildScrollView(child: Html(data: space.sigHtml)))
          else
            Container(),
          SizedBox(height: 24.0),
          Row(
            children: [
              InkWell(
                child: Label(label: '好友数', value: '${space.friends}'),
                onTap: () {
                  Navigator.of(context)
                      .pushNamed('/space/friend', arguments: space.uid);
                },
              ),
              SizedBox(width: 8.0),
              InkWell(
                  child: Label(label: '主题数', value: '${space.threads}'),
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed('/space/thread', arguments: space.uid);
                  }),
              SizedBox(width: 8.0),
              InkWell(
                  child: Label(label: '回复数', value: '${space.posts}'),
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed('/space/reply', arguments: space.uid);
                  }),
              Expanded(child: Container()),
              // ElevatedButton(onPressed: () {}, child: Text('关注')),
              // SizedBox(width: 8.0),
              // ElevatedButton(onPressed: () {}, child: Icon(Icons.chat))
            ],
          )
        ],
      ),
    ));
  }

  Widget _buildTabBarView(Space space) {
    final children = [
      _buildMedals(space.medals),
      _buildActivity(space),
      _buildStatistics(space)
    ];
    return Container(
        height: 400.0,
        padding: EdgeInsets.all(32.0),
        child: TabBarView(controller: _controller, children: children));
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
        });
  }

  // 活跃概况
  Widget _buildActivity(Space space) {
    return ListView(
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
}
