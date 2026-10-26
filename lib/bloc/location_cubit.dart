import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/location.dart';
import 'settings_cubit.dart';

final class LocateState extends Equatable {
  const LocateState({this.locating = false, this.error, this.grantedNow = false});

  final bool locating;

  /// A [LocationException] code from the last attempt.
  final String? error;

  /// True when this attempt is what first obtained permission.
  final bool grantedNow;

  @override
  List<Object?> get props => [locating, error, grantedNow];
}

/// Finds the device's position and hands it to [SettingsCubit].
class LocationCubit extends Cubit<LocateState> {
  LocationCubit({required this._service, required this._settings})
    : super(const LocateState());

  final LocationService _service;
  final SettingsCubit _settings;

  /// [silent] attempts (the refresh on launch) never surface errors.
  Future<void> locate({bool silent = false}) async {
    if (state.locating) return;
    final before = await _service.access();
    emit(const LocateState(locating: true));
    try {
      final (lat, lon) = await _service.current();
      _settings.setLocation(lat, lon);
      if (!isClosed) {
        emit(
          LocateState(
            grantedNow:
                before == LocationAccess.denied ||
                before == LocationAccess.blocked ||
                before == LocationAccess.disabled,
          ),
        );
      }
    } on LocationException catch (e) {
      if (!isClosed) emit(LocateState(error: silent ? null : e.code));
    } catch (_) {
      if (!isClosed) {
        emit(LocateState(error: silent ? null : LocationException.failed));
      }
    }
  }

  /// The tune sheet has been shown for [LocateState.grantedNow].
  void acknowledgeGrant() {
    if (isClosed || !state.grantedNow) return;
    emit(const LocateState());
  }

  /// Picks up a new position on launch when reading by location.
  void refresh() {
    if (_settings.state.usesLocation) locate(silent: true);
  }

  Future<void> openSettings() => _service.openSettings();
}
