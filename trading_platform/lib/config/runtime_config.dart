class RuntimeConfig {
  static const bool useMock =
  bool.fromEnvironment('USE_MOCK', defaultValue: true);
  static const bool bypassAuth =
  bool.fromEnvironment('BYPASS_AUTH', defaultValue: true);
  static const String bypassRoute =
  String.fromEnvironment('BYPASS_ROUTE', defaultValue: '');
}
