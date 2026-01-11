import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopify_flutter/shopify_flutter.dart' as sf;

import '../../../core/config/deeplink/merchant_context_service.dart';
import '../../../core/config/merchant_config.dart';
import '../../../core/di/injection_container.dart';
import '../../../features/catalogue/bloc/product/products_bloc.dart';
import '../../../features/catalogue/bloc/product/products_event.dart';
import '../../../features/catalogue/bloc/product/products_state.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utility/utility.dart';
import '../../layout/responsive.dart';


/// AllProductsScreen (Bloc-driven):
/// - UI stays the same (chips + grid + sheets)
/// - Data comes from ProductsBloc (Shopify via repository + cache)
/// - Local filter/sort affects the in-memory list (fast)
/// - Optional: keep URL in sync using replace() (doesn't break back stack)
///
/// NOTE:
/// This screen expects that YOU provide it with a BlocProvider in the route:
/// BlocProvider(
///   create: (_) => sl<ProductsBloc>()..add(const LoadProducts(limit: 30)),
///   child: const AllProductsScreen(),
/// )
class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen>
/// This tells Flutter: don’t dispose this screen’s state when it’s inside a tab/shell and you switch tabs.
/// That prevents reloading and losing filter selection.
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  _ProductsFilter _filter = _ProductsFilter.all;
  _ProductsSort _sort = _ProductsSort.none;

  /// Avoid re-parsing same uri again and again (prevents snap-back issues)
  Uri? _lastParsedUri;

  /// Local wishlist only (fast + keeps demo behavior)
  final Set<String> _wishlisted = <String>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ Ensure products load at least once
    final bloc = context.read<ProductsBloc>();
    if (bloc.state is ProductsInitial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        bloc.add(const LoadProducts(limit: 30));
      });
    }

    // (keep your deep-link query parsing code below unchanged)
    final uri = GoRouterState.of(context).uri;
    if (_lastParsedUri == uri) return;
    _lastParsedUri = uri;

    final f = uri.queryParameters['filter'];
    final s = uri.queryParameters['sort'];

    final parsedFilter = _ProductsFilterX.fromQuery(f);
    final parsedSort = _ProductsSortX.fromQuery(s);

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
    final config = sl<MerchantContextService>().current!;
    final flags = config.features;

    final cols = r.columns(minTileWidth: 190, min: 2, max: 4);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocConsumer<ProductsBloc, ProductsState>(
        listenWhen: (prev, next) {
          return next is ProductsError && prev.runtimeType != next.runtimeType;
        },
        listener: (context, state) {
          if (state is ProductsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = _isLoading(state);
          final error = _errorMessage(state);

          final rawProducts = _products(state);

// If there's no real data yet, show fake products in UI (TEMP)
//           final List<_ProductVM> vms = rawProducts.isEmpty
//               ? _kFakeProducts
//               : rawProducts.map(_vmFromShopify).toList(growable: false);

          // ✅ Real data only
          final List<_ProductVM> vms =
          rawProducts.map(_vmFromShopify).toList(growable: false);

// Apply local filter/sort to what we have
          final visible = _applyFilterAndSort(vms, _filter, _sort);

// For empty-state decisions, use what the user actually sees
          final bool isVisiblyEmpty = visible.isEmpty;


          return CustomScrollView(
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
                    // Real "back" behavior requires that /products was opened with push().
                    // If it was opened with go() or via deep link, there's nothing to pop.
                    if (GoRouter.of(context).canPop()) {
                      context.pop();
                      return;
                    }
                    // Fallback safe route
                    context.go('/home');
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
                    // IMPORTANT: do NOT sync query params here.
                    // Opening sheet must be a pure UI action to avoid snap-back.
                    onPressed: () => _openFilterSheet(context),
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
              // Filter chips row
              // ---------------------------------------------------------------
              SliverPadding(
                padding: EdgeInsets.only(top: r.s2),
                sliver: SliverToBoxAdapter(
                  child: _FilterChipsRow(
                    selected: _filter,
                    onSelected: (f) {
                      if (f == _filter) return;
                      setState(() => _filter = f);
                      _syncQueryParams();
                    },
                  ),
                ),
              ),

              // ---------------------------------------------------------------
              // Count label / Loading / Error
              // ---------------------------------------------------------------
              SliverPadding(
                padding: EdgeInsets.only(top: r.s3),
                sliver: SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(end: r.gutter, start: r.gutter),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.productsCount(visible.length),
                            textScaler: TextScaler.linear(r.textScale),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.black.withOpacity(.55),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        if (isLoading)
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: const CircularProgressIndicator(strokeWidth: 2),
                          ),

                        if (!isLoading && (error != null && error.isNotEmpty))
                          TextButton(
                            onPressed: () {
                              // Retry (keeps it simple)
                              context.read<ProductsBloc>().add(const LoadProducts(limit: 30));
                            },
                            child: Text(l10n.retry),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // ---------------------------------------------------------------
              // Empty state
              // ---------------------------------------------------------------
              if (!isLoading && isVisiblyEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(r.gutter),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            (error != null && error.isNotEmpty) ? error : l10n.noResults,
                            textScaler: TextScaler.linear(r.textScale),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.black.withOpacity(.65),
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: r.s3),
                          SizedBox(
                            width: (r.w * 0.6).clamp(180.0, 320.0),
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<ProductsBloc>().add(const LoadProducts(limit: 30, forceRefresh: true));
                              },
                              child: Text(l10n.retry),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // ---------------------------------------------------------------
              // Products grid
              // ---------------------------------------------------------------
              if (visible.isNotEmpty)
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(r.gutter, r.s3, r.gutter, r.s4),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      mainAxisSpacing: r.s2,
                      crossAxisSpacing: r.s2,
                      childAspectRatio: r.productAspect,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final p = visible[index];
                        final isWish = _wishlisted.contains(p.id);

                        return _ProductTile(
                          product: p,
                          enableWishlist: flags.enableWishlist,
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
                            // future
                          },
                          onTap: () => context.push(
                            '/product/${Uri.encodeComponent(p.id)}',
                            extra: rawProducts.firstWhere((x) => x.id.toString() == p.id),
                          ),
                        );
                      },
                      childCount: visible.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ✅ State selectors (ADJUST HERE IF YOUR ProductsState USES DIFFERENT FIELDS)
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  // ✅ State helpers for your sealed ProductsState
  // ---------------------------------------------------------------------------

  bool _isLoading(ProductsState state) => state is ProductsLoading;

  String? _errorMessage(ProductsState state) {
    return switch (state) {
      ProductsError(:final message) => message,
      _ => null,
    };
  }

  List<sf.Product> _products(ProductsState state) {
    return switch (state) {
      ProductsLoaded(:final products) => products,
      _ => const <sf.Product>[],
    };
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

  /// Sync URL without destroying navigation stack.
  /// - uses replace(), not go()
  /// - omits filter when "all"
  /// - omits sort when "none"
  void _syncQueryParams() {
    final qp = <String, String>{};

    final f = _filter.toQuery();
    if (f != null) qp['filter'] = f;

    final s = _sort.toQuery();
    if (s != null) qp['sort'] = s;

    final newUri = Uri(path: '/products', queryParameters: qp.isEmpty ? null : qp);
    final currentUri = GoRouterState.of(context).uri;
    if (currentUri.toString() == newUri.toString()) return;

    _lastParsedUri = newUri;
    context.replace(newUri.toString());
  }
}

// ============================================================================
// Shopify -> VM mapper (minimal + safe)
//
// This keeps your UI untouched while switching your data source to Shopify models.
// ============================================================================

_ProductVM _vmFromShopify(sf.Product p) {
  final title = (p.title ?? '').toString().trim();
  final safeTitle = title.isEmpty ? 'Untitled' : title;

  // --- Price (defensive) ---
  double price = 0;
  double? compareAt;

  try {
    final variants = (p.productVariants ?? const []);
    if (variants.isNotEmpty) {
      final v0 = variants.first;

      price = moneyToDouble(v0.price);

      final c = _toDoubleSafeNullable(v0.compareAtPrice);
      if (c != null && c > price) compareAt = c;
    }
  } catch (_) {
    // keep defaults
  }

  // --- CreatedAt (defensive) ---
  DateTime createdAt = DateTime(1970, 1, 1);
  bool isNew = false;

  try {
    final raw = (p.createdAt)?.toString();
    final parsed = raw == null ? null : DateTime.tryParse(raw);
    if (parsed != null) {
      createdAt = parsed;
      isNew = DateTime.now().difference(createdAt).inDays <= 14;
    }
  } catch (_) {}

  // --- Image (defensive across plugin versions) ---
  final imageUrl = _tryGetFirstImageUrl(p);
  final ImageProvider imageProvider = (imageUrl != null && imageUrl.isNotEmpty)
      ? NetworkImage(imageUrl)
      : const AssetImage('assets/demo/product_sneakers.jpg');

  final badgeText =
  (compareAt != null) ? 'SALE' : (isNew ? 'NEW' : '');

  return _ProductVM(
    raw: p,
    id: p.id.toString(),
    title: safeTitle,
    price: price,
    compareAt: compareAt,
    isNew: isNew,
    popularityScore: 0,
    image: imageProvider,
    badgeText: badgeText,
    createdAt: createdAt,
  );
}

double _toDoubleSafe(dynamic v) {
  final s = v?.toString().trim() ?? '';
  return double.tryParse(s) ?? 0;
}

double? _toDoubleSafeNullable(dynamic v) {
  final s = v?.toString().trim();
  if (s == null || s.isEmpty) return null;
  return double.tryParse(s);
}

/// Tries to read product image URL across shopify_flutter model variations.
String? _tryGetFirstImageUrl(sf.Product p) {
  try {
    final d = p as dynamic;

    // common: product.images -> list
    final images = d.images;
    if (images != null && images.isNotEmpty) {
      final img0 = images.first;
      final url = img0.originalSrc ?? img0.src ?? img0.url;
      return url?.toString();
    }

    // sometimes: product.image -> single
    final img = d.image;
    if (img != null) {
      final url = img.originalSrc ?? img.src ?? img.url;
      return url?.toString();
    }
  } catch (_) {}

  return null;
}

// ============================================================================
// Filtering / Sorting
// ============================================================================

enum _ProductsFilter { all, sale, newest, popular }

extension _ProductsFilterX on _ProductsFilter {
  /// IMPORTANT:
  /// - "all" returns null => omitted from URL, prevents snap-back problems.
  String? toQuery() {
    switch (this) {
      case _ProductsFilter.all:
        return null;
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
// UI widgets (UNCHANGED from your original file)
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
      padding: EdgeInsetsDirectional.only(start: r.gutter, end: r.gutter),
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
    final badgeText = product.badgeText.trim();
    final Color badgeColor = switch (badgeText) {
      'NEW'  => const Color(0xFF4AAE9B),
      'SALE' => const Color(0xFFD1493F),
      _      => Colors.transparent, // won't be used because we won't render badge
    };

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
                  Image(
                    image: product.image,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/demo/product_sneakers.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),

                  if (badgeText.trim().isNotEmpty)
                    PositionedDirectional(
                      start: r.s3,
                      top: r.s3,
                      child: _Badge(
                        text: badgeText,
                        color: badgeColor,
                      ),
                    ),

                  if (enableWishlist)
                    if (badgeText.trim().isNotEmpty)
                      PositionedDirectional(
                        start: r.s3,
                        top: r.s3,
                        child: _Badge(
                          text: badgeText,
                          color: badgeColor,
                        ),
                      ),

                  if (badgeText.trim().isNotEmpty)
                    PositionedDirectional(
                      start: r.s3,
                      top: r.s3,
                      child: _Badge(
                        text: badgeText,
                        color: badgeColor,
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
// VM used by your tile (unchanged)
// ============================================================================

class _ProductVM {
  const _ProductVM({
    required this.raw,
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

  final sf.Product raw;
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

// ---------------------------------------------------------------------------
// TEMP UI-ONLY FALLBACK (remove once Shopify storefront is wired)
// ---------------------------------------------------------------------------


// final List<_ProductVM> _kFakeProducts = <_ProductVM>[
//   _ProductVM(
//     id: 'demo_1',
//     title: 'Classic White Sneakers',
//     price: 129.00,
//     compareAt: 159.00,
//     isNew: true,
//     popularityScore: 85,
//     image: const AssetImage('assets/demo/product_sneakers.jpg'),
//     badgeText: 'SALE',
//     createdAt: DateTime(2025, 12, 10),
//   ),
//   _ProductVM(
//     id: 'demo_2',
//     title: 'Leather Tote Bag',
//     price: 245.00,
//     compareAt: null,
//     isNew: true,
//     popularityScore: 72,
//     image: const AssetImage('assets/demo/product_sneakers.jpg'),
//     badgeText: 'NEW',
//     createdAt: DateTime(2025, 12, 20),
//   ),
//   _ProductVM(
//     id: 'demo_3',
//     title: 'Luxury Watch',
//     price: 399.00,
//     compareAt: 479.00,
//     isNew: false,
//     popularityScore: 90,
//     image: const AssetImage('assets/demo/product_sneakers.jpg'),
//     badgeText: 'SALE',
//     createdAt: DateTime(2025, 11, 18),
//   ),
//   _ProductVM(
//     id: 'demo_4',
//     title: 'Silk Shirt',
//     price: 189.00,
//     compareAt: null,
//     isNew: true,
//     popularityScore: 60,
//     image: const AssetImage('assets/demo/product_sneakers.jpg'),
//     badgeText: 'NEW',
//     createdAt: DateTime(2025, 12, 24),
//   ),
//   _ProductVM(
//     id: 'demo_4',
//     title: 'Silk Shirt',
//     price: 189.00,
//     compareAt: null,
//     isNew: true,
//     popularityScore: 60,
//     image: const AssetImage('assets/demo/product_sneakers.jpg'),
//     badgeText: 'NEW',
//     createdAt: DateTime(2025, 12, 24),
//   ),
//   _ProductVM(
//     id: 'demo_4',
//     title: 'Silk Shirt',
//     price: 189.00,
//     compareAt: null,
//     isNew: true,
//     popularityScore: 60,
//     image: const AssetImage('assets/demo/product_sneakers.jpg'),
//     badgeText: 'NEW',
//     createdAt: DateTime(2025, 12, 24),
//   ),
//   _ProductVM(
//     id: 'demo_4',
//     title: 'Silk Shirt',
//     price: 189.00,
//     compareAt: null,
//     isNew: true,
//     popularityScore: 60,
//     image: const AssetImage('assets/demo/product_sneakers.jpg'),
//     badgeText: 'NEW',
//     createdAt: DateTime(2025, 12, 24),
//   ),
//   _ProductVM(
//     id: 'demo_4',
//     title: 'Silk Shirt',
//     price: 189.00,
//     compareAt: null,
//     isNew: true,
//     popularityScore: 60,
//     image: const AssetImage('assets/demo/product_sneakers.jpg'),
//     badgeText: 'NEW',
//     createdAt: DateTime(2025, 12, 24),
//   ),
// ];
// final List<_ProductVM> _kFakeProducts = <_ProductVM>[];

