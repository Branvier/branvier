part of '../branvier.dart';

void main() {
  // timeDilation = 4;
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
            TextButtonX(
              // hasFormX: true,
              controller: ctrl,
              onPressed: fakeThrow,
              onLongPress: fakeThrow,
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

// abstract class ButtonX extends ButtonStyleButton {
//   const ButtonX({
//     //Extended.
//     this.controller,
//     this.hasFormx = false,
//     this.error = Text.new,
//     this.errorLength = 30,
//     this.loader = const CircularProgressIndicator(color: Colors.white),

//     //ElevatedButton.
//     super.key,
//     required super.onPressed,
//     super.onLongPress,
//     super.onHover,
//     super.onFocusChange,
//     super.style,
//     super.focusNode,
//     super.autofocus = false,
//     super.clipBehavior = Clip.none,
//     super.statesController,
//     required super.child,
//   });

//   ///Controls this button programatically. -> controller.tap().
//   final ButtonController? controller;

//   ///In the presence of a [FormX] above, animates loading.
//   final bool hasFormx;

//   ///The widget to show on loading.
//   final Widget loader;

//   ///The widget with error as string.
//   final Widget Function(String e) error;

//   ///The length limit of characters allowed in this error.
//   final int errorLength;

//   @override
//   State<ButtonX> createState() => ButtonXState();
// }

// class ButtonXState extends State<ButtonX> {
//   @override
//   Widget build(BuildContext context) {
//     final ctrl = useFinal(widget.controller ?? ButtonController());
//     ctrl._isLoading = useState(false);
//     ctrl._hasError = useState(false);
//     ctrl._press = widget.onPressed;
//     ctrl._longPress = widget.onLongPress;
//     ctrl._hover = widget.onHover;

//     useFormxLoading(widget.hasFormx, (value) => ctrl._isLoading?.value = value);

//     final animationStyle = ElevatedButton.styleFrom(
//       minimumSize: Size.zero,
//       padding: EdgeInsets.zero,
//       backgroundColor: ctrl.hasError ? context.colors.error : null,
//     );

//     return ElevatedButton(
//       key: widget.key,
//       onPressed: (widget.onPressed != null && ctrl.isEnabled) ? ctrl.tap : null,
//       onLongPress:
//           (widget.onLongPress != null && ctrl.isEnabled) ? ctrl.hold : null,
//       onHover: ctrl.hover,
//       autofocus: widget.autofocus,
//       clipBehavior: widget.clipBehavior,
//       focusNode: widget.focusNode,
//       onFocusChange: widget.onFocusChange,
//       statesController: widget.statesController,

//       //inherited style
//       style: animationStyle.merge(widget.style),

//       //load animation
//       child: _ButtonAnimations(
//         loader: widget.loader,
//         style: widget.style ?? context.theme.elevatedButtonTheme.style,
//         ctrl: ctrl,
//         error: widget.error,
//         errorLength: widget.errorLength,
//         child: widget.child!,
//       ),
//     );
//   }
// }
