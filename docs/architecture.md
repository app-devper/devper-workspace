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

The category, customer and supplier edit screens follow this too: one sealed
type each, named for its own entity, rather than a shared generic command state.

Twelve screens that ran one command each — add, edit and the small
tier/unit/stock dialogs — follow the same shape: a sealed task beside the data
the screen renders. Where a screen prints a message it wrote itself rather than
reporting a failed request, the variant is Rejected(message) and keeps the text
verbatim; wrapping it in a Failure would append an error code to strings the
user reads.

OrderDetailState shows the other half of the rule: a screen with several
unrelated flows gets one sealed type per flow, not one per screen. Its order
commands are an OrderTask and its supplier profile fetch a SupplierLookup, while
`logged` and `totalCostUpdated` stay plain booleans because each is a single
one-shot signal rather than a command with flags. Naming the variants also
settled what the code meant: a missing supplier profile is SupplierNotConfigured,
a state the screen acts on, not an error it reports.

CartState now follows this: checkout is a sealed CheckoutState carrying the
OrderResult, sitting beside the cart's own loading/error rather than merging with
it, because a barcode lookup and a submit are different operations.

Outstanding findings, not yet migrated:

- stock_count_item_picker matches the single-command field count but is not one
  of them: selectedProduct is selection state the user drives, not a command
  result, so it belongs with the list screens below.
- Twelve list screens carry loading/items/error. These are the weakest case for
  the rule: `items` is data that has to survive a reload, not a command result,
  so only loading and error are in tension, and no view model can currently
  produce both. Converting them buys a sealed status beside the data, not a
  smaller state.
- OrderState looks like an offender by field count but is not one. `logged`,
  `initialized` and `rangeSelection` are three unrelated one-shot signals rather
  than competing results of one command, and the rest is screen data.
- POS HomeState is likewise fine: `isAdmin` is the permission predicate the rule
  explicitly allows, and `loggedOut` is a navigation signal.
- SM HomeState: loading/error and loggedOut are separate concerns. Use a typed
  systems query state and a session/navigation result rather than a single enum
  that combines every possible screen condition.

Do not rename booleans to unrelated enums without eliminating invalid combinations.
Add LoginErrorType only when callers need different handling for verified error
categories; preserve the existing typed Failure instead of guessing from message text.
