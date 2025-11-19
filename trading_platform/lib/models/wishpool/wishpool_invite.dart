import 'package:json_annotation/json_annotation.dart';
import '../product/product.dart';
import '../user/user.dart';
import 'wishpool.dart';

part 'wishpool_invite.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class WishPoolInvite {
  final int id;
  final int wishPoolId;
  final int sellerId;
  final int? productId; // 允許為空
  final String? message;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  final User? seller;
  final Product? product;
  final WishPool? wishpool;

  WishPoolInvite({
    required this.id,
    required this.wishPoolId,
    required this.sellerId,
    this.productId,
    this.message,
    this.status = 'pending',
    required this.createdAt,
    this.updatedAt,
    this.seller,
    this.product,
    this.wishpool,
  });

  factory WishPoolInvite.fromJson(Map<String, dynamic> json) =>
      _$WishPoolInviteFromJson(json);

  Map<String, dynamic> toJson() => _$WishPoolInviteToJson(this);

  WishPoolInvite copyWith({
    int? id,
    int? wishPoolId,
    int? sellerId,
    int? productId,
    String? message,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? seller,
    Product? product,
    WishPool? wishpool,
  }) {
    return WishPoolInvite(
      id: id ?? this.id,
      wishPoolId: wishPoolId ?? this.wishPoolId,
      sellerId: sellerId ?? this.sellerId,
      productId: productId ?? this.productId,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      seller: seller ?? this.seller,
      product: product ?? this.product,
      wishpool: wishpool ?? this.wishpool,
    );
  }
}