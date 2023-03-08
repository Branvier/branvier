import 'package:flutter/material.dart';
import 'page_builder.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: _Example())));

enum _PaymentNest { details, options, paymentType, credit, pix, bill, debit }

class _Example extends StatelessWidget {
  const _Example({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NestBuilder<_PaymentNest>(
      ///Transform all enum values in pages.
      values: _PaymentNest.values,

      ///Optional wrapper that will always be visible.
      ///You can also just wrap the NestBuilder.
      nestWrapper: (nest, child) {
        return Scaffold(
          body: Center(child: child),
          appBar: AppBar(leading: BackButton(onPressed: nest.back)),
          floatingActionButton: FloatingActionButton(onPressed: nest.next),
        );
      },

      ///Optional wrapper for each page.
      ///You can also just wrap each page individually.
      pageWrapper: (nest, child) => Scaffold(body: Center(child: child)),

      ///The content of each page.
      builder: (nest) {
        switch (nest.type) {
          case _PaymentNest.details:
            return Text(nest.name);
          case _PaymentNest.options:
            return const _PaymentOptions();
          case _PaymentNest.paymentType:
            return Text(nest.name);
          case _PaymentNest.credit:
            return Text(nest.name);
          case _PaymentNest.pix:
            return Text(nest.name);
          case _PaymentNest.bill:
            return Text(nest.name);
          case _PaymentNest.debit:
            return Text(nest.name);
        }
      },
    );
  }
}

class _PaymentOptions extends StatelessWidget {
  const _PaymentOptions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //you can use the native button, as it calls .pop()
        const BackButton(),
        ElevatedButton(
          // Shortcut for your enum page.
          onPressed: () => context.toNested(_PaymentNest.bill),
          // onPressed: () => Navigator.pushNamed(context,PaymentNest.pix.name),
          onLongPress: () => context.nest.back(),
          //or below.
          // onLongPress: () => context.backNested(),
          //or even:
          // onLongPress: () => Navigator.pop(context),
          child: const Text('options -> pix'),
        ),
      ],
    );
  }
}

///Simple nested navigation with enums. [_Example] above.
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
  void next() {
    if (!isNextAvailable) return;
    state.pushNamed(values[index + 1].name);
  }

  ///Goes back to previous page index.
  void back() {
    if (!isBackAvailable) return;
    state.pop();
  }

  ///Goes to specific page index.
  void to(Enum type) {
    if (!isAttached) return;
    state.pushNamed(type.name);
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

///Simple nested navigation with enums. [_Example] above .
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
    Key? key,
  }) : super(key: key);

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

extension NextCtxExt on BuildContext {
  NestController get nest =>
      dependOnInheritedWidgetOfExactType<NestScope>()!.nest;
  void toNested(Enum type) => nest.to(type);
  void nextNested() => nest.next();
  void backNested() => nest.back();
}

extension NextNavExt on NavigatorState {
  NestController get nest => context.nest;
  void toNested(Enum type) => nest.to(type);
  void nextNested() => nest.next();
  void backNested() => nest.back();
}
