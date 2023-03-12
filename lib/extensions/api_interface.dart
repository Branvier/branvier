part of '/branvier.dart';

abstract class IApi {
  ///Headers to attach to the request.
  Map<String, String> headers = {};

  String baseUrl = '';

  String contentType = 'application/json';

  ///A [get] function that returns [T].
  Future<T> get<T>(String url);

  ///A [post] function that returns [T].
  Future<T> post<T>(String url, [data]);
}

extension IApiExt on IApi {
  void authorize(String? token) => token == null
      ? headers.remove('authorization')
      : headers['authorization'] = token;
}

class MockApi with IApi {
  @override
  Future<T> get<T>(String url) async => 'data' as T;

  @override
  Future<T> post<T>(String url, [data]) async => 'response' as T;
}

extension MockApiX on MockApi {
  Future<String> getJString() async => '"Hello, World!"';
  Future<String> getJList() async => '["apple", "banana", "orange"]';
  Future<String> getJMap() async => '{"name": "Antony"}';
}
