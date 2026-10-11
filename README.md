# XUNA mobile

Flutter companion base for XUNA. The owner confirmed retaining the imported Clean architecture and GetX base for future development on 2026-10-11.

## Structure

- `lib/core/data`: shared local storage, network adapters and response models.
- `lib/core/domain`: shared entities, repository and use-case contracts.
- `lib/core/presentation`: base controllers, bindings, navigation and widgets.
- `lib/features`: feature-specific data/domain/presentation; currently splash and home only.
- `lib/shared`: reusable constants, themes, mapper base, exceptions and utilities.
- `lib/routes`: splash/home routes. Home provides the M02 simulator interaction flow through a fake device repository; physical BLE is not implemented.

The imported login/product-detail examples, province models/mappers, old backend endpoint and business-specific locale/constants were removed. Generic base classes, packages, UI assets and generator tooling remain. Network clients require an explicit `baseUrl` and are not registered on startup; the legacy response envelope is retained as base compatibility, not an approved XUNA backend protocol. Bearer-token helpers remain dormant infrastructure, without a login flow.

## Development

```sh
flutter pub get
flutter analyze
flutter run
```

Package: `xuna_mobile`. Android `com.example.xuna_mobile` and iOS `com.example.xunaMobile` are development placeholders; production IDs/signing remain undecided. App labels are XUNA. Original dependency constraints are retained; `pubspec.lock` was resolved with Flutter 3.32.8 / Dart 3.8.1. The empty login test was removed; add meaningful feature/base tests when behavior requires them.

Generated files/cache are ignored. Asset-generator and localization instructions remain in README_image.md and README_locales.md. Preserve generator and third-party provenance notices; they are not XUNA product branding.

Follow root AGENTS.md, PROCESS.md and PLAN.md. This scoped base cleanup does not implement M02 or change device-state ownership decisions.

## M02 simulator slice

This checkpoint intentionally binds `SimulatorDeviceRepository` in `HomeBinding`. The screen always displays **SIMULATOR · FAKE BLE**; even on a real phone it does not scan/connect a board. Scan, connect, Idle/Happy, 2400 ms happy expiry and disconnect/reconnect run locally. Domain repository/use-case contracts remain separate from the data fake and GetX presentation. The original core/shared base and dependencies remain intact.

`ProtocolCodec` implements the approved v1 command wire layout and validates status values. Full capabilities negotiation, result correlation, deduplication, real BLE errors/timeouts and plugin transport remain subsequent M02 work; this fake is not evidence that those behaviors work over BLE. No BLE plugin is added at this simulator-only checkpoint.

```sh
flutter analyze
flutter test --reporter expanded
LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 flutter build ios --simulator --debug
flutter run -d <simulator-id>
```

Verified on 2026-10-11 with Flutter 3.32.8 / Dart 3.8.1 and Xcode 14.2: analyzer PASS; 4 protocol/domain/widget tests PASS; iOS simulator debug build PASS; `flutter run` opened Home on iPhone 13/iOS 16.2 and its screenshot was inspected. Interaction flow was exercised by widget tests, not automated native taps. CocoaPods required the UTF-8 locale shown above. Physical validation needs a real iPhone/iPad and BLE firmware. Android native build is unverified.
