import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/deeplink/merchant_context_service.dart';
import '../../../core/di/injection_container.dart';
import '../../../l10n/app_localizations.dart';
import '../../layout/responsive.dart';

/// HomeScreen (high performance + responsive)
/// - CustomScrollView + Slivers => lazy build, no nested scroll jank
/// - Uses Responsive (context.r) for all sizing (no static widths/heights)
/// - Uses MerchantConfig + FeatureFlags for white-label behavior
/// - Uses AppLocalizations for system-locale strings (no manual language logic)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _controller = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Demo Data (replace with Shopify API later)
  // ---------------------------------------------------------------------------
  static const _categories = <_CategoryVM>[
    _CategoryVM(title: 'Women', itemsCount: 248, image: AssetImage('assets/demo/category_women.jpg')),
    _CategoryVM(title: 'Men', itemsCount: 186, image: AssetImage('assets/demo/category_men.jpg')),
    _CategoryVM(title: 'Accessories', itemsCount: 124, image: AssetImage('assets/demo/category_accessories.jpg')),
  ];

  static const _featuredCollections = <_CollectionVM>[
    _CollectionVM(title: 'Summer\nEssentials', itemsCount: 45, image: AssetImage('assets/demo/collection_summer.jpg')),
    _CollectionVM(title: 'Winter\nCollection', itemsCount: 38, image: AssetImage('assets/demo/collection_winter.jpg')),
  ];

  static const _bestSellers = <_ProductVM>[
    _ProductVM(title: 'Classic White Sneakers', price: 129, compareAt: 159, badge: '-19%', image: AssetImage('assets/demo/product_sneakers.jpg')),
    _ProductVM(title: 'Leather Tote Bag', price: 245, compareAt: null, badge: 'NEW', image: AssetImage('assets/demo/product_bag.jpg')),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final config = sl<MerchantContextService>().current!;
    final flags = config.features;
    final l10n = AppLocalizations.of(context)!;

    // Reusable responsive tokens for *all* sizing.
    final r = context.r;

    // Responsive columns
    final featuredCols = r.columns(minTileWidth: 220);
    final productCols = r.columns(minTileWidth: 190);

    return SafeArea(
      child: CustomScrollView(
        controller: _controller,

        // Prefetch some pixels ahead for smoother fling.
        cacheExtent: (r.h * 1.2).clamp(600.0, 1200.0),

        slivers: [
          // -----------------------------------------------------------------
          // App Bar (pinned + floating like the kit)
          // -----------------------------------------------------------------
          SliverAppBar(
            pinned: true,
            floating: true,
            snap: true,
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            toolbarHeight: (r.w * 0.14).clamp(56.0, 68.0),

            titleSpacing: r.gutter,
            title: Text(
              config.appName.toUpperCase(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
              textScaler: TextScaler.linear(r.textScale),
            ),
            actions: [
              IconButton(
                tooltip: l10n.homeSearch,
                onPressed: () {
                  // context.go('/search');
                },
                icon: const Icon(Icons.search),
              ),

              // White-label gating: hide bell if push disabled
              if (flags.enablePushNotifications)
                _BellIconButton(
                  tooltip: l10n.homeNotifications,
                  hasUnread: true,
                  onTap: () {
                    // context.go('/notifications');
                  },
                ),

              IconButton(
                tooltip: l10n.homeCart,
                onPressed: () => context.go('/cart'),
                icon: const Icon(Icons.shopping_bag_outlined),
              ),
              SizedBox(width: r.gutter / 2),
            ],
          ),

          // -----------------------------------------------------------------
          // Hero Banner (height scales with device width)
          // -----------------------------------------------------------------
          SliverPadding(
            padding: EdgeInsets.fromLTRB(r.gutter, r.s2, r.gutter, 0),
            sliver: SliverToBoxAdapter(
              child: _HeroBanner(
                height: r.heroHeight,
                radius: r.radiusLg,
                image: const AssetImage('assets/demo/hero.jpg'),
                eyebrow: l10n.homeSpring2025,
                title: l10n.homeNewSeasonArrivals,
                cta: l10n.homeExploreCollection,
                onTap: () {
                  // Example: future deeplink-friendly collection route
                  // context.go('/collection/spring-2025');
                },
              ),
            ),
          ),

          // -----------------------------------------------------------------
          // Categories
          // -----------------------------------------------------------------
          SliverPadding(
            padding: EdgeInsets.fromLTRB(r.gutter, r.s4, r.gutter, 0),
            sliver: SliverToBoxAdapter(
              child: _SectionHeader(
                title: l10n.homeCategories,
                actionText: l10n.homeSeeAll,
                onAction: () {
                  context.go('/categories');
                },
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: r.hCardHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.fromLTRB(r.gutter, r.s2, r.gutter, 0),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => SizedBox(width: r.s2),
                itemBuilder: (context, index) {
                  final c = _categories[index];
                  return SizedBox(
                    width: r.hCardWidth,
                    child: _CategoryCard(
                      radius: r.radiusMd,
                      title: c.title, // localize later by adding keys if desired
                      subtitle: l10n.homeItemsCount(c.itemsCount),
                      image: c.image,
                      onTap: () {
                        // context.go('/collection/${c.handle}');
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          // -----------------------------------------------------------------
          // Featured Collections (responsive grid)
          // -----------------------------------------------------------------
          SliverPadding(
            padding: EdgeInsets.fromLTRB(r.gutter, r.s4, r.gutter, 0),
            sliver: SliverToBoxAdapter(
              child: _SectionHeader(
                title: l10n.homeFeaturedCollections,
                actionText: l10n.homeViewAll,
                onAction: () {
                  context.go('/collections');
                },
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.fromLTRB(r.gutter, r.s2, r.gutter, 0),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: featuredCols,
                mainAxisSpacing: r.s2,
                crossAxisSpacing: r.s2,
                childAspectRatio: r.featuredAspect,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final col = _featuredCollections[index];
                  return _CollectionCard(
                    radius: r.radiusLg,
                    title: col.title,
                    subtitle: l10n.homeItemsCount(col.itemsCount),
                    image: col.image,
                    onTap: () {},
                  );
                },
                childCount: _featuredCollections.length,
              ),
            ),
          ),

          // -----------------------------------------------------------------
          // Best Sellers (responsive product grid)
          // -----------------------------------------------------------------
          SliverPadding(
            padding: EdgeInsets.fromLTRB(r.gutter, r.s4, r.gutter, 0),
            sliver: SliverToBoxAdapter(
              child: _SectionHeader(
                title: l10n.homeBestSellers,
                actionText: l10n.homeSeeAll,
                onAction: () {
                  context.go('/products?filter=sale');
                },
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.fromLTRB(r.gutter, r.s2, r.gutter, r.s4),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: productCols,
                mainAxisSpacing: r.s2,
                crossAxisSpacing: r.s2,
                childAspectRatio: r.productAspect,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final p = _bestSellers[index];
                  return _ProductCard(
                    radius: r.radiusLg,
                    title: p.title,
                    badge: p.badge,
                    price: p.price,
                    compareAt: p.compareAt,
                    image: p.image,
                    onTap: () {
                      // Deep-link compatible:
                      context.go('/product/${index + 1}');
                    },
                  );
                },
                childCount: _bestSellers.length,
              ),
            ),
          ),

          // Proof of existing l10n usage (your exact style)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(r.gutter, 0, r.gutter, r.s3),
              child: Text(
                l10n.welcomeMessage(config.appName),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Remove this helper later. It just prevents unused warnings if you copy/paste.
void _toggleTODO(BuildContext context) {}

/// Demo view models
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

class _CollectionVM {
  const _CollectionVM({
    required this.title,
    required this.itemsCount,
    required this.image,
  });

  final String title;
  final int itemsCount;
  final ImageProvider image;
}

class _ProductVM {
  const _ProductVM({
    required this.title,
    required this.price,
    required this.compareAt,
    required this.badge,
    required this.image,
  });

  final String title;
  final double price;
  final double? compareAt;
  final String badge;
  final ImageProvider image;
}

/// Notification bell with unread dot
class _BellIconButton extends StatelessWidget {
  const _BellIconButton({
    required this.tooltip,
    required this.hasUnread,
    required this.onTap,
  });

  final String tooltip;
  final bool hasUnread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_none),
          if (hasUnread)
            PositionedDirectional(
              end: -1,
              top: -1,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFF6B3D),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Section header: title + action
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionText,
    required this.onAction,
  });

  final String title;
  final String actionText;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final r = context.r;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            textScaler: TextScaler.linear(r.textScale),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        InkWell(
          onTap: onAction,
          borderRadius: BorderRadius.circular(r.radiusSm),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: r.s2, vertical: r.s1),
            child: Text(
              actionText,
              textScaler: TextScaler.linear(r.textScale),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Hero banner (adaptive height)
class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.height,
    required this.radius,
    required this.image,
    required this.eyebrow,
    required this.title,
    required this.cta,
    required this.onTap,
  });

  final double height;
  final double radius;
  final ImageProvider image;
  final String eyebrow;
  final String title;
  final String cta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = context.r;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image(image: image, fit: BoxFit.cover, filterQuality: FilterQuality.medium),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xAA000000), Color(0x33000000)],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(r.s4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      eyebrow,
                      textScaler: TextScaler.linear(r.textScale),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white.withOpacity(0.85),
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: r.s2),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textScaler: TextScaler.linear(r.textScale),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: r.s3),
                    _PillCta(text: cta, onTap: onTap),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillCta extends StatelessWidget {
  const _PillCta({required this.text, required this.onTap});
  final String text;
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                textScaler: TextScaler.linear(r.textScale),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: r.s2),
              const Icon(Icons.arrow_forward, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
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
            Image(image: image, fit: BoxFit.cover, filterQuality: FilterQuality.medium),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xAA000000), Color(0x11000000)],
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: r.s1),
                  Text(
                    subtitle,
                    textScaler: TextScaler.linear(r.textScale),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(.85),
                      fontWeight: FontWeight.w500,
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

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({
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
            Image(image: image, fit: BoxFit.cover, filterQuality: FilterQuality.medium),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xC0000000), Color(0x22000000)],
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
                    maxLines: 2,
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
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: r.s2),
                  Align(
                    alignment: AlignmentDirectional.bottomEnd,
                    child: _CircleArrow(onTap: onTap),
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

class _CircleArrow extends StatelessWidget {
  const _CircleArrow({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(.18),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(Icons.arrow_forward, color: Colors.white),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.radius,
    required this.title,
    required this.badge,
    required this.price,
    required this.compareAt,
    required this.image,
    required this.onTap,
  });

  final double radius;
  final String title;
  final String badge;
  final double price;
  final double? compareAt;
  final ImageProvider image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = context.r;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image(image: image, fit: BoxFit.cover, filterQuality: FilterQuality.medium),
                  PositionedDirectional(
                    start: r.s3,
                    top: r.s3,
                    child: _Badge(text: badge),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: r.s2),
          Text(
            title,
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
                '\$${price.toStringAsFixed(2)}',
                textScaler: TextScaler.linear(r.textScale),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: compareAt == null ? Colors.black : const Color(0xFFD1493F),
                ),
              ),
              SizedBox(width: r.s2),
              if (compareAt != null)
                Text(
                  '\$${compareAt!.toStringAsFixed(2)}',
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
  const _Badge({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    final isDiscount = text.contains('%') || text.contains('٪') || text.contains('-');
    final bg = isDiscount ? const Color(0xFFD1493F) : const Color(0xFF4AAE9B);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.s3, vertical: r.s2),
      decoration: BoxDecoration(
        color: bg,
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
