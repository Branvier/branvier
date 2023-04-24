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
  if (widget is AnimatedLoader) return true;

  return false;
}

///Check if is Flutter Widget. Ignores [StatelessWidget]/[StatefulWidget].
bool isFlutterWidget(widget) {
  if (widget is Actions) return true;
  if (widget is AnimatedSize) return true;
  if (widget is AnimatedWidget) return true;
  if (widget is AutomaticKeepAlive) return true;
  if (widget is Banner) return true;
  if (widget is Builder) return true;
  if (widget is ButtonStyleButton) return true;
  if (widget is Checkbox) return true;
  if (widget is CheckedModeBanner) return true;
  if (widget is DefaultTextEditingShortcuts) return true;
  if (widget is Dismissible) return true;
  if (widget is Divider) return true;
  if (widget is Draggable) return true;
  if (widget is Drawer) return true;
  if (widget is DropdownButton) return true;
  if (widget is ExpandIcon) return true;
  if (widget is ExpansionPanelList) return true;
  if (widget is FloatingActionButton) return true;
  if (widget is Focus) return true;
  if (widget is FocusTraversalGroup) return true;
  if (widget is Form) return true;
  if (widget is FormField) return true;
  if (widget is GestureDetector) return true;
  if (widget is Hero) return true;
  if (widget is ImplicitlyAnimatedWidget) return true;
  if (widget is InkResponse) return true;
  if (widget is KeyedSubtree) return true;
  if (widget is ListTile) return true;
  if (widget is Localizations) return true;
  if (widget is Material) return true;
  if (widget is ModalBarrier) return true;
  if (widget is NavigationToolbar) return true;
  if (widget is Navigator) return true;
  if (widget is NestedScrollView) return true;
  if (widget is Overlay) return true;
  if (widget is PageStorage) return true;
  if (widget is PageView) return true;
  if (widget is PopupMenuButton) return true;
  if (widget is PositionedDirectional) return true;
  if (widget is PreferredSizeWidget) return true;
  if (widget is ProgressIndicator) return true;
  if (widget is ProxyWidget) return true;
  if (widget is Radio) return true;
  if (widget is RawGestureDetector) return true;
  if (widget is RefreshIndicator) return true;
  if (widget is RenderObjectWidget) return true;
  if (widget is ReorderableListView) return true;
  if (widget is RestorationScope) return true;
  if (widget is RootRestorationScope) return true;
  if (widget is Router) return true;
  if (widget is SafeArea) return true;
  if (widget is Scaffold) return true;
  if (widget is ScaffoldMessenger) return true;
  if (widget is ScrollNotificationObserver) return true;
  if (widget is Scrollbar) return true;
  if (widget is SharedAppData) return true;
  if (widget is ShortcutRegistrar) return true;
  if (widget is Shortcuts) return true;
  if (widget is SimpleDialog) return true;
  if (widget is SingleChildScrollView) return true;
  if (widget is Slider) return true;
  if (widget is SnackBar) return true;
  if (widget is StatefulBuilder) return true;
  if (widget is Stepper) return true;
  if (widget is Switch) return true;
  if (widget is TabBarView) return true;
  if (widget is Text) return true;
  if (widget is TextField) return true;
  if (widget is Theme) return true;
  if (widget is TickerMode) return true;
  if (widget is Title) return true;
  if (widget is Tooltip) return true;
  if (widget is UnconstrainedBox) return true;
  if (widget is VerticalDivider) return true;
  if (widget is WillPopScope) return true;

  return false;
}
