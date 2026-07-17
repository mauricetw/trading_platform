class DiscountInfo {
  final double discountAmount;
  final String? message;
  final String? appliedCouponCode;
  final bool isFreeShipping;

  DiscountInfo({
    required this.discountAmount,
    this.message,
    this.appliedCouponCode,
    this.isFreeShipping = false,
  });

  // (copyWith, ==, hashCode, toString 方法是可選的)
  DiscountInfo copyWith({
    double? discountAmount,
    String? message,
    String? appliedCouponCode,
    bool? isFreeShipping,
  }) {
    return DiscountInfo(
      discountAmount: discountAmount ?? this.discountAmount,
      message: message ?? this.message,
      appliedCouponCode: appliedCouponCode ?? this.appliedCouponCode,
      isFreeShipping: isFreeShipping ?? this.isFreeShipping,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is DiscountInfo &&
              runtimeType == other.runtimeType &&
              discountAmount == other.discountAmount &&
              message == other.message &&
              appliedCouponCode == other.appliedCouponCode &&
              isFreeShipping == other.isFreeShipping;

  @override
  int get hashCode =>
      discountAmount.hashCode ^
      message.hashCode ^
      appliedCouponCode.hashCode ^
      isFreeShipping.hashCode;

  @override
  String toString() {
    return 'DiscountInfo{discountAmount: $discountAmount, message: $message, appliedCouponCode: $appliedCouponCode, isFreeShipping: $isFreeShipping}';
  }
}

