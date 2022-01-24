import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/forum/models/cat.dart';
import 'package:keylol_flutter/common/log.dart';

part 'forum_index_event.dart';

part 'forum_index_state.dart';

class ForumIndexBloc extends Bloc<ForumIndexEvent, ForumIndexState> {
  final _logger = Log();
  final Dio client;

  ForumIndexBloc({required this.client})
      : super(ForumIndexState(status: ForumIndexStatus.initial)) {
    on<ForumIndexFetched>(_onFetched);
    on<ForumIndexSelected>(_onSelected);
  }

  Future<void> _onFetched(
    ForumIndexEvent event,
    Emitter<ForumIndexState> emit,
  ) async {
    try {
      final cats = await _fetchIndex();
      emit(state.copyWith(status: ForumIndexStatus.success, cats: cats));
    } catch (error) {
      _logger.e('获取版块索引错误', error);
      emit(state.copyWith(status: ForumIndexStatus.failure));
    }
  }

  Future<List<Cat>> _fetchIndex() async {
    var res = await client.get("/api/mobile/index.php",
        queryParameters: {'module': 'forumindex'});

    var variables = res.data['Variables'];

    var forumMap = new HashMap<String, CatForum>();
    for (var forumJson in (variables['forumlist'] as List<dynamic>)) {
      final forum = CatForum.fromJson(forumJson);
      forumMap[forum.fid] = forum;
    }

    if (res.data['Message'] != null) {
      return Future.error(res.data['Message']!['messagestr']);
    }
    return (variables['catlist'] as List<dynamic>).map((catJson) {
      final cat = Cat.fromJson(catJson);
      List<CatForum> forums = (catJson['forums'] as List<dynamic>)
          .map((fid) => forumMap[fid]!)
          .toList();
      cat.forums = forums;
      return cat;
    }).toList();
  }

  Future<void> _onSelected(
    ForumIndexSelected event,
    Emitter<ForumIndexState> emit,
  ) async {
    final selected = event.selected;
    emit(state.copyWith(selected: selected));
  }
}
