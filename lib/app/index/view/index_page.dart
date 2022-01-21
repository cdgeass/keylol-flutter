import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/authentication/authentication.dart';
import 'package:keylol_flutter/app/index/bloc/index_bloc.dart';
import 'package:keylol_flutter/app/index/view/index_list.dart';
import 'package:keylol_flutter/common/keylol_client.dart';

class IndexPage extends StatelessWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWidget(),
      body: BlocProvider(
        create: (_) =>
            IndexBloc(client: KeylolClient().dio)..add(IndexFetched()),
        child: IndexList(),
      ),
    );
  }
}
