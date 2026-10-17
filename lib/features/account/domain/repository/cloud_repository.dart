import 'package:xuna_mobile/features/account/domain/entity/cloud_profile.dart';

/// XUNA Cloud backend. Throws [AccountException] (`cloud*`, `notSignedIn`).
abstract interface class CloudRepository {
  Future<CloudProfile> fetchProfile();
}
