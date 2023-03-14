part of '/branvier.dart';

class Translation extends StatefulWidget {
  const Translation({
    super.key,
    this.initialLocale = 'en',
    required this.translations,
    required this.child,
  });

  final Map<String, Map<String, String>> translations;
  final String initialLocale;
  final Widget child;

  static final _key = GlobalKey();

  static Future<void> changeLocale(String locale) async {
    await _key.currentContext?.changeLocale(locale);
  }

  @override
  State<Translation> createState() => _TranslationState();
}

class _TranslationState extends State<Translation> {
  late final locale = ValueNotifier(widget.initialLocale);

  @override
  Widget build(BuildContext context) {
    return TranslationNotifier(
      notifier: locale,
      translations: widget.translations,
      child: Builder(
        key: Translation._key,
        builder: (_) => widget.child,
      ),
    );
  }
}

class TranslationNotifier extends InheritedNotifier {
  const TranslationNotifier({
    super.key,
    required this.translations,
    required super.child,
    required ValueNotifier<String> super.notifier,
  });

  final Map<String, Map<String, String>> translations;
}

extension TransExt on TranslationNotifier {
  ValueNotifier<String> get locale => notifier! as ValueNotifier<String>;
  String translate(String key) => translations[locale.value]?[key] ?? key;
}

extension TranlationExt on String {
  ///Translates. Returns this string on failure.
  String get trs {
    final scope = Translation._key.currentContext
        ?.dependOnInheritedWidgetOfExactType<TranslationNotifier>();

    return scope?.translate(this) ?? this;
  }

  ///Translates. Returns null on failure.
  String? get trn {
    if (trs == this) return null;
    return trs;
  }
}

extension TrCtxExt on BuildContext {
  Future<void> changeLocale(String locale) async {
    final scope = dependOnInheritedWidgetOfExactType<TranslationNotifier>();
    scope?.locale.value = locale;
    await engine.performReassemble();
  }
}
