part of 'export.dart';

extension DateTimeExt on DateTime {
  int get secondsSinceEpoch => millisecondsSinceEpoch * 1000;
}

extension FutureNullable<T> on Future<T?> {
  ///Marks as non nullable.
  Future<T> get non async => (await this)!;
}

extension FutureExt<T> on Future<T> {
  ///Same as [then], returns null on error.
  Future<R> thenTry<R>(FutureOr<R> Function(T value) function) {
    return then(function, onError: () => null);
  }
}

extension TypeExt<T> on T Function() {
  R then<R>(R Function(T value) action) => action(this());
}

extension DurationExt on Duration {
  Future<T> then<T>(Getter<T>? function) => Future.delayed(this, function);
}
