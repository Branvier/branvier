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
  void fetch() => _retry();

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
  void _close() {
    if (!isAttached) throw AsyncException.called('close');
    _streamController.close();
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
    this.initial,
    this.controller,
    this.interval,
    this.updater,
    this.loader = const Center(child: CircularProgressIndicator()),
    this.empty = const Center(child: Text('-')),
    this.error,
    Key? key,
  })  : assert(future != null || stream != null, 'No async function found.'),
        super(key: key);

  ///The main async function. Useful for fetching data.
  final FutureGet<T>? future;
  final StreamGet<T>? stream;

  ///Fallback async function. Useful for initial data.
  final FutureGet<T>? initial;

  ///The builder with [AsyncSnapshot] data.
  final WidgetOn<T> builder;

  ///Controls the state of the [AsyncBuilder].
  final AsyncController? controller;

  ///If not null, calls the [future] each [interval]'s [Duration].
  final Duration? interval;

  ///[Widget] that shows while [future] is not done.
  final Widget loader;

  ///Wraps [builder] while [future] is updating.
  final WidgetWrapper? updater;

  ///[Widget] that shows while [future] is done, but empty.
  final Widget empty;

  ///The builder with [AsyncSnapshot] error message.
  final WidgetOn<String>? error;

  @override
  Widget build(BuildContext context) {
    final initial = this.initial != null ? useAsyncFuture(this.initial!) : null;
    late final AsyncState<T> async;

    if (stream == null && future == null) return empty;

    if (this.stream != null) async = useAsyncStream(this.stream!);
    if (this.future != null) async = useAsyncFuture(this.future!);

    useInterval(async.retry, interval);

    final hasInitialData = initial?.data != null;
    final state = (hasInitialData && !async.hasData) ? initial! : async;

    //Called once. Attaches on build. Closes on widget dispose.
    useInit(
      () => controller?._attach(async.retry),
      dispose: controller?._close,
    );

    //Called on every build. Keeps controller synced to the widget.
    controller?._sync(state);

    //On error.
    Widget error(String e) => this.error?.call(e) ?? Center(child: Text(e));

    //On data.
    Widget child() => state.isEmpty ? empty : builder(state.data as T);

    if (state.isUpdating) return updater?.call(child()) ?? Updater(child());
    if (state.isLoading) return loader;
    if (state.hasError) return error(state.e.toString());
    return child();
  }
}

class Updater extends StatelessWidget {
  const Updater(this.child, {Key? key}) : super(key: key);
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
