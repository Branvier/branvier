import 'package:branvier/branvier.dart';
import 'package:flutter/material.dart';

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
    final ctrl = FormController();

    return Center(
      child: FormX(
        controller: ctrl,
        key: key,
        decoration: (tag) => InputDecoration(
          constraints: const BoxConstraints(maxHeight: 50),
          labelText: 'form.label.$tag'.tr,
        ),
        fieldWrapper: (tag, child) => child.pad(all: 8),
        onChange: print,
        onSubmit: print,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('home.form.costumer.title'.tr),
              Field.required('name'),
              Field.required('document_number', mask: '###.###.###-##'),
              Field.required('email'),
              FormX(
                tag: 'address',
                child: Column(
                  children: [
                    Field.required('street'),
                    Row(
                      children: [
                        Field.required('street_number', mask: '####'),
                        Field.required('neighborhood'),
                      ].list((e) => e.expand()),
                    ),
                    Row(
                      children: [
                        Field.required('zipcode', mask: '#####-###'),
                        Field.required('city'),
                        Field.required('state'),
                      ].list((e) => e.expand()),
                    ),
                    FormX(
                      tag: 'phone',
                      child: Row(
                        children: [
                          Field.required('ddd', mask: '##'),
                          Field.required('numer', mask: '# ####-####'),
                        ].list((e) => e.expand()),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('home.terms.policy'.tr),
                  BorderButton(
                    text: 'home.payment.proceed'.tr,
                    onTap: ctrl.reset,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BorderButton extends StatelessWidget {
  const BorderButton({super.key, required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(32),
        ),
      ),
      child: Text(text).w700(),
    );
  }
}
