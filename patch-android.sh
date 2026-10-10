#!/usr/bin/env bash
# Roda depois de "npx cap add android": coloca ícone, tela inicial e permissões.
set -euo pipefail

# ---- PERSONALIZE AQUI: cor de fundo da tela inicial ----
SPLASH_BG="#0F1115"
# (a imagem central é o arquivo splash-logo.png)

RES=android/app/src/main/res
MAN=android/app/src/main/AndroidManifest.xml
STY="$RES/values/styles.xml"

# ícone: remove o adaptativo padrão e usa os PNGs do ícone enviado
rm -rf "$RES"/mipmap-anydpi-v26 "$RES"/drawable-v24/ic_launcher_foreground.xml || true
for d in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
  mkdir -p "$RES/mipmap-$d"
  cp icon-$d.png "$RES/mipmap-$d/ic_launcher.png"
  cp icon-round-$d.png "$RES/mipmap-$d/ic_launcher_round.png"
  cp icon-$d.png "$RES/mipmap-$d/ic_launcher_foreground.png"
done

# tela inicial personalizada (fundo colorido + logo no centro)
find "$RES" -name 'splash*.png' -delete
mkdir -p "$RES/drawable" "$RES/drawable-nodpi" "$RES/values"
cp splash-logo.png "$RES/drawable-nodpi/splash_logo.png"
cat > "$RES/values/splash_colors.xml" <<XML
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="splash_bg">$SPLASH_BG</color>
</resources>
XML
cat > "$RES/drawable/splash.xml" <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@color/splash_bg" />
    <item>
        <bitmap android:src="@drawable/splash_logo" android:gravity="center" />
    </item>
</layer-list>
XML
# Android 12+: usa o mesmo fundo e logo
if grep -q 'Theme.SplashScreen' "$STY"; then
  sed -i '/name="AppTheme.NoActionBarLaunch"/,/<\/style>/ s#</style>#    <item name="windowSplashScreenBackground">@color/splash_bg</item>\n        <item name="windowSplashScreenAnimatedIcon">@drawable/splash_logo</item>\n    </style>#' "$STY"
fi

# permissões: câmera e microfone (gravador de voz)
if ! grep -q "android.permission.CAMERA" "$MAN"; then
  sed -i 's#<application#<uses-permission android:name="android.permission.CAMERA" />\n    <uses-permission android:name="android.permission.RECORD_AUDIO" />\n    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />\n    <application#' "$MAN"
fi
echo "Android patch OK"
