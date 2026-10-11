import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim/bloc/ruqyah/ruqyah_bloc.dart';
import 'package:muslim/services/islamic_api.dart';

const _entry = RuqyahEntry(id: 1, title: 'Al-Fatiha 1:1-7', arabic: 'بِسْمِ');

class _FakeApi extends IslamicApi {
  _FakeApi() : super(apiKey: 'test');

  final calls = <String>[];
  Completer<void>? gate;

  @override
  Future<List<RuqyahEntry>> fetchRuqyah(
    RuqyahProgram program,
    RuqyahSource source,
    String lang,
  ) async {
    calls.add('${program.name}/${source.name}/$lang');
    await gate?.future;
    if (program == RuqyahProgram.long) {
      throw const ApiException('Invalid program');
    }
    return const [_entry];
  }

  @override
  Future<List<RuqyahTopic>> fetchRuqyahTopics(String lang) async {
    calls.add('topics/$lang');
    return const [
      RuqyahTopic(slug: 'evil-eye-and-envy', title: 'Evil Eye', count: 18),
    ];
  }

  @override
  Future<List<RuqyahArticle>> fetchRuqyahArticles(
    String topic,
    String lang,
  ) async {
    calls.add('articles/$topic/$lang');
    return const [];
  }
}

void main() {
  test('parses entries with string ids', () {
    final e = RuqyahEntry.fromJson({
      'id': '3',
      'title': 'Muslim : 2708',
      'arabic': 'أَعُوذُ',
      'translation': 'I seek refuge…',
      'transliteration': null,
    });
    expect(e.id, 3);
    expect(e.transliteration, '');
  });

  test('flattens topic categories into topics with counts', () {
    final topics = RuqyahTopic.listFromJson([
      {
        'title': 'Black Magic (Sihr)',
        'subcategories': [
          {
            'subcategory': 'Black Magic (Sihr)',
            'subcategory-slug': 'black-magic-sihr',
            'ruqyah': [
              {'id': '1', 'title': 'a'},
              {'id': '2', 'title': 'b'},
            ],
          },
        ],
      },
    ]);
    expect(topics.single.slug, 'black-magic-sihr');
    expect(topics.single.count, 2);
  });

  test('article drops empty blocks, unknown types become text', () {
    final a = RuqyahArticle.fromJson({
      'sub_id': 15,
      'id': 1,
      'title': 'Existence',
      'section_title': 'Existence',
      'content': [
        {'type': 'header', 'content': 'Types'},
        {'type': 'arabic', 'content': '  '},
        {'type': 'quote', 'content': 'x'},
      ],
    });
    expect(a.id, 1);
    expect(a.blocks.map((b) => b.type), [BlockType.header, BlockType.text]);
  });

  test('program audio urls', () {
    expect(
      RuqyahProgram.medium.audioUrl.toString(),
      'https://islamicapi.com/audio/ruqyah/total_med_ruqyah.mp3',
    );
  });

  group('RuqyahBloc', () {
    late _FakeApi api;
    setUp(() => api = _FakeApi());

    blocTest<RuqyahBloc, RuqyahState>(
      'caches each program/source; switching back does not refetch',
      build: () => RuqyahBloc(api: api),
      act: (b) async {
        b.add(const RuqyahRecitationRequested());
        await Future<void>.delayed(Duration.zero);
        b.add(const RuqyahRecitationRequested(source: RuqyahSource.sunnah));
        await Future<void>.delayed(Duration.zero);
        b.add(const RuqyahRecitationRequested(source: RuqyahSource.quran));
      },
      verify: (b) {
        expect(api.calls, ['brief/quran/en', 'brief/sunnah/en']);
        expect(b.state.current.data, [_entry]);
      },
    );

    blocTest<RuqyahBloc, RuqyahState>(
      'failure is retryable',
      build: () => RuqyahBloc(api: api),
      act: (b) async {
        b.add(const RuqyahRecitationRequested(program: RuqyahProgram.long));
        await Future<void>.delayed(Duration.zero);
        b.add(const RuqyahRecitationRequested());
      },
      verify: (b) {
        expect(api.calls, ['long/quran/en', 'long/quran/en']);
        expect(b.state.current.error, 'Invalid program');
      },
    );

    blocTest<RuqyahBloc, RuqyahState>(
      'response for an old language is dropped after switching',
      build: () => RuqyahBloc(api: api..gate = Completer<void>()),
      act: (b) async {
        b.add(const RuqyahRecitationRequested());
        await Future<void>.delayed(Duration.zero);
        b.add(const RuqyahLanguageChanged('ar'));
        await Future<void>.delayed(Duration.zero);
        api.gate!.complete();
        await Future<void>.delayed(Duration.zero);
      },
      verify: (b) {
        expect(b.state.language, 'ar');
        expect(
          api.calls,
          containsAll(['brief/quran/en', 'brief/quran/ar', 'topics/ar']),
        );
        expect(b.state.current.data, [_entry]);
      },
    );
  });
}
