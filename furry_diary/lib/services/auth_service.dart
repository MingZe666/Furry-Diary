import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/app_models.dart';
import 'local_store.dart';
import '../config/build_config.dart';

class AuthService {
  AuthService(this._dio, this._localStore, this._secureStorage);

  final Dio _dio;
  final LocalStore _localStore;
  final FlutterSecureStorage _secureStorage;

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  Future<String?> getStoredToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> _saveToken(String token, {String? refreshToken}) async {
    await _secureStorage.write(key: _tokenKey, value: token);
    if (refreshToken != null) {
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  Future<void> _clearToken() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  Future<void> requestSmsCode(String phone) async {
    await _dio.post('/api/v1/auth/sms/send', data: {'phone': phone});
  }

  Future<LoginResult> loginByPhone({
    required String phone,
    required String code,
    String? deviceId,
    String? deviceName,
  }) async {
    final response = await _dio.post(
      '/api/v1/auth/login/phone',
      data: {
        'phone': phone,
        'code': code,
        'device_id': deviceId,
        'device_name': deviceName,
      },
    );

    final data = response.data;
    final token = data['token'] as String;
    final isNewUser = data['is_new_user'] as bool? ?? false;
    final needSetupProfile = data['need_setup_profile'] as bool? ?? false;

    await _saveToken(token);

    final userJson = UserModel.fromJson(Map<String, dynamic>.from(data['user']));
    final user = userJson.copyWith(token: token);
    await _localStore.saveUser(user);

    return LoginResult(
      user: user,
      isNewUser: isNewUser,
      needSetupProfile: needSetupProfile,
    );
  }

  Future<LoginResult> loginByWechat({
    required String code,
    String? deviceId,
    String? deviceName,
  }) async {
    final response = await _dio.post(
      '/api/v1/auth/login/wechat',
      data: {
        'code': code,
        'device_id': deviceId,
        'device_name': deviceName,
      },
    );

    final data = response.data;
    final token = data['token'] as String;
    final needBindPhone = data['need_bind_phone'] as bool? ?? false;

    await _saveToken(token);

    final userJson = UserModel.fromJson(Map<String, dynamic>.from(data['user']));
    final user = userJson.copyWith(token: token);
    await _localStore.saveUser(user);

    return LoginResult(
      user: user,
      isNewUser: false,
      needSetupProfile: needBindPhone,
    );
  }

  Future<LoginResult> loginByQQ({
    required String accessToken,
    required String openId,
    String? deviceId,
    String? deviceName,
  }) async {
    final response = await _dio.post(
      '/api/v1/auth/login/qq',
      data: {
        'access_token': accessToken,
        'open_id': openId,
        'device_id': deviceId,
        'device_name': deviceName,
      },
    );

    final data = response.data;
    final token = data['token'] as String;
    final needBindPhone = data['need_bind_phone'] as bool? ?? false;

    await _saveToken(token);

    final userJson = UserModel.fromJson(Map<String, dynamic>.from(data['user']));
    final user = userJson.copyWith(token: token);
    await _localStore.saveUser(user);

    return LoginResult(
      user: user,
      isNewUser: false,
      needSetupProfile: needBindPhone,
    );
  }

  Future<void> bindPhone({
    required String phone,
    required String code,
  }) async {
    await _dio.post(
      '/api/v1/auth/bind/phone',
      data: {
        'phone': phone,
        'code': code,
      },
    );

    final user = _localStore.getCurrentUser();
    if (user != null) {
      await _localStore.saveUser(user.copyWith(phone: phone));
    }
  }

  Future<void> bindWechat({required String code}) async {
    await _dio.post(
      '/api/v1/auth/bind/wechat',
      data: {'code': code},
    );
  }

  Future<void> bindQQ({
    required String accessToken,
    required String openId,
  }) async {
    await _dio.post(
      '/api/v1/auth/bind/qq',
      data: {
        'access_token': accessToken,
        'open_id': openId,
      },
    );
  }

  Future<UserModel> updateProfile({
    String? nickname,
    String? avatarUrl,
    String? email,
  }) async {
    final response = await _dio.put(
      '/api/v1/user/profile',
      data: {
        if (nickname != null) 'nickname': nickname,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (email != null) 'email': email,
      },
    );

    final user = UserModel.fromJson(Map<String, dynamic>.from(response.data['user']));
    await _localStore.saveUser(user);
    return user;
  }

  Future<UserModel?> fetchProfile() async {
    try {
      final response = await _dio.get('/api/v1/user/profile');
      final userJson = UserModel.fromJson(Map<String, dynamic>.from(response.data));
      final currentUser = _localStore.getCurrentUser();
      final user = userJson.copyWith(token: currentUser?.token);
      await _localStore.saveUser(user);
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout({String? deviceId}) async {
    try {
      await _dio.post(
        '/api/v1/user/logout',
        data: {'device_id': deviceId},
      );
    } catch (e) {
      // 忽略登出API错误，继续清理本地数据
    }

    await _clearToken();
    await _localStore.clearUser();
  }

  Future<void> deleteAccount() async {
    try {
      await _dio.delete('/api/v1/user/account');
    } catch (e) {
      // 忽略错误
    }

    await _clearToken();
    await _localStore.clearUser();
  }

  Future<bool> refreshToken() async {
    final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
    if (refreshToken == null) return false;

    try {
      final response = await _dio.post(
        '/api/v1/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final token = response.data['token'] as String;
      final newRefreshToken = response.data['refresh_token'] as String?;
      await _saveToken(token, refreshToken: newRefreshToken);
      return true;
    } catch (e) {
      return false;
    }
  }
}

class LoginResult {
  LoginResult({
    required this.user,
    this.isNewUser = false,
    this.needSetupProfile = false,
  });

  final UserModel user;
  final bool isNewUser;
  final bool needSetupProfile;
}
