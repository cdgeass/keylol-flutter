import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/global.dart';
import 'package:keylol_flutter/model/index.dart';
import 'package:keylol_flutter/pages/user_account_drawer.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  late Future<Index> _indexFuture;

  @override
  void initState() {
    _indexFuture = Global.keylolClient.fetchIndex();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: UserAccountDrawer(),
      body: SafeArea(
        child: FutureBuilder(
          future: _indexFuture,
          builder: (BuildContext context, AsyncSnapshot<Index> snapshot) {
            if (snapshot.hasData) {
              var index = snapshot.data!;
              // 轮播图
              final slideView = CarouselSlider(
                options: CarouselOptions(
                  height: 276.0,
                  enableInfiniteScroll: false,
                  autoPlay: true,
                ),
                items: index.slideViewItems
                    ?.map((slideViewItem) =>
                        _SlideViewItem(slideViewItem: slideViewItem))
                    .toList(),
              );

              return slideView;
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

class _SlideViewItem extends StatelessWidget {
  final IndexSlideViewItem slideViewItem;

  const _SlideViewItem({Key? key, required this.slideViewItem})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 图片
    final img = Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 200.0,
        child: FadeInImage.assetNetwork(
          placeholder: "images/slide_view_placeholder.jpg",
          image: slideViewItem.img,
          fit: BoxFit.cover,
        ),
      ),
    );
    // 页脚
    final footer = Material(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(4.0))),
      clipBehavior: Clip.antiAlias,
      color: Colors.transparent,
      child: GridTileBar(
        backgroundColor: Colors.black45,
        title: Text(
          slideViewItem.title,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {},
        child: GridTile(
          footer: footer,
          child: img,
        ),
      ),
    );
  }
}
