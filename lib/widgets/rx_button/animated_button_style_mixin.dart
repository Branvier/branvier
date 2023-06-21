// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';

mixin AnimatedButtonStyleMixin<T extends ButtonStyleButton>
    on State<T>, TickerProviderStateMixin<T> {
  late final controller = AnimationController(vsync: this);

  late final animation =
      CurvedAnimation(parent: controller, curve: Curves.easeInOut);

  late var _bgColor = _buttonStyle.backgroundColor!.resolve({})!;
  late var _fgColor = _buttonStyle.foregroundColor!.resolve({})!;
  late var _padding = _buttonStyle.padding!.resolve({})!;
  late var _bgAnimation =
      animation.drive(ColorTween(begin: _bgColor, end: _bgColor));
  late var _fgAnimation =
      animation.drive(ColorTween(begin: _fgColor, end: _fgColor));

  late var _paddingAnimation = animation.drive(
    EdgeInsetsGeometryTween(begin: _padding, end: _padding),
  );

  late final initialStyle =
      (widget.style ?? widget.themeStyleOf(context) ?? const ButtonStyle())
          .merge(widget.defaultStyleOf(context));

  late var _buttonStyle = initialStyle;

  ButtonStyle get animatedStyle => ButtonStyle(
        backgroundColor: MaterialStateProperty.all(_bgAnimation.value),
        foregroundColor: MaterialStateProperty.all(_fgAnimation.value),
        padding: MaterialStateProperty.all(_paddingAnimation.value),
      );

  void changeButtonStyle(ButtonStyle newStyle) {
    _bgColor = _bgAnimation.value!;
    _fgColor = _fgAnimation.value!;
    _padding = _paddingAnimation.value;

    _bgAnimation = animation.drive(
      ColorTween(
        begin: _bgColor,
        end: newStyle.backgroundColor!.resolve({}),
      ),
    );

    _fgAnimation = animation.drive(
      ColorTween(
        begin: _fgColor,
        end: newStyle.foregroundColor!.resolve({}),
      ),
    );

    _paddingAnimation = animation.drive(
      EdgeInsetsGeometryTween(
        begin: _padding,
        end: newStyle.padding!.resolve({}),
      ),
    );

    _buttonStyle = newStyle;

    if (mounted) controller.forward(from: 0.0);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    animation.addListener(_rebuild);
    super.initState();
  }

  @override
  void dispose() {
    animation.removeListener(_rebuild);
    controller.dispose();
    super.dispose();
  }
}
