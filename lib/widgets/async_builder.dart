part of '/branvier.dart';

class AsyncController<T> {
  AsyncController({
    this.interval,
    this.onReassemble,
    this.onAppLifecycleStateChange,
    this.onAsyncState,
  });

  final Duration? interval;
  final VoidCallback? onReassemble;
  final LifecycleCallback? onAppLifecycleStateChange;
  final void Function(AsyncSnap<T> state)? onAsyncState;

  ///Calls the async callback again. Rebuilds AsyncBuilder.
  void reload() => _resync?.call();
  VoidCallback? _resync;
}

typedef AsyncListener<T> = void Function(AsyncSnap<T> state);

class AsyncStates {
  const AsyncStates({
    this.center = true,
    this.onError = Text.new,
    this.onNull = const Text('null.data'),
    this.onEmpty = const Text('-'),
    this.onLoading = const CircularProgressIndicator.adaptive(),
    this.onReloading = const Align(
      alignment: Alignment.topCenter,
      child: LinearProgressIndicator(),
    ),
  });

  AsyncStates.none({
    this.center = false,
    this.onError,
    this.onNull = const SizedBox.shrink(),
    this.onEmpty = const SizedBox.shrink(),
    this.onLoading = const SizedBox.shrink(),
    this.onReloading = const SizedBox.shrink(),
  });

  @Deprecated('User center = false instead or .none()')
  const AsyncStates.min({
    this.center = false,
    this.onError,
    this.onNull = const SizedBox.shrink(),
    this.onEmpty = const SizedBox.shrink(),
    this.onLoading = const CircularProgressIndicator(),
    this.onReloading = const SizedBox.shrink(),
  });

  /// Whether to put [Center] in all states (except [onReloading]).
  final bool center;

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
    super.key,
  })  : _future = future,
        _stream = null;

  const AsyncBuilder.stream({
    required Stream<T> Function() stream,
    required this.builder,
    this.initialData,
    this.controller,
    this.states = const AsyncStates(),
    super.key,
  })  : _stream = stream,
        _future = null;

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

    if (controller?.onAppLifecycleStateChange != null) {
      useOnAppLifecycleStateChange(controller!.onAppLifecycleStateChange);
    }
    if (controller?.onReassemble != null) {
      useReassemble(controller!.onReassemble!);
    }

    if (_future != null) {
      snap = useAsyncFuture(_future!, initialData: initialData);
    } else {
      snap = useAsyncStream(_stream!, initialData: initialData);
    }

    //Retry every [interval], if not null.
    useInterval(snap.retry, controller?.interval);

    //Called once. Attaches on build. Closes on widget dispose.
    useInit(() {
      controller?._resync = snap.retry;
    });

    //Called on every build. Keeps controller synced to the widget.
    controller?.onAsyncState?.call(snap);

    //On error.
    Widget error(String e) =>
        states.onError?.call(e) ?? const SizedBox.shrink();

    //On data.
    Widget child() => builder(snap.data as T).withFill();
    Widget reloading() {
      if (states.onReloading == null) return states.onLoading;
      return Stack(children: [child(), states.onReloading!]);
    }

    if (snap.isUpdating) return reloading();
    if (snap.isLoading) return states.onLoading._center(states.center);
    if (snap.hasError) return error('${snap.e}')._center(states.center);
    if (snap.data == null) return states.onNull._center(states.center);
    if (snap.isEmpty) return states.onEmpty._center(states.center);

    return Stack(children: [child()]);
  }
}

extension on Widget {
  Widget _center(bool will) => will ? Center(child: this) : this;
}

typedef ReBuilderCallback = void Function(ReBuilderState state);

class ReBuilder extends StatefulWidget {
  /// Controls rebuilds states.
  ///
  /// - You can set [interval] duration between [rebuilds].
  /// - You can acces [ReBuilderState] on any callback.
  const ReBuilder({
    super.key,
    this.interval = Duration.zero,
    this.rebuilds = 0,
    this.onInit,
    this.onDispose,
    this.onBuild,
    this.onRebuild,
    required this.builder,
  });

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

class AsyncListBuilder<T extends Object> extends StatelessWidget {
  const AsyncListBuilder({
    required this.list,
    required this.builder,
    this.future,
    this.controller,
    this.states = const AsyncStates(),
    this.config = const ListConfig(),
    super.key,
  });

  final List<T> list;
  final Widget Function(T item, int i) builder; //sucess

  //Async
  final AsyncController<T>? controller;
  final Future<void> Function()? future;
  final AsyncStates states;
  final ListConfig<T> config;

  @override
  Widget build(BuildContext context) {
    return AsyncBuilder<List<T>>(
      initialData: list,
      controller: controller,
      future: () async {
        await future?.call();
        return list;
      },
      builder: (list) {
        return ListBuilder(list: list, builder: builder, config: config);
      },
    );
  }
}
