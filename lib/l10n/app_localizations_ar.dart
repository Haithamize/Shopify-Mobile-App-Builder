// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String welcomeMessage(String appName) {
    return 'مرحباً بك في $appName';
  }

  @override
  String get checkout => 'الدفع';

  @override
  String get homeCategories => 'الفئات';

  @override
  String get homeSeeAll => 'عرض الكل';

  @override
  String get homeFeaturedCollections => 'مجموعات مميزة';

  @override
  String get homeViewAll => 'عرض الكل';

  @override
  String get homeBestSellers => 'الأكثر مبيعاً';

  @override
  String get homeExploreCollection => 'استكشف التشكيلة';

  @override
  String get homeSpring2025 => 'ربيع ٢٠٢٥';

  @override
  String get homeNewSeasonArrivals => 'وصلت تشكيلات الموسم';

  @override
  String get homeSearch => 'بحث';

  @override
  String get homeNotifications => 'الإشعارات';

  @override
  String get homeCart => 'السلة';

  @override
  String get men => 'رجال';

  @override
  String get women => 'سيدات';

  @override
  String get accessories => 'اكسسوارات';

  @override
  String get shoes => 'احذية';

  @override
  String get collectionsTitle => 'المجموعات';

  @override
  String get collectionsSubtitle => 'اكتشف مجموعاتنا المختارة بعناية';

  @override
  String homeItemsCount(int count) {
    return '$count عنصر';
  }

  @override
  String get productsAllTitle => 'كل المنتجات';

  @override
  String get productsFilterAll => 'الكل';

  @override
  String get productsFilterOnSale => 'تخفيضات';

  @override
  String get productsFilterNew => 'جديد';

  @override
  String get productsFilterPopular => 'الأكثر شيوعاً';

  @override
  String productsCount(int count) {
    return '$count منتج';
  }

  @override
  String get productsQuickAdd => 'إضافة سريعة';

  @override
  String get productsSort => 'ترتيب';

  @override
  String get productsFilter => 'تصفية';

  @override
  String get productsSortPriceLowHigh => 'السعر: من الأقل للأعلى';

  @override
  String get productsSortPriceHighLow => 'السعر: من الأعلى للأقل';

  @override
  String get productsSortNewest => 'الأحدث';

  @override
  String get productsSortPopular => 'الأكثر شيوعاً';

  @override
  String get retry => 'حاول مرة اخري';

  @override
  String get noResults => 'لا توجد نتائج';

  @override
  String get productColor => 'اللون';

  @override
  String get productSize => 'المقاس';

  @override
  String get productQuantity => 'الكمية';

  @override
  String get productDescription => 'الوصف';

  @override
  String get productAddToCart => 'أضف إلى السلة';

  @override
  String get productSale => 'تخفيض';

  @override
  String productAddedToCart(int qty) {
    return 'تمت إضافة $qty إلى السلة';
  }

  @override
  String productAddToCartTotal(String label, String total) {
    return '$label — $total';
  }
}
