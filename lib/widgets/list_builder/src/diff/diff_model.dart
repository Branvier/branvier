// ignore_for_file: no_runtimetype_tostring

abstract class Diff implements Comparable<Diff> {
  const Diff(
    this.index,
    this.size,
  );
  final int index;
  final int size;

  @override
  String toString() => '$runtimeType(index: $index, size: $size)';

  @override
  int compareTo(Diff other) => index - other.index;
}

class Insertion<E> extends Diff {
  const Insertion(
    super.index,
    super.size,
    this.items,
  );
  final List<E> items;
}

class Deletion extends Diff {
  const Deletion(
    super.index,
    super.size,
  );
}

class Modification<E> extends Diff {
  const Modification(
    super.index,
    super.size,
    this.items,
  );
  final List<E> items;

  @override
  String toString() {
    return '$runtimeType(index: $index, size: $size, items: $items)';
  }
}
