import 'package:first_flutter_project/providers/auth_provider.dart';
import 'package:first_flutter_project/providers/cart_provider.dart';
import 'package:first_flutter_project/services/address_service.dart';
import 'package:first_flutter_project/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/checkout_provider.dart';
import '../../services/order_service.dart';
import '../../widgets/FullBottomConcaveAppBarShape.dart';
import '../../models/user/address.dart';
import '../../models/user/shipping_option.dart';
import '../../models/user/cart_item.dart';
import '../../models/order/order.dart'; // 添加 OrderModel 的導入

const double _kBottomSummaryHeightEstimate = 220.0;

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 從現有的 Provider 獲取實例
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    // 創建必要的服務
    final orderService = OrderService();
    final addressService = AddressService();

    return ChangeNotifierProvider(
      create: (_) => CheckoutProvider(
        orderService,
        addressService,
        authProvider,
        cartProvider,
      ), // 移除 loadInitialData()，因為在構造函數中已經調用了 _initializeCheckoutData
      child: Scaffold(
        backgroundColor: primaryCS.surface,
        appBar: AppBar(
          title: const Text('結帳'),
          backgroundColor: primaryCS.primary,
          foregroundColor: primaryCS.onPrimary,
          elevation: 0,
          shape: const FullBottomConcaveAppBarShape(
            curveHeight: 25,
            topCornerRadius: 15,
          ),
        ),
        body: Consumer<CheckoutProvider>(
          builder: (context, provider, child) {
            if (provider.isLoadingAddresses &&
                provider.availableAddresses.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.checkoutError != null &&
                provider.availableAddresses.isEmpty &&
                !provider.isLoadingAddresses) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "錯誤: ${provider.checkoutError}\n請返回並重試。",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              );
            }

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    top: 16.0,
                    bottom: _kBottomSummaryHeightEstimate + 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // 統一錯誤提示
                      if (provider.checkoutError != null &&
                          provider.checkoutError!.isNotEmpty &&
                          (provider.availableAddresses.isNotEmpty ||
                              provider.isLoadingAddresses))
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Text(
                            provider.checkoutError!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // 1. 配送地址
                      _buildSectionContainer(
                        context: context,
                        title: "配送地址",
                        isLoading: provider.isLoadingAddresses,
                        trailing: TextButton(
                          child: const Text("管理地址"),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("跳轉到地址管理頁面 (TODO)")),
                            );
                          },
                        ),
                        child: provider.selectedAddress != null
                            ? _buildAddressInfo(
                          context,
                          provider.selectedAddress!,
                          provider,
                        )
                            : provider.availableAddresses.isEmpty &&
                            !provider.isLoadingAddresses
                            ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text("請添加配送地址"),
                        )
                            : const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text("請選擇或添加配送地址"),
                        ),
                      ),

                      // 2. 配送方式
                      _buildShippingSection(context, provider),

                      // 3. 購物車商品摘要
                      _buildSectionContainer(
                        context: context,
                        title: "商品摘要",
                        child: _buildCartSummary(context, provider),
                      ),

                      // 4. 優惠券
                      _buildSectionContainer(
                        context: context,
                        title: "優惠券",
                        isLoading: provider.isApplyingCoupon,
                        child: _buildCouponSection(context, provider),
                      ),

                      // 5. 支付方式
                      _buildSectionContainer(
                        context: context,
                        title: "支付方式",
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.wallet_outlined),
                          title: const Text("貨到付款"),
                          trailing: Radio<bool>(
                            value: true,
                            groupValue: true,
                            onChanged: (bool? value) {},
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // 底部固定區域
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildBottomSummaryAndButton(context, provider),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionContainer({
    required BuildContext context,
    required String title,
    required Widget child,
    bool isLoading = false,
    Widget? trailing,
    EdgeInsetsGeometry? padding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 8.0,
    ),
    EdgeInsetsGeometry? contentPadding = const EdgeInsets.fromLTRB(
      16.0,
      12.0,
      16.0,
      16.0,
    ),
  }) {
    return Container(
      color: Theme.of(context).cardColor,
      margin: padding,
      padding: contentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              else if (trailing != null)
                trailing,
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildAddressInfo(
      BuildContext context,
      Address address,
      CheckoutProvider provider,
      ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        "${address.recipientName ?? 'N/A'} (${address.phoneNumber ?? 'N/A'})",
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        address.displayAddress,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildShippingSection(
      BuildContext context,
      CheckoutProvider provider,
      ) {
    const double shippingOptionsListHeight = 160.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
      color: primaryCS.tertiary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "配送方式",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              if (provider.isLoadingShippingOptions &&
                  provider.selectedAddress != null)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
            ],
          ),
          const SizedBox(height: 10),
          provider.selectedAddress == null
              ? const Text("請先選擇配送地址。")
              : provider.isLoadingShippingOptions
              ? const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text("正在加載配送方式...", style: TextStyle(fontSize: 13)),
            ),
          )
              : provider.shippingOptions.isEmpty
              ? const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text("此地址無可用配送方式。", style: TextStyle(fontSize: 13)),
            ),
          )
              : SizedBox(
            height: shippingOptionsListHeight,
            child: _buildShippingOptionListWidget(context, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingOptionListWidget(
      BuildContext context,
      CheckoutProvider provider,
      ) {
    return ListView.builder(
      itemCount: provider.shippingOptions.length,
      itemBuilder: (context, index) {
        final option = provider.shippingOptions[index];
        return RadioListTile<ShippingOption>(
          title: Text(
            option.name,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            "${option.description} (NT\$${option.cost.toStringAsFixed(0)})",
            style: const TextStyle(fontSize: 13),
          ),
          value: option,
          groupValue: provider.selectedShippingOption,
          onChanged: option.isEnabled
              ? (ShippingOption? value) {
            if (value != null) provider.selectShippingOption(value);
          }
              : null,
          activeColor: option.isEnabled ? Theme.of(context).primaryColor : Colors.grey,
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
        );
      },
    );
  }

  Widget _buildCartSummary(BuildContext context, CheckoutProvider provider) {
    final List<CartItem> items = provider.checkoutItems;

    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text("您的購物車是空的。"),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...items.map(
              (item) => Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "${item.product.name} x ${item.quantity}",
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                Text(
                  "NT\$${(item.product.price * item.quantity).toStringAsFixed(0)}",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("商品小計:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              "NT\$${provider.itemsSubtotal.toStringAsFixed(0)}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCouponSection(BuildContext context, CheckoutProvider provider) {
    final TextEditingController couponController = TextEditingController(
      text: provider.lastAppliedCouponCode ?? '',
    );
    couponController.selection = TextSelection.fromPosition(
      TextPosition(offset: couponController.text.length),
    );

    return Column(
      children: [
        TextField(
          controller: couponController,
          decoration: InputDecoration(
            hintText: '輸入優惠券代碼',
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 12,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon: provider.isApplyingCoupon
                ? const Padding(
              padding: EdgeInsets.all(10.0),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
                : IconButton(
              icon: const Icon(Icons.local_offer_outlined, size: 20),
              onPressed: () {
                FocusScope.of(context).unfocus();
                if (provider.checkoutItems.isNotEmpty) {
                  provider.applyCoupon(couponController.text);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("購物車是空的，無法套用優惠券。")),
                  );
                }
              },
            ),
          ),
          onSubmitted: (value) {
            FocusScope.of(context).unfocus();
            if (provider.checkoutItems.isNotEmpty) {
              provider.applyCoupon(value);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("購物車是空的，無法套用優惠券。")),
              );
            }
          },
        ),
        if (provider.discountInfo != null &&
            provider.discountInfo!.message != null &&
            provider.discountInfo!.message!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              provider.discountInfo!.message!,
              style: TextStyle(
                fontSize: 13,
                color: provider.discountInfo!.discountAmount > 0 ||
                    provider.discountInfo!.isFreeShipping
                    ? Colors.green.shade700
                    : Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildBottomSummaryAndButton(
      BuildContext context,
      CheckoutProvider provider,
      ) {
    final bottomSafePadding = MediaQuery.of(context).padding.bottom;
    return Material(
      elevation: 8.0,
      child: Container(
        color: primaryCS.secondary,
        padding: EdgeInsets.fromLTRB(
          16.0,
          16.0,
          16.0,
          bottomSafePadding + 16.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("商品小計:", style: TextStyle(fontSize: 14)),
                Text(
                  "NT\$${provider.itemsSubtotal.toStringAsFixed(0)}",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("運費:", style: TextStyle(fontSize: 14)),
                Text(
                  "NT\$${provider.shippingCost.toStringAsFixed(0)}",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            if (provider.discountAmount > 0) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      "優惠券 (${provider.discountInfo?.appliedCouponCode ?? ''}):",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green.shade700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    "-NT\$${provider.discountAmount.toStringAsFixed(0)}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ],
            const Divider(height: 20, thickness: 0.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "應付總額:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "NT\$${provider.totalAmount.toStringAsFixed(0)}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                textStyle: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: provider.isPlacingOrder ||
                  provider.checkoutItems.isEmpty ||
                  provider.selectedAddress == null ||
                  provider.selectedShippingOption == null
                  ? null
                  : () async {
                final order = await provider.placeOrder();
                if (order != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.green,
                      content: Text(
                        "訂單已創建！ID: ${order.orderId ?? 'N/A'}",
                      ),
                    ),
                  );
                  Navigator.of(context).popUntil((route) => route.isFirst);
                } else if (order == null &&
                    context.mounted &&
                    provider.checkoutError != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      content: Text("下單失敗: ${provider.checkoutError}"),
                    ),
                  );
                }
              },
              child: provider.isPlacingOrder
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
                  : const Text("提交訂單"),
            ),
          ],
        ),
      ),
    );
  }
}