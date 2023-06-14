// ignore_for_file: use_setters_to_change_properties

part of '../branvier.dart';

void main() {
  // timeDilation = 4;
  RxButton.setConfig(
    ButtonConfig(
      delegate: LeButtonType.transforming,
      onLoading: const CircularProgressIndicator(),
    ),
  );
  runApp(MaterialApp(home: Scaffold(body: Buttons())));
}

Future<void> fakeThrow() async {
  await 5.seconds.delay;
  // print('fui chamado');
  // ignore: only_throw_errors
  throw '1234512345123451234512345123456';
}

class Buttons extends HookWidget {
  Buttons({super.key});
  final ctrl = ButtonController();

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 3,
      child: Center(
        child: FormX.tr(
          onSubmit: (form) async {
            // throw 'yooooooooooooooo';
            await 3.seconds.delay;
          },
          child: Builder(
            builder: (context) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Field('name'),
                  RxElevatedButton(
                    onPressed: () async {
                      await 1.seconds.delay;
                      throw 'This is a error';
                    },
                    child: const Text('Click me'),
                  ),
                  RxOutlinedButton(
                    onPressed: () async {
                      await 1.seconds.delay;
                      throw 'This is a really long error';
                    },
                    child: const Text('Click me'),
                  ),
                  RxTextButton(
                    onPressed: () async {
                      await 1.seconds.delay;
                      throw 'This error is more than huge, its';
                    },
                    child: const Text('Click me'),
                  ),
                  RxFilledButton(
                    onPressed: () async {
                      await 1.seconds.delay;
                      throw 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
                    },
                    child: const Text('Click me'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
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
    super.key,
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
  });

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
    super.key,
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
  });

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
    super.key,
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
  });

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
    super.key,
  });
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
    super.key,
  });
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

class RxElevatedButton extends RxButton<ElevatedButton> {
  static ButtonConfig? _config;

  /// The default [ButtonConfig] for [RxElevatedButton].
  static void setConfig(ButtonConfig config) => _config = config;

  const RxElevatedButton({
    super.config, // * <- le config
    super.listenables,
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

class RxOutlinedButton extends RxButton<OutlinedButton> {
  static ButtonConfig? _config;

  /// The default [ButtonConfig] for [RxOutlinedButton].
  static void setConfig(ButtonConfig config) => _config = config;

  const RxOutlinedButton({
    //Extended.
    super.config, // * <- le config
    super.listenables,
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

class RxTextButton extends RxButton<TextButton> {
  static ButtonConfig? _config;

  /// The default [ButtonConfig] for [RxTextButton].
  static void setConfig(ButtonConfig config) => _config = config;

  const RxTextButton({
    super.config, // * <- le config
    super.listenables,
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

class RxFilledButton extends RxButton<FilledButton> {
  static ButtonConfig? _config;

  /// The default [ButtonConfig] for [RxFilledButton].
  static void setConfig(ButtonConfig config) => _config = config;

  const RxFilledButton({
    super.config, // * <- le config
    super.listenables,
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
  final List<ValueListenable<bool>> listenables;

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

class RxButtonState<T extends ButtonStyleButton> extends State<RxButton<T>> {
  ButtonConfig? get _config {
    if (isElevatedButton) return RxElevatedButton._config;
    if (isFilledButton) return RxFilledButton._config;
    if (isOutlinedButton) return RxOutlinedButton._config;
    if (isTextButton) return RxTextButton._config;
    return null;
  }

  // State variables.
  bool _isLoading = false;
  bool _isOnError = false;
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
  bool get isLoading => _isLoading && !isInit;
  bool get isOnError => _isOnError && !isInit;
  bool get isAnimating => isOnError || isLoading;

  // Error getters.
  Object? get error => _error;
  StackTrace? get stackTrace => _stackTrace;

  /// The child of this button.
  Widget get child => widget.child!;

  /// Same [setState], but with [mounted].
  void _setState(VoidCallback action) {
    if (mounted) setState(action);
  }

  // Loading listener
  void _setLoading() {
    _isLoading = widget.listenables.any((listener) => listener.value);
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

  /// Performs custom [action] and trigger animations.
  FutureOr<void> setAction(FutureOr<void> action()) async {
    // Clean resources.
    _error = _stackTrace = null;

    // Cancels if busy or not ready.
    if (isAnimating || !mounted) return null;

    try {
      _setState(() => _isLoading = true);
      await action(); // * <------------------ action callback
    } catch (e, s) {
      _setState(() => _isOnError = true);
      _stackTrace = s;
      _error = e;
    } finally {
      _setState(() => _isLoading = false);
      if (mounted) await Future.delayed(config.errorDuration);
      _setState(() => _isOnError = false);
    }
  }

  @override
  void initState() {
    super.initState();
    for (var notifier in widget.listenables) {
      notifier.addListener(_setLoading);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _size ??= context.size;
      _setLoading();
    });
  }

  @override
  void dispose() {
    super.dispose();

    for (var listenable in widget.listenables) {
      listenable.removeListener(_setLoading);
    }
  }

  @override
  void reassemble() {
    super.reassemble();

    // Checks listenables on hot reload.
    WidgetsBinding.instance.addPostFrameCallback((_) => _setLoading());
  }

  late final _style =
      widget.themeStyleOf(context) ?? widget.defaultStyleOf(context);

  /// The resolved [ButtonStyle] theme.
  late final style = config.delegate?.onStyle(this, _style) ?? _style;

  /// We wait first build size before any animation.
  bool get isInit => _size == null;

  /// This button [Size] when not animating.
  Size get size => _size!;
  Size? _size;

  @override
  Widget build(BuildContext context) {
    // Widget styles.
    final errorStyle = config.delegate?.onErrorStyle(this, style);
    final loadingStyle = config.delegate?.onLoadingStyle(this, style);

    // Constructor torn-off.
    return () {
      if (isFilledButton) return FilledButton.new;
      if (isOutlinedButton) return OutlinedButton.new;
      if (isTextButton) return TextButton.new;
      return ElevatedButton.new;
    }()(
      style: () {
        if (isOnError && errorStyle != null) return errorStyle;
        if (isLoading && loadingStyle != null) return loadingStyle;
        return style;
      }(),
      // By default it's a pure button. Use [RxButtonBuilder] for custom behavior.
      child: config.delegate?.build(this) ?? child,
      onLongPress: widget.onLongPress != null ? longPress : null,
      onPressed: widget.onPressed != null ? press : null,
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

  final RxButtonDelegate? delegate;

  /// The widget to show on loading.
  final Widget onLoading;

  /// The widget with error as string.
  final Widget Function(String errorText) onError;

  /// The length limit of characters allowed in this error.
  final int errorLength;

  final Duration animationDuration;
  final Duration errorDuration;
}

mixin LeButtonType {
  static String errorMessage(RxButtonState state) {
    final message = state.error.toString();
    int customIndex = 0;
    int i = 0;

    while (i < message.length) {
      customIndex += (message[i].toUpperCase() == message[i] &&
              message[i] != message[i].toLowerCase())
          ? 2
          : 1;
      if (customIndex > state.config.errorLength) {
        break;
      }
      i++;
    }

    return (i < message.length) ? '${message.substring(0, i)}...' : message;
  }

  static final transforming = LeButtonAnimatedBuilder(
    onLoading: (state) {
      final onlyText =
          state.style.backgroundColor?.resolve({}) == Colors.transparent;
      return SizedBox(
        height: state.size.height / 2,
        width: state.size.height / 2,
        child: CircularProgressIndicator(
          color: onlyText ? null : Colors.white,
          strokeWidth: 2,
        ),
      );
    },
    onError: (state) {
      return Text(errorMessage(state));
    },
  );
}

class LeButtonAnimatedBuilder extends RxButtonDelegate {
  const LeButtonAnimatedBuilder({
    required this.onLoading,
    required this.onError,
    this.alignment = Alignment.center,
    this.curve = Curves.fastOutSlowIn,
    this.duration = const Duration(milliseconds: 600),
    this.errorColor = Colors.redAccent,
    this.errorLength = 30,
  });

  final AlignmentGeometry alignment;
  final Color errorColor;
  final Duration duration;
  final Curve curve;
  final Widget Function(RxButtonState state) onLoading;
  final Widget Function(RxButtonState state) onError;
  final double errorLength;

  @override
  Widget build(RxButtonState state) {
    return AnimatedOpacity(
      duration: duration,
      curve: curve,
      opacity: state.isInit ? 0 : 1,
      child: AnimatedSize(
        alignment: alignment,
        duration: duration,
        curve: curve,
        child: () {
          if (state.isOnError) return onError(state);
          if (state.isLoading) return onLoading(state);
          return state.child;
        }(),
      ),
    );
  }

  @override
  ButtonStyle? onErrorStyle(RxButtonState state, ButtonStyle style) {
    final onlyText = style.backgroundColor?.resolve({}) == Colors.transparent;
    final errorMaterial = MaterialStatePropertyAll(errorColor);
    return style.copyWith(
      backgroundColor: onlyText ? null : errorMaterial,
      foregroundColor: onlyText ? errorMaterial : null,
    );
  }

  @override
  ButtonStyle? onLoadingStyle(RxButtonState state, ButtonStyle style) {
    return style.copyWith(
      padding: const MaterialStatePropertyAll(EdgeInsets.zero),
    );
  }

  @override
  ButtonStyle? onStyle(RxButtonState state, ButtonStyle themeStyle) {
    return themeStyle;
  }
}

/// Class that delegates [RxButton] state and styles.
///
/// - Use [LeButtonBuilder] for a full control, no presets.
/// - Use [LeButtonAnimatedBuilder] with animation presets.
abstract class RxButtonDelegate {
  const RxButtonDelegate();

  /// Overrides button [onStyle]. Inherits [themeStyle].
  ButtonStyle? onStyle(RxButtonState state, ButtonStyle themeStyle);

  /// Overrides error [ButtonStyle]. Inherits [style].
  ButtonStyle? onErrorStyle(RxButtonState state, ButtonStyle style);

  /// Overrides loading [ButtonStyle]. Inherits [style].
  ButtonStyle? onLoadingStyle(RxButtonState state, ButtonStyle style);

  /// Builds the Button child widget.
  Widget build(RxButtonState state);
}

typedef ButtonStyleCallback = ButtonStyle Function(
  RxButtonState state,
  ButtonStyle themeStyle,
);

/// This class gives you full access to the [RxButton]'s state and styles.
class LeButtonBuilder extends RxButtonDelegate {
  const LeButtonBuilder({
    this.style,
    this.loadingStyle,
    this.errorStyle,
    required this.builder,
  });

  /// Overrides button [style]. Inherits theme.
  final ButtonStyleCallback? style;

  /// Overrides button [errorStyle]. Inherits [style].
  final ButtonStyleCallback? errorStyle;

  /// Overrides button [loadingStyle]. Inherits [style].
  final ButtonStyleCallback? loadingStyle;

  /// Builds the Button child widget.
  final Widget Function(RxButtonState state) builder;

  @override
  ButtonStyle? onStyle(state, themeStyle) => style?.call(state, themeStyle);

  @override
  ButtonStyle? onErrorStyle(state, style) => errorStyle?.call(state, style);

  @override
  ButtonStyle? onLoadingStyle(state, style) => loadingStyle?.call(state, style);

  @override
  Widget build(RxButtonState state) => builder(state);
}
