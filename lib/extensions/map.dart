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
