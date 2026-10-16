import 'package:flutter_test/flutter_test.dart';
import 'package:xuna_mobile/features/device/domain/domain.src.dart';

class _Repository extends Fake implements DeviceRepository {
  @override
  Future<LearningExplanation?> readExplanation() async => null;
}

void main() {
  test('old firmware has no projection and causes no command', () async {
    expect(
        await ReadLearningExplanationUseCase(_Repository()).execute(), isNull);
  });
}
