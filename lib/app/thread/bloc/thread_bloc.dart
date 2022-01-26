import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/common/log.dart';
import 'package:keylol_flutter/app/thread/models/thread.dart';

part './thread_event.dart';

part './thread_state.dart';

class ThreadBloc extends Bloc<ThreadEvent, ThreadState> {
  final _logger = Log();
  final Dio client;
  final String tid;

  ThreadBloc({
    required this.client,
    required this.tid,
  }) : super(ThreadState(status: ThreadStatus.initial));
}
