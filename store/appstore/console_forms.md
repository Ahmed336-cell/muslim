# App Store Connect — forms & review answers

Matches the app as of October 2026. Re-check if features change.

## Privacy Policy URL
Same hosted page as Play (`privacy_policy.html` via GitHub Pages or your site).  
Contact in the policy: `ahmaher04@gmail.com`

## App Privacy (nutrition labels)

**Does this app collect data?** → **Yes** (location only, optional).

**Data Used to Track You:** **No**  
**Data Linked to You:** **No** (no accounts)

| Data type | Collected | Linked to identity | Used for tracking | Purpose |
|---|---|---|---|---|
| Location → Precise Location | Yes (optional; user can pick a city instead) | No | No | App Functionality |
| Location → Coarse Location | No separate collection | — | — | — |
| Audio Data | **No** (hifz recitation is processed only on device and not stored) | — | — | — |
| Contact Info, Identifiers, Purchases, Usage, Diagnostics, etc. | **No** | — | — | — |

Product Page disclosure: you may leave “Privacy Nutrition Labels” as above; there is no account deletion flow because nothing is stored on a server.

## Age Rating
Questionnaire → expect **4+**.
- Unrestricted web access: No
- User-generated content / social: No
- Gambling, violence, etc.: No
- Medical/treatment information: No (ruqyah is religious text, not a medical claim — answer No to health/medical treatment features)

## Advertising
**No** — the app does not show ads and does not use advertising identifiers.

## Content Rights
You have the rights to the branding, icons, and bundled content you ship.  
**Note:** confirm the English Riyad as-Salihin licence before relying on it publicly (same note as Play).

## Export Compliance
**Does your app use encryption?** → Yes (HTTPS only / standard OS crypto).  
**Is it exempt?** → Yes.  
Info.plist already has `ITSAppUsesNonExemptEncryption` = `false`, so App Store Connect should not ask every upload. If it still asks: select exemption for HTTPS / encryption limited to Apple OS APIs.

## App Encryption Documentation
Not required with the exemption above.

## Pricing
Free. No In-App Purchases. No subscriptions.

## Availability
All countries/regions you want (typically all).  
Devices: iPhone (iPad supported by the binary; you may uncheck iPad in Availability if you have no iPad screenshots).

## App Review Information

**Sign-in required?** No.

**Contact**
- First / last name: your name
- Phone: a number Apple can reach
- Email: `ahmaher04@gmail.com`

**Notes for Review** (paste):
```
Sabeelak is a free Islamic companion app with no accounts and no ads.

Demo:
1. On first launch, choose English or Arabic and pick a city (e.g. Cairo) or allow location.
2. Home shows the next prayer and features. Prayer tab: times and tracker. More: settings, reminders, widgets help.
3. Quran → Mushaf / Reciters / Hifz. Hifz “recite check” uses the microphone; audio is processed only on-device (Privacy Manifest + privacy policy).
4. Notifications: enable in Settings if prompted — adhan and Friday reminders are local (no push server).
5. Home Screen widgets need the App Group group.com.elmoahm.sabeelk (already in the build).

No special credentials. No backend login. Optional network for prayer/content APIs and Quran audio downloads.
```

**Attachment:** none required. Optional: a short screen recording of adhan notification + widget.

## Sign-in / Access
Not applicable.

## Government / Gaming / Health
None.

## Third-party content
Quran text/audio and API content from providers listed in the privacy policy (alquran.cloud, quran.com, islamicapi.com, etc.).
