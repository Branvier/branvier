part of '/branvier.dart';

extension MapExt<K, V> on Map<K, V?> {
  MapEntry<K, V?> get first => entries.first;
  MapEntry<K, V?> get second => entries.second;
  MapEntry<K, V?> get third => entries.third;
  MapEntry<K, V?> get antepenult => entries.antepenult;
  MapEntry<K, V?> get penult => entries.penult;
  MapEntry<K, V?> get last => entries.last;

  ///Sames map, same keys, no nullables.
  Map<K, V> get noNulls => Map<K, V>.from(this..removeNulls());

  ///Deeply remove all null values from this [Map].
  void removeNulls() {
    removeWhere((key, value) {
      if (value == null) return true;
      if (value is Map) value.removeNulls();
      return false;
    });
  }

  ///Creates a new map with only the typed value.
  Map<K, T> only<T>() {
    final map = <K, T>{};
    forEach((key, value) {
      if (value is T) map[key] = value;
    });
    return map;
  }
}

extension ScopeFunctionsForObject<T extends Object> on T {
  /// Calls the specified function [operation] with `this` value as its argument and returns its result.
  R let<R>(R operation(T self)) {
    return operation(this);
  }

  /// Calls the specified function [operation] with `this` value as its argument and returns `this` value.
  T also(void Function(T self) operation) {
    operation(this);
    return this;
  }
}

/// Represents a generic pair of two values.
class Pair<L, R> {
  Pair(this.left, this.right);

  final L left;
  final R right;

  @override
  String toString() => '($left, $right)';
}

extension PairExtensions<T> on Pair<T, T> {
  List<T> toList() => [left, right];
}
