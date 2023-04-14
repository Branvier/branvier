part of '/branvier.dart';

class AsyncController<T> {
  AsyncController({this.interval});

  final Duration? interval;
  VoidCallback? _resync;
  void Function(AsyncSnap<T> state)? onState;

  ///Calls the async callback again. Rebuilds AsyncBuilder.
  void reload() => _resync?.call();

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
  final WidgetOn<String>? onError;

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
    Widget child() => builder(snap.data as T).fill();
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
