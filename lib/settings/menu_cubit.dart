import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/repository/repository.dart';

class MenuCubit extends Cubit<List<String>> {
  static const List<String> defaultMenu = const [
    'index',
    'guide',
    'forumIndex',
    'favThread',
    'notice',
    'history',
    'login'
  ];

  final SettingsRepository _settingsRepository;

  MenuCubit({
    required SettingsRepository settingsRepository,
  })  : _settingsRepository = settingsRepository,
        super(settingsRepository.getMenus() ?? defaultMenu);

  void updateMenus(List<String> menus) {
    _settingsRepository.setMenus(menus);
    emit(menus);
  }
}
