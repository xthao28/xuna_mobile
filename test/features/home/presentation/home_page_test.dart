import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:xuna_mobile/core/presentation/navigation/navigation_src.dart';
import 'package:xuna_mobile/features/home/presentation/binding/home_binding.dart';
import 'package:xuna_mobile/features/home/presentation/home_page.dart';
import 'package:xuna_mobile/features/home/presentation/widgets/home_connection_section.dart';
import 'package:xuna_mobile/generated/locales.g.dart';

Future<void> _pumpHome(WidgetTester tester) async {
  Get.testMode = true;
  Get.put<AppNavigator>(AppNavigatorImpl());
  HomeBinding(simulator: true).dependencies();
  await tester.pumpWidget(GetMaterialApp(
    translationsKeys: AppTranslation.translations,
    locale: const Locale('vi', 'VN'),
    home: HomePage(),
  ));
}

Future<void> _connectSimulator(WidgetTester tester) async {
  await tester.tap(find.text('Tìm XUNA mô phỏng'));
  await tester.pump();
  await tester.tap(find.text('XUNA simulator'));
  await tester.pump();
}

/// Scrolls [finder] into view, lays out the new position, then taps it.
Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
}

String? _animationLabel(WidgetTester tester) => tester
    .widget<Text>(find.byKey(HomeConnectionSection.animationLabelKey))
    .data;

Future<void> _tearDown(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  Get.reset();
}

void main() {
  testWidgets(
      'simulator UI scans, connects, plays happy, expires and disconnects',
      (tester) async {
    await _pumpHome(tester);
    expect(find.text('SIMULATOR · FAKE BLE'), findsOneWidget);
    await _connectSimulator(tester);
    expect(find.text('Đã kết nối mô phỏng'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Happy'));
    await tester.pump();
    expect(_animationLabel(tester), 'Happy');
    await tester.pump(const Duration(milliseconds: 2401));
    expect(_animationLabel(tester), 'Idle');

    await tester.ensureVisible(find.text('Ngắt kết nối'));
    await tester.tap(find.text('Ngắt kết nối'));
    await tester.pump();
    await tester.drag(find.byType(ListView), const Offset(0, 1200));
    await tester.pumpAndSettle();
    expect(find.text('Đã ngắt kết nối'), findsOneWidget);
    await _tearDown(tester);
  });

  testWidgets('forget asks for confirmation before deleting memory',
      (tester) async {
    await _pumpHome(tester);
    await _connectSimulator(tester);
    await _tapVisible(tester, find.widgetWithText(FilledButton, 'Yên tĩnh'));
    await _tapVisible(
      tester,
      find.widgetWithText(OutlinedButton, 'Không thích'),
    );
    const memoryRow = 'Yên tĩnh: Idle → không thích (nút feedback)';
    expect(find.text(memoryRow), findsOneWidget);

    await _tapVisible(tester, find.text('Xóa memory và preference'));
    await tester.pumpAndSettle();
    expect(find.text('Xóa memory và preference?'), findsOneWidget);

    await tester.tap(find.text('Xóa'));
    await tester.pumpAndSettle();
    expect(find.text('Xóa memory và preference?'), findsNothing);
    expect(find.text(memoryRow), findsNothing);
    expect(find.text('Đã xóa preference và memory.'), findsOneWidget);
    await _tearDown(tester);
  });
}
