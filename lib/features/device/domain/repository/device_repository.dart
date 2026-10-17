import 'package:xuna_mobile/features/device/domain/entity/learning_explanation.dart';
import 'package:xuna_mobile/features/device/domain/entity/animation_state.dart';
import 'package:xuna_mobile/features/device/domain/entity/device_status.dart';
import 'package:xuna_mobile/features/device/domain/entity/interaction_context.dart';
import 'package:xuna_mobile/features/device/domain/entity/life_summary.dart';
import 'package:xuna_mobile/features/device/domain/entity/memory_episode.dart';
import 'package:xuna_mobile/features/device/domain/entity/pet_identity.dart';

/// Connection to one XUNA device.
///
/// The device is authoritative for pet-life state; this contract only
/// requests, reads and confirms. Every method throws [DeviceException] on
/// failure.
abstract interface class DeviceRepository {
  bool get supportsStatedPreference;
  bool get supportsTimeSync;
  bool get supportsIdentity;

  /// Returns null for firmware without the Identity V1 capability or when
  /// the device has no ready identity yet.
  Future<PetIdentity?> readIdentity();

  /// Returns null for firmware without the additive explanation capability.
  Future<LearningExplanation?> readExplanation();

  /// Device state changes. Emits a [DeviceException] error when the
  /// connection drops or a notification is malformed.
  Stream<DeviceStatus> watchStatus();

  /// IDs of nearby XUNA devices.
  Future<List<String>> scan();

  Future<DeviceStatus> connect(String deviceId);

  Future<DeviceStatus> requestAnimation(AnimationState animation);

  /// Asks the device to choose an action for [context] from its learned
  /// preference.
  Future<DeviceStatus> suggest(InteractionContext context);

  /// Rates the suggestion identified by [decisionId].
  Future<void> sendFeedback({
    required bool approved,
    required bool fromText,
    required int decisionId,
  });

  Future<LifeSummary> readLife();

  /// Retained episodes, oldest first.
  Future<List<MemoryEpisode>> readMemories();

  /// Deletes the learned preference and memories on the device.
  Future<void> forget();
  Future<void> statePreference(
      {required bool likes,
      required int contextKey,
      required AnimationState action});

  Future<void> disconnect();
}
