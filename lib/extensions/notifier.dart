part of '/branvier.dart';

extension CallState<T> on ValueNotifier<T> {
  ///Sets value. Ignores null values.
  T call([T? value]) => this.value = value ?? this.value;

  ///Sets value of other notifier.
  T of(ValueNotifier<T> other) => value = other.value;

  ///Sets value after [action].
  To update<To>(InOut<T, To> action) {
    final value = this.value;
    final response = action(value);
    this.value = value;
    return response;
  }

  ///Sets value post frame.
  T post(T value) {
    if (!has(value)) postFrame(() => this.value = value);
    return this.value;
  }

  ///Checks if the notifier has this value.
  bool has(T value) => this.value == value;

  ///Checks if both notifiers have the same value.
  bool same(ValueNotifier<T> other) => value == other.value;

  ///Switches between [left] and [right] values;
  T switcher(T left, T right) => value = value != left ? left : right;

  bool get isEmpty => [{}, [], ''].contains(value);
}

extension NullNotifier<V> on ValueNotifier<V?> {
  ///Sets value to null.
  V? toNull() => value = null;
}

extension ListNotifier<V> on ValueNotifier<List<V>> {
  ///Sets List<value> after [action].
  To update<To>(InOut<List<V>, To> action) {
    final list = [...value];
    final response = action(list);
    value = list;
    return response;
  }

  //Getters
  int get length => value.length;
  V get first => value.first;
  V get second => value.elementAt(1);
  V get third => value.elementAt(2);
  V get antepenult => reversed.elementAt(2);
  V get penult => reversed.elementAt(1);
  V get last => value.last;
  Iterable<V> get reversed => value.reversed;
  Iterator<V> get iterator => value.iterator;
  V get single => value.single;
  bool get isEmpty => value.isEmpty;
  bool get isNotEmpty => value.isNotEmpty;
  R _<R>(InOut<List<V>, R> action) => update(action); //short

  //Increase list size.
  void add(V element) => update((list) => list.add(element));
  void addAll(iterable) => update((list) => list.addAll(iterable));
  void insert(index, element) => update((list) => list.insert(index, element));
  void insertAll(int i, Iterable<V> iter) => _((l) => l.insertAll(i, iter));
  Iterable<R> expand<R>(Iterable<R> Function(V) exp) => _((l) => l.expand(exp));

  //Decrease list size.
  void clear() => update((list) => list.clear());
  bool remove(V element) => update((list) => list.remove(element));
  V removeLast() => update((list) => list.removeLast());
  V removeAt(int index) => update((list) => list.removeAt(index));
  void removeRange(int start, int end) => _((l) => l.removeRange(start, end));
  void removeWhere(bool Function(V) test) => update((l) => l.removeWhere(test));

  //Operations
  void shuffle() => update((list) => list.shuffle());
  V reduce(V Function(V, V) combine) => update((list) => list.reduce(combine));
  R fold<R>(R init, R Function(R, V) combine) =>
      _((l) => l.fold(init, combine));

  //Readables.
  bool contains(Object? element) => value.contains(element);
  Iterable<R> map<R>(InOut<V, R> toElement) => value.map(toElement);

  //Operators
  V operator [](int index) => update((list) => list[index]);
  List<V> operator +(List<V> value) => update((list) => list + value);
  void operator []=(int index, V value) => update((l) => l[index] = value);
}

extension MapNotifier<K, V> on ValueNotifier<Map<K, V>> {
  ///Sets Map<value> after [action].
  R update<R>(R Function(Map<K, V> map) action) {
    final map = {...value};
    final response = action(map);
    value = map;
    return response;
  }

  void forEach(void Function(K, V) action) => update((e) => e.forEach(action));

  //Operators
  V? operator [](Object? key) => update((map) => map[key]);
  void operator []=(K key, V value) => update((map) => map[key] = value);
}

extension SetNotifier<V> on ValueNotifier<Set<V>> {
  ///Sets Set<value> after [action].
  R update<R>(R Function(Set<V> set) action) {
    final set = {...value};
    final response = action(set);
    value = set;
    return response;
  }
}

extension BoolNotifier on ValueNotifier<bool> {
  ///Toggles the values. Can set instead.
  bool toggle([bool? value]) => this.value = value ?? !this.value;

  ///Toggles on. Sets to true.
  bool on() => call(true);

  ///Toggles off. Sets to false.
  bool off() => call(false);

  ///Test if the inner value is true.
  bool get isTrue => value == true;

  ///Test if the inner value is false.
  bool get isFalse => value == false;

  ///Toggles boolean after [duration].
  Future<bool> delay<T>(Duration duration, [bool? value]) {
    return Future.delayed(duration, () => toggle(value));
  }

  bool operator &(bool other) => value && other;
}

extension ListNotifiers<T> on List<ValueNotifier<T>> {
  // void off() => map((e) => e.off());

  void call(T value) => map((e) => e(value));
}
