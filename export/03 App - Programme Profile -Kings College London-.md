# 03 App — Programme Profile (King's College London)

Deep programme profile, nine sections, English and Arabic.

**Source file:** `Ejadah App - Programme Profile.dc.html`  
**Exported:** 2 August 2026  
**Size:** 98,919 characters · template 453 lines · logic 0 lines

> This is a Design Component. It is one self-contained HTML file that opens directly in a browser.
> The **template** is the markup between `<x-dc>` and `</x-dc>`. The **logic** is a `class Component extends DCLogic`
> whose `renderVals()` returns the values the template's `{{ }}` holes read. `{{ }}` holes are dotted lookups only —
> never expressions. To reassemble a working file: document shell → `<x-dc>` + template + `</x-dc>` → `<script data-dc-script>` + logic + `</script>`.

## Template

```html
<helmet data-dc-atomics>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700;800&family=Inter:wght@400;500;600;700;800&family=Amiri:wght@400;700&family=IBM+Plex+Sans+Arabic:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
  body{margin:0;background:#EDE9E1;-webkit-font-smoothing:antialiased}
  a{color:#FF6B1A;text-decoration:none}
  a:hover{color:#FF2D32}
</style>
</helmet>

<div style="display:flex;gap:40px;align-items:flex-start;padding:40px;min-height:100vh;box-sizing:border-box">

  <div style="width:280px;flex:none;position:sticky;top:40px">
    <div style="font:600 11px/1 Inter,sans-serif;letter-spacing:.12em;text-transform:uppercase;color:#FF6B1A;margin-bottom:10px">Masters · deep profile</div>
    <h1 style="font:700 25px/1.2 'Playfair Display',serif;color:#1B1B1B;margin:0 0 10px">King's College London — MSc Endodontology</h1>
    <p style="font:400 13px/1.7 Inter,sans-serif;color:#716D67;margin:0 0 20px">Nine sections, built from the reference pages you sent, now fully bilingual. Every figure comes from that source — nothing invented.</p>

    <div style="font:600 10.5px/1 Inter,sans-serif;letter-spacing:.12em;text-transform:uppercase;color:#716D67;margin-bottom:10px">Language</div>
    <div style="display:flex;gap:8px;margin-bottom:22px">
      <button onClick="{{ setEn }}" style="flex:1;height:40px;border-radius:12px;cursor:pointer;border:1.5px solid {{ enBorder }};background:{{ enBg }};color:{{ enFg }};font:700 13px/1 Inter,sans-serif">EN</button>
      <button onClick="{{ setAr }}" style="flex:1;height:40px;border-radius:12px;cursor:pointer;border:1.5px solid {{ arBorder }};background:{{ arBg }};color:{{ arFg }};font:700 13px/1 'IBM Plex Sans Arabic',sans-serif;letter-spacing:0">عربي</button>
    </div>

    <div style="font:600 10.5px/1 Inter,sans-serif;letter-spacing:.12em;text-transform:uppercase;color:#716D67;margin-bottom:10px">Jump to section</div>
    <div style="display:grid;gap:6px">
      <sc-for list="{{ navItems }}" as="s" hint-placeholder-count="9">
        <button onClick="{{ s.go }}" style="text-align:start;height:38px;padding:0 12px;border-radius:10px;cursor:pointer;background:{{ s.railBg }};color:{{ s.railFg }};border:1.5px solid {{ s.railBorder }};font:600 12.5px/1 Inter,sans-serif">{{ s.railLabel }}</button>
      </sc-for>
    </div>

    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:16px;margin-top:20px">
      <div style="font:600 10.5px/1 Inter,sans-serif;letter-spacing:.12em;text-transform:uppercase;color:#716D67;margin-bottom:10px">Arabic draft — please review</div>
      <div style="font:400 12px/1.7 Inter,sans-serif;color:#1B1B1B">Modern Standard Arabic, Western numerals throughout, and every exam code, software name, university name and currency figure kept in Latin and bidi-isolated. Have a native reviewer check the specialist terms before launch — particularly <span style="direction:rtl;unicode-bidi:isolate">إعادة المعالجة</span>, <span style="direction:rtl;unicode-bidi:isolate">الحشو اللبي</span> and the Syndicate step names.</div>
    </div>
  </div>

  <div style="flex:none">
    <div style="width:390px;height:844px;border-radius:44px;background:#1B1B1B;padding:10px;box-shadow:0 30px 70px rgba(0,0,0,.3);box-sizing:border-box">
      <div dir="{{ dir }}" style="width:370px;height:824px;border-radius:35px;overflow:hidden;background:#FFF9EF;display:flex;flex-direction:column;font-family:{{ ff }};letter-spacing:{{ ls }}">

        <div style="background:#1B1B1B;padding:12px 20px 0;flex:none">
          <div style="display:flex;justify-content:space-between;align-items:center;font-size:11px;font-weight:600;color:rgba(255,255,255,.55)">
            <span>9:41</span>
            <span style="display:flex;gap:5px;align-items:center"><span style="width:16px;height:8px;border:1px solid rgba(255,255,255,.5);border-radius:2px;display:inline-block"></span><span style="width:22px;height:8px;background:rgba(255,255,255,.5);border-radius:2px;display:inline-block"></span></span>
          </div>
        </div>

        <div style="flex:1;overflow-y:auto;overflow-x:hidden;scrollbar-width:thin">

          <div style="background:linear-gradient(180deg,rgba(27,27,27,.72),rgba(27,27,27,.96)), #1B1B1B center/cover no-repeat url(https://picsum.photos/seed/ejadah-kings-guys/760/520);padding:8px 14px 26px">
            <div style="display:flex;align-items:center;justify-content:space-between">
              <button aria-label="{{ t.back }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#fff;display:flex;align-items:center;justify-content:center">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
              </button>
              <button onClick="{{ toggleSave }}" aria-label="{{ t.saveProg }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;display:flex;align-items:center;justify-content:center">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="{{ savedFill }}" stroke="{{ savedStroke }}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20s-7-4.5-7-9.2A4 4 0 0 1 12 8a4 4 0 0 1 7 2.8C19 15.5 12 20 12 20z"></path></svg>
              </button>
            </div>
            <div style="padding:6px 6px 0">
              <div style="display:flex;align-items:center;gap:10px;margin-bottom:14px">
                <img src="https://flagcdn.com/w80/gb.png" alt="United Kingdom" style="width:40px;height:28px;border-radius:5px;object-fit:cover;border:1px solid rgba(255,255,255,.25)">
                <div style="font-size:11.5px;font-weight:500;color:rgba(255,255,255,.6);line-height:1.5">{{ t.hospital }}</div>
              </div>
              <div style="font-size:12.5px;font-weight:600;color:#FFC62E;margin-bottom:6px;direction:ltr;unicode-bidi:isolate;text-align:start">King's College London</div>
              <div style="font-family:{{ ffDisp }};font-weight:700;font-size:28px;line-height:{{ lhTight }};color:#fff;margin-bottom:6px"><span style="direction:ltr;unicode-bidi:isolate;display:inline-block">MSc Endodontology</span></div>
              <div style="font-size:12.5px;font-weight:400;line-height:{{ lhSnug }};color:rgba(255,255,255,.6);margin-bottom:16px">{{ t.faculty }}</div>
              <div style="display:flex;flex-wrap:wrap;gap:7px;margin-bottom:20px">
                <span style="font-size:10.5px;font-weight:700;color:#1B1B1B;background:#FFC62E;padding:5px 9px;border-radius:999px;line-height:1.4">{{ t.badgeScholarships }}</span>
                <span style="font-size:10.5px;font-weight:600;color:rgba(255,255,255,.75);background:rgba(255,255,255,.08);padding:5px 9px;border-radius:999px;line-height:1.4">{{ t.badgeMicroscope }}</span>
              </div>
              <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:18px">
                <div style="background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.1);border-radius:14px;padding:13px">
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:20px;line-height:1.3;color:#fff;direction:ltr;unicode-bidi:isolate;text-align:start">£26,000</div>
                  <div style="font-size:10.5px;font-weight:500;color:rgba(255,255,255,.5);margin-top:5px;line-height:1.5">{{ t.statTuition }}</div>
                </div>
                <div style="background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.1);border-radius:14px;padding:13px">
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:20px;line-height:1.3;color:#fff">{{ t.statOneYear }}</div>
                  <div style="font-size:10.5px;font-weight:500;color:rgba(255,255,255,.5);margin-top:5px;line-height:1.5">{{ t.statMode }}</div>
                </div>
                <div style="background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.1);border-radius:14px;padding:13px">
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:20px;line-height:1.3;color:#fff;direction:ltr;unicode-bidi:isolate;text-align:start">~15%</div>
                  <div style="font-size:10.5px;font-weight:500;color:rgba(255,255,255,.5);margin-top:5px;line-height:1.5">{{ t.statAcceptance }}</div>
                </div>
                <div style="background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.1);border-radius:14px;padding:13px">
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:20px;line-height:1.3;color:#fff;direction:ltr;unicode-bidi:isolate;text-align:start">8–12</div>
                  <div style="font-size:10.5px;font-weight:500;color:rgba(255,255,255,.5);margin-top:5px;line-height:1.5">{{ t.statCohort }}</div>
                </div>
              </div>
              <div style="font-size:11.5px;font-weight:500;color:rgba(255,255,255,.55);line-height:{{ lhBody }}">{{ t.keyLine }}</div>
            </div>
          </div>

          <div style="position:sticky;top:0;z-index:5;background:#FFF9EF;border-bottom:1px solid #E7E2DA;padding:12px 0 10px">
            <div style="display:flex;gap:8px;overflow-x:auto;padding:0 20px;scrollbar-width:thin">
              <sc-for list="{{ navItems }}" as="s" hint-placeholder-count="9">
                <button onClick="{{ s.go }}" style="flex:none;border-radius:999px;padding:9px 13px;cursor:pointer;background:{{ s.bg }};color:{{ s.fg }};border:1.5px solid {{ s.border }};font-size:12.5px;font-weight:600;white-space:nowrap;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ s.label }}</button>
              </sc-for>
            </div>
          </div>

          <sc-if value="{{ isOverview }}" hint-placeholder-val="{{ true }}">
            <div style="padding:22px 20px 30px">
              <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:12px;line-height:1.4">{{ t.aboutLabel }}</div>
              <p style="font-size:14px;font-weight:400;line-height:{{ lhBody }};color:#1B1B1B;margin:0 0 12px">{{ t.about1 }}</p>
              <p style="font-size:14px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin:0 0 26px">{{ t.about2 }}</p>

              <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:12px;line-height:1.4">{{ t.whyLabel }}</div>
              <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:6px 16px;margin-bottom:26px">
                <sc-for list="{{ differentiators }}" as="d" hint-placeholder-count="7">
                  <div style="padding:13px 0;border-bottom:1px solid #E7E2DA;font-size:13px;font-weight:400;line-height:{{ lhBody }};color:#1B1B1B">{{ d.text }}</div>
                </sc-for>
              </div>

            </div>
          </sc-if>

          <sc-if value="{{ isCurriculum }}" hint-placeholder-val="{{ false }}">
            <div style="padding:22px 20px 30px">
              <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:8px;line-height:1.4">{{ t.modulesLabel }}</div>
              <p style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin:0 0 16px">{{ t.modulesIntro }}</p>
              <div style="display:grid;gap:10px;margin-bottom:26px">
                <sc-for list="{{ modules }}" as="m" hint-placeholder-count="8">
                  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:15px">
                    <div style="display:flex;align-items:center;gap:8px;margin-bottom:8px;flex-wrap:wrap">
                      <span style="font-size:10.5px;font-weight:600;color:#716D67;background:#F5F2EC;padding:4px 8px;border-radius:999px;line-height:1.4">{{ m.weeks }}</span>
                      <span style="font-size:10.5px;font-weight:700;color:#496FA8;background:rgba(73,111,168,.1);padding:4px 8px;border-radius:999px;line-height:1.4">{{ m.credits }}</span>
                    </div>
                    <div style="font-size:13.5px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B;margin-bottom:5px">{{ m.title }}</div>
                    <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67">{{ m.desc }}</div>
                  </div>
                </sc-for>
              </div>
              <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:8px;line-height:1.4">{{ t.assessLabel }}</div>
              <p style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin:0 0 16px">{{ t.assessIntro }}</p>
              <div style="display:grid;gap:10px">
                <sc-for list="{{ assessments }}" as="a" hint-placeholder-count="5">
                  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:15px">
                    <div style="display:flex;align-items:baseline;justify-content:space-between;gap:12px;margin-bottom:6px">
                      <div style="font-size:13.5px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ a.title }}</div>
                      <div style="flex:none;font-family:{{ ffDisp }};font-weight:700;font-size:17px;color:#FF6B1A;direction:ltr;unicode-bidi:isolate">{{ a.weight }}</div>
                    </div>
                    <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67">{{ a.desc }}</div>
                  </div>
                </sc-for>
              </div>
            </div>
          </sc-if>

          <sc-if value="{{ isRequirements }}" hint-placeholder-val="{{ false }}">
            <div style="padding:22px 20px 30px">
              <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:16px;line-height:1.4">{{ t.reqLabel }}</div>
              <div style="display:grid;gap:10px;margin-bottom:20px">
                <sc-for list="{{ requirements }}" as="r" hint-placeholder-count="8">
                  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:15px">
                    <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:10px;margin-bottom:6px">
                      <div style="font-size:13.5px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ r.title }}</div>
                      <span style="flex:none;font-size:10px;font-weight:700;color:{{ r.tagFg }};background:{{ r.tagBg }};padding:4px 8px;border-radius:999px;line-height:1.4">{{ r.tag }}</span>
                    </div>
                    <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67">{{ r.desc }}</div>
                  </div>
                </sc-for>
              </div>
              <div style="background:rgba(255,45,50,.08);border:1.5px solid rgba(255,45,50,.28);border-radius:16px;padding:15px">
                <div style="font-size:13px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B;margin-bottom:5px">{{ t.verifyTitle }}</div>
                <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67">{{ t.verifyBody }} <span style="direction:ltr;unicode-bidi:isolate">dentaladmissions@kcl.ac.uk · +44 20 7848 3040</span></div>
              </div>
            </div>
          </sc-if>

          <sc-if value="{{ isApplication }}" hint-placeholder-val="{{ false }}">
            <div style="padding:22px 20px 30px">
              <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:8px;line-height:1.4">{{ t.statementLabel }}</div>
              <p style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin:0 0 14px">{{ t.statementIntro }}</p>
              <div style="display:grid;gap:8px;margin-bottom:26px">
                <sc-for list="{{ statementPoints }}" as="p" hint-placeholder-count="5">
                  <div style="display:flex;gap:12px;background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:14px">
                    <div style="flex:none;width:24px;height:24px;border-radius:8px;background:#F5F2EC;color:#1B1B1B;font-size:12px;font-weight:700;display:flex;align-items:center;justify-content:center">{{ p.n }}</div>
                    <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#1B1B1B">{{ p.text }}</div>
                  </div>
                </sc-for>
              </div>

              <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:8px;line-height:1.4">{{ t.portfolioLabel }}</div>
              <p style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin:0 0 14px">{{ t.portfolioIntro }}</p>
              <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:6px 16px;margin-bottom:26px">
                <sc-for list="{{ portfolioPoints }}" as="p" hint-placeholder-count="5">
                  <div style="padding:13px 0;border-bottom:1px solid #E7E2DA;font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#1B1B1B">{{ p.text }}</div>
                </sc-for>
              </div>

              <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:8px;line-height:1.4">{{ t.interviewLabel }}</div>
              <p style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin:0 0 14px">{{ t.interviewIntro }}</p>
              <div style="display:grid;gap:10px;margin-bottom:26px">
                <sc-for list="{{ interviewQs }}" as="q" hint-placeholder-count="6">
                  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:15px">
                    <div style="font-size:13px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B;margin-bottom:7px">{{ q.q }}</div>
                    <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67">{{ q.a }}</div>
                  </div>
                </sc-for>
              </div>

              <div style="background:#1B1B1B;border-radius:20px;padding:20px">
                <div style="font-size:10.5px;font-weight:600;color:#FFC62E;margin-bottom:14px;line-height:1.4">{{ t.rejectLabel }}</div>
                <div style="display:grid;gap:11px">
                  <sc-for list="{{ rejections }}" as="r" hint-placeholder-count="6">
                    <div style="display:flex;gap:10px;font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.78)">
                      <span style="flex:none;color:#FF8A8A;font-weight:700">{{ r.n }}</span>{{ r.text }}
                    </div>
                  </sc-for>
                </div>
              </div>
            </div>
          </sc-if>

          <sc-if value="{{ isScholarships }}" hint-placeholder-val="{{ false }}">
            <div style="padding:22px 20px 30px">
              <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:8px;line-height:1.4">{{ t.fundingLabel }}</div>
              <p style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin:0 0 16px">{{ t.fundingIntro }}</p>
              <div style="display:grid;gap:12px">
                <sc-for list="{{ scholarships }}" as="s" hint-placeholder-count="5">
                  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:16px">
                    <div style="display:flex;flex-wrap:wrap;gap:7px;margin-bottom:10px">
                      <span style="font-size:10px;font-weight:700;color:#716D67;background:#F5F2EC;padding:4px 8px;border-radius:999px;line-height:1.4">{{ s.kind }}</span>
                      <span style="font-size:10px;font-weight:700;color:{{ s.tagFg }};background:{{ s.tagBg }};padding:4px 8px;border-radius:999px;line-height:1.4">{{ s.tag }}</span>
                    </div>
                    <div style="font-size:13.5px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B;margin-bottom:6px">{{ s.name }}</div>
                    <div style="font-family:{{ ffDisp }};font-weight:700;font-size:20px;line-height:{{ lhSnug }};color:#1B1B1B;margin-bottom:12px">{{ s.amount }}</div>
                    <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:12px">{{ s.eligibility }}</div>
                    <div style="background:#F5F2EC;border-radius:12px;padding:12px;margin-bottom:10px">
                      <div style="font-size:10px;font-weight:700;color:#FF6B1A;margin-bottom:5px;line-height:1.4">{{ t.tipLabel }}</div>
                      <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#1B1B1B">{{ s.tip }}</div>
                    </div>
                    <div style="font-size:11.5px;font-weight:600;line-height:{{ lhBody }};color:#716D67">{{ s.deadline }}</div>
                  </div>
                </sc-for>
              </div>
            </div>
          </sc-if>

          <sc-if value="{{ isAfter }}" hint-placeholder-val="{{ false }}">
            <div style="padding:22px 20px 30px">
              <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:8px;line-height:1.4">{{ t.salaryLabel }}</div>
              <p style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin:0 0 16px">{{ t.salaryIntro }}</p>
              <div style="display:grid;gap:12px;margin-bottom:26px">
                <sc-for list="{{ salaries }}" as="s" hint-placeholder-count="3">
                  <div style="background:#1B1B1B;border-radius:20px;padding:18px">
                    <div style="font-size:10.5px;font-weight:600;color:#FFC62E;margin-bottom:10px;line-height:1.4">{{ s.place }}</div>
                    <div style="font-family:{{ ffDisp }};font-weight:700;font-size:20px;line-height:{{ lhSnug }};color:#fff;margin-bottom:10px;direction:ltr;unicode-bidi:isolate;text-align:start">{{ s.range }}</div>
                    <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.7);margin-bottom:12px">{{ s.detail }}</div>
                    <div style="display:flex;flex-wrap:wrap;gap:7px">
                      <span style="font-size:10.5px;font-weight:600;color:rgba(255,255,255,.75);background:rgba(255,255,255,.08);padding:5px 9px;border-radius:999px;line-height:1.5">{{ s.timeline }}</span>
                      <span style="font-size:10.5px;font-weight:600;color:rgba(255,255,255,.75);background:rgba(255,255,255,.08);padding:5px 9px;border-radius:999px;line-height:1.5">{{ s.tax }}</span>
                    </div>
                  </div>
                </sc-for>
              </div>

              <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:8px;line-height:1.4">{{ t.gdcLabel }}</div>
              <p style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin:0 0 14px">{{ t.gdcIntro }}</p>
              <div style="display:grid;gap:10px;margin-bottom:14px">
                <sc-for list="{{ gdcRoutes }}" as="r" hint-placeholder-count="2">
                  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:15px">
                    <div style="font-size:13.5px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B;margin-bottom:6px">{{ r.title }}</div>
                    <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:10px">{{ r.desc }}</div>
                    <div style="display:flex;flex-wrap:wrap;gap:7px">
                      <span style="font-size:10.5px;font-weight:600;color:#716D67;background:#F5F2EC;padding:5px 9px;border-radius:999px;line-height:1.5">{{ r.a }}</span>
                      <span style="font-size:10.5px;font-weight:700;color:#FF2D32;background:rgba(255,45,50,.08);padding:5px 9px;border-radius:999px;line-height:1.5">{{ r.b }}</span>
                    </div>
                  </div>
                </sc-for>
              </div>
              <div style="background:rgba(45,155,104,.1);border:1.5px solid rgba(45,155,104,.3);border-radius:16px;padding:15px;margin-bottom:26px">
                <div style="font-size:12.5px;font-weight:500;line-height:{{ lhBody }};color:#1B1B1B">{{ t.gulfNote }}</div>
              </div>

              <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:14px;line-height:1.4">{{ t.syndicateLabel }}</div>
              <div style="display:grid;gap:10px;margin-bottom:26px">
                <sc-for list="{{ syndicate }}" as="s" hint-placeholder-count="6">
                  <div style="display:flex;gap:12px;background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:15px">
                    <div style="flex:none;width:26px;height:26px;border-radius:8px;background:{{ grad }};color:#fff;font-size:12px;font-weight:800;display:flex;align-items:center;justify-content:center">{{ s.n }}</div>
                    <div style="min-width:0">
                      <div style="font-size:13px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B;margin-bottom:5px">{{ s.title }}</div>
                      <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67">{{ s.desc }}</div>
                    </div>
                  </div>
                </sc-for>
              </div>

              <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:14px;line-height:1.4">{{ t.pathsLabel }}</div>
              <div style="display:grid;gap:10px">
                <sc-for list="{{ paths }}" as="p" hint-placeholder-count="5">
                  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:15px">
                    <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:10px;margin-bottom:6px">
                      <div style="font-size:13.5px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ p.title }}</div>
                      <span style="flex:none;font-size:10px;font-weight:700;color:#716D67;background:#F5F2EC;padding:4px 8px;border-radius:999px;line-height:1.4">{{ p.when }}</span>
                    </div>
                    <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67">{{ p.desc }}</div>
                  </div>
                </sc-for>
              </div>
            </div>
          </sc-if>

          <sc-if value="{{ never }}" hint-placeholder-val="{{ false }}">
            <div style="padding:22px 20px 30px">
              <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:16px;line-height:1.4">{{ t.recognitionLabel }}</div>
              <div style="display:grid;gap:12px;margin-bottom:16px">
                <sc-for list="{{ recognition }}" as="r" hint-placeholder-count="4">
                  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:16px">
                    <div style="display:flex;align-items:center;gap:10px;margin-bottom:10px">
                      <span style="flex:none;font-size:26px;line-height:1">{{ r.flag }}</span>
                      <div style="font-size:14px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ r.country }}</div>
                      <span style="margin-inline-start:auto;font-size:10px;font-weight:700;color:#2D9B68;background:rgba(45,155,104,.1);padding:4px 8px;border-radius:999px;line-height:1.4">{{ t.recognised }}</span>
                    </div>
                    <div style="font-size:11.5px;font-weight:600;line-height:{{ lhSnug }};color:#496FA8;margin-bottom:8px">{{ r.body }}</div>
                    <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67">{{ r.detail }}</div>
                  </div>
                </sc-for>
              </div>
              <div style="background:rgba(255,45,50,.08);border:1.5px solid rgba(255,45,50,.28);border-radius:16px;padding:15px">
                <div style="font-size:12.5px;font-weight:500;line-height:{{ lhBody }};color:#1B1B1B">{{ t.recognitionWarning }}</div>
              </div>
            </div>
          </sc-if>

          <sc-if value="{{ isLiving }}" hint-placeholder-val="{{ false }}">
            <div style="padding:22px 20px 30px">
              <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:8px;line-height:1.4">{{ t.costsLabel }}</div>
              <p style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin:0 0 14px">{{ t.costsIntro }}</p>
              <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:6px 16px;margin-bottom:26px">
                <sc-for list="{{ costs }}" as="c" hint-placeholder-count="7">
                  <div style="display:flex;justify-content:space-between;gap:16px;padding:12px 0;border-bottom:1px solid #E7E2DA">
                    <span style="font-size:12.5px;font-weight:400;line-height:{{ lhSnug }};color:#716D67">{{ c.label }}</span>
                    <span style="flex:none;font-size:13px;font-weight:600;color:#1B1B1B;display:flex;gap:3px;align-items:baseline"><span style="direction:ltr;unicode-bidi:isolate">{{ c.value }}</span><span style="font-weight:500;color:#716D67;font-size:11.5px">{{ unitMonth }}</span></span>
                  </div>
                </sc-for>
                <div style="display:flex;justify-content:space-between;gap:16px;padding:14px 0">
                  <span style="font-size:13px;font-weight:700;color:#1B1B1B">{{ t.totalEstimate }}</span>
                  <span style="flex:none;font-family:{{ ffDisp }};font-weight:700;font-size:18px;color:#FF6B1A;display:flex;gap:4px;align-items:baseline"><span style="direction:ltr;unicode-bidi:isolate">{{ totalValue }}</span><span style="font-family:{{ ff }};font-size:12px;font-weight:600">{{ unitMonth }}</span></span>
                </div>
              </div>

              <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:8px;line-height:1.4">{{ t.areasLabel }}</div>
              <p style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin:0 0 14px">{{ t.areasIntro }}</p>
              <div style="display:grid;gap:10px;margin-bottom:26px">
                <sc-for list="{{ areas }}" as="a" hint-placeholder-count="5">
                  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:15px">
                    <div style="display:flex;align-items:baseline;justify-content:space-between;gap:10px;margin-bottom:4px">
                      <div style="font-size:13.5px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B;direction:ltr;unicode-bidi:isolate;text-align:start">{{ a.name }}</div>
                      <div style="flex:none;font-size:12.5px;font-weight:700;color:#1B1B1B;display:flex;gap:3px;align-items:baseline"><span style="direction:ltr;unicode-bidi:isolate">{{ a.rent }}</span><span style="font-weight:500;color:#716D67;font-size:11px">{{ unitMonth }}</span></div>
                    </div>
                    <div style="font-size:11.5px;font-weight:600;line-height:{{ lhSnug }};color:#496FA8;margin-bottom:6px">{{ a.commute }}</div>
                    <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67">{{ a.note }}</div>
                  </div>
                </sc-for>
              </div>

              <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:14px;line-height:1.4">{{ t.setupLabel }}</div>
              <div style="display:grid;gap:10px;margin-bottom:26px">
                <sc-for list="{{ setup }}" as="s" hint-placeholder-count="6">
                  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:15px">
                    <div style="font-size:13px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B;margin-bottom:5px">{{ s.title }}</div>
                    <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67">{{ s.desc }}</div>
                  </div>
                </sc-for>
              </div>

              <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:14px;line-height:1.4">{{ t.visaLabel }}</div>
              <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:6px 16px">
                <sc-for list="{{ visa }}" as="v" hint-placeholder-count="7">
                  <div style="padding:12px 0;border-bottom:1px solid #E7E2DA">
                    <div style="font-size:11.5px;font-weight:600;color:#716D67;margin-bottom:4px;line-height:1.5">{{ v.label }}</div>
                    <div style="font-size:12.5px;font-weight:500;line-height:{{ lhBody }};color:#1B1B1B">{{ v.value }}</div>
                  </div>
                </sc-for>
                <div style="padding:14px 0;font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67">{{ t.casNote }}</div>
              </div>
            </div>
          </sc-if>

          <sc-if value="{{ isFaq }}" hint-placeholder-val="{{ false }}">
            <div style="padding:22px 20px 30px">
              <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:16px;line-height:1.4">{{ t.faqLabel }}</div>
              <div style="display:grid;gap:10px;margin-bottom:20px">
                <sc-for list="{{ faqs }}" as="f" hint-placeholder-count="8">
                  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:15px">
                    <div style="font-size:13px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B;margin-bottom:7px">{{ f.q }}</div>
                    <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67">{{ f.a }}</div>
                  </div>
                </sc-for>
              </div>
              <div style="background:#1B1B1B;border-radius:20px;padding:20px">
                <div style="font-size:10.5px;font-weight:600;color:#FFC62E;margin-bottom:10px;line-height:1.4">{{ t.notCoveredLabel }}</div>
                <div style="font-size:13px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.72);margin-bottom:16px">{{ t.notCoveredBody }}</div>
                <button style="width:100%;height:48px;border:none;border-radius:14px;background:#fff;color:#1B1B1B;font-size:13.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.bookConsult }}</button>
              </div>
            </div>
          </sc-if>

          <div style="padding:0 20px 26px">
            <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:16px">
              <div style="font-size:10.5px;font-weight:700;color:#716D67;margin-bottom:8px;line-height:1.4">{{ t.admissionsLabel }}</div>
              <div style="font-size:12.5px;font-weight:500;line-height:{{ lhBody }};color:#1B1B1B;direction:ltr;unicode-bidi:isolate;text-align:start">dentaladmissions@kcl.ac.uk<br>+44 20 7848 3040</div>
            </div>
          </div>
        </div>

        <div style="flex:none;background:#fff;border-top:1.5px solid #E7E2DA;padding:12px 16px 20px;display:flex;gap:10px;align-items:center">
          <div style="min-width:0;flex:1">
            <div style="font-family:{{ ffDisp }};font-weight:700;font-size:17px;line-height:1.3;color:#1B1B1B;display:flex;gap:4px;align-items:baseline"><span style="direction:ltr;unicode-bidi:isolate">£26,000</span><span style="font-family:{{ ff }};font-size:11px;font-weight:500;color:#716D67">{{ unitYear }}</span></div>
            <div style="font-size:10.5px;font-weight:600;color:#FF2D32;margin-top:4px;line-height:1.4">{{ t.deadlineLine }}</div>
          </div>
          <button style="flex:none;height:48px;padding:0 14px;border-radius:14px;border:1.5px solid #E7E2DA;background:#fff;color:#1B1B1B;font-size:12.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.getHelp }}</button>
          <button style="flex:none;height:48px;padding:0 18px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:13px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.applyShort }}</button>
        </div>

      </div>
    </div>
  </div>

  <div style="width:280px;flex:none;position:sticky;top:40px">
    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:18px;margin-bottom:16px">
      <div style="font:600 10.5px/1 Inter,sans-serif;letter-spacing:.12em;text-transform:uppercase;color:#716D67;margin-bottom:12px">Programme facts</div>
      <div style="font:400 12.5px/1.9 Inter,sans-serif;color:#1B1B1B">
        <div>QS ranking · #8 Dentistry</div>
        <div>Format · clinical + academic</div>
        <div>Duration · 1 yr FT / 2 yr PT</div>
        <div>Tuition · £26,000/year</div>
        <div>All-in (FT) · ~£78,000–£95,000</div>
        <div>Living · £1,530–£2,220/mo</div>
        <div>IELTS · 7.0 overall</div>
        <div>Cohort · 8–12 students</div>
        <div>Acceptance · ~15%</div>
        <div>Cases required · 150</div>
        <div>Interview · required</div>
        <div>Thesis + viva · required</div>
        <div>Intake · September 2026</div>
        <div>Deadline · 31 January 2026</div>
      </div>
    </div>
    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:18px">
      <div style="font:600 10.5px/1 Inter,sans-serif;letter-spacing:.12em;text-transform:uppercase;color:#716D67;margin-bottom:12px">Notes</div>
      <ul style="margin:0;padding-inline-start:18px;font:400 12.5px/1.8 Inter,sans-serif;color:#1B1B1B">
        <li>Real flags on the recognition cards, as you asked — overriding the no-emoji rule for flags only.</li>
        <li>Nine web sections become a sticky chip strip, not a desktop tab row.</li>
        <li>Apply and Get help pinned to a sticky bottom bar.</li>
        <li>Payment stays on the web: Get help opens consultation booking, never a card form.</li>
      </ul>
    </div>
  </div>

</div>
```

## Logic

_Template-only component — no logic class._
