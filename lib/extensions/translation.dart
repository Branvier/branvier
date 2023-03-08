part of 'export.dart';

class Translation extends StatefulWidget {
  const Translation({
    Key? key,
    this.initialLocale = 'en',
    required this.translations,
    required this.child,
  }) : super(key: key);

  final Map<String, Map<String, String>> translations;
  final String initialLocale;
  final Widget child;

  static final _key = GlobalKey();

  static void changeLocale(String locale) {
    _key.currentContext?.changeLocale(locale);
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
    Key? key,
    required this.translations,
    required Widget child,
    required ValueNotifier<String> notifier,
  }) : super(key: key, child: child, notifier: notifier);

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
  void changeLocale(String locale) {
    final scope = dependOnInheritedWidgetOfExactType<TranslationNotifier>();
    scope?.locale.value = locale;
    engine.performReassemble();
  }
}
