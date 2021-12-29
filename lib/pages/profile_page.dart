import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:keylol_flutter/common/keylol_client.dart';
import 'package:keylol_flutter/components/avatar.dart';
import 'package:keylol_flutter/components/throwable_future_builder.dart';
import 'package:keylol_flutter/models/space.dart';

class ProfilePage extends StatefulWidget {
  final String uid;

  const ProfilePage({Key? key, required this.uid}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late Future<Space> _future;
  late final TabController _controller;

  @override
  void initState() {
    super.initState();

    _onRefresh();
    _controller = TabController(length: 3, vsync: this);
  }

  Future<void> _onRefresh() async {
    _future = KeylolClient().fetchProfile(uid: widget.uid, cached: false);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: _onRefresh,
        child: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(),
          body: ThrowableFutureBuilder(
            future: _future,
            builder: (context, Space space) {
              return Column(children: [
                _buildProfileCard(space),
                Container(
                    padding: EdgeInsets.only(left: 32.0, right: 32.0),
                    child: TabBar(
                      controller: _controller,
                      tabs: [
                        Tab(text: '勋章'),
                        Tab(text: '活跃概况'),
                        Tab(text: '统计信息')
                      ],
                    )),
                _buildTabBarView(space)
              ]);
            },
          ),
        ));
  }

  Widget _buildProfileCard(Space space) {
    return Card(
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
              _Label(label: '好友数', value: '${space.friends}'),
              SizedBox(width: 8.0),
              _Label(label: '回复数', value: '${space.posts}'),
              SizedBox(width: 8.0),
              _Label(label: '主题数', value: '${space.threads}'),
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
              CachedNetworkImage(
                  height: 30.0,
                  imageUrl:
                      'https://keylol.com/static/image/common/${medal.image}'),
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

class _Label extends StatelessWidget {
  final String label;
  final String value;

  const _Label({Key? key, required this.label, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label),
        SizedBox(height: 8.0),
        Text(value),
      ],
    );
  }
}
