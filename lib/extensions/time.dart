// ignore_for_file: null_check_on_nullable_type_parameter

part of '/branvier.dart';

extension DateTimeExt on DateTime {
  int get secondsSinceEpoch => millisecondsSinceEpoch * 1000;
}

extension DurationExt on Duration {
  ///Transforms this Duration into a delayed function.
  @Deprecated('User .delay instead, for clarity.')
  Future<void> call() => Future.delayed(this);

  ///Returns [value] after this Duration.
  @Deprecated('User .delay.then() instead, for clarity.')
  Future<T> set<T>(T value) => Future.delayed(this, () => value);

}
