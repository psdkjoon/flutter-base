# flutter-base

The starting point for my Flutter apps. It is the Flutter `templates/app` folder with my structure, theme, icons, fonts, update check, notifications and Android quick-settings tile already wired together, so a new app starts from the same place as the last one.

This README is also the guide to how I build apps. Follow it and any app of mine, or yours, will look and feel the same.

- [Install and use](#install-and-use)
- [Project structure](#project-structure)
- [Naming and code style](#naming-and-code-style)
- [How the app starts](#how-the-app-starts)
- [app_info.dart](#app_infodart)
- [Theme](#theme)
- [Fonts](#fonts)
- [Icons](#icons)
- [Localization](#localization)
- [About screen](#about-screen)
- [Version checking](#version-checking)
- [Notifications](#notifications)
- [Quick-settings tile](#quick-settings-tile)
- [Release and CI](#release-and-ci)
- [Checklist for a new app](#checklist-for-a-new-app)

## Install and use

`flutter create` renders every file whose path contains `.tmpl` and ignores everything else. It also skips any file that is not listed in `packages/flutter_tools/templates/template_manifest.json`. `tool/install.sh` handles both: it copies this folder over `templates/app` in your SDK and adds the new files to the manifest.

```
bash tool/install.sh
flutter create --org ir.psdkjoon --platforms android,linux,windows my_app
cd my_app
flutter pub get
```

- `--flutter <path>` points the installer at a specific SDK. Without it, it uses the SDK behind `flutter` on your `PATH`.
- Run it again after every `flutter upgrade`, because an upgrade resets the SDK folder.
- `--org` decides the package id. `my_app` becomes `ir.psdkjoon.my_app`, which is used for the Android application id, the Linux application id and the update checker's repository name.

How file names work inside this folder:

| Name | What `flutter create` does |
| --- | --- |
| `file.dart.tmpl` | Renders the mustache variables, drops `.tmpl` |
| `file.png.copy.tmpl` | Copies the file untouched (images, fonts, scripts, the CI workflow) |
| any file inside `android.tmpl/`, `linux.tmpl/` or `windows.tmpl/` | Copied as is, unless it ends in `.tmpl` |
| `README.md`, `tool/` | Not copied to new apps |

Variables in use: `projectName`, `titleCaseProjectName`, `projectNameUpperCamelCase`, `androidIdentifier`, `linuxIdentifier`, `description`, `dartSdkVersionBounds`.

Two limits to keep in mind when editing templates:

- Never write `{{` in a rendered file unless it is a variable. That is why the CI workflow and scripts are `.copy.tmpl`.
- Paths containing `android`, `ios` or `web` are skipped when that platform is not selected, so avoid those words in other file names.

## Project structure

```
lib/
  main.dart                    entry point: open storage, run the app, start platform services
  app.dart                     MaterialApp: theme, locale, localization delegates
  app_info.dart                name, version, author, links, package ids
  core/                        plain Dart with no UI: kv_store, app_dirs, update_checker
  localization/                L10n, the Text and Icon wrappers, one strings_xx.dart per language
  settings/                    app_settings: one ChangeNotifier saved in kv_store
  platform/                    everything that talks to the OS through a channel
  theme/                       catppuccin, app_theme, app_text_style, app_spacing
  ui/                          screens, sheets and dialogs
  ui/widgets/                  small reusable widgets
android/.../EngineHolder.kt    one Flutter engine for the whole process, owns every channel
android/.../QuickTileService.kt
linux/runner/platform.cc       desktop notifications over D-Bus
windows/installer/installer.iss  Inno Setup script for the Windows installer
assets/icons/                  icon SVG sources and generated PNGs
assets/fonts/                  Space Grotesk and the subsetted Noto fonts
scripts/                       generate_icons, subset_fonts, bump_version, appimage, strip, verify-apk
.github/workflows/release.yml  check, build, publish
VERSION                        single line, the version the update checker reads
```

When an app grows, add a folder per feature next to `core/`, `settings/` and `ui/`, named after the thing it manages (`connection/`, `servers/`, `workouts/`). Put the state in a `*_controller.dart` there and the screens in `ui/`. Pure logic with no Flutter import goes in `core/`.

## Naming and code style

**Files** are `snake_case` and end with their role:

| Suffix | Use |
| --- | --- |
| `_screen` | A full page, listed in the app shell |
| `_sheet`, `_dialog`, `_prompt` | Modal bottom sheets, dialogs, one-off prompts |
| `_card`, `_tile`, `_pill`, `_button`, `_view` | Widgets in `ui/widgets/` |
| `_service` | Static wrapper around a platform channel or OS feature (`system_service`, `notification_service`) |
| `_controller` | State holder with a `ChangeNotifier` for one feature |
| `_settings`, `_store`, `_dirs` | Persistence and paths |

**Classes** are `PascalCase` and match the file name. A widget that is only used by one file is private (`_LinkTile`) and lives in that file. Stateless helpers are `abstract class` with only `static` members (`AppInfo`, `AppIcon`, `SystemService`). The class owning the screen is the first one in the file.

**Style**

- No comments in the code. Names and file layout carry the meaning.
- Always import with `package:<app>/...`, never `../`.
- One responsibility per file. If a file needs a section divider, split it.
- Spacing comes from `AppSpacing`, corner radii from `AppRadius`, colors from `Theme.of(context).colorScheme`. A number that is used once and is not a token is a private `static const double _name` on the widget.
- Use `spacing:` on `Row` and `Column`, not `SizedBox` gaps.
- Single quotes, trailing commas, `const` wherever possible. `analysis_options.yaml` turns on strict casts, strict inference and strict raw types, and `flutter analyze` must be clean.
- Import Material with `hide Text, Icon` in any file that shows text, so the translating `Text` and `Icon` from `localization.dart` are used (see [Localization](#localization)).
- No third-party packages unless there is no other way. The template has none.

## How the app starts

`main.dart` does only this:

1. `KvStore.open()` loads a small JSON file from the app data folder.
2. `AppSettings.load(store)` builds the settings, including the language, before the first frame.
3. `runApp(<Name>App(settings: settings))`.
4. `_initPlatform` starts right after `runApp` without blocking: edge-to-edge system UI, then `LauncherIconService.init`.

Add new startup work to `_initPlatform` and keep `main` short. Anything slow must not run before `runApp`.

`app.dart` listens to `AppSettings` and rebuilds `MaterialApp`. It wraps the home page in `KeyedSubtree(key: ValueKey(L10n.code))`, so changing the language rebuilds the whole tree.

`ui/app_shell.dart` is the frame: a `NavigationBar` under 800 logical pixels wide, a sidebar from 800 up. To add a screen, add a `_Destination` and a case in the `switch`. The selected tab is remembered in a static so a language change does not reset it.

`ui/widgets/page_frame.dart` centers page content at 720 wide with the standard padding. `ui/widgets/settings_section.dart` is the titled card used in settings. Build every screen from these two.

## app_info.dart

One place for everything about the app that is not code:

| Field | Used by |
| --- | --- |
| `name` | Window title, about screen, notifications, release asset names. Comes from `titleCaseProjectName` |
| `packageName` | App data folder name, update checker user agent |
| `version` | About screen, update checker. Must equal `VERSION` and `pubspec.yaml` |
| `author`, `githubHandle`, `telegramHandle`, `donateUrl` | About screen links |
| `repoName` | Update checker and the GitHub link. Defaults to the project name |
| `linuxPackageName` | Linux application id |
| `usesNotifications` | `true` makes the shell ask for notification permission at start |

Change the version with `bash scripts/bump_version.sh 1.2.0`. It updates `VERSION`, `pubspec.yaml` and `app_info.dart` together, and CI fails if the three differ.

## Theme

The look is Catppuccin: Mocha when dark, Latte when light, mauve as the accent.

- `catppuccin.dart` holds the two palettes as one `CatppuccinPalette` class.
- `app_theme.dart` turns a palette into a `ThemeData`. Card, chip, navigation bar, sheet, input, divider, list tile and segmented button themes are set there, so widgets rarely style themselves.
- `StatusColors` is a `ThemeExtension` with `success`, `warning` and `heart`. Read it with `Theme.of(context).extension<StatusColors>()!`. Add new semantic colors there, not as raw palette colors in a widget.
- `app_spacing.dart` has `AppSpacing` (a 20 px unit: `xxs 5`, `sm 10`, `md 15`, `lg 20`, `xl 25`, `xxl 35`) and `AppRadius` (`tile 16`, `card 22`, `pill 99`).

Theme mode is Auto, Latte or Mocha, chosen in Settings and stored in `AppSettings.themeMode`.

## Fonts

- **Space Grotesk** (variable) is the default family for Latin text. `pubspec.yaml` lists the same file four times with weights 400, 500, 600 and 700, and `AppTextStyle` sets the exact weight with `FontVariation.weight`.
- **Noto Sans** (Latin and Cyrillic) and **Noto Sans Arabic** are the fallback chain (`AppTextStyle.fontFallback`). Any glyph Space Grotesk lacks is drawn by them. They are subsetted, so they are small.
- `AppTextStyle.fontFamily` switches the primary family by language: Persian uses Noto Sans Arabic, Russian uses Noto Sans, everything else uses Space Grotesk.
- Sizes go through one scale: `size * 1.2 - 2`. Only the text styles the theme actually uses are defined. Add a new one to `AppTextStyle` and to its `textTheme`.
- In widgets use `theme.textTheme.<style>?.copyWith(color: ...)`, never a raw `TextStyle` with a font size.

To add a language that needs another script:

1. Download the original fonts and run `python3 scripts/subset_fonts.py --src <folder>`. The script keeps the script ranges for Latin, Cyrillic and Arabic plus every non-ASCII character found in `lib/`.
2. For Chinese or Japanese add `--cjk sc jp`. These fonts only keep the characters your strings use, so rerun the script whenever you add text.
3. Add the new family to `pubspec.yaml` and to `AppTextStyle`.

## Icons

**The icon theme.** Every icon is a rounded square filling the whole canvas, with one glyph in the middle.

- The source is a `24 x 24` SVG: a `rect id="tile"` with `rx="6.16"`, a `path id="glyph"` in the accent color, and an optional `id="detail"` shape in the tile color that cuts a hole in the glyph.
- The glyph covers about 60% to 70% of the tile and sits in the center.
- Mocha: tile `#342e46`, glyph `#cba6f7`. Latte: tile `#d6ccef`, glyph `#8839ef`.
- Corners are transparent. There is no padding and no adaptive-icon layer.

Edit `assets/icons/icon_mocha.svg` and `icon_latte.svg` (keep the three ids), then run:

```
python3 scripts/generate_icons.py
```

It needs Pillow and one SVG renderer (`rsvg-convert`, `inkscape`, `magick` or `python-cairosvg`). On Arch: `sudo pacman -S python-pillow librsvg`. It writes:

| Output | Used for |
| --- | --- |
| `assets/icons/logo_mocha.png`, `logo_latte.png` (1024) | In-app logo, about screen, home screen |
| `assets/icons/tray_mocha.png`, `tray_latte.png` (256) | System tray icons if the app adds a tray |
| `android/.../mipmap-*/ic_launcher.png` (48 to 192) | Default launcher icon (Mocha) |
| `android/.../mipmap-*/ic_launcher_mocha.png`, `ic_launcher_latte.png` | The two launcher icons that switch with the theme, and the splash screen |
| `android/.../drawable/ic_tile.xml` | White glyph for the quick tile and notification small icon |
| `linux/icon.png` (256) | AppImage and desktop entry |
| `windows/runner/resources/app_icon.ico` | Windows executable |

**Using the icon in the app.** Never reference an asset path in a widget. Use `AppIcon`:

```dart
Image.asset(AppIcon.logo(Theme.of(context).brightness))
```

**Changing the launcher icon with the theme (Android).** The manifest has two `activity-alias` entries, `IconMocha` (enabled) and `IconLatte` (disabled), each with its own icon. `LauncherIconService` follows `AppSettings.themeMode` and the system brightness and tells Android to enable the alias that matches. Two rules matter:

- The swap happens only when the app goes to the background. Switching aliases while the app is open can make some launchers close it.
- Pass `canApply` to `LauncherIconService.init` when the app has a state where it must not be touched (a running connection, a recording). It is checked at every attempt, and `refreshOn` lets a listenable trigger a retry.

On Linux and Windows the icon is a single static file, so there is nothing to switch. The splash screen follows the system theme through `drawable` and `drawable-night`.

## Localization

All user-facing text is written in English in the code and translated at display time.

```dart
import 'package:flutter/material.dart' hide Text, Icon;
import 'package:my_app/localization/localization.dart';

const Text('Settings');
Text('Version ${AppInfo.version}');
final label = 'Copy link'.tr;
```

`Text` and `Icon` in `localization.dart` replace the Flutter ones: `Text` runs its string through `L10n.tr`, and `Icon` always draws left to right. A string with a variable part is matched by pattern, so a table entry `'Version {}'` translates `'Version 1.0.0'`.

To add a language:

1. Create `lib/localization/strings_xx.dart` with `const Map<String, String> stringsXx = {'English text': 'translated text'};`.
2. Register it in `L10n.languages` and `L10n._tables`.
3. Add its glyph and font family to `_glyphs` and `_families` in `ui/language_sheet.dart`, and its font to `AppTextStyle.fontFamily` if it needs one.
4. Rerun `scripts/subset_fonts.py`.

The Language section in Settings only appears once there are two or more languages. Right-to-left codes are listed in `L10n._rtlCodes`.

## About screen

`ui/about_screen.dart` is built entirely from `AppInfo`: logo (theme aware), name, version, a "Made with love by" card with an animated gradient and beating hearts, link tiles with copy buttons (GitHub, Telegram, Donate) and the floating "Built with" bubbles.

To change what it credits, edit the `_sources` list: `_Source(name, detail, size, x, y, phase)`. `size` is the bubble diameter in pixels, `x` and `y` are fractions (0 to 1) of the field, `phase` offsets the float animation. Keep centers at least the sum of the two radii apart so bubbles do not overlap.

## Version checking

The app compares its own `AppInfo.version` with the `VERSION` file on the `main` branch of its GitHub repository.

1. At start, `UpdatePrompt.run` (called from `AppShell`) asks `UpdateChecker.check()`, unless the user turned off Settings, Updates.
2. The checker downloads `https://raw.githubusercontent.com/<githubHandle>/<repoName>/main/VERSION` with timeouts. Any error returns `null`, so a failed check never bothers the user.
3. A newer version (compared number by number, `v` prefix and `+build` ignored) is looked up on the release `v<version>`. The checker picks the asset that fits the device:
   - Android: `.apk` containing the device ABI (`arm64-v8a`, `armeabi-v7a`, `x86_64`), else one containing `universal`
   - Linux: `.AppImage` containing `x86_64` or `aarch64`
   - Windows: `.exe` containing `windows` (the installer)
   - If there is no matching asset or the API fails, it falls back to the release page.
4. A dialog offers Later or Download. Download opens the URL with `SystemService.openUrl`. Nothing installs by itself.

For this to work a release must be named like this (the workflow already does it):

| Platform | Asset |
| --- | --- |
| Android | `<Name>-arm64-v8a.apk`, `<Name>-armeabi-v7a.apk`, `<Name>-x86_64.apk`, `<Name>-universal.apk` |
| Linux | `<Name>-x86_64.AppImage`, `<Name>-aarch64.AppImage` |
| Windows | `<Name>-windows-x64-setup.exe` |

and the tag is `v` plus the content of `VERSION`.

## Notifications

Set `AppInfo.usesNotifications = true` if the app shows any. Then the shell asks for the Android 13+ permission once at start. Apps that never notify leave it `false` and never prompt.

`NotificationService` has three calls:

```dart
NotificationService.show('Title'.tr, 'Body'.tr);

NotificationService.follow<Status>(
  controller,
  () => controller.status,
  (previous, current) => switch (current) {
    Status.done => (title: '${AppInfo.name} finished'.tr, body: 'Your task is done.'.tr),
    _ => null,
  },
);
```

`follow` watches any `Listenable`, calls your builder only when the value changes, and sends a notification when the builder returns a message. Rules I follow:

- Notify on a change of state, never on every update.
- Return `null` for states that need no notification (a start-up state, "connecting").
- Titles start with `AppInfo.name`. Texts are short sentences that go through `.tr`.
- Android posts a normal notification on the `general` channel with the `ic_tile` glyph as the small icon, and tapping it opens the app. Linux sends it over D-Bus (`org.freedesktop.Notifications`) from `linux/runner/platform.cc`, so no extra package is needed. Windows does nothing.
- A long-running Android job (a VPN, a download) uses a foreground service with its own ongoing notification in Kotlin, not this service.

## Quick-settings tile

Android only. The tile is already in the manifest as `QuickTileService`, but disabled, so apps without a tile do not show one. To use it:

```dart
await QuickTileService.init(controller.toggle);
await QuickTileService.enable();
controller.addListener(() => QuickTileService.setState(
      switch (controller.status) {
        Status.idle => TileState.off,
        Status.working => TileState.busy,
        Status.active => TileState.on,
      },
    ));
```

- `init` registers the function that runs when the tile is tapped. It also runs it once if the tap started the app.
- `enable` turns the tile on in the system list. Call it once, for example from a settings switch or the first launch. The user then adds it from the quick-settings edit screen.
- `setState` keeps the tile in sync: `off` is inactive, `busy` and `on` are active. The subtitle comes from `tile_off`, `tile_busy` and `tile_on` in `res/values/strings.xml`.

How it works:

- A tile tap with the app running calls `toggleRequested` on the existing engine.
- A tap with the app closed starts the process. `MainApplication` creates the engine through `EngineHolder`, Dart starts, and `init` asks `consumeToggle` whether a tap is waiting.
- This is why `EngineHolder` keeps one engine for the whole process and `MainActivity` never destroys it. If an app needs no tile, no background work and no notifications from the background, delete `MainApplication` and let `MainActivity` use the default engine.

Rules for the toggle function: it must be safe to call while busy, and it must set the state it ends in so the tile never stays in `busy`. The tile label is always the app name, and the icon is `ic_tile.xml`.

## Release and CI

`.github/workflows/release.yml` runs on every push to `main` and on pull requests.

1. `check`: `VERSION`, `pubspec.yaml` and `app_info.dart` match, then `flutter pub get` and `flutter analyze`, and `flutter test` if `test/` exists.
2. `android`: universal and split-per-ABI APKs. With the signing secrets set, `scripts/strip.sh` strips, aligns and signs them as `<Name>-<abi>.apk` and `scripts/verify-apk.sh` checks the native libraries.
3. `linux`: x86_64 and aarch64 builds, packaged as AppImages by `scripts/appimage.sh`. The AppImage installs its own menu entry on first launch.
4. `windows`: builds the release folder, bundles the Visual C++ runtime, wraps it in an installer with [Inno Setup](https://jrsoftware.org/isinfo.php), then silently installs it, checks the files, starts the app for a few seconds and uninstalls it. The installer is the only Windows file published.
5. `release` (only on `main`): tags `v<VERSION>` and publishes everything to GitHub Releases.

Secrets for signed Android builds: `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`. Locally, create `android/key.properties` with `storeFile`, `storePassword`, `keyAlias` and `keyPassword`. Without it, release builds are signed with the debug key.

`FLUTTER_VERSION` at the top of the workflow pins the Flutter version in CI.

**Windows installer.** `windows/installer/installer.iss` is generic. The workflow passes everything that changes per app as `/D` defines, so the script itself never needs editing:

| Define | Value in CI |
| --- | --- |
| `AppName` | `AppInfo.name`, read from `lib/app_info.dart` |
| `AppExe` | `<project name>.exe`, read from `pubspec.yaml` |
| `AppVersion` | the content of `VERSION` |
| `AppGuid` | a GUID made from the repository name, so every app gets its own stable uninstall identity and an update installs over the old version |
| `AppPublisher`, `AppUrl` | the repository owner and URL |
| `OutputBaseName` | `<Name>-windows-x64-setup` |

The installer needs no administrator rights by default (per-user install in `%LocalAppData%\Programs`) and offers to install for all users through the standard dialog. It adds a Start menu entry, an optional desktop icon and an uninstaller. If the app creates a single-instance mutex, pass `/DAppMutex=<name>` so the installer asks to close a running copy first.

To build it locally on Windows: `iscc /DAppName=MyApp /DAppExe=my_app.exe /DAppVersion=1.0.0 windows\installer\installer.iss` after `flutter build windows --release`.

The installer is not code signed, so Windows SmartScreen warns on first run. Signing needs a certificate, which this template does not assume.

## Checklist for a new app

1. `bash tool/install.sh`, then `flutter create --org ir.psdkjoon --platforms android,linux,windows <name>`.
2. Edit `lib/app_info.dart`: confirm `name`, `githubHandle` and `repoName`.
3. Replace the glyph in `assets/icons/icon_mocha.svg` and `icon_latte.svg`, then `python3 scripts/generate_icons.py`.
4. Replace `HomeScreen` and add screens to `AppShell`.
5. Set `AppInfo.usesNotifications` if needed and wire `NotificationService`.
6. Wire `QuickTileService` if the app has a tile.
7. Edit `_sources` in the about screen for what the app uses.
8. Create the GitHub repository named `repoName`, add the signing secrets, push to `main`. The release job refuses to publish without the Android signing secrets. For an app without Android, delete the `android` job and its entries in `release`.
