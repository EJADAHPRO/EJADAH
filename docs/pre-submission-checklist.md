# Store-submission checklist

What must be true before Ejadah is submitted to the App Store and Google Play.

Kept separate from `implementation-status.md` on purpose: that document says what
is built, this one says what must be true before anyone can install it. Nothing
here blocks development.

Each item says who can close it — **repo** (a change in this repository),
**owner** (an asset, an account or a credential only the owner has), or
**both**.

---

## 0 · What is already true

Written down because a checklist of gaps reads as though nothing is ready, and
several of the store's harder requirements are already met.

- **In-app account deletion** exists and reaches a real endpoint —
  `apps/mobile/lib/features/profile/presentation/delete_account_screen.dart`.
  Apple has required this since 2022 and rejects for it routinely.
- **No third-party SDKs.** The app's entire dependency list is Flutter, Riverpod,
  go_router, intl, url_launcher, file_picker, pdf and printing. No analytics
  vendor, no crash reporter, no advertising identifier, no tracking SDK. That
  makes the privacy answers in §4 short and, more usefully, true.
- **Courses are IAP-only.** `iap_purchase_sheet.dart` quotes no price of its own
  and offers no external checkout, which is Apple §3.1.1. Sessions are paid on
  the website and are a different case on purpose; the two must not be merged.
- **Analytics cannot leak clinical text.** `AnalyticsDispatcher.forbiddenKeys`
  drops `goal`, `notes`, `patient`, `cv`, `free_text`, credentials and payment
  keys before dispatch.
- **Uploads are owner-only**, type-checked by magic bytes rather than by
  filename, served as attachments with `nosniff`, and answer 404 rather than 403
  to a stranger.
- **Both languages are complete** and key-identical, enforced by a test.

---

## 1 · Platform configuration · found and fixed in the store-readiness pass

These were Flutter scaffold defaults nobody had revisited since `flutter create`,
and every one was visible to a reviewer or a user. All are fixed except where
noted; they are written down because the fixes are invisible in the app and the
next person needs to know they were deliberate.

### 1.1 The app was called `ejadah_mobile` on the home screen · FIXED
`AndroidManifest.xml` carried `android:label="ejadah_mobile"`, and `Info.plist`
carried `CFBundleName` `ejadah_mobile` with `CFBundleDisplayName` "Ejadah
Mobile". The launcher label is the product's name in the one place every user
sees it.

Now **Ejadah** / **إجادة**, from `res/values/strings.xml` and
`res/values-ar/strings.xml` on Android, and `Info.plist` plus
`ios/Runner/{ar,en}.lproj/InfoPlist.strings` on iOS.

> **One Xcode step remains, and it cannot be done from this repository.**
> `ar.lproj/InfoPlist.strings` exists but is not yet a member of the Runner
> target, so iOS will show "Ejadah" on an Arabic device until someone opens
> `Runner.xcworkspace` and adds both `.lproj` folders to *Build Phases → Copy
> Bundle Resources*. Editing `project.pbxproj` by hand is how Xcode projects get
> corrupted; this is worth the two minutes.

### 1.2 Release builds were signed with the debug key · FIXED, needs the key
`build.gradle.kts` had `signingConfig = signingConfigs.getByName("debug")` in
`buildTypes.release`, and Play refuses a debug-signed upload.

It now reads `android/key.properties` and signs with the upload key when one is
present, falling back to the debug key — with a build warning, not silently — so
`flutter run --release` still works for anyone without it.

**Owner:** generate the upload keystore and write `android/key.properties` with
`storeFile`, `storePassword`, `keyAlias`, `keyPassword`. Both are git-ignored,
along with `*.jks`, `*.keystore`, `*.p12` and `*.mobileprovision`. A signing key
in a repository is a signing key everyone with read access owns, and it is the
one secret whose loss cannot be recovered from — without it the app can never be
updated, only republished under a new identity.

### 1.3 iOS did not declare Arabic · FIXED
`Info.plist` had no `CFBundleLocalizations`, so the App Store would have listed
the app as English-only and iOS would not have matched it to an Arabic-language
device — the wrong way round for a product whose in-app default is Arabic. Now
declares `ar` and `en`.

### 1.4 Export compliance was unanswered · FIXED
No `ITSAppUsesNonExemptEncryption`, so every upload stopped for a manual
encryption question. The app uses HTTPS and the platform's own crypto and
nothing else, which is the exempt case. Now `false`.

### 1.5 Version is still `1.0.0+1` · owner
`apps/mobile/pubspec.yaml`. Fine as a first submission, but the build number must
increment on every upload and neither store lets you reuse one.

---

## 2 · Blocking · owner assets and credentials

### 2.1 Vector logo, app icon, and the icon master
Conflict #9 in `REGISTER.md`. Two JPGs exist; there is no vector, no dark
variant and no icon master. The app icon uses the documented gradient-tile
pattern in the meantime.

Needed: a 1024×1024 icon with **no transparency and no rounded corners** (Apple
rounds it), an Android adaptive icon as separate foreground and background
layers, and the vector master everything else is cut from.

### 2.2 Screenshots
None exist. Both stores require them and both reject placeholder content.

Required per store, **in both languages** — an Arabic listing with English
screenshots is a rejection and, worse, a bad first impression on the audience
this product is actually for:

| Store | Sizes | Count |
|---|---|---|
| App Store | 6.9" and 6.5" iPhone; 13" iPad if an iPad build ships | 3–10 each |
| Play | phone, 7" tablet, 10" tablet | 2–8 each |

Shoot them from a seeded build, not the demo fixtures: every face in
`handoff/` is an unlicensed placeholder (§2.5). The screens worth showing are
the ones the product is about — the roadmap result, a country guide with its
sourced costs, a tutor profile with real availability, the CV builder.

### 2.3 IAP credentials and receipt verification
The IAP path exists and **fails closed**: an unverified receipt grants nothing.
That is the safe direction and it is deliberate, but it means no purchase can
succeed against a real store today.

Needs App Store Connect and Play Console products created and priced, then
server-side receipt validation — Apple's `verifyReceipt` (or the App Store
Server API) and the Play Developer API — before
`POST /learn/courses/{id}/entitlement` grants anything. Owner decision, 15 Aug
2026: this belongs here rather than in the build order.

**Test before submitting:** a sandbox purchase grants the course; a replayed or
forged receipt does not.

### 2.4 The privacy policy and terms pages must exist
Settings links to `https://ejadah.international/privacy` and `/terms`, and both
stores also require a privacy-policy URL in the listing itself. A link that
404s is a rejection. They must cover what §4 declares, and exist in Arabic.

### 2.5 Real rosters and photographs
Every tutor image in the handoff is a placeholder and unlicensed for production.
The app shows initials on the inset surface — never a broken image, never an
unlicensed portrait — so nothing breaks, but shipping placeholder people would.

### 2.6 Somewhere for a tutor application to be reviewed
`POST /people/apply/submit` moves an application to `under_review` and the screen
promises a reply within three working days. Nothing in this repository approves
one; the reviewer's tool is the admin panel, which is web-only and deliberately
outside this app. Until it exists, an application that arrives is one nobody
answers, and the promise on PE-12 is one the product cannot keep.

Approving by hand is documented in `operations.md` — two statements, one
transaction, rehearsed against the real schema, logged in `ops-log.md`. So this
blocks the first real tutor, not the build.

### 2.7 Server configuration
Checked by `AppConfig` at boot, so a misconfigured production process does not
start rather than starting wrong.

- `PAYMENT_PROVIDER` — `dev` is the simulator and production refuses to boot
  with it.
- `JWT_SECRET` — production refuses known placeholders and low-variety values.
  Generate with `openssl rand -base64 48`.
- `TRUSTED_PROXY_COUNT` — the number of proxies in front of the process. Left at
  zero, `X-Forwarded-For` is ignored and the rate limiter keys off the socket
  address; safe, but wrong behind a load balancer, where every request appears
  to come from one address.

---

## 3 · Blocking · one security decision, owed to the owner

### 3.1 The refresh token is not in the Keychain · repo, needs a decision
`TokenStore` (`packages/ejadah_core/lib/src/network/token_store.dart`) uses
`SharedPreferences` on **every** platform, native included. An earlier draft of
this document claimed native builds used secure storage. That was not true, and
this line replaces it.

What it means in practice:

- **Android** — app-private storage under `/data/data/<package>/shared_prefs`.
  Reasonably protected on a non-rooted device, but not the Keystore.
- **iOS** — `NSUserDefaults`, which is **included in device and iCloud backups**.
  A refresh token in a backup outlives the device it was issued to, and that is
  the part that matters.
- **Web** — `localStorage`, readable by any script in the origin. Already an
  accepted owner decision: ship native-first, web is a preview surface, debug
  web builds say so on screen.

The fix is `flutter_secure_storage` behind the existing `TokenStore` interface —
Keychain on iOS with `first_unlock_this_device` (which excludes it from backups),
EncryptedSharedPreferences on Android, and `SharedPreferences` kept as the web
implementation, since the web has nothing better to offer.

**Not done, deliberately.** It is a change to the path every session in the app
depends on, and it cannot be verified anywhere in this environment — there is no
device and no emulator here, and a token store that compiles but does not
persist signs every user out on relaunch. It wants one run on a real device,
which is an owner call rather than something to land unsupervised in a hardening
pass.

---

## 4 · Privacy labels · answers, from what the app actually does

Apple's App Privacy card and Play's Data safety form ask the same questions in
different words. Both are declarations under penalty of removal, so these are
derived from the code rather than from intent.

Nothing below is shared with a third party, used for tracking, or used for
advertising, because there is no third party in the app to share it with (§0).

| Data | Collected | Linked to identity | Purpose |
|---|---|---|---|
| Email address | Yes | Yes | account, sign-in, verification |
| Name (EN + AR) | Yes | Yes | account, public profile, CV |
| Photos — avatar | Yes, optional | Yes | profile |
| Other user content — certificates, CV documents | Yes, optional | Yes | verification, CV |
| Other user content — booking goal (free text) | Yes | Yes | shown to the student's own tutor only |
| Purchase history | Yes | Yes | course entitlement |
| Device ID — a locally generated token | Yes | No, until sign-up | carries a guest's roadmap to their new account |
| Product interaction | Yes | Yes | product analytics |
| Precise or coarse location | **No** | — | never requested |
| Contacts, calendar, health, financial info | **No** | — | never requested |
| Advertising identifier | **No** | — | no advertising SDK exists |

Two answers need care, because both are easy to get wrong:

- **The booking goal is health-adjacent free text.** It is a dentist describing a
  clinical case they need help with, so it can contain patient detail. It is
  shown to the student's own tutor and to nobody else, it is excluded from
  analytics by name, and it is never logged. Declare it as *Other User Content*,
  not as *Health & Fitness* — Apple's health category means data read from
  HealthKit or a sensor, which this is not. Whichever way the owner declares it,
  the privacy policy must describe it in the same words.
- **The device token is not an advertising identifier and must not be declared
  as one.** It is generated on the device with `Random.secure()`, never leaves
  the account it belongs to, and exists so a guest who completes the roadmap
  before signing up does not lose it. Declare it under *Identifiers*, marked as
  not used for tracking.

**Age rating.** Ejadah is a professional-education product for qualified
dentists: no user-to-user messaging (deliberate, moderation liability), no
user-generated public feed, no gambling, no explicit content. That reads as 4+
on Apple and *Everyone* on Play. The one question to answer honestly is the
medical/treatment-information prompt: the app carries clinical educational
content and regulator facts, so answer yes where asked about
medical/treatment information rather than trying to fit the lower rating.

---

## 5 · Store listing · what to write

Both stores, both languages. The Arabic listing is not a translation
afterthought — it is the primary audience's listing.

- [ ] App name (30 chars Apple / 30 Play), subtitle, promotional text
- [ ] Description — what the product is for, in the product's own voice: no
      exclamation marks, no emoji, no superlatives it cannot support
- [ ] Keywords (Apple, 100 chars)
- [ ] Category — Education, with Medical as the secondary
- [ ] Support URL and marketing URL, both live
- [ ] Copyright, and the seller/developer name matching the legal entity
- [ ] Play: a 1024×500 feature graphic and a short description (80 chars)
- [ ] Apple: demo account credentials for review — a real reviewable account,
      **never** the development demo accounts, which must not exist in
      production at all
- [ ] Apple: review notes explaining that sessions are paid on the website
      because they are a service and not digital content, so §3.1.1 does not
      apply to them. This is the single most likely rejection reason for this
      app and it is much cheaper to pre-empt than to appeal.

---

## 6 · Recorded, not blocking

### Flutter Web is a preview surface
The web build keeps its refresh token in `localStorage`, readable by any script
in the origin. Owner decision, 15 Aug 2026: ship native-first, treat web as
preview. Debug web builds carry a banner saying so. If web becomes a real
distribution channel the fix is an HttpOnly refresh cookie set by the existing
refresh endpoint — not a patch to the client.

### Cairo time is a fixed +02:00
Egypt reinstated summer time in 2023, so displayed times run an hour behind
during it. Owner decision, 15 Aug 2026: keep the fixed offset and make the copy
honest — every string names "Cairo time" and none names an offset. Closing the
gap later is a data change (IANA `Africa/Cairo`) applied to `CairoClock.offset`,
the only place in the server that converts to local time.

### 14 pending regulator facts
7 exam fees and 7 cost rows print "Pending source". This is a first-class data
state, not a gap to fill before shipping — the product's credibility rests on
it. Owner-supplied sources replace them whenever they arrive.

### Uploaded files sit on local disk, unscanned
`LocalFileStore` writes under `STORAGE_ROOT`. The bytes decide the type, reads
are owner-only, everything is served as an attachment with `nosniff` — but there
is no virus scanning, no image re-encoding, and the disk is not backed up by this
repository. Moving to object storage replaces one class behind the `FileStore`
interface.

### Arabic clinical-terminology review
Strings ship exactly as authored in `strings.ar.json`. No machine translation was
introduced. The practising-dentist review is owed and does not block.

### The CV PDF has not been read on a phone
Both languages are proven by test — A4 at the real MediaBox precision, Amiri and
IBM Plex Sans Arabic embedded and verified by grepping the output bytes, Western
numerals throughout, the patient-data warning correctly absent from the print.
What a test cannot judge is whether Amiri is comfortable to read at body size on
a handset. One human look at both PDFs, on a phone, before submission.
