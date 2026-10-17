import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:xuna_mobile/features/account/domain/entity/consent_settings.dart';
import 'package:xuna_mobile/features/home/presentation/widgets/home_account_card.dart';
import 'package:xuna_mobile/features/home/presentation/widgets/home_consent_sheet.dart';
import 'package:xuna_mobile/generated/locales.g.dart';
import 'package:xuna_mobile/shared/widgets/widget_src.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );

Widget _card({
  bool connected = true,
  String? boundPetId,
  bool aiChatOn = false,
  List<String>? taps,
}) =>
    HomeAccountCard(
      accountName: 'owner@example.com',
      isBusy: false,
      onSignIn: () => taps?.add('signIn'),
      onSignOut: () => taps?.add('signOut'),
      onCheckCloud: () => taps?.add('check'),
      connected: connected,
      boundPetId: boundPetId,
      aiChatOn: aiChatOn,
      onBind: () => taps?.add('bind'),
      onConsents: () => taps?.add('consents'),
    );

AppBoxButton _button(WidgetTester tester, String label) => tester.widget(
    find.ancestor(of: find.text(label), matching: find.byType(AppBoxButton)));

void main() {
  setUpAll(() {
    Get.addTranslations(AppTranslation.translations);
    Get.locale = const Locale('vi', 'VN');
  });

  testWidgets('bind is offered only while connected and unbound',
      (tester) async {
    final taps = <String>[];
    await _pump(tester, _card(taps: taps));
    expect(find.text(LocaleKeys.account_petUnbound.tr), findsOneWidget);
    expect(find.text(LocaleKeys.account_aiChatOff.tr), findsOneWidget);
    await tester.tap(find.text(LocaleKeys.account_bind.tr));
    await tester.tap(find.text(LocaleKeys.account_consents.tr));
    expect(taps, ['bind', 'consents']);

    await _pump(tester, _card(connected: false));
    expect(_button(tester, LocaleKeys.account_bind.tr).onPressed, isNull);

    await _pump(
      tester,
      _card(boundPetId: 'd945c77026fd4f4a8a899bbff4aeed86', aiChatOn: true),
    );
    expect(find.text(LocaleKeys.account_bind.tr), findsNothing);
    expect(
      find.text(LocaleKeys.account_petBound.trParams({'petId': 'd945c770…'})),
      findsOneWidget,
    );
    expect(find.text(LocaleKeys.account_aiChatOn.tr), findsOneWidget);
  });

  testWidgets('consent sheet shows U1–U3 off and reports each toggle',
      (tester) async {
    final changes = <String>[];
    var saved = 0;
    await _pump(
      tester,
      HomeConsentSheet(
        draft: const ConsentSettings(),
        isBusy: false,
        onAggregateMetrics: (value) => changes.add('u1:$value'),
        onExperienceEvents: (value) => changes.add('u2:$value'),
        onConversationText: (value) => changes.add('u3:$value'),
        onSave: () => saved++,
        onClose: () {},
      ),
    );
    final toggles = tester.widgetList<AppToggle>(find.byType(AppToggle));
    expect(toggles.map((t) => t.value), [false, false, false]);
    expect(find.text(LocaleKeys.account_consentU3Note.tr), findsOneWidget);
    for (final toggle in find.byType(AppToggle).evaluate().toList()) {
      await tester.tap(find.byWidget(toggle.widget));
    }
    expect(changes, ['u1:true', 'u2:true', 'u3:true']);
    await tester.tap(find.text(LocaleKeys.account_consentSave.tr));
    expect(saved, 1);
  });

  testWidgets('consent toggles are disabled while busy', (tester) async {
    await _pump(
      tester,
      HomeConsentSheet(
        draft: const ConsentSettings(conversationText: true),
        isBusy: true,
        onAggregateMetrics: (_) {},
        onExperienceEvents: (_) {},
        onConversationText: (_) {},
        onSave: () {},
        onClose: () {},
      ),
    );
    final toggles = tester.widgetList<AppToggle>(find.byType(AppToggle));
    expect(toggles.map((t) => t.onChanged), everyElement(isNull));
    expect(toggles.last.value, isTrue);
    expect(
        _button(tester, LocaleKeys.account_consentSave.tr).onPressed, isNull);
  });
}
