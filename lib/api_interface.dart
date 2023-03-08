part of 'export.dart';

abstract class IApi<T> {
  ///Headers to attach to the request.
  Map<String, String> headers = {};

  String baseUrl = '';

  String contentType = 'application/json';

  ///A [get] function that returns [T].
  Future<T> get(String url);

  ///A [post] function that returns [T].
  Future<T> post(String url, [data]);
}

extension IApiExt on IApi {
  void authorize(String? token) => token == null
      ? headers.remove('authorization')
      : headers['authorization'] = token;
}
