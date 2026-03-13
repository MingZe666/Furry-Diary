import '../models/app_models.dart';
import 'local_store.dart';

class EstrusService {
  EstrusService(this._localStore);

  final LocalStore _localStore;

  static const Map<String, int> defaultCycles = {
    'dog_small': 180,
    'dog_medium': 210,
    'dog_large': 300,
    'cat': 21,
  };

  static const Map<String, int> defaultDuration = {
    'dog_small': 18,
    'dog_medium': 18,
    'dog_large': 18,
    'cat': 8,
  };

  static const List<String> smallDogBreeds = [
    '吉娃娃',
    '泰迪',
    '博美',
    '约克夏',
    '马尔济斯',
    '比熊',
    '贵宾',
    '雪纳瑞',
    '西施',
    '巴哥',
    '柯基',
    'Chihuahua',
    'Poodle',
    'Pomeranian',
    'Yorkshire',
    'Maltese',
    'Bichon',
    'Schnauzer',
    'Shih Tzu',
    'Pug',
    'Corgi',
  ];

  static const List<String> largeDogBreeds = [
    '金毛',
    '拉布拉多',
    '德牧',
    '哈士奇',
    '阿拉斯加',
    '萨摩耶',
    '边境牧羊犬',
    '罗威纳',
    '杜宾',
    'Golden Retriever',
    'Labrador',
    'German Shepherd',
    'Husky',
    'Alaskan',
    'Samoyed',
    'Border Collie',
    'Rottweiler',
    'Doberman',
  ];

  String getPetSizeCategory(String? species, String? breed) {
    if (species == null) return 'dog_medium';

    final speciesLower = species.toLowerCase();
    if (speciesLower.contains('猫') || speciesLower.contains('cat')) {
      return 'cat';
    }

    if (breed != null) {
      for (final smallBreed in smallDogBreeds) {
        if (breed.contains(smallBreed)) {
          return 'dog_small';
        }
      }
      for (final largeBreed in largeDogBreeds) {
        if (breed.contains(largeBreed)) {
          return 'dog_large';
        }
      }
    }

    return 'dog_medium';
  }

  int getDefaultCycle(String? species, String? breed) {
    final category = getPetSizeCategory(species, breed);
    return defaultCycles[category] ?? 180;
  }

  int getDefaultDuration(String? species, String? breed) {
    final category = getPetSizeCategory(species, breed);
    return defaultDuration[category] ?? 18;
  }

  List<int> calculateCycleLengths(List<EstrusRecord> records) {
    final sorted = List<EstrusRecord>.from(records)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    final lengths = <int>[];
    for (int i = 1; i < sorted.length; i++) {
      final days = sorted[i].startDate.difference(sorted[i - 1].startDate).inDays;
      lengths.add(days);
    }
    return lengths;
  }

  EstrusPrediction predictNextEstrus(
    List<EstrusRecord> records, {
    required String? species,
    String? breed,
  }) {
    final normalRecords = records.where((r) => !r.isAbnormal).toList();

    if (normalRecords.isEmpty) {
      final defaultCycle = getDefaultCycle(species, breed);
      final defaultDur = getDefaultDuration(species, breed);
      final now = DateTime.now();
      return EstrusPrediction(
        predictedDate: now.add(Duration(days: defaultCycle)),
        averageCycle: defaultCycle,
        confidence: PredictionConfidence.low,
        predictionBasis: PredictionBasis.defaultValue,
        message: '基于平均周期预测，准确度较低',
        averageDuration: defaultDur,
      );
    }

    final cycleLengths = calculateCycleLengths(normalRecords);

    if (cycleLengths.isEmpty) {
      final defaultCycle = getDefaultCycle(species, breed);
      final defaultDur = getDefaultDuration(species, breed);
      return EstrusPrediction(
        predictedDate: normalRecords.last.startDate.add(Duration(days: defaultCycle)),
        averageCycle: defaultCycle,
        confidence: PredictionConfidence.low,
        predictionBasis: PredictionBasis.defaultValue,
        message: '数据不足，建议继续记录',
        averageDuration: defaultDur,
      );
    }

    double weightedSum = 0;
    double totalWeight = 0;

    final recentCycles = cycleLengths.reversed.take(3).toList();
    final weights = [0.4, 0.35, 0.25];

    for (int i = 0; i < recentCycles.length; i++) {
      weightedSum += recentCycles[i] * weights[i];
      totalWeight += weights[i];
    }

    final avgCycle = (weightedSum / totalWeight).round();
    final predictedDate = normalRecords.last.startDate.add(Duration(days: avgCycle));

    final durations = normalRecords
        .where((r) => r.durationDays != null)
        .map((r) => r.durationDays!)
        .toList();
    int? avgDuration;
    if (durations.isNotEmpty) {
      avgDuration = (durations.reduce((a, b) => a + b) / durations.length).round();
    } else {
      avgDuration = getDefaultDuration(species, breed);
    }

    final confidence = _calculateConfidence(normalRecords.length);

    return EstrusPrediction(
      predictedDate: predictedDate,
      averageCycle: avgCycle,
      confidence: confidence,
      predictionBasis: PredictionBasis.historicalData,
      message: confidence == PredictionConfidence.high
          ? '预测准确度较高'
          : confidence == PredictionConfidence.medium
              ? '预测准确度中等'
              : '数据不足，建议继续记录',
      averageDuration: avgDuration,
    );
  }

  PredictionConfidence _calculateConfidence(int recordCount) {
    if (recordCount >= 6) return PredictionConfidence.high;
    if (recordCount >= 2) return PredictionConfidence.medium;
    return PredictionConfidence.low;
  }

  List<String> detectAbnormalReasons(EstrusRecord record, List<EstrusRecord> previousRecords) {
    final reasons = <String>[];

    if (record.durationDays != null) {
      if (record.durationDays! > 30) {
        reasons.add('持续时间过长（超过30天）');
      } else if (record.durationDays! < 3) {
        reasons.add('持续时间过短（少于3天）');
      }
    }

    if (previousRecords.isNotEmpty) {
      final lastRecord = previousRecords.first;
      final interval = record.startDate.difference(lastRecord.startDate).inDays;
      if (interval < 45) {
        reasons.add('间隔时间过短（少于45天）');
      } else if (interval > 365) {
        reasons.add('间隔时间过长（超过365天）');
      }
    }

    final abnormalColors = ['绿色', '黑色', 'green', 'black', '脓性'];
    if (record.dischargeColor != null) {
      for (final color in abnormalColors) {
        if (record.dischargeColor!.contains(color)) {
          reasons.add('分泌物颜色异常');
          break;
        }
      }
    }

    return reasons;
  }

  bool isRecordAbnormal(EstrusRecord record, List<EstrusRecord> previousRecords) {
    return detectAbnormalReasons(record, previousRecords).isNotEmpty;
  }

  EstrusRecord? getLatestOngoingRecord(String petId) {
    final records = _localStore.estrusRecordsByPet(petId);
    if (records.isEmpty) return null;

    final latest = records.first;
    if (latest.endDate == null) {
      return latest;
    }
    return null;
  }

  Map<String, int> getStatistics(String petId) {
    final records = _localStore.estrusRecordsByPet(petId);
    final normalRecords = records.where((r) => !r.isAbnormal).toList();

    if (normalRecords.isEmpty) {
      return {
        'totalRecords': records.length,
        'averageCycle': 0,
        'averageDuration': 0,
      };
    }

    final cycleLengths = calculateCycleLengths(normalRecords);
    final avgCycle = cycleLengths.isEmpty
        ? 0
        : (cycleLengths.reduce((a, b) => a + b) / cycleLengths.length).round();

    final durations = normalRecords
        .where((r) => r.durationDays != null)
        .map((r) => r.durationDays!)
        .toList();
    final avgDuration = durations.isEmpty
        ? 0
        : (durations.reduce((a, b) => a + b) / durations.length).round();

    return {
      'totalRecords': records.length,
      'averageCycle': avgCycle,
      'averageDuration': avgDuration,
    };
  }

  Map<String, int> getSymptomStatistics(String petId) {
    final records = _localStore.estrusRecordsByPet(petId);
    final stats = <String, int>{};

    for (final record in records) {
      for (final symptom in record.symptoms) {
        stats[symptom] = (stats[symptom] ?? 0) + 1;
      }
      for (final behavior in record.behaviorChanges) {
        stats[behavior] = (stats[behavior] ?? 0) + 1;
      }
    }

    return stats;
  }
}
