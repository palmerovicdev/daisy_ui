// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../theme_radius.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DaisyThemeRadius {

/// Cards, modals, alerts.
 int get boxes;/// Buttons, inputs, selects, tabs.
 int get fields;/// Checkboxes, toggles, badges.
 int get selectors;
/// Create a copy of DaisyThemeRadius
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DaisyThemeRadiusCopyWith<DaisyThemeRadius> get copyWith => _$DaisyThemeRadiusCopyWithImpl<DaisyThemeRadius>(this as DaisyThemeRadius, _$identity);

  /// Serializes this DaisyThemeRadius to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DaisyThemeRadius;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DaisyThemeRadius&&(identical(other.boxes, _this.boxes) || other.boxes == _this.boxes)&&(identical(other.fields, _this.fields) || other.fields == _this.fields)&&(identical(other.selectors, _this.selectors) || other.selectors == _this.selectors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DaisyThemeRadius;
  return Object.hash(runtimeType,_this.boxes,_this.fields,_this.selectors);
}

@override
String toString() {
  final _this = this as DaisyThemeRadius;
  return 'DaisyThemeRadius(boxes: ${_this.boxes}, fields: ${_this.fields}, selectors: ${_this.selectors})';
}


}

/// @nodoc
abstract mixin class $DaisyThemeRadiusCopyWith<$Res>  {
  factory $DaisyThemeRadiusCopyWith(DaisyThemeRadius value, $Res Function(DaisyThemeRadius) _then) = _$DaisyThemeRadiusCopyWithImpl;
@useResult
$Res call({
 int boxes, int fields, int selectors
});




}
/// @nodoc
class _$DaisyThemeRadiusCopyWithImpl<$Res>
    implements $DaisyThemeRadiusCopyWith<$Res> {
  _$DaisyThemeRadiusCopyWithImpl(this._self, this._then);

  final DaisyThemeRadius _self;
  final $Res Function(DaisyThemeRadius) _then;

/// Create a copy of DaisyThemeRadius
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? boxes = null,Object? fields = null,Object? selectors = null,}) {
  return _then(DaisyThemeRadius(
boxes: null == boxes ? _self.boxes : boxes // ignore: cast_nullable_to_non_nullable
as int,fields: null == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as int,selectors: null == selectors ? _self.selectors : selectors // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DaisyThemeRadius].
extension DaisyThemeRadiusPatterns on DaisyThemeRadius {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DaisyThemeRadius value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DaisyThemeRadius() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DaisyThemeRadius value)  $default,){
final _that = this;
switch (_that) {
case _DaisyThemeRadius():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DaisyThemeRadius value)?  $default,){
final _that = this;
switch (_that) {
case _DaisyThemeRadius() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int boxes,  int fields,  int selectors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DaisyThemeRadius() when $default != null:
return $default(_that.boxes,_that.fields,_that.selectors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int boxes,  int fields,  int selectors)  $default,) {final _that = this;
switch (_that) {
case _DaisyThemeRadius():
return $default(_that.boxes,_that.fields,_that.selectors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int boxes,  int fields,  int selectors)?  $default,) {final _that = this;
switch (_that) {
case _DaisyThemeRadius() when $default != null:
return $default(_that.boxes,_that.fields,_that.selectors);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DaisyThemeRadius implements DaisyThemeRadius {
  const _DaisyThemeRadius({required this.boxes, required this.fields, required this.selectors});
  factory _DaisyThemeRadius.fromJson(Map<String, dynamic> json) => _$DaisyThemeRadiusFromJson(json);

/// Cards, modals, alerts.
@override final  int boxes;
/// Buttons, inputs, selects, tabs.
@override final  int fields;
/// Checkboxes, toggles, badges.
@override final  int selectors;

/// Create a copy of DaisyThemeRadius
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DaisyThemeRadiusCopyWith<_DaisyThemeRadius> get copyWith => __$DaisyThemeRadiusCopyWithImpl<_DaisyThemeRadius>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DaisyThemeRadiusToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DaisyThemeRadius&&(identical(other.boxes, boxes) || other.boxes == boxes)&&(identical(other.fields, fields) || other.fields == fields)&&(identical(other.selectors, selectors) || other.selectors == selectors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,boxes,fields,selectors);
}

@override
String toString() {
    return 'DaisyThemeRadius(boxes: $boxes, fields: $fields, selectors: $selectors)';
}


}

/// @nodoc
abstract mixin class _$DaisyThemeRadiusCopyWith<$Res> implements $DaisyThemeRadiusCopyWith<$Res> {
  factory _$DaisyThemeRadiusCopyWith(_DaisyThemeRadius value, $Res Function(_DaisyThemeRadius) _then) = __$DaisyThemeRadiusCopyWithImpl;
@override @useResult
$Res call({
 int boxes, int fields, int selectors
});




}
/// @nodoc
class __$DaisyThemeRadiusCopyWithImpl<$Res>
    implements _$DaisyThemeRadiusCopyWith<$Res> {
  __$DaisyThemeRadiusCopyWithImpl(this._self, this._then);

  final _DaisyThemeRadius _self;
  final $Res Function(_DaisyThemeRadius) _then;

/// Create a copy of DaisyThemeRadius
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? boxes = null,Object? fields = null,Object? selectors = null,}) {
  return _then(_DaisyThemeRadius(
boxes: null == boxes ? _self.boxes : boxes // ignore: cast_nullable_to_non_nullable
as int,fields: null == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as int,selectors: null == selectors ? _self.selectors : selectors // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
