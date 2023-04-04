import 'package:branvier/branvier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('strings', () {
    test('subWords', () {
      const words = '1.2.3.4.5';
      final subwords = words.subWords('.');

      expect(subwords.length, 5);
      expect(subwords.first, words);
      expect(subwords.last, '1');
    });

    String tr() {
      const words = '1.2.3.4.5';
      final subwords = words.subWords('.');

      for (final word in subwords) {
        final translation = word == '';
        if (translation) return word;
      }
      return words;
    }

    test('trs', () {
      expect(tr(), '1.2.3.4.5');
    });

  });
}
