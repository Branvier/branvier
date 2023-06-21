import 'package:flutter/material.dart';

import '../../branvier.dart';
import 'rx_button.dart';

void main() => runApp(
      const MaterialApp(home: Scaffold(body: MyWidget())),
    );

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // onPressed
    Future<void> onPressed() async {
      await Future.delayed(const Duration(seconds: 1));
      throw Exception('Error');
    }

    final loading1 = ValueNotifier(false);
    final loading2 = ValueNotifier(true);
    final progress1 = ValueNotifier(0.2);
    final progress2 = ValueNotifier(0.6);
    final message1 = ValueNotifier('');
    final message2 = ValueNotifier('');

    return Theme(
      data: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: RxButtonStyle(
            config: ButtonConfig(
              onHover: (state) {
                return state.child.withShimmer(state.isHovering);
              },
            ),
          ),
        ),
      ),
      child: Transform.scale(
        scale: 2,
        child: Center(
          child: FormX(
            onSubmit: (form) async {
              await Future.delayed(const Duration(seconds: 1));
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Field('Username'),
                RxElevatedButton(
                  listenables: [FormX.loading],
                  onPressed: onPressed,
                  child: const Text('ElevatedButton'),
                ),
                RxElevatedButton(
                  config: ButtonConfig(
                    onHover: (state) {
                      // scales on hover
                      return state.child.withShimmer(state.isHovering);
                    },
                    onLoading: (state) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: Text(
                          key: ValueKey(state.loadingMessage),
                          state.loadingMessage,
                        ),
                      );
                    },
                  ),
                  listenables: [
                    loading1,
                    // loading2,
                    progress1,
                    progress2,
                    message1,
                    message2,
                  ],
                  onPressed: () async {
                    await Future.delayed(const Duration(milliseconds: 900));
                    message1.value = 'lets go';
                    await Future.delayed(const Duration(milliseconds: 900));
                    message2.value = 'yes';
                    await Future.delayed(const Duration(milliseconds: 900));
                    message1.value = 'boom';
                    await Future.delayed(const Duration(milliseconds: 900));
                    message2.value = 'lalala';
                    await Future.delayed(const Duration(milliseconds: 900));
                  },
                  child: const Text('OutlinedButton'),
                ),
                RxTextButton(
                  onPressed: onPressed,
                  child: const Text('TextButton'),
                ),
                RxFilledButton(
                  onPressed: onPressed,
                  child: const Text('FilledButton'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
