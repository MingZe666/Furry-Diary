import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/app_models.dart';
import '../services/local_store.dart';
import '../services/auth_service.dart';
import '../services/sync_manager.dart';


// Create a global dio instance, could configure interceptors here later
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));
  return dio;
});

// Since LocalStore is async initialized in main(), we can use a Provider with an initial crash value, 
// then override it in ProviderScope. But for simplicity and to match existing patterns:
final localStoreProvider = Provider<LocalStore>((ref) {
  throw UnimplementedError('localStoreProvider not overridden');
});

final authServiceProvider = Provider<AuthService>((ref) {
  final dio = ref.watch(dioProvider);
  final localStore = ref.watch(localStoreProvider);
  return AuthService(dio, localStore);
});

class AuthNotifier extends StateNotifier<UserModel?> {
  AuthNotifier(this._authService, this._localStore) : super(_localStore.getCurrentUser());

  final AuthService _authService;
  final LocalStore _localStore;

  Future<void> login(String phone, String code) async {
    // In a real app we'd call the backend
    try {
      final user = await _authService.loginByPhone(phone: phone, code: code);
      state = user;
    } catch (e) {
      // Fallback local mock for now to test UI
      final mockUser = UserModel(
        id: 'user-mock-123',
        isGuest: false,
        isPro: false,
        phone: phone,
        nickname: '铲屎官' + phone.substring(phone.length - 4),
        token: 'mock_token_123',
      );
      await _localStore.saveUser(mockUser);
      state = mockUser;
    }
  }

  Future<void> logout() async {
    await _localStore.clearUser();
    // revert to guest mode
    final guest = await _authService.enterGuestMode();
    state = guest;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  final authService = ref.watch(authServiceProvider);
  final localStore = ref.watch(localStoreProvider);
  return AuthNotifier(authService, localStore);
});


final syncManagerProvider = Provider<SyncManager>((ref) {
  final dio = ref.watch(dioProvider);
  final localStore = ref.watch(localStoreProvider);
  return SyncManager(dio, localStore);
});
