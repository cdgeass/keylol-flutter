import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/api/models/thread.dart';
import 'package:keylol_flutter/app/thread/bloc/thread_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

Size boundingTextSize(String text, TextStyle style,
    {int maxLines = 2 ^ 31, double maxWidth = double.infinity}) {
  final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(text: text, style: style),
      maxLines: maxLines)
    ..layout(maxWidth: maxWidth);
  return textPainter.size;
}

class ThreadAppBar extends SliverPersistentHeaderDelegate {
  final Thread thread;
  final TextStyle textStyle;
  final double width;
  final double appBarHeight;

  final String? favId;

  final double _subjectHeight;

  final double topPadding;

  ThreadAppBar({
    required this.thread,
    required this.textStyle,
    required this.width,
    required this.appBarHeight,
    this.favId,
    double? topPadding,
  })  : _subjectHeight =
            boundingTextSize(thread.subject, textStyle, maxWidth: width - 32.0)
                .height,
        this.topPadding = topPadding ?? 0.0;

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    double toolbarOpacity = maxExtent == minExtent
        ? 0.0
        : ((maxExtent - minExtent - shrinkOffset) / (maxExtent - minExtent))
            .clamp(0.0, 1.0);

    final title = toolbarOpacity == 0.0 ? Text(thread.subject) : null;

    final appBarTheme = Theme.of(context).appBarTheme;
    final titleTextStyle = appBarTheme.titleTextStyle ??
        Theme.of(context).textTheme.headlineMedium;

    return AppBar(
      title: title,
      flexibleSpace: Opacity(
        opacity: toolbarOpacity,
        child: Stack(
          children: [
            Positioned(
              top: appBarHeight - shrinkOffset,
              child: Container(
                padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                width: width,
                child: AnimatedCrossFade(
                  firstChild: Text(thread.subject, style: titleTextStyle),
                  secondChild: Container(),
                  crossFadeState: toolbarOpacity == 0.0
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(microseconds: 200),
                ),
              ),
            )
          ],
        ),
      ),
      actions: [
        if (favId != null)
          IconButton(
            icon: Icon(Icons.favorite_outlined),
            onPressed: () {
              context.read<ThreadBloc>().add(ThreadUnfavored());
            },
          ),
        if (favId == null)
          IconButton(
            icon: Icon(Icons.favorite_outline),
            onPressed: () {
              _favThread(context);
            },
          ),
        PopupMenuButton(
          icon: Icon(Icons.more_vert_outlined),
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                child: Text('在浏览器中打开'),
                onTap: () {
                  launchUrlString(
                    'https://keylol.com/t${thread.tid}-1-1',
                    mode: LaunchMode.externalApplication,
                  );
                },
              )
            ];
          },
        ),
      ],
    );
  }

  @override
  double get maxExtent => _subjectHeight + appBarHeight;

  @override
  double get minExtent => appBarHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  void _favThread(BuildContext context) {
    final controller = TextEditingController();
    final dialog = AlertDialog(
      title: Text('收藏备注'),
      content: TextField(
        controller: controller,
      ),
      actions: [
        ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('取消')),
        ElevatedButton(
            onPressed: () async {
              context
                  .read<ThreadBloc>()
                  .add(ThreadFavored(description: controller.text));
              Navigator.pop(context);
            },
            child: Text('确认'))
      ],
    );

    showDialog(context: context, builder: (context) => dialog);
  }
}
