part of '../branvier.dart';

void main() => runApp(MaterialApp(home: Scaffold(body: Buttons())));

Future<void> fun() async {
  await 2.seconds();
  throw '';
}

class Buttons extends StatelessWidget {
  Buttons({super.key});
  final ctrl = ButtonController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ElevatedButtonX(
            onTap: fun,
            child: Text('Arthur Miranda'),
          ),
          OutlinedButtonX(
            onTap: 3.seconds.call,
            child: const Text('Iran Neto'),
          ),
          TextButtonX(
            controller: ctrl,
            onTap: 3.seconds.call,
            child: const Text('Juan Alesson'),
          ),
          ElevatedButton(onPressed: ctrl.tap, child: const Text('tap'))
        ],
      ),
    );
  }
}

class ButtonController {
  ButtonController({
    this.animationDuration = const Duration(milliseconds: 600),
    this.errorDuration = const Duration(seconds: 3),
    this.errorColor = Colors.redAccent,
  });
  final Duration animationDuration;
  final Duration errorDuration;
  final Color errorColor;
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
    required this.onTap,
    required this.child,
    this.controller,
    this.loader = const SmallIndicator(color: Colors.white),
    this.error = const Text('!'),
    this.style,
    super.key,
  });

  final FutureOr<void> Function()? onTap;
  final Widget child;
  final ButtonController? controller;
  final Widget loader;
  final Widget error;
  final ButtonStyle? style;
  ButtonController get ctrl => controller ?? ButtonController();

  @override
  Widget build(BuildContext context) {
    final ctrl = useRef(this.ctrl).value;
    ctrl._isLoading = useState(false);
    ctrl._hasError = useState(false);
    ctrl._tap = onTap;

    return ElevatedButton(
      onPressed: (onTap != null && ctrl.isEnabled) ? ctrl.tap : null,

      //inherited style
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        backgroundColor: ctrl.hasError ? ctrl.errorColor : null,
        minimumSize: const Size.square(36),
      ).merge(style),

      //load animation
      child: AnimatedLoader(
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
    required this.onTap,
    required this.child,
    this.controller,
    this.loader = const SmallIndicator(),
    this.error = const Text('!'),
    this.style,
    super.key,
  });
  final FutureOr<void> Function()? onTap;
  final Widget child;
  final ButtonController? controller;
  final Widget loader;
  final Widget error;
  final ButtonStyle? style;
  ButtonController get ctrl => controller ?? ButtonController();

  @override
  Widget build(BuildContext context) {
    final ctrl = useRef(this.ctrl).value;
    ctrl._isLoading = useState(false);
    ctrl._hasError = useState(false);
    ctrl._tap = onTap;

    //Current default border color.
    final border = Theme.of(context).colorScheme.onSurface.withOpacity(0.12);

    return OutlinedButton(
      onPressed: (onTap != null && ctrl.isEnabled) ? ctrl.tap : null,

      //inherited style
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.zero,
        foregroundColor: ctrl.hasError ? ctrl.errorColor : null,
        side: BorderSide(color: ctrl.hasError ? ctrl.errorColor : border),
        minimumSize: const Size.square(36),
      ).merge(style),

      //load animation
      child: AnimatedLoader(
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
    required this.onTap,
    required this.child,
    this.controller,
    this.loader = const SmallIndicator(),
    this.error = const Text('!'),
    this.style,
    super.key,
  });
  final FutureOr<void> Function()? onTap;
  final Widget child;
  final ButtonController? controller;
  final Widget loader;
  final Widget error;
  final ButtonStyle? style;
  ButtonController get ctrl => controller ?? ButtonController();

  @override
  Widget build(BuildContext context) {
    final ctrl = useRef(this.ctrl).value;
    ctrl._isLoading = useState(false);
    ctrl._hasError = useState(false);
    ctrl._tap = onTap;

    return TextButton(
      onPressed: (onTap != null && ctrl.isEnabled) ? ctrl.tap : null,

      //inherited style
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        foregroundColor: ctrl.hasError ? ctrl.errorColor : null,
        minimumSize: const Size.square(36),
      ).merge(style),

      //load animation
      child: AnimatedLoader(
        loader: loader,
        loading: ctrl.isLoading,
        duration: ctrl.animationDuration,
        child: (ctrl.hasError ? error : child).pad(horizontal: 8),
      ),
    );
  }
}

///Animates the loading indicator.
class AnimatedLoader extends HookWidget {
  const AnimatedLoader({
    super.key,
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
