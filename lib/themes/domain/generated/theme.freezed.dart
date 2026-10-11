// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../theme.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DaisyThemeModel {

 String get id; String get name; String get description; DaisyThemeColor get colors; DaisyThemeRadius get radius; DaisyThemeSize get size;
/// Create a copy of DaisyThemeModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DaisyThemeModelCopyWith<DaisyThemeModel> get copyWith => _$DaisyThemeModelCopyWithImpl<DaisyThemeModel>(this as DaisyThemeModel, _$identity);

  /// Serializes this DaisyThemeModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DaisyThemeModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DaisyThemeModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.colors, _this.colors) || other.colors == _this.colors)&&(identical(other.radius, _this.radius) || other.radius == _this.radius)&&(identical(other.size, _this.size) || other.size == _this.size));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DaisyThemeModel;
  return Object.hash(runtimeType,_this.id,_this.name,_this.description,_this.colors,_this.radius,_this.size);
}

@override
String toString() {
  final _this = this as DaisyThemeModel;
  return 'DaisyThemeModel(id: ${_this.id}, name: ${_this.name}, description: ${_this.description}, colors: ${_this.colors}, radius: ${_this.radius}, size: ${_this.size})';
}


}

/// @nodoc
abstract mixin class $DaisyThemeModelCopyWith<$Res>  {
  factory $DaisyThemeModelCopyWith(DaisyThemeModel value, $Res Function(DaisyThemeModel) _then) = _$DaisyThemeModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, DaisyThemeColor colors, DaisyThemeRadius radius, DaisyThemeSize size
});


$DaisyThemeColorCopyWith<$Res> get colors;$DaisyThemeRadiusCopyWith<$Res> get radius;$DaisyThemeSizeCopyWith<$Res> get size;

}
/// @nodoc
class _$DaisyThemeModelCopyWithImpl<$Res>
    implements $DaisyThemeModelCopyWith<$Res> {
  _$DaisyThemeModelCopyWithImpl(this._self, this._then);

  final DaisyThemeModel _self;
  final $Res Function(DaisyThemeModel) _then;

/// Create a copy of DaisyThemeModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? colors = null,Object? radius = null,Object? size = null,}) {
  return _then(DaisyThemeModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,colors: null == colors ? _self.colors : colors // ignore: cast_nullable_to_non_nullable
as DaisyThemeColor,radius: null == radius ? _self.radius : radius // ignore: cast_nullable_to_non_nullable
as DaisyThemeRadius,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as DaisyThemeSize,
  ));
}
/// Create a copy of DaisyThemeModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DaisyThemeColorCopyWith<$Res> get colors {
  
  return $DaisyThemeColorCopyWith<$Res>(_self.colors, (value) {
    return _then(_self.copyWith(colors: value));
  });
}/// Create a copy of DaisyThemeModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DaisyThemeRadiusCopyWith<$Res> get radius {
  
  return $DaisyThemeRadiusCopyWith<$Res>(_self.radius, (value) {
    return _then(_self.copyWith(radius: value));
  });
}/// Create a copy of DaisyThemeModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DaisyThemeSizeCopyWith<$Res> get size {
  
  return $DaisyThemeSizeCopyWith<$Res>(_self.size, (value) {
    return _then(_self.copyWith(size: value));
  });
}
}


/// Adds pattern-matching-related methods to [DaisyThemeModel].
extension DaisyThemeModelPatterns on DaisyThemeModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DaisyThemeModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DaisyThemeModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DaisyThemeModel value)  $default,){
final _that = this;
switch (_that) {
case _DaisyThemeModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DaisyThemeModel value)?  $default,){
final _that = this;
switch (_that) {
case _DaisyThemeModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  DaisyThemeColor colors,  DaisyThemeRadius radius,  DaisyThemeSize size)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DaisyThemeModel() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.colors,_that.radius,_that.size);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  DaisyThemeColor colors,  DaisyThemeRadius radius,  DaisyThemeSize size)  $default,) {final _that = this;
switch (_that) {
case _DaisyThemeModel():
return $default(_that.id,_that.name,_that.description,_that.colors,_that.radius,_that.size);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  DaisyThemeColor colors,  DaisyThemeRadius radius,  DaisyThemeSize size)?  $default,) {final _that = this;
switch (_that) {
case _DaisyThemeModel() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.colors,_that.radius,_that.size);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DaisyThemeModel implements DaisyThemeModel {
  const _DaisyThemeModel({required this.id, required this.name, required this.description, required this.colors, required this.radius, required this.size});
  factory _DaisyThemeModel.fromJson(Map<String, dynamic> json) => _$DaisyThemeModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String description;
@override final  DaisyThemeColor colors;
@override final  DaisyThemeRadius radius;
@override final  DaisyThemeSize size;

/// Create a copy of DaisyThemeModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DaisyThemeModelCopyWith<_DaisyThemeModel> get copyWith => __$DaisyThemeModelCopyWithImpl<_DaisyThemeModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DaisyThemeModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DaisyThemeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.colors, colors) || other.colors == colors)&&(identical(other.radius, radius) || other.radius == radius)&&(identical(other.size, size) || other.size == size));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,description,colors,radius,size);
}

@override
String toString() {
    return 'DaisyThemeModel(id: $id, name: $name, description: $description, colors: $colors, radius: $radius, size: $size)';
}


}

/// @nodoc
abstract mixin class _$DaisyThemeModelCopyWith<$Res> implements $DaisyThemeModelCopyWith<$Res> {
  factory _$DaisyThemeModelCopyWith(_DaisyThemeModel value, $Res Function(_DaisyThemeModel) _then) = __$DaisyThemeModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, DaisyThemeColor colors, DaisyThemeRadius radius, DaisyThemeSize size
});


@override $DaisyThemeColorCopyWith<$Res> get colors;@override $DaisyThemeRadiusCopyWith<$Res> get radius;@override $DaisyThemeSizeCopyWith<$Res> get size;

}
/// @nodoc
class __$DaisyThemeModelCopyWithImpl<$Res>
    implements _$DaisyThemeModelCopyWith<$Res> {
  __$DaisyThemeModelCopyWithImpl(this._self, this._then);

  final _DaisyThemeModel _self;
  final $Res Function(_DaisyThemeModel) _then;

/// Create a copy of DaisyThemeModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? colors = null,Object? radius = null,Object? size = null,}) {
  return _then(_DaisyThemeModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,colors: null == colors ? _self.colors : colors // ignore: cast_nullable_to_non_nullable
as DaisyThemeColor,radius: null == radius ? _self.radius : radius // ignore: cast_nullable_to_non_nullable
as DaisyThemeRadius,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as DaisyThemeSize,
  ));
}

/// Create a copy of DaisyThemeModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DaisyThemeColorCopyWith<$Res> get colors {
  
  return $DaisyThemeColorCopyWith<$Res>(_self.colors, (value) {
    return _then(_self.copyWith(colors: value));
  });
}/// Create a copy of DaisyThemeModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DaisyThemeRadiusCopyWith<$Res> get radius {
  
  return $DaisyThemeRadiusCopyWith<$Res>(_self.radius, (value) {
    return _then(_self.copyWith(radius: value));
  });
}/// Create a copy of DaisyThemeModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DaisyThemeSizeCopyWith<$Res> get size {
  
  return $DaisyThemeSizeCopyWith<$Res>(_self.size, (value) {
    return _then(_self.copyWith(size: value));
  });
}
}

// dart format on
