# Application architecture

## Boundaries

POS and SM use Clean Architecture + MVVM. Shared UM uses Clean Architecture
with Flutter Hooks in its presentation layer. Hooks do not replace use cases.

- Domain: plain Dart entities, repository contracts and use cases. No Flutter,
  navigation, service locator, HTTP clients or JSON parsing.
- Data: repository implementations, API services, serialization and local storage.
- Composition root (`container.dart`): constructs repositories and use cases.
- POS/SM presentation: View -> ViewModel -> UseCase -> Repository contract.
- UM presentation: HookWidget -> presentation hook -> UseCase -> Repository contract.
- Design system: reusable widgets such as AppShell; no application repositories.

Repository interfaces may be injected directly for trivial reads, but workflows
that sequence calls or are shared across apps belong in use cases. Do not move
network or business operations into `useEffect` merely to remove a ViewModel.

## Shared UM

`domain/usecase/auth_use_cases.dart` and `user_use_cases.dart` expose typed actions.
`RestoreSessionUseCase` restores authentication before reading the active system.
Hooks resolve those actions at the composition boundary, and callers retain their
existing hook API. Data repositories remain responsible for token/cache handling.

Read hooks memoize a Future with its input/reload keys. Mutation hooks use
`useMutationAction`, a presentation adapter that:

- renders the one shared `LoadingDialog`, so UM and POS never drift apart;
- rejects duplicate calls while one request is pending;
- reads the newest action/success callback after a rebuild;
- owns a specific loading route, never blindly pops the current screen;
- removes its loading route and suppresses callbacks after unmount;
- maps request failures to an error dialog without treating callback exceptions
  as failed API requests.

Forms use `useTextEditingController`, `useFocusNode`, and `useState` for local
visual state. Splash's effect ignores async completion after disposal.
Do not memoize callbacks with empty keys when they capture changing props unless
their latest values are explicitly held in refs.

## POS / SM

Keep ValueListenable view models and constructor injection. Shared authentication
queries and commands are injected as UM use cases; the apps do not adopt Hooks.
Views own rendering, text controllers, navigation and dialogs. View models own
screen state and invoke use cases. Use cases should not accept BuildContext.

## Migration scope and follow-up

This change migrates UM hook repository calls and POS/SM authentication consumers.
It does not claim that every existing POS workflow is fully migrated: cart views
still access CartStore and some domain entities are mutable. Move cart pricing,
checkout assembly and cache mutation into dedicated commands with regression tests
before making those entities immutable. Async ViewModel completion after disposal
also needs a consistent state-publication policy in a separate migration.

## Validation

Hook widget tests cover duplicate execution, current callback selection, disposal,
error handling (Exception and Error alike), inherited-theme capture and preservation
of the underlying route. POS/SM ViewModel tests
continue to use fake repository contracts through real use cases. Run analyzer
and the UM, POS and SM test suites for shared authentication changes.

## No boolean flag soup audit

A boolean is appropriate for a genuinely binary UI choice (obscure password,
expanded sidebar), or a derived permission predicate. Do not encode one command
with independent loading/success/error flags or clear-result flags.

Define sealed state types in the screen that owns the flow, not a shared generic
command abstraction. ProductReturnState and StockAdjustmentState each have their
own Idle, Submitting, Succeeded(result), and Failed(failure) variants. Their payloads
cannot be mixed with another screen's result. loading/error/created getters are
read-only UI projections, not independently writable flags.

UM mutation lifecycle uses a local enum and never transitions from disposed back
to idle after an async completion.

Outstanding findings, not yet migrated:

- ReceiveManageState: multiple load flags plus created/updated/removed payloads
  and clear flags. Separate document/items load states from a typed command result
  (create/update/import/remove), retaining the rule that saving requires loaded items.
- CartState: orderSaving/orderResult/orderError allow contradictory checkout states.
  Define checkout-specific state variants carrying OrderResult; keep product lookup separate
  because those are distinct operations, not one global progress enum.
- SM HomeState: loading/error and loggedOut are separate concerns. Use a typed
  systems query state and a session/navigation result rather than a single enum
  that combines every possible screen condition.

Do not rename booleans to unrelated enums without eliminating invalid combinations.
Add LoginErrorType only when callers need different handling for verified error
categories; preserve the existing typed Failure instead of guessing from message text.
