import 'dart:async';
import '../domain/device_repository.dart';
import 'protocol_codec.dart';

/// Development fake, with the same bounded preference rule as firmware.
class SimulatorDeviceRepository extends DeviceRepository {
  SimulatorDeviceRepository(
      {this.happyDuration = const Duration(milliseconds: 2400)});
  final Duration happyDuration;
  final _statuses = StreamController<DeviceStatus>.broadcast();
  Timer? _expiry;
  bool _connected = false, _feedbackUsed = true;
  int _requestId = 0, _decision = 0, _events = 0;
  InteractionContext _context = InteractionContext.quiet;
  AnimationState _action = AnimationState.idle;
  DeviceStatus _status = const DeviceStatus(AnimationState.idle, 0);
  final _memories = <MemoryEpisode>[];
  final _positive = List.generate(2, (_) => [0, 0]);
  final _negative = List.generate(2, (_) => [0, 0]);
  @override
  bool get simulated => true;
  @override
  Stream<DeviceStatus> get statuses => _statuses.stream;
  @override
  Future<List<String>> scan() async => ['XUNA simulator'];
  @override
  Future<DeviceStatus> connect(String id) async {
    if (id != 'XUNA simulator') throw ArgumentError('Unknown simulator');
    _connected = true;
    _requestId = 0;
    _decision = 0;
    _feedbackUsed = true;
    return _status;
  }

  void _requireConnection() {
    if (!_connected) throw StateError('Connect first');
  }

  void _setAnimation(AnimationState animation) {
    if (_status.animation != animation) {
      _status = DeviceStatus(animation, (_status.sequence + 1) & 0xffffffff);
    }
    _statuses.add(_status);
  }

  @override
  Future<DeviceStatus> requestAnimation(AnimationState animation) async {
    _requireConnection();
    _decision = 0;
    _feedbackUsed = true;
    final command = ProtocolCodec.parseCommand(
        ProtocolCodec.command(++_requestId, animation));
    _expiry?.cancel();
    _setAnimation(command.$2);
    if (animation == AnimationState.happy ||
        animation == AnimationState.curious) {
      _expiry = Timer(happyDuration, () => _setAnimation(AnimationState.idle));
    }
    return _status;
  }

  AnimationState _choose(InteractionContext context) {
    final p = _positive[context.index], n = _negative[context.index];
    return (p[1] + 1) * (p[0] + n[0] + 2) > (p[0] + 1) * (p[1] + n[1] + 2)
        ? AnimationState.happy
        : AnimationState.idle;
  }

  @override
  Future<DeviceStatus> suggest(InteractionContext context) async {
    _requireConnection();
    _context = context;
    _action = _choose(context);
    final result = await requestAnimation(_action);
    _decision = _requestId;
    _feedbackUsed = false;
    return result;
  }

  @override
  Future<void> feedback(bool approved, {bool fromText = false}) async {
    _requireConnection();
    if (_feedbackUsed) {
      throw StateError('Hãy để XUNA chọn trước khi gửi feedback.');
    }
    final p = _positive[_context.index],
        n = _negative[_context.index],
        a = _action.index;
    if ((approved ? p[a] : n[a]) >= 1000) {
      p[a] = (p[a] + 1) ~/ 2;
      n[a] = (n[a] + 1) ~/ 2;
    }
    if (approved) {
      p[a]++;
    } else {
      n[a]++;
    }
    _events++;
    _memories.add(MemoryEpisode(_context, _action, approved, fromText));
    if (_memories.length > 8) _memories.removeAt(0);
    _feedbackUsed = true;
  }

  @override
  Future<LifeSummary> readLife() async {
    _requireConnection();
    return LifeSummary(
        events: _events,
        decisionId: _decision,
        context: _context,
        action: _action,
        quietChoice: _choose(InteractionContext.quiet),
        playChoice: _choose(InteractionContext.play),
        canFeedback: !_feedbackUsed,
        memories: _events.clamp(0, 8));
  }

  @override
  Future<List<MemoryEpisode>> readMemories() async {
    _requireConnection();
    return List.unmodifiable(_memories);
  }

  @override
  Future<void> forget() async {
    _requireConnection();
    for (final row in [..._positive, ..._negative]) {
      row.fillRange(0, 2, 0);
    }
    _memories.clear();
    _events = 0;
    _decision = 0;
    _feedbackUsed = true;
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
    _decision = 0;
    _feedbackUsed = true;
  }

  @override
  void onClose() {
    _expiry?.cancel();
    _statuses.close();
    super.onClose();
  }
}
