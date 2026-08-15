# 07 Audit Phase 3 - Interconnection

Current state (13 chains, 3 crossings) vs target state; the six missing cross-links A-F.

**Exported:** 2 August 2026  
**Size:** 17,196 characters · template 173 lines

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

<div style="width:1760px;padding:48px 40px 64px;box-sizing:border-box">

  <div style="margin-bottom:30px;max-width:900px">
    <div style="font:800 12px/1 Inter,sans-serif;letter-spacing:.14em;color:#A83A0C;margin-bottom:12px">PHASE 3 DELIVERABLE · 30 JULY 2026</div>
    <h1 style="font:700 38px/1.15 'Playfair Display',serif;margin:0 0 10px">Interconnection — current state vs target state</h1>
    <p style="font:400 14px/1.7 Inter,sans-serif;color:#635F5A;margin:0 0 10px">A feature that doesn't feed another feature is a page. The two diagrams below show the same eight clusters: on the left, the links that exist today; on the right, the same map with the six missing links drawn in. Every arrow is a real navigation the app either performs or should.</p>
    <p style="font:400 13px/1.7 Inter,sans-serif;color:#635F5A;margin:0">The finding in one line: <strong>Ejadah is well connected along the emigration spine (roadmap → guides → programmes → tracker) and barely connected across it — three crossings against thirteen chains, and not one of them reaches a course.</strong></p>
  </div>

  <div style="display:grid;grid-template-columns:1fr 1fr;gap:20px;margin-bottom:26px">

    <!-- CURRENT -->
    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:24px 26px">
      <div style="display:flex;align-items:baseline;gap:12px;margin-bottom:6px">
        <div style="font:700 20px/1.3 'Playfair Display',serif">Current state</div>
        <div style="font:600 12px/1.4 Inter,sans-serif;color:#1B6B47">13 chains · 27 hops</div>
      </div>
      <p style="font:400 12.5px/1.7 Inter,sans-serif;color:#635F5A;margin:0 0 6px">Strong vertically. The emigration path is a genuine chain; Learn is a self-contained loop; the marketplaces are reached mostly by browsing rather than by need.</p>
      <p style="font:400 11.5px/1.6 Inter,sans-serif;color:#5A5751;margin:0 0 18px;background:#F5F2EC;border-radius:8px;padding:8px 11px"><strong>Counting unit:</strong> a <strong>chain</strong> is one journey a user actually takes; a <strong>hop</strong> is one arrow inside it. "Roadmap → guide → programmes" is 1 chain, 2 hops. Totals below: 5 + 3 + 3 + 2 = 13 chains.</p>

      <div style="background:#F5F2EC;border-radius:14px;padding:16px;margin-bottom:10px">
        <div style="font:800 11px/1 Inter,sans-serif;letter-spacing:.1em;color:#5A5751;margin-bottom:12px">THE EMIGRATION SPINE · 5 chains</div>
        <div style="font:500 12.5px/2 Inter,sans-serif;color:#1B1B1B">
          Roadmap result <span style="color:#1B6B47;font-weight:700">→</span> country guide <span style="color:#1B6B47;font-weight:700">→</span> programmes there<br>
          Programme saved <span style="color:#1B6B47;font-weight:700">→</span> Home deadline strip <span style="color:#1B6B47;font-weight:700">→</span> tracker <span style="color:#1B6B47;font-weight:700">→</span> documents<br>
          Roadmap result <span style="color:#1B6B47;font-weight:700">→</span> My plan <span style="color:#1B6B47;font-weight:700">→</span> stage tasks<br>
          Filter set <span style="color:#1B6B47;font-weight:700">→</span> saved alert <span style="color:#1B6B47;font-weight:700">→</span> notification while closed<br>
          Eligibility gap <span style="color:#1B6B47;font-weight:700">→</span> mentor from that programme &nbsp;<span style="font-size:10px;font-weight:800;color:#8A5C00;background:rgba(255,170,24,.14);padding:2px 6px;border-radius:5px">CROSSING</span>
        </div>
      </div>

      <div style="background:#F5F2EC;border-radius:14px;padding:16px;margin-bottom:10px">
        <div style="font:800 11px/1 Inter,sans-serif;letter-spacing:.1em;color:#5A5751;margin-bottom:12px">THE LEARN LOOP · 3 chains, self-contained</div>
        <div style="font:500 12.5px/2 Inter,sans-serif;color:#1B1B1B">
          Course complete <span style="color:#1B6B47;font-weight:700">→</span> certificate <span style="color:#1B6B47;font-weight:700">→</span> CV <span style="color:#1B6B47;font-weight:700">→</span> public profile <span style="color:#1B6B47;font-weight:700">→</span> card<br>
          Quiz <span style="color:#1B6B47;font-weight:700">→</span> flashcards <span style="color:#1B6B47;font-weight:700">→</span> daily review <span style="color:#1B6B47;font-weight:700">→</span> Home "Today"<br>
          Certificate <span style="color:#1B6B47;font-weight:700">→</span> CPD ledger
        </div>
      </div>

      <div style="background:#F5F2EC;border-radius:14px;padding:16px;margin-bottom:10px">
        <div style="font:800 11px/1 Inter,sans-serif;letter-spacing:.1em;color:#5A5751;margin-bottom:12px">MARKETPLACE · 3 chains · 2 of them are crossings</div>
        <div style="font:500 12.5px/2 Inter,sans-serif;color:#1B1B1B">
          Home matched tutors <span style="color:#1B6B47;font-weight:700">→</span> profile <span style="color:#1B6B47;font-weight:700">→</span> booking &nbsp;<span style="font-size:10px;font-weight:800;color:#8A5C00;background:rgba(255,170,24,.14);padding:2px 6px;border-radius:5px">CROSSING</span><br>
          Session end <span style="color:#1B6B47;font-weight:700">→</span> practice list <span style="color:#1B6B47;font-weight:700">→</span> book the next one<br>
          Tracker "Interview" <span style="color:#1B6B47;font-weight:700">→</span> mentor &nbsp;<span style="font-size:10px;font-weight:800;color:#8A5C00;background:rgba(255,170,24,.14);padding:2px 6px;border-radius:5px">CROSSING</span>
        </div>
      </div>

      <div style="background:#F5F2EC;border-radius:14px;padding:16px">
        <div style="font:800 11px/1 Inter,sans-serif;letter-spacing:.1em;color:#5A5751;margin-bottom:12px">OUTWARD · 2 chains, the growth loop</div>
        <div style="font:500 12.5px/2 Inter,sans-serif;color:#1B1B1B">
          Card tapped by a stranger <span style="color:#1B6B47;font-weight:700">→</span> public profile <span style="color:#1B6B47;font-weight:700">→</span> "create your own"<br>
          Roadmap saved <span style="color:#1B6B47;font-weight:700">→</span> referral ask <span style="color:#1B6B47;font-weight:700">→</span> +1 month
        </div>
      </div>
    </div>

    <!-- TARGET -->
    <div style="background:#fff;border:2px solid #FFC62E;border-radius:20px;padding:24px 26px">
      <div style="display:flex;align-items:baseline;gap:12px;margin-bottom:6px">
        <div style="font:700 20px/1.3 'Playfair Display',serif">Target state</div>
        <div style="font:600 12px/1.4 Inter,sans-serif;color:#8A5C00">+6 links · the same map, connected across</div>
      </div>
      <p style="font:400 12.5px/1.7 Inter,sans-serif;color:#635F5A;margin:0 0 18px">Every new arrow crosses from Career into Learn or the marketplace at a moment of felt need. None of them is a new feature — all six connect things that already exist.</p>

      <div style="display:grid;gap:10px">
        <div style="background:rgba(255,170,24,.09);border:1.5px solid rgba(255,170,24,.45);border-radius:14px;padding:15px 16px">
          <div style="display:flex;align-items:baseline;gap:9px;margin-bottom:7px">
            <span style="font:800 11px/1 Inter,sans-serif;color:#8A5C00">A</span>
            <span style="font:700 13.5px/1.4 Inter,sans-serif">Programme detail <span style="color:#8A5C00">→</span> tutor for its entry exam</span>
          </div>
          <div style="font:400 12px/1.7 Inter,sans-serif;color:#635F5A">"This programme needs IELTS 7.0 — four tutors prepare it." The requirement is already printed on the page; the person who can fix it is three taps away and never mentioned. <strong style="color:#8A5C00">Highest-intent cross-sell in the product.</strong></div>
        </div>

        <div style="background:rgba(255,170,24,.09);border:1.5px solid rgba(255,170,24,.45);border-radius:14px;padding:15px 16px">
          <div style="display:flex;align-items:baseline;gap:9px;margin-bottom:7px">
            <span style="font:800 11px/1 Inter,sans-serif;color:#8A5C00">B</span>
            <span style="font:700 13.5px/1.4 Inter,sans-serif">Country guide <span style="color:#8A5C00">→</span> mentors who made that move</span>
          </div>
          <div style="font:400 12px/1.7 Inter,sans-serif;color:#635F5A">The guide is the map. A person who walked it is the proof it can be walked — and the free 15-minute intro call means the next step costs nothing.</div>
        </div>

        <div style="background:rgba(255,170,24,.09);border:1.5px solid rgba(255,170,24,.45);border-radius:14px;padding:15px 16px">
          <div style="display:flex;align-items:baseline;gap:9px;margin-bottom:7px">
            <span style="font:800 11px/1 Inter,sans-serif;color:#8A5C00">C</span>
            <span style="font:700 13.5px/1.4 Inter,sans-serif">Roadmap stage <span style="color:#8A5C00">→</span> the course for that stage</span>
          </div>
          <div style="font:400 12px/1.7 Inter,sans-serif;color:#635F5A">"Stage 3 is ORE Part 1 — this course covers its syllabus." <strong>This is the single link that joins the two halves of the product</strong>, and it is the only reason a Career user would ever buy a course.</div>
        </div>

        <div style="background:rgba(255,170,24,.09);border:1.5px solid rgba(255,170,24,.45);border-radius:14px;padding:15px 16px">
          <div style="display:flex;align-items:baseline;gap:9px;margin-bottom:7px">
            <span style="font:800 11px/1 Inter,sans-serif;color:#8A5C00">D</span>
            <span style="font:700 13.5px/1.4 Inter,sans-serif">Quiz failed <span style="color:#8A5C00">→</span> one session on that topic</span>
          </div>
          <div style="font:400 12px/1.7 Inter,sans-serif;color:#635F5A">Scored under 60% is the most honest moment of need in the app. One session, never a package, never blocking the retry.</div>
        </div>

        <div style="background:rgba(255,170,24,.09);border:1.5px solid rgba(255,170,24,.45);border-radius:14px;padding:15px 16px">
          <div style="display:flex;align-items:baseline;gap:9px;margin-bottom:7px">
            <span style="font:800 11px/1 Inter,sans-serif;color:#8A5C00">E</span>
            <span style="font:700 13.5px/1.4 Inter,sans-serif">Tutor approved <span style="color:#8A5C00">→</span> first-student playbook</span>
          </div>
          <div style="font:400 12px/1.7 Inter,sans-serif;color:#635F5A">Supply side. Three actions on the approval screen: share your profile, switch intro calls on, add weekly hours. An approved tutor with no students churns in a month.</div>
        </div>

        <div style="background:rgba(255,170,24,.09);border:1.5px solid rgba(255,170,24,.45);border-radius:14px;padding:15px 16px">
          <div style="display:flex;align-items:baseline;gap:9px;margin-bottom:7px">
            <span style="font:800 11px/1 Inter,sans-serif;color:#8A5C00">F</span>
            <span style="font:700 13.5px/1.4 Inter,sans-serif">Website <span style="color:#8A5C00">↔</span> app</span>
          </div>
          <div style="font:400 12px/1.7 Inter,sans-serif;color:#635F5A">A course bought on the web should deep-link open in the app. A roadmap shared from the app should render as a web page that ends in an install button. Today the two surfaces are strangers.</div>
        </div>
      </div>
    </div>
  </div>

  <!-- THE SPINE DIAGRAM -->
  <div style="background:#1B1B1B;border-radius:20px;padding:26px 30px;margin-bottom:20px">
    <div style="font:800 11px/1 Inter,sans-serif;letter-spacing:.12em;color:#FFC62E;margin-bottom:6px">THE STRUCTURAL POINT</div>
    <div style="font:700 22px/1.3 'Playfair Display',serif;color:#fff;margin-bottom:8px">Three crossings today — and none of them reaches a course</div>
    <p style="font:400 12.5px/1.7 Inter,sans-serif;color:rgba(255,255,255,.6);margin:0 0 18px;max-width:900px">A <strong style="color:#fff">crossing</strong> is a chain that starts in the free half and ends in the paid half. Three exist. All three land on a <em>person</em> — a tutor or a mentor. <strong style="color:#FFC62E">Zero reach a course</strong>, which is the half of the revenue that scales without anyone's time.</p>
    <div style="display:grid;grid-template-columns:1fr auto 1fr;gap:22px;align-items:center">
      <div style="background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.12);border-radius:16px;padding:18px">
        <div style="font:800 10.5px/1 Inter,sans-serif;letter-spacing:.1em;color:#7FD4A6;margin-bottom:12px">CAREER — 9 features, 5 internal chains</div>
        <div style="font:500 12.5px/1.9 Inter,sans-serif;color:rgba(255,255,255,.82)">Roadmap · country guides · programme database · shortlist · alerts · tracker · documents · eligibility · affordability</div>
        <div style="font:400 11.5px/1.7 Inter,sans-serif;color:rgba(255,255,255,.55);margin-top:10px">Free forever. This half earns trust and retention, not revenue.</div>
      </div>
      <div style="text-align:center;padding:0 4px;min-width:150px">
        <div style="font:800 11px/1.5 Inter,sans-serif;color:#FFC62E;letter-spacing:.08em;margin-bottom:10px">3 CROSSINGS<br>TODAY</div>
        <div style="font:400 10.5px/1.6 Inter,sans-serif;color:rgba(255,255,255,.62);text-align:start">eligibility gap → mentor<br>tracker interview → mentor<br>Home matches → tutor</div>
        <div style="font:700 10.5px/1.5 Inter,sans-serif;color:#FF9A8A;margin-top:10px">0 reach a course</div>
      </div>
      <div style="background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.12);border-radius:16px;padding:18px">
        <div style="font:800 10.5px/1 Inter,sans-serif;letter-spacing:.1em;color:#FFC62E;margin-bottom:12px">LEARN + MARKETPLACE — 8 features, 6 internal chains</div>
        <div style="font:500 12.5px/1.9 Inter,sans-serif;color:rgba(255,255,255,.82)">Courses · quizzes · flashcards · certificates · CPD · tutoring · mentoring · consulting</div>
        <div style="font:400 11.5px/1.7 Inter,sans-serif;color:rgba(255,255,255,.55);margin-top:10px">Everything that earns money lives here.</div>
      </div>
    </div>
    <div style="margin-top:18px;background:rgba(255,198,46,.12);border:1px solid rgba(255,198,46,.3);border-radius:12px;padding:14px 16px;font:500 13px/1.75 Inter,sans-serif;color:#fff">
      Three crossings against thirteen chains is still barely connected — and the three that exist are the ambient ones (a Home shelf, a late tracker stage). None fires at the moment a user reads a requirement they cannot yet meet. <strong style="color:#FFC62E">A</strong> fixes that for tutors and <strong style="color:#FFC62E">C</strong> opens the first path to a course at all. Build A first: it is the only place where the user has already read the problem the paid thing solves, printed on the page in front of them.
    </div>
  </div>

  <!-- SEQUENCING -->
  <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:14px">
    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:18px 20px">
      <div style="font:800 11px/1 Inter,sans-serif;letter-spacing:.1em;color:#1B6B47;margin-bottom:12px">BUILD FIRST · A, then C</div>
      <div style="font:400 12.5px/1.75 Inter,sans-serif;color:#635F5A">Both are pure placement — no new screens, no new data. A cross-sell module under the entry requirements, and a course row on the stage card. Each is an afternoon, and together they open the only path from the free half of the product to the paid half.</div>
    </div>
    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:18px 20px">
      <div style="font:800 11px/1 Inter,sans-serif;letter-spacing:.1em;color:#8A5C00;margin-bottom:12px">NEEDS DATA · B and D</div>
      <div style="font:400 12.5px/1.75 Inter,sans-serif;color:#635F5A">B needs mentors tagged by destination country; D needs quiz topics mapped to tutor subjects. Both are one column in a table, but neither works before the real rosters land — so they follow the roster work, not the code.</div>
    </div>
    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:18px 20px">
      <div style="font:800 11px/1 Inter,sans-serif;letter-spacing:.1em;color:#5A5751;margin-bottom:12px">NEEDS ENGINEERING · E and F</div>
      <div style="font:400 12.5px/1.75 Inter,sans-serif;color:#635F5A">E is a design change with a real behavioural claim behind it, so it wants measurement before it is tuned. F is deep-link plumbing across two codebases — schedule it with the web work, not the app work.</div>
    </div>
  </div>

</div>
```

## Logic

_Template-only component — no logic class._
