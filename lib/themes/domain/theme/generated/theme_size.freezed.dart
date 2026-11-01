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
 DaisyThemeSizePresets get fields;/// Checkboxes, toggles, badges.
 DaisyThemeSizePresets get selectors;
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
 DaisyThemeSizePresets fields, DaisyThemeSizePresets selectors
});


$DaisyThemeSizePresetsCopyWith<$Res> get fields;$DaisyThemeSizePresetsCopyWith<$Res> get selectors;

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
as DaisyThemeSizePresets,selectors: null == selectors ? _self.selectors : selectors // ignore: cast_nullable_to_non_nullable
as DaisyThemeSizePresets,
  ));
}
/// Create a copy of DaisyThemeSize
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DaisyThemeSizePresetsCopyWith<$Res> get fields {
  
  return $DaisyThemeSizePresetsCopyWith<$Res>(_self.fields, (value) {
    return _then(_self.copyWith(fields: value));
  });
}/// Create a copy of DaisyThemeSize
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DaisyThemeSizePresetsCopyWith<$Res> get selectors {
  
  return $DaisyThemeSizePresetsCopyWith<$Res>(_self.selectors, (value) {
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DaisyThemeSizePresets fields,  DaisyThemeSizePresets selectors)?  $default,{required TResult orElse(),}) {final _that = this;
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DaisyThemeSizePresets fields,  DaisyThemeSizePresets selectors)  $default,) {final _that = this;
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DaisyThemeSizePresets fields,  DaisyThemeSizePresets selectors)?  $default,) {final _that = this;
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
@override final  DaisyThemeSizePresets fields;
/// Checkboxes, toggles, badges.
@override final  DaisyThemeSizePresets selectors;

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
 DaisyThemeSizePresets fields, DaisyThemeSizePresets selectors
});


@override $DaisyThemeSizePresetsCopyWith<$Res> get fields;@override $DaisyThemeSizePresetsCopyWith<$Res> get selectors;

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
as DaisyThemeSizePresets,selectors: null == selectors ? _self.selectors : selectors // ignore: cast_nullable_to_non_nullable
as DaisyThemeSizePresets,
  ));
}

/// Create a copy of DaisyThemeSize
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DaisyThemeSizePresetsCopyWith<$Res> get fields {
  
  return $DaisyThemeSizePresetsCopyWith<$Res>(_self.fields, (value) {
    return _then(_self.copyWith(fields: value));
  });
}/// Create a copy of DaisyThemeSize
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DaisyThemeSizePresetsCopyWith<$Res> get selectors {
  
  return $DaisyThemeSizePresetsCopyWith<$Res>(_self.selectors, (value) {
    return _then(_self.copyWith(selectors: value));
  });
}
}


/// @nodoc
mixin _$DaisyThemeSizePresets {

/// Base step in logical pixels; every size below derives from it.
 int get base;
/// Create a copy of DaisyThemeSizePresets
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DaisyThemeSizePresetsCopyWith<DaisyThemeSizePresets> get copyWith => _$DaisyThemeSizePresetsCopyWithImpl<DaisyThemeSizePresets>(this as DaisyThemeSizePresets, _$identity);

  /// Serializes this DaisyThemeSizePresets to a JSON map.
  Map<String, dynamic> toJson();




@override
String toString() {
  final _this = this as DaisyThemeSizePresets;
  return 'DaisyThemeSizePresets(base: ${_this.base})';
}


}

/// @nodoc
abstract mixin class $DaisyThemeSizePresetsCopyWith<$Res>  {
  factory $DaisyThemeSizePresetsCopyWith(DaisyThemeSizePresets value, $Res Function(DaisyThemeSizePresets) _then) = _$DaisyThemeSizePresetsCopyWithImpl;
@useResult
$Res call({
 int base
});




}
/// @nodoc
class _$DaisyThemeSizePresetsCopyWithImpl<$Res>
    implements $DaisyThemeSizePresetsCopyWith<$Res> {
  _$DaisyThemeSizePresetsCopyWithImpl(this._self, this._then);

  final DaisyThemeSizePresets _self;
  final $Res Function(DaisyThemeSizePresets) _then;

/// Create a copy of DaisyThemeSizePresets
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? base = null,}) {
  return _then(DaisyThemeSizePresets(
base: null == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DaisyThemeSizePresets].
extension DaisyThemeSizePresetsPatterns on DaisyThemeSizePresets {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DaisyThemeSizePresets value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DaisyThemeSizePresets() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DaisyThemeSizePresets value)  $default,){
final _that = this;
switch (_that) {
case _DaisyThemeSizePresets():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DaisyThemeSizePresets value)?  $default,){
final _that = this;
switch (_that) {
case _DaisyThemeSizePresets() when $default != null:
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
case _DaisyThemeSizePresets() when $default != null:
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
case _DaisyThemeSizePresets():
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
case _DaisyThemeSizePresets() when $default != null:
return $default(_that.base);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DaisyThemeSizePresets extends DaisyThemeSizePresets {
  const _DaisyThemeSizePresets({required this.base}): super._();
  factory _DaisyThemeSizePresets.fromJson(Map<String, dynamic> json) => _$DaisyThemeSizePresetsFromJson(json);

/// Base step in logical pixels; every size below derives from it.
@override final  int base;

/// Create a copy of DaisyThemeSizePresets
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DaisyThemeSizePresetsCopyWith<_DaisyThemeSizePresets> get copyWith => __$DaisyThemeSizePresetsCopyWithImpl<_DaisyThemeSizePresets>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DaisyThemeSizePresetsToJson(this, );
}



@override
String toString() {
    return 'DaisyThemeSizePresets(base: $base)';
}


}

/// @nodoc
abstract mixin class _$DaisyThemeSizePresetsCopyWith<$Res> implements $DaisyThemeSizePresetsCopyWith<$Res> {
  factory _$DaisyThemeSizePresetsCopyWith(_DaisyThemeSizePresets value, $Res Function(_DaisyThemeSizePresets) _then) = __$DaisyThemeSizePresetsCopyWithImpl;
@override @useResult
$Res call({
 int base
});




}
/// @nodoc
class __$DaisyThemeSizePresetsCopyWithImpl<$Res>
    implements _$DaisyThemeSizePresetsCopyWith<$Res> {
  __$DaisyThemeSizePresetsCopyWithImpl(this._self, this._then);

  final _DaisyThemeSizePresets _self;
  final $Res Function(_DaisyThemeSizePresets) _then;

/// Create a copy of DaisyThemeSizePresets
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? base = null,}) {
  return _then(_DaisyThemeSizePresets(
base: null == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
