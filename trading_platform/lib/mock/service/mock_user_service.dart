import '../../models/user/user.dart';
import '../data/mock_users.dart';
import '../../services/abstractions.dart';

class MockUserService implements IUserService {
  @override
  Future<User> getPublicProfile(int userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return mockPublicProfile(userId);
  }
}
