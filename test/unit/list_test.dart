import 'package:branvier/branvier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('operations', () {
    test('toIndexMap', () {
      final list = ['pear', 'kiwi'];
      final map = list.toIndexMap();

      expect(map, {'0': 'pear', '1': 'kiwi'});
    });
    test('remove nulls', () {
      final list = [null, null, 1, ''];
      list.removeNulls();

      expect(list, [1, '']);
    });
    test('no nulls', () {
      final list = [null, null];

      expect(list.noNulls, []);
    });

    test('rsort', () {
      final list = ['a', 'b', 'c'];
      list.rsort();

      expect(list, ['c', 'b', 'a']);
    });
  });
}
