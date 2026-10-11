import 'package:flutter/material.dart';
import 'package:xuna_mobile/core/presentation/app.dart';
import 'package:xuna_mobile/core/presentation/bindings/app_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBinding().bind();
  runApp(App());
}
