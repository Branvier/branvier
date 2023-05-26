part of '/branvier.dart';

extension WidgetToDeprecate on Widget {
  @Deprecated('Use .withOpacity() instead.')
  Widget hide([bool? value = true]) =>
      Opacity(opacity: value ?? false ? 0 : 1, child: this);
  @Deprecated('Use .withOpacity() instead.')
  Widget opacity([double value = 1.0]) => Opacity(opacity: value, child: this);
  @Deprecated('Use .withExpanded() instead.')
  Widget expand([int flex = 1]) => Expanded(flex: flex, child: this);
  @Deprecated('Use .withCenter() instead')
  Align toCenter() => Align(child: this);
  @Deprecated('Use .withAligment() instead')
  Align toTopLeft() => Align(alignment: _Align.topLeft, child: this);
  @Deprecated('Use .withAligment() instead')
  Align toTopCenter() => Align(alignment: _Align.topCenter, child: this);
  @Deprecated('Use .withAligment() instead')
  Align toTopRight() => Align(alignment: _Align.topRight, child: this);
  @Deprecated('Use .withAligment() instead')
  Align toCenterLeft() => Align(alignment: _Align.centerLeft, child: this);
  @Deprecated('Use .withAligment() instead')
  Align toCenterRight() => Align(alignment: _Align.centerRight, child: this);
  @Deprecated('Use .withAligment() instead')
  Align toBottomLeft() => Align(alignment: _Align.bottomLeft, child: this);
  @Deprecated('Use .withAligment() instead')
  Align toBottomCenter() => Align(alignment: _Align.bottomCenter, child: this);
  @Deprecated('Use .withAligment() instead')
  Align toBottomRight() => Align(alignment: _Align.bottomRight, child: this);
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

  /// Adds [Opacity] to this widget.
  Widget withOpacity(double opacity) {
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

  /// Sizes this widget.
  /// Where [height] and [width] overrides other values.
  Widget withSize({
    Size? size,
    double? height,
    double? width,
    double? dimension,
    double? radius,
  }) {
    return SizedBox(
      height: height ?? size?.height ?? dimension ?? radius?.multiply(2),
      width: width ?? size?.width ?? dimension ?? radius?.multiply(2),
      child: this,
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
  /// Returns null or [or] when [condition] is not met.
  T? withCondition<T extends Widget>(bool? condition, {T? or}) {
    return condition != null && condition == true ? (this as T) : or;
  }

  /// This child expanded in a [Row], [Column], or [Flex].
  Expanded withExpanded([int flex = 1]) => Expanded(flex: flex, child: this);

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
  /// You can use [x] or [y] to overried [scale] in that axis.
  Transform withScale(
    double scale, {
    double? x,
    double? y,
    Offset? origin,
    Alignment? aligment = Alignment.center,
    bool transformHitTests = true,
    FilterQuality? filterQuality,
  }) =>
      Transform.scale(
        scaleX: x ?? scale,
        scaleY: y ?? scale,
        origin: origin,
        alignment: aligment,
        transformHitTests: transformHitTests,
        filterQuality: filterQuality,
        child: this,
      );

  /// Moves this wiget with [Offset].
  Transform withOffset({
    Offset? offset,
    double dx = 0,
    double dy = 0,
    bool transformHitTests = true,
    FilterQuality? filterQuality,
  }) =>
      Transform.translate(
        offset: offset ?? Offset(dx, dy),
        transformHitTests: transformHitTests,
        filterQuality: filterQuality,
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
  Align withAlignment(
    // ignore: avoid_types_as_parameter_names
    Alignment, {
    double? widthFactor,
    double? heightFactor,
  }) {
    return Align(
      alignment: Alignment,
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      child: this,
    );
  }
}


// ignore: avoid_private_typedef_functions, camel_case_types
typedef _Align = Alignment;

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
