/// XUNA BLE protocol v1 constants (parent docs/roadmap/M02-ble.md and
/// MVP-local.md).
abstract final class DeviceProtocol {
  static const version = 1;

  static const opcodeAnimation = 1;
  static const opcodeSuggest = 2;
  static const opcodeFeedback = 3;
  static const opcodeForget = 4;
  static const opcodeTimeSync = 5;
  static const opcodeStatedPreference = 6;
  static const opcodeHatch = 7;

  static const statusSnapshot = 0;
  static const statusResult = 1;
  static const statusStateChange = 2;

  static const resultOk = 0;
  static const resultUnsupportedVersion = 1;
  static const resultInvalidLength = 2;
  static const resultUnsupportedOpcode = 3;
  static const resultInvalidArgument = 4;
  static const resultBusy = 5;
  static const resultRequestIdConflict = 6;
  static const resultNotReady = 7;
  static const resultExpired = 8;

  static const animationIdle = 0;
  static const animationHappy = 1;
  static const animationSleep = 2;
  static const animationCurious = 3;

  static const contextQuiet = 0;
  static const contextPlay = 1;

  static const sourceNone = 0;
  static const sourceButton = 1;
  static const sourceText = 2;
  static const sourcePhone = 1;

  static const capabilityStatedPreference = 1 << 5;
  static const capabilityTimeSync = 1 << 4;
  static const capabilityHatch = 1 << 6;
  static const capabilityIdentity = 1 << 7;

  static const maxRequestId = 0xffffffff;
  static const maxMemoryEpisodes = 8;
}
