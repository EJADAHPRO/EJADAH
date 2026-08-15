# 05 Audit Phase 1 - Sitemap

All 95 screens in eight clusters plus the website, colour-coded by journey stage. Dead ends in red (the app has none).

**Exported:** 2 August 2026  
**Size:** 30,429 characters · template 375 lines

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
  a{color:#FF6B1A;text-decoration:none}
  a:hover{color:#FF2D32}
</style>
</helmet>

<div style="width:1680px;padding:48px 40px 64px;box-sizing:border-box">

  <div style="display:flex;align-items:flex-end;justify-content:space-between;gap:40px;margin-bottom:28px">
    <div style="min-width:0">
      <div style="font:800 11px/1 Inter,sans-serif;letter-spacing:.14em;color:#A83A0C;margin-bottom:12px">PHASE 1 DELIVERABLE · 30 JULY 2026</div>
      <h1 style="font:700 38px/1.15 'Playfair Display',serif;margin:0 0 10px">Full sitemap — every screen, by journey stage</h1>
      <p style="font:400 14px/1.7 Inter,sans-serif;color:#635F5A;max-width:820px;margin:0 0 10px"><strong>95 screens</strong> in the mobile build, grouped into eight app clusters plus the website. Each node carries its journey stage as a colour bar and its outbound connections underneath; several cards group closely-related screens, so cluster counts are stated on each cluster and sum to 95. <strong>Dead ends are marked with a red outline — the app has none.</strong></p>
      <p style="font:400 12.5px/1.7 Inter,sans-serif;color:#8A5C00;max-width:820px;margin:0;background:rgba(255,170,24,.1);border-radius:8px;padding:9px 12px"><strong>Count correction:</strong> the figure of 57 used in earlier notes and in the companion audit predates the last three weeks of build — the ten system screens, the PM feature layer, the public profile, custom plans and the account screens. 95 is the current inventory; treat 57 as stale wherever it appears.</p>
    </div>
    <div style="flex:none;background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:16px 18px">
      <div style="font:800 11px/1 Inter,sans-serif;letter-spacing:.1em;color:#5A5751;margin-bottom:12px">JOURNEY STAGE</div>
      <div style="display:grid;gap:7px">
        <div style="display:flex;align-items:center;gap:9px"><span style="width:22px;height:8px;border-radius:3px;background:#496FA8"></span><span style="font:600 11.5px/1 Inter,sans-serif">Discovery</span></div>
        <div style="display:flex;align-items:center;gap:9px"><span style="width:22px;height:8px;border-radius:3px;background:#FF6B1A"></span><span style="font:600 11.5px/1 Inter,sans-serif">Consideration</span></div>
        <div style="display:flex;align-items:center;gap:9px"><span style="width:22px;height:8px;border-radius:3px;background:#FFAA18"></span><span style="font:600 11.5px/1 Inter,sans-serif">Activation</span></div>
        <div style="display:flex;align-items:center;gap:9px"><span style="width:22px;height:8px;border-radius:3px;background:#2D9B68"></span><span style="font:600 11.5px/1 Inter,sans-serif">Habit</span></div>
        <div style="display:flex;align-items:center;gap:9px"><span style="width:22px;height:8px;border-radius:3px;background:#FF2D32"></span><span style="font:600 11.5px/1 Inter,sans-serif">Payment</span></div>
        <div style="display:flex;align-items:center;gap:9px"><span style="width:22px;height:8px;border-radius:3px;background:#716D67"></span><span style="font:600 11.5px/1 Inter,sans-serif">Advocacy</span></div>
        <div style="display:flex;align-items:center;gap:9px;margin-top:4px;padding-top:8px;border-top:1px solid #E7E2DA"><span style="width:22px;height:8px;border-radius:3px;border:2px solid #FF2D32;box-sizing:border-box"></span><span style="font:600 11.5px/1 Inter,sans-serif;color:#C41419">Dead end (none in app)</span></div>
        <div style="display:flex;align-items:center;gap:9px"><span style="width:22px;height:8px;border-radius:3px;background:#B07500"></span><span style="font:600 11.5px/1 Inter,sans-serif;color:#8A5C00">Cross-sell gap</span></div>
      </div>
    </div>
  </div>

  <!-- ROW 1 — ENTRY -->
  <div style="background:#1B1B1B;border-radius:18px;padding:20px 24px;margin-bottom:14px">
    <div style="display:flex;align-items:baseline;gap:14px;margin-bottom:16px">
      <div style="font:800 11px/1 Inter,sans-serif;letter-spacing:.12em;color:#FFC62E">CLUSTER 1 · FIRST RUN</div>
      <div style="font:500 12px/1 Inter,sans-serif;color:rgba(255,255,255,.5)">12 screens · store listing → personalised Home</div>
    </div>
    <div style="display:grid;grid-template-columns:repeat(9,1fr);gap:9px">
      <div style="background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.12);border-radius:12px;padding:12px 11px">
        <div style="height:4px;border-radius:2px;background:#496FA8;margin-bottom:9px"></div>
        <div style="font:700 12px/1.35 Inter,sans-serif;color:#fff;margin-bottom:5px">Splash</div>
        <div style="font:400 10px/1.5 Inter,sans-serif;color:rgba(255,255,255,.5)">→ Language</div>
      </div>
      <div style="background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.12);border-radius:12px;padding:12px 11px">
        <div style="height:4px;border-radius:2px;background:#496FA8;margin-bottom:9px"></div>
        <div style="font:700 12px/1.35 Inter,sans-serif;color:#fff;margin-bottom:5px">Language</div>
        <div style="font:400 10px/1.5 Inter,sans-serif;color:rgba(255,255,255,.5)">EN / عربي · first launch only</div>
      </div>
      <div style="background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.12);border-radius:12px;padding:12px 11px">
        <div style="height:4px;border-radius:2px;background:#496FA8;margin-bottom:9px"></div>
        <div style="font:700 12px/1.35 Inter,sans-serif;color:#fff;margin-bottom:5px">Carousel</div>
        <div style="font:400 10px/1.5 Inter,sans-serif;color:rgba(255,255,255,.5)">3 slides · Skip</div>
      </div>
      <div style="background:rgba(255,198,46,.14);border:1.5px solid #FFC62E;border-radius:12px;padding:12px 11px">
        <div style="height:4px;border-radius:2px;background:#FFAA18;margin-bottom:9px"></div>
        <div style="font:700 12px/1.35 Inter,sans-serif;color:#FFC62E;margin-bottom:5px">Guest roadmap ★</div>
        <div style="font:400 10px/1.5 Inter,sans-serif;color:rgba(255,255,255,.6)">Value BEFORE signup wall</div>
      </div>
      <div style="background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.12);border-radius:12px;padding:12px 11px">
        <div style="height:4px;border-radius:2px;background:#FFAA18;margin-bottom:9px"></div>
        <div style="font:700 12px/1.35 Inter,sans-serif;color:#fff;margin-bottom:5px">Result gate</div>
        <div style="font:400 10px/1.5 Inter,sans-serif;color:rgba(255,255,255,.5)">Stages 3–4 blurred → Sign up</div>
      </div>
      <div style="background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.12);border-radius:12px;padding:12px 11px">
        <div style="height:4px;border-radius:2px;background:#FFAA18;margin-bottom:9px"></div>
        <div style="font:700 12px/1.35 Inter,sans-serif;color:#fff;margin-bottom:5px">Sign up · Log in</div>
        <div style="font:400 10px/1.5 Inter,sans-serif;color:rgba(255,255,255,.5)">→ Verify email</div>
      </div>
      <div style="background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.12);border-radius:12px;padding:12px 11px">
        <div style="height:4px;border-radius:2px;background:#FFAA18;margin-bottom:9px"></div>
        <div style="font:700 12px/1.35 Inter,sans-serif;color:#fff;margin-bottom:5px">Verify · Forgot · Reset</div>
        <div style="font:400 10px/1.5 Inter,sans-serif;color:rgba(255,255,255,.5)">60s resend cooldown</div>
      </div>
      <div style="background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.12);border-radius:12px;padding:12px 11px">
        <div style="height:4px;border-radius:2px;background:#FFAA18;margin-bottom:9px"></div>
        <div style="font:700 12px/1.35 Inter,sans-serif;color:#fff;margin-bottom:5px">Profiling · 4 steps</div>
        <div style="font:400 10px/1.5 Inter,sans-serif;color:rgba(255,255,255,.5)">Goal · specialty · region · notifs</div>
      </div>
      <div style="background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.12);border-radius:12px;padding:12px 11px">
        <div style="height:4px;border-radius:2px;background:#716D67;margin-bottom:9px"></div>
        <div style="font:700 12px/1.35 Inter,sans-serif;color:#fff;margin-bottom:5px">Premium status</div>
        <div style="font:400 10px/1.5 Inter,sans-serif;color:rgba(255,255,255,.5)">→ Home (personalised)</div>
      </div>
    </div>
  </div>

  <!-- ROW 2 — HOME -->
  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:20px 24px;margin-bottom:14px">
    <div style="display:flex;align-items:baseline;gap:14px;margin-bottom:16px">
      <div style="font:800 11px/1 Inter,sans-serif;letter-spacing:.12em;color:#A83A0C">CLUSTER 2 · HOME</div>
      <div style="font:500 12px/1.4 Inter,sans-serif;color:#635F5A">4 screens · the router. Feed, notification centre, activation checklist, recently viewed. Persona-aware: 6 personas change the primary CTA and section order. The six cards below are sections of the feed.</div>
    </div>
    <div style="display:grid;grid-template-columns:repeat(6,1fr);gap:9px">
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px">
        <div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div>
        <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">Continue where you left off</div>
        <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">→ course player · roadmap · flashcards</div>
      </div>
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px">
        <div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div>
        <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">Today · flashcard queue</div>
        <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">→ review · streak · <strong>the daily-open driver</strong></div>
      </div>
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px">
        <div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div>
        <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">Deadline strip</div>
        <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Saved programmes by urgency → shortlist</div>
      </div>
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px">
        <div style="height:4px;border-radius:2px;background:#FFAA18;margin-bottom:9px"></div>
        <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">Roadmap CTA / progress</div>
        <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">→ Career funnel or My plan</div>
      </div>
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px">
        <div style="height:4px;border-radius:2px;background:#FF2D32;margin-bottom:9px"></div>
        <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">Matched tutors</div>
        <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">→ tutor profile → booking</div>
      </div>
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px">
        <div style="height:4px;border-radius:2px;background:#496FA8;margin-bottom:9px"></div>
        <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">Explore tiles · Notifications</div>
        <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">→ all four tabs · notif centre</div>
      </div>
    </div>
  </div>

  <!-- ROW 3 — THE FOUR TABS -->
  <div style="display:grid;grid-template-columns:1fr 1fr;gap:14px;margin-bottom:14px">

    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:20px 24px">
      <div style="display:flex;align-items:baseline;gap:14px;margin-bottom:16px">
        <div style="font:800 11px/1 Inter,sans-serif;letter-spacing:.12em;color:#A83A0C">CLUSTER 3 · CAREER</div>
        <div style="font:500 12px/1.4 Inter,sans-serif;color:#635F5A">14 screens · the core of the product</div>
      </div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:9px">
        <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px">
          <div style="height:4px;border-radius:2px;background:#FFAA18;margin-bottom:9px"></div>
          <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">Roadmap funnel · 4 steps</div>
          <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">→ loading → result</div>
        </div>
        <div style="background:rgba(255,198,46,.16);border:1.5px solid #FFC62E;border-radius:12px;padding:12px 11px">
          <div style="height:4px;border-radius:2px;background:#FFAA18;margin-bottom:9px"></div>
          <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">Roadmap result ★</div>
          <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">→ country guide · My plan · what-if · share</div>
        </div>
        <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px">
          <div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div>
          <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">What-if · My roadmaps</div>
          <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Regenerate · saved snapshots</div>
        </div>
        <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px">
          <div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div>
          <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">My plan · stage tasks</div>
          <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">→ tracker · <span style="color:#8A5C00;font-weight:700">Module C gap: stage course</span></div>
        </div>
        <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px">
          <div style="height:4px;border-radius:2px;background:#FF6B1A;margin-bottom:9px"></div>
          <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">Country list · filters · regions</div>
          <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">23 guides → detail · compare</div>
        </div>
        <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px">
          <div style="height:4px;border-radius:2px;background:#FF6B1A;margin-bottom:9px"></div>
          <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">Country detail · 4 tabs</div>
          <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">→ programmes · <span style="color:#8A5C00;font-weight:700">Module B gap: mentors</span></div>
        </div>
        <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px">
          <div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div>
          <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">Application tracker</div>
          <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">→ docs · mentor at Interview stage</div>
        </div>
        <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px">
          <div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div>
          <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">Affordability · Career search</div>
          <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Scoped to programmes + guides only</div>
        </div>
      </div>
    </div>

    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:20px 24px">
      <div style="display:flex;align-items:baseline;gap:14px;margin-bottom:16px">
        <div style="font:800 11px/1 Inter,sans-serif;letter-spacing:.12em;color:#A83A0C">CLUSTER 4 · POSTGRAD</div>
        <div style="font:500 12px/1.4 Inter,sans-serif;color:#635F5A">9 screens · 199 records, paginated</div>
      </div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:9px">
        <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px">
          <div style="height:4px;border-radius:2px;background:#FF6B1A;margin-bottom:9px"></div>
          <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">Database · search + filters</div>
          <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Hides expired by default</div>
        </div>
        <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px">
          <div style="height:4px;border-radius:2px;background:#FF6B1A;margin-bottom:9px"></div>
          <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">Filter sheet · sort</div>
          <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">→ save as alert</div>
        </div>
        <div style="background:rgba(255,198,46,.16);border:1.5px solid #FFC62E;border-radius:12px;padding:12px 11px">
          <div style="height:4px;border-radius:2px;background:#FF6B1A;margin-bottom:9px"></div>
          <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">Programme detail ★</div>
          <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">→ <span style="color:#8A5C00;font-weight:700">Module A gap: exam tutor</span></div>
        </div>
        <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px">
          <div style="height:4px;border-radius:2px;background:#FF6B1A;margin-bottom:9px"></div>
          <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">Compare · up to 3</div>
          <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Differences highlighted</div>
        </div>
        <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px">
          <div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div>
          <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">Shortlist</div>
          <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">→ Home deadline strip · tracker</div>
        </div>
        <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px">
          <div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div>
          <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">Eligibility match · Alerts</div>
          <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Gap → mentor · works while app closed</div>
        </div>
      </div>
    </div>
  </div>

  <div style="display:grid;grid-template-columns:1fr 1fr;gap:14px;margin-bottom:14px">

    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:20px 24px">
      <div style="display:flex;align-items:baseline;gap:14px;margin-bottom:16px">
        <div style="font:800 11px/1 Inter,sans-serif;letter-spacing:.12em;color:#A83A0C">CLUSTER 5 · COURSES</div>
        <div style="font:500 12px/1.4 Inter,sans-serif;color:#635F5A">12 screens · one-off purchases</div>
      </div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:9px">
        <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px">
          <div style="height:4px;border-radius:2px;background:#496FA8;margin-bottom:9px"></div>
          <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">Department hub · 3 depts</div>
          <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">→ list → detail</div>
        </div>
        <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px">
          <div style="height:4px;border-radius:2px;background:#FF2D32;margin-bottom:9px"></div>
          <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">Course detail · purchase sheet</div>
          <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Lesson 1 free · in-app purchase</div>
        </div>
        <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px">
          <div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div>
          <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">Player · lesson complete</div>
          <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">5s auto-advance + cancel</div>
        </div>
        <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px">
          <div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div>
          <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">Quiz</div>
          <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">→ <span style="color:#8A5C00;font-weight:700">Module D gap: fail rescue</span></div>
        </div>
        <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px">
          <div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div>
          <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">Flashcards · handouts</div>
          <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">→ daily review queue</div>
        </div>
        <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px">
          <div style="height:4px;border-radius:2px;background:#716D67;margin-bottom:9px"></div>
          <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">Course complete · downloads</div>
          <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">→ certificate → CV → card</div>
        </div>
      </div>
    </div>

    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:20px 24px">
      <div style="display:flex;align-items:baseline;gap:14px;margin-bottom:16px">
        <div style="font:800 11px/1 Inter,sans-serif;letter-spacing:.12em;color:#A83A0C">CLUSTER 6 · CONNECT</div>
        <div style="font:500 12px/1.4 Inter,sans-serif;color:#635F5A">15 screens · the revenue engine</div>
      </div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:9px">
        <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px">
          <div style="height:4px;border-radius:2px;background:#496FA8;margin-bottom:9px"></div>
          <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">Hub · 3 services</div>
          <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Tutoring · mentoring · consulting</div>
        </div>
        <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px">
          <div style="height:4px;border-radius:2px;background:#FF6B1A;margin-bottom:9px"></div>
          <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">Lists · filters · sort</div>
          <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">By subject, year, destination</div>
        </div>
        <div style="background:rgba(255,198,46,.16);border:1.5px solid #FFC62E;border-radius:12px;padding:12px 11px">
          <div style="height:4px;border-radius:2px;background:#FF2D32;margin-bottom:9px"></div>
          <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">Tutor profile ★</div>
          <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Packages · custom plan · intro call</div>
        </div>
        <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px">
          <div style="height:4px;border-radius:2px;background:#FF2D32;margin-bottom:9px"></div>
          <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">Booking · 8 steps</div>
          <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Week-by-week scheduling → web checkout</div>
        </div>
        <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px">
          <div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div>
          <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">My bookings · session end</div>
          <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">→ practice list → book N+1</div>
        </div>
        <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px">
          <div style="height:4px;border-radius:2px;background:#716D67;margin-bottom:9px"></div>
          <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">Tutor onboarding · earnings</div>
          <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">→ <span style="color:#8A5C00;font-weight:700">Module E gap: first-student</span></div>
        </div>
      </div>
    </div>
  </div>

  <!-- ROW 5 — PROFILE + SYSTEM + WEB -->
  <div style="display:grid;grid-template-columns:1.3fr 1fr 1fr;gap:14px">

    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:20px 24px">
      <div style="display:flex;align-items:baseline;gap:14px;margin-bottom:16px">
        <div style="font:800 11px/1 Inter,sans-serif;letter-spacing:.12em;color:#A83A0C">CLUSTER 7 · PROFILE</div>
        <div style="font:500 12px/1.4 Inter,sans-serif;color:#635F5A">19 screens · retention + advocacy</div>
      </div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:9px">
        <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px">
          <div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div>
          <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">Profile home · 4 groups</div>
          <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Completeness meter → 3 fixes</div>
        </div>
        <div style="background:rgba(255,198,46,.16);border:1.5px solid #FFC62E;border-radius:12px;padding:12px 11px">
          <div style="height:4px;border-radius:2px;background:#716D67;margin-bottom:9px"></div>
          <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">NFC card · public profile ★</div>
          <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751"><strong>The growth loop</strong> → stranger installs</div>
        </div>
        <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px">
          <div style="height:4px;border-radius:2px;background:#716D67;margin-bottom:9px"></div>
          <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">Card analytics · order card</div>
          <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Private · EGP 299 physical</div>
        </div>
        <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px">
          <div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div>
          <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">CV builder · certificates</div>
          <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Experience · skills · languages · CPD</div>
        </div>
        <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px">
          <div style="height:4px;border-radius:2px;background:#716D67;margin-bottom:9px"></div>
          <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">Verification page</div>
          <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Public · third-party trust</div>
        </div>
        <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px">
          <div style="height:4px;border-radius:2px;background:#716D67;margin-bottom:9px"></div>
          <div style="font:700 12px/1.35 Inter,sans-serif;margin-bottom:5px">Invite · Premium · settings</div>
          <div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">+1 month per referral · delete account</div>
        </div>
      </div>
    </div>

    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:20px 24px">
      <div style="display:flex;align-items:baseline;gap:14px;margin-bottom:16px">
        <div style="font:800 11px/1 Inter,sans-serif;letter-spacing:.12em;color:#A83A0C">CLUSTER 8 · SYSTEM</div>
        <div style="font:500 12px/1.4 Inter,sans-serif;color:#635F5A">10 screens · one template, ten states</div>
      </div>
      <div style="font:400 12px/1.9 Inter,sans-serif;color:#1B1B1B">
        Offline · 500 · session expired · force update · maintenance · notification permission · camera permission · error boundary · 404 · rate limited
      </div>
      <div style="margin-top:14px;background:rgba(45,155,104,.08);border-radius:10px;padding:11px 13px;font:600 11.5px/1.6 Inter,sans-serif;color:#1B6B47">
        Every one routes to an action. None is a dead end — this is the cluster most products skip entirely.
      </div>
    </div>

    <div style="background:rgba(255,170,24,.07);border:1.5px solid rgba(255,170,24,.45);border-radius:18px;padding:20px 24px">
      <div style="display:flex;align-items:baseline;gap:14px;margin-bottom:16px">
        <div style="font:800 11px/1 Inter,sans-serif;letter-spacing:.12em;color:#8A5C00">CLUSTER 9 · WEBSITE</div>
        <div style="font:500 12px/1.4 Inter,sans-serif;color:#635F5A">~81 routes · unverified</div>
      </div>
      <div style="font:400 12px/1.75 Inter,sans-serif;color:#1B1B1B;margin-bottom:12px">
        I hold ~30 exported pages, not the route table, so exits are unverified. Three structural risks already visible:
      </div>
      <ol style="margin:0;padding-inline-start:16px;font:500 12px/1.75 Inter,sans-serif;color:#1B1B1B">
        <li style="margin-bottom:6px"><strong>Pricing pages contradict the app</strong> — tiers with prices vs the app's free Premium account</li>
        <li style="margin-bottom:6px"><strong>Exams section still navigable</strong> — out of Phase 1 scope; reads as abandoned</li>
        <li><strong>Demo data indexable</strong> — noindex before launch or poison your SEO start</li>
      </ol>
    </div>
  </div>

</div>
```

## Logic

_Template-only component — no logic class._
