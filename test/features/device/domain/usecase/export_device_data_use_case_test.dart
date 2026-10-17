import 'package:flutter_test/flutter_test.dart';
import 'package:xuna_mobile/features/device/domain/entity/device_export.dart';
import 'package:xuna_mobile/features/device/domain/entity/device_export_result.dart';
import 'package:xuna_mobile/features/device/domain/entity/learning_explanation.dart';
import 'package:xuna_mobile/features/device/domain/entity/life_summary.dart';
import 'package:xuna_mobile/features/device/domain/entity/memory_episode.dart';
import 'package:xuna_mobile/features/device/domain/entity/pet_identity.dart';
import 'package:xuna_mobile/features/device/domain/exception/device_exception.dart';
import 'package:xuna_mobile/features/device/domain/repository/device_export_repository.dart';
import 'package:xuna_mobile/features/device/domain/repository/device_repository.dart';
import 'package:xuna_mobile/features/device/domain/usecase/export_device_data_use_case.dart';

class _Device extends Fake implements DeviceRepository {
  _Device(this.identity);
  final PetIdentity? identity;
  final reads = <String>[];
  @override
  bool get supportsStatedPreference => false;
  @override
  bool get supportsTimeSync => true;
  @override
  bool get supportsIdentity => identity != null;
  @override
  Future<PetIdentity?> readIdentity() async {
    reads.add('identity');
    return identity;
  }

  @override
  Future<LifeSummary> readLife() async {
    reads.add('life');
    return const LifeSummary(events: 2);
  }

  @override
  Future<List<MemoryEpisode>> readMemories() async {
    reads.add('memories');
    return const [];
  }

  @override
  Future<LearningExplanation?> readExplanation() async {
    reads.add('explanation');
    return null;
  }
}

class _Exports implements DeviceExportRepository {
  DeviceExport? saved;
  @override
  Future<DeviceExportResult> save(DeviceExport export) async {
    saved = export;
    return const DeviceExportResult(location: 'f', sha256: 'h');
  }
}

void main() {
  const identity = PetIdentity(
    petId: '000102030405460788090a0b0c0d0e0f',
    origin: PetOrigin.hatchedOnDevice,
    snapshotGeneration: 5,
  );

  test('collects device reads into one UTC export', () async {
    final device = _Device(identity);
    final exports = _Exports();
    final result = await ExportDeviceDataUseCase(
      device,
      exports,
      now: () => DateTime.utc(2026, 10, 17, 1),
    ).execute();
    expect(result.location, 'f');
    expect(device.reads, ['identity', 'life', 'memories', 'explanation']);
    final saved = exports.saved!;
    expect(saved.identity, identity);
    expect(saved.exportedAt.isUtc, isTrue);
    expect(saved.life.events, 2);
    expect(saved.capabilities,
        (statedPreference: false, timeSync: true, identity: true));
  });

  test('without a PetId nothing else is read or written', () async {
    final device = _Device(null);
    final exports = _Exports();
    await expectLater(
      ExportDeviceDataUseCase(device, exports).execute(),
      throwsA(isA<DeviceException>().having(
          (e) => e.kind, 'kind', DeviceExceptionKind.identityUnavailable)),
    );
    expect(device.reads, ['identity']);
    expect(exports.saved, isNull);
  });
}
