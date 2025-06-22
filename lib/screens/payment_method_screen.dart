import 'package:flutter/material.dart';

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose Payment Method"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.credit_card),
                label: const Text("Pay with Stripe"),
                onPressed: () {
                  Navigator.pushNamed(context, '/stripe-payment');
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.mobile_friendly),
                label: const Text("Pay with Flutterwave"),
                onPressed: () {
                  Navigator.pushNamed(context, '/flutterwave-payment');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
