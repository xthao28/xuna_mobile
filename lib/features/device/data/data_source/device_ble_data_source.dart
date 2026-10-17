import 'package:xuna_mobile/features/device/data/model/learning_explanation_model.dart';
import 'package:xuna_mobile/features/device/data/model/device_command_model.dart';
import 'package:xuna_mobile/features/device/data/model/device_status_model.dart';
import 'package:xuna_mobile/features/device/data/model/life_summary_model.dart';
import 'package:xuna_mobile/features/device/data/model/memory_episode_model.dart';

/// BLE transport to one XUNA device, protocol v1.
///
/// Implemented by the FlutterBluePlus adapter and by the development
/// simulator. Throws `DeviceException` for protocol conditions it detects and
/// leaves other errors to the repository.
abstract interface class DeviceBleDataSource {
  bool get supportsStatedPreference;
  bool get supportsTimeSync;

  /// Returns null for firmware without the additive explanation capability.
  Future<LearningExplanationModel?> readExplanation();

  /// Status notifications, including command results. Errors are emitted
  /// when the connection drops or a frame is malformed.
  Stream<DeviceStatusModel> get statuses;

  Future<List<String>> scan();

  /// Connects, checks capabilities and returns the current status.
  Future<DeviceStatusModel> connect(String deviceId);

  /// Sends one command and waits for its correlated, successful result. At
  /// most one command is in flight; a timed-out command is never resent.
  Future<DeviceStatusModel> send(DeviceCommandModel command);

  Future<LifeSummaryModel> readLife();

  /// Both memory pages, oldest episode first.
  Future<List<MemoryEpisodeModel>> readMemories();

  Future<void> disconnect();

  /// Disconnects and releases resources; the data source is unusable after.
  Future<void> close();
}
