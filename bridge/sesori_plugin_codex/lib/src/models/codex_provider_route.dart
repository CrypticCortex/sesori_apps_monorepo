/// Codex native credentials and the explicitly selected environment-key route.
enum CodexProviderRoute({
  required final String providerID,
}) {
  nativeLogin(
    providerID: "openai",
  ),
  openAiApi(
    providerID: "sesori-openai-api",
  );

  static CodexProviderRoute? fromProviderID({required String? providerID}) {
    for (final mode in values) {
      if (mode.providerID == providerID) return mode;
    }
    return null;
  }
}
