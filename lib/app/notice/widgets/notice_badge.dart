import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/notice/bloc/notice_count_bloc.dart';

class NoticeBadge extends StatelessWidget {
  final Widget? child;

  const NoticeBadge({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (child == null) {
      return SizedBox.shrink();
    }
    return BlocBuilder<NoticeCountBloc, NoticeCountState>(
      builder: (context, state) {
        if (state.notice.count() > 0) {
          return Badge(
            child: child,
          );
        }
        return child!;
      },
    );
  }
}
