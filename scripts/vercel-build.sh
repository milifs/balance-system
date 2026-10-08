#!/bin/sh
set -e
if [ ! -d flutter ]; then
  git clone https://github.com/flutter/flutter.git -b 3.44.0 --depth 1
fi
flutter/bin/flutter config --enable-web

# Versión que viaja en los reclamos de Soporte. Sale de pubspec.yaml y se le
# pega el commit corto, que es lo que hace falta para ubicar el build cuando
# alguien reporta un problema. Se puede pisar con la env var APP_VERSION.
if [ -z "$APP_VERSION" ]; then
  APP_VERSION=$(grep -m1 '^version:' app/pubspec.yaml | awk '{print $2}')
  if [ -n "$VERCEL_GIT_COMMIT_SHA" ]; then
    APP_VERSION="$APP_VERSION ($(echo "$VERCEL_GIT_COMMIT_SHA" | cut -c1-7))"
  fi
fi
: "${APP_VERSION:=dev}"
: "${CLIENTE_NOMBRE:=Don Chacho}"

cd app
../flutter/bin/flutter build web --release \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
  --dart-define=APP_VERSION="$APP_VERSION" \
  --dart-define=CLIENTE_NOMBRE="$CLIENTE_NOMBRE" \
  --dart-define=SOPORTE_WHATSAPP="$SOPORTE_WHATSAPP"
