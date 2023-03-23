part of '/branvier.dart';

extension MapExp<K, V> on Map<K, V> {
  ///Map only the values, [K] keys keeps untouched.
  Map<K, R> mapv<R>(R Function(K k, V v) toMap) =>
      map((k, v) => MapEntry(k, toMap(k, v)));

  List<R> list<R>(GetOn<V, R> toElement) => values.list(toElement);
}

extension IterExt<V> on Iterable<V> {
  List<R> list<R>(GetOn<V, R> toElement) => map<R>(toElement).toList();
  V get antepenult => toList().reversed.elementAt(2);
  V get penult => toList().reversed.elementAt(1);
  V get second => elementAt(1);
  V get third => elementAt(2);

  /// Converts to [Map], where keys are string indexes.
  ///
  /// Ex: ['pear', 'kiwi'] -> {'0': 'pear', '1': 'kiwi'};
  ///
  /// Tested in list_test.
  Map<String, V> toIndexMap() {
    final map = <String, V>{};
    length.forEach((i) {
      map[i.toString()] = toList()[i];
    });
    return map;
  }
}

extension ListExt<V> on List<V> {
  void clearAdd(V value) {
    clear();
    add(value);
  }

  void clearAddAll(Iterable<V> items) {
    clear();
    addAll(items);
  }

  void sorter(
    Sort Function(V a, V b) toSort, {
    bool az = true,
    bool lowerCase = true,
  }) {
    sort((a, b) {
      final sort = toSort(a, b).isLower(lowerCase);
      return az ? sort.az : sort.za;
    });
  }
}

extension StringsExt on Strings {
  List<String> get sorted {
    final list = [...this];
    list.sort();
    return list;
  }

  List<String> get rsorted {
    final list = [...this];
    list.rsort();
    return list;
  }

  ///Reverse sort() on [descending] true. Normal sort() on false.
  void rsort([bool descending = true]) =>
      descending ? sort((a, b) => b.compareTo(a)) : sort();
}

extension ListExtN<V> on List<V?> {
  List<V> get noNulls {
    if (V == Null) return [];
    return whereType<V>().toList();
  }

  void removeNulls() => clearAddAll(noNulls);
}

class Sort {
  const Sort(this.a, this.b);
  final String? a;
  final String? b;

  Sort get lower => Sort(a?.toLowerCase(), b?.toLowerCase());
  Sort isLower(bool condition) => condition ? lower : this;
  int isAz(bool ascending) => ascending ? az : za;
  int get az => a.or('').compareTo(b.or(''));
  int get za => b.or('').compareTo(a.or(''));
}
