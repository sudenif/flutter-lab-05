part of 'content_bloc.dart';

sealed class ContentState extends Equatable {
  const ContentState();
  @override
  List<Object?> get props => [];
}

final class ContentInitial extends ContentState {}

final class ContentLoadInProgress extends ContentState {}

final class ContentLoadSuccess extends ContentState {
  const ContentLoadSuccess({required this.content});
  final Content content;
  @override
  List<Object?> get props => [content];
}

final class ContentLoadFailure extends ContentState {
  const ContentLoadFailure({required this.exception});
  final Object exception;
  @override
  List<Object?> get props => [exception.toString()];
}
