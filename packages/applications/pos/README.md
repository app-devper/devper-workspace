# Devper POS

Flutter POS application for the Devper workspace.

## Overview

This package contains the POS app UI and application logic for:

- product search and barcode scanning
- cart and checkout flow
- order history and order detail
- customer, supplier, category, and receive management

The app is started from:

```sh
lib/main.dart
```

and loads app configuration from:

```sh
config/app.json
```

## Dependencies

This application depends on shared workspace packages such as:

- `common`
- `um`

Make sure workspace dependencies are prepared from the repository root before running the app.

## Setup

From the workspace root:

```sh
fvm flutter pub get
fvm dart pub global run melos bootstrap
```

or:

```sh
fvm dart pub global run melos run prepare
```

## Run the POS App

From the workspace root:

```sh
fvm flutter run -t packages/applications/pos/lib/main.dart
```

If you want to run from the package directory:

```sh
fvm flutter run -t lib/main.dart
```

## Assets and Config

This package uses:

- `config/` for environment/app configuration
- `assets/images/` for app images
- `assets/font/` for application fonts

## Notes

- The POS app uses the workspace Flutter SDK managed by `FVM`
- API integration depends on the shared configuration loaded through `AppConfig.forEnvironment("app")`
- If package references are missing in the IDE, rerun:

```sh
fvm dart pub global run melos run prepare
```
