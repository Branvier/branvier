import 'package:branvier/branvier.dart';
import 'package:test/test.dart';

void main() {
  group('toLocale()', () {
    test('should return Locale _ object with two parts', () {
      final locale = 'en_US'.toLocale();
      expect(locale.languageCode, equals('en'));
      expect(locale.countryCode, equals('US'));
    });

    test('should return Locale | object with two parts', () {
      final locale = 'en|US'.toLocale();
      expect(locale.languageCode, equals('en'));
      expect(locale.countryCode, equals('US'));
    });

    test('should return Locale . object with two parts', () {
      final locale = 'en.US'.toLocale();
      expect(locale.languageCode, equals('en'));
      expect(locale.countryCode, equals('US'));
    });

    test('should return Locale - object with two parts', () {
      final locale = 'en-US'.toLocale();
      expect(locale.languageCode, equals('en'));
      expect(locale.countryCode, equals('US'));
    });

    test('should return Locale /s object with two parts', () {
      final locale = 'en US'.toLocale();
      expect(locale.languageCode, equals('en'));
      expect(locale.countryCode, equals('US'));
    });

    test('should return Locale / object with two parts', () {
      final locale = 'en/US'.toLocale();
      expect(locale.languageCode, equals('en'));
      expect(locale.countryCode, equals('US'));
    });

    test('should return Locale + object with two parts', () {
      final locale = 'en/US'.toLocale();
      expect(locale.languageCode, equals('en'));
      expect(locale.countryCode, equals('US'));
    });

    test('should return Locale slash object with two parts ', () {
      final locale = r'en\US'.toLocale();
      expect(locale.languageCode, equals('en'));
      expect(locale.countryCode, equals('US'));
    });

    test('should return Locale object with one part', () {
      final locale = 'fr'.toLocale();
      expect(locale.languageCode, equals('fr'));
      expect(locale.countryCode, isNull);
    });
  });
}
