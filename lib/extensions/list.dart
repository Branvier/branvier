part of '/branvier.dart';

extension IterExt<V> on Iterable<V> {
  List<R> list<R>(GetOn<V, R> toElement) => map<R>(toElement).toList();
}

extension ListExt<V> on List<V> {
  V get antepenult => reversed.elementAt(2);
  V get penult => reversed.elementAt(1);
  V get second => elementAt(1);
  V get third => elementAt(2);

  void assign(V value) {
    clear();
    add(value);
  }

  void assignAll(Iterable<V> items) {
    clear();
    addAll(items);
  }
}

extension ListExtN<V> on List<V?> {
  List<V> get noNulls {
    if (V == Null) return [];
    return whereType<V>().toList();
  }

  void removeNulls() => assignAll(noNulls);
}
