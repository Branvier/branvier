import 'dart:developer';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

///Returns the [LifecycleState] of the application.
LifecycleState useLifecycle({
  ///Called when this object is inserted into the tree. Like initState.
  VoidCallback? onInit,

  ///Called when this object is builded for the 1st time. 1 frame after onInit.
  VoidCallback? onBuild,

  ///Called when this object is rebuilded. When updated or state set.
  VoidCallback? onRebuild,

  ///Called when this object is removed from the tree permanently. Like dispose.
  VoidCallback? onDispose,

  ///Called when the application is not currently visible to the user.
  VoidCallback? onPaused,

  ///Called when the application is visible and responding to user input.
  VoidCallback? onResumed,

  ///Called when detached from any host views. Ex: Transitioning between views.
  VoidCallback? onDetached,

  ///Called when the application view is inactive and not receiving user input.
  //Ex: When device's overlays like control center or app switcher are open.
  VoidCallback? onInactive,

  ///Called when the [AppLifecycleState] is changed.
  ///Ex: onChange: (prev, curr) => print('Changed from $prev to $curr').
  void Function(LifecycleState? previous, LifecycleState current)? onChange,

  ///If not null logs all the lifecycles. This String identifies the widget.
  String? logger,
}) {
  final builds = useRef(0).value++;
  final rebuild = useState(0);
  final mounted = useIsMounted();
  final state = useAppLifecycleState();

  void logIf(String msg) {
    final mount = mounted() ? 'mounted' : 'unmounted';
    if (logger != null) debugPrint('$logger $msg ($mount|${state?.name})');
  }

  // ignore: no_leading_underscores_for_local_identifiers
  void _rebuild(VoidCallback? fn) {
    fn?.call();
    logIf('state set [${++rebuild.value}]');
  }

  useInit(
    () {
      logIf('inited');
      onInit?.call();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        logIf('builded ($builds)');
        onBuild?.call();
      });
    },
    dispose: () {
      logIf('disposed');
      onDispose?.call();
    },
  );

  useUpdateEffect(() {
    logIf('rebuilded ($builds)');
    onRebuild?.call();
    return null;
  });

  useOnAppLifecycleStateChange(
    (previous, current) {
      logIf('changed ${previous?.name} -> ${current.name}');

      onChange?.call(
        LifecycleState(previous, mounted, _rebuild),
        LifecycleState(current, mounted, _rebuild),
      );

      if (current == AppLifecycleState.paused) onPaused?.call();
      if (current == AppLifecycleState.resumed) onResumed?.call();
      if (current == AppLifecycleState.detached) onDetached?.call();
      if (current == AppLifecycleState.inactive) onInactive?.call();
    },
  );

  return LifecycleState(state, mounted, _rebuild);
}

class LifecycleState {
  LifecycleState(this._state, this._mounted, this._rebuild);
  final AppLifecycleState? _state;
  final bool Function() _mounted;
  final void Function(VoidCallback? fn) _rebuild;

  ///Sets the state, marking the widget to rebuild.
  void set([VoidCallback? fn]) => _rebuild(fn);

  bool get isMounted => _mounted();
  bool get isPaused => _state == AppLifecycleState.paused;
  bool get isResumed => _state == AppLifecycleState.resumed;
  bool get isDetached => _state == AppLifecycleState.detached;
  bool get isInactive => _state == AppLifecycleState.inactive;
}

/// Flutter lifecycle hook that console logs parameters as component
/// transitions through lifecycles.
void useLogger(String componentName, {Map<String, dynamic> props = const {}}) {
  useInit(
    () => log('$componentName mounted $props'),
    dispose: () => log('$componentName unmounted'),
  );

  useUpdateEffect(() {
    log('$componentName updated $props');
    return null;
  });
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

/// Flutter effect hook that ignores the first invocation (e.g. on mount).
/// The signature is exactly the same as the useEffect hook.
void useUpdateEffect(VoidCallback? Function() effect, [List<Object?>? keys]) {
  final isFirstMount = useFirstMountState();

  useEffect(
    () {
      if (!isFirstMount) {
        return effect();
      }
      return null;
    },
    keys,
  );
}

/// Returns true if component is just mounted (on first build) and
/// false otherwise.
bool useFirstMountState() {
  final isFirst = useRef(true);

  if (isFirst.value) {
    isFirst.value = false;

    return true;
  }

  return isFirst.value;
}
