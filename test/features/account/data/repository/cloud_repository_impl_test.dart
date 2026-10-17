import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xuna_mobile/features/account/data/data_source/cloud_remote_data_source.dart';
import 'package:xuna_mobile/features/account/data/model/sse_event_model.dart';
import 'package:xuna_mobile/features/account/data/repository/cloud_repository_impl.dart';
import 'package:xuna_mobile/features/account/domain/domain.src.dart';
import 'package:xuna_mobile/features/device/domain/domain.src.dart';

import '../../../../helpers/fake_cloud.dart';

const _petId = 'd945c77026fd4f4a8a899bbff4aeed86';

Map<String, dynamic> _pet() => {
      'petId': _petId,
      'brainId': '11111111-1111-4111-8111-111111111111',
      'deviceId': '22222222-2222-4222-8222-222222222222',
      'origin': 'migrated_from_v1',
      'lastGeneration': 39,
      'boundAt': '2026-10-17T05:00:00+00:00',
    };

class _Remote extends Fake implements CloudRemoteDataSource {
  @override
  bool configured = true;
  Object? error;
  final requests = <(String, String?, Map<String, dynamic>?)>[];
  Map<String, dynamic> challenge = {
    'challengeId': '00000000-0000-4000-8000-000000000001',
    'nonce': 'AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8=',
    'expiresAt': '2026-10-17T05:05:00+00:00',
  };
  Map<String, dynamic> consents = {
    'aggregateMetrics': false,
    'experienceEvents': false,
    'conversationText': true,
    'version': 3,
    'updatedAt': null,
  };
  List<SseEventModel> events = const [
    SseEventModel(event: 'delta', data: '{"text": "Chào "}'),
    SseEventModel(event: 'toolCall', data: '{"name": "x"}'),
    SseEventModel(event: 'delta', data: '{"text": "bạn"}'),
    SseEventModel(event: 'finished', data: '{"latencyMs": 9}'),
  ];

  Future<Map<String, dynamic>> _answer(String name, String? key,
      Map<String, dynamic>? body, Map<String, dynamic> response) async {
    requests.add((name, key, body));
    final failure = error;
    if (failure != null) throw failure;
    return response;
  }

  @override
  Future<Map<String, dynamic>> postChallenge(String idToken,
          {required String idempotencyKey,
          required Map<String, dynamic> body}) =>
      _answer('challenge', idempotencyKey, body, challenge);

  @override
  Future<Map<String, dynamic>> postPet(String idToken,
          {required String idempotencyKey,
          required Map<String, dynamic> body}) =>
      _answer('pet', idempotencyKey, body, _pet());

  @override
  Future<Map<String, dynamic>> getPets(String idToken) =>
      _answer('pets', null, null, {
        'items': [_pet()]
      });

  @override
  Future<Map<String, dynamic>> getConsents(String idToken) =>
      _answer('consents', null, null, consents);

  @override
  Future<Map<String, dynamic>> putConsents(String idToken,
          {required String idempotencyKey,
          required Map<String, dynamic> body}) =>
      _answer('putConsents', idempotencyKey, body, consents);

  @override
  Stream<SseEventModel> postTurn(String idToken,
      {required String petId, required Map<String, dynamic> body}) async* {
    requests.add(('turn:$petId', null, body));
    final failure = error;
    if (failure != null) throw failure;
    yield* Stream.fromIterable(events);
  }
}

DioException _problem(int status, String code) => DioException(
      requestOptions: RequestOptions(path: '/v1'),
      response: Response(
        requestOptions: RequestOptions(path: '/v1'),
        statusCode: status,
        data: {'type': 'x', 'status': status, 'code': code},
      ),
    );

Matcher _kind(AccountExceptionKind kind) =>
    throwsA(isA<AccountException>().having((e) => e.kind, 'kind', kind));

void main() {
  late _Remote remote;
  late CloudRepositoryImpl repository;
  var keys = 0;

  setUp(() {
    remote = _Remote();
    repository = CloudRepositoryImpl(remote, FakeCloud(),
        newIdempotencyKey: () => 'key-${++keys}');
  });

  test('bind sends the challenge, signed generation and base64 proof',
      () async {
    final challenge = await repository.createChallenge(_petId);
    expect(challenge.nonce, List.generate(32, (i) => i));
    final pet = await repository.bindPet(
      identity: const PetIdentity(
        petId: _petId,
        origin: PetOrigin.migratedFromV1,
        snapshotGeneration: 38,
      ),
      challenge: challenge,
      proof: DeviceBindProof(
        generation: 39,
        publicKey: [4, ...List.filled(64, 1)],
        signature: List.filled(64, 2),
      ),
    );
    expect(pet.lastGeneration, 39);
    expect(pet.boundAt, DateTime.utc(2026, 10, 17, 5));
    final (_, challengeKey, challengeBody) = remote.requests[0];
    final (_, petKey, petBody) = remote.requests[1];
    expect(challengeBody, {'schemaVersion': 1, 'petId': _petId});
    expect(challengeKey, isNot(petKey));
    expect(petBody!['schemaVersion'], 1);
    expect(petBody['origin'], 'migrated_from_v1');
    expect(petBody['snapshotGeneration'], 39);
    final proof = petBody['deviceProof'] as Map<String, dynamic>;
    expect(proof['challengeId'], challenge.challengeId);
    expect(proof['publicKey'], startsWith('BAEB'));
    expect(proof['signature'], hasLength(88));
  });

  test('consents round trip with expectedVersion', () async {
    final current = await repository.readConsents();
    expect(current.conversationText, isTrue);
    expect(current.version, 3);
    await repository.updateConsents(current.copyWith(aggregateMetrics: true));
    final (_, key, body) = remote.requests.last;
    expect(key, isNotNull);
    expect(body, {
      'schemaVersion': 1,
      'aggregateMetrics': true,
      'experienceEvents': false,
      'conversationText': true,
      'expectedVersion': 3,
    });
    expect((await repository.listPets()).single.petId, _petId);
  });

  test('backend problem codes become account kinds', () async {
    final cases = {
      _problem(409, 'challenge_invalid'): AccountExceptionKind.challengeInvalid,
      _problem(403, 'invalid_signature'): AccountExceptionKind.invalidSignature,
      _problem(422, 'invalid_public_key'):
          AccountExceptionKind.invalidSignature,
      _problem(409, 'pet_already_bound'): AccountExceptionKind.petAlreadyBound,
      _problem(409, 'device_key_mismatch'):
          AccountExceptionKind.deviceKeyMismatch,
      _problem(409, 'consent_version_conflict'):
          AccountExceptionKind.consentVersionConflict,
      _problem(403, 'consent_required'): AccountExceptionKind.consentRequired,
      _problem(401, 'unauthorized'): AccountExceptionKind.cloudRejected,
      _problem(404, 'not_found'): AccountExceptionKind.petNotFound,
      _problem(503, 'database_unavailable'):
          AccountExceptionKind.cloudUnavailable,
      _problem(403, 'something_new'): AccountExceptionKind.cloudRejected,
      TimeoutException('slow'): AccountExceptionKind.cloudUnavailable,
    };
    for (final MapEntry(key: error, value: kind) in cases.entries) {
      remote.error = error;
      await expectLater(repository.createChallenge(_petId), _kind(kind),
          reason: '$error');
    }
  });

  test('malformed responses and missing configuration are translated',
      () async {
    remote.challenge = {...remote.challenge, 'nonce': 'AAEC'};
    await expectLater(repository.createChallenge(_petId),
        _kind(AccountExceptionKind.cloudUnavailable));
    remote.configured = false;
    await expectLater(repository.readConsents(),
        _kind(AccountExceptionKind.cloudNotConfigured));
    expect(remote.requests, hasLength(1));
  });

  test('a reply streams only delta text and stops at finished', () async {
    final deltas =
        await repository.streamReply(petId: _petId, text: 'chào').toList();
    expect(deltas, ['Chào ', 'bạn']);
    final (path, _, body) = remote.requests.single;
    expect(path, 'turn:$_petId');
    expect(body, {'schemaVersion': 1, 'text': 'chào', 'locale': 'vi'});
  });

  test('a reply error event or an early end fails the stream', () async {
    remote.events = const [
      SseEventModel(event: 'delta', data: '{"text": "Ch"}'),
      SseEventModel(event: 'error', data: '{"code": "provider_unavailable"}'),
    ];
    await expectLater(repository.streamReply(petId: _petId, text: 'x').toList(),
        _kind(AccountExceptionKind.providerUnavailable));
    remote.events = const [SseEventModel(event: 'delta', data: '{"t": 1}')];
    await expectLater(repository.streamReply(petId: _petId, text: 'x').toList(),
        _kind(AccountExceptionKind.cloudUnavailable));
    remote.events = const [];
    await expectLater(repository.streamReply(petId: _petId, text: 'x').toList(),
        _kind(AccountExceptionKind.cloudUnavailable));
    remote.error = _problem(403, 'consent_required');
    await expectLater(repository.streamReply(petId: _petId, text: 'x').toList(),
        _kind(AccountExceptionKind.consentRequired));
  });
}
