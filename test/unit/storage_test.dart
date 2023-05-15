import 'package:branvier/branvier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final box = FakeBox();

  group('storage base', () {
    test('write & readAll', () async {
      await box.write('hello', 'world');
      await box.write('bye', 'world');
      final map = box.readAll();

      expect(map.values.length >= 2, true);
    });
    test('read', () async {
      final hello = await box.read('hello');

      expect(hello, 'world');
    });
    test('delete', () async {
      await box.delete('hello');
      final hello = await box.read('hello');

      expect(hello, null);
    });
    test('deleteAll', () async {
      await box.deleteAll();
      final bye = await box.read('bye');

      expect(bye, null);
    });
  });

  group('parse', () {
    test('parsing nums', () {
      const nums = '[1.1, 9.8, 3.2]';
      final parsed = nums.parse<List<int>>();
      expect(parsed, [1, 10, 3]);
    });
    test('parsing num map', () {
      const map = '{"a": 1.1, "b": 9.8}';
      final parsed = map.parse<DoubleMap>();
      expect(parsed, {'a': 1.1, 'b': 9.8});
    });
  });

  group('storage extensions', () {
    final fruits = ['apple', 'banana', 'orange']; //jlist

    test('update', () async {
      await box.write('market', fruits); //map
      await box.update<List>('market', (data) => data!..add('kiwi'));
      final data = box.read<List>('market'); //map

      expect(data, isNotNull);
      expect(data!.length, 4);
    });
  });

  group('on key change', () {
    final fruits = ['apple', 'banana', 'orange']; //jlist

    test('on', () async {
      // box.onChange('market', (old, data) {
      //   log('$old --> $data');
      // });
      await box.write('market', fruits); //map
      await box.update<List>('market', (data) => data!..add('kiwi'));
      final data = box.read<List>('market'); //map

      expect(data, isNotNull);
      expect(data!.length, 4);
    });
  });
}
