import 'package:flutter/material.dart';
import 'core/di/injection_container.dart';
import 'main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize with MOCK flag = true
  await initDependencies(isMock: true);

  runApp(const WhiteLabelApp());
}