import 'package:branvier/branvier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final box = MockBox();

  group('storage base', () {
    test('write & readAll', () async {
      await box.write('hello', 'world');
      await box.write('bye', 'world');
      final map = await box.readAll();

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
    const fruits = '["apple", "banana", "orange"]'; //jlist
    const market = '{"fruits": $fruits, "from": "belém"}'; //jmap
    const town = '{"market": $market, "market2": $market}'; //jmaps

    test('readAs: parse', () async {
      await box.write('fruits', fruits);
      await box.write('market', market);
      await box.write('town', town);

      final list = await box.readAs<Strings>('fruits');
      final map = await box.readAs<Json>('market');
      final jsonMap = await box.readAs<JsonMap>('town');

      expect(list?.length, 3);
      expect(map?['fruits'], list);
      expect(jsonMap?['market']?['fruits'], list);
    });
    test('readSubAs & writeSub', () async {
      await box.writeSub('market', 'fruits', "[]");
      final subEmpty = await box.readSubAs<Strings>('market', 'fruits');
      expect(subEmpty, []);

      await box.writeSub('market', 'fruits', fruits);
      final subFruits = await box.readSubAs<Strings>('market', 'fruits');
      expect(subFruits?.length, 3);
    });
    test('append', () async {
      await box.write('fruits', '[]');
      await box.append('fruits', 'melon');
      await box.append('fruits', 'apple');
      await box.append('fruits', 'pear');
      await box.append('fruits', 'pear'); //ignored
      await box.append('fruits', 'pear', duplicates: true);
      final fruits = await box.readAs<Strings>('fruits');

      expect(fruits?.first, 'melon');
      expect(fruits?.contains('apple'), true);
      expect(fruits?.last, 'pear');
      expect(fruits?.length, 4);
    });
    test('modify', () async {
      await box.write('market', market); //map
      await box.modify('market', (data) => data ?? "{}");
      final data = await box.read('market'); //map

      expect(data, market);

      await box.modify('market', (data) => "{}");
      final dataEmpty = await box.read('market'); //map

      expect(dataEmpty, "{}");
    });
    test('modifyAs', () async {
      await box.write('market', market); //map
      await box.modifyAs<Json>('market', (map) => (map?..remove('from')) ?? {});
      final from = await box.readSubAs('market', 'from');
      expect(from, null);
    });
    test('merge', () async {
      await box.write('market', market); //map with 2 entries
      await box.merge('market', town.parse()); //map with 2 entries
      final merged = await box.readAs<Json>('market');
      expect(merged?.entries.length, 4);
    });
  });
}
