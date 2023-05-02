part of '/branvier.dart';

extension ContextExt on BuildContext {
  /// The same of [MediaQuery.of(context).size]
  Size get mediaQuerySize => MediaQuery.of(this).size;

  /// The same of [MediaQuery.of(context).size.height]
  /// Note: updates when you rezise your screen (like on a browser or
  /// desktop window)
  double get height => mediaQuerySize.height;

  /// The same of [MediaQuery.of(context).size.width]
  /// Note: updates when you rezise your screen (like on a browser or
  /// desktop window)
  double get width => mediaQuerySize.width;

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

  ///The colors of the current theme.
  ColorScheme get colors => Theme.of(this).colorScheme;

  ///The font styles of the current theme.
  TextTheme get font => theme.textTheme;

  ///If the [ThemeMode] is dark.
  bool get isDarkMode => colors.brightness == Brightness.dark;

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
      if (widget.runtimeType.toString().startsWith('Cupertino')) return true;
      return false;
    }

    void visit(Element element) {
      if (element.widget is T) {
        onElement?.call(parent, element);
        onWidget?.call(parent.widget, element.widget as T);

        if (!rebuild) list.add(element.widget as T);

        if (rebuild && !ignoreType(element.widget)) {
          list.add(element.widget as T);
          element.markNeedsBuild();
        }
      }
      parent = element;
      element.visitChildren(visit);
    }

    parent.visitChildren(visit);

    dev.log('${list.length} $T widgets ${rebuild ? 'rebuilt' : 'found'}');
    dev.log('Types: ${list.toSet().map((e) => e.runtimeType)}');
    return list;
  }
}

extension ColorSchemeExtension on ColorScheme {
  ///Tells if the current theme in this is dark.
  bool get isDark => brightness == Brightness.dark;

  ///Flutter official guideline for disabled color.
  Color get disabled => onSurface.withOpacity(0.38);

  ///The default flutter textTheme. This will override your theme. Use as ref.
  TextTheme get defaultText =>
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;
}

extension SetMaterialStateExtension on Set<MaterialState> {
  bool get isHovered => contains(MaterialState.hovered);
  bool get isFocused => contains(MaterialState.focused);
  bool get isPressed => contains(MaterialState.pressed);
  bool get isDragged => contains(MaterialState.dragged);
  bool get isSelected => contains(MaterialState.selected);
  bool get isScrolledUnder => contains(MaterialState.scrolledUnder);
  bool get isDisabled => contains(MaterialState.disabled);
  bool get isError => contains(MaterialState.error);
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

  ///Set this [Color] as default and add optional states.
  ///
  ///Attention, this will be applied for all states!
  ///It's really recommended to set some invidiual states.
  MaterialStateProperty<Color?> resolve({
    Color? hovered,
    Color? focused,
    Color? pressed,
    Color? dragged,
    Color? selected,
    Color? scrolledUnder,
    Color? disabled,
    Color? error,
  }) {
    return MaterialStateColor.resolveWith((states) {
      if (states.isHovered && hovered != null) return hovered;
      if (states.isFocused && focused != null) return focused;
      if (states.isPressed && pressed != null) return pressed;
      if (states.isDragged && dragged != null) return dragged;
      if (states.isSelected && selected != null) return selected;
      if (states.isScrolledUnder && scrolledUnder != null) return scrolledUnder;
      if (states.isDisabled && disabled != null) return disabled;
      if (states.isError && error != null) return error;
      return this;
    });
  }

}

