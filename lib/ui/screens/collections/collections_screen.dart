import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/deeplink/merchant_context_service.dart';
import '../../../core/config/merchant_config.dart';
import '../../../core/di/injection_container.dart';
import '../../../l10n/app_localizations.dart';
import '../../layout/responsive.dart';

/// CollectionsScreen:
/// - Matches the UI kit: title + subtitle + featured wide card + grid of cards
/// - Sliver-based for best performance
/// - Responsive sizing via context.r (no static widths/heights)
/// - Deeplink-ready: add route /collections
class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({super.key});

  // Demo data: replace with Shopify collections later
  static const _collections = <_CollectionVM>[
    _CollectionVM(
      title: 'Summer Essentials',
      itemsCount: 45,
      featured: true,
      image: AssetImage('assets/demo/collection_summer.jpg'),
    ),
    _CollectionVM(
      title: 'Winter Collection',
      itemsCount: 38,
      featured: false,
      image: AssetImage('assets/demo/collection_winter.jpg'),
    ),
    _CollectionVM(
      title: 'Best Sellers',
      itemsCount: 24,
      featured: false,
      image: AssetImage('assets/demo/collection_best.jpg'),
    ),
    _CollectionVM(
      title: 'New Arrivals',
      itemsCount: 56,
      featured: false,
      image: AssetImage('assets/demo/collection_new.jpg'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    final l10n = AppLocalizations.of(context)!;
    final config = sl<MerchantContextService>().current!;

    // Responsive columns for grid portion.
    final cols = r.columns(minTileWidth: 190, min: 2, max: 4);

    // In the screenshot: 1 big featured card then 2-col grid.
    final featured = _collections.firstWhere((c) => c.featured, orElse: () => _collections.first);
    final rest = _collections.where((c) => c != featured).toList(growable: false);

    return SafeArea(
      child: CustomScrollView(
        cacheExtent: (r.h * 1.2).clamp(600.0, 1200.0),
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            centerTitle: true,
            toolbarHeight: (r.w * 0.14).clamp(56.0, 68.0),
            title: Text(
              l10n.collectionsTitle,
              textScaler: TextScaler.linear(r.textScale),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          // Subtitle line (like "Discover our curated collections")
          SliverPadding(
            padding: EdgeInsets.fromLTRB(r.gutter, r.s3, r.gutter, 0),
            sliver: SliverToBoxAdapter(
              child: Text(
                l10n.collectionsSubtitle,
                textScaler: TextScaler.linear(r.textScale),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.black.withOpacity(0.55),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Featured wide card
          SliverPadding(
            padding: EdgeInsets.fromLTRB(r.gutter, r.s3, r.gutter, 0),
            sliver: SliverToBoxAdapter(
              child: _CollectionWideCard(
                radius: r.radiusLg,
                height: (r.heroHeight * 0.92).clamp(170.0, 260.0),
                title: featured.title,
                subtitle: l10n.homeItemsCount(featured.itemsCount),
                image: featured.image,
                onTap: () {
                  // Future: route to collection details
                  // keep deeplink-friendly:
                  // context.go('/collection/${featured.handle}');
                },
              ),
            ),
          ),

          // Grid cards
          SliverPadding(
            padding: EdgeInsets.fromLTRB(r.gutter, r.s3, r.gutter, r.s4),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: r.s2,
                crossAxisSpacing: r.s2,
                // Similar to kit: slightly tall cards
                childAspectRatio: r.isSmall ? 0.94 : 0.98,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final c = rest[index];
                  return _CollectionGridCard(
                    radius: r.radiusLg,
                    title: _wrapTitleForKit(c.title),
                    subtitle: l10n.homeItemsCount(c.itemsCount),
                    image: c.image,
                    onTap: () {
                      // context.go('/collection/${c.handle}');
                    },
                  );
                },
                childCount: rest.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionVM {
  const _CollectionVM({
    required this.title,
    required this.itemsCount,
    required this.featured,
    required this.image,
  });

  final String title;
  final int itemsCount;
  final bool featured;
  final ImageProvider image;
}

/// The kit breaks titles like "Best Sellers" into 2 lines.
/// This keeps the aesthetic without hardcoding per-screen.
String _wrapTitleForKit(String title) {
  if (title.contains(' ')) {
    final parts = title.split(' ');
    if (parts.length == 2) return '${parts[0]}\n${parts[1]}';
  }
  return title;
}

/// Wide featured card (full width)
class _CollectionWideCard extends StatelessWidget {
  const _CollectionWideCard({
    required this.radius,
    required this.height,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.onTap,
  });

  final double radius;
  final double height;
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
        child: SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image(image: image, fit: BoxFit.cover, filterQuality: FilterQuality.medium),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xC0000000), Color(0x14000000)],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(r.s4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _CollectionText(
                        title: title,
                        subtitle: subtitle,
                        titleStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                        subtitleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(.85),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: r.s2),
                    _ArrowFab(onTap: onTap),
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

/// Grid card
class _CollectionGridCard extends StatelessWidget {
  const _CollectionGridCard({
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
                  colors: [Color(0xC0000000), Color(0x1A000000)],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(r.s3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _CollectionText(
                      title: title,
                      subtitle: subtitle,
                      titleStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                      subtitleStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(.85),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: r.s2),
                  _ArrowFab(onTap: onTap),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Extracted text widget to reduce duplication and keep rebuild cost low.
class _CollectionText extends StatelessWidget {
  const _CollectionText({
    required this.title,
    required this.subtitle,
    required this.titleStyle,
    required this.subtitleStyle,
  });

  final String title;
  final String subtitle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  @override
  Widget build(BuildContext context) {
    final r = context.r;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textScaler: TextScaler.linear(r.textScale),
          style: titleStyle,
        ),
        SizedBox(height: r.s1),
        Text(
          subtitle,
          textScaler: TextScaler.linear(r.textScale),
          style: subtitleStyle,
        ),
      ],
    );
  }
}

class _ArrowFab extends StatelessWidget {
  const _ArrowFab({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(.22),
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
