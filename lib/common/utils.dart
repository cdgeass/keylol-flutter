import 'package:flutter/material.dart';
import 'package:keylol_flutter/components/rich_text.dart';

Size calTextSize(BuildContext context, String text,
    {TextStyle? style,
      int maxLines = 2 ^ 31,
      double maxWidth = double.infinity}) {
  if (text.isEmpty) {
    return Size.zero;
  }

  final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(text: text, style: style),
      locale: Localizations.localeOf(context),
      maxLines: maxLines)
    ..layout(maxWidth: maxWidth);
  return textPainter.size;
}

List<Widget> htmlHandler(BuildContext context, String html) {
  List<Widget> widgets = [];

  var lastIndex = 0;
  var index = 0;

  while (html.contains('iframe')) {
    index = html.indexOf('<iframe');
    final beforeIframe = html.substring(lastIndex, index);
    widgets.add(KRichText(message: beforeIframe));

    lastIndex = index;

    index = html.indexOf('</iframe>') + 9;
    final iframe = html.substring(lastIndex, index);
    // TODO 添加设置项
    widgets.add(KRichText(message: '<spoil>$iframe</spoil>'));

    html = html.substring(index);
    lastIndex = 0;
    index = 0;
  }
  if (html.isNotEmpty) {
    widgets.add(KRichText(message: html));
  }

  return widgets;
}
