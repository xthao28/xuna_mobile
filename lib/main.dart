import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:xuna_mobile/core/presentation/app.dart';
import 'package:xuna_mobile/core/presentation/bindings/app_binding.dart';
import 'package:xuna_mobile/shared/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Optional cloud account. XUNA's local life never depends on it.
    await Firebase.initializeApp();
  } catch (error) {
    logger.w('Firebase unavailable: ${error.runtimeType}');
  }
  await AppBinding().bind();
  runApp(App());
}
