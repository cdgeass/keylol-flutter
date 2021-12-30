import 'package:flutter/material.dart';

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