// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '毛孩子日记';

  @override
  String get tabHome => '首页';

  @override
  String get tabProfiles => '档案';

  @override
  String get tabRecords => '记录';

  @override
  String get tabMine => '我的';

  @override
  String get petProfilesTitle => '宠物档案';

  @override
  String get addPet => '添加宠物';

  @override
  String get petName => '名字';

  @override
  String get petSpecies => '物种 (如猫、狗)';

  @override
  String get petBreed => '品种';

  @override
  String get petBirthDate => '出生日期 (YYYY-MM-DD)';

  @override
  String get petWeight => '体重 (kg)';

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get delete => '删除';

  @override
  String get deleteConfirm => '确定要删除这个宠物档案吗？';

  @override
  String get noPets => '还没有添加宠物，点击右下角添加吧！';

  @override
  String get selectAvatar => '选择头像';

  @override
  String get camera => '拍照';

  @override
  String get gallery => '相册';

  @override
  String get settingsTitle => '我的与设置';

  @override
  String get language => '语言';

  @override
  String get theme => '主题';

  @override
  String get about => '关于';

  @override
  String get homeTitle => '首页';

  @override
  String get welcome => '欢迎来到毛孩子日记';

  @override
  String get moreFeatures => '更多功能开发中...';

  @override
  String get healthRecordsTitle => '健康记录';

  @override
  String get noRecords => '暂无记录';

  @override
  String get languageChinese => '中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get accountStatus => '账号状态';

  @override
  String get proUser => 'Pro 用户';

  @override
  String get freeUser => '免费用户';

  @override
  String get upgradePro => '升级 Pro';

  @override
  String get upgradeProDesc => '解锁无限记录、更多提醒自定义能力';

  @override
  String get privacySettings => '隐私设置';

  @override
  String get notificationSettings => '通知设置';

  @override
  String get petGender => '性别';

  @override
  String get editPet => '编辑宠物';

  @override
  String get addPetDesc => '还没有宠物档案，点击右下角添加';

  @override
  String petBreedLabel(String breed) {
    return '品种: $breed';
  }

  @override
  String petGenderLabel(String gender) {
    return '性别: $gender';
  }

  @override
  String get statusUnplanned => '未计划';

  @override
  String get statusOverdue => '已逾期';

  @override
  String get statusDueSoon => '即将到期';

  @override
  String get statusNormal => '正常';

  @override
  String lastRecord(String date) {
    return '上次：$date';
  }

  @override
  String nextReminder(String date) {
    return '下次提醒：$date';
  }

  @override
  String get nextReminderUnplanned => '下次提醒：未计划';

  @override
  String get typeVaccine => '疫苗';

  @override
  String get typeDeworm => '驱虫';

  @override
  String get typeCheckup => '体检';

  @override
  String get typeMedication => '用药';

  @override
  String get typeBath => '洗澡';

  @override
  String get typeWeight => '体重';

  @override
  String get upcomingReminders => '近期待办提醒';

  @override
  String get upcomingNoData => '近期没有需要处理的待办事项哦~';
}
