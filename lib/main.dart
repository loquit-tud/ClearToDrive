import 'package:cleartodrive/app.dart';
import 'package:cleartodrive/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const ProviderScope(child: ClearToDriveApp()));
}
