part of '/branvier.dart';

typedef OnTap = void Function(GetSnackBar snack);

typedef SnackbarStatusCallback = void Function(SnackbarStatus? status);

mixin Messenger {
  // static final mkey = GlobalKey<ScaffoldMessengerState>();
  // static final key = GlobalKey<NavigatorState>();

  /// give access to current Overlay Context
  // static BuildContext? get overlayContext {
  //   BuildContext? overlay;
  //   Navigation.key.currentState?.overlay?.context.visitChildElements((element) {
  //     overlay = element;
  //   });
  //   return overlay;
  // }

  static SnackbarController rawSnackbar({
    String? title,
    String? message,
    Widget? titleText,
    Widget? messageText,
    Widget? icon,
    bool instantInit = true,
    bool shouldIconPulse = true,
    double? maxWidth,
    EdgeInsets margin = const EdgeInsets.all(0.0),
    EdgeInsets padding = const EdgeInsets.all(16),
    double borderRadius = 0.0,
    Color? borderColor,
    double borderWidth = 1.0,
    Color backgroundColor = const Color(0xFF303030),
    Color? leftBarIndicatorColor,
    List<BoxShadow>? boxShadows,
    Gradient? backgroundGradient,
    Widget? mainButton,
    OnTap? onTap,
    Duration? duration = const Duration(seconds: 3),
    bool isDismissible = true,
    DismissDirection? dismissDirection,
    bool showProgressIndicator = false,
    AnimationController? progressIndicatorController,
    Color? progressIndicatorBackgroundColor,
    Animation<Color>? progressIndicatorValueColor,
    SnackPosition snackPosition = SnackPosition.BOTTOM,
    SnackStyle snackStyle = SnackStyle.FLOATING,
    Curve forwardAnimationCurve = Curves.easeOutCirc,
    Curve reverseAnimationCurve = Curves.easeOutCirc,
    Duration animationDuration = const Duration(seconds: 1),
    SnackbarStatusCallback? snackbarStatus,
    double barBlur = 0.0,
    double overlayBlur = 0.0,
    Color? overlayColor,
    Form? userInputForm,
  }) {
    final getSnackBar = GetSnackBar(
      snackbarStatus: snackbarStatus,
      title: title,
      message: message,
      titleText: titleText,
      messageText: messageText,
      snackPosition: snackPosition,
      borderRadius: borderRadius,
      margin: margin,
      duration: duration,
      barBlur: barBlur,
      backgroundColor: backgroundColor,
      icon: icon,
      shouldIconPulse: shouldIconPulse,
      maxWidth: maxWidth,
      padding: padding,
      borderColor: borderColor,
      borderWidth: borderWidth,
      leftBarIndicatorColor: leftBarIndicatorColor,
      boxShadows: boxShadows,
      backgroundGradient: backgroundGradient,
      mainButton: mainButton,
      onTap: onTap,
      isDismissible: isDismissible,
      dismissDirection: dismissDirection,
      showProgressIndicator: showProgressIndicator,
      progressIndicatorController: progressIndicatorController,
      progressIndicatorBackgroundColor: progressIndicatorBackgroundColor,
      progressIndicatorValueColor: progressIndicatorValueColor,
      snackStyle: snackStyle,
      forwardAnimationCurve: forwardAnimationCurve,
      reverseAnimationCurve: reverseAnimationCurve,
      animationDuration: animationDuration,
      overlayBlur: overlayBlur,
      overlayColor: overlayColor,
      userInputForm: userInputForm,
    );

    final controller = SnackbarController(getSnackBar);

    if (instantInit) {
      controller.show();
    } else {
      ambiguate(SchedulerBinding.instance)?.addPostFrameCallback((_) {
        controller.show();
      });
    }
    return controller;
  }

  static SnackbarController showSnackbar(GetSnackBar snackbar) {
    final controller = SnackbarController(snackbar);
    controller.show();
    return controller;
  }

  static SnackbarController snackbar(
    String title,
    String message, {
    Color? colorText,
    Duration? duration = const Duration(seconds: 3),

    /// with instantInit = false you can put snackbar on initState
    bool instantInit = true,
    SnackPosition? snackPosition,
    Widget? titleText,
    Widget? messageText,
    Widget? icon,
    bool? shouldIconPulse,
    double? maxWidth,
    EdgeInsets? margin,
    EdgeInsets? padding,
    double? borderRadius,
    Color? borderColor,
    double? borderWidth,
    Color? backgroundColor,
    Color? leftBarIndicatorColor,
    List<BoxShadow>? boxShadows,
    Gradient? backgroundGradient,
    TextButton? mainButton,
    OnTap? onTap,
    bool? isDismissible,
    bool? showProgressIndicator,
    DismissDirection? dismissDirection,
    AnimationController? progressIndicatorController,
    Color? progressIndicatorBackgroundColor,
    Animation<Color>? progressIndicatorValueColor,
    SnackStyle? snackStyle,
    Curve? forwardAnimationCurve,
    Curve? reverseAnimationCurve,
    Duration? animationDuration,
    double? barBlur,
    double? overlayBlur,
    SnackbarStatusCallback? snackbarStatus,
    Color? overlayColor,
    Form? userInputForm,
  }) {
    final theme = Branvier.context?.theme;

    final getSnackBar = GetSnackBar(
      snackbarStatus: snackbarStatus,
      titleText: titleText ??
          Text(
            title,
            style: TextStyle(
              color: colorText ?? theme?.colorScheme.onSurface ?? Colors.black,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
      messageText: messageText ??
          Text(
            message,
            style: TextStyle(
              color: colorText ?? theme?.colorScheme.onSurface ?? Colors.black,
              fontWeight: FontWeight.w300,
              fontSize: 14,
            ),
          ),
      snackPosition: snackPosition ?? SnackPosition.TOP,
      borderRadius: borderRadius ?? 15,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 10),
      duration: duration,
      barBlur: barBlur ?? 7.0,
      backgroundColor: backgroundColor ?? Colors.grey.withOpacity(0.2),
      icon: icon,
      shouldIconPulse: shouldIconPulse ?? true,
      maxWidth: maxWidth,
      padding: padding ?? const EdgeInsets.all(16),
      borderColor: borderColor,
      borderWidth: borderWidth,
      leftBarIndicatorColor: leftBarIndicatorColor,
      boxShadows: boxShadows,
      backgroundGradient: backgroundGradient,
      mainButton: mainButton,
      onTap: onTap,
      isDismissible: isDismissible ?? true,
      dismissDirection: dismissDirection,
      showProgressIndicator: showProgressIndicator ?? false,
      progressIndicatorController: progressIndicatorController,
      progressIndicatorBackgroundColor: progressIndicatorBackgroundColor,
      progressIndicatorValueColor: progressIndicatorValueColor,
      snackStyle: snackStyle ?? SnackStyle.FLOATING,
      forwardAnimationCurve: forwardAnimationCurve ?? Curves.easeOutCirc,
      reverseAnimationCurve: reverseAnimationCurve ?? Curves.easeOutCirc,
      animationDuration: animationDuration ?? const Duration(seconds: 1),
      overlayBlur: overlayBlur ?? 0.0,
      overlayColor: overlayColor ?? Colors.transparent,
      userInputForm: userInputForm,
    );

    final controller = SnackbarController(getSnackBar);

    if (instantInit) {
      controller.show();
    } else {
      //routing.isSnackbar = true;
      ambiguate(SchedulerBinding.instance)?.addPostFrameCallback((_) {
        controller.show();
      });
    }
    return controller;
  }
}

class SnackbarController {
  SnackbarController(this.snackbar);
  static final _snackBarQueue = _SnackBarQueue();
  static bool get isSnackbarBeingShown => _snackBarQueue._isJobInProgress;
  // final key = GlobalKey<GetSnackBarState>();

  late Animation<double> _filterBlurAnimation;
  late Animation<Color?> _filterColorAnimation;

  final GetSnackBar snackbar;
  final _transitionCompleter = Completer();

  late void Function(SnackbarStatus? status)? _snackbarStatus;
  late final Alignment? _initialAlignment;
  late final Alignment? _endAlignment;

  bool _wasDismissedBySwipe = false;

  bool _onTappedDismiss = false;

  Timer? _timer;

  /// The animation that drives the route's transition and the previous route's
  /// forward transition.
  late final Animation<Alignment> _animation;

  /// The animation controller that the route uses to drive the transitions.
  ///
  /// The animation itself is exposed by the animation property.
  late final AnimationController _controller;

  SnackbarStatus? _currentStatus;

  final _overlayEntries = <OverlayEntry>[];

  OverlayState? _overlayState;

  Future<void> get future => _transitionCompleter.future;

  /// Close the snackbar with animation
  Future<void> close({bool withAnimations = true}) async {
    if (!withAnimations) {
      _removeOverlay();
      return;
    }
    _removeEntry();
    await future;
  }

  /// Adds GetSnackbar to a view queue.
  /// Only one GetSnackbar will be displayed at a time, and this method returns
  /// a future to when the snackbar disappears.
  Future<void> show() {
    return _snackBarQueue._addJob(this);
  }

  void _cancelTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
  }

  // ignore: avoid_returning_this
  void _configureAlignment(SnackPosition snackPosition) {
    switch (snackbar.snackPosition) {
      case SnackPosition.TOP:
        {
          _initialAlignment = const Alignment(-1.0, -2.0);
          _endAlignment = const Alignment(-1.0, -1.0);
          break;
        }
      case SnackPosition.BOTTOM:
        {
          _initialAlignment = const Alignment(-1.0, 2.0);
          _endAlignment = const Alignment(-1.0, 1.0);
          break;
        }
    }
  }

  void _configureOverlay() {
    _overlayState = Overlay.of(Branvier.overlay!);
    _overlayEntries.clear();
    _overlayEntries.addAll(_createOverlayEntries(_getBodyWidget()));
    _overlayState!.insertAll(_overlayEntries);
    _configureSnackBarDisplay();
  }

  void _configureSnackBarDisplay() {
    assert(
      !_transitionCompleter.isCompleted,
      'Cannot configure a snackbar after disposing it.',
    );
    _controller = _createAnimationController();
    _configureAlignment(snackbar.snackPosition);
    _snackbarStatus = snackbar.snackbarStatus;
    _filterBlurAnimation = _createBlurFilterAnimation();
    _filterColorAnimation = _createColorOverlayColor();
    _animation = _createAnimation();
    _animation.addStatusListener(_handleStatusChanged);
    _configureTimer();
    _controller.forward();
  }

  void _configureTimer() {
    if (snackbar.duration != null) {
      if (_timer != null && _timer!.isActive) {
        _timer!.cancel();
      }
      _timer = Timer(snackbar.duration!, _removeEntry);
    } else {
      if (_timer != null) {
        _timer!.cancel();
      }
    }
  }

  /// Called to create the animation that exposes the current progress of
  /// the transition controlled by the animation controller created by
  /// `createAnimationController()`.
  Animation<Alignment> _createAnimation() {
    assert(
      !_transitionCompleter.isCompleted,
      'Cannot create a animation from a disposed snackbar',
    );
    return AlignmentTween(begin: _initialAlignment, end: _endAlignment).animate(
      CurvedAnimation(
        parent: _controller,
        curve: snackbar.forwardAnimationCurve,
        reverseCurve: snackbar.reverseAnimationCurve,
      ),
    );
  }

  /// Called to create the animation controller that will drive the transitions
  /// to this route from the previous one, and back to the previous route
  /// from this one.
  AnimationController _createAnimationController() {
    assert(
      !_transitionCompleter.isCompleted,
      'Cannot create a animationController from a disposed snackbar',
    );
    assert(snackbar.animationDuration >= Duration.zero);
    return AnimationController(
      duration: snackbar.animationDuration,
      debugLabel: '$runtimeType',
      vsync: _overlayState!,
    );
  }

  Animation<double> _createBlurFilterAnimation() {
    return Tween(begin: 0.0, end: snackbar.overlayBlur).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.35,
          curve: Curves.easeInOutCirc,
        ),
      ),
    );
  }

  Animation<Color?> _createColorOverlayColor() {
    return ColorTween(
      begin: const Color(0x00000000),
      end: snackbar.overlayColor,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.35,
          curve: Curves.easeInOutCirc,
        ),
      ),
    );
  }

  Iterable<OverlayEntry> _createOverlayEntries(Widget child) {
    return <OverlayEntry>[
      if (snackbar.overlayBlur > 0.0) ...[
        OverlayEntry(
          builder: (context) => GestureDetector(
            onTap: () {
              if (snackbar.isDismissible && !_onTappedDismiss) {
                _onTappedDismiss = true;
                close();
              }
            },
            child: AnimatedBuilder(
              animation: _filterBlurAnimation,
              builder: (context, child) {
                return BackdropFilter(
                  filter: ui.ImageFilter.blur(
                    sigmaX: max(0.001, _filterBlurAnimation.value),
                    sigmaY: max(0.001, _filterBlurAnimation.value),
                  ),
                  child: Container(
                    constraints: const BoxConstraints.expand(),
                    color: _filterColorAnimation.value,
                  ),
                );
              },
            ),
          ),
        ),
      ],
      OverlayEntry(
        builder: (context) => Semantics(
          focused: false,
          container: true,
          explicitChildNodes: true,
          child: AlignTransition(
            alignment: _animation,
            child: snackbar.isDismissible
                ? _getDismissibleSnack(child)
                : _getSnackbarContainer(child),
          ),
        ),
      ),
    ];
  }

  Widget _getBodyWidget() {
    return Builder(
      builder: (_) {
        return GestureDetector(
          onTap: snackbar.onTap != null
              ? () => snackbar.onTap?.call(snackbar)
              : null,
          child: snackbar,
        );
      },
    );
  }

  DismissDirection _getDefaultDismissDirection() {
    if (snackbar.snackPosition == SnackPosition.TOP) {
      return DismissDirection.up;
    }
    return DismissDirection.down;
  }

  Widget _getDismissibleSnack(Widget child) {
    return Dismissible(
      direction: snackbar.dismissDirection ?? _getDefaultDismissDirection(),
      resizeDuration: null,
      confirmDismiss: (_) {
        if (_currentStatus == SnackbarStatus.OPENING ||
            _currentStatus == SnackbarStatus.CLOSING) {
          return Future.value(false);
        }
        return Future.value(true);
      },
      key: const Key('dismissible'),
      onDismissed: (_) {
        _wasDismissedBySwipe = true;
        _removeEntry();
      },
      child: _getSnackbarContainer(child),
    );
  }

  Widget _getSnackbarContainer(Widget child) {
    return Container(
      margin: snackbar.margin,
      child: child,
    );
  }

  void _handleStatusChanged(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.completed:
        _currentStatus = SnackbarStatus.OPEN;
        _snackbarStatus?.call(_currentStatus);
        if (_overlayEntries.isNotEmpty) _overlayEntries.first.opaque = false;

        break;
      case AnimationStatus.forward:
        _currentStatus = SnackbarStatus.OPENING;
        _snackbarStatus?.call(_currentStatus);
        break;
      case AnimationStatus.reverse:
        _currentStatus = SnackbarStatus.CLOSING;
        _snackbarStatus?.call(_currentStatus);
        if (_overlayEntries.isNotEmpty) _overlayEntries.first.opaque = false;
        break;
      case AnimationStatus.dismissed:
        assert(!_overlayEntries.first.opaque);
        _currentStatus = SnackbarStatus.CLOSED;
        _snackbarStatus?.call(_currentStatus);
        _removeOverlay();
        break;
    }
  }

  void _removeEntry() {
    assert(
      !_transitionCompleter.isCompleted,
      'Cannot remove entry from a disposed snackbar',
    );

    _cancelTimer();

    if (_wasDismissedBySwipe) {
      Timer(const Duration(milliseconds: 200), _controller.reset);
      _wasDismissedBySwipe = false;
    } else {
      _controller.reverse();
    }
  }

  void _removeOverlay() {
    for (var element in _overlayEntries) {
      element.remove();
    }

    assert(
      !_transitionCompleter.isCompleted,
      'Cannot remove overlay from a disposed snackbar',
    );
    _controller.dispose();
    _overlayEntries.clear();
    _transitionCompleter.complete();
  }

  Future<void> _show() {
    _configureOverlay();
    return future;
  }

  static void cancelAllSnackbars() {
    _snackBarQueue._cancelAllJobs();
  }

  static Future<void> closeCurrentSnackbar() async {
    await _snackBarQueue._closeCurrentJob();
  }
}

class _SnackBarQueue {
  final _queue = GetQueue();
  final _snackbarList = <SnackbarController>[];

  SnackbarController? get _currentSnackbar {
    if (_snackbarList.isEmpty) return null;
    return _snackbarList.first;
  }

  bool get _isJobInProgress => _snackbarList.isNotEmpty;

  Future<void> _addJob(SnackbarController job) async {
    _snackbarList.add(job);
    final data = await _queue.add(job._show);
    _snackbarList.remove(job);
    return data;
  }

  Future<void> _cancelAllJobs() async {
    await _currentSnackbar?.close();
    _queue.cancelAllJobs();
    _snackbarList.clear();
  }

  Future<void> _closeCurrentJob() async {
    if (_currentSnackbar == null) return;
    await _currentSnackbar!.close();
  }
}

class GetQueue {
  final List<_Item> _queue = [];
  bool _active = false;

  Future<T> add<T>(Function job) {
    final completer = Completer<T>();
    _queue.add(_Item(completer, job));
    _check();
    return completer.future;
  }

  void cancelAllJobs() {
    _queue.clear();
  }

  void _check() async {
    if (!_active && _queue.isNotEmpty) {
      _active = true;
      final item = _queue.removeAt(0);
      try {
        item.completer.complete(await item.job());
      } on Exception catch (e) {
        item.completer.completeError(e);
      }
      _active = false;
      _check();
    }
  }
}

class _Item {
  _Item(this.completer, this.job);
  final dynamic completer;
  final dynamic job;
}

/// Indicates Status of snackbar
/// [SnackbarStatus.OPEN] Snack is fully open, [SnackbarStatus.CLOSED] Snackbar
/// has closed,
/// [SnackbarStatus.OPENING] Starts with the opening animation and ends
/// with the full
/// snackbar display, [SnackbarStatus.CLOSING] Starts with the closing animation
/// and ends
/// with the full snackbar dispose
enum SnackbarStatus { OPEN, CLOSED, OPENING, CLOSING }

/// Indicates if snack is going to start at the [TOP] or at the [BOTTOM]
enum SnackPosition { TOP, BOTTOM }

/// Indicates if snack will be attached to the edge of the screen or not
enum SnackStyle { FLOATING, GROUNDED }

class GetSnackBar extends StatefulWidget {
  const GetSnackBar({
    this.title,
    this.message,
    this.titleText,
    this.messageText,
    this.icon,
    this.shouldIconPulse = true,
    this.maxWidth,
    this.margin = const EdgeInsets.all(0.0),
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 0.0,
    this.borderColor,
    this.borderWidth = 1.0,
    this.backgroundColor = const Color(0xFF303030),
    this.leftBarIndicatorColor,
    this.boxShadows,
    this.backgroundGradient,
    this.mainButton,
    this.onTap,
    this.duration,
    this.isDismissible = true,
    this.dismissDirection,
    this.showProgressIndicator = false,
    this.progressIndicatorController,
    this.progressIndicatorBackgroundColor,
    this.progressIndicatorValueColor,
    this.snackPosition = SnackPosition.BOTTOM,
    this.snackStyle = SnackStyle.FLOATING,
    this.forwardAnimationCurve = Curves.easeOutCirc,
    this.reverseAnimationCurve = Curves.easeOutCirc,
    this.animationDuration = const Duration(seconds: 1),
    this.barBlur = 0.0,
    this.overlayBlur = 0.0,
    this.overlayColor = Colors.transparent,
    this.userInputForm,
    this.snackbarStatus,
  });

  /// A callback for you to listen to the different Snack status
  final SnackbarStatusCallback? snackbarStatus;

  /// The title displayed to the user
  final String? title;

  /// The direction in which the SnackBar can be dismissed.
  ///
  /// Default is [DismissDirection.down] when
  /// [snackPosition] == [SnackPosition.BOTTOM] and [DismissDirection.up]
  /// when [snackPosition] == [SnackPosition.TOP]
  final DismissDirection? dismissDirection;

  /// The message displayed to the user.
  final String? message;

  /// Replaces [title]. Although this accepts a [Widget], it is meant
  /// to receive [Text] or [RichText]
  final Widget? titleText;

  /// Replaces [message]. Although this accepts a [Widget], it is meant
  /// to receive [Text] or  [RichText]
  final Widget? messageText;

  /// Will be ignored if [backgroundGradient] is not null
  final Color backgroundColor;

  /// If not null, shows a left vertical colored bar on notification.
  /// It is not possible to use it with a [Form] and I do not recommend
  /// using it with [LinearProgressIndicator]
  final Color? leftBarIndicatorColor;

  /// [boxShadows] The shadows generated by Snack. Leave it null
  /// if you don't want a shadow.
  /// You can use more than one if you feel the need.
  /// Check (this example)[https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/material/shadows.dart]
  final List<BoxShadow>? boxShadows;

  /// Give to GetSnackbar a gradient background.
  /// It Makes [backgroundColor] be ignored.
  final Gradient? backgroundGradient;

  /// You can use any widget here, but I recommend [Icon] or [Image] as
  /// indication of what kind
  /// of message you are displaying. Other widgets may break the layout
  final Widget? icon;

  /// An option to animate the icon (if present). Defaults to true.
  final bool shouldIconPulse;

  /// (optional) An action that the user can take based on the snack bar.
  ///
  /// For example, the snack bar might let the user undo the operation that
  /// prompted the snackbar.
  final Widget? mainButton;

  /// A callback that registers the user's click anywhere.
  /// An alternative to [mainButton]
  final void Function(GetSnackBar snack)? onTap;

  /// How long until Snack will hide itself (be dismissed).
  /// To make it indefinite, leave it null.
  final Duration? duration;

  /// True if you want to show a [LinearProgressIndicator].
  final bool showProgressIndicator;

  /// An optional [AnimationController] when you want to control the
  /// progress of your [LinearProgressIndicator].
  final AnimationController? progressIndicatorController;

  /// A [LinearProgressIndicator] configuration parameter.
  final Color? progressIndicatorBackgroundColor;

  /// A [LinearProgressIndicator] configuration parameter.
  final Animation<Color>? progressIndicatorValueColor;

  /// Determines if the user can swipe or click the overlay
  /// (if [overlayBlur] > 0) to dismiss.
  /// It is recommended that you set [duration] != null if this is false.
  /// If the user swipes to dismiss or clicks the overlay, no value
  /// will be returned.
  final bool isDismissible;

  /// Used to limit Snack width (usually on large screens)
  final double? maxWidth;

  /// Adds a custom margin to Snack
  final EdgeInsets margin;

  /// Adds a custom padding to Snack
  /// The default follows material design guide line
  final EdgeInsets padding;

  /// Adds a radius to all corners of Snack. Best combined with [margin].
  /// I do not recommend using it with [showProgressIndicator]
  /// or [leftBarIndicatorColor].
  final double borderRadius;

  /// Adds a border to every side of Snack
  /// I do not recommend using it with [showProgressIndicator]
  /// or [leftBarIndicatorColor].
  final Color? borderColor;

  /// Changes the width of the border if [borderColor] is specified
  final double? borderWidth;

  /// Snack can be based on [SnackPosition.TOP] or on [SnackPosition.BOTTOM]
  /// of your screen.
  /// [SnackPosition.BOTTOM] is the default.
  final SnackPosition snackPosition;

  /// Snack can be floating or be grounded to the edge of the screen.
  /// If grounded, I do not recommend using [margin] or [borderRadius].
  /// [SnackStyle.FLOATING] is the default
  /// If grounded, I do not recommend using a [backgroundColor] with
  /// transparency or [barBlur]
  final SnackStyle snackStyle;

  /// The [Curve] animation used when show() is called.
  /// [Curves.easeOut] is default
  final Curve forwardAnimationCurve;

  /// The [Curve] animation used when dismiss() is called.
  /// [Curves.fastOutSlowIn] is default
  final Curve reverseAnimationCurve;

  /// Use it to speed up or slow down the animation duration
  final Duration animationDuration;

  /// Default is 0.0. If different than 0.0, blurs only Snack's background.
  /// To take effect, make sure your [backgroundColor] has some opacity.
  /// The greater the value, the greater the blur.
  final double barBlur;

  /// Default is 0.0. If different than 0.0, creates a blurred
  /// overlay that prevents the user from interacting with the screen.
  /// The greater the value, the greater the blur.
  final double overlayBlur;

  /// Default is [Colors.transparent]. Only takes effect if [overlayBlur] > 0.0.
  /// Make sure you use a color with transparency here e.g.
  /// Colors.grey[600].withOpacity(0.2).
  final Color? overlayColor;

  /// A [TextFormField] in case you want a simple user input.
  /// Every other widget is ignored if this is not null.
  final Form? userInputForm;

  @override
  State createState() => GetSnackBarState();

  /// Show the snack. It's call [SnackbarStatus.OPENING] state
  /// followed by [SnackbarStatus.OPEN]
  SnackbarController show() {
    // return Get.showSnackbar(this);
    final controller = SnackbarController(this);
    controller.show();
    return controller;
  }
}

T? ambiguate<T>(T? value) => value;

class GetSnackBarState extends State<GetSnackBar>
    with TickerProviderStateMixin {
  AnimationController? _fadeController;
  late Animation<double> _fadeAnimation;

  final Widget _emptyWidget = const SizedBox(width: 0.0, height: 0.0);
  final double _initialOpacity = 1.0;
  final double _finalOpacity = 0.4;

  final Duration _pulseAnimationDuration = const Duration(seconds: 1);

  late bool _isTitlePresent;
  late double _messageTopMargin;

  FocusScopeNode? _focusNode;
  late FocusAttachment _focusAttachment;

  final Completer<Size> _boxHeightCompleter = Completer<Size>();

  late CurvedAnimation _progressAnimation;

  final _backgroundBoxKey = GlobalKey();

  double get buttonPadding {
    if (widget.padding.right - 12 < 0) {
      return 4;
    } else {
      return widget.padding.right - 12;
    }
  }

  RowStyle get _rowStyle {
    if (widget.mainButton != null && widget.icon == null) {
      return RowStyle.action;
    } else if (widget.mainButton == null && widget.icon != null) {
      return RowStyle.icon;
    } else if (widget.mainButton != null && widget.icon != null) {
      return RowStyle.all;
    } else {
      return RowStyle.none;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      heightFactor: 1.0,
      child: Material(
        color: widget.snackStyle == SnackStyle.FLOATING
            ? Colors.transparent
            : widget.backgroundColor,
        child: SafeArea(
          minimum: widget.snackPosition == SnackPosition.BOTTOM
              ? EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                )
              : EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          bottom: widget.snackPosition == SnackPosition.BOTTOM,
          top: widget.snackPosition == SnackPosition.TOP,
          left: false,
          right: false,
          child: Stack(
            children: [
              FutureBuilder<Size>(
                future: _boxHeightCompleter.future,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (widget.barBlur == 0) {
                      return _emptyWidget;
                    }
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(
                          sigmaX: widget.barBlur,
                          sigmaY: widget.barBlur,
                        ),
                        child: Container(
                          height: snapshot.data!.height,
                          width: snapshot.data!.width,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(widget.borderRadius),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return _emptyWidget;
                  }
                },
              ),
              if (widget.userInputForm != null)
                _containerWithForm()
              else
                _containerWithoutForm()
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController?.dispose();
    widget.progressIndicatorController?.removeListener(_updateProgress);
    widget.progressIndicatorController?.dispose();

    _focusAttachment.detach();
    _focusNode!.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    assert(
        widget.userInputForm != null ||
            ((widget.message != null && widget.message!.isNotEmpty) ||
                widget.messageText != null),
        '''
You need to either use message[String], or messageText[Widget] or define a userInputForm[Form] in GetSnackbar''');

    _isTitlePresent = widget.title != null || widget.titleText != null;
    _messageTopMargin = _isTitlePresent ? 6.0 : widget.padding.top;

    _configureLeftBarFuture();
    _configureProgressIndicatorAnimation();

    if (widget.icon != null && widget.shouldIconPulse) {
      _configurePulseAnimation();
      _fadeController?.forward();
    }

    _focusNode = FocusScopeNode();
    _focusAttachment = _focusNode!.attach(context);
  }

  Widget _buildLeftBarIndicator() {
    if (widget.leftBarIndicatorColor != null) {
      return FutureBuilder<Size>(
        future: _boxHeightCompleter.future,
        builder: (buildContext, snapshot) {
          if (snapshot.hasData) {
            return Container(
              color: widget.leftBarIndicatorColor,
              width: 5.0,
              height: snapshot.data!.height,
            );
          } else {
            return _emptyWidget;
          }
        },
      );
    } else {
      return _emptyWidget;
    }
  }

  void _configureLeftBarFuture() {
    ambiguate(SchedulerBinding.instance)?.addPostFrameCallback(
      (_) {
        final keyContext = _backgroundBoxKey.currentContext;
        if (keyContext != null) {
          final box = keyContext.findRenderObject() as RenderBox;
          _boxHeightCompleter.complete(box.size);
        }
      },
    );
  }

  void _configureProgressIndicatorAnimation() {
    if (widget.showProgressIndicator &&
        widget.progressIndicatorController != null) {
      widget.progressIndicatorController!.addListener(_updateProgress);

      _progressAnimation = CurvedAnimation(
        curve: Curves.linear,
        parent: widget.progressIndicatorController!,
      );
    }
  }

  void _configurePulseAnimation() {
    _fadeController =
        AnimationController(vsync: this, duration: _pulseAnimationDuration);
    _fadeAnimation = Tween(begin: _initialOpacity, end: _finalOpacity).animate(
      CurvedAnimation(
        parent: _fadeController!,
        curve: Curves.linear,
      ),
    );

    _fadeController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _fadeController!.reverse();
      }
      if (status == AnimationStatus.dismissed) {
        _fadeController!.forward();
      }
    });

    _fadeController!.forward();
  }

  Widget _containerWithForm() {
    return Container(
      key: _backgroundBoxKey,
      constraints: widget.maxWidth != null
          ? BoxConstraints(maxWidth: widget.maxWidth!)
          : null,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        gradient: widget.backgroundGradient,
        boxShadow: widget.boxShadows,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: widget.borderColor != null
            ? Border.all(
                color: widget.borderColor!,
                width: widget.borderWidth!,
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 8.0,
          right: 8.0,
          bottom: 8.0,
          top: 16.0,
        ),
        child: FocusScope(
          node: _focusNode,
          autofocus: true,
          child: widget.userInputForm!,
        ),
      ),
    );
  }

  Widget _containerWithoutForm() {
    final iconPadding = widget.padding.left > 16.0 ? widget.padding.left : 0.0;
    final left = _rowStyle == RowStyle.icon || _rowStyle == RowStyle.all
        ? 4.0
        : widget.padding.left;
    final right = _rowStyle == RowStyle.action || _rowStyle == RowStyle.all
        ? 8.0
        : widget.padding.right;
    return Container(
      key: _backgroundBoxKey,
      constraints: widget.maxWidth != null
          ? BoxConstraints(maxWidth: widget.maxWidth!)
          : null,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        gradient: widget.backgroundGradient,
        boxShadow: widget.boxShadows,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: widget.borderColor != null
            ? Border.all(color: widget.borderColor!, width: widget.borderWidth!)
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showProgressIndicator)
            LinearProgressIndicator(
              value: widget.progressIndicatorController != null
                  ? _progressAnimation.value
                  : null,
              backgroundColor: widget.progressIndicatorBackgroundColor,
              valueColor: widget.progressIndicatorValueColor,
            )
          else
            _emptyWidget,
          Row(
            children: [
              _buildLeftBarIndicator(),
              if (_rowStyle == RowStyle.icon || _rowStyle == RowStyle.all)
                ConstrainedBox(
                  constraints:
                      BoxConstraints.tightFor(width: 42.0 + iconPadding),
                  child: _getIcon(),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (_isTitlePresent)
                      Padding(
                        padding: EdgeInsets.only(
                          top: widget.padding.top,
                          left: left,
                          right: right,
                        ),
                        child: widget.titleText ??
                            Text(
                              widget.title ?? '',
                              style: const TextStyle(
                                fontSize: 16.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      )
                    else
                      _emptyWidget,
                    Padding(
                      padding: EdgeInsets.only(
                        top: _messageTopMargin,
                        left: left,
                        right: right,
                        bottom: widget.padding.bottom,
                      ),
                      child: widget.messageText ??
                          Text(
                            widget.message ?? '',
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.white,
                            ),
                          ),
                    ),
                  ],
                ),
              ),
              if (_rowStyle == RowStyle.action || _rowStyle == RowStyle.all)
                Padding(
                  padding: EdgeInsets.only(right: buttonPadding),
                  child: widget.mainButton,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget? _getIcon() {
    if (widget.icon != null && widget.icon is Icon && widget.shouldIconPulse) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: widget.icon,
      );
    } else if (widget.icon != null) {
      return widget.icon;
    } else {
      return _emptyWidget;
    }
  }

  void _updateProgress() => setState(() {});
}

enum RowStyle {
  icon,
  action,
  all,
  none,
}
