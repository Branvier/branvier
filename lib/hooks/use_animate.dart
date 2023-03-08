import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

///On true animates to [end], false animates back to [begin].
AnimationController useAnimateOn(
  bool condition, {
  double begin = 0.0,
  double end = 1.0,
  Curve curve = Curves.fastOutSlowIn,
  Duration duration = const Duration(milliseconds: 300),
}) =>
    useAnimateTo(condition ? end : begin, curve: curve, duration: duration);

///Animates from its current value to target.
AnimationController useAnimateTo(
  double target, {
  double begin = 0.0,
  double end = 1.0,
  Curve curve = Curves.fastOutSlowIn,
  Duration duration = const Duration(milliseconds: 300),
}) {
  final ac = useAnimationController(lowerBound: begin, upperBound: end);
  return ac..animateTo(target, duration: duration, curve: curve);
}

bool useChanged<T>(T value, {void Function(T? old)? onChange}) {
  var changed = false;
  useValueChanged<T, void>(value, (oldValue, oldResult) {
    changed = true;
    // resizing.on();
    onChange?.call(oldValue);

    // return stateSize.value = baseSize;
  });
  return changed;
}

/// This "function" class is the implementation of `debouncer()` Worker.
/// It calls the function passed after specified [delay] parameter.
/// Example:
/// ```
/// final delayed = Debouncer( delay: Duration( seconds: 1 )) ;
/// print( 'the next function will be called after 1 sec' );
/// delayed( () => print( 'called after 1 sec' ));
/// ```
class Debouncer {
  Debouncer([this.duration = const Duration(milliseconds: 500), this._action]);
  final Duration duration;
  VoidCallback? _action;
  Timer? _timer;

  ///Debounces. Reseting the timer.
  void call([VoidCallback? action]) {
    _debounce(duration, action ?? () => _action?.call());
  }

  ///Delays the timer.
  void delay([Duration? duration]) {
    _debounce(duration ?? this.duration, () => _action?.call());
  }

  void _debounce(Duration duration, VoidCallback action) {
    cancel();
    _timer = Timer(duration, action);
  }

  void _sync(VoidCallback? action) {
    if (action != null) call(_action = action);
  }

  /// Notifies if the delayed call is active.
  bool get isRunning => _timer?.isActive ?? false;

  /// Cancel the current delayed call.
  void cancel() => _timer?.cancel();
}

///Calls after timer's [duration]. If called before, resets the timer.
///
///If [action] is not null, timer will reset on every rebuild.
Debouncer useDebounce(Duration duration, [void Function()? action]) {
  final debounce = useRef(Debouncer(duration));
  return debounce.value.._sync(action);
}
