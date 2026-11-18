<div align="center">

<img src="docs/icon.png" alt="Jiyi" width="128" height="128" />

# Jiyi

**A tiny menu-bar translator for macOS**

Named after *ji* and *yi*, the interpreters of the east and of the north in the *Book of Rites*.

[![macOS 14+](https://img.shields.io/badge/macOS-14%2B-000000?logo=apple&logoColor=white)](#requirements)
[![Version](https://img.shields.io/badge/version-v0.1.0-blue)](https://github.com/okayzk/Jiyi/releases/latest)
[![License](https://img.shields.io/badge/license-Apache--2.0-orange)](./LICENSE)

Hit a hotkey, get a translation. Works **out of the box** with built-in Google + Microsoft + DeepL adapters, and unlocks AI-grade dictionary / explanation when you bring your own model.

[简体中文](./README.zh-CN.md) · [Install](#install) · [Usage](#usage) · [Features](#features)

</div>

---

## Highlights

- ⚡ **One-hotkey translation** — press `⌥D` on any selected text, anywhere in macOS, and a tooltip appears in ~200ms. `Esc` dismisses it
- 🔁 **Reverse translation** — text that's already in your target language is translated into your secondary language instead (Chinese ⇄ English out of the box)
- ⌨️ **Type to translate** — press `⌥D` with nothing selected and a text box appears; type or paste. The original stays above the result, and clicking it reopens the editor for another pass
- 🖼️ **Screenshot translation** — press `⌥S`, drag a region, get the translation. On-device Vision OCR by default (fast + private + free); falls back to AI vision if you've configured one
- 🔀 **Multi-source side-by-side** — Google, Microsoft, DeepL and Apple's on-device engine stack above your AI result, each with its own switch and collapse controls
- 🧠 **AI dictionary mode** — for single words, AI providers can return multiple meanings, IPA phonetics, and a short usage explanation
- 📖 **Dictionary lookup** — a dedicated card for single words and short fixed phrases, with UK/US IPA and pronunciation playback, grouped senses, bilingual examples and related phrases; Youdao is the primary source, macOS's built-in dictionary is the offline fallback, and a dictionary hit skips translation by default
- 📌 **Pin as note** — detach a translation into a floating sticky note that keeps the per-result controls and can be unpinned back into the tooltip
- 💾 **Local cache** — repeat lookups hit a JSON cache, scoped per provider; configurable TTL and size cap
- 🫧 **Native Liquid Glass** — translation tooltips and pinned notes use Liquid Glass on macOS 26+ when available, with an automatic fallback on older systems
- 🪶 **Small footprint** — a ~4.5 MB download, ~12 MB installed. Pure Swift/AppKit, no Electron, no Web view
- 🔄 **Updates itself** — checks for a new version once a day and installs it with one click; turn it off in General settings
- 🌐 **Bilingual UI** — auto English / Chinese based on system language, with a manual override
- 🆓 **Zero-config friendly** — works on a fresh install with no API keys (Google + Microsoft + DeepL adapters, plus on-device Apple translation on macOS 26+); add an OpenAI-compatible endpoint when you want richer output

---

## Install

### Download the latest release

1. Grab the latest `Jiyi.dmg` from the [Releases page](https://github.com/okayzk/Jiyi/releases)
2. Open the DMG and drag **Jiyi** into your `Applications` folder
3. Launch Jiyi — a small **`Jiyi`** label appears in your menu bar (top-right of the screen)
4. On first launch Jiyi asks for **Accessibility** permission. The global hotkeys can't work without it, so click **Open System Settings** and switch Jiyi on under Privacy & Security → Accessibility. Skipped the dialog? Click the menu bar label and use the gear next to the permission row
5. Optional: turn on **Launch at login** in the General settings

> **Heads up**: Jiyi is signed with its developer's own certificate, not an Apple Developer ID, so macOS blocks the first launch. After the warning, click **Open Anyway** in System Settings → Privacy & Security, or run `xattr -d com.apple.quarantine /Applications/Jiyi.app`. Every release is signed with the same certificate, so updates keep the Accessibility permission.

### Build from source

Requires **macOS 14+** and **Swift 5.9+** (Xcode 15 / Command Line Tools).

```bash
git clone https://github.com/okayzk/Jiyi.git
cd Jiyi

# Quick dev build
swift run Jiyi

# Build the .app for this Mac (icon, Info.plist, Sparkle, codesign)
make build
open build/Jiyi.app

# Build what a release ships: universal .app, DMG and zip in dist/
make package
open dist/Jiyi.dmg
```

---

## Usage

### Hotkeys

| Hotkey | Action |
|---|---|
| `⌥D` | Translate the currently selected text — or open a text box when nothing is selected |
| `⌥S` | Screenshot a region and translate the text it contains |
| `Esc` | Dismiss the tooltip |

Both translation hotkeys are reconfigurable in **Settings → Hotkeys**.

### The translation tooltip

The header shows the detected source language and the target (e.g. `English → 简体中文`). Below it you'll see one or two sections:

- **Top — API results** (Google, Microsoft, DeepL): fast and free, no API key required. Each row can be switched to another enabled service or collapsed from its header
- **Bottom — AI result** (if enabled): richer output with multiple meanings, IPA phonetics, and explanations for technical terms

Each row has its own copy button. The whole tooltip is **draggable from its header** if you want to move it out of the way; `Esc` or a click outside dismisses it. Click the pin (📌) in the header to detach it into a sticky note. The note has the same switch, collapse and source-edit controls; its pin-slash button unpins it back into a normal tooltip, while × removes it.

Every result header also has a **switch button** (choose another enabled service that isn't already on screen) and a **collapse chevron**. Collapsing only hides that row — it never re-runs a translation.

If a provider fails three times in a row (blocked network, dead endpoint) its row collapses to a single line with a **Disable** button, so it stops shouting on every translation.

### Dictionary card

For a single English word or a short fixed phrase (up to 4 words), a dictionary card appears above the API rows. It shows UK/US IPA with a play button, senses grouped by part of speech, bilingual examples, common phrases and related words. Youdao's keyless web dictionary is the primary source; if it fails, Jiyi falls back to macOS's built-in 牛津英汉汉英词典 (single words only). By default, a dictionary hit replaces the API/AI rows for that lookup; turn off **Skip translation when a definition exists** in Dictionary settings to show them together. Tap the speaker next to the UK/US IPA to play the pronunciation — Youdao's audio when available, otherwise a system `en-GB` / `en-US` voice.

### PopClip extension

The repo ships a [PopClip](https://www.popclip.app/) extension in [`PopClip-plugin/`](PopClip-plugin/): select text, click **Jiyi** in the PopClip bar, and the translation tooltip opens at the pointer.

1. Install the bundled Jiyi `.app` (the `jiyi://` URL scheme is declared in the app bundle, so `swift run` does not register it).
2. Double-click `PopClip-plugin/Jiyi.popclipext` and confirm the install. For an unsigned local build, run `defaults write com.pilotmoon.popclip LoadUnsignedExtensions -bool YES` first if PopClip refuses it.
3. Make sure at least one translation provider is enabled in Jiyi.

The extension only opens `jiyi://translate?text=<selection>`; Jiyi reuses the same selection-translation pipeline (providers, cache, reverse translation). See [`PopClip-plugin/README.md`](PopClip-plugin/README.md) for packaging and icon regeneration.

### Reverse translation

If the text you select is already in your target language, Jiyi translates it into your **secondary language** instead — so a Chinese target still gives you English for Chinese selections. Both languages are set in General settings.

### Translator settings

Click the **`Jiyi`** label in your menu bar to open the settings panel.

The General page holds the target and secondary languages, launch-at-login, hotkeys, screenshot OCR and cache options, plus three translator toggles:

- ☑️ **API Translation** (on by default) — Google + Microsoft + DeepL. Zero config.
- ☐ **AI Translation** (off by default) — OpenAI-compatible endpoint. Configure base URL + key + model in the AI subpage.
- ☑️ **Dictionary** (on by default) — dictionary card for single words and short fixed phrases. Youdao is the primary source; the macOS system dictionary is the offline fallback.

Each provider name in the API subpage has a reachability dot, checked automatically when the page opens. In the AI subpage, the **Test** button below Timeout sends a tiny request with a dot next to its label.

The API subpage also has an optional **Fallback** toggle: when a provider fails or is unreachable, the remaining enabled API providers are added to the same translation automatically, and the failed row stays visible with its error.

The **Dictionary** subpage shows the source status, a Test button for the macOS dictionary, a **Manually Download** guide (opens Dictionary.app and lists the steps to install 牛津英汉汉英词典), the 1–4 word lookup limit and a **Skip translation when a definition exists** switch (on by default).

**Default translation services** picks which of the enabled services run on every new translation. Select one or several; anything left unchecked stays one click away in each result's switch menu.

At the bottom of the General section, **Check for updates automatically** (on by default, once a day) and **Check Now** control updates.

#### AI configuration (optional)

Inside **AI Translation** subpage:

- **Base URL** — any OpenAI-compatible endpoint, e.g. `https://api.openai.com/v1`, `http://localhost:11434/v1` (Ollama), `https://generativelanguage.googleapis.com/v1beta/openai/` (Gemini OpenAI-compat)
- **API Key** — kept locally in `~/Library/Preferences/io.github.okayzk.Jiyi.plist`
- **Translation Model** — model name to use for selection translation (e.g. `gpt-4o-mini`, `qwen2.5:7b`)
- **Screenshot Model** — vision-capable model used when **Vision OCR** is OFF (e.g. `gpt-4o`, `claude-3.5-sonnet`)
- **Timeout** — idle limit per AI request (Google / Microsoft use a fixed 15 s, DeepL 20 s)
- **Phonetic** — append IPA to single-word lookups
- **Smart Explanation** — add a dictionary-style explanation block (idioms, proper-noun definitions, etc.)
- **Translation Prompts** — fully editable system + smart-explanation prompts

#### Screenshot OCR settings

The **Screenshot** section in the General page controls how `⌥S` works:

- ☑️ **Use Vision OCR** (on by default) — recognise text on-device with macOS Vision (no AI needed!), then translate via the selected providers
- ☐ **Use Vision OCR** OFF — send the screenshot directly to your AI vision model

Add or remove recognition languages from the chip row below. Default: Simplified Chinese + English + Japanese.

---

## Features

### Translation providers

| Provider | Key required | Free | Streaming | Multi-meaning | Phonetic | Explanation |
|---|---|---|---|---|---|---|
| Google (built-in) | ❌ | ✅ | — | ❌ | ❌ | ❌ |
| Microsoft (built-in) | ❌ | ✅ | — | ❌ | ❌ | ❌ |
| DeepL (built-in) | ❌ | ✅ (1500 chars/request) | — | ❌ | ❌ | ❌ |
| Apple (built-in, macOS 26+) | ❌ | ✅ | — | ❌ | ❌ | ❌ |
| OpenAI-compatible | ✅ | depends | ✅ | ✅ | ✅ | ✅ |

### Other goodies

- **Smart tooltip placement** — Web-style flip algorithm; tooltip never gets pushed off-screen or covers your selection
- **Dictionary card** — English words and short phrases get UK/US IPA, pronunciation, grouped senses and bilingual examples; a hit skips API/AI translation by default, and the Dictionary settings page manages sources, the system-dictionary guide and the word limit
- **Adaptive glass surface** — native Liquid Glass on macOS 26+ with Swift 6.2+ builds; older macOS versions keep the AppKit `NSVisualEffectView` tooltip material
- **Cache stats** — see how many entries are cached and how much disk they're using, with a one-click clear button
- **Untranslatable detection** — proper nouns / brands / misspellings get a 🔘 marker and skip the cache
- **Theme** — Auto / Light / Dark, applied app-wide

---

## Requirements

- macOS **14.0** (Sonoma) or later
- Apple's on-device translation source requires **macOS 26** plus the matching language pack (System Settings › General › Language & Region › Translation Languages)
- Apple silicon or Intel
- A handful of MB of disk for the local cache
- For AI features: any OpenAI-compatible endpoint (paid or local-LLM)

---

## Privacy

- Jiyi is a **local app**. No telemetry, no analytics, no crash reporters.
- Translation providers (Google, Microsoft, DeepL, your AI endpoint) and the optional Youdao dictionary receive only the text you trigger a lookup for. Apple system translation runs entirely on-device, and the macOS system dictionary lookup also stays on-device. Language detection for the tooltip header and reverse translation runs on-device.
- Network activity beyond translations: once a day, a request to GitHub for the update feed (turn it off in General settings), a small connection-warming request to each enabled provider when you press a hotkey's modifier key, a Youdao dictionary request when a word/phrase lookup runs, and a Youdao audio request when you tap a pronunciation button.
- Cache lives at `~/Library/Caches/io.github.okayzk.Jiyi/translations.json` and `dictionary.json`. Settings live at `~/Library/Preferences/io.github.okayzk.Jiyi.plist`. Delete any of them at any time.
- A diagnostic log is written to `/tmp/jiyi.log`; it includes the first characters of translated text. Delete it whenever you like.

---

## Troubleshooting

- **Hotkeys do nothing** — Accessibility isn't granted (menu bar label → Permissions shows an orange dot), or another app has turned on macOS Secure Keyboard Entry (1Password autofill, Terminal with that option on, a focused password field); settings shows a warning while that's the case.
- **Screenshot translation produces nothing** — check Screen Recording permission, then open `/tmp/jiyi-last-screenshot.png` to see what was captured.
- **Reporting a bug** — attach `/tmp/jiyi.log` (rotates at ~1 MB to `/tmp/jiyi.old.log`).
- **Scripting the AI config** — these environment variables override the saved settings for one run: `JIYI_AI_BASE_URL`, `JIYI_API_KEY`, `JIYI_TEXT_MODEL`, `JIYI_SCREENSHOT_MODEL`, `JIYI_TARGET_LANGUAGE`.

---

## License

Apache 2.0 — see [LICENSE](./LICENSE) for details. This repository is a derivative work of [atst](https://github.com/itaober/atst) by [@itaober](https://github.com/itaober); copyright attribution and the list of modifications are in [NOTICE](./NOTICE).

## Acknowledgments

- macOS [Vision framework](https://developer.apple.com/documentation/vision) for the OCR engine
- [Sparkle](https://sparkle-project.org) for updates (MIT)
- The OpenAI Chat Completions protocol — adopted by virtually every modern LLM endpoint
- **Original project** — [atst](https://github.com/itaober/atst) by [@itaober](https://github.com/itaober). This repository is a secondary development based on it; the original architecture and core translation flow are the original author's work.
- Built with [DeepSeek](https://www.deepseek.com/).
