import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/islamic_api.dart';
import '../../services/tawashih.dart';

final class TawashihTracksState extends Equatable {
  const TawashihTracksState({this.tracks, this.error});

  final List<TawashihTrack>? tracks;
  final String? error;

  @override
  List<Object?> get props => [tracks, error];
}

class TawashihTracksCubit extends Cubit<TawashihTracksState> {
  TawashihTracksCubit({required this.api, required this.munshid})
    : super(const TawashihTracksState()) {
    load();
  }

  final TawashihApi api;
  final TawashihMunshid munshid;

  Future<void> load() async {
    emit(const TawashihTracksState());
    try {
      final tracks = await api.tracks(munshid);
      emit(TawashihTracksState(tracks: tracks));
    } catch (_) {
      emit(const TawashihTracksState(error: ApiException.network));
    }
  }
}
