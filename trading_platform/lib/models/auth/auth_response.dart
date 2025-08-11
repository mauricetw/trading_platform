// 引入你的 User 模型，請確保路徑正確
import '../user/user.dart';

// 這個模型對應後端回傳的 token 物件
class Token {
  final String accessToken;
  final String tokenType;

  Token({required this.accessToken, required this.tokenType});

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
    );
  }
}

// 這個模型對應整個登入/註冊成功後的回應
class AuthResponse {
  final Token token;
  final User user;

  AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: Token.fromJson(json['token']),
      user: User.fromJson(json['user']),
    );
  }
}