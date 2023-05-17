import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    Key? key,
    required this.child,
    this.center = true,
  }) : super(key: key);
  final Widget child;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final scaffold = MaterialApp(home: Scaffold(body: child));

    if (center) return Center(child: scaffold);
    return scaffold;
  }
}
