# Google Play — publish checklist (Sabeelak)

## 1. Blockers in the project
- [ ] **Application ID.** `com.example.muslim` is rejected by Play. Pick a permanent ID
      (e.g. `com.yourname.sabeelak`). It can never change after the first upload.
      Change `applicationId` in `android/app/build.gradle.kts` (namespace can stay).
- [ ] **Upload key.** Create once, back it up (losing it = contact Play support):
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
- [ ] **Version.** `pubspec.yaml` → `version: 1.0.0+1`. Bump the `+N` build number on every upload.
- [ ] **Build the bundle** (Play wants AAB, not APK):
      ```
      flutter build appbundle --release
      ```
      Output: `build/app/outputs/bundle/release/app-release.aab`
- [ ] **API key.** `assets/env/env.json` is bundled inside the app, so anyone can extract it.
      Use a key restricted to this app / with quotas, not a personal master key.
- [ ] **Hadith licence.** Riyad as-Salihin English text comes from a scraped dataset with
      no clear licence; confirm rights or remove before going public.

## 2. Play Console setup
- [ ] Developer account ($25 one-time), identity verified.
- [ ] **New personal accounts:** must run a **closed test with ≥12 testers for 14 days**
      before production access is granted. Start this early.
- [ ] Create app → name `Sabeelak: Prayer, Quran, Azkar`, default language, App, Free.
- [ ] Play App Signing: accept (Google holds the app signing key; you keep the upload key).

## 3. Store listing (text in `listing.md`)
- [ ] App name, short + full description — en and ar
- [ ] App icon `graphics/app_icon_512.png`
- [ ] Feature graphic `graphics/feature_graphic_en.jpg` / `_ar.jpg`
- [ ] 2–8 phone screenshots per language → `screenshots/{en,ar}/` (run `frame.swift`)
- [ ] Category Lifestyle, contact email, privacy policy URL

## 4. App content (answers in `console_forms.md`)
- [ ] Privacy policy URL — host `privacy_policy.html` (replace `YOUR_EMAIL@example.com` first)
- [ ] Ads: No · App access: no login
- [ ] Content rating questionnaire
- [ ] Target audience (18+, note the Kids' corner)
- [ ] Data safety form
- [ ] Foreground service (media playback) declaration + video
- [ ] Exact alarm declaration if asked

## 5. Release
- [ ] Internal testing → upload AAB, install from Play on a real phone, check adhan,
      widgets, notifications, Arabic/RTL, dark mode.
- [ ] Closed testing (12 testers × 14 days if required) → apply for production.
- [ ] Production release with release notes from `listing.md`; staged rollout 20% → 100%.
