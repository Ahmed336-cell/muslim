import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/hisn.dart';

final class HisnState extends Equatable {
  const HisnState({this.book, this.failed = false, this.query = ''});

  final HisnBook? book;
  final bool failed;
  final String query;

  List<HisnChapter> get results => book?.search(query) ?? const [];

  @override
  List<Object?> get props => [book, failed, query];
}

class HisnCubit extends Cubit<HisnState> {
  HisnCubit({required this._repository}) : super(const HisnState());

  final HisnRepository _repository;

  Future<void> load() async {
    if (state.book != null) return;
    try {
      emit(HisnState(book: await _repository.load(), query: state.query));
    } catch (_) {
      emit(HisnState(failed: true, query: state.query));
    }
  }

  void search(String query) =>
      emit(HisnState(book: state.book, failed: state.failed, query: query));
}
