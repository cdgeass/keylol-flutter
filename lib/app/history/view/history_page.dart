import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/history/bloc/history_bloc.dart';
import 'package:keylol_flutter/components/thread_card.dart';
import 'package:keylol_flutter/repository/history_repository.dart';

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          HistoryBloc(historyRepository: context.read<HistoryRepository>())
            ..add(HistoryReloaded()),
      child: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text('历史'),
              centerTitle: true,
            ),
            body: ListView.builder(
              itemCount: state.threads.length,
              itemBuilder: (context, index) {
                return ThreadCard(thread: state.threads[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
