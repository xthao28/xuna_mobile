# Feature skeleton

Companion to [AGENTS.md](../AGENTS.md). Copy this structure when adding a feature, replacing `Xxx`/`xxx` with the feature name. `xxx` is an illustrative, **phone-owned** list of items stored locally. It is not an approved product feature. Pet-life data is device-owned and never modeled like this (AGENTS §6).

Verified on 2026-10-13: this exact code, added to a scratch copy of the repository, passed `fvm flutter analyze` with no issues and its 4 tests below on the pinned Flutter 3.32.8, and `dart format` made no changes. For a real BLE feature, also read the reference implementation in `lib/features/device` (codec, data source contract, simulator, repository error translation).

Order of work: domain → data → presentation → binding/route → locales → tests.

```text
lib/features/xxx/
├── domain/
│   ├── entity/xxx_item.dart
│   ├── exception/xxx_exception.dart
│   ├── repository/xxx_repository.dart
│   └── usecase/{get_xxx_items_use_case.dart, save_xxx_item_use_case.dart}
├── data/
│   ├── data_source/xxx_local_data_source.dart
│   ├── mapper/xxx_item_mapper.dart
│   ├── model/xxx_item_model.dart
│   └── repository/xxx_repository_impl.dart
└── presentation/
    ├── binding/xxx_binding.dart
    ├── controller/xxx_controller.dart
    ├── extension/xxx_exception_message.dart
    ├── widgets/xxx_item_tile.dart
    └── xxx_page.dart
test/features/xxx/
├── domain/usecase/save_xxx_item_use_case_test.dart
└── presentation/controller/xxx_controller_test.dart
```

## Domain

`domain/entity/xxx_item.dart`

```dart
import 'package:equatable/equatable.dart';

class XxxItem extends Equatable {
  const XxxItem({
    required this.id,
    required this.title,
    this.done = false,
  });

  final String id;
  final String title;
  final bool done;

  XxxItem copyWith({String? title, bool? done}) => XxxItem(
        id: id,
        title: title ?? this.title,
        done: done ?? this.done,
      );

  @override
  List<Object?> get props => [id, title, done];
}
```

`domain/exception/xxx_exception.dart`

```dart
import 'package:xuna_mobile/shared/exceptions/base/app_exception.dart';

enum XxxExceptionKind { invalidInput, corruptedData }

/// Failures of the xxx feature. Carries no UI text: presentation maps [kind]
/// to a localized message.
class XxxException extends AppException {
  const XxxException(this.kind, {this.rootException})
      : super(AppExceptionType.custom);

  final XxxExceptionKind kind;
  final Object? rootException;

  @override
  String toString() => 'XxxException($kind, root: $rootException)';
}
```

`domain/repository/xxx_repository.dart`

```dart
import 'package:xuna_mobile/features/xxx/domain/entity/xxx_item.dart';

/// Phone-owned xxx items.
///
/// Every method throws [XxxException] on failure; no platform exception
/// escapes an implementation.
abstract interface class XxxRepository {
  Future<List<XxxItem>> getItems();

  Future<void> saveItem(XxxItem item);
}
```

`domain/usecase/get_xxx_items_use_case.dart`

```dart
import 'package:xuna_mobile/core/domain/usecase/base_use_case.dart';
import 'package:xuna_mobile/features/xxx/domain/entity/xxx_item.dart';
import 'package:xuna_mobile/features/xxx/domain/repository/xxx_repository.dart';

class GetXxxItemsUseCase extends NoInputUseCase<List<XxxItem>> {
  const GetXxxItemsUseCase(this._repository);

  final XxxRepository _repository;

  @override
  Future<List<XxxItem>> execute() => _repository.getItems();
}
```

`domain/usecase/save_xxx_item_use_case.dart`: validation belongs in the use case, not the controller.

```dart
import 'package:xuna_mobile/core/domain/usecase/base_use_case.dart';
import 'package:xuna_mobile/features/xxx/domain/entity/xxx_item.dart';
import 'package:xuna_mobile/features/xxx/domain/exception/xxx_exception.dart';
import 'package:xuna_mobile/features/xxx/domain/repository/xxx_repository.dart';

class SaveXxxItemUseCase extends UseCase<XxxItem, void> {
  const SaveXxxItemUseCase(this._repository);

  final XxxRepository _repository;

  @override
  Future<void> execute(XxxItem input) async {
    if (input.title.trim().isEmpty) {
      throw const XxxException(XxxExceptionKind.invalidInput);
    }
    await _repository.saveItem(input);
  }
}
```

## Data

`data/model/xxx_item_model.dart`

```dart
/// Stored shape of an xxx item (schema v1).
class XxxItemModel {
  const XxxItemModel({
    required this.id,
    required this.title,
    required this.done,
  });

  /// Throws [FormatException] when a field is missing or has the wrong type.
  factory XxxItemModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    final done = json['done'];
    if (id is! String || title is! String || done is! bool) {
      throw const FormatException('Invalid XxxItemModel');
    }
    return XxxItemModel(id: id, title: title, done: done);
  }

  final String id;
  final String title;
  final bool done;

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'done': done};
}
```

`data/mapper/xxx_item_mapper.dart`

```dart
import 'package:xuna_mobile/features/xxx/data/model/xxx_item_model.dart';
import 'package:xuna_mobile/features/xxx/domain/entity/xxx_item.dart';
import 'package:xuna_mobile/shared/mappers/mappers_src.dart';

class XxxItemMapper extends BaseDataMapper<XxxItemModel, XxxItem>
    with DataMapperMixin<XxxItemModel, XxxItem> {
  @override
  XxxItem mapToEntity(XxxItemModel? data) {
    if (data == null) throw const FormatException('Missing XxxItemModel');
    return XxxItem(id: data.id, title: data.title, done: data.done);
  }

  @override
  XxxItemModel mapToData(XxxItem entity) => XxxItemModel(
        id: entity.id,
        title: entity.title,
        done: entity.done,
      );
}
```

`data/data_source/xxx_local_data_source.dart`: a BLE data source follows the same contract + `Impl` shape around `flutter_blue_plus`, and the simulator implements that contract.

```dart
import 'package:xuna_mobile/core/data/data_source/local/local_src.dart';
import 'package:xuna_mobile/features/xxx/data/model/xxx_item_model.dart';

abstract interface class XxxLocalDataSource {
  /// Throws [FormatException] when stored data is corrupted.
  List<XxxItemModel> readItems();

  Future<void> writeItems(List<XxxItemModel> items);
}

class XxxLocalDataSourceImpl implements XxxLocalDataSource {
  XxxLocalDataSourceImpl(this._appHive);

  /// Versioned key: bump the suffix and migrate when the schema changes.
  static const _itemsKey = 'xxx_items_v1';

  final AppHive _appHive;

  @override
  List<XxxItemModel> readItems() {
    final raw = _appHive.get<List<dynamic>>(_itemsKey) ?? const [];
    return raw
        .map((e) => XxxItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<void> writeItems(List<XxxItemModel> items) =>
      _appHive.put(_itemsKey, items.map((e) => e.toJson()).toList());
}
```

`data/repository/xxx_repository_impl.dart`: maps models to entities and translates every platform error.

```dart
import 'package:xuna_mobile/core/domain/repository/base_repository.dart';
import 'package:xuna_mobile/features/xxx/data/data_source/xxx_local_data_source.dart';
import 'package:xuna_mobile/features/xxx/data/mapper/xxx_item_mapper.dart';
import 'package:xuna_mobile/features/xxx/domain/entity/xxx_item.dart';
import 'package:xuna_mobile/features/xxx/domain/exception/xxx_exception.dart';
import 'package:xuna_mobile/features/xxx/domain/repository/xxx_repository.dart';

class XxxRepositoryImpl extends BaseRepository implements XxxRepository {
  XxxRepositoryImpl(this._localDataSource, this._mapper);

  final XxxLocalDataSource _localDataSource;
  final XxxItemMapper _mapper;

  @override
  Future<List<XxxItem>> getItems() async {
    try {
      return _mapper.mapToListEntity(_localDataSource.readItems());
    } on FormatException catch (e) {
      throw XxxException(XxxExceptionKind.corruptedData, rootException: e);
    }
  }

  @override
  Future<void> saveItem(XxxItem item) async {
    try {
      final items = _localDataSource.readItems()
        ..removeWhere((e) => e.id == item.id)
        ..add(_mapper.mapToData(item));
      await _localDataSource.writeItems(items);
    } on FormatException catch (e) {
      throw XxxException(XxxExceptionKind.corruptedData, rootException: e);
    }
  }
}
```

## Presentation

`presentation/extension/xxx_exception_message.dart`: the only place where exception kinds become text.

```dart
import 'package:get/get.dart';
import 'package:xuna_mobile/features/xxx/domain/exception/xxx_exception.dart';
import 'package:xuna_mobile/generated/locales.g.dart';

extension XxxExceptionMessage on XxxException {
  String get localizedMessage => switch (kind) {
        XxxExceptionKind.invalidInput => LocaleKeys.xxx_errorInvalidInput.tr,
        XxxExceptionKind.corruptedData => LocaleKeys.xxx_errorCorruptedData.tr,
      };
}
```

`presentation/controller/xxx_controller.dart`

```dart
import 'dart:async';

import 'package:get/get.dart';
import 'package:xuna_mobile/core/presentation/controllers/base_getx_controller.dart';
import 'package:xuna_mobile/features/xxx/domain/entity/xxx_item.dart';
import 'package:xuna_mobile/features/xxx/domain/exception/xxx_exception.dart';
import 'package:xuna_mobile/features/xxx/domain/usecase/get_xxx_items_use_case.dart';
import 'package:xuna_mobile/features/xxx/domain/usecase/save_xxx_item_use_case.dart';
import 'package:xuna_mobile/features/xxx/presentation/extension/xxx_exception_message.dart';
import 'package:xuna_mobile/shared/exceptions/base/app_exception.dart';

class XxxController extends BaseGetxController {
  XxxController(this._getItems, this._saveItem);

  final GetXxxItemsUseCase _getItems;
  final SaveXxxItemUseCase _saveItem;

  /// Read by the page; mutated only inside this controller.
  final items = <XxxItem>[].obs;

  bool get isBusy => isLoading.value || isLoadingOverlay.value;

  @override
  void onReady() {
    super.onReady();
    unawaited(loadItems());
  }

  Future<void> loadItems() => buildState(
        showLoading: true,
        action: () async {
          items.assignAll(await _getItems.execute());
        },
        onError: _handleError,
      );

  Future<void> toggleDone(XxxItem item) async {
    if (isBusy) return;
    await buildState(
      showLoadingOverlay: true,
      action: () async {
        await _saveItem.execute(item.copyWith(done: !item.done));
        items.assignAll(await _getItems.execute());
      },
      onError: _handleError,
    );
  }

  /// Handles feature failures; returns other exceptions to the base handler.
  AppException? _handleError(AppException error) {
    if (error is! XxxException) return error;
    nav.showSnackBar(error.localizedMessage);
    return null;
  }
}
```

`presentation/widgets/xxx_item_tile.dart`: feature-local because only this screen uses it. As soon as a second screen needs the same row, move it to `lib/shared/widgets/` as a business-free base widget (AGENTS §5.4) that takes plain values (`title`, `checked`) instead of `XxxItem`.

```dart
import 'package:flutter/material.dart';
import 'package:xuna_mobile/features/xxx/domain/entity/xxx_item.dart';
import 'package:xuna_mobile/shared/constants/const_src.dart';
import 'package:xuna_mobile/shared/themes/app_colors.dart';

/// Dumb widget: data in through the constructor, events out via callbacks.
class XxxItemTile extends StatelessWidget {
  const XxxItemTile({
    super.key,
    required this.item,
    required this.onToggle,
  });

  final XxxItem item;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimens.defaultPadding,
      ),
      title: Text(item.title, style: AppTextStyle.font14Re),
      trailing: Icon(
        item.done ? Icons.check_box : Icons.check_box_outline_blank,
        color: AppColors.primaryColor,
      ),
      onTap: onToggle,
    );
  }
}
```

`presentation/xxx_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xuna_mobile/core/presentation/widgets/base_get_page.dart';
import 'package:xuna_mobile/features/xxx/presentation/controller/xxx_controller.dart';
import 'package:xuna_mobile/features/xxx/presentation/widgets/xxx_item_tile.dart';
import 'package:xuna_mobile/generated/locales.g.dart';
import 'package:xuna_mobile/shared/constants/const_src.dart';

class XxxPage extends BaseGetPage<XxxController> {
  XxxPage({super.key});

  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.xxx_title.tr, style: AppTextStyle.font18Bo),
      ),
      body: baseShowLoading(
        () => Obx(
          () => controller.items.isEmpty
              ? Center(
                  child: Text(
                    LocaleKeys.xxx_empty.tr,
                    style: AppTextStyle.font14Re,
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimens.paddingVerySmall,
                  ),
                  children: [
                    for (final item in controller.items)
                      XxxItemTile(
                        item: item,
                        onToggle: () => controller.toggleDone(item),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
```

`presentation/binding/xxx_binding.dart`

```dart
import 'package:get/get.dart';
import 'package:xuna_mobile/core/presentation/bindings/base_bindings.dart';
import 'package:xuna_mobile/features/xxx/data/data_source/xxx_local_data_source.dart';
import 'package:xuna_mobile/features/xxx/data/mapper/xxx_item_mapper.dart';
import 'package:xuna_mobile/features/xxx/data/repository/xxx_repository_impl.dart';
import 'package:xuna_mobile/features/xxx/domain/repository/xxx_repository.dart';
import 'package:xuna_mobile/features/xxx/domain/usecase/get_xxx_items_use_case.dart';
import 'package:xuna_mobile/features/xxx/domain/usecase/save_xxx_item_use_case.dart';
import 'package:xuna_mobile/features/xxx/presentation/controller/xxx_controller.dart';
import 'package:xuna_mobile/shared/utils/utils_src.dart';

/// Composition root of the xxx route: the only presentation file that may
/// import `data/`.
class XxxBinding extends BaseBindings {
  @override
  void bindingsRepository() {
    Get.lazyPut<XxxLocalDataSource>(() => XxxLocalDataSourceImpl(sl()));
    Get.lazyPut<XxxRepository>(() => XxxRepositoryImpl(sl(), XxxItemMapper()));
  }

  @override
  void bindingsUseCase() {
    Get.lazyPut(() => GetXxxItemsUseCase(sl()));
    Get.lazyPut(() => SaveXxxItemUseCase(sl()));
  }

  @override
  void bindingsController() {
    Get.lazyPut(() => XxxController(sl(), sl()));
  }
}
```

## Route and locales

`routes/app_routes.dart`: add the enum value.

```dart
enum AppRoutes {
  splash,
  home,
  xxx;

  String get path => '/$name';
}
```

`routes/app_pages.dart`: add the page with its binding.

```dart
GetPage(
  name: AppRoutes.xxx.path,
  page: () => XxxPage(),
  binding: XxxBinding(),
),
```

`assets/locales/vi_VN.json`: one section per feature, then `get generate locales assets/locales` (or update `lib/generated/locales.g.dart` by hand with identical keys).

```json
"xxx": {
  "title": "Xxx",
  "empty": "Chưa có mục nào.",
  "errorInvalidInput": "Tiêu đề không được để trống.",
  "errorCorruptedData": "Dữ liệu đã lưu bị lỗi."
}
```

Navigate from a controller with `nav.toNamed(AppRoutes.xxx.path)`.

## Tests

`test/features/xxx/domain/usecase/save_xxx_item_use_case_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:xuna_mobile/features/xxx/domain/entity/xxx_item.dart';
import 'package:xuna_mobile/features/xxx/domain/exception/xxx_exception.dart';
import 'package:xuna_mobile/features/xxx/domain/repository/xxx_repository.dart';
import 'package:xuna_mobile/features/xxx/domain/usecase/save_xxx_item_use_case.dart';

class _FakeXxxRepository implements XxxRepository {
  final saved = <XxxItem>[];

  @override
  Future<List<XxxItem>> getItems() async => List.of(saved);

  @override
  Future<void> saveItem(XxxItem item) async {
    saved
      ..removeWhere((e) => e.id == item.id)
      ..add(item);
  }
}

void main() {
  test('saves a valid item', () async {
    final repository = _FakeXxxRepository();
    await SaveXxxItemUseCase(repository)
        .execute(const XxxItem(id: '1', title: 'Water'));
    expect(repository.saved, [const XxxItem(id: '1', title: 'Water')]);
  });

  test('rejects a blank title without touching the repository', () async {
    final repository = _FakeXxxRepository();
    await expectLater(
      SaveXxxItemUseCase(repository)
          .execute(const XxxItem(id: '1', title: ' ')),
      throwsA(
        isA<XxxException>()
            .having((e) => e.kind, 'kind', XxxExceptionKind.invalidInput),
      ),
    );
    expect(repository.saved, isEmpty);
  });
}
```

`test/features/xxx/presentation/controller/xxx_controller_test.dart`: real use cases over a fake repository, and a fake navigator for the error path.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:xuna_mobile/core/presentation/navigation/navigation_src.dart';
import 'package:xuna_mobile/features/xxx/domain/entity/xxx_item.dart';
import 'package:xuna_mobile/features/xxx/domain/repository/xxx_repository.dart';
import 'package:xuna_mobile/features/xxx/domain/usecase/get_xxx_items_use_case.dart';
import 'package:xuna_mobile/features/xxx/domain/usecase/save_xxx_item_use_case.dart';
import 'package:xuna_mobile/features/xxx/presentation/controller/xxx_controller.dart';
import 'package:xuna_mobile/generated/locales.g.dart';

class _FakeXxxRepository implements XxxRepository {
  final saved = <XxxItem>[];

  @override
  Future<List<XxxItem>> getItems() async => List.of(saved);

  @override
  Future<void> saveItem(XxxItem item) async {
    saved
      ..removeWhere((e) => e.id == item.id)
      ..add(item);
  }
}

class _FakeNavigator extends Fake implements AppNavigator {
  final snackBars = <String>[];

  @override
  void showSnackBar<T>(
    String message, {
    Duration duration = const Duration(seconds: 2),
    SnackBarType type = SnackBarType.failure,
    Alignment? align,
  }) =>
      snackBars.add(message);
}

void main() {
  late _FakeXxxRepository repository;
  late _FakeNavigator navigator;
  late XxxController controller;

  setUp(() {
    Get.testMode = true;
    navigator = Get.put<AppNavigator>(_FakeNavigator()) as _FakeNavigator;
    repository = _FakeXxxRepository();
    controller = XxxController(
      GetXxxItemsUseCase(repository),
      SaveXxxItemUseCase(repository),
    )..isTestMode = true;
  });

  tearDown(Get.reset);

  test('toggleDone saves and reloads items', () async {
    repository.saved.add(const XxxItem(id: '1', title: 'Water'));
    await controller.loadItems();

    await controller.toggleDone(controller.items.single);

    expect(controller.items.single.done, isTrue);
    expect(controller.isBusy, isFalse);
  });

  test('feature error is shown as a localized snack bar', () async {
    await controller.toggleDone(const XxxItem(id: '1', title: ' '));

    expect(navigator.snackBars, [LocaleKeys.xxx_errorInvalidInput.tr]);
    expect(repository.saved, isEmpty);
  });
}
```
