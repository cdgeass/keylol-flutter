import 'package:flutter/material.dart';
import 'package:keylol_flutter/api/models/thread.dart';
import 'package:keylol_flutter/components/avatar.dart';

typedef ThreadWrapperBuilder = Widget Function(Widget child);

class ThreadItem extends StatelessWidget {
  final Thread thread;
  final ThreadWrapperBuilder? wrapperBuilder;

  const ThreadItem({Key? key, required this.thread, this.wrapperBuilder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = ListTile(
      leading: thread.authorId.isEmpty
          ? null
          : Avatar(
              key: Key('Avatar ${thread.authorId}'),
              uid: thread.authorId,
              username: thread.author,
              width: 40.0,
              height: 40.0,
            ),
      title: Text(
        thread.subject,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      subtitle: Text(
        '${thread.author} • ${thread.dateline}',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      onTap: () {
        Navigator.of(context).pushNamed(
          '/thread',
          arguments: {'tid': thread.tid},
        );
      },
    );
    return Container(
      child: wrapperBuilder == null ? content : wrapperBuilder!.call(content),
    );
  }
}
