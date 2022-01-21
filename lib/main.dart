import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/app.dart';

import 'common/keylol_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await KeylolClient().init();

  BlocOverrides.runZoned(
    () => runApp(KeylolApp()),
  );
}
