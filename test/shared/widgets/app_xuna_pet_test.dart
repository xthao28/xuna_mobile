import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xuna_mobile/shared/widgets/widget_src.dart';

void main() {
  testWidgets('simple backgrounds fit a small card', (tester) async {
    for (final background in AppPetBackground.values) {
      await tester.pumpWidget(MaterialApp(
        home: Center(
            child: AppXunaPet(background: background, width: 100, height: 80)),
      ));
      final image = tester.widget<Image>(find.byType(Image));
      expect((image.image as AssetImage).assetName,
          'assets/images/xuna_pet_idle.png');
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('portraits use transparent pet assets for every expression',
      (tester) async {
    for (final expression in AppPetExpression.values) {
      await tester.pumpWidget(MaterialApp(
        home: AppXunaPet(expression: expression, width: 64, height: 64),
      ));
      final image = tester.widget<Image>(find.byType(Image));
      expect((image.image as AssetImage).assetName,
          'assets/images/xuna_pet_${expression.name}.png');
      expect(image.filterQuality, FilterQuality.none);
      expect(image.width, 64);
    }
  });
}
