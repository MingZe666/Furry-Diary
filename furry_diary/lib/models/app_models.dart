import 'dart:convert';

enum RecordType { vaccine, deworm, checkup, medication, bath, weight, other }

class PetProfile {
  PetProfile({
    required this.id,
    required this.name,
    this.avatarPath,
    this.type,
    this.breed,
    this.gender,
    this.isNeutered,
    this.weight,
    this.color,
    this.chipNo,
    this.birthday,
    this.adoptionDate,
  });

  final String id;
  final String name;
  final String? avatarPath;
  final String? type;
  final String? breed;
  final String? gender;
  final bool? isNeutered;
  final double? weight;
  final String? color;
  final String? chipNo;
  final DateTime? birthday;
  final DateTime? adoptionDate;

  factory PetProfile.fromJson(Map<String, dynamic> json) => PetProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        avatarPath: json['avatarPath'] as String?,
        type: json['type'] as String?,
        breed: json['breed'] as String?,
        gender: json['gender'] as String?,
        isNeutered: json['isNeutered'] as bool?,
        weight:
            json['weight'] != null ? (json['weight'] as num).toDouble() : null,
        color: json['color'] as String?,
        chipNo: json['chipNo'] as String?,
        birthday: json['birthday'] == null
            ? null
            : DateTime.parse(json['birthday'] as String),
        adoptionDate: json['adoptionDate'] == null
            ? null
            : DateTime.parse(json['adoptionDate'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarPath': avatarPath,
        'type': type,
        'breed': breed,
        'gender': gender,
        'isNeutered': isNeutered,
        'weight': weight,
        'color': color,
        'chipNo': chipNo,
        'birthday': birthday?.toIso8601String(),
        'adoptionDate': adoptionDate?.toIso8601String(),
      };
}

class UserModel {
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
}

class HealthRecord {
  HealthRecord({
    required this.id,
    required this.petId,
    required this.type,
    required this.date,
    this.nextDueDate,
    this.note,
    this.title,
    this.isSynced = false,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String petId;
  final RecordType type;
  final DateTime date;
  final DateTime? nextDueDate;
  final String? note;
  final String? title;
  bool isSynced;
  DateTime updatedAt;

  factory HealthRecord.fromJson(Map<String, dynamic> json) => HealthRecord(
        id: json['id'] as String,
        petId: json['petId'] as String,
        type: RecordType.values.firstWhere((item) => item.name == json['type']),
        date: DateTime.parse(json['date'] as String),
        nextDueDate: json['nextDueDate'] == null
            ? null
            : DateTime.parse(json['nextDueDate'] as String),
        note: json['note'] as String?,
        title: json['title'] as String?,
        isSynced: json['isSynced'] as bool? ?? false,
        updatedAt: json['updatedAt'] == null
            ? null
            : DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'petId': petId,
        'type': type.name,
        'date': date.toIso8601String(),
        'nextDueDate': nextDueDate?.toIso8601String(),
        'note': note,
        'title': title,
        'isSynced': isSynced,
        'updatedAt': updatedAt.toIso8601String(),
      };
}

class SyncPayload {
  SyncPayload({required this.lastSyncedAt, required this.dirty});

  final DateTime? lastSyncedAt;
  final List<HealthRecord> dirty;

  factory SyncPayload.fromJson(Map<String, dynamic> json) => SyncPayload(
        lastSyncedAt: json['lastSyncedAt'] == null
            ? null
            : DateTime.parse(json['lastSyncedAt'] as String),
        dirty: (json['dirty'] as List<dynamic>)
            .map((item) =>
                HealthRecord.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'lastSyncedAt': lastSyncedAt?.toIso8601String(),
        'dirty': dirty.map((item) => item.toJson()).toList(),
      };

  String toRawJson() => jsonEncode(toJson());
}
