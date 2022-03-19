import 'package:flutter/material.dart';

import '../../notice/widgets/widgets.dart';

class IndexAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final Widget slideView;
  final TabBar tabBar;

  final double? topPadding;

  IndexAppBar({
    required this.expandedHeight,
    required this.slideView,
    required this.tabBar,
    this.topPadding,
  });

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    double toolbarOpacity =
        ((maxExtent - minExtent - shrinkOffset).round() / minExtent)
            .clamp(0.0, 1.0);

    final title = toolbarOpacity == 0.0 ? Text('聚焦') : null;

    return AppBar(
      leading: NoticeLeading(),
      title: title,
      centerTitle: true,
      flexibleSpace: Opacity(
        opacity: toolbarOpacity,
        child: Stack(
          children: [
            Positioned(
              top: -shrinkOffset,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: slideView,
              ),
            )
          ],
        ),
      ),
      bottom: tabBar,
    );
  }

  @override
  double get maxExtent => expandedHeight + tabBar.preferredSize.height;

  @override
  double get minExtent =>
      kToolbarHeight + tabBar.preferredSize.height + (topPadding ?? 0.0);

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
