part of '../branvier.dart';

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
  late final String initialPath;

  /// Listens only while [initialPath] is part of the navigation stack.
  /// This is intended to avoid unnecessary rebuilds and dispose problems.
  void listener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Modular.to.path.contains(initialPath) && mounted) setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    initialPath = Modular.to.path;
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
  BuildContext? get _context {
    try {
      return Navigator.of(routerOutletContext!).context;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      _context ?? context,
      widget.child,
    );
  }
}
