part of '/branvier.dart';

/// Implement as singleton.
/// Ex:
///   factory MyApi() => _instance;
///   MyApi._();
///   static final _instance = MyApi._();
mixin IApi {
  ///Headers to attach to the request.
  final Json headers = <String, dynamic>{};

  ///Changes the baseUrl.
  set baseUrl(String url);

  ///A [get] function that returns [T].
  Future<T> get<T>(String url);

  ///A [post] function that returns [T].
  Future<T> post<T>(String url, [data]);
}

extension IApiExt on IApi {
  ///The current [token].
  String? get token => headers['authorization'];

  ///Authorizes, if null, removes any authorization for security.
  void authorize(String? token) => token == null
      ? headers.remove('authorization')
      : headers['authorization'] = token;
}

class MockApi with IApi {
  @override
  Future<T> get<T>(String url) async => 'data' as T;

  @override
  Future<T> post<T>(String url, [data]) async => 'response' as T;

  @override
  set baseUrl(String url) {}
}

extension MockApiX on MockApi {
  Future<String> getJString() async => '"Hello, World!"';
  Future<String> getJList() async => '["apple", "banana", "orange"]';
  Future<String> getJMap() async => '{"name": "Antony"}';
}
