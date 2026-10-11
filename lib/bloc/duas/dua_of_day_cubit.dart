import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/islamic_api.dart';

final class DuaOfDayState extends Equatable {
  const DuaOfDayState({this.dua, this.loading = false, this.error});

  final Dua? dua;
  final bool loading;
  final String? error;

  @override
  List<Object?> get props => [dua, loading, error];
}

class DuaOfDayCubit extends Cubit<DuaOfDayState> {
  DuaOfDayCubit({required this._api}) : super(const DuaOfDayState());

  final IslamicApi _api;

  /// Size of the dataset at the time of writing; ids are 1…N.
  static const _knownCount = 1001;

  static int idFor(DateTime d) {
    final day = DateTime.utc(
      d.year,
      d.month,
      d.day,
    ).difference(DateTime.utc(2000)).inDays;
    return day * 7 % _knownCount + 1;
  }

  Future<void> load({required DateTime day, String language = 'en'}) async {
    emit(DuaOfDayState(dua: state.dua, loading: true));
    try {
      final dua = await _api
          .fetchDua(language, id: idFor(day))
          .catchError(
            (_) => _api.fetchDua(language),
            test: (e) => e is ApiException && e.message.contains('not found'),
          );
      emit(DuaOfDayState(dua: dua));
    } on ApiException catch (e) {
      emit(DuaOfDayState(dua: state.dua, error: e.message));
    } catch (_) {
      emit(DuaOfDayState(dua: state.dua, error: ApiException.badResponse));
    }
  }
}
