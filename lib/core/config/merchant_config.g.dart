// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'merchant_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MerchantConfig _$MerchantConfigFromJson(Map<String, dynamic> json) =>
    _MerchantConfig(
      merchantId: json['merchantId'] as String,
      shopDomain: json['shopDomain'] as String,
      storefrontToken: json['storefrontToken'] as String,
      appName: json['appName'] as String,
      theme: MerchantTheme.fromJson(json['theme'] as Map<String, dynamic>),
      features: FeatureFlags.fromJson(json['features'] as Map<String, dynamic>),
      integrationKeys: json['integrationKeys'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$MerchantConfigToJson(_MerchantConfig instance) =>
    <String, dynamic>{
      'merchantId': instance.merchantId,
      'shopDomain': instance.shopDomain,
      'storefrontToken': instance.storefrontToken,
      'appName': instance.appName,
      'theme': instance.theme,
      'features': instance.features,
      'integrationKeys': instance.integrationKeys,
    };

_MerchantTheme _$MerchantThemeFromJson(Map<String, dynamic> json) =>
    _MerchantTheme(
      primaryColor: json['primaryColor'] as String,
      secondaryColor: json['secondaryColor'] as String,
      fontFamily: json['fontFamily'] as String,
      logoUrl: json['logoUrl'] as String,
    );

Map<String, dynamic> _$MerchantThemeToJson(_MerchantTheme instance) =>
    <String, dynamic>{
      'primaryColor': instance.primaryColor,
      'secondaryColor': instance.secondaryColor,
      'fontFamily': instance.fontFamily,
      'logoUrl': instance.logoUrl,
    };

_FeatureFlags _$FeatureFlagsFromJson(Map<String, dynamic> json) =>
    _FeatureFlags(
      useNativeCheckout: json['useNativeCheckout'] as bool? ?? false,
      enableWishlist: json['enableWishlist'] as bool? ?? false,
      enableSocialLogin: json['enableSocialLogin'] as bool? ?? false,
      enablePushNotifications: json['enablePushNotifications'] as bool? ?? true,
      supportedLanguages:
          (json['supportedLanguages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [EN, AR],
      defaultLanguage: json['defaultLanguage'] as String? ?? EN,
      enableLanguageSwitching:
          json['enableLanguageSwitching'] as bool? ?? false,
    );

Map<String, dynamic> _$FeatureFlagsToJson(_FeatureFlags instance) =>
    <String, dynamic>{
      'useNativeCheckout': instance.useNativeCheckout,
      'enableWishlist': instance.enableWishlist,
      'enableSocialLogin': instance.enableSocialLogin,
      'enablePushNotifications': instance.enablePushNotifications,
      'supportedLanguages': instance.supportedLanguages,
      'defaultLanguage': instance.defaultLanguage,
      'enableLanguageSwitching': instance.enableLanguageSwitching,
    };
