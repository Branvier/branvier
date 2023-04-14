part of '/branvier.dart';

typedef Translations = Map<String, Map<String, String>>;

///Mini [Translation] package for translation.
///
///Reads translations maps in the format {'locale': {'key': 'translation'}, ... }.
///
///- Changing Language:
///Translation.changeLanguage('pt').
///
///- Translating:
///For {'pt': {'login.button.title': 'Login'}}, just 'login.button.title'.tr -> 'Login'.
///
///- Dot Patterns:
///For {'pt': {'form.invalid': 'Invalid field'}}: 'form.invalid.email'.tr -> 'Invalid field'.
///
/// [.tr] Pattern: 'a.b.c' -> 'a.b' -> 'a' -> 'a.b.c'.
///
/// [.trn] Pattern: 'a.b.c' -> 'a.b' -> 'a' -> null.
class Translation {
  const Translation._(this.initialLocale, this.translations);
  static Translation? _instance;
  static String? _locale;

  ///Inits [translations] right away with a [Map].
  static void init({
    required String initialLocale,
    required Translations translations,
  }) {
    _locale ??= initialLocale;
    _instance ??= Translation._(initialLocale, translations);
  }

  ///Loads all [translations] files from asset [path] then init().
  static Future<void> initAsset(
    String initialLocale,
    String path,
  ) async {
    final translations = await _loadFolder(path);
    init(initialLocale: initialLocale, translations: translations);
  }

  ///Translation loader utility. Loads from asset [path].
  static Future<Translations> _loadFolder(String path) async {
    final translations = <String, StringMap>{};

    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    final translationFiles = manifestMap.keys
        .where((key) => key.contains(path))
        .where((key) => key.endsWith('.json'));

    for (final file in translationFiles) {
      final json = await rootBundle.loadString(file);
      final languageCode = file.split('/').last.split('.').first; //fileName
      translations[languageCode] = json.parse<StringMap>();
    }

    return translations;
  }

  ///All translations. {'locale': {'key': 'translation'}, ... }.
  final Translations translations;

  ///The language the app starts with.
  final String initialLocale;

  ///Translates [key]. Fallbacks to subkeys.
  String? translate(String key) {
    final keys = key.subWords('.');

    //looking for sub keys.
    for (final key in keys) {
      final translation = translations[locale]?[key];
      if (translation != null) return translation; //found.
    }

    return null; //not found.
  }

  ///Current [locale].
  static String get locale => _locale!;

  ///Change app language with locale.
  static Future<void> changeLanguage(String locale) async {
    _locale = locale;
    await engine.performReassemble();
  }
}

class TranslationOld extends StatelessWidget {
  const TranslationOld({
    required this.translations,
    required this.builder,
    this.initialLocale = 'en',
    super.key,
  });

  ///All translations. {'locale': {'key': 'translation'}, ... }.
  final Translations translations;

  ///The language the app starts with.
  final String initialLocale;

  ///Rebuild on [TranslationOld].changeLocale. [MaterialApp] must be below.
  final WidgetBuilder builder;

  ///Current language code.
  static String get locale => _scope.locale;

  ///Change app language to [locale].
  static Future<void> changeLocale(String locale) async {
    await _scope.change(locale);
  }

  ///Translation loader utility. Loads from asset.
  static Future<Translations> fromAssetFolder(String path) async {
    final translations = <String, StringMap>{};

    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    final translationFiles = manifestMap.keys
        .where((key) => key.contains(path))
        .where((key) => key.endsWith('.json'));

    for (final file in translationFiles) {
      final json = await rootBundle.loadString(file);
      final languageCode = file.split('/').last.split('.').first; //fileName
      translations[languageCode] = json.parse<StringMap>();
    }

    return translations;
  }

  ///Reference to find our [TranslationOld].
  static final _key = GlobalKey();

  ///The notifier scope of this [TranslationOld].
  static TranslationNotifier get _scope {
    assert(
      TranslationOld._key.currentContext != null,
      'Translation() not found. You need to put Translation widget above MaterialApp.',
    );
    return TranslationOld._key.currentContext!
        .dependOnInheritedWidgetOfExactType<TranslationNotifier>()!;
  }

  static String? _locale;

  @override
  Widget build(BuildContext context) {
    return TranslationNotifier(
      locale: _locale ??= initialLocale,
      translations: translations,
      child: Builder(
        key: TranslationOld._key,
        builder: builder,
      ),
    );
  }
}

class TranslationNotifier extends InheritedWidget {
  const TranslationNotifier({
    required this.locale,
    required this.translations,
    required super.child,
    super.key,
  });

  ///All translations.
  final Translations translations;

  ///Language code.
  final String locale;

  ///Reactive locale.
  // ValueNotifier<String> get locale => notifier! as ValueNotifier<String>;

  ///Translates [key]. Fallbacks to subkeys.
  ///
  ///Ex: form.invalid.email.
  ///If none, translates 'form.invalid'.
  ///If none, translates 'form'.
  ///If none, returns [key].
  String? translate(String key) {
    final keys = key.subWords('.');

    //looking for sub keys.
    for (final key in keys) {
      final translation = translations[locale]?[key];
      if (translation != null) return translation; //found.
    }

    return null; //not found.
  }

  ///Change app language code.
  Future<void> change(String locale) async {
    TranslationOld._locale = locale;
    await engine.performReassemble();
  }

  @override
  bool updateShouldNotify(oldWidget) => false;
}

extension TranlationExtension on String {
  ///Translates this key. If no pattern found, returns this.
  ///
  ///Pattern: 'a.b.c' -> 'a.b' -> 'a' -> 'a.b.c'.
  String get tr => trn ?? this;

  ///Translates this key. If no pattern found, returns null.
  ///
  ///Pattern: 'a.b.c' -> 'a.b' -> 'a' -> null.
  String? get trn {
    assert(
      Translation._instance != null,
      'Translation not inited. You need to call Translation.init()',
    );
    return Translation._instance?.translate(this);
  }
}

///Simplest way to track any [Exception] in the app.
///
///Additionally auto translates this [key] if any translation matches.
class ExceptionKey implements Exception {
  ///Identifies [Exception] with unique [key]. Translates, if any.
  ExceptionKey(this.key);
  final String key;

  @override
  String toString() => key.tr;
}
