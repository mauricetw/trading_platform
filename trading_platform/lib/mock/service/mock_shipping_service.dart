import 'dart:async';
import '../../models/user/shipping_option.dart';
import '../../services/abstractions.dart';

class MockShippingService implements IShippingService {
  final List<ShippingOption> _db = [];
  int _seq = 1;

  MockShippingService() {
    _seed();
  }

  void _seed() {
    _db
      ..clear()
      ..addAll([
        ShippingOption(
          id: _genId(),
          name: '模擬-7-11 超商取貨 (C2C)',
          cost: 60.0,
          description: '限重5公斤，尺寸 45x30x30 cm，本島門市。',
          isEnabled: true,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        ShippingOption(
          id: _genId(),
          name: '模擬-黑貓宅配',
          cost: 120.0,
          description: '本島常溫翌日到貨（模擬）。',
          isEnabled: true,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
        ShippingOption(
          id: _genId(),
          name: '模擬-郵局掛號',
          cost: 80.0,
          description: '約 2–3 個工作天（模擬）。',
          isEnabled: false,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ]);
  }

  String _genId() => 'mock_id_${_seq++}';

  @override
  Future<List<ShippingOption>> getShippingOptions(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List<ShippingOption>.from(_db);
  }

  @override
  Future<ShippingOption> addShippingOption(ShippingOption option) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final newOption = option.copyWith(
      id: _genId(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _db.add(newOption);
    return newOption;
  }

  @override
  Future<ShippingOption> updateShippingOption(ShippingOption option) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final i = _db.indexWhere((o) => o.id == option.id);
    if (i < 0) {
      throw StateError('Mock: option ${option.id} not found');
    }
    final updated = option.copyWith(updatedAt: DateTime.now());
    _db[i] = updated;
    return updated;
  }

  @override
  Future<void> deleteShippingOption(String optionId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _db.removeWhere((o) => o.id == optionId);
  }
}
