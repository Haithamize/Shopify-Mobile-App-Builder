// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String welcomeMessage(String appName) {
    return 'Welcome to $appName';
  }

  @override
  String get checkout => 'Checkout';

  @override
  String get homeCategories => 'Categories';

  @override
  String get homeSeeAll => 'See All';

  @override
  String get homeFeaturedCollections => 'Featured Collections';

  @override
  String get homeViewAll => 'View All';

  @override
  String get homeBestSellers => 'Best Sellers';

  @override
  String get homeExploreCollection => 'Explore Collection';

  @override
  String get homeSpring2025 => 'SPRING 2025';

  @override
  String get homeNewSeasonArrivals => 'New Season Arrivals';

  @override
  String get homeSearch => 'Search';

  @override
  String get homeNotifications => 'Notifications';

  @override
  String get homeCart => 'Cart';

  @override
  String get men => 'Men';

  @override
  String get women => 'Women';

  @override
  String get accessories => 'Accessories';

  @override
  String get shoes => 'Shoes';

  @override
  String get collectionsTitle => 'Collections';

  @override
  String get collectionsSubtitle => 'Discover our curated collections';

  @override
  String homeItemsCount(int count) {
    return '$count items';
  }

  @override
  String get productsAllTitle => 'All Products';

  @override
  String get productsFilterAll => 'All';

  @override
  String get productsFilterOnSale => 'On Sale';

  @override
  String get productsFilterNew => 'New';

  @override
  String get productsFilterPopular => 'Popular';

  @override
  String productsCount(int count) {
    return '$count products';
  }

  @override
  String get productsQuickAdd => 'Quick Add';

  @override
  String get productsSort => 'Sort';

  @override
  String get productsFilter => 'Filter';

  @override
  String get productsSortPriceLowHigh => 'Price: Low to High';

  @override
  String get productsSortPriceHighLow => 'Price: High to Low';

  @override
  String get productsSortNewest => 'Newest';

  @override
  String get productsSortPopular => 'Popular';

  @override
  String get retry => 'Retry';

  @override
  String get noResults => 'No results';

  @override
  String get productColor => 'Color';

  @override
  String get productSize => 'Size';

  @override
  String get productQuantity => 'Quantity';

  @override
  String get productDescription => 'Description';

  @override
  String get productAddToCart => 'Add to Cart';

  @override
  String get productSale => 'SALE';

  @override
  String productAddedToCart(int qty) {
    return 'Added $qty to cart';
  }

  @override
  String productAddToCartTotal(String label, String total) {
    return '$label — $total';
  }
}
