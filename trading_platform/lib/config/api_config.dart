class APIConfig {
  // --- 1. 開發環境的後端網址 ---
  // 已修正為我們 FastAPI 伺服器使用的正確網址和端口。
  static const String _devBaseUrl = "http://10.0.2.2:8000";

  // --- 2. 生產環境的後端網址 ---
  // 這是 App 正式上線後要連接的真實伺服器網址。
  // 在部署前，你需要將 'your.api.production.com' 替換為你的真實網域。
  static const String _prodBaseUrl = "https://your.api.production.com";

  // --- 3. 自動環境偵測 ---
  // 這行程式碼會自動判斷 App 是在開發模式下運行還是在正式發布模式下運行。
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  // --- 4. 提供統一的 baseUrl ---
  // 你的 App 程式碼只需要呼叫 APIConfig.baseUrl，
  // 它就會根據當前的運行環境，自動回傳正確的網址。
  static String get baseUrl {
    return isProduction ? _prodBaseUrl : _devBaseUrl;
  }

// --- 5. API 端點 (可選，但推薦) ---
// 將 API 路徑也定義為常數，可以避免在 service 中打錯字。
// 例如：
// static const String authLogin = "/auth/login";
// static const String products = "/products";
}
