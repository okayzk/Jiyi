#!/usr/bin/env bash
#
# Package the extension as Jiyi.popclipextz, the zip format PopClip
# installs by double-click. Output: PopClip-plugin/Jiyi.popclipextz
set -euo pipefail

cd "$(dirname "$0")"

rm -f Jiyi.popclipextz
zip -r -X Jiyi.popclipextz Jiyi.popclipext -x '*.DS_Store' >/dev/null
printf 'Built %s\n' "$PWD/Jiyi.popclipextz"
