# Template guide

Rules for anyone (or any AI) turning this template into an app.

## Platform and delivery

The finished project is Android only, unless the user asks for Linux or Windows.

- Delete `linux/`, `windows/`, `scripts/appimage.sh` and the Linux and Windows jobs in `.github/workflows/release.yml`. Keep them only for a platform the user asked for.
- The result is one `.7z` file, named `<projectName>.7z`, with a single top-level folder `<projectName>/` that has `pubspec.yaml` at its root.
- The user must be able to run it with exactly two commands, from inside that folder:

  ```
  f create --org ir.psdkjoon .
  f run --release
  ```

- That only works if:
  - Every `{{placeholder}}` is replaced. `{{androidIdentifier}}` is `ir.psdkjoon.<projectName>`, so it matches `--org ir.psdkjoon`.
  - The folder is named `<projectName>`, the same as `name:` in `pubspec.yaml`. `f create .` takes the app name from it.
  - The Kotlin files sit in `android/app/src/main/kotlin/ir/psdkjoon/<projectName>/`. In the template that folder is called `androidIdentifier`: rename it to the package path (dots become slashes). `f create` adds its own `MainActivity.kt` at exactly that path when none is there, and a second `MainActivity` in the same package fails the build.
  - The folder holds source only: no `build/`, `.dart_tool/`, `.gradle/`, `.idea/`, `key.properties`, keystores or `local.properties`.
  - Nothing in it needs another step first (no code generation, no scripts to run, no manual file copying).
- Build the archive from outside the project folder: `7z a -t7z <projectName>.7z <projectName>/`.
- Do not hand over a `.zip` or a bare folder instead of the `.7z`.

## Android folder

There is one Android folder, `android/`, laid out like any Flutter project: `build.gradle.kts`, `app/build.gradle.kts`, `app/src/main/` with the manifest, `res/` and `kotlin/`. There is no `android-kotlin/` folder.

`f create` fills in what the template leaves out (`settings.gradle.kts`, `gradle.properties`, the Gradle wrapper, `.metadata`, and so on). It never overwrites a file that already exists, so every file listed above must be in the project already.

## Launch and splash

- The app has no splash screen. Do not add a splash drawable, a logo, a `SplashScreenDrawable` meta-data entry or any other launch image.
- `LaunchTheme` and `NormalTheme` both use the plain `window_bg` color (Mocha or Latte), so nothing flashes between launch and the first frame.
- Android 12+ always draws a starting window. `values-v31/styles.xml` makes it blank (`window_bg` with `blank_icon`). Leave that in place, because removing it makes the system draw the app icon.

## Theme sync

Syncing the accent and theme between apps must change the app's UI, not only the launcher icon, the first time the user opens the app.

- Native code (`ThemeSync.kt`) stores the newest look in `files/theme_sync.json`, even while Dart is not running.
- `main.dart` calls `ThemeSyncService.adoptStored` before `runApp`, so the first frame already uses it.
- `ThemeSyncService` syncs again every time the app comes back to the foreground. A stopped or frozen app misses the "changed" broadcast.
- An adopted look is written to disk at once (`AppSettings.flush`). Android can stop the process right after a background refresh.
- Native code also syncs without Dart. `ThemeSync.pull` works when the app has no `theme_sync.json` yet (a fresh install), so a sibling's poke is enough for a new app to take the accent and switch its icon.
- A running app watches for a new sibling being installed (`ThemeSync.watchInstalls`) and wakes it with `FLAG_INCLUDE_STOPPED_PACKAGES`. A never-opened app is in the stopped state and gets no broadcast otherwise. This is best effort: it needs one sibling process alive at that moment. If none is, the new app syncs on its first open.
- Do not remove any of these.

## Kotlin

- Give `arrayOf` an explicit element type when the values have different types: `arrayOf<Any>(text, number)`. Without it, Kotlin infers an intersection type for the reified parameter and newer Kotlin versions fail the build (`Type argument for reified type parameter 'T' was inferred to the intersection of ...`). This applies to `MatrixCursor.addRow` in `ThemeSync.kt`.

## Persian (fa)

- Persian shows Persian digits (۰۱۲۳۴۵۶۷۸۹), never 0-9.
- `L10n.tr` / the `Text` widget from `localization.dart` already convert digits, so show every number through them.
- A number built in code and shown through plain `w.Text` must go through `L10n.digits(...)` first.
- Words containing `/`, `@` or a Latin letter (links, handles, wallet addresses, names like TRC-20) keep their ASCII digits on purpose.
- Persian text uses pure Persian words. Do not use Arabic loanwords when a Persian word exists, and do not write a foreign word where a Persian one is in use. Examples: `مهر` not `عشق`, `نگارش` not `نسخه`, `بارگیری` not `دانلود`, `رونوشت` not `کپی`, `پوسته` not `تم`, `پروانه` not `اجازه`, `لغزش` not `خطا`, `برگه` not `صفحه`.
- Proper names (people, products, fonts such as Catppuccin or Space Grotesk) stay as they are.
- Run every new Persian string through this rule before adding it to `strings_fa.dart`.

## Settings screen order

The sections of the settings screen always appear in this order:

1. Appearance (first)
2. Language (second, shown only while the app has more than one language)
3. Any app-specific sections
4. Updates, with "Check for updates" (last of the settings)

The About block (links, diagnostics, the app mark and version, the love card) follows the settings on the same screen. There is no separate About screen, no moving bubbles and no "Built with" credits area.

New sections go between Language and Updates. Inside Appearance the order is theme mode, accent color, then sync theme.

## Dependencies and checks

- `pubspec.yaml` has no `dev_dependencies`: no `flutter_test`, no `flutter_lints`.
- `analysis_options.yaml` does not `include:` `flutter_lints`.
- Do not add a `test/` folder, and do not add test steps to CI.

## No helper scripts in the result

- Python (or any other) scripts used to generate icons, strings or assets are for building only.
- Run them from outside the project folder, or delete them before finishing. The final project contains no `.py` files.
- The only scripts that stay are the shell scripts in `scripts/` that release CI uses.

## Icons

- Change the icon on the real app: the files `appIcon` points to (`android/app/src/main/res/mipmap-*`), `assets/icons/*.svg`, and the Linux and Windows icons.
- Never "change" the icon by adding an `activity-alias` or any other launcher entry. Aliases leave the old icon in Settings and create duplicate launcher entries.
- The existing `Icon<Accent><Mode>` aliases are the template's accent-follow feature. Leave them as they are, or remove the whole feature (manifest aliases, `LauncherIcon.kt`, `launcher_icon_service.dart`, the `ic_launcher_<accent>_<mode>` mipmaps). Do not add new ones.

## Background work

If the app has to keep working with the screen off (foreground service, reminders, alarms, scheduled work, boot start):

1. Set `AppInfo.usesBackground = true`. On start the app then asks for notifications, for exemption from battery optimization, and for exact alarms (Android 12+).
2. Check `AndroidManifest.xml` has what the app uses. It already declares `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_DATA_SYNC`, `FOREGROUND_SERVICE_MEDIA_PLAYBACK`, `WAKE_LOCK`, `RECEIVE_BOOT_COMPLETED`, `SCHEDULE_EXACT_ALARM`, `POST_NOTIFICATIONS` and `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`.
3. A new kind of foreground service needs its own `FOREGROUND_SERVICE_<TYPE>` permission and matching `android:foregroundServiceType` on the `<service>`.
4. Remove permissions the finished app does not use.

## Bottom bar

- On narrow screens the app uses the compact 56 dp bar (`_CompactBar` in `app_shell.dart`), not Material's 80 dp `NavigationBar`. Only the selected destination shows its name.
- From 800 dp wide it switches to the sidebar.
- The app has two destinations, Home and Settings. Keep it to 2 to 5. Do not go back to `NavigationBar`.

## Donations

The Links section at the bottom of Settings has two donation entries and they stay in this order:

1. **Donate (Iran):** `AppInfo.donateIranUrl`, a Daramet page. Iranian payments cannot use the international options.
2. **Donate (crypto):** opens `donate_sheet.dart`, which lists `AppInfo.wallets` with a copy button for each. Bitcoin on the Bitcoin network, USDT on TRON (TRC-20), USDC on Base.

Rules:
- Every wallet shows its network next to the address. Money sent on the wrong network is lost.
- Addresses are displayed left to right in every language, and never digit-converted.
- Check an address before adding it: Bitcoin (bech32 checksum), TRON (base58check, starts with `T`, 34 characters), Base/Ethereum (`0x` plus 40 hex, EIP-55 checksum).
- Do not put a wallet address in an app that is not the owner's. Replace the three wallets and the Daramet handle when the template is used for someone else.
- Coin marks are single-color SVGs in `assets/icons/coins/` (`btc.svg`, `usdt.svg`, `usdc.svg`), the glyph only with the colored disc removed. `flutter_svg` tints them with the accent, so they follow the theme. Get coin artwork from the project's own brand page and respect its terms; do not redraw it.
- `flutter_svg` is the only dependency besides Flutter itself.
