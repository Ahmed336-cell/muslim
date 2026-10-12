import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/islamic_api.dart' show ApiException;
import '../../services/mushaf_pages.dart';
import '../../services/quran.dart';

final class PageLoad extends Equatable {
  const PageLoad({this.page, this.error});

  final MushafPage? page;
  final String? error;

  bool get loading => page == null && error == null;

  @override
  List<Object?> get props => [page, error];
}

final class MushafState extends Equatable {
  const MushafState({required this.mushaf, this.pages = const {}});

  final Mushaf mushaf;
  final Map<int, PageLoad> pages;

  @override
  List<Object?> get props => [mushaf, pages];
}

/// Pages of the mushaf, loaded around the one being read.
class MushafCubit extends Cubit<MushafState> {
  MushafCubit({required this._api, required Mushaf mushaf})
    : super(MushafState(mushaf: mushaf));

  final QuranApi _api;

  /// Loads [page] and the pages either side, so swiping feels instant.
  void visit(int page) {
    final ready = <int, PageLoad>{};
    for (final p in [page, page + 1, page - 1]) {
      if (p < 1 || p > pageCount || state.pages[p]?.page != null) continue;
      final now = _api.pageNow(p, state.mushaf);
      if (now != null) ready[p] = PageLoad(page: now);
    }
    if (ready.isNotEmpty) {
      emit(
        MushafState(mushaf: state.mushaf, pages: {...state.pages, ...ready}),
      );
    }
    for (final p in [page, page + 1, page - 1]) {
      if (p >= 1 && p <= pageCount) _load(p);
    }
  }

  void setMushaf(Mushaf mushaf, {required int page}) {
    if (mushaf == state.mushaf) return;
    emit(MushafState(mushaf: mushaf));
    visit(page);
  }

  Future<void> _load(int page) async {
    final mushaf = state.mushaf;
    final current = state.pages[page];
    if (current != null && current.error == null) return;
    _put(page, const PageLoad());

    PageLoad result;
    try {
      result = PageLoad(page: await _api.fetchPage(page, mushaf));
    } on ApiException catch (e) {
      result = PageLoad(error: e.message);
    } catch (_) {
      result = const PageLoad(error: ApiException.badResponse);
    }
    if (!isClosed && state.mushaf == mushaf) _put(page, result);
  }

  void _put(int page, PageLoad value) => emit(
    MushafState(mushaf: state.mushaf, pages: {...state.pages, page: value}),
  );
}
