import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xuna_mobile/features/device/domain/entity/animation_state.dart';
import 'package:xuna_mobile/features/home/presentation/widgets/home_pet_scene.dart';

void main() {
  testWidgets('device state selects the matching loop and disconnected still',
      (tester) async {
    for (final state in AnimationState.values) {
      await tester.pumpWidget(MaterialApp(
        home: HomePetScene(animation: state, connected: true),
      ));
      var image = tester.widget<Image>(find.byType(Image));
      expect((image.image as AssetImage).assetName,
          'assets/images/xuna_${state.name}.gif');
      await tester.pumpWidget(MaterialApp(
        home: HomePetScene(animation: state, connected: false),
      ));
      image = tester.widget<Image>(find.byType(Image));
      expect((image.image as AssetImage).assetName,
          'assets/images/xuna_${state.name}.png');
    }
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('reduced motion uses a still', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: HomePetScene(animation: AnimationState.happy, connected: true),
      ),
    ));
    expect(
        (tester.widget<Image>(find.byType(Image)).image as AssetImage)
            .assetName,
        'assets/images/xuna_happy.png');
    await tester.pumpWidget(const SizedBox());
  });
}
