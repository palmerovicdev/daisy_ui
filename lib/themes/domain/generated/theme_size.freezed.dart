// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../theme_size.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DaisyThemeSize {

/// Buttons, inputs, selects, tabs.
 DaisyThemeSizeConfig get fields;/// Checkboxes, toggles, badges.
 DaisyThemeSizeConfig get selectors;
/// Create a copy of DaisyThemeSize
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DaisyThemeSizeCopyWith<DaisyThemeSize> get copyWith => _$DaisyThemeSizeCopyWithImpl<DaisyThemeSize>(this as DaisyThemeSize, _$identity);

  /// Serializes this DaisyThemeSize to a JSON map.
  Map<String, dynamic> toJson();




@override
String toString() {
  final _this = this as DaisyThemeSize;
  return 'DaisyThemeSize(fields: ${_this.fields}, selectors: ${_this.selectors})';
}


}

/// @nodoc
abstract mixin class $DaisyThemeSizeCopyWith<$Res>  {
  factory $DaisyThemeSizeCopyWith(DaisyThemeSize value, $Res Function(DaisyThemeSize) _then) = _$DaisyThemeSizeCopyWithImpl;
@useResult
$Res call({
 DaisyThemeSizeConfig fields, DaisyThemeSizeConfig selectors
});


$DaisyThemeSizeConfigCopyWith<$Res> get fields;$DaisyThemeSizeConfigCopyWith<$Res> get selectors;

}
/// @nodoc
class _$DaisyThemeSizeCopyWithImpl<$Res>
    implements $DaisyThemeSizeCopyWith<$Res> {
  _$DaisyThemeSizeCopyWithImpl(this._self, this._then);

  final DaisyThemeSize _self;
  final $Res Function(DaisyThemeSize) _then;

/// Create a copy of DaisyThemeSize
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fields = null,Object? selectors = null,}) {
  return _then(DaisyThemeSize(
fields: null == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as DaisyThemeSizeConfig,selectors: null == selectors ? _self.selectors : selectors // ignore: cast_nullable_to_non_nullable
as DaisyThemeSizeConfig,
  ));
}
/// Create a copy of DaisyThemeSize
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DaisyThemeSizeConfigCopyWith<$Res> get fields {
  
  return $DaisyThemeSizeConfigCopyWith<$Res>(_self.fields, (value) {
    return _then(_self.copyWith(fields: value));
  });
}/// Create a copy of DaisyThemeSize
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DaisyThemeSizeConfigCopyWith<$Res> get selectors {
  
  return $DaisyThemeSizeConfigCopyWith<$Res>(_self.selectors, (value) {
    return _then(_self.copyWith(selectors: value));
  });
}
}


/// Adds pattern-matching-related methods to [DaisyThemeSize].
extension DaisyThemeSizePatterns on DaisyThemeSize {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DaisyThemeSize value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DaisyThemeSize() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DaisyThemeSize value)  $default,){
final _that = this;
switch (_that) {
case _DaisyThemeSize():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DaisyThemeSize value)?  $default,){
final _that = this;
switch (_that) {
case _DaisyThemeSize() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DaisyThemeSizeConfig fields,  DaisyThemeSizeConfig selectors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DaisyThemeSize() when $default != null:
return $default(_that.fields,_that.selectors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DaisyThemeSizeConfig fields,  DaisyThemeSizeConfig selectors)  $default,) {final _that = this;
switch (_that) {
case _DaisyThemeSize():
return $default(_that.fields,_that.selectors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DaisyThemeSizeConfig fields,  DaisyThemeSizeConfig selectors)?  $default,) {final _that = this;
switch (_that) {
case _DaisyThemeSize() when $default != null:
return $default(_that.fields,_that.selectors);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DaisyThemeSize extends DaisyThemeSize {
  const _DaisyThemeSize({required this.fields, required this.selectors}): super._();
  factory _DaisyThemeSize.fromJson(Map<String, dynamic> json) => _$DaisyThemeSizeFromJson(json);

/// Buttons, inputs, selects, tabs.
@override final  DaisyThemeSizeConfig fields;
/// Checkboxes, toggles, badges.
@override final  DaisyThemeSizeConfig selectors;

/// Create a copy of DaisyThemeSize
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DaisyThemeSizeCopyWith<_DaisyThemeSize> get copyWith => __$DaisyThemeSizeCopyWithImpl<_DaisyThemeSize>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DaisyThemeSizeToJson(this, );
}



@override
String toString() {
    return 'DaisyThemeSize(fields: $fields, selectors: $selectors)';
}


}

/// @nodoc
abstract mixin class _$DaisyThemeSizeCopyWith<$Res> implements $DaisyThemeSizeCopyWith<$Res> {
  factory _$DaisyThemeSizeCopyWith(_DaisyThemeSize value, $Res Function(_DaisyThemeSize) _then) = __$DaisyThemeSizeCopyWithImpl;
@override @useResult
$Res call({
 DaisyThemeSizeConfig fields, DaisyThemeSizeConfig selectors
});


@override $DaisyThemeSizeConfigCopyWith<$Res> get fields;@override $DaisyThemeSizeConfigCopyWith<$Res> get selectors;

}
/// @nodoc
class __$DaisyThemeSizeCopyWithImpl<$Res>
    implements _$DaisyThemeSizeCopyWith<$Res> {
  __$DaisyThemeSizeCopyWithImpl(this._self, this._then);

  final _DaisyThemeSize _self;
  final $Res Function(_DaisyThemeSize) _then;

/// Create a copy of DaisyThemeSize
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fields = null,Object? selectors = null,}) {
  return _then(_DaisyThemeSize(
fields: null == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as DaisyThemeSizeConfig,selectors: null == selectors ? _self.selectors : selectors // ignore: cast_nullable_to_non_nullable
as DaisyThemeSizeConfig,
  ));
}

/// Create a copy of DaisyThemeSize
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DaisyThemeSizeConfigCopyWith<$Res> get fields {
  
  return $DaisyThemeSizeConfigCopyWith<$Res>(_self.fields, (value) {
    return _then(_self.copyWith(fields: value));
  });
}/// Create a copy of DaisyThemeSize
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DaisyThemeSizeConfigCopyWith<$Res> get selectors {
  
  return $DaisyThemeSizeConfigCopyWith<$Res>(_self.selectors, (value) {
    return _then(_self.copyWith(selectors: value));
  });
}
}


/// @nodoc
mixin _$DaisyThemeSizeConfig {

/// Base step in logical pixels; every size below derives from it.
 int get base;
/// Create a copy of DaisyThemeSizeConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DaisyThemeSizeConfigCopyWith<DaisyThemeSizeConfig> get copyWith => _$DaisyThemeSizeConfigCopyWithImpl<DaisyThemeSizeConfig>(this as DaisyThemeSizeConfig, _$identity);

  /// Serializes this DaisyThemeSizeConfig to a JSON map.
  Map<String, dynamic> toJson();




@override
String toString() {
  final _this = this as DaisyThemeSizeConfig;
  return 'DaisyThemeSizeConfig(base: ${_this.base})';
}


}

/// @nodoc
abstract mixin class $DaisyThemeSizeConfigCopyWith<$Res>  {
  factory $DaisyThemeSizeConfigCopyWith(DaisyThemeSizeConfig value, $Res Function(DaisyThemeSizeConfig) _then) = _$DaisyThemeSizeConfigCopyWithImpl;
@useResult
$Res call({
 int base
});




}
/// @nodoc
class _$DaisyThemeSizeConfigCopyWithImpl<$Res>
    implements $DaisyThemeSizeConfigCopyWith<$Res> {
  _$DaisyThemeSizeConfigCopyWithImpl(this._self, this._then);

  final DaisyThemeSizeConfig _self;
  final $Res Function(DaisyThemeSizeConfig) _then;

/// Create a copy of DaisyThemeSizeConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? base = null,}) {
  return _then(DaisyThemeSizeConfig(
base: null == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DaisyThemeSizeConfig].
extension DaisyThemeSizeConfigPatterns on DaisyThemeSizeConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DaisyThemeSizeConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DaisyThemeSizeConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DaisyThemeSizeConfig value)  $default,){
final _that = this;
switch (_that) {
case _DaisyThemeSizeConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DaisyThemeSizeConfig value)?  $default,){
final _that = this;
switch (_that) {
case _DaisyThemeSizeConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int base)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DaisyThemeSizeConfig() when $default != null:
return $default(_that.base);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int base)  $default,) {final _that = this;
switch (_that) {
case _DaisyThemeSizeConfig():
return $default(_that.base);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int base)?  $default,) {final _that = this;
switch (_that) {
case _DaisyThemeSizeConfig() when $default != null:
return $default(_that.base);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DaisyThemeSizeConfig extends DaisyThemeSizeConfig {
  const _DaisyThemeSizeConfig({required this.base}): super._();
  factory _DaisyThemeSizeConfig.fromJson(Map<String, dynamic> json) => _$DaisyThemeSizeConfigFromJson(json);

/// Base step in logical pixels; every size below derives from it.
@override final  int base;

/// Create a copy of DaisyThemeSizeConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DaisyThemeSizeConfigCopyWith<_DaisyThemeSizeConfig> get copyWith => __$DaisyThemeSizeConfigCopyWithImpl<_DaisyThemeSizeConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DaisyThemeSizeConfigToJson(this, );
}



@override
String toString() {
    return 'DaisyThemeSizeConfig(base: $base)';
}


}

/// @nodoc
abstract mixin class _$DaisyThemeSizeConfigCopyWith<$Res> implements $DaisyThemeSizeConfigCopyWith<$Res> {
  factory _$DaisyThemeSizeConfigCopyWith(_DaisyThemeSizeConfig value, $Res Function(_DaisyThemeSizeConfig) _then) = __$DaisyThemeSizeConfigCopyWithImpl;
@override @useResult
$Res call({
 int base
});




}
/// @nodoc
class __$DaisyThemeSizeConfigCopyWithImpl<$Res>
    implements _$DaisyThemeSizeConfigCopyWith<$Res> {
  __$DaisyThemeSizeConfigCopyWithImpl(this._self, this._then);

  final _DaisyThemeSizeConfig _self;
  final $Res Function(_DaisyThemeSizeConfig) _then;

/// Create a copy of DaisyThemeSizeConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? base = null,}) {
  return _then(_DaisyThemeSizeConfig(
base: null == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
