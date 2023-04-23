// import 'dart:convert';

part of '/branvier.dart';

/// Implement CRUD rules for REST API.
/// Must be a singleton.
///
/// Ex:
///
/// factory MyApi() => _instance;
///
/// MyApi._();
///
/// static final _instance = MyApi._();
abstract class IApi {
  ///Headers to attach to the request. Usually String or List<String>.
  Map<String, dynamic> get headers;

  ///Changes the baseUrl.
  set baseUrl(String url);

  ///CREATE.
  Future<T> post<T>(String path, [data]);

  ///READ.
  Future<T> get<T>(String path);

  ///UPDATE.
  Future<T> put<T>(String path, [data]);

  ///DELETE.
  Future<T> delete<T>(String path);
}

extension IApiExt on IApi {
  ///The current [token].
  String? get token => headers['authorization'] as String?;

  ///Sets the current [token]. If null, removes.
  set token(String? token) => token == null
      ? headers.remove('authorization')
      : headers['authorization'] = token;
}

///Simple http client Mocker using mocktail.
class MockApi extends Mock implements IApi {
  @override
  var baseUrl = '';

  @override
  final headers = <String, dynamic>{};
}

extension ApiResponseExt<T> on ApiResponse<T> {
  ///Gets the expected [T] base data.
  T get data {
    return jsonEncode(content).parse<T>();
  }

  ///Gets the content as [List].
  List get list => List.from(content);

  ///Gets the content as [Json].
  Json get map {
    if (content is Map) return Json.from(content);
    if (content is List && content.isEmpty) throw ApiException('API.EMPTY');
    return Json.from((content as List).first);
  }

  ///Gets the result as [String].
  String get string {
    if (content is String) return content;
    if (content is List && content.isEmpty) throw ApiException('API.EMPTY');
    return (content as List).first;
  }
}

///Modelo padrão para todas as requisições recebidas via API.
class ApiResponse<T> {
  const ApiResponse({
    required this.result,
    required this.message,
    required this.content,
    required this.token,
  });

  final bool result;
  final String message;
  final dynamic content;
  final String? token;

  // ignore: sort_constructors_first
  ApiResponse.fromJson(Json json)
      : result = json['result'],
        message = json['message'],
        content = json['content'],
        token = json['token'];

  Json toJson() {
    final data = <String, dynamic>{};
    data['result'] = result;
    data['message'] = message;
    data['content'] = content;
    return data;
  }
}

extension ApiResponseException<T> on ApiResponse<T> {
  ApiException get exception => ApiException(message);
}

@immutable
class ApiException extends KeyException {
  ApiException(String key) : super(key.toUpperCase());
}
