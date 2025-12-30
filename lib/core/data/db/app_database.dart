import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Stores cached products JSON per merchant + queryKey.
/// queryKey can be something like: "products:limit=30|filter=sale|sort=price_asc"
class CachedProducts extends Table {
  TextColumn get merchantId => text()();
  TextColumn get queryKey => text()();

  /// JSON string of List<Map<String, dynamic>>
  TextColumn get json => text()();

  /// Unix millis
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {merchantId, queryKey};
}

@DriftDatabase(tables: [CachedProducts])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<String?> readCachedJson({
    required String merchantId,
    required String queryKey,
  }) async {
    final row = await (select(cachedProducts)
      ..where((t) =>
      t.merchantId.equals(merchantId) & t.queryKey.equals(queryKey)))
        .getSingleOrNull();
    return row?.json;
  }

  Future<void> writeCachedJson({
    required String merchantId,
    required String queryKey,
    required String json,
    required int updatedAt,
  }) async {
    await into(cachedProducts).insertOnConflictUpdate(
      CachedProductsCompanion.insert(
        merchantId: merchantId,
        queryKey: queryKey,
        json: json,
        updatedAt: updatedAt,
      ),
    );
  }
}

/// ✅ This is the simplest + correct connection for drift_flutter 0.2.x
/// It avoids FlutterQueryExecutor / NativeDatabase differences entirely.
QueryExecutor _openConnection() {
  return driftDatabase(name: 'shopiney_cache');
}
