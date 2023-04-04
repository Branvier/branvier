part of '/branvier.dart';

class AsyncController<T> {
  late final StreamController<AsyncState<T>> _streamController;
  late AsyncState<T> _state;
  late final VoidCallback _retry;
  var _attached = false;

  ///Tells if the [AsyncController] is attached to the [AsyncState].
  bool get isAttached => _attached;

  ///Stream of all [AsyncState] events from [AsyncBuilder].
  Stream<AsyncState<T>> get stream {
    if (!isAttached) throw AsyncException.called('stream');
    return _streamController.stream;
  }

  ///The current state of the [AsyncBuilder].
  AsyncState<T> get state {
    if (!isAttached) throw AsyncException.called('state');
    return _state;
  }

  ///Calls the async callback again. Rebuilds AsyncBuilder.
  void reload() => _retry();

  ///Syncs the [AsyncState] to the [AsyncController].
  void _sync(AsyncState<T> state) {
    _streamController.add(_state = state);
  }

  ///Attaches the [AsyncState] to the [AsyncController].
  void _attach(VoidCallback retry) {
    if (isAttached) throw AsyncException('Controller already attached');
    _attached = true;
    _retry = retry;
    _streamController = StreamController();
  }

  ///Closes the stream. All listeners will be removed (no need to cancel them).
  Future<void> _close() async {
    if (!isAttached) throw AsyncException.called('close');
    await _streamController.close();
  }
}

class AsyncException implements Exception {
  AsyncException(this.message);
  AsyncException.called(String object)
      : message = 'Tried to call $object while controller is not attached.\n'
            'You have to wait AsyncBuilder build, before using AsyncController';

  final String message;
}

class AsyncBuilder<T> extends HookWidget {
  const AsyncBuilder({
    required this.builder,
    this.future,
    this.stream,
    this.controller,
    this.interval,
    this.reloader,
    this.loader = const Center(child: CircularProgressIndicator()),
    this.empty = const Center(child: Text('-')),
    this.error,
    super.key,
  }) : assert(future != null || stream != null, 'No async function found.');

  ///The main async function. Useful for fetching data.
  final FutureGet<T>? future;
  final StreamGet<T>? stream;

  ///The builder with [AsyncSnapshot] data.
  final WidgetOn<T> builder;

  ///Controls the state of the [AsyncBuilder].
  final AsyncController? controller;

  ///If not null, calls the async each [interval]'s [Duration].
  final Duration? interval;

  ///[Widget] that shows while async is not done.
  final Widget loader;

  ///Wraps [builder] while async is updating.
  final WidgetWrapper? reloader;

  ///[Widget] that shows while async is done, but empty.
  final Widget empty;

  ///The builder with [AsyncSnapshot] error message.
  final WidgetOn<String>? error;

  @override
  Widget build(BuildContext context) {
    late final AsyncState<T> async;

    //If both are null, return [empty].
    if (stream == null && future == null) return empty;

    if (this.stream != null) async = useAsyncStream(this.stream!);
    if (this.future != null) async = useAsyncFuture(this.future!);

    //Retry every [interval], if not null.
    useInterval(async.retry, interval);

    //Called once. Attaches on build. Closes on widget dispose.
    useInit(
      () => controller?._attach(async.retry),
      dispose: controller?._close,
    );

    //Called on every build. Keeps controller synced to the widget.
    controller?._sync(async);

    //On error.
    Widget error(String e) => this.error?.call(e) ?? Center(child: Text(e));

    //On data.
    Widget child() => async.isEmpty ? empty : builder(async.data as T);

    if (async.isUpdating) return reloader?.call(child()) ?? Reloader(child());
    if (async.isLoading) return loader;
    if (async.hasError) return error(async.e.toString());
    return child();
  }
}

class Reloader extends StatelessWidget {
  const Reloader(this.child, {super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: child),
        const LinearProgressIndicator().toTopCenter(),
      ],
    );
  }
}
