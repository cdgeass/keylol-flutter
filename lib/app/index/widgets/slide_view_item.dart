import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:keylol_flutter/app/index/models/models.dart';

import '../../thread/view/view.dart';

class SlideViewItem extends StatelessWidget {
  final IndexSlideViewItem slideViewItem;

  const SlideViewItem({Key? key, required this.slideViewItem})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 图片
    final img = Material(
      child: Container(
        child: FadeInImage(
          image: CachedNetworkImageProvider(slideViewItem.img),
          placeholder: AssetImage("images/slide_view_placeholder.jpg"),
          fit: BoxFit.cover,
        ),
      ),
    );

    // 页脚
    final footer = Container(
      color: Colors.transparent,
      child: GridTileBar(
        backgroundColor: Colors.black26,
        title: Text(slideViewItem.title,
            softWrap: true, overflow: TextOverflow.ellipsis),
      ),
    );

    return Container(
      child: InkWell(
        onTap: () {
          // 跳转到帖子页面
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ThreadPage(tid: slideViewItem.tid)));
        },
        child: GridTile(
          footer: footer,
          child: img,
        ),
      ),
    );
  }
}
