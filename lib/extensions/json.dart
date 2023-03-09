part of '/branvier.dart';

extension JsonObject on Json {
  ///Converts to an indented [String].
  String toJson() => const JsonEncoder.withIndent('  ').convert(this);

  ///Logs a formatted json in the console.
  void log() => dev.log(toJson());
}

extension JsonString on String {
  ///Parses [this] String as [T].
  T parse<T>() => const JsonDecoder().convert(this);

  ///Tries to parse [this] String as [T].
  T? tryParse<T>() {
    try {
      return parse<T>();
    } catch (e) {
      return null;
    }
  }
}

extension JsonInt on num {
  String toJson() => const JsonEncoder.withIndent('  ').convert(this);
}

extension JsonBool on bool {
  String toJson() => const JsonEncoder.withIndent('  ').convert(this);
}

extension JsonStringList on List<String> {
  String toJson() => const JsonEncoder.withIndent('  ').convert(this);
}

extension JsonNumList on List<num> {
  String toJson() => const JsonEncoder.withIndent('  ').convert(this);
}

extension JsonBoolList on List<bool> {
  String toJson() => const JsonEncoder.withIndent('  ').convert(this);
}
