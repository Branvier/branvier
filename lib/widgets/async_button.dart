// ignore_for_file: use_setters_to_change_properties

part of '../branvier.dart';

void main() {
  // timeDilation = 4;
  LeButton.setConfig(ButtonConfig(
      delegate: LeButtonCollapsable(), onLoading: CircularProgressIndicator()));
  runApp(MaterialApp(home: Scaffold(body: Buttons())));
}

Future<void> fakeThrow() async {
  await 5.seconds.delay;
  // print('fui chamado');
  // ignore: only_throw_errors
  throw '1234512345123451234512345123456';
}

class Buttons extends HookWidget {
  Buttons({Key? key}) : super(key: key);
  final ctrl = ButtonController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LeFilledButton(
          onPressed: () async {
            await 3.seconds.delay;
          },
          child: Text('lets go00000')),
    );
    return Theme(
      data: ThemeData(
          // visualDensity: VisualDensity.adaptivePlatformDensity,

          ),
      child: FormX.tr(
        onSubmit: (form) async {
          await 3.seconds.delay;
        },
        child: ListView(
          children: [
            Field.required('test', validator: Validators.email),
            Field.required('a'),
            Field.required('b'),
            Field.required('c'),
            Field.required('d'),
            Field.required('e'),
            Field.required('f'),
            const ElevatedButtonX(
              // hasFormX: true, // todo: looses bind on hot reload.
              onPressed: fakeThrow,
              onLongPress: fakeThrow,
              // onHover: (isHovering) async => fun(),
              // on: fun,
              child: SizedBox.shrink(),
              // error: Text.new,
            ),
            const ColoredBox(
              color: Colors.red,
              child: SizedBox.square(
                dimension: 60,
              ),
            ),
            const OutlinedButtonX(
              // hasFormX: true,

              onPressed: fakeThrow,
              onLongPress: fakeThrow,
              child: Text('Iran Neto'),
              // error: (_) => Text('Falha ao logar, tente mais tarde'),
            ),
            LeButton(
              onPressed: () async {
                await 3.seconds.delay;
              },
              child: const Text('Juan Alesson'),
            ),
            ElevatedButton(onPressed: ctrl.tap, child: const Text('tap'))
          ],
        ),
      ),
    );
  }
}

class ButtonController {
  ButtonController({
    this.animationDuration = const Duration(milliseconds: 600),
    this.errorDuration = const Duration(seconds: 5),
  });
  final Duration animationDuration;
  final Duration errorDuration;
  StackTrace? _stackTrace;
  Object? _error;

  FutureOr Function()? _press;
  FutureOr Function()? _longPress;
  FutureOr Function(bool value)? _hover;
  ValueNotifier<bool>? _isLoading;
  ValueNotifier<bool>? _hasError;
  var _hovering = false;

  ///Performs press programatically.
  void tap() {
    if (hasError) error.toString().copyToClipboard();
    _animate(_press);
  }

  ///Performs longPress programatically.
  void hold() => _animate(_longPress);

  ///Performs hover programatically.
  void hover([bool isHovering = true]) => _hover?.call(_hovering = isHovering);

  ///Starts animating the button.
  void _animate(FutureOr action()?) async {
    _stackTrace = _error = null;

    if (isLoading || hasError) return;
    try {
      _isLoading?.value = true;
      await action?.call();
      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      _hasError?.value = true;
      _error = e;
      _stackTrace = s;
    } finally {
      _isLoading?.value = false;
      await errorDuration.delay;
      _hasError?.value = false;
    }
  }

  ///Tell if the button is currently loading.
  bool get isLoading => _isLoading?.value ?? false;

  ///Tell if the button catched an exception.
  bool get hasError => _hasError?.value ?? false;

  //Errors.
  Object? get error => _error;
  StackTrace? get stackTrace => _stackTrace;
  String get errorStack => 'Error: $error \n\nStack: $stackTrace';

  ///Tell if the button is animating.
  bool get isAnimating => isLoading || hasError;
  bool get isEnabled => !isLoading || !hasError;

  ///Tell if this button is being hovered.
  bool get isHovering => _hovering;
}

///Hook for listening [FormX] loading state.
void useFormxLoading(bool hasFormX, void onChange(bool isLoading)) {
  final context = useContext();
  final formx = useFinal(
    hasFormX ? context.dependOnInheritedWidgetOfExactType<FormScope>() : null,
  );

  if (hasFormX && formx == null) dev.log('No Formx above this button!');

  void onLoading() => onChange(formx!.isLoading.value);

  useInit(
    () => formx?.isLoading.addListener(onLoading),
    dispose: () => formx?.isLoading.removeListener(onLoading),
  );
}

///Native [ElevatedButton] with animations for [loader] and [error].
///
///Use [ButtonController] to tap programatically.
class ElevatedButtonX extends HookWidget {
  const ElevatedButtonX({
    //Extended.
    this.controller,
    this.hasFormx = false,
    this.error = Text.new,
    this.errorLength = 30,
    this.loader = const CircularProgressIndicator(color: Colors.white),

    //ElevatedButton.
    Key? key,
    required this.onPressed,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
    this.statesController,
    required this.child,
  }) : super(key: key);

  //Same as [ElevatedButton].
  final FutureOr<void> Function()? onPressed;
  final FutureOr Function()? onLongPress;
  final FutureOr Function(bool isHovering)? onHover;
  final void Function(bool value)? onFocusChange;
  final ButtonStyle? style;
  final FocusNode? focusNode;
  final Clip clipBehavior;
  final bool autofocus;
  final MaterialStatesController? statesController;
  final Widget child;

  ///Controls this button programatically. -> controller.tap().
  final ButtonController? controller;

  ///In the presence of a [FormX] above, animates loading.
  final bool hasFormx;

  ///The widget to show on loading.
  final Widget loader;

  ///The widget with error as string.
  final Widget Function(String e) error;

  ///The length limit of characters allowed in this error.
  final int errorLength;
  @override
  Widget build(BuildContext context) {
    final ctrl = useFinal(controller ?? ButtonController());
    ctrl._isLoading = useState(false);
    ctrl._hasError = useState(false);
    ctrl._press = onPressed;
    ctrl._longPress = onLongPress;
    ctrl._hover = onHover;

    useFormxLoading(hasFormx, (value) => ctrl._isLoading?.value = value);

    final animationStyle = ElevatedButton.styleFrom(
      minimumSize: Size.zero,
      padding: EdgeInsets.zero,
      backgroundColor: ctrl.hasError ? context.colors.error : null,
    );

    return ElevatedButton(
      key: key,
      onPressed: (onPressed != null && ctrl.isEnabled) ? ctrl.tap : null,
      onLongPress: (onLongPress != null && ctrl.isEnabled) ? ctrl.hold : null,
      onHover: ctrl.hover,
      autofocus: autofocus,
      clipBehavior: clipBehavior,
      focusNode: focusNode,
      onFocusChange: onFocusChange,
      statesController: statesController,

      //inherited style
      style: animationStyle.merge(style),

      //load animation
      child: _ButtonAnimations(
        loader: loader,
        style: style ?? context.theme.elevatedButtonTheme.style,
        ctrl: ctrl,
        error: error,
        errorLength: errorLength,
        child: child,
      ),
    );
  }
}

///Native [OutlinedButton] with animations for [loader] and [error].
///
///Use [ButtonController] to tap programatically.
class OutlinedButtonX extends HookWidget {
  const OutlinedButtonX({
    //Extended.
    this.controller,
    this.hasFormx = false,
    this.error = Text.new, //!
    this.errorLength = 30,
    this.loader = const CircularProgressIndicator(),

    //ElevatedButton.
    Key? key,
    required this.onPressed,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
    this.statesController,
    required this.child,
  }) : super(key: key);

  //Same as [ElevatedButton].
  final FutureOr<void> Function()? onPressed;
  final FutureOr Function()? onLongPress;
  final FutureOr Function(bool isHovering)? onHover;
  final void Function(bool value)? onFocusChange;
  final ButtonStyle? style;
  final FocusNode? focusNode;
  final Clip clipBehavior;
  final bool autofocus;
  final MaterialStatesController? statesController;
  final Widget child;

  ///Controls this button programatically. -> controller.tap().
  final ButtonController? controller;

  ///In the presence of a [FormX] above, animates loading.
  final bool hasFormx;

  ///The widget to show on loading.
  final Widget loader;

  ///The widget with error as string.
  final Widget Function(String e) error;

  ///The length limit of characters allowed in this error.
  final int errorLength;
  @override
  Widget build(BuildContext context) {
    final ctrl = useFinal(controller ?? ButtonController());
    ctrl._isLoading = useState(false);
    ctrl._hasError = useState(false);
    ctrl._press = onPressed;
    ctrl._longPress = onLongPress;
    ctrl._hover = onHover;

    //Formx inherited
    useFormxLoading(hasFormx, (value) => ctrl._isLoading?.value = value);

    //Theme inherited.
    final side = context.theme.outlinedButtonTheme.style?.side?.resolve({});
    final errorSide = BorderSide(color: context.colors.error).copyWith(
      width: side?.width,
      style: side?.style,
      strokeAlign: side?.strokeAlign,
    );

    //Loading theme merged with inherited.
    final resolvedStyle = OutlinedButton.styleFrom(
      minimumSize: Size.zero,
      padding: EdgeInsets.zero,
      foregroundColor: ctrl.hasError ? context.colors.error : null,
      side: ctrl.hasError ? errorSide : null,
    ).merge(style);

    return OutlinedButton(
      key: key,
      onPressed: (onPressed != null && ctrl.isEnabled) ? ctrl.tap : null,
      onLongPress: (onLongPress != null && ctrl.isEnabled) ? ctrl.hold : null,
      onHover: ctrl.hover,
      autofocus: autofocus,
      clipBehavior: clipBehavior,
      focusNode: focusNode,
      onFocusChange: onFocusChange,
      statesController: statesController,

      //inherited style
      style: resolvedStyle,

      //load animation
      child: _ButtonAnimations(
        loader: loader,
        style: style ?? context.theme.outlinedButtonTheme.style,
        ctrl: ctrl,
        error: error,
        errorLength: errorLength,
        child: child,
      ),
    );
  }
}

///Native [TextButton] with animations for [loader] and [error].
///
///Use [ButtonController] to tap programatically.
class TextButtonX extends HookWidget {
  const TextButtonX({
    //Extended.
    this.controller,
    this.hasFormx = false,
    this.error = Text.new, //!
    this.errorLength = 30,
    this.loader = const CircularProgressIndicator(),

    //ElevatedButton.
    Key? key,
    required this.onPressed,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
    this.statesController,
    required this.child,
  }) : super(key: key);

  //Same as [ElevatedButton].
  final FutureOr<void> Function()? onPressed;
  final FutureOr Function()? onLongPress;
  final FutureOr Function(bool isHovering)? onHover;
  final void Function(bool value)? onFocusChange;
  final ButtonStyle? style;
  final FocusNode? focusNode;
  final Clip clipBehavior;
  final bool autofocus;
  final MaterialStatesController? statesController;
  final Widget child;

  ///Controls this button programatically. -> controller.tap().
  final ButtonController? controller;

  ///In the presence of a [FormX] above, animates loading.
  final bool hasFormx;

  ///The widget to show on loading.
  final Widget loader;

  ///The widget with error as string.
  final Widget Function(String e) error;

  ///The length limit of characters allowed in this error.
  final int errorLength;

  @override
  Widget build(BuildContext context) {
    final ctrl = useFinal(controller ?? ButtonController());
    ctrl._isLoading = useState(false);
    ctrl._hasError = useState(false);
    ctrl._press = onPressed;
    ctrl._longPress = onLongPress;
    ctrl._hover = onHover;

    useFormxLoading(hasFormx, (value) => ctrl._isLoading?.value = value);

    final animationStyle = TextButton.styleFrom(
      minimumSize: Size.zero,
      padding: EdgeInsets.zero,
      foregroundColor: ctrl.hasError ? context.colors.error : null,
    );

    return TextButton(
      key: key,
      onPressed: (onPressed != null && ctrl.isEnabled) ? ctrl.tap : null,
      onLongPress: (onLongPress != null && ctrl.isEnabled) ? ctrl.hold : null,
      onHover: ctrl.hover,
      autofocus: autofocus,
      clipBehavior: clipBehavior,
      focusNode: focusNode,
      onFocusChange: onFocusChange,
      statesController: statesController,

      //inherited style
      style: animationStyle.merge(style),

      //load animation
      child: _ButtonAnimations(
        isText: true,
        loader: loader,
        style: style ?? context.theme.textButtonTheme.style,
        ctrl: ctrl,
        error: error,
        errorLength: errorLength,
        child: child,
      ),
    );
  }
}

class _ButtonAnimations extends HookWidget {
  const _ButtonAnimations({
    required this.loader,
    required this.style,
    required this.ctrl,
    required this.error,
    required this.child,
    required this.errorLength,
    this.isText = false,
  });

  final ButtonStyle? style;
  final ButtonController ctrl;
  final Widget loader;
  final Widget Function(String) error;
  final Widget child;
  final int errorLength;
  final bool isText;

  @override
  Widget build(BuildContext context) {
    //minimumSize
    final msize = style?.minimumSize?.resolve({}) ?? Size(isText ? 64 : 88, 36);
    final vide = style?.visualDensity ?? VisualDensity.adaptivePlatformDensity;
    final box = BoxConstraints(minWidth: msize.width, minHeight: msize.height);
    final constraints = vide.effectiveConstraints(box);

    //minHeight
    final height = usePostSize()?.height ?? constraints.minHeight;
    // final height = dy > constraints.minHeight ? dy : constraints.minHeight;

    //errorText
    String errorMessage() {
      final message = ctrl.error.toString();
      if (message.length <= 30) return message;
      return '${message.substring(0, errorLength)}...';
    }

    return Tooltip(
      message: 'Copied!',
      waitDuration: 1.minutes,
      triggerMode: TooltipTriggerMode.values[ctrl.hasError ? 1 : 0],
      onTriggered: () async => ctrl.errorStack.copyToClipboard(),
      child: _ButtonLoader(
        loader: SizeTransform(size: height, child: loader),
        loading: ctrl.isLoading,
        duration: ctrl.animationDuration,

        // * readding constrainsts and padding from theme (only loader and error)
        child: ConstrainedBox(
          constraints: constraints,
          child: Padding(
            padding: style?.padding?.resolve({}) ?? const EdgeInsets.all(8.0),

            // * using column just to center without taking all the space
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [if (ctrl.hasError) error(errorMessage()) else child],
            ),
          ),
        ),
      ),
    );
  }
}

///Animates the loading indicator.
class _ButtonLoader extends HookWidget {
  const _ButtonLoader({
    required this.child,
    required this.loading,
    required this.loader,
    this.duration = const Duration(milliseconds: 600),
  });
  final Widget child;
  final Widget loader;
  final bool loading;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: duration,
      curve: Curves.fastOutSlowIn,
      child: loading
          ? loader
          : AnimatedOpacity(
              opacity: useState(0.0).post(1),
              duration: duration,
              curve: Curves.easeInExpo,
              child: child,
            ),
    );
  }
}

///A smaller [CircularProgressIndicator]
class SmallIndicator extends StatelessWidget {
  const SmallIndicator({
    this.size = 24.0,
    this.scale = 0.5,
    this.color,
    Key? key,
  }) : super(key: key);
  final double size;
  final double scale;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: Size.square(size),
      child: Transform.scale(
        scale: scale,
        child: CircularProgressIndicator(color: color),
      ),
    );
  }
}

///A Widget that sizes and transforms.
class SizeTransform extends StatelessWidget {
  const SizeTransform({
    this.size = 24.0,
    this.scale = 0.5,
    required this.child,
    Key? key,
  }) : super(key: key);
  final double size;
  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: Size.square(size),
      child: Transform.scale(
        scale: scale,
        child: child,
      ),
    );
  }
}

class LeElevatedButton extends LeButton<ElevatedButton> {
  static ButtonConfig? _config;

  /// The default [ButtonConfig] for [LeElevatedButton].
  static void setConfig(ButtonConfig config) => _config = config;

  const LeElevatedButton({
    super.config, // * <- le config
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
}

class LeOutlinedButton extends LeButton<OutlinedButton> {
  static ButtonConfig? _config;

  /// The default [ButtonConfig] for [LeOutlinedButton].
  static void setConfig(ButtonConfig config) => _config = config;

  const LeOutlinedButton({
    //Extended.
    super.config, // * <- le config
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
}

class LeTextButton extends LeButton<TextButton> {
  static ButtonConfig? _config;

  /// The default [ButtonConfig] for [LeTextButton].
  static void setConfig(ButtonConfig config) => _config = config;

  const LeTextButton({
    super.config, // * <- le config
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
}

class LeFilledButton extends LeButton<FilledButton> {
  static ButtonConfig? _config;

  /// The default [ButtonConfig] for [LeFilledButton].
  static void setConfig(ButtonConfig config) => _config = config;

  const LeFilledButton({
    super.config, // * <- le config
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
}

class LeButton<T extends ButtonStyleButton> extends ButtonStyleButton {
  static var _config = const ButtonConfig();

  /// The default [ButtonConfig] of all LeButtons.
  static void setConfig(ButtonConfig config) => _config = config;

  const LeButton({
    //Extended.
    this.config,

    //LeButton.
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

  /// Le configs of [LeButton]
  final ButtonConfig? config;

  @override
  State<LeButton<T>> createState() => LeButtonState<T>();

  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    if (this is LeButton<OutlinedButton>) return OutlinedButton.styleFrom();
    if (this is LeButton<FilledButton>) return FilledButton.styleFrom();
    if (this is LeButton<TextButton>) return TextButton.styleFrom();
    return ElevatedButton.styleFrom();
  }

  @override
  ButtonStyle? themeStyleOf(BuildContext context) {
    if (this is LeButton<OutlinedButton>) {
      return OutlinedButtonTheme.of(context).style;
    }
    if (this is LeButton<FilledButton>) {
      return FilledButtonTheme.of(context).style;
    }
    if (this is LeButton<TextButton>) return TextButtonTheme.of(context).style;
    return ElevatedButtonTheme.of(context).style;
  }
}

class LeButtonState<T extends ButtonStyleButton> extends State<LeButton<T>> {
  //Config by type.
  ButtonConfig? get typeConfig {
    if (this is LeButtonState<OutlinedButton>) return LeOutlinedButton._config;
    if (this is LeButtonState<FilledButton>) return LeFilledButton._config;
    if (this is LeButtonState<TextButton>) return LeTextButton._config;
    return LeElevatedButton._config;
  }

  //Config.
  ButtonConfig get config => widget.config ?? typeConfig ?? LeButton._config;

  //Async casting.
  FutureOr<void> Function()? get onPressed => widget.onPressed;
  FutureOr<void> Function()? get onLongPress => widget.onLongPress;

  //Async states.
  bool _isLoading = false;
  bool _isOnError = false;

  //Async refs.
  Object? _error;
  StackTrace? _stackTrace;

  //Getters.
  bool get isLoading => _isLoading;
  bool get isOnError => _isOnError;
  bool get isAnimating => isOnError || isLoading;

  Object? get error => _error;
  StackTrace? get stackTrace => _stackTrace;

  /// Performs custom [action] and trigger animations.
  FutureOr<void> setAction(FutureOr<void> action()) async {
    if (_isLoading || _isOnError) return null;
    _error = null;
    _stackTrace = null;

    try {
      setState(() => _isLoading = true);
      await action(); // * <- action callback
    } catch (e, s) {
      setState(() => _isOnError = true);
      _stackTrace = s;
      _error = e;
    } finally {
      setState(() => _isLoading = false);
      await Future.delayed(config.errorDuration);
      setState(() => _isOnError = false);
    }
  }

  /// Performs [onPressed] and trigger animations.
  FutureOr<void> press() {
    if (onPressed != null) return setAction(() => onPressed!());
  }

  /// Performs [onLongPress] and trigger animations.
  FutureOr<void> longPress() {
    if (onLongPress != null) return setAction(() => onLongPress!());
  }

  /// We wait first build size before any animation.
  bool get isFirstBuild => _size == null;

  /// The child of this button.
  Widget get child => widget.child!;

  /// This button [Size] when not animating.
  Size get size => _size!;
  Size? _size;

  @override
  Widget build(BuildContext context) {
    /// Gettings widget first size.
    if (isFirstBuild) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _size ??= context.size);
    }

    // Widget styles.
    final themeStyle = widget.themeStyleOf(context);
    final style = config.delegate?.style?.merge(themeStyle) ?? themeStyle;
    final errorStyle = config.delegate?.errorStyle?.merge(style) ?? style;
    final loadingStyle = config.delegate?.loadingStyle?.merge(style) ?? style;

    // Defining the constructor.
    return () {
      if (this is LeButtonState<OutlinedButton>) return OutlinedButton.new;
      if (this is LeButtonState<FilledButton>) return FilledButton.new;
      if (this is LeButtonState<TextButton>) return TextButton.new;
      return ElevatedButton.new;
    }()(
      style: () {
        if (isOnError && errorStyle != null) return errorStyle;
        if (isLoading && loadingStyle != null) return loadingStyle;
        return style;
      }(),
      child: () {
        if (isFirstBuild) return child;
        return config.delegate?.build(this) ?? child;
      }(),
      onLongPress: onLongPress != null ? longPress : null,
      onPressed: onPressed != null ? press : null,
      statesController: widget.statesController,
      onFocusChange: widget.onFocusChange,
      clipBehavior: widget.clipBehavior,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      onHover: widget.onHover,
      key: widget.key,
    );
  }
}

class ButtonConfig {
  const ButtonConfig({
    this.delegate,
    this.animationDuration = const Duration(milliseconds: 600),
    this.onLoading = const CircularProgressIndicator.adaptive(),
    this.onError = Text.new,
    this.errorLength = 30,
    this.errorDuration = const Duration(seconds: 5),
  });

  final LeButtonRawDelegate? delegate;

  ///The widget to show on loading.
  final Widget onLoading;

  ///The widget with error as string.
  final Widget Function(String errorText) onError;

  ///The length limit of characters allowed in this error.
  final int errorLength;

  final Duration animationDuration;
  final Duration errorDuration;
}

class LeButtonCollapsable extends LeButtonAnimatedDelegate {
  String errorMessage(LeButtonState state) {
    final message = state.error.toString();
    if (message.length <= state.config.errorLength) return message;
    return '${message.substring(0, state.config.errorLength)}...';
  }

  @override
  Widget onError(LeButtonState<ButtonStyleButton> state) {
    return AnimatedOpacity(
      duration: state.config.animationDuration,
      opacity: state.isOnError ? 1 : 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: state.config.onError(errorMessage(state)),
      ),
    );
  }

  @override
  Widget onLoading(LeButtonState<ButtonStyleButton> state) {
    return SizeTransform(
      size: state.size.height,
      child: state.config.onLoading,
    );
  }

  @override
  Widget onChild(LeButtonState<ButtonStyleButton> state) {
    return AnimatedOpacity(
      duration: state.config.animationDuration,
      opacity: state.isAnimating ? 0 : 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: state.child,
      ),
    );
  }
}

abstract class LeButtonRawDelegate {
  LeButtonRawDelegate({this.style, this.errorStyle, this.loadingStyle});

  /// This button style. It's merged with theme and applied to all states.
  final ButtonStyle? style;

  /// Overrides button style while on error.
  final ButtonStyle? errorStyle;

  /// Overrides button style while loading.
  final ButtonStyle? loadingStyle;

  /// Builds the Button child widget.
  Widget build(LeButtonState state);
}

abstract class LeButtonAnimatedDelegate extends LeButtonRawDelegate {
  @override
  ButtonStyle? get style => const ButtonStyle(
      padding: MaterialStatePropertyAll(EdgeInsets.zero),
      backgroundColor: MaterialStatePropertyAll(Colors.purple));

  @override
  ButtonStyle? get errorStyle => const ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(Colors.redAccent),
      );

  /// The widget to animate size on error.
  Widget onError(LeButtonState state);

  /// The widget to animate size on loading.
  Widget onLoading(LeButtonState state);

  /// The child widget of this button.
  Widget onChild(LeButtonState state);

  @override
  Widget build(LeButtonState state) {
    return AnimatedSize(
      duration: state.config.animationDuration,
      child: () {
        if (state.isOnError) return onError(state);
        if (state.isLoading) return onLoading(state);
        return state.child;
      }(),
    );
  }
}
