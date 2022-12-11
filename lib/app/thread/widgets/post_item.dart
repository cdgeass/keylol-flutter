import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/api/models/post.dart';
import 'package:keylol_flutter/components/avatar.dart';
import 'package:keylol_flutter/app/thread/bloc/thread_bloc.dart';
import 'package:keylol_flutter/app/thread/widgets/reply_modal.dart';

typedef PostBuilder = Widget Function(Post post);

class PostItem extends StatelessWidget {
  final Post post;
  final PostBuilder builder;

  const PostItem({Key? key, required this.post, required this.builder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        border: BorderDirectional(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.surfaceVariant,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Avatar(
              uid: post.authorId,
              username: post.author,
              width: 40.0,
              height: 40.0,
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(post.author),
                Text('${post.number}楼'),
              ],
            ),
            subtitle: Text(post.dateline),
          ),
          builder.call(post),
          ButtonBar(
            alignment: MainAxisAlignment.start,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      ReplyRoute(context.read<ThreadBloc>(), null, post),
                    );
                  },
                  icon: Icon(Icons.reply_outlined)),
              // if (Provider.of<ProfileProvider>(context).profile?.memberUid ==
              //     post.authorId)
              //   IconButton(
              //       onPressed: () {
              //         // TODO 编辑
              //       },
              //       icon: Icon(Icons.edit)),
            ],
          )
        ],
      ),
    );
  }
}
