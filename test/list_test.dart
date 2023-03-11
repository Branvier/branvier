import 'package:branvier/branvier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('operations', () {
    test('remove nulls', () {
      final list = [null, null, 1, ''];
      list.removeNulls();

      expect(list, [1, '']);
    });
    test('no nulls', () {
      final list = [null, null];

      expect(list.noNulls, []);
    });
  });
}
