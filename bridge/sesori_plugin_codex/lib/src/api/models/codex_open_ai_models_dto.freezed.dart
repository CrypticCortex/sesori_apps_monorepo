// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'codex_open_ai_models_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CodexOpenAiModelsDto {

 List<CodexOpenAiModelDto> get data;
/// Create a copy of CodexOpenAiModelsDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CodexOpenAiModelsDtoCopyWith<CodexOpenAiModelsDto> get copyWith => _$CodexOpenAiModelsDtoCopyWithImpl<CodexOpenAiModelsDto>(this as CodexOpenAiModelsDto, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CodexOpenAiModelsDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CodexOpenAiModelsDto&&const DeepCollectionEquality().equals(other.data, _this.data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CodexOpenAiModelsDto;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.data));
}

@override
String toString() {
  final _this = this as CodexOpenAiModelsDto;
  return 'CodexOpenAiModelsDto(data: ${_this.data})';
}


}

/// @nodoc
abstract mixin class $CodexOpenAiModelsDtoCopyWith<$Res>  {
  factory $CodexOpenAiModelsDtoCopyWith(CodexOpenAiModelsDto value, $Res Function(CodexOpenAiModelsDto) _then) = _$CodexOpenAiModelsDtoCopyWithImpl;
@useResult
$Res call({
 List<CodexOpenAiModelDto> data
});




}
/// @nodoc
class _$CodexOpenAiModelsDtoCopyWithImpl<$Res>
    implements $CodexOpenAiModelsDtoCopyWith<$Res> {
  _$CodexOpenAiModelsDtoCopyWithImpl(this._self, this._then);

  final CodexOpenAiModelsDto _self;
  final $Res Function(CodexOpenAiModelsDto) _then;

/// Create a copy of CodexOpenAiModelsDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,}) {
  return _then(CodexOpenAiModelsDto(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as List<CodexOpenAiModelDto>,
  ));
}

}



/// @nodoc
@JsonSerializable(createToJson: false)

class _CodexOpenAiModelsDto implements CodexOpenAiModelsDto {
  const _CodexOpenAiModelsDto({required  List<CodexOpenAiModelDto> data}): _data = data;
  factory _CodexOpenAiModelsDto.fromJson(Map<String, dynamic> json) => _$CodexOpenAiModelsDtoFromJson(json);

 final  List<CodexOpenAiModelDto> _data;
@override List<CodexOpenAiModelDto> get data {
  if (_data is EqualUnmodifiableListView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_data);
}


/// Create a copy of CodexOpenAiModelsDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CodexOpenAiModelsDtoCopyWith<_CodexOpenAiModelsDto> get copyWith => __$CodexOpenAiModelsDtoCopyWithImpl<_CodexOpenAiModelsDto>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CodexOpenAiModelsDto&&const DeepCollectionEquality().equals(other.data, _data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_data));
}

@override
String toString() {
    return 'CodexOpenAiModelsDto(data: $data)';
}


}

/// @nodoc
abstract mixin class _$CodexOpenAiModelsDtoCopyWith<$Res> implements $CodexOpenAiModelsDtoCopyWith<$Res> {
  factory _$CodexOpenAiModelsDtoCopyWith(_CodexOpenAiModelsDto value, $Res Function(_CodexOpenAiModelsDto) _then) = __$CodexOpenAiModelsDtoCopyWithImpl;
@override @useResult
$Res call({
 List<CodexOpenAiModelDto> data
});




}
/// @nodoc
class __$CodexOpenAiModelsDtoCopyWithImpl<$Res>
    implements _$CodexOpenAiModelsDtoCopyWith<$Res> {
  __$CodexOpenAiModelsDtoCopyWithImpl(this._self, this._then);

  final _CodexOpenAiModelsDto _self;
  final $Res Function(_CodexOpenAiModelsDto) _then;

/// Create a copy of CodexOpenAiModelsDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(_CodexOpenAiModelsDto(
data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as List<CodexOpenAiModelDto>,
  ));
}


}


/// @nodoc
mixin _$CodexOpenAiModelDto {

 String get id;
/// Create a copy of CodexOpenAiModelDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CodexOpenAiModelDtoCopyWith<CodexOpenAiModelDto> get copyWith => _$CodexOpenAiModelDtoCopyWithImpl<CodexOpenAiModelDto>(this as CodexOpenAiModelDto, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CodexOpenAiModelDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CodexOpenAiModelDto&&(identical(other.id, _this.id) || other.id == _this.id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CodexOpenAiModelDto;
  return Object.hash(runtimeType,_this.id);
}

@override
String toString() {
  final _this = this as CodexOpenAiModelDto;
  return 'CodexOpenAiModelDto(id: ${_this.id})';
}


}

/// @nodoc
abstract mixin class $CodexOpenAiModelDtoCopyWith<$Res>  {
  factory $CodexOpenAiModelDtoCopyWith(CodexOpenAiModelDto value, $Res Function(CodexOpenAiModelDto) _then) = _$CodexOpenAiModelDtoCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class _$CodexOpenAiModelDtoCopyWithImpl<$Res>
    implements $CodexOpenAiModelDtoCopyWith<$Res> {
  _$CodexOpenAiModelDtoCopyWithImpl(this._self, this._then);

  final CodexOpenAiModelDto _self;
  final $Res Function(CodexOpenAiModelDto) _then;

/// Create a copy of CodexOpenAiModelDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,}) {
  return _then(CodexOpenAiModelDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}



/// @nodoc
@JsonSerializable(createToJson: false)

class _CodexOpenAiModelDto implements CodexOpenAiModelDto {
  const _CodexOpenAiModelDto({required this.id});
  factory _CodexOpenAiModelDto.fromJson(Map<String, dynamic> json) => _$CodexOpenAiModelDtoFromJson(json);

@override final  String id;

/// Create a copy of CodexOpenAiModelDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CodexOpenAiModelDtoCopyWith<_CodexOpenAiModelDto> get copyWith => __$CodexOpenAiModelDtoCopyWithImpl<_CodexOpenAiModelDto>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CodexOpenAiModelDto&&(identical(other.id, id) || other.id == id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id);
}

@override
String toString() {
    return 'CodexOpenAiModelDto(id: $id)';
}


}

/// @nodoc
abstract mixin class _$CodexOpenAiModelDtoCopyWith<$Res> implements $CodexOpenAiModelDtoCopyWith<$Res> {
  factory _$CodexOpenAiModelDtoCopyWith(_CodexOpenAiModelDto value, $Res Function(_CodexOpenAiModelDto) _then) = __$CodexOpenAiModelDtoCopyWithImpl;
@override @useResult
$Res call({
 String id
});




}
/// @nodoc
class __$CodexOpenAiModelDtoCopyWithImpl<$Res>
    implements _$CodexOpenAiModelDtoCopyWith<$Res> {
  __$CodexOpenAiModelDtoCopyWithImpl(this._self, this._then);

  final _CodexOpenAiModelDto _self;
  final $Res Function(_CodexOpenAiModelDto) _then;

/// Create a copy of CodexOpenAiModelDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(_CodexOpenAiModelDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
