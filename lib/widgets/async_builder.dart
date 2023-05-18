part of '/branvier.dart';

class AsyncController<T> {
  AsyncController({this.interval});

  final Duration? interval;
  VoidCallback? _resync;
  void Function(AsyncSnap<T> state)? onState;

  ///Calls the async callback again. Rebuilds AsyncBuilder.
  void reload() => _resync?.call();

  // ignore: use_setters_to_change_properties
  void listen(AsyncListener<T> onState) {
    this.onState = onState;
  }
}
typedef AsyncListener<T> = void Function(AsyncSnap<T> state);

class AsyncStates {
  const AsyncStates({
    this.onError,
    this.onNull = const Center(child: Text('null.data')),
    this.onEmpty = const Center(child: Text('-')),
    this.onLoading = const Center(child: CircularProgressIndicator()),
    this.onReloading = const Align(
      alignment: Alignment.topCenter,
      child: LinearProgressIndicator(),
    ),
  });

  const AsyncStates.min({
    this.onError,
    this.onNull = const SizedBox.shrink(),
    this.onEmpty = const SizedBox.shrink(),
    this.onLoading = const CircularProgressIndicator(),
    this.onReloading = const SizedBox.shrink(),
  });

  ///The builder with [AsyncSnapshot] error message.
  final Widget Function(String errorText)? onError;

  ///[Widget] to show when async is done, but null.
  final Widget onNull;

  ///[Widget] to show when async is done, but empty.
  final Widget onEmpty;

  ///[Widget] that shows while async is not done.
  final Widget onLoading;

  ///Wraps builder while async is updating.
  final Widget? onReloading;
}

class AsyncBuilder<T> extends HookWidget {
  const AsyncBuilder({
    required Future<T> Function() future,
    required this.builder,
    this.initialData,
    this.controller,
    this.states = const AsyncStates(),
    Key? key,
  })  : _future = future,
        _stream = null,
        super(key: key);

  const AsyncBuilder.stream({
    required Stream<T> Function() stream,
    required this.builder,
    this.initialData,
    this.controller,
    this.states = const AsyncStates(),
    Key? key,
  })  : _stream = stream,
        _future = null,
        super(key: key);

  ///The main async function. Useful for fetching data.
  final Future<T> Function()? _future;
  final Stream<T> Function()? _stream;
  final T? initialData;

  ///The builder with [AsyncSnapshot] data.
  final Widget Function(T data) builder;

  ///Can observe and control the current async function.
  final AsyncController? controller;

  ///The [AsyncBuilder] states.
  final AsyncStates states;

  @override
  Widget build(BuildContext context) {
    late final AsyncSnap<T> snap;

    if (_future != null) {
      snap = useAsyncFuture(_future!, initialData: initialData);
    } else {
      snap = useAsyncStream(_stream!, initialData: initialData);
    }

    //Retry every [interval], if not null.
    useInterval(snap.retry, controller?.interval);

    //Called once. Attaches on build. Closes on widget dispose.
    useInit(() => controller?._resync = snap.retry);

    //Called on every build. Keeps controller synced to the widget.
    controller?.onState?.call(snap);

    //On error.
    Widget error(String e) => states.onError?.call(e) ?? Center(child: Text(e));

    //On data.
    Widget child() => builder(snap.data as T).withFill();
    Widget reloading() {
      if (states.onReloading == null) return states.onLoading;
      return Stack(children: [child(), states.onReloading!]);
    }

    if (snap.isUpdating) return reloading();
    if (snap.isLoading) return states.onLoading;
    if (snap.hasError) return error(snap.e.toString());
    if (snap.data == null) return states.onNull;
    if (snap.isEmpty) return states.onEmpty;

    return Stack(children: [child()]);
  }
}

typedef ReBuilderCallback = void Function(ReBuilderState state);

class ReBuilder extends StatefulWidget {
  /// Controls rebuilds states.
  ///
  /// - You can set [interval] duration between [rebuilds].
  /// - You can acces [ReBuilderState] on any callback.
  const ReBuilder({
    Key? key,
    this.interval = Duration.zero,
    this.rebuilds = 0,
    this.onInit,
    this.onDispose,
    this.onBuild,
    this.onRebuild,
    required this.builder,
  }) : super(key: key);

  final ReBuilderCallback? onInit;
  final ReBuilderCallback? onDispose;
  final ReBuilderCallback? onBuild;
  final ReBuilderCallback? onRebuild;
  final Widget Function(ReBuilderState state) builder;

  /// The interval between rebuilds.
  final Duration interval;

  /// How many times it will rebuild. Default is 1 extra rebuild.
  final int rebuilds;

  @override
  ReBuilderState createState() => ReBuilderState();
}

class ReBuilderState extends State<ReBuilder> {
  var rebuilds = 0;

  @override
  void initState() {
    // On init.
    widget.onInit?.call(this);
    super.initState();

    // On build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onBuild?.call(this);
    });
  }

  /// Resets the [rebuilds] to zero.
  void reset() {
    rebuilds = 0;
  }

  /// Immediatly adds a rebuild.
  void rebuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => rebuilds++);
      widget.onRebuild?.call(this);
    });
  }

  /// The [_rebuilder] is never a infite loop. When the widget.rebuilds reaches, it stops.
  void _rebuilder() {
    if (rebuilds >= widget.rebuilds) return reset();
    Future.delayed(widget.interval, rebuild);
  }

  @override
  void dispose() {
    // On dispose.
    widget.onDispose?.call(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _rebuilder();
    return widget.builder(this);
  }
}
