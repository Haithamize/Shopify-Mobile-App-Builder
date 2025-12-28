import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/merchant_config.dart';
import '../../../core/di/injection_container.dart';
import '../../../l10n/app_localizations.dart';
import '../../layout/responsive.dart';

/// AllProductsScreen:
/// - Matches kit: top bar (back + title + filter/sort icons)
/// - Filter chips row (All/On Sale/New/Popular)
/// - Product grid with badges + wishlist + quick add
/// - Filtering + sorting logic is implemented (local demo data)
///
/// White-label:
/// - feature flags can hide wishlist, quick add, etc.
/// - later swap demo list -> Shopify results without changing the UI structure
///
/// Deeplink/push:
/// - make route /products
/// - optional query params: ?filter=all|sale|new|popular&sort=price_asc|price_desc|newest|popular
class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Demo source list (replace with API later)
  late final List<_ProductVM> _all = List<_ProductVM>.unmodifiable(_demoProducts);

  _ProductsFilter _filter = _ProductsFilter.all;
  _ProductsSort _sort = _ProductsSort.none;

  // Optional: keep wishlist state local for demo
  final Set<String> _wishlisted = <String>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Deeplink support via query params:
    // /products?filter=new&sort=price_asc
    final uri = GoRouterState.of(context).uri;

    final f = uri.queryParameters['filter'];
    final s = uri.queryParameters['sort'];

    final parsedFilter = _ProductsFilterX.fromQuery(f);
    final parsedSort = _ProductsSortX.fromQuery(s);

    // Only update if different to avoid rebuild loops
    if (parsedFilter != _filter || parsedSort != _sort) {
      setState(() {
        _filter = parsedFilter;
        _sort = parsedSort;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final r = context.r;
    final l10n = AppLocalizations.of(context)!;
    final config = sl<MerchantConfig>();
    final flags = config.features;

    final cols = r.columns(minTileWidth: 190, min: 2, max: 4);

    final visible = _applyFilterAndSort(_all, _filter, _sort);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        cacheExtent: (r.h * 1.2).clamp(600.0, 1200.0),
        slivers: [
          // ---------------------------------------------------------------
          // Top bar (pinned)
          // ---------------------------------------------------------------
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            toolbarHeight: (r.w * 0.14).clamp(56.0, 68.0),
            leading: IconButton(
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () {
                // Pop if this screen was pushed. If it was opened via `go()`, there’s nothing to pop.
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                  return;
                }

                // GoRouter stack might still be able to pop in some nested navigators
                if (GoRouter.of(context).canPop()) {
                  context.pop();
                  return;
                }

                // Fallback: go to a safe place (adjust to your real root route)
                context.go('/home'); // or '/home' or your tab route
              },
              icon: const Icon(Icons.arrow_back),
            ),
            centerTitle: true,
            title: Text(
              l10n.productsAllTitle,
              textScaler: TextScaler.linear(r.textScale),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              IconButton(
                tooltip: l10n.productsFilter,
                onPressed: () {
                  _syncQueryParams();
                  _openFilterSheet(context);
                },
                icon: const Icon(Icons.tune),
              ),
              IconButton(
                tooltip: l10n.productsSort,
                onPressed: () => _openSortSheet(context),
                icon: const Icon(Icons.swap_vert),
              ),
              SizedBox(width: r.gutter / 2),
            ],
          ),

          // ---------------------------------------------------------------
          // Filter chips row (pinned-like section under app bar)
          // ---------------------------------------------------------------
          SliverPadding(
            padding: EdgeInsets.only(top: r.s2),
            sliver: SliverToBoxAdapter(
              child: _FilterChipsRow(
                selected: _filter,
                onSelected: (f) {
                  if (f == _filter) return;
                  setState(() => _filter = f);
                  _syncQueryParams(); // <-- keep URL in sync so it won't snap back
                },
              ),
            ),
          ),

          // ---------------------------------------------------------------
          // Count label
          // ---------------------------------------------------------------
          SliverPadding(
            padding: EdgeInsets.only(top: r.s3),
            sliver: SliverToBoxAdapter(
              child: Align(
                alignment: AlignmentDirectional.centerEnd, // keeps it on the right in RTL
                child: Padding(
                  padding: EdgeInsetsDirectional.only(end: r.gutter), // optional small inset
                  child: Text(
                    l10n.productsCount(visible.length),
                    textScaler: TextScaler.linear(r.textScale),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.black.withOpacity(.55),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ---------------------------------------------------------------
          // Products grid
          // ---------------------------------------------------------------
          SliverPadding(
            padding: EdgeInsets.fromLTRB(r.gutter, r.s3, r.gutter, r.s4),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: r.s2,
                crossAxisSpacing: r.s2,
                childAspectRatio: r.productAspect, // from your responsive tokens
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final p = visible[index];
                  final isWish = _wishlisted.contains(p.id);

                  return _ProductTile(
                    product: p,
                    enableWishlist: flags.enableWishlist, // white-label
                    isWishlisted: isWish,
                    onToggleWishlist: flags.enableWishlist
                        ? () {
                      setState(() {
                        if (isWish) {
                          _wishlisted.remove(p.id);
                        } else {
                          _wishlisted.add(p.id);
                        }
                      });
                    }
                        : null,
                    onQuickAdd: () {
                      // In future: add to cart service + toast
                      // Keep as a stub for now.
                    },
                    onTap: () => context.go('/product/${p.id}'), // deeplink-compatible
                  );
                },
                childCount: visible.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sheets: Filter & Sort
  // ---------------------------------------------------------------------------

  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx)!;
        return _BottomSheetList(
          title: l10n.productsFilter,
          children: [
            _SheetOption(
              title: l10n.productsFilterAll,
              selected: _filter == _ProductsFilter.all,
              onTap: () => _setFilterAndClose(ctx, _ProductsFilter.all),
            ),
            _SheetOption(
              title: l10n.productsFilterOnSale,
              selected: _filter == _ProductsFilter.sale,
              onTap: () => _setFilterAndClose(ctx, _ProductsFilter.sale),
            ),
            _SheetOption(
              title: l10n.productsFilterNew,
              selected: _filter == _ProductsFilter.newest,
              onTap: () => _setFilterAndClose(ctx, _ProductsFilter.newest),
            ),
            _SheetOption(
              title: l10n.productsFilterPopular,
              selected: _filter == _ProductsFilter.popular,
              onTap: () => _setFilterAndClose(ctx, _ProductsFilter.popular),
            ),
          ],
        );
      },
    );
  }

  void _openSortSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx)!;
        return _BottomSheetList(
          title: l10n.productsSort,
          children: [
            _SheetOption(
              title: l10n.productsSortPriceLowHigh,
              selected: _sort == _ProductsSort.priceAsc,
              onTap: () => _setSortAndClose(ctx, _ProductsSort.priceAsc),
            ),
            _SheetOption(
              title: l10n.productsSortPriceHighLow,
              selected: _sort == _ProductsSort.priceDesc,
              onTap: () => _setSortAndClose(ctx, _ProductsSort.priceDesc),
            ),
            _SheetOption(
              title: l10n.productsSortNewest,
              selected: _sort == _ProductsSort.newest,
              onTap: () => _setSortAndClose(ctx, _ProductsSort.newest),
            ),
            _SheetOption(
              title: l10n.productsSortPopular,
              selected: _sort == _ProductsSort.popular,
              onTap: () => _setSortAndClose(ctx, _ProductsSort.popular),
            ),
          ],
        );
      },
    );
  }

  void _setFilterAndClose(BuildContext context, _ProductsFilter f) {
    setState(() => _filter = f);
    Navigator.of(context).pop();
    _syncQueryParams();
  }

  void _setSortAndClose(BuildContext context, _ProductsSort s) {
    setState(() => _sort = s);
    Navigator.of(context).pop();
    _syncQueryParams();
  }

  /// Keep URL in sync (deeplink friendly).
  /// For tabs/shell routes, this still works with GoRouter.
  void _syncQueryParams() {
    final qp = <String, String>{};

    final f = _filter.toQuery();
    if (f != null) qp['filter'] = f;

    final s = _sort.toQuery();
    if (s != null) qp['sort'] = s;

    final uri = Uri(path: '/products', queryParameters: qp.isEmpty ? null : qp);
    context.go(uri.toString());
  }
}

// ============================================================================
// Filtering / Sorting
// ============================================================================

enum _ProductsFilter { all, sale, newest, popular }

extension _ProductsFilterX on _ProductsFilter {
  String? toQuery() {
    switch (this) {
      case _ProductsFilter.all:
        return 'all';
      case _ProductsFilter.sale:
        return 'sale';
      case _ProductsFilter.newest:
        return 'new';
      case _ProductsFilter.popular:
        return 'popular';
    }
  }

  static _ProductsFilter fromQuery(String? v) {
    switch (v) {
      case 'sale':
        return _ProductsFilter.sale;
      case 'new':
        return _ProductsFilter.newest;
      case 'popular':
        return _ProductsFilter.popular;
      case 'all':
      default:
        return _ProductsFilter.all;
    }
  }
}

enum _ProductsSort { none, priceAsc, priceDesc, newest, popular }

extension _ProductsSortX on _ProductsSort {
  String? toQuery() {
    switch (this) {
      case _ProductsSort.none:
        return null;
      case _ProductsSort.priceAsc:
        return 'price_asc';
      case _ProductsSort.priceDesc:
        return 'price_desc';
      case _ProductsSort.newest:
        return 'newest';
      case _ProductsSort.popular:
        return 'popular';
    }
  }

  static _ProductsSort fromQuery(String? v) {
    switch (v) {
      case 'price_asc':
        return _ProductsSort.priceAsc;
      case 'price_desc':
        return _ProductsSort.priceDesc;
      case 'newest':
        return _ProductsSort.newest;
      case 'popular':
        return _ProductsSort.popular;
      default:
        return _ProductsSort.none;
    }
  }
}

List<_ProductVM> _applyFilterAndSort(
    List<_ProductVM> source,
    _ProductsFilter filter,
    _ProductsSort sort,
    ) {
  Iterable<_ProductVM> items = source;

  switch (filter) {
    case _ProductsFilter.all:
      break;
    case _ProductsFilter.sale:
      items = items.where((p) => p.compareAt != null && p.compareAt! > p.price);
      break;
    case _ProductsFilter.newest:
      items = items.where((p) => p.isNew);
      break;
    case _ProductsFilter.popular:
      items = items.where((p) => p.popularityScore >= 70);
      break;
  }

  final list = items.toList(growable: false);

  int cmpNum(num a, num b) => a.compareTo(b);

  switch (sort) {
    case _ProductsSort.none:
      return list;
    case _ProductsSort.priceAsc:
      list.sort((a, b) => cmpNum(a.price, b.price));
      return list;
    case _ProductsSort.priceDesc:
      list.sort((a, b) => cmpNum(b.price, a.price));
      return list;
    case _ProductsSort.newest:
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    case _ProductsSort.popular:
      list.sort((a, b) => b.popularityScore.compareTo(a.popularityScore));
      return list;
  }
}

// ============================================================================
// UI widgets
// ============================================================================

class _FilterChipsRow extends StatelessWidget {
  const _FilterChipsRow({required this.selected, required this.onSelected});

  final _ProductsFilter selected;
  final ValueChanged<_ProductsFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsetsDirectional.only(start: r.gutter, end: r.gutter), // small safe inset
      child: Row(
        children: [
          _Chip(
            label: l10n.productsFilterAll,
            selected: selected == _ProductsFilter.all,
            onTap: () => onSelected(_ProductsFilter.all),
          ),
          SizedBox(width: r.s2),
          _Chip(
            label: l10n.productsFilterOnSale,
            selected: selected == _ProductsFilter.sale,
            onTap: () => onSelected(_ProductsFilter.sale),
          ),
          SizedBox(width: r.s2),
          _Chip(
            label: l10n.productsFilterNew,
            selected: selected == _ProductsFilter.newest,
            onTap: () => onSelected(_ProductsFilter.newest),
          ),
          SizedBox(width: r.s2),
          _Chip(
            label: l10n.productsFilterPopular,
            selected: selected == _ProductsFilter.popular,
            onTap: () => onSelected(_ProductsFilter.popular),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = context.r;

    final bg = selected
        ? Theme.of(context).colorScheme.primary
        : Colors.black.withOpacity(0.04);

    final fg = selected ? Colors.white : Colors.black.withOpacity(0.8);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: r.s4, vertical: r.s2),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          textScaler: TextScaler.linear(r.textScale),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: fg,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.product,
    required this.enableWishlist,
    required this.isWishlisted,
    required this.onToggleWishlist,
    required this.onQuickAdd,
    required this.onTap,
  });

  final _ProductVM product;
  final bool enableWishlist;
  final bool isWishlisted;
  final VoidCallback? onToggleWishlist;
  final VoidCallback onQuickAdd;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    final l10n = AppLocalizations.of(context)!;

    final hasSale = product.compareAt != null && product.compareAt! > product.price;
    final badgeText = product.badgeText;
    final badgeColor = badgeText == 'NEW'
        ? const Color(0xFF4AAE9B)
        : const Color(0xFFD1493F);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(r.radiusLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(r.radiusLg),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image(image: product.image, fit: BoxFit.cover, filterQuality: FilterQuality.medium),

                  // Badge
                  PositionedDirectional(
                    start: r.s3,
                    top: r.s3,
                    child: _Badge(
                      text: badgeText,
                      color: badgeColor,
                    ),
                  ),

                  // Wishlist (optional by feature flag)
                  if (enableWishlist)
                    PositionedDirectional(
                      end: r.s3,
                      top: r.s3,
                      child: _CircleIconButton(
                        icon: isWishlisted ? Icons.favorite : Icons.favorite_border,
                        onTap: onToggleWishlist!,
                      ),
                    ),

                  // Quick add (only show on products that allow it; example: always true)
                  PositionedDirectional(
                    start: r.s3,
                    end: r.s3,
                    bottom: r.s3,
                    child: _QuickAddButton(
                      label: l10n.productsQuickAdd,
                      onTap: onQuickAdd,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: r.s2),

          Text(
            product.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textScaler: TextScaler.linear(r.textScale),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),

          SizedBox(height: r.s1),

          Row(
            children: [
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                textScaler: TextScaler.linear(r.textScale),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: hasSale ? const Color(0xFFD1493F) : Colors.black,
                ),
              ),
              SizedBox(width: r.s2),
              if (hasSale)
                Text(
                  '\$${product.compareAt!.toStringAsFixed(2)}',
                  textScaler: TextScaler.linear(r.textScale),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black.withOpacity(.45),
                    decoration: TextDecoration.lineThrough,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final r = context.r;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.s3, vertical: r.s2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        textScaler: TextScaler.linear(r.textScale),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon),
        ),
      ),
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  const _QuickAddButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = context.r;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: r.s4, vertical: r.s2),
          child: Center(
            child: Text(
              label,
              textScaler: TextScaler.linear(r.textScale),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomSheetList extends StatelessWidget {
  const _BottomSheetList({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final r = context.r;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(r.gutter, r.s2, r.gutter, r.s4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textScaler: TextScaler.linear(r.textScale),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: r.s2),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = context.r;

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        textScaler: TextScaler.linear(r.textScale),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      trailing: selected ? const Icon(Icons.check) : null,
    );
  }
}

// ============================================================================
// Demo model (replace with Storefront model later)
/// Keep this VM minimal and immutable for performance.
/// Later map from Shopify GraphQL Product -> VM.
class _ProductVM {
  const _ProductVM({
    required this.id,
    required this.title,
    required this.price,
    required this.compareAt,
    required this.isNew,
    required this.popularityScore,
    required this.image,
    required this.badgeText,
    required this.createdAt,
  });

  final String id;
  final String title;
  final double price;
  final double? compareAt;
  final bool isNew;
  final int popularityScore;
  final ImageProvider image;
  final String badgeText;
  final DateTime createdAt;
}

// Demo list
final _demoProducts = <_ProductVM>[
  _ProductVM(
    id: '1',
    title: 'Classic White Sneakers',
    price: 129,
    compareAt: 159,
    isNew: false,
    popularityScore: 80,
    image: const AssetImage('assets/demo/product_sneakers.jpg'),
    badgeText: '-19%',
    createdAt: DateTime(2025, 12, 10),
  ),
  _ProductVM(
    id: '2',
    title: 'Leather Tote Bag',
    price: 245,
    compareAt: null,
    isNew: true,
    popularityScore: 74,
    image: const AssetImage('assets/demo/product_bag.jpg'),
    badgeText: 'NEW',
    createdAt: DateTime(2025, 12, 20),
  ),
  _ProductVM(
    id: '3',
    title: 'Luxury Watch',
    price: 399,
    compareAt: 479,
    isNew: false,
    popularityScore: 90,
    image: const AssetImage('assets/demo/product_watch.jpg'),
    badgeText: '-17%',
    createdAt: DateTime(2025, 11, 18),
  ),
  _ProductVM(
    id: '4',
    title: 'Silk Shirt',
    price: 189,
    compareAt: null,
    isNew: true,
    popularityScore: 65,
    image: const AssetImage('assets/demo/product_shirt.jpg'),
    badgeText: 'NEW',
    createdAt: DateTime(2025, 12, 24),
  ),
  _ProductVM(
    id: '4',
    title: 'Silk Shirt',
    price: 189,
    compareAt: null,
    isNew: true,
    popularityScore: 65,
    image: const AssetImage('assets/demo/product_shirt.jpg'),
    badgeText: 'NEW',
    createdAt: DateTime(2025, 12, 24),
  ),
  _ProductVM(
    id: '4',
    title: 'Silk Shirt',
    price: 189,
    compareAt: null,
    isNew: true,
    popularityScore: 65,
    image: const AssetImage('assets/demo/product_shirt.jpg'),
    badgeText: 'NEW',
    createdAt: DateTime(2025, 12, 24),
  ),
  _ProductVM(
    id: '4',
    title: 'Silk Shirt',
    price: 189,
    compareAt: null,
    isNew: true,
    popularityScore: 65,
    image: const AssetImage('assets/demo/product_shirt.jpg'),
    badgeText: 'NEW',
    createdAt: DateTime(2025, 12, 24),
  ),
  _ProductVM(
    id: '4',
    title: 'Silk Shirt',
    price: 189,
    compareAt: null,
    isNew: true,
    popularityScore: 65,
    image: const AssetImage('assets/demo/product_shirt.jpg'),
    badgeText: 'NEW',
    createdAt: DateTime(2025, 12, 24),
  ),
  // add more as needed
];
