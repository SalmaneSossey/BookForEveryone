import 'package:flutter/material.dart';

import 'app.dart';
import 'core/services/hive_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const KitabLilJamieApp());
}
