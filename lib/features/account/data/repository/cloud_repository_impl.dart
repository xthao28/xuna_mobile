import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'package:xuna_mobile/core/domain/repository/base_repository.dart';
import 'package:xuna_mobile/features/account/data/data_source/cloud_remote_data_source.dart';
import 'package:xuna_mobile/features/account/data/mapper/cloud_challenge_mapper.dart';
import 'package:xuna_mobile/features/account/data/mapper/cloud_pet_mapper.dart';
import 'package:xuna_mobile/features/account/data/mapper/consent_mapper.dart';
import 'package:xuna_mobile/features/account/data/model/cloud_challenge_model.dart';
import 'package:xuna_mobile/features/account/data/model/cloud_pet_model.dart';
import 'package:xuna_mobile/features/account/data/model/consent_model.dart';
import 'package:xuna_mobile/features/account/domain/entity/cloud_challenge.dart';
import 'package:xuna_mobile/features/account/domain/entity/cloud_pet.dart';
import 'package:xuna_mobile/features/account/domain/entity/cloud_profile.dart';
import 'package:xuna_mobile/features/account/domain/entity/consent_settings.dart';
import 'package:xuna_mobile/features/account/domain/exception/account_exception.dart';
import 'package:xuna_mobile/features/account/domain/repository/account_repository.dart';
import 'package:xuna_mobile/features/account/domain/repository/cloud_repository.dart';
import 'package:xuna_mobile/features/device/domain/entity/device_bind_proof.dart';
import 'package:xuna_mobile/features/device/domain/entity/pet_identity.dart';

class CloudRepositoryImpl extends BaseRepository implements CloudRepository {
  CloudRepositoryImpl(
    this._remote,
    this._accounts, {
    String Function()? newIdempotencyKey,
  }) : _newKey = newIdempotencyKey ?? const Uuid().v4;

  static const _schemaVersion = 1;

  final CloudRemoteDataSource _remote;
  final AccountRepository _accounts;
  final String Function() _newKey;
  final _petMapper = CloudPetMapper();
  final _challengeMapper = CloudChallengeMapper();
  final _consentMapper = ConsentMapper();

  @override
  Future<CloudProfile> fetchProfile() => _call((token) async {
        final json = await _remote.getMe(token);
        final userId = json['userId'];
        if (userId is! String || userId.isEmpty) {
          throw const FormatException('userId');
        }
        return CloudProfile(userId: userId);
      });

  @override
  Future<CloudChallenge> createChallenge(String petId) =>
      _call((token) async => _challengeMapper.mapToEntity(
            CloudChallengeModel.fromJson(await _remote.postChallenge(
              token,
              idempotencyKey: _newKey(),
              body: {'schemaVersion': _schemaVersion, 'petId': petId},
            )),
          ));

  @override
  Future<CloudPet> bindPet({
    required PetIdentity identity,
    required CloudChallenge challenge,
    required DeviceBindProof proof,
  }) =>
      _call((token) async => _petMapper.mapToEntity(
            CloudPetModel.fromJson(await _remote.postPet(
              token,
              idempotencyKey: _newKey(),
              body: {
                'schemaVersion': _schemaVersion,
                'petId': identity.petId,
                'origin': _origin(identity.origin),
                // The generation the device signed, not the earlier read.
                'snapshotGeneration': proof.generation,
                'deviceProof': {
                  'challengeId': challenge.challengeId,
                  'publicKey': base64.encode(proof.publicKey),
                  'signature': base64.encode(proof.signature),
                },
              },
            )),
          ));

  @override
  Future<List<CloudPet>> listPets() => _call((token) async {
        final items = (await _remote.getPets(token))['items'];
        if (items is! List) throw const FormatException('items');
        return [
          for (final item in items)
            _petMapper.mapToEntity(
              CloudPetModel.fromJson(Map<String, dynamic>.from(item as Map)),
            ),
        ];
      });

  @override
  Future<ConsentSettings> readConsents() =>
      _call((token) async => _consentMapper.mapToEntity(
          ConsentModel.fromJson(await _remote.getConsents(token))));

  @override
  Future<ConsentSettings> updateConsents(ConsentSettings desired) =>
      _call((token) async => _consentMapper.mapToEntity(
            ConsentModel.fromJson(await _remote.putConsents(
              token,
              idempotencyKey: _newKey(),
              body: _consentMapper.mapToData(desired).toUpdateJson(),
            )),
          ));

  @override
  Stream<String> streamReply({
    required String petId,
    required String text,
  }) async* {
    try {
      final token = await _token();
      final events = _remote.postTurn(
        token,
        petId: petId,
        body: {'schemaVersion': _schemaVersion, 'text': text, 'locale': 'vi'},
      );
      await for (final event in events) {
        switch (event.event) {
          case 'delta':
            final delta = _object(event.data)['text'];
            if (delta is! String) throw const FormatException('delta');
            yield delta;
          case 'finished':
            return;
          case 'error':
            throw AccountException(_problemKind(_object(event.data)['code']) ??
                AccountExceptionKind.providerUnavailable);
          default:
            continue; // toolCall and future additive events are ignored.
        }
      }
      // The stream must end with `finished` or `error`.
      throw const AccountException(AccountExceptionKind.cloudUnavailable);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(translate(error), stackTrace);
    }
  }

  Future<String> _token() async {
    if (!_remote.configured) {
      throw const AccountException(AccountExceptionKind.cloudNotConfigured);
    }
    return _accounts.idToken();
  }

  Future<T> _call<T>(Future<T> Function(String token) action) async {
    try {
      return await action(await _token());
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(translate(error), stackTrace);
    }
  }

  static Map<String, dynamic> _object(String data) {
    final value = jsonDecode(data);
    if (value is! Map<String, dynamic>) throw const FormatException('event');
    return value;
  }

  static String _origin(PetOrigin origin) => switch (origin) {
        PetOrigin.hatchedOnDevice => 'hatched_on_device',
        PetOrigin.hatchedViaApp => 'hatched_via_app',
        PetOrigin.migratedFromV1 => 'migrated_from_v1',
      };

  /// Stable backend problem `code`s (contract draft §1).
  static AccountExceptionKind? _problemKind(Object? code) => switch (code) {
        'unauthorized' => AccountExceptionKind.cloudRejected,
        'challenge_invalid' => AccountExceptionKind.challengeInvalid,
        'invalid_signature' ||
        'invalid_public_key' =>
          AccountExceptionKind.invalidSignature,
        'pet_already_bound' => AccountExceptionKind.petAlreadyBound,
        'device_key_mismatch' => AccountExceptionKind.deviceKeyMismatch,
        'not_found' => AccountExceptionKind.petNotFound,
        'consent_required' => AccountExceptionKind.consentRequired,
        'consent_version_conflict' =>
          AccountExceptionKind.consentVersionConflict,
        'provider_unavailable' => AccountExceptionKind.providerUnavailable,
        _ => null,
      };

  static AccountException translate(Object error) {
    if (error is AccountException) return error;
    if (error is DioException) {
      final response = error.response;
      final data = response?.data;
      final kind = _problemKind(data is Map ? data['code'] : null) ??
          switch (response?.statusCode) {
            401 || 403 => AccountExceptionKind.cloudRejected,
            _ => AccountExceptionKind.cloudUnavailable,
          };
      return AccountException(kind, rootException: error);
    }
    return AccountException(AccountExceptionKind.cloudUnavailable,
        rootException: error);
  }
}
