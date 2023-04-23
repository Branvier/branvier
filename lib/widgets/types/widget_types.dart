import 'package:flutter/material.dart';

import '../../branvier.dart';
import '../../state.dart';

///Checks if is Branvier Widget.
bool isBranvierWidget(Widget widget) {
  if (widget is ElevatedButtonX) return true;
  if (widget is OutlinedButtonX) return true;
  if (widget is TextButtonX) return true;
  if (widget is ListBuilder) return true;
  if (widget is AsyncBuilder) return true;
  if (widget is ObxBuilder) return true;
  if (widget is ObxListBuilder) return true;
  if (widget is Nil) return true;
  if (widget is NestBuilder) return true;
  if (widget is PageBuilder) return true;
  if (widget is FormX) return true;
  if (widget is AnimatedBuilderX) return true;

  return false;
}

///Check if is Flutter Widget. Ignores [StatelessWidget]/[StatefulWidget].
bool isFlutterWidget(widget) {
  if (widget is ProxyWidget) return true;
  if (widget is RenderObjectWidget) return true;
  if (widget is PreferredSizeWidget) return true;
  if (widget is UnconstrainedBox) return true;
  if (widget is PositionedDirectional) return true;
  if (widget is KeyedSubtree) return true;
  if (widget is AnimatedWidget) return true;
  if (widget is Builder) return true;
  if (widget is StatefulBuilder) return true;

  return false;
}
