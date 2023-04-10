import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:keylol_flutter/app/home/avatar_action.dart';
import 'package:keylol_flutter/app/home/bloc/notification/notification_bloc.dart';
import 'package:keylol_flutter/components/authentication_bloc_provider.dart';
import 'package:keylol_flutter/components/avatar.dart';
import 'package:keylol_flutter/components/list_divider.dart';
import 'package:skeletons/skeletons.dart';

class NotificationView extends StatefulWidget {
  final GlobalKey<ScaffoldState> homeKey;

  const NotificationView({Key? key, required this.homeKey}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('提醒'),
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
      ),
      body: AuthenticationBlocProvider(
        create: (_) => NotificationBloc(client: context.read<KeylolApiClient>())
          ..add(NotificationReloaded()),
        event: NotificationReloaded(),
        child: _NotificationList(),
      ),
    );
  }
}

class _NotificationList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NotificationListState();
}

class _NotificationListState extends State<_NotificationList> {
  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController()
      ..addListener(() {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final pixels = _scrollController.position.pixels;

        if (maxScroll == pixels) {
          context.read<NotificationBloc>().add(NotificationLoaded());
        }
      });

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  ListView _buildNotificationListSkeleton(BuildContext context) {
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
    return RefreshIndicator(
      onRefresh: () async {
        context.read<NotificationBloc>().add(NotificationReloaded());
      },
      child: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state.notes == null ||
              state.status != NotificationStatus.success) {
            return _buildNotificationListSkeleton(context);
          }

          final notes = state.notes ?? const [];
          return ListView.separated(
            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
            controller: _scrollController,
            itemCount: notes.length + 1,
            itemBuilder: (context, index) {
              if (index == notes.length) {
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

              final note = notes[index];
              final date =
                  DateTime.fromMillisecondsSinceEpoch(note.dateline * 1000);
              return ListTile(
                onTap: () {
                  if (note.noteVar != null) {
                    final noteVar = note.noteVar;
                    Navigator.of(context).pushNamed(
                      '/thread',
                      arguments: {
                        'tid': noteVar?.tid,
                        'pid': noteVar?.pid,
                      },
                    );
                  }
                },
                leading: Avatar(
                  key: Key('Avatar ${note.authorId}'),
                  uid: note.authorId,
                  username: note.author,
                  width: 40.0,
                  height: 40.0,
                ),
                title: Html(
                  shrinkWrap: true,
                  data: note.note,
                  customRender: {
                    'a': (context, child) {
                      return TextSpan(text: context.tree.element!.innerHtml);
                    },
                    'blockquote': (context, child) {
                      return TextSpan(text: context.tree.element!.innerHtml);
                    }
                  },
                  style: {
                    "body": Style(
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.zero,
                      fontSize: FontSize(
                        Theme.of(context).textTheme.bodyLarge?.fontSize,
                      ),
                    ),
                  },
                ),
                subtitle: Text(formatDate(date, [yyyy, '-', mm, '-', dd])),
              );
            },
            separatorBuilder: (context, index) {
              return ListDivider(
                isLast: index == notes.length - 1,
              );
            },
          );
        },
      ),
    );
  }
}
