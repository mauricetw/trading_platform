// --- FILE: lib/screens/user/checkout.dart ---
import 'package:first_flutter_project/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../../providers/checkout_provider.dart';
import '../../services/order_service.dart';
import '../../widgets/FullBottomConcaveAppBarShape.dart';
import '../../models/user/address.dart';
import '../../models/user/shipping_option.dart';
import '../../models/user/cart_item.dart';

const double _kBottomSummaryHeightEstimate = 220.0;

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- 關鍵修正：移除了本地的 Provider 和 Service 實例化 ---
    // 現在這個頁面會直接使用由 main.dart 提供的 CheckoutProvider

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('結帳'),
        centerTitle: true,
        backgroundColor: primaryCS.primary,
        foregroundColor: primaryCS.onPrimary,
        elevation: 6,
        shape: const FullBottomConcaveAppBarShape(
          curveHeight: 25,
          topCornerRadius: 15,
        ),
      ),
      body: Consumer<CheckoutProvider>(
        builder: (context, provider, child) {
          // 首次進入頁面時，觸發一次資料載入
          // 這裡的邏輯已移至 CheckoutProvider 的建構函式中，更為簡潔

          // 首屏載入地址
          if (provider.isLoadingAddresses && provider.availableAddresses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // 致命錯誤畫面
          if (provider.checkoutError != null &&
              provider.availableAddresses.isEmpty &&
              !provider.isLoadingAddresses) {
            return _FatalErrorView(error: provider.checkoutError!);
          }

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(
                  top: 16,
                  bottom: _kBottomSummaryHeightEstimate + 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 非致命提示（不再呼叫 provider.clearError()）
                    if (provider.checkoutError != null &&
                        provider.checkoutError!.isNotEmpty &&
                        (provider.availableAddresses.isNotEmpty || provider.isLoadingAddresses))
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(provider.checkoutError!, style: const TextStyle(fontSize: 13)),
                        ),
                      ),

                    // 1. 配送地址
                    _SectionCard(
                      title: '配送地址',
                      trailing: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('跳轉到地址管理頁 (TODO)')),
                          );
                        },
                        child: const Text('管理地址'),
                      ),
                      isLoading: provider.isLoadingAddresses,
                      child: provider.selectedAddress != null
                          ? _AddressTile(address: provider.selectedAddress!)
                          : (provider.availableAddresses.isEmpty && !provider.isLoadingAddresses)
                          ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('請添加配送地址'),
                      )
                          : const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('請選擇或添加配送地址'),
                      ),
                    ),

                    // 2. 配送方式
                    _ShippingSectionCard(provider: provider),

                    // 3. 商品摘要
                    _SectionCard(
                      title: '商品摘要',
                      child: _CartSummary(
                        items: provider.checkoutItems,
                        itemsSubtotal: provider.itemsSubtotal,
                      ),
                    ),

                    // 4. 優惠券
                    _SectionCard(
                      title: '優惠券',
                      isLoading: provider.isApplyingCoupon,
                      child: _CouponField(),
                    ),

                    // 5. 支付方式（暫時固定）
                    _SectionCard(
                      title: '支付方式',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.wallet_outlined),
                        title: const Text('貨到付款'),
                        trailing: const Radio<bool>(value: true, groupValue: true, onChanged: null),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // 底部結算欄
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _BottomSummaryBar(),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// ----------------------
/// 小型元件（樣式對齊）
/// ----------------------

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isLoading;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.child,
    this.isLoading = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Card(
        elevation: 1.5,
        color: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  else if (trailing != null)
                    trailing!,
                ],
              ),
              const SizedBox(height: 10),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  final Address address;
  const _AddressTile({required this.address});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.location_on_outlined),
      title: Text(
        '${address.recipientName}（${address.phoneNumber}）',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(address.displayAddress, maxLines: 2, overflow: TextOverflow.ellipsis),
    );
  }
}

class _ShippingSectionCard extends StatelessWidget {
  final CheckoutProvider provider;
  const _ShippingSectionCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget content;
    if (provider.selectedAddress == null) {
      content = const Text('請先選擇配送地址。');
    } else if (provider.isLoadingShippingOptions) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(child: Text('正在加載配送方式...', style: TextStyle(fontSize: 13))),
      );
    } else if (provider.shippingOptions.isEmpty) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(child: Text('此地址無可用配送方式。', style: TextStyle(fontSize: 13))),
      );
    } else {
      content = ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: provider.shippingOptions.length,
        separatorBuilder: (_, __) => Divider(
          height: 8,
          color: Theme.of(context).dividerColor.withOpacity(0.6), // 取代 outlineVariant
        ),
        itemBuilder: (_, i) {
          final ShippingOption opt = provider.shippingOptions[i];
          return RadioListTile<ShippingOption>(
            value: opt,
            groupValue: provider.selectedShippingOption,
            onChanged: opt.isEnabled ? (v) => provider.selectShippingOption(v!) : null,
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeColor: Theme.of(context).primaryColor,
            title: Text(opt.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              '${opt.description}（NT\$${opt.cost.toStringAsFixed(0)}）',
              style: const TextStyle(fontSize: 13),
            ),
            secondary: opt.isEnabled ? null : const Icon(Icons.block, color: Colors.grey),
          );
        },
      );
    }

    return _SectionCard(
      title: '配送方式',
      isLoading: provider.isLoadingShippingOptions && provider.selectedAddress != null,
      child: content,
    );
  }
}

class _CartSummary extends StatelessWidget {
  final List<CartItem> items;
  final double itemsSubtotal;
  const _CartSummary({required this.items, required this.itemsSubtotal});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('您的購物車是空的。'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...items.map(
              (it) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text('${it.product.name} x ${it.quantity}', style: const TextStyle(fontSize: 14)),
                ),
                Text('NT\$${(it.product.price * it.quantity).toStringAsFixed(0)}'),
              ],
            ),
          ),
        ),
        const Divider(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('商品小計：', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('NT\$${itemsSubtotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

class _CouponField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckoutProvider>();
    final controller = TextEditingController(text: provider.lastAppliedCouponCode ?? '');
    controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));

    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: '輸入優惠券代碼',
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon: provider.isApplyingCoupon
                ? const Padding(
              padding: EdgeInsets.all(10),
              child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
            )
                : IconButton(
              icon: const Icon(Icons.local_offer_outlined, size: 20),
              onPressed: () {
                FocusScope.of(context).unfocus();
                if (provider.checkoutItems.isNotEmpty) {
                  provider.applyCoupon(controller.text);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('購物車是空的，無法套用優惠券。')),
                  );
                }
              },
            ),
          ),
          onSubmitted: (v) {
            FocusScope.of(context).unfocus();
            if (provider.checkoutItems.isNotEmpty) {
              provider.applyCoupon(v);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('購物車是空的，無法套用優惠券。')),
              );
            }
          },
        ),
        if (provider.discountInfo != null &&
            provider.discountInfo!.message != null &&
            provider.discountInfo!.message!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              provider.discountInfo!.message!,
              style: TextStyle(
                fontSize: 13,
                color: provider.discountInfo!.discountAmount > 0 || provider.discountInfo!.isFreeShipping
                    ? Colors.green.shade700
                    : Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}

class _BottomSummaryBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckoutProvider>();
    final bottom = MediaQuery.of(context).padding.bottom;
    final scheme = Theme.of(context).colorScheme;

    return Material(
      elevation: 8,
      child: Container(
        color: scheme.surface,
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _line('商品小計：', provider.itemsSubtotal),
            const SizedBox(height: 4),
            _line('運費：', provider.shippingCost),
            if (provider.discountAmount > 0) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      '優惠券（${provider.discountInfo?.appliedCouponCode ?? ''}）：',
                      style: TextStyle(fontSize: 14, color: Colors.green.shade700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '-NT\$${provider.discountAmount.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 14, color: Colors.green.shade700),
                  ),
                ],
              ),
            ],
            const Divider(height: 20, thickness: 0.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('應付總額：', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  'NT\$${provider.totalAmount.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: scheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: const StadiumBorder(),
                ),
                onPressed: provider.isPlacingOrder ||
                    provider.checkoutItems.isEmpty ||
                    provider.selectedAddress == null ||
                    provider.selectedShippingOption == null
                    ? null
                    : () async {
                  final order = await provider.placeOrder();
                  if (!context.mounted) return;
                  if (order != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.green,
                        content: Text('訂單已創建！ID: ${order.orderId}'),
                      ),
                    );
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        content: Text('下單失敗：${provider.checkoutError ?? '未知錯誤'}'),
                      ),
                    );
                  }
                },
                child: provider.isPlacingOrder
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
                    : const Text('提交訂單'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _line(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Text('NT\$${value.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

class _FatalErrorView extends StatelessWidget {
  final String error;
  const _FatalErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: scheme.error, size: 56),
            const SizedBox(height: 12),
            Text('錯誤：$error\n請返回並重試。', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
