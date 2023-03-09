part of '/branvier.dart';

abstract class Api<T> {
  ///Headers to attach to the request.
  Map<String, String> headers = {};

  String baseUrl = '';

  String contentType = 'application/json';

  ///A [get] function that returns [T].
  Future<T> get(String url);

  ///A [post] function that returns [T].
  Future<T> post(String url, [data]);
}

extension IApiExt on Api {
  void authorize(String? token) => token == null
      ? headers.remove('authorization')
      : headers['authorization'] = token;
}
