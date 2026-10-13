# XUNA mobile — coding rules

> **Mandatory before writing or changing any code in this repository.** Applies to every coding agent (Claude Code, Codex, Cursor, Copilot) and engineer.
>
> - Product intent, approved decisions and session scope: the parent repository's [AGENTS.md](../AGENTS.md) (canonical), then [PROCESS.md](../PROCESS.md) and the session entry in [XUNA_SESSION_PLAN.md](../docs/roadmap/XUNA_SESSION_PLAN.md). Relative links assume the `xuna_pet` superproject checkout.
> - How mobile code is written: **this file**. Skeleton for new files: [docs/FEATURE_TEMPLATE.md](docs/FEATURE_TEMPLATE.md).
> - If a request conflicts with either, stop and ask the owner. Changing these rules requires owner approval.
>
> Status: owner-requested 2026-10-13. Architecture: **Clean Architecture, feature-first, built on the owner-confirmed GetX base** (2026-10-11). Keep `lib/core` and `lib/shared`; build features on top of them.

## 0. Workflow when asked to write a feature

1. Read the documents above, this file and [docs/FEATURE_TEMPLATE.md](docs/FEATURE_TEMPLATE.md).
2. Confirm the feature belongs to the requested session/milestone. Do not build later sessions speculatively.
3. Inspect the code you will touch, the existing features (`lib/features/**`, `test/**`) and the base widgets in `lib/shared/widgets/` (§5.4). Reuse; do not duplicate.
4. Before coding, tell the owner in Vietnamese: purpose, scope, layers/files affected, whether a board or phone is needed (parent AGENTS §10).
5. Design top-down (screen → use cases → contracts), implement bottom-up: **domain → data → presentation → binding/route → locales → tests**.
6. Run the checks in §10 and walk through the Definition of Done (§12).
7. Report in Vietnamese: files changed, commands and results, what was **not** run, risks, next step. Update README/handoff docs when behavior or commands change. Commit only when asked.

## 1. Layers and the dependency rule

```text
 presentation ───────▶ domain ◀─────── data
 (controller, page)    (entity,       (data source, model,
                        contract,      mapper, repository impl)
                        use case)
        binding = composition root: the only place that sees all three
```

- Dependencies point **inward to domain**. Domain knows nothing about data, presentation, Flutter, GetX or plugins.
- Data implements domain contracts and returns domain entities. Presentation calls domain use cases.
- Presentation never imports `data/`; data never imports `presentation/`. Exceptions: route bindings, `AppBinding` and `routes/app_pages.dart` (composition roots).

| Code in | May import | Must not import |
| --- | --- | --- |
| `features/*/domain/**` | `dart:*`, `package:equatable`, `core/domain/usecase/**`, `core/domain/entity/**`, `shared/exceptions/base/app_exception.dart`, other features' `domain/` | `package:flutter/*`, `get`, `dio`, `hive`, `flutter_blue_plus`, any plugin, `core/domain/repository/base_repository.dart` (pulls in dio/GetX), any `data/` or `presentation/` |
| `features/*/data/**` | own and other features' `domain/`, `core/data/**`, `core/domain/**` (including `BaseRepository`), `shared/{exceptions,mappers,utils}`, `shared/constants/const.dart`, platform packages | any `presentation/`, `LocaleKeys`, `.tr`, widgets, `sl()`/`Get.find` |
| `features/*/presentation/**` | any feature's `domain/`, capability features' `presentation/{extension,widgets}/`, `core/presentation/**`, `shared/**`, `generated/locales.g.dart`, `assets.dart`, `routes/`, Flutter, GetX | any `data/` (bindings excepted) |
| `core/**`, `shared/**` | each other, packages | `features/**` (composition roots excepted) |

- Cross-feature imports: another feature's `domain/`, plus a capability feature's `presentation/extension/` and `presentation/widgets/` (its UI vocabulary, such as enum labels and exception messages). Never its `data/`, controllers, bindings or pages. No import cycles between features. Truly shared, business-free code goes to `shared/`.
- Service location (`sl()`, `slf()`, `Get.find`) only in bindings and in the existing base classes. Everything else receives dependencies through its constructor.

## 2. Folder layout and naming

```text
lib/
├── core/        # base framework (keep): base controller/bindings/pages, AppNavigator, AppHive, RestApiClient, UseCase, BaseRepository
├── shared/      # business-free reusables: constants, themes, exceptions, mappers, utils, widgets
├── routes/      # AppRoutes enum + AppPages
├── generated/   # generated locales (see §5.5)
├── assets.dart  # generated asset constants
└── features/<feature>/
    ├── domain/
    │   ├── entity/<name>.dart
    │   ├── repository/<feature>_repository.dart
    │   ├── usecase/<verb>_<noun>_use_case.dart
    │   └── exception/<feature>_exception.dart
    ├── data/
    │   ├── codec/<protocol>_codec.dart            (binary protocols only)
    │   ├── data_source/<feature>_<ble|local|remote>_data_source.dart
    │   ├── model/<name>_model.dart
    │   ├── mapper/<name>_mapper.dart
    │   └── repository/<feature>_repository_impl.dart
    └── presentation/
        ├── binding/<screen>_binding.dart
        ├── controller/<screen>_controller.dart
        ├── extension/<feature>_exception_message.dart
        ├── widgets/<widget>.dart
        └── <screen>_page.dart
```

- Create only the folders a feature needs (parent AGENTS: no empty skeleton). A pure rule feature may be `domain/` only; a screen that composes other features (like `home`) may be `presentation/` only.
- Capability features (`device`, `conversation`, `memory`) own business logic. Screen features compose capability use cases and hold no business rules.
- One public top-level type per file. A file may also hold that type's own small enum or a `typedef` for its input, and a short data source contract may share a file with its only implementation.

| Kind | Class | File |
| --- | --- | --- |
| Entity | `LifeSummary` (no suffix) | `life_summary.dart` |
| Repository contract | `DeviceRepository` | `device_repository.dart` |
| Repository implementation | `DeviceRepositoryImpl` (`Impl` suffix, as `AppHiveImpl`, `AppNavigatorImpl`) | `device_repository_impl.dart` |
| Data source | `DeviceBleDataSource` + `DeviceBleDataSourceImpl`; kinds `Ble`, `Local`, `Remote` | `device_ble_data_source.dart` |
| Model (DTO / wire / stored shape) | `LifeSummaryModel` | `life_summary_model.dart` |
| Mapper | `LifeSummaryMapper` | `life_summary_mapper.dart` |
| Use case | `ReadLifeSummaryUseCase` (verb + noun + `UseCase`); streams: `Watch…UseCase` | `read_life_summary_use_case.dart` |
| Exception | `DeviceException` + `DeviceExceptionKind` | `device_exception.dart` |
| Controller / binding / page | `HomeController` / `HomeBinding` / `HomePage` | `home_controller.dart`, `home_binding.dart`, `home_page.dart` |
| Route | `AppRoutes.journal` (lowerCamel enum value) | `routes/app_routes.dart` |
| Locale key | `LocaleKeys.<feature>_<camelKey>` from JSON section `<feature>` | `assets/locales/vi_VN.json` |

## 3. Domain layer

### 3.1 Entities

- Pure Dart and immutable: `final` fields, `const` constructor, named parameters when there are more than two fields.
- Value equality with `Equatable` (`props`). Add `copyWith` only when used.
- No `fromJson`/`toJson`, no byte parsing, no Flutter types (`Color`, `IconData`), no localized text.
- Closed sets are enums. An enum's `index` is **not** a wire or storage format.

### 3.2 Repository contracts

- `abstract interface class XxxRepository` in `domain/repository/`.
- Signatures use only domain types: entities, enums, primitives, `Future`, `Stream`. Never `Uint8List` frames, models, `BluetoothDevice`, Dio `Response`, Hive types.
- Contracts do **not** extend `BaseRepository`; implementations in `data/` do.
- A `///` comment states which `XxxException` kinds the methods can throw.

### 3.3 Use cases

- One class per user or business action, extending `UseCase<Input, Output>` or `NoInputUseCase<Output>` from `core/domain/usecase/base_use_case.dart`.
- `const` constructor; repository contracts injected as private `final` fields.
- Several inputs: a named-record `typedef` in the same file, e.g. `typedef SendFeedbackInput = ({bool approved, FeedbackSource source});`.
- Streams: `NoInputUseCase<Stream<T>>` named `Watch<Noun>UseCase`.
- Transport-independent rules and input validation live here, not in controllers. They pre-validate for UX only; the device stays authoritative and re-validates (§6).
- A use case that only forwards to the repository is normal: it keeps controllers independent of repositories.

### 3.4 Domain exceptions

- Failures the UI must distinguish: `class XxxException extends AppException` with a `kind` enum and `AppExceptionType.custom`. No message text in domain.
- Do not add values to `AppExceptionType` without updating the exhaustive switch in `ExceptionHandler` in the same change.

## 4. Data layer

### 4.1 Data sources

- A thin wrapper over exactly one I/O mechanism: BLE (`flutter_blue_plus`), local storage (`AppHive`), or HTTP (`RestApiClient`). Abstract contract plus `Impl`, so tests and the simulator can replace it.
- Return models or raw values, never entities. No business decisions, no UI text.
- A data source may throw the feature exception for protocol conditions it detects itself (not connected, request rejected, busy); the repository translates every other error (§4.3).
- Every I/O call has an explicit timeout.
- The simulator is a **fake transport**: it implements a data source contract, not the repository (implementation plan §5.4).

### 4.2 Models, codecs and mappers

- Models mirror the external shape (JSON, stored map, BLE frame), with `fromJson`/`toJson` or `decode`/`encode`.
- Validate every inbound field (length, version, enum range, required key, type) and throw `FormatException` on violation. Validate outbound arguments before encoding.
- Binary protocol codecs live in `data/`, are pure Dart and are unit tested with byte fixtures, including malformed input.
- Mappers extend `BaseDataMapper<Model, Entity>` (add `DataMapperMixin` or use `BaseEntityMapper` for the reverse direction).
- Map enums to wire/storage values with an explicit `switch`, never `enum.index` or `Enum.values[i]`: reordering an enum must not silently change the protocol or stored data.

### 4.3 Repository implementations

- `class XxxRepositoryImpl extends BaseRepository implements XxxRepository`; data sources and mappers injected through the constructor.
- Orchestrates data sources, maps models to entities, and translates **every** platform or transport error (`FlutterBluePlusException`, `TimeoutException`, `FormatException`, `RemoteException`, storage errors) into the feature's `AppException` subclass. Nothing platform-specific escapes.
- Owns session state when needed (BLE connection epoch, in-flight request); cancels subscriptions and closes `StreamController`s in `onClose`.
- Use `cancelToken` from `BaseRepository` for HTTP requests.

### 4.4 Local storage and network

- Local data goes through `AppHive` (or a feature data source wrapping it). Keys are constants with a schema version suffix (`'journal_entries_v1'`); stored values are versioned maps; migrate when the shape changes. Hive returns `Map<dynamic, dynamic>`: convert with `Map<String, dynamic>.from(...)` before `fromJson`.
- Never store raw conversation text, and never store pet-life state as truth on the phone (§6).
- `RestApiClient` and its subclasses exist but are not registered, and no backend is approved. Do not register or call network clients unless the session explicitly scopes a backend/cloud integration. No secrets or API keys in source, `--dart-define` defaults or committed `envied` files.

## 5. Presentation layer (GetX)

### 5.1 Controllers

- Extend `BaseGetxController`. Inject **use cases only** through the constructor; plain configuration values (such as the simulator flag) may also be passed in from the binding. No repositories, data sources or `sl()` inside controllers.
- State: `final xxx = <T>.obs`, `Rxn<T>()`, `<T>[].obs`. Only the controller mutates state; pages and widgets only read it.
- Every async action runs through `buildState(action: …, showLoading/showLoadingOverlay: …, onError: …)`. No hand-written try/catch wrappers, never show `e.toString()` to users.
  - `await` every async call inside `action`, otherwise `buildState` cannot catch the error.
  - `onError` handles the feature's exception (show a localized message, return `null`) and returns any other exception to the base handler.
  - Device commands must not overlap: return early while `isLoading`/`isLoadingOverlay` is true and disable the triggering buttons.
- Lifecycle: subscribe in `onInit`, start the first load in `onReady`, cancel subscriptions and timers in `onClose` (calling `super`). Do not dispose app-scoped dependencies (§5.6).
- Navigation, dialogs and snack bars only through `nav` (`AppNavigator`). No `BuildContext` in controllers.
- No Flutter UI types (`Color`, `IconData`, `Widget`) in controller state: expose domain state and let the page map it.

### 5.2 Pages, dialogs and widgets

- A screen with state extends `BaseGetPage<XxxController>`; a screen that can be stacked several times uses `BaseGetPageFactory` with `BaseBindingsFactory` and `nav.toNamedFactory`. Override `buildPage`, not `build`; override `hasAppBar => false` when there is no AppBar.
- Static screens without a controller may be a plain `StatelessWidget` (like `SplashPage`).
- A dialog or bottom sheet with its own controller extends `BaseGetBtsDialog` and is opened with `nav.showDialog`/`nav.showBottomSheet`. Simple confirmation/information: `nav.showConfirmDialog`/`nav.showInfoDialog`. Never call `showDialog`, `Navigator.*`, `Get.dialog`, `Get.to*` or `Get.back` directly.
- Pages lay out and bind only: read state inside the narrowest `Obx`, call controller methods on events. No business rules, no direct writes to `controller.xxx.value`.
- Loading: `baseShowLoading(() => …)` replaces the content while `isLoading` is true; for inline progress that keeps content visible, read `controller.isLoading` inside an `Obx`. `showLoadingOverlay` renders the base overlay automatically.
- Split a page above roughly 200 lines into widgets under `presentation/widgets/`. Widgets are dumb: data in through the constructor, callbacks out; they do not look up controllers. Prefer `const` constructors.

### 5.3 Styling and assets

- Colors from `AppColors`, text from `AppTextStyle.fontNN{Re,Semi,Bo,Ex}`, spacing and radius from `AppDimens`, loading indicator and spacers from `UtilWidget`. No raw `Color(0x…)`, `TextStyle(…)` or magic spacing numbers in pages; add the missing token to `shared/` instead.
- `AppTextStyle` styles set `overflow: TextOverflow.ellipsis`, which limits a `Text` to one line unless `maxLines` is set. Give multi-line text an explicit `maxLines`, as the base dialogs do.
- Assets go under `assets/`; regenerate `lib/assets.dart` and the pubspec asset section with `sds_agen -s -t d --const-array --rule uwu --package --no-watch` ([README_image.md](README_image.md)); reference `Assets.ASSETS_…`. Do not hand-edit generated sections.

### 5.4 Base widgets (shared UI components)

Base widgets are the app's shared UI components: buttons, cards, list rows, section headers, empty and error states, and similar. They live in `lib/shared/widgets/`, are exported from `widget_src.dart` and use the `App` prefix (`AppPrimaryButton`, `AppSectionCard`), like `AppColors` and `AppTextStyle`.

- **Must use when one exists.** Before building any UI, check `lib/shared/widgets/`. If a base widget covers the role, use it; screens must not rebuild that role from raw Flutter widgets or copied styling. If it almost fits, extend the base widget with a parameter instead of forking it.
- **Must create when UI repeats across screens.** When a UI pattern appears on a second screen, dialog or bottom sheet, extract it into a base widget in the same change and migrate the existing usage. Never copy widget trees or styling between screens. Repetition inside one feature only goes to that feature's `presentation/widgets/` (§5.2); promote it to a base widget as soon as another feature needs it.
- Base widgets are business-free: no controllers, use cases, feature entities, `LocaleKeys` or navigation. Text, data and callbacks come in through constructor parameters; styling comes only from tokens (`AppColors`, `AppTextStyle`, `AppDimens`).
- Write them as widget classes with `const` constructors, not new static builder functions in `UtilWidget`.
- Changing a base widget changes every screen: keep its API backward compatible or update every call site in the same change. Add a widget test when it has behavior (states, enabled/disabled, callbacks).
- **Current state (2026-10-13): there is no XUNA design yet, so no base widgets exist.** Until the design arrives, screens use Flutter Material widgets styled with tokens (button labels keep the Material button theme), and the extraction rule above already applies. `UtilWidget`'s button, card and dropdown builders carry the inherited palette of the imported base; they are not XUNA base widgets, so do not spread them into new screens. When the design is delivered, a dedicated session builds the base widget set from it and migrates existing screens.

### 5.5 User-facing text

- Every user-visible string comes from locales: add it to `assets/locales/vi_VN.json` under a section named after the feature, regenerate with `get generate locales assets/locales` ([README_locales.md](README_locales.md)), use `LocaleKeys.<feature>_<key>.tr`, or `.trParams({'count': '$n'})` with `@count` placeholders.
- If `get_cli` is unavailable, update `vi_VN.json` and `lib/generated/locales.g.dart` together with identical keys.
- No user-visible strings in domain or data. Log and exception debug messages may be English literals.
- Copy must be honest: do not call rule-based behavior "AI" or "learning" unless it is (parent AGENTS §6). Simulator mode is always labeled.

### 5.6 Bindings, dependency scopes and routes

- Every route has a binding extending `BaseBindings`: data sources and repositories (registered by contract type) in `bindingsRepository`, then `bindingsUseCase`, then `bindingsController`. Use `Get.lazyPut<Contract>(() => Impl(sl()))`.
- Scopes:
  - **Route** (default): registered in the route binding, disposed with the route.
  - **App**: a dependency that owns a long-lived resource used by several screens (BLE connection/device repository, Hive box, event bus) is registered once in `AppBinding` with `permanent: true`. Route bindings only `sl()` it; controllers never dispose it.
  - **Factory** (stackable screens and dialogs): `BaseBindingsFactory` with `Get.lazyPutFactory`/`Get.putFactory`, resolved with `slf()`.
- Build-time switches (`XUNA_SIMULATOR`) are read only in bindings via `bool.fromEnvironment`.
- New route: add an `AppRoutes` value, add `GetPage(name:, page:, binding:)` to `AppPages`, navigate with `nav.toNamed(AppRoutes.x.path, arguments: …)`. Pass one typed argument object, not maps; read it in the controller's `onInit` with `Get.safeArguments<T>()`.
- `AppData` holds only true app-global values. `EventBus` is for app-wide notifications between presentation components, never a substitute for repository streams.

## 6. XUNA invariants for mobile code

1. **The device is authoritative** for pet-life state: identity, mood, memory, preferences, learning and growth. The app requests, displays and confirms. It never decides learning outcomes and never stores pet state as truth; cached copies are read-only projections labeled with their source and time.
2. **No second learner in Dart.** `SimulatorDeviceRepository` is a development fake. Do not add learning or decision rules to it; behavior that must match firmware is checked against firmware golden vectors (session S20, plan G17).
3. **Protocol discipline:** versioned frames; validate every inbound field and outbound argument; check capabilities before using a feature; request IDs with at most one command in flight; explicit timeouts; never auto-resend a non-idempotent command; disconnect cancels pending requests and ignores stale callbacks; protocol changes are additive (v1 keeps working) and ship with byte-level tests.
4. **Conversation input:** parse locally into candidate intents. Anything that teaches XUNA needs an explicit confirmation showing what will be recorded and its source. Unknown input never learns. Raw input text is neither stored nor logged. Future AI/provider output is untrusted until validated.
5. **Destructive and privacy actions** (forget, reset, delete) require `nav.showConfirmDialog` and say they cannot be undone.
6. **Simulator** is opt-in (`--dart-define=XUNA_SIMULATOR=true`) and always visibly labeled; simulator data is never presented as board data.
7. **No backend, LLM, voice or cloud** calls, permissions or dependencies unless the current session explicitly includes them.

## 7. Async, resources and logging

- Cancel every `StreamSubscription` and `Timer`, and close every `StreamController` you create.
- Mark intentional fire-and-forget calls with `unawaited(…)`.
- After reconnects, guard callbacks against stale sessions (epoch or ID check, as in the BLE code).
- Log with `logger` (`shared/utils/logger.dart`), never `print`. Never log user-entered text, personal facts or secrets.

## 8. Code style

- Project imports use `package:xuna_mobile/…`, never relative paths; the only exception is tests importing shared helpers from `test/helpers/`. Order: `dart:`, `package:flutter`, other packages, project.
- Readability over density: one declaration per line, descriptive names (single letters only for loop indices and short lambdas), no multiple fields declared on one line.
- Prefer `const` and `final`. `switch` on enums you own without `default`, so a new value is a compile error.
- English identifiers and new comments; existing Vietnamese comments in the base stay. User-facing copy is Vietnamese via locales.
- `///` doc comments on public contracts, codecs and use cases with non-obvious rules (intent and error behavior). No comments on obvious code.
- `// ignore:` only with a reason comment on the same line.

## 9. Testing

- Test paths mirror `lib/`: `test/features/<feature>/{domain,data,presentation}/…_test.dart`.
- For every change, cover each layer touched:
  - **Domain:** use cases and pure rules, table-driven, including negative cases.
  - **Data:** codecs, models and mappers with valid and malformed fixtures; repository implementations with fake data sources, including error translation and timeouts.
  - **Presentation:** controller tests with fake repositories behind real use cases (state transitions, error mapping, overlap guards); a widget test for the main flow of a new screen.
- Fakes are hand-written: `implements Contract`, or `extends Fake implements AppNavigator` from `flutter_test`. Do not add mocking packages without approval.
- Controllers in tests: set `isTestMode = true`; register a fake `AppNavigator` with `Get.put<AppNavigator>(…)` before exercising error paths; `Get.testMode = true`; `Get.reset()` in `tearDown`.
- Firmware golden vectors, when available, live in `test/fixtures/` with a documented update procedure.

## 10. Toolchain, dependencies and checks

- Flutter **3.32.8** through fvm (`.fvmrc`, decision D14). Always run `fvm flutter …`. No SDK or dependency upgrade inside a feature session.
- After `fvm flutter pub get`, `pubspec.lock` must be unchanged unless the session approves a dependency change. A changed lock without a dependency change means the wrong SDK: stop and report.
- New packages need owner approval: check license, maintenance and platform support; pin plugins exactly (as `flutter_blue_plus: 1.35.5`); preserve required notices.
- Checks before reporting:

```sh
fvm flutter pub get                 # lock must stay unchanged
fvm dart format <changed files>
fvm flutter analyze                 # no issues
fvm flutter test --reporter expanded
```

- Simulator, real-phone and board runs are reported separately. Never claim a run that was not executed.

## 11. Reference implementation and known gaps

`features/device`, `features/conversation` and `features/home` were migrated to these rules on 2026-10-13 and are the reference to imitate, together with [docs/FEATURE_TEMPLATE.md](docs/FEATURE_TEMPLATE.md).

Remaining gaps. Do not fix them as a side effect of an unrelated feature; handle them in their own session or when the trigger in the last column happens.

| Location | Gap | Resolve when |
| --- | --- | --- |
| `features/device/data/data_source/simulator_device_ble_data_source.dart` | The fake transport still contains a Dart copy of the firmware learner (plan G17) | S20: check it against firmware golden vectors |
| `features/home/presentation/binding/home_binding.dart` | The device data source and repository are route-scoped | A second screen needs the device: move them to `AppBinding` (§5.6) |
| `HomeController` status stream handler | Any stream error, including one malformed notification, marks the UI disconnected (MVP behavior kept by the refactor) | Owner decides whether only `disconnected` should do so |
| `shared/themes/app_colors.dart`, `UtilWidget` buttons/card/dropdown, dialog texts in `vi_VN.json` | Palette and copy inherited from the imported base, not XUNA branding | The XUNA design is delivered (§5.4) |

## 12. Definition of Done

- [ ] Scope matches the requested session; nothing from later sessions.
- [ ] Domain is pure Dart; presentation imports no `data/` (bindings excepted); contracts use domain types only.
- [ ] Controllers depend on use cases only; every async action goes through `buildState`.
- [ ] No hardcoded user-facing strings, colors, text styles or spacing; locales regenerated or kept in sync.
- [ ] Existing base widgets used for their roles; UI repeated across screens extracted into a base widget (§5.4).
- [ ] Navigation and dialogs through `nav`; destructive actions confirmed.
- [ ] XUNA invariants (§6) respected; simulator labeled.
- [ ] Subscriptions, timers and controllers disposed; no `print`; no user text in logs.
- [ ] Tests for each layer touched; `fvm flutter analyze` clean; `fvm flutter test` passes; `pubspec.lock` unchanged or approved.
- [ ] README and handoff docs updated when behavior or commands changed; the report lists what was and was not run.
