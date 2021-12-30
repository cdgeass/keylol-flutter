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

  html = html.replaceAll('<br>', '<br />');

  var lastIndex = 0;
  var index = 0;

  while (html.contains('iframe')) {
    index = html.indexOf('<iframe');
    final beforeIframe = html.substring(lastIndex, index);
    if (beforeIframe != '\n') {
      widgets.addAll(_htmlBrHandler(context, beforeIframe));
    }

    lastIndex = index;

    index = html.indexOf('</iframe>') + 9;
    final iframe = html.substring(lastIndex, index);
    widgets.add(KRichText(message: iframe));

    html = html.substring(index);
    lastIndex = 0;
    index = 0;
  }
  if (html.isNotEmpty) {
    widgets.add(KRichText(message: html));
  }

  return widgets;
}

List<Widget> _htmlBrHandler(BuildContext context, String html) {
  List<Widget> widgets = [];

  var lastIndex = 0;
  var index = 0;
  while (html.contains('<br />')) {
    index = html.indexOf('<br />');
    var beforeBr = html.substring(lastIndex, index);
    beforeBr = beforeBr.trim();
    if (beforeBr.isNotEmpty) {
      widgets.add(KRichText(message: beforeBr));
    }

    lastIndex = index;
    index = index + 6;

    html = html.substring(index);
    lastIndex = 0;
    index = 0;
  }

  return widgets;
}
