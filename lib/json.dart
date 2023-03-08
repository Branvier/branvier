part of 'export.dart';

extension JsonObject on Json {
  ///Converts to an indented [String].
  String encode() => const JsonEncoder.withIndent('  ').convert(this);

  ///Logs a formatted json in the console.
  void log() => dev.log(encode());
}

extension JsonString on String {
  T decode<T>() => const JsonDecoder().convert(this);
}
