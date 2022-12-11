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

  final client = await KeylolApiClient.init();
  final authenticationRepository = AuthenticationRepository(client: client);
  client.addInterceptor(ProfileInterceptor(
    profileRepository: authenticationRepository,
  ));
  await authenticationRepository.logIn();

  runApp(KeylolApp(
    client: client,
    settingsRepository: settingsRepository,
    authenticationRepository: authenticationRepository,
    historyRepository: historyRepository,
  ));
}
