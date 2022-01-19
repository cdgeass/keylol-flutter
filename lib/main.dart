import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/index/index.dart';
import 'common/keylol_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await KeylolClient().init();

  BlocOverrides.runZoned(
    () => runApp(MaterialApp(home: IndexPage())),
  );
}
