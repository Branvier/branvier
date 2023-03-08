part of 'export.dart';

extension StyledText<T extends Text> on T {
  TextStyle get _style => style ?? const TextStyle();
  T _copy(TextStyle style) => copyWith(style: style);

  T copyWith({
    String? data,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextAlign? textAlign,
    TextDirection? textDirection,
    Locale? locale,
    bool? softWrap,
    TextOverflow? overflow,
    double? textScaleFactor,
    int? maxLines,
    String? semanticsLabel,
    TextWidthBasis? textWidthBasis,
  }) =>
      Text(
        data ?? this.data ?? '',
        style: style ?? this.style,
        strutStyle: strutStyle ?? this.strutStyle,
        textAlign: textAlign ?? this.textAlign,
        locale: locale ?? this.locale,
        maxLines: maxLines ?? this.maxLines,
        overflow: overflow ?? this.overflow,
        semanticsLabel: semanticsLabel ?? this.semanticsLabel,
        softWrap: softWrap ?? this.softWrap,
        textDirection: textDirection ?? this.textDirection,
        textScaleFactor: textScaleFactor ?? this.textScaleFactor,
        textWidthBasis: textWidthBasis ?? this.textWidthBasis,
      ) as T;

  T size(double? fontSize) => _copy(_style.size(fontSize));
  T color(Color color) => _copy(_style.copyWith(color: color));

  T w100([double? fontSize]) => _copy(_style.w100.size(fontSize));
  T w200([double? fontSize]) => _copy(_style.w200.size(fontSize));
  T w300([double? fontSize]) => _copy(_style.w300.size(fontSize));
  T w400([double? fontSize]) => _copy(_style.w400.size(fontSize));
  T w500([double? fontSize]) => _copy(_style.w500.size(fontSize));
  T w600([double? fontSize]) => _copy(_style.w600.size(fontSize));
  T w700([double? fontSize]) => _copy(_style.w700.size(fontSize));
  T w800([double? fontSize]) => _copy(_style.w800.size(fontSize));
  T w900([double? fontSize]) => _copy(_style.w900.size(fontSize));

  T italic() => _copy(_style.italic);
  T underLine() => _copy(_style.underline);

  T fontFamily(String font) => _copy(_style.copyWith(fontFamily: font));
  T letterSpacing(double space) => _copy(_style.copyWith(letterSpacing: space));
  T wordSpacing(double space) => _copy(_style.copyWith(wordSpacing: space));

  T shadow({
    Color color = const Color(0x34000000),
    double blurRadius = 0.0,
    Offset offset = Offset.zero,
  }) {
    return _copy(
      _style.shadow(color: color, blurRadius: blurRadius, offset: offset),
    );
  }
}

extension TextStyleExt on TextStyle {
  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);
  TextStyle get underline => copyWith(decoration: TextDecoration.underline);

  TextStyle shadow({
    Color color = const Color(0x34000000),
    double blurRadius = 0.0,
    Offset offset = Offset.zero,
  }) =>
      copyWith(
        shadows: [Shadow(color: color, blurRadius: blurRadius, offset: offset)],
      );

  //FontSize
  TextStyle size(double? fontSize) => copyWith(fontSize: fontSize);
  TextStyle get s10 => copyWith(fontSize: 10);
  TextStyle get s12 => copyWith(fontSize: 12);
  TextStyle get s14 => copyWith(fontSize: 14);
  TextStyle get s16 => copyWith(fontSize: 16);
  TextStyle get s18 => copyWith(fontSize: 18);
  TextStyle get s20 => copyWith(fontSize: 20);
  TextStyle get s24 => copyWith(fontSize: 24);
  TextStyle get s32 => copyWith(fontSize: 32);
  TextStyle get s40 => copyWith(fontSize: 40);
  TextStyle get s48 => copyWith(fontSize: 48);

  //FontWeight
  TextStyle get w100 => copyWith(fontWeight: FontWeight.w100);
  TextStyle get w200 => copyWith(fontWeight: FontWeight.w200);
  TextStyle get w300 => copyWith(fontWeight: FontWeight.w300);
  TextStyle get w400 => copyWith(fontWeight: FontWeight.w400);
  TextStyle get w500 => copyWith(fontWeight: FontWeight.w500);
  TextStyle get w600 => copyWith(fontWeight: FontWeight.w600);
  TextStyle get w700 => copyWith(fontWeight: FontWeight.w700);
  TextStyle get w800 => copyWith(fontWeight: FontWeight.w800);
  TextStyle get w900 => copyWith(fontWeight: FontWeight.w900);
}
