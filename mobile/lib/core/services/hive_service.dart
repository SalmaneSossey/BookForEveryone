import 'package:hive_flutter/hive_flutter.dart';

import '../models/reading_progress.dart';
import '../models/user_profile.dart';

class HiveService {
  const HiveService._();

  static const profileBoxName = 'profile_box';
  static const readingProgressBoxName = 'reading_progress_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(profileBoxName);
    await Hive.openBox<dynamic>(readingProgressBoxName);
  }

  static Future<void> saveProfile(UserProfile profile) async {
    final box = Hive.box<dynamic>(profileBoxName);
    await box.put('profile', profile.toJson());
  }

  static UserProfile? loadProfile() {
    final box = Hive.box<dynamic>(profileBoxName);
    final raw = box.get('profile');
    if (raw is Map) {
      return UserProfile.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  static Future<void> saveReadingProgress(ReadingProgress progress) async {
    final box = Hive.box<dynamic>(readingProgressBoxName);
    await box.put(progress.bookId, progress.toJson());
  }

  static ReadingProgress? loadReadingProgress(String bookId) {
    final box = Hive.box<dynamic>(readingProgressBoxName);
    final raw = box.get(bookId);
    if (raw is Map) {
      return ReadingProgress.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }
}
