import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/notice/bloc/notice_bloc.dart';
import 'package:keylol_flutter/app/notice/widgets/widgets.dart';

class NoticeList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NoticeListState();
}

class _NoticeListState extends State<NoticeList> {
  final _controller = ScrollController();

  @override
  void initState() {
    _controller.addListener(() {
      final maxScroll = _controller.position.maxScrollExtent;
      final pixels = _controller.position.pixels;
      if (maxScroll == pixels) {
        setState(() {
          context.read<NoticeBloc>().add(NoticeLoaded());
        });
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
    return BlocBuilder<NoticeBloc, NoticeState>(
      builder: (context, state) {
        return ListView.builder(
          controller: _controller,
          itemCount: state.notes.length + 1,
          itemBuilder: (context, index) {
            if (index == state.notes.length) {
              return Center(
                child: Opacity(
                  opacity: state.total > state.notes.length ? 1.0 : 0.0,
                  child: CircularProgressIndicator(),
                ),
              );
            } else {
              final note = state.notes[index];
              if (note.type == 'pcomment') {
                return PcommentCard(note: note);
              } else if (note.type == 'system') {
                return SystemCard(note: note);
              } else if (note.type == 'post') {
                return PostCard(note: note);
              } else if (note.type == 'favorite_thread') {
                return FavoriteThread(note: note);
              }
            }
            return Container();
          },
        );
      },
    );
  }
}
