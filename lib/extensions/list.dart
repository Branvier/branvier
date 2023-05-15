part of '/branvier.dart';

extension MapExp<K, V> on Map<K, V> {
  @Deprecated('Use .map().toList() instead, for clarity')
  List<R> list<R>(R Function(V e) toElement) => values.list(toElement);
}

extension IterExt<V> on Iterable<V> {
  @Deprecated('Use .map().toList() instead, for clarity')
  List<R> list<R>(R Function(V e) toElement) => map<R>(toElement).toList();
}

void name(params) {
  final List a = [].map((e) => '').toList();
  a.add('value');
}
