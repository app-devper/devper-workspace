# devper_workspace

Devper Workspace

## Requirements

This workspace uses:

- `FVM` to manage the Flutter SDK
- `Melos` to manage the monorepo and local package dependencies

Install tools:

```sh
dart pub global activate fvm
dart pub global activate melos
```

## Flutter Version

This workspace is currently aligned with:

- `Flutter 3.38.7`
- `Dart 3.10.7`

Use the workspace Flutter SDK through FVM:

```sh
fvm flutter --version
```

## Getting Started

Install root dependencies:

```sh
fvm flutter pub get
```

Bootstrap the workspace:

```sh
fvm dart pub global run melos bootstrap
```

Or run the workspace prepare script:

```sh
fvm dart pub global run melos run prepare
```

## Useful Commands

Get outdated packages:

```sh
fvm flutter pub outdated
```

Analyze the workspace:

```sh
fvm dart pub global run melos run analyze
```

## Notes

- `melos` workspace configuration is defined in the root `pubspec.yaml`
- If dependencies or IDE package references look broken, run:

```sh
fvm dart pub global run melos run prepare
```
