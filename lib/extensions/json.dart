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
  List<double> toDouble() => map((e) => e.toDouble()).toList();
  List<int> toInt() => map((e) => e.round()).toList();
}

extension CastMap on NumMap {
  DoubleMap toDouble() => map((k, v) => MapEntry(k, v.toDouble()));
  IntMap toInt() => map((k, v) => MapEntry(k, v.round()));
}

extension JsonString on String {
  ///Parses this String as [T].
  ///Aimed for subtypes.
  ///
  ///For bool, int, double. Use toBool, toInt and toDouble.
  ///
  ///Test: 'readAs: parse' in storage_test.dart.
  T parse<T>() {
    final parsed = const JsonDecoder().convert(this);

    try {
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

    } catch (e) {
      throw ArgumentError.value(parsed, T.toString());
    }
    //For complex objects or [T] absent, dynamic cast.
    return parsed as T;
  }

  ///Tries to parse this String as [T].
  T? tryParse<T>() {
    try {
      return parse<T>();
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      return null;
    }
  }

  ///Returns false on fail.
  bool toBool() => this == 'true';

  ///Parses from dec [10], hex [16] or other radix to [int]. Max: 36.
  int toInt([int? radix]) => int.parse(this, radix: radix);
  int? tryInt([int? radix]) => int.tryParse(this, radix: radix);

  ///Parses to Double. Ex: '1.2' -> 1.2.
  double toDouble() => double.parse(this);
  double? tryDouble() => double.tryParse(this);

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
  ///Universal Timestamp Unix in seconds. Ex "1647323301".
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
