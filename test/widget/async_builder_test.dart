// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:branvier/branvier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_scaffold_widget.dart';

void main2() {
  testWidgets(
    'async builder',
    (tester) async {
      var response = 'the future is here';
      final controller = AsyncController();

      // Build our app and trigger a frame.
      await tester.pumpWidget(
        AppScaffold(
          child: AsyncBuilder<String>(
            async: Async.future(
              () async {
                if (response == 'error') throw Exception('error');
                return 1.seconds.set(response);
              },
              controller: controller,
            ),
            builder: (data) {
              return Text(data);
            },
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(0.5.seconds);
      expect(find.byType(Text), findsOneWidget);
      expect(find.text('initial is here'), findsOneWidget);

      await tester.pump(0.5.seconds);
      expect(find.byType(Text), findsOneWidget);
      expect(find.text('the future is here'), findsOneWidget);

      ///Emptying the data.
      response = '';
      controller.reload();

      ///Updating data.
      await tester.pump();
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      ///Data updated and empty.
      await tester.pump(1.seconds);
      expect(find.byType(Text), findsOneWidget);
      expect(find.text('-'), findsOneWidget);

      ///Added error.
      response = 'error';
      controller.reload();

      //With throw, changes to updating for 1 frame.
      await tester.pump();
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      //Show error in next frame, AsyncBuilder sends initial data.
      await tester.pump();
      expect(find.text('initial is here'), findsOneWidget);
    },
  );
}
