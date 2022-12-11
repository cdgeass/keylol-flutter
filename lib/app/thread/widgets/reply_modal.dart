import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:keylol_flutter/app/thread/bloc/thread_bloc.dart';
import 'package:keylol_flutter/common/constants.dart';
import 'package:keylol_flutter/components/sliver_tab_bar_delegate.dart';
import 'package:keylol_flutter/repository/repository.dart';

typedef ReplyCallback = void Function();

class ReplyRoute extends PopupRoute {
  final ThreadBloc bloc;
  final Thread? thread;
  final Post? post;

  ReplyRoute(this.bloc, this.thread, this.post);

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return BlocProvider.value(
      value: bloc,
      child: ReplyModal(
        thread: thread,
        post: post,
      ),
    );
  }

  @override
  Duration get transitionDuration => Duration(microseconds: 750);
}

class ReplyModal extends StatefulWidget {
  final Thread? thread;
  final Post? post;

  const ReplyModal({
    Key? key,
    this.thread,
    this.post,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ReplyModalState();
}

class _ReplyModalState extends State<ReplyModal> {
  final _controller = TextEditingController();

  bool _showSmiley = false;

  final List<String> _aidList = [];

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.black12.withOpacity(0.75),
      body: Column(
        children: [
          Expanded(
              child: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(),
          )),
          Container(
            padding: EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0),
            color: Theme.of(context).colorScheme.surface,
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.multiline,
              cursorColor: Theme.of(context).primaryColor,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              maxLines: null,
              autofocus: true,
              onTap: () {
                // 收回表情
                if (_showSmiley) {
                  setState(() {
                    _showSmiley = false;
                  });
                }
              },
            ),
          ),
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                // 表情
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showSmiley = true;
                    });
                  },
                  icon: Icon(Icons.emoji_emotions_outlined),
                  color: Theme.of(context).primaryColor,
                ),
                IconButton(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final image =
                        await picker.pickImage(source: ImageSource.gallery);

                    if (image != null) {
                      final uid =
                          context.read<AuthenticationRepository>().profile?.memberUid;
                      if (uid == null) {
                        return;
                      }
                      final aid = await context
                          .read<KeylolApiClient>()
                          .fileUpload(uid, image);
                      _insertText('[attachimg]$aid[/attachimg]');
                      _aidList.add(aid);
                    }
                  },
                  icon: Icon(Icons.photo_outlined),
                  color: Theme.of(context).primaryColor,
                ),
                // 空白
                Expanded(child: Container()),
                // 发送
                IconButton(
                  onPressed: () {
                    _sendReply(context);
                  },
                  icon: Icon(Icons.send),
                  color: Theme.of(context).primaryColor,
                )
              ],
            ),
          ),
          if (_showSmiley)
            Container(
              color: Theme.of(context).colorScheme.surface,
              height: 400.0,
              child: _SmileyPicker(
                onSelect: (smiley) {
                  _insertText(smiley);
                },
              ),
            ),
        ],
      ),
    );
  }

  void _insertText(String insertText) {
    final selection = _controller.selection;

    final text = _controller.text;
    final newText =
        text.replaceRange(selection.start, selection.end, insertText);

    _controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
            offset: selection.baseOffset + insertText.length));
  }

  void _sendReply(BuildContext context) {
    if (widget.thread != null) {
      context.read<ThreadBloc>().add(ThreadReplied(
            message: _controller.text,
            aIds: _aidList,
          ));
    } else if (widget.post != null) {
      context.read<ThreadBloc>().add(ThreadReplied(
            post: widget.post,
            message: _controller.text,
            aIds: _aidList,
          ));
    }
    Navigator.of(context).pop();
  }
}

typedef SmileySelectCallback = void Function(String emoji);

class _SmileyPicker extends StatelessWidget {
  final SmileySelectCallback onSelect;

  const _SmileyPicker({Key? key, required this.onSelect}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: SMILEY_MAP.keys.length,
      child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverPersistentHeader(
                  pinned: true,
                  floating: true,
                  delegate: SliverTabBarDelegate(
                      tabBar: TabBar(
                          isScrollable: true,
                          tabs: SMILEY_MAP.keys
                              .map((key) => Tab(child: Text(key)))
                              .toList()))),
            ];
          },
          body: TabBarView(
              children: SMILEY_MAP.keys.map((key) {
            var emojis = SMILEY_MAP[key]!;
            return GridView.count(
              crossAxisCount: 5,
              children: emojis.map((pair) {
                var url = pair.keys.first;
                var alt = pair[url]!;
                return GestureDetector(
                  onTap: () => onSelect.call(alt),
                  child: CachedNetworkImage(
                    imageUrl: url,
                  ),
                );
              }).toList(),
            );
          }).toList())),
    );
  }
}
