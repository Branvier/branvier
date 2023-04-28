part of '../branvier.dart';

void main() => runApp(MaterialApp(home: Scaffold(body: Buttons())));

Future<void> fun() async {
  await 2.seconds();
  print('fui chamado');
  // ignore: only_throw_errors
  throw '';
}

class Buttons extends HookWidget {
  Buttons({super.key});
  final ctrl = ButtonController();

  @override
  Widget build(BuildContext context) {
    return FormX(
      onSubmit: (form) async {
        await 3.seconds();
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Field('test'),
            ElevatedButtonX(
              // hasFormX: true, // todo: looses bind on hot reload.
              onPressed: fun,
              onLongPress: fun,
              // onHover: (isHovering) async => fun(),
              // on: fun,
              child: Text('Arthur Miranda'),
            ),
            OutlinedButtonX(
              // hasFormX: true,
              onPressed: fun,
              onLongPress: fun,
              child: const Text('Iran Neto'),
            ),
            TextButtonX(
              // hasFormX: true,
              controller: ctrl,
              onPressed: fun,
              onLongPress: fun,
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
    this.errorDuration = const Duration(seconds: 3),
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
  void tap() => _animate(_press);

  ///Performs longPress programatically.
  void hold() => _animate(_longPress);

  ///Performs hover programatically.
  void hover([bool isHovering = true]) => _hover?.call(_hovering = isHovering);

  ///Starts animating the button.
  void _animate(FutureOr action()?) async {
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
      await errorDuration();
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
    this.error = const Text('!'),
    this.loader = const SmallIndicator(color: Colors.white),

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

  ///The widget to show on error.
  final Widget error;

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
      padding: ctrl.isAnimating ? EdgeInsets.zero : null,
      backgroundColor: ctrl.hasError ? context.colors.error : null,
      minimumSize: ctrl.isAnimating ? const Size.square(36) : null,
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
      child: _ButtonLoader(
        loader: loader,
        loading: ctrl.isLoading,
        duration: ctrl.animationDuration,
        child: ctrl.hasError ? error : child,
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
    this.error = const Text('!'),
    this.loader = const SmallIndicator(),

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

  ///The widget to show on error.
  final Widget error;

  @override
  Widget build(BuildContext context) {
    final ctrl = useFinal(controller ?? ButtonController());
    ctrl._isLoading = useState(false);
    ctrl._hasError = useState(false);
    ctrl._press = onPressed;
    ctrl._longPress = onLongPress;
    ctrl._hover = onHover;

    useFormxLoading(hasFormx, (value) => ctrl._isLoading?.value = value);

    //Theme inherited.
    final side = context.theme.outlinedButtonTheme.style?.side?.resolve({});
    final errorSide = BorderSide(color: context.colors.error).copyWith(
      width: side?.width,
      style: side?.style,
      strokeAlign: side?.strokeAlign,
    );

    final animationStyle = OutlinedButton.styleFrom(
      padding: ctrl.isAnimating ? EdgeInsets.zero : null,
      foregroundColor: ctrl.hasError ? context.colors.error : null,
      minimumSize: ctrl.isAnimating ? const Size.square(36) : null,
      side: ctrl.hasError ? errorSide : null,
    );

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
      style: animationStyle.merge(style),

      //load animation
      child: _ButtonLoader(
        loader: loader,
        loading: ctrl.isLoading,
        duration: ctrl.animationDuration,
        child: ctrl.hasError ? error : child,
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
    this.error = const Text('!'),
    this.loader = const SmallIndicator(),

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

  ///The widget to show on error.
  final Widget error;

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
      padding: ctrl.isAnimating ? EdgeInsets.zero : null,
      foregroundColor: ctrl.hasError ? context.colors.error : null,
      minimumSize: ctrl.isAnimating ? const Size.square(36) : null,
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
      child: _ButtonLoader(
        loader: loader,
        loading: ctrl.isLoading,
        duration: ctrl.animationDuration,
        child: ctrl.hasError ? error : child,
      ),
    );
  }
}

///Animates the loading indicator.
class _ButtonLoader extends HookWidget {
  const _ButtonLoader({
    required this.child,
    required this.loading,
    this.loader = const SmallIndicator(),
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
          : Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedOpacity(
                  opacity: useState(0.0).post(1),
                  duration: duration,
                  curve: Curves.easeInExpo,
                  child: child,
                ),
              ],
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
