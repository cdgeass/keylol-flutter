import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/thread/bloc/thread_bloc.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class ThreadList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ThreadListState();
}

class _ThreadListState extends State<ThreadList> {
  final _controller = AutoScrollController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThreadBloc, ThreadState>(
      builder: (context, state) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [],
          ),
        );
      },
    );
  }
}
