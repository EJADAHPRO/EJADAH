# 06 Audit Phase 2 - Journey Maps

Six user types across seven stages, every cell naming the real screen and button, breakpoints marked.

**Exported:** 2 August 2026  
**Size:** 28,198 characters · template 167 lines

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

<div style="width:1780px;padding:48px 40px 64px;box-sizing:border-box">

  <div style="display:flex;align-items:flex-end;justify-content:space-between;gap:40px;margin-bottom:30px">
    <div style="min-width:0">
      <div style="font:800 12px/1 Inter,sans-serif;letter-spacing:.14em;color:#A83A0C;margin-bottom:12px">PHASE 2 DELIVERABLE · 30 JULY 2026</div>
      <h1 style="font:700 38px/1.15 'Playfair Display',serif;margin:0 0 10px">Journey maps — six user types, first touch to referral</h1>
      <p style="font:400 14px/1.7 Inter,sans-serif;color:#635F5A;max-width:860px;margin:0">Each map runs left to right through the same seven stages, naming the actual screen and the actual button at every step. Breakpoints are marked where the journey stalls, dumps the user, or is missing an obvious next step. The six types are derived from what is built, not from a persona workshop — the app already ships a persona switcher with exactly these roles.</p>
    </div>
    <div style="flex:none;background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:16px 18px">
      <div style="font:800 11px/1 Inter,sans-serif;letter-spacing:.1em;color:#5A5751;margin-bottom:12px">STEP STATUS</div>
      <div style="display:grid;gap:7px">
        <div style="display:flex;align-items:center;gap:9px"><span style="width:22px;height:8px;border-radius:3px;background:#2D9B68"></span><span style="font:600 11.5px/1 Inter,sans-serif">Smooth — built and connected</span></div>
        <div style="display:flex;align-items:center;gap:9px"><span style="width:22px;height:8px;border-radius:3px;background:#FFAA18"></span><span style="font:600 11.5px/1 Inter,sans-serif">Stalls — works, but loses people</span></div>
        <div style="display:flex;align-items:center;gap:9px"><span style="width:22px;height:8px;border-radius:3px;background:#FF2D32"></span><span style="font:600 11.5px/1 Inter,sans-serif">Breakpoint — missing next step</span></div>
      </div>
    </div>
  </div>

  <div style="display:grid;grid-template-columns:repeat(7,1fr);gap:10px;margin-bottom:12px;padding:0 21.5px">
    <div style="font:800 11px/1.3 Inter,sans-serif;letter-spacing:.08em;color:#5A5751;text-align:center">FIRST TOUCH</div>
    <div style="font:800 11px/1.3 Inter,sans-serif;letter-spacing:.08em;color:#5A5751;text-align:center">CONSIDERATION</div>
    <div style="font:800 11px/1.3 Inter,sans-serif;letter-spacing:.08em;color:#5A5751;text-align:center">SIGNUP</div>
    <div style="font:800 11px/1.3 Inter,sans-serif;letter-spacing:.08em;color:#5A5751;text-align:center">ACTIVATION</div>
    <div style="font:800 11px/1.3 Inter,sans-serif;letter-spacing:.08em;color:#5A5751;text-align:center">HABIT</div>
    <div style="font:800 11px/1.3 Inter,sans-serif;letter-spacing:.08em;color:#5A5751;text-align:center">PAYMENT</div>
    <div style="font:800 11px/1.3 Inter,sans-serif;letter-spacing:.08em;color:#5A5751;text-align:center">REFERRAL</div>
  </div>

  <!-- 1 · STUDENT -->
  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:18px 20px;margin-bottom:12px">
    <div style="display:flex;align-items:baseline;gap:12px;margin-bottom:14px">
      <div style="font:700 17px/1.3 'Playfair Display',serif">1 · Dental student</div>
      <div style="font:500 12px/1 Inter,sans-serif;color:#6B6862">3rd–5th year · no money, plenty of time · wants to pass this term</div>
    </div>
    <div style="display:grid;grid-template-columns:repeat(7,1fr);gap:10px">
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;margin-bottom:5px">Colleague's card or referral link</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Public profile → install CTA</div></div>
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;margin-bottom:5px">Carousel → guest roadmap</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">No wall yet — the hook</div></div>
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;margin-bottom:5px">Result gate → Create a free account</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Converts after 4 answers invested</div></div>
      <div style="background:rgba(255,45,50,.06);border:1.5px solid rgba(255,45,50,.35);border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#FF2D32;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;color:#C41419;margin-bottom:5px">BREAKPOINT — roadmap is career-abroad only</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">A 3rd-year wants "pass endo this term", not the UK in 2029</div></div>
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;margin-bottom:5px">Flashcards → daily review streak</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Home "Today" card brings them back</div></div>
      <div style="background:rgba(255,170,24,.1);border:1.5px solid rgba(255,170,24,.5);border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#FFAA18;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;color:#8A5C00;margin-bottom:5px">STALLS — one session at EGP 650</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Real budget is nearer 200. No student rate exists</div></div>
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;margin-bottom:5px">Invite a colleague · +1 month</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Students refer hardest — same year group</div></div>
    </div>
    <div style="margin-top:12px;background:rgba(255,45,50,.05);border-radius:10px;padding:11px 13px;font:500 11.5px/1.65 Inter,sans-serif"><strong style="color:#C41419">Fix:</strong> give the roadmap a student branch — "I'm still studying" as a first-question option that produces a term plan (topics, flashcard decks, one tutor) instead of an emigration route. And add a group-session or student rate; three students sharing a tutor at EGP 250 each earns the tutor more than one at 650.</div>
  </div>

  <!-- 2 · FRESH GRAD -->
  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:18px 20px;margin-bottom:12px">
    <div style="display:flex;align-items:baseline;gap:12px;margin-bottom:14px">
      <div style="font:700 17px/1.3 'Playfair Display',serif">2 · Fresh graduate</div>
      <div style="font:500 12px/1 Inter,sans-serif;color:#6B6862">Intern or 1 year out · maximum ambition, minimum cash · the emigration decision is live</div>
    </div>
    <div style="display:grid;grid-template-columns:repeat(7,1fr);gap:10px">
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;margin-bottom:5px">Facebook group → country guide (web)</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">SEO capture, once guides ship</div></div>
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;margin-bottom:5px">Guide → guest roadmap</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Exact question they came with</div></div>
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;margin-bottom:5px">Result gate → signup</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Highest-intent signup in the product</div></div>
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;margin-bottom:5px">My plan → "start attestation now"</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">A task they can do this week, free</div></div>
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;margin-bottom:5px">Shortlist → deadline alerts</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Works while the app is closed</div></div>
      <div style="background:rgba(255,45,50,.06);border:1.5px solid rgba(255,45,50,.35);border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#FF2D32;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;color:#C41419;margin-bottom:5px">BREAKPOINT — nothing routes to the cheapest useful move</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Free intro call exists but the result never offers it</div></div>
      <div style="background:rgba(255,170,24,.1);border:1.5px solid rgba(255,170,24,.5);border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#FFAA18;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;color:#8A5C00;margin-bottom:5px">STALLS — share is generic</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Their roadmap is the shareable artefact, not a referral code</div></div>
    </div>
    <div style="margin-top:12px;background:rgba(255,45,50,.05);border-radius:10px;padding:11px 13px;font:500 11.5px/1.65 Inter,sans-serif"><strong style="color:#C41419">Fix:</strong> put a single "Talk to someone who did this — 15 minutes, free" button directly on the roadmap result, above the stage list. It is the lowest-friction step in the product and currently nothing points at it. Then make the share sheet default to sharing the roadmap itself with the referral code attached.</div>
  </div>

  <!-- 3 · GP DENTIST -->
  <div style="background:#fff;border:2px solid #FFC62E;border-radius:18px;padding:18px 20px;margin-bottom:12px">
    <div style="display:flex;align-items:baseline;gap:12px;margin-bottom:14px">
      <div style="font:700 17px/1.3 'Playfair Display',serif">3 · GP dentist</div>
      <div style="font:500 12px/1 Inter,sans-serif;color:#6B6862">2–8 years qualified · earning, time-poor, decisive · <strong style="color:#8A5C00">the core persona and the best journey in the product</strong></div>
    </div>
    <div style="display:grid;grid-template-columns:repeat(7,1fr);gap:10px">
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;margin-bottom:5px">Search "ORE fees 2026" → exam hub</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Sourced numbers nobody else publishes</div></div>
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;margin-bottom:5px">Database → filter → compare 3</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Real 199 records, expired hidden</div></div>
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;margin-bottom:5px">Save a programme → signup</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Saving is the natural wall</div></div>
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;margin-bottom:5px">Roadmap → My plan → tracker</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Every step feeds the next</div></div>
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;margin-bottom:5px">Deadline alerts + stage nudges</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Months between visits, still retained</div></div>
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;margin-bottom:5px">Tracker hits Interview → mentor</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Highest-stakes week; highest willingness to pay</div></div>
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;margin-bottom:5px">Card + roadmap share</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Peers ask how they did it</div></div>
    </div>
    <div style="margin-top:12px;background:rgba(45,155,104,.08);border-radius:10px;padding:11px 13px;font:500 11.5px/1.65 Inter,sans-serif"><strong style="color:#1B6B47">No breakpoints.</strong> Protect this path above all others: it is the one journey where discovery, activation, retention, payment and referral all connect without a gap. Every change elsewhere should be checked against whether it disturbs it.</div>
  </div>

  <!-- 4 · SPECIALIST -->
  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:18px 20px;margin-bottom:12px">
    <div style="display:flex;align-items:baseline;gap:12px;margin-bottom:14px">
      <div style="font:700 17px/1.3 'Playfair Display',serif">4 · Specialist / consultant</div>
      <div style="font:500 12px/1 Inter,sans-serif;color:#6B6862">Master's or board held · not emigrating · wants standing, CPD and to be found</div>
    </div>
    <div style="display:grid;grid-template-columns:repeat(7,1fr);gap:10px">
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;margin-bottom:5px">Invited to tutor, or a peer's card</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Supply-side recruitment</div></div>
      <div style="background:rgba(255,45,50,.06);border:1.5px solid rgba(255,45,50,.35);border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#FF2D32;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;color:#C41419;margin-bottom:5px">BREAKPOINT — Home assumes they're leaving</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Roadmap CTA is wrong for someone who arrived</div></div>
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;margin-bottom:5px">Signup → persona "Specialist"</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Profiling step 1 does capture this</div></div>
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;margin-bottom:5px">Build CV → public profile → card</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Their real activation is being findable</div></div>
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;margin-bottom:5px">CPD ledger + card analytics</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Returns monthly, not daily — that's fine</div></div>
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;margin-bottom:5px">Physical card EGP 299 · earns via tutoring</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">They are net revenue-positive, not a buyer</div></div>
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;margin-bottom:5px">Card at every conference</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Highest-reach referrer you have</div></div>
    </div>
    <div style="margin-top:12px;background:rgba(255,45,50,.05);border-radius:10px;padding:11px 13px;font:500 11.5px/1.65 Inter,sans-serif"><strong style="color:#C41419">Fix:</strong> when persona is Specialist, swap Home's primary CTA from "Build your career roadmap" to "Set up your professional card" and lead with CPD, certificates and card views. The persona switcher already exists — the Home CTA just doesn't read it for this role.</div>
  </div>

  <!-- 5 · TUTOR -->
  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:18px 20px;margin-bottom:12px">
    <div style="display:flex;align-items:baseline;gap:12px;margin-bottom:14px">
      <div style="font:700 17px/1.3 'Playfair Display',serif">5 · Tutor / mentor / consultant</div>
      <div style="font:500 12px/1 Inter,sans-serif;color:#6B6862">Supply side · <strong style="color:#8A5C00">harder to replace than demand — churn here costs most</strong></div>
    </div>
    <div style="display:grid;grid-template-columns:repeat(7,1fr);gap:10px">
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;margin-bottom:5px">"Become a tutor" in Connect</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Or direct recruitment</div></div>
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;margin-bottom:5px">70/30 split stated up front</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Live earnings estimate in step 4</div></div>
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;margin-bottom:5px">6-step application · saves drafts</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Can leave and return</div></div>
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;margin-bottom:5px">Approved → dashboard</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Review timeline explained honestly</div></div>
      <div style="background:rgba(255,45,50,.06);border:1.5px solid rgba(255,45,50,.35);border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#FF2D32;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;color:#C41419;margin-bottom:5px">BREAKPOINT — approved, zero bookings, no playbook</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Dashboard shows empty stats and no instruction</div></div>
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;margin-bottom:5px">Earnings · payouts itemised</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">They get paid — that is the retention</div></div>
      <div style="background:rgba(255,170,24,.1);border:1.5px solid rgba(255,170,24,.5);border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#FFAA18;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;color:#8A5C00;margin-bottom:5px">STALLS — no "refer a colleague to tutor"</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Good tutors know good tutors</div></div>
    </div>
    <div style="margin-top:12px;background:rgba(255,45,50,.05);border-radius:10px;padding:11px 13px;font:500 11.5px/1.65 Inter,sans-serif"><strong style="color:#C41419">Fix (Module E, already specced):</strong> the approval screen gains three checkboxed actions — share your profile on WhatsApp, switch free intro calls on, add 5+ weekly hours — under the line "tutors who do all three get their first booking 4× faster". An approved tutor with no students churns inside a month and takes their availability with them.</div>
  </div>

  <!-- 6 · CLINIC OWNER -->
  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:18px 20px;margin-bottom:26px">
    <div style="display:flex;align-items:baseline;gap:12px;margin-bottom:14px">
      <div style="font:700 17px/1.3 'Playfair Display',serif">6 · Clinic owner</div>
      <div style="font:500 12px/1 Inter,sans-serif;color:#6B6862">Consulting demand · lowest volume, highest ticket · <strong style="color:#8A5C00">the thinnest journey in the product</strong></div>
    </div>
    <div style="display:grid;grid-template-columns:repeat(7,1fr);gap:10px">
      <div style="background:rgba(255,45,50,.06);border:1.5px solid rgba(255,45,50,.35);border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#FF2D32;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;color:#C41419;margin-bottom:5px">BREAKPOINT — no first touch exists</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Nothing published on pricing, staffing or equipment</div></div>
      <div style="background:rgba(255,170,24,.1);border:1.5px solid rgba(255,170,24,.5);border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#FFAA18;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;color:#8A5C00;margin-bottom:5px">STALLS — consulting list is unreachable in practice</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Third tab of Connect, no upstream link</div></div>
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;margin-bottom:5px">Signup is trivial for them</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Motivated by a specific problem</div></div>
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;margin-bottom:5px">Free 15-min intro call</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Right instrument for a high ticket</div></div>
      <div style="background:rgba(255,170,24,.1);border:1.5px solid rgba(255,170,24,.5);border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#FFAA18;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;color:#8A5C00;margin-bottom:5px">STALLS — nothing to return for</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">No owner-facing content or tools</div></div>
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;margin-bottom:5px">Consulting package — highest ticket</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">One booking &gt; twenty tutoring hours</div></div>
      <div style="background:#F5F2EC;border-radius:12px;padding:12px 11px"><div style="height:4px;border-radius:2px;background:#2D9B68;margin-bottom:9px"></div><div style="font:700 11.5px/1.4 Inter,sans-serif;margin-bottom:5px">Owner-to-owner word of mouth</div><div style="font:400 11px/1.55 Inter,sans-serif;color:#5A5751">Small, tight, high-trust network</div></div>
    </div>
    <div style="margin-top:12px;background:rgba(255,45,50,.05);border-radius:10px;padding:11px 13px;font:500 11.5px/1.65 Inter,sans-serif"><strong style="color:#C41419">Fix, but fix late:</strong> this needs content marketing, not product — one honest piece on what a Cairo clinic actually costs to open, ending in a consultant. Until that exists the consulting marketplace has no demand funnel. Cheap interim: cross-sell a consultant from the Business &amp; Paradental course track, which is the only place these people already are.</div>
  </div>

  <!-- SUMMARY -->
  <div style="background:#1B1B1B;border-radius:18px;padding:24px 28px">
    <div style="font:800 11px/1 Inter,sans-serif;letter-spacing:.12em;color:#FFC62E;margin-bottom:14px">WHAT THE SIX MAPS SAY TOGETHER</div>
    <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:18px">
      <div>
        <div style="font:700 14px/1.4 Inter,sans-serif;color:#fff;margin-bottom:7px">One journey is finished</div>
        <div style="font:400 12.5px/1.75 Inter,sans-serif;color:rgba(255,255,255,.7)">The GP dentist path has no gaps. It is also the persona with money and urgency. Everything else should be measured against it — and nothing should be shipped that disturbs it.</div>
      </div>
      <div>
        <div style="font:700 14px/1.4 Inter,sans-serif;color:#fff;margin-bottom:7px">Two personas meet the wrong Home</div>
        <div style="font:400 12.5px/1.75 Inter,sans-serif;color:rgba(255,255,255,.7)">Students and specialists both land on a roadmap CTA built for someone emigrating. The persona switcher exists; Home's primary CTA simply doesn't branch on it for those two roles. Cheapest high-value fix on this page.</div>
      </div>
      <div>
        <div style="font:700 14px/1.4 Inter,sans-serif;color:#fff;margin-bottom:7px">The supply side has the costliest gap</div>
        <div style="font:400 12.5px/1.75 Inter,sans-serif;color:rgba(255,255,255,.7)">An approved tutor with no students is a lost tutor, and tutors are harder to replace than students. The first-student playbook is small work with an outsized effect on marketplace liquidity.</div>
      </div>
    </div>
  </div>

</div>
```

## Logic

_Template-only component — no logic class._
