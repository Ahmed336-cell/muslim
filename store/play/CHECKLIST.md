# Google Play — publish checklist (Sabeelak)

## 1. Blockers in the project
- [x] **Application ID.** `com.elmoahm.sabeelk` (Android + iOS). Never changes after first upload.
- [x] **Upload key.** Create once, back it up (losing it = contact Play support):
      ```
      keytool -genkey -v -keystore ~/sabeelak-upload.jks -keyalg RSA -keysize 2048 \
        -validity 10000 -alias upload
      ```
      Then create `android/key.properties` (gitignored):
      ```
      storePassword=…
      keyPassword=…
      keyAlias=upload
      storeFile=/Users/you/sabeelak-upload.jks
      ```
      `build.gradle.kts` already uses it when present.
- [x] **Version.** `pubspec.yaml` → `version: 1.0.0+1`. Bump the `+N` build number on every upload.
- [ ] **Build the bundle** — rebuild after adding `env.json` (Play wants AAB, not APK):
      ```
      flutter build appbundle --release
      ```
      Output: `build/app/outputs/bundle/release/app-release.aab`
- [ ] **API key.** `assets/env/env.json` is currently MISSING — prayer times, fasting, nisab,
      names, duas and ruqyah calls fail with `missing_key`. Restore it, then rebuild.
      It is bundled inside the app, so anyone can extract it.
      Use a key restricted to this app / with quotas, not a personal master key.
- [ ] **Hadith licence.** Riyad as-Salihin English text comes from a scraped dataset with
      no clear licence; confirm rights or remove before going public.

## 2. Play Console setup
- [x] Developer account ($25 one-time), identity verified.
- [x] **New personal accounts:** must run a **closed test with ≥12 testers for 14 days**
      before production access is granted. Start this early.
- [x] Create app → name `Sabeelak: Prayer, Quran, Azkar`, default language, App, Free.
- [x] Play App Signing: accept (Google holds the app signing key; you keep the upload key).

## 3. Store listing (text in `listing.md`)
- [x] App name, short + full description — en and ar
- [x] App icon `graphics/app_icon_512.png`
- [x] Feature graphic `graphics/feature_graphic_en.jpg` / `_ar.jpg`
- [x] 2–8 phone screenshots per language → `screenshots/{en,ar}/` (run `frame.swift`)
- [x] Category Lifestyle, contact email, privacy policy URL

## 4. App content (answers in `console_forms.md`)
- [x] Privacy policy URL — host `privacy_policy.html` via `.github/workflows/privacy-policy.yml` (email already set)
- [x] Ads: No · App access: no login
- [x] Content rating questionnaire
- [x] Target audience (18+, note the Kids' corner)
- [x] Data safety form
- [x] Foreground service (media playback) declaration + video
- [x] Exact alarm declaration if asked

## 5. Release
- [ ] Internal testing → upload AAB, install from Play on a real phone, check adhan,
      widgets, notifications, Arabic/RTL, dark mode.
- [ ] Closed testing (12 testers × 14 days if required) → apply for production.
- [ ] Production release with release notes from `listing.md`; staged rollout 20% → 100%.
