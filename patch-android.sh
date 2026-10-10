#!/usr/bin/env bash
# Roda depois de "npx cap add android": coloca o ícone e as permissões.
set -euo pipefail
RES=android/app/src/main/res
MAN=android/app/src/main/AndroidManifest.xml

# ícone: remove o adaptativo padrão e usa os PNGs do ícone enviado
rm -rf "$RES"/mipmap-anydpi-v26 "$RES"/drawable-v24/ic_launcher_foreground.xml || true
for d in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
  mkdir -p "$RES/mipmap-$d"
  cp icon-$d.png "$RES/mipmap-$d/ic_launcher.png"
  cp icon-round-$d.png "$RES/mipmap-$d/ic_launcher_round.png"
  cp icon-$d.png "$RES/mipmap-$d/ic_launcher_foreground.png"
done

# permissões: câmera e microfone (gravador de voz)
if ! grep -q "android.permission.CAMERA" "$MAN"; then
  sed -i 's#<application#<uses-permission android:name="android.permission.CAMERA" />\n    <uses-permission android:name="android.permission.RECORD_AUDIO" />\n    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />\n    <application#' "$MAN"
fi
echo "Android patch OK"
