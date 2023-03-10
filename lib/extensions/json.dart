part of '/branvier.dart';

extension JsonObject on Json {
  ///Converts to an indented [String].
  String toJson() => const JsonEncoder.withIndent('  ').convert(this);

  ///Logs a formatted json in the console.
  void log() => dev.log(toJson());
}

typedef Strings = List<String>;
typedef Ints = List<int>;
typedef Bools = List<bool>;
typedef Lists<T> = List<List<T>>;
typedef Maps<T> = List<Json<T>>;

typedef StringMap = Json<String>;
typedef IntMap = Json<int>;
typedef BoolMap = Json<bool>;
typedef JsonMap<T> = Json<Json<T>>;
typedef ListMap<T> = Json<List<T>>;
extension JsonString on String {


  ///Parses [this] String as [T].
  ///Aditionally parses the first subtype.
  ///
  ///Subtypes of subtypes are still dynamic.
  ///Ex: List<List<String>>> will fail.
  ///Use List<List>> instead.
  ///
  ///Test: 'readAs: parse' in storage_test.dart.
  T parse<T>() {
    final parsed = const JsonDecoder().convert(this);

    if (T == Strings) return Strings.from(parsed) as T;
    if (T == Ints) return Ints.from(parsed) as T;
    if (T == Bools) return Bools.from(parsed) as T;
    if (T == Lists) return Lists.from(parsed) as T;
    if (T == Maps) return Maps.from(parsed) as T;

    if (T == StringMap) return StringMap.from(parsed) as T;
    if (T == IntMap) return IntMap.from(parsed) as T;
    if (T == BoolMap) return BoolMap.from(parsed) as T;
    if (T == JsonMap) return JsonMap.from(parsed) as T;
    if (T == ListMap) return ListMap.from(parsed) as T;

    //For complex objects or [T] absent, dynamic cast.
    return parsed as T;
  }

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
