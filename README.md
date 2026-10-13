# XUNA mobile

Flutter companion base for XUNA. The owner confirmed retaining the imported Clean architecture and GetX base for future development on 2026-10-11.

## Structure

- `lib/core/data`: shared local storage, network adapters and response models.
- `lib/core/domain`: shared entities, repository and use-case contracts.
- `lib/core/presentation`: base controllers, bindings, navigation and widgets.
- `lib/features`: feature-specific data/domain/presentation: `device` (BLE transport, protocol, simulator), `conversation` (local text intents), `home` (MVP screen) and `splash`.
- `lib/shared`: reusable constants, themes, mapper base, exceptions and utilities.
- `lib/routes`: splash/home routes. Home provides local MVP interaction through physical BLE or explicitly selected simulator transport.

The imported login/product-detail examples, province models/mappers, old backend endpoint and business-specific locale/constants were removed. Generic base classes, packages, UI assets and generator tooling remain. Network clients require an explicit `baseUrl` and are not registered on startup; the legacy response envelope is retained as base compatibility, not an approved XUNA backend protocol. Bearer-token helpers remain dormant infrastructure, without a login flow.

## Development

Coding rules for agents and engineers: [AGENTS.md](AGENTS.md) (read before writing code) and the feature skeleton in [docs/FEATURE_TEMPLATE.md](docs/FEATURE_TEMPLATE.md).

Flutter is pinned to 3.32.8 through fvm (`.fvmrc`, decision D14):

```sh
fvm flutter pub get     # pubspec.lock must stay unchanged
fvm flutter analyze
fvm flutter test
fvm flutter run
```

Package: `xuna_mobile`. Android `com.example.xuna_mobile` and iOS `com.example.xunaMobile` are development placeholders; production IDs/signing remain undecided. App labels are XUNA. Original dependency constraints are retained; `pubspec.lock` was resolved with Flutter 3.32.8 / Dart 3.8.1. The empty login test was removed; add meaningful feature/base tests when behavior requires them.

Generated files/cache are ignored. Asset-generator and localization instructions remain in README_image.md and README_locales.md. Preserve generator and third-party provenance notices; they are not XUNA product branding.

Follow root AGENTS.md, PROCESS.md and PLAN.md. This scoped base cleanup does not implement M02 or change device-state ownership decisions.

## Local MVP through M05

Default HomeBinding wires `DeviceRepositoryImpl` to `DeviceBleDataSourceImpl` (FlutterBluePlus 1.35.5). Physical transport targets the XUNA MVP service: capabilities, correlated commands/status, life summary and two bounded memory pages. The explicit simulator, `SimulatorDeviceBleDataSource`, is an in-memory fake transport, always identified in the UI, with the same small preference rule. It never validates board persistence or BLE.

```sh
flutter analyze
flutter test --reporter expanded
LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 flutter run -d <simulator-id> --dart-define=XUNA_SIMULATOR=true
LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 flutter run -d <real-iphone-id>
```

Connect, request four animations, choose quiet/play, give explicit feedback, inspect learned preference/recent episodes, or forget memory/preference after confirmation. Text V1 recognizes chơi/yên tĩnh/thích/không thích (short aliases in `parse_text_intent_use_case.dart`); preference feedback requires confirmation. No LLM/backend, no raw text retention. Board owns durable MVP state; simulator data is session-only. Keep Clean/GetX core/shared and existing dependency baseline.

2026-10-13 Clean Architecture refactor (no protocol change): `fvm flutter analyze` clean and 16 protocol/data/domain/controller/widget tests PASS on Flutter 3.32.8 / Windows; no native build or device run after the refactor. Earlier MVP evidence: 10 tests and iPhone13/iOS16.2 simulator debug build/run PASS on Flutter3.32.8/Dart3.8.1/Xcode14.2. Native iOS Bluetooth adapter compiles; physical phone/signing/permissions and Android native validation remain pending. iOS usage description is present. Preserve BSD-style notices for pinned FlutterBluePlus and all resolved subpackages; newer major versions may use different terms.

Parent docs/roadmap/MVP-local.md owns scope, protocol and physical checklist. The previous 24026b2 simulator checkpoint is committed/pushed; subsequent MVP changes are uncommitted until delivery is requested.
