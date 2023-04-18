part of '/branvier.dart';

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

extension MaterialColorGenerator on Color {
  /// Generates and returns a MaterialColor from a single Color.
  MaterialColor toMaterialColor() {
    return _createMaterialColor(this);
  }

  MaterialColor _createMaterialColor(Color color) {
    final strengths = <double>[.05];
    final swatch = <int, Color>{};
    final r = color.red, g = color.green, b = color.blue;

    for (var i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}
