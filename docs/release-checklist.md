# Release checklist

What no test can see: windows, permissions, real mouse and keyboard, other apps. Run this by hand in the packaged app (`make package`, then open `dist/Jiyi.dmg` and start the app from it) before tagging. Each item says what must happen.

When a release fixes a bug that is not on this list, add its reproduction here in the same commit, so the next release checks it again.

## First launch

1. Open the disk image and drag the app to Applications. Start it from there: it opens, and About (or its equivalent) shows the version in `app.env`.
2. Each permission the app asks for (screen recording, accessibility, notifications, …) is asked once; after granting it and restarting the app, the feature that needed it works.
3. On an unnotarized build, the first start is blocked: follow the README's steps and confirm they still match what macOS shows.
4. With the previous release installed and its permissions granted, drag this one over it and start it: nothing is asked again. (Not testable before the second release.)

## Updates

1. In the previous release, Check for Updates offers this one; installing it relaunches into this version without a Gatekeeper prompt and without asking for permissions again. In this one it says it is up to date. (Not testable before the second release.)

## Selection translation

1. Select text in another app (Safari, Notes) and press ⌥D: the tooltip opens next to the selection without taking focus from that app, the header names the source and target languages, and each default service fills its own row.
2. Select Chinese text with Chinese as the target: it is translated into the secondary language instead, and the header says so.
3. Drag the tooltip by its header; then press Esc: it closes even though it was never the key window. A click outside also closes it.
4. On a result row, the switch menu replaces only that row; the chevron collapses it without a new request; "add all" adds every enabled service not on screen.
5. Turn the network off and translate: each API row fails on its own with a readable error, and after three failures in a row it collapses into "failed N times · Disable".

## Screenshot translation

1. Press ⌥S and drag over text: the recognised text is translated in the same multi-row tooltip, placed beside the captured region.
2. Press ⌥S and cancel with Esc: nothing opens and no error is shown.
3. With Vision OCR off and no AI configured, ⌥S shows the "AI vision unavailable" message with how to fix it.

## Manual input

1. Press ⌥D with nothing selected: a text box opens and accepts typing and pasting at once; the tooltip's width follows the text.
2. Submit: the result shows an Original block; clicking it reopens the editor with the text, and the previous result stays visible underneath while editing.
3. After the editor closes, the tooltip does not look see-through (it is no longer the key window).

## PopClip

1. Package the extension (`PopClip-plugin/package.sh`), install it, select text and click Jiyi in the PopClip bar: the tooltip opens at the pointer with the translation.
2. With Jiyi not running, the same click launches it and still translates.

## Dictionary

1. Select a single English word (e.g. "translate"): the dictionary card shows UK/US IPA, both speakers play, senses are grouped, and no provider rows appear (skip translation is on by default).
2. Select a word Youdao does not know, or a 5-word phrase: the normal provider rows appear instead, without an error.
3. Turn "Skip translation when a definition exists" off: the card and the provider rows render together.
4. Dictionary settings → Test reports the macOS dictionary's status, and Manually Download opens Dictionary.app with the steps.

## Pinned notes

1. Pin a translation: a note appears where the tooltip was, keeps its top-left corner, and its switch, collapse and Original controls work.
2. Unpin it: the live tooltip opens at the note's position with the same results; × on another note closes it without opening anything.
3. With "Notes on all desktops" on, switch desktops: the note follows.

## Settings

1. Click the menu bar label: settings open under it; launching the app again (Finder, Spotlight) also opens them, even with the menu bar icon hidden.
2. The pin keeps settings above other windows and stops outside clicks from closing them.
3. Every change is saved at once and survives a restart; Reset restores defaults but keeps the AI URL, key and models.
4. The API page shows a reachability dot for each provider; the AI page's Test reports the draft configuration.
5. Launch at login: turn it on, log out and in, and Jiyi is running.
6. Updates: "Check for updates automatically" and "Check Now" are enabled in the packaged app; Check Now answers (up to date, or the new version) within a few seconds.

## Languages

1. With the system in English and in Simplified Chinese (or per app under System Settings → Language & Region → Applications): every text is in that language, none mixed.

## Memory

1. `footprint <pid>` just after launch, and again after using every feature once: the numbers are what this project allows.
2. No helper process is left running afterwards.
