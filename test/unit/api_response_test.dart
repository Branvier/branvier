import 'package:branvier/branvier.dart';
import 'package:flutter_test/flutter_test.dart';

ApiResponse<T> _response<T>(data) => ApiResponse<T>(
      result: true,
      message: 'message',
      content: data is List ? data : [data],
      token: 'token',
    );

///$message - daa
void main() {

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
