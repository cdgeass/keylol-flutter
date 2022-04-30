import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:keylol_flutter/app/app.dart';
import 'package:keylol_flutter/repository/history_repository.dart';
import 'package:keylol_flutter/repository/notice_repository.dart';
import 'package:keylol_flutter/repository/profile_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      profileRepository: profileRepository,
      noticeRepository: noticeRepository,
      historyRepository: historyRepository,
    )),
  );
}
