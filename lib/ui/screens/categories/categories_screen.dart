import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/deeplink/merchant_context_service.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/config/merchant_config.dart';
import '../../../l10n/app_localizations.dart';
import '../../layout/responsive.dart';

/// CategoriesScreen:
/// - Grid of categories like the screenshot (2 columns on phones, more on tablets)
/// - Sliver-based for performance (lazy building)
/// - Uses responsive tokens (context.r) for all sizing
/// - Uses l10n strings (system locale)
/// - Deeplink-ready: route this screen at /categories
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  // Demo categories (replace with Shopify collections later)
  static const _categories = <_CategoryVM>[
    _CategoryVM(title: 'Women', itemsCount: 248, image: AssetImage('assets/demo/category_women.jpg')),
    _CategoryVM(title: 'Men', itemsCount: 186, image: AssetImage('assets/demo/category_men.jpg')),
    _CategoryVM(title: 'Accessories', itemsCount: 124, image: AssetImage('assets/demo/category_accessories.jpg')),
    _CategoryVM(title: 'Shoes', itemsCount: 92, image: AssetImage('assets/demo/category_shoes.jpg')),
  ];

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    final l10n = AppLocalizations.of(context)!;
    final config = sl<MerchantContextService>().current!; // for future merchant-level logic, brand assets, etc.

    // Grid columns adapt based on width.
    // minTileWidth controls density.
    final cols = r.columns(minTileWidth: 190, min: 2, max: 4);

    return SafeArea(
      child: CustomScrollView(
        cacheExtent: (r.h * 1.2).clamp(600.0, 1200.0),
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            centerTitle: true,
            toolbarHeight: (r.w * 0.14).clamp(56.0, 68.0),
            title: Text(
              // Use existing key you already planned: "Categories"
              // If you add a dedicated categoriesTitle key, replace this with l10n.categoriesTitle.
              l10n.homeCategories,
              textScaler: TextScaler.linear(r.textScale),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            // Optional: back button only if this page is opened as a pushed route
            // rather than via the tab. The tab shell usually doesn't need it.
            // automaticallyImplyLeading: true,
          ),

          SliverPadding(
            padding: EdgeInsets.fromLTRB(r.gutter, r.s3, r.gutter, r.s4),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: r.s2,
                crossAxisSpacing: r.s2,

                // Similar to screenshot: rounded “square” cards.
                // Use ~1:1 tile ratio. Slightly taller on small phones.
                childAspectRatio: r.isSmall ? 0.96 : 1.0,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final c = _categories[index];
                  return _CategoryTile(
                    radius: r.radiusLg,
                    title: c.title, // localize later by adding keys per category if you want
                    subtitle: l10n.homeItemsCount(c.itemsCount),
                    image: c.image,
                    onTap: () {
                      // Future: open collection/products listing
                      // Keep deeplink-friendly path style
                      // context.go('/collection/${c.handle}');
                    },
                  );
                },
                childCount: _categories.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryVM {
  const _CategoryVM({
    required this.title,
    required this.itemsCount,
    required this.image,
  });

  final String title;
  final int itemsCount;
  final ImageProvider image;
}

/// A single category tile:
/// - One clip (performance)
/// - Gradient overlay for text readability
/// - Responsive padding & typography scaling
class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.radius,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.onTap,
  });

  final double radius;
  final String title;
  final String subtitle;
  final ImageProvider image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = context.r;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image(
              image: image,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xAA000000), Color(0x12000000)],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(r.s3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textScaler: TextScaler.linear(r.textScale),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: r.s1),
                  Text(
                    subtitle,
                    textScaler: TextScaler.linear(r.textScale),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(.85),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
