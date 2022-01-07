import 'package:flutter/material.dart';

final blue = ThemeData.from(
    colorScheme: ColorScheme.light()
        .copyWith(primary: Color(0xFF2196F3), secondary: Color(0xFFEF5350)));

final purple = ThemeData.from(
    colorScheme: ColorScheme.light()
        .copyWith(primary: Color(0xFF9C27B0), secondary: Color(0xFFFFCA28)));

final red = ThemeData.from(
    colorScheme: ColorScheme.light()
        .copyWith(primary: Color(0xFFF44336), secondary: Color(0xFFFFA726)));

final orange = ThemeData.from(
    colorScheme: ColorScheme.light()
        .copyWith(primary: Color(0xFFFF5722), secondary: Color(0xFFFBC02D)));

final green = ThemeData.from(
    colorScheme: ColorScheme.light()
        .copyWith(primary: Color(0xFFCDDC39), secondary: Color(0xFF009688)));

final lowChroma = ThemeData.from(
    colorScheme: ColorScheme.light()
        .copyWith(primary: Color(0xFF607D8B), secondary: Color(0xFFFDD835)));

final colors = [blue, purple, red, orange, green, lowChroma];
