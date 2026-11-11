import "package:http/http.dart" as http;
import "package:sesori_shared/sesori_shared.dart";

import "models/codex_open_ai_models_dto.dart";

/// The official API catalog for the bridge's environment key. Credentials
/// stay in the request header and never enter a catalog or process argument.
class CodexOpenAiModelApi({
  required final String? _apiKey,
  required final Duration _requestTimeout,
}) {
  bool get isConfigured => _apiKey?.trim().isNotEmpty ?? false;

  Future<CodexOpenAiModelsDto> listModels() async {
    if (!isConfigured) throw StateError("OpenAI API requires OPENAI_API_KEY in the bridge environment.");
    final client = http.Client();
    try {
      final response = await client
          .get(Uri.https("api.openai.com", "/v1/models"), headers: {"Authorization": "Bearer ${_apiKey?.trim()}"})
          .timeout(_requestTimeout);
      if (response.statusCode != 200) {
        throw CodexOpenAiModelException(statusCode: response.statusCode, cause: null);
      }
      return CodexOpenAiModelsDto.fromJson(jsonDecodeMap(response.body));
    } on CodexOpenAiModelException {
      rethrow;
    } on Object catch (error) {
      throw CodexOpenAiModelException(statusCode: null, cause: error);
    } finally {
      client.close();
    }
  }
}

final class const CodexOpenAiModelException({
  required final int? statusCode,
  required final Object? cause,
}) implements Exception {
  @override
  String toString() => "OpenAI API model discovery failed${statusCode == null ? '' : ' (HTTP $statusCode)'}.";
}
