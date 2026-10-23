import 'dart:convert';

import 'package:http/http.dart' as http;

/// Aladhan Qibla Direction API.
/// https://aladhan.com/qibla-api
/// GET https://api.aladhan.com/v1/qibla/:latitude/:longitude
class QiblaApi {
  QiblaApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Degrees clockwise from true north. Null when the request fails.
  Future<double?> direction(double lat, double lon) async {
    final uri = Uri.https('api.aladhan.com', '/v1/qibla/$lat/$lon');
    try {
      final res = await _client.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      final body = jsonDecode(res.body);
      if (body is! Map) return null;
      final data = body['data'];
      if (data is! Map) return null;
      final direction = data['direction'];
      if (direction is! num) return null;
      return direction.toDouble();
    } catch (_) {
      return null;
    }
  }
}
