import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/thread/bloc/thread_bloc.dart';
import 'package:keylol_flutter/app/thread/widgets/widgets.dart';
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
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: ThreadAppBar(
                    thread: state.thread!,
                    textStyle: Theme.of(context).textTheme.headline6!,
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
              ];
            },
            body: ListView.builder(
              itemBuilder: (context, index) {
                return Card(
                  child: SizedBox(
                    height: 64.0,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
