import 'package:html/dom.dart';
import 'package:keylol_flutter/models/thread.dart';

// 首页
class Index {
  late final List<IndexSlideViewItem> slideViewItems;
  late final Map<IndexTabTitleItem, List<Thread>> tabThreadsMap;

  Index(this.slideViewItems, this.tabThreadsMap);

  Index.fromDocument(Document document) {
    // 轮播图
    var portalContent = document.getElementById('portal_block_431_content');
    if (portalContent != null) {
      var slideShow = portalContent.getElementsByClassName('slideshow')[0];
      slideViewItems =
          slideShow.getElementsByTagName('li').map((slideShowItem) {
        final title = slideShowItem.getElementsByClassName('title')[0].text;
        final content = slideShowItem.getElementsByTagName('a')[0];
        final tid = content.attributes['href']
            ?.replaceAll('https://keylol.com/', '')
            .split('-')[0]
            .replaceFirst('t', '');
        final img = content.getElementsByTagName('img')[0].attributes['src'];
        return IndexSlideViewItem(tid!, title, img!);
      }).toList();
    }

    // tab 列表
    tabThreadsMap = new Map();
    var tab = document.getElementById('tabPAhn0P_title');
    if (tab != null) {
      var tabTitles = tab.nodes;
      for (var tabTitle in tabTitles) {
        var titleId = tabTitle.attributes['id']!;
        var content = document.getElementById(titleId + '_content')!;
        var items = content.getElementsByTagName('li');

        var tabThreads = items.map((item) {
          var aTags = item.getElementsByTagName('a');
          var authorHref = aTags[0];
          final authorId = authorHref.attributes['href']!.split('-')[1];

          String? fid;
          String? fname;
          if (aTags.length > 2) {
            var fInfo = aTags[1];
            fid = fInfo.attributes['href']!.replaceFirst('f', '').split('-')[0];
            fname = fInfo.text;
          } else {
            fid = null;
          }

          var tInfo = aTags[aTags.length - 1];
          final tid =
              tInfo.attributes['href']!.replaceFirst('t', '').split('-')[0];
          var fonts = tInfo.getElementsByTagName('font');
          String title;
          if (tInfo.innerHtml.contains('data-yjshash')) {
            title = calculateProtectedEmail(tInfo);
          } else if (fonts.isEmpty) {
            title = tInfo.text;
          } else {
            title = fonts[0].text;
          }
          final titleInfo =
              tInfo.attributes['title']!.split('\n')[1].split(' ');
          final author = titleInfo[1];
          final dateline = titleInfo[2].substring(1, titleInfo[2].length - 1);

          return Thread.fromJson({
            'tid': tid,
            'subject': title,
            'dateline': dateline,
            'authorid': authorId,
            'author': author
          });
        }).toList();

        var fid = titleId.split('_')[2];
        var name = (tabTitle as Element)
            .getElementsByClassName('blocktitle')[0]
            .getElementsByTagName('a')[0]
            .text;
        var tabTitleItem = IndexTabTitleItem(fid, name);

        tabThreadsMap[tabTitleItem] = tabThreads;
      }
    }
  }

  // 计算加密的含@字符串
  String calculateProtectedEmail(Element element) {
    final span = element.getElementsByClassName('__yjs_email__')[0];
    var a = span.attributes['data-yjsemail']!;

    final r = int.parse('0x' + a.substring(0, 2)) | 0;
    var e = '';
    for (var n = 2; a.length - n > 0; n += 2) {
      final temp = ('0' +
          (int.parse('0x' + a.substring(n, n + 2)) ^ r).toRadixString(16));
      e += '%' + temp.substring(temp.length - 2);
    }

    return Uri.decodeComponent(e);
  }
}

// 轮播图
class IndexSlideViewItem {
  // 帖子id
  final String tid;

  // 标题
  final String title;

  // 封面图
  final String img;

  const IndexSlideViewItem(this.tid, this.title, this.img);
}

// Tab页标题
class IndexTabTitleItem {
  // 板块id
  final String fid;

  // 板块名称
  final String name;

  IndexTabTitleItem(this.fid, this.name);
}
