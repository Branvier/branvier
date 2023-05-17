// ignore_for_file: deprecated_member_use_from_same_package

part of '/branvier.dart';

extension IntExt on int {
  ///List of indexes where this is the length.
  ///Ex: 3.indexed -> [0,1,2].
  List<int> get indexed => list((i) => i);

  ///List of consecutive numbers where this is the last.
  ///Ex: 3.numbered -> ['1','2','3'].
  List<String> get numbered => list((i) => (++i).toString());

  ///Calls [action] this many times. Callbacks index for each time.
  @Deprecated('Use for instead, for clarity')
  void forEach(void Function(int i) action) {
    for (var i = 0; i < this; i++) {
      action(i);
    }
  }

  ///Creates a list with this length. Callbacks element index.
  @Deprecated('Use for instead, for clarity')
  List<T> list<T>(T Function(int i) toElement) {
    final list = <T>[];
    forEach((i) => list.add(toElement(i)));
    return list;
  }
}

extension NumberOperations on num {
  double divide(double by) => this / by;
  double multiply(double by) => this * by;
}
