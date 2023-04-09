part of '/branvier.dart';

class AsyncController<T> {
  late final StreamController<AsyncSnap<T>> _streamController;
  late AsyncSnap<T> _state;
  late final VoidCallback _retry;
  var _attached = false;

  ///Tells if the [AsyncController] is attached to the [AsyncSnap].
  bool get isAttached => _attached;

  ///Stream of all [AsyncSnap] events from [AsyncBuilder].
  Stream<AsyncSnap<T>> get stream {
    if (!isAttached) throw AsyncException.called('stream');
    return _streamController.stream;
  }

  ///The current state of the [AsyncBuilder].
  AsyncSnap<T> get state {
    if (!isAttached) throw AsyncException.called('state');
    return _state;
  }

  ///Calls the async callback again. Rebuilds AsyncBuilder.
  void reload() => _retry();

  ///Syncs the [AsyncSnap] to the [AsyncController].
  void _sync(AsyncSnap<T> state) {
    _streamController.add(_state = state);
  }

  ///Attaches the [AsyncSnap] to the [AsyncController].
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

class Async<T> {
  const Async.stream(
    this.stream, {
    this.interval,
    this.initialData,
    this.controller,
  }) : future = null;

  const Async.future(
    this.future, {
    this.interval,
    this.initialData,
    this.controller,
  }) : stream = null;

  final T? initialData;
  final Future<T> Function()? future;
  final Stream<T> Function()? stream;
  final Duration? interval;
  final AsyncController? controller;
}

class AsyncStates {
  const AsyncStates({
    this.onError,
    this.onNull = const Center(child: Text('null.data')),
    this.onEmpty = const Center(child: Text('-')),
    this.onLoading = const Center(child: CircularProgressIndicator()),
    this.onReloading,
  });
  const AsyncStates.min({
    this.onError,
    this.onNull = const Text('null.data'),
    this.onEmpty = const Text('-'),
    this.onLoading = const CircularProgressIndicator(),
    this.onReloading,
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
  final WidgetWrap? onReloading;
}

class AsyncBuilder<T> extends HookWidget {
  const AsyncBuilder({
    required this.async,
    required this.builder,
    this.states = const AsyncStates(),
    super.key,
  });

  ///The main async function. Useful for fetching data.
  final Async<T> async;

  ///The builder with [AsyncSnapshot] data.
  final Widget Function(T data) builder;

  ///The [AsyncBuilder] states.
  final AsyncStates states;

  @override
  Widget build(BuildContext context) {
    late final AsyncSnap<T> snap;

    //If both are null, return [empty].
    if (async.stream == null && async.future == null) return states.onEmpty;

    final init = async.initialData;
    if (async.stream != null) snap = useAsyncStream(async.stream!, init: init);
    if (async.future != null) snap = useAsyncFuture(async.future!, init: init);

    //Retry every [interval], if not null.
    useInterval(snap.retry, async.interval);

    //Called once. Attaches on build. Closes on widget dispose.
    useInit(
      () => async.controller?._attach(snap.retry),
      dispose: async.controller?._close,
    );

    //Called on every build. Keeps controller synced to the widget.
    async.controller?._sync(snap);

    //On error.
    Widget error(String e) => states.onError?.call(e) ?? Center(child: Text(e));

    //On data.
    Widget child() => snap.isEmpty ? states.onEmpty : builder(snap.data as T);

    if (snap.isUpdating) {
      return states.onReloading?.call(child()) ?? Reloader(child());
    }
    if (snap.isLoading) return states.onLoading;
    if (snap.hasError) return error(snap.e.toString());
    if (snap.data == null) return states.onNull;

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
