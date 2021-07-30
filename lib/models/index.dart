import 'package:html/dom.dart';

class Index {
  List<IndexSlideViewItem>? slideViewItems;
  Map<IndexTabTitleItem, List<IndexTabThreadItem>>? tabThreadsMap;

  Index(this.slideViewItems);

  Index.fromDocument(Document document) {
    // 轮播图
    var portalContent = document.getElementById('portal_block_431_content');
    if (portalContent != null) {
      var slideShow = portalContent.getElementsByClassName('slideshow')[0];
      slideViewItems =
          slideShow.getElementsByTagName('li').map((slideShowItem) {
        final title =
            slideShowItem.getElementsByClassName('title')[0].innerHtml;

        final content = slideShowItem.getElementsByTagName('a')[0];
        final tid =
            content.attributes['href']?.split('-')[0].replaceFirst('t', '');
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
          var memberInfo = aTags[0];
          final memberUid = memberInfo.attributes['href']!.split('-')[1];

          String? fid;
          if (aTags.length > 2) {
            var fInfo = aTags[1];
            fid = fInfo.attributes['href']!.replaceFirst('f', '').split('-')[0];
          } else {
            fid = null;
          }

          var tInfo = aTags[aTags.length - 1];
          final tid =
              tInfo.attributes['href']!.replaceFirst('t', '').split('-')[0];
          var fonts = tInfo.getElementsByTagName('font');
          String title;
          if (fonts.isEmpty) {
            title = tInfo.innerHtml;
          } else {
            title = fonts[0].innerHtml;
          }
          final titleInfo =
              tInfo.attributes['title']!.split('\n')[1].split(' ');
          final memberUsername = titleInfo[1];
          final dateLine = titleInfo[2].substring(1, titleInfo[2].length - 1);

          return IndexTabThreadItem(
              tid, fid, title, memberUsername, memberUid, dateLine);
        }).toList();

        var fid = titleId.split('_')[2];
        var name = (tabTitle as Element)
            .getElementsByClassName('blocktitle')[0]
            .getElementsByTagName('a')[0]
            .innerHtml;
        var tabTitleItem = IndexTabTitleItem(fid, name);

        tabThreadsMap![tabTitleItem] = tabThreads;
      }
    }
  }
}

class IndexSlideViewItem {
  final String tid;
  final String title;
  final String img;

  const IndexSlideViewItem(this.tid, this.title, this.img);
}

class IndexTabTitleItem {
  final String fid;
  final String name;

  IndexTabTitleItem(this.fid, this.name);
}

class IndexTabThreadItem {
  final String tid;
  final String? fid;
  final String title;
  final String memberUsername;
  final String memberUid;
  final String dateLine;

  IndexTabThreadItem(this.tid, this.fid, this.title, this.memberUsername,
      this.memberUid, this.dateLine);
}
