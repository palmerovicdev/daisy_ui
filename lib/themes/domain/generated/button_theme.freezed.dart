// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../button_theme.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DaisyButtonTheme {

 DaisyButtonType get type; DaisyButtonStyle get style; DaisyButtonSize get size; DaisyButtonModifier get modifier; double get elevation; double get hoverElevation; double get pressedElevation;
/// Create a copy of DaisyButtonTheme
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DaisyButtonThemeCopyWith<DaisyButtonTheme> get copyWith => _$DaisyButtonThemeCopyWithImpl<DaisyButtonTheme>(this as DaisyButtonTheme, _$identity);

  /// Serializes this DaisyButtonTheme to a JSON map.
  Map<String, dynamic> toJson();




@override
String toString() {
  final _this = this as DaisyButtonTheme;
  return 'DaisyButtonTheme(type: ${_this.type}, style: ${_this.style}, size: ${_this.size}, modifier: ${_this.modifier}, elevation: ${_this.elevation}, hoverElevation: ${_this.hoverElevation}, pressedElevation: ${_this.pressedElevation})';
}


}

/// @nodoc
abstract mixin class $DaisyButtonThemeCopyWith<$Res>  {
  factory $DaisyButtonThemeCopyWith(DaisyButtonTheme value, $Res Function(DaisyButtonTheme) _then) = _$DaisyButtonThemeCopyWithImpl;
@useResult
$Res call({
 DaisyButtonType type, DaisyButtonStyle style, DaisyButtonSize size, DaisyButtonModifier modifier, double elevation, double hoverElevation, double pressedElevation
});




}
/// @nodoc
class _$DaisyButtonThemeCopyWithImpl<$Res>
    implements $DaisyButtonThemeCopyWith<$Res> {
  _$DaisyButtonThemeCopyWithImpl(this._self, this._then);

  final DaisyButtonTheme _self;
  final $Res Function(DaisyButtonTheme) _then;

/// Create a copy of DaisyButtonTheme
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? style = null,Object? size = null,Object? modifier = null,Object? elevation = null,Object? hoverElevation = null,Object? pressedElevation = null,}) {
  return _then(DaisyButtonTheme(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DaisyButtonType,style: null == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as DaisyButtonStyle,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as DaisyButtonSize,modifier: null == modifier ? _self.modifier : modifier // ignore: cast_nullable_to_non_nullable
as DaisyButtonModifier,elevation: null == elevation ? _self.elevation : elevation // ignore: cast_nullable_to_non_nullable
as double,hoverElevation: null == hoverElevation ? _self.hoverElevation : hoverElevation // ignore: cast_nullable_to_non_nullable
as double,pressedElevation: null == pressedElevation ? _self.pressedElevation : pressedElevation // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [DaisyButtonTheme].
extension DaisyButtonThemePatterns on DaisyButtonTheme {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DaisyButtonTheme value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DaisyButtonTheme() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DaisyButtonTheme value)  $default,){
final _that = this;
switch (_that) {
case _DaisyButtonTheme():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DaisyButtonTheme value)?  $default,){
final _that = this;
switch (_that) {
case _DaisyButtonTheme() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DaisyButtonType type,  DaisyButtonStyle style,  DaisyButtonSize size,  DaisyButtonModifier modifier,  double elevation,  double hoverElevation,  double pressedElevation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DaisyButtonTheme() when $default != null:
return $default(_that.type,_that.style,_that.size,_that.modifier,_that.elevation,_that.hoverElevation,_that.pressedElevation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DaisyButtonType type,  DaisyButtonStyle style,  DaisyButtonSize size,  DaisyButtonModifier modifier,  double elevation,  double hoverElevation,  double pressedElevation)  $default,) {final _that = this;
switch (_that) {
case _DaisyButtonTheme():
return $default(_that.type,_that.style,_that.size,_that.modifier,_that.elevation,_that.hoverElevation,_that.pressedElevation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DaisyButtonType type,  DaisyButtonStyle style,  DaisyButtonSize size,  DaisyButtonModifier modifier,  double elevation,  double hoverElevation,  double pressedElevation)?  $default,) {final _that = this;
switch (_that) {
case _DaisyButtonTheme() when $default != null:
return $default(_that.type,_that.style,_that.size,_that.modifier,_that.elevation,_that.hoverElevation,_that.pressedElevation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DaisyButtonTheme extends DaisyButtonTheme {
  const _DaisyButtonTheme({this.type = DaisyButtonType.filled, this.style = DaisyButtonStyle.neutral, this.size = DaisyButtonSize.md, this.modifier = DaisyButtonModifier.none, this.elevation = 0, this.hoverElevation = 4, this.pressedElevation = 0}): super._();
  factory _DaisyButtonTheme.fromJson(Map<String, dynamic> json) => _$DaisyButtonThemeFromJson(json);

@override@JsonKey() final  DaisyButtonType type;
@override@JsonKey() final  DaisyButtonStyle style;
@override@JsonKey() final  DaisyButtonSize size;
@override@JsonKey() final  DaisyButtonModifier modifier;
@override@JsonKey() final  double elevation;
@override@JsonKey() final  double hoverElevation;
@override@JsonKey() final  double pressedElevation;

/// Create a copy of DaisyButtonTheme
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DaisyButtonThemeCopyWith<_DaisyButtonTheme> get copyWith => __$DaisyButtonThemeCopyWithImpl<_DaisyButtonTheme>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DaisyButtonThemeToJson(this, );
}



@override
String toString() {
    return 'DaisyButtonTheme(type: $type, style: $style, size: $size, modifier: $modifier, elevation: $elevation, hoverElevation: $hoverElevation, pressedElevation: $pressedElevation)';
}


}

/// @nodoc
abstract mixin class _$DaisyButtonThemeCopyWith<$Res> implements $DaisyButtonThemeCopyWith<$Res> {
  factory _$DaisyButtonThemeCopyWith(_DaisyButtonTheme value, $Res Function(_DaisyButtonTheme) _then) = __$DaisyButtonThemeCopyWithImpl;
@override @useResult
$Res call({
 DaisyButtonType type, DaisyButtonStyle style, DaisyButtonSize size, DaisyButtonModifier modifier, double elevation, double hoverElevation, double pressedElevation
});




}
/// @nodoc
class __$DaisyButtonThemeCopyWithImpl<$Res>
    implements _$DaisyButtonThemeCopyWith<$Res> {
  __$DaisyButtonThemeCopyWithImpl(this._self, this._then);

  final _DaisyButtonTheme _self;
  final $Res Function(_DaisyButtonTheme) _then;

/// Create a copy of DaisyButtonTheme
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? style = null,Object? size = null,Object? modifier = null,Object? elevation = null,Object? hoverElevation = null,Object? pressedElevation = null,}) {
  return _then(_DaisyButtonTheme(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DaisyButtonType,style: null == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as DaisyButtonStyle,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as DaisyButtonSize,modifier: null == modifier ? _self.modifier : modifier // ignore: cast_nullable_to_non_nullable
as DaisyButtonModifier,elevation: null == elevation ? _self.elevation : elevation // ignore: cast_nullable_to_non_nullable
as double,hoverElevation: null == hoverElevation ? _self.hoverElevation : hoverElevation // ignore: cast_nullable_to_non_nullable
as double,pressedElevation: null == pressedElevation ? _self.pressedElevation : pressedElevation // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
