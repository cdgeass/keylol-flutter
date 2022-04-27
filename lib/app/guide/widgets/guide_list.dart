import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/guide/bloc/guide_bloc.dart';
import 'package:keylol_flutter/components/thread_card.dart';

class GuideList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GuideState();
}

class _GuideState extends State<GuideList> {
  final _controller = ScrollController();

  @override
  void initState() {
    _controller.addListener(() {
      final maxScroll = _controller.position.maxScrollExtent;
      final pixels = _controller.position.pixels;

      if (maxScroll == pixels) {
        context.read<GuideBloc>()..add(GuideLoaded());
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GuideBloc, GuideState>(
      builder: (context, state) {
        if (state.status != GuideStatus.success) {
          return Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: () async {
            context.read<GuideBloc>()..add(GuideReloaded());
          },
          child: ListView.builder(
            padding: EdgeInsets.only(top: 8.0),
            controller: _controller,
            itemCount: state.threads.length + 1,
            itemBuilder: (context, index) {
              if (index == state.threads.length) {
                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Opacity(
                    opacity: state.hasReachedMax ? 0.0 : 1.0,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }
              return ThreadCard(thread: state.threads[index]);
            },
          ),
        );
      },
    );
  }
}
