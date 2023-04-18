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

/// An instance of text to be re-cased.
class ReCase {
  ReCase(String text) {
    originalText = text;
    _words = _groupIntoWords(text);
  }
  final RegExp _upperAlphaRegex = RegExp('[A-Z]');

  final symbolSet = {' ', '.', '/', '_', r'\', '-'};

  late String originalText;
  late List<String> _words;

  List<String> _groupIntoWords(String text) {
    final sb = StringBuffer();
    final words = <String>[];
    final isAllCaps = text.toUpperCase() == text;

    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      final nextChar = i + 1 == text.length ? null : text[i + 1];

      if (symbolSet.contains(char)) {
        continue;
      }

      sb.write(char);

      final isEndOfWord = nextChar == null ||
          (_upperAlphaRegex.hasMatch(nextChar) && !isAllCaps) ||
          symbolSet.contains(nextChar);

      if (isEndOfWord) {
        words.add(sb.toString());
        sb.clear();
      }
    }

    return words;
  }

  /// camelCase
  String get camelCase => _getCamelCase();

  /// CONSTANT_CASE
  String get constantCase => _getConstantCase();

  /// Sentence case
  String get sentenceCase => _getSentenceCase();

  /// snake_case
  String get snakeCase => _getSnakeCase();

  /// dot.case
  String get dotCase => _getSnakeCase(separator: '.');

  /// param-case
  String get paramCase => _getSnakeCase(separator: '-');

  /// path/case
  String get pathCase => _getSnakeCase(separator: '/');

  /// PascalCase
  String get pascalCase => _getPascalCase();

  /// Header-Case
  String get headerCase => _getPascalCase(separator: '-');

  /// Title Case
  String get titleCase => _getPascalCase(separator: ' ');

  String _getCamelCase({String separator = ''}) {
    final words = _words.map(_upperCaseFirstLetter).toList();
    if (_words.isNotEmpty) {
      words[0] = words[0].toLowerCase();
    }

    return words.join(separator);
  }

  String _getConstantCase({String separator = '_'}) {
    final words = _words.map((word) => word.toUpperCase()).toList();

    return words.join(separator);
  }

  String _getPascalCase({String separator = ''}) {
    final words = _words.map(_upperCaseFirstLetter).toList();

    return words.join(separator);
  }

  String _getSentenceCase({String separator = ' '}) {
    final words = _words.map((word) => word.toLowerCase()).toList();
    if (_words.isNotEmpty) {
      words[0] = _upperCaseFirstLetter(words[0]);
    }

    return words.join(separator);
  }

  String _getSnakeCase({String separator = '_'}) {
    final words = _words.map((word) => word.toLowerCase()).toList();

    return words.join(separator);
  }

  String _upperCaseFirstLetter(String word) {
    return '${word.substring(0, 1).toUpperCase()}${word.substring(1).toLowerCase()}';
  }
}

extension StringReCase on String {
  /// camelCase
  String get camelCase => ReCase(this).camelCase;

  /// CONSTANT_CASE
  String get constantCase => ReCase(this).constantCase;

  /// Sentence case
  String get sentenceCase => ReCase(this).sentenceCase;

  /// snake_case
  String get snakeCase => ReCase(this).snakeCase;

  /// dot.case
  String get dotCase => ReCase(this).dotCase;

  /// param-case
  String get paramCase => ReCase(this).paramCase;

  /// path/case
  String get pathCase => ReCase(this).pathCase;

  /// PascalCase
  String get pascalCase => ReCase(this).pascalCase;

  /// Header-Case
  String get headerCase => ReCase(this).headerCase;

  /// Title Case
  String get titleCase => ReCase(this).titleCase;
}
