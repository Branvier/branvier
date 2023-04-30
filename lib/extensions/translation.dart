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
  static Translation get to => instance;

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
  var _lazyLoad = false;
  var _logger = true;

  ///All translations. {'locale': {'key': 'translation'}, ... }.
  final Translations translations = {};
  final missingTranslations = <String>{};
  final translationFiles = <String>{};
  final supportedLocales = <Locale>{};

  ///Load all locales from asset [path].
  Future<Set<Locale>> _loadLocales(String path) async {
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

  ///Translation loader. Loads one if [_lazyLoad] = true.
  Future<void> _loadByLocale(Locale locale) async {
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

  ///Translation loader. Loads all if [_lazyLoad] = false.
  Future<void> _loadAll() async {
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

    //checking locale.
    var code = locale.toString();
    final hasCode = translations.keys.contains(locale.toString());
    if (!hasCode) {
      final languages = translations.keys.where(
        (key) => key.startsWith(locale.languageCode),
      );
      if (languages.isNotEmpty) {
        code = languages.first;
      }
    }

    //looking for sub keys.
    for (final key in keys) {
      final translation = translations[code]?[key];
      if (translation != null) return translation; //found.
    }
    return null; //not found.
  }

  ///Current [locale].
  Locale get fallback => _fallback;
  Locale get locale => _locale ?? _fallback;

  ///Change app language with locale.
  Future<void> changeLanguage(Locale locale) async {
    if (_locale == locale) return; //ignoring.
    if (_logger) dev.log('[Tr]: Translation changed: $_locale -> $locale');
    _locale = locale;

    if (_logger && _lazyLoad) dev.log('[Tr]: isLazy = true. Loading...');
    if (_lazyLoad) await _loadByLocale(locale);
    if (_logger && _lazyLoad) dev.log('[Tr]: isLazy = true. Loaded!');

    key.currentContext?.visitAll(rebuild: true);

    if (key.currentContext == null && _logger) {
      dev.log(
          '[Tr]: Currently running is read mode. In order to update the UI, '
          'set Translation.key on any widget above your app or manage the '
          'the state manually. Use setLogger(false) to disable this.');
    }

    //Log missing translations.
    postFrame(
      () {
        if (_logger) {
          final total = <String>{};
          final n = missingTranslations.length;

          translations.forEach((key, value) {
            total.addAll(value.values);
          });

          final percent = (n / total.length) - 1;

          if (percent == 1) {
            dev.log('[Tr]: Keys 100% translated! ✓');
          } else {
            dev.log('[Tr]: There are $n missing keys. Progress: $percent%');
            dev.log('[Tr]: Missing these: ${jsonEncode(missingTranslations)}');
          }
        }
      },
    );
  }

  ///Changes default path. Default: 'assets/translations'.
  static void setPath(String path) {
    if (to._logger) dev.log('[Tr]: Translation path: $path');
    to._path = path;
  }

  ///The [Locale] the app starts. If null, use system's or fallback.
  static void setInitial(Locale locale) {
    if (to._logger) dev.log('[Tr]: Translation initial locale: $locale');
    to._locale = locale;
  }

  ///Changes default fallback. Default: 'enUS'.
  static void setFallback(Locale locale) {
    if (to._logger) dev.log('[Tr]: Translation fallback: $locale');
    to._fallback = locale;
  }

  ///Activates or desactivate log messages.
  static void setLogger(bool isActive) {
    dev.log('[Tr]: Logger isActive: $isActive');
    to._logger = isActive;
  }

  ///Changes translation behavior. Default: false.
  ///
  ///If true, translation won't be instant. It will only load translations files
  ///when changeLanguage is first used.
  ///
  ///Tip: Only use in case you have lots of translations and huge files.
  static void setLazyLoad(bool isLazy) {
    if (to._logger) dev.log('[Tr]: Translation isLazy: $isLazy');
    to._lazyLoad = isLazy;
  }
}

class _TranslationLocalizations extends LocalizationsDelegate {
  const _TranslationLocalizations._();
  static const delegate = _TranslationLocalizations._();

  ///Intance.
  Translation get to => Translation.instance;

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<Translation> load(Locale locale) async {
    final locales = await to._loadLocales(to._path);
    final hasLocale = locales.contains(locale);
    final localeToLoad = hasLocale ? locale : to._fallback;

    if (!to._lazyLoad) await to._loadAll();

    await to.changeLanguage(to._locale ?? localeToLoad);
    return Translation.instance;
  }

  @override
  bool shouldReload(LocalizationsDelegate old) => false;
}

extension TranlationExtension on String {
  ///Translates this key. If no pattern found, returns this.
  ///
  ///Pattern: 'a.b.c' -> 'a.b' -> 'a' -> 'a.b.c'.
  String get tr {
    final i = Translation.instance;
    if (i._logger && i.translations.isEmpty) {
      dev.log(
        '[Tr]: 0 translations. Did you set Translation.delegates on MaterialApp?',
      );
    }
    final translation = trn;

    if (i._logger && translation == null) {
      dev.log('[Tr]: Missing translation: $this');
      i.missingTranslations.add(this);
    }

    return translation ?? this;
  }

  ///Translates this key. If no pattern found, returns null.
  ///
  ///Pattern: 'a.b.c' -> 'a.b' -> 'a' -> null.
  String? get trn => Translation.to.translate(this);

  ///Converts this String to [Locale].
  ///Separators: _ , - , + , . , / , | , \ and space.
  Locale toLocale() {
    final parts = split(RegExp(r'[_\-\s\.\/|+\\]'));
    if (parts.length == 2) {
      return Locale(parts[0], parts[1]);
    } else if (parts.length == 1) {
      return Locale(parts[0]);
    } else {
      dev.log('[Tr]: invalid Locale: $this');
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
