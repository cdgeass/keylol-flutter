import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<Color> {
  ThemeCubit() : super(defaultColor);

  static const defaultColor = Colors.lightBlue;

  void updateTheme(Color? color) {
    if (color != null) {
      emit(color);
    }
  }
}
