import 'package:drift/drift.dart';

/// Stores products per merchant.
/// We keep JSON blobs to avoid schema explosion (variants/images can be large).
/// Fast reads, easy migrations.
class CachedProducts extends Table {
  TextColumn get merchantId => text()(); // white-label boundary
  TextColumn get productId => text()();  // stable Shopify product ID
  TextColumn get json => text()();       // domain JSON
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {merchantId, productId};
}

/// Stores query result ordering (so you can cache "sale", "new", etc.)
/// This avoids rebuilding lists in memory and keeps stable ordering offline.
class ProductQueryIndex extends Table {
  TextColumn get merchantId => text()();
  TextColumn get queryKey => text()();     // e.g. "filter=sale&sort=price_asc"
  IntColumn get position => integer()();   // ordering
  TextColumn get productId => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {merchantId, queryKey, position};
}
