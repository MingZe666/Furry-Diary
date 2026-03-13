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
    this.updatedAt,
    this.deletedAt,
    this.isSynced = false,
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
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final bool isSynced;

  factory PetProfile.fromJson(Map<String, dynamic> json) => PetProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        avatarPath: json['avatarPath'] as String? ?? json['avatar_path'] as String?,
        type: json['type'] as String?,
        breed: json['breed'] as String?,
        gender: json['gender'] as String?,
        isNeutered: json['isNeutered'] as bool? ?? json['is_neutered'] as bool?,
        weight:
            json['weight'] != null ? (json['weight'] as num).toDouble() : null,
        color: json['color'] as String?,
        chipNo: json['chipNo'] as String? ?? json['chip_no'] as String?,
        birthday: json['birthday'] == null
            ? null
            : DateTime.parse(json['birthday'] as String),
        adoptionDate: json['adoptionDate'] == null
            ? null
            : DateTime.parse(json['adoptionDate'] as String),
        updatedAt: json['updatedAt'] == null
            ? null
            : DateTime.parse(json['updatedAt'] as String),
        deletedAt: json['deletedAt'] == null
            ? null
            : DateTime.parse(json['deletedAt'] as String),
        isSynced: json['isSynced'] as bool? ?? json['is_synced'] as bool? ?? false,
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
        'updatedAt': updatedAt?.toIso8601String(),
        'deletedAt': deletedAt?.toIso8601String(),
        'isSynced': isSynced,
      };

  PetProfile copyWith({
    String? id,
    String? name,
    String? avatarPath,
    String? type,
    String? breed,
    String? gender,
    bool? isNeutered,
    double? weight,
    String? color,
    String? chipNo,
    DateTime? birthday,
    DateTime? adoptionDate,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? isSynced,
  }) {
    return PetProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarPath: avatarPath ?? this.avatarPath,
      type: type ?? this.type,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      isNeutered: isNeutered ?? this.isNeutered,
      weight: weight ?? this.weight,
      color: color ?? this.color,
      chipNo: chipNo ?? this.chipNo,
      birthday: birthday ?? this.birthday,
      adoptionDate: adoptionDate ?? this.adoptionDate,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
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
    this.email,
    this.wechatBound = false,
    this.qqBound = false,
    this.proExpiredAt,
    this.createdAt,
    this.lastSyncedAt,
  });

  final String id;
  final bool isGuest;
  final bool isPro;
  final String? phone;
  final String? token;
  final String? nickname;
  final String? avatarPath;
  final String? email;
  final bool wechatBound;
  final bool qqBound;
  final DateTime? proExpiredAt;
  final DateTime? createdAt;
  final DateTime? lastSyncedAt;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'].toString(),
        isGuest: json['isGuest'] as bool? ?? json['is_guest'] as bool? ?? false,
        isPro: json['isPro'] as bool? ?? json['is_pro'] as bool? ?? false,
        phone: json['phone'] as String?,
        token: json['token'] as String?,
        nickname: json['nickname'] as String?,
        avatarPath: json['avatarPath'] as String? ?? json['avatar_url'] as String?,
        email: json['email'] as String?,
        wechatBound: json['wechatBound'] as bool? ?? json['wechat_bound'] as bool? ?? false,
        qqBound: json['qqBound'] as bool? ?? json['qq_bound'] as bool? ?? false,
        proExpiredAt: json['proExpiredAt'] == null
            ? null
            : DateTime.parse(json['proExpiredAt'] as String),
        createdAt: json['createdAt'] == null
            ? null
            : DateTime.parse(json['createdAt'] as String),
        lastSyncedAt: json['lastSyncedAt'] == null
            ? null
            : DateTime.parse(json['lastSyncedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'isGuest': isGuest,
        'isPro': isPro,
        'phone': phone,
        'token': token,
        'nickname': nickname,
        'avatarPath': avatarPath,
        'email': email,
        'wechatBound': wechatBound,
        'qqBound': qqBound,
        'proExpiredAt': proExpiredAt?.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
        'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      };

  UserModel copyWith({
    String? id,
    bool? isGuest,
    bool? isPro,
    String? phone,
    String? token,
    String? nickname,
    String? avatarPath,
    String? email,
    bool? wechatBound,
    bool? qqBound,
    DateTime? proExpiredAt,
    DateTime? createdAt,
    DateTime? lastSyncedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      isGuest: isGuest ?? this.isGuest,
      isPro: isPro ?? this.isPro,
      phone: phone ?? this.phone,
      token: token ?? this.token,
      nickname: nickname ?? this.nickname,
      avatarPath: avatarPath ?? this.avatarPath,
      email: email ?? this.email,
      wechatBound: wechatBound ?? this.wechatBound,
      qqBound: qqBound ?? this.qqBound,
      proExpiredAt: proExpiredAt ?? this.proExpiredAt,
      createdAt: createdAt ?? this.createdAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
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
    DateTime? deletedAt,
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
  final DateTime? deletedAt;

  factory HealthRecord.fromJson(Map<String, dynamic> json) => HealthRecord(
        id: json['id'] as String,
        petId: json['petId'] as String? ?? json['pet_id']?.toString() ?? '',
        type: RecordType.values.firstWhere((item) => item.name == json['type']),
        date: DateTime.parse(json['date'] as String),
        nextDueDate: json['nextDueDate'] == null
            ? null
            : DateTime.parse(json['nextDueDate'] as String),
        note: json['note'] as String?,
        title: json['title'] as String?,
        isSynced: json['isSynced'] as bool? ?? json['is_synced'] as bool? ?? false,
        updatedAt: json['updatedAt'] == null
            ? null
            : DateTime.parse(json['updatedAt'] as String),
        deletedAt: json['deletedAt'] == null
            ? null
            : DateTime.parse(json['deletedAt'] as String),
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
        'deletedAt': deletedAt?.toIso8601String(),
      };

  HealthRecord copyWith({
    String? id,
    String? petId,
    RecordType? type,
    DateTime? date,
    DateTime? nextDueDate,
    String? note,
    String? title,
    bool? isSynced,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return HealthRecord(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      type: type ?? this.type,
      date: date ?? this.date,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      note: note ?? this.note,
      title: title ?? this.title,
      isSynced: isSynced ?? this.isSynced,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
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

class Device {
  Device({
    required this.id,
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    this.lastLoginAt,
    this.lastActiveAt,
    this.isCurrent = false,
  });

  final int id;
  final String deviceId;
  final String deviceName;
  final String deviceType;
  final DateTime? lastLoginAt;
  final DateTime? lastActiveAt;
  final bool isCurrent;

  factory Device.fromJson(Map<String, dynamic> json) => Device(
        id: json['id'] as int,
        deviceId: json['device_id'] as String,
        deviceName: json['device_name'] as String? ?? '未知设备',
        deviceType: json['device_type'] as String? ?? 'unknown',
        lastLoginAt: json['last_login_at'] == null
            ? null
            : DateTime.parse(json['last_login_at'] as String),
        lastActiveAt: json['last_active_at'] == null
            ? null
            : DateTime.parse(json['last_active_at'] as String),
        isCurrent: json['is_current'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'device_id': deviceId,
        'device_name': deviceName,
        'device_type': deviceType,
        'last_login_at': lastLoginAt?.toIso8601String(),
        'last_active_at': lastActiveAt?.toIso8601String(),
        'is_current': isCurrent,
      };
}

enum EstrusPhase {
  proestrus,
  estrus,
  diestrus,
  anestrus,
}

enum DischargeAmount {
  light,
  moderate,
  heavy,
}

enum SwellingLevel {
  none,
  mild,
  moderate,
  severe,
}

enum PredictionBasis {
  defaultValue,
  historicalData,
}

enum PredictionConfidence {
  low,
  medium,
  high,
}

class EstrusRecord {
  EstrusRecord({
    required this.id,
    required this.petId,
    required this.startDate,
    this.endDate,
    this.durationDays,
    this.phase,
    this.dischargeColor,
    this.dischargeAmount,
    this.vulvaSwelling,
    this.behaviorChanges = const [],
    this.symptoms = const [],
    this.note,
    this.isAbnormal = false,
    this.abnormalReasons = const [],
    this.isSynced = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String petId;
  final DateTime startDate;
  final DateTime? endDate;
  final int? durationDays;
  final EstrusPhase? phase;
  final String? dischargeColor;
  final DischargeAmount? dischargeAmount;
  final SwellingLevel? vulvaSwelling;
  final List<String> behaviorChanges;
  final List<String> symptoms;
  final String? note;
  final bool isAbnormal;
  final List<String> abnormalReasons;
  bool isSynced;
  final DateTime createdAt;
  DateTime updatedAt;

  factory EstrusRecord.fromJson(Map<String, dynamic> json) {
    List<String> parseStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return [];
    }

    EstrusPhase? parsePhase(String? value) {
      if (value == null) return null;
      return EstrusPhase.values.firstWhere(
        (e) => e.name == value,
        orElse: () => EstrusPhase.proestrus,
      );
    }

    DischargeAmount? parseDischargeAmount(String? value) {
      if (value == null) return null;
      return DischargeAmount.values.firstWhere(
        (e) => e.name == value,
        orElse: () => DischargeAmount.moderate,
      );
    }

    SwellingLevel? parseSwellingLevel(String? value) {
      if (value == null) return null;
      return SwellingLevel.values.firstWhere(
        (e) => e.name == value,
        orElse: () => SwellingLevel.none,
      );
    }

    return EstrusRecord(
      id: json['id'] as String,
      petId: json['petId'] as String? ?? json['pet_id']?.toString() ?? '',
      startDate: DateTime.parse(json['startDate'] as String? ?? json['start_date'] as String),
      endDate: json['endDate'] == null && json['end_date'] == null
          ? null
          : DateTime.parse(json['endDate'] as String? ?? json['end_date'] as String),
      durationDays: json['durationDays'] as int? ?? json['duration_days'] as int?,
      phase: parsePhase(json['phase'] as String?),
      dischargeColor: json['dischargeColor'] as String? ?? json['discharge_color'] as String?,
      dischargeAmount: parseDischargeAmount(
          json['dischargeAmount'] as String? ?? json['discharge_amount'] as String?),
      vulvaSwelling: parseSwellingLevel(
          json['vulvaSwelling'] as String? ?? json['vulva_swelling'] as String?),
      behaviorChanges: parseStringList(json['behaviorChanges'] ?? json['behavior_changes']),
      symptoms: parseStringList(json['symptoms']),
      note: json['note'] as String?,
      isAbnormal: json['isAbnormal'] as bool? ?? json['is_abnormal'] as bool? ?? false,
      abnormalReasons: parseStringList(json['abnormalReasons'] ?? json['abnormal_reasons']),
      isSynced: json['isSynced'] as bool? ?? json['is_synced'] as bool? ?? false,
      createdAt: json['createdAt'] == null && json['created_at'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String? ?? json['created_at'] as String),
      updatedAt: json['updatedAt'] == null && json['updated_at'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String? ?? json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'petId': petId,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'durationDays': durationDays,
        'phase': phase?.name,
        'dischargeColor': dischargeColor,
        'dischargeAmount': dischargeAmount?.name,
        'vulvaSwelling': vulvaSwelling?.name,
        'behaviorChanges': behaviorChanges,
        'symptoms': symptoms,
        'note': note,
        'isAbnormal': isAbnormal,
        'abnormalReasons': abnormalReasons,
        'isSynced': isSynced,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  EstrusRecord copyWith({
    String? id,
    String? petId,
    DateTime? startDate,
    DateTime? endDate,
    int? durationDays,
    EstrusPhase? phase,
    String? dischargeColor,
    DischargeAmount? dischargeAmount,
    SwellingLevel? vulvaSwelling,
    List<String>? behaviorChanges,
    List<String>? symptoms,
    String? note,
    bool? isAbnormal,
    List<String>? abnormalReasons,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EstrusRecord(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      durationDays: durationDays ?? this.durationDays,
      phase: phase ?? this.phase,
      dischargeColor: dischargeColor ?? this.dischargeColor,
      dischargeAmount: dischargeAmount ?? this.dischargeAmount,
      vulvaSwelling: vulvaSwelling ?? this.vulvaSwelling,
      behaviorChanges: behaviorChanges ?? this.behaviorChanges,
      symptoms: symptoms ?? this.symptoms,
      note: note ?? this.note,
      isAbnormal: isAbnormal ?? this.isAbnormal,
      abnormalReasons: abnormalReasons ?? this.abnormalReasons,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  int? calculateDurationDays() {
    if (endDate == null) return null;
    return endDate!.difference(startDate).inDays + 1;
  }
}

class EstrusPrediction {
  EstrusPrediction({
    required this.predictedDate,
    required this.averageCycle,
    required this.confidence,
    required this.predictionBasis,
    required this.message,
    this.averageDuration,
  });

  final DateTime predictedDate;
  final int averageCycle;
  final PredictionConfidence confidence;
  final PredictionBasis predictionBasis;
  final String message;
  final int? averageDuration;

  factory EstrusPrediction.fromJson(Map<String, dynamic> json) => EstrusPrediction(
        predictedDate: DateTime.parse(json['predictedDate'] as String? ?? json['predicted_date'] as String),
        averageCycle: json['averageCycle'] as int? ?? json['average_cycle'] as int? ?? 180,
        confidence: PredictionConfidence.values.firstWhere(
          (e) => e.name == (json['confidence'] as String? ?? 'low'),
          orElse: () => PredictionConfidence.low,
        ),
        predictionBasis: PredictionBasis.values.firstWhere(
          (e) => e.name == (json['predictionBasis'] as String? ?? json['prediction_basis'] as String? ?? 'defaultValue'),
          orElse: () => PredictionBasis.defaultValue,
        ),
        message: json['message'] as String? ?? '',
        averageDuration: json['averageDuration'] as int? ?? json['average_duration'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'predictedDate': predictedDate.toIso8601String(),
        'averageCycle': averageCycle,
        'confidence': confidence.name,
        'predictionBasis': predictionBasis.name,
        'message': message,
        'averageDuration': averageDuration,
      };

  int get daysUntilNext => predictedDate.difference(DateTime.now()).inDays;

  DateTime get predictedEndDate => predictedDate.add(Duration(days: averageDuration ?? 18));
}
