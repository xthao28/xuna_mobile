import 'package:equatable/equatable.dart';
import 'package:xuna_mobile/features/device/domain/entity/learning_explanation.dart';
import 'package:xuna_mobile/features/device/domain/entity/life_summary.dart';
import 'package:xuna_mobile/features/device/domain/entity/memory_episode.dart';
import 'package:xuna_mobile/features/device/domain/entity/pet_identity.dart';

typedef DeviceExportCapabilities = ({
  bool statedPreference,
  bool timeSync,
  bool identity,
});

/// Read-only snapshot of device-confirmed data for a local export (Cloud
/// gate c). Every field was read from the device; nothing is phone truth.
class DeviceExport extends Equatable {
  const DeviceExport({
    required this.exportedAt,
    required this.capabilities,
    required this.identity,
    required this.life,
    required this.memories,
    required this.explanation,
  });

  final DateTime exportedAt;
  final DeviceExportCapabilities capabilities;
  final PetIdentity identity;
  final LifeSummary life;

  /// Oldest first.
  final List<MemoryEpisode> memories;

  /// Null when the firmware lacks the explanation capability.
  final LearningExplanation? explanation;

  @override
  List<Object?> get props =>
      [exportedAt, capabilities, identity, life, memories, explanation];
}
