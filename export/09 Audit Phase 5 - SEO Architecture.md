# 09 Audit Phase 5 - SEO Architecture

Target URL architecture (~400 pages), Arabic-first, plus what blocks launch.

**Exported:** 2 August 2026  
**Size:** 12,663 characters · template 125 lines

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
    <div style="font:800 12px/1 Inter,sans-serif;letter-spacing:.14em;color:#A83A0C;margin-bottom:12px">PHASE 5 DELIVERABLE · 30 JULY 2026</div>
    <h1 style="font:700 38px/1.15 'Playfair Display',serif;margin:0 0 10px">SEO &amp; SEM — architecture, and what to build</h1>
    <p style="font:400 14px/1.7 Inter,sans-serif;color:#635F5A;margin:0 0 10px">Website only; the app has no search surface. Scope caveat repeated from Phase 1: I hold roughly 30 exported pages, not the route table, so I can propose the target architecture but cannot audit your current internal linking or metadata without a crawl.</p>
    <div style="background:#1B1B1B;border-radius:12px;padding:14px 17px">
      <div style="font:800 10.5px/1 Inter,sans-serif;letter-spacing:.12em;color:#FFC62E;margin-bottom:8px">THE ONE THING THAT MATTERS MOST</div>
      <div style="font:500 13px/1.7 Inter,sans-serif;color:#fff">Your users search in Arabic. <strong>معادلة شهادة طب الأسنان في بريطانيا</strong> has no good answer online — the competition is a Facebook comment from 2019. You already hold sourced, dated data for 23 countries and 199 programmes, and almost nobody in this niche does Arabic SEO properly. That asymmetry is worth more than any English head term you could chase.</div>
    </div>
  </div>

  <div style="display:grid;grid-template-columns:1.15fr 1fr;gap:20px;margin-bottom:22px">

    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:24px 26px">
      <div style="font:700 20px/1.3 'Playfair Display',serif;margin-bottom:6px">Target URL architecture</div>
      <p style="font:400 12.5px/1.7 Inter,sans-serif;color:#635F5A;margin:0 0 16px">One page per question a dentist actually types. Every path below is generated from data you already own, which is why this is a publishing job rather than a writing job.</p>

      <div style="background:#F5F2EC;border-radius:14px;padding:16px;font:500 12.5px/2.05 Inter,sans-serif;direction:ltr;text-align:left;margin-bottom:12px">
        <div style="font:800 10.5px/1 Inter,sans-serif;letter-spacing:.1em;color:#5A5751;margin-bottom:11px">COUNTRY — 23 × 4 = 92 pages</div>
        /guides/<span style="color:#A83A0C">{country}</span><br>
        /guides/<span style="color:#A83A0C">{country}</span>/costs &nbsp;·&nbsp; /salary &nbsp;·&nbsp; /exam<br>
        <span style="font-size:11px;color:#5A5751">Each split targets a distinct intent: "how much", "what will I earn", "what's the test".</span>
      </div>

      <div style="background:#F5F2EC;border-radius:14px;padding:16px;font:500 12.5px/2.05 Inter,sans-serif;direction:ltr;text-align:left;margin-bottom:12px">
        <div style="font:800 10.5px/1 Inter,sans-serif;letter-spacing:.1em;color:#5A5751;margin-bottom:11px">PROGRAMMES — ~199 + ~60 index pages</div>
        /programmes/<span style="color:#A83A0C">{university-slug}</span>-<span style="color:#A83A0C">{degree}</span><br>
        /programmes/<span style="color:#A83A0C">{country}</span>/<span style="color:#A83A0C">{specialty}</span> &nbsp;<span style="font-size:11px;color:#5A5751">— filtered indexes</span><br>
        /programmes/scholarships &nbsp;·&nbsp; /programmes/no-ielts
      </div>

      <div style="background:#F5F2EC;border-radius:14px;padding:16px;font:500 12.5px/2.05 Inter,sans-serif;direction:ltr;text-align:left;margin-bottom:12px">
        <div style="font:800 10.5px/1 Inter,sans-serif;letter-spacing:.1em;color:#5A5751;margin-bottom:11px">COMPARISON &amp; EXAMS — the missing money pages</div>
        /compare/<span style="color:#A83A0C">{a}</span>-vs-<span style="color:#A83A0C">{b}</span> &nbsp;<span style="font-size:11px;color:#5A5751">— uk-vs-germany, uae-vs-saudi…</span><br>
        /exams/<span style="color:#A83A0C">{ore|adc|ndeb|inbde|sdle|dha|qchp}</span><br>
        /exams/<span style="color:#A83A0C">{code}</span>/fees &nbsp;·&nbsp; /dates &nbsp;·&nbsp; /from-egypt
      </div>

      <div style="background:#F5F2EC;border-radius:14px;padding:16px;font:500 12.5px/2.05 Inter,sans-serif;direction:ltr;text-align:left">
        <div style="font:800 10.5px/1 Inter,sans-serif;letter-spacing:.1em;color:#5A5751;margin-bottom:11px">PEOPLE &amp; TRUST — free backlinks</div>
        /dr/<span style="color:#A83A0C">{slug}</span> &nbsp;<span style="font-size:11px;color:#5A5751">— one per NFC card, self-multiplying</span><br>
        /verify/<span style="color:#A83A0C">{certificate-code}</span> &nbsp;<span style="font-size:11px;color:#5A5751">— already built</span><br>
        /tutors/<span style="color:#A83A0C">{specialty}</span> &nbsp;·&nbsp; /mentors/<span style="color:#A83A0C">{country}</span>
      </div>
    </div>

    <div style="display:grid;gap:14px;align-content:start">
      <div style="background:rgba(255,45,50,.05);border:1.5px solid rgba(255,45,50,.3);border-radius:18px;padding:20px 22px">
        <div style="font:800 11px/1 Inter,sans-serif;letter-spacing:.1em;color:#C41419;margin-bottom:12px">BLOCKS LAUNCH — DO THIS FIRST</div>
        <div style="font:700 15px/1.4 Inter,sans-serif;margin-bottom:7px">Noindex every route carrying demo data</div>
        <div style="font:400 12.5px/1.7 Inter,sans-serif;color:#635F5A;margin-bottom:14px">Ranking with invented tutor names is worse than not ranking. Google's first impression of a domain is expensive to undo, and you only get one.</div>
        <div style="font:700 15px/1.4 Inter,sans-serif;margin-bottom:7px">Resolve the pricing contradiction</div>
        <div style="font:400 12.5px/1.7 Inter,sans-serif;color:#635F5A">The exported pages still show membership tiers with prices while the app sells courses one at a time. Whichever is right, both surfaces must say it — a visitor who checks two pages and finds two answers stops trusting the numbers you got right.</div>
      </div>

      <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:20px 22px">
        <div style="font:800 11px/1 Inter,sans-serif;letter-spacing:.1em;color:#5A5751;margin-bottom:12px">STRUCTURALLY MISSING</div>
        <div style="display:grid;gap:11px;font:400 12.5px/1.7 Inter,sans-serif;color:#635F5A">
          <div><strong style="color:#1B1B1B">Arabic pages with hreflang.</strong> Not translated afterwards — authored in Arabic, with the exam codes left in Latin. Highest-value gap on this page.</div>
          <div><strong style="color:#1B1B1B">Comparison pages.</strong> "UK vs Germany for Egyptian dentists" is a literal search string and you hold both datasets already.</div>
          <div><strong style="color:#1B1B1B">Exam hubs.</strong> "ORE Part 1 fees 2026" — you can answer with a sourced figure and a date, which nobody else does.</div>
          <div><strong style="color:#1B1B1B">Schema.</strong> Course, FAQPage on guide questions, Person on tutors, EducationalOrganization. None visible in the exports.</div>
          <div><strong style="color:#1B1B1B">A "verified on" date on every fact.</strong> Freshness is a ranking input and a trust signal at once. It is also already in your data model.</div>
        </div>
      </div>
    </div>
  </div>

  <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:14px;margin-bottom:22px">
    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:18px 20px">
      <div style="font:800 11px/1 Inter,sans-serif;letter-spacing:.1em;color:#1B6B47;margin-bottom:10px">SEM-READY TODAY</div>
      <div style="font:400 12.5px/1.7 Inter,sans-serif;color:#635F5A;margin-bottom:10px">Country guides and the tutoring lists. Single intent, single CTA, content that matches the ad promise exactly.</div>
      <div style="font:600 12px/1.6 Inter,sans-serif;color:#1B1B1B">Send paid traffic here and nowhere else.</div>
    </div>
    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:18px 20px">
      <div style="font:800 11px/1 Inter,sans-serif;letter-spacing:.1em;color:#8A5C00;margin-bottom:10px">WOULD BURN SPEND</div>
      <div style="font:400 12.5px/1.7 Inter,sans-serif;color:#635F5A;margin-bottom:10px">The homepage and the 81-route sprawl. A visitor who clicks an ad about the ORE and lands on a general homepage bounces, and you paid for it.</div>
      <div style="font:600 12px/1.6 Inter,sans-serif;color:#1B1B1B">No ad should point at a page that doesn't name the thing in the ad.</div>
    </div>
    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:18px 20px">
      <div style="font:800 11px/1 Inter,sans-serif;letter-spacing:.1em;color:#5A5751;margin-bottom:10px">THE COMPOUNDING ONE</div>
      <div style="font:400 12.5px/1.7 Inter,sans-serif;color:#635F5A;margin-bottom:10px">Every NFC card sold creates a <span style="direction:ltr;unicode-bidi:isolate">/dr/{slug}</span> page that a real person shares deliberately. That is a backlink you did not buy, on a domain you own.</div>
      <div style="font:600 12px/1.6 Inter,sans-serif;color:#1B1B1B">Distribution and SEO are the same product here.</div>
    </div>
  </div>

  <div style="background:#1B1B1B;border-radius:20px;padding:26px 30px">
    <div style="font:800 11px/1 Inter,sans-serif;letter-spacing:.12em;color:#FFC62E;margin-bottom:6px">SEQUENCE</div>
    <div style="font:700 22px/1.3 'Playfair Display',serif;color:#fff;margin-bottom:18px">Roughly 400 pages, none of them written by hand</div>
    <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:16px">
      <div style="background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.12);border-radius:14px;padding:16px">
        <div style="font:800 10.5px/1 Inter,sans-serif;color:#7FD4A6;margin-bottom:9px">1 · BEFORE LAUNCH</div>
        <div style="font:500 12.5px/1.75 Inter,sans-serif;color:rgba(255,255,255,.8)">Noindex demo routes. Fix the pricing contradiction. Unlink the dead Exams section.</div>
      </div>
      <div style="background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.12);border-radius:14px;padding:16px">
        <div style="font:800 10.5px/1 Inter,sans-serif;color:#FFC62E;margin-bottom:9px">2 · WEEK ONE LIVE</div>
        <div style="font:500 12.5px/1.75 Inter,sans-serif;color:rgba(255,255,255,.8)">23 country guides in English and Arabic. They exist as data already — this is templating, not authoring.</div>
      </div>
      <div style="background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.12);border-radius:14px;padding:16px">
        <div style="font:800 10.5px/1 Inter,sans-serif;color:#FFC62E;margin-bottom:9px">3 · MONTH ONE</div>
        <div style="font:500 12.5px/1.75 Inter,sans-serif;color:rgba(255,255,255,.8)">199 programme pages + filtered indexes. Add schema and "verified on" dates in the same pass.</div>
      </div>
      <div style="background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.12);border-radius:14px;padding:16px">
        <div style="font:800 10.5px/1 Inter,sans-serif;color:#FFC62E;margin-bottom:9px">4 · QUARTER ONE</div>
        <div style="font:500 12.5px/1.75 Inter,sans-serif;color:rgba(255,255,255,.8)">Comparison pages and exam hubs, ordered by what Search Console shows people are already finding you for.</div>
      </div>
    </div>
    <div style="margin-top:18px;background:rgba(255,198,46,.12);border:1px solid rgba(255,198,46,.3);border-radius:12px;padding:14px 16px;font:500 13px/1.75 Inter,sans-serif;color:#fff">
      Note the shape of this: steps 2 and 3 are <strong style="color:#FFC62E">templating work over data you already own</strong>. The expensive part of content SEO — having something true to say — is the part you have already done. The eleven unsourced regulator fees are the one gap, and they are worth closing before these pages publish, because "Pending source" printed 23 times is the wrong first impression for a site whose whole claim is verified data.
    </div>
  </div>

</div>
```

## Logic

_Template-only component — no logic class._
