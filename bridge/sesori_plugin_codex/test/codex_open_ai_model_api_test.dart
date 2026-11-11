import "dart:async";

import "package:codex_plugin/src/api/codex_open_ai_model_api.dart";
import "package:http/http.dart" as http;
import "package:http/testing.dart";
import "package:test/test.dart";

void main() {
  test("reads only model IDs from the official endpoint with a header credential", () async {
    await http.runWithClient(
      () async {
        final api = CodexOpenAiModelApi(apiKey: "fixture-key", requestTimeout: const Duration(seconds: 1));
        expect((await api.listModels()).data.map((model) => model.id), ["gpt-fixture"]);
      },
      () => MockClient((request) async {
        expect(request.url.toString(), "https://api.openai.com/v1/models");
        expect(request.headers["Authorization"], "Bearer fixture-key");
        expect(request.url.toString(), isNot(contains("fixture-key")));
        return http.Response('{"data":[{"id":"gpt-fixture","owned_by":"fixture"}]}', 200);
      }),
    );
  });

  test("unauthorized catalog is an observable error without response body or key", () async {
    await http.runWithClient(() async {
      final api = CodexOpenAiModelApi(apiKey: "fixture-key", requestTimeout: const Duration(seconds: 1));
      await expectLater(
        api.listModels(),
        throwsA(
          isA<CodexOpenAiModelException>()
              .having((error) => error.statusCode, "status", 401)
              .having((error) => error.toString(), "safe message", isNot(contains("fixture-key"))),
        ),
      );
    }, () => MockClient((_) async => http.Response('fixture-key upstream body', 401)));
  });

  test("a hung catalog request times out and retains its cause", () async {
    await http.runWithClient(() async {
      final api = CodexOpenAiModelApi(apiKey: "fixture-key", requestTimeout: const Duration(milliseconds: 5));
      await expectLater(
        api.listModels(),
        throwsA(isA<CodexOpenAiModelException>().having((error) => error.cause, "cause", isA<TimeoutException>())),
      );
    }, () => MockClient((_) => Completer<http.Response>().future));
  });
}
