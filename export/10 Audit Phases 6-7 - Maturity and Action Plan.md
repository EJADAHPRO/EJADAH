# 10 Audit Phases 6-7 - Maturity and Action Plan

The v2 of each feature, then the 16-item board with a 'know it worked' metric each.

**Exported:** 2 August 2026  
**Size:** 18,594 characters · template 193 lines

> Design Component — one self-contained HTML file that opens directly in a browser.
> Template = markup between `<x-dc>` and `</x-dc>`. Logic = `class Component extends DCLogic` whose
> `renderVals()` returns what the template's `{{ }}` holes read (dotted lookups only, never expressions).

## Template

```html
<helmet>
<meta name="design_doc_mode" content="canvas">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700;800&family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<style>
  body{margin:0;background:#EDE9E1;-webkit-font-smoothing:antialiased;color:#1B1B1B;font-family:Inter,sans-serif}
  a{color:#A83A0C;text-decoration:none}
  a:hover{color:#C41419}
</style>
</helmet>

<div style="width:1780px;padding:48px 40px 64px;box-sizing:border-box">

  <div style="margin-bottom:28px;max-width:940px">
    <div style="font:800 12px/1 Inter,sans-serif;letter-spacing:.14em;color:#A83A0C;margin-bottom:12px">PHASES 6 &amp; 7 · FINAL DELIVERABLE · 30 JULY 2026</div>
    <h1 style="font:700 38px/1.15 'Playfair Display',serif;margin:0 0 10px">Maturity gaps and the action plan</h1>
    <p style="font:400 14px/1.7 Inter,sans-serif;color:#635F5A;margin:0">What takes each feature from built to mature, then the whole audit resolved into a board: this week, this month, next quarter. Everything on the board traces to a finding in Phases 1–5, and each item names how you will know it worked.</p>
  </div>

  <!-- PHASE 6 -->
  <div style="background:#1B1B1B;border-radius:18px;padding:20px 26px;margin-bottom:16px">
    <div style="font:800 11px/1 Inter,sans-serif;letter-spacing:.12em;color:#FFC62E;margin-bottom:6px">PHASE 6</div>
    <div style="font:700 22px/1.3 'Playfair Display',serif;color:#fff">Maturity — the v2 of each thing</div>
  </div>

  <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:14px;margin-bottom:30px">
    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:18px 20px">
      <div style="font:700 15px/1.4 Inter,sans-serif;margin-bottom:8px">Roadmap</div>
      <div style="font:400 12.5px/1.75 Inter,sans-serif;color:#635F5A;margin-bottom:10px"><strong style="color:#1B1B1B">Today:</strong> a static snapshot generated once.</div>
      <div style="font:400 12.5px/1.75 Inter,sans-serif;color:#635F5A"><strong style="color:#8A5C00">v2:</strong> it maintains itself. A deadline moves, the stage dates shift, one notification explains what changed. That turns a document into a companion — and it is the difference between a tool used once and one opened monthly for two years.</div>
    </div>
    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:18px 20px">
      <div style="font:700 15px/1.4 Inter,sans-serif;margin-bottom:8px">Programme database</div>
      <div style="font:400 12.5px/1.75 Inter,sans-serif;color:#635F5A;margin-bottom:10px"><strong style="color:#1B1B1B">Today:</strong> 199 real records, 11 fees unsourced, no re-check rota.</div>
      <div style="font:400 12.5px/1.75 Inter,sans-serif;color:#635F5A"><strong style="color:#8A5C00">v2:</strong> a freshness pipeline — every field carries "verified on", with a six-month rota and an owner. Data decay is the only thing that can kill this product quietly.</div>
    </div>
    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:18px 20px">
      <div style="font:700 15px/1.4 Inter,sans-serif;margin-bottom:8px">Marketplaces</div>
      <div style="font:400 12.5px/1.75 Inter,sans-serif;color:#635F5A;margin-bottom:10px"><strong style="color:#1B1B1B">Today:</strong> booking works; trust signals are thin.</div>
      <div style="font:400 12.5px/1.75 Inter,sans-serif;color:#635F5A"><strong style="color:#8A5C00">v2:</strong> reviews only from completed bookings, response-time badges, and the in-session messaging your policy already promises but the product doesn't have.</div>
    </div>
    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:18px 20px">
      <div style="font:700 15px/1.4 Inter,sans-serif;margin-bottom:8px">Courses</div>
      <div style="font:400 12.5px/1.75 Inter,sans-serif;color:#635F5A;margin-bottom:10px"><strong style="color:#1B1B1B">Today:</strong> evergreen, self-paced, bought one at a time.</div>
      <div style="font:400 12.5px/1.75 Inter,sans-serif;color:#635F5A"><strong style="color:#8A5C00">v2:</strong> cohort start dates — a date creates urgency that evergreen content never will — plus track bundles priced below the sum of their parts.</div>
    </div>
    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:18px 20px">
      <div style="font:700 15px/1.4 Inter,sans-serif;margin-bottom:8px">NFC card &amp; public profile</div>
      <div style="font:400 12.5px/1.75 Inter,sans-serif;color:#635F5A;margin-bottom:10px"><strong style="color:#1B1B1B">Today:</strong> a shareable profile with private analytics.</div>
      <div style="font:400 12.5px/1.75 Inter,sans-serif;color:#635F5A"><strong style="color:#8A5C00">v2:</strong> the profile becomes a real landing page with an install CTA, and the analytics start prompting: "18 people opened your CV this month — it's four months old."</div>
    </div>
    <div style="background:rgba(255,45,50,.05);border:1.5px solid rgba(255,45,50,.3);border-radius:16px;padding:18px 20px">
      <div style="font:700 15px/1.4 Inter,sans-serif;margin-bottom:8px">Measurement</div>
      <div style="font:400 12.5px/1.75 Inter,sans-serif;color:#635F5A;margin-bottom:10px"><strong style="color:#C41419">Today:</strong> 4 of ~35 events wired.</div>
      <div style="font:400 12.5px/1.75 Inter,sans-serif;color:#635F5A"><strong style="color:#8A5C00">v2:</strong> the taxonomy in <span style="direction:ltr;unicode-bidi:isolate">handoff/analytics-events.md</span> fully instrumented. Until then activation is unmeasurable and <strong>every recommendation on this board — including mine — is an argument rather than a finding.</strong></div>
    </div>
  </div>

  <!-- PHASE 7 -->
  <div style="background:#1B1B1B;border-radius:18px;padding:20px 26px;margin-bottom:16px">
    <div style="font:800 11px/1 Inter,sans-serif;letter-spacing:.12em;color:#FFC62E;margin-bottom:6px">PHASE 7</div>
    <div style="font:700 22px/1.3 'Playfair Display',serif;color:#fff">The board</div>
  </div>

  <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:16px;margin-bottom:22px">

    <div style="background:rgba(45,155,104,.06);border:1.5px solid rgba(45,155,104,.35);border-radius:18px;padding:20px 22px">
      <div style="font:800 11px/1 Inter,sans-serif;letter-spacing:.1em;color:#1B6B47;margin-bottom:4px">QUICK WINS · THIS WEEK</div>
      <div style="font:400 11.5px/1.6 Inter,sans-serif;color:#5A5751;margin-bottom:16px">High impact, low effort, no dependencies.</div>
      <div style="display:grid;gap:12px">
        <div style="background:#fff;border-radius:12px;padding:14px 15px">
          <div style="font:700 13px/1.4 Inter,sans-serif;margin-bottom:5px">1 · Noindex demo routes</div>
          <div style="font:400 11.5px/1.65 Inter,sans-serif;color:#5A5751;margin-bottom:7px">Ranking with invented names poisons a domain you only get to launch once.</div>
          <div style="font:600 11px/1.5 Inter,sans-serif;color:#1B6B47">Know it worked: Search Console shows zero indexed demo URLs.</div>
        </div>
        <div style="background:#fff;border-radius:12px;padding:14px 15px">
          <div style="font:700 13px/1.4 Inter,sans-serif;margin-bottom:5px">2 · End the pricing contradiction</div>
          <div style="font:400 11.5px/1.65 Inter,sans-serif;color:#5A5751;margin-bottom:7px">Website tiers vs app one-off purchases. Two answers is worse than either answer.</div>
          <div style="font:600 11px/1.5 Inter,sans-serif;color:#1B6B47">Know it worked: both surfaces state the same model, or the web pages are unlinked.</div>
        </div>
        <div style="background:#fff;border-radius:12px;padding:14px 15px">
          <div style="font:700 13px/1.4 Inter,sans-serif;margin-bottom:5px">3 · Module A — exam-tutor cross-sell</div>
          <div style="font:400 11.5px/1.65 Inter,sans-serif;color:#5A5751;margin-bottom:7px">On programme detail, under entry requirements. Pure placement, no new data.</div>
          <div style="font:600 11px/1.5 Inter,sans-serif;color:#1B6B47">Know it worked: tutor-profile views arriving from programme detail, from zero.</div>
        </div>
        <div style="background:#fff;border-radius:12px;padding:14px 15px">
          <div style="font:700 13px/1.4 Inter,sans-serif;margin-bottom:5px">4 · Persona-branch the Home CTA</div>
          <div style="font:400 11.5px/1.65 Inter,sans-serif;color:#5A5751;margin-bottom:7px">Students and specialists currently meet a CTA built for someone emigrating. The switcher already exists.</div>
          <div style="font:600 11px/1.5 Inter,sans-serif;color:#1B6B47">Know it worked: Home CTA taps rise for both personas.</div>
        </div>
        <div style="background:#fff;border-radius:12px;padding:14px 15px">
          <div style="font:700 13px/1.4 Inter,sans-serif;margin-bottom:5px">5 · Intro call on the roadmap result</div>
          <div style="font:400 11.5px/1.65 Inter,sans-serif;color:#5A5751;margin-bottom:7px">One button. The lowest-friction step in the product isn't offered at its highest-intent moment.</div>
          <div style="font:600 11px/1.5 Inter,sans-serif;color:#1B6B47">Know it worked: intro calls booked within a day of a roadmap.</div>
        </div>
      </div>
    </div>

    <div style="background:rgba(255,170,24,.08);border:1.5px solid rgba(255,170,24,.45);border-radius:18px;padding:20px 22px">
      <div style="font:800 11px/1 Inter,sans-serif;letter-spacing:.1em;color:#8A5C00;margin-bottom:4px">CORE FIXES · THIS MONTH</div>
      <div style="font:400 11.5px/1.6 Inter,sans-serif;color:#5A5751;margin-bottom:16px">Funnel blockers, and the things that must be true before launch.</div>
      <div style="display:grid;gap:12px">
        <div style="background:#fff;border-radius:12px;padding:14px 15px">
          <div style="font:700 13px/1.4 Inter,sans-serif;margin-bottom:5px">6 · Wire the analytics taxonomy</div>
          <div style="font:400 11.5px/1.65 Inter,sans-serif;color:#5A5751;margin-bottom:7px">Do this first of the six. Everything below becomes guesswork without it.</div>
          <div style="font:600 11px/1.5 Inter,sans-serif;color:#8A5C00">Know it worked: you can answer "what percentage reach a saved roadmap?"</div>
        </div>
        <div style="background:#fff;border-radius:12px;padding:14px 15px">
          <div style="font:700 13px/1.4 Inter,sans-serif;margin-bottom:5px">7 · Real rosters + Arabic review</div>
          <div style="font:400 11.5px/1.65 Inter,sans-serif;color:#5A5751;margin-bottom:7px">Blocks every external demo, and blocks modules B and D behind it.</div>
          <div style="font:600 11px/1.5 Inter,sans-serif;color:#8A5C00">Know it worked: a practising dentist reads the Arabic without wincing.</div>
        </div>
        <div style="background:#fff;border-radius:12px;padding:14px 15px">
          <div style="font:700 13px/1.4 Inter,sans-serif;margin-bottom:5px">8 · Source the 11 pending fees</div>
          <div style="font:400 11.5px/1.65 Inter,sans-serif;color:#5A5751;margin-bottom:7px">"Pending source" is honest in an app and damaging on 23 landing pages.</div>
          <div style="font:600 11px/1.5 Inter,sans-serif;color:#8A5C00">Know it worked: zero Pending-source strings in the dataset.</div>
        </div>
        <div style="background:#fff;border-radius:12px;padding:14px 15px">
          <div style="font:700 13px/1.4 Inter,sans-serif;margin-bottom:5px">9 · Module C — stage → course</div>
          <div style="font:400 11.5px/1.65 Inter,sans-serif;color:#5A5751;margin-bottom:7px">The only link that opens course revenue. Needs a stage-to-course mapping table.</div>
          <div style="font:600 11px/1.5 Inter,sans-serif;color:#8A5C00">Know it worked: first course purchase originating in Career.</div>
        </div>
        <div style="background:#fff;border-radius:12px;padding:14px 15px">
          <div style="font:700 13px/1.4 Inter,sans-serif;margin-bottom:5px">10 · Tutor first-student playbook</div>
          <div style="font:400 11.5px/1.65 Inter,sans-serif;color:#5A5751;margin-bottom:7px">Supply churn costs more than demand churn and is slower to repair.</div>
          <div style="font:600 11px/1.5 Inter,sans-serif;color:#8A5C00">Know it worked: days from approval to first booking falls.</div>
        </div>
        <div style="background:#fff;border-radius:12px;padding:14px 15px">
          <div style="font:700 13px/1.4 Inter,sans-serif;margin-bottom:5px">11 · Time five real dentists</div>
          <div style="font:400 11.5px/1.65 Inter,sans-serif;color:#5A5751;margin-bottom:7px">The three-minute activation claim is still an assertion, including in my own documents.</div>
          <div style="font:600 11px/1.5 Inter,sans-serif;color:#8A5C00">Know it worked: five stopwatch numbers, however inconvenient.</div>
        </div>
      </div>
    </div>

    <div style="background:rgba(73,111,168,.06);border:1.5px solid rgba(73,111,168,.4);border-radius:18px;padding:20px 22px">
      <div style="font:800 11px/1 Inter,sans-serif;letter-spacing:.1em;color:#3A5A87;margin-bottom:4px">GROWTH BUILDS · NEXT QUARTER</div>
      <div style="font:400 11.5px/1.6 Inter,sans-serif;color:#5A5751;margin-bottom:16px">Bigger bets, each dependent on the month's work landing first.</div>
      <div style="display:grid;gap:12px">
        <div style="background:#fff;border-radius:12px;padding:14px 15px">
          <div style="font:700 13px/1.4 Inter,sans-serif;margin-bottom:5px">12 · The page factory</div>
          <div style="font:400 11.5px/1.65 Inter,sans-serif;color:#5A5751;margin-bottom:7px">~400 pages in both languages, templated from data you already own. Arabic first.</div>
          <div style="font:600 11px/1.5 Inter,sans-serif;color:#3A5A87">Know it worked: organic impressions on Arabic queries, from a base of zero.</div>
        </div>
        <div style="background:#fff;border-radius:12px;padding:14px 15px">
          <div style="font:700 13px/1.4 Inter,sans-serif;margin-bottom:5px">13 · Self-updating roadmaps</div>
          <div style="font:400 11.5px/1.65 Inter,sans-serif;color:#5A5751;margin-bottom:7px">Data pipeline plus notifications. Turns the roadmap from a document into a companion.</div>
          <div style="font:600 11px/1.5 Inter,sans-serif;color:#3A5A87">Know it worked: return visits triggered by a roadmap-changed notification.</div>
        </div>
        <div style="background:#fff;border-radius:12px;padding:14px 15px">
          <div style="font:700 13px/1.4 Inter,sans-serif;margin-bottom:5px">14 · Decide January pricing</div>
          <div style="font:400 11.5px/1.65 Inter,sans-serif;color:#5A5751;margin-bottom:7px">Decide in October, announce in November. Never in the final fortnight.</div>
          <div style="font:600 11px/1.5 Inter,sans-serif;color:#3A5A87">Know it worked: a written policy, including what founders keep for good.</div>
        </div>
        <div style="background:#fff;border-radius:12px;padding:14px 15px">
          <div style="font:700 13px/1.4 Inter,sans-serif;margin-bottom:5px">15 · Cohorts and bundles</div>
          <div style="font:400 11.5px/1.65 Inter,sans-serif;color:#5A5751;margin-bottom:7px">A start date is the only urgency evergreen content can borrow.</div>
          <div style="font:600 11px/1.5 Inter,sans-serif;color:#3A5A87">Know it worked: completion rate for a cohort vs the same course self-paced.</div>
        </div>
        <div style="background:#fff;border-radius:12px;padding:14px 15px">
          <div style="font:700 13px/1.4 Inter,sans-serif;margin-bottom:5px">16 · Clinic-owner content</div>
          <div style="font:400 11.5px/1.65 Inter,sans-serif;color:#5A5751;margin-bottom:7px">One honest piece on what a Cairo clinic costs to open, ending in a consultant. Highest ticket, thinnest funnel.</div>
          <div style="font:600 11px/1.5 Inter,sans-serif;color:#3A5A87">Know it worked: a consulting booking that didn't come from your phone contacts.</div>
        </div>
      </div>
    </div>
  </div>

  <!-- CLOSING -->
  <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px">
    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:22px 24px">
      <div style="font:800 11px/1 Inter,sans-serif;letter-spacing:.1em;color:#5A5751;margin-bottom:14px">WHAT I ASSUMED ON YOUR BEHALF</div>
      <ul style="margin:0;padding-inline-start:18px;font:400 12.5px/1.9 Inter,sans-serif;color:#635F5A">
        <li>The app's model is the company's model, and the website must follow it</li>
        <li>Arabic-first SEO is worth more to you than English head terms</li>
        <li>Post-January pricing will gate output and scale, never data access</li>
        <li>Current brand tokens stand; your prompt cited the older website palette and I kept the newer one</li>
        <li>Launch is close enough that "before launch" means weeks, not months</li>
      </ul>
    </div>
    <div style="background:#1B1B1B;border-radius:18px;padding:22px 24px">
      <div style="font:800 11px/1 Inter,sans-serif;letter-spacing:.1em;color:#FFC62E;margin-bottom:14px">FOUR QUESTIONS I NEED ANSWERED</div>
      <ol style="margin:0;padding-inline-start:18px;font:400 12.5px/1.9 Inter,sans-serif;color:rgba(255,255,255,.8)">
        <li>Which of the 81 web routes are actually linked in the live nav? The dead-end audit for the website needs a crawl or repo access.</li>
        <li>What is the January price, and does the founding cohort keep anything free permanently?</li>
        <li>Who owns programme-data re-verification every six months — staff, or mentors in exchange for credit?</li>
        <li>Is in-session messaging being built for launch? Your cancellation policy references it; the product doesn't have it.</li>
      </ol>
      <div style="margin-top:16px;padding-top:14px;border-top:1px solid rgba(255,255,255,.14);font:500 12.5px/1.75 Inter,sans-serif;color:rgba(255,255,255,.72)"><strong style="color:#fff">One thing I'd have built differently:</strong> 81 routes is roughly three times what a launch needs. I would have shipped guides, the database and tutoring, then let search data decide what came next — rather than deciding in advance and discovering later which pages nobody wanted.</div>
    </div>
  </div>

</div>
```

## Logic

_Template-only component — no logic class._
