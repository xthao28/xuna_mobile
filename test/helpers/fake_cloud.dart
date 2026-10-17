import 'dart:async';

import 'package:xuna_mobile/features/account/domain/domain.src.dart';
import 'package:xuna_mobile/features/device/domain/domain.src.dart';

/// Hand-written fake of the account and XUNA Cloud repositories. Records the
/// calls in order so tests can check the bind sequence.
class FakeCloud implements AccountRepository, CloudRepository {
  final _changes = StreamController<Account?>.broadcast();
  final calls = <String>[];
  AccountException? signInError;
  AccountException? cloudError;
  AccountException? bindError;
  AccountException? consentError;
  int cloudCalls = 0;

  final pets = <CloudPet>[];
  ConsentSettings consents = const ConsentSettings();

  /// Deltas for the next reply; [replyError] ends the stream instead.
  List<String> replyDeltas = const ['Chào ', 'bạn!'];
  AccountException? replyError;
  final repliedTexts = <String>[];

  static final challenge = CloudChallenge(
    challengeId: '00000000-0000-4000-8000-000000000001',
    nonce: List.generate(32, (i) => i),
    expiresAt: DateTime.utc(2026, 10, 17, 12, 5),
  );

  @override
  Stream<Account?> watchAccount() => _changes.stream;

  @override
  Future<Account> signInWithGoogle() async {
    final error = signInError;
    if (error != null) throw error;
    const account = Account(uid: 'u1', email: 'owner@example.com');
    _changes.add(account);
    return account;
  }

  @override
  Future<void> signOut() async => _changes.add(null);

  @override
  Future<String> idToken() async => 'token';

  @override
  Future<CloudProfile> fetchProfile() async {
    cloudCalls++;
    final error = cloudError;
    if (error != null) throw error;
    return const CloudProfile(userId: 'xuna-user');
  }

  @override
  Future<CloudChallenge> createChallenge(String petId) async {
    calls.add('challenge:$petId');
    final error = cloudError;
    if (error != null) throw error;
    return challenge;
  }

  @override
  Future<CloudPet> bindPet({
    required PetIdentity identity,
    required CloudChallenge challenge,
    required DeviceBindProof proof,
  }) async {
    calls.add('bind:${identity.petId}:${proof.generation}');
    final error = bindError;
    if (error != null) throw error;
    final pet = CloudPet(
      petId: identity.petId,
      brainId: 'brain-1',
      deviceId: 'device-1',
      lastGeneration: proof.generation,
      boundAt: DateTime.utc(2026, 10, 17),
    );
    pets.add(pet);
    return pet;
  }

  @override
  Future<List<CloudPet>> listPets() async {
    calls.add('pets');
    return List.of(pets);
  }

  @override
  Future<ConsentSettings> readConsents() async {
    calls.add('consents');
    return consents;
  }

  @override
  Future<ConsentSettings> updateConsents(ConsentSettings desired) async {
    calls.add('updateConsents:${desired.version}');
    final error = consentError;
    if (error != null) throw error;
    consents = ConsentSettings(
      aggregateMetrics: desired.aggregateMetrics,
      experienceEvents: desired.experienceEvents,
      conversationText: desired.conversationText,
      version: desired.version + 1,
    );
    return consents;
  }

  @override
  Stream<String> streamReply({
    required String petId,
    required String text,
  }) async* {
    repliedTexts.add(text);
    for (final delta in replyDeltas) {
      yield delta;
    }
    final error = replyError;
    if (error != null) throw error;
  }
}
