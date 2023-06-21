// ignore_for_file: use_setters_to_change_properties

part of 'rx_button.dart';

class RxElevatedButton extends RxButton<ElevatedButton> {
  static ButtonConfig? _config;

  /// The default [ButtonConfig] for [RxElevatedButton].
  static void setConfig(ButtonConfig config) => _config = config;

  const RxElevatedButton({
    //Extended.
    super.config,
    super.listenables,

    //Base.
    super.key,
    required super.onPressed,
    super.onLongPress,
    super.onHover,
    super.onFocusChange,
    super.style,
    super.focusNode,
    super.autofocus,
    super.clipBehavior,
    super.statesController,
    required super.child,
  });
}

class RxOutlinedButton extends RxButton<OutlinedButton> {
  static ButtonConfig? _config;

  /// The default [ButtonConfig] for [RxOutlinedButton].
  static void setConfig(ButtonConfig config) => _config = config;

  const RxOutlinedButton({
    //Extended.
    super.config,
    super.listenables,

    //Base.
    super.key,
    required super.onPressed,
    super.onLongPress,
    super.onHover,
    super.onFocusChange,
    super.style,
    super.focusNode,
    super.autofocus,
    super.clipBehavior,
    super.statesController,
    required super.child,
  });
}

class RxTextButton extends RxButton<TextButton> {
  static ButtonConfig? _config;

  /// The default [ButtonConfig] for [RxTextButton].
  static void setConfig(ButtonConfig config) => _config = config;

  const RxTextButton({
    //Extended.
    super.config,
    super.listenables,

    //Base.
    super.key,
    required super.onPressed,
    super.onLongPress,
    super.onHover,
    super.onFocusChange,
    super.style,
    super.focusNode,
    super.autofocus,
    super.clipBehavior,
    super.statesController,
    required super.child,
  });
}

class RxFilledButton extends RxButton<FilledButton> {
  static ButtonConfig? _config;

  /// The default [ButtonConfig] for [RxFilledButton].
  static void setConfig(ButtonConfig config) => _config = config;

  const RxFilledButton({
    //Extended.
    super.config,
    super.listenables,

    //Base.
    super.key,
    required super.onPressed,
    super.onLongPress,
    super.onHover,
    super.onFocusChange,
    super.style,
    super.focusNode,
    super.autofocus,
    super.clipBehavior,
    super.statesController,
    required super.child,
  });
}
