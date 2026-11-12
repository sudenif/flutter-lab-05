import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/content.dart';
import '../../../../data/repositories/content_repository_interface.dart';

part 'content_event.dart';
part 'content_state.dart';

class ContentBloc extends Bloc<ContentEvent, ContentState> {
  ContentBloc(this.contentRepository) : super(ContentInitial()) {
    on<ContentLoad>(_load);
  }
  final ContentRepositoryInterface contentRepository;

  Future<void> _load(ContentLoad event, Emitter<ContentState> emit) async {
    if (state is ContentLoadInProgress) return;
    emit(ContentLoadInProgress());
    try {
      final content = await contentRepository.getContentById(event.id);
      emit(ContentLoadSuccess(content: content));
    } catch (exception, stackTrace) {
      addError(exception, stackTrace);
      emit(ContentLoadFailure(exception: exception));
    }
  }
}
