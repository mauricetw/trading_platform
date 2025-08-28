import 'dart:math';
import '../../models/user/user.dart';
import 'mock_utils.dart';

/// 給 PublicUserProfilePage 的「簡化公開檔案」資料結構
class PublicProfileBasics {
  final String username;
  final String avatarUrl;
  final int completedTransactions;
  final String bio;
  final String school;

  const PublicProfileBasics({
    required this.username,
    required this.avatarUrl,
    required this.completedTransactions,
    required this.bio,
    required this.school,
  });
}

/// 產生公開檔案基礎資料（純假資料，不依賴 User model）
PublicProfileBasics buildMockPublicProfileBasics(String userId) {
  final h = userId.hashCode;
  final completed = (h % 100).abs();
  final name = '用戶 ${userId.substring(0, max(1, min(3, userId.length)))}';
  final school = (h.isEven) ? '國立台灣科技大學管理學院' : '範例大學軟體工程系';
  final avatar = 'https://picsum.photos/seed/profile_$h/200/200';
  final bio =
      '這是用戶 $name 的公開介紹。熱愛探索新技術與開源！已完成 $completed 筆交易。';

  return PublicProfileBasics(
    username: name,
    avatarUrl: avatar,
    completedTransactions: completed,
    bio: bio,
    school: school,
  );
}

User mockSellerUser(int userId) => User(
  id: userId,
  username: 'seller_$userId',
  email: 'seller_$userId@example.com',
  phoneNumber: null,
  avatarUrl: 'https://picsum.photos/seed/seller_$userId/120/120',
  registeredAt: DateTime.now().subtract(const Duration(days: 200)),
  lastLoginAt: DateTime.now().subtract(const Duration(hours: 5)),
  bio: 'UI 測試用賣家（mock）',
  schoolName: userId.isEven ? '國立範例大學' : '範例科技大學',
  isVerified: true,
  roles: const ['seller'],
  isSeller: true,
  sellerName: '賣家$userId的小店',
  sellerDescription: '高 CP 值好物專賣（mock）',
  sellerRating: 4.6,
  buyerRating: 4.5,
  productCount: 8,
  favoriteProductIds: const [],
  publicDisplayName: '賣家$userId',
  publicBio: '公開介紹：我們專注於品質與服務（mock）',
  publicCoverPhotoUrl: 'https://picsum.photos/seed/seller_cover_$userId/800/240',
  isSchoolPublic: true,
);

User mockPublicProfile(int userId) => User(
  id: userId,
  username: 'user_$userId',
  email: 'user_$userId@example.com',
  phoneNumber: null,
  avatarUrl: userId.isOdd ? null : 'https://picsum.photos/seed/user_$userId/120/120',
  registeredAt: DateTime.now().subtract(const Duration(days: 300)),
  lastLoginAt: DateTime.now().subtract(const Duration(hours: 2)),
  bio: '這是公開簡介（mock）for user_$userId',
  schoolName: userId.isEven ? '國立範例大學' : '範例科大',
  isVerified: true,
  roles: const ['buyer'],
  isSeller: userId % 3 == 0,
  sellerName: userId % 3 == 0 ? 'user_$userId 的小店' : null,
  sellerDescription: userId % 3 == 0 ? '偶爾上架好物（mock）' : null,
  sellerRating: userId % 3 == 0 ? 4.3 : null,
  buyerRating: 4.4,
  productCount: userId % 3 == 0 ? 5 : 0,
  favoriteProductIds: const [],
  publicDisplayName: '用戶$userId',
  publicBio: '公開介紹：喜歡挖寶（mock）',
  publicCoverPhotoUrl: 'https://picsum.photos/seed/public_cover_$userId/800/240',
  isSchoolPublic: userId.isEven,
);
