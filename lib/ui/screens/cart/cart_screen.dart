import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

/// CartScreen:
/// - Placeholder for cart UI
/// - Will eventually show:
///   - cart items list
///   - subtotal
///   - checkout button (native checkout if enabled)
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.checkout)), // using existing key
      body: const Center(
        child: Text('Cart items UI goes here'),
      ),
    );
  }
}
