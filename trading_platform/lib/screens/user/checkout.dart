import 'package:first_flutter_project/services/address_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/checkout_provider.dart';
import '../../services/order_service.dart';
// 移除了未使用的接口導入，如果 Provider 構造函數需要接口類型，則保留
// import '../../services/interfaces/order_service_interface.dart';
// import '../../services/interfaces/address_service_interface.dart';
import '../../widgets/FullBottomConcaveAppBarShape.dart';
import '../../widgets/BottomConvexArcWidget.dart';
import '../../models/user/address.dart';
import '../../models/user/shipping_option.dart';
import '../../models/user/cart_item.dart'; // 確保導入 CartItem
// import '../address/add_edit_address_screen.dart'; // 用於導航到地址編輯頁

const double _kBottomSummaryHeightEstimate = 220.0; // 估算的底部固定區域高度，用於滾動視圖的 bottom padding

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 在實際應用中，這些服務實例更適合通過依賴注入框架（如 get_it, provider）在更高層次創建並提供。
    // 為了簡化，暫時在此處直接實例化。
    final orderService = OrderService();
    final addressService = AddressService();

    return ChangeNotifierProvider(
      create: (_) => CheckoutProvider(orderService, addressService)..loadInitialData(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface, // 統一背景色
        appBar: AppBar(
          title: const Text('結帳'),
          backgroundColor: Colors.blueAccent, // 您可以自定義 AppBar 顏色
          elevation: 0, // 可以設置為 0，如果希望 Shape 更突出
          shape: const FullBottomConcaveAppBarShape(
            curveHeight: 25, // AppBar 底部凹陷曲線的高度
            topCornerRadius: 15, // AppBar 頂部圓角 (可選)
          ),
        ),
        body: Consumer<CheckoutProvider>(
          builder: (context, provider, child) {
            if (provider.isLoadingAddresses && provider.availableAddresses.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            // 初始加載地址失敗且沒有地址時顯示錯誤
            if (provider.checkoutError != null && provider.availableAddresses.isEmpty && !provider.isLoadingAddresses) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "錯誤: ${provider.checkoutError}\n請返回並重試。",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              );
            }

            return Stack( // 使用 Stack 以便將底部總結固定在最下方
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    top: 16.0, // 內容區域頂部留白
                    bottom: _kBottomSummaryHeightEstimate + 16.0, // 為底部固定區域預留空間 + 額外間距
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // --- 統一錯誤提示 (非初始加載地址錯誤) ---
                      if (provider.checkoutError != null && provider.checkoutError!.isNotEmpty && (provider.availableAddresses.isNotEmpty || provider.isLoadingAddresses))
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            provider.checkoutError!,
                            style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // --- 1. 配送地址 ---
                      _buildSectionContainer(
                        context: context,
                        title: "配送地址",
                        isLoading: provider.isLoadingAddresses,
                        trailing: TextButton(
                          child: const Text("管理地址"),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("跳轉到地址管理頁面 (TODO)"))
                            );
                            // Navigator.push(context, MaterialPageRoute(builder: (_) => ManageAddressScreen()));
                          },
                        ),
                        child: provider.selectedAddress != null
                            ? _buildAddressInfo(context, provider.selectedAddress!, provider)
                            : provider.availableAddresses.isEmpty && !provider.isLoadingAddresses
                            ? const Padding( // 如果沒有地址且不在加載中
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text("請添加配送地址"),
                        )
                            : const Padding( // 如果有地址但未選擇，或仍在加載
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text("請選擇或添加配送地址"),
                        ),
                      ),

                      // --- 2. 配送方式 (使用 BottomConvexArcWidget) ---
                      _buildShippingSection(context, provider),


                      // --- 3. 購物車商品摘要 ---
                      _buildSectionContainer(
                          context: context,
                          title: "商品摘要",
                          child: _buildCartSummary(context, provider)
                      ),


                      // --- 4. 優惠券 ---
                      _buildSectionContainer(
                        context: context,
                        title: "優惠券",
                        isLoading: provider.isApplyingCoupon,
                        child: _buildCouponSection(context, provider),
                      ),

                      // --- 5. 支付方式 (暫時簡化) ---
                      _buildSectionContainer(
                        context: context,
                        title: "支付方式",
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.wallet_outlined),
                          title: const Text("貨到付款"),
                          trailing: Radio<bool>(
                            value: true,
                            groupValue: true, // 假設總是選中，實際應用中應由 provider 控制
                            onChanged: (bool? value) { /* 暫不處理支付方式選擇 */ },
                          ),
                        ),
                      ),
                      // 底部額外間距
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // --- 底部固定區域：訂單總結和下單按鈕 ---
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildBottomSummaryAndButton(context, provider),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  // --- 輔助構建方法 ---

  Widget _buildSectionContainer({
    required BuildContext context,
    required String title,
    required Widget child,
    bool isLoading = false,
    Widget? trailing,
    EdgeInsetsGeometry? padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    EdgeInsetsGeometry? contentPadding = const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
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
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              if (isLoading) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5))
              else if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildAddressInfo(BuildContext context, Address address, CheckoutProvider provider) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text("${address.recipientName ?? 'N/A'} (${address.phoneNumber ?? 'N/A'})", style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(address.displayAddress, maxLines: 2, overflow: TextOverflow.ellipsis),
    );
  }

  Widget _buildShippingSection(BuildContext context, CheckoutProvider provider) {
    const double shippingOptionsListHeight = 160.0;
    const double curveHeightForArc = 25.0;
    const double barHeightForArc = shippingOptionsListHeight + 16.0 + 16.0;

    return BottomConvexArcWidget(
      curveHeight: curveHeightForArc,
      barHeight: barHeightForArc,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("配送方式", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                // 【【修改處】】 使用 isLoadingShippingOptions
                if (provider.isLoadingShippingOptions && provider.selectedAddress != null)
                  const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5)),
              ],
            ),
            const SizedBox(height: 10),
            provider.selectedAddress == null
                ? const Text("請先選擇配送地址。")
            // 【【修改處】】 使用 isLoadingShippingOptions
                : provider.isLoadingShippingOptions
                ? const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text("正在加載配送方式...", style: TextStyle(fontSize: 13))))
                : provider.shippingOptions.isEmpty
                ? const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text("此地址無可用配送方式。", style: TextStyle(fontSize: 13))))
                : SizedBox(
              height: shippingOptionsListHeight,
              child: _buildShippingOptionListWidget(context, provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingOptionListWidget(BuildContext context, CheckoutProvider provider) {
    return ListView.builder(
      itemCount: provider.shippingOptions.length,
      itemBuilder: (context, index) {
        final option = provider.shippingOptions[index];
        return RadioListTile<ShippingOption>(
          title: Text(option.name, style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text("${option.description} (\$${option.cost.toStringAsFixed(0)})", style: const TextStyle(fontSize: 13)),
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
    // 【【修改處】】 從 provider 獲取購物車項目，而不是創建模擬數據
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
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text("${item.productName} x ${item.quantity}", style: const TextStyle(fontSize: 14))),
              // 【【修改處】】 使用 item.productPrice
              Text("\$${(item.productPrice * item.quantity).toStringAsFixed(2)}", style: const TextStyle(fontSize: 14)),
            ],
          ),
        )).toList(),
        const Divider(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("商品小計:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("\$${provider.itemsSubtotal.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildCouponSection(BuildContext context, CheckoutProvider provider) {
    // TextEditingController 最好與 State 綁定生命週期，但由於這裡是 StatelessWidget 的輔助方法，
    // 每次 build 都會重新創建。如果 CheckoutScreen 變為 StatefulWidget，
    // 應將 controller 移至 State 並在 dispose 中處理。
    // 為了保持與原代碼相似，暫時這樣處理。
    // 為了能響應 provider.lastAppliedCouponCode 的變化，我們在 TextField 中使用它
    final TextEditingController couponController = TextEditingController(text: provider.lastAppliedCouponCode ?? '');
    // 將光標移至文本末尾
    couponController.selection = TextSelection.fromPosition(TextPosition(offset: couponController.text.length));


    return Column(
      children: [
        TextField(
          controller: couponController,
          decoration: InputDecoration(
            hintText: '輸入優惠券代碼',
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon: provider.isApplyingCoupon
                ? const Padding(padding: EdgeInsets.all(10.0), child: SizedBox(width:18, height:18, child: CircularProgressIndicator(strokeWidth: 2)))
                : IconButton(
              icon: const Icon(Icons.local_offer_outlined, size: 20),
              onPressed: () {
                FocusScope.of(context).unfocus();
                // 【【修改處】】 使用 provider.checkoutItems，並檢查是否為空
                if (provider.checkoutItems.isNotEmpty) {
                  provider.applyCoupon(couponController.text, provider.checkoutItems);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("購物車是空的，無法套用優惠券。"))
                  );
                }
              },
            ),
          ),
          onSubmitted:(value) {
            FocusScope.of(context).unfocus();
            // 【【修改處】】 使用 provider.checkoutItems，並檢查是否為空
            if (provider.checkoutItems.isNotEmpty) {
              provider.applyCoupon(value, provider.checkoutItems);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("購物車是空的，無法套用優惠券。"))
              );
            }
          },
        ),
        if (provider.discountInfo != null && provider.discountInfo!.message != null && provider.discountInfo!.message!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
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

  Widget _buildBottomSummaryAndButton(BuildContext context, CheckoutProvider provider) {
    final bottomSafePadding = MediaQuery.of(context).padding.bottom;
    return Material(
      elevation: 8.0,
      child: Container(
        color: Theme.of(context).bottomAppBarTheme.color ?? Theme.of(context).colorScheme.surfaceBright,
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, bottomSafePadding + 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("商品小計:", style: TextStyle(fontSize: 14)),
                Text("\$${provider.itemsSubtotal.toStringAsFixed(2)}", style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("運費:", style: TextStyle(fontSize: 14)),
                Text("\$${provider.shippingCost.toStringAsFixed(2)}", style: const TextStyle(fontSize: 14)),
              ],
            ),
            if (provider.discountAmount > 0) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible( // 避免優惠券名稱過長導致溢出
                    child: Text(
                      "優惠券 (${provider.discountInfo?.appliedCouponCode ?? ''}):",
                      style: TextStyle(fontSize: 14, color: Colors.green.shade700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text("-\$${provider.discountAmount.toStringAsFixed(2)}", style: TextStyle(fontSize: 14, color: Colors.green.shade700)),
                ],
              ),
            ],
            const Divider(height: 20, thickness: 0.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("應付總額:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  "\$${provider.totalAmount.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: provider.isPlacingOrder ||
                  provider.checkoutItems.isEmpty || // 如果購物車是空的，也禁用
                  provider.selectedAddress == null ||
                  provider.selectedShippingOption == null
                  ? null
                  : () async {
                bool success = await provider.placeOrder();
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(backgroundColor: Colors.green, content: Text("訂單已創建！ID: ${provider.createdOrder?.orderId ?? 'N/A'}")),
                  );
                  // 通常結帳成功後會導航到訂單成功頁面或訂單列表頁面
                  // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: provider.createdOrder!)), (route) => route.isFirst);
                  Navigator.of(context).popUntil((route) => route.isFirst); // 簡單返回到第一個頁面
                } else if (!success && context.mounted && provider.checkoutError != null) {
                  // 錯誤信息已在頂部顯示，這裡可以只用一個簡短提示
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(backgroundColor: Theme.of(context).colorScheme.error, content: Text("下單失敗: ${provider.checkoutError}")),
                  );
                }
              },
              child: provider.isPlacingOrder
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5,))
                  : const Text("提交訂單"),
            ),
          ],
        ),
      ),
    );
  }
}
