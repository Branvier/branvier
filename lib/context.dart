part of 'export.dart';

extension ContextExt on BuildContext {
  ///Ensure the context widget is entirely visible. Defaults to scroll center.
  Future<void> ensureVisible({
    Duration duration = const Duration(milliseconds: 600),
    double aligment = 0.5,
  }) =>
      Scrollable.ensureVisible(this, alignment: 0.5, duration: duration);

  Future<T?> dialog<T>(WidgetBuilder builder, {bool dismissible = true}) {
    return showDialog<T>(
      context: this,
      barrierDismissible: dismissible,
      builder: builder,
    );
  }

  ///Current settings from the closest route.
  RouteSettings? get route => ModalRoute.of(this)?.settings;
}
