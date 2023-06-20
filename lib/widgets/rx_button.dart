// ignore_for_file: use_setters_to_change_properties

part of '../branvier.dart';

void main() => runApp(
      MaterialApp(
        home: const MyWidget(),
        theme: ThemeData(
          elevatedButtonTheme: const ElevatedButtonThemeData(),
        ),
      ),
    );

class RxButtonStyle extends ButtonStyle {
  const RxButtonStyle({
    this.config,
    super.textStyle,
    super.backgroundColor,
    super.foregroundColor,
    super.overlayColor,
    super.shadowColor,
    super.surfaceTintColor,
    super.elevation,
    super.padding,
    super.minimumSize,
    super.fixedSize,
    super.maximumSize,
    super.iconColor,
    super.iconSize,
    super.side,
    super.shape,
    super.mouseCursor,
    super.visualDensity,
    super.tapTargetSize,
    super.animationDuration,
    super.enableFeedback,
    super.alignment,
    super.splashFactory,
  });

  final ButtonConfig? config;
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RxElevatedButton(
              onPressed: () async {
                await Future.delayed(const Duration(seconds: 2));
                throw Exception('error');
              },
              child: Text('spinner'),
            ),
            RxElevatedButton(
              config: ButtonConfig(
                onHover: (state) {
                  return AnimatedSize(
                    duration: const Duration(milliseconds: 600),
                    // scale: state.isHovering ? 2 : 1.0,
                    child: state.child,
                  );
                },
              ),
              onPressed: () {},
              child: const WavePulser(),
            ),
            SizedBox.square(
              dimension: 500,
              child: GradientAnimator(
                duration: const Duration(seconds: 1),
                colors: const [
                  Colors.red,
                  Colors.orange,
                  Colors.yellow,
                  Colors.green,
                  Colors.blue,
                  Colors.purple,
                  Colors.purple,
                  Colors.blue,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GradientAnimator extends StatefulWidget {
  final List<Color> colors;
  final Duration duration;

  const GradientAnimator({
    required this.colors,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  _GradientAnimatorState createState() => _GradientAnimatorState();
}

class _GradientAnimatorState extends State<GradientAnimator> {
  late Color color1 = widget.colors[0];
  late Color color2 = widget.colors[1];

  void animate() async {
    for (var i = 0; i < widget.colors.length; i++) {
      color1 = widget.colors[i];
      color2 = widget.colors[(i + 1) % widget.colors.length];
      await Future.delayed(widget.duration);
      setState(() {});
    }
    animate();
  }

  @override
  void initState() {
    super.initState();
    animate();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: widget.duration,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color1,
            color2,
          ],
        ),
      ),
      child: Container(),
    );
  }
}

class CustomTransform extends StatelessWidget {
  final Widget child;
  final Offset offset;
  final double scale;
  final double rotationAngle;
  final bool flipHorizontally;
  final bool flipVertically;

  const CustomTransform({
    required this.child,
    this.offset = Offset.zero,
    this.scale = 1.0,
    this.rotationAngle = 0.0,
    this.flipHorizontally = false,
    this.flipVertically = false,
  });

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()
        ..translate(offset.dx, offset.dy)
        ..scale(scale, scale)
        ..rotateZ(rotationAngle)
        ..rotateY(flipHorizontally ? math.pi : 0)
        ..rotateX(flipVertically ? math.pi : 0),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class Pulser extends StatefulWidget {
  final int pulses;
  final Duration animationDuration;
  final Duration pulseDelay;
  final Curve curve;
  final Widget Function(BuildContext, Animation<double> animation)? builder;

  const Pulser({
    required this.builder,
    this.pulses = 3,
    this.curve = Curves.slowMiddle,
    this.animationDuration = const Duration(milliseconds: 800),
    this.pulseDelay = const Duration(milliseconds: 200),
    super.key,
  });

  Widget build(BuildContext context, Animation<double> animation) {
    return builder!(context, animation);
  }

  @override
  _PulserState createState() => _PulserState();
}

class _PulserState extends State<Pulser> with TickerProviderStateMixin {
  final _controllers = <AnimationController>[];
  final _animations = <Animation<double>>[];

  @override
  void initState() {
    super.initState();

    for (var i = 0; i < widget.pulses; i++) {
      _controllers.add(
        AnimationController(
          duration: widget.animationDuration,
          vsync: this,
        ),
      );

      _animations.add(
        CurvedAnimation(
          parent: _controllers[i],
          curve: widget.curve,
        ),
      );

      startAnimation(i);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void startAnimation(int index) {
    Future.delayed(widget.pulseDelay * index, () {
      _controllers[index].repeat(reverse: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(
        widget.pulses,
        (index) => AnimatedBuilder(
          animation: _animations[index],
          builder: (context, _) => widget.build(context, _animations[index]),
        ),
      ),
    );
  }
}

class DotPulser extends Pulser {
  const DotPulser({
    super.animationDuration,
    super.curve,
    super.pulseDelay,
    super.pulses,
    super.key,
  }) : super(builder: null);

  @override
  Widget build(BuildContext context, Animation<double> animation) {
    return CustomTransform(
      scale: animation.value,
      offset: Offset(0, (-8 * animation.value) + 4),
      child: Container(
        width: 10,
        height: 10,
        margin: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );
  }
}

class WavePulser extends Pulser {
  const WavePulser({
    super.animationDuration,
    super.curve,
    super.pulseDelay,
    super.pulses,
    super.key,
  }) : super(builder: null);

  @override
  Widget build(BuildContext context, Animation<double> animation) {
    return Transform.translate(
      offset: Offset(0, (-8 * animation.value) + 4),
      child: Container(
        width: 10,
        height: 10,
        margin: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );
  }
}

class PulseDot extends StatefulWidget {
  final int pulses;
  final Decoration decoration;
  final double minScale;
  final double maxScale;
  final Size size;
  final Duration animationDuration;
  final Duration delayBetweenDots;
  final Curve curve;
  final EdgeInsetsGeometry dotMargin;

  const PulseDot({
    this.decoration = const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    this.pulses = 3,
    this.dotMargin = const EdgeInsets.symmetric(horizontal: 3),
    this.minScale = 0.3,
    this.maxScale = 1.0,
    this.size = const Size.square(10),
    this.curve = Curves.easeInOut,
    this.animationDuration = const Duration(milliseconds: 800),
    this.delayBetweenDots = const Duration(milliseconds: 200),
  });

  @override
  _PulseDotState createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot> with TickerProviderStateMixin {
  final controllers = <AnimationController>[];
  final animations = <Animation<double>>[];

  @override
  void initState() {
    super.initState();

    for (var i = 0; i < widget.pulses; i++) {
      controllers.add(
        AnimationController(
          duration: widget.animationDuration,
          vsync: this,
        ),
      );

      animations.add(
        CurvedAnimation(
          parent: controllers[i],
          curve: widget.curve,
        ),
      );

      startAnimation(i);
    }
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void startAnimation(int index) {
    Future.delayed(widget.delayBetweenDots * index, () {
      controllers[index].repeat(reverse: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.pulses, (index) {
        return ScaleTransition(
          scale: Tween<double>(
            begin: widget.minScale,
            end: widget.maxScale,
          ).animate(animations[index]),
          child: Container(
            margin: widget.dotMargin,
            height: widget.size.height,
            width: widget.size.width,
            decoration: widget.decoration,
          ),
        );
      }),
    );
  }
}

// offset: Offset(0, (-10 * _animations[index].value) + 5),

void main2() {
  // timeDilation = 4;
  RxButton.setConfig(
    ButtonConfig(),
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
                    listenables: [
                      ValueNotifier(true),
                    ],
                    onPressed: () async {
                      await 1.seconds.delay;
                      throw Exception('This is a error');
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
  }
}

class RxElevatedButton extends RxButton<ElevatedButton> {
  static ButtonConfig? _config;

  /// The default [ButtonConfig] for [RxElevatedButton].
  static void setConfig(ButtonConfig config) => _config = config;

  const RxElevatedButton({
    super.config, // * <- config
    super.listenables,
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
    super.config, // * <- config
    super.listenables,
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
    super.config, // * <- config
    super.listenables,
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
    super.config, // * <- le config
    super.listenables,
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

class RxButtonState<T extends ButtonStyleButton> extends State<RxButton<T>>
    with SingleTickerProviderStateMixin {
  ButtonConfig? get _config {
    if (isElevatedButton) return RxElevatedButton._config;
    if (isFilledButton) return RxFilledButton._config;
    if (isOutlinedButton) return RxOutlinedButton._config;
    if (isTextButton) return RxTextButton._config;
    return null;
  }

  // State variables.
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
    if (mounted) setState(action);
    _updateStyle();
  }

  // Loading listener
  void _setLoading() {
    _isLoading = widget.listenables.any((listener) => listener.value);
    _setState(() {});
    _updateStyle();
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

  late final _styleNotifier = ValueNotifier<ButtonStyle>(_currentStyle);
  late final _controller = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );
  late var _currentStyle = _buttonStyle();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _size ??= context.size;
      _styleNotifier.addListener(() {
        _controller
          ..reset()
          ..forward().whenComplete(() {
            _currentStyle = _styleNotifier.value;
          });
      });
      for (var notifier in widget.listenables) {
        notifier.addListener(_setLoading);
      }
      _setLoading();
    });
  }

  void _updateStyle() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _styleNotifier.value = _buttonStyle();
    });
  }

  ButtonStyle _buttonStyle() {
    if (isOnError) return config.errorStyle(this);
    if (isLoading) return config.loadingStyle(this);
    // if (isHovering) return config.hoverStyle?.call(this) ?? style;
    return style;
  }

  @override
  void dispose() {
    _controller.dispose();
    _styleNotifier.dispose();

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

  /// The [ButtonStyle] of this button.
  late final style = widget.style ??
      widget.themeStyleOf(context) ??
      widget.defaultStyleOf(context);

  /// We wait first build size before any animation.
  bool get hasSize => _size != null;

  /// This button [Size] when not animating.
  Size get size => _size!;
  Size? _size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
        size: config.keepSize ? _size : null,

        // Constructor torn-off.
        child: AnimatedBuilder(
          animation: Listenable.merge([_controller, _styleNotifier]),
          builder: (context, _) {
            return () {
              if (isOutlinedButton) return OutlinedButton.new;
              if (isFilledButton) return FilledButton.new;
              if (isTextButton) return TextButton.new;
              return ElevatedButton.new;
            }()(
              style: _controller.isAnimating
                  ? ButtonStyle.lerp(
                      _currentStyle,
                      _styleNotifier.value,
                      _controller.value,
                    )
                  : _styleNotifier.value,
              child: config.parent(this, () {
                if (isOnError) return config.onError(this);
                if (isLoading) return config.onLoading(this);
                if (isHovering) return config.onHover?.call(this) ?? child;
                return child;
              }()),
              onHover: (hover) {
                _isOnHover = hover;
                // _updateStyle();
                widget.onHover?.call(hover);
              },
              onLongPress: widget.onLongPress != null ? longPress : null,
              onPressed: widget.onPressed != null ? press : null,
              statesController: widget.statesController,
              onFocusChange: widget.onFocusChange,
              clipBehavior: widget.clipBehavior,
              focusNode: widget.focusNode,
              autofocus: widget.autofocus,
              key: widget.key,
            );
          },
        ));
  }
}

/// Class that defines [RxButton] states and styles.
class ButtonConfig {
  const ButtonConfig({
    this.keepSize = false,
    this.errorDuration = const Duration(seconds: 3),
    this.parent = _defaultParent,
    this.onLoading = _defaultLoading,
    this.onError = _defaultError,
    this.onHover,
    this.loadingStyle = _defaultLoadingStyle,
    this.errorStyle = _defaultErrorStyle,
    this.hoverStyle,
  });

  /// Whether or not this button should keep its size when animating.
  final bool keepSize;

  /// The duration to show error widget.
  final Duration errorDuration;

  /// The parent widget that holds all button states.
  final Widget Function(RxButtonState state, Widget child) parent;

  /// The widget to show on loading.
  final Widget Function(RxButtonState state) onLoading;

  /// The widget to show on error.
  final Widget Function(RxButtonState state) onError;

  /// The widget to show on hover.
  final Widget Function(RxButtonState state)? onHover;

  /// The style to apply on loading.
  final ButtonStyle Function(RxButtonState state) loadingStyle;

  /// The style to apply on error.
  final ButtonStyle Function(RxButtonState state) errorStyle;

  /// The style to apply on hover.
  final ButtonStyle Function(RxButtonState state)? hoverStyle;

  static Widget _defaultParent(RxButtonState state, Widget child) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      child: child,
    );
  }

  static Widget _defaultLoading(RxButtonState state) {
    return SizedBox.square(
      dimension: state.size.height / 2,
      child: const CircularProgressIndicator(
        strokeWidth: 2,
        color: Colors.white,
      ),
    );
  }

  static Widget _defaultError(RxButtonState state) {
    return Text(
      state.errorMessage,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Overrides loading [ButtonStyle].
  static ButtonStyle _defaultLoadingStyle(RxButtonState state) {
    return state.style.copyWith(
      padding: const MaterialStatePropertyAll(EdgeInsets.zero),
    );
  }

  /// Overrides error [ButtonStyle].
  static ButtonStyle _defaultErrorStyle(RxButtonState state) {
    final errorColor = Theme.of(state.context).colorScheme.error;
    final errorMaterial = MaterialStatePropertyAll(errorColor);

    return state.style.copyWith(
      backgroundColor: () {
        if (state.isOutlinedButton) return null;
        if (state.isTextButton) return null;
        return errorMaterial;
      }(),
      foregroundColor: () {
        if (state.isElevatedButton) return null;
        if (state.isFilledButton) return null;
        return errorMaterial;
      }(),
    );
  }
}
