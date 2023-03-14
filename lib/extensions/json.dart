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

extension DynamicCast on dynamic {
  /// Cast any type and specially subtypes.
  /// Subtypes of subtypes are not supported.
  /// Ex List<List<String>> instead, use: List<List>.
  T cast<T>() {
    if (T == Strings) return Strings.from(this) as T;
    if (T == Nums) return Nums.from(this) as T;
    if (T == Ints) return Nums.from(this).toInt() as T;
    if (T == Doubles) return Nums.from(this).toDouble() as T;
    if (T == Bools) return Bools.from(this) as T;
    if (T == Lists) return Lists.from(this) as T;
    if (T == Maps) return Maps.from(this) as T;

    if (T == StringMap) return StringMap.from(this) as T;
    if (T == NumMap) return NumMap.from(this) as T;
    if (T == IntMap) return NumMap.from(this).toInt() as T;
    if (T == DoubleMap) return NumMap.from(this).toDouble() as T;
    if (T == BoolMap) return BoolMap.from(this) as T;
    if (T == JsonMap) return JsonMap.from(this) as T;
    if (T == ListMap) return ListMap.from(this) as T;

    return this as T;
  }
}

extension JsonString on String {
  ///Parses [this] String as [T].
  ///Aditionally parses the first subtype.
  ///
  ///Test: 'readAs: parse' in storage_test.dart.
  T parse<T>() {
    final parsed = const JsonDecoder().convert(this);

    //For complex objects or [T] absent, dynamic cast.
    return parsed.cast<T>();
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

  ///Parses from dec [10], hex [16] or other radix to [int]. Max: 36.
  BigInt toBigInt([int? radix]) => BigInt.parse(this, radix: radix);
  BigInt? tryBigInt([int? radix]) => BigInt.tryParse(this, radix: radix);

  String toR36([int? radix]) => toBigInt(radix).toRadixString(36);
  String toHex([int? radix]) => toBigInt(radix).toRadixString(16);
  String toDec([int? radix]) => toBigInt(radix).toRadixString(10);
  String toOct([int? radix]) => toBigInt(radix).toRadixString(8);
  String toBin([int? radix]) => toBigInt(radix).toRadixString(2);

  ///Converts to [DateTime].
  DateTime toDate() => int.parse(this).toDate();
}

extension DateExt on DateTime {
  ///Universal Timestamp Unix. Ex "1647323301".
  String toUnix() => secondsSinceEpoch.toJson();

  ///Human Readable Time. Ex: "2023-03-14T10:30:00.000".
  String toJson() => const JsonEncoder.withIndent('  ').convert(this);
}

extension JsonInt on num {
  ///The number of digits after zero.
  int get length => round().toString().length;

  BigInt toBig() => BigInt.from(this);

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
