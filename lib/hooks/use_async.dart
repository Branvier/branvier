// ignore_for_file: discarded_futures, cast_nullable_to_non_nullable

part of '/branvier.dart';

// typedef AsyncCallback<T> = Future<T> Function();

///Shares immutable intance of [value] across rebuilds.
T useFinal<T>(T value) => useRef(value).value;

/// Fetch async data only when [key] is changed or when has interval
/// If [key] is not present, the data will only be fetched once and never again.
///
/// Also returns an [AsyncSnap] with handy features like [AsyncSnapshot] and a
/// retry() method to easily retry/refresh.
///
/// This is a Sintax sugar of useMemoized with useFuture.
AsyncSnap<T> useAsyncFuture<T>(
  Future<T> Function() future, {
  Duration? interval,
  T? initialData,
  Object? key,
}) {
  final changes = useRef(0);
  final attempts = useState(0);
  final changed = useChanged<T?>(initialData, onChange: (_) => changes.value++);

  Future<T> fetch() async {
    if (changed && initialData != null) return initialData;
    return future();
  }

  //Updates the shared [SnapCallback] if the keys are changed.
  var snapshot = useFuture<T>(
    useMemoized(fetch, [attempts.value, changes.value, key]),
    initialData: initialData,
  );

  if (changed && snapshot.hasData && !snapshot.isEmpty) {
    snapshot = snapshot.inState(ConnectionState.done);
  }

  //Fetches new data every [interval].
  useInterval(() => attempts.value++, interval);

  //Creates [AsyncState] and returns it.
  return AsyncSnap<T>(snapshot, () => attempts.value++, attempts.value);
}

AsyncSnap<T> useAsyncStream<T>(
  Stream<T> Function() stream, {
  Duration? interval,
  T? initialData,
  Object? key,
}) {
  final changes = useRef(0);
  final attempts = useState(0);
  final changed = useChanged<T?>(initialData, onChange: (_) => changes.value++);

  Stream<T> fetch() async* {
    if (changed && initialData != null) {
      yield initialData;
    } else {
      yield* stream();
    }
  }

  //Updates the shared [SnapCallback] if the keys are changed.
  var snapshot = useStream<T>(
    useMemoized(fetch, [attempts.value, changes.value, key]),
    initialData: initialData,
  );

  if (changed && snapshot.hasData && !snapshot.isEmpty) {
    snapshot = snapshot.inState(ConnectionState.done);
  }

  //Fetches new data every [interval].
  useInterval(() => attempts.value++, interval);

  //Creates [AsyncState] and returns it.
  return AsyncSnap<T>(snapshot, () => attempts.value++, attempts.value);
}

///If [delay] != null, calls the callback in each [delay] interval.
void useInterval(void Function() callback, Duration? delay) {
  Timer? timer;

  useEffect(
    () {
      if (delay == null) return timer?.cancel;
      timer = Timer.periodic(delay, (_) => callback());
      return timer?.cancel;
    },
    [delay],
  );
}

///Sintax sugar for [useEffect]. Called only once.
void useInit(VoidCallback? init, {VoidCallback? dispose}) {
  useEffect(
    () {
      init?.call();
      return dispose;
    },
    [],
  );
}

///Sintax sugar for dipose(). Called only when the widget disposes.
void useDispose(VoidCallback? dispose) => useEffect(() => dispose, []);

@immutable
class AsyncSnap<T> {
  const AsyncSnap(this.snapshot, this._retry, this.attempts);

  ///The snapshot from the AsyncCallback.
  final AsyncSnapshot<T> snapshot;
  final VoidCallback _retry;

  ///Calls the AsyncCallback again.
  void retry() => _retry();

  ///Number of attempts to retry.
  final int attempts;

  ///Check if the computation is still loading.
  bool get isLoading => snapshot.connectionState != ConnectionState.done;

  //Check if the computation is loading but already had data.
  bool get isUpdating => isLoading && hasData;

  ///Returns if the data is empty iterable.
  bool get isEmpty => snapshot.isEmpty;

  ///The [AsyncSnapshot] data.
  T? get data => snapshot.data;

  ///Check if the [AsyncSnapshot] has error.
  bool get hasData => snapshot.hasData && !isEmpty;

  ///Check if the [AsyncSnapshot] has error.
  bool get hasError => snapshot.hasError;

  ///Returns the [AsyncSnapshot] error.
  Object? get e => snapshot.error;

  ///Returns the [AsyncSnapshot]'s [StackTrace].
  StackTrace? get s => snapshot.stackTrace;
}

extension AsyncSnapshotExtension<T> on AsyncSnapshot<T> {
  bool get isEmpty => data is Iterable && (data as Iterable).isEmpty;
  bool get isLoading => connectionState != ConnectionState.done;
  bool get isUpdating => isLoading && hasData && !isEmpty;
}
