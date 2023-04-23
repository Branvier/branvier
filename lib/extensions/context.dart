part of '/branvier.dart';

extension ContextExt on BuildContext {
  ///Ensure the context widget is entirely visible. Defaults to scroll center.
  Future<void> ensureVisible({
    Duration duration = const Duration(milliseconds: 600),
    double aligment = 0.5,
  }) =>
      Scrollable.ensureVisible(this, alignment: 0.5, duration: duration);

  void dialog<T>({
    required WidgetBuilder builder,
    bool dismissible = true,
    void onDismiss(T? result)?,
  }) {
    postFrame(() async {
      final result = showDialog<T>(
        context: this,
        barrierDismissible: dismissible,
        builder: builder,
      );
      await result.then((re) => onDismiss?.call(re));
    });
  }

  ///Current settings from the closest route.
  RouteSettings? get route => ModalRoute.of(this)?.settings;

  ///Current theme of the app.
  ThemeData get theme => Theme.of(this);
  
  ///Visits all [T] widgets below this context. If [T] is absent, visits all.
  ///
  ///Additionally returns a list of the Widgets found.
  ///
  ///You can rebuild the widgets found. Native and private classes are ignored,
  ///making this very lightweight and fast.
  List<T> visitAll<T extends Widget>({
    bool rebuild = false,
    void onWidget(Widget parent, T widget)?,
    void onElement(Element parent, Element element)?,
  }) {
    final list = <T>[];
    var parent = this as Element;

    bool ignoreType(Widget widget) {
      if (isFlutterWidget(widget)) return true;
      if (isBranvierWidget(widget)) return true;
      if (widget.runtimeType.toString().startsWith('_')) return true;
      return false;
    }

    void visit(Element element) {
      if (element.widget is T) {
        onElement?.call(parent, element);
        onWidget?.call(parent.widget, element.widget as T);
        list.add(element.widget as T);

        if (rebuild && !ignoreType(element.widget)) {
          element.markNeedsBuild();
        }
      }
      parent = element;
      element.visitChildren(visit);
    }

    parent.visitChildren(visit);

    dev.log('${list.length} $T widgets found');
    dev.log('Types: ${list.toSet().map((e) => e.runtimeType)}');
    return list;
  }
}

extension MaterialColorGenerator on Color {
  ///Add shades to this [Color].
  ///
  /// From Lighest to Darkest. Where [500] is the same color.
  /// - [50],[100],[200],[300],[400],[500],[600],[700],[800],[900].
  ///
  /// Any other value will return the closest shade value.
  Color operator [](int shade) {
    final shades = [50, 100, 200, 300, 400, 500, 600, 700, 800, 900];

    if (shades.contains(shade)) return swatch[shade]!;
    if (shade < 25) return Colors.white;
    if (shade < 75) return swatch[50]!;
    if (shade >= 950) return Colors.black;
    if (shade >= 850) return swatch[900]!;

    ///Round to closest shade.
    return swatch[(shade / 100).round() * 100]!;
  }

  /// Generates [MaterialColor] swatch from a single Color.
  MaterialColor get swatch {
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
