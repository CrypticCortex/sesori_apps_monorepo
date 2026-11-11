import "package:freezed_annotation/freezed_annotation.dart";

part "codex_open_ai_models_dto.freezed.dart";
part "codex_open_ai_models_dto.g.dart";

@Freezed(fromJson: true, toJson: false)
sealed class CodexOpenAiModelsDto with _$CodexOpenAiModelsDto {
  const factory({required List<CodexOpenAiModelDto> data}) = _CodexOpenAiModelsDto;

  factory fromJson(Map<String, dynamic> json) => _$CodexOpenAiModelsDtoFromJson(json);
}

@Freezed(fromJson: true, toJson: false)
sealed class CodexOpenAiModelDto with _$CodexOpenAiModelDto {
  const factory({required String id}) = _CodexOpenAiModelDto;

  factory fromJson(Map<String, dynamic> json) => _$CodexOpenAiModelDtoFromJson(json);
}
