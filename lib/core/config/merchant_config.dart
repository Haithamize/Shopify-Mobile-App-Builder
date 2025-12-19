import 'package:freezed_annotation/freezed_annotation.dart';
// logic: part 'filename.freezed.dart';
part 'merchant_config.freezed.dart';
// logic: part 'filename.g.dart'; (for JSON parsing)
part 'merchant_config.g.dart';

@freezed
abstract class MerchantConfig with _$MerchantConfig {
  const factory MerchantConfig({
    required String merchantId,
    required String shopDomain,
    required String storefrontToken,
    required String appName,
    required MerchantTheme theme,
    required FeatureFlags features,
    required Map<String, dynamic> integrationKeys, // Firebase, FB Pixel, etc.
  }) = _MerchantConfig;

  factory MerchantConfig.fromJson(Map<String, dynamic> json) =>
      _$MerchantConfigFromJson(json);
}

@freezed
abstract class MerchantTheme with _$MerchantTheme {
  const factory MerchantTheme({
    required String primaryColor,
    required String secondaryColor,
    required String fontFamily,
    required String logoUrl,
  }) = _MerchantTheme;

  factory MerchantTheme.fromJson(Map<String, dynamic> json) =>
      _$MerchantThemeFromJson(json); // Correct
}

@freezed
abstract class FeatureFlags with _$FeatureFlags {
  const factory FeatureFlags({
    @Default(false) bool useNativeCheckout,
    @Default(false) bool enableWishlist,
    @Default(false) bool enableSocialLogin,
  }) = _FeatureFlags;

  factory FeatureFlags.fromJson(Map<String, dynamic> json) =>
      _$FeatureFlagsFromJson(json);
}