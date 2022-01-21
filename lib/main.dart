import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/app.dart';
import 'package:keylol_flutter/common/log.dart';

import 'common/keylol_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await KeylolClient().init();

  BlocOverrides.runZoned(() => runApp(KeylolApp()),
      blocObserver: SimpleObserver());
}

class SimpleObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);

    Log().d('${bloc.runtimeType} $change');
  }
}
