part of '/branvier.dart';

/// Implement as singleton.
/// Ex:
///   factory MyApi() => _instance;
///   MyApi._();
///   static final _instance = MyApi._();
abstract class IApi {
  ///Headers to attach to the request. Usually String or List<String>.
  Map<String, dynamic> get headers;

  ///Changes the baseUrl.
  set baseUrl(String url);

  ///A [get] function that returns [T].
  Future<T> get<T>(String path);

  ///A [post] function that returns [T].
  Future<T> post<T>(String path, [data]);
}

/// Used only for internal projects.
abstract class IApiResponse {
  ///Headers to attach to the request. Usually String or List<String>.
  Map<String, dynamic> get headers;

  ///Changes the baseUrl.
  set baseUrl(String url);

  ///A [get] function that returns [T].
  Future<ApiResponse<T>> get<T>(String path);

  ///A [post] function that returns [T].
  Future<ApiResponse<T>> post<T>(String path, [data]);
}

extension IApiExt on IApi {
  ///The current [token].
  String? get token => headers['authorization'] as String?;

  ///Authorizes, if null, removes any authorization for security.
  void authorize(String? token) => token == null
      ? headers.remove('authorization')
      : headers['authorization'] = token;
}

class MockApi implements IApi {
  @override
  Future<T> get<T>(String url) async => 'data' as T;

  @override
  Future<T> post<T>(String url, [data]) async => 'response' as T;

  @override
  set baseUrl(String url) {}

  @override
  // TODO: implement headers
  Map<String, dynamic> get headers => throw UnimplementedError();
}

extension MockApiX on MockApi {
  Future<String> getJString() async => '"Hello, World!"';
  Future<String> getJList() async => '["apple", "banana", "orange"]';
  Future<String> getJMap() async => '{"name": "Antony"}';
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
  final List<T> content;
  final String? token;

  ///Gets the single element data.
  T? get data => isSingle ? content.first : null;

  ///Checks if one single data.
  bool get isSingle => content.length == 1;

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

@immutable
class ApiException implements Exception {
  const ApiException(this.response, [this.data]);
  ApiException.message(String message, [this.data])
      : response = ApiResponse(
          result: false,
          message: message,
          content: [null],
          token: null,
        );

  final ApiResponse response;
  final dynamic data;

  bool get result => response.result;
  String get message => response.message;
  List get content => response.content;
  String? get token => response.token;
}
