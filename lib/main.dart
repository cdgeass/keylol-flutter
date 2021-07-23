import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/global.dart';
import 'package:keylol_flutter/pages/user_account_drawer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Global.init();
  runApp(KeylolApp());
}

class KeylolApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Keylol',
      theme: ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(),
        drawer: UserAccountDrawer(),
      ),
    );
  }
}
