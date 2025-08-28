import '../../models/user/user.dart';
import '../../services/abstractions.dart';

class MockAuthService implements IAuthService {
  static final User _fake = User(
    id: 9999,
    username: '開發模式使用者',
    email: 'dev@example.com',
    phoneNumber: null,
    avatarUrl: null,
    registeredAt: DateTime(2024, 1, 1),
    lastLoginAt: DateTime.now().subtract(const Duration(hours: 1)),
    bio: '這是 mock 的登入使用者，用來讓 App 在無後端時也能跑流程。',
    schoolName: '範例大學',
    isVerified: true,
    roles: const ['buyer', 'seller'],
    isSeller: true,
    sellerName: '開發者小舖',
    sellerDescription: '只賣 UI 測試用假資料 😎',
    sellerRating: 4.9,
    buyerRating: 4.8,
    productCount: 42,
    favoriteProductIds: const ['101000', '202000'], // 任意
    publicDisplayName: 'DevUser',
    publicBio: '公開介紹：我是測試帳號',
    publicCoverPhotoUrl: 'https://picsum.photos/seed/dev_cover/800/240',
    isSchoolPublic: true,
  );

  User? _current = _fake;

  @override
  Future<User?> getCurrentUser() async => _current;

  @override
  Future<User> signInSilently() async => _fake;

  @override
  Future<void> signOut() async => _current = null;
}
