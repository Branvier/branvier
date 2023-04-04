part of '/branvier.dart';

extension StrinExt on String {
  /// Capitalizes all words. ex: your name => Your Name.
  String get capitalized => split(' ').map((e) => e.capitalizeFirst).join(' ');

  /// Uppercase first letter inside string and let the others lowercase.
  /// Example: your name => Your name.
  String get capitalizeFirst {
    if (isEmpty) return '';
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  String get lastPascalCaseWord {
    final pattern = RegExp(r'[A-Z][a-z0-9]*(?=\b)');
    final matches = pattern.allMatches(this);
    if (matches.isNotEmpty) {
      final match = matches.last;
      return substring(match.start, match.end);
    }
    return this;
  }

  ///All sub words between [pattern].
  ///Ex: 'a.b.c' -> ['a.b.c','a.b','a'].
  List<String> subWords(Pattern pattern) {
    final words = split(pattern);
    final nestedStrings = <String>[];

    for (var i = 0; i < words.length; i++) {
      final currentNestedString = words.sublist(0, i + 1).join('.');
      nestedStrings.add(currentNestedString);
    }

    return nestedStrings.reversed.toList();
  } //tested [string_test]

  ///Remove all the chars in [charsToRemove].
  String removeChars(String charsToRemove) {
    var result = this;
    charsToRemove.split('').forEach((char) {
      result = result.replaceAll(char, '');
    });
    return result;
  }
}
