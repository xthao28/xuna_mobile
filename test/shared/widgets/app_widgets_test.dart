import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xuna_mobile/assets.dart';
import 'package:xuna_mobile/shared/widgets/widget_src.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
      MaterialApp(home: Scaffold(body: Center(child: child))),
    );

void main() {
  testWidgets('AppInkCard taps only when enabled', (tester) async {
    var taps = 0;
    await _pump(
      tester,
      AppInkCard(onTap: () => taps++, child: const Text('card')),
    );
    await tester.tap(find.text('card'));
    expect(taps, 1);

    await _pump(
      tester,
      AppInkCard(
        enabled: false,
        onTap: () => taps++,
        child: const Text('card'),
      ),
    );
    await tester.tap(find.text('card'));
    expect(taps, 1);
  });

  testWidgets('AppCtaButton and AppBoxButton are disabled without a callback',
      (tester) async {
    await _pump(
      tester,
      const Column(
        children: [
          AppCtaButton(label: 'CTA', onPressed: null),
          AppBoxButton(label: 'BOX', onPressed: null),
        ],
      ),
    );
    final cards = tester.widgetList<AppInkCard>(find.byType(AppInkCard));
    expect(cards.every((card) => !card.enabled), isTrue);
  });

  testWidgets('AppToggle reports the flipped value and can be disabled',
      (tester) async {
    bool? changed;
    await _pump(
      tester,
      AppToggle(value: false, onChanged: (value) => changed = value),
    );
    await tester.tap(find.byType(AppToggle));
    expect(changed, isTrue);

    changed = null;
    await _pump(tester, const AppToggle(value: true, onChanged: null));
    await tester.tap(find.byType(AppToggle));
    expect(changed, isNull);
  });

  testWidgets('AppBottomNavBar reports the tapped index', (tester) async {
    int? selected;
    final items = [
      for (final label in ['A', 'B'])
        AppNavItem(
          label: label,
          iconAsset: Assets.ASSETS_ICONS_IC_NAV_HOME_SVG,
          activeIconAsset: Assets.ASSETS_ICONS_IC_NAV_HOME_ACTIVE_SVG,
        ),
    ];
    await _pump(
      tester,
      AppBottomNavBar(
        items: items,
        currentIndex: 0,
        onSelected: (index) => selected = index,
      ),
    );
    await tester.tap(find.text('B'));
    expect(selected, 1);
  });

  testWidgets('AppStatusDot stops blinking when no longer busy',
      (tester) async {
    await _pump(
      tester,
      const AppStatusDot(color: Colors.yellow, blinking: true),
    );
    await tester.pump(const Duration(milliseconds: 400));
    await _pump(tester, const AppStatusDot(color: Colors.green));
    await tester.pumpAndSettle();
    final fade = tester.widget<FadeTransition>(
      find.descendant(
        of: find.byType(AppStatusDot),
        matching: find.byType(FadeTransition),
      ),
    );
    expect(fade.opacity.value, 1);
  });
}
