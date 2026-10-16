import 'package:xuna_mobile/features/device/data/model/learning_explanation_model.dart';
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:xuna_mobile/features/device/data/codec/protocol_codec.dart';
import 'package:xuna_mobile/features/device/data/data_source/device_ble_data_source.dart';
import 'package:xuna_mobile/features/device/data/data_source/result_correlator.dart';
import 'package:xuna_mobile/features/device/data/model/device_command_model.dart';
import 'package:xuna_mobile/features/device/data/model/device_status_model.dart';
import 'package:xuna_mobile/features/device/data/model/life_summary_model.dart';
import 'package:xuna_mobile/features/device/data/model/memory_episode_model.dart';
import 'package:xuna_mobile/features/device/domain/exception/device_exception.dart';

/// FlutterBluePlus adapter for the XUNA MVP service: foreground, unbonded,
/// 20-byte values, explicit timeouts and no command replay.
class DeviceBleDataSourceImpl implements DeviceBleDataSource {
  static const _service = 1;
  static const _capabilities = 2;
  static const _command = 3;
  static const _status = 4;
  static const _life = 5;
  static const _explanation = 11;
  static const _memoryPages = [6, 7];

  /// FlutterBluePlus GATT operation timeout, in seconds.
  static const _gattTimeout = 3;
  static const _adapterTimeout = Duration(seconds: 3);
  static const _scanDuration = Duration(seconds: 10);
  static const _scanTimeout = Duration(seconds: 12);
  static const _connectTimeout = Duration(seconds: 10);

  static Guid _uuid(int part) => Guid(
      '7a6e${part.toRadixString(16).padLeft(4, '0')}-8c44-4db6-9f61-2b7d5300a101');

  final _statuses = StreamController<DeviceStatusModel>.broadcast();
  final _found = <String, BluetoothDevice>{};
  final _results = ResultCorrelator();
  BluetoothDevice? _device;
  BluetoothCharacteristic? _commandCharacteristic;
  BluetoothCharacteristic? _statusCharacteristic;
  BluetoothCharacteristic? _lifeCharacteristic;
  BluetoothCharacteristic? _explanationCharacteristic;
  List<BluetoothCharacteristic> _memoryCharacteristics = [];
  StreamSubscription<List<int>>? _values;
  StreamSubscription<BluetoothConnectionState>? _connection;
  int _requestId = 0;

  /// Incremented on every connect/disconnect so stale callbacks are ignored.
  int _epoch = 0;
  bool _ready = false;
  bool _supportsStatedPreference = false;
  @override
  bool get supportsStatedPreference => _supportsStatedPreference;

  @override
  Stream<DeviceStatusModel> get statuses => _statuses.stream;

  @override
  Future<List<String>> scan() async {
    if (!await FlutterBluePlus.isSupported) {
      throw const DeviceException(DeviceExceptionKind.bluetoothUnsupported);
    }
    final state = await FlutterBluePlus.adapterState
        .where((s) => s != BluetoothAdapterState.unknown)
        .first
        .timeout(_adapterTimeout);
    if (state != BluetoothAdapterState.on) {
      throw const DeviceException(DeviceExceptionKind.bluetoothOff);
    }
    _found.clear();
    final subscription = FlutterBluePlus.onScanResults.listen((results) {
      for (final result in results) {
        _found[result.device.remoteId.str] = result.device;
      }
    });
    try {
      await FlutterBluePlus.startScan(
        withServices: [_uuid(_service)],
        timeout: _scanDuration,
      );
      await FlutterBluePlus.isScanning
          .where((scanning) => !scanning)
          .first
          .timeout(_scanTimeout);
      return _found.keys.toList();
    } finally {
      await FlutterBluePlus.stopScan();
      await subscription.cancel();
    }
  }

  @override
  Future<DeviceStatusModel> connect(String deviceId) async {
    await disconnect();
    final device = _found[deviceId];
    if (device == null) {
      throw const DeviceException(DeviceExceptionKind.deviceNotFound);
    }
    final epoch = ++_epoch;
    _device = device;
    try {
      await device.connect(timeout: _connectTimeout, mtu: null);
      _connection = device.connectionState.listen((state) {
        if (epoch != _epoch) return;
        if (state == BluetoothConnectionState.disconnected) {
          _ready = false;
          const error = DeviceException(DeviceExceptionKind.disconnected);
          _results.cancel(error);
          _statuses.addError(error);
        }
      });
      final services = await device.discoverServices(timeout: _gattTimeout);
      final service =
          services.where((s) => s.uuid == _uuid(_service)).firstOrNull;
      if (service == null) {
        throw const DeviceException(DeviceExceptionKind.unsupportedDevice);
      }
      BluetoothCharacteristic characteristic(int part) =>
          service.characteristics.firstWhere(
            (c) => c.uuid == _uuid(part),
            orElse: () => throw const DeviceException(
              DeviceExceptionKind.unsupportedDevice,
            ),
          );
      _commandCharacteristic = characteristic(_command);
      _statusCharacteristic = characteristic(_status);
      _lifeCharacteristic = characteristic(_life);
      _memoryCharacteristics = [
        for (final part in _memoryPages) characteristic(part),
      ];
      final capabilities =
          await characteristic(_capabilities).read(timeout: _gattTimeout);
      try {
        ProtocolCodec.validateCapabilities(Uint8List.fromList(capabilities));
        _supportsStatedPreference = ProtocolCodec.supportsStatedPreference(
          Uint8List.fromList(capabilities),
        );
      } on FormatException catch (e) {
        throw DeviceException(
          DeviceExceptionKind.unsupportedDevice,
          rootException: e,
        );
      }
      _explanationCharacteristic =
          _supportsStatedPreference ? characteristic(_explanation) : null;
      _values = _statusCharacteristic!.onValueReceived.listen((bytes) {
        if (epoch != _epoch) return;
        try {
          final status = ProtocolCodec.decodeStatus(Uint8List.fromList(bytes));
          _statuses.add(status);
          _results.accept(status);
        } catch (e) {
          _statuses.addError(e);
        }
      });
      await _statusCharacteristic!.setNotifyValue(true, timeout: _gattTimeout);
      final status = await _readStatus();
      if (epoch != _epoch || !device.isConnected) {
        throw const DeviceException(DeviceExceptionKind.disconnected);
      }
      _requestId = 0;
      _ready = true;
      return status;
    } catch (_) {
      await disconnect();
      rethrow;
    }
  }

  @override
  Future<DeviceStatusModel> send(DeviceCommandModel command) async {
    final characteristic = _commandCharacteristic;
    if (!_ready || characteristic == null) {
      throw const DeviceException(DeviceExceptionKind.notConnected);
    }
    final frame = ProtocolCodec.encode(++_requestId, command);
    final response = _results.begin(_requestId);
    try {
      await characteristic.write(frame, timeout: _gattTimeout);
      return await response;
    } catch (e) {
      _results.cancel(e);
      await response.then<void>((_) {}, onError: (Object _) {});
      final outcomeUnknown =
          e is DeviceException && e.kind == DeviceExceptionKind.outcomeUnknown;
      if (outcomeUnknown && _ready && _statusCharacteristic != null) {
        // Report the current state; the command itself is never resent.
        try {
          _statuses.add(await _readStatus());
        } catch (_) {/* Preserve the original failure. */}
      }
      rethrow;
    }
  }

  @override
  Future<LearningExplanationModel?> readExplanation() async {
    if (!_ready) throw const DeviceException(DeviceExceptionKind.notConnected);
    final characteristic = _explanationCharacteristic;
    if (characteristic == null) return null;
    final bytes = await characteristic.read(timeout: _gattTimeout);
    return LearningExplanationModel.decode(Uint8List.fromList(bytes));
  }

  @override
  Future<LifeSummaryModel> readLife() async {
    final characteristic = _lifeCharacteristic;
    if (!_ready || characteristic == null) {
      throw const DeviceException(DeviceExceptionKind.notConnected);
    }
    final bytes = await characteristic.read(timeout: _gattTimeout);
    return ProtocolCodec.decodeLife(Uint8List.fromList(bytes));
  }

  @override
  Future<List<MemoryEpisodeModel>> readMemories() async {
    if (!_ready) {
      throw const DeviceException(DeviceExceptionKind.notConnected);
    }
    final episodes = <MemoryEpisodeModel>[];
    for (var page = 0; page < _memoryCharacteristics.length; page++) {
      final bytes =
          await _memoryCharacteristics[page].read(timeout: _gattTimeout);
      episodes.addAll(
        ProtocolCodec.decodeMemoryPage(Uint8List.fromList(bytes), page),
      );
    }
    return episodes;
  }

  @override
  Future<void> disconnect() async {
    ++_epoch;
    _ready = false;
    _supportsStatedPreference = false;
    _results.cancel(const DeviceException(DeviceExceptionKind.disconnected));
    await _values?.cancel();
    await _connection?.cancel();
    _values = null;
    _connection = null;
    final device = _device;
    _device = null;
    _commandCharacteristic = null;
    _statusCharacteristic = null;
    _lifeCharacteristic = null;
    _explanationCharacteristic = null;
    _memoryCharacteristics = [];
    await device?.disconnect();
  }

  @override
  Future<void> close() async {
    try {
      await disconnect();
    } finally {
      await _statuses.close();
    }
  }

  Future<DeviceStatusModel> _readStatus() async {
    final bytes = await _statusCharacteristic!.read(timeout: _gattTimeout);
    return ProtocolCodec.decodeStatus(Uint8List.fromList(bytes));
  }
}
