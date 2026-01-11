import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shopify_flutter/shopify_flutter.dart' as sf;

import '../../../../core/di/injection_container.dart';
import '../../../../features/catalogue/bloc/cart/cart_bloc.dart';
import '../../../../features/catalogue/bloc/cart/cart_event.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../utility/utility.dart';
import '../../../layout/responsive.dart';
import '../../../../core/shopify/shopify_facade.dart';


class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({
    super.key,
    required this.productId,
    this.product,
  });

  final String productId;
  final sf.Product? product;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late Future<_ProductDetailsVM> _future;

  int _imageIndex = 0;
  bool _wishlisted = false;

  String _selectedColor = 'White';
  String _selectedSize = 'US 9';
  int _qty = 1;
  bool _didInitSelections = false;

  Future<_ProductDetailsVM> _loadProduct() async {
    // ✅ If we navigated from cart/list, we already have it
    final provided = widget.product;
    if (provided != null) {
      return _detailsVmFromShopify(provided);
    }

    // ✅ Deep link fallback
    final sfProduct =
    await sl<ShopifyFacade>().fetchProductById(widget.productId);
    return _detailsVmFromShopify(sfProduct);
  }

  @override
  void initState() {
    super.initState();
    _future = _loadProduct();
  }

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<_ProductDetailsVM>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(r.gutter),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Failed to load product:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: r.s3),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        _didInitSelections = false;
                        _future = _loadProduct(); // ✅ actually retries
                      }),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final product = snapshot.data!;
        // ✅ DON'T reset selections on every rebuild.
        // Do it once after product is loaded.
        if (!_didInitSelections) {
          _selectedColor =
          product.colors.isNotEmpty ? product.colors.first.name : _selectedColor;
          _selectedSize =
          product.sizes.isNotEmpty ? product.sizes.first : _selectedSize;
          _didInitSelections = true;
        }

        final total = product.price * _qty;
        final totalText = '\$${total.toStringAsFixed(2)}';
        final addToCartText = l10n.productAddToCartTotal(l10n.productAddToCart, totalText);

        final expandedH = (r.h * 0.42).clamp(240.0, 420.0);
        final collapsedH = (r.h * 0.16).clamp(110.0, 140.0);

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(r.gutter, r.s2, r.gutter, r.s2),
              child: _AddToCartButton(
                text: addToCartText,
                onTap: () {
                  final variantId = _resolveVariantId(
                    product.raw,
                    selectedColor: _selectedColor,
                    selectedSize: _selectedSize,
                  );

                  context.read<CartBloc>().add(
                    CartAddVariant(variantId: variantId, quantity: _qty),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.productAddedToCart(_qty))),
                  );

                  context.go('/cart');
                },
                height: (r.w * 0.13).clamp(48.0, 56.0),
              ),
            ),
          ),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                stretch: true,
                elevation: 0,
                backgroundColor: theme.scaffoldBackgroundColor,
                collapsedHeight: collapsedH,
                leading: IconButton(
                  onPressed: () {
                    if (GoRouter.of(context).canPop()) {
                      context.pop();
                    } else {
                      context.go('/products');
                    }
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                actions: [
                  _CircleAction(
                    icon: _wishlisted ? Icons.favorite : Icons.favorite_border,
                    onTap: () => setState(() => _wishlisted = !_wishlisted),
                  ),
                  SizedBox(width: r.s2),
                  _CircleAction(
                    icon: Icons.share,
                    onTap: () async {
                      final link = _buildDeepLink(productId: widget.productId);
                      await Share.share(link);
                    },
                  ),
                  SizedBox(width: r.gutter),
                ],
                expandedHeight: expandedH,
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxH = expandedH;
                    final minH = collapsedH;
                    final currentH = constraints.maxHeight;
                    final collapseT = ((maxH - currentH) / (maxH - minH)).clamp(0.0, 1.0);

                    return FlexibleSpaceBar(
                      background: _HeaderImages(
                        images: product.images.isEmpty
                            ? const [AssetImage('assets/demo/product_sneakers.jpg')]
                            : product.images,
                        index: _imageIndex.clamp(0, (product.images.length - 1).clamp(0, 999)),
                        onIndexChanged: (i) => setState(() => _imageIndex = i),
                        collapseT: collapseT,
                        showSale: product.compareAt != null && product.compareAt! > product.price,
                        saleText: l10n.productSale,
                      ),
                    );
                  },
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(r.gutter, r.s3, r.gutter, r.s4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        textScaler: TextScaler.linear(r.textScale),
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: r.s2),

                      Row(
                        children: [
                          Text(
                            '\$${product.price.toStringAsFixed(0)}',
                            textScaler: TextScaler.linear(r.textScale),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFD1493F),
                            ),
                          ),
                          SizedBox(width: r.s2),
                          if (product.compareAt != null && product.compareAt! > product.price)
                            Text(
                              '\$${product.compareAt!.toStringAsFixed(0)}',
                              textScaler: TextScaler.linear(r.textScale),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.black.withOpacity(.45),
                                decoration: TextDecoration.lineThrough,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      ),

                      SizedBox(height: r.s4),

                      _TitleRow(left: l10n.productColor, right: _selectedColor),
                      SizedBox(height: r.s2),
                      _ColorDots(
                        colors: product.colors,
                        selectedName: _selectedColor,
                        onSelected: (name) => setState(() => _selectedColor = name),
                      ),

                      SizedBox(height: r.s4),

                      _TitleRow(left: l10n.productSize, right: _selectedSize),
                      SizedBox(height: r.s2),
                      _SizeChips(
                        sizes: product.sizes,
                        selected: _selectedSize,
                        onSelected: (s) => setState(() => _selectedSize = s),
                      ),

                      SizedBox(height: r.s4),

                      Text(
                        l10n.productQuantity,
                        textScaler: TextScaler.linear(r.textScale),
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: r.s2),
                      _QtyStepper(
                        value: _qty,
                        onMinus: _qty > 1 ? () => setState(() => _qty--) : null,
                        onPlus: () => setState(() => _qty++),
                      ),

                      SizedBox(height: r.s4),

                      Text(
                        l10n.productDescription,
                        textScaler: TextScaler.linear(r.textScale),
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: r.s2),
                      Text(
                        product.description,
                        textScaler: TextScaler.linear(r.textScale),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.45,
                          color: Colors.black.withOpacity(.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: r.s5),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _buildDeepLink({required String productId}) {
    // This is the ONLY link format that we know works with your DeepLinkService normalization:
    // shopifyme://product/<id>  -> /product/<id>
    final scheme = Uri(
      scheme: 'shopifyme',
      host: 'product',
      path: '/${Uri.encodeComponent(productId)}',
    ).toString();

    // Optional: only include universal link if you actually have app/universal links domain configured.
    // If you don't have it, don't share it (it will just open browser).
    //
    // final universal = Uri(
    //   scheme: 'https',
    //   host: 'YOUR_APP_LINKS_DOMAIN_HERE', // e.g. app.yourbrand.com
    //   path: '/product/$productId',
    // ).toString();

    return scheme; // or '$scheme\n$universal' if universal is real
  }
}

// --------------------------- HEADER (expands + collapses with mini image) ---------------------------

class _HeaderImages extends StatelessWidget {
  const _HeaderImages({
    required this.images,
    required this.index,
    required this.onIndexChanged,
    required this.collapseT,
    required this.showSale,
    required this.saleText,
  });

  final List<ImageProvider> images;
  final int index;
  final ValueChanged<int> onIndexChanged;
  final double collapseT; // 0 expanded, 1 collapsed
  final bool showSale;
  final String saleText;

  @override
  Widget build(BuildContext context) {
    final r = context.r;

    // when collapsed, we still show a small slice at the bottom
    final miniH = (r.h * 0.10).clamp(70.0, 90.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Full carousel in expanded state
        Opacity(
          opacity: (1.0 - collapseT).clamp(0.0, 1.0),
          child: _FullCarousel(
            images: images,
            index: index,
            onIndexChanged: onIndexChanged,
            showSale: showSale,
            saleText: saleText,
          ),
        ),

        // Mini preview in collapsed state
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: miniH,
            child: Opacity(
              opacity: (collapseT).clamp(0.0, 1.0),
              child: _CollapsedMiniStrip(
                image: images[index.clamp(0, images.length - 1)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FullCarousel extends StatelessWidget {
  const _FullCarousel({
    required this.images,
    required this.index,
    required this.onIndexChanged,
    required this.showSale,
    required this.saleText,
  });

  final List<ImageProvider> images;
  final int index;
  final ValueChanged<int> onIndexChanged;
  final bool showSale;
  final String saleText;

  @override
  Widget build(BuildContext context) {
    final r = context.r;

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: images.length,
          onPageChanged: onIndexChanged,
          itemBuilder: (context, i) {
            return Image(
              image: images[i],
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
            );
          },
        ),

        if (showSale)
          PositionedDirectional(
            start: r.gutter,
            top: (r.s4 + 10).clamp(18.0, 44.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: r.s3, vertical: r.s1),
              decoration: BoxDecoration(
                color: const Color(0xFFD1493F),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                saleText,
                textScaler: TextScaler.linear(r.textScale),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

        PositionedDirectional(
          bottom: r.s2,
          start: 0,
          end: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (i) {
              final selected = i == index;
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: selected ? Colors.black : Colors.black.withOpacity(.22),
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _CollapsedMiniStrip extends StatelessWidget {
  const _CollapsedMiniStrip({required this.image});
  final ImageProvider image;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Colors.white),
      child: ClipRect(
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: 0.55, // show a “slice” of the image
          child: Image(
            image: image,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
            width: double.infinity,
          ),
        ),
      ),
    );
  }
}

// --------------------------- UI pieces ---------------------------

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    final size = (r.w * 0.11).clamp(40.0, 48.0);

    return Padding(
      padding: EdgeInsetsDirectional.only(end: r.s2),
      child: SizedBox(
        width: size,
        height: size,
        child: Material(
          color: Colors.white,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Icon(icon, size: 22, color: Colors.black),
          ),
        ),
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.left, required this.right});
  final String left;
  final String right;

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    final theme = Theme.of(context);

    return Row(
      children: [
        Text(
          left,
          textScaler: TextScaler.linear(r.textScale),
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const Spacer(),
        Text(
          right,
          textScaler: TextScaler.linear(r.textScale),
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.black.withOpacity(.55),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ColorDots extends StatelessWidget {
  const _ColorDots({
    required this.colors,
    required this.selectedName,
    required this.onSelected,
  });

  final List<_ColorOption> colors;
  final String selectedName;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    final outer = (r.w * 0.09).clamp(36.0, 46.0);
    final inner = (r.w * 0.07).clamp(28.0, 38.0);

    return Row(
      children: colors.map((c) {
        final selected = c.name == selectedName;

        return Padding(
          padding: EdgeInsetsDirectional.only(end: r.s2),
          child: InkWell(
            onTap: () => onSelected(c.name),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: outer,
              height: outer,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 2.5,
                  color: selected ? const Color(0xFF2F4B3A) : Colors.transparent,
                ),
              ),
              child: Center(
                child: Container(
                  width: inner,
                  height: inner,
                  decoration: BoxDecoration(
                    color: c.color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black.withOpacity(.08),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SizeChips extends StatelessWidget {
  const _SizeChips({
    required this.sizes,
    required this.selected,
    required this.onSelected,
  });

  final List<String> sizes;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final r = context.r;

    return Wrap(
      spacing: r.s2,
      runSpacing: r.s2,
      children: sizes.map((s) {
        final isSel = s == selected;

        return InkWell(
          onTap: () => onSelected(s),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: r.s4, vertical: r.s2),
            decoration: BoxDecoration(
              color: isSel ? const Color(0xFF2F4B3A) : Colors.black.withOpacity(.04),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              s,
              textScaler: TextScaler.linear(r.textScale),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: isSel ? Colors.white : Colors.black.withOpacity(.85),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final int value;
  final VoidCallback? onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    final h = (r.w * 0.12).clamp(44.0, 54.0);

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
            splashRadius: 20,
          ),
          SizedBox(width: r.s2),
          Text(
            '$value',
            textScaler: TextScaler.linear(r.textScale),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(width: r.s2),
          IconButton(
            onPressed: onPlus,
            icon: const Icon(Icons.add),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}

class _AddToCartButton extends StatelessWidget {
  const _AddToCartButton({
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

// --------------------------- TEMP demo data ---------------------------

class _ProductDetailsVM {
  final sf.Product raw;
  final String id;
  final String title;
  final double price;
  final double? compareAt;
  final String description;
  final List<ImageProvider> images;
  final List<_ColorOption> colors;
  final List<String> sizes;

  const _ProductDetailsVM({
    required this.raw,
    required this.id,
    required this.title,
    required this.price,
    required this.compareAt,
    required this.description,
    required this.images,
    required this.colors,
    required this.sizes,
  });
}

class _ColorOption {
  final String name;
  final Color color;
  const _ColorOption(this.name, this.color);
}

_ProductDetailsVM _detailsVmFromShopify(sf.Product p) {
  final title = (p.title ?? '').toString().trim();
  final safeTitle = title.isEmpty ? 'Untitled' : title;

  // descriptionHtml sometimes exists; keep it simple as plain string
  final desc = (p.description ?? '').toString().trim();
  final safeDesc = desc.isEmpty ? 'No description.' : desc;

  // price/compareAt from first variant
  double price = 0;
  double? compareAt;
  try {
    final variants = (p.productVariants ?? const []);
    if (variants.isNotEmpty) {
      final v0 = variants.first;
      price = moneyToDouble(v0.price);
      final c = moneyToDouble(v0.compareAtPrice);
      if (c > price) compareAt = c;
    }
  } catch (_) {}

  // images
  final urls = _tryGetAllImageUrls(p);
  final images = urls.isNotEmpty
      ? urls.map((u) => NetworkImage(u) as ImageProvider).toList(growable: false)
      : const <ImageProvider>[AssetImage('assets/demo/product_sneakers.jpg')];

  // options -> colors & sizes (best-effort)
  final options = _tryGetOptions(p);

  final colors = _extractOptionValues(options, keys: const ['color', 'colour'])
      .map((name) => _ColorOption(name, _colorFromName(name)))
      .toList(growable: false);

  final sizes = _extractOptionValues(options, keys: const ['size'])
      .toList(growable: false);

  // safe fallbacks so your UI doesn't break
  final safeColors = colors.isNotEmpty ? colors : const <_ColorOption>[
    _ColorOption('Default', Color(0xFFF4F4F4)),
  ];
  final safeSizes = sizes.isNotEmpty ? sizes : const <String>['Default'];

  return _ProductDetailsVM(
    raw: p,
    id: p.id.toString(),
    title: safeTitle,
    price: price,
    compareAt: compareAt,
    description: safeDesc,
    images: images,
    colors: safeColors,
    sizes: safeSizes,
  );
}

List<String> _tryGetAllImageUrls(sf.Product p) {
  try {
    final d = p as dynamic;

    final images = d.images;
    if (images != null && images.isNotEmpty) {
      return List<String>.from(
        images.map((img) => (img.originalSrc ?? img.src ?? img.url).toString()),
      ).where((e) => e.isNotEmpty).toList();
    }

    // sometimes single image
    final img = d.image;
    if (img != null) {
      final url = (img.originalSrc ?? img.src ?? img.url)?.toString() ?? '';
      if (url.isNotEmpty) return [url];
    }
  } catch (_) {}

  return const <String>[];
}

/// Returns a list of maps like: [{name: "Color", values: ["Red","Blue"]}, ...]
List<Map<String, dynamic>> _tryGetOptions(sf.Product p) {
  try {
    final d = p as dynamic;
    final opts = d.options;
    if (opts != null && opts.isNotEmpty) {
      return List<Map<String, dynamic>>.from(
        opts.map((o) => {
          'name': (o.name ?? '').toString(),
          'values': (o.values ?? const []).map((v) => v.toString()).toList(),
        }),
      );
    }
  } catch (_) {}

  return const <Map<String, dynamic>>[];
}

Iterable<String> _extractOptionValues(
    List<Map<String, dynamic>> options, {
      required List<String> keys,
    }) sync* {
  for (final o in options) {
    final name = (o['name'] ?? '').toString().toLowerCase();
    if (keys.any((k) => name.contains(k))) {
      final values = o['values'];
      if (values is List) {
        for (final v in values) {
          final s = v.toString().trim();
          if (s.isNotEmpty) yield s;
        }
      }
    }
  }
}

/// Simple color guesser (good enough for UI dots)
Color _colorFromName(String name) {
  final n = name.toLowerCase();
  if (n.contains('black')) return const Color(0xFF0E1525);
  if (n.contains('white')) return const Color(0xFFF4F4F4);
  if (n.contains('gray') || n.contains('grey')) return const Color(0xFF9AA3AF);
  if (n.contains('blue')) return const Color(0xFF213A8F);
  if (n.contains('green')) return const Color(0xFF2F4B3A);
  if (n.contains('red')) return const Color(0xFFD1493F);
  if (n.contains('brown')) return const Color(0xFF7B4F2A);
  return const Color(0xFFCCCCCC);
}


// _ProductDetailsVM _demoProductById(String id) {
//   const img = AssetImage('assets/demo/product_sneakers.jpg');
//
//   return _ProductDetailsVM(
//     id: id,
//     title: 'Classic White Sneakers',
//     price: 129,
//     compareAt: 159,
//     description:
//     'Premium leather sneakers with a minimalist design. Features a cushioned insole for all-day comfort.',
//     images: const [img, img, img],
//     colors: const [
//       _ColorOption('White', Color(0xFFF4F4F4)),
//       _ColorOption('Black', Color(0xFF0E1525)),
//       _ColorOption('Gray', Color(0xFF9AA3AF)),
//       _ColorOption('Blue', Color(0xFF213A8F)),
//     ],
//     sizes: const ['US 7', 'US 8', 'US 9', 'US 10', 'US 11'],
//   );
// }

String _resolveVariantId(
    sf.Product product, {
      required String selectedColor,
      required String selectedSize,
    }) {
  final variants = product.productVariants ?? const [];
  if (variants.isEmpty) throw Exception('Product has no variants.');

  // Best-effort match: variant.selectedOptions contains names/values
  for (final v in variants) {
    try {
      final d = v as dynamic;
      final opts = d.selectedOptions as List?;
      if (opts == null) continue;

      bool matchesColor = true;
      bool matchesSize = true;

      for (final o in opts) {
        final name = (o.name ?? '').toString().toLowerCase();
        final value = (o.value ?? '').toString();

        if (name.contains('color') || name.contains('colour')) {
          matchesColor = (value == selectedColor);
        }
        if (name.contains('size')) {
          matchesSize = (value == selectedSize);
        }
      }

      if (matchesColor && matchesSize) {
        return v.id.toString();
      }
    } catch (_) {}
  }

  // Fallback: first variant
  return variants.first.id.toString();
}

