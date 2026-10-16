/// Read-only Lifecycle V1 projection owned by the device.
class LifecycleModel {
  const LifecycleModel({
    required this.identityState,
    required this.growthStage,
    required this.clockQuality,
    required this.bornAtQuality,
    required this.origin,
    required this.hasBornAt,
  });

  final int identityState;
  final int growthStage;
  final int clockQuality;
  final int bornAtQuality;
  final int origin;
  final bool hasBornAt;
}
