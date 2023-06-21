part of 'rx_button.dart';

class RxButtonStyle extends ButtonStyle {
  const RxButtonStyle({
    this.config,
    super.textStyle,
    super.backgroundColor,
    super.foregroundColor,
    super.overlayColor,
    super.shadowColor,
    super.surfaceTintColor,
    super.elevation,
    super.padding,
    super.minimumSize,
    super.fixedSize,
    super.maximumSize,
    super.iconColor,
    super.iconSize,
    super.side,
    super.shape,
    super.mouseCursor,
    super.visualDensity,
    super.tapTargetSize,
    super.animationDuration,
    super.enableFeedback,
    super.alignment,
    super.splashFactory,
  });

  final ButtonConfig? config;
}

extension ButtonStyleExtension on ButtonStyle {
  /// Returns a copy of this [ButtonStyle] with [ButtonConfig] applied.
  RxButtonStyle withConfig(ButtonConfig config) {
    return RxButtonStyle(
      config: config,
      textStyle: textStyle,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      overlayColor: overlayColor,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      elevation: elevation,
      padding: padding,
      minimumSize: minimumSize,
      fixedSize: fixedSize,
      maximumSize: maximumSize,
      iconColor: iconColor,
      iconSize: iconSize,
      side: side,
      shape: shape,
      mouseCursor: mouseCursor,
      visualDensity: visualDensity,
      tapTargetSize: tapTargetSize,
      animationDuration: animationDuration,
      enableFeedback: enableFeedback,
      alignment: alignment,
      splashFactory: splashFactory,
    );
  }
}
