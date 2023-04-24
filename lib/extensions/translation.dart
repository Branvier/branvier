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
  static Translation? _instance;
  static final instance = _instance ??= Translation();

  ///Set this [key] on any widget above your translations getters.
  ///Ex: [MaterialApp].
  static final key = GlobalKey();

  ///Set this on [MaterialApp].localizationsDelegates.
  static List<LocalizationsDelegate> get delegates => [
        _TranslationLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];

  ///Path translations. Defaults to 'assets/translations'
  var _path = 'assets/translations';

  Locale? _locale; //current [Locale].
  var _fallback = const Locale('en', 'US');
  var _lazyTranslation = false;
  var _logger = true;

  ///All translations. {'locale': {'key': 'translation'}, ... }.
  final Translations translations = {};
  final missingTranslations = <String>{};
  final translationFiles = <String>{};
  final supportedLocales = <Locale>{};

  ///Load all locales from asset [path].
  Future<Set<Locale>> loadLocales(String path) async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    translationFiles.clear();
    final files = manifestMap.keys
        .where((key) => key.contains(path))
        .where((key) => key.endsWith('.json'));
    translationFiles.addAll(files);

    supportedLocales.clear();
    for (final file in translationFiles) {
      final code = file.split('/').last.split('.').first; //fileName
      supportedLocales.add(code.toLocale());
    }
    return supportedLocales;
  }

  ///Translation loader. Loads one if [_lazyTranslation] = true.
  Future<void> loadByLocale(Locale locale) async {
    final translations = <String, StringMap>{};
    late Locale fileLocale;

    final file = translationFiles.firstWhere((e) {
      fileLocale = e.split('/').last.split('.').first.toLocale();
      return fileLocale == locale;
    });

    final json = await rootBundle.loadString(file);
    translations[fileLocale.toString()] = json.parse<StringMap>();

    ///Merge with existings.
    Translation.instance.translations.addAll(translations);
  }

  ///Translation loader. Loads all if [_lazyTranslation] = false.
  Future<void> loadAll() async {
    final translations = <String, StringMap>{};

    for (final file in translationFiles) {
      final json = await rootBundle.loadString(file);
      final locale = file.split('/').last.split('.').first.toLocale(); //file
      translations[locale.toString()] = json.parse<StringMap>();
    }

    ///Merge with existings.
    Translation.instance.translations.addAll(translations);
  }

  ///Translates [key]. Fallbacks to subkeys.
  String? translate(String key) {
    final keys = key.subWords('.');

    //looking for sub keys.
    for (final key in keys) {
      final translation = translations[locale.toString()]?[key];
      if (translation != null) return translation; //found.
    }
    missingTranslations.add(key);
    if (_logger) dev.log('Missing translation: $key');
    return null; //not found.
  }

  ///Current [locale].
  Locale get fallback => _fallback;
  Locale get locale => _locale ?? _fallback;

  ///Change app language with locale.
  Future<void> changeLanguage(Locale locale) async {
    if (_locale == locale) return; //ignoring.
    if (_logger) dev.log('Translation changed: $_locale -> $locale');
    _locale = locale;

    if (_logger && _lazyTranslation) dev.log('isLazy = true. Loading...');
    if (_lazyTranslation) await loadByLocale(locale);
    if (_logger && _lazyTranslation) dev.log('isLazy = true. Loaded!');

    key.currentContext?.visitAll(rebuild: true);

    if (key.currentContext == null && _logger) {
      dev.log('Currently running is read mode. In order to update the UI, '
          'set Translation.key on any widget above your app or manage the '
          'the state manually. Use setLogger(false) to disable this.');
    }

    //Log missing translations.
    postFrame(
      () {
        if (_logger) dev.log('Missing translations: $missingTranslations');
      },
    );
  }

  ///Changes default path. Default: 'assets/translations'.
  void setPath(String path) {
    if (_logger) dev.log('Translation path: $path');
    _path = path;
  }

  ///The [Locale] the app starts. If null, use system's or fallback.
  void setInitial(Locale locale) {
    if (_logger) dev.log('Translation initial locale: $locale');
    _locale = locale;
  }

  ///Changes default fallback. Default: 'enUS'.
  void setFallback(Locale locale) {
    if (_logger) dev.log('Translation fallback: $locale');
    _fallback = locale;
  }

  ///Activates or desactivate log messages.
  void setLogger(bool isActive) {
    dev.log('Logger isActive: $isActive');
    _logger = isActive;
  }

  ///Changes translation behavior. Default: false.
  ///
  ///If true, translation won't be instant. It will only load translations files
  ///when the locale set on changeLanguage is first used.
  ///
  ///Tip: Only use in case you have lots of translations and huge files.
  void setLazyTranslation(bool isLazy) {
    if (_logger) dev.log('Translation isLazy: $isLazy');
    _lazyTranslation = isLazy;
  }
}

class _TranslationLocalizations extends LocalizationsDelegate {
  const _TranslationLocalizations._();
  static const delegate = _TranslationLocalizations._();

  ///Intance.
  Translation get trans => Translation.instance;

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<Translation> load(Locale locale) async {
    final locales = await trans.loadLocales(trans._path);
    final hasLocale = locales.contains(locale);
    final localeToLoad = hasLocale ? locale : trans._fallback;

    if (!trans._lazyTranslation) await trans.loadAll();

    await trans.changeLanguage(trans._locale ?? localeToLoad);
    return Translation.instance;
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
    final trans = Translation.instance;
    if (trans._logger && trans.translations.isEmpty) {
      dev.log(
        '0 translations. Did you set Translation.delegates on MaterialApp?',
      );
    }
    return Translation.instance.translate(this);
  }

  ///Converts this String to [Locale].
  ///Separators: _ , - , + , . , / , | , \ and space.
  Locale toLocale() {
    final parts = split(RegExp(r'[_\-\s\.\/|+\\]'));
    if (parts.length == 2) {
      return Locale(parts[0], parts[1]);
    } else if (parts.length == 1) {
      return Locale(parts[0]);
    } else {
      dev.log('invalid Locale: $this');
      return Locale(this);
    }
  }
}

///Simplest way to track any [Exception] in the app.
///
///Additionally auto translates this [key] if any translation matches.
class KeyException implements Exception {
  ///Identifies [Exception] with unique [key]. Translates, if any.
  KeyException(this.key);
  final String key;

  @override
  String toString() => key.tr;
}
