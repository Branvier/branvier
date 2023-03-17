import 'package:branvier/branvier.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: PaymentForm())));

class PaymentForm extends StatelessWidget {
  const PaymentForm({
    super.key,
    this.installments = false,
    this.onPaymentSubmit,
  });
  final bool installments;
  final ValueSetter<Json>? onPaymentSubmit;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FormX(
        decoration: (tag) => InputDecoration(
          constraints: const BoxConstraints(maxHeight: 50),
          labelText: 'form.label.$tag'.tr,
        ),
        fieldWrapper: (key, child) => child.pad(all: 4),
        onChange: print,
        onSubmit: onPaymentSubmit,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Field('name'),
              const Field('document_number', mask: '###.###.###-##'),
              const Field('email'),
              FormX(
                tag: 'costumer',
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Field('expire', mask: '##/##'),
                        const Field('cvv', mask: '###'),
                      ].list((e) => e.expand()),
                    ),
                  ],
                ),
              ),
              if (installments)
                Row(
                  children: [
                    const SizedBox(),
                    Field('installments', options: 12.numbered),
                  ].list((e) => e.expand()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
