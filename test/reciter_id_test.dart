import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:muslim/services/reciter_id.dart';
import 'package:muslim/services/reciter_match.dart';

void main() {
  test('nearest voiceprint wins', () {
    final voices = [
      const ReciterVoice(
        reciterId: 1,
        recordingId: 10,
        nameAr: 'أ',
        nameEn: 'A',
        recordingName: 'حفص',
      ),
      const ReciterVoice(
        reciterId: 2,
        recordingId: 20,
        nameAr: 'ب',
        nameEn: 'B',
        recordingName: 'ورش',
      ),
    ];
    final embeddings = Float32List.fromList([1, 0, 0, 1]);
    final matches = rankReciters(
      Float32List.fromList([0.6, 0.8]),
      embeddings,
      voices,
    );
    expect(matches.first.voice.reciterId, 2);
    expect(matches.first.score, closeTo(0.8, 1e-6));
    expect(matches[1].voice.reciterId, 1);
  });

  test('silence matches nobody', () {
    final matches = rankReciters(
      Float32List.fromList([0, 0]),
      Float32List.fromList([1, 0]),
      const [
        ReciterVoice(
          reciterId: 1,
          recordingId: 1,
          nameAr: 'أ',
          nameEn: 'A',
          recordingName: '',
        ),
      ],
    );
    expect(matches, isEmpty);
  });

  test('hafs voices map to verse audio, warsh does not', () {
    const hafs = ReciterVoice(
      reciterId: 118,
      recordingId: 1,
      nameAr: 'الحصري',
      nameEn: 'Husary',
      recordingName: 'حفص عن عاصم - مرتل',
    );
    const warsh = ReciterVoice(
      reciterId: 118,
      recordingId: 2,
      nameAr: 'الحصري',
      nameEn: 'Husary',
      recordingName: 'ورش عن نافع - مرتل',
    );
    expect(hafs.ayahReciter?.id, 'ar.husary');
    expect(warsh.ayahReciter, isNull);
  });

  test('30s clip is two windows, under 20s is none', () {
    expect(ReciterId.audioWindows(Float32List(15 * 16000)), isEmpty);
    expect(ReciterId.audioWindows(Float32List(20 * 16000)), hasLength(1));
    final half = ReciterId.audioWindows(Float32List(25 * 16000));
    expect(half, hasLength(1));
    expect(half.first.length, 20 * 16000);
    final windows = ReciterId.audioWindows(Float32List(30 * 16000));
    expect(windows, hasLength(2));
    expect(windows.first.length, 20 * 16000);
    expect(windows.last.length, 20 * 16000);
  });

  test('wav pcm comes back as 16 kHz mono', () {
    final data = Uint8List(4);
    final samples = ByteData.sublistView(data);
    samples.setInt16(0, 1000, Endian.little);
    samples.setInt16(2, -1000, Endian.little);
    final fmt = ByteData(16);
    fmt.setUint16(0, 1, Endian.little);
    fmt.setUint16(2, 1, Endian.little);
    fmt.setUint32(4, 8000, Endian.little);
    fmt.setUint32(8, 16000, Endian.little);
    fmt.setUint16(12, 2, Endian.little);
    fmt.setUint16(14, 16, Endian.little);
    Uint8List u32(int n) {
      final b = ByteData(4)..setUint32(0, n, Endian.little);
      return b.buffer.asUint8List();
    }

    final body = BytesBuilder()
      ..add('fmt '.codeUnits)
      ..add(u32(16))
      ..add(fmt.buffer.asUint8List())
      ..add('data'.codeUnits)
      ..add(u32(data.length))
      ..add(data);
    final wav = BytesBuilder()
      ..add('RIFF'.codeUnits)
      ..add(u32(4 + body.length))
      ..add('WAVE'.codeUnits)
      ..add(body.toBytes());
    expect(pcm16kFromWav(wav.toBytes()).length, 8);
  });
}
