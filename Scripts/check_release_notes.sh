#!/bin/bash
# Written by release-kit; adapt it to this project freely.
# The release notes become the GitHub Release as they are, so their shape is checked:
# the title names the version in app.env, and each language in NOTES_LANGUAGES has its
# list, all of the same length, each item "N. **Label**: sentence."
#
#   Scripts/check_release_notes.sh            shape only (part of make check)
#   Scripts/check_release_notes.sh --release  also refuses TODO items (release preflight)
set -euo pipefail
cd "$(dirname "$0")/.."
. Scripts/lib.sh

NOTES=.github/RELEASE_NOTES.md
[ -f "$NOTES" ] || die "$NOTES does not exist"
TAG_PATTERN="${TAG_PREFIX}${VERSION//./\\.}"
grep -Eq "^# $TAG_PATTERN [A-Z][A-Za-z]+$" <(head -1 "$NOTES") \
  || die "$NOTES must start with '# $TAG <Codename>', found: $(head -1 "$NOTES")"

items() { # <section heading>: prints that section's numbered lines
  awk -v heading="$1" '$0 == heading {on = 1; next} /^### / {on = 0} on && /^[0-9]+\. /' "$NOTES"
}
COUNT=""
ALL=""
for language in $NOTES_LANGUAGES; do
  case "$language" in
    en) HEADING='### Changelog'; SHAPE='^[0-9]+\. \*\*[^*]+\*\*: .+\.$' ;;
    zh) HEADING='### 更新日志';  SHAPE='^[0-9]+\. \*\*[^*]+\*\*：.+。$' ;;
    *) die "NOTES_LANGUAGES in app.env: unknown language '$language' (en, zh)" ;;
  esac
  LIST="$(items "$HEADING")"
  [ -n "$LIST" ] || die "$NOTES has no numbered items under '$HEADING'"
  BAD="$(printf '%s\n' "$LIST" | grep -Ev "$SHAPE" || true)"
  [ -z "$BAD" ] || die "items under '$HEADING' not shaped 'N. **Label**: sentence.': $BAD"
  N="$(printf '%s\n' "$LIST" | wc -l | tr -d ' ')"
  [ -z "$COUNT" ] || [ "$N" = "$COUNT" ] || die "the lists in $NOTES differ in length"
  COUNT="$N"
  ALL="$ALL$LIST"$'\n'
done

if grep -q 'TODO' <<< "$ALL"; then
  [ "${1:-}" = --release ] && die "$NOTES still has TODO items"
  echo "Release notes match $TAG in shape, but still hold TODO items (a release refuses them)."
  exit 0
fi
echo "Release notes match $TAG ($COUNT items in each language)."
