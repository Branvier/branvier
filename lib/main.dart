import 'package:flutter/material.dart';

import 'branvier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Translation.init(
    initialLocale: 'en',
    translations: const {
      'en': {
        'hello1': 'hello one',
        'hello2': 'hello two',
        'hello3': 'hello three',
      },
      'pt': {
        'hello1': 'oi um',
        'hello2': 'oi dois',
        'hello3': 'oi três',
      },
    },
  );

  await Translation.initAsset('initialLocale', 'path');

  // final translations = Translation.loadTranslations();
  runApp(
    const MaterialApp(
      home: HomeScreen(),
    ),
  );
}

class Scaff extends StatelessWidget {
  const Scaff({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('hello2'.trn ?? 'falhou'),
      ),
      body: child,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('hello3'.tr)),
      body: Center(
        child: ElevatedButtonX(
          onTap: () async {
            await Translation.changeLanguage(
              Translation.locale == 'en' ? 'pt' : 'en',
            );
          },
          child: Text(TranslationOld.locale),
        ),
      ),
    );
  }
}
