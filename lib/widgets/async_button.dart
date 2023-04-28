part of '../branvier.dart';

void main() => runApp(MaterialApp(home: Scaffold(body: Buttons())));

Future<void> fun() async {
  await 2.seconds();
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
              hasFormX: true, // todo: looses bind on hot reload.
              onPressed: fun,
              child: Text('Arthur Miranda'),
            ),
            OutlinedButtonX(
              hasFormX: true,
              onPressed: 3.seconds.call,
              child: const Text('Iran Neto'),
            ),
            TextButtonX(
              hasFormX: true,
              controller: ctrl,
              onPressed: 3.seconds.call,
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

  FutureOr Function()? _tap;
  ValueNotifier<bool>? _isLoading;
  ValueNotifier<bool>? _hasError;

  ///Taps the [ElevatedButtonX] programatically.
  void tap() async {
    if (isLoading || hasError) return;
    try {
      _isLoading?.value = true;
      await _tap?.call();
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

  ///Tell if the button can be tapped.
  bool get isEnabled => !isLoading || !hasError;
}

///Native [ElevatedButton] with animations for [loader] and [error].
///
///Use [ButtonController] to tap programatically.
class ElevatedButtonX extends HookWidget {
  const ElevatedButtonX({
    required this.onPressed,
    required this.child,
    this.hasFormX = false,
    this.controller,
    this.loader = const SmallIndicator(color: Colors.white),
    this.error = const Text('!'),
    this.style,
    super.key,
  });

  ///In the presence of a [FormX] above, animates loading.
  final bool hasFormX;

  ///Controls this button programatically. -> controller.tap().
  final ButtonController? controller;

  ///The widget to show on loading.
  final Widget loader;

  ///The widget to show on error.
  final Widget error;

  //Same as [TextButton].
  final FutureOr<void> Function()? onPressed;
  final Widget child;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final ctrl = useFinal(controller ?? ButtonController());
    ctrl._isLoading = useState(false);
    ctrl._hasError = useState(false);
    ctrl._tap = onPressed;

    final formx = useFinal(
      hasFormX ? context.dependOnInheritedWidgetOfExactType<FormScope>() : null,
    );

    if (hasFormX && formx == null) dev.log('No Formx above this button!');

    void onLoading() {
      ctrl._isLoading?.value = formx!.isLoading.value;
    }

    useInit(
      () => formx?.isLoading.addListener(onLoading),
      dispose: () => formx?.isLoading.removeListener(onLoading),
    );

    //Theme inherited.
    final colors = Theme.of(context).colorScheme;
    final appStyle = context.theme.elevatedButtonTheme.style;

    final mustStyle = ElevatedButton.styleFrom(
      backgroundColor: ctrl.hasError ? colors.error : null,
    );

    final defaultStyle = ElevatedButton.styleFrom(
      padding: appStyle?.padding?.resolve({}) ?? EdgeInsets.zero,
      minimumSize: appStyle?.minimumSize?.resolve({}) ?? const Size.square(36),
    );

    return ElevatedButton(
      onPressed: (onPressed != null && ctrl.isEnabled) ? ctrl.tap : null,

      //inherited style
      style: mustStyle.merge(style).merge(defaultStyle),

      //load animation
      child: _ButtonLoader(
        loader: loader,
        loading: ctrl.isLoading,
        duration: ctrl.animationDuration,
        child: (ctrl.hasError ? error : child).pad(horizontal: 8),
      ),
    );
  }
}

///Native [OutlinedButton] with animations for [loader] and [error].
///
///Use [ButtonController] to tap programatically.
class OutlinedButtonX extends HookWidget {
  const OutlinedButtonX({
    required this.onPressed,
    required this.child,
    this.hasFormX = false,
    this.controller,
    this.loader = const SmallIndicator(),
    this.error = const Text('!'),
    this.style,
    super.key,
  });

  ///In the presence of a [FormX] above, animates loading.
  final bool hasFormX;

  ///Controls this button programatically. -> controller.tap().
  final ButtonController? controller;

  ///The widget to show on loading.
  final Widget loader;

  ///The widget to show on error.
  final Widget error;

  //Same as [TextButton].
  final FutureOr<void> Function()? onPressed;
  final Widget child;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final ctrl = useFinal(controller ?? ButtonController());
    ctrl._isLoading = useState(false);
    ctrl._hasError = useState(false);
    ctrl._tap = onPressed;

    final formx = useFinal(
      hasFormX ? context.dependOnInheritedWidgetOfExactType<FormScope>() : null,
    );

    if (hasFormX && formx == null) dev.log('No Formx above this button!');

    void onLoading() => ctrl._isLoading?.value = formx!.isLoading.value;

    useInit(
      () => formx?.isLoading.addListener(onLoading),
      dispose: () => formx?.isLoading.removeListener(onLoading),
    );

    //Theme inherited.
    final colors = Theme.of(context).colorScheme;
    final side = Theme.of(context).outlinedButtonTheme.style?.side?.resolve({});
    final errorSide = BorderSide(color: colors.error).copyWith(
      width: side?.width,
      style: side?.style,
      strokeAlign: side?.strokeAlign,
    );
    final appStyle = context.theme.elevatedButtonTheme.style;

    final mustStyle = OutlinedButton.styleFrom(
      foregroundColor: ctrl.hasError ? colors.error : null,
      side: ctrl.hasError ? errorSide : null,
    );

    final defaultStyle = OutlinedButton.styleFrom(
      padding: appStyle?.padding?.resolve({}) ?? EdgeInsets.zero,
      minimumSize: appStyle?.minimumSize?.resolve({}) ?? const Size.square(36),
    );
    return OutlinedButton(
      onPressed: (onPressed != null && ctrl.isEnabled) ? ctrl.tap : null,

      //inherited style
      style: mustStyle.merge(style).merge(defaultStyle),

      //load animation
      child: _ButtonLoader(
        loader: loader,
        loading: ctrl.isLoading,
        duration: ctrl.animationDuration,
        child: (ctrl.hasError ? error : child).pad(horizontal: 8),
      ),
    );
  }
}

///Native [TextButton] with animations for [loader] and [error].
///
///Use [ButtonController] to tap programatically.
class TextButtonX extends HookWidget {
  const TextButtonX({
    required this.onPressed,
    required this.child,
    this.hasFormX = false,
    this.controller,
    this.loader = const SmallIndicator(),
    this.error = const Text('!'),
    this.style,
    super.key,
  });

  ///In the presence of a [FormX] above, animates loading.
  final bool hasFormX;

  ///Controls this button programatically. -> controller.tap().
  final ButtonController? controller;

  ///The widget to show on loading.
  final Widget loader;

  ///The widget to show on error.
  final Widget error;

  //Same as [TextButton].
  final FutureOr<void> Function()? onPressed;
  final Widget child;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final ctrl = useFinal(controller ?? ButtonController());
    ctrl._isLoading = useState(false);
    ctrl._hasError = useState(false);
    ctrl._tap = onPressed;

    final formx = useFinal(
      hasFormX ? context.dependOnInheritedWidgetOfExactType<FormScope>() : null,
    );

    if (hasFormX && formx == null) dev.log('No Formx above this button!');

    void onLoading() => ctrl._isLoading?.value = formx!.isLoading.value;

    useInit(
      () => formx?.isLoading.addListener(onLoading),
      dispose: () => formx?.isLoading.removeListener(onLoading),
    );

    //Theme inherited.
    final colors = Theme.of(context).colorScheme;
    final appStyle = context.theme.elevatedButtonTheme.style;

    final mustStyle = ElevatedButton.styleFrom(
      foregroundColor: ctrl.hasError ? colors.error : null,
    );

    final defaultStyle = ElevatedButton.styleFrom(
      padding: appStyle?.padding?.resolve({}) ?? EdgeInsets.zero,
      minimumSize: appStyle?.minimumSize?.resolve({}) ?? const Size.square(36),
    );

    return TextButton(
      onPressed: (onPressed != null && ctrl.isEnabled) ? ctrl.tap : null,

      //inherited style
      style: mustStyle.merge(style).merge(defaultStyle),

      //load animation
      child: _ButtonLoader(
        loader: loader,
        loading: ctrl.isLoading,
        duration: ctrl.animationDuration,
        child: (ctrl.hasError ? error : child).pad(horizontal: 8),
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
