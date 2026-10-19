// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../theme_color.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DaisyThemeColor {

/// Default surface and stepped surfaces (app background, cards).
 DaisyThemeColorPair get base;/// Primary brand color and its foreground.
 DaisyThemeColorPair get primary;/// Secondary brand color and its foreground.
 DaisyThemeColorPair get secondary;/// Accent color and its foreground.
 DaisyThemeColorPair get accent;/// Low-emphasis surfaces (muted, disabled) and their foreground.
 DaisyThemeColorPair get neutral;/// Informative states and their foreground.
 DaisyThemeColorPair get info;/// Positive/success states and their foreground.
 DaisyThemeColorPair get success;/// Negative/error states and their foreground.
 DaisyThemeColorPair get error;/// Warning states and their foreground.
 DaisyThemeColorPair get warning;/// Destructive actions and their foreground. Reuses [error] values
/// when the source theme does not define it.
 DaisyThemeColorPair get danger;
/// Create a copy of DaisyThemeColor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DaisyThemeColorCopyWith<DaisyThemeColor> get copyWith => _$DaisyThemeColorCopyWithImpl<DaisyThemeColor>(this as DaisyThemeColor, _$identity);

  /// Serializes this DaisyThemeColor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DaisyThemeColor;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DaisyThemeColor&&(identical(other.base, _this.base) || other.base == _this.base)&&(identical(other.primary, _this.primary) || other.primary == _this.primary)&&(identical(other.secondary, _this.secondary) || other.secondary == _this.secondary)&&(identical(other.accent, _this.accent) || other.accent == _this.accent)&&(identical(other.neutral, _this.neutral) || other.neutral == _this.neutral)&&(identical(other.info, _this.info) || other.info == _this.info)&&(identical(other.success, _this.success) || other.success == _this.success)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.warning, _this.warning) || other.warning == _this.warning)&&(identical(other.danger, _this.danger) || other.danger == _this.danger));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DaisyThemeColor;
  return Object.hash(runtimeType,_this.base,_this.primary,_this.secondary,_this.accent,_this.neutral,_this.info,_this.success,_this.error,_this.warning,_this.danger);
}

@override
String toString() {
  final _this = this as DaisyThemeColor;
  return 'DaisyThemeColor(base: ${_this.base}, primary: ${_this.primary}, secondary: ${_this.secondary}, accent: ${_this.accent}, neutral: ${_this.neutral}, info: ${_this.info}, success: ${_this.success}, error: ${_this.error}, warning: ${_this.warning}, danger: ${_this.danger})';
}


}

/// @nodoc
abstract mixin class $DaisyThemeColorCopyWith<$Res>  {
  factory $DaisyThemeColorCopyWith(DaisyThemeColor value, $Res Function(DaisyThemeColor) _then) = _$DaisyThemeColorCopyWithImpl;
@useResult
$Res call({
 DaisyThemeColorPair base, DaisyThemeColorPair primary, DaisyThemeColorPair secondary, DaisyThemeColorPair accent, DaisyThemeColorPair neutral, DaisyThemeColorPair info, DaisyThemeColorPair success, DaisyThemeColorPair error, DaisyThemeColorPair warning, DaisyThemeColorPair danger
});


$DaisyThemeColorPairCopyWith<$Res> get base;$DaisyThemeColorPairCopyWith<$Res> get primary;$DaisyThemeColorPairCopyWith<$Res> get secondary;$DaisyThemeColorPairCopyWith<$Res> get accent;$DaisyThemeColorPairCopyWith<$Res> get neutral;$DaisyThemeColorPairCopyWith<$Res> get info;$DaisyThemeColorPairCopyWith<$Res> get success;$DaisyThemeColorPairCopyWith<$Res> get error;$DaisyThemeColorPairCopyWith<$Res> get warning;$DaisyThemeColorPairCopyWith<$Res> get danger;

}
/// @nodoc
class _$DaisyThemeColorCopyWithImpl<$Res>
    implements $DaisyThemeColorCopyWith<$Res> {
  _$DaisyThemeColorCopyWithImpl(this._self, this._then);

  final DaisyThemeColor _self;
  final $Res Function(DaisyThemeColor) _then;

/// Create a copy of DaisyThemeColor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? base = null,Object? primary = null,Object? secondary = null,Object? accent = null,Object? neutral = null,Object? info = null,Object? success = null,Object? error = null,Object? warning = null,Object? danger = null,}) {
  return _then(DaisyThemeColor(
base: null == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as DaisyThemeColorPair,primary: null == primary ? _self.primary : primary // ignore: cast_nullable_to_non_nullable
as DaisyThemeColorPair,secondary: null == secondary ? _self.secondary : secondary // ignore: cast_nullable_to_non_nullable
as DaisyThemeColorPair,accent: null == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as DaisyThemeColorPair,neutral: null == neutral ? _self.neutral : neutral // ignore: cast_nullable_to_non_nullable
as DaisyThemeColorPair,info: null == info ? _self.info : info // ignore: cast_nullable_to_non_nullable
as DaisyThemeColorPair,success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as DaisyThemeColorPair,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as DaisyThemeColorPair,warning: null == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as DaisyThemeColorPair,danger: null == danger ? _self.danger : danger // ignore: cast_nullable_to_non_nullable
as DaisyThemeColorPair,
  ));
}
/// Create a copy of DaisyThemeColor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DaisyThemeColorPairCopyWith<$Res> get base {
  
  return $DaisyThemeColorPairCopyWith<$Res>(_self.base, (value) {
    return _then(_self.copyWith(base: value));
  });
}/// Create a copy of DaisyThemeColor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DaisyThemeColorPairCopyWith<$Res> get primary {
  
  return $DaisyThemeColorPairCopyWith<$Res>(_self.primary, (value) {
    return _then(_self.copyWith(primary: value));
  });
}/// Create a copy of DaisyThemeColor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DaisyThemeColorPairCopyWith<$Res> get secondary {
  
  return $DaisyThemeColorPairCopyWith<$Res>(_self.secondary, (value) {
    return _then(_self.copyWith(secondary: value));
  });
}/// Create a copy of DaisyThemeColor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DaisyThemeColorPairCopyWith<$Res> get accent {
  
  return $DaisyThemeColorPairCopyWith<$Res>(_self.accent, (value) {
    return _then(_self.copyWith(accent: value));
  });
}/// Create a copy of DaisyThemeColor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DaisyThemeColorPairCopyWith<$Res> get neutral {
  
  return $DaisyThemeColorPairCopyWith<$Res>(_self.neutral, (value) {
    return _then(_self.copyWith(neutral: value));
  });
}/// Create a copy of DaisyThemeColor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DaisyThemeColorPairCopyWith<$Res> get info {
  
  return $DaisyThemeColorPairCopyWith<$Res>(_self.info, (value) {
    return _then(_self.copyWith(info: value));
  });
}/// Create a copy of DaisyThemeColor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DaisyThemeColorPairCopyWith<$Res> get success {
  
  return $DaisyThemeColorPairCopyWith<$Res>(_self.success, (value) {
    return _then(_self.copyWith(success: value));
  });
}/// Create a copy of DaisyThemeColor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DaisyThemeColorPairCopyWith<$Res> get error {
  
  return $DaisyThemeColorPairCopyWith<$Res>(_self.error, (value) {
    return _then(_self.copyWith(error: value));
  });
}/// Create a copy of DaisyThemeColor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DaisyThemeColorPairCopyWith<$Res> get warning {
  
  return $DaisyThemeColorPairCopyWith<$Res>(_self.warning, (value) {
    return _then(_self.copyWith(warning: value));
  });
}/// Create a copy of DaisyThemeColor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DaisyThemeColorPairCopyWith<$Res> get danger {
  
  return $DaisyThemeColorPairCopyWith<$Res>(_self.danger, (value) {
    return _then(_self.copyWith(danger: value));
  });
}
}


/// Adds pattern-matching-related methods to [DaisyThemeColor].
extension DaisyThemeColorPatterns on DaisyThemeColor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DaisyThemeColor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DaisyThemeColor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DaisyThemeColor value)  $default,){
final _that = this;
switch (_that) {
case _DaisyThemeColor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DaisyThemeColor value)?  $default,){
final _that = this;
switch (_that) {
case _DaisyThemeColor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DaisyThemeColorPair base,  DaisyThemeColorPair primary,  DaisyThemeColorPair secondary,  DaisyThemeColorPair accent,  DaisyThemeColorPair neutral,  DaisyThemeColorPair info,  DaisyThemeColorPair success,  DaisyThemeColorPair error,  DaisyThemeColorPair warning,  DaisyThemeColorPair danger)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DaisyThemeColor() when $default != null:
return $default(_that.base,_that.primary,_that.secondary,_that.accent,_that.neutral,_that.info,_that.success,_that.error,_that.warning,_that.danger);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DaisyThemeColorPair base,  DaisyThemeColorPair primary,  DaisyThemeColorPair secondary,  DaisyThemeColorPair accent,  DaisyThemeColorPair neutral,  DaisyThemeColorPair info,  DaisyThemeColorPair success,  DaisyThemeColorPair error,  DaisyThemeColorPair warning,  DaisyThemeColorPair danger)  $default,) {final _that = this;
switch (_that) {
case _DaisyThemeColor():
return $default(_that.base,_that.primary,_that.secondary,_that.accent,_that.neutral,_that.info,_that.success,_that.error,_that.warning,_that.danger);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DaisyThemeColorPair base,  DaisyThemeColorPair primary,  DaisyThemeColorPair secondary,  DaisyThemeColorPair accent,  DaisyThemeColorPair neutral,  DaisyThemeColorPair info,  DaisyThemeColorPair success,  DaisyThemeColorPair error,  DaisyThemeColorPair warning,  DaisyThemeColorPair danger)?  $default,) {final _that = this;
switch (_that) {
case _DaisyThemeColor() when $default != null:
return $default(_that.base,_that.primary,_that.secondary,_that.accent,_that.neutral,_that.info,_that.success,_that.error,_that.warning,_that.danger);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DaisyThemeColor implements DaisyThemeColor {
  const _DaisyThemeColor({required this.base, required this.primary, required this.secondary, required this.accent, required this.neutral, required this.info, required this.success, required this.error, required this.warning, required this.danger});
  factory _DaisyThemeColor.fromJson(Map<String, dynamic> json) => _$DaisyThemeColorFromJson(json);

/// Default surface and stepped surfaces (app background, cards).
@override final  DaisyThemeColorPair base;
/// Primary brand color and its foreground.
@override final  DaisyThemeColorPair primary;
/// Secondary brand color and its foreground.
@override final  DaisyThemeColorPair secondary;
/// Accent color and its foreground.
@override final  DaisyThemeColorPair accent;
/// Low-emphasis surfaces (muted, disabled) and their foreground.
@override final  DaisyThemeColorPair neutral;
/// Informative states and their foreground.
@override final  DaisyThemeColorPair info;
/// Positive/success states and their foreground.
@override final  DaisyThemeColorPair success;
/// Negative/error states and their foreground.
@override final  DaisyThemeColorPair error;
/// Warning states and their foreground.
@override final  DaisyThemeColorPair warning;
/// Destructive actions and their foreground. Reuses [error] values
/// when the source theme does not define it.
@override final  DaisyThemeColorPair danger;

/// Create a copy of DaisyThemeColor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DaisyThemeColorCopyWith<_DaisyThemeColor> get copyWith => __$DaisyThemeColorCopyWithImpl<_DaisyThemeColor>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DaisyThemeColorToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DaisyThemeColor&&(identical(other.base, base) || other.base == base)&&(identical(other.primary, primary) || other.primary == primary)&&(identical(other.secondary, secondary) || other.secondary == secondary)&&(identical(other.accent, accent) || other.accent == accent)&&(identical(other.neutral, neutral) || other.neutral == neutral)&&(identical(other.info, info) || other.info == info)&&(identical(other.success, success) || other.success == success)&&(identical(other.error, error) || other.error == error)&&(identical(other.warning, warning) || other.warning == warning)&&(identical(other.danger, danger) || other.danger == danger));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,base,primary,secondary,accent,neutral,info,success,error,warning,danger);
}

@override
String toString() {
    return 'DaisyThemeColor(base: $base, primary: $primary, secondary: $secondary, accent: $accent, neutral: $neutral, info: $info, success: $success, error: $error, warning: $warning, danger: $danger)';
}


}

/// @nodoc
abstract mixin class _$DaisyThemeColorCopyWith<$Res> implements $DaisyThemeColorCopyWith<$Res> {
  factory _$DaisyThemeColorCopyWith(_DaisyThemeColor value, $Res Function(_DaisyThemeColor) _then) = __$DaisyThemeColorCopyWithImpl;
@override @useResult
$Res call({
 DaisyThemeColorPair base, DaisyThemeColorPair primary, DaisyThemeColorPair secondary, DaisyThemeColorPair accent, DaisyThemeColorPair neutral, DaisyThemeColorPair info, DaisyThemeColorPair success, DaisyThemeColorPair error, DaisyThemeColorPair warning, DaisyThemeColorPair danger
});


@override $DaisyThemeColorPairCopyWith<$Res> get base;@override $DaisyThemeColorPairCopyWith<$Res> get primary;@override $DaisyThemeColorPairCopyWith<$Res> get secondary;@override $DaisyThemeColorPairCopyWith<$Res> get accent;@override $DaisyThemeColorPairCopyWith<$Res> get neutral;@override $DaisyThemeColorPairCopyWith<$Res> get info;@override $DaisyThemeColorPairCopyWith<$Res> get success;@override $DaisyThemeColorPairCopyWith<$Res> get error;@override $DaisyThemeColorPairCopyWith<$Res> get warning;@override $DaisyThemeColorPairCopyWith<$Res> get danger;

}
/// @nodoc
class __$DaisyThemeColorCopyWithImpl<$Res>
    implements _$DaisyThemeColorCopyWith<$Res> {
  __$DaisyThemeColorCopyWithImpl(this._self, this._then);

  final _DaisyThemeColor _self;
  final $Res Function(_DaisyThemeColor) _then;

/// Create a copy of DaisyThemeColor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? base = null,Object? primary = null,Object? secondary = null,Object? accent = null,Object? neutral = null,Object? info = null,Object? success = null,Object? error = null,Object? warning = null,Object? danger = null,}) {
  return _then(_DaisyThemeColor(
base: null == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as DaisyThemeColorPair,primary: null == primary ? _self.primary : primary // ignore: cast_nullable_to_non_nullable
as DaisyThemeColorPair,secondary: null == secondary ? _self.secondary : secondary // ignore: cast_nullable_to_non_nullable
as DaisyThemeColorPair,accent: null == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as DaisyThemeColorPair,neutral: null == neutral ? _self.neutral : neutral // ignore: cast_nullable_to_non_nullable
as DaisyThemeColorPair,info: null == info ? _self.info : info // ignore: cast_nullable_to_non_nullable
as DaisyThemeColorPair,success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as DaisyThemeColorPair,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as DaisyThemeColorPair,warning: null == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as DaisyThemeColorPair,danger: null == danger ? _self.danger : danger // ignore: cast_nullable_to_non_nullable
as DaisyThemeColorPair,
  ));
}

/// Create a copy of DaisyThemeColor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DaisyThemeColorPairCopyWith<$Res> get base {
  
  return $DaisyThemeColorPairCopyWith<$Res>(_self.base, (value) {
    return _then(_self.copyWith(base: value));
  });
}/// Create a copy of DaisyThemeColor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DaisyThemeColorPairCopyWith<$Res> get primary {
  
  return $DaisyThemeColorPairCopyWith<$Res>(_self.primary, (value) {
    return _then(_self.copyWith(primary: value));
  });
}/// Create a copy of DaisyThemeColor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DaisyThemeColorPairCopyWith<$Res> get secondary {
  
  return $DaisyThemeColorPairCopyWith<$Res>(_self.secondary, (value) {
    return _then(_self.copyWith(secondary: value));
  });
}/// Create a copy of DaisyThemeColor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DaisyThemeColorPairCopyWith<$Res> get accent {
  
  return $DaisyThemeColorPairCopyWith<$Res>(_self.accent, (value) {
    return _then(_self.copyWith(accent: value));
  });
}/// Create a copy of DaisyThemeColor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DaisyThemeColorPairCopyWith<$Res> get neutral {
  
  return $DaisyThemeColorPairCopyWith<$Res>(_self.neutral, (value) {
    return _then(_self.copyWith(neutral: value));
  });
}/// Create a copy of DaisyThemeColor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DaisyThemeColorPairCopyWith<$Res> get info {
  
  return $DaisyThemeColorPairCopyWith<$Res>(_self.info, (value) {
    return _then(_self.copyWith(info: value));
  });
}/// Create a copy of DaisyThemeColor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DaisyThemeColorPairCopyWith<$Res> get success {
  
  return $DaisyThemeColorPairCopyWith<$Res>(_self.success, (value) {
    return _then(_self.copyWith(success: value));
  });
}/// Create a copy of DaisyThemeColor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DaisyThemeColorPairCopyWith<$Res> get error {
  
  return $DaisyThemeColorPairCopyWith<$Res>(_self.error, (value) {
    return _then(_self.copyWith(error: value));
  });
}/// Create a copy of DaisyThemeColor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DaisyThemeColorPairCopyWith<$Res> get warning {
  
  return $DaisyThemeColorPairCopyWith<$Res>(_self.warning, (value) {
    return _then(_self.copyWith(warning: value));
  });
}/// Create a copy of DaisyThemeColor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DaisyThemeColorPairCopyWith<$Res> get danger {
  
  return $DaisyThemeColorPairCopyWith<$Res>(_self.danger, (value) {
    return _then(_self.copyWith(danger: value));
  });
}
}


/// @nodoc
mixin _$DaisyThemeColorPair {

/// Main surface color of the role.
 RayOklch get base;/// Foreground (text/icon) color readable on top of [base].
 RayOklch get content;/// Second stepped surface (`base-200`). Only set on the
/// [DaisyThemeColor.base] role; `null` on every other role.
 RayOklch? get base200;/// Third stepped surface (`base-300`). Only set on the
/// [DaisyThemeColor.base] role; `null` on every other role.
 RayOklch? get base300;
/// Create a copy of DaisyThemeColorPair
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DaisyThemeColorPairCopyWith<DaisyThemeColorPair> get copyWith => _$DaisyThemeColorPairCopyWithImpl<DaisyThemeColorPair>(this as DaisyThemeColorPair, _$identity);

  /// Serializes this DaisyThemeColorPair to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DaisyThemeColorPair;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DaisyThemeColorPair&&(identical(other.base, _this.base) || other.base == _this.base)&&(identical(other.content, _this.content) || other.content == _this.content)&&(identical(other.base200, _this.base200) || other.base200 == _this.base200)&&(identical(other.base300, _this.base300) || other.base300 == _this.base300));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DaisyThemeColorPair;
  return Object.hash(runtimeType,_this.base,_this.content,_this.base200,_this.base300);
}

@override
String toString() {
  final _this = this as DaisyThemeColorPair;
  return 'DaisyThemeColorPair(base: ${_this.base}, content: ${_this.content}, base200: ${_this.base200}, base300: ${_this.base300})';
}


}

/// @nodoc
abstract mixin class $DaisyThemeColorPairCopyWith<$Res>  {
  factory $DaisyThemeColorPairCopyWith(DaisyThemeColorPair value, $Res Function(DaisyThemeColorPair) _then) = _$DaisyThemeColorPairCopyWithImpl;
@useResult
$Res call({
 RayOklch base, RayOklch content, RayOklch? base200, RayOklch? base300
});




}
/// @nodoc
class _$DaisyThemeColorPairCopyWithImpl<$Res>
    implements $DaisyThemeColorPairCopyWith<$Res> {
  _$DaisyThemeColorPairCopyWithImpl(this._self, this._then);

  final DaisyThemeColorPair _self;
  final $Res Function(DaisyThemeColorPair) _then;

/// Create a copy of DaisyThemeColorPair
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? base = null,Object? content = null,Object? base200 = freezed,Object? base300 = freezed,}) {
  return _then(DaisyThemeColorPair(
base: null == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as RayOklch,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as RayOklch,base200: freezed == base200 ? _self.base200 : base200 // ignore: cast_nullable_to_non_nullable
as RayOklch?,base300: freezed == base300 ? _self.base300 : base300 // ignore: cast_nullable_to_non_nullable
as RayOklch?,
  ));
}

}


/// Adds pattern-matching-related methods to [DaisyThemeColorPair].
extension DaisyThemeColorPairPatterns on DaisyThemeColorPair {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DaisyThemeColorPair value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DaisyThemeColorPair() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DaisyThemeColorPair value)  $default,){
final _that = this;
switch (_that) {
case _DaisyThemeColorPair():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DaisyThemeColorPair value)?  $default,){
final _that = this;
switch (_that) {
case _DaisyThemeColorPair() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RayOklch base,  RayOklch content,  RayOklch? base200,  RayOklch? base300)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DaisyThemeColorPair() when $default != null:
return $default(_that.base,_that.content,_that.base200,_that.base300);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RayOklch base,  RayOklch content,  RayOklch? base200,  RayOklch? base300)  $default,) {final _that = this;
switch (_that) {
case _DaisyThemeColorPair():
return $default(_that.base,_that.content,_that.base200,_that.base300);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RayOklch base,  RayOklch content,  RayOklch? base200,  RayOklch? base300)?  $default,) {final _that = this;
switch (_that) {
case _DaisyThemeColorPair() when $default != null:
return $default(_that.base,_that.content,_that.base200,_that.base300);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DaisyThemeColorPair implements DaisyThemeColorPair {
  const _DaisyThemeColorPair({required this.base, required this.content, this.base200, this.base300});
  factory _DaisyThemeColorPair.fromJson(Map<String, dynamic> json) => _$DaisyThemeColorPairFromJson(json);

/// Main surface color of the role.
@override final  RayOklch base;
/// Foreground (text/icon) color readable on top of [base].
@override final  RayOklch content;
/// Second stepped surface (`base-200`). Only set on the
/// [DaisyThemeColor.base] role; `null` on every other role.
@override final  RayOklch? base200;
/// Third stepped surface (`base-300`). Only set on the
/// [DaisyThemeColor.base] role; `null` on every other role.
@override final  RayOklch? base300;

/// Create a copy of DaisyThemeColorPair
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DaisyThemeColorPairCopyWith<_DaisyThemeColorPair> get copyWith => __$DaisyThemeColorPairCopyWithImpl<_DaisyThemeColorPair>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DaisyThemeColorPairToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DaisyThemeColorPair&&(identical(other.base, base) || other.base == base)&&(identical(other.content, content) || other.content == content)&&(identical(other.base200, base200) || other.base200 == base200)&&(identical(other.base300, base300) || other.base300 == base300));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,base,content,base200,base300);
}

@override
String toString() {
    return 'DaisyThemeColorPair(base: $base, content: $content, base200: $base200, base300: $base300)';
}


}

/// @nodoc
abstract mixin class _$DaisyThemeColorPairCopyWith<$Res> implements $DaisyThemeColorPairCopyWith<$Res> {
  factory _$DaisyThemeColorPairCopyWith(_DaisyThemeColorPair value, $Res Function(_DaisyThemeColorPair) _then) = __$DaisyThemeColorPairCopyWithImpl;
@override @useResult
$Res call({
 RayOklch base, RayOklch content, RayOklch? base200, RayOklch? base300
});




}
/// @nodoc
class __$DaisyThemeColorPairCopyWithImpl<$Res>
    implements _$DaisyThemeColorPairCopyWith<$Res> {
  __$DaisyThemeColorPairCopyWithImpl(this._self, this._then);

  final _DaisyThemeColorPair _self;
  final $Res Function(_DaisyThemeColorPair) _then;

/// Create a copy of DaisyThemeColorPair
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? base = null,Object? content = null,Object? base200 = freezed,Object? base300 = freezed,}) {
  return _then(_DaisyThemeColorPair(
base: null == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as RayOklch,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as RayOklch,base200: freezed == base200 ? _self.base200 : base200 // ignore: cast_nullable_to_non_nullable
as RayOklch?,base300: freezed == base300 ? _self.base300 : base300 // ignore: cast_nullable_to_non_nullable
as RayOklch?,
  ));
}


}

// dart format on
