import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:keylol_flutter/app/home/avatar_action.dart';
import 'package:keylol_flutter/app/home/bloc/guide/guide_bloc.dart';
import 'package:keylol_flutter/components/authentication_bloc_provider.dart';
import 'package:keylol_flutter/components/avatar.dart';
import 'package:keylol_flutter/components/list_divider.dart';
import 'package:skeletons/skeletons.dart';

class GuideView extends StatefulWidget {
  final GlobalKey<ScaffoldState> homeKey;

  const GuideView({Key? key, required this.homeKey}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GuideViewState();
}

class _GuideViewState extends State<GuideView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final blocs = [
      GuideBloc(
        client: context.read<KeylolApiClient>(),
        type: 'hot',
      )..add(GuideReloaded()),
      GuideBloc(
        client: context.read<KeylolApiClient>(),
        type: 'digest',
      )..add(GuideReloaded()),
      GuideBloc(
        client: context.read<KeylolApiClient>(),
        type: 'newthread',
      )..add(GuideReloaded()),
      GuideBloc(
        client: context.read<KeylolApiClient>(),
        type: 'new',
      )..add(GuideReloaded()),
      GuideBloc(
        client: context.read<KeylolApiClient>(),
        type: 'sofa',
      )..add(GuideReloaded()),
    ];

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text('导读'),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              widget.homeKey.currentState?.openDrawer();
            },
          ),
          actions: [
            Container(
              padding: EdgeInsets.all(9.0),
              child: AvatarAction(),
              width: 48.0,
              height: 48.0,
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: '最新热门'),
              Tab(text: '最新精华'),
              Tab(text: '最新发表'),
              Tab(text: '最新回复'),
              Tab(text: '抢沙发'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AuthenticationBlocProvider(
              create: (_) => blocs[0],
              event: GuideReloaded(),
              child: _GuideList(),
            ),
            AuthenticationBlocProvider(
              create: (_) => blocs[1],
              event: GuideReloaded(),
              child: _GuideList(),
            ),
            AuthenticationBlocProvider(
              create: (_) => blocs[2],
              event: GuideReloaded(),
              child: _GuideList(),
            ),
            AuthenticationBlocProvider(
              create: (_) => blocs[3],
              event: GuideReloaded(),
              child: _GuideList(),
            ),
            AuthenticationBlocProvider(
              create: (_) => blocs[4],
              event: GuideReloaded(),
              child: _GuideList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GuideListState();
}

class _GuideListState extends State<_GuideList>
    with AutomaticKeepAliveClientMixin {
  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController()
      ..addListener(() {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final pixels = _scrollController.position.pixels;

        if (maxScroll == pixels) {
          context.read<GuideBloc>().add(GuideLoaded());
        }
      });

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  ListView _buildGuideListSkeleton(BuildContext context) {
    return ListView.separated(
      itemCount: 20,
      itemBuilder: (context, index) {
        return SkeletonItem(
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
      },
      separatorBuilder: (context, index) {
        return Divider(
          color: Theme.of(context).colorScheme.surfaceVariant,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: () async {
        context.read<GuideBloc>().add(GuideReloaded());
      },
      child: BlocBuilder<GuideBloc, GuideState>(
        builder: (context, state) {
          if (state.threads == null || state.status == GuideStatus.initial) {
            return _buildGuideListSkeleton(context);
          }

          final threads = state.threads ?? const [];
          return ListView.separated(
            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
            controller: _scrollController,
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: threads.length + 1,
            itemBuilder: (context, index) {
              if (index == threads.length) {
                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Opacity(
                    opacity: state.hasReachedMax ? 0.0 : 1.0,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }

              final thread = threads[index];
              return ListTile(
                leading: Avatar(
                  key: Key('Avatar ${thread.authorId}'),
                  uid: thread.authorId,
                  username: thread.author,
                  width: 40.0,
                  height: 40.0,
                ),
                title: Text(
                  thread.subject,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                subtitle: Text(
                  '${thread.author} • ${thread.dateline}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/thread',
                    arguments: {'tid': thread.tid},
                  );
                },
              );
            },
            separatorBuilder: (context, index) {
              return ListDivider(
                isLast: index == threads.length - 1,
              );
            },
          );
        },
      ),
    );
  }
}
