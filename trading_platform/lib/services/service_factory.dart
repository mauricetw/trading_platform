import '../config/runtime_config.dart';
import 'abstractions.dart';
import 'api_client.dart';

// (可選) 你若已有這些 API 類別就引入；沒有就先註解掉
// import 'api_service_auth.dart' show ApiAuthService;
// import 'api_service_user.dart' show ApiUserService;
// import 'api_service_product.dart' show ApiProductService;

// 你給的 ShippingApiService（現存檔案）
import 'api_services/shipping_api_service.dart';
import 'adapters/shipping_api_adapter.dart';

// Mock 版本
import '../mock/service/mock_auth_service.dart';
import '../mock/service/mock_user_service.dart';
import '../mock/service/mock_product_service.dart';
import '../mock/service/mock_shipping_service.dart';

IAuthService makeAuthService(ApiClient client) {
  // 你現在的登入流程在 ApiService 檔案中，不走這層也行。
  // 如果要走抽象層，請實作 ApiAuthService 再切換。
  if (RuntimeConfig.useMock || RuntimeConfig.bypassAuth) {
    return MockAuthService();
  } else {
    // return ApiAuthService(client);
    throw UnimplementedError('ApiAuthService 尚未接到 factory，先用 Mock 或補 API 版');
  }
}

IUserService makeUserService(ApiClient client) {
  if (RuntimeConfig.useMock) {
    return MockUserService();
  } else {
    // return ApiUserService(client);
    throw UnimplementedError('ApiUserService 尚未接到 factory，先用 Mock 或補 API 版');
  }
}

IProductService makeProductService(ApiClient client) {
  if (RuntimeConfig.useMock) {
    return MockProductService();
  } else {
    // return ApiProductService(client);
    throw UnimplementedError('ApiProductService 尚未接到 factory，先用 Mock 或補 API 版');
  }
}

IShippingService makeShippingService(ApiClient client) {
  if (RuntimeConfig.useMock) {
    return MockShippingService();
  } else {
    // 用 Adapter 包你現有的 ShippingApiService
    // 注意：把 ShippingApiService 裡的 _useMockData 設為 false，避免雙重 mock
    return ShippingApiAdapter(ShippingApiService());
  }
}
