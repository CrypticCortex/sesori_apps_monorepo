// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'codex_open_ai_models_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CodexOpenAiModelsDto _$CodexOpenAiModelsDtoFromJson(Map json) =>
    _CodexOpenAiModelsDto(
      data: (json['data'] as List<dynamic>)
          .map(
            (e) => CodexOpenAiModelDto.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
    );

_CodexOpenAiModelDto _$CodexOpenAiModelDtoFromJson(Map json) =>
    _CodexOpenAiModelDto(id: json['id'] as String);
