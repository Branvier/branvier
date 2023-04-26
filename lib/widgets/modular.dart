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
    super.key,
  });

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
