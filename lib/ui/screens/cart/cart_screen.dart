import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopify_flutter/shopify_flutter.dart' as sf;
import 'package:shopify_sheet/shopify_sheet.dart';

import '../../../features/catalogue/bloc/cart/cart_bloc.dart';
import '../../../features/catalogue/bloc/cart/cart_event.dart';
import '../../../features/catalogue/bloc/cart/cart_state.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utility/utility.dart';
import '../../layout/responsive.dart';
import '../webview/checkout_webview_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ShopifySheet _sheet = ShopifySheet();
  late final StreamSubscription _checkoutSub;

  @override
  void initState() {
    super.initState();

    _checkoutSub = _sheet.checkoutEvents.listen((event) {
      switch (event.type) {
        case ShopifySheetEventType.completed:
          debugPrint("Checkout Completed");

          // Close sheet (optional; usually it auto-closes but this is safe)
          // _sheet.closeCheckout();

          // ✅ Clear cart in app
          if (mounted) {
            context.read<CartBloc>().add(const CartCheckoutCompleted());
            context.read<CartBloc>().add(const CartRefresh());
          }
          break;

        case ShopifySheetEventType.canceled:
          _sheet.closeCheckout();
          debugPrint("Checkout Canceled");
          break;

        case ShopifySheetEventType.failed:
          debugPrint("Checkout Failed: ${event.error}");
          break;

        case ShopifySheetEventType.pixelEvent:
          debugPrint("Pixel Event: ${event.data}");
          break;

        default:
          debugPrint("Unknown Checkout event");
      }
    });
  }

  @override
  void dispose() {
    _checkoutSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<CartBloc, CartState>(
      listenWhen: (prev, curr) => curr is CartCheckoutReady,
      listener: (context, state) async {
        final s = state as CartCheckoutReady;
        final checkoutUrlWithUtm = withUtmParams(
          s.checkoutUrl,
          utmSource: 'baffi store app',
          utmMedium: 'shopify_sheet',
          utmCampaign: 'checkout',
          // optional:
          utmContent: 'cart_screen',
          utmTerm: 'android',
        );
        // TODO change from webview to shopify sheet poc using this code
        // final result = await Navigator.of(context).push<bool>(
        //   MaterialPageRoute(
        //     builder: (_) => CheckoutWebViewScreen(
        //       checkoutUrl: s.checkoutUrl,
        //       onSuccess: () {
        //         // ✅ clear cart immediately when thank_you is detected
        //         context.read<CartBloc>().add(const CartCheckoutCompleted());
        //       },
        //     ),
        //   ),
        // );

        // If user closed the WebView (result == false/null), you might want to refresh:
        // if (context.mounted) {
        //   context.read<CartBloc>().add(const CartRefresh());
        // }
        _sheet.launchCheckout(s.checkoutUrl);
        debugPrint("🧾 Checkout URL (UTM): $checkoutUrlWithUtm");
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text('Cart', textScaler: TextScaler.linear(r.textScale)),
          actions: [
            IconButton(
              onPressed: () => context.read<CartBloc>().add(const CartRefresh()),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            if (state is CartLoading || state is CartInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CartError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(r.gutter),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.message, textAlign: TextAlign.center),
                      SizedBox(height: r.s3),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<CartBloc>().add(const CartEnsureStarted()),
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ✅ IMPORTANT: because listener state is CartCheckoutReady, builder must handle it too.
            // easiest: treat it like CartLoaded (it contains cart)
            late final sf.Cart cart;
            if (state is CartLoaded) {
              cart = state.cart;
            } else if (state is CartCheckoutReady) {
              cart = state.cart;
            } else {
              // fallback safety
              return const SizedBox.shrink();
            }

            final lines = cart.lines;

            if (lines.isEmpty) {
              return Center(
                child: Text(
                  'Your cart is empty.',
                  textScaler: TextScaler.linear(r.textScale),
                ),
              );
            }

            final subtotal = _moneyAmount(cart.cost?.subtotalAmount);
            final total = _moneyAmount(cart.cost?.totalAmount);
            final itemCount = lines.length + 1;

            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(r.gutter, r.s3, r.gutter, r.s3),
                    itemCount: itemCount,
                    separatorBuilder: (_, __) => SizedBox(height: r.s3),
                    itemBuilder: (context, index) {
                      if (index == lines.length) return _CartInfoBox(r: r);

                      final line = lines[index];
                      return _CartLineTile(
                        line: line,
                        onTap: () {
                          final productId = _lineProductId(line);
                          if (productId == null) return;
                          context.push('/product/${Uri.encodeComponent(productId)}');
                        },
                        onRemove: () {
                          final id = line.id;
                          if (id == null) return;
                          context.read<CartBloc>().add(CartRemoveLine(lineId: id));
                        },
                        onMinus: () {
                          final q = (line.quantity ?? 1) - 1;
                          if (q < 1) return;
                          final id = line.id;
                          final merchId = _lineMerchandiseId(line);
                          if (id == null || merchId == null) return;
                          context.read<CartBloc>().add(
                            CartUpdateLineQty(
                              lineId: id,
                              quantity: q,
                              merchandiseId: merchId,
                            ),
                          );
                        },
                        onPlus: () {
                          final q = (line.quantity ?? 1) + 1;
                          final id = line.id;
                          final merchId = _lineMerchandiseId(line);
                          if (id == null || merchId == null) return;
                          context.read<CartBloc>().add(
                            CartUpdateLineQty(
                              lineId: id,
                              quantity: q,
                              merchandiseId: merchId,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(r.gutter, 0, r.gutter, r.s2),
                    child: Column(
                      children: [
                        _TotalsRow(label: 'Subtotal', value: _formatMoney(subtotal)),
                        SizedBox(height: r.s1),
                        _TotalsRow(label: 'Total', value: _formatMoney(total), isBold: true),
                        SizedBox(height: r.s2),
                        _CheckoutButton(
                          text: l10n.checkout,
                          height: (r.w * 0.13).clamp(48.0, 56.0),
                          onTap: () => context.read<CartBloc>().add(const CartCheckoutRequested()),
                        ),
                        SizedBox(height: r.s1),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  double _moneyAmount(dynamic moneyV2) {
    if (moneyV2 == null) return 0;
    try {
      final d = moneyV2 as dynamic;
      final a = d.amount?.toString() ?? '0';
      return double.tryParse(a) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  String _formatMoney(double v) => '\$${v.toStringAsFixed(2)}';
}

class _CartLineTile extends StatelessWidget {
  const _CartLineTile({
    required this.line,
    required this.onRemove,
    required this.onMinus,
    required this.onPlus,
    required this.onTap,
  });

  final sf.Line line;
  final VoidCallback onRemove;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = context.r;

    final title = _safeTitle(line);
    final variantText = _safeVariantText(line);

    final qty = line.quantity ?? 1;
    final price = _lineTotal(line);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LineImage(line: line),
          SizedBox(width: r.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Remove (X)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(top: r.s1),
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textScaler: TextScaler.linear(r.textScale),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onRemove,
                      icon: const Icon(Icons.close),
                      splashRadius: 18,
                      tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                    ),
                  ],
                ),

                // Variant text (Color/Size) - hides Default Title
                if (variantText.isNotEmpty)
                  Padding(
                    padding: EdgeInsetsDirectional.only(top: r.s1),
                    child: Text(
                      variantText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textScaler: TextScaler.linear(r.textScale),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black.withOpacity(.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                SizedBox(height: r.s2),

                // Qty pill + Price
                Row(
                  children: [
                    _QtyPill(qty: qty, onMinus: onMinus, onPlus: onPlus),
                    const Spacer(),
                    Text(
                      '\$${price.toStringAsFixed(2)}',
                      textScaler: TextScaler.linear(r.textScale),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: r.s2),

                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.black.withOpacity(.08),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _safeTitle(sf.Line line) {
    try {
      final merch = line.merchandise as dynamic;
      final product = merch.product as dynamic;
      final t = (product.title ?? '').toString().trim();
      return t.isEmpty ? 'Item' : t;
    } catch (_) {
      return 'Item';
    }
  }

  String _safeVariantText(sf.Line line) {
    try {
      final merch = line.merchandise as dynamic;

      final opts = merch.selectedOptions as List?;
      if (opts != null && opts.isNotEmpty) {
        final interesting = <String>[];
        final all = <String>[];

        for (final o in opts) {
          final name = (o.name ?? '').toString().toLowerCase();
          final value = (o.value ?? '').toString().trim();
          if (value.isEmpty) continue;

          all.add(value);

          final isInteresting =
              name.contains('color') || name.contains('colour') || name.contains('size');
          if (isInteresting) interesting.add(value);
        }

        final picked = interesting.isNotEmpty ? interesting : all;

        final filtered = picked
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty && e.toLowerCase() != 'default title')
            .toList();

        return filtered.join(' / ');
      }

      final t = (merch.title ?? '').toString().trim();
      if (t.isEmpty) return '';
      if (t.toLowerCase() == 'default title') return '';
      return t;
    } catch (_) {
      return '';
    }
  }

  double _lineTotal(sf.Line line) {
    try {
      final d = line as dynamic;

      // Newer: line.cost.totalAmount.amount
      final cost = d.cost;
      final totalAmount = cost?.totalAmount;
      final amountStr = totalAmount?.amount?.toString();
      final v = double.tryParse(amountStr ?? '');
      if (v != null) return v;

      // Some versions: line.estimatedCost.totalAmount.amount
      final est = d.estimatedCost;
      final estTotal = est?.totalAmount;
      final estStr = estTotal?.amount?.toString();
      final ev = double.tryParse(estStr ?? '');
      if (ev != null) return ev;

      // Fallback: unit * qty
      final qty = (d.quantity as int?) ?? 1;
      final merch = d.merchandise;
      final price = merch?.price;
      final unitStr = price?.amount?.toString();
      final unit = double.tryParse(unitStr ?? '') ?? 0;
      return unit * qty;
    } catch (_) {
      return 0;
    }
  }
}

String? _lineMerchandiseId(sf.Line line) {
  try {
    final d = line.merchandise as dynamic;
    final id = d.id?.toString();
    return (id == null || id.isEmpty) ? null : id;
  } catch (_) {
    return null;
  }
}


String? _lineProductId(sf.Line line) {
  try {
    final merch = line.merchandise as dynamic;
    final product = merch.product as dynamic;
    final id = product.id?.toString();
    return (id == null || id.isEmpty) ? null : id;
  } catch (_) {
    return null;
  }
}

class _LineImage extends StatelessWidget {
  const _LineImage({required this.line});
  final sf.Line line;

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    final size = (r.w * 0.18).clamp(72.0, 92.0);

    ImageProvider img = const AssetImage('assets/demo/product_sneakers.jpg');

    try {
      final d = line.merchandise as dynamic;
      final image = d.image;
      final url = (image?.originalSrc ?? image?.src ?? image?.url)?.toString();
      if (url != null && url.isNotEmpty) img = NetworkImage(url);
    } catch (_) {}

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: size,
        height: size,
        child: Image(
          image: img,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(
            'assets/demo/product_sneakers.jpg',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _QtyPill extends StatelessWidget {
  const _QtyPill({
    required this.qty,
    required this.onMinus,
    required this.onPlus,
  });

  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    final h = (r.w * 0.11).clamp(40.0, 50.0);

    return Container(
      height: h,
      padding: EdgeInsets.symmetric(horizontal: r.s2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.04),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onMinus,
            icon: const Icon(Icons.remove),
            splashRadius: 18,
          ),
          SizedBox(width: r.s1),
          Text(
            '$qty',
            textScaler: TextScaler.linear(r.textScale),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(width: r.s1),
          IconButton(
            onPressed: onPlus,
            icon: const Icon(Icons.add),
            splashRadius: 18,
          ),
        ],
      ),
    );
  }
}

class _TotalsRow extends StatelessWidget {
  const _TotalsRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
    );

    return Row(
      children: [
        Text(label, style: style),
        const Spacer(),
        Text(value, style: style),
      ],
    );
  }
}

class _CheckoutButton extends StatelessWidget {
  const _CheckoutButton({
    required this.text,
    required this.onTap,
    required this.height,
  });

  final String text;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final r = context.r;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Material(
        color: const Color(0xFF2F4B3A),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Center(
            child: Text(
              text,
              textScaler: TextScaler.linear(r.textScale),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CartInfoBox extends StatelessWidget {
  const _CartInfoBox({required this.r});
  final Responsive r;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(r.s3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.04),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline),
          SizedBox(width: r.s2),
          Expanded(
            child: Text(
              "Checkout redirects to Shopify's secure web checkout.",
              textScaler: TextScaler.linear(r.textScale),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black.withOpacity(.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}