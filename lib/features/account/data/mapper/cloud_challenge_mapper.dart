import 'package:xuna_mobile/features/account/data/model/cloud_challenge_model.dart';
import 'package:xuna_mobile/features/account/domain/entity/cloud_challenge.dart';
import 'package:xuna_mobile/shared/mappers/mappers_src.dart';

class CloudChallengeMapper
    extends BaseDataMapper<CloudChallengeModel, CloudChallenge> {
  @override
  CloudChallenge mapToEntity(CloudChallengeModel? data) {
    if (data == null) throw const FormatException('Missing challenge');
    return CloudChallenge(
      challengeId: data.challengeId,
      nonce: List.unmodifiable(data.nonce),
      expiresAt: data.expiresAt.toUtc(),
    );
  }
}
