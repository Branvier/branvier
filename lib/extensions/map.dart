part of '/branvier.dart';

extension MapExt<K, V> on Map<K, V?> {
  ///Deeply remove all null values from this [Map].
  void removeNulls() {
    removeWhere((key, value) {
      if (value == null) return true;
      if (value is Map) value.removeNulls();
      return false;
    });
  }

  ///Sames map, same keys, no nullables.
  Map<K, V> get noNulls => Map<K, V>.from(this..removeNulls());
}
