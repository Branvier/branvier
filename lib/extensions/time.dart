// ignore_for_file: null_check_on_nullable_type_parameter

part of '/branvier.dart';

extension DateTimeExt on DateTime {
  int get secondsSinceEpoch => millisecondsSinceEpoch * 1000;
}

extension DurationExt on Duration {
  ///Transforms [this] Duration into a delayed function.
  Future<void> call() => Future.delayed(this);

  ///Returns [value] after [this] Duration.
  Future<T> set<T>(T value) => Future.delayed(this, () => value);

  ///Calls [function] after [this] Duration.
  Future<T> then<T>(Getter<T>? function) => Future.delayed(this, function);
}

extension FutureNullable<T> on Future<T?> {
  ///Returns [T] as non-nullable. On null/error fallbacks [value].
  Future<T> or([T? value]) async {
    return then((r) => r ?? value!, onError: (e) => value!);
  }

  ///Returns [T] as non-nullable. On null/error fallbacks [or].
  Future<R> thenOr<R>(Then<T, R> action, {R? or}) async {
    return then((r) => r != null ? (action(r)) : or!, onError: (e) => or!);
  }

  ///Returns [action] if [T] is non-null, else [null].
  Future<R?> thenTry<R>(Then<T, R> action) async {
    return then((r) => r != null ? action(r) : null, onError: (e) => null);
  }
}

extension TypeNullable<T> on T? {
  ///Marks [T] as non-nullable. On null/error fallbacks [value].
  T or([T? value]) => this ?? value!;

  ///Returns [onNonNull] if [T] is non-null, else [null].
  R? non<R>(GetOn<T, R> onNonNull) => this != null ? onNonNull(this!) : null;
}
