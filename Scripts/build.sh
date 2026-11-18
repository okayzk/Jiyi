#!/bin/bash
# Builds the app bundle.
#
#   Scripts/build.sh                 development build for this Mac -> build/<NAME>.app
#   ARCH=universal OUT_DIR=dist ...  what a release ships (Apple silicon + Intel)
#
# Environment:
#   ARCH           native (default) | universal
#   OUT_DIR        where the bundle goes (default: build)
#   SIGN_IDENTITY  codesign identity; default: what a release signs with (Developer ID,
#                  else the release certificate in app.env), else "Apple Development",
#                  else ad hoc ("-")
#   HARDENED=1     sign with the hardened runtime and --timestamp (needed to notarize).
#                  The app needs no entitlements: it is not sandboxed, and receiving the
#                  jiyi:// Apple Event or tapping events needs none.
#
# It leaves $OUT_DIR/$NAME.app, with the executable at Contents/MacOS/$NAME, signed with
# the identity (Sparkle.framework inside it signed first, never with --deep), and with
# CFBundleIdentifier, CFBundleShortVersionString and CFBundleVersion taken from app.env.
#
# SwiftPM compiles and links: Package.swift depends on Sparkle, so `swift build` and
# `swift run` keep working on their own. This script embeds the framework SwiftPM linked
# against, after checking it is the version Scripts/sparkle.sh pins for the appcast tools.
set -euo pipefail
cd "$(dirname "$0")/.."
. Scripts/lib.sh

ARCH="${ARCH:-native}"
OUT_DIR="${OUT_DIR:-build}"
APP="$PWD/$OUT_DIR/$NAME.app"
CONTENTS="$APP/Contents"

# 1. Compile. The rpath lets the executable find Sparkle in Contents/Frameworks.
SWIFT_FLAGS=(-c release -Xlinker -rpath -Xlinker @executable_path/../Frameworks)
case "$ARCH" in
  native) ;;
  universal) SWIFT_FLAGS+=(--arch arm64 --arch x86_64) ;;
  *) die "ARCH must be native or universal, got: $ARCH" ;;
esac
swift build "${SWIFT_FLAGS[@]}"
PRODUCTS="$(swift build "${SWIFT_FLAGS[@]}" --show-bin-path)"

SPARKLE_LINKED="$PRODUCTS/Sparkle.framework"
SPARKLE_TOOLS="$(./Scripts/sparkle.sh)"
version_of() { /usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$1/Resources/Info.plist"; }
[ "$(version_of "$SPARKLE_LINKED")" = "$(version_of "$SPARKLE_TOOLS/Sparkle.framework")" ] \
  || die "Package.swift links Sparkle $(version_of "$SPARKLE_LINKED") but Scripts/sparkle.sh pins $(version_of "$SPARKLE_TOOLS/Sparkle.framework"): make them equal"

# 2. Icons, drawn by Scripts/generate-icons.swift. pngquant (optional) shrinks the
#    PNGs inside AppIcon.icns with no visible difference at icon sizes.
swift Scripts/generate-icons.swift
if command -v pngquant >/dev/null 2>&1; then
  for png in Resources/AppIcon.iconset/*.png; do
    pngquant --quality=80-95 --speed 1 --skip-if-larger --force --output "$png" "$png" || true
  done
  iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns
else
  echo "pngquant not found: the icon is left uncompressed (brew install pngquant)"
fi

# 3. The bundle.
rm -rf "$APP"
mkdir -p "$CONTENTS/MacOS" "$CONTENTS/Resources" "$CONTENTS/Frameworks"
/usr/bin/ditto "$PRODUCTS/$NAME" "$CONTENTS/MacOS/$NAME"
cp Resources/AppIcon.icns "$CONTENTS/Resources/AppIcon.icns"
# Apache-2.0 §4(a) and §4(d): a distributed binary carries the license and the NOTICE.
cp LICENSE NOTICE "$CONTENTS/Resources/"
# Sparkle's MIT license travels with the framework it covers.
cp .build/checkouts/Sparkle/LICENSE "$CONTENTS/Resources/Sparkle-LICENSE"
# The name Finder, Spotlight and System Settings show: Jiyi in English, 寄译 in Chinese,
# the same as Branding.appName inside the app.
mkdir -p "$CONTENTS/Resources/en.lproj" "$CONTENTS/Resources/zh-Hans.lproj"
printf '"CFBundleDisplayName" = "%s";\n"CFBundleName" = "%s";\n' "$NAME" "$NAME" \
  > "$CONTENTS/Resources/en.lproj/InfoPlist.strings"
printf '"CFBundleDisplayName" = "寄译";\n"CFBundleName" = "寄译";\n' \
  > "$CONTENTS/Resources/zh-Hans.lproj/InfoPlist.strings"

PLIST="$CONTENTS/Info.plist"
cat > "$PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>$NAME</string>
  <key>CFBundleIdentifier</key>
  <string>$BUNDLE_ID</string>
  <key>CFBundleName</key>
  <string>$NAME</string>
  <key>CFBundleDisplayName</key>
  <string>$NAME</string>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>LSHasLocalizedDisplayName</key>
  <true/>
  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleURLTypes</key>
  <array>
    <dict>
      <key>CFBundleURLName</key>
      <string>$BUNDLE_ID.url</string>
      <key>CFBundleURLSchemes</key>
      <array>
        <string>jiyi</string>
      </array>
    </dict>
  </array>
  <key>CFBundleShortVersionString</key>
  <string>$VERSION</string>
  <key>CFBundleVersion</key>
  <string>$BUILD</string>
  <key>LSMinimumSystemVersion</key>
  <string>14.0</string>
  <key>LSUIElement</key>
  <true/>
  <key>NSHumanReadableCopyright</key>
  <string>Copyright © 2026 okayzk. Based on atst by itaober (Apache-2.0).</string>
</dict>
</plist>
PLIST

# Updates (Sources/Jiyi/Support/Updater.swift): Sparkle reads the signed appcast on the
# repository's appcast branch, written by Scripts/release.sh. A build without the public key cannot verify any update; the
# release preflight refuses to ship one, so here it is only a warning.
/usr/bin/plutil -insert SUFeedURL -string "$APPCAST_URL" "$PLIST"
if [ -n "$UPDATE_PUBLIC_KEY" ]; then
  /usr/bin/plutil -insert SUPublicEDKey -string "$UPDATE_PUBLIC_KEY" "$PLIST"
else
  echo "warning: no UPDATE_PUBLIC_KEY in app.env (Scripts/make_update_key.sh): this build cannot update itself"
fi
# Check once a day without first asking whether to; Settings can turn it off.
/usr/bin/plutil -insert SUEnableAutomaticChecks -bool YES "$PLIST"
/usr/bin/plutil -insert SURequireSignedFeed -bool YES "$PLIST"
/usr/bin/plutil -insert SUVerifyUpdateBeforeExtraction -bool YES "$PLIST"

# 4. Sign. A stable signature lets macOS keep the Accessibility permission across
#    rebuilds and updates. The system keeps one permission per bundle id, so development
#    builds are signed like releases by default.
IDENTITY="${SIGN_IDENTITY:-}"
[ -z "$IDENTITY" ] && IDENTITY="$(developer_id)"
[ -z "$IDENTITY" ] && IDENTITY="$(release_certificate)"
if [ -z "$IDENTITY" ]; then
  if /usr/bin/security find-identity -v -p codesigning | grep -q '"Apple Development'; then
    IDENTITY="Apple Development"
  else
    IDENTITY="-"
  fi
fi
SIGN_FLAGS=(--force --sign "$IDENTITY")
[ -n "${SIGNING_KEYCHAIN:-}" ] && SIGN_FLAGS+=(--keychain "$SIGNING_KEYCHAIN")
[ "${HARDENED:-0}" = 1 ] && SIGN_FLAGS+=(--options runtime --timestamp)

# Sparkle, signed from the inside out with the app's identity. The app is not sandboxed,
# so Sparkle's XPC services are left out, as its sandboxing guide allows.
FRAMEWORK="$CONTENTS/Frameworks/Sparkle.framework"
/usr/bin/ditto "$SPARKLE_LINKED" "$FRAMEWORK"
rm -rf "$FRAMEWORK/XPCServices" "$FRAMEWORK/Versions/B/XPCServices"
for part in "$FRAMEWORK/Versions/B/Autoupdate" "$FRAMEWORK/Versions/B/Updater.app" "$FRAMEWORK"; do
  /usr/bin/codesign "${SIGN_FLAGS[@]}" "$part"
done

# An ad hoc signature's own requirement is the hash of this one build; naming the bundle
# id instead keeps the Accessibility permission across local rebuilds.
[ "$IDENTITY" = "-" ] && SIGN_FLAGS+=(--requirements "=designated => identifier \"$BUNDLE_ID\"")
/usr/bin/codesign "${SIGN_FLAGS[@]}" "$APP"

printf 'Built: %s\n' "$APP"
