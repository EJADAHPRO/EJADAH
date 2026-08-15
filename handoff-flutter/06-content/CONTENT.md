# Content — Microcopy · Validation · Empty/Error/Loading · Notifications
### Combines: MICROCOPY_GUIDE, FORM_VALIDATION_COPY, EMPTY_ERROR_LOADING_COPY, NOTIFICATION_COPY, CONTENT_RULES
Voice rules: `../02-brand/BRAND_GUIDE.md` §2. All strings below already exist (or belong) in `handoff/strings.*.json` — keys noted where established.

## Content rules
Honest, specific, warm. State what survived in every failure. Consequence before destructive confirm (exact EGP). "Pending source"/"بانتظار المصدر" verbatim — no variants. No exclamation marks, no emoji, no status codes, no "N/A". CTAs = verb+object. One idea per sentence in AR; never machine-literal.

## Canonical reusable copy (EN / AR)
- No saved programmes: "No saved programmes yet — 17 are open right now." → CTA Browse programmes / «لا برامج محفوظة بعد — 17 برنامجًا مفتوح الآن.» → تصفح البرامج
- No results (filters): "Nothing matches those filters. Nearest match: {relaxation}." / «لا نتائج بهذه التصفية. الأقرب: {relaxation}.»
- No bookings: "No sessions yet. Find a mentor who made your move." / «لا جلسات بعد. ابحث عن مرشد قام بخطوتك.»
- No notifications: "Nothing yet. Deadline alerts will land here." / «لا شيء بعد. ستصل تنبيهات المواعيد هنا.»
- Offline: "Offline — showing your saved content" / «بلا اتصال — نعرض المحتوى المحفوظ» (banner, key exists)
- Server: "Something went wrong on our side. Nothing you saved is affected." / «حدث خطأ من جانبنا. لم يتأثر ما حفظته.»
- Session expired: "Please sign in again. You'll come straight back — nothing is lost." / «سجّل الدخول مجددًا. ستعود لمكانك — لم يُفقد شيء.»
- Rate limited: "Take a short break — try in 2 minutes." / «خذ وقتًا قصيرًا — حاول بعد دقيقتين.»
- Content unavailable: "This is no longer available — often the intake closed." / «لم يعد متاحًا — غالبًا أُغلقت الدفعة.»
- Generic: "We couldn't do that just now. Nothing you entered is lost." / «تعذّر ذلك الآن. لم يُفقد ما أدخلته.»
- Slot taken: "Someone booked that time a moment ago. Here's what's still open." / «حُجز هذا الموعد قبل لحظات. هذه المواعيد المتاحة.»
- Hold expired: "That hold ran out and the time was released. Pick another — nothing was charged." / «انتهى الحجز المؤقت وتحرر الموعد. اختر آخر — لم يُخصم شيء.»
- Undo toast: "Removed from your shortlist — Undo" / «أُزيل من قائمتك — تراجع»

## Form validation (per field: rule → EN / AR error)
**Sign up:** name required+AR-script-if-AR-field → "Please enter your name in Arabic"/«اكتب اسمك بالعربية»; email format → "That email doesn't look right"/«البريد غير صحيح»; password ≥8 + letter+number (rules checklist live, green as met); terms unchecked → tap-reason "Accept the terms to continue"/«وافق على الشروط للمتابعة».
**OTP:** 6 digits, LTR; wrong → "That code didn't match. {n} tries left."; resend cooldown 60s shown as text, not disabled-mystery.
**Booking goal:** ≥10 chars → "Write a line or two about what you need — it makes the session far more useful."/«اكتب سطرًا أو سطرين عمّا تحتاجه»; patient-data warning always visible: "Please don't include patient names or identifying details."/«لا تُدرج أسماء المرضى أو بيانات تعريفية».
**Tutor application:** per-step named blockers (subjects/rate/availability/qualification) — exact strings exist (`add_at_least_one_subject`…); files ≤5MB, PDF/JPG/PNG.
**NFC editor:** URL fields validated as https; socials optional; live preview updates per keystroke.
**CV:** section optional except name/stage; same patient-data warning.
Server fallback everywhere: the generic error + preserved input. Validate on blur, never per keystroke; on failed submit scroll+focus first invalid and announce.

## Notification copy (3 categories — no marketing; keys in handoff/push-notifications.md)
Deadline 30/14/7: "King's College London closes in 14 days" / «كينجز كوليدج لندن يُغلق بعد 14 يومًا» (deep link → programme).
Session reminder T-24h/T-1h: "Your session with Dr. Mona Adel is tomorrow 7:00 pm (Cairo time)" / AR equivalent (→ booking).
Roadmap nudge weekly, stage-specific: "Ready for stage 2 — credential verification?" / «جاهز للمرحلة 2 — التحقق من الشهادة؟» (→ roadmap).
Permission priming (in-context sheet, never cold start): title "Want a warning before deadlines close?" — list the 3 types + "Never marketing. Each can be switched off separately."
