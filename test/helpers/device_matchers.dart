import 'package:flutter_test/flutter_test.dart';
import 'package:xuna_mobile/features/device/domain/exception/device_exception.dart';

TypeMatcher<DeviceException> isDeviceException(DeviceExceptionKind kind) =>
    isA<DeviceException>().having((e) => e.kind, 'kind', kind);
