import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/authentication/authentication.dart';
import 'package:keylol_flutter/app/forum/bloc/forum_bloc.dart';
import 'package:keylol_flutter/app/forum/view/forum_page.dart';
import 'package:keylol_flutter/common/keylol_client.dart';

class ForumIndexPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: DrawerWidget(),
      body: BlocProvider(
        create: (_) => ForumIndexBloc(client: KeylolClient().dio)
          ..add(ForumIndexFetched()),
        child: BlocBuilder<ForumIndexBloc, ForumIndexState>(
          builder: (context, state) {
            switch (state.status) {
              case ForumIndexStatus.failure:
                return Center(child: Text('出错误啦!!!'));
              case ForumIndexStatus.success:
                final cats = state.cats;
                final selected = state.selected;
                return Row(
                  children: [
                    NavigationRail(
                      destinations: [
                        for (final cat in cats)
                          NavigationRailDestination(
                            icon: SizedBox.shrink(),
                            label: Text(cat.name),
                          )
                      ],
                      labelType: NavigationRailLabelType.all,
                      selectedIndex: selected,
                      onDestinationSelected: (index) {
                        context
                            .read<ForumIndexBloc>()
                            .add(ForumIndexSelected(index));
                      },
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 0.0),
                        child: MediaQuery.removePadding(
                          removeTop: true,
                          context: context,
                          child: ListView(
                            children: [
                              for (final forum in cats[selected].forums)
                                ListTile(
                                  leading: forum.icon == null
                                      ? ClipOval(
                                          child: Image.asset(
                                            'images/forum.gif',
                                            width: 40.0,
                                          ),
                                        )
                                      : CachedNetworkImage(
                                          imageUrl: forum.icon!,
                                          width: 40.0,
                                        ),
                                  title: Text(forum.name),
                                  subtitle: forum.description == null
                                      ? null
                                      : Text(forum.description!),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ForumPage(fid: forum.fid),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                );
              default:
                return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
