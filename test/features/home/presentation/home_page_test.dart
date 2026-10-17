import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:xuna_mobile/core/presentation/navigation/navigation_src.dart';
import 'package:xuna_mobile/features/home/presentation/binding/home_binding.dart';
import 'package:xuna_mobile/features/home/presentation/home_page.dart';
import 'package:xuna_mobile/features/home/presentation/widgets/home_chat_composer.dart';
import 'package:xuna_mobile/features/home/presentation/widgets/home_chat_tab.dart';
import 'package:xuna_mobile/features/home/presentation/widgets/home_device_status_card.dart';
import 'package:xuna_mobile/features/home/presentation/widgets/home_device_tab.dart';
import 'package:xuna_mobile/features/home/presentation/widgets/home_journal_tab.dart';
import 'package:xuna_mobile/features/home/presentation/widgets/home_overview_tab.dart';
import 'package:xuna_mobile/features/home/presentation/widgets/home_room_card.dart';
import 'package:xuna_mobile/generated/locales.g.dart';
import 'package:xuna_mobile/shared/widgets/widget_src.dart';

Future<void> _pumpHome(
  WidgetTester tester, {
  Size size = const Size(393, 852),
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  Get.testMode = true;
  Get.put<AppNavigator>(AppNavigatorImpl());
  HomeBinding(simulator: true).dependencies();
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 3));
    Get.reset();
    tester.view.reset();
  });
  await tester.pumpWidget(GetMaterialApp(
    translationsKeys: AppTranslation.translations,
    locale: const Locale('vi', 'VN'),
    builder: BotToastInit(),
    home: HomePage(),
  ));
  await tester.pump();
}

/// All tabs stay mounted in an IndexedStack; scope finders to one of them.
Finder _inTab<T extends Widget>(Finder finder) =>
    find.descendant(of: find.byType(T), matching: finder);

Future<void> _openTab(WidgetTester tester, String label) async {
  await tester.tap(_inTab<AppBottomNavBar>(find.text(label)));
  await tester.pump();
}

/// Scrolls the tab owning [finder] until it is built, then taps it.
Future<void> _tapIn<T extends Widget>(
    WidgetTester tester, Finder finder) async {
  final target = _inTab<T>(finder);
  if (target.evaluate().isEmpty) {
    // Lazy lists may have disposed it above or below: restart from the top.
    final scrollable = _inTab<T>(find.byType(Scrollable)).first;
    tester.state<ScrollableState>(scrollable).position.jumpTo(0);
    await tester.pump();
    if (target.evaluate().isEmpty) {
      await tester.scrollUntilVisible(target, 200, scrollable: scrollable);
    }
  }
  await _tap(tester, target);
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
}

Future<void> _connectSimulator(WidgetTester tester) async {
  await _openTab(tester, 'Thiết bị');
  await _tapIn<HomeDeviceTab>(tester, find.text('TÌM XUNA MÔ PHỎNG'));
  await _tapIn<HomeDeviceTab>(tester, find.text('XUNA simulator'));
  // The tab is a lazy ListView; bring the status card back into view.
  await tester.scrollUntilVisible(
    find.byKey(HomeDeviceStatusCard.statusMessageKey),
    -200,
    scrollable: _inTab<HomeDeviceTab>(find.byType(Scrollable)).first,
  );
}

String? _deviceStatus(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(HomeDeviceStatusCard.statusMessageKey)).data;

String? _activity(WidgetTester tester) => tester
    .widget<Text>(
      find.descendant(
        of: find.byKey(HomeRoomCard.activityKey),
        matching: find.byType(Text),
      ),
    )
    .data;

Future<void> _say(WidgetTester tester, String prompt) =>
    _tap(tester, _inTab<HomeChatComposer>(find.text(prompt)));

void main() {
  testWidgets(
      'simulator connects from the device tab and mirrors the device animation',
      (tester) async {
    await _pumpHome(tester);
    expect(_activity(tester), 'CHƯA KẾT NỐI');
    expect(_inTab<HomeOverviewTab>(find.text('MÔ PHỎNG')), findsOneWidget);

    await _openTab(tester, 'Thiết bị');
    expect(_inTab<HomeDeviceTab>(find.text('SIMULATOR · FAKE BLE')),
        findsOneWidget);
    await _connectSimulator(tester);
    expect(_deviceStatus(tester), 'Đã kết nối mô phỏng');

    await _tapIn<HomeDeviceTab>(tester, find.text('Vui'));
    await _openTab(tester, 'Nhà');
    expect(_activity(tester), 'ĐANG VUI');
    expect(find.text('Hihi, nhột quá!'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2401));
    expect(_activity(tester), 'ĐANG THƯ GIÃN');
    expect(find.text('Hihi, nhột quá!'), findsNothing);

    await _openTab(tester, 'Thiết bị');
    await _tapIn<HomeDeviceTab>(tester, find.text('NGẮT KẾT NỐI'));
    expect(_deviceStatus(tester), 'Đã ngắt kết nối');
  });

  testWidgets(
      'chat feedback needs confirmation, then appears in the journal and can be forgotten',
      (tester) async {
    await _pumpHome(tester);
    await _connectSimulator(tester);
    await _openTab(tester, 'Trò chuyện');

    await _say(tester, 'Nghỉ nhé');
    expect(
      _inTab<HomeChatTab>(find.textContaining('cho yên tĩnh')),
      findsOneWidget,
    );
    await _say(tester, 'Không thích');
    expect(_inTab<HomeChatTab>(find.text('Xác nhận ghi feedback')),
        findsOneWidget);
    await _openTab(tester, 'Nhật ký');
    expect(
      _inTab<HomeJournalTab>(
          find.text('Bạn không thích XUNA thư giãn khi yên tĩnh')),
      findsNothing,
    );

    await _openTab(tester, 'Trò chuyện');
    await _tap(tester, _inTab<HomeChatTab>(find.text('Xác nhận ghi feedback')));
    expect(
        _inTab<HomeChatTab>(find.text('Xác nhận ghi feedback')), findsNothing);

    await _openTab(tester, 'Nhật ký');
    const memory = 'Bạn không thích XUNA thư giãn khi yên tĩnh';
    expect(_inTab<HomeJournalTab>(find.text(memory)), findsOneWidget);
    expect(
      _inTab<HomeJournalTab>(find.text('Ghi lại từ tin nhắn bạn đã xác nhận.')),
      findsOneWidget,
    );

    await _tapIn<HomeJournalTab>(tester, find.text('Xóa memory và preference'));
    await tester.pumpAndSettle();
    expect(find.text('Xóa memory và preference?'), findsOneWidget);
    await tester.tap(find.text('Xóa'));
    await tester.pumpAndSettle();
    expect(_inTab<HomeJournalTab>(find.text(memory)), findsNothing);

    await _openTab(tester, 'Trò chuyện');
    expect(
      _inTab<HomeChatTab>(find.text('Đã xóa preference và memory.')),
      findsOneWidget,
    );
  });

  testWidgets('features without data are labeled coming soon', (tester) async {
    await _pumpHome(tester);
    expect(_inTab<HomeOverviewTab>(find.text('SẮP CÓ')), findsOneWidget);
    await _openTab(tester, 'Trò chuyện');
    expect(_inTab<HomeChatTab>(find.textContaining('SẮP CÓ')), findsOneWidget);

    await _openTab(tester, 'Thiết bị');
    await tester.scrollUntilVisible(
      _inTab<HomeDeviceTab>(find.text('Loa & micro trên thiết bị')),
      200,
      scrollable: _inTab<HomeDeviceTab>(find.byType(Scrollable)),
    );
    expect(_inTab<HomeDeviceTab>(find.text('SẮP CÓ')), findsNWidgets(4));

    await _openTab(tester, 'Nhật ký');
    expect(
      _inTab<HomeJournalTab>(
        find.text('Nhật ký nằm trên XUNA. Kết nối để xem.'),
      ),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      _inTab<HomeJournalTab>(find.text('SẮP CÓ')),
      200,
      scrollable: _inTab<HomeJournalTab>(find.byType(Scrollable)).first,
    );
  });

  testWidgets('every tab lays out on a small phone without overflow',
      (tester) async {
    await _pumpHome(tester, size: const Size(360, 640));
    for (final tab in ['Trò chuyện', 'Nhật ký', 'Thiết bị', 'Nhà']) {
      await _openTab(tester, tab);
      expect(tester.takeException(), isNull, reason: tab);
    }
    await _connectSimulator(tester);
    for (final tab in ['Nhật ký', 'Trò chuyện', 'Nhà']) {
      await _openTab(tester, tab);
      expect(tester.takeException(), isNull, reason: '$tab connected');
    }
  });
}
