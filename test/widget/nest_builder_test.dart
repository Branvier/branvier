import 'package:branvier/branvier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_scaffold_widget.dart';

enum PaymentNest { details, options, paymentType, credit, pix, bill, debit }

void main() {
  testWidgets('nest builder', (tester) async {
    await tester.pumpWidget(
      AppScaffold(
        child: NestBuilder<PaymentNest>(
          ///Transform all enum values in pages.
          values: PaymentNest.values,

          ///Optional wrapper that will always be visible.
          ///You can also just wrap the NestBuilder.
          nestWrapper: (nest, child) {
            return Scaffold(
              body: Center(child: child),
              appBar: AppBar(leading: BackButton(onPressed: nest.back)),
              floatingActionButton: FloatingActionButton(onPressed: nest.next),
            );
          },

          ///Optional wrapper for each page.
          ///You can also just wrap each page individually.
          pageWrapper: (nest, child) => Scaffold(body: Center(child: child)),

          ///The content of each page.
          builder: (nest) {
            switch (nest.type) {
              case PaymentNest.details:
                return Text(nest.name);
              case PaymentNest.options:
                return const _PaymentOptions();
              case PaymentNest.paymentType:
                return Text(nest.name);
              case PaymentNest.credit:
                return Text(nest.name);
              case PaymentNest.pix:
                return Text(nest.name);
              case PaymentNest.bill:
                return Text(nest.name);
              case PaymentNest.debit:
                return Text(nest.name);
            }
          },
        ),
      ),
    );
  });
}

class _PaymentOptions extends StatelessWidget {
  const _PaymentOptions();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //you can use the native button, as it calls .pop()
        const BackButton(),
        ElevatedButton(
          // Shortcut for your enum page.
          onPressed: () => context.toNested(PaymentNest.bill),
          // onPressed: () => Navigator.pushNamed(context,PaymentNest.pix.name),
          onLongPress: () => context.nest.back(),
          //or below.
          // onLongPress: () => context.backNested(),
          //or even:
          // onLongPress: () => Navigator.pop(context),
          child: const Text('options -> pix'),
        ),
      ],
    );
  }
}
