import 'package:flutter/material.dart';

class IndexAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final Widget slideView;
  final TabBar tabBar;

  IndexAppBar({
    required this.expandedHeight,
    required this.slideView,
    required this.tabBar,
  });

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    double toolbarOpacity =
        ((maxExtent - minExtent - shrinkOffset).round() / minExtent)
            .clamp(0.0, 1.0);
    final isScrolledUnder =
        overlapsContent || (shrinkOffset > maxExtent - minExtent);

    final title = toolbarOpacity == 0.0 ? Text('聚焦') : null;
    final flexibleSpace = toolbarOpacity == 0.0
        ? null
        : Semantics(
            header: true,
            child: slideView,
          );

    return AppBar(
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
  double get maxExtent => expandedHeight + 46.0;

  @override
  double get minExtent => kToolbarHeight + 46.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
