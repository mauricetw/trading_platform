import '../../models/user/shipping_option.dart';
import '../../services/abstractions.dart';
import '../../services/api_services/shipping_api_service.dart';

/// 別去動 ShippingApiService，這裡把它包成 IShippingService
class ShippingApiAdapter implements IShippingService {
  final ShippingApiService _api;
  ShippingApiAdapter(this._api);

  @override
  Future<List<ShippingOption>> getShippingOptions(String userId) {
    return _api.getShippingOptions(userId);
  }

  @override
  Future<ShippingOption> addShippingOption(ShippingOption option /*, String userId */) {
    // 你的原方法沒用 userId，所以先不帶
    return _api.addShippingOption(option);
  }

  @override
  Future<ShippingOption> updateShippingOption(ShippingOption option) {
    return _api.updateShippingOption(option);
  }

  @override
  Future<void> deleteShippingOption(String optionId) {
    return _api.deleteShippingOption(optionId);
  }
}
