class APIConfig {
  static const String _devBaseUrl = "http://10.0.2.2:8080/api"; // 假設後端端口是 8080
  static const String _prodBaseUrl = "https://your.api.production.com/api";

  // 使用 Dart 的編譯時環境變量 (通過 --dart-define 設置)
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  static String get baseUrl {
    return isProduction ? _prodBaseUrl : _devBaseUrl;
  }

  static const String productsEndpoint = "/products";
  static const String cartEndpoint = "/cart";
// ... 其他端點
}
