import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/index/bloc/index_bloc.dart';
import 'package:keylol_flutter/app/index/view/index_tabview.dart';

class IndexPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocProvider(
        create: (_) => IndexBloc()..add(IndexFetched()),
        child: IndexTabView(),
      ),
    );
  }
}
