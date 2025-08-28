class APIConfig {
  // --- 1. 開發環境的後端網址 ---
  static const String _devBaseUrl = "http://10.0.2.2:8000";

  // --- 2. 生產環境的後端網址 ---
  static const String _prodBaseUrl = "https://your.api.production.com";

  // --- 3. 自動環境偵測 ---
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  // --- 4. Mock 模式開關 (true = 使用模擬資料, false = 連後端 API) ---
  static const bool useMock = true; // 🚀 開發時設 true，上線前改 false

  // --- 5. 提供統一的 baseUrl ---
  static String get baseUrl {
    return isProduction ? _prodBaseUrl : _devBaseUrl;
  }

  // --- 6. API 端點 ---
  static const String authLogin = "/auth/login";
  static const String products = "/products";
}
