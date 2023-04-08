// ignore_for_file: discarded_futures

part of '/branvier.dart';

// typedef AsyncCallback<T> = Future<T> Function();

/// Fetch async data only when [key] is changed or when has interval
/// If [key] is not present, the data will only be fetched once and never again.
///
/// Also returns an [AsyncState] with handy features like [AsyncSnapshot] and a
/// retry() method to easily retry/refresh.
///
/// This is a Sintax sugar of useMemoized with useFuture.
AsyncState<T> useAsyncFuture<T>(
  Future<T> Function() async, {
  Duration? interval,
  T? initialData,
  Object? key,
}) {
  final attempts = useState(0);

  //Updates the shared [SnapCallback] if the keys are changed.
  final snapshot = useFuture<T>(
    useMemoized(async, [attempts.value, key]),
    initialData: initialData,
  );

  //Fetches new data every [interval].
  useInterval(() => attempts.value++, interval);

  //Creates [AsyncState] and returns it.
  return AsyncState<T>(snapshot, () => attempts.value++, attempts.value);
}

AsyncState<T> useAsyncStream<T>(
  Stream<T> Function() stream, {
  T? initialData,
  Object? key,
}) {
  final attempts = useState(0);

  //Updates the shared [SnapCallback] if the keys are changed.
  final snapshot = useStream<T>(
    useMemoized(stream, [attempts.value, key]),
    initialData: initialData,
  );

  //Creates [AsyncState] and returns it.
  return AsyncState<T>(snapshot, () => attempts.value++, attempts.value);
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
class AsyncState<T> {
  const AsyncState(this.snapshot, this._retry, this.attempts);

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

  ///Returns if the data is empty.
  bool get isEmpty => ['', [], {}].contains(snapshot.data);

  ///The [AsyncSnapshot] data.
  T? get data => snapshot.data;

  ///Check if the [AsyncSnapshot] has error.
  bool get hasData => snapshot.hasData;

  ///Check if the [AsyncSnapshot] has error.
  bool get hasError => snapshot.hasError;

  ///Returns the [AsyncSnapshot] error.
  Object? get e => snapshot.error;

  ///Returns the [AsyncSnapshot]'s [StackTrace].
  StackTrace? get s => snapshot.stackTrace;
}
