import 'package:equatable/equatable.dart';
import 'package:xuna_mobile/features/device/domain/entity/animation_state.dart';

/// Current animation reported by the device.
class DeviceStatus extends Equatable {
  const DeviceStatus({
    required this.animation,
    required this.sequence,
  });

  final AnimationState animation;

  /// Increments on every device state transition; wraps modulo 2^32.
  final int sequence;

  @override
  List<Object?> get props => [animation, sequence];
}
