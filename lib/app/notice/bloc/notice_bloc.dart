import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part './notice_event.dart';

part './notice_state.dart';

class NoticeBloc extends Bloc<NoticeEvent, NoticeState> {
  NoticeBloc() : super(NoticeState(status: NoticeStatus.initial));
}