# App Store — publish checklist (Sabeelak / سبيلك)

Bundle ID: `com.elmoahm.sabeelk`  
Team ID: `3J4N6PL7CX`  
Widget extension: `com.elmoahm.sabeelk.MuslimWidgets`  
App Group: `group.com.elmoahm.sabeelk`

## 1. Apple Developer account
- [ ] Paid Apple Developer Program membership ($99/year), identity verified.
- [ ] Sign in to [App Store Connect](https://appstoreconnect.apple.com) with the same Apple ID.
- [ ] In [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list):
  - [ ] App ID `com.elmoahm.sabeelk` — enable **App Groups**, **Push Notifications** (if you later add remote push; local notifications do not need it), **Associated Domains** only if used.
  - [ ] App ID `com.elmoahm.sabeelk.MuslimWidgets`
  - [ ] App Group `group.com.elmoahm.sabeelk` linked to both App IDs
- [ ] Xcode → Settings → Accounts → download profiles (Automatic signing is already on in the project).

## 2. App Store Connect — create the app
- [ ] My Apps → **+** → New App
  - Platforms: **iOS**
  - Name: `Sabeelak` (or `سبيلك` as primary if Arabic is primary locale)
  - Primary language: **Arabic** or **English (U.K.)**
  - Bundle ID: `com.elmoahm.sabeelk`
  - SKU: `sabeelak-ios` (any unique string; never shown to users)
  - User Access: Full Access

## 3. Project / build (already prepared in repo)
- [x] Bundle ID `com.elmoahm.sabeelk` + widgets + App Group
- [x] Display name: Sabeelak / سبيلك (`InfoPlist.strings`)
- [x] Usage strings: Location, Microphone, Camera
- [x] `ITSAppUsesNonExemptEncryption` = false (export compliance)
- [x] `PrivacyInfo.xcprivacy` (no tracking; location for app functionality; required-reason APIs)
- [x] App Store icon 1024×1024 **without alpha** → `graphics/app_icon_1024.png`
- [x] Phone screenshots 1290×2796 (6.7") → `screenshots/{en,ar}/`
- [x] Listing text, privacy answers, review notes → `listing.md`, `console_forms.md`
- [ ] `assets/env/env.json` present with API key before release build
- [ ] Bump `pubspec.yaml` version if needed (`1.0.0+N` — `+N` must increase every upload)

## 4. Build & upload
```bash
# From project root. Uses Automatic signing + team 3J4N6PL7CX.
flutter build ipa --release --export-options-plist=store/appstore/exportOptions.plist
```
- Output: `build/ios/ipa/*.ipa`
- Or open `ios/Runner.xcworkspace` → Product → Archive → Distribute App → App Store Connect.
- Wait for processing in App Store Connect → TestFlight (often 5–30 min).

## 5. App Store listing (paste from `listing.md`)
- [ ] Name, subtitle, promotional text, description — **English (U.K.)** and **Arabic**
- [ ] Keywords
- [ ] Support URL (required) — e.g. `mailto:ahmaher04@gmail.com` or a simple page
- [ ] Privacy Policy URL — hosted `privacy_policy.html` (same as Play / GitHub Pages)
- [ ] Category: **Lifestyle** (secondary: Reference / Education)
- [ ] Copyright: `© 2026 Ahmed Maher` (or your legal name)
- [ ] App icon 1024×1024 (no transparency)
- [ ] Screenshots: at least **one** size — 6.7" (1290×2796) prepared; add 6.5" / iPad if you target iPad

## 6. App Privacy & age (answers in `console_forms.md`)
- [ ] App Privacy nutrition labels
- [ ] Age Rating questionnaire → expect **4+**
- [ ] Content Rights / Ads: No
- [ ] Export Compliance: No non-exempt encryption (Info.plist already set)

## 7. Review & release
- [ ] TestFlight internal / external build smoke-tested (adhan, widgets, Arabic RTL, hifz mic, notifications)
- [ ] App Review Information: contact email/phone, demo notes from `console_forms.md`
- [ ] Submit for Review → once Approved, release manually or automatically
- [ ] What’s New from `listing.md`

## Notes
- Losing the Apple Developer account or App ID is recoverable; losing Play’s upload key is harder — keep both backed up.
- Home-screen widgets need the App Group registered on both App IDs or widgets stay empty on device.
- Qibla is currently hidden in the app (`qiblaEnabled = false`); do not advertise it in the listing until it is back.
