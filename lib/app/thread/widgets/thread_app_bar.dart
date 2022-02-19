import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/api/models/thread.dart';
import 'package:keylol_flutter/app/thread/bloc/thread_bloc.dart';

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

  final String? favId;

  final double _subjectHeight;

  final double? topPadding;

  ThreadAppBar({
    required this.thread,
    required this.textStyle,
    required width,
    this.favId,
    this.topPadding,
  })  : width = width - 32.0,
        _subjectHeight =
            boundingTextSize(thread.subject, textStyle, maxWidth: width - 32.0)
                .height;

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    double toolbarOpacity =
        ((maxExtent - minExtent - shrinkOffset).round() / minExtent)
            .clamp(0.0, 1.0);

    final title = toolbarOpacity == 0.0 ? Text(thread.subject) : null;

    return AppBar(
      title: title,
      centerTitle: true,
      flexibleSpace: Opacity(
        opacity: toolbarOpacity,
        child: Stack(
          children: [
            Positioned(
              top: kToolbarHeight + (topPadding ?? 0.0) - shrinkOffset,
              child: Container(
                padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                width: width,
                child: Text(thread.subject, style: textStyle),
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
      ],
    );
  }

  @override
  double get maxExtent =>
      kToolbarHeight + _subjectHeight + 8.0 + (topPadding ?? 0.0);

  @override
  double get minExtent => kToolbarHeight + (topPadding ?? 0.0);

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
