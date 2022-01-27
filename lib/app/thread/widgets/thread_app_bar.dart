import 'package:flutter/material.dart';
import 'package:keylol_flutter/app/thread/models/thread.dart';

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

  final double _subjectHeight;

  ThreadAppBar({
    required this.thread,
    required this.textStyle,
    required width,
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
              top: kToolbarHeight - shrinkOffset,
              child: Container(
                padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                width: width,
                child: Text(thread.subject, style: textStyle),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => kToolbarHeight + _subjectHeight + 8.0;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
