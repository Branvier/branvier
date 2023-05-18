part of '../branvier.dart';

/// Just a [FutureBuilder] wrapper for [Modular].isModuleReady().
class ModuleBuilder<M extends Module> extends StatelessWidget {
  /// Shows [loader] while [M] is not ready.
  ///
  /// Type [M] with your [Module] and it will wait for isModuleReady().
  const ModuleBuilder({
    this.loader = const Center(child: CircularProgressIndicator()),
    this.onLoad,
    this.builder,
    Key? key,
  }) : super(key: key);

  ///Called when isModuleReady() is done.
  final void Function()? onLoad;

  ///The widget to build when done.
  final WidgetBuilder? builder;

  ///The widget to show while not done.
  final Widget loader;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Modular.isModuleReady<M>(),
      builder: (context, snapshot) {
        // Returns [loader] while loading.
        if (snapshot.connectionState != ConnectionState.done) return loader;

        // Calls [onLoad] when it's done.
        WidgetsBinding.instance.addPostFrameCallback((_) => onLoad?.call());

        // The widget to build.
        return builder?.call(context) ?? loader;
      },
    );
  }
}

///Use [ReassembleMixin] when you need to recover navigation stack upon hot reload.
///
///Ex: Useful for [RouterOutlet] that can't auto cache routes on reload.
class ReassemblePath with ReassembleMixin {
  late String path;
  late Completer completer;
  var count = 0;

  //Called every time the route changes. Stops when complete is called.
  void _reassemblePath() {
    //All paths in a list.
    final paths = path.split('/').where((e) => e.isNotEmpty).toList();
    final isLast = count == paths.length - 1;
    final slash = !isLast || path.endsWith('/') ? '/' : '';

    //Add to stack.

    Modular.to.pushNamed(Modular.to.path + paths[count++] + slash);

    //Completes after reading all.
    if (isLast) completer.complete();
  }

  @override
  void reassemble() async {
    count = 0;
    path = Modular.to.path; //current path
    completer = Completer(); //future starts

    Modular.to.addListener(_reassemblePath);
    await completer.future;
    Modular.to.removeListener(_reassemblePath);
  }
}

///Custom Transitions for Modular.
mixin TransitionCustom {
  static final topLevel = CustomTransition(
    transitionBuilder: (context, anim1, anim2, child) {
      return const ZoomPageTransitionsBuilder()
          .buildTransitions(null, context, anim1, anim2, child);
    },
  );
  static final openUpwards = CustomTransition(
    transitionBuilder: (context, anim1, anim2, child) {
      return const OpenUpwardsPageTransitionsBuilder()
          .buildTransitions(null, context, anim1, anim2, child);
    },
  );
  static final fadeUpwards = CustomTransition(
    transitionBuilder: (context, anim1, anim2, child) {
      return const FadeUpwardsPageTransitionsBuilder()
          .buildTransitions(null, context, anim1, anim2, child);
    },
  );
  static CustomTransition cupertino(PageRoute route) => CustomTransition(
        transitionBuilder: (context, anim1, anim2, child) {
          return const CupertinoPageTransitionsBuilder()
              .buildTransitions(route, context, anim1, anim2, child);
        },
      );
}

class NavigationListenerX extends StatefulWidget {
  /// Same as [NavigationListener] but gives the [BuildContext] of any [Navigator] below it.
  /// Additionally waits for navigation frame complete when listening.
  const NavigationListenerX({
    Key? key,
    required this.builder,
    this.child,
  }) : super(key: key);
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  @override
  NavigationListenerXState createState() => NavigationListenerXState();
}

class NavigationListenerXState extends State<NavigationListenerX> {
  void listener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    Modular.to.addListener(listener);

    // Waiting for the [BuildContext] to build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getRouterOutletContext();
    });
  }

  @override
  void dispose() {
    super.dispose();
    Modular.to.removeListener(listener);
  }

  /// Looks for the furthest [Navigator] down in the tree.
  void _getRouterOutletContext() {
    void visit(Element element) {
      if (element.widget is Navigator) routerOutletContext = element;
      element.visitChildren(visit);
    }

    (context as Element).visitChildren(visit);
  }

  BuildContext? routerOutletContext;

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      routerOutletContext ?? context,
      widget.child,
    );
  }
}
