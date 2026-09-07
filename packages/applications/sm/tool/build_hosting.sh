#!/bin/sh
set -eu

# Keep the Firebase artifact separate from the local ENV=dev server.
app_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$app_dir"

if command -v fvm >/dev/null 2>&1; then
  fvm flutter build web --release --dart-define=ENV=app --pwa-strategy=none --output="$app_dir/build/hosting/sm"
elif command -v flutter >/dev/null 2>&1; then
  flutter build web --release --dart-define=ENV=app --pwa-strategy=none --output="$app_dir/build/hosting/sm"
else
  echo 'Flutter is required. Install the project Flutter SDK with FVM, or add flutter to PATH.' >&2
  exit 1
fi
