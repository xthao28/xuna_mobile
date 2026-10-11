import 'dart:async';
import '../domain/device_repository.dart';
import 'protocol_codec.dart';

/// Explicit development fake; never communicates with a physical board.
class SimulatorDeviceRepository extends DeviceRepository {
  SimulatorDeviceRepository(
      {this.happyDuration = const Duration(milliseconds: 2400)});
  final Duration happyDuration;
  final _statuses = StreamController<DeviceStatus>.broadcast();
  Timer? _expiry;
  bool _connected = false;
  int _requestId = 0;
  DeviceStatus _status = const DeviceStatus(AnimationState.idle, 0);
  @override
  Stream<DeviceStatus> get statuses => _statuses.stream;
  @override
  Future<List<String>> scan() async => ['XUNA simulator'];
  @override
  Future<DeviceStatus> connect(String id) async {
    if (id != 'XUNA simulator') throw ArgumentError('Unknown simulator');
    _connected = true;
    _requestId = 0;
    return _status;
  }

  void _setAnimation(AnimationState animation) {
    if (_status.animation != animation) {
      _status = DeviceStatus(animation, (_status.sequence + 1) & 0xffffffff);
    }
    _statuses.add(_status);
  }

  @override
  Future<DeviceStatus> requestAnimation(AnimationState animation) async {
    if (!_connected) throw StateError('Connect first');
    final command = ProtocolCodec.parseCommand(
        ProtocolCodec.command(++_requestId, animation));
    _expiry?.cancel();
    _setAnimation(command.$2);
    if (animation == AnimationState.happy) {
      _expiry = Timer(happyDuration, () => _setAnimation(AnimationState.idle));
    }
    return _status;
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
    // The simulated device keeps its animation timeout running independently.
  }

  @override
  void onClose() {
    _expiry?.cancel();
    _statuses.close();
    super.onClose();
  }
}
