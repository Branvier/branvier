part of '/branvier.dart';

/// Simple nested navigation with enums.
/// Just give your [Enum].values to the [NestBuilder].
///
/// Navigate using:
/// - context.toNested(Payment.credit).
/// - context.back().
/// - context.next().
///
/// Example in nest_builder_test.dart.
class NestBuilder<T extends Enum> extends StatelessWidget {
  const NestBuilder({
    required this.values,
    required this.builder,
    this.nestWrapper,
    this.pageWrapper,
    this.controller,
    this.transition = PageTransition.theme,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.fastOutSlowIn,
    super.key,
  });

  ///Each [Enum] as a page.
  final List<T> values;
  final Widget Function(NestController<T> nest) builder;

  ///Wrapper for the nest.
  final Widget Function(NestController<T> nest, Widget child)? nestWrapper;

  ///Wrapper for each page.
  final Widget Function(NestController<T> nest, Widget child)? pageWrapper;

  ///Controls the nested navigation.
  final NestController<T>? controller;

  ///The transition of the routes.
  final PageTransition transition;

  ///The transition animation duration.
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<NavigatorState>();
    final nest = (this.controller ?? NestController<T>()).._attach(key, values);

    final nav = Navigator(
      key: key,
      initialRoute: values.first.name,
      observers: [
        PageObserver(
          onPop: (_, prev) => nest._sync(prev?.settings),
        ),
      ],
      onGenerateRoute: (route) {
        nest._sync(route);

        return PageBuilder(
          type: transition,
          duration: duration,
          reverseDuration: duration,
          child: pageWrapper?.call(nest, builder(nest)) ?? builder(nest),
          settings: route,
          curve: curve,
        );
      },
    );

    return NestScope(nest, child: nestWrapper?.call(nest, nav) ?? nav);
  }
}

///You can programatically control the nest anywhere.
///
/// class Logic {
///
/// final nest = NestController(); // Instantiate anywhere.
///
/// void goNext() => nest.next(); //Control the nest.
///
/// ... }
///
/// class View {
///
/// NestBuilder(
///
///   controller: logic.nest, // attach it on the Nest.
///
/// ... ) }
class NestController<T extends Enum> {
  late final GlobalKey<NavigatorState> key;
  late final List<T> values;
  RouteSettings? route;
  var _attached = false;

  BuildContext get context => key.currentContext!;
  NavigatorState get state => key.currentState!;

  bool get isAttached => _attached;
  bool get hasName => _attached && route?.name != null;
  bool get isNextAvailable => hasName && index < (values.length - 1);
  bool get isBackAvailable => hasName && index > 0;

  T get type => values.singleWhere((e) => e.name == route?.name);
  String get name => type.name;
  int get index => type.index;

  ///Goes to the next page index. Useful for linear nested pages.
  void next() async {
    if (!isNextAvailable) return;
    await state.pushNamed(values[index + 1].name);
  }

  ///Goes back to previous page index.
  void back() {
    if (!isBackAvailable) return;
    state.pop();
  }

  ///Goes to specific page index.
  void to(Enum type) async {
    if (!isAttached) return;
    await state.pushNamed(type.name);
  }

  void _attach(GlobalKey<NavigatorState> key, List<T> values) {
    if (isAttached) return;
    _attached = true;
    this.key = key;
    this.values = values;
  }

  void _sync(RouteSettings? route) {
    if (!isAttached) return;
    this.route = route;
  }
}
class NestScope extends InheritedWidget {
  const NestScope(
    this.nest, {
    required super.child,
    super.key,
  });
  final NestController nest;

  @override
  bool updateShouldNotify(oldWidget) => false;
}

extension NestCtxExt on BuildContext {
  NestController get nest =>
      dependOnInheritedWidgetOfExactType<NestScope>()!.nest;
  void toNested(Enum type) => nest.to(type);
  void nextNested() => nest.next();
  void backNested() => nest.back();
}

extension NestNavExt on NavigatorState {
  NestController get nest => context.nest;
  void toNested(Enum type) => nest.to(type);
  void nextNested() => nest.next();
  void backNested() => nest.back();
}
