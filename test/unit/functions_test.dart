import 'package:branvier/branvier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<String?> get() async => null;

  test('future values', () async {
    final then = await get().then((r) => r).or('a');
    expect(then, 'a');

    final or = await get().or('b');
    expect(or, 'b');

    final thenTry = await get().thenOr((r) => r, or: 'c');
    expect(thenTry, 'c');
  });

  test('should not throw', () async {
    Future<String?> get() async => throw Exception('get');

    final then = await get().thenTry((value) => get());
    expect(then, null);

    final or = await get().thenOr((value) => value, or: '');
    expect(or, '');

    final nor = await get().thenOr((value) => value, or: '');
    expect(nor, '');
  });

}
