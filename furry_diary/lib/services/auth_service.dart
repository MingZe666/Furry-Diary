import 'package:dio/dio.dart';

import '../models/app_models.dart';
import 'local_store.dart';

class AuthService {
  AuthService(this._dio, this._localStore);

  final Dio _dio;
  final LocalStore _localStore;

  Future<UserModel> enterGuestMode() async {
    final guest = UserModel(
      id: 'guest-${DateTime.now().millisecondsSinceEpoch}',
      isGuest: true,
      isPro: false,
    );
    await _localStore.saveUser(guest);
    return guest;
  }

  Future<void> requestSmsCode(String phone) async {
    await _dio.post('/api/v1/auth/sms/send', data: {'phone': phone});
  }

  Future<UserModel> loginByPhone(
      {required String phone, required String code}) async {
    final response = await _dio.post(
      '/api/v1/auth/login/phone',
      data: {'phone': phone, 'code': code},
    );

    final user =
        UserModel.fromJson(Map<String, dynamic>.from(response.data['user']));
    await _localStore.saveUser(user);
    return user;
  }
}
