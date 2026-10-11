import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:xuna_mobile/features/home/presentation/binding/home_binding.dart';
import 'package:xuna_mobile/features/home/presentation/home_page.dart';

void main() {
  testWidgets(
      'simulator UI scans, connects, plays happy, expires and disconnects',
      (tester) async {
    Get.testMode = true;
    HomeBinding(simulator: true).dependencies();
    await tester.pumpWidget(GetMaterialApp(home: HomePage()));
    expect(find.text('SIMULATOR · FAKE BLE'), findsOneWidget);
    await tester.tap(find.text('Tìm XUNA mô phỏng'));
    await tester.pump();
    await tester.tap(find.text('XUNA simulator'));
    await tester.pump();
    expect(find.text('Đã kết nối mô phỏng'), findsOneWidget);
    await tester.tap(find.text('Happy'));
    await tester.pump();
    expect(find.text('happy'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2401));
    expect(find.text('idle'), findsOneWidget);
    await tester.ensureVisible(find.text('Ngắt kết nối'));
    await tester.tap(find.text('Ngắt kết nối'));
    await tester.pump();
    await tester.drag(find.byType(ListView), const Offset(0, 1200));
    await tester.pumpAndSettle();
    expect(find.text('Đã ngắt kết nối'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    Get.reset();
  });
}
