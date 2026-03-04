// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Furry Diary';

  @override
  String get tabHome => 'Home';

  @override
  String get tabProfiles => 'Profiles';

  @override
  String get tabRecords => 'Records';

  @override
  String get tabMine => 'Mine';

  @override
  String get petProfilesTitle => 'Pet Profiles';

  @override
  String get addPet => 'Add Pet';

  @override
  String get petName => 'Name';

  @override
  String get petSpecies => 'Species (e.g., Cat, Dog)';

  @override
  String get petBreed => 'Breed';

  @override
  String get petBirthDate => 'Birth Date (YYYY-MM-DD)';

  @override
  String get petWeight => 'Weight (kg)';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get deleteConfirm =>
      'Are you sure you want to delete this pet profile?';

  @override
  String get noPets => 'No pets added yet. Tap the button below to add one!';

  @override
  String get selectAvatar => 'Select Avatar';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get settingsTitle => 'Mine & Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get about => 'About';

  @override
  String get homeTitle => 'Home';

  @override
  String get welcome => 'Welcome to Furry Diary';

  @override
  String get moreFeatures => 'More features coming soon...';

  @override
  String get healthRecordsTitle => 'Health Records';

  @override
  String get noRecords => 'No records yet';

  @override
  String get languageChinese => '中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get accountStatus => 'Account Status';

  @override
  String get proUser => 'Pro User';

  @override
  String get freeUser => 'Free User';

  @override
  String get upgradePro => 'Upgrade to Pro';

  @override
  String get upgradeProDesc =>
      'Unlock unlimited records and more reminder customizations';

  @override
  String get privacySettings => 'Privacy Settings';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get petGender => 'Gender';

  @override
  String get editPet => 'Edit Pet';

  @override
  String get addPetDesc => 'No pet profiles yet, tap the bottom right to add';

  @override
  String petBreedLabel(String breed) {
    return 'Breed: $breed';
  }

  @override
  String petGenderLabel(String gender) {
    return 'Gender: $gender';
  }

  @override
  String get statusUnplanned => 'Unplanned';

  @override
  String get statusOverdue => 'Overdue';

  @override
  String get statusDueSoon => 'Due Soon';

  @override
  String get statusNormal => 'Normal';

  @override
  String lastRecord(String date) {
    return 'Last: $date';
  }

  @override
  String nextReminder(String date) {
    return 'Next: $date';
  }

  @override
  String get nextReminderUnplanned => 'Next: Unplanned';

  @override
  String get typeVaccine => 'Vaccine';

  @override
  String get typeDeworm => 'Deworm';

  @override
  String get typeCheckup => 'Checkup';

  @override
  String get typeMedication => 'Medication';

  @override
  String get typeBath => 'Bath';

  @override
  String get typeWeight => 'Weight';

  @override
  String get upcomingReminders => 'Upcoming Reminders';

  @override
  String get upcomingNoData => 'No upcoming reminders at the moment.';
}
