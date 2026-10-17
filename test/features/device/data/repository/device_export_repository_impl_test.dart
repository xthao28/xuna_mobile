import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xuna_mobile/features/device/data/codec/export_document_codec.dart';
import 'package:xuna_mobile/features/device/data/data_source/device_export_local_data_source.dart';
import 'package:xuna_mobile/features/device/data/repository/device_export_repository_impl.dart';
import 'package:xuna_mobile/features/device/domain/entity/animation_state.dart';
import 'package:xuna_mobile/features/device/domain/entity/device_export.dart';
import 'package:xuna_mobile/features/device/domain/entity/interaction_context.dart';
import 'package:xuna_mobile/features/device/domain/entity/learning_explanation.dart';
import 'package:xuna_mobile/features/device/domain/entity/life_summary.dart';
import 'package:xuna_mobile/features/device/domain/entity/memory_episode.dart';
import 'package:xuna_mobile/features/device/domain/entity/pet_identity.dart';
import 'package:xuna_mobile/features/device/domain/exception/device_exception.dart';

class _MemoryFiles implements DeviceExportLocalDataSource {
  _MemoryFiles({this.error});
  final Object? error;
  final files = <String, String>{};
  @override
  Future<String> write(String fileName, String content) async {
    final failure = error;
    if (failure != null) throw failure;
    files[fileName] = content;
    return '/docs/exports/$fileName';
  }
}

final _export = DeviceExport(
  exportedAt: DateTime.utc(2026, 10, 17, 8, 5, 9),
  capabilities: (statedPreference: true, timeSync: true, identity: true),
  identity: const PetIdentity(
    petId: 'd945c77026fd4f4a8a899bbff4aeed86',
    origin: PetOrigin.migratedFromV1,
    snapshotGeneration: 34,
  ),
  life: const LifeSummary(
    activeSeconds: 6989,
    events: 4,
    decisionId: 7,
    context: InteractionContext.play,
    action: AnimationState.happy,
    playChoice: AnimationState.curious,
    memories: 1,
  ),
  memories: const [
    MemoryEpisode(
      context: InteractionContext.quiet,
      action: AnimationState.idle,
      approved: true,
      fromText: true,
    ),
  ],
  explanation: const LearningExplanation(
    interaction: LearningInteraction.quiet,
    dayPart: LearningDayPart.evening,
    action: AnimationState.happy,
    reason: LearningReason.told,
    fine: false,
    rated: 0,
    probability: 0.6015625,
    effectiveMass: 0.5,
    positive: 0.5,
    negative: 0,
    statedPositive: 0.5,
    statedNegative: 0,
  ),
);

void main() {
  test('writes a versioned, hash-verified xuna.export.v1 document', () async {
    final files = _MemoryFiles();
    final result =
        await DeviceExportRepositoryImpl(files, appVersion: '1.0.0+1')
            .save(_export);
    const name =
        'xuna-export-d945c77026fd4f4a8a899bbff4aeed86-20261017T080509Z.json';
    expect(result.location, '/docs/exports/$name');
    final document = files.files[name]!;
    final payload = ExportDocumentCodec.decode(document);
    expect(result.sha256, ExportDocumentCodec.hash(payload));
    final json = jsonDecode(document) as Map<String, dynamic>;
    expect(json['format'], 'xuna.export.v1');
    expect(payload['exportedAtUtc'], '2026-10-17T08:05:09.000Z');
    expect(payload['app'], {'version': '1.0.0+1'});
    expect(payload['identity'], {
      'petId': 'd945c77026fd4f4a8a899bbff4aeed86',
      'origin': 'migrated_from_v1',
      'snapshotGeneration': 34,
    });
    final life = payload['life'] as Map<String, dynamic>;
    expect(life['feedbackCount'], 4);
    expect(life['playChoice'], 'curious');
    expect(payload['memories'], [
      {
        'context': 'quiet',
        'action': 'idle',
        'approved': true,
        'source': 'text'
      },
    ]);
    final explanation = payload['explanation'] as Map<String, dynamic>;
    expect(explanation['reason'], 'told');
    expect(explanation['dayPart'], 'evening');
    expect(explanation['probabilityQ8'], 154);
    expect(explanation['statedPositiveQ8'], 128);
  });

  test('the hash is SHA-256 of the compact payload JSON', () async {
    final files = _MemoryFiles();
    await DeviceExportRepositoryImpl(files, appVersion: 'x').save(_export);
    final json = jsonDecode(files.files.values.single) as Map<String, dynamic>;
    final compact = jsonEncode(json['payload']);
    expect(json['sha256'], sha256.convert(utf8.encode(compact)).toString());
    final tampered = files.files.values.single.replaceFirst('6989', '6990');
    expect(() => ExportDocumentCodec.decode(tampered), throwsFormatException);
  });

  test('null explanation is exported as null', () async {
    final files = _MemoryFiles();
    final withoutWhy = DeviceExport(
      exportedAt: _export.exportedAt,
      capabilities: _export.capabilities,
      identity: _export.identity,
      life: _export.life,
      memories: const [],
      explanation: null,
    );
    await DeviceExportRepositoryImpl(files, appVersion: 'x').save(withoutWhy);
    final payload = ExportDocumentCodec.decode(files.files.values.single);
    expect(payload['explanation'], isNull);
    expect(payload['memories'], isEmpty);
  });

  test('storage failures become exportFailed', () async {
    final repository = DeviceExportRepositoryImpl(
      _MemoryFiles(error: const FileSystemException('full')),
      appVersion: 'x',
    );
    await expectLater(
      repository.save(_export),
      throwsA(isA<DeviceException>()
          .having((e) => e.kind, 'kind', DeviceExceptionKind.exportFailed)),
    );
  });
}
