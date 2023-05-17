part of '/branvier.dart';

extension WidgetToDeprecate on Widget {
  @Deprecated('Use .withOpacity() instead.')
  Widget hide([bool? value = true]) =>
      Opacity(opacity: value ?? false ? 0 : 1, child: this);
  @Deprecated('Use .withOpacity() instead.')
  Widget opacity([double value = 1.0]) => Opacity(opacity: value, child: this);
  @Deprecated('Use .expanded() instead.')
  Widget expand([int flex = 1]) => Expanded(flex: flex, child: this);
  @Deprecated('Use .centered() instead')
  Align toCenter() => Align(child: this);
  @Deprecated('Use .withAligment.topLeft() instead')
  Align toTopLeft() => Align(alignment: _To.topLeft, child: this);
  @Deprecated('Use .withAligment.topCenter() instead')
  Align toTopCenter() => Align(alignment: _To.topCenter, child: this);
  @Deprecated('Use .withAligment.topRight() instead')
  Align toTopRight() => Align(alignment: _To.topRight, child: this);
  @Deprecated('Use .withAligment.centerLeft() instead')
  Align toCenterLeft() => Align(alignment: _To.centerLeft, child: this);
  @Deprecated('Use .withAligment.centerRight() instead')
  Align toCenterRight() => Align(alignment: _To.centerRight, child: this);
  @Deprecated('Use .withAligment.bottomLeft() instead')
  Align toBottomLeft() => Align(alignment: _To.bottomLeft, child: this);
  @Deprecated('Use .withAligment.bottomCenter() instead')
  Align toBottomCenter() => Align(alignment: _To.bottomCenter, child: this);
  @Deprecated('Use .withAligment.bottomRight() instead')
  Align toBottomRight() => Align(alignment: _To.bottomRight, child: this);
  @Deprecated('Use .withPadding() instead')
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
  @Deprecated('Use .withFill() instead')
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
}

extension WidgetFeatures on Widget {
  /// Makes this widget tappable.
  Widget onTap(
    VoidCallback? onTap, {
    double radius = 0,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        radius: radius,
        borderRadius: BorderRadius.circular(radius),
        child: this,
      ),
    );
  }

  /// Control whether this widget is visible.
  @Deprecated('Use withVisibility instead.')
  Widget visible([bool value = true]) =>
      Visibility(visible: value, child: this);
}

extension WidgetEffects on Widget {
  /// Adds a [Shimmer] effect on this widget.
  Widget withShimmer(bool enable, {Color? baseColor, Color? highlightColor}) {
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

  /// Control whether this widget is visible.
  Widget withVisibility([bool visible = true]) {
    return Visibility(visible: visible, child: this);
  }

  /// Adds [Opacity] to this widget.
  Widget withOpacity([double opacity = 1.0]) {
    return Opacity(opacity: opacity, child: this);
  }

  /// Pads this widget in order: Only > Symmetrical > All > Zero.
  Padding withPadding({
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

  /// Margins this widget in order: Only > Symmetrical > All > Zero.
  Widget withMargin({
    double? all,
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? horizontal,
    double? vertical,
  }) =>
      Container(
        margin: EdgeInsets.fromLTRB(
          left ?? horizontal ?? all ?? 0.0,
          top ?? vertical ?? all ?? 0.0,
          right ?? horizontal ?? all ?? 0.0,
          bottom ?? vertical ?? all ?? 0.0,
        ),
        child: this,
      );

  /// Adds [Decoration] to this widget.
  Widget withDecoration(Decoration decoration) {
    return DecoratedBox(decoration: decoration, child: this);
  }

  /// Sizes this widget.
  /// Where [height] and [width] overrides [size] respective values.
  Widget withSize({
    Size? size,
    double? height,
    double? width,
  }) {
    return SizedBox(
      height: height ?? size?.height,
      width: width ?? size?.width,
    );
  }

  /// Adds [Constraints] to this widget.
  Widget withConstraints({
    double minWidth = 0.0,
    double maxWidth = double.infinity,
    double minHeight = 0.0,
    double maxHeight = double.infinity,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minWidth,
        maxWidth: maxWidth,
        minHeight: minHeight,
        maxHeight: maxHeight,
      ),
      child: this,
    );
  }
}

extension WidgetPositioning on Widget {
  /// This child expanded in a [Row], [Column], or [Flex].
  Widget withExpanded([int flex = 1]) => Expanded(flex: flex, child: this);

  /// This child centered with [Center].
  Center withCenter({
    double? widthFactor,
    double? heightFactor,
  }) =>
      Center(
        widthFactor: widthFactor,
        heightFactor: heightFactor,
        child: this,
      );

  /// Scales this widget by [scale].
  ///
  /// You can either use this caller, or withScale.only() for custom axis.
  Transform withScale(
    double scale, {
    Offset? origin,
    Alignment? aligment = Alignment.center,
  }) =>
      Transform.scale(
        scale: scale,
        origin: origin,
        alignment: aligment,
        child: this,
      );

  /// Rotates this widget clockwise by [angle], in radians.
  Widget withAngle(
    double angle, {
    Offset? origin,
    Alignment? aligment = Alignment.center,
  }) =>
      Transform.rotate(
        angle: angle,
        origin: origin,
        alignment: aligment,
        child: this,
      );

  /// This widget flipped in [x]/[y] (horizontally/vertically).
  ///
  /// You can either use this called or:
  /// - withFlip.x()
  /// - withFlip.y()
  Widget withFlip({
    bool x = false,
    bool y = false,
    Offset? origin,
  }) {
    return Transform.flip(flipX: x, flipY: y, origin: origin, child: this);
  }

  /// Moves this wiget with [Offset].
  Widget withOffset({Offset? offset, double dx = 0, double dy = 0}) =>
      Transform.translate(
        offset: offset ?? Offset(dx, dy),
        child: this,
      );

  /// Fills and controls this widget position under a [Stack].
  Positioned withFill({
    double? all,
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? horizontal,
    double? vertical,
  }) =>
      Positioned.fill(
        left: left ?? horizontal ?? all,
        top: top ?? vertical ?? all,
        right: right ?? horizontal ?? all,
        bottom: bottom ?? vertical ?? all,
        child: this,
      );

  /// Aligns this widget.
  ///
  /// You can either use this caller or shortcuts:
  /// - withAlignment.center(),
  /// - withAlignment.topLeft(),
  /// - withAlignment.topCenter(),
  /// - withAlignment.topRight(),
  /// - withAlignment.centerLeft(),
  /// - withAlignment.centerRight(),
  /// - withAlignment.bottomLeft(),
  /// - withAlignment.bottomCenter(),
  /// - withAlignment.bottomRight();
  Align withAlignment(
    alignment, {
    double? widthFactor,
    double? heightFactor,
  }) {
    return Align(
      alignment: alignment,
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      child: this,
    );
  }
}

// ignore: avoid_private_typedef_functions, camel_case_types
typedef _To = Alignment;

extension AlignmentFunction on Align Function(
  Alignment alignment, {
  double? heightFactor,
  double? widthFactor,
}) {
  Widget? get _child => this(Alignment.center).child;

  @Deprecated('Use .centered() instead')
  Align center() => Align(child: _child);
  Align topLeft() => Align(alignment: _To.topLeft, child: _child);
  Align topCenter() => Align(alignment: _To.topCenter, child: _child);
  Align topRight() => Align(alignment: _To.topRight, child: _child);
  Align centerLeft() => Align(alignment: _To.centerLeft, child: _child);
  Align centerRight() => Align(alignment: _To.centerRight, child: _child);
  Align bottomLeft() => Align(alignment: _To.bottomLeft, child: _child);
  Align bottomCenter() => Align(alignment: _To.bottomCenter, child: _child);
  Align bottomRight() => Align(alignment: _To.bottomRight, child: _child);
}

extension WidgetListX on Iterable<Widget> {
  @Deprecated('Use .withPaddingAll')
  List<Widget> padAll({
    double? all,
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? horizontal,
    double? vertical,
  }) {
    return map(
      (e) => e.withPadding(
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

  ///Adds [Padding] to all widgets. Order: Only > Symmetrical > All > Zero.
  List<Widget> withPaddingAll({
    double? all,
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? horizontal,
    double? vertical,
  }) {
    return map(
      (e) => e.withPadding(
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

  /// Expands all the widgets inside this list.
  List<Widget> withExpandedAll() => map((e) => e.withExpanded()).toList();

  @Deprecated('Use withExpandedAll() instead')
  List<Widget> expandAll() => map((e) => e.withExpanded()).toList();
}

extension TransformFunction on Transform Function(
  double, {
  Alignment? aligment,
  Offset? origin,
}) {
  Widget? get _child => this(0).child;

  /// Scales this widget [x]/[y] axis.
  Transform only({
    double? x,
    double? y,
    Offset? origin,
    Alignment? aligment = Alignment.center,
  }) =>
      Transform.scale(
        scaleX: x,
        scaleY: y,
        origin: origin,
        alignment: aligment,
        child: _child,
      );
}

extension IterableWidgetX<T extends Object> on Iterable<T> {
  ///Maps to List of [Widget].
  List<Widget> builder(Widget toWidget(T item, int i)) {
    var index = 0;
    return map((e) => toWidget(e, index++)).toList();
  }

  ///Builds this list into a [Widget].
  ///You can configure this list with [ListConfig].
  Widget build(
    Widget toWidget(T item, int i), {
    ListConfig config = const ListConfig(),
  }) {
    return ListBuilder(
      config: config,
      list: toList(),
      builder: toWidget,
    );
  }
}
