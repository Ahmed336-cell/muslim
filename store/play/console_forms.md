# Play Console — "App content" answers

Policy → App content. Answers below match what the code does today; re-check if features change.

## Privacy policy
URL of the hosted `privacy_policy.html` (GitHub Pages, Netlify, or any site you own).

## Ads
**No**, the app does not contain ads.

## App access
**All functionality is available without special access** (no login).

## Content rating (IARC questionnaire)
- Category: **Reference, News, or Educational**
- Violence, sexuality, language, drugs, gambling: **No** to all
- User-generated content / users can interact: **No**
- Shares location with other users: **No**
- Digital purchases: **No**
- Expected result: Everyone / PEGI 3

## Target audience and content
- Target age groups: **18 and over** (optionally 13–17 as well).
- Do **not** select under-13 groups: that puts the app under the Families policy
  (extra review, certified ad SDKs, teacher-approved rules).
- "Could the app unintentionally appeal to children?" → **Yes**, because of the Kids' corner.
  Explain: "Religious reference app for adults; includes an optional section for parents to
  use with their children. No ads, no data collection, no accounts."

## Data safety
Data collected: **Yes** (only location, see below). Data shared: **No**.
Encrypted in transit: **Yes** (all HTTPS). Users can request deletion: no account, no server
data → choose "No" for deletion request and explain data is not stored.

| Data type | Collected | Shared | Optional? | Processed ephemerally | Purpose |
|---|---|---|---|---|---|
| Location → Approximate location | Yes | No | Yes (user can pick a city) | Yes | App functionality |
| Location → Precise location | No (rounded to ~100 m before sending) | No | — | — | — |
| Audio (voice recordings) | No (processed only on device) | No | — | — | — |
| Everything else (personal info, contacts, app activity, device IDs, etc.) | No | No | — | — | — |

## Permissions declarations
- **Foreground service (media playback)** — `FOREGROUND_SERVICE_MEDIA_PLAYBACK`:
  Play asks for a description + short video. "Plays Quran recitation and adhan audio while
  the app is in the background or the screen is off, with media controls in the notification."
  Record a 30 s screen video: start a recitation, lock the phone, show the media notification.
- **Exact alarms** (if Play asks — scheduled adhan uses exact timing): "Adhan and prayer
  reminders must fire at the exact prayer time." Prayer-time apps qualify as alarm/reminder use.
- **Microphone** — runtime permission only; no form, but mention in the description (done).
- **Location** — foreground only; no background location form needed.

## Government apps / financial features / health
No / none / none.

## News app
No.
