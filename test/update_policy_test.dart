import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:muslim/services/play_update.dart';

void main() {
  test('min build blocks only older installs while force is on', () {
    expect(
      installedBuildIsTooOld(force: true, minBuild: 8, installedBuild: 7),
      isTrue,
    );
    expect(
      installedBuildIsTooOld(force: true, minBuild: 8, installedBuild: 8),
      isFalse,
    );
    expect(
      installedBuildIsTooOld(force: false, minBuild: 8, installedBuild: 1),
      isFalse,
    );
    expect(
      installedBuildIsTooOld(force: true, minBuild: 0, installedBuild: 1),
      isFalse,
    );
  });

  test('Play force update follows availability', () {
    expect(
      playUpdateIsRequired(
        force: true,
        availability: UpdateAvailability.updateAvailable,
      ),
      isTrue,
    );
    expect(
      playUpdateIsRequired(
        force: true,
        availability: UpdateAvailability.developerTriggeredUpdateInProgress,
      ),
      isTrue,
    );
    expect(
      playUpdateIsRequired(
        force: true,
        availability: UpdateAvailability.updateNotAvailable,
      ),
      isFalse,
    );
    expect(
      playUpdateIsRequired(
        force: false,
        availability: UpdateAvailability.updateAvailable,
      ),
      isFalse,
    );
  });
}
