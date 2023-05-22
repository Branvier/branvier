// ignore_for_file: null_check_on_nullable_type_parameter

part of '/branvier.dart';

extension DateTimeFormatting on DateTime {
  /// Unix timestamp in seconds.
  int get secondsSinceEpoch => millisecondsSinceEpoch * 1000;

  /// Format this [DateTime] to a customized format.
  ///
  /// 'hh:mm:ss' -> 07:13:01
  /// 'dd/MM/yyyy' -> 04/05/2001
  String format(String pattern) {
    final replacements = {
      'yyyy': '$year',
      'yy': year.toString().padLeft(2, '0').substring(2),
      'MM': month.toString().padLeft(2, '0'),
      'M': '$month',
      'dd': day.toString().padLeft(2, '0'),
      'd': '$day',
      'HH': hour.toString().padLeft(2, '0'),
      'H': '$hour',
      'mm': minute.toString().padLeft(2, '0'),
      'm': '$minute',
      'ss': second.toString().padLeft(2, '0'),
      's': '$second',
    };

    String replacePattern(String pattern) {
      return pattern.replaceAllMapped(RegExp(r'(\b\w+\b)'), (match) {
        final key = match.group(0);
        return replacements[key] ?? key!;
      });
    }

    return replacePattern(pattern);
  }
}

extension DurationExt on Duration {
  ///Transforms this Duration into a delayed function.
  @Deprecated('User .delay instead, for clarity.')
  Future<void> call() => Future.delayed(this);

  ///Returns [value] after this Duration.
  @Deprecated('User .delay.then() instead, for clarity.')
  Future<T> set<T>(T value) => Future.delayed(this, () => value);
}
