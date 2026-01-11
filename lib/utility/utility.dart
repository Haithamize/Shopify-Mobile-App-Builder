double moneyToDouble(dynamic moneyLike) {
  if (moneyLike == null) return 0;

  try {
    // MoneyV2 { amount, currencyCode }
    final d = moneyLike as dynamic;
    final a = d.amount?.toString();
    final v = double.tryParse(a ?? '');
    if (v != null) return v;
  } catch (_) {}

  // Sometimes it's already a string/num
  final s = moneyLike.toString().trim();
  return double.tryParse(s) ?? 0;
}

String withUtmParams(
    String checkoutUrl, {
      required String utmSource,
      required String utmMedium,
      required String utmCampaign,
      String? utmContent,
      String? utmTerm,
    }) {
  final uri = Uri.parse(checkoutUrl);

  final merged = Map<String, String>.from(uri.queryParameters);

  merged['utm_source'] = utmSource;
  merged['utm_medium'] = utmMedium;
  merged['utm_campaign'] = utmCampaign;

  if (utmContent != null && utmContent.isNotEmpty) merged['utm_content'] = utmContent;
  if (utmTerm != null && utmTerm.isNotEmpty) merged['utm_term'] = utmTerm;

  return uri.replace(queryParameters: merged).toString();
}

