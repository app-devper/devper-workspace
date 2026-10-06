---
name: dart-flutter-patterns
description: How Dart and Flutter code is written in devper-workspace — Clean Architecture + MVVM with ValueNotifier view models and OneShot events, get_it composition in container.dart, http via CustomClient/PosService and jsonOrThrow, sealed AppException → Failure, CachedList, Flutter Hooks only in UM, and tests with fake repositories and MockClient. Use when writing or reviewing Dart/Flutter code in this repo — a screen, view model, use case, repository, mapper or test.
---

# Dart / Flutter patterns — devper-workspace

The house style of this melos workspace, taken from the code. When this file
and the code disagree, the code and [docs/architecture.md](../../../docs/architecture.md)
win — fix this file. Domain words (Sale, Till, Line, Order…) are defined in
[CONTEXT.md](../../../CONTEXT.md); use them in names and comments.

**Not used here — do not introduce:** BLoC, Riverpod, Provider, GetX, MobX,
Freezed/json_serializable, Dio, GoRouter, mockito/mocktail. Adding any of them
is an architecture decision (ADR), not a refactor.

| Need | Use |
|---|---|
| DI | `get_it` via `getIt()` — registrations in each app's `container.dart` |
| Screen state | `ValueNotifier<XState>` exposed as `ValueListenable` |
| One-off outcomes | `OneShot<T>` (`common/core/state/one_shot.dart`) |
| HTTP | `package:http` through `CustomClient` + a `*Service` class |
| Errors | `AppException` (sealed) → `toFailure(e)` → Thai message |
| JSON | extension mappers on `Map<String, dynamic>` / `List`, `json_ext` readers |
| Navigation | `Navigator.pushNamed` + route constants, `RouterApp.generateRoute` |
| UM presentation | Flutter Hooks (`HookWidget`, `use*` hooks) — UM only |
| Tests | `flutter_test`, hand-written `Fake*Repository`, `MockClient` from `package:http/testing.dart` |

## Packages and layers

```
packages/
  applications/pos   POS app        Clean Architecture + MVVM
  applications/sm    admin app      Clean Architecture + MVVM (consumes UM hooks in sections)
  features/um        auth & users   Clean Architecture + Flutter Hooks
  libraries/common   DI, network, errors, OneShot, json_ext, navigation
  libraries/design_system  widgets/theme only — no repositories
```

Inside an app: `lib/domain` (models, repository contracts, use cases) →
`lib/data` (`datasource/network/*_service.dart`, `repositories/*_impl.dart`,
`*_mapper.dart`) → `lib/presentation/<feature>/<screen>/` (`*_page.dart`,
`*_view_model.dart`, `*_state.dart`).

Rules:
- **Domain** is plain Dart: no Flutter, no `get_it`, no `http`, no JSON.
- **Data** owns services, mappers, caches and token handling.
- **Presentation**: View → ViewModel → UseCase (or repository contract for a
  trivial read) → Repository. A use case never takes a `BuildContext`.
- A workflow that sequences calls or is shared across screens/apps is a use
  case (e.g. `CheckoutSaleUseCase`). Don't add pass-through use cases that only
  forward one repository call — #88/#89 removed those.

## Composition — container.dart

```dart
final sl = getIt();

Future<void> initPos() async {
  sl.registerFactory(() => CategoryEditViewModel(categoryRepo: sl()));
  sl.registerSingleton(Till());
  sl.registerFactory(() => CartViewModel(
        till: sl(),
        checkoutSaleUseCase: sl(),
        getProductByBarcodeUseCase: sl(),
      ));
  // repositories / use cases / services registered below
}
```

- View models: `registerFactory` (one per screen instance; the page disposes it).
- Shared state that outlives a screen (`Till`, use cases holding in-flight
  state like `CheckoutSaleUseCase`): singletons.
- Constructor injection with named `required` parameters. Only `container.dart`
  and pages call `sl<…>()`.

## View model

```dart
class CategoryEditViewModel {
  final CategoryRepository categoryRepo;
  CategoryEditViewModel({required this.categoryRepo});

  final _state = ValueNotifier<CategoryEditState>(const CategoryEditState());
  final _updated = OneShot<Category>();
  final _errors = OneShot<String>();

  ValueListenable<CategoryEditState> get state => _state;
  Stream<Category> get updated => _updated.stream;
  Stream<String> get errors => _errors.stream;

  Future<void> updateCategoryById(String id, CategoryParam param) async {
    if (_state.value.busy) return;                 // reject double submit
    _state.value = _state.value.copyWith(busy: true);
    try {
      _updated.emit(await categoryRepo.updateCategoryById(id, param));
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    } finally {
      _state.value = _state.value.copyWith(busy: false);
    }
  }

  void dispose() {
    _state.dispose();
    _updated.dispose();
    _errors.dispose();
  }
}
```

- **State is what the screen draws** (data, `busy`/`loading`, permission
  predicates like `isAdmin`). Immutable class with `const` constructor and
  `copyWith`, annotated `@immutable`.
- **Outcomes the screen reacts to once** (saved record → pop, error → snackbar,
  reload signal) go through `OneShot`, never into state with a `consume*()`
  call. Emitting with no listener drops the event — by design.
- **No boolean flag soup.** One command → one `busy` flag or one sealed type
  named for that screen's flow (`OrderTask`, `SupplierLookup`). Never
  independent `loading`/`success`/`error` flags, never a shared generic
  `CommandState`. A message the screen wrote itself is `Rejected(message)`, not
  a `Failure` (that would append an error code).
- Results of a use case with several outcomes are a sealed class owned by the
  use case:

  ```dart
  sealed class SaleCheckoutResult { const SaleCheckoutResult(); }
  final class SaleCheckoutRecorded extends SaleCheckoutResult { final OrderResult order; … }
  final class SaleCheckoutRejected extends SaleCheckoutResult { final String message; … }
  final class SaleCheckoutPending  extends SaleCheckoutResult { … }
  ```

  Handle them with an exhaustive `switch`.
- After `dispose()`, async completions must not publish (see `CartViewModel`).

## View (page)

```dart
class _CategoryEditPageState extends State<CategoryEditPage> {
  late CategoryEditViewModel _viewModel;
  late StreamSubscription<String> _errors;
  late StreamSubscription<Category> _removed;
  bool _loadingShown = false;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<CategoryEditViewModel>();
    _viewModel.state.addListener(_onStateChanged);
    _errors = _viewModel.errors.listen(_showError);
    _removed = _viewModel.removed.listen((c) => Navigator.pop(context, c));
    WidgetsBinding.instance.addPostFrameCallback((_) => _viewModel.getCategoryById(widget.category.id));
  }

  void _onStateChanged() {
    final s = _viewModel.state.value;
    if (s.loading && !_loadingShown) { _loadingShown = true; showLoadingDialog(context); }
    else if (!s.loading && _loadingShown) { _loadingShown = false; hideLoadingDialog(context); }
  }

  @override
  void dispose() {
    _viewModel.state.removeListener(_onStateChanged);
    _errors.cancel();
    _removed.cancel();
    _viewModel.dispose();
    super.dispose();
  }
}
```

- Views own rendering, `TextEditingController`/`FocusNode`, navigation, dialogs
  and snackbars (`CustomSnackBar`, `showLoadingDialog` from `common`). Build
  with `ValueListenableBuilder` on `viewModel.state`.
- Every `listen` has a `cancel` and every controller/node a `dispose`.
- Widgets come from `design_system` (`AppShell`, buttons, inputs, dialogs,
  `TitleBar`); don't restyle locally — add to `design_system` if it is reusable.
- Navigation: `Navigator.pushNamed(context, someRoute, arguments: …)` with the
  route constants and `RouterApp.generateRoute`; `resetToRoute` /
  `appNavigatorKey` for whole-stack resets (e.g. logout).

## UM (Hooks)

UM screens are `HookWidget`s that call presentation hooks in
`features/um/lib/hooks/` (`use_login.dart`, `use_users.dart`…). Hooks resolve
UM use cases; they do not replace them.

- Reads: memoize the `Future` with its input/reload keys.
- Mutations: `useMutationAction(context, action, onSuccess: …)` — one shared
  `LoadingDialog`, rejects duplicates while pending, owns its own loading route,
  ignores completions after unmount, maps request failures to an error dialog.
- Local form state: `useTextEditingController`, `useFocusNode`, `useState`.
- Don't move network/business calls into `useEffect` to avoid a use case, and
  don't memoize callbacks with empty keys when they capture changing props.
- POS does not adopt Hooks; SM only uses UM's hooks inside its home sections.

## Data layer

```dart
// service: one method per endpoint, returns http.Response
Future<http.Response> getCategories() {
  final url = Uri.parse('${networkConfig.getHostApp()}/api/pos/v1/categories');
  return client.get(url, headers: networkConfig.getHeaders(url));
}

// repository: service → jsonOrThrow → mapper → domain
@override
Future<Category> updateCategoryById(String id, CategoryParam param) async {
  final response = await posService.updateCategoryById(id, param.toCategoryRequest());
  final result = (jsonOrThrow(response) as Map<String, dynamic>).toCategoryDomain();
  _categories.invalidate();          // any write that changes a cached read
  return result;
}
```

- `CustomClient` wraps `http.Client` with interceptors (logging, 401 →
  unauthorized handling). Services take `NetworkConfig` + `CustomClient`.
- `jsonOrThrow` decodes 2xx and throws a typed `AppException` otherwise
  (401 Auth, 403 Forbidden, 404 NotFound, 409 Conflict with `payload`, 5xx Server).
- Mappers are extensions in `*_mapper.dart`: `extension CategoryJson on
  Map<String, dynamic> { Category toCategoryDomain() … }`, list versions on
  `List`, request bodies as `param.toXRequest()` returning a JSON string. Read
  numbers with `json_ext` (`readDouble`, `readInt`, `readString`) — the API
  sends ints and doubles interchangeably.
- In-memory caches are `CachedList<T>` inside the repository: `fill` on a
  fresh read, `invalidate()` on every write that could change it (including a
  write in another repository — `OrderRepositoryImpl` invalidates the product
  catalogue after recording a Sale).

## Errors

```dart
sealed class AppException implements Exception { final String message; final String code; … }
final class ConflictException extends AppException { final Map<String, dynamic>? payload; … }

Failure toFailure(Object e) => switch (e) {
  AuthException() => Failure(errorCode: e.code, error: "เซสชันหมดอายุ กรุณาเข้าสู่ระบบใหม่"),
  ValidationException() => Failure(errorCode: e.code, error: e.message),
  ConflictException() => Failure(errorCode: e.code, error: e.message),
  http.ClientException() => const Failure(errorCode: "NETWORK_ERROR", error: _networkErrorMessage),
  // …
};
```

- Data throws `AppException`; view models catch `on Exception`, convert with
  `toFailure(e)` and emit `failure.getMessage()` (`"<message> [<code>]"`).
- User-facing text is Thai. Map by exception type, never by parsing message
  text. Add a new subtype only when callers handle it differently.

## Domain models

- Entities are plain classes; behaviour that defines a business rule lives on
  the model and is unit-tested without fakes (`Sale` prices Lines, checks
  `covers(tendered)`, builds `toOrder()`; `OrderItemDetail.paid()`).
- Money: a Line's `price` is the whole quantity before discount, `discount` is
  per unit (see CONTEXT.md). The server decides what an Order charges.
- Use `final`, `const` constructors and null-safety (`?`, `??`, `late` only
  when initialised in `initState`). Avoid `!` except right after a check.

## Tests

```dart
class FakeOrderRepository implements OrderRepository {
  final OrderDetail? orderDetail;
  final Object? getByIdThrows;
  final List<String> loadedOrderIds = [];
  FakeOrderRepository({this.orderDetail, this.getByIdThrows});

  @override
  Future<OrderDetail> getOrderById(String orderId) async {
    final error = getByIdThrows;
    if (error != null) {
      throw error;
    }
    loadedOrderIds.add(orderId);
    return orderDetail!;
  }

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

// real use cases over fakes, built by one helper per test file
OrderDetailViewModel _vm({OrderRepository? orderRepo, LoginRepository? loginRepo}) {
  return OrderDetailViewModel(
    getRoleUseCase: GetRoleUseCase(loginRepo ?? FakeLoginRepository()),
    getOrderByIdUseCase: GetOrderByIdUseCase(orderRepo: orderRepo ?? FakeOrderRepository()),
    // …
  );
}

test('a failure is reported and stops the spinner', () async {
  final vm = _vm(orderRepo: FakeOrderRepository(getByIdThrows: Exception('offline')));
  final errors = <String>[];
  vm.errors.listen(errors.add);
  await vm.getOrderById('order-1');
  await _pump();                       // Future<void>.delayed(Duration.zero)
  expect(vm.state.value.loading, isFalse);
  expect(errors, hasLength(1));
});
```

- View models are tested with **real use cases over fake repository
  contracts** — hand-written fakes with `noSuchMethod` for unused members, no
  mocking library.
- Repositories are tested end to end through `CustomClient(inner:
  MockClient(...))` with a `FakeNetworkConfig`, asserting the request path/body
  and the mapped domain result.
- Domain rules (Sale, Line, money) get plain unit tests.
- Hook tests cover duplicate execution, latest callback, disposal and error
  handling.
- Test names read as behaviour ("a failed reload keeps the document already on
  screen"). Tests live under `test/` mirroring `lib/`.

## Before you finish

```bash
melos run analyze                                        # flutter analyze --fatal-infos
melos exec -c 1 --dir-exists=test -- flutter test
melos run import_sorter                                  # keeps the // Flutter/Package/Project imports: headers
```

Flutter is pinned by `.fvmrc` (3.38.7). Review with `flutter-dart-code-review`
and apply only the parts that fit the patterns above.
