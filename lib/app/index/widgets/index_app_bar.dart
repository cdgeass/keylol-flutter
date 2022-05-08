import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/index/bloc/index_bloc.dart';
import 'package:keylol_flutter/components/searchable_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

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

    return SearchableAppBar(
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
      callback: (text) {
        Navigator.of(context).pushNamed(
          '/webView',
          arguments:
              'https://www.google.com/search?q=site:keylol.com+${text.replaceAll(' ', '+')}',
        );
      },
      isClearAfterCallback: true,
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
