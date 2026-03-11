import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/app_models.dart';
import '../services/local_store.dart';
import '../services/auth_service.dart';
import '../services/sync_manager.dart';
import '../config/build_config.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: BuildConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final storage = FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
    onError: (error, handler) async {
      if (error.response?.statusCode == 401) {
        final storage = FlutterSecureStorage();
        await storage.delete(key: 'auth_token');
      }
      return handler.next(error);
    },
  ));

  return dio;
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final localStoreProvider = Provider<LocalStore>((ref) {
  throw UnimplementedError('localStoreProvider not overridden');
});

final authServiceProvider = Provider<AuthService>((ref) {
  final dio = ref.watch(dioProvider);
  final localStore = ref.watch(localStoreProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthService(dio, localStore, secureStorage);
});

class AuthNotifier extends StateNotifier<UserModel?> {
  AuthNotifier(this._authService, this._localStore, this._syncManager)
      : super(_localStore.getCurrentUser());

  final AuthService _authService;
  final LocalStore _localStore;
  final SyncManager _syncManager;

  Future<LoginResult?> loginByPhone(String phone, String code,
      {String? deviceId, String? deviceName}) async {
    try {
      final result = await _authService.loginByPhone(
        phone: phone,
        code: code,
        deviceId: deviceId,
        deviceName: deviceName,
      );
      state = result.user;
      await _syncManager.mergeGuestDataAfterLogin();
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<LoginResult?> loginByWechat(String code,
      {String? deviceId, String? deviceName}) async {
    try {
      final result = await _authService.loginByWechat(
        code: code,
        deviceId: deviceId,
        deviceName: deviceName,
      );
      state = result.user;
      await _syncManager.mergeGuestDataAfterLogin();
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<LoginResult?> loginByQQ(String accessToken, String openId,
      {String? deviceId, String? deviceName}) async {
    try {
      final result = await _authService.loginByQQ(
        accessToken: accessToken,
        openId: openId,
        deviceId: deviceId,
        deviceName: deviceName,
      );
      state = result.user;
      await _syncManager.mergeGuestDataAfterLogin();
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> bindPhone(String phone, String code) async {
    await _authService.bindPhone(phone: phone, code: code);
    final user = _localStore.getCurrentUser();
    if (user != null) {
      state = user.copyWith(phone: phone);
    }
  }

  Future<void> updateProfile({String? nickname, String? avatarUrl, String? email}) async {
    final user = await _authService.updateProfile(
      nickname: nickname,
      avatarUrl: avatarUrl,
      email: email,
    );
    state = user;
  }

  Future<void> logout({String? deviceId}) async {
    await _authService.logout(deviceId: deviceId);
    state = null;
  }

  Future<void> deleteAccount() async {
    await _authService.deleteAccount();
    state = null;
  }

  Future<void> refreshProfile() async {
    final user = await _authService.fetchProfile();
    if (user != null) {
      state = user;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  final authService = ref.watch(authServiceProvider);
  final localStore = ref.watch(localStoreProvider);
  final syncManager = ref.watch(syncManagerProvider);
  return AuthNotifier(authService, localStore, syncManager);
});

final syncManagerProvider = Provider<SyncManager>((ref) {
  final dio = ref.watch(dioProvider);
  final localStore = ref.watch(localStoreProvider);
  return SyncManager(dio, localStore);
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(authProvider);
  return user != null && !user.isGuest;
});
