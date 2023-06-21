part of 'rx_button.dart';

/// Class that defines [RxButton] states and styles.
class ButtonConfig {
  const ButtonConfig({
    this.keepSize = false,
    this.animatedSize = const AnimatedSizeConfig(),
    this.errorDuration = const Duration(seconds: 3),
    this.styleDuration = const Duration(seconds: 1),
    this.onLoading = RxButtonLoaders.spinner,
    this.onError = RxButtonErrors.text,
    this.onHover,
    this.hoverStyle,
    this.loadingStyle = _defaultLoadingStyle,
    this.errorStyle = _defaultErrorStyle,
  });

  /// Whether or not this button should keep its size when animating.
  final bool keepSize;

  /// The configuration for [AnimatedSize].
  final AnimatedSizeConfig? animatedSize;

  /// The duration to show error widget.
  final Duration errorDuration;

  /// The duration between styles animations.
  final Duration styleDuration;

  /// The widget to show on loading.
  final Widget Function(RxButtonState state) onLoading;

  /// The widget to show on error.
  final Widget Function(RxButtonState state) onError;

  /// The widget to show on hover.
  final Widget Function(RxButtonState state)? onHover;

  /// The style to apply on loading.
  final ButtonStyle Function(RxButtonState state) loadingStyle;

  /// The style to apply on error.
  final ButtonStyle Function(RxButtonState state) errorStyle;

  /// The style to apply on hover.
  final ButtonStyle Function(RxButtonState state)? hoverStyle;

  /// Overrides loading [ButtonStyle].
  static ButtonStyle _defaultLoadingStyle(RxButtonState state) {
    return state.initialStyle.copyWith(
      padding: const MaterialStatePropertyAll(EdgeInsets.zero),
    );
  }

  /// Overrides error [ButtonStyle].
  static ButtonStyle _defaultErrorStyle(RxButtonState state) {
    final errorColor = Theme.of(state.context).colorScheme.error;

    return state.initialStyle.copyWith(
      backgroundColor: () {
        if (state.isOutlinedButton) return null;
        if (state.isTextButton) return null;
        return MaterialStatePropertyAll(errorColor);
      }(),
      foregroundColor: () {
        if (state.isElevatedButton) return null;
        if (state.isFilledButton) return null;
        return MaterialStatePropertyAll(errorColor);
      }(),
    );
  }
}

mixin RxButtonLoaders {
  static Widget spinner(RxButtonState state) {
    return SizedBox.square(
      dimension: state.size.height / 2,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        value: state.loadingProgress,
        color: () {
          if (state.isOutlinedButton) return null;
          if (state.isTextButton) return null;
          return Theme.of(state.context).colorScheme.onPrimary;
        }(),
      ),
    );
  }
}

mixin RxButtonErrors {
  static Widget text(RxButtonState state) {
    return Text(
      state.errorMessage,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class AnimatedSizeConfig {
  const AnimatedSizeConfig({
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.fastOutSlowIn,
    this.clipBehavior = Clip.hardEdge,
    this.alignment = Alignment.center,
    this.reverseDuration,
  });

  final Duration duration;
  final Curve curve;
  final Clip clipBehavior;
  final Alignment alignment;
  final Duration? reverseDuration;
}
