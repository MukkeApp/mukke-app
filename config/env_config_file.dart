// config/env_config_file.dart
class EnvConfigFile {
  /// NEVER hardcode secrets in the repo.
  /// Provide OPENAI_API_KEY via environment / CI secrets.
  static const String openAiApiKey =
      String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
}
