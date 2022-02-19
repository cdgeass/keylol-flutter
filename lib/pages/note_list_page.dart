import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/keylol_client.dart';
import 'package:keylol_flutter/app/notice/widgets/widgets.dart';
import 'package:keylol_flutter/components/noticeable_leading.dart';
import 'package:keylol_flutter/components/user_account_drawer.dart';
import 'package:keylol_flutter/models/notice.dart';

class NoteListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  int _page = 1;
  int _total = 0;
  List<Note> _noteList = [];

  final controller = ScrollController();

  @override
  void initState() {
    super.initState();

    _onRefresh();

    controller.addListener(() {
      final maxScroll = controller.position.maxScrollExtent;
      final pixels = controller.position.pixels;
      if (maxScroll == pixels) {
        setState(() {
          _loadMore();
        });
      }
    });
  }

  Future<void> _onRefresh() async {
    final noteList = await KeylolClient().fetchNoteList();
    setState(() {
      _page = 1;
      _total = noteList.count;
      _noteList = noteList.list;
    });
  }

  void _loadMore() async {
    final noteList = await KeylolClient().fetchNoteList(page: _page + 1);
    setState(() {
      _page = noteList.page;
      _total = noteList.count;
      _noteList.addAll(noteList.list);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: NoticeableLeading(),
          title: Text('提醒'),
          centerTitle: true,
        ),
        drawer: UserAccountDrawer(),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.builder(
            controller: controller,
            itemCount: _noteList.length + 1,
            itemBuilder: (context, index) {
              if (index == _noteList.length) {
                return Center(
                  child: Opacity(
                    opacity: _total > _noteList.length ? 1.0 : 0.0,
                    child: CircularProgressIndicator(),
                  ),
                );
              } else {
                final note = _noteList[index];

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
          ),
        ));
  }
}
