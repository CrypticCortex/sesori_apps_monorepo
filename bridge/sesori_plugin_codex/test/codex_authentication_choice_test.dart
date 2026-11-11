import "dart:async";
import "dart:convert";
import "dart:io";

import "package:codex_plugin/codex_plugin.dart";
import "package:http/http.dart" as http;
import "package:http/testing.dart";
import "package:path/path.dart" as p;
import "package:sesori_plugin_interface/sesori_plugin_interface.dart";
import "package:test/test.dart";

import "support/codex_plugin_test_factory.dart";

const _apiProvider = "sesori-openai-api";
const _model = "gpt-fixture";
const _dummyKey = "dummy-openai-key-not-a-secret";

void main() {
  late Directory home;
  late _RoutingAppServer server;
  late CodexPlugin plugin;
  var apiCatalogStatus = 200;
  Future<T> discover<T>(Future<T> Function() load) => http.runWithClient(
    load,
    () => MockClient((request) async {
      expect(request.url.toString(), "https://api.openai.com/v1/models");
      expect(request.headers["Authorization"], "Bearer $_dummyKey");
      return http.Response(
        jsonEncode({
          "data": [
            {"id": _model},
            {"id": "audio-only"},
          ],
        }),
        apiCatalogStatus,
      );
    }),
  );

  setUp(() async {
    apiCatalogStatus = 200;
    home = await Directory.systemTemp.createTemp("codex-auth-choice-");
    server = await _RoutingAppServer.start();
  });

  tearDown(() async {
    await plugin.dispose();
    await server.close();
    await home.delete(recursive: true);
  });

  void configure({required bool apiKeyConfigured, String provider = "openai", String model = _model}) {
    File(p.join(home.path, "config.toml")).writeAsStringSync(
      'model = "$model"\nmodel_provider = "$provider"\n',
    );
    plugin = createInjectedCodexPlugin(
      toolOutcomeRepository: createMemoryCodexToolOutcomeRepository(),
      runtimeExit: runningCodexRuntime,
      serverUrl: server.url,
      environment: {"CODEX_HOME": home.path, if (apiKeyConfigured) "OPENAI_API_KEY": _dummyKey},
      projectCwd: "/repo/fixture",
      clientFactory: null,
      keepaliveInterval: const Duration(hours: 1),
    );
  }

  Future<PluginSession> create({required String? provider}) => plugin.createSession(
    directory: "/repo/fixture",
    parentSessionId: null,
    parts: const [PluginPromptPart.text(text: "fixture prompt")],
    userVisibleText: null,
    variant: null,
    agent: null,
    model: provider == null ? null : (providerID: provider, modelID: _model),
    fastMode: false,
  );

  Future<void> prompt({required String? provider}) => plugin.sendPrompt(
    sessionId: "thread-fixture",
    promptId: "prompt-fixture",
    parts: const [PluginPromptPart.text(text: "fixture continuation")],
    variant: null,
    agent: null,
    model: provider == null ? null : (providerID: provider, modelID: _model),
    fastMode: false,
  );

  Future<void> command({required String name, required String? provider}) => plugin.sendCommand(
    sessionId: "thread-fixture",
    promptId: "command-fixture",
    command: name,
    arguments: "",
    userVisibleArguments: null,
    variant: null,
    agent: null,
    model: provider == null ? null : (providerID: provider, modelID: _model),
    fastMode: false,
  );

  for (final account in <String?>[null, "apiKey", "futureAccount"]) {
    test("API generation does not need ChatGPT login (${account ?? 'absent'})", () async {
      server.accountType = account;
      configure(apiKeyConfigured: true);

      await create(provider: _apiProvider);
      await prompt(provider: null);
      await command(name: "review", provider: null);
      await command(name: "compact", provider: null);

      expect(server.generations.map((generation) => generation.provider), everyElement(_apiProvider));
      expect(server.generations.map((generation) => generation.operation), ["turn", "turn", "turn", "compact"]);
      expect(server.calls.map((call) => call.method), isNot(contains("account/read")));
      expect(jsonEncode(server.calls.map((call) => call.params).toList()), isNot(contains(_dummyKey)));
    });

    test(
      "native login accepts supported or future account kinds and rejects only absence (${account ?? 'absent'})",
      () async {
        server.accountType = account;
        configure(apiKeyConfigured: true);

        if (account != null) {
          await create(provider: "openai");
          await prompt(provider: "openai");
          expect(server.generations.map((generation) => generation.provider), everyElement("openai"));
          return;
        }

        await expectLater(create(provider: "openai"), throwsA(isA<StateError>()));
        expect(server.calls.map((call) => call.method), isNot(contains("thread/start")));
        expect(server.generations, isEmpty);

        await create(provider: _apiProvider);
        final acceptedGenerations = List<_Generation>.of(server.generations);
        final resumes = server.resumeProviders.length;
        for (final action in <Future<void> Function()>[
          () => prompt(provider: "openai"),
          () => command(name: "review", provider: "openai"),
          () => command(name: "compact", provider: "openai"),
        ]) {
          await expectLater(action(), throwsA(isA<StateError>()));
          expect(server.provider, _apiProvider);
          expect(server.resumeProviders, hasLength(resumes));
          expect(server.generations, acceptedGenerations);
        }
        await prompt(provider: null);
        expect(server.generations.last.provider, _apiProvider);
      },
    );
  }

  for (final (index, response) in <Object>[
    "invalid response",
    <Object>[],
    {"account": "invalid account"},
    {
      "account": {"type": 123},
    },
  ].indexed) {
    test("subscription rejects malformed account response $index before generation", () async {
      server.accountResponse = response;
      configure(apiKeyConfigured: true);

      await expectLater(
        create(provider: "openai"),
        throwsA(anyOf(isA<StateError>(), isA<TypeError>(), isA<ArgumentError>())),
      );
      expect(server.calls.map((call) => call.method), isNot(contains("thread/start")));
      expect(server.generationAttempts, isEmpty);
      expect(server.provider, "openai");
    });
  }

  test("loaded native sessions check authentication once until an actual resume", () async {
    configure(apiKeyConfigured: false);
    await create(provider: "openai");
    await prompt(provider: null);
    await command(name: "compact", provider: null);
    expect(server.calls.where((call) => call.method == "account/read"), hasLength(1));
    server.failNextGeneration = true;
    await prompt(provider: null);
    expect(server.calls.where((call) => call.method == "account/read"), hasLength(2));
  });

  test("missing standard environment key rejects API without falling back to subscription", () async {
    server.accountType = "apiKey";
    configure(apiKeyConfigured: false);

    await expectLater(create(provider: _apiProvider), throwsA(isA<StateError>()));
    expect(server.calls.map((call) => call.method), isNot(contains("thread/start")));
    server.accountType = "chatgpt";
    await create(provider: "openai");
    final acceptedGenerations = List<_Generation>.of(server.generations);
    for (final action in <Future<void> Function()>[
      () => prompt(provider: _apiProvider),
      () => command(name: "review", provider: _apiProvider),
      () => command(name: "compact", provider: _apiProvider),
    ]) {
      await expectLater(action(), throwsA(isA<StateError>()));
      expect(server.provider, "openai");
      expect(server.resumeProviders, isEmpty);
      expect(server.generations, acceptedGenerations);
    }
  });

  for (final initialProvider in ["openai", _apiProvider]) {
    test(
      "an existing $initialProvider session rejects billing changes without mutating prompts or snapshots",
      () async {
        configure(apiKeyConfigured: true);
        await create(provider: initialProvider);
        final otherProvider = initialProvider == "openai" ? _apiProvider : "openai";
        final acceptedGenerations = List<_Generation>.of(server.generations);
        for (final action in <Future<void> Function()>[
          () => prompt(provider: otherProvider),
          () => command(name: "review", provider: otherProvider),
          () => command(name: "compact", provider: otherProvider),
        ]) {
          await expectLater(action(), throwsA(isA<StateError>()));
          expect(server.provider, initialProvider);
          expect(server.resumeProviders, isEmpty);
          expect(server.generations, acceptedGenerations);
        }
        await prompt(provider: null);
        final snapshot = plugin.events
            .where((event) => event is BridgeSseMessageUpdated && event.info.id == "message-retained")
            .cast<BridgeSseMessageUpdated>()
            .first;
        server.emitAssistant(id: "message-retained");
        expect((await snapshot.timeout(const Duration(seconds: 2))).info.toJson()["providerID"], initialProvider);
        expect(server.generations.last.provider, initialProvider);
      },
    );
  }

  test("omitted model resumes and preserves thread provider instead of project config", () async {
    server
      ..accountType = null
      ..provider = _apiProvider;
    configure(apiKeyConfigured: true, provider: "openai", model: "different-config-model");

    await prompt(provider: null);
    await command(name: "review", provider: null);

    expect(server.resumeProviders, [_apiProvider]);
    expect(server.generations.map((generation) => generation.provider), [_apiProvider, _apiProvider]);
    expect(server.calls.map((call) => call.method), isNot(contains("account/read")));
  });

  test("omitted model validates resumed subscription even when config selects API", () async {
    server
      ..accountType = null
      ..provider = "openai";
    configure(apiKeyConfigured: true, provider: _apiProvider);

    await expectLater(prompt(provider: null), throwsA(isA<StateError>()));
    expect(server.resumeProviders, isEmpty);
    expect(server.provider, "openai");
    expect(server.generations, isEmpty);
    await expectLater(command(name: "compact", provider: null), throwsA(isA<StateError>()));
    expect(server.generations, isEmpty);
  });

  test("resumed custom provider remains in catalog even when project config selects native", () async {
    server
      ..accountType = null
      ..provider = "fixture-custom";
    configure(apiKeyConfigured: false, provider: "openai", model: "gpt-other");
    await prompt(provider: null);

    final options = await discover(() => plugin.getProviders(projectId: "/repo/fixture"));
    final custom = options.providers.singleWhere((provider) => provider.id == "fixture-custom");
    expect(custom.defaultModelID, _model);
    expect(custom.models.map((model) => model.id), [_model]);
    expect(server.generations.single.provider, "fixture-custom");
  });

  for (final operation in ["prompt", "review", "compact"]) {
    test("not-loaded retry keeps requested API provider for $operation", () async {
      configure(apiKeyConfigured: true);
      await create(provider: _apiProvider);
      server.failNextGeneration = true;

      if (operation == "prompt") {
        await prompt(provider: _apiProvider);
      } else {
        await command(name: operation, provider: _apiProvider);
      }

      expect(server.resumeProviders, [_apiProvider]);
      expect(server.generationAttempts.skip(1).map((generation) => generation.provider), [_apiProvider, _apiProvider]);
      expect(server.generations.last.provider, _apiProvider);
    });
  }

  test("custom provider generation remains independent of native authentication", () async {
    server.accountType = "futureAccount";
    configure(apiKeyConfigured: false, provider: "fixture-custom");

    await create(provider: "fixture-custom");
    await prompt(provider: null);
    await command(name: "compact", provider: null);

    expect(server.generations.map((generation) => generation.provider), everyElement("fixture-custom"));
    expect(server.calls.map((call) => call.method), isNot(contains("account/read")));
  });

  test("catalog exposes both billing routes without inventing custom-provider models or defaults", () async {
    configure(apiKeyConfigured: true, provider: "fixture-custom", model: "custom-only-model");
    await plugin.initialize();
    final options = await discover(() => plugin.getProviders(projectId: "/repo/fixture"));
    final providers = {for (final provider in options.providers) provider.id: provider};

    expect(providers.keys, ["openai", _apiProvider, "fixture-custom"]);
    expect(providers["openai"]?.name, "ChatGPT subscription");
    expect(providers[_apiProvider]?.name, "OpenAI API");
    expect(providers["openai"]?.authType, PluginProviderAuthType.oauth);
    expect(providers[_apiProvider]?.authType, PluginProviderAuthType.apiKey);
    for (final id in ["openai", _apiProvider]) {
      expect(providers[id]?.defaultModelID, _model);
      expect(providers[id]?.models.map((model) => model.id), id == "openai" ? [_model, "gpt-other"] : [_model]);
    }
    expect(providers["openai"]?.models.first.name, "Fixture model · ChatGPT");
    expect(providers[_apiProvider]?.models.first.name, "Fixture model · API");
    expect(providers["fixture-custom"]?.defaultModelID, "custom-only-model");
    expect(providers["fixture-custom"]?.models.map((model) => model.id), ["custom-only-model"]);
  });

  test("environment-key-only setup defaults to the available API route", () async {
    server.accountType = null;
    configure(apiKeyConfigured: true);
    await plugin.initialize();
    final agents = await discover(() => plugin.getAgents(projectId: "/repo/fixture"));
    expect(agents.single.model?.providerID, _apiProvider);
    final providers = (await discover(() => plugin.getProviders(projectId: "/repo/fixture"))).providers;
    expect(providers.first.models.every((model) => !model.isAvailable), isTrue);
    expect(providers.last.models.map((model) => model.id), [_model]);
    await discover(() => create(provider: null));
    expect(server.generations.single.provider, _apiProvider);
  });

  test("missing environment key omits API models before selection", () async {
    configure(apiKeyConfigured: false);
    await plugin.initialize();
    final providers = (await plugin.getProviders(projectId: "/repo/fixture")).providers;
    expect(providers.singleWhere((provider) => provider.id == _apiProvider).models, isEmpty);
    expect(providers.every((provider) => provider.isSessionFixed), isTrue);
  });

  test("API catalog denial keeps native models usable and API models unavailable", () async {
    configure(apiKeyConfigured: true);
    apiCatalogStatus = 401;
    await plugin.initialize();
    final providers = (await discover(() => plugin.getProviders(projectId: "/repo/fixture"))).providers;
    expect(providers.first.models.every((model) => model.isAvailable), isTrue);
    expect(providers.last.models, isEmpty);
  });

  test("native API-key login is labeled as API billing", () async {
    server.accountType = "apiKey";
    configure(apiKeyConfigured: false);
    await plugin.initialize();
    final native = (await plugin.getProviders(projectId: "/repo/fixture")).providers.first;
    expect(native.name, "OpenAI API (Codex login)");
    expect(native.authType, PluginProviderAuthType.apiKey);
    expect(native.models.every((model) => model.isAvailable && model.name.endsWith("API login")), isTrue);
  });

  test("a no-auth custom default does not manufacture a missing native account", () async {
    server.accountResponse = {"account": null, "requiresOpenaiAuth": false};
    configure(apiKeyConfigured: false, provider: "fixture-custom");
    await create(provider: "openai");
    expect(server.generations.single.provider, "openai");
  });

  for (final selectedProvider in ["openai", _apiProvider]) {
    test("project defaults are scoped to $selectedProvider rather than leaking across billing routes", () async {
      configure(apiKeyConfigured: true, provider: selectedProvider, model: "gpt-other");
      await plugin.initialize();
      final options = await discover(() => plugin.getProviders(projectId: "/repo/fixture"));
      final providers = {for (final provider in options.providers) provider.id: provider};

      expect(providers[selectedProvider]?.defaultModelID, selectedProvider == "openai" ? "gpt-other" : _model);
      final otherProvider = selectedProvider == "openai" ? _apiProvider : "openai";
      expect(providers[otherProvider]?.defaultModelID, _model);
    });
  }
}

typedef _Call = ({String method, Map<String, dynamic> params});
typedef _Generation = ({String operation, String provider});

class _RoutingAppServer({required final HttpServer _http}) {
  static Future<_RoutingAppServer> start() async {
    final result = _RoutingAppServer(http: await HttpServer.bind(InternetAddress.loopbackIPv4, 0));
    result._http.listen((request) async {
      final socket = await WebSocketTransformer.upgrade(request);
      result._sockets.add(socket);
      socket.listen((frame) => result._receive(socket: socket, frame: frame as String));
    });
    return result;
  }

  final List<WebSocket> _sockets = [];
  final List<_Call> calls = [];
  final List<String?> resumeProviders = [];
  final List<_Generation> generationAttempts = [];
  final List<_Generation> generations = [];
  String? accountType = "chatgpt";
  Object? accountResponse;
  String provider = "openai";
  bool failNextGeneration = false;
  int _turn = 0;

  String get url => "ws://127.0.0.1:${_http.port}";

  Map<String, Object?> get _threadResult => {
    "model": _model,
    "modelProvider": provider,
    "thread": {
      "id": "thread-fixture",
      "cwd": "/repo/fixture",
      "modelProvider": provider,
      "createdAt": 1700000000,
      "updatedAt": 1700000000,
    },
  };

  void _receive({required WebSocket socket, required String frame}) {
    final request = jsonDecode(frame) as Map<String, dynamic>;
    if (request["id"] == null) return;
    final method = request["method"] as String;
    final params = (request["params"] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    calls.add((method: method, params: params));
    Object? result;
    switch (method) {
      case "initialize":
        result = {"userAgent": "codex-fixture"};
      case "account/read":
        result =
            accountResponse ??
            {
              "account": accountType == null ? null : {"type": accountType, "email": "dummy@example.invalid"},
              "requiresOpenaiAuth": true,
            };
      case "config/read":
        result = {"config": <String, Object?>{}};
      case "thread/start":
        provider = params["modelProvider"] as String? ?? provider;
        result = _threadResult;
      case "thread/read":
        result = _threadResult;
      case "thread/resume":
        final requestedProvider = params["modelProvider"] as String?;
        resumeProviders.add(requestedProvider);
        provider = requestedProvider ?? provider;
        result = _threadResult;
      case "turn/start":
      case "thread/compact/start":
        final generation = (operation: method == "turn/start" ? "turn" : "compact", provider: provider);
        generationAttempts.add(generation);
        if (failNextGeneration) {
          failNextGeneration = false;
          socket.add(
            jsonEncode({
              "jsonrpc": "2.0",
              "id": request["id"],
              "error": {"code": -32600, "message": "thread not found"},
            }),
          );
          return;
        }
        generations.add(generation);
        result = method == "turn/start"
            ? {
                "turn": {"id": "turn-${++_turn}"},
              }
            : <String, Object?>{};
      case "model/list":
        result = {
          "data": [
            {"id": _model, "displayName": "Fixture model", "isDefault": true, "hidden": false},
            {"id": "gpt-other", "displayName": "Other model", "isDefault": false, "hidden": false},
          ],
        };
      default:
        throw StateError("Unexpected fixture request: $method");
    }
    socket.add(jsonEncode({"jsonrpc": "2.0", "id": request["id"], "result": result}));
  }

  void emitStarted() {
    _sockets.single.add(
      jsonEncode({
        "jsonrpc": "2.0",
        "method": "thread/started",
        "params": _threadResult,
      }),
    );
  }

  void emitAssistant({required String id}) {
    _sockets.single.add(
      jsonEncode({
        "jsonrpc": "2.0",
        "method": "item/completed",
        "params": {
          "threadId": "thread-fixture",
          "turnId": "turn-$_turn",
          "item": {"type": "agentMessage", "id": id, "text": "Fixture response"},
        },
      }),
    );
  }

  Future<void> close() async {
    for (final socket in _sockets) {
      await socket.close();
    }
    await _http.close(force: true);
  }
}
