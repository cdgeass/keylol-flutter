import 'package:html/dom.dart';

class Index {
  List<IndexSlideViewItem>? slideViewItems;

  Index(this.slideViewItems);

  Index.fromDocument(Document document) {
    var portalContent = document.getElementById('portal_block_431_content');
    if (portalContent == null) {
      return;
    }

    var slideShow = portalContent.getElementsByClassName('slideshow')[0];
    slideViewItems = slideShow.getElementsByTagName('li').map((slideShowItem) {
      final title = slideShowItem.getElementsByClassName('title')[0].innerHtml;

      final content = slideShowItem.getElementsByTagName('a')[0];
      final tid =
          content.attributes['href']?.split('-')[0].replaceFirst('t', '');
      final img = content.getElementsByTagName('img')[0].attributes['src'];

      return IndexSlideViewItem(tid!, title, img!);
    }).toList();


  }
}

class IndexSlideViewItem {
  final String tid;
  final String title;
  final String img;

  const IndexSlideViewItem(this.tid, this.title, this.img);
}
