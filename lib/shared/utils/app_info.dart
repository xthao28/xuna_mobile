import 'dart:developer';

import 'package:package_info_plus/package_info_plus.dart';

class AppInfo {
  PackageInfo? _packageInfo;

  String get appName => _packageInfo?.appName ?? '';
  String get applicationId => _packageInfo?.packageName ?? '';
  String get versionCode => _packageInfo?.buildNumber ?? '';
  String get versionName => _packageInfo?.version ?? '';

  Future<AppInfo> init() async {
    _packageInfo = await PackageInfo.fromPlatform();
    log('APPLICATION_ID: ${_packageInfo!.packageName}');
    log('APP_NAME: ${_packageInfo!.appName}');
    log('VERSION_NAME: ${_packageInfo!.version}');
    log('VERSION_CODE: ${_packageInfo!.buildNumber}');
    return this;
  }
}
