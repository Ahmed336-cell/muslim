import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/islamic_api.dart' show ApiException;
import '../../services/recitation.dart';

final class RecitersState extends Equatable {
  const RecitersState({this.reciters, this.error});

  final List<Reciter>? reciters;

  /// An [ApiException] message.
  final String? error;

  bool get loading => reciters == null && error == null;

  @override
  List<Object?> get props => [reciters, error];
}

class RecitersCubit extends Cubit<RecitersState> {
  RecitersCubit({required this._api, required this._language})
    : super(const RecitersState()) {
    load();
  }

  final RecitersApi _api;
  final String _language;

  Future<void> load() async {
    emit(const RecitersState());
    try {
      emit(RecitersState(reciters: await _api.fetch(_language)));
    } on ApiException catch (e) {
      emit(RecitersState(error: e.message));
    } catch (_) {
      emit(const RecitersState(error: ApiException.badResponse));
    }
  }
}
