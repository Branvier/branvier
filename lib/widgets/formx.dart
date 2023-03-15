// ignore_for_file: public_member_api_docs, sort_constructors_first
part of '/branvier.dart';

typedef FieldMap = Map<String, GlobalKey<FormFieldState>>;
typedef FormMap = Map<String, String>;

class FormX extends StatelessWidget {
  const FormX({
    super.key,
    required this.child,
    this.formWrapper,
    this.fieldWrapper,
    this.onChange,
    this.onSubmit,
    this.onErrorText,
    this.decoration,
  });
  final Widget child;

  ///Wrapper for the form.
  final Widget Function(Widget child)? formWrapper;

  ///Wrapper for each field.
  final Widget Function(String tag, Widget child)? fieldWrapper;

  ///Listens to all descendants changes.
  final ValueChanged<FormMap>? onChange;

  ///Submits if all descendants are valid.
  final ValueSetter<FormMap>? onSubmit;

  ///Retunrs the field validator response;
  final String Function(String tag, String error)? onErrorText;

  ///Decorates each [Field] below. You can use tag to differentiate.
  final InputDecoration Function(String tag)? decoration;

  ///Access to [Form].
  static FormState of(BuildContext context) => Form.of(context);

  @override
  Widget build(BuildContext context) {
    return FormScope(
      form: FormMap.from({}),
      fields: FieldMap.from({}),
      onChange: onChange,
      onSubmit: onSubmit,
      onErrorText: onErrorText,
      decoration: decoration,
      fieldWrapper: fieldWrapper,
      child: Form(child: formWrapper?.call(child) ?? child),
    );
  }
}

class FormScope extends InheritedWidget {
  const FormScope({
    super.key,
    required super.child,
    required this.form,
    required this.fields,
    required this.decoration,
    required this.onChange,
    required this.onSubmit,
    required this.onErrorText,
    required this.fieldWrapper,
  });

  final FormMap form;
  final FieldMap fields;
  final InputDecoration Function(String tag)? decoration;
  final ValueChanged<FormMap>? onChange;
  final ValueSetter<FormMap>? onSubmit;
  final String Function(String tag, String error)? onErrorText;
  final Widget Function(String tag, Widget child)? fieldWrapper;

  @override
  bool updateShouldNotify(FormScope oldWidget) => false;
  // bool updateShouldNotify(MapFormScope oldWidget) => form != oldWidget.form;
}

///A TextField that saves all the value changes in MapForm.of(context).
class Field extends StatefulWidget {
  ///Creates a TextField where the value is stored in [tag].
  const Field(
    this.tag, {
    this.obscure = false,
    this.options,
    this.decoration,
    this.validator,
    this.keyboardType,
    this.mask,
    super.key,
  });

  ///Aditionally validates if the value is empty.
  ///Returns 'form.empty.$tag' if requiredText is null.
  ///
  ///You can use [validator] for aditional validations.
  factory Field.required(
    String tag, {
    String? requiredText,
    bool obscure = false,
    List<String>? options,
    InputDecoration? decoration,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
    String? mask,
    Key? key,
  }) =>
      Field(
        tag,
        obscure: obscure,
        options: options,
        decoration: decoration,
        validator: (value) {
          if (value == null) return null;
          if (value.isEmpty) return requiredText ?? 'form.empty.$tag';
          return validator?.call(value);
        },
        keyboardType: keyboardType,
        mask: mask,
        key: key,
      );

  ///Where to store the value in the map. Will always lowercase.
  final String tag;
  final bool obscure;
  final List<String>? options;
  final InputDecoration? decoration;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;

  ///Use # to mask numbers and A to mask letters.
  ///Ex: cpf: ###.###.###-##.
  final String? mask;

  @override
  State<Field> createState() => _FieldState();
}

class _FieldState extends State<Field> {
  final key = GlobalKey<FormFieldState>();
  final ctrl = TextEditingController();
  final focus = FocusNode();
  late var obscure = widget.obscure;

  @override
  Widget build(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FormScope>();
    final dec = scope?.decoration?.call(widget.tag) ?? const InputDecoration();
    final decoration = dec.update(widget.decoration);

    void onChanged(String value) {
      //Assures the map keys to have only lowercases characters.
      scope?.form[widget.tag.toLowerCase()] = value;

      //Cleans map, if empty value.
      if (value.isEmpty) scope?.form.remove(widget.tag);

      //Notifies the owner.
      scope?.onChange?.call(scope.form);
    }

    Widget obscureIcon() {
      return IconButton(
        splashRadius: 20,
        onPressed: () => setState(() => obscure = !obscure),
        icon: Icon(obscure ? CupertinoIcons.eye_slash : CupertinoIcons.eye),
      );
    }

    Widget dropDownIcon() {
      DropdownMenuItem<T> item<T>(T i) =>
          DropdownMenuItem(value: i, child: Text(i.toString()));

      return DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: ctrl.text.isEmpty ? null : ctrl.text,
          onChanged: (i) {
            setState(() => onChanged(ctrl.text = i!));
            focus.requestFocus();
          },
          onTap: () => Future.delayed(Duration.zero, focus.requestFocus),
          items: widget.options!.map(item).toList(),
          selectedItemBuilder: (_) =>
              widget.options!.map((_) => const SizedBox.shrink()).toList(),
          isDense: true,
          borderRadius: BorderRadius.circular(8),
          icon: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.arrow_drop_down),
          ),
        ),
      );
    }

    Widget? icon() {
      if (widget.obscure) return obscureIcon();
      if (widget.options != null) return dropDownIcon();
      return null;
    }

    final field = TextFormField(
      focusNode: focus,
      readOnly: widget.options != null,
      controller: ctrl,
      inputFormatters: [MaskTextInputFormatter(mask: widget.mask)],
      keyboardType: widget.keyboardType,
      key: scope?.fields[widget.tag] = key,
      obscureText: obscure,
      obscuringCharacter: '*',
      onChanged: widget.options == null ? onChanged : null,
      validator: (value) {
        final errorText = widget.validator?.call(value);
        if (errorText == null) return null;

        //Called only when there is an errorText.
        return scope?.onErrorText?.call(widget.tag, errorText);
      },
      onFieldSubmitted: (_) {
        if (Form.of(context).validate()) scope?.onSubmit?.call(scope.form);
      },
      decoration: decoration.copyWith(suffixIcon: icon()),
    );

    //Field wrapper.
    return scope?.fieldWrapper?.call(widget.tag, field) ?? field;
  }
}

extension FormExt on FormState {
  FormScope get _scope {
    final scope = context.dependOnInheritedWidgetOfExactType<FormScope>();
    assert(scope != null, 'No [FormX] was found in the widget tree.');
    return scope!;
  }

  ///Gets a [FormMap] containing all values from all descendents [Field].
  FormMap get form => _scope.form;

  ///Validates all the field with the enclosing [tags].
  bool validateTags(List<String> tags) {
    final areValid = tags.map(validateTag);
    return !areValid.contains(false);
  }

  ///Validates only the field with the enclosing [tag].
  bool validateTag(String tag) {
    return _scope.fields[tag]?.currentState?.validate() ?? false;
  }

  ///Validates one, two or all fields. Returns [FormMap] on success.
  FormMap? submit([List<String>? tags]) {
    final isValid = tags == null ? validate() : validateTags(tags);
    return isValid ? form : null;
  }
}

extension InputExt on InputDecoration {
  ///Updates all the fields, if any.
  InputDecoration update(InputDecoration? decoration) {
    return InputDecoration(
      icon: decoration?.icon ?? icon,
      iconColor: decoration?.iconColor ?? iconColor,
      label: decoration?.label ?? label,
      labelText: decoration?.labelText ?? labelText,
      labelStyle: decoration?.labelStyle ?? labelStyle,
      floatingLabelStyle: decoration?.floatingLabelStyle ?? floatingLabelStyle,
      helperText: decoration?.helperText ?? helperText,
      helperStyle: decoration?.helperStyle ?? helperStyle,
      helperMaxLines: decoration?.helperMaxLines ?? helperMaxLines,
      hintText: decoration?.hintText ?? hintText,
      hintStyle: decoration?.hintStyle ?? hintStyle,
      hintTextDirection: decoration?.hintTextDirection ?? hintTextDirection,
      hintMaxLines: decoration?.hintMaxLines ?? hintMaxLines,
      errorText: decoration?.errorText ?? errorText,
      errorStyle: decoration?.errorStyle ?? errorStyle,
      errorMaxLines: decoration?.errorMaxLines ?? errorMaxLines,
      floatingLabelBehavior:
          decoration?.floatingLabelBehavior ?? floatingLabelBehavior,
      floatingLabelAlignment:
          decoration?.floatingLabelAlignment ?? floatingLabelAlignment,
      isCollapsed: decoration?.isCollapsed ?? isCollapsed,
      isDense: decoration?.isDense ?? isDense,
      contentPadding: decoration?.contentPadding ?? contentPadding,
      prefixIcon: decoration?.prefixIcon ?? prefixIcon,
      prefix: decoration?.prefix ?? prefix,
      prefixText: decoration?.prefixText ?? prefixText,
      prefixStyle: decoration?.prefixStyle ?? prefixStyle,
      prefixIconColor: decoration?.prefixIconColor ?? prefixIconColor,
      prefixIconConstraints:
          decoration?.prefixIconConstraints ?? prefixIconConstraints,
      suffixIcon: decoration?.suffixIcon ?? suffixIcon,
      suffix: decoration?.suffix ?? suffix,
      suffixText: decoration?.suffixText ?? suffixText,
      suffixStyle: decoration?.suffixStyle ?? suffixStyle,
      suffixIconColor: decoration?.suffixIconColor ?? suffixIconColor,
      suffixIconConstraints:
          decoration?.suffixIconConstraints ?? suffixIconConstraints,
      counter: decoration?.counter ?? counter,
      counterText: decoration?.counterText ?? counterText,
      counterStyle: decoration?.counterStyle ?? counterStyle,
      filled: decoration?.filled ?? filled,
      fillColor: decoration?.fillColor ?? fillColor,
      focusColor: decoration?.focusColor ?? focusColor,
      hoverColor: decoration?.hoverColor ?? hoverColor,
      errorBorder: decoration?.errorBorder ?? errorBorder,
      focusedBorder: decoration?.focusedBorder ?? focusedBorder,
      focusedErrorBorder: decoration?.focusedErrorBorder ?? focusedErrorBorder,
      disabledBorder: decoration?.disabledBorder ?? disabledBorder,
      enabledBorder: decoration?.enabledBorder ?? enabledBorder,
      border: decoration?.border ?? border,
      enabled: decoration?.enabled ?? enabled,
      semanticCounterText:
          decoration?.semanticCounterText ?? semanticCounterText,
      alignLabelWithHint: decoration?.alignLabelWithHint ?? alignLabelWithHint,
      constraints: decoration?.constraints ?? constraints,
    );
  }
}

enum MaskAutoCompletionType {
  lazy,
  eager,
}

class MaskTextInputFormatter implements TextInputFormatter {
  final MaskAutoCompletionType type;

  String? _mask;
  List<String> _maskChars = [];
  Map<String, RegExp>? _maskFilter;

  int _maskLength = 0;
  final _TextMatcher _resultTextArray = _TextMatcher();
  String _resultTextMasked = '';

  TextEditingValue? _lastResValue;
  TextEditingValue? _lastNewValue;

  /// Create the [mask] formatter for TextField
  ///
  /// The keys of the [filter] assign which character in the mask should be
  /// replaced and the values validate the entered character
  /// By default `#` match to the number and `A` to the letter
  ///
  /// Set [type] for autocompletion behavior:
  ///  - [MaskAutoCompletionType.lazy] (default): autocomplete unfiltered
  /// characters once the following filtered character is input.
  ///  For example, with the mask "#/#" and the sequence of characters "1" then
  /// "2", the formatter will output "1", then "1/2"
  ///  - [MaskAutoCompletionType.eager]: autocomplete unfiltered characters when
  ///  the previous filtered character is input.
  ///  For example, with the mask "#/#" and the sequence of characters "1" then
  /// "2", the formatter will output "1/", then "1/2"
  MaskTextInputFormatter({
    String? mask,
    Map<String, RegExp>? filter,
    String? initialText,
    this.type = MaskAutoCompletionType.lazy,
  }) {
    updateMask(
      mask: mask,
      filter: filter ?? {'#': RegExp('[0-9]'), 'A': RegExp('[^0-9]')},
    );
    if (initialText != null) {
      formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue(text: initialText),
      );
    }
  }

  /// Change the mask
  TextEditingValue updateMask({String? mask, Map<String, RegExp>? filter}) {
    _mask = mask;
    if (filter != null) {
      _updateFilter(filter);
    }
    _calcMaskLength();
    final unmaskedText = getUnmaskedText();
    clear();
    return formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(
        text: unmaskedText,
        selection: TextSelection.collapsed(offset: unmaskedText.length),
      ),
    );
  }

  /// Get current mask
  String? getMask() {
    return _mask;
  }

  /// Get masked text, e.g. "+0 (123) 456-78-90"
  String getMaskedText() {
    return _resultTextMasked;
  }

  /// Get unmasked text, e.g. "01234567890"
  String getUnmaskedText() {
    return _resultTextArray.toString();
  }

  /// Check if target mask is filled
  bool isFill() {
    return _resultTextArray.length == _maskLength;
  }

  /// Clear masked text of the formatter
  /// Note: you need to call this method if you clear the text of the TextField
  /// because it doesn't call the formatter when it has empty text
  void clear() {
    _resultTextMasked = '';
    _resultTextArray.clear();
    _lastResValue = null;
    _lastNewValue = null;
  }

  /// Mask some text
  String maskText(String text) {
    return MaskTextInputFormatter(
      mask: _mask,
      filter: _maskFilter,
      initialText: text,
    ).getMaskedText();
  }

  /// Unmask some text
  String unmaskText(String text) {
    return MaskTextInputFormatter(
      mask: _mask,
      filter: _maskFilter,
      initialText: text,
    ).getUnmaskedText();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (_lastResValue == oldValue && newValue == _lastNewValue) {
      return oldValue;
    }
    if (oldValue.text.isEmpty) {
      _resultTextArray.clear();
    }
    _lastNewValue = newValue;
    return _lastResValue = _format(oldValue, newValue);
  }

  TextEditingValue _format(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final mask = _mask;

    if (mask == null || mask.isEmpty == true) {
      _resultTextMasked = newValue.text;
      _resultTextArray.set(newValue.text);
      return newValue;
    }

    final beforeText = oldValue.text;
    final afterText = newValue.text;

    final beforeSelection = oldValue.selection;
    final afterSelection = newValue.selection;

    final beforeSelectionStart = afterSelection.isValid
        ? beforeSelection.isValid
            ? beforeSelection.start
            : 0
        : 0;
    final beforeSelectionLength = afterSelection.isValid
        ? beforeSelection.isValid
            ? beforeSelection.end - beforeSelection.start
            : 0
        : oldValue.text.length;

    final lengthDifference =
        afterText.length - (beforeText.length - beforeSelectionLength);
    final lengthRemoved = lengthDifference < 0 ? lengthDifference.abs() : 0;
    final lengthAdded = lengthDifference > 0 ? lengthDifference : 0;

    final afterChangeStart = math.max(0, beforeSelectionStart - lengthRemoved);
    final afterChangeEnd = math.max(0, afterChangeStart + lengthAdded);

    final beforeReplaceStart =
        math.max(0, beforeSelectionStart - lengthRemoved);
    final beforeReplaceLength = beforeSelectionLength + lengthRemoved;

    final beforeResultTextLength = _resultTextArray.length;

    var currentResultTextLength = _resultTextArray.length;
    var currentResultSelectionStart = 0;
    var currentResultSelectionLength = 0;

    for (var i = 0;
        i < math.min(beforeReplaceStart + beforeReplaceLength, mask.length);
        i++) {
      if (_maskChars.contains(mask[i]) && currentResultTextLength > 0) {
        currentResultTextLength -= 1;
        if (i < beforeReplaceStart) {
          currentResultSelectionStart += 1;
        }
        if (i >= beforeReplaceStart) {
          currentResultSelectionLength += 1;
        }
      }
    }

    final replacementText =
        afterText.substring(afterChangeStart, afterChangeEnd);
    var targetCursorPosition = currentResultSelectionStart;
    if (replacementText.isEmpty) {
      _resultTextArray.removeRange(
        currentResultSelectionStart,
        currentResultSelectionStart + currentResultSelectionLength,
      );
    } else {
      if (currentResultSelectionLength > 0) {
        _resultTextArray.removeRange(
          currentResultSelectionStart,
          currentResultSelectionStart + currentResultSelectionLength,
        );
      }
      _resultTextArray.insert(currentResultSelectionStart, replacementText);
      targetCursorPosition += replacementText.length;
    }

    if (beforeResultTextLength == 0 && _resultTextArray.length > 1) {
      for (var i = 0; i < mask.length; i++) {
        if (_maskChars.contains(mask[i])) {
          final resultPrefix = _resultTextArray._symbolArray.take(i).toList();
          for (var j = 0; j < resultPrefix.length; j++) {
            if (_resultTextArray.length <= j ||
                (mask[j] != resultPrefix[j] ||
                    (mask[j] == resultPrefix[j] &&
                        j == resultPrefix.length - 1))) {
              _resultTextArray.removeRange(0, j);
              break;
            }
          }
          break;
        }
      }
    }

    var curTextPos = 0;
    var maskPos = 0;
    _resultTextMasked = '';
    var cursorPos = -1;
    var nonMaskedCount = 0;

    while (maskPos < mask.length) {
      final curMaskChar = mask[maskPos];
      final isMaskChar = _maskChars.contains(curMaskChar);

      var curTextInRange = curTextPos < _resultTextArray.length;

      String? curTextChar;
      if (isMaskChar && curTextInRange) {
        while (curTextChar == null && curTextInRange) {
          final potentialTextChar = _resultTextArray[curTextPos];
          if (_maskFilter?[curMaskChar]?.hasMatch(potentialTextChar) ?? false) {
            curTextChar = potentialTextChar;
          } else {
            _resultTextArray.removeAt(curTextPos);
            curTextInRange = curTextPos < _resultTextArray.length;
            if (curTextPos <= targetCursorPosition) {
              targetCursorPosition -= 1;
            }
          }
        }
      } else if (!isMaskChar &&
          !curTextInRange &&
          type == MaskAutoCompletionType.eager) {
        curTextInRange = true;
      }

      if (isMaskChar && curTextInRange && curTextChar != null) {
        _resultTextMasked += curTextChar;
        if (curTextPos == targetCursorPosition && cursorPos == -1) {
          cursorPos = maskPos - nonMaskedCount;
        }
        nonMaskedCount = 0;
        curTextPos += 1;
      } else {
        if (curTextPos == targetCursorPosition &&
            cursorPos == -1 &&
            !curTextInRange) {
          cursorPos = maskPos;
        }

        if (!curTextInRange) {
          break;
        } else {
          _resultTextMasked += mask[maskPos];
        }

        if (type == MaskAutoCompletionType.lazy || lengthRemoved > 0) {
          nonMaskedCount++;
        }
      }

      maskPos += 1;
    }

    if (nonMaskedCount > 0) {
      _resultTextMasked = _resultTextMasked.substring(
        0,
        _resultTextMasked.length - nonMaskedCount,
      );
      cursorPos -= nonMaskedCount;
    }

    if (_resultTextArray.length > _maskLength) {
      _resultTextArray.removeRange(_maskLength, _resultTextArray.length);
    }

    final finalCursorPosition =
        cursorPos < 0 ? _resultTextMasked.length : cursorPos;

    return TextEditingValue(
      text: _resultTextMasked,
      selection: TextSelection(
        baseOffset: finalCursorPosition,
        extentOffset: finalCursorPosition,
        affinity: newValue.selection.affinity,
        isDirectional: newValue.selection.isDirectional,
      ),
    );
  }

  void _calcMaskLength() {
    _maskLength = 0;
    final mask = _mask;
    if (mask != null) {
      for (var i = 0; i < mask.length; i++) {
        if (_maskChars.contains(mask[i])) {
          _maskLength++;
        }
      }
    }
  }

  void _updateFilter(Map<String, RegExp> filter) {
    _maskFilter = filter;
    _maskChars = _maskFilter?.keys.toList(growable: false) ?? [];
  }
}

class _TextMatcher {
  final List<String> _symbolArray = <String>[];
  int get length => _symbolArray.fold(0, (prev, match) => prev + match.length);
  void removeRange(int start, int end) => _symbolArray.removeRange(start, end);
  void insert(int start, String substring) {
    for (var i = 0; i < substring.length; i++) {
      _symbolArray.insert(start + i, substring[i]);
    }
  }

  bool get isEmpty => _symbolArray.isEmpty;
  void removeAt(int index) => _symbolArray.removeAt(index);
  String operator [](int index) => _symbolArray[index];
  void clear() => _symbolArray.clear();
  @override
  String toString() => _symbolArray.join();

  void set(String text) {
    _symbolArray.clear();
    for (var i = 0; i < text.length; i++) {
      _symbolArray.add(text[i]);
    }
  }
}

void main() => runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppDropdownInput(
              options: const ['test', 'sss', 'aaa'],
              value: 'test',
              onChanged: (test) {},
            ),
          ),
        ),
      ),
    );

class AppDropdownInput<T> extends StatelessWidget {
  final String hintText;
  final List<T> options;
  final T value;
  final String Function(T)? getLabel;
  final void Function(T?)? onChanged;

  const AppDropdownInput({
    this.hintText = 'Please select an Option',
    this.options = const [],
    this.getLabel,
    required this.value,
    this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      builder: (state) {
        return InputDecorator(
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
            labelText: hintText,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
          ),
          isEmpty: value == null || value == '',
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isDense: true,
              onChanged: onChanged,
              items: options.map((value) {
                return DropdownMenuItem<T>(
                  value: value,
                  child: Text(getLabel?.call(value) ?? value.toString()),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
