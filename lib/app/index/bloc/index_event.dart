part of 'index_bloc.dart';

abstract class IndexEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class IndexFetched extends IndexEvent {}
