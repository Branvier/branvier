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
  static Locale? _locale;
  static Locale? _fallback;

  ///Path translations.
  static var _path = 'assets/translations';

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

  ///Set this on [MaterialApp].key.
  static final key = GlobalKey();

  ///Set this on [MaterialApp].localizationsDelegates.
  static List<LocalizationsDelegate> get delegates => [
        TranslationDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];

  ///All translations. {'locale': {'key': 'translation'}, ... }.
  final Translations translations;
  static final Translations missingTranslations = {};

  ///The language the app starts with.
  final Locale initialLocale;

  ///Translates [key]. Fallbacks to subkeys.
  String? translate(String key) {
    final keys = key.subWords('.');

    //looking for sub keys.
    for (final key in keys) {
      final translation = translations[locale.toLanguageTag()]?[key];
      if (translation != null) return translation; //found.
    }
    dev.log('Missing translation: $key');
    missingTranslations[locale.toLanguageTag()]?[key] = '';
    return null; //not found.
  }

  ///Current [locale].
  static Locale get locale => _locale!;
  static Locale get fallback => _fallback!;

  ///Change app language with locale.
  static void changeLanguage(Locale locale) {
    _locale = locale;
    dev.log('Translation changed: $_locale -> $locale');
    key.currentContext?.visitAll(rebuild: true);
    postFrame(Translation.missingTranslations.log);
  }

  ///Changes default path. Default: 'assets/translations'.
  static void setPath(String path) {
    dev.log('Translation path: $path');
    Translation._path = path;
  }

  ///Changes default fallback. Default: 'en-US'.
  static void setFallback(Locale locale) {
    dev.log('Translation fallback: $locale');
    Translation._fallback = locale;
  }
}

class TranslationDelegate extends LocalizationsDelegate<Translation> {
  @override
  bool isSupported(Locale locale) =>
      Translation._instance!.translations.keys.contains(locale.toLanguageTag());

  @override
  Future<Translation> load(Locale locale) async {
    final translations = await Translation._loadFolder(Translation._path);
    final supported = translations.keys.contains(locale.toLanguageTag());
    final fallback = Translation._fallback ??= const Locale('en', 'US');
    final initialLocale = supported ? locale : fallback;

    //init
    return Translation._instance ??= Translation._(initialLocale, translations);
  }

  @override
  bool shouldReload(LocalizationsDelegate old) => false;
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
    if (Translation._instance == null) {
      dev.log('Translation failed. You need to call Translation.init()');
    }
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
