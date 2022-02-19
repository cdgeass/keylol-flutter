import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:keylol_flutter/components/avatar.dart';
import 'package:keylol_flutter/models/notice.dart';

String _trim(String note) {
  var str = note.replaceAllMapped(RegExp(r'<[^>]+>'), (match) => '').trim();
  str = HtmlUnescape().convert(str);
  if (str.endsWith('查看')) {
    return str.substring(0, str.lastIndexOf('查看')).trim();
  } else if (str.endsWith('查看 ›')) {
    return str.substring(0, str.lastIndexOf('查看 ›')).trim();
  } else {
    return str.trim();
  }
}

class PcommentCard extends StatelessWidget {
  final Note note;

  const PcommentCard({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final document = HtmlParser.parseHTML(note.note);
    final aTags = document.body!.getElementsByTagName('a');

    final href = aTags[2].attributes['href']!;
    final params = href.split('?')[1].split('&');
    late String tid;
    String? pid;
    for (final param in params) {
      if (param.startsWith('pid')) {
        pid = param.split('=')[1];
      } else if (param.startsWith('tid')) {
        tid = param.split('=')[1];
      } else if (param.startsWith('ptid')) {
        tid = param.split('=')[1];
      }
    }

    return InkWell(
        child: Card(
          child: ListTile(
            leading: Avatar(
              uid: note.authorId,
              width: 40.0,
              size: AvatarSize.middle,
            ),
            title: Text(_trim(note.note)),
          ),
        ),
        onTap: () {
          Navigator.of(context)
              .pushNamed('/thread', arguments: {'tid': tid, 'pid': pid});
        });
  }
}

class PostCard extends StatelessWidget {
  final Note note;

  const PostCard({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fromIdType = note.fromIdType;

    if (fromIdType == 'post') {
      final noteVar = note.noteVar!;

      return InkWell(
        child: Card(
          child: ListTile(
            leading: Avatar(
              uid: note.authorId,
              width: 40.0,
              size: AvatarSize.middle,
            ),
            title: Text(_trim(note.note)),
          ),
        ),
        onTap: () {
          Navigator.of(context).pushNamed('/thread',
              arguments: {'tid': noteVar.tid, 'pid': noteVar.pid});
        },
      );
    } else if (fromIdType == 'quote') {
      final noteVar = note.noteVar!;

      return InkWell(
        child: Card(
          child: ListTile(
            leading: Avatar(
              uid: note.authorId,
              width: 40.0,
              size: AvatarSize.middle,
            ),
            title: Text(_trim(note.note)),
          ),
        ),
        onTap: () {
          Navigator.of(context).pushNamed('/thread',
              arguments: {'tid': noteVar.tid, 'pid': noteVar.pid});
        },
      );
    } else if (fromIdType == 'moderate_移动') {
      final document = HtmlParser.parseHTML(note.note);
      final aTags = document.getElementsByTagName('a');
      final params = aTags[0].attributes['href']!.split('?')[1].split('&');
      late String tid;
      for (final param in params) {
        if (param.startsWith('tid')) {
          tid = param.split('=')[1];
        }
      }

      return InkWell(
        child: Card(
          child: ListTile(
            leading: CachedNetworkImage(
              imageUrl: 'https://keylol.com/static/image/common/systempm.png',
              width: 40.0,
            ),
            title: Text(_trim(note.note)),
          ),
        ),
        onTap: () {
          Navigator.of(context).pushNamed('/thread', arguments: {'tid': tid});
        },
      );
    }

    return Card();
  }
}

class SystemCard extends StatelessWidget {
  final Note note;

  const SystemCard({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (note.fromIdType == 'rate') {
      final document = HtmlParser.parseHTML(note.note);
      final aTags = document.getElementsByTagName('a');
      final params = aTags[0].attributes['href']!.split('?')[1].split('&');
      late String tid;
      String? pid;
      for (final param in params) {
        if (param.startsWith('pid')) {
          pid = param.split('=')[1];
        } else if (param.startsWith('tid')) {
          tid = param.split('=')[1];
        } else if (param.startsWith('ptid')) {
          tid = param.split('=')[1];
        }
      }

      return InkWell(
        child: Card(
            child: ListTile(
          leading: CachedNetworkImage(
            imageUrl: 'https://keylol.com/static/image/common/systempm.png',
            width: 40.0,
          ),
          title: Text(_trim(note.note)),
        )),
        onTap: () {
          Navigator.of(context)
              .pushNamed('/thread', arguments: {'tid': tid, 'pid': pid});
        },
      );
    } else {
      return InkWell(
          child: Card(
        child: ListTile(
            leading: CachedNetworkImage(
              imageUrl: 'https://keylol.com/static/image/common/systempm.png',
              width: 40.0,
            ),
            title: Text(_trim(note.note))),
      ));
    }
  }
}

class FavoriteThread extends StatelessWidget {
  final Note note;

  const FavoriteThread({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Card(
        child: ListTile(
          leading: CachedNetworkImage(
            imageUrl: 'https://keylol.com/static/image/common/systempm.png',
            width: 40.0,
          ),
          title: Text(_trim(note.note)),
        ),
      ),
      onTap: () {
        Navigator.of(context)
            .pushNamed('/thread', arguments: {'tid': note.fromId});
      },
    );
  }
}
