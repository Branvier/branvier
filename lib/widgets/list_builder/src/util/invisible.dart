import 'package:flutter/material.dart';

class Invisible extends StatelessWidget {
  const Invisible({
    super.key,
    this.child,
    this.invisible = false,
  });
  final bool invisible;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: !invisible,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: child!,
    );
  }
}
