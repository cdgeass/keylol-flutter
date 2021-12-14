import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:keylol_flutter/common/keylol_client.dart';
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
    final noteList = await KeylolClient().fetchNoteList(1);
    setState(() {
      _page = 1;
      _total = noteList.count;
      _noteList = noteList.list;
    });
  }

  void _loadMore() async {
    final noteList = await KeylolClient().fetchNoteList(_page + 1);
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
          leading: buildAppBarLeading(),
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
                var text = parse(note.note).body?.text ?? '';
                text = text.replaceAll(' 查看', '');
                return InkWell(
                    onTap: () {
                      final tid = note.noteVar?.tid;
                      if (tid != null) {
                        Navigator.of(context)
                            .pushNamed('/thread', arguments: tid);
                      }
                    },
                    child: Card(
                        color: Theme.of(context).cardColor,
                        child: Container(
                          padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                          alignment: Alignment.centerLeft,
                          constraints: BoxConstraints(minHeight: 48.0),
                          child: Text(text),
                        )));
              }
            },
          ),
        ));
  }
}
