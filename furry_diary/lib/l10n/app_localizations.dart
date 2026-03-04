import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'毛孩子日记'**
  String get appTitle;

  /// No description provided for @tabHome.
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get tabHome;

  /// No description provided for @tabProfiles.
  ///
  /// In zh, this message translates to:
  /// **'档案'**
  String get tabProfiles;

  /// No description provided for @tabRecords.
  ///
  /// In zh, this message translates to:
  /// **'记录'**
  String get tabRecords;

  /// No description provided for @tabMine.
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get tabMine;

  /// No description provided for @petProfilesTitle.
  ///
  /// In zh, this message translates to:
  /// **'宠物档案'**
  String get petProfilesTitle;

  /// No description provided for @addPet.
  ///
  /// In zh, this message translates to:
  /// **'添加宠物'**
  String get addPet;

  /// No description provided for @petName.
  ///
  /// In zh, this message translates to:
  /// **'名字'**
  String get petName;

  /// No description provided for @petSpecies.
  ///
  /// In zh, this message translates to:
  /// **'物种 (如猫、狗)'**
  String get petSpecies;

  /// No description provided for @petBreed.
  ///
  /// In zh, this message translates to:
  /// **'品种'**
  String get petBreed;

  /// No description provided for @petBirthDate.
  ///
  /// In zh, this message translates to:
  /// **'出生日期 (YYYY-MM-DD)'**
  String get petBirthDate;

  /// No description provided for @petWeight.
  ///
  /// In zh, this message translates to:
  /// **'体重 (kg)'**
  String get petWeight;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// No description provided for @deleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除这个宠物档案吗？'**
  String get deleteConfirm;

  /// No description provided for @noPets.
  ///
  /// In zh, this message translates to:
  /// **'还没有添加宠物，点击右下角添加吧！'**
  String get noPets;

  /// No description provided for @selectAvatar.
  ///
  /// In zh, this message translates to:
  /// **'选择头像'**
  String get selectAvatar;

  /// No description provided for @camera.
  ///
  /// In zh, this message translates to:
  /// **'拍照'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In zh, this message translates to:
  /// **'相册'**
  String get gallery;

  /// No description provided for @settingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'我的与设置'**
  String get settingsTitle;

  /// No description provided for @language.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In zh, this message translates to:
  /// **'主题'**
  String get theme;

  /// No description provided for @about.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get about;

  /// No description provided for @homeTitle.
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get homeTitle;

  /// No description provided for @welcome.
  ///
  /// In zh, this message translates to:
  /// **'欢迎来到毛孩子日记'**
  String get welcome;

  /// No description provided for @moreFeatures.
  ///
  /// In zh, this message translates to:
  /// **'更多功能开发中...'**
  String get moreFeatures;

  /// No description provided for @healthRecordsTitle.
  ///
  /// In zh, this message translates to:
  /// **'健康记录'**
  String get healthRecordsTitle;

  /// No description provided for @noRecords.
  ///
  /// In zh, this message translates to:
  /// **'暂无记录'**
  String get noRecords;

  /// No description provided for @languageChinese.
  ///
  /// In zh, this message translates to:
  /// **'中文'**
  String get languageChinese;

  /// No description provided for @languageEnglish.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @accountStatus.
  ///
  /// In zh, this message translates to:
  /// **'账号状态'**
  String get accountStatus;

  /// No description provided for @proUser.
  ///
  /// In zh, this message translates to:
  /// **'Pro 用户'**
  String get proUser;

  /// No description provided for @freeUser.
  ///
  /// In zh, this message translates to:
  /// **'免费用户'**
  String get freeUser;

  /// No description provided for @upgradePro.
  ///
  /// In zh, this message translates to:
  /// **'升级 Pro'**
  String get upgradePro;

  /// No description provided for @upgradeProDesc.
  ///
  /// In zh, this message translates to:
  /// **'解锁无限记录、更多提醒自定义能力'**
  String get upgradeProDesc;

  /// No description provided for @privacySettings.
  ///
  /// In zh, this message translates to:
  /// **'隐私设置'**
  String get privacySettings;

  /// No description provided for @notificationSettings.
  ///
  /// In zh, this message translates to:
  /// **'通知设置'**
  String get notificationSettings;

  /// No description provided for @petGender.
  ///
  /// In zh, this message translates to:
  /// **'性别'**
  String get petGender;

  /// No description provided for @editPet.
  ///
  /// In zh, this message translates to:
  /// **'编辑宠物'**
  String get editPet;

  /// No description provided for @addPetDesc.
  ///
  /// In zh, this message translates to:
  /// **'还没有宠物档案，点击右下角添加'**
  String get addPetDesc;

  /// No description provided for @petBreedLabel.
  ///
  /// In zh, this message translates to:
  /// **'品种: {breed}'**
  String petBreedLabel(String breed);

  /// No description provided for @petGenderLabel.
  ///
  /// In zh, this message translates to:
  /// **'性别: {gender}'**
  String petGenderLabel(String gender);

  /// No description provided for @statusUnplanned.
  ///
  /// In zh, this message translates to:
  /// **'未计划'**
  String get statusUnplanned;

  /// No description provided for @statusOverdue.
  ///
  /// In zh, this message translates to:
  /// **'已逾期'**
  String get statusOverdue;

  /// No description provided for @statusDueSoon.
  ///
  /// In zh, this message translates to:
  /// **'即将到期'**
  String get statusDueSoon;

  /// No description provided for @statusNormal.
  ///
  /// In zh, this message translates to:
  /// **'正常'**
  String get statusNormal;

  /// No description provided for @lastRecord.
  ///
  /// In zh, this message translates to:
  /// **'上次：{date}'**
  String lastRecord(String date);

  /// No description provided for @nextReminder.
  ///
  /// In zh, this message translates to:
  /// **'下次提醒：{date}'**
  String nextReminder(String date);

  /// No description provided for @nextReminderUnplanned.
  ///
  /// In zh, this message translates to:
  /// **'下次提醒：未计划'**
  String get nextReminderUnplanned;

  /// No description provided for @typeVaccine.
  ///
  /// In zh, this message translates to:
  /// **'疫苗'**
  String get typeVaccine;

  /// No description provided for @typeDeworm.
  ///
  /// In zh, this message translates to:
  /// **'驱虫'**
  String get typeDeworm;

  /// No description provided for @typeCheckup.
  ///
  /// In zh, this message translates to:
  /// **'体检'**
  String get typeCheckup;

  /// No description provided for @typeMedication.
  ///
  /// In zh, this message translates to:
  /// **'用药'**
  String get typeMedication;

  /// No description provided for @typeBath.
  ///
  /// In zh, this message translates to:
  /// **'洗澡'**
  String get typeBath;

  /// No description provided for @typeWeight.
  ///
  /// In zh, this message translates to:
  /// **'体重'**
  String get typeWeight;

  /// No description provided for @upcomingReminders.
  ///
  /// In zh, this message translates to:
  /// **'近期待办提醒'**
  String get upcomingReminders;

  /// No description provided for @upcomingNoData.
  ///
  /// In zh, this message translates to:
  /// **'近期没有需要处理的待办事项哦~'**
  String get upcomingNoData;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
