import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/repository/repository.dart';

class ThemeCubit extends Cubit<Color> {
  static const _defaultColor = Colors.lightBlue;

  final SettingsRepository _settingsRepository;

  ThemeCubit({
    required SettingsRepository settingsRepository,
  })  : this._settingsRepository = settingsRepository,
        super(_defaultColor);


  void updateTheme(Color? color) {
    if (color != null) {
      emit(color);
    }
  }
}
