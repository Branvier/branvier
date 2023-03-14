part of '/branvier.dart';

extension JsonObject on Json {
  ///Converts to an indented [String].
  String toJson() => const JsonEncoder.withIndent('  ').convert(this);

  ///Logs a formatted json in the console.
  void log() => dev.log(toJson());
}

typedef Json<V> = Map<String, V>;

typedef Strings = List<String>;
typedef Nums = List<num>;
typedef Ints = List<int>;
typedef Doubles = List<double>;
typedef Bools = List<bool>;
typedef Lists<T> = List<List<T>>;
typedef Maps<T> = List<Json<T>>;

typedef StringMap = Json<String>;
typedef NumMap = Json<num>;
typedef IntMap = Json<int>;
typedef DoubleMap = Json<double>;
typedef BoolMap = Json<bool>;
typedef JsonMap<T> = Json<Json<T>>;
typedef ListMap<T> = Json<List<T>>;

extension CastList on List<num> {
  List<double> toDouble() => list((e) => e.toDouble());
  List<int> toInt() => list((e) => e.round());
}

extension CastMap on NumMap {
  DoubleMap toDouble() => map((k, v) => MapEntry(k, v.toDouble()));
  IntMap toInt() => map((k, v) => MapEntry(k, v.round()));
}

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
    if (T == Nums) return Nums.from(parsed) as T;
    if (T == Ints) return Nums.from(parsed).toInt() as T;
    if (T == Doubles) return Nums.from(parsed).toDouble() as T;
    if (T == Bools) return Bools.from(parsed) as T;
    if (T == Lists) return Lists.from(parsed) as T;
    if (T == Maps) return Maps.from(parsed) as T;

    if (T == StringMap) return StringMap.from(parsed) as T;
    if (T == NumMap) return NumMap.from(parsed) as T;
    if (T == IntMap) return NumMap.from(parsed).toInt() as T;
    if (T == DoubleMap) return NumMap.from(parsed).toDouble() as T;
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

  ///Parses from dec [10], hex [16] or other radix to [int]. Max: 36.
  int toInt([int? radix]) => int.parse(this, radix: radix);
  int? tryInt([int? radix]) => int.tryParse(this, radix: radix);

  ///Converts to [DateTime].
  DateTime toDate() => int.parse(this).toDate();
}

extension JsonInt on num {
  ///The number of digits after zero.
  int get length => round().toString().length;

  String toJson() => const JsonEncoder.withIndent('  ').convert(this);

  ///Converts to [DateTime].
  DateTime toDate() {
    if (length <= 10) return DateTime.fromMillisecondsSinceEpoch(this ~/ 0.001);
    if (length <= 13) return DateTime.fromMillisecondsSinceEpoch(round());
    if (length <= 16) return DateTime.fromMicrosecondsSinceEpoch(round());
    return DateTime.fromMicrosecondsSinceEpoch(this ~/ 1000);
  }
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

f() {}
