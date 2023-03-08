extension Validators on String {
  bool get hasUppercase => RegExp('[A-Z]').hasMatch(this);
  bool get hasLowercase => RegExp('[a-z]').hasMatch(this);
  bool get hasNumber => RegExp('[0-9]').hasMatch(this);
  bool get hasSpecial => RegExp(r'[!@#\$&*~]').hasMatch(this);
  bool get isLength8 => length >= 6;
  bool get isPassword => hasNumber && isLength8;

  static String? password(String? text) => text?.test(text.isPassword, true);
  // static String? email(String? text) => text?.test(text.isEmail, true);
  // static String? cpf(String? text) => text?.test(text.isCpf, true);

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
