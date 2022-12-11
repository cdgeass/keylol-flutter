import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/history/bloc/history_bloc.dart';
import 'package:keylol_flutter/components/list_divider.dart';
import 'package:keylol_flutter/components/thread_item.dart';
import 'package:keylol_flutter/repository/history_repository.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HistoryPage();
}

class _HistoryPage extends State<HistoryPage> {
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
            body: ListView.separated(
              itemCount: state.threads.length,
              itemBuilder: (context, index) {
                return ThreadItem(thread: state.threads[index]);
              },
              separatorBuilder: (context, index) {
                return ListDivider(isLast: index == state.threads.length - 1);
              },
            ),
          );
        },
      ),
    );
  }
}
