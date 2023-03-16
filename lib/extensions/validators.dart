part of '/branvier.dart';

extension StrinExt on String {
  /// Capitalizes all words. ex: your name => Your Name.
  String get capitalized => split(' ').map((e) => e.capitalizeFirst).join(' ');

  /// Uppercase first letter inside string and let the others lowercase.
  /// Example: your name => Your name.
  String get capitalizeFirst {
    if (isEmpty) return '';
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  String get lastPascalCaseWord {
    final pattern = RegExp(r'[A-Z][a-z0-9]*(?=\b)');
    final matches = pattern.allMatches(this);
    if (matches.isNotEmpty) {
      final match = matches.last;
      return substring(match.start, match.end);
    }
    return this;
  }

  ///Remove all the chars in [charsToRemove].
  String removeChars(String charsToRemove) {
    var result = this;
    charsToRemove.split('').forEach((char) {
      result = result.replaceAll(char, '');
    });
    return result;
  }
}

extension Validators on String {
  bool get hasUppercase => RegExp('[A-Z]').hasMatch(this);
  bool get hasLowercase => RegExp('[a-z]').hasMatch(this);
  bool get hasNumber => RegExp('[0-9]').hasMatch(this);
  bool get hasSpecial => RegExp(r'[!@#\$&*~]').hasMatch(this);
  bool get isLength8 => length >= 6;
  bool get isPassword => hasNumber && isLength8;
  bool get isEmail => Utils.isEmail(this);
  bool get isUrl => Utils.isUrl(this);
  bool get isCpf => Utils.isCpf(this);
  bool get isCnpj => Utils.isCnpj(this);
  bool get isPhone => Utils.isPhone(this);
  bool get isCurrency => Utils.isCurrency(this);
  bool get isDateTime => Utils.isDateTime(this);
  bool get isPassport => Utils.isPassport(this);
  bool get isBinary => Utils.isBinary(this);
  bool get isHexadecimal => Utils.isHexadecimal(this);

  static String? password(String? text) => text?.test(text.isPassword, true);
  static String? email(String? text) => text?.test(text.isEmail, true);
  static String? cpf(String? text) => text?.test(text.isCpf, true);

  ///Validates if the field is required. Nothing else.
  static String? required(String? value) => value?.validator(required: true);

  ///Short version.
  String? test(bool test, [bool required = false]) {
    return validator(test: test, required: required);
  }

  ///Declares a Form validator callback.
  String? validator({
    bool? test,
    bool required = false,
    String invalidText = 'form.invalid',
    String requiredText = 'form.required',
  }) {
    if (isEmpty && required) return requiredText;
    if (test == null) return null;
    return test == true ? null : invalidText;
  }
}

mixin Utils {
  static bool isEmail(String value) => RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
      ).hasMatch(value);

  static bool isUrl(String value) => RegExp(
        r"^((((H|h)(T|t)|(F|f))(T|t)(P|p)((S|s)?))\://)?(www.|[a-zA-Z0-9].)[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,6}(\:[0-9]{1,5})*(/($|[a-zA-Z0-9\.\,\;\?\'\\\+&amp;%\$#\=~_\-]+))*$",
      ).hasMatch(value);

  static bool isPhone(String value) {
    if (value.length > 16 || value.length < 9) return false;
    return RegExp(
      r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$',
    ).hasMatch(value);
  }

  static bool isDateTime(String value) =>
      RegExp(r'^\d{4}-\d{2}-\d{2}[ T]\d{2}:\d{2}:\d{2}.\d{3}Z?$')
          .hasMatch(value);

  static bool isPassport(String value) =>
      RegExp(r'^(?!^0+$)[a-zA-Z0-9]{6,9}$').hasMatch(value);

  static bool isBinary(String value) => RegExp(r'^[0-1]+$').hasMatch(value);

  static bool isHexadecimal(String value) =>
      RegExp(r'^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$').hasMatch(value);

  static bool isCurrency(String value) => RegExp(
        r'^(S?\$|\₩|Rp|\¥|\€|\₹|\₽|fr|R\$|R)?[ ]?[-]?([0-9]{1,3}[,.]([0-9]{3}[,.])*[0-9]{3}|[0-9]+)([,.][0-9]{1,2})?( ?(USD?|AUD|NZD|CAD|CHF|GBP|CNY|EUR|JPY|IDR|MXN|NOK|KRW|TRY|INR|RUB|BRL|ZAR|SGD|MYR))?$',
      ).hasMatch(value);

  //Check if num is a cnpj
  static bool isCnpj(String cnpj) {
    // Obter somente os números do CNPJ
    final numbers = cnpj.replaceAll(RegExp('[^0-9]'), '');

    // Testar se o CNPJ possui 14 dígitos
    if (numbers.length != 14) return false;

    // Testar se todos os dígitos do CNPJ são iguais
    if (RegExp(r'^(\d)\1*$').hasMatch(numbers)) {
      return false;
    }

    // Dividir dígitos
    final digits = numbers.split('').map(int.parse).toList();

    // Calcular o primeiro dígito verificador
    var calcDv1 = 0;
    var j = 0;
    for (final i in Iterable<int>.generate(12, (i) => i < 4 ? 5 - i : 13 - i)) {
      calcDv1 += digits[j++] * i;
    }
    calcDv1 %= 11;
    final dv1 = calcDv1 < 2 ? 0 : 11 - calcDv1;

    // Testar o primeiro dígito verificado
    if (digits[12] != dv1) {
      return false;
    }

    // Calcular o segundo dígito verificador
    var calcDv2 = 0;
    j = 0;
    for (final i in Iterable<int>.generate(13, (i) => i < 5 ? 6 - i : 14 - i)) {
      calcDv2 += digits[j++] * i;
    }
    calcDv2 %= 11;
    final dv2 = calcDv2 < 2 ? 0 : 11 - calcDv2;

    // Testar o segundo dígito verificador
    if (digits[13] != dv2) {
      return false;
    }

    return true;
  }

  /// Checks if the cpf is valid.
  static bool isCpf(String cpf) {
    // get only the numbers
    final numbers = cpf.replaceAll(RegExp('[^0-9]'), '');
    // Test if the CPF has 11 digits
    if (numbers.length != 11) {
      return false;
    }
    // Test if all CPF digits are the same
    if (RegExp(r'^(\d)\1*$').hasMatch(numbers)) {
      return false;
    }

    // split the digits
    final digits = numbers.split('').map(int.parse).toList();

    // Calculate the first verifier digit
    var calcDv1 = 0;
    for (final i in Iterable<int>.generate(9, (i) => 10 - i)) {
      calcDv1 += digits[10 - i] * i;
    }
    calcDv1 %= 11;

    final dv1 = calcDv1 < 2 ? 0 : 11 - calcDv1;

    // Tests the first verifier digit
    if (digits[9] != dv1) {
      return false;
    }

    // Calculate the second verifier digit
    var calcDv2 = 0;
    for (final i in Iterable<int>.generate(10, (i) => 11 - i)) {
      calcDv2 += digits[11 - i] * i;
    }
    calcDv2 %= 11;

    final dv2 = calcDv2 < 2 ? 0 : 11 - calcDv2;

    // Test the second verifier digit
    if (digits[10] != dv2) {
      return false;
    }
    return true;
  }
}

extension TypeExt on Type {
  ///Extracts the base type as [String].
  String get baseString {
    final s = toString();
    final i = s.indexOf('<');

    if (i == -1) return s.lastPascalCaseWord;
    final matches = RegExp('[A-Z][a-z]*').allMatches(s.substring(0, i));

    if (matches.isEmpty) return '';
    final match = matches.last;

    return s.substring(match.start, match.end);
  }

  ///Returns the base of the [Type].
  ///Ex: LinkedHashMap -> Map.
  Type get baseType {
    if (isString) return String;
    if (isMap) return Map;
    if (isList) return List;
    if (isIterable) return Iterable;
    if (isSet) return Set;
    if (isBool) return bool;
    if (isInt) return int;
    if (isDouble) return double;
    if (isNum) return num;
    return Type;
  }

  bool get isString => baseString == 'String';
  bool get isMap => baseString == 'Map';
  bool get isList => baseString == 'List';
  bool get isIterable => baseString == 'Iterable';
  bool get isSet => baseString == 'Set';
  bool get isBool => baseString == 'bool';
  bool get isInt => baseString == 'int';
  bool get isDouble => baseString == 'double';
  bool get isNum => isInt || isDouble;
}
