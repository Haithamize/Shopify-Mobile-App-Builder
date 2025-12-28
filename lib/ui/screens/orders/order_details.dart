import 'package:flutter/material.dart';

/// OrderDetailsScreen:
/// - Works with deep links immediately:
///     /orders/:id
/// - Later you’ll fetch the order from your backend/Shopify/etc.
class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order $orderId')),
      body: Center(
        child: Text('Order details for $orderId'),
      ),
    );
  }
}
