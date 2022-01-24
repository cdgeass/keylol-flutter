import 'package:flutter/material.dart';
import 'package:keylol_flutter/app/forum/models/models.dart';
import 'package:keylol_flutter/components/thread_card.dart';
import 'package:keylol_flutter/models/thread.dart';

class ForumThreadItem extends StatelessWidget {
  final ForumDisplayThread thread;

  const ForumThreadItem({Key? key, required this.thread}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThreadBuilder? builder;
    if (thread.displayOrder == 1) {
      builder = (child) {
        return ClipRect(
            child: Banner(
                location: BannerLocation.topStart,
                message: '置顶',
                color: Color(0xFF81C784),
                child: child));
      };
    } else if (thread.displayOrder == 3) {
      builder = (child) {
        return ClipRect(
            child: Banner(
                location: BannerLocation.topStart,
                message: '置顶',
                color: Color(0xFFFFD54F),
                child: child));
      };
    }

    return ThreadCard(
        thread: Thread.fromJson({
          'tid': thread.tid!,
          'subject': thread.subject!,
          'authorid': thread.authorId!,
          'author': thread.author!,
          'dateline': thread.dateline!
        }),
        builder: builder);
  }
}
