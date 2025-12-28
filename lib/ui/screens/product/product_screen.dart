import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';

/// ProductScreen:
/// - Works with deep links immediately:
///     /product/:id
/// - Later you will fetch product details from Shopify Storefront API
/// - Includes a checkout CTA for UI testing
class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text('Product $productId')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product details for $productId'),
            const SizedBox(height: 16),

            // Example: route to cart tab
            FilledButton(
              onPressed: () => context.go('/cart'),
              child: Text(l10n.checkout),
            ),
          ],
        ),
      ),
    );
  }
}
