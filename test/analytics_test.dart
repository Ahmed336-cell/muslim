import 'package:flutter_test/flutter_test.dart';
import 'package:muslim/services/analytics.dart';
import 'package:muslim/widgets/features.dart';

void main() {
  test('feature routes map onto the feature list', () {
    expect(featureFromRoute(null), isNull);
    expect(featureFromRoute(''), isNull);
    expect(featureFromRoute('/'), isNull);
    expect(featureFromRoute('quran'), 'quran');
    expect(featureFromRoute('azkar:morning'), 'azkar');
    expect(featureFromRoute('azkar:sleep'), 'azkar');
    for (final feature in Feature.values) {
      expect(featureFromRoute(feature.name), feature.name);
    }
  });

  test('tracking before init does nothing', () {
    Analytics.feature('quran');
    Analytics.feature('');
  });
}
