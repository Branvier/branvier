// ignore_for_file: use_setters_to_change_properties

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'animated_button_style_mixin.dart';

part 'rx_button_config.dart';
part 'rx_button_impl.dart';
part 'rx_button_style.dart';

abstract class RxButton<T extends ButtonStyleButton> extends ButtonStyleButton {
  static var _config = const ButtonConfig();

  /// The default [ButtonConfig] of all RxButton's.
  static void setConfig(ButtonConfig config) => _config = config;

  const RxButton({
    //Extended.
    this.config,
    this.listenables = const [],

    //RxButton.
    super.key,
    required super.onPressed,
    super.onLongPress,
    super.onHover,
    super.onFocusChange,
    super.style,
    super.focusNode,
    super.autofocus = false,
    super.clipBehavior = Clip.none,
    super.statesController,
    required super.child,
  });

  /// Le configs of [RxButton]. Prefer setting RxButton<Type>.setConfig().
  final ButtonConfig? config;

  /// Animates whenever the notifier callbacks true.
  final List<ValueListenable> listenables;

  @override
  State<RxButton<T>> createState() => RxButtonState<T>();

  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    if (this is RxButton<OutlinedButton>) {
      return const OutlinedButton(onPressed: null, child: Text(''))
          .defaultStyleOf(context);
    }
    if (this is RxButton<FilledButton>) {
      return const FilledButton(onPressed: null, child: Text(''))
          .defaultStyleOf(context);
    }
    if (this is RxButton<TextButton>) {
      return const TextButton(onPressed: null, child: Text(''))
          .defaultStyleOf(context);
    }
    return const ElevatedButton(onPressed: null, child: Text(''))
        .defaultStyleOf(context);
  }

  @override
  ButtonStyle? themeStyleOf(BuildContext context) {
    if (this is RxButton<OutlinedButton>) {
      return OutlinedButtonTheme.of(context).style;
    }
    if (this is RxButton<FilledButton>) {
      return FilledButtonTheme.of(context).style;
    }
    if (this is RxButton<TextButton>) return TextButtonTheme.of(context).style;
    return ElevatedButtonTheme.of(context).style;
  }
}

class RxButtonState<T extends ButtonStyleButton> extends State<RxButton<T>>
    with TickerProviderStateMixin, AnimatedButtonStyleMixin<RxButton<T>> {
  /// Resolves the default [ButtonConfig] of this [T].
  ButtonConfig? get _config {
    final config = () {
      if (isFilledButton) return RxFilledButton._config;
      if (isOutlinedButton) return RxOutlinedButton._config;
      if (isTextButton) return RxTextButton._config;
      return RxElevatedButton._config;
    }();

    final theme = widget.themeStyleOf(context);
    return config ?? (theme is RxButtonStyle ? theme.config : null);
  }

  // State variables.
  double? _loadingProgress;
  var _isLoading = false;
  var _isOnError = false;
  var _isOnHover = false;
  Object? _error;
  StackTrace? _stackTrace;

  /// The current [ButtonConfig] of this button.
  ButtonConfig get config => widget.config ?? _config ?? RxButton._config;

  // Button state getters.
  bool get isElevatedButton => this is RxButtonState<ElevatedButton>;
  bool get isFilledButton => this is RxButtonState<FilledButton>;
  bool get isOutlinedButton => this is RxButtonState<OutlinedButton>;
  bool get isTextButton => this is RxButtonState<TextButton>;

  // State check getters.
  bool get isLoading => _isLoading && hasSize;
  bool get isOnError => _isOnError && hasSize;
  bool get isHovering => _isOnHover && hasSize;
  bool get isAnimating => isOnError || isLoading;
  double? get loadingProgress => _loadingProgress;

  // Error getters.
  Object? get error => _error;
  StackTrace? get stackTrace => _stackTrace;
  String get errorMessage {
    try {
      return (error as dynamic).message;
    } catch (_) {
      return error.toString();
    }
  }

  /// The child of this button.
  Widget get child => widget.child!;

  /// Same [setState], but with [mounted].
  void _setState(VoidCallback action) {
    if (!mounted) return;
    setState(action);
    changeButtonStyle(_buttonStyle());
  }

  var _loadingMessages = <String>[];

  String get loadingMessage {
    return _loadingMessages.firstWhere((e) => e.isNotEmpty, orElse: () => '');
  }

  void _setLoading() {
    final values = widget.listenables.map((listener) => listener.value);

    // Sets the loading.
    if (!_settingAction) {
      _isLoading = values.any((value) => value == true);
    }

    // Sets the loading progress.
    _loadingProgress = () {
      final nums = values.whereType<num>();
      if (nums.isEmpty) return null;

      return nums.reduce((a, b) => a + b) / nums.length; //mean
    }();

    // Looks for the last message set.
    _loadingMessages = values
        .whereType<String>()
        .where((e) => !_loadingMessages.contains(e))
        .toList();

    _setState(() {});
  }

  /// Triggers onPressed and animations.
  FutureOr<void> press() {
    if (widget.onPressed != null) return setAction(widget.onPressed!);
  }

  /// Triggers onLongPress and animations.
  FutureOr<void> longPress() {
    if (widget.onLongPress != null) return setAction(widget.onLongPress!);
  }

  var _settingAction = false;

  /// Performs custom [action] and trigger animations.
  FutureOr<void> setAction(FutureOr<void> action()) async {
    // Cancels if busy or not ready.
    if (_settingAction || !mounted) return;
    _settingAction = true;

    // Clean resources.
    _error = _stackTrace = null;

    try {
      _setState(() => _isLoading = true);
      await action(); // * <------------------ action callback
    } catch (e, s) {
      _setState(() => _isOnError = true);
      _stackTrace = s;
      _error = e;
    } finally {
      _setState(() => _isLoading = false);
      _loadingMessages.clear();

      if (mounted) await Future.delayed(config.errorDuration);
      _setState(() => _isOnError = false);
      _settingAction = false;
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _size ??= context.size;
      controller.duration = config.styleDuration;
      animation.curve = Curves.fastOutSlowIn;

      for (var notifier in widget.listenables) {
        notifier.addListener(_setLoading);
      }
      _setLoading();
    });
  }

  ButtonStyle _buttonStyle() {
    if (isOnError) return config.errorStyle(this);
    if (isLoading) return config.loadingStyle(this);
    if (isHovering) return config.hoverStyle?.call(this) ?? initialStyle;
    return initialStyle;
  }

  @override
  void dispose() {
    for (var listenable in widget.listenables) {
      listenable.removeListener(_setLoading);
    }
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();

    // Checks listenables on hot reload.
    WidgetsBinding.instance.addPostFrameCallback((_) => _setLoading());
  }

  /// We wait first build size before any animation.
  bool get hasSize => _size != null;

  /// This button [Size] when not animating.
  Size get size => _size!;
  Size? _size;

  @override
  Widget build(BuildContext context) {
    // Whether to use the animated size.
    Widget animatedSize({required Widget child}) {
      if (config.animatedSize == null) return child;

      return AnimatedSize(
        curve: config.animatedSize!.curve,
        duration: config.animatedSize!.duration,
        alignment: config.animatedSize!.alignment,
        clipBehavior: config.animatedSize!.clipBehavior,
        reverseDuration: config.animatedSize!.reverseDuration,
        child: child,
      );
    }

    return SizedBox.fromSize(
      size: config.keepSize ? _size : null,
      child: () {
        if (isOutlinedButton) return OutlinedButton.new;
        if (isFilledButton) return FilledButton.new;
        if (isTextButton) return TextButton.new;
        return ElevatedButton.new;
      }()(
        style: animatedStyle,
        child: animatedSize(
          child: () {
            if (isOnError) return config.onError(this);
            if (isLoading) return config.onLoading(this);
            if (isHovering) return config.onHover?.call(this) ?? child;
            return child;
          }(),
        ),
        onHover: (hover) {
          _isOnHover = hover;
          widget.onHover?.call(hover);
          if (config.onHover != null) _setState(() {});
        },
        onLongPress: widget.onLongPress != null ? longPress : null,
        onPressed: widget.onPressed != null ? press : null,
        statesController: widget.statesController,
        onFocusChange: widget.onFocusChange,
        clipBehavior: widget.clipBehavior,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        key: widget.key,
      ),
    );
  }
}
