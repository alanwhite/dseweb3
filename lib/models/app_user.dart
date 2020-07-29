enum LoginStatus { Authenticated, Authenticating, Unauthenticated }

class AppUser {
  LoginStatus loginStatus = LoginStatus.Unauthenticated;
  String accessToken = '';
  String refreshToken = '';
}
