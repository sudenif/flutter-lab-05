part of 'content_bloc.dart';

sealed class ContentEvent extends Equatable {
  const ContentEvent();
}

final class ContentLoad extends ContentEvent {
  const ContentLoad(this.id);
  final int id;
  @override
  List<Object?> get props => [id];
}
