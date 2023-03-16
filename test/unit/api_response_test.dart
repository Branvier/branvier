import 'dart:collection';

import 'package:branvier/branvier.dart';
import 'package:flutter_test/flutter_test.dart';

ApiResponse<T> _response<T>(data) => ApiResponse<T>(
      result: true,
      message: 'message',
      content: data is List ? data : [data],
      token: 'token',
    );

final types = [];
set add(value) => types.add(value);

///$message - daa
void main() {
  test('a', () {});
  test('map', () {
    types.clear();
    final a = 0.runtimeType;
    final b = a.baseString;

    final set = <dynamic>{};
    final iter = set.map((e) => null);

    add = ''.runtimeType.isString;
    add = {}.runtimeType.isMap;
    add = [].runtimeType.isList;
    add = iter.runtimeType.isIterable;
    add = set.runtimeType.isSet;
    add = true.runtimeType.isBool;
    add = 1.runtimeType.isInt;
    add = 1.0.runtimeType.isDouble;
    add = 2.runtimeType.isNum;

    expect(types.contains(false), false);
    // expect({'a': 1}.runtimeType is Map, true);
    // expect(b is List, true);
  });
  group('extensions', () {
    test('string', () {
      final r = _response('a');
      expect(r.data, ['a']);
    });
    test('list', () {
      final r = _response<List<String>>(['a']);
      expect(r.data, ['a']);
    });
    test('map', () {
      final r = _response<Json<int>>({'a': 1});
      expect(r.data, {'a': 1});
    });
  });
}
