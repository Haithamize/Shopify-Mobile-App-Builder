// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'merchant_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MerchantConfig {

 String get merchantId; String get shopDomain; String get storefrontToken; String get appName; MerchantTheme get theme; FeatureFlags get features; Map<String, dynamic> get integrationKeys;
/// Create a copy of MerchantConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MerchantConfigCopyWith<MerchantConfig> get copyWith => _$MerchantConfigCopyWithImpl<MerchantConfig>(this as MerchantConfig, _$identity);

  /// Serializes this MerchantConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MerchantConfig&&(identical(other.merchantId, merchantId) || other.merchantId == merchantId)&&(identical(other.shopDomain, shopDomain) || other.shopDomain == shopDomain)&&(identical(other.storefrontToken, storefrontToken) || other.storefrontToken == storefrontToken)&&(identical(other.appName, appName) || other.appName == appName)&&(identical(other.theme, theme) || other.theme == theme)&&(identical(other.features, features) || other.features == features)&&const DeepCollectionEquality().equals(other.integrationKeys, integrationKeys));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,merchantId,shopDomain,storefrontToken,appName,theme,features,const DeepCollectionEquality().hash(integrationKeys));

@override
String toString() {
  return 'MerchantConfig(merchantId: $merchantId, shopDomain: $shopDomain, storefrontToken: $storefrontToken, appName: $appName, theme: $theme, features: $features, integrationKeys: $integrationKeys)';
}


}

/// @nodoc
abstract mixin class $MerchantConfigCopyWith<$Res>  {
  factory $MerchantConfigCopyWith(MerchantConfig value, $Res Function(MerchantConfig) _then) = _$MerchantConfigCopyWithImpl;
@useResult
$Res call({
 String merchantId, String shopDomain, String storefrontToken, String appName, MerchantTheme theme, FeatureFlags features, Map<String, dynamic> integrationKeys
});


$MerchantThemeCopyWith<$Res> get theme;$FeatureFlagsCopyWith<$Res> get features;

}
/// @nodoc
class _$MerchantConfigCopyWithImpl<$Res>
    implements $MerchantConfigCopyWith<$Res> {
  _$MerchantConfigCopyWithImpl(this._self, this._then);

  final MerchantConfig _self;
  final $Res Function(MerchantConfig) _then;

/// Create a copy of MerchantConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? merchantId = null,Object? shopDomain = null,Object? storefrontToken = null,Object? appName = null,Object? theme = null,Object? features = null,Object? integrationKeys = null,}) {
  return _then(_self.copyWith(
merchantId: null == merchantId ? _self.merchantId : merchantId // ignore: cast_nullable_to_non_nullable
as String,shopDomain: null == shopDomain ? _self.shopDomain : shopDomain // ignore: cast_nullable_to_non_nullable
as String,storefrontToken: null == storefrontToken ? _self.storefrontToken : storefrontToken // ignore: cast_nullable_to_non_nullable
as String,appName: null == appName ? _self.appName : appName // ignore: cast_nullable_to_non_nullable
as String,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as MerchantTheme,features: null == features ? _self.features : features // ignore: cast_nullable_to_non_nullable
as FeatureFlags,integrationKeys: null == integrationKeys ? _self.integrationKeys : integrationKeys // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}
/// Create a copy of MerchantConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MerchantThemeCopyWith<$Res> get theme {
  
  return $MerchantThemeCopyWith<$Res>(_self.theme, (value) {
    return _then(_self.copyWith(theme: value));
  });
}/// Create a copy of MerchantConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FeatureFlagsCopyWith<$Res> get features {
  
  return $FeatureFlagsCopyWith<$Res>(_self.features, (value) {
    return _then(_self.copyWith(features: value));
  });
}
}


/// Adds pattern-matching-related methods to [MerchantConfig].
extension MerchantConfigPatterns on MerchantConfig {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MerchantConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MerchantConfig() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MerchantConfig value)  $default,){
final _that = this;
switch (_that) {
case _MerchantConfig():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MerchantConfig value)?  $default,){
final _that = this;
switch (_that) {
case _MerchantConfig() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String merchantId,  String shopDomain,  String storefrontToken,  String appName,  MerchantTheme theme,  FeatureFlags features,  Map<String, dynamic> integrationKeys)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MerchantConfig() when $default != null:
return $default(_that.merchantId,_that.shopDomain,_that.storefrontToken,_that.appName,_that.theme,_that.features,_that.integrationKeys);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String merchantId,  String shopDomain,  String storefrontToken,  String appName,  MerchantTheme theme,  FeatureFlags features,  Map<String, dynamic> integrationKeys)  $default,) {final _that = this;
switch (_that) {
case _MerchantConfig():
return $default(_that.merchantId,_that.shopDomain,_that.storefrontToken,_that.appName,_that.theme,_that.features,_that.integrationKeys);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String merchantId,  String shopDomain,  String storefrontToken,  String appName,  MerchantTheme theme,  FeatureFlags features,  Map<String, dynamic> integrationKeys)?  $default,) {final _that = this;
switch (_that) {
case _MerchantConfig() when $default != null:
return $default(_that.merchantId,_that.shopDomain,_that.storefrontToken,_that.appName,_that.theme,_that.features,_that.integrationKeys);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MerchantConfig implements MerchantConfig {
  const _MerchantConfig({required this.merchantId, required this.shopDomain, required this.storefrontToken, required this.appName, required this.theme, required this.features, required final  Map<String, dynamic> integrationKeys}): _integrationKeys = integrationKeys;
  factory _MerchantConfig.fromJson(Map<String, dynamic> json) => _$MerchantConfigFromJson(json);

@override final  String merchantId;
@override final  String shopDomain;
@override final  String storefrontToken;
@override final  String appName;
@override final  MerchantTheme theme;
@override final  FeatureFlags features;
 final  Map<String, dynamic> _integrationKeys;
@override Map<String, dynamic> get integrationKeys {
  if (_integrationKeys is EqualUnmodifiableMapView) return _integrationKeys;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_integrationKeys);
}


/// Create a copy of MerchantConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MerchantConfigCopyWith<_MerchantConfig> get copyWith => __$MerchantConfigCopyWithImpl<_MerchantConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MerchantConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MerchantConfig&&(identical(other.merchantId, merchantId) || other.merchantId == merchantId)&&(identical(other.shopDomain, shopDomain) || other.shopDomain == shopDomain)&&(identical(other.storefrontToken, storefrontToken) || other.storefrontToken == storefrontToken)&&(identical(other.appName, appName) || other.appName == appName)&&(identical(other.theme, theme) || other.theme == theme)&&(identical(other.features, features) || other.features == features)&&const DeepCollectionEquality().equals(other._integrationKeys, _integrationKeys));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,merchantId,shopDomain,storefrontToken,appName,theme,features,const DeepCollectionEquality().hash(_integrationKeys));

@override
String toString() {
  return 'MerchantConfig(merchantId: $merchantId, shopDomain: $shopDomain, storefrontToken: $storefrontToken, appName: $appName, theme: $theme, features: $features, integrationKeys: $integrationKeys)';
}


}

/// @nodoc
abstract mixin class _$MerchantConfigCopyWith<$Res> implements $MerchantConfigCopyWith<$Res> {
  factory _$MerchantConfigCopyWith(_MerchantConfig value, $Res Function(_MerchantConfig) _then) = __$MerchantConfigCopyWithImpl;
@override @useResult
$Res call({
 String merchantId, String shopDomain, String storefrontToken, String appName, MerchantTheme theme, FeatureFlags features, Map<String, dynamic> integrationKeys
});


@override $MerchantThemeCopyWith<$Res> get theme;@override $FeatureFlagsCopyWith<$Res> get features;

}
/// @nodoc
class __$MerchantConfigCopyWithImpl<$Res>
    implements _$MerchantConfigCopyWith<$Res> {
  __$MerchantConfigCopyWithImpl(this._self, this._then);

  final _MerchantConfig _self;
  final $Res Function(_MerchantConfig) _then;

/// Create a copy of MerchantConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? merchantId = null,Object? shopDomain = null,Object? storefrontToken = null,Object? appName = null,Object? theme = null,Object? features = null,Object? integrationKeys = null,}) {
  return _then(_MerchantConfig(
merchantId: null == merchantId ? _self.merchantId : merchantId // ignore: cast_nullable_to_non_nullable
as String,shopDomain: null == shopDomain ? _self.shopDomain : shopDomain // ignore: cast_nullable_to_non_nullable
as String,storefrontToken: null == storefrontToken ? _self.storefrontToken : storefrontToken // ignore: cast_nullable_to_non_nullable
as String,appName: null == appName ? _self.appName : appName // ignore: cast_nullable_to_non_nullable
as String,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as MerchantTheme,features: null == features ? _self.features : features // ignore: cast_nullable_to_non_nullable
as FeatureFlags,integrationKeys: null == integrationKeys ? _self._integrationKeys : integrationKeys // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

/// Create a copy of MerchantConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MerchantThemeCopyWith<$Res> get theme {
  
  return $MerchantThemeCopyWith<$Res>(_self.theme, (value) {
    return _then(_self.copyWith(theme: value));
  });
}/// Create a copy of MerchantConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FeatureFlagsCopyWith<$Res> get features {
  
  return $FeatureFlagsCopyWith<$Res>(_self.features, (value) {
    return _then(_self.copyWith(features: value));
  });
}
}


/// @nodoc
mixin _$MerchantTheme {

 String get primaryColor; String get secondaryColor; String get fontFamily; String get logoUrl;
/// Create a copy of MerchantTheme
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MerchantThemeCopyWith<MerchantTheme> get copyWith => _$MerchantThemeCopyWithImpl<MerchantTheme>(this as MerchantTheme, _$identity);

  /// Serializes this MerchantTheme to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MerchantTheme&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor)&&(identical(other.secondaryColor, secondaryColor) || other.secondaryColor == secondaryColor)&&(identical(other.fontFamily, fontFamily) || other.fontFamily == fontFamily)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,primaryColor,secondaryColor,fontFamily,logoUrl);

@override
String toString() {
  return 'MerchantTheme(primaryColor: $primaryColor, secondaryColor: $secondaryColor, fontFamily: $fontFamily, logoUrl: $logoUrl)';
}


}

/// @nodoc
abstract mixin class $MerchantThemeCopyWith<$Res>  {
  factory $MerchantThemeCopyWith(MerchantTheme value, $Res Function(MerchantTheme) _then) = _$MerchantThemeCopyWithImpl;
@useResult
$Res call({
 String primaryColor, String secondaryColor, String fontFamily, String logoUrl
});




}
/// @nodoc
class _$MerchantThemeCopyWithImpl<$Res>
    implements $MerchantThemeCopyWith<$Res> {
  _$MerchantThemeCopyWithImpl(this._self, this._then);

  final MerchantTheme _self;
  final $Res Function(MerchantTheme) _then;

/// Create a copy of MerchantTheme
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? primaryColor = null,Object? secondaryColor = null,Object? fontFamily = null,Object? logoUrl = null,}) {
  return _then(_self.copyWith(
primaryColor: null == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as String,secondaryColor: null == secondaryColor ? _self.secondaryColor : secondaryColor // ignore: cast_nullable_to_non_nullable
as String,fontFamily: null == fontFamily ? _self.fontFamily : fontFamily // ignore: cast_nullable_to_non_nullable
as String,logoUrl: null == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MerchantTheme].
extension MerchantThemePatterns on MerchantTheme {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MerchantTheme value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MerchantTheme() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MerchantTheme value)  $default,){
final _that = this;
switch (_that) {
case _MerchantTheme():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MerchantTheme value)?  $default,){
final _that = this;
switch (_that) {
case _MerchantTheme() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String primaryColor,  String secondaryColor,  String fontFamily,  String logoUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MerchantTheme() when $default != null:
return $default(_that.primaryColor,_that.secondaryColor,_that.fontFamily,_that.logoUrl);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String primaryColor,  String secondaryColor,  String fontFamily,  String logoUrl)  $default,) {final _that = this;
switch (_that) {
case _MerchantTheme():
return $default(_that.primaryColor,_that.secondaryColor,_that.fontFamily,_that.logoUrl);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String primaryColor,  String secondaryColor,  String fontFamily,  String logoUrl)?  $default,) {final _that = this;
switch (_that) {
case _MerchantTheme() when $default != null:
return $default(_that.primaryColor,_that.secondaryColor,_that.fontFamily,_that.logoUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MerchantTheme implements MerchantTheme {
  const _MerchantTheme({required this.primaryColor, required this.secondaryColor, required this.fontFamily, required this.logoUrl});
  factory _MerchantTheme.fromJson(Map<String, dynamic> json) => _$MerchantThemeFromJson(json);

@override final  String primaryColor;
@override final  String secondaryColor;
@override final  String fontFamily;
@override final  String logoUrl;

/// Create a copy of MerchantTheme
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MerchantThemeCopyWith<_MerchantTheme> get copyWith => __$MerchantThemeCopyWithImpl<_MerchantTheme>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MerchantThemeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MerchantTheme&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor)&&(identical(other.secondaryColor, secondaryColor) || other.secondaryColor == secondaryColor)&&(identical(other.fontFamily, fontFamily) || other.fontFamily == fontFamily)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,primaryColor,secondaryColor,fontFamily,logoUrl);

@override
String toString() {
  return 'MerchantTheme(primaryColor: $primaryColor, secondaryColor: $secondaryColor, fontFamily: $fontFamily, logoUrl: $logoUrl)';
}


}

/// @nodoc
abstract mixin class _$MerchantThemeCopyWith<$Res> implements $MerchantThemeCopyWith<$Res> {
  factory _$MerchantThemeCopyWith(_MerchantTheme value, $Res Function(_MerchantTheme) _then) = __$MerchantThemeCopyWithImpl;
@override @useResult
$Res call({
 String primaryColor, String secondaryColor, String fontFamily, String logoUrl
});




}
/// @nodoc
class __$MerchantThemeCopyWithImpl<$Res>
    implements _$MerchantThemeCopyWith<$Res> {
  __$MerchantThemeCopyWithImpl(this._self, this._then);

  final _MerchantTheme _self;
  final $Res Function(_MerchantTheme) _then;

/// Create a copy of MerchantTheme
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? primaryColor = null,Object? secondaryColor = null,Object? fontFamily = null,Object? logoUrl = null,}) {
  return _then(_MerchantTheme(
primaryColor: null == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as String,secondaryColor: null == secondaryColor ? _self.secondaryColor : secondaryColor // ignore: cast_nullable_to_non_nullable
as String,fontFamily: null == fontFamily ? _self.fontFamily : fontFamily // ignore: cast_nullable_to_non_nullable
as String,logoUrl: null == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$FeatureFlags {

 bool get useNativeCheckout; bool get enableWishlist; bool get enableSocialLogin;
/// Create a copy of FeatureFlags
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeatureFlagsCopyWith<FeatureFlags> get copyWith => _$FeatureFlagsCopyWithImpl<FeatureFlags>(this as FeatureFlags, _$identity);

  /// Serializes this FeatureFlags to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeatureFlags&&(identical(other.useNativeCheckout, useNativeCheckout) || other.useNativeCheckout == useNativeCheckout)&&(identical(other.enableWishlist, enableWishlist) || other.enableWishlist == enableWishlist)&&(identical(other.enableSocialLogin, enableSocialLogin) || other.enableSocialLogin == enableSocialLogin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,useNativeCheckout,enableWishlist,enableSocialLogin);

@override
String toString() {
  return 'FeatureFlags(useNativeCheckout: $useNativeCheckout, enableWishlist: $enableWishlist, enableSocialLogin: $enableSocialLogin)';
}


}

/// @nodoc
abstract mixin class $FeatureFlagsCopyWith<$Res>  {
  factory $FeatureFlagsCopyWith(FeatureFlags value, $Res Function(FeatureFlags) _then) = _$FeatureFlagsCopyWithImpl;
@useResult
$Res call({
 bool useNativeCheckout, bool enableWishlist, bool enableSocialLogin
});




}
/// @nodoc
class _$FeatureFlagsCopyWithImpl<$Res>
    implements $FeatureFlagsCopyWith<$Res> {
  _$FeatureFlagsCopyWithImpl(this._self, this._then);

  final FeatureFlags _self;
  final $Res Function(FeatureFlags) _then;

/// Create a copy of FeatureFlags
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? useNativeCheckout = null,Object? enableWishlist = null,Object? enableSocialLogin = null,}) {
  return _then(_self.copyWith(
useNativeCheckout: null == useNativeCheckout ? _self.useNativeCheckout : useNativeCheckout // ignore: cast_nullable_to_non_nullable
as bool,enableWishlist: null == enableWishlist ? _self.enableWishlist : enableWishlist // ignore: cast_nullable_to_non_nullable
as bool,enableSocialLogin: null == enableSocialLogin ? _self.enableSocialLogin : enableSocialLogin // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FeatureFlags].
extension FeatureFlagsPatterns on FeatureFlags {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeatureFlags value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeatureFlags() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeatureFlags value)  $default,){
final _that = this;
switch (_that) {
case _FeatureFlags():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeatureFlags value)?  $default,){
final _that = this;
switch (_that) {
case _FeatureFlags() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool useNativeCheckout,  bool enableWishlist,  bool enableSocialLogin)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeatureFlags() when $default != null:
return $default(_that.useNativeCheckout,_that.enableWishlist,_that.enableSocialLogin);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool useNativeCheckout,  bool enableWishlist,  bool enableSocialLogin)  $default,) {final _that = this;
switch (_that) {
case _FeatureFlags():
return $default(_that.useNativeCheckout,_that.enableWishlist,_that.enableSocialLogin);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool useNativeCheckout,  bool enableWishlist,  bool enableSocialLogin)?  $default,) {final _that = this;
switch (_that) {
case _FeatureFlags() when $default != null:
return $default(_that.useNativeCheckout,_that.enableWishlist,_that.enableSocialLogin);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FeatureFlags implements FeatureFlags {
  const _FeatureFlags({this.useNativeCheckout = false, this.enableWishlist = false, this.enableSocialLogin = false});
  factory _FeatureFlags.fromJson(Map<String, dynamic> json) => _$FeatureFlagsFromJson(json);

@override@JsonKey() final  bool useNativeCheckout;
@override@JsonKey() final  bool enableWishlist;
@override@JsonKey() final  bool enableSocialLogin;

/// Create a copy of FeatureFlags
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeatureFlagsCopyWith<_FeatureFlags> get copyWith => __$FeatureFlagsCopyWithImpl<_FeatureFlags>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FeatureFlagsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeatureFlags&&(identical(other.useNativeCheckout, useNativeCheckout) || other.useNativeCheckout == useNativeCheckout)&&(identical(other.enableWishlist, enableWishlist) || other.enableWishlist == enableWishlist)&&(identical(other.enableSocialLogin, enableSocialLogin) || other.enableSocialLogin == enableSocialLogin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,useNativeCheckout,enableWishlist,enableSocialLogin);

@override
String toString() {
  return 'FeatureFlags(useNativeCheckout: $useNativeCheckout, enableWishlist: $enableWishlist, enableSocialLogin: $enableSocialLogin)';
}


}

/// @nodoc
abstract mixin class _$FeatureFlagsCopyWith<$Res> implements $FeatureFlagsCopyWith<$Res> {
  factory _$FeatureFlagsCopyWith(_FeatureFlags value, $Res Function(_FeatureFlags) _then) = __$FeatureFlagsCopyWithImpl;
@override @useResult
$Res call({
 bool useNativeCheckout, bool enableWishlist, bool enableSocialLogin
});




}
/// @nodoc
class __$FeatureFlagsCopyWithImpl<$Res>
    implements _$FeatureFlagsCopyWith<$Res> {
  __$FeatureFlagsCopyWithImpl(this._self, this._then);

  final _FeatureFlags _self;
  final $Res Function(_FeatureFlags) _then;

/// Create a copy of FeatureFlags
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? useNativeCheckout = null,Object? enableWishlist = null,Object? enableSocialLogin = null,}) {
  return _then(_FeatureFlags(
useNativeCheckout: null == useNativeCheckout ? _self.useNativeCheckout : useNativeCheckout // ignore: cast_nullable_to_non_nullable
as bool,enableWishlist: null == enableWishlist ? _self.enableWishlist : enableWishlist // ignore: cast_nullable_to_non_nullable
as bool,enableSocialLogin: null == enableSocialLogin ? _self.enableSocialLogin : enableSocialLogin // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
