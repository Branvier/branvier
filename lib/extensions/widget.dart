part of '/branvier.dart';

extension WidgetX on Widget {
  // Widget scale(double scale) => Transform.scale(scale: scale, child: this);
  Widget onTap(VoidCallback? onTap) => InkWell(onTap: onTap, child: this);
  Widget expand([int flex = 1]) => Expanded(flex: flex, child: this);
  Widget visible([bool value = true]) =>
      Visibility(visible: value, child: this);
  Widget hide([bool? value = true]) =>
      Opacity(opacity: value ?? false ? 0 : 1, child: this);
  Widget opacity([double value = 1.0]) => Opacity(opacity: value, child: this);

  Widget shimmer(bool enable, {Color? baseColor, Color? highlightColor}) {
    if (enable) {
      return Shimmer.fromColors(
        baseColor: baseColor ?? Colors.grey.shade300,
        highlightColor: highlightColor ?? Colors.grey.shade100,
        enabled: enable,
        child: this,
      );
    } else {
      return this;
    }
  }

  ///Adds a [Padding] to this [Widget] following the priority order:
  ///EdgeInsets: Only > Symmetrical > All > Zero.
  Padding pad({
    double? all,
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? horizontal,
    double? vertical,
  }) =>
      Padding(
        padding: EdgeInsets.fromLTRB(
          left ?? horizontal ?? all ?? 0.0,
          top ?? vertical ?? all ?? 0.0,
          right ?? horizontal ?? all ?? 0.0,
          bottom ?? vertical ?? all ?? 0.0,
        ),
        child: this,
      );

  ///Fill and controls its position (must be under [Stack]).
  Positioned fill({
    double? all,
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? horizontal,
    double? vertical,
  }) =>
      Positioned.fill(
        left: left ?? horizontal ?? all ?? 0.0,
        top: top ?? vertical ?? all ?? 0.0,
        right: right ?? horizontal ?? all ?? 0.0,
        bottom: bottom ?? vertical ?? all ?? 0.0,
        child: this,
      );

  Align toCenter() => Align(child: this);
  Align toTopLeft() => Align(alignment: _To.topLeft, child: this);
  Align toTopCenter() => Align(alignment: _To.topCenter, child: this);
  Align toTopRight() => Align(alignment: _To.topRight, child: this);
  Align toCenterLeft() => Align(alignment: _To.centerLeft, child: this);
  Align toCenterRight() => Align(alignment: _To.centerRight, child: this);
  Align toBottomLeft() => Align(alignment: _To.bottomLeft, child: this);
  Align toBottomCenter() => Align(alignment: _To.bottomCenter, child: this);
  Align toBottomRight() => Align(alignment: _To.bottomRight, child: this);
}

// ignore: avoid_private_typedef_functions
typedef _To = Alignment;

extension ListWidgetX on Iterable<Widget> {
  ///Adds a [Padding] to all [Widget] in this list, following the priority order:
  ///EdgeInsets: Only > Symmetrical > All > Zero.
  List<Widget> padAll(
    double? all,
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? horizontal,
    double? vertical,
  ) {
    return map(
      (e) => e.pad(
        all: all,
        left: left,
        top: top,
        right: right,
        bottom: bottom,
        horizontal: horizontal,
        vertical: vertical,
      ),
    ).toList();
  }

  List<Widget> expandAll() => map((e) => e.expand()).toList();
}
