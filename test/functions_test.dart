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
    Future<String?> get() async => throw '';

    final then = await get().thenTry((value) => get());
    expect(then, null);

    final or = await get().thenOr((value) => value, or: '');
    expect(or, '');

    final nor = await get().thenOr((value) => value, or: '');
    expect(nor, '');
  });

  test('if non-null', () async {
    Future<String?> get() async => 'null';

    var validated = false;

    void onValidate(String value) {
      validated = true;
    }

    String? validator(String? value) {
      value.non(onValidate);
      return value;
    }

    final string = await get();
    final r = string.non(validator);

    expect(r, 'null');
    expect(validated, true);
  });
}
