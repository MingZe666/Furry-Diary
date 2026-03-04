with open('lib/models/app_models.dart', 'r', encoding='utf-8') as f:
    text = f.read()

import re

old_model = '''class UserModel {
  UserModel({
    required this.id,
    required this.isGuest,
    required this.isPro,
    this.phone,
    this.token,
  });

  final String id;
  final bool isGuest;
  final bool isPro;
  final String? phone;
  final String? token;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        isGuest: json['isGuest'] as bool? ?? false,
        isPro: json['isPro'] as bool? ?? false,
        phone: json['phone'] as String?,
        token: json['token'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'isGuest': isGuest,
        'isPro': isPro,
        'phone': phone,
        'token': token,
      };
}'''

new_model = '''class UserModel {
  UserModel({
    required this.id,
    required this.isGuest,
    required this.isPro,
    this.phone,
    this.token,
    this.nickname,
    this.avatarPath,
  });

  final String id;
  final bool isGuest;
  final bool isPro;
  final String? phone;
  final String? token;
  final String? nickname;
  final String? avatarPath;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        isGuest: json['isGuest'] as bool? ?? false,
        isPro: json['isPro'] as bool? ?? false,
        phone: json['phone'] as String?,
        token: json['token'] as String?,
        nickname: json['nickname'] as String?,
        avatarPath: json['avatarPath'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'isGuest': isGuest,
        'isPro': isPro,
        'phone': phone,
        'token': token,
        'nickname': nickname,
        'avatarPath': avatarPath,
      };
}'''

text = text.replace(old_model, new_model)

with open('lib/models/app_models.dart', 'w', encoding='utf-8') as f:
    f.write(text)
