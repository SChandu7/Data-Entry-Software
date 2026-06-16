import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';
import 'db/database.dart';
import 'shared.dart';
import 'splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SQLite FFI for desktop
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Pre-open DB so the data folder is ready before first use
  await AppDatabase.instance.database;

  // Window setup
  await windowManager.ensureInitialized();
  const opts = WindowOptions(
    size: Size(1340, 860),
    minimumSize: Size(1100, 700),
    center: true,
    title: 'BIP — Bn Information Package',
    titleBarStyle: TitleBarStyle.normal,
  );
  windowManager.waitUntilReadyToShow(opts, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const BipApp());
}

class BipApp extends StatelessWidget {
  const BipApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BIP — Bn Information Package',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const SplashScreen(),
    );
  }
}
