import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venera/components/components.dart';
import 'package:venera/foundation/favorites_meta.dart';
import 'package:venera/utils/translations.dart';

// A `language:` tag used to be classified as metadata and filtered out of the
// displayed tag list, but no view ever rendered it as metadata — so it vanished
// entirely (issue #288). These tests pin that it stays a content tag.

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(AppTranslation.init);

  test('a language tag is classified as a content tag, not extra metadata', () {
    expect(classifyTag('language:chinese').bucket, TagBucket.tag);
    expect(classifyTag('Languages:japanese').bucket, TagBucket.tag);
    expect(classifyTag('lang:korean').bucket, TagBucket.tag);
    expect(classifyTag('语言:中文').bucket, TagBucket.tag);
    expect(classifyTag('語言:中文').bucket, TagBucket.tag);
  });

  test('a language tag keeps its value once classified', () {
    expect(classifyTag('language:chinese').value, 'chinese');
  });

  test('neighbouring metadata prefixes still route to extra metadata', () {
    expect(classifyTag('uploader:someone').bucket, TagBucket.extra);
    expect(classifyTag('source:somewhere').bucket, TagBucket.extra);
  });

  test('favoriting keeps a language tag in the tags bucket', () {
    final buckets = splitFavoriteTags([
      'language:chinese',
      'female:sole male',
      'uploader:someone',
    ]);
    expect(buckets.tags, containsAll(['chinese', 'sole male']));
    expect(buckets.extraMeta.containsKey('language'), isFalse);
    expect(buckets.extraMeta['uploader'], 'someone');
  });

  testWidgets('a comic tile lists a language tag among its tags', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 220,
            width: 420,
            child: ComicDescription(
              title: 'Comic',
              subtitle: '',
              description: '',
              enableTranslate: false,
              tags: ['language:chinese', 'female:sole male'],
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('chinese'), findsOneWidget);
  });
}
