import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../domain/device_repository.dart';
import 'protocol_codec.dart';
import 'result_correlator.dart';

class BleDeviceRepository extends DeviceRepository {
  static Guid uuid(int part) =>
      Guid('7a6e000$part-8c44-4db6-9f61-2b7d5300a101');
  final _statuses = StreamController<DeviceStatus>.broadcast();
  final _found = <String, BluetoothDevice>{};
  BluetoothDevice? _device;
  List<BluetoothCharacteristic> _memories = [];
  BluetoothCharacteristic? _command, _status, _life;
  StreamSubscription<List<int>>? _values;
  StreamSubscription<BluetoothConnectionState>? _connection;
  final _results = ResultCorrelator();
  int _id = 0, _epoch = 0;
  bool _ready = false;
  @override
  bool get simulated => false;
  @override
  Stream<DeviceStatus> get statuses => _statuses.stream;
  @override
  Future<List<String>> scan() async {
    if (!await FlutterBluePlus.isSupported) {
      throw StateError('Thiết bị không hỗ trợ Bluetooth.');
    }
    final state = await FlutterBluePlus.adapterState
        .where((s) => s != BluetoothAdapterState.unknown)
        .first
        .timeout(const Duration(seconds: 3));
    if (state != BluetoothAdapterState.on) {
      throw StateError('Bật Bluetooth và cấp quyền Bluetooth cho XUNA.');
    }
    _found.clear();
    final sub = FlutterBluePlus.onScanResults.listen((results) {
      for (final r in results) {
        _found[r.device.remoteId.str] = r.device;
      }
    });
    try {
      await FlutterBluePlus.startScan(
          withServices: [uuid(1)], timeout: const Duration(seconds: 10));
      await FlutterBluePlus.isScanning
          .where((s) => !s)
          .first
          .timeout(const Duration(seconds: 12));
      return _found.keys.toList();
    } finally {
      await FlutterBluePlus.stopScan();
      await sub.cancel();
    }
  }

  @override
  Future<DeviceStatus> connect(String id) async {
    await disconnect();
    final device = _found[id];
    if (device == null) throw StateError('Tìm lại XUNA trước khi kết nối.');
    final epoch = ++_epoch;
    _device = device;
    try {
      await device.connect(timeout: const Duration(seconds: 10), mtu: null);
      _connection = device.connectionState.listen((state) {
        if (epoch != _epoch) return;
        if (state == BluetoothConnectionState.disconnected) {
          _ready = false;
          _results.cancel(StateError('XUNA đã ngắt kết nối.'));
          _statuses.addError(
              StateError('XUNA đã ngắt kết nối. Hãy tìm và kết nối lại.'));
        }
      });
      final services = await device.discoverServices(timeout: 3);
      final service = services.where((s) => s.uuid == uuid(1)).firstOrNull;
      if (service == null) throw const FormatException('Missing XUNA service');
      BluetoothCharacteristic characteristic(int n) =>
          service.characteristics.firstWhere((c) => c.uuid == uuid(n));
      _command = characteristic(3);
      _status = characteristic(4);
      _life = characteristic(5);
      _memories = [characteristic(6), characteristic(7)];
      ProtocolCodec.validateCapabilities(
          Uint8List.fromList(await characteristic(2).read(timeout: 3)));
      _values = _status!.onValueReceived.listen((bytes) {
        if (epoch != _epoch) return;
        try {
          final s = ProtocolCodec.parseStatus(Uint8List.fromList(bytes));
          _statuses.add(s);
          _results.accept(s);
        } catch (e) {
          _statuses.addError(e);
        }
      });
      await _status!.setNotifyValue(true, timeout: 3);
      final status = ProtocolCodec.parseStatus(
          Uint8List.fromList(await _status!.read(timeout: 3)));
      if (epoch != _epoch || !device.isConnected) {
        throw StateError('Connection changed');
      }
      _id = 0;
      _ready = true;
      return status;
    } catch (_) {
      await disconnect();
      rethrow;
    }
  }

  Future<DeviceStatus> _send(int opcode, int arg,
      {int source = 0, int target = 0}) async {
    if (!_ready || _command == null) throw StateError('Kết nối XUNA trước.');
    final response = _results.begin(++_id);
    try {
      await _command!.write(
          ProtocolCodec.encode(_id, opcode, arg,
              source: source, target: target),
          timeout: 3);
      return await response;
    } catch (e) {
      _results.cancel(e);
      await response
          .catchError((Object _) => const DeviceStatus(AnimationState.idle, 0));
      if (e is TimeoutException && _ready && _status != null) {
        try {
          _statuses.add(ProtocolCodec.parseStatus(
              Uint8List.fromList(await _status!.read(timeout: 3))));
        } catch (_) {/* Preserve original failure. */}
      }
      rethrow;
    }
  }

  @override
  Future<DeviceStatus> requestAnimation(AnimationState animation) =>
      _send(1, animation.index);
  @override
  Future<DeviceStatus> suggest(InteractionContext context) =>
      _send(2, context.index);
  @override
  Future<void> feedback(bool approved, {bool fromText = false}) async {
    final life = await readLife();
    if (!life.canFeedback) {
      throw StateError('Hãy để XUNA chọn trước khi gửi feedback.');
    }
    await _send(3, approved ? 1 : 0,
        source: fromText ? 2 : 1, target: life.decisionId);
  }

  @override
  Future<LifeSummary> readLife() async {
    if (!_ready || _life == null) throw StateError('Kết nối XUNA trước.');
    return ProtocolCodec.parseLife(
        Uint8List.fromList(await _life!.read(timeout: 3)));
  }

  @override
  Future<List<MemoryEpisode>> readMemories() async {
    if (!_ready) throw StateError('Kết nối XUNA trước.');
    final result = <MemoryEpisode>[];
    for (var page = 0; page < 2; page++) {
      result.addAll(ProtocolCodec.parseMemories(
          Uint8List.fromList(await _memories[page].read(timeout: 3)), page));
    }
    return result;
  }

  @override
  Future<void> forget() async {
    await _send(4, 0);
  }

  @override
  Future<void> disconnect() async {
    ++_epoch;
    _ready = false;
    _results.cancel(StateError('Disconnected'));
    await _values?.cancel();
    await _connection?.cancel();
    _values = null;
    _connection = null;
    final d = _device;
    _device = null;
    _command = null;
    _status = null;
    _life = null;
    await d?.disconnect();
  }

  @override
  void onClose() {
    unawaited(disconnect().whenComplete(_statuses.close));
    super.onClose();
  }
}
