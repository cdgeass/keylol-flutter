import 'package:html/dom.dart';
import 'package:keylol_flutter/app/thread/models/thread.dart';

class Guide {
  int totalPage = 1;
  List<Thread> threadList = [];

  Guide.fromDocument(Document document) {
    final bmCs = document.getElementsByClassName('bm_c');

    late Element table;
    for (final bmC in bmCs) {
      final tables = bmC.getElementsByTagName('table');
      if (tables.isNotEmpty) {
        table = tables[0];
        break;
      }
    }

    threadList = [];
    final tbodys = table.getElementsByTagName('tbody');
    for (final tbody in tbodys) {
      if (tbody.text == '暂时还没有帖子') {
        return;
      }

      // 帖子
      final common = tbody.getElementsByClassName('common')[0];
      final commonAs = common.getElementsByTagName('a');
      var commonA = commonAs[0];
      if (commonA.getElementsByTagName('img').isNotEmpty) {
        commonA = commonAs[1];
      }

      final tid =
          commonA.attributes['href']!.split('-')[0].replaceFirst('t', '');
      final subject = commonA.text;

      // 版块
      final by1 = tbody.getElementsByClassName('by')[0];
      final by1A = by1.getElementsByTagName('a')[0];

      final fid = by1A.attributes['href']!.split('-')[0].replaceFirst('f', '');

      // 作者
      final by2 = tbody.getElementsByClassName('by')[1];
      final by2A = by2.getElementsByTagName('a')[0];
      final lastSpan = by2.getElementsByTagName('span')[0];

      final authorId = by2A.attributes['href']!.split('-')[1];
      final author = by2A.text;
      late String dateline;
      if (lastSpan.getElementsByTagName('span').isEmpty) {
        dateline = lastSpan.text;
      } else {
        dateline = lastSpan.getElementsByTagName('span')[0].text;
      }

      // 统计
      final num = tbody.getElementsByClassName('num')[0];
      final numA = num.getElementsByTagName('a')[0];
      final numEm = num.getElementsByTagName('em')[0];

      final views = numA.text;
      final replies = numEm.text;

      threadList.add(Thread.fromJson({
        'tid': tid,
        'fid': fid,
        'author': author,
        'authorid': authorId,
        'subject': subject,
        'dateline': dateline,
        'views': views,
        'replies': replies
      }));
    }

    final labels = document.getElementsByTagName('label');
    for (final label in labels) {
      final spans = label.getElementsByTagName('span');
      if (spans.isNotEmpty) {
        final span = spans[0];
        final title = span.attributes['title']!;
        totalPage =
            int.parse(title.replaceFirst('共', '').replaceFirst('页', '').trim());
        break;
      }
    }
  }
}
