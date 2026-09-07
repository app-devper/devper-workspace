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

Put the FVM SDK and the pub global bin directory on `PATH`. The melos scripts
shell out to `melos exec`, so `melos run <script>` fails with
`melos: command not found` unless both are resolvable:

```sh
export PATH="$HOME/fvm/versions/3.38.7/bin:$HOME/.pub-cache/bin:$PATH"
```

Bootstrap the workspace:

```sh
melos bootstrap
```

Or run the workspace prepare script:

```sh
melos run prepare
```

## Useful Commands

Get outdated packages:

```sh
fvm flutter pub outdated
```

Analyze the workspace (CI runs this same script and fails on any issue):

```sh
melos run analyze
```

Run every package's tests:

```sh
melos exec -c 1 --dir-exists=test -- flutter test
```

## Notes

- `melos` workspace configuration is defined in the root `pubspec.yaml`
- If dependencies or IDE package references look broken, run:

```sh
melos run prepare
```

## API gateway

The POS and SM applications use `https://api.devper.app` in `config/app.json`. Both `apiUrl` (UM) and `hostApp` (business API) point to this gateway. Pinning `hostApp` prevents the system host returned by UM from bypassing the gateway, including after logout.

- `/api/um/v1/*` routes to the UM service.
- `/api/pos/v1/*` routes to the POS service through the sibling `devper-api` repository.
- Deploy the gateway POS rewrite before releasing these application configs.
- `--dart-define=ENV=dev` keeps the existing direct localhost configuration for local development.
### Local POS integration

POS `ENV=dev` routes UM and POS requests through `http://127.0.0.1:8587`.
Run `python3 tools/local-pos-gateway.py` with UM on port 8585 and POS on 8586,
then build POS with `flutter build web --release --dart-define=ENV=dev` and serve
on port 8088. The local gateway binds to loopback and forwards only `/api/um/`
and `/api/pos/`. `ENV=app` continues to use the Firebase API gateway.

## Deploy POS to Firebase Hosting: devper

There is no deploy pipeline in this repo — hosting deploys are manual, and
they are cut from `main`, never from a feature branch or `develop`. Land the
release into `main` first, then:

```sh
git checkout main && git pull --ff-only
cd packages/applications/pos
firebase deploy --only hosting:devper
```

Deploying from anywhere else publishes code that is not on the production
line, and the next release then silently overwrites it.

The `devper` target maps to site `devper` in Firebase project `devperpos`,
served at https://devper.web.app.
The predeploy hook builds a fresh release with `ENV=app` and both API hosts set
by `config/app.json` to `https://api.devper.app`. Build failure stops deployment.
It uses FVM when available, otherwise Flutter from PATH.

Hosting serves `build/hosting/devper`; local `build/web` remains separate.
The hosted build disables Flutter service-worker caching and uses `no-cache`
headers so browsers revalidate updates. SPA routes fall back to `index.html`.
The `pos` target is unchanged. Firebase CLI must already be logged in with
access to `devperpos`. To prepare the hosting build without publishing:

```sh
sh tool/build_hosting.sh
```
