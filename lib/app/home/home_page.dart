import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/authentication/authentication.dart';
import 'package:keylol_flutter/app/home/custom_drawer.dart';
import 'package:keylol_flutter/app/home/forum_index_view.dart';
import 'package:keylol_flutter/app/home/guide_view.dart';
import 'package:keylol_flutter/app/home/index_view.dart';
import 'package:keylol_flutter/app/home/notification_view.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> homeKey = GlobalKey();
  late PageController _pageController;
  DateTime? _lastPressedAt;

  @override
  void initState() {
    _pageController = PageController();

    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  void _changePage(int? index) {
    _pageController.animateToPage(
      index!,
      duration: const Duration(microseconds: 200),
      curve: Curves.linear,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        int noticeCount = state.profile?.notice?.count() ?? 0;
        final destinations = [
          SalomonBottomBarItem(
            icon: Icon(
              Icons.home_outlined,
            ),
            activeIcon: Icon(
              Icons.home,
            ),
            title: Text('聚焦'),
          ),
          SalomonBottomBarItem(
            icon: Icon(
              Icons.camera_outlined,
            ),
            activeIcon: Icon(
              Icons.camera,
            ),
            title: Text('导读'),
          ),
          SalomonBottomBarItem(
            icon: Icon(
              Icons.dashboard_outlined,
            ),
            activeIcon: Icon(
              Icons.dashboard,
            ),
            title: Text('版块'),
          ),
          SalomonBottomBarItem(
            icon: Badge(
              isLabelVisible: noticeCount != 0,
              child: Icon(
                Icons.notifications_outlined,
              ),
            ),
            activeIcon: Badge(
              isLabelVisible: noticeCount != 0,
              child: Icon(
                Icons.notifications,
              ),
            ),
            title: Text('提醒'),
          ),
        ];

        final pages = [
          IndexView(homeKey: homeKey),
          GuideView(homeKey: homeKey),
          ForumIndexView(homeKey: homeKey),
          NotificationView(homeKey: homeKey),
        ];

        return WillPopScope(
          onWillPop: () async {
            if (_lastPressedAt == null ||
                DateTime.now().difference(_lastPressedAt!) >
                    Duration(seconds: 1)) {
              //两次点击间隔超过1秒则重新计时
              _lastPressedAt = DateTime.now();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('再按一次将退出'),
                  duration: Duration(seconds: 1),
                ),
              );
              return false;
            }
            return true;
          },
          child: Scaffold(
            key: homeKey,
            drawer: CustomDrawer(),
            body: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              children: pages,
            ),
            bottomNavigationBar: _BottomNavigationBarWrapper(
              items: destinations,
              onTap: _changePage,
            ),
          ),
        );
      },
    );
  }
}

class _BottomNavigationBarWrapper extends StatefulWidget {
  final List<SalomonBottomBarItem> items;
  final ValueChanged<int>? onTap;

  const _BottomNavigationBarWrapper({Key? key, required this.items, this.onTap})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _BottomNavigationBarWrapperState();
}

class _BottomNavigationBarWrapperState
    extends State<_BottomNavigationBarWrapper> {
  late int _currentIndex;

  @override
  void initState() {
    _currentIndex = 0;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      child: SalomonBottomBar(
        selectedItemColor: Theme.of(context).colorScheme.onSurface,
        itemPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
        currentIndex: _currentIndex,
        items: widget.items,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          widget.onTap?.call(index);
        },
      ),
    );
  }
}
