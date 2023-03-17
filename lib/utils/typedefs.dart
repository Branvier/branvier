part of '/branvier.dart';

///Typedef pattern
///ReturnType + [Action]<Type,Return>
///
///Dart style recommends <T> in general and <R> for returns, so:
///[Action] Get: Adds <...,R> type inference. Always last.
///[Action] On: Adds <T,...> type inference. Always first.
/// ex:
///   - Future<String> Function() -> FutureGet<String>
///   - void Function(List<int>) -> OnList<int> or On<List<int>>
///   - String Function(bool) -> GetOn<bool,String>
///
/// By following this, you know:
/// A Function that starts with [On] is *always* be void.
/// [On] will always be close to the infered parameter. Return+On<T,...>
/// ex: GetOn<T,R>.

//Mapper functions.
typedef Getter<R> = R Function();
typedef Then<T, R> = FutureOr<R> Function(T value);
typedef Echo<T> = T Function(T e);
typedef EchoOn<T> = T? Function(T e);
typedef EchoGet<T> = T Function(T? e);

//Async functions.
//Future.
typedef FutureGet<R> = Future<R> Function();
typedef FutureOn<T> = Future<void> Function(T data);
typedef FutureGetOn<T, R> = Future<R> Function(T data);

//Stream.
typedef StreamGet<R> = Stream<R> Function();
typedef StreamOn<T> = Stream<void> Function(T data);
typedef StreamGetOn<T, R> = Stream<R> Function(T data);

//Callback functions.
typedef On<T> = void Function(T data);
typedef GetOn<T, R> = R Function(T e);

//Widget
typedef WidgetWrapper = Widget Function(Widget child);
typedef WidgetOn<T> = Widget Function(T data);

//prefix
typedef OnWidget = void Function(Widget child);
typedef OnList<T> = void Function(List<T> list);
typedef OnMap<K, V> = void Function(Map<K, V> map);
typedef OnJson<V> = void Function(Json<V> map);
typedef OnForm<V> = void Function(Json<V> form);

//bases
typedef OnChange = void Function(String value);
typedef OnIndex = void Function(int i);
typedef OnCondition = void Function(bool bool);
typedef OnEach<T> = void Function(int index, List<T> list);
