import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:keylol_flutter/app/app.dart';
import 'package:keylol_flutter/repository/repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsRepository = SettingsRepository();
  await settingsRepository.initial();

  final historyRepository = HistoryRepository();
  await historyRepository.initial();

  final profileRepository = ProfileRepository();
  final noticeRepository = NoticeRepository();
  final client = await KeylolApiClient.create(
    profileRepository: profileRepository,
    noticeRepository: noticeRepository,
  );

  BlocOverrides.runZoned(
    () => runApp(KeylolApp(
      client: client,
      settingsRepository: settingsRepository,
      profileRepository: profileRepository,
      noticeRepository: noticeRepository,
      historyRepository: historyRepository,
    )),
  );
}
