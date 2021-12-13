import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:keylol_flutter/common/constants.dart';
import 'package:keylol_flutter/common/keylol_client.dart';
import 'package:keylol_flutter/models/space.dart';
import 'package:keylol_flutter/pages/avatar.dart';

class ProfilePage extends StatefulWidget {
  final String uid;

  const ProfilePage({Key? key, required this.uid}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Space> _future;

  @override
  void initState() {
    super.initState();

    _onRefresh();
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
          body: FutureBuilder(
            future: _future,
            builder: (context, AsyncSnapshot<Space> snapshot) {
              late Widget body;
              if (snapshot.hasData) {
                return _buildBody(snapshot.data!);
              } else {
                body = Center(
                  child: CircularProgressIndicator(),
                );
              }

              return body;
            },
          ),
        ));
  }

  Widget _buildBody(Space space) {
    return Container(
      padding: EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Avatar(
                uid: space.uid,
                avatarUrl: avatarUrlLarge + space.uid,
                size: Size(64.0, 64.0),
                clip: false,
              ),
              Padding(
                padding: EdgeInsets.only(left: 16.0, right: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      space.username,
                      style: TextStyle(fontWeight: FontWeight.bold),
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
          if (space.sigHtml != null) Html(data: space.sigHtml) else Container(),
          SizedBox(height: 32.0),
          Row(
            children: [
              _Label(label: '好友数', value: '${space.friends}'),
              SizedBox(width: 8.0),
              _Label(label: '回复数', value: '${space.posts}'),
              SizedBox(width: 8.0),
              _Label(label: '主题数', value: '${space.threads}'),
              Expanded(child: Container()),
              ElevatedButton(onPressed: () {}, child: Text('关注')),
              SizedBox(width: 8.0),
              ElevatedButton(onPressed: () {}, child: Icon(Icons.chat))
            ],
          )
        ],
      ),
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
