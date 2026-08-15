# 01 App - Home and Career (main build)

The complete Phase 1 mobile app: 95 screens, six tabs (Home / Connect / Courses / Career / Postgrad / Profile), both languages, all states.

**Source file:** `export/src/app-home-career.dc.html`  
**Exported:** 2 August 2026  
**Size:** 888,658 characters · template 4,846 lines · logic 0 lines

> This is a Design Component — one self-contained HTML file that opens directly in a browser.
> The **template** is the markup between `<x-dc>` and `</x-dc>`. The **logic** is a `class Component extends DCLogic`
> whose `renderVals()` returns the values the template's `{{ }}` holes read (dotted lookups only, never expressions).
> To reassemble: document shell → `<x-dc>` + template + `</x-dc>` → `<script data-dc-script>` + logic + `</script>`.

## Template

```html
<helmet data-dc-atomics>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700;800&family=Inter:wght@400;500;600;700;800&family=Amiri:wght@400;700&family=IBM+Plex+Sans+Arabic:wght@400;500;600;700&display=swap" rel="stylesheet">
<script src="data/programmes.js"></script>
<script src="data/countries.js"></script>
<style>
  body{margin:0;background:#EDE9E1;-webkit-font-smoothing:antialiased}
  a{color:#FF6B1A;text-decoration:none}
  a:hover{color:#FF2D32}
  @keyframes shimmer{0%{background-position:-240px 0}100%{background-position:420px 0}}
  @keyframes sheetUp{from{transform:translateY(100%)}to{transform:translateY(0)}}
  @keyframes pulseDot{0%,100%{opacity:1}50%{opacity:.25}}
  @keyframes spin{to{transform:rotate(360deg)}}
</style>
</helmet>

<div style="display:flex;gap:40px;align-items:flex-start;padding:40px;min-height:100vh;box-sizing:border-box">

  <div style="width:300px;flex:none;position:sticky;top:40px">
    <div style="font:600 11px/1 Inter,sans-serif;letter-spacing:.12em;text-transform:uppercase;color:#FF6B1A;margin-bottom:10px">Phase 1 · flagship screens</div>
    <h1 style="font:700 26px/1.2 'Playfair Display',serif;color:#1B1B1B;margin:0 0 10px">Shell, Home feed, Connect &amp; Career</h1>
    <p style="font:400 13px/1.7 Inter,sans-serif;color:#716D67;margin:0 0 26px">Six tabs. The roadmap generator sits in Career with a CTA card on Home; Connect holds tutoring, mentoring and consulting. Switch language and state below — every state is designed in both languages.</p>

    <div style="font:600 10.5px/1 Inter,sans-serif;letter-spacing:.12em;text-transform:uppercase;color:#716D67;margin-bottom:10px">Language</div>
    <div style="display:flex;gap:8px;margin-bottom:24px">
      <button onClick="{{ setEn }}" style="flex:1;height:40px;border-radius:12px;cursor:pointer;border:1.5px solid {{ enBorder }};background:{{ enBg }};color:{{ enFg }};font:700 13px/1 Inter,sans-serif">EN</button>
      <button onClick="{{ setAr }}" style="flex:1;height:40px;border-radius:12px;cursor:pointer;border:1.5px solid {{ arBorder }};background:{{ arBg }};color:{{ arFg }};font:700 13px/1 'IBM Plex Sans Arabic',sans-serif;letter-spacing:0">عربي</button>
    </div>

    <div style="font:600 10.5px/1 Inter,sans-serif;letter-spacing:.12em;text-transform:uppercase;color:#716D67;margin-bottom:10px">Who is using it</div>
    <div style="display:grid;gap:8px;margin-bottom:24px">
      <sc-for list="{{ personaBtns }}" as="pb" hint-placeholder-count="4">
        <button onClick="{{ pb.pick }}" style="height:40px;border-radius:12px;cursor:pointer;text-align:start;padding:0 14px;border:1.5px solid {{ pb.b }};background:{{ pb.g }};color:{{ pb.f }};font:600 12.5px/1 Inter,sans-serif">{{ pb.label }}</button>
      </sc-for>
      <button onClick="{{ roleTutor }}" style="height:40px;border-radius:12px;cursor:pointer;text-align:start;padding:0 14px;border:1.5px solid {{ rTutorB }};background:{{ rTutorG }};color:{{ rTutorF }};font:600 12.5px/1 Inter,sans-serif">Tutor · supply side</button>
    </div>

    <div style="font:600 10.5px/1 Inter,sans-serif;letter-spacing:.12em;text-transform:uppercase;color:#716D67;margin-bottom:10px">First-run flow</div>
    <button onClick="{{ startAuth }}" style="width:100%;height:40px;border-radius:12px;cursor:pointer;border:1.5px solid #E7E2DA;background:#fff;color:#1B1B1B;font:600 12.5px/1 Inter,sans-serif;margin-bottom:24px">Language → welcome → register → profiling</button>

    <div style="font:600 10.5px/1 Inter,sans-serif;letter-spacing:.12em;text-transform:uppercase;color:#716D67;margin-bottom:10px">Phone scale</div>
    <div style="display:flex;gap:6px;margin-bottom:24px">
      <sc-for list="{{ scaleOpts }}" as="s" hint-placeholder-count="4">
        <button onClick="{{ s.pick }}" style="flex:1;min-height:36px;border-radius:10px;cursor:pointer;border:1.5px solid {{ s.bd }};background:{{ s.bg }};color:{{ s.fg }};font:700 11px/1 Inter,sans-serif">{{ s.label }}</button>
      </sc-for>
    </div>

    <div style="font:600 10.5px/1 Inter,sans-serif;letter-spacing:.12em;text-transform:uppercase;color:#716D67;margin-bottom:4px">Access</div>
    <div style="font:400 11px/1.6 Inter,sans-serif;color:#716D67;margin-bottom:20px">Every account is on Premium — all features, no locked screens, nothing sold inside the app — which also keeps it clear of App Store §3.1.1 entirely. The gating logic is kept but inert for after launch.</div>

    <div style="font:600 10.5px/1 Inter,sans-serif;letter-spacing:.12em;text-transform:uppercase;color:#716D67;margin-bottom:4px">Premium &amp; retention layer</div>
    <div style="font:400 11px/1.6 Inter,sans-serif;color:#716D67;margin-bottom:10px">Trackers, not browsers — the features that make people return weekly for months.</div>
    <div style="display:grid;gap:6px;margin-bottom:20px">
      <sc-for list="{{ pmPicker }}" as="s" hint-placeholder-count="9">
        <button onClick="{{ s.pick }}" style="min-height:36px;border-radius:10px;cursor:pointer;text-align:start;padding:8px 12px;border:1.5px solid {{ s.bd }};background:{{ s.bg }};color:{{ s.fg }};font:600 11.5px/1.4 Inter,sans-serif">{{ s.label }}</button>
      </sc-for>
    </div>

    <div style="font:600 10.5px/1 Inter,sans-serif;letter-spacing:.12em;text-transform:uppercase;color:#716D67;margin-bottom:10px">Avatar</div>
    <button onClick="{{ togglePhoto }}" style="width:100%;min-height:40px;border-radius:12px;cursor:pointer;border:1.5px solid #E7E2DA;background:#fff;color:#1B1B1B;font:600 12px/1.4 Inter,sans-serif;margin-bottom:24px;padding:8px 12px">{{ photoToggleL }}</button>

    <div style="font:600 10.5px/1 Inter,sans-serif;letter-spacing:.12em;text-transform:uppercase;color:#716D67;margin-bottom:4px">Batch 8 · system states</div>
    <div style="font:400 11px/1.6 Inter,sans-serif;color:#716D67;margin-bottom:10px">The ten screens the brief says get skipped. Every one is built.</div>
    <div style="display:grid;gap:6px;margin-bottom:20px">
      <sc-for list="{{ sysPicker }}" as="s" hint-placeholder-count="10">
        <button onClick="{{ s.pick }}" style="min-height:36px;border-radius:10px;cursor:pointer;text-align:start;padding:8px 12px;border:1.5px solid {{ s.bd }};background:{{ s.bg }};color:{{ s.fg }};font:600 11.5px/1.4 Inter,sans-serif">{{ s.label }}</button>
      </sc-for>
    </div>

    <div style="font:600 10.5px/1 Inter,sans-serif;letter-spacing:.12em;text-transform:uppercase;color:#716D67;margin-bottom:4px">Batches 2–9 · gaps now filled</div>
    <div style="font:400 11px/1.6 Inter,sans-serif;color:#716D67;margin-bottom:10px">Activation, growth and account screens that were missing.</div>
    <div style="display:grid;gap:6px;margin-bottom:12px">
      <sc-for list="{{ gapPicker }}" as="s" hint-placeholder-count="17">
        <button onClick="{{ s.pick }}" style="min-height:36px;border-radius:10px;cursor:pointer;text-align:start;padding:8px 12px;border:1.5px solid {{ s.bd }};background:{{ s.bg }};color:{{ s.fg }};font:600 11.5px/1.4 Inter,sans-serif">{{ s.label }}</button>
      </sc-for>
    </div>
    <sc-if value="{{ gapOn }}" hint-placeholder-val="{{ false }}">
      <button onClick="{{ gapClear }}" style="width:100%;height:40px;border-radius:12px;cursor:pointer;border:none;background:#1B1B1B;color:#fff;font:700 12px/1 Inter,sans-serif;margin-bottom:24px">{{ gapClearL }}</button>
    </sc-if>

    <div style="font:600 10.5px/1 Inter,sans-serif;letter-spacing:.12em;text-transform:uppercase;color:#716D67;margin-bottom:10px">Screen state</div>
    <div style="display:grid;gap:8px;margin-bottom:24px">
      <button onClick="{{ stDefault }}" style="height:40px;border-radius:12px;cursor:pointer;text-align:start;padding:0 14px;border:1.5px solid {{ b_default }};background:{{ g_default }};color:{{ f_default }};font:600 12.5px/1 Inter,sans-serif">Returning user</button>
      <button onClick="{{ stNew }}" style="height:40px;border-radius:12px;cursor:pointer;text-align:start;padding:0 14px;border:1.5px solid {{ b_new }};background:{{ g_new }};color:{{ f_new }};font:600 12.5px/1 Inter,sans-serif">Brand-new user · empty</button>
      <button onClick="{{ stLoading }}" style="height:40px;border-radius:12px;cursor:pointer;text-align:start;padding:0 14px;border:1.5px solid {{ b_loading }};background:{{ g_loading }};color:{{ f_loading }};font:600 12.5px/1 Inter,sans-serif">Loading · skeletons</button>
      <button onClick="{{ stError }}" style="height:40px;border-radius:12px;cursor:pointer;text-align:start;padding:0 14px;border:1.5px solid {{ b_error }};background:{{ g_error }};color:{{ f_error }};font:600 12.5px/1 Inter,sans-serif">Error</button>
      <button onClick="{{ stOffline }}" style="height:40px;border-radius:12px;cursor:pointer;text-align:start;padding:0 14px;border:1.5px solid {{ b_offline }};background:{{ g_offline }};color:{{ f_offline }};font:600 12.5px/1 Inter,sans-serif">Offline · cached</button>
      <button onClick="{{ stPartial }}" style="height:40px;border-radius:12px;cursor:pointer;text-align:start;padding:0 14px;border:1.5px solid {{ b_partial }};background:{{ g_partial }};color:{{ f_partial }};font:600 12.5px/1 Inter,sans-serif">Partial · one section failed</button>
    </div>

    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:16px">
      <div style="font:600 10.5px/1 Inter,sans-serif;letter-spacing:.12em;text-transform:uppercase;color:#716D67;margin-bottom:10px">Data provenance</div>
      <div style="font:400 12px/1.7 Inter,sans-serif;color:#1B1B1B">199 programme records loaded from your spreadsheet. Its own notes sheet flags that recognition status and source URLs were lost in extraction — so recognition renders as <strong>Not verified</strong> everywhere until each country is sourced. Nothing is guessed.</div>
    </div>
  </div>

  <div style="flex:none;position:sticky;top:12px;align-self:flex-start;width:{{ phoneBoxW }}px;height:{{ phoneBoxH }}px">
    <div style="transform:scale({{ phoneScale }});transform-origin:top left;width:390px;height:844px;border-radius:44px;background:#1B1B1B;padding:10px;box-shadow:0 30px 70px rgba(0,0,0,.3);box-sizing:border-box">
      <div dir="{{ dir }}" style="width:370px;height:824px;border-radius:35px;overflow:hidden;position:relative;background:#FFF9EF;display:flex;flex-direction:column;font-family:{{ ff }};letter-spacing:{{ ls }}">

        <div style="background:#1B1B1B;padding:12px 20px 0;flex:none">
          <div style="display:flex;justify-content:space-between;align-items:center;font-size:11px;font-weight:600;color:rgba(255,255,255,.55)">
            <span>9:41</span>
            <span style="display:flex;gap:5px;align-items:center"><span style="width:16px;height:8px;border:1px solid rgba(255,255,255,.5);border-radius:2px;display:inline-block"></span><span style="width:22px;height:8px;background:rgba(255,255,255,.5);border-radius:2px;display:inline-block"></span></span>
          </div>
        </div>

        <sc-if value="{{ showOfflineBanner }}" hint-placeholder-val="{{ false }}">
          <div style="background:#24201D;padding:10px 20px;display:flex;align-items:center;gap:10px;flex:none">
            <span style="width:7px;height:7px;border-radius:50%;background:#FFAA18;flex:none"></span>
            <span style="font-size:12px;font-weight:600;color:#FFC62E;line-height:{{ lhSnug }}">{{ t.offlineBanner }}</span>
          </div>
        </sc-if>

        <sc-if value="{{ authOn }}" hint-placeholder-val="{{ false }}">
          <div style="flex:1;overflow-y:auto;overflow-x:hidden;scrollbar-width:thin;background:#1B1B1B">
            <sc-if value="{{ aLang }}" hint-placeholder-val="{{ false }}">
              <div style="padding:60px 24px 30px;text-align:center">
                <div style="width:72px;height:72px;border-radius:20px;background:{{ grad }};margin:0 auto 40px"></div>
                <div style="font:700 12px/1.4 Inter,sans-serif;letter-spacing:{{ lsE }};color:rgba(255,255,255,.5);margin-bottom:28px">CHOOSE YOUR LANGUAGE · اختر لغتك</div>
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px">
                  <button onClick="{{ pickEn }}" style="aspect-ratio:1;border-radius:24px;border:1.5px solid rgba(255,255,255,.16);background:rgba(255,255,255,.05);cursor:pointer;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:10px">
                    <span style="font:800 32px/1 'Playfair Display',serif;color:#fff">EN</span>
                    <span style="font:600 13px/1.4 Inter,sans-serif;color:rgba(255,255,255,.6)">I prefer English</span>
                  </button>
                  <button onClick="{{ pickAr }}" style="aspect-ratio:1;border-radius:24px;border:1.5px solid rgba(255,255,255,.16);background:rgba(255,255,255,.05);cursor:pointer;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:10px">
                    <span style="font:700 34px/1 Amiri,serif;letter-spacing:0;color:#fff">ع</span>
                    <span style="font:600 13px/1.6 'IBM Plex Sans Arabic',sans-serif;letter-spacing:0;color:rgba(255,255,255,.6)">أفضّل العربية</span>
                  </button>
                </div>
                <div style="font:400 11.5px/1.7 Inter,sans-serif;color:rgba(255,255,255,.35);margin-top:26px">You can switch at any time in Profile · يمكنك التغيير لاحقًا من ملفك</div>
              </div>
            </sc-if>

            <sc-if value="{{ aWelcome }}" hint-placeholder-val="{{ false }}">
              <div style="min-height:100%;display:flex;flex-direction:column;padding:14px 24px 30px;box-sizing:border-box">
                <div style="display:flex;justify-content:flex-end">
                  <button onClick="{{ skipSlides }}" style="background:none;border:none;cursor:pointer;font-size:13px;font-weight:700;color:rgba(255,255,255,.6);font-family:{{ ff }};letter-spacing:{{ ls }};padding:10px 4px">{{ t.skip }}</button>
                </div>
                <div style="flex:1;display:flex;flex-direction:column;justify-content:center;gap:26px;padding:20px 0">
                  <div role="img" aria-label="Ejadah" style="height:180px;border-radius:24px;background:linear-gradient(160deg,rgba(255,45,50,.35),rgba(27,27,27,.55)), #1B1B1B center/cover no-repeat url(https://picsum.photos/seed/ejadah-welcome-2/720/420);border:1px solid rgba(255,255,255,.12)"></div>
                  <div>
                    <div style="font-family:{{ ffDisp }};font-weight:700;font-size:27px;line-height:{{ lhTight }};color:#fff;margin-bottom:12px">{{ slideOne.h }}</div>
                    <div style="font-size:14.5px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.65)">{{ slideOne.b }}</div>
                  </div>
                </div>
                <div style="display:flex;gap:6px;justify-content:center;margin-bottom:22px">
                  <sc-for list="{{ slides }}" as="s" hint-placeholder-count="3">
                    <span style="height:7px;border-radius:4px;background:{{ s.dotBg }};width:{{ s.dotW }}"></span>
                  </sc-for>
                </div>
                <button onClick="{{ nextSlide }}" style="width:100%;height:56px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 8px 28px rgba(255,107,26,.35);color:#fff;font-size:15px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.continue }}</button>
                <button onClick="{{ goLogin }}" style="width:100%;height:48px;margin-top:8px;border:none;background:transparent;color:rgba(255,255,255,.6);font-size:13.5px;font-weight:600;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.haveAccount }}</button>
              </div>
            </sc-if>

            <sc-if value="{{ aLogin }}" hint-placeholder-val="{{ false }}">
              <div>
                <div style="padding:44px 24px 34px;text-align:center">
                  <div style="width:56px;height:56px;border-radius:16px;background:{{ grad }};margin:0 auto 18px"></div>
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:25px;line-height:{{ lhTight }};color:#fff">{{ t.welcomeBack }}</div>
                </div>
                <div style="background:#FFF9EF;border-radius:24px 24px 0 0;padding:26px 20px 30px;min-height:420px">
                  <label style="display:block;font-size:12px;font-weight:600;color:#1B1B1B;margin-bottom:8px">{{ t.email }}</label>
                  <div style="height:48px;border:1.5px solid #E7E2DA;border-radius:12px;background:#fff;display:flex;align-items:center;padding:0 14px;font-size:14px;color:#716D67;margin-bottom:16px;direction:ltr;unicode-bidi:isolate">you@example.com</div>
                  <label style="display:block;font-size:12px;font-weight:600;color:#1B1B1B;margin-bottom:8px">{{ t.password }}</label>
                  <div style="height:48px;border:1.5px solid #E7E2DA;border-radius:12px;background:#fff;display:flex;align-items:center;justify-content:space-between;padding:0 14px;font-size:14px;color:#1B1B1B;margin-bottom:10px">••••••••<span style="color:#716D67"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2.5 12S6 6.5 12 6.5 21.5 12 21.5 12 18 17.5 12 17.5 2.5 12 2.5 12z"></path><circle cx="12" cy="12" r="3"></circle></svg></span></div>
                  <div style="text-align:end;margin-bottom:20px"><button onClick="{{ goForgot }}" style="background:none;border:none;min-height:44px;cursor:pointer;font-size:12.5px;font-weight:600;color:#FF6B1A;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.forgotPassword }}</button></div>
                  <button onClick="{{ exitAuth }}" style="width:100%;height:54px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.signIn }}</button>
                  <div style="display:flex;align-items:center;gap:12px;margin:22px 0">
                    <span style="flex:1;height:1px;background:#E7E2DA"></span>
                    <span style="font-size:11px;font-weight:600;color:#716D67">{{ t.noAccount }}</span>
                    <span style="flex:1;height:1px;background:#E7E2DA"></span>
                  </div>
                  <button onClick="{{ goRegister }}" style="width:100%;height:52px;border:1.5px solid #E7E2DA;border-radius:14px;background:#fff;color:#1B1B1B;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.signUp }}</button>
                </div>
              </div>
            </sc-if>

            <sc-if value="{{ aRegister }}" hint-placeholder-val="{{ false }}">
              <div>
                <div style="padding:30px 24px 26px">
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:25px;line-height:{{ lhTight }};color:#fff">{{ t.signUp }}</div>
                  <div style="font-size:13px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.6);margin-top:8px">{{ t.registerSub }}</div>
                </div>
                <div style="background:#FFF9EF;border-radius:24px 24px 0 0;padding:26px 20px 30px">
                  <label style="display:block;font-size:12px;font-weight:600;color:#1B1B1B;margin-bottom:8px">{{ t.fullName }}</label>
                  <div style="height:48px;border:1.5px solid #E7E2DA;border-radius:12px;background:#fff;display:flex;align-items:center;padding:0 14px;font-size:14px;color:#716D67;margin-bottom:16px">{{ t.namePlaceholder }}</div>
                  <label style="display:block;font-size:12px;font-weight:600;color:#1B1B1B;margin-bottom:8px">{{ t.email }}</label>
                  <div style="height:48px;border:1.5px solid #E7E2DA;border-radius:12px;background:#fff;display:flex;align-items:center;padding:0 14px;font-size:14px;color:#716D67;margin-bottom:16px;direction:ltr;unicode-bidi:isolate">you@example.com</div>
                  <label style="display:block;font-size:12px;font-weight:600;color:#1B1B1B;margin-bottom:8px">{{ t.password }}</label>
                  <div style="height:48px;border:1.5px solid #E7E2DA;border-radius:12px;background:#fff;display:flex;align-items:center;padding:0 14px;font-size:14px;color:#1B1B1B;margin-bottom:6px">••••••••</div>
                  <div style="font-size:11px;font-weight:500;color:#716D67;margin-bottom:18px">{{ t.pwRule }}</div>
                  <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:10px;line-height:1.4">{{ t.yourStage }}</div>
                  <div style="display:flex;flex-wrap:wrap;gap:8px;margin-bottom:22px">
                    <sc-for list="{{ stageChips }}" as="c" hint-placeholder-count="5">
                      <button onClick="{{ c.pick }}" style="border-radius:999px;min-height:44px;padding:10px 13px;cursor:pointer;background:{{ c.bg }};color:{{ c.fg }};border:1.5px solid {{ c.bd }};font-size:12.5px;font-weight:600;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ c.label }}</button>
                    </sc-for>
                  </div>
                  <button onClick="{{ goOnboard }}" style="width:100%;height:54px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.createAccount }}</button>
                  <button onClick="{{ goLogin }}" style="width:100%;height:46px;margin-top:8px;border:none;background:transparent;color:#716D67;font-size:13px;font-weight:600;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.haveAccount }}</button>
                </div>
              </div>
            </sc-if>

            <sc-if value="{{ aOnboard }}" hint-placeholder-val="{{ false }}">
              <div style="background:#FFF9EF;min-height:100%;padding:16px 20px 30px;box-sizing:border-box">
                <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:14px">
                  <span style="font-size:12px;font-weight:700;color:#716D67">{{ pStepLabel }}</span>
                  <button onClick="{{ pSkip }}" style="background:none;border:none;cursor:pointer;font-size:12.5px;font-weight:700;color:#716D67;font-family:{{ ff }};letter-spacing:{{ ls }};padding:8px 4px">{{ t.skip }}</button>
                </div>
                <div style="height:5px;border-radius:3px;background:#E7E2DA;overflow:hidden;margin-bottom:24px"><div style="height:100%;border-radius:3px;background:{{ grad }};width:{{ pProgress }}%"></div></div>

                <sc-if value="{{ pStep1 }}" hint-placeholder-val="{{ true }}">
                  <div>
                    <div style="font-family:{{ ffDisp }};font-weight:700;font-size:23px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:18px">{{ t.pGoal }}</div>
                    <div style="display:grid;gap:10px">
                      <sc-for list="{{ goalCards }}" as="g" hint-placeholder-count="4">
                        <button onClick="{{ g.pick }}" style="text-align:start;background:{{ g.bg }};border:1.5px solid {{ g.bd }};border-radius:18px;padding:18px;cursor:pointer;font-size:14.5px;font-weight:600;color:#1B1B1B;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ g.label }}</button>
                      </sc-for>
                    </div>
                  </div>
                </sc-if>
                <sc-if value="{{ pStep2 }}" hint-placeholder-val="{{ false }}">
                  <div>
                    <div style="font-family:{{ ffDisp }};font-weight:700;font-size:23px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:18px">{{ t.pSpec }}</div>
                    <div style="display:flex;flex-wrap:wrap;gap:8px">
                      <sc-for list="{{ specChips }}" as="c" hint-placeholder-count="6">
                        <button onClick="{{ c.pick }}" style="border-radius:999px;min-height:44px;padding:11px 14px;cursor:pointer;background:{{ c.bg }};color:{{ c.fg }};border:1.5px solid {{ c.bd }};font-size:12.5px;font-weight:600;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ c.label }}</button>
                      </sc-for>
                    </div>
                  </div>
                </sc-if>
                <sc-if value="{{ pStep3 }}" hint-placeholder-val="{{ false }}">
                  <div>
                    <div style="font-family:{{ ffDisp }};font-weight:700;font-size:23px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:8px">{{ t.pRegion }}</div>
                    <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:18px">{{ t.pRegionSub }}</div>
                    <div style="display:flex;flex-wrap:wrap;gap:8px">
                      <sc-for list="{{ regionChips }}" as="c" hint-placeholder-count="5">
                        <button onClick="{{ c.pick }}" style="border-radius:999px;min-height:44px;padding:11px 14px;cursor:pointer;background:{{ c.bg }};color:{{ c.fg }};border:1.5px solid {{ c.bd }};font-size:12.5px;font-weight:600;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ c.label }}</button>
                      </sc-for>
                    </div>
                  </div>
                </sc-if>
                <sc-if value="{{ pStep4 }}" hint-placeholder-val="{{ false }}">
                  <div>
                    <div style="font-family:{{ ffDisp }};font-weight:700;font-size:23px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:12px">{{ t.pNotify }}</div>
                    <div style="font-size:13.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:18px">{{ t.pNotifyWhy }}</div>
                    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:6px 16px">
                      <div style="padding:13px 0;border-bottom:1px solid #E7E2DA;font-size:13px;font-weight:500;color:#1B1B1B">{{ t.notifStudy }}</div>
                      <div style="padding:13px 0;border-bottom:1px solid #E7E2DA;font-size:13px;font-weight:500;color:#1B1B1B">{{ t.notifBooking }}</div>
                      <div style="padding:13px 0;font-size:13px;font-weight:500;color:#1B1B1B">{{ t.notifDeadline }}</div>
                    </div>
                  </div>
                </sc-if>
                <button onClick="{{ pNext }}" style="width:100%;height:54px;margin-top:24px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.continue }}</button>
              </div>
            </sc-if>
          </div>
        </sc-if>

        <div data-phone-scroll="1" style="flex:1;overflow-y:auto;overflow-x:hidden;scrollbar-width:thin;display:{{ appDisplay }}">

          <sc-if value="{{ isHome }}" hint-placeholder-val="{{ true }}">
            <div>
              <div style="background:#1B1B1B;padding:16px 20px 26px">
                <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:12px">
                  <div style="min-width:0">
                    <div style="font-size:11px;font-weight:600;color:#FFC62E;margin-bottom:8px;line-height:1">{{ t.greetingEyebrow }}</div>
                    <div style="font-family:{{ ffDisp }};font-weight:700;font-size:26px;line-height:{{ lhTight }};color:#fff">{{ t.userName }}</div>
                    <button onClick="{{ openGrantFromProfile }}" style="display:inline-flex;align-items:center;gap:7px;margin-top:12px;background:rgba(255,198,46,.16);border:1px solid rgba(255,198,46,.35);border-radius:999px;padding:6px 12px;min-height:32px;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">
                      <span style="width:6px;height:6px;border-radius:50%;background:#FFC62E"></span>
                      <span style="font-size:11px;font-weight:700;color:#FFC62E;line-height:1">{{ grantBadgeL }}</span>
                    </button>
                    <sc-if value="{{ hasStreak }}" hint-placeholder-val="{{ true }}">
                      <div style="display:inline-flex;align-items:center;gap:7px;margin-top:12px;background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.1);border-radius:999px;padding:6px 12px">
                        <span style="width:6px;height:6px;border-radius:50%;background:#FFC62E"></span>
                        <span style="font-size:11.5px;font-weight:600;color:rgba(255,255,255,.8);line-height:1">{{ t.streak }}</span>
                      </div>
                    </sc-if>
                  </div>
                  <div style="display:flex;gap:10px;align-items:center;flex:none">
                    <button onClick="{{ openNotifsTab }}" aria-label="{{ t.notifications }}" style="width:44px;height:44px;border-radius:999px;background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.12);color:rgba(255,255,255,.8);display:flex;align-items:center;justify-content:center;cursor:pointer;position:relative">
                      <svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 15V10a6 6 0 1 0-12 0v5l-1.5 2.5h15z"></path><path d="M10 20a2 2 0 0 0 4 0"></path></svg>
                      <sc-if value="{{ hasUnread }}" hint-placeholder-val="{{ true }}">
                        <span style="position:absolute;top:9px;inset-inline-end:10px;width:8px;height:8px;border-radius:50%;background:#FF2D32;border:1.5px solid #1B1B1B"></span>
                      </sc-if>
                    </button>
                    <button onClick="{{ openProfileTab }}" aria-label="{{ t.profile }}" style="width:44px;height:44px;border-radius:999px;background:{{ avatarBgSm }};border:1.5px solid rgba(255,255,255,.18);color:#fff;font-size:14px;font-weight:700;cursor:pointer;padding:0;display:flex;align-items:center;justify-content:center;overflow:hidden">
                      <sc-if value="{{ noAvatar }}" hint-placeholder-val="{{ false }}">
                        <span>{{ t.initials }}</span>
                      </sc-if>
                    </button>
                  </div>
                </div>
              </div>

              <sc-if value="{{ isLoading }}" hint-placeholder-val="{{ false }}">
                <div style="padding:22px 20px 30px">
                  <div style="height:13px;width:120px;border-radius:6px;background:linear-gradient(90deg,#F1ECE4,#E6E0D6,#F1ECE4);background-size:420px 100%;animation:shimmer 1.2s linear infinite;margin-bottom:16px"></div>
                  <div style="display:flex;gap:12px;margin-bottom:28px">
                    <div style="width:210px;height:112px;border-radius:20px;flex:none;background:linear-gradient(90deg,#F1ECE4,#E6E0D6,#F1ECE4);background-size:420px 100%;animation:shimmer 1.2s linear infinite"></div>
                    <div style="width:210px;height:112px;border-radius:20px;flex:none;background:linear-gradient(90deg,#F1ECE4,#E6E0D6,#F1ECE4);background-size:420px 100%;animation:shimmer 1.2s linear infinite"></div>
                  </div>
                  <div style="height:13px;width:150px;border-radius:6px;background:linear-gradient(90deg,#F1ECE4,#E6E0D6,#F1ECE4);background-size:420px 100%;animation:shimmer 1.2s linear infinite;margin-bottom:16px"></div>
                  <div style="height:150px;border-radius:20px;background:linear-gradient(90deg,#F1ECE4,#E6E0D6,#F1ECE4);background-size:420px 100%;animation:shimmer 1.2s linear infinite;margin-bottom:28px"></div>
                  <div style="height:13px;width:130px;border-radius:6px;background:linear-gradient(90deg,#F1ECE4,#E6E0D6,#F1ECE4);background-size:420px 100%;animation:shimmer 1.2s linear infinite;margin-bottom:16px"></div>
                  <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px">
                    <div style="height:96px;border-radius:20px;background:linear-gradient(90deg,#F1ECE4,#E6E0D6,#F1ECE4);background-size:420px 100%;animation:shimmer 1.2s linear infinite"></div>
                    <div style="height:96px;border-radius:20px;background:linear-gradient(90deg,#F1ECE4,#E6E0D6,#F1ECE4);background-size:420px 100%;animation:shimmer 1.2s linear infinite"></div>
                  </div>
                </div>
              </sc-if>

              <sc-if value="{{ isError }}" hint-placeholder-val="{{ false }}">
                <div style="padding:44px 24px">
                  <div style="text-align:center">
                    <span style="color:#FF2D32;display:inline-block;margin-bottom:16px"><svg width="34" height="34" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><path d="M12 4l9 16H3z"></path><path d="M12 10v5M12 18h.01"></path></svg></span>
                    <div style="font-size:19px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B;margin-bottom:8px">{{ t.errTitle }}</div>
                    <div style="font-size:13.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:22px">{{ t.errBody }}</div>
                    <button onClick="{{ stDefault }}" style="height:52px;padding:0 30px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.retry }}</button>
                  </div>
                </div>
              </sc-if>

              <sc-if value="{{ showFeed }}" hint-placeholder-val="{{ true }}">
                <div style="padding:24px 0 30px">

                  <div style="padding:0 20px;margin-bottom:30px">
                    <button onClick="{{ todayCard.go }}" style="width:100%;text-align:start;background:#1B1B1B;border:none;border-radius:20px;padding:20px;cursor:pointer;position:relative;overflow:hidden;font-family:{{ ff }};letter-spacing:{{ ls }};transition:transform .15s cubic-bezier(.4,0,.2,1)" style-active="transform:scale(.98)">
                      <span style="position:absolute;inset:0;background:radial-gradient(200px 110px at 88% 0%,rgba(255,198,46,.18),transparent 70%);pointer-events:none"></span>
                      <span style="position:relative;display:block">
                        <span style="display:block;font-size:10px;font-weight:800;color:#FFC62E;letter-spacing:{{ lsE }};margin-bottom:11px">{{ todayCard.eyebrow }}</span>
                        <span style="display:block;font-family:{{ ffDisp }};font-weight:700;font-size:22px;line-height:{{ lhTight }};color:#fff;margin-bottom:7px">{{ todayCard.title }}</span>
                        <span style="display:block;font-size:13px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.7);margin-bottom:16px">{{ todayCard.body }}</span>
                        <span style="display:inline-flex;align-items:center;gap:7px;background:#fff;color:#1B1B1B;border-radius:12px;padding:12px 18px;font-size:13px;font-weight:700">{{ todayCard.action }}<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M4 12h15"></path><path d="M13 6l6 6-6 6"></path></svg></span>
                      </span>
                    </button>
                  </div>


                  <sc-if value="{{ hasContinue }}" hint-placeholder-val="{{ true }}">
                    <div style="margin-bottom:30px">
                      <div style="display:flex;align-items:baseline;justify-content:space-between;padding:0 20px;margin-bottom:14px">
                        <div style="font-size:11px;font-weight:600;color:#FF6B1A;line-height:1">{{ t.continueLabel }}</div>
                        <button onClick="{{ seeAllCourses }}" disabled="{{ netDisabled }}" aria-disabled="{{ netAria }}" title="{{ netReason }}" style="background:none;border:none;min-height:44px;padding:0;cursor:{{ seeAllCursor }};font-size:12.5px;font-weight:600;color:{{ seeAllFg }};font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.seeAll }}</button>
                      </div>
                      <div style="display:flex;gap:12px;overflow-x:auto;padding:2px 20px 6px;scrollbar-width:thin">
                        <sc-for list="{{ continueItems }}" as="item" hint-placeholder-count="2">
                          <div style="width:212px;flex:none;background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:16px;box-shadow:0 1px 3px rgba(0,0,0,.05);cursor:pointer">
                            <div style="display:flex;align-items:center;gap:8px;margin-bottom:12px">
                              <span style="font-size:10.5px;font-weight:700;color:#716D67;background:#F5F2EC;padding:5px 9px;border-radius:999px;line-height:1">{{ item.kind }}</span>
                              <span style="font-size:11px;font-weight:600;color:#716D67;line-height:1">{{ item.meta }}</span>
                            </div>
                            <div style="font-size:14.5px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B;margin-bottom:14px;min-height:40px">{{ item.title }}</div>
                            <div style="height:6px;border-radius:4px;background:#E7E2DA;overflow:hidden;margin-bottom:8px"><div style="height:100%;border-radius:4px;background:{{ grad }};width:{{ item.pct }}%;margin-inline-start:0"></div></div>
                            <div style="font-size:11px;font-weight:600;color:#716D67;line-height:1">{{ item.progress }}</div>
                          </div>
                        </sc-for>
                      </div>
                    </div>
                  </sc-if>

                  <div style="padding:0 20px;margin-bottom:30px">
                    <div style="font-size:11px;font-weight:600;color:#FF6B1A;line-height:1;margin-bottom:14px">{{ t.roadmapLabel }}</div>
                    <sc-if value="{{ hasRoadmap }}" hint-placeholder-val="{{ true }}">
                      <div style="background:#1B1B1B;border-radius:20px;padding:20px;position:relative;overflow:hidden;cursor:pointer">
                        <div style="position:absolute;inset:0;background:radial-gradient(220px 120px at 85% 0%,rgba(255,198,46,.18),transparent 70%);pointer-events:none"></div>
                        <div style="position:relative">
                          <div style="display:flex;align-items:center;justify-content:space-between;gap:12px;margin-bottom:14px">
                            <div style="font-size:10.5px;font-weight:600;color:rgba(255,255,255,.5);line-height:1">{{ t.roadmapStageLabel }}</div>
                            <div style="font-size:11px;font-weight:700;color:#1B1B1B;background:#FFC62E;padding:5px 10px;border-radius:999px;line-height:1">{{ roadmap.fit }}</div>
                          </div>
                          <div style="font-family:{{ ffDisp }};font-weight:700;font-size:24px;line-height:{{ lhTight }};color:#fff;margin-bottom:6px">{{ roadmap.destination }}</div>
                          <div style="font-size:13.5px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.7);margin-bottom:18px">{{ roadmap.nextAction }}</div>
                          <div style="height:6px;border-radius:4px;background:rgba(255,255,255,.12);overflow:hidden;margin-bottom:10px"><div style="height:100%;border-radius:4px;background:{{ grad }};width:{{ roadmap.pct }}%"></div></div>
                          <div style="display:flex;align-items:center;justify-content:space-between;gap:12px">
                            <span style="font-size:11px;font-weight:600;color:rgba(255,255,255,.55);line-height:1">{{ roadmap.progress }}</span>
                            <span style="display:flex;align-items:center;gap:6px;font-size:12.5px;font-weight:700;color:#FFC62E;line-height:1">{{ t.openRoadmap }}<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M9 5l7 7-7 7"></path></svg></span>
                          </div>
                        </div>
                      </div>
                    </sc-if>
                    <sc-if value="{{ noRoadmap }}" hint-placeholder-val="{{ false }}">
                      <button onClick="{{ startRoadmapFromHome }}" style="width:100%;text-align:start;border:none;cursor:pointer;border-radius:20px;padding:22px;background:{{ grad }};box-shadow:0 8px 28px rgba(255,107,26,.35);font-family:{{ ff }};letter-spacing:{{ ls }}">
                        <div style="font-size:10.5px;font-weight:700;color:rgba(255,255,255,.8);line-height:1;margin-bottom:12px">{{ t.roadmapCtaEyebrow }}</div>
                        <div style="font-family:{{ ffDisp }};font-weight:700;font-size:24px;line-height:{{ lhTight }};color:#fff;margin-bottom:8px">{{ t.roadmapCtaTitle }}</div>
                        <div style="font-size:13.5px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.9);margin-bottom:18px">{{ t.roadmapCtaBody }}</div>
                        <span style="display:inline-flex;align-items:center;gap:8px;background:#fff;color:#1B1B1B;border-radius:12px;padding:12px 18px;font-size:13px;font-weight:700">{{ t.roadmapCtaAction }}<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M4 12h15"></path><path d="M13 6l6 6-6 6"></path></svg></span>
                      </button>
                    </sc-if>
                  </div>

                  <div style="padding:0 20px;margin-bottom:30px">
                    <div style="font-size:11px;font-weight:600;color:#FF6B1A;line-height:1;margin-bottom:14px">{{ pCta.label }}</div>
                    <button onClick="{{ pCta.go }}" style="width:100%;text-align:start;border:none;cursor:pointer;border-radius:20px;padding:20px;background:#1B1B1B;font-family:{{ ff }};letter-spacing:{{ ls }}">
                      <span style="display:block;font-family:{{ ffDisp }};font-weight:700;font-size:21px;line-height:{{ lhTight }};color:#fff;margin-bottom:8px">{{ pCta.title }}</span>
                      <span style="display:block;font-size:13px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.7);margin-bottom:16px">{{ pCta.body }}</span>
                      <span style="display:inline-flex;align-items:center;gap:8px;background:#fff;color:#1B1B1B;border-radius:12px;padding:11px 16px;font-size:12.5px;font-weight:700">{{ pCta.action }}<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M4 12h15"></path><path d="M13 6l6 6-6 6"></path></svg></span>
                    </button>
                    <sc-if value="{{ pCta.hasAction2 }}" hint-placeholder-val="{{ false }}">
                      <button onClick="{{ pCta.go2 }}" style="width:100%;margin-top:8px;height:40px;border:none;background:transparent;color:#FF6B1A;font-size:12.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ pCta.action2 }}</button>
                    </sc-if>
                  </div>

                  <sc-if value="{{ hasUpcoming }}" hint-placeholder-val="{{ true }}">
                    <div style="padding:0 20px;margin-bottom:30px">
                      <div style="font-size:11px;font-weight:600;color:#FF6B1A;line-height:1;margin-bottom:14px">{{ t.upcomingLabel }}</div>
                      <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:16px;display:flex;gap:14px;align-items:center;box-shadow:0 1px 3px rgba(0,0,0,.05)">
                        <div style="width:52px;flex:none;text-align:center;background:#F5F2EC;border-radius:12px;padding:9px 0">
                          <div style="font-family:{{ ffDisp }};font-weight:700;font-size:20px;line-height:1;color:#1B1B1B">{{ upcoming.day }}</div>
                          <div style="font-size:10.5px;font-weight:600;color:#716D67;margin-top:3px;line-height:1">{{ upcoming.month }}</div>
                        </div>
                        <div style="min-width:0;flex:1">
                          <div style="font-size:14.5px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ upcoming.title }}</div>
                          <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-top:2px">{{ upcoming.meta }}</div>
                        </div>
                        <button onClick="{{ openBookingsTab }}" disabled="{{ netDisabled }}" aria-disabled="{{ netAria }}" title="{{ netReason }}" style="flex:none;min-height:44px;padding:0 16px;border-radius:12px;border:1.5px solid {{ joinBorder }};background:{{ joinBg }};color:{{ joinFg }};font-size:12.5px;font-weight:700;cursor:{{ joinCursor }};font-family:{{ ff }};letter-spacing:{{ ls }}">{{ joinLabel }}</button>
                      </div>
                    </div>
                  </sc-if>

                  <sc-if value="{{ hasTutors }}" hint-placeholder-val="{{ true }}">
                    <div style="margin-bottom:30px">
                      <div style="display:flex;align-items:baseline;justify-content:space-between;padding:0 20px;margin-bottom:6px">
                        <div style="font-size:11px;font-weight:600;color:#FF6B1A;line-height:1">{{ t.tutorsLabel }}</div>
                        <button onClick="{{ seeAllTutors }}" disabled="{{ netDisabled }}" aria-disabled="{{ netAria }}" title="{{ netReason }}" style="background:none;border:none;min-height:44px;padding:0;cursor:{{ seeAllCursor }};font-size:12.5px;font-weight:600;color:{{ seeAllFg }};font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.seeAll }}</button>
                      </div>
                      <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;padding:0 20px;margin-bottom:14px">{{ t.tutorsSub }}</div>
                      <div style="display:flex;gap:12px;overflow-x:auto;padding:2px 20px 6px;scrollbar-width:thin">
                        <sc-for list="{{ tutors }}" as="tutor" hint-placeholder-count="3">
                          <div style="width:186px;flex:none;background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:16px;box-shadow:0 1px 3px rgba(0,0,0,.05);cursor:pointer">
                            <div style="display:flex;align-items:center;gap:10px;margin-bottom:12px">
                              <div role="img" aria-label="{{ tutor.name }}" style="width:42px;height:42px;border-radius:999px;border:1.5px solid #E7E2DA;background:#F5F2EC center/cover no-repeat url({{ tutor.photo }});flex:none"></div>
                              <div style="min-width:0">
                                <div style="font-size:13.5px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ tutor.name }}</div>
                                <div style="display:flex;align-items:center;gap:4px;margin-top:3px">
                                  <svg width="11" height="11" viewBox="0 0 24 24" fill="#FFAA18" stroke="none"><path d="M12 3.5l2.7 5.6 6.1.8-4.4 4.3 1.1 6-5.5-3-5.5 3 1.1-6L3.2 9.9l6.1-.8z"></path></svg>
                                  <span style="font-size:11px;font-weight:600;color:#716D67;line-height:1">{{ tutor.rating }}</span>
                                </div>
                              </div>
                            </div>
                            <div style="font-size:11px;font-weight:700;color:#496FA8;background:rgba(73,111,168,.1);padding:5px 9px;border-radius:999px;display:inline-block;line-height:1;margin-bottom:12px">{{ tutor.specialty }}</div>
                            <div style="font-size:12px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:12px">{{ tutor.next }}</div>
                            <div style="display:flex;align-items:baseline;gap:4px">
                              <span style="font-family:{{ ffDisp }};font-weight:700;font-size:17px;line-height:1;color:#1B1B1B">{{ tutor.rate }}</span>
                              <span style="font-size:11px;font-weight:500;color:#716D67;line-height:1">{{ t.perHour }}</span>
                            </div>
                          </div>
                        </sc-for>
                      </div>
                    </div>
                  </sc-if>

                  <sc-if value="{{ tutorsFailed }}" hint-placeholder-val="{{ false }}">
                    <div style="padding:0 20px;margin-bottom:30px">
                      <div style="font-size:11px;font-weight:600;color:#FF6B1A;line-height:1;margin-bottom:14px">{{ t.tutorsLabel }}</div>
                      <div style="background:#fff;border:1.5px dashed #E7E2DA;border-radius:20px;padding:18px;display:flex;align-items:center;gap:14px">
                        <div style="min-width:0;flex:1">
                          <div style="font-size:13.5px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ t.partialTitle }}</div>
                          <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-top:2px">{{ t.partialBody }}</div>
                        </div>
                        <button onClick="{{ stDefault }}" style="flex:none;height:40px;padding:0 14px;border-radius:12px;border:1.5px solid #E7E2DA;background:#fff;color:#1B1B1B;font-size:12.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.retry }}</button>
                      </div>
                    </div>
                  </sc-if>

                  <div style="padding:0 20px;margin-bottom:30px">
                    <div style="font-size:11px;font-weight:600;color:#FF6B1A;line-height:1;margin-bottom:14px">{{ t.exploreLabel }}</div>
                    <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px">
                      <button onClick="{{ goMasters }}" style="text-align:start;background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:16px;cursor:pointer;box-shadow:0 1px 3px rgba(0,0,0,.05);font-family:{{ ff }};letter-spacing:{{ ls }};transition:transform .15s cubic-bezier(.4,0,.2,1),box-shadow .15s cubic-bezier(.4,0,.2,1)" style-active="transform:scale(.98);box-shadow:0 8px 28px rgba(0,0,0,.1)">
                        <span style="color:#FF6B1A;display:block;margin-bottom:12px"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 8.5 12 4l10 4.5-10 4.5z"></path><path d="M6 10.8V16c0 1.7 2.7 3 6 3s6-1.3 6-3v-5.2"></path></svg></span>
                        <span style="display:block;font-size:14px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ t.tileProgrammes }}</span>
                        <span style="display:block;font-size:11.5px;font-weight:500;color:#716D67;margin-top:4px;line-height:{{ lhSnug }}">{{ t.tileProgrammesMeta }}</span>
                      </button>
                      <button onClick="{{ goCareer }}" style="text-align:start;background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:16px;cursor:pointer;box-shadow:0 1px 3px rgba(0,0,0,.05);font-family:{{ ff }};letter-spacing:{{ ls }};transition:transform .15s cubic-bezier(.4,0,.2,1),box-shadow .15s cubic-bezier(.4,0,.2,1)" style-active="transform:scale(.98);box-shadow:0 8px 28px rgba(0,0,0,.1)">
                        <span style="color:#FF6B1A;display:block;margin-bottom:12px"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"></circle><path d="M15.5 8.5l-2 5-5 2 2-5z"></path></svg></span>
                        <span style="display:block;font-size:14px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ t.tileCountries }}</span>
                        <span style="display:block;font-size:11.5px;font-weight:500;color:#716D67;margin-top:4px;line-height:{{ lhSnug }}">{{ t.tileCountriesMeta }}</span>
                      </button>
                      <button onClick="{{ goCareer }}" style="text-align:start;background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:16px;cursor:pointer;box-shadow:0 1px 3px rgba(0,0,0,.05);font-family:{{ ff }};letter-spacing:{{ ls }};transition:transform .15s cubic-bezier(.4,0,.2,1),box-shadow .15s cubic-bezier(.4,0,.2,1)" style-active="transform:scale(.98);box-shadow:0 8px 28px rgba(0,0,0,.1)">
                        <span style="color:#FF6B1A;display:block;margin-bottom:12px"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20s-7-4.5-7-9.2A4 4 0 0 1 12 8a4 4 0 0 1 7 2.8C19 15.5 12 20 12 20z"></path></svg></span>
                        <span style="display:block;font-size:14px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ t.tileShortlist }}</span>
                        <span style="display:block;font-size:11.5px;font-weight:500;color:#716D67;margin-top:4px;line-height:{{ lhSnug }}">{{ shortlistMetaDyn }}</span>
                      </button>
                      <button onClick="{{ goProfile }}" style="text-align:start;background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:16px;cursor:pointer;box-shadow:0 1px 3px rgba(0,0,0,.05);font-family:{{ ff }};letter-spacing:{{ ls }};transition:transform .15s cubic-bezier(.4,0,.2,1),box-shadow .15s cubic-bezier(.4,0,.2,1)" style-active="transform:scale(.98);box-shadow:0 8px 28px rgba(0,0,0,.1)">
                        <span style="color:#FF6B1A;display:block;margin-bottom:12px"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="9" r="4.4"></circle><path d="M6 20.5c0-3 2.7-5 6-5s6 2 6 5"></path></svg></span>
                        <span style="display:block;font-size:14px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ t.tileCertificates }}</span>
                        <span style="display:block;font-size:11.5px;font-weight:500;color:#716D67;margin-top:4px;line-height:{{ lhSnug }}">{{ t.tileCertificatesMeta }}</span>
                      </button>
                    </div>
                  </div>

                  <div style="padding:0 20px">
                      <div style="display:flex;align-items:baseline;justify-content:space-between;margin-bottom:14px">
                        <div style="font-size:11px;font-weight:600;color:#FF6B1A;line-height:1">{{ t.deadlinesLabel }}</div>
                        <button onClick="{{ openShortlist }}" style="background:none;border:none;min-height:44px;padding:0;cursor:pointer;font-size:12.5px;font-weight:600;color:#716D67;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.seeAll }}</button>
                      </div>
                      <sc-if value="{{ hasHomeDeadlines }}" hint-placeholder-val="{{ false }}">
                        <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:6px 16px;box-shadow:0 1px 3px rgba(0,0,0,.05)">
                          <sc-for list="{{ homeDeadlines }}" as="d" hint-placeholder-count="3">
                            <button onClick="{{ d.go }}" style="width:100%;display:flex;align-items:center;gap:11px;min-height:58px;padding:10px 0;background:none;border:none;border-bottom:1px solid #F1ECE4;cursor:pointer;text-align:start;font-family:{{ ff }};letter-spacing:{{ ls }}">
                              <span role="img" aria-label="" style="flex:none;width:32px;height:22px;border-radius:4px;border:1px solid #E7E2DA;background:{{ d.flagBg }}"></span>
                              <span style="flex:1;min-width:0">
                                <span style="display:block;font-size:12.5px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">{{ d.name }}</span>
                                <span style="display:block;font-size:11px;font-weight:500;color:#716D67;margin-top:2px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">{{ d.uni }}</span>
                              </span>
                              <span style="flex:none;font-size:10.5px;font-weight:700;color:{{ d.stFg }};background:{{ d.stBg }};padding:5px 9px;border-radius:999px;line-height:1">{{ d.stText }}</span>
                            </button>
                          </sc-for>
                          <button onClick="{{ openShortlist }}" style="width:100%;min-height:48px;background:none;border:none;cursor:pointer;font-size:12.5px;font-weight:700;color:#FF6B1A;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ dlViewAllL }}</button>
                        </div>
                      </sc-if>
                      <sc-if value="{{ noHomeDeadlines }}" hint-placeholder-val="{{ false }}">
                      <button onClick="{{ goMasters }}" style="width:100%;text-align:start;background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:18px;cursor:pointer;box-shadow:0 1px 3px rgba(0,0,0,.05);font-family:{{ ff }};letter-spacing:{{ ls }};transition:transform .15s cubic-bezier(.4,0,.2,1),box-shadow .15s cubic-bezier(.4,0,.2,1)" style-active="transform:scale(.98);box-shadow:0 8px 28px rgba(0,0,0,.1)">
                        <span style="display:block;font-family:{{ ffDisp }};font-weight:700;font-size:19px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:6px">{{ t.deadlinesTitle }}</span>
                        <span style="display:block;font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:14px">{{ t.deadlinesBody }}</span>
                        <span style="display:inline-flex;align-items:center;gap:7px;font-size:12.5px;font-weight:700;color:#FF6B1A">{{ t.deadlinesAction }}<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M9 5l7 7-7 7"></path></svg></span>
                      </button>
                      </sc-if>
                  </div>

                </div>
              </sc-if>
            </div>
          </sc-if>

          <sc-if value="{{ xCountries }}" hint-placeholder-val="{{ false }}">
            <div>
              <div style="background:#1B1B1B;padding:12px 14px 24px">
                <button onClick="{{ closeX }}" aria-label="{{ t.back }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#fff;display:flex;align-items:center;justify-content:center;margin-bottom:4px">
                  <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                </button>
                <div style="padding:0 6px">
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:24px;line-height:{{ lhTight }};color:#fff;margin-bottom:8px">{{ t.tileCountries }}</div>
                  <div style="font-size:13px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.65)">{{ t.countriesBlurb }}</div>
                </div>
              </div>
              <div style="padding:16px 20px 0">
                <div style="display:flex;gap:8px;overflow-x:auto;scrollbar-width:none;padding-bottom:2px">
                  <sc-for list="{{ cFilters }}" as="cf" hint-placeholder-count="5">
                    <button onClick="{{ cf.pick }}" style="flex:none;height:36px;padding:0 14px;border-radius:999px;border:1.5px solid {{ cf.bd }};background:{{ cf.bg }};color:{{ cf.fg }};font-size:11.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ cf.label }}</button>
                  </sc-for>
                </div>
                <div style="display:flex;gap:8px;overflow-x:auto;scrollbar-width:none;padding:10px 0 2px">
                  <sc-for list="{{ cRegions }}" as="cr" hint-placeholder-count="5">
                    <button onClick="{{ cr.pick }}" style="flex:none;height:32px;padding:0 12px;border-radius:999px;border:1.5px solid {{ cr.bd }};background:{{ cr.bg }};color:{{ cr.fg }};font-size:11px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ cr.label }}</button>
                  </sc-for>
                </div>
                <div style="font-size:11px;font-weight:600;color:#716D67;margin-top:10px">{{ countriesCount }}</div>
                <sc-if value="{{ cCmpBarShow }}" hint-placeholder-val="{{ false }}">
                  <button onClick="{{ openCountryCompare }}" style="width:100%;height:46px;margin-top:12px;border:none;border-radius:12px;background:#1B1B1B;color:#fff;font-size:12.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ cCmpBarL }}</button>
                </sc-if>
              </div>
              <div style="padding:14px 20px 30px;display:grid;gap:12px">
                <sc-for list="{{ countriesFiltered }}" as="c" hint-placeholder-count="6">
                  <button onClick="{{ c.open }}" style="text-align:start;background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:16px;cursor:pointer;box-shadow:0 1px 3px rgba(0,0,0,.05);font-family:{{ ff }};letter-spacing:{{ ls }}">
                    <span style="display:flex;gap:13px;align-items:center">
                      <span role="img" aria-label="{{ c.name }}" style="flex:none;width:40px;height:28px;border-radius:5px;border:1px solid #E7E2DA;background:{{ c.bg }}"></span>
                      <span style="flex:1;min-width:0">
                        <span style="display:flex;align-items:center;gap:7px;flex-wrap:wrap">
                          <span style="font-size:14.5px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ c.name }}</span>
                          <sc-if value="{{ c.isPopular }}" hint-placeholder-val="{{ false }}">
                            <span style="font-size:9px;font-weight:800;color:#fff;background:{{ grad }};padding:3px 7px;border-radius:999px;letter-spacing:{{ lsB }}">{{ popularL }}</span>
                          </sc-if>
                        </span>
                        <span style="display:block;font-size:11.5px;font-weight:500;color:#716D67;margin-top:4px">{{ c.reg }}</span>
                      </span>
                      <span style="flex:none;display:flex;flex-direction:column;align-items:flex-end;gap:5px">
                        <span style="font-size:10.5px;font-weight:800;color:#1B1B1B;background:#FFC62E;padding:4px 8px;border-radius:999px;direction:ltr;unicode-bidi:isolate">{{ c.exam }}</span>
                        <span style="font-size:10px;font-weight:700;color:{{ c.recFg }};background:{{ c.recBg }};padding:4px 8px;border-radius:999px">{{ c.recL }}</span>
                      </span>
                    </span>
                    <sc-if value="{{ c.hasMeta }}" hint-placeholder-val="{{ false }}">
                      <span style="display:flex;align-items:center;justify-content:space-between;gap:8px;margin-top:12px;padding-top:12px;border-top:1px solid #F1ECE4">
                        <span style="display:flex;gap:6px;flex-wrap:wrap;min-width:0">
                          <span style="font-size:10px;font-weight:700;color:#716D67;background:#F5F2EC;padding:4px 8px;border-radius:999px">{{ c.clsL }}</span>
                          <span style="font-size:10px;font-weight:700;color:#716D67;background:#F5F2EC;padding:4px 8px;border-radius:999px;direction:ltr;unicode-bidi:isolate">{{ c.months }} {{ cdL.months }}</span>
                          <span style="font-size:10px;font-weight:700;color:#716D67;background:#F5F2EC;padding:4px 8px;border-radius:999px">{{ c.diff }}</span>
                        </span>
                        <span style="flex:none;display:inline-flex;align-items:center;gap:5px;font-size:11px;font-weight:700;color:#FF6B1A">{{ viewPathwayL }}<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M9 5l7 7-7 7"></path></svg></span>
                      </span>
                    </sc-if>
                  </button>
                </sc-for>
              </div>
            </div>
          </sc-if>

          <sc-if value="{{ xCountryDetail }}" hint-placeholder-val="{{ false }}">
            <div>
              <div style="background:#1B1B1B;padding:12px 14px 26px">
                <button onClick="{{ backToCountries }}" aria-label="{{ t.back }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#fff;display:flex;align-items:center;justify-content:center;margin-bottom:6px">
                  <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                </button>
                <div style="padding:0 6px">
                  <div style="display:flex;align-items:center;gap:11px;margin-bottom:14px">
                    <span role="img" aria-label="{{ country.name }}" style="width:44px;height:31px;border-radius:5px;border:1px solid rgba(255,255,255,.25);background:{{ country.bg }}"></span>
                    <span style="font-size:11px;font-weight:800;color:#1B1B1B;background:#FFC62E;padding:5px 10px;border-radius:999px;direction:ltr;unicode-bidi:isolate">{{ country.exam }}</span>
                    <span style="font-size:10.5px;font-weight:700;color:{{ country.recFg }};background:{{ country.recBg }};padding:5px 10px;border-radius:999px">{{ country.recL }}</span>
                  </div>
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:26px;line-height:{{ lhTight }};color:#fff;margin-bottom:6px">{{ country.name }}</div>
                  <div style="font-size:13px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.65)">{{ country.reg }}</div>
                  <sc-if value="{{ country.hasDeep }}" hint-placeholder-val="{{ false }}">
                    <div>
                      <div style="display:flex;flex-wrap:wrap;gap:7px;margin-top:12px">
                        <span style="font-size:10.5px;font-weight:700;color:rgba(255,255,255,.85);background:rgba(255,255,255,.09);border:1px solid rgba(255,255,255,.14);padding:5px 10px;border-radius:999px">{{ country.diff }}</span>
                        <span style="font-size:10.5px;font-weight:700;color:rgba(255,255,255,.85);background:rgba(255,255,255,.09);border:1px solid rgba(255,255,255,.14);padding:5px 10px;border-radius:999px;direction:ltr;unicode-bidi:isolate">{{ country.months }} {{ cdL.months }}</span>
                        <span style="font-size:10.5px;font-weight:700;color:rgba(255,255,255,.85);background:rgba(255,255,255,.09);border:1px solid rgba(255,255,255,.14);padding:5px 10px;border-radius:999px">{{ country.clsL }}</span>
                      </div>
                      <div style="margin-top:16px;background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.12);border-radius:16px;padding:14px 16px">
                        <div style="font-size:10.5px;font-weight:600;color:rgba(255,255,255,.55);margin-bottom:6px;line-height:1.4">{{ cdL.earn }}</div>
                        <div style="font-family:{{ ffDisp }};font-weight:700;font-size:20px;color:#FFC62E;direction:ltr;unicode-bidi:isolate;text-align:start;line-height:1.2">{{ country.salaryBand }}</div>
                        <div style="font-size:11.5px;font-weight:500;color:rgba(255,255,255,.65);margin-top:5px;line-height:{{ lhSnug }}">{{ country.salaryNote }} · {{ country.market }}</div>
                      </div>
                    </div>
                  </sc-if>
                </div>
              </div>
              <sc-if value="{{ country.hasDeep }}" hint-placeholder-val="{{ false }}">
                <div style="padding:20px 20px 30px">
                  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;overflow:hidden;margin-bottom:18px">
                    <div style="display:flex;gap:12px;padding:12px 16px;border-bottom:1px solid #F1ECE4">
                      <span style="flex:none;width:110px;font-size:11px;font-weight:700;color:#716D67">{{ cdL.auth }}</span>
                      <span style="font-size:12px;font-weight:600;color:#1B1B1B;line-height:{{ lhSnug }}">{{ country.authority }}</span>
                    </div>
                    <div style="display:flex;gap:12px;padding:12px 16px;border-bottom:1px solid #F1ECE4">
                      <span style="flex:none;width:110px;font-size:11px;font-weight:700;color:#716D67">{{ cdL.visaCat }}</span>
                      <span style="font-size:12px;font-weight:500;color:#1B1B1B;line-height:{{ lhBody }}">{{ country.visa }}</span>
                    </div>
                    <div style="display:flex;gap:12px;padding:12px 16px">
                      <span style="flex:none;width:110px;font-size:11px;font-weight:700;color:#716D67">{{ cdL.updated }}</span>
                      <span style="font-size:12px;font-weight:600;color:#1B1B1B;direction:ltr;unicode-bidi:isolate;text-align:start">{{ country.updated }}</span>
                    </div>
                  </div>
                  <div style="display:flex;gap:8px;overflow-x:auto;scrollbar-width:none;margin-bottom:20px">
                    <sc-for list="{{ cdTabs }}" as="ct" hint-placeholder-count="4">
                      <button onClick="{{ ct.pick }}" style="flex:none;height:38px;padding:0 15px;border-radius:999px;border:1.5px solid {{ ct.bd }};background:{{ ct.bg }};color:{{ ct.fg }};font-size:12px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ ct.label }}</button>
                    </sc-for>
                  </div>

                  <sc-if value="{{ cdPath }}" hint-placeholder-val="{{ true }}">
                    <div>
                      <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:10px;line-height:1.4">{{ cdL.overview }}</div>
                      <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:16px;font-size:13px;font-weight:400;line-height:{{ lhBody }};color:#1B1B1B;margin-bottom:22px">{{ country.overview }}</div>
                      <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:12px;line-height:1.4">{{ cdL.stepsT }}</div>
                      <div style="display:grid;gap:10px;margin-bottom:22px">
                        <sc-for list="{{ country.steps }}" as="s" hint-placeholder-count="5">
                          <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:15px;display:flex;gap:12px">
                            <span style="flex:none;width:26px;height:26px;border-radius:8px;background:{{ grad }};color:#fff;font-size:12px;font-weight:800;display:flex;align-items:center;justify-content:center">{{ s.n }}</span>
                            <span style="min-width:0;flex:1">
                              <span style="display:flex;align-items:center;justify-content:space-between;gap:8px;flex-wrap:wrap">
                                <span style="font-size:13.5px;font-weight:700;line-height:{{ lhSnug }};color:#1B1B1B">{{ s.t }}</span>
                                <span style="font-size:10.5px;font-weight:700;color:#716D67;background:#F5F2EC;padding:4px 9px;border-radius:999px;direction:ltr;unicode-bidi:isolate">{{ s.when }}</span>
                              </span>
                              <sc-if value="{{ s.showOpt }}" hint-placeholder-val="{{ false }}">
                                <span style="display:inline-block;font-size:10px;font-weight:700;color:#496FA8;background:rgba(73,111,168,.1);padding:3px 8px;border-radius:999px;margin-top:6px">{{ cdL.optional }}</span>
                              </sc-if>
                              <span style="display:block;font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-top:6px">{{ s.d }}</span>
                            </span>
                          </div>
                        </sc-for>
                      </div>
                      <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:12px;line-height:1.4">{{ cdL.tips }}</div>
                      <div style="background:#1B1B1B;border-radius:16px;padding:16px;display:grid;gap:12px;margin-bottom:22px">
                        <sc-for list="{{ country.tips }}" as="tip" hint-placeholder-count="3">
                          <div style="display:flex;gap:10px">
                            <span style="flex:none;width:6px;height:6px;border-radius:50%;background:#FFC62E;margin-top:7px"></span>
                            <span style="font-size:12.5px;font-weight:500;line-height:{{ lhBody }};color:rgba(255,255,255,.85)">{{ tip }}</span>
                          </div>
                        </sc-for>
                      </div>
                      <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:12px;line-height:1.4">{{ cdL.examsT }}</div>
                      <div style="display:grid;gap:10px">
                        <sc-for list="{{ country.exams }}" as="ex" hint-placeholder-count="2">
                          <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:16px">
                            <div style="font-size:13.5px;font-weight:700;line-height:{{ lhSnug }};color:#1B1B1B;margin-bottom:6px;direction:ltr;unicode-bidi:isolate;text-align:start">{{ ex.n }}</div>
                            <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:12px">{{ ex.d }}</div>
                            <div style="display:grid;grid-template-columns:1fr 1fr;gap:9px;font-size:11.5px;margin-bottom:12px">
                              <div><div style="font-weight:600;color:#716D67;margin-bottom:2px">{{ cdL.dates }}</div><div style="font-weight:600;color:#1B1B1B">{{ ex.dates }}</div></div>
                              <div><div style="font-weight:600;color:#716D67;margin-bottom:2px">{{ cdL.fee }}</div><div style="font-weight:700;color:#1B1B1B;direction:ltr;unicode-bidi:isolate;text-align:start">{{ ex.fee }}</div></div>
                              <div><div style="font-weight:600;color:#716D67;margin-bottom:2px">{{ cdL.pass }}</div><div style="font-weight:600;color:#1B1B1B">{{ ex.pass }}</div></div>
                            </div>
                            <button onClick="{{ goCourses }}" style="height:40px;padding:0 16px;border-radius:12px;border:1.5px solid #E7E2DA;background:#fff;color:#1B1B1B;font-size:12px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ cdL.prep }}</button>
                          </div>
                        </sc-for>
                      </div>
                    </div>
                  </sc-if>

                  <sc-if value="{{ cdDocs }}" hint-placeholder-val="{{ false }}">
                    <div>
                      <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:12px;line-height:1.4">{{ cdL.checklist }}</div>
                      <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;overflow:hidden;margin-bottom:14px">
                        <sc-for list="{{ country.docs }}" as="doc" hint-placeholder-count="6">
                          <div style="display:flex;gap:11px;align-items:flex-start;padding:13px 16px;border-bottom:1px solid #F1ECE4">
                            <span style="flex:none;width:18px;height:18px;border-radius:6px;border:1.5px solid #E7E2DA;margin-top:1px"></span>
                            <span style="font-size:12.5px;font-weight:500;line-height:{{ lhSnug }};color:#1B1B1B">{{ doc }}</span>
                          </div>
                        </sc-for>
                      </div>
                      <div style="display:flex;gap:9px;background:rgba(255,170,24,.1);border:1px solid rgba(255,170,24,.35);border-radius:14px;padding:13px 15px">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#B87700" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" style="flex:none;margin-top:2px"><path d="M12 4l9 16H3z"></path><path d="M12 10v4M12 17h.01"></path></svg>
                        <span style="font-size:12px;font-weight:500;line-height:{{ lhBody }};color:#7A5200">{{ cdL.docNote }}</span>
                      </div>
                    </div>
                  </sc-if>

                  <sc-if value="{{ cdCosts }}" hint-placeholder-val="{{ false }}">
                    <div>
                      <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:12px;line-height:1.4">{{ cdL.costsT }}</div>
                      <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;overflow:hidden;margin-bottom:14px">
                        <sc-for list="{{ country.costs }}" as="row" hint-placeholder-count="5">
                          <div style="display:flex;gap:12px;align-items:baseline;justify-content:space-between;padding:13px 16px;border-bottom:1px solid #F1ECE4">
                            <span style="font-size:12.5px;font-weight:500;line-height:{{ lhSnug }};color:#1B1B1B;min-width:0">{{ row.l }}</span>
                            <span style="flex:none;text-align:end">
                              <span style="display:block;font-size:13px;font-weight:700;color:#1B1B1B;direction:ltr;unicode-bidi:isolate">{{ row.v }}</span>
                              <span style="display:block;font-size:10.5px;font-weight:600;color:#716D67;direction:ltr;unicode-bidi:isolate">≈ {{ row.usd }}</span>
                            </span>
                          </div>
                        </sc-for>
                      </div>
                      <div style="font-size:11.5px;font-weight:500;line-height:{{ lhBody }};color:#716D67">{{ country.costNote }}</div>
                    </div>
                  </sc-if>

                  <sc-if value="{{ cdRec }}" hint-placeholder-val="{{ false }}">
                    <div>
                      <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:12px;line-height:1.4">{{ cdL.recT }}</div>
                      <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:16px;margin-bottom:14px">
                        <div style="display:flex;gap:8px;flex-wrap:wrap;margin-bottom:12px">
                          <span style="font-size:10.5px;font-weight:700;color:{{ country.recFg }};background:{{ country.recBg }};padding:5px 10px;border-radius:999px">{{ country.recL }}</span>
                          <span style="font-size:10.5px;font-weight:700;color:#716D67;background:#F5F2EC;padding:5px 10px;border-radius:999px">{{ country.clsL }}</span>
                        </div>
                        <div style="font-size:13px;font-weight:400;line-height:{{ lhBody }};color:#1B1B1B">{{ country.recNote }}</div>
                      </div>
                    </div>
                  </sc-if>

                  <button onClick="{{ toggleCmpCountry }}" style="width:100%;height:48px;margin-top:20px;border:1.5px solid #1B1B1B;border-radius:14px;background:{{ cmpToggleBg }};color:{{ cmpToggleFg }};font-size:13px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ cmpToggleL }}</button>
                  <sc-if value="{{ cCmpHasAny }}" hint-placeholder-val="{{ false }}">
                    <button onClick="{{ openCountryCompare }}" style="width:100%;height:44px;margin-top:9px;border:none;border-radius:14px;background:none;color:#FF6B1A;font-size:12.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ cCmpBarL }}</button>
                  </sc-if>
                  <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin:22px 0 12px;line-height:1.4">{{ cdL.resources }}</div>
                  <div style="display:grid;gap:9px;margin-bottom:18px">
                    <button onClick="{{ goConnect }}" style="text-align:start;display:flex;align-items:center;justify-content:space-between;gap:10px;background:#fff;border:1.5px solid #E7E2DA;border-radius:14px;padding:14px 16px;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">
                      <span style="font-size:13px;font-weight:600;color:#1B1B1B">{{ cdL.rMentors }}</span>
                      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#716D67" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" style="flex:none;transform:scaleX({{ flip }})"><path d="M9 5l7 7-7 7"></path></svg>
                    </button>
                    <button onClick="{{ goMasters }}" style="text-align:start;display:flex;align-items:center;justify-content:space-between;gap:10px;background:#fff;border:1.5px solid #E7E2DA;border-radius:14px;padding:14px 16px;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">
                      <span style="font-size:13px;font-weight:600;color:#1B1B1B">{{ cdL.rMasters }}</span>
                      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#716D67" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" style="flex:none;transform:scaleX({{ flip }})"><path d="M9 5l7 7-7 7"></path></svg>
                    </button>
                    <button onClick="{{ startRoadmap }}" style="text-align:start;display:flex;align-items:center;justify-content:space-between;gap:10px;background:#fff;border:1.5px solid #E7E2DA;border-radius:14px;padding:14px 16px;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">
                      <span style="font-size:13px;font-weight:600;color:#1B1B1B">{{ cdL.rRoadmap }}</span>
                      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#716D67" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" style="flex:none;transform:scaleX({{ flip }})"><path d="M9 5l7 7-7 7"></path></svg>
                    </button>
                  </div>
                  <div style="display:flex;align-items:center;justify-content:space-between;gap:10px;background:#F5F2EC;border-radius:14px;padding:13px 16px">
                    <span style="font-size:11.5px;font-weight:600;color:#716D67;line-height:{{ lhSnug }}">{{ cdL.auth }} · {{ country.authority }}</span>
                    <span style="flex:none;font-size:11.5px;font-weight:700;color:#FF6B1A;direction:ltr;unicode-bidi:isolate">{{ country.site }}</span>
                  </div>
                </div>
              </sc-if>
              <sc-if value="{{ country.noDeep }}" hint-placeholder-val="{{ false }}">
              <div style="padding:20px 20px 30px">
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:22px">
                  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:15px">
                    <div style="font-family:{{ ffDisp }};font-weight:700;font-size:17px;color:#1B1B1B;direction:ltr;unicode-bidi:isolate;text-align:start">{{ country.months }}</div>
                    <div style="font-size:10.5px;font-weight:600;color:#716D67;margin-top:5px">{{ t.monthsTypical }}</div>
                  </div>
                  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:15px">
                    <div style="font-family:{{ ffDisp }};font-weight:700;font-size:17px;color:#1B1B1B;direction:ltr;unicode-bidi:isolate;text-align:start">{{ country.cost }}</div>
                    <div style="font-size:10.5px;font-weight:600;color:#716D67;margin-top:5px">{{ t.typicalCost }}</div>
                  </div>
                </div>
                <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:12px;line-height:1.4">{{ t.licensingRoute }}</div>
                <div style="display:grid;gap:10px;margin-bottom:22px">
                  <sc-for list="{{ country.stages }}" as="s" hint-placeholder-count="4">
                    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:15px;display:flex;gap:12px;align-items:center">
                      <span style="flex:none;width:26px;height:26px;border-radius:8px;background:{{ grad }};color:#fff;font-size:12px;font-weight:800;display:flex;align-items:center;justify-content:center">{{ s.n }}</span>
                      <span style="font-size:13px;font-weight:500;line-height:{{ lhSnug }};color:#1B1B1B">{{ s.text }}</span>
                    </div>
                  </sc-for>
                </div>
                <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:12px;line-height:1.4">{{ t.visaRoute }}</div>
                <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:16px;font-size:13px;font-weight:400;line-height:{{ lhBody }};color:#1B1B1B;margin-bottom:20px">{{ country.visa }}</div>
                <button onClick="{{ goMasters }}" style="width:100%;height:52px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:13.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.seeProgrammesHere }}</button>
              </div>
              </sc-if>
            </div>
          </sc-if>

          <sc-if value="{{ xCountryCompare }}" hint-placeholder-val="{{ false }}">
            <div>
              <div style="background:#1B1B1B;padding:12px 14px 22px">
                <button onClick="{{ backToCountries }}" aria-label="{{ t.back }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#fff;display:flex;align-items:center;justify-content:center;margin-bottom:4px">
                  <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                </button>
                <div style="padding:0 6px;font-family:{{ ffDisp }};font-weight:700;font-size:23px;line-height:{{ lhTight }};color:#fff">{{ cCmpBarL }}</div>
              </div>
              <sc-if value="{{ cCmpHasAny }}" hint-placeholder-val="{{ true }}">
                <div style="padding:18px 0 30px;overflow-x:auto;scrollbar-width:thin">
                  <div style="display:grid;grid-template-columns:{{ cCmpGrid }};gap:12px;padding:0 20px;min-width:min-content">
                    <sc-for list="{{ cCmpCols }}" as="c" hint-placeholder-count="2">
                      <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:14px">
                        <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:8px;margin-bottom:10px">
                          <span role="img" aria-label="{{ c.name }}" style="flex:none;width:34px;height:24px;border-radius:4px;border:1px solid #E7E2DA;background:{{ c.bg }}"></span>
                          <button onClick="{{ c.drop }}" aria-label="{{ t.clearAll }}" style="flex:none;width:26px;height:26px;border-radius:999px;border:1px solid #E7E2DA;background:#fff;color:#716D67;cursor:pointer;display:flex;align-items:center;justify-content:center;margin:-4px -4px 0 0">
                            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round"><path d="M6 6l12 12M18 6L6 18"></path></svg>
                          </button>
                        </div>
                        <div style="font-size:13px;font-weight:700;line-height:{{ lhSnug }};color:#1B1B1B;margin-bottom:12px">{{ c.name }}</div>
                        <div style="display:grid;gap:9px;font-size:11.5px">
                          <div><div style="font-weight:600;color:#716D67;margin-bottom:2px">{{ cRowExam }}</div><div style="font-weight:700;color:#1B1B1B;direction:ltr;unicode-bidi:isolate;text-align:start">{{ c.exam }}</div></div>
                          <div><div style="font-weight:600;color:#716D67;margin-bottom:2px">{{ cRowClass }}</div><div style="font-weight:600;color:#1B1B1B">{{ c.clsL }}</div></div>
                          <div><div style="font-weight:600;color:#716D67;margin-bottom:2px">{{ cRowMonths }}</div><div style="font-weight:700;color:#1B1B1B;direction:ltr;unicode-bidi:isolate;text-align:start">{{ c.months }}</div></div>
                          <div><div style="font-weight:600;color:#716D67;margin-bottom:2px">{{ cRowCost }}</div><div style="font-weight:700;color:#1B1B1B;direction:ltr;unicode-bidi:isolate;text-align:start">{{ c.cost }}</div></div>
                          <div><div style="font-weight:600;color:#716D67;margin-bottom:2px">{{ cRowSalary }}</div><div style="font-weight:700;color:#1B1B1B;direction:ltr;unicode-bidi:isolate;text-align:start">{{ c.salary }}</div></div>
                          <div><div style="font-weight:600;color:#716D67;margin-bottom:2px">{{ cRowDiff }}</div><div style="font-weight:600;color:#1B1B1B">{{ c.diff }}</div></div>
                          <div><div style="font-weight:600;color:#716D67;margin-bottom:2px">{{ cRowMarket }}</div><div style="font-weight:600;color:#1B1B1B">{{ c.market }}</div></div>
                        </div>
                      </div>
                    </sc-for>
                  </div>
                </div>
              </sc-if>
              <sc-if value="{{ cCmpEmptyC }}" hint-placeholder-val="{{ false }}">
                <div style="padding:40px 28px;text-align:center">
                  <div style="font-size:17px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B;margin-bottom:6px">{{ cCmpEmptyTitleL }}</div>
                  <div style="font-size:13px;font-weight:400;line-height:{{ lhBody }};color:#716D67">{{ cCmpEmptyBodyL }}</div>
                </div>
              </sc-if>
            </div>
          </sc-if>

          <sc-if value="{{ isStore }}" hint-placeholder-val="{{ false }}">
            <div style="min-height:100%;display:flex;flex-direction:column;justify-content:flex-end;padding:20px 0 0;box-sizing:border-box">
              <div style="background:#fff;border-radius:26px 26px 0 0;border-top:1.5px solid #E7E2DA;padding:10px 24px 30px">
                <div style="width:38px;height:4px;border-radius:2px;background:#E7E2DA;margin:0 auto 20px"></div>
                <div style="font-family:{{ ffDisp }};font-weight:700;font-size:22px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:16px">{{ stTitle }}</div>
                <div style="background:#F5F2EC;border-radius:16px;padding:16px;margin-bottom:14px">
                  <div style="font-size:10px;font-weight:800;color:#6B6862;letter-spacing:{{ lsE }};margin-bottom:7px">{{ stItemL }}</div>
                  <div style="font-size:14px;font-weight:700;line-height:{{ lhSnug }};color:#1B1B1B;margin-bottom:8px">{{ course.title }}</div>
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:26px;line-height:1;color:#1B1B1B;direction:ltr;unicode-bidi:isolate;text-align:start">{{ course.priceL }}</div>
                </div>
                <div style="display:grid;gap:8px;margin-bottom:14px">
                  <sc-for list="{{ stIncL }}" as="i" hint-placeholder-count="3">
                    <div style="display:flex;gap:9px;align-items:flex-start">
                      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#2D9B68" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round" style="flex:none;margin-top:3px"><path d="M5 13l4.5 4.5L19 7"></path></svg>
                      <span style="font-size:12.5px;font-weight:500;line-height:{{ lhBody }};color:#1B1B1B">{{ i }}</span>
                    </div>
                  </sc-for>
                </div>
                <div style="background:rgba(45,155,104,.1);border-radius:11px;padding:11px 13px;font-size:11.5px;font-weight:700;color:#2D9B68;line-height:{{ lhSnug }};margin-bottom:10px">{{ stOwnedL }}</div>
                <div style="background:#F5F2EC;border-radius:11px;padding:11px 13px;font-size:11px;font-weight:500;color:#6B6862;line-height:{{ lhBody }};margin-bottom:16px">{{ stPriceNote }}</div>
                <button onClick="{{ stBuy }}" style="width:100%;height:54px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};transition:transform .15s cubic-bezier(.4,0,.2,1)" style-active="transform:scale(.97)">{{ stBuyL }}</button>
                <button onClick="{{ stRestore }}" style="width:100%;min-height:46px;margin-top:8px;border:none;background:transparent;color:#FF6B1A;font-size:12.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ stRestoreL }}</button>
                <button onClick="{{ gBack }}" style="width:100%;min-height:44px;border:none;background:transparent;color:#6B6862;font-size:12.5px;font-weight:600;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ stCancelL }}</button>
              </div>
            </div>
          </sc-if>

          <sc-if value="{{ isGrant }}" hint-placeholder-val="{{ false }}">
            <div style="min-height:100%;background:#1B1B1B;padding:36px 24px 30px;box-sizing:border-box;position:relative;overflow:hidden">
              <div style="position:absolute;inset:0;background:radial-gradient(260px 160px at 80% 0%,rgba(255,198,46,.2),transparent 70%);pointer-events:none"></div>
              <div style="position:relative">
                <div style="width:60px;height:60px;border-radius:18px;background:{{ grad }};display:flex;align-items:center;justify-content:center;margin-bottom:22px">
                  <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M5 13l4.5 4.5L19 7"></path></svg>
                </div>
                <div style="font-size:10.5px;font-weight:800;color:#FFC62E;letter-spacing:{{ lsE }};margin-bottom:12px">{{ grEyebrow }}</div>
                <div style="font-family:{{ ffDisp }};font-weight:700;font-size:29px;line-height:{{ lhTight }};color:#fff;margin-bottom:12px">{{ grTitle }}</div>
                <div style="font-size:13.5px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.72);margin-bottom:22px">{{ grBody }}</div>
                <div style="display:grid;gap:10px;margin-bottom:22px">
                  <sc-for list="{{ grItems }}" as="i" hint-placeholder-count="4">
                    <div style="display:flex;gap:11px;align-items:flex-start">
                      <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#FFC62E" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round" style="flex:none;margin-top:3px"><path d="M5 13l4.5 4.5L19 7"></path></svg>
                      <span style="font-size:12.5px;font-weight:500;line-height:{{ lhBody }};color:rgba(255,255,255,.88)">{{ i }}</span>
                    </div>
                  </sc-for>
                </div>
                <div style="font-size:10px;font-weight:800;color:rgba(255,255,255,.45);letter-spacing:{{ lsE }};margin-bottom:10px">{{ grPaidL }}</div>
                <div style="display:grid;gap:9px;margin-bottom:22px">
                  <sc-for list="{{ grPaid }}" as="p" hint-placeholder-count="3">
                    <div style="display:flex;gap:11px;align-items:flex-start">
                      <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.5)" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" style="flex:none;margin-top:3px"><path d="M6 7h13l-1.6 9H8zM6 7 5 4H3M9.5 20h.01M16 20h.01"></path></svg>
                      <span style="font-size:12.5px;font-weight:500;line-height:{{ lhBody }};color:rgba(255,255,255,.7)">{{ p }}</span>
                    </div>
                  </sc-for>
                </div>
                <div style="display:flex;align-items:center;gap:9px;background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.14);border-radius:12px;padding:13px 15px;margin-bottom:10px">
                  <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" style="flex:none"><rect x="5" y="6" width="14" height="14" rx="2"></rect><path d="M8 3v4M16 3v4M5 11h14"></path></svg>
                  <span style="font-size:12px;font-weight:700;color:#fff;line-height:{{ lhSnug }}">{{ grRenewalL }}</span>
                </div>
                <div style="background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.14);border-radius:12px;padding:13px 15px;font-size:12px;font-weight:600;line-height:{{ lhBody }};color:#FFC62E;margin-bottom:24px">{{ grAskL }}</div>
                <button onClick="{{ grCta }}" style="width:100%;height:54px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 6px 24px rgba(255,107,26,.35);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};transition:transform .15s cubic-bezier(.4,0,.2,1)" style-active="transform:scale(.97)">{{ grCtaL }}</button>
                <button onClick="{{ openInvite }}" style="width:100%;min-height:48px;margin-top:9px;border:1px solid rgba(255,255,255,.2);border-radius:14px;background:rgba(255,255,255,.06);color:#fff;font-size:12.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ grInviteL }}</button>
                <button onClick="{{ grLater }}" style="width:100%;min-height:46px;margin-top:4px;border:none;background:transparent;color:rgba(255,255,255,.55);font-size:12.5px;font-weight:600;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ grLaterL }}</button>
              </div>
            </div>
          </sc-if>

          <sc-if value="{{ isAlerts }}" hint-placeholder-val="{{ false }}">
            <div>
              <div style="background:#1B1B1B;padding:12px 14px 22px">
                <button onClick="{{ gBack }}" aria-label="{{ gBackL }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#fff;display:flex;align-items:center;justify-content:center;margin-bottom:4px">
                  <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                </button>
                <div style="padding:0 6px">
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:24px;line-height:{{ lhTight }};color:#fff;margin-bottom:9px">{{ alTitle }}</div>
                  <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.68)">{{ alSub }}</div>
                </div>
              </div>
              <div style="padding:18px 20px 30px">
                <div style="font-size:10px;font-weight:800;color:#716D67;letter-spacing:{{ lsE }};margin-bottom:8px">{{ alCurrentL }}</div>
                <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:14px 16px;font-size:12.5px;font-weight:600;line-height:{{ lhBody }};color:#1B1B1B;margin-bottom:10px">{{ alCurrent }}</div>
                <button onClick="{{ alCreate }}" style="width:100%;height:52px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:13.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};transition:transform .15s cubic-bezier(.4,0,.2,1)" style-active="transform:scale(.97)">{{ alCreateL }}</button>
                <div style="font-size:11px;font-weight:600;color:#716D67;margin:10px 0 20px;direction:ltr;unicode-bidi:isolate;text-align:start">{{ alCountL }}</div>
                <sc-if value="{{ alAtCap }}" hint-placeholder-val="{{ false }}">
                  <div style="display:flex;align-items:flex-start;gap:9px;background:#F5F2EC;border-radius:12px;padding:13px 14px;margin-bottom:20px">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#716D67" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" style="flex:none;margin-top:1px"><rect x="5" y="11" width="14" height="9" rx="2"></rect><path d="M8 11V8a4 4 0 0 1 8 0v3"></path></svg>
                    <span style="font-size:11.5px;font-weight:600;line-height:{{ lhBody }};color:#716D67">{{ alCapL }}</span>
                  </div>
                </sc-if>
                <sc-if value="{{ alHasAny }}" hint-placeholder-val="{{ true }}">
                  <div style="display:grid;gap:10px;margin-bottom:16px">
                    <sc-for list="{{ alRows }}" as="a" hint-placeholder-count="1">
                      <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:16px">
                        <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:12px;margin-bottom:10px">
                          <span style="flex:1;min-width:0;font-size:13px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ a.f }}</span>
                          <button onClick="{{ a.toggle }}" aria-label="{{ a.f }}" style="flex:none;width:42px;height:25px;border:none;border-radius:999px;background:{{ a.trackBg }};display:flex;align-items:center;padding:2px;box-sizing:border-box;cursor:pointer">
                            <span style="width:21px;height:21px;border-radius:999px;background:#fff;margin-inline-start:{{ a.knob }}"></span>
                          </button>
                        </div>
                        <div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap;margin-bottom:12px">
                          <span style="font-size:11px;font-weight:700;color:#2D9B68;background:rgba(45,155,104,.1);padding:5px 9px;border-radius:999px">{{ a.nL }}</span>
                          <span style="font-size:11px;font-weight:500;color:#716D67">{{ a.last }}</span>
                        </div>
                        <button onClick="{{ a.remove }}" style="min-height:38px;padding:0 13px;border:1.5px solid #E7E2DA;border-radius:10px;background:#fff;color:#FF2D32;font-size:11.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ dlRemoveL }}</button>
                      </div>
                    </sc-for>
                  </div>
                </sc-if>
                <sc-if value="{{ alNone }}" hint-placeholder-val="{{ false }}">
                  <div style="background:#F5F2EC;border-radius:12px;padding:14px 15px;font-size:12px;font-weight:500;line-height:{{ lhBody }};color:#716D67;margin-bottom:16px">{{ alNoneL }}</div>
                </sc-if>
                <div style="font-size:11px;font-weight:400;line-height:{{ lhBody }};color:#716D67">{{ alQuietL }}</div>
              </div>
            </div>
          </sc-if>

          <sc-if value="{{ isPubProfile }}" hint-placeholder-val="{{ false }}">
            <div>
              <div style="background:#1B1B1B;padding:12px 14px 24px;position:relative;overflow:hidden">
                <div style="position:absolute;inset:0;background:radial-gradient(220px 130px at 85% 0%,rgba(255,198,46,.16),transparent 70%);pointer-events:none"></div>
                <div style="position:relative">
                  <button onClick="{{ gBack }}" aria-label="{{ gBackL }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#fff;display:flex;align-items:center;justify-content:center;margin-bottom:8px">
                    <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                  </button>
                  <div style="padding:0 6px;text-align:center">
                    <div role="img" aria-label="{{ ppName }}" style="width:88px;height:88px;border-radius:999px;border:2px solid rgba(255,255,255,.2);background:{{ avatarBgLg }};margin:0 auto 14px"></div>
                    <div style="font-family:{{ ffDisp }};font-weight:700;font-size:24px;line-height:{{ lhTight }};color:#fff;margin-bottom:6px">{{ ppName }}</div>
                    <div style="font-size:12.5px;font-weight:500;color:rgba(255,255,255,.68);margin-bottom:12px;line-height:{{ lhSnug }}">{{ ppRole }}</div>
                    <div style="display:flex;flex-wrap:wrap;gap:7px;justify-content:center;margin-bottom:16px">
                      <span style="font-size:10.5px;font-weight:700;color:#1B1B1B;background:#FFC62E;padding:5px 11px;border-radius:999px">{{ ppSpec }}</span>
                      <span style="font-size:10.5px;font-weight:700;color:rgba(255,255,255,.82);background:rgba(255,255,255,.1);border:1px solid rgba(255,255,255,.16);padding:5px 11px;border-radius:999px">{{ ppAlumni }}</span>
                      <span style="font-size:10.5px;font-weight:600;color:rgba(255,255,255,.6);background:rgba(255,255,255,.06);padding:5px 11px;border-radius:999px">{{ ppCity }}</span>
                    </div>
                    <div style="font-size:11px;font-weight:600;color:rgba(255,255,255,.45);margin-bottom:16px;direction:ltr;unicode-bidi:isolate">{{ ppHandle }}</div>
                    <div style="display:flex;gap:8px">
                      <button onClick="{{ openNfc }}" style="flex:1;min-height:46px;border:none;border-radius:12px;background:{{ grad }};color:#fff;font-size:12px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ ppViewCardL }}</button>
                      <button onClick="{{ openCv }}" style="flex:1;min-height:46px;border:1px solid rgba(255,255,255,.2);border-radius:12px;background:rgba(255,255,255,.08);color:#fff;font-size:12px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ ppDownloadCvL }}</button>
                    </div>
                  </div>
                </div>
              </div>
              <div style="display:flex;background:#fff;border-bottom:1.5px solid #E7E2DA">
                <sc-for list="{{ ppTabs }}" as="tb" hint-placeholder-count="3">
                  <button onClick="{{ tb.pick }}" style="flex:1;min-height:50px;background:none;border:none;border-bottom:2.5px solid {{ tb.bar }};cursor:pointer;color:{{ tb.fg }};font-size:12.5px;font-weight:700;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ tb.label }}</button>
                </sc-for>
              </div>
              <div style="padding:20px">
                <sc-if value="{{ ppIsAbout }}" hint-placeholder-val="{{ true }}">
                  <div>
                    <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:9px;line-height:1.4">{{ ppAboutL }}</div>
                    <div style="font-size:13px;font-weight:400;line-height:{{ lhBody }};color:#1B1B1B;margin-bottom:22px">{{ ppAbout }}</div>
                    <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:10px;line-height:1.4">{{ ppSkillsL }}</div>
                    <div style="display:flex;flex-wrap:wrap;gap:7px;margin-bottom:22px">
                      <sc-for list="{{ ppSkills }}" as="s" hint-placeholder-count="4">
                        <span style="font-size:11.5px;font-weight:600;color:#1B1B1B;background:#F5F2EC;padding:9px 13px;border-radius:999px">{{ s }}</span>
                      </sc-for>
                    </div>
                    <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:10px;line-height:1.4">{{ ppExpL }}</div>
                    <div style="display:grid;gap:14px">
                      <sc-for list="{{ ppExp }}" as="e" hint-placeholder-count="2">
                        <div style="border-inline-start:2.5px solid #FF6B1A;padding-inline-start:13px">
                          <div style="font-size:13px;font-weight:700;line-height:{{ lhSnug }};color:#1B1B1B">{{ e.r }}</div>
                          <div style="font-size:11.5px;font-weight:500;color:#716D67;margin-top:3px">{{ e.p }}</div>
                          <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-top:4px;direction:ltr;unicode-bidi:isolate;text-align:start">{{ e.d }}</div>
                        </div>
                      </sc-for>
                    </div>
                  </div>
                </sc-if>
                <sc-if value="{{ ppIsCerts }}" hint-placeholder-val="{{ false }}">
                  <div>
                    <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:10px;line-height:1.4">{{ ppCertsL }}</div>
                    <div style="display:grid;gap:10px;margin-bottom:14px">
                      <sc-for list="{{ ppCerts }}" as="c" hint-placeholder-count="3">
                        <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:15px">
                          <div style="display:flex;align-items:flex-start;gap:10px;margin-bottom:9px">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#2D9B68" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round" style="flex:none;margin-top:2px"><path d="M5 13l4.5 4.5L19 7"></path></svg>
                            <div style="min-width:0">
                              <div style="font-size:13px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ c.n }}</div>
                              <div style="font-size:11px;font-weight:500;color:#716D67;margin-top:3px;direction:ltr;unicode-bidi:isolate;text-align:start">{{ c.d }}</div>
                            </div>
                          </div>
                          <div style="display:flex;align-items:center;justify-content:space-between;gap:10px">
                            <span style="font-size:10px;font-weight:600;color:#716D67;direction:ltr;unicode-bidi:isolate">{{ c.code }}</span>
                            <button onClick="{{ ppVerifyGo }}" style="flex:none;min-height:36px;padding:0 13px;border:1.5px solid #E7E2DA;border-radius:9px;background:#fff;color:#FF6B1A;font-size:11px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ ppVerifyL }}</button>
                          </div>
                        </div>
                      </sc-for>
                    </div>
                    <div style="background:rgba(45,155,104,.1);border-radius:12px;padding:12px 14px;font-size:11.5px;font-weight:600;line-height:{{ lhBody }};color:#2D9B68">{{ ppCertNote }}</div>
                  </div>
                </sc-if>
                <sc-if value="{{ ppIsContact }}" hint-placeholder-val="{{ false }}">
                  <div>
                    <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:10px;line-height:1.4">{{ ppContactL }}</div>
                    <div style="display:grid;gap:9px;margin-bottom:14px">
                      <sc-for list="{{ ppContacts }}" as="c" hint-placeholder-count="3">
                        <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:14px;padding:14px;display:flex;align-items:center;gap:12px">
                          <span style="flex:none;width:36px;height:36px;border-radius:10px;background:#F5F2EC;color:#716D67;display:flex;align-items:center;justify-content:center">
                            <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="{{ c.icon }}"></path><path d="{{ c.d }}"></path></svg>
                          </span>
                          <span style="flex:1;min-width:0;font-size:12px;font-weight:600;color:#1B1B1B;direction:ltr;unicode-bidi:isolate;text-align:start;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">{{ c.l }}</span>
                          <button onClick="{{ c.go }}" style="flex:none;min-height:38px;padding:0 13px;border:none;border-radius:10px;background:{{ grad }};color:#fff;font-size:11px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ c.a }}</button>
                        </div>
                      </sc-for>
                    </div>
                    <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin:20px 0 10px;line-height:1.4">{{ ppSocialsL }}</div>
                    <sc-if value="{{ ppHasSocials }}" hint-placeholder-val="{{ true }}">
                      <div style="display:grid;gap:8px;margin-bottom:12px">
                        <sc-for list="{{ ppSocials }}" as="s" hint-placeholder-count="4">
                          <button onClick="{{ s.go }}" style="display:flex;align-items:center;gap:12px;min-height:52px;background:#fff;border:1.5px solid #E7E2DA;border-radius:14px;padding:11px 14px;cursor:pointer;text-align:start;font-family:{{ ff }};letter-spacing:{{ ls }}">
                            <span style="flex:none;width:34px;height:34px;border-radius:10px;background:#F5F2EC;display:flex;align-items:center;justify-content:center">
                              <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="{{ s.tone }}" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
                                <sc-for list="{{ s.paths }}" as="p" hint-placeholder-count="2">
                                  <path d="{{ p }}"></path>
                                </sc-for>
                              </svg>
                            </span>
                            <span style="flex:1;min-width:0">
                              <span style="display:block;font-size:12px;font-weight:700;color:#1B1B1B">{{ s.n }}</span>
                              <span style="display:block;font-size:10.5px;font-weight:500;color:#716D67;margin-top:2px;direction:ltr;unicode-bidi:isolate;text-align:start;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">{{ s.v }}</span>
                            </span>
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#716D67" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" style="flex:none;transform:scaleX({{ flip }})"><path d="M9 5l7 7-7 7"></path></svg>
                          </button>
                        </sc-for>
                      </div>
                    </sc-if>
                    <sc-if value="{{ ppNoSocials }}" hint-placeholder-val="{{ false }}">
                      <div style="background:#F5F2EC;border-radius:12px;padding:13px 14px;font-size:11.5px;font-weight:500;color:#716D67;margin-bottom:12px">{{ ppNoSocialsL }}</div>
                    </sc-if>
                    <button onClick="{{ openSocialEdit }}" style="width:100%;min-height:46px;border:1.5px dashed #E7E2DA;border-radius:12px;background:#fff;color:#FF6B1A;font-size:12px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};margin-bottom:18px">{{ ppEditLinksL }}</button>
                    <button onClick="{{ ppSaveContact }}" style="width:100%;min-height:50px;border:1.5px solid #E7E2DA;border-radius:14px;background:#fff;color:#1B1B1B;font-size:13px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};margin-bottom:14px">{{ ppSaveContactL }}</button>
                    <div style="background:#F5F2EC;border-radius:12px;padding:13px 14px;font-size:11.5px;font-weight:500;line-height:{{ lhBody }};color:#716D67">{{ ppNoInboxL }}</div>
                  </div>
                </sc-if>
                <div style="margin-top:24px;padding-top:18px;border-top:1px solid #E7E2DA;text-align:center">
                  <div style="font-size:10.5px;font-weight:600;color:#716D67;margin-bottom:12px">{{ ppFooterL }}</div>
                  <div style="display:flex;gap:8px">
                    <button onClick="{{ openCardStats }}" style="flex:1;min-height:46px;padding:0 12px;border:1.5px solid #E7E2DA;border-radius:12px;background:#fff;color:#1B1B1B;font-size:11.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ csTitle }}</button>
                    <button onClick="{{ openOrderCard }}" style="flex:1;min-height:46px;padding:0 12px;border:1.5px solid #E7E2DA;border-radius:12px;background:#fff;color:#FF6B1A;font-size:11.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ ppJoinL }}</button>
                  </div>
                </div>
              </div>
            </div>
          </sc-if>

          <sc-if value="{{ isSocialEdit }}" hint-placeholder-val="{{ false }}">
            <div style="padding:12px 20px 30px">
              <button onClick="{{ openPubProfile }}" aria-label="{{ gBackL }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center;margin:0 0 6px -10px">
                <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
              </button>
              <div style="font-family:{{ ffDisp }};font-weight:700;font-size:22px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:6px">{{ seTitle }}</div>
              <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:12px">{{ seSub }}</div>
              <div style="font-size:11.5px;font-weight:700;color:#FF6B1A;margin-bottom:16px;direction:ltr;unicode-bidi:isolate;text-align:start">{{ seShownCount }}</div>
              <div style="display:grid;gap:9px;margin-bottom:16px">
                <sc-for list="{{ seRows }}" as="s" hint-placeholder-count="8">
                  <div style="background:{{ s.bg }};border:1.5px solid {{ s.bd }};border-radius:16px;padding:14px">
                    <div style="display:flex;align-items:center;gap:11px;margin-bottom:11px">
                      <span style="flex:none;width:32px;height:32px;border-radius:9px;background:#fff;border:1px solid #E7E2DA;display:flex;align-items:center;justify-content:center">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="{{ s.tone }}" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
                          <sc-for list="{{ s.paths }}" as="p" hint-placeholder-count="2">
                            <path d="{{ p }}"></path>
                          </sc-for>
                        </svg>
                      </span>
                      <span style="flex:1;min-width:0;font-size:12.5px;font-weight:700;color:{{ s.fg }}">{{ s.n }}</span>
                      <button onClick="{{ s.toggle }}" aria-label="{{ s.n }}" style="flex:none;width:42px;height:25px;border:none;border-radius:999px;background:{{ s.trackBg }};display:flex;align-items:center;padding:2px;box-sizing:border-box;cursor:pointer">
                        <span style="width:21px;height:21px;border-radius:999px;background:#fff;margin-inline-start:{{ s.knob }}"></span>
                      </button>
                    </div>
                    <div style="display:flex;gap:8px;align-items:center">
                      <div style="flex:1;min-width:0;height:44px;border:1.5px solid #E7E2DA;border-radius:11px;background:#fff;display:flex;align-items:center;padding:0 12px;font-size:11.5px;font-weight:500;color:#1B1B1B;direction:ltr;unicode-bidi:isolate;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">{{ s.v }}</div>
                      <button onClick="{{ seEditGo }}" style="flex:none;min-height:44px;padding:0 14px;border:1.5px solid #E7E2DA;border-radius:11px;background:#fff;color:#FF6B1A;font-size:11.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ seEditL }}</button>
                    </div>
                  </div>
                </sc-for>
              </div>
              <div style="background:rgba(255,170,24,.1);border-radius:12px;padding:13px 15px;font-size:11.5px;font-weight:500;line-height:{{ lhBody }};color:#1B1B1B;margin-bottom:16px">{{ seWarnL }}</div>
              <button onClick="{{ seSave }}" style="width:100%;height:54px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};transition:transform .15s cubic-bezier(.4,0,.2,1)" style-active="transform:scale(.97)">{{ seSaveL }}</button>
            </div>
          </sc-if>

          <sc-if value="{{ isCardStats }}" hint-placeholder-val="{{ false }}">
            <div style="padding:12px 20px 30px">
              <button onClick="{{ gBack }}" aria-label="{{ gBackL }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center;margin:0 0 6px -10px">
                <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
              </button>
              <div style="display:inline-flex;align-items:center;gap:7px;background:rgba(73,111,168,.1);border-radius:999px;padding:6px 12px;margin-bottom:12px">
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#496FA8" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" style="flex:none"><rect x="5" y="11" width="14" height="9" rx="2"></rect><path d="M8 11V8a4 4 0 0 1 8 0v3"></path></svg>
                <span style="font-size:10px;font-weight:800;color:#496FA8;letter-spacing:{{ lsB }}">{{ csPrivateL }}</span>
              </div>
              <div style="font-family:{{ ffDisp }};font-weight:700;font-size:22px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:6px">{{ csTitle }}</div>
              <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:18px">{{ csSub }}</div>
              <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:20px">
                <sc-for list="{{ csStats }}" as="s" hint-placeholder-count="4">
                  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:16px">
                    <div style="font-family:{{ ffDisp }};font-weight:700;font-size:26px;line-height:1;color:#1B1B1B;direction:ltr">{{ s.n }}</div>
                    <div style="font-size:11.5px;font-weight:600;color:#1B1B1B;margin-top:6px;line-height:{{ lhSnug }}">{{ s.l }}</div>
                    <div style="font-size:10.5px;font-weight:700;color:#2D9B68;margin-top:4px;direction:ltr;unicode-bidi:isolate;text-align:start">{{ s.delta }}</div>
                  </div>
                </sc-for>
              </div>
              <div style="font-size:10px;font-weight:800;color:#716D67;letter-spacing:{{ lsE }};margin-bottom:9px">{{ csSourceL }}</div>
              <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:4px 16px;margin-bottom:16px">
                <sc-for list="{{ csSources }}" as="s" hint-placeholder-count="4">
                  <div style="padding:13px 0;border-bottom:1px solid #E7E2DA">
                    <div style="display:flex;align-items:center;justify-content:space-between;gap:10px;margin-bottom:7px">
                      <span style="font-size:12.5px;font-weight:600;color:#1B1B1B">{{ s.l }}</span>
                      <span style="flex:none;font-size:11.5px;font-weight:800;color:#1B1B1B;direction:ltr">{{ s.n }}</span>
                    </div>
                    <div style="height:5px;border-radius:3px;background:#E7E2DA;overflow:hidden"><div style="height:100%;border-radius:3px;background:{{ grad }};width:{{ s.pct }}%"></div></div>
                  </div>
                </sc-for>
              </div>
              <div style="background:#F5F2EC;border-radius:12px;padding:13px 14px;font-size:11.5px;font-weight:500;line-height:{{ lhBody }};color:#716D67">{{ csNoNamesL }}</div>
            </div>
          </sc-if>

          <sc-if value="{{ isOrderCard }}" hint-placeholder-val="{{ false }}">
            <div>
              <div style="background:#1B1B1B;padding:12px 14px 22px">
                <button onClick="{{ gBack }}" aria-label="{{ gBackL }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#fff;display:flex;align-items:center;justify-content:center;margin-bottom:4px">
                  <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                </button>
                <div style="padding:0 6px">
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:23px;line-height:{{ lhTight }};color:#fff;margin-bottom:9px">{{ ocTitle }}</div>
                  <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.68)">{{ ocSub }}</div>
                </div>
              </div>
              <div style="padding:18px 20px 30px">
                <div style="border-radius:16px;background:{{ ocPreviewBg }};border:1.5px solid #E7E2DA;padding:18px;margin-bottom:16px;aspect-ratio:1.6;display:flex;flex-direction:column;justify-content:space-between">
                  <div>
                    <div style="font-size:8.5px;font-weight:800;letter-spacing:{{ lsE }};color:{{ ocPreviewSub }};margin-bottom:2px">EJADAH</div>
                    <div style="font-size:7px;font-weight:600;letter-spacing:{{ lsE }};color:{{ ocPreviewSub }}">INTERNATIONAL ACADEMY</div>
                  </div>
                  <div>
                    <div style="font-family:{{ ffDisp }};font-weight:700;font-size:17px;line-height:{{ lhTight }};color:{{ ocPreviewFg }}">{{ ppName }}</div>
                    <div style="font-size:10px;font-weight:500;color:{{ ocPreviewSub }};margin-top:4px">{{ ppRole }}</div>
                  </div>
                </div>
                <div style="font-size:10px;font-weight:800;color:#716D67;letter-spacing:{{ lsE }};margin-bottom:8px">{{ ocThemeL }}</div>
                <div style="display:flex;gap:8px;margin-bottom:16px">
                  <sc-for list="{{ ocThemes }}" as="th" hint-placeholder-count="3">
                    <button onClick="{{ th.pick }}" style="flex:1;min-height:52px;border-radius:12px;border:1.5px solid {{ th.bd }};background:#fff;color:{{ th.fg }};cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};display:flex;flex-direction:column;align-items:center;justify-content:center;gap:6px;padding:8px">
                      <span style="width:22px;height:14px;border-radius:3px;background:{{ th.bg }};border:1px solid #E7E2DA"></span>
                      <span style="font-size:11px;font-weight:700">{{ th.label }}</span>
                    </button>
                  </sc-for>
                </div>
                <button onClick="{{ toggleOcQr }}" style="width:100%;display:flex;align-items:center;justify-content:space-between;gap:12px;min-height:52px;background:#fff;border:1.5px solid #E7E2DA;border-radius:14px;padding:12px 15px;cursor:pointer;text-align:start;font-family:{{ ff }};letter-spacing:{{ ls }};margin-bottom:16px">
                  <span style="font-size:12.5px;font-weight:600;color:#1B1B1B;line-height:{{ lhSnug }}">{{ ocQrL }}</span>
                  <span style="flex:none;width:42px;height:25px;border-radius:999px;background:{{ ocQrTrackBg }};display:flex;align-items:center;padding:2px;box-sizing:border-box">
                    <span style="width:21px;height:21px;border-radius:999px;background:#fff;margin-inline-start:{{ ocQrKnob }}"></span>
                  </span>
                </button>
                <div style="font-size:10px;font-weight:800;color:#716D67;letter-spacing:{{ lsE }};margin-bottom:9px">{{ ocScopeL }}</div>
                <div style="display:grid;gap:8px;margin-bottom:20px">
                  <sc-for list="{{ ocScopes }}" as="sc" hint-placeholder-count="3">
                    <button onClick="{{ sc.pick }}" style="display:flex;align-items:flex-start;gap:11px;min-height:56px;background:{{ sc.bg }};border:1.5px solid {{ sc.bd }};border-radius:14px;padding:13px 14px;cursor:pointer;text-align:start;font-family:{{ ff }};letter-spacing:{{ ls }}">
                      <span style="flex:none;width:20px;height:20px;border-radius:999px;border:1.5px solid {{ sc.boxBd }};background:{{ sc.boxBg }};display:flex;align-items:center;justify-content:center;margin-top:1px">
                        <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="3.6" stroke-linecap="round" stroke-linejoin="round"><path d="M5 13l4.5 4.5L19 7"></path></svg>
                      </span>
                      <span style="flex:1;min-width:0">
                        <span style="display:block;font-size:12.5px;font-weight:700;color:#1B1B1B">{{ sc.label }}</span>
                        <span style="display:block;font-size:11px;font-weight:500;color:#716D67;margin-top:3px;line-height:{{ lhSnug }}">{{ sc.sub }}</span>
                      </span>
                    </button>
                  </sc-for>
                </div>
                <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:18px;margin-bottom:14px">
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:26px;line-height:1;color:#1B1B1B;direction:ltr;unicode-bidi:isolate;text-align:start;margin-bottom:7px">{{ ocPriceL }}</div>
                  <div style="font-size:11.5px;font-weight:500;line-height:{{ lhBody }};color:#716D67">{{ ocPriceNote }}</div>
                </div>
                <button onClick="{{ ocOrder }}" style="width:100%;height:54px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};transition:transform .15s cubic-bezier(.4,0,.2,1)" style-active="transform:scale(.97)">{{ ocOrderL }}</button>
                <div style="font-size:11px;font-weight:500;line-height:{{ lhBody }};color:#716D67;margin:12px 0 14px">{{ ocPhysNote }}</div>
                <button onClick="{{ ocShareInstead }}" style="width:100%;min-height:48px;border:1.5px solid #E7E2DA;border-radius:14px;background:#fff;color:#1B1B1B;font-size:12.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ ocShareInsteadL }}</button>
              </div>
            </div>
          </sc-if>

          <sc-if value="{{ isCustom }}" hint-placeholder-val="{{ false }}">
            <div>
              <div style="background:#1B1B1B;padding:12px 14px 22px">
                <button onClick="{{ gBack }}" aria-label="{{ gBackL }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#fff;display:flex;align-items:center;justify-content:center;margin-bottom:4px">
                  <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                </button>
                <div style="padding:0 6px">
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:24px;line-height:{{ lhTight }};color:#fff;margin-bottom:9px">{{ cuTitle }}</div>
                  <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.68)">{{ cuSub }}</div>
                </div>
              </div>
              <div style="padding:18px 20px 30px">

                <div style="font-size:10px;font-weight:800;color:#716D67;letter-spacing:{{ lsE }};margin-bottom:8px">{{ cuWeekL }}</div>
                <div style="display:flex;gap:8px;margin-bottom:16px">
                  <sc-for list="{{ cuWeekOpts }}" as="o" hint-placeholder-count="4">
                    <button onClick="{{ o.pick }}" style="flex:1;min-height:46px;border-radius:12px;border:1.5px solid {{ o.bd }};background:{{ o.bg }};color:{{ o.fg }};font-size:13px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};direction:ltr">{{ o.label }}</button>
                  </sc-for>
                </div>

                <div style="font-size:10px;font-weight:800;color:#716D67;letter-spacing:{{ lsE }};margin-bottom:8px">{{ cuHoursL }}</div>
                <div style="display:flex;gap:8px;margin-bottom:16px">
                  <sc-for list="{{ cuHoursOpts }}" as="o" hint-placeholder-count="4">
                    <button onClick="{{ o.pick }}" style="flex:1;min-height:46px;border-radius:12px;border:1.5px solid {{ o.bd }};background:{{ o.bg }};color:{{ o.fg }};font-size:13px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};direction:ltr">{{ o.label }}</button>
                  </sc-for>
                </div>

                <div style="font-size:10px;font-weight:800;color:#716D67;letter-spacing:{{ lsE }};margin-bottom:8px">{{ cuWeeksL }}</div>
                <div style="display:flex;gap:8px;margin-bottom:20px">
                  <sc-for list="{{ cuWeeksOpts }}" as="o" hint-placeholder-count="4">
                    <button onClick="{{ o.pick }}" style="flex:1;min-height:46px;border-radius:12px;border:1.5px solid {{ o.bd }};background:{{ o.bg }};color:{{ o.fg }};font-size:12.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};direction:ltr">{{ o.label }}</button>
                  </sc-for>
                </div>

                <div style="background:#1B1B1B;border-radius:20px;padding:20px;margin-bottom:16px;position:relative;overflow:hidden">
                  <div style="position:absolute;inset:0;background:radial-gradient(200px 110px at 88% 0%,rgba(255,198,46,.16),transparent 70%);pointer-events:none"></div>
                  <div style="position:relative">
                    <div style="display:flex;align-items:center;justify-content:space-between;gap:10px;margin-bottom:12px">
                      <span style="font-size:11.5px;font-weight:700;color:rgba(255,255,255,.7);direction:ltr;unicode-bidi:isolate;text-align:start">{{ cuSessionsL }}</span>
                      <sc-if value="{{ cuHasDiscount }}" hint-placeholder-val="{{ true }}">
                        <span style="flex:none;font-size:11px;font-weight:800;color:#1B1B1B;background:#FFC62E;padding:5px 10px;border-radius:999px;direction:ltr">{{ cuTierPct }}</span>
                      </sc-if>
                    </div>
                    <div style="display:flex;align-items:baseline;gap:10px;flex-wrap:wrap;margin-bottom:6px">
                      <span style="font-family:{{ ffDisp }};font-weight:700;font-size:30px;line-height:1;color:#fff;direction:ltr;unicode-bidi:isolate">{{ cuTotalL }}</span>
                      <sc-if value="{{ cuHasDiscount }}" hint-placeholder-val="{{ true }}">
                        <span style="font-size:13px;font-weight:500;color:rgba(255,255,255,.45);text-decoration:line-through;direction:ltr;unicode-bidi:isolate">{{ cuGrossL }}</span>
                      </sc-if>
                    </div>
                    <div style="font-size:12px;font-weight:600;color:rgba(255,255,255,.72);margin-bottom:4px;direction:ltr;unicode-bidi:isolate;text-align:start">{{ cuPerSessionL }}</div>
                    <sc-if value="{{ cuHasDiscount }}" hint-placeholder-val="{{ true }}">
                      <div style="font-size:12px;font-weight:700;color:#FFC62E;direction:ltr;unicode-bidi:isolate;text-align:start">{{ cuSavedL }}</div>
                    </sc-if>
                    <sc-if value="{{ cuHasNextTier }}" hint-placeholder-val="{{ true }}">
                      <div style="margin-top:14px;background:rgba(255,255,255,.08);border-radius:10px;padding:11px 13px;font-size:11.5px;font-weight:600;color:rgba(255,255,255,.85);line-height:{{ lhSnug }}">{{ cuNextTierL }}</div>
                    </sc-if>
                  </div>
                </div>

                <div style="font-size:10px;font-weight:800;color:#716D67;letter-spacing:{{ lsE }};margin-bottom:9px">{{ cuLadderL }}</div>
                <div style="display:grid;gap:7px;margin-bottom:22px">
                  <sc-for list="{{ cuLadder }}" as="t" hint-placeholder-count="4">
                    <button onClick="{{ t.pick }}" style="width:100%;display:flex;align-items:center;justify-content:space-between;gap:12px;background:{{ t.bg }};border:1.5px solid {{ t.bd }};border-radius:12px;padding:12px 14px;min-height:52px;cursor:pointer;text-align:start;font-family:{{ ff }};letter-spacing:{{ ls }};transition:transform .15s cubic-bezier(.4,0,.2,1)" style-active="transform:scale(.98)">
                      <span style="flex:1;min-width:0">
                        <span style="display:block;font-size:12.5px;font-weight:600;color:{{ t.fg }}">{{ t.l }}</span>
                        <span style="display:block;font-size:10.5px;font-weight:500;color:#716D67;margin-top:2px;direction:ltr;unicode-bidi:isolate;text-align:start">{{ t.hint }}</span>
                      </span>
                      <span style="flex:none;font-size:12px;font-weight:800;color:{{ t.fg }};direction:ltr;unicode-bidi:isolate">{{ t.pct }}</span>
                    </button>
                  </sc-for>
                </div>

                <div style="font-size:10px;font-weight:800;color:#716D67;letter-spacing:{{ lsE }};margin-bottom:5px">{{ cuSlotsL }}</div>
                <div style="font-size:11px;font-weight:400;color:#716D67;margin-bottom:11px;line-height:{{ lhSnug }}">{{ cuSlotsHint }}</div>
                <div style="display:flex;gap:6px;overflow-x:auto;scrollbar-width:none;margin-bottom:12px">
                  <sc-for list="{{ cuWeekDots }}" as="w" hint-placeholder-count="8">
                    <button onClick="{{ w.pick }}" aria-label="{{ w.label }}" style="flex:none;min-width:44px;min-height:44px;border-radius:12px;cursor:pointer;background:{{ w.bg }};color:{{ w.fg }};border:1.5px solid {{ w.bd }};font-size:12px;font-weight:800;font-family:{{ ff }};letter-spacing:{{ ls }};direction:ltr;display:flex;align-items:center;justify-content:center;gap:3px">
                      <sc-if value="{{ w.full }}" hint-placeholder-val="{{ false }}">
                        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="{{ w.tick }}" stroke-width="3.4" stroke-linecap="round" stroke-linejoin="round" style="flex:none"><path d="M5 13l4.5 4.5L19 7"></path></svg>
                      </sc-if>
                      <sc-if value="{{ w.notFull }}" hint-placeholder-val="{{ true }}">
                        <span>{{ w.label }}</span>
                      </sc-if>
                    </button>
                  </sc-for>
                </div>
                <div style="height:6px;border-radius:4px;background:#E7E2DA;overflow:hidden;margin-bottom:10px"><div style="height:100%;border-radius:4px;background:{{ grad }};width:{{ cuOverallPct }}%;transition:width .3s cubic-bezier(.4,0,.2,1)"></div></div>
                <div style="display:flex;align-items:center;gap:9px;background:{{ cuStatusBg }};border-radius:11px;padding:11px 13px;margin-bottom:14px">
                  <sc-if value="{{ cuStatusDone }}" hint-placeholder-val="{{ false }}">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="{{ cuStatusFg }}" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" style="flex:none"><path d="M5 13l4.5 4.5L19 7"></path></svg>
                  </sc-if>
                  <span style="font-size:12px;font-weight:700;line-height:{{ lhSnug }};color:{{ cuStatusFg }}">{{ cuStatusL }}</span>
                </div>
                <div style="display:flex;align-items:baseline;justify-content:space-between;gap:10px;margin-bottom:4px">
                  <span style="font-size:13.5px;font-weight:700;color:#1B1B1B">{{ cuWeekTitleL }}</span>
                  <sc-if value="{{ cuSameShow }}" hint-placeholder-val="{{ false }}">
                    <button onClick="{{ cuSame }}" style="flex:none;min-height:36px;padding:0 11px;border:1.5px solid #FF6B1A;border-radius:10px;background:rgba(255,107,26,.06);color:#FF6B1A;font-size:11px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ cuSameL }}</button>
                  </sc-if>
                </div>
                <div style="font-size:11.5px;font-weight:500;color:#716D67;margin-bottom:12px;direction:ltr;unicode-bidi:isolate;text-align:start">{{ cuWeekNeedL }}</div>
                <div style="display:flex;gap:6px;overflow-x:auto;scrollbar-width:none;margin-bottom:14px">
                  <sc-for list="{{ cuDays }}" as="d" hint-placeholder-count="7">
                    <button onClick="{{ d.pick }}" style="flex:none;min-width:56px;min-height:52px;border-radius:12px;padding:8px 10px;cursor:pointer;background:{{ d.bg }};color:{{ d.fg }};border:1.5px solid {{ d.bd }};font-size:11.5px;font-weight:700;font-family:{{ ff }};letter-spacing:{{ ls }};display:flex;flex-direction:column;align-items:center;justify-content:center;gap:3px">
                      <span>{{ d.label }}</span>
                      <sc-if value="{{ d.hasN }}" hint-placeholder-val="{{ false }}">
                        <span style="font-size:9.5px;font-weight:800;opacity:.7;direction:ltr">{{ d.n }}</span>
                      </sc-if>
                    </button>
                  </sc-for>
                </div>
                <div style="font-size:12.5px;font-weight:700;color:#1B1B1B;margin-bottom:10px">{{ cuDayFullL }}</div>
                <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:7px;margin-bottom:14px">
                  <sc-for list="{{ cuCells }}" as="h" hint-placeholder-count="15">
                    <button onClick="{{ h.toggle }}" style="min-height:44px;border-radius:11px;cursor:{{ h.cursor }};background:{{ h.bg }};color:{{ h.fg }};border:1.5px solid {{ h.bd }};font-size:11.5px;font-weight:700;font-family:{{ ff }};letter-spacing:{{ ls }};direction:ltr;unicode-bidi:isolate">{{ h.label }}</button>
                  </sc-for>
                </div>
                <div style="font-size:11.5px;font-weight:600;color:#1B1B1B;margin-bottom:14px;direction:ltr;unicode-bidi:isolate;text-align:start">{{ cuPickedCount }}</div>
                <sc-if value="{{ cuHasPicked }}" hint-placeholder-val="{{ true }}">
                  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:4px 14px;margin-bottom:18px">
                    <sc-for list="{{ cuPickedRows }}" as="r" hint-placeholder-count="2">
                      <div style="padding:12px 0;border-bottom:1px solid #F1ECE4">
                        <div style="font-size:12px;font-weight:700;color:#1B1B1B">{{ r.day }}</div>
                        <div style="font-size:11px;font-weight:500;color:#716D67;margin-top:3px;direction:ltr;unicode-bidi:isolate;text-align:start">{{ r.hours }}</div>
                      </div>
                    </sc-for>
                  </div>
                </sc-if>

                <button onClick="{{ cuRequest }}" style="width:100%;height:54px;border:none;border-radius:14px;background:{{ cuRequestBg }};color:{{ cuRequestFg }};font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};transition:transform .15s cubic-bezier(.4,0,.2,1)" style-active="transform:scale(.97)">{{ cuRequestL }}</button>
                <div style="font-size:11px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-top:14px">{{ cuNoteL }}</div>
              </div>
            </div>
          </sc-if>

          <sc-if value="{{ isTracker }}" hint-placeholder-val="{{ false }}">
            <div>
              <div style="background:#1B1B1B;padding:12px 14px 22px">
                <button onClick="{{ gBack }}" aria-label="{{ gBackL }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#fff;display:flex;align-items:center;justify-content:center;margin-bottom:4px">
                  <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                </button>
                <div style="padding:0 6px">
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:25px;line-height:{{ lhTight }};color:#fff;margin-bottom:8px">{{ trackerTitle }}</div>
                  <div style="font-size:13px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.7)">{{ trackerSub }}</div>
                </div>
              </div>
              <div style="padding:16px 20px 30px">
                <div style="display:flex;gap:6px;overflow-x:auto;scrollbar-width:none;margin-bottom:18px">
                  <sc-for list="{{ pipe }}" as="st" hint-placeholder-count="5">
                    <div style="flex:none;background:{{ st.bg }};border-radius:12px;padding:9px 12px;text-align:center;min-width:62px">
                      <div style="font-family:{{ ffDisp }};font-weight:700;font-size:17px;line-height:1;color:{{ st.fg }};direction:ltr">{{ st.n }}</div>
                      <div style="font-size:9.5px;font-weight:700;color:#716D67;margin-top:4px;line-height:1.4">{{ st.label }}</div>
                    </div>
                  </sc-for>
                </div>
                <sc-if value="{{ trackerEmpty }}" hint-placeholder-val="{{ false }}">
                  <div style="padding:30px 10px;text-align:center">
                    <div style="font-size:13px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:18px">{{ trackerEmptyL }}</div>
                    <button onClick="{{ goMasters }}" style="height:50px;padding:0 24px;border:none;border-radius:14px;background:{{ grad }};color:#fff;font-size:13.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.tileProgrammes }}</button>
                  </div>
                </sc-if>
                <div style="display:grid;gap:12px">
                  <sc-for list="{{ trackerRows }}" as="r" hint-placeholder-count="3">
                    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:16px;box-shadow:0 1px 3px rgba(0,0,0,.05)">
                      <div style="display:flex;align-items:flex-start;gap:11px;margin-bottom:13px">
                        <span role="img" aria-label="" style="flex:none;width:34px;height:24px;border-radius:4px;border:1px solid #E7E2DA;background:{{ r.flagBg }};margin-top:2px"></span>
                        <div style="flex:1;min-width:0">
                          <div style="font-size:13.5px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ r.name }}</div>
                          <div style="font-size:11.5px;font-weight:500;color:#716D67;margin-top:3px">{{ r.uni }}</div>
                        </div>
                        <span style="flex:none;font-size:10px;font-weight:700;color:{{ r.dlFg }};background:{{ r.dlBg }};padding:5px 9px;border-radius:999px;line-height:1.4">{{ r.dl }}</span>
                      </div>
                      <div style="display:flex;align-items:center;gap:5px;margin-bottom:8px">
                        <sc-for list="{{ r.dots }}" as="d" hint-placeholder-count="5">
                          <span style="height:5px;width:{{ d.w }};border-radius:3px;background:{{ d.bg }}"></span>
                        </sc-for>
                        <span style="font-size:11px;font-weight:700;color:#1B1B1B;margin-inline-start:6px">{{ r.stageL }}</span>
                      </div>
                      <div style="font-size:12px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:12px">{{ r.next }}</div>
                      <button onClick="{{ r.openDocs }}" style="width:100%;background:#F5F2EC;border:none;border-radius:12px;padding:11px 13px;cursor:pointer;text-align:start;font-family:{{ ff }};letter-spacing:{{ ls }};margin-bottom:10px">
                        <span style="display:flex;align-items:center;justify-content:space-between;gap:10px;margin-bottom:7px">
                          <span style="font-size:11.5px;font-weight:700;color:#1B1B1B">{{ r.docsL }}</span>
                          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#FF6B1A" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" style="flex:none;transform:scaleX({{ flip }})"><path d="M9 5l7 7-7 7"></path></svg>
                        </span>
                        <span style="display:block;height:5px;border-radius:3px;background:#E7E2DA;overflow:hidden"><span style="display:block;height:100%;border-radius:3px;background:{{ grad }};width:{{ r.docsPct }}%"></span></span>
                      </button>
                      <sc-if value="{{ r.canAdvance }}" hint-placeholder-val="{{ true }}">
                        <button onClick="{{ r.advance }}" style="width:100%;min-height:44px;border:1.5px solid #E7E2DA;border-radius:12px;background:#fff;color:#1B1B1B;font-size:12px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ r.advanceL }}</button>
                      </sc-if>
                    </div>
                  </sc-for>
                </div>
              </div>
            </div>
          </sc-if>

          <sc-if value="{{ isTrackerDocs }}" hint-placeholder-val="{{ false }}">
            <div style="padding:12px 20px 30px">
              <button onClick="{{ openTracker }}" aria-label="{{ gBackL }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center;margin:0 0 6px -10px">
                <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
              </button>
              <div style="font-family:{{ ffDisp }};font-weight:700;font-size:22px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:4px">{{ docsTitle }}</div>
              <div style="font-size:12.5px;font-weight:500;color:#716D67;margin-bottom:6px">{{ trkName }}</div>
              <div style="font-size:11.5px;font-weight:400;color:#716D67;margin-bottom:18px">{{ trkUni }}</div>
              <div style="display:grid;gap:9px;margin-bottom:18px">
                <sc-for list="{{ docRows }}" as="d" hint-placeholder-count="7">
                  <button onClick="{{ d.toggle }}" style="display:flex;align-items:center;gap:12px;min-height:52px;background:#fff;border:1.5px solid #E7E2DA;border-radius:14px;padding:10px 14px;cursor:pointer;text-align:start;font-family:{{ ff }};letter-spacing:{{ ls }}">
                    <span style="flex:none;width:24px;height:24px;border-radius:7px;border:1.5px solid {{ d.boxBd }};background:{{ d.boxBg }};display:flex;align-items:center;justify-content:center">
                      <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="3.4" stroke-linecap="round" stroke-linejoin="round"><path d="M5 13l4.5 4.5L19 7"></path></svg>
                    </span>
                    <span style="font-size:13px;font-weight:600;line-height:{{ lhSnug }};color:{{ d.fg }};text-decoration:{{ d.deco }}">{{ d.label }}</span>
                  </button>
                </sc-for>
              </div>
              <div style="background:rgba(255,170,24,.1);border-radius:12px;padding:13px 15px;font-size:12px;font-weight:500;line-height:{{ lhBody }};color:#1B1B1B">{{ docsNote }}</div>
            </div>
          </sc-if>

          <sc-if value="{{ isMatch }}" hint-placeholder-val="{{ false }}">
            <div>
              <div style="background:#1B1B1B;padding:12px 14px 22px">
                <button onClick="{{ gBack }}" aria-label="{{ gBackL }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#fff;display:flex;align-items:center;justify-content:center;margin-bottom:4px">
                  <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                </button>
                <div style="padding:0 6px">
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:25px;line-height:{{ lhTight }};color:#fff;margin-bottom:8px">{{ matchTitle }}</div>
                  <div style="font-size:13px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.7)">{{ matchSub }}</div>
                </div>
              </div>
              <div style="padding:18px 20px 30px">
                <div style="display:grid;gap:11px;margin-bottom:16px">
                  <sc-for list="{{ matchRows }}" as="m" hint-placeholder-count="4">
                    <button onClick="{{ m.open }}" style="text-align:start;background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:16px;cursor:pointer;box-shadow:0 1px 3px rgba(0,0,0,.05);font-family:{{ ff }};letter-spacing:{{ ls }}">
                      <span style="display:flex;align-items:center;gap:11px;margin-bottom:11px">
                        <span role="img" aria-label="" style="flex:none;width:32px;height:22px;border-radius:4px;border:1px solid #E7E2DA;background:{{ m.flagBg }}"></span>
                        <span style="flex:1;min-width:0">
                          <span style="display:block;font-size:13px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ m.name }}</span>
                          <span style="display:block;font-size:11px;font-weight:500;color:#716D67;margin-top:2px">{{ m.uni }}</span>
                        </span>
                        <span style="flex:none;font-family:{{ ffDisp }};font-weight:700;font-size:19px;color:{{ m.tone }};direction:ltr">{{ m.pct }}%</span>
                      </span>
                      <span style="display:block;height:6px;border-radius:4px;background:#E7E2DA;overflow:hidden;margin-bottom:9px"><span style="display:block;height:100%;border-radius:4px;background:{{ m.tone }};width:{{ m.pct }}%"></span></span>
                      <span style="display:block;font-size:11px;font-weight:700;color:#1B1B1B;margin-bottom:3px">{{ m.metL }}</span>
                      <span style="display:block;font-size:11.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67">{{ m.gapL }}</span>
                    </button>
                  </sc-for>
                </div>
                <div style="background:#1B1B1B;border-radius:18px;padding:18px;position:relative;overflow:hidden">
                  <div style="position:absolute;inset:0;background:radial-gradient(180px 100px at 90% 0%,rgba(255,198,46,.16),transparent 70%);pointer-events:none"></div>
                  <div style="position:relative">
                    <div style="font-size:14.5px;font-weight:700;line-height:{{ lhSnug }};color:#fff;margin-bottom:6px">{{ matchAllL }}</div>
                    <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.7);margin-bottom:14px">{{ matchAllSub }}</div>
                    <sc-if value="{{ pmLocked }}" hint-placeholder-val="{{ true }}">
                      <div style="display:flex;align-items:center;gap:9px;background:rgba(255,255,255,.08);border-radius:10px;padding:11px 13px">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.75)" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" style="flex:none"><rect x="5" y="11" width="14" height="9" rx="2"></rect><path d="M8 11V8a4 4 0 0 1 8 0v3"></path></svg>
                        <span style="font-size:11.5px;font-weight:700;color:rgba(255,255,255,.8)">{{ pmLockL }}</span>
                      </div>
                    </sc-if>
                    <sc-if value="{{ pmUnlocked }}" hint-placeholder-val="{{ false }}">
                      <button onClick="{{ goMasters }}" style="min-height:46px;padding:0 18px;border:none;border-radius:12px;background:#fff;color:#1B1B1B;font-size:12.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.viewDetails }}</button>
                    </sc-if>
                  </div>
                </div>
              </div>
            </div>
          </sc-if>

          <sc-if value="{{ isMatchDetail }}" hint-placeholder-val="{{ false }}">
            <div style="padding:12px 20px 30px">
              <button onClick="{{ openMatch }}" aria-label="{{ gBackL }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center;margin:0 0 6px -10px">
                <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
              </button>
              <div style="font-family:{{ ffDisp }};font-weight:700;font-size:21px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:4px">{{ mdName }}</div>
              <div style="font-size:12px;font-weight:500;color:#716D67;margin-bottom:18px">{{ mdUni }}</div>
              <div style="display:grid;gap:8px;margin-bottom:18px">
                <sc-for list="{{ mdReqs }}" as="rq" hint-placeholder-count="7">
                  <div style="display:flex;align-items:flex-start;gap:11px;background:{{ rq.bg }};border-radius:12px;padding:12px 14px">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="{{ rq.tone }}" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round" style="flex:none;margin-top:2px"><path d="{{ rq.icon }}"></path></svg>
                    <div style="min-width:0">
                      <div style="font-size:12.5px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ rq.l }}</div>
                      <div style="font-size:11px;font-weight:500;color:#716D67;margin-top:3px;direction:ltr;unicode-bidi:isolate;text-align:start">{{ rq.mine }}</div>
                    </div>
                  </div>
                </sc-for>
              </div>
              <div style="background:#1B1B1B;border-radius:16px;padding:16px">
                <div style="font-size:12.5px;font-weight:500;line-height:{{ lhBody }};color:rgba(255,255,255,.82);margin-bottom:14px">{{ mdFixL }}</div>
                <button onClick="{{ mdFixGo }}" style="width:100%;min-height:46px;border:none;border-radius:12px;background:{{ grad }};color:#fff;font-size:12.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ mdFixCta }}</button>
              </div>
            </div>
          </sc-if>

          <sc-if value="{{ isThread }}" hint-placeholder-val="{{ false }}">
            <div>
              <div style="background:#1B1B1B;padding:12px 14px 22px">
                <button onClick="{{ gBack }}" aria-label="{{ gBackL }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#fff;display:flex;align-items:center;justify-content:center;margin-bottom:6px">
                  <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                </button>
                <div style="display:flex;align-items:center;gap:13px;padding:0 6px">
                  <span role="img" aria-label="{{ threadTutor }}" style="flex:none;width:52px;height:52px;border-radius:999px;border:1.5px solid rgba(255,255,255,.2);background:#F5F2EC center/cover no-repeat url(https://i.pravatar.cc/160?img=32)"></span>
                  <div style="min-width:0">
                    <div style="font-family:{{ ffDisp }};font-weight:700;font-size:21px;line-height:{{ lhTight }};color:#fff">{{ threadTutor }}</div>
                    <div style="font-size:12px;font-weight:500;color:rgba(255,255,255,.62);margin-top:3px">{{ threadMeta }}</div>
                  </div>
                </div>
              </div>
              <div style="padding:20px 20px 30px">
                <div style="font-size:11px;font-weight:600;color:#FF6B1A;line-height:1.4;margin-bottom:10px">{{ threadPracticeL }}</div>
                <div style="display:grid;gap:8px;margin-bottom:24px">
                  <sc-for list="{{ practiceRows }}" as="p" hint-placeholder-count="3">
                    <button onClick="{{ p.toggle }}" style="display:flex;align-items:flex-start;gap:11px;min-height:48px;background:#fff;border:1.5px solid #E7E2DA;border-radius:14px;padding:12px 14px;cursor:pointer;text-align:start;font-family:{{ ff }};letter-spacing:{{ ls }}">
                      <span style="flex:none;width:22px;height:22px;border-radius:7px;border:1.5px solid {{ p.boxBd }};background:{{ p.boxBg }};display:flex;align-items:center;justify-content:center;margin-top:1px">
                        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="3.4" stroke-linecap="round" stroke-linejoin="round"><path d="M5 13l4.5 4.5L19 7"></path></svg>
                      </span>
                      <span style="font-size:12.5px;font-weight:500;line-height:{{ lhBody }};color:{{ p.fg }};text-decoration:{{ p.deco }}">{{ p.l }}</span>
                    </button>
                  </sc-for>
                </div>
                <div style="font-size:11px;font-weight:600;color:#FF6B1A;line-height:1.4;margin-bottom:10px">{{ threadHistoryL }}</div>
                <div style="display:grid;gap:10px;margin-bottom:22px">
                  <sc-for list="{{ threadSessions }}" as="s" hint-placeholder-count="3">
                    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:15px">
                      <div style="display:flex;align-items:center;gap:10px;margin-bottom:9px">
                        <span style="flex:none;width:26px;height:26px;border-radius:999px;background:{{ grad }};color:#fff;font-size:12px;font-weight:800;display:flex;align-items:center;justify-content:center">{{ s.n }}</span>
                        <span style="font-size:11.5px;font-weight:700;color:#716D67">{{ s.when }}</span>
                      </div>
                      <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#1B1B1B;margin-bottom:9px">{{ s.note }}</div>
                      <div style="font-size:11px;font-weight:600;color:#496FA8;background:rgba(73,111,168,.09);border-radius:8px;padding:8px 10px;display:inline-block">{{ s.files }}</div>
                    </div>
                  </sc-for>
                </div>
                <button onClick="{{ threadBookGo }}" style="width:100%;height:54px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};transition:transform .15s cubic-bezier(.4,0,.2,1)" style-active="transform:scale(.97)">{{ threadBookL }}</button>
                <button onClick="{{ threadMsgGo }}" style="width:100%;height:48px;margin-top:9px;border:1.5px solid #E7E2DA;border-radius:14px;background:#fff;color:#1B1B1B;font-size:13px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ threadMsgL }}</button>
              </div>
            </div>
          </sc-if>

          <sc-if value="{{ isIntro }}" hint-placeholder-val="{{ false }}">
            <div style="min-height:100%;display:flex;flex-direction:column;justify-content:flex-end;padding:20px 0 0;box-sizing:border-box">
              <div style="background:#fff;border-radius:26px 26px 0 0;border-top:1.5px solid #E7E2DA;padding:10px 24px 30px">
                <div style="width:38px;height:4px;border-radius:2px;background:#E7E2DA;margin:0 auto 20px"></div>
                <div style="width:52px;height:52px;border-radius:16px;background:rgba(45,155,104,.1);color:#2D9B68;display:flex;align-items:center;justify-content:center;margin-bottom:16px">
                  <svg width="25" height="25" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 5h5l2 4-2.5 1.5a10 10 0 0 0 4.5 4.5L16 12l4 2v5a12 12 0 0 1-12-12z"></path></svg>
                </div>
                <div style="font-family:{{ ffDisp }};font-weight:700;font-size:22px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:10px">{{ introTitle }}</div>
                <div style="font-size:13.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:20px">{{ introBody }}</div>
                <sc-if value="{{ introAvailable }}" hint-placeholder-val="{{ true }}">
                  <button onClick="{{ introGo }}" style="width:100%;height:54px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};transition:transform .15s cubic-bezier(.4,0,.2,1)" style-active="transform:scale(.97)">{{ introCta }}</button>
                </sc-if>
                <sc-if value="{{ introUsed }}" hint-placeholder-val="{{ false }}">
                  <div style="background:#F5F2EC;border-radius:12px;padding:14px 15px;font-size:12.5px;font-weight:600;color:#716D67;line-height:{{ lhBody }}">{{ introUsedL }}</div>
                </sc-if>
                <button onClick="{{ gBack }}" style="width:100%;height:48px;margin-top:9px;border:none;background:transparent;color:#716D67;font-size:13px;font-weight:600;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.maybeLater }}</button>
              </div>
            </div>
          </sc-if>

          <sc-if value="{{ isTracks }}" hint-placeholder-val="{{ false }}">
            <div>
              <div style="background:#1B1B1B;padding:12px 14px 22px">
                <button onClick="{{ gBack }}" aria-label="{{ gBackL }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#fff;display:flex;align-items:center;justify-content:center;margin-bottom:4px">
                  <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                </button>
                <div style="padding:0 6px">
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:25px;line-height:{{ lhTight }};color:#fff;margin-bottom:8px">{{ tracksTitle }}</div>
                  <div style="font-size:13px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.7)">{{ tracksSub }}</div>
                </div>
              </div>
              <div style="padding:18px 20px 30px;display:grid;gap:12px">
                <sc-for list="{{ trackList }}" as="tr" hint-placeholder-count="3">
                  <button onClick="{{ tr.open }}" style="text-align:start;background:#fff;border:1.5px solid {{ tr.bd }};border-radius:20px;padding:18px;cursor:pointer;box-shadow:0 1px 3px rgba(0,0,0,.05);font-family:{{ ff }};letter-spacing:{{ ls }}">
                    <sc-if value="{{ tr.rec }}" hint-placeholder-val="{{ false }}">
                      <span style="display:inline-block;font-size:9px;font-weight:800;color:#fff;background:{{ grad }};padding:4px 8px;border-radius:999px;letter-spacing:{{ lsB }};margin-bottom:10px">{{ tr.recL }}</span>
                    </sc-if>
                    <span style="display:block;font-family:{{ ffDisp }};font-weight:700;font-size:19px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:7px">{{ tr.title }}</span>
                    <span style="display:block;font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:14px">{{ tr.blurb }}</span>
                    <span style="display:flex;align-items:center;justify-content:space-between;gap:10px;margin-bottom:7px">
                      <span style="font-size:11.5px;font-weight:700;color:#1B1B1B">{{ tr.countL }}</span>
                      <span style="font-size:11px;font-weight:600;color:#716D67;direction:ltr;unicode-bidi:isolate">{{ tr.hrs }}h · {{ tr.cpd }} CPD</span>
                    </span>
                    <span style="display:block;height:6px;border-radius:4px;background:#E7E2DA;overflow:hidden;margin-bottom:12px"><span style="display:block;height:100%;border-radius:4px;background:{{ grad }};width:{{ tr.pct }}%"></span></span>
                    <sc-if value="{{ tr.locked }}" hint-placeholder-val="{{ false }}">
                      <span style="display:flex;align-items:center;gap:8px;background:#F5F2EC;border-radius:10px;padding:10px 12px">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#716D67" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" style="flex:none"><rect x="5" y="11" width="14" height="9" rx="2"></rect><path d="M8 11V8a4 4 0 0 1 8 0v3"></path></svg>
                        <span style="font-size:11.5px;font-weight:700;color:#716D67">{{ tr.lockL }}</span>
                      </span>
                    </sc-if>
                    <sc-if value="{{ tr.rec }}" hint-placeholder-val="{{ false }}">
                      <span style="display:flex;align-items:center;gap:8px;background:rgba(45,155,104,.1);border-radius:10px;padding:10px 12px">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#2D9B68" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round" style="flex:none"><path d="M5 13l4.5 4.5L19 7"></path></svg>
                        <span style="font-size:11.5px;font-weight:600;color:#2D9B68;line-height:{{ lhSnug }}">{{ tr.certL }}</span>
                      </span>
                    </sc-if>
                  </button>
                </sc-for>
              </div>
            </div>
          </sc-if>

          <sc-if value="{{ isReview }}" hint-placeholder-val="{{ false }}">
            <div style="padding:12px 20px 30px">
              <button onClick="{{ gBack }}" aria-label="{{ gBackL }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center;margin:0 0 6px -10px">
                <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
              </button>
              <div style="display:flex;align-items:center;gap:18px;margin-bottom:18px">
                <div style="flex:none;position:relative;width:82px;height:82px">
                  <svg width="82" height="82" viewBox="0 0 36 36" style="transform:rotate(-90deg)">
                    <circle cx="18" cy="18" r="15.9" fill="none" stroke="#E7E2DA" stroke-width="3.4"></circle>
                    <circle cx="18" cy="18" r="15.9" fill="none" stroke="#FF6B1A" stroke-width="3.4" stroke-linecap="round" stroke-dasharray="{{ reviewRingDash }}"></circle>
                  </svg>
                  <div style="position:absolute;inset:0;display:flex;align-items:center;justify-content:center;font-size:15px;font-weight:800;color:#1B1B1B;direction:ltr">{{ reviewPct }}%</div>
                </div>
                <div style="min-width:0">
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:22px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:6px">{{ reviewTitle }}</div>
                  <div style="display:inline-flex;align-items:center;gap:6px;background:rgba(255,170,24,.12);border-radius:999px;padding:5px 11px">
                    <span style="width:6px;height:6px;border-radius:50%;background:#FFAA18"></span>
                    <span style="font-size:11px;font-weight:700;color:#1B1B1B">{{ reviewStreakL }}</span>
                  </div>
                </div>
              </div>
              <div style="font-size:13.5px;font-weight:600;color:#1B1B1B;margin-bottom:4px">{{ reviewDueL }}</div>
              <div style="font-size:12px;font-weight:500;color:#716D67;margin-bottom:18px">{{ reviewedL }}</div>
              <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:6px 16px;margin-bottom:18px">
                <sc-for list="{{ reviewDecks }}" as="d" hint-placeholder-count="3">
                  <div style="display:flex;align-items:center;justify-content:space-between;gap:12px;padding:14px 0;border-bottom:1px solid #E7E2DA">
                    <span style="font-size:13px;font-weight:500;color:#1B1B1B">{{ d.n }}</span>
                    <span style="flex:none;font-size:11px;font-weight:700;color:#FF6B1A;background:rgba(255,107,26,.08);padding:5px 10px;border-radius:999px">{{ d.dueL }}</span>
                  </div>
                </sc-for>
              </div>
              <button onClick="{{ reviewStart }}" style="width:100%;height:54px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};transition:transform .15s cubic-bezier(.4,0,.2,1)" style-active="transform:scale(.97)">{{ reviewStartL }}</button>
              <div style="font-size:11.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-top:14px">{{ reviewNoteL }}</div>
            </div>
          </sc-if>

          <sc-if value="{{ isPlan }}" hint-placeholder-val="{{ false }}">
            <div>
              <div style="background:#1B1B1B;padding:12px 14px 24px">
                <button onClick="{{ gBack }}" aria-label="{{ gBackL }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#fff;display:flex;align-items:center;justify-content:center;margin-bottom:4px">
                  <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                </button>
                <div style="padding:0 6px">
                  <div style="display:flex;align-items:flex-end;justify-content:space-between;gap:12px;margin-bottom:10px">
                    <div style="font-family:{{ ffDisp }};font-weight:700;font-size:25px;line-height:{{ lhTight }};color:#fff">{{ planTitle }}</div>
                    <div style="flex:none;font-family:{{ ffDisp }};font-weight:700;font-size:22px;color:#FFC62E;direction:ltr">{{ planPctL }}%</div>
                  </div>
                  <div style="height:6px;border-radius:4px;background:rgba(255,255,255,.14);overflow:hidden;margin-bottom:8px"><div style="height:100%;border-radius:4px;background:{{ grad }};width:{{ planPctL }}%"></div></div>
                  <div style="font-size:11.5px;font-weight:600;color:rgba(255,255,255,.6);margin-bottom:12px;direction:ltr;unicode-bidi:isolate;text-align:start">{{ planCountL }}</div>
                  <div style="font-size:13px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.7)">{{ planSub }}</div>
                </div>
              </div>
              <div style="padding:18px 20px 30px;display:grid;gap:12px">
                <sc-for list="{{ planStages }}" as="st" hint-placeholder-count="5">
                  <div style="background:#fff;border:1.5px solid {{ st.bd }};border-radius:20px;padding:16px;box-shadow:0 1px 3px rgba(0,0,0,.05)">
                    <div style="display:flex;align-items:center;gap:11px;margin-bottom:11px">
                      <span style="flex:none;width:28px;height:28px;border-radius:999px;background:{{ st.markerBg }};color:{{ st.markerFg }};font-size:12.5px;font-weight:800;display:flex;align-items:center;justify-content:center">{{ st.n }}</span>
                      <span style="flex:1;min-width:0;font-size:14.5px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ st.title }}</span>
                      <span style="flex:none;font-size:9px;font-weight:800;color:{{ st.badgeFg }};background:{{ st.badgeBg }};padding:4px 8px;border-radius:999px;letter-spacing:{{ lsB }}">{{ st.badge }}</span>
                    </div>
                    <div style="display:flex;align-items:center;justify-content:space-between;gap:10px;margin-bottom:12px">
                      <span style="font-size:11.5px;font-weight:700;color:#FF6B1A">{{ st.when }}</span>
                      <span style="font-size:11px;font-weight:700;color:#716D67;direction:ltr;unicode-bidi:isolate">{{ st.countL }}</span>
                    </div>
                    <div style="display:grid;gap:7px;margin-bottom:12px">
                      <sc-for list="{{ st.tasks }}" as="tk" hint-placeholder-count="3">
                        <button onClick="{{ tk.toggle }}" style="display:flex;align-items:flex-start;gap:10px;min-height:44px;background:#F5F2EC;border:none;border-radius:11px;padding:11px 12px;cursor:pointer;text-align:start;font-family:{{ ff }};letter-spacing:{{ ls }}">
                          <span style="flex:none;width:20px;height:20px;border-radius:6px;border:1.5px solid {{ tk.boxBd }};background:{{ tk.boxBg }};display:flex;align-items:center;justify-content:center;margin-top:1px">
                            <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="3.6" stroke-linecap="round" stroke-linejoin="round"><path d="M5 13l4.5 4.5L19 7"></path></svg>
                          </span>
                          <span style="font-size:12px;font-weight:500;line-height:{{ lhSnug }};color:{{ tk.fg }};text-decoration:{{ tk.deco }}">{{ tk.l }}</span>
                        </button>
                      </sc-for>
                    </div>
                    <div style="font-size:10px;font-weight:800;color:#716D67;letter-spacing:{{ lsE }};margin-bottom:5px">{{ planDocsL }}</div>
                    <div style="font-size:11.5px;font-weight:500;line-height:{{ lhBody }};color:#716D67">{{ st.docs }}</div>
                  </div>
                </sc-for>
              </div>
            </div>
          </sc-if>

          <sc-if value="{{ isAfford }}" hint-placeholder-val="{{ false }}">
            <div>
              <div style="background:#1B1B1B;padding:12px 14px 24px">
                <button onClick="{{ gBack }}" aria-label="{{ gBackL }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#fff;display:flex;align-items:center;justify-content:center;margin-bottom:4px">
                  <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                </button>
                <div style="padding:0 6px">
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:24px;line-height:{{ lhTight }};color:#fff;margin-bottom:10px">{{ affordTitle }}</div>
                  <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.68)">{{ affordSub }}</div>
                </div>
              </div>
              <div style="padding:18px 20px 30px">
                <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:18px;margin-bottom:16px">
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:28px;line-height:1.2;color:#1B1B1B;direction:ltr;unicode-bidi:isolate;text-align:start;margin-bottom:6px">{{ affordTotalL }}</div>
                  <div style="font-size:12px;font-weight:500;color:#716D67">{{ affordSavingsL }}</div>
                </div>
                <div style="font-size:10px;font-weight:800;color:#716D67;letter-spacing:{{ lsE }};margin-bottom:9px">{{ affordRateL }}</div>
                <div style="display:flex;gap:8px;margin-bottom:16px">
                  <sc-for list="{{ rateOpts }}" as="ro" hint-placeholder-count="3">
                    <button onClick="{{ ro.pick }}" style="flex:1;min-height:44px;border-radius:12px;border:1.5px solid {{ ro.bd }};background:{{ ro.bg }};color:{{ ro.fg }};font-size:11.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};direction:ltr;unicode-bidi:isolate">{{ ro.label }}</button>
                  </sc-for>
                </div>
                <button onClick="{{ toggleSchol }}" style="width:100%;display:flex;align-items:center;justify-content:space-between;gap:12px;min-height:52px;background:#fff;border:1.5px solid #E7E2DA;border-radius:14px;padding:12px 15px;cursor:pointer;text-align:start;font-family:{{ ff }};letter-spacing:{{ ls }};margin-bottom:18px">
                  <span style="font-size:12.5px;font-weight:600;color:#1B1B1B;line-height:{{ lhSnug }}">{{ affordScholL }}</span>
                  <span style="flex:none;width:42px;height:25px;border-radius:999px;background:{{ scholTrackBg }};display:flex;align-items:center;padding:2px;box-sizing:border-box">
                    <span style="width:21px;height:21px;border-radius:999px;background:#fff;margin-inline-start:{{ scholKnob }}"></span>
                  </span>
                </button>
                <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:4px 14px;margin-bottom:16px">
                  <div style="display:flex;gap:8px;padding:11px 0;border-bottom:1.5px solid #E7E2DA">
                    <span style="flex:1;font-size:9.5px;font-weight:800;color:#716D67;letter-spacing:{{ lsB }}">{{ affordColCost }}</span>
                    <span style="flex:none;width:82px;font-size:9.5px;font-weight:800;color:#716D67;letter-spacing:{{ lsB }};text-align:end">{{ affordColCum }}</span>
                    <span style="flex:none;width:58px;font-size:9.5px;font-weight:800;color:#716D67;letter-spacing:{{ lsB }};text-align:end">{{ affordColBy }}</span>
                  </div>
                  <sc-for list="{{ affordRows }}" as="a" hint-placeholder-count="6">
                    <div style="display:flex;gap:8px;align-items:flex-start;padding:12px 0;border-bottom:1px solid #F1ECE4">
                      <span style="flex:1;min-width:0">
                        <span style="display:block;font-size:12px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ a.l }}</span>
                        <span style="display:block;font-size:10.5px;font-weight:500;color:#716D67;margin-top:2px;direction:ltr;unicode-bidi:isolate;text-align:start">{{ a.egp }}</span>
                      </span>
                      <span style="flex:none;width:82px;font-size:11px;font-weight:700;color:#1B1B1B;text-align:end;direction:ltr;unicode-bidi:isolate">{{ a.cumL }}</span>
                      <span style="flex:none;width:58px;font-size:10.5px;font-weight:700;color:#FF6B1A;text-align:end;direction:ltr;unicode-bidi:isolate">{{ a.by }}</span>
                    </div>
                  </sc-for>
                </div>
                <div style="background:#1B1B1B;border-radius:16px;padding:16px 18px;font-size:13px;font-weight:600;line-height:{{ lhBody }};color:#fff">{{ affordVerdictL }}</div>
              </div>
            </div>
          </sc-if>

          <sc-if value="{{ isCv }}" hint-placeholder-val="{{ false }}">
            <div>
              <div style="background:#1B1B1B;padding:12px 14px 24px">
                <button onClick="{{ gBack }}" aria-label="{{ gBackL }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#fff;display:flex;align-items:center;justify-content:center;margin-bottom:6px">
                  <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                </button>
                <div style="padding:0 6px">
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:24px;line-height:{{ lhTight }};color:#fff;margin-bottom:9px">{{ cvTitle }}</div>
                  <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.68)">{{ cvSub }}</div>
                </div>
              </div>
              <div style="padding:18px 20px 30px">
                <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:20px;margin-bottom:18px;box-shadow:0 6px 24px rgba(0,0,0,.06)">
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:21px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:5px">{{ cvName }}</div>
                  <div style="font-size:12px;font-weight:500;color:#716D67;padding-bottom:16px;border-bottom:1.5px solid #E7E2DA;margin-bottom:16px">{{ cvRole }}</div>
                  <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px">
                    <sc-for list="{{ cvStats }}" as="s" hint-placeholder-count="4">
                      <div>
                        <div style="font-family:{{ ffDisp }};font-weight:700;font-size:22px;line-height:1;color:#1B1B1B;direction:ltr">{{ s.n }}</div>
                        <div style="font-size:11px;font-weight:600;color:#716D67;margin-top:4px">{{ s.l }}</div>
                      </div>
                    </sc-for>
                  </div>
                </div>
                <sc-if value="{{ cvAsk }}" hint-placeholder-val="{{ true }}">
                  <div>
                    <div style="font-family:{{ ffDisp }};font-weight:700;font-size:21px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:9px">{{ cvAskTitle }}</div>
                    <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:18px">{{ cvAskSub }}</div>
                    <button onClick="{{ cvPickUp }}" style="width:100%;text-align:start;border:none;border-radius:20px;padding:20px;cursor:pointer;background:{{ grad }};box-shadow:0 6px 24px rgba(255,107,26,.3);font-family:{{ ff }};letter-spacing:{{ ls }};margin-bottom:10px">
                      <span style="display:block;font-size:15px;font-weight:700;color:#fff;line-height:{{ lhSnug }};margin-bottom:7px">{{ cvPickUpL }}</span>
                      <span style="display:block;font-size:12px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.88)">{{ cvPickUpSub }}</span>
                    </button>
                    <button onClick="{{ cvPickGen }}" style="width:100%;text-align:start;background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:20px;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">
                      <span style="display:block;font-size:15px;font-weight:700;color:#1B1B1B;line-height:{{ lhSnug }};margin-bottom:7px">{{ cvPickGenL }}</span>
                      <span style="display:block;font-size:12px;font-weight:400;line-height:{{ lhBody }};color:#716D67">{{ cvPickGenSub }}</span>
                    </button>
                  </div>
                </sc-if>
                <sc-if value="{{ cvNotAsk }}" hint-placeholder-val="{{ false }}">
                  <button onClick="{{ cvChange }}" style="min-height:40px;margin-bottom:14px;padding:0;background:none;border:none;cursor:pointer;color:#FF6B1A;font-size:12px;font-weight:700;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ cvChangeL }}</button>
                </sc-if>
                <sc-if value="{{ cvIsUp }}" hint-placeholder-val="{{ false }}">
                  <div>
                    <div style="font-family:{{ ffDisp }};font-weight:700;font-size:19px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:8px">{{ cvUpTitle }}</div>
                    <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:16px">{{ cvUpBody }}</div>
                    <sc-if value="{{ cvUpNoFile }}" hint-placeholder-val="{{ true }}">
                      <button onClick="{{ cvUpPick }}" style="width:100%;background:#fff;border:1.5px dashed #E7E2DA;border-radius:18px;padding:26px 18px;cursor:pointer;text-align:center;font-family:{{ ff }};letter-spacing:{{ ls }};margin-bottom:14px">
                        <span style="display:flex;justify-content:center;margin-bottom:12px"><svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="#FF6B1A" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><path d="M12 17V6"></path><path d="M7.5 10.5L12 6l4.5 4.5"></path><path d="M5 19h14"></path></svg></span>
                        <span style="display:block;font-size:13.5px;font-weight:700;color:#1B1B1B;margin-bottom:5px">{{ cvUpBrowseL }}</span>
                        <span style="display:block;font-size:11px;font-weight:500;color:#716D67;direction:ltr;unicode-bidi:isolate">{{ cvUpHintL }}</span>
                      </button>
                    </sc-if>
                    <sc-if value="{{ cvUpHasFile }}" hint-placeholder-val="{{ false }}">
                      <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:16px;margin-bottom:14px">
                        <div style="display:flex;align-items:center;gap:12px;margin-bottom:12px">
                          <span style="flex:none;width:40px;height:44px;border-radius:8px;background:rgba(255,45,50,.08);color:#FF2D32;display:flex;align-items:center;justify-content:center;font-size:9px;font-weight:800">PDF</span>
                          <span style="flex:1;min-width:0">
                            <span style="display:block;font-size:12.5px;font-weight:700;color:#1B1B1B;direction:ltr;unicode-bidi:isolate;text-align:start;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">{{ cvUpFileName }}</span>
                            <span style="display:block;font-size:10.5px;font-weight:500;color:#716D67;margin-top:3px">{{ cvUpFileMeta }}</span>
                          </span>
                        </div>
                        <div style="display:flex;align-items:center;gap:7px;background:rgba(45,155,104,.1);border-radius:9px;padding:9px 11px;margin-bottom:12px">
                          <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#2D9B68" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round" style="flex:none"><path d="M5 13l4.5 4.5L19 7"></path></svg>
                          <span style="font-size:11px;font-weight:700;color:#2D9B68">{{ cvUpLiveL }}</span>
                        </div>
                        <div style="display:flex;gap:8px">
                          <button onClick="{{ cvUpPick }}" style="flex:1;min-height:44px;border:1.5px solid #E7E2DA;border-radius:11px;background:#fff;color:#1B1B1B;font-size:11.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ cvUpReplaceL }}</button>
                          <button onClick="{{ cvUpRemove }}" style="flex:1;min-height:44px;border:1.5px solid #E7E2DA;border-radius:11px;background:#fff;color:#FF2D32;font-size:11.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ cvUpRemoveL }}</button>
                        </div>
                      </div>
                    </sc-if>
                    <button onClick="{{ toggleCvAttach }}" style="width:100%;display:flex;align-items:center;justify-content:space-between;gap:12px;min-height:56px;background:#fff;border:1.5px solid #E7E2DA;border-radius:14px;padding:13px 15px;cursor:pointer;text-align:start;font-family:{{ ff }};letter-spacing:{{ ls }};margin-bottom:14px">
                      <span style="font-size:12.5px;font-weight:600;color:#1B1B1B;line-height:{{ lhSnug }}">{{ cvUpAttachL }}</span>
                      <span style="flex:none;width:42px;height:25px;border-radius:999px;background:{{ cvUpAttachTrackBg }};display:flex;align-items:center;padding:2px;box-sizing:border-box">
                        <span style="width:21px;height:21px;border-radius:999px;background:#fff;margin-inline-start:{{ cvUpAttachKnob }}"></span>
                      </span>
                    </button>
                    <div style="background:rgba(255,170,24,.1);border-radius:12px;padding:13px 15px;font-size:11.5px;font-weight:500;line-height:{{ lhBody }};color:#1B1B1B">{{ cvUpWarnL }}</div>
                  </div>
                </sc-if>
                <sc-if value="{{ cvIsGen }}" hint-placeholder-val="{{ true }}">
                <div>
                <div style="font-size:10px;font-weight:800;color:#716D67;letter-spacing:{{ lsE }};margin-bottom:9px">{{ cvDetailsL }}</div>

                <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:16px;margin-bottom:10px">
                  <div style="display:flex;align-items:center;justify-content:space-between;gap:10px;margin-bottom:9px">
                    <span style="font-size:12.5px;font-weight:700;color:#1B1B1B">{{ cvStatementL }}</span>
                    <button onClick="{{ cvEditStatement }}" style="flex:none;min-height:32px;padding:0 12px;border:1.5px solid #E7E2DA;border-radius:9px;background:#fff;color:#FF6B1A;font-size:11px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ cvEditL }}</button>
                  </div>
                  <div style="background:#F5F2EC;border-radius:12px;padding:13px 14px;font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#1B1B1B;margin-bottom:8px">{{ cvStatement }}</div>
                  <div style="font-size:10.5px;font-weight:600;color:#716D67;direction:ltr;unicode-bidi:isolate;text-align:start">{{ cvStatementCount }}</div>
                </div>

                <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:16px;margin-bottom:10px">
                  <div style="font-size:12.5px;font-weight:700;color:#1B1B1B;margin-bottom:12px">{{ cvExpL }}</div>
                  <div style="display:grid;gap:10px;margin-bottom:12px">
                    <sc-for list="{{ expRows }}" as="e" hint-placeholder-count="2">
                      <div style="border-inline-start:2.5px solid #FF6B1A;padding-inline-start:13px">
                        <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:10px">
                          <div style="min-width:0">
                            <div style="font-size:13px;font-weight:700;line-height:{{ lhSnug }};color:#1B1B1B">{{ e.role }}</div>
                            <div style="font-size:11.5px;font-weight:500;color:#716D67;margin-top:2px">{{ e.place }}</div>
                            <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-top:4px;direction:ltr;unicode-bidi:isolate;text-align:start">{{ e.dates }}</div>
                          </div>
                          <button onClick="{{ e.remove }}" aria-label="{{ cvRemoveL }}" style="flex:none;width:34px;height:34px;border-radius:9px;border:none;background:#F5F2EC;color:#716D67;cursor:pointer;display:flex;align-items:center;justify-content:center;margin-top:-2px">
                            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round"><path d="M6 6l12 12M18 6L6 18"></path></svg>
                          </button>
                        </div>
                        <div style="font-size:11.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-top:6px">{{ e.blurb }}</div>
                      </div>
                    </sc-for>
                  </div>
                  <button onClick="{{ cvAddExp }}" style="width:100%;min-height:44px;border:1.5px dashed #E7E2DA;border-radius:12px;background:#fff;color:#FF6B1A;font-size:12px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">+ {{ cvAddExpL }}</button>
                </div>

                <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:16px;margin-bottom:10px">
                  <div style="font-size:12.5px;font-weight:700;color:#1B1B1B;margin-bottom:10px">{{ cvEduL }}</div>
                  <div style="border-inline-start:2.5px solid #E7E2DA;padding-inline-start:13px">
                    <div style="font-size:13px;font-weight:700;line-height:{{ lhSnug }};color:#1B1B1B">{{ cvEduDeg }}</div>
                    <div style="font-size:11.5px;font-weight:500;color:#716D67;margin-top:3px;direction:ltr;unicode-bidi:isolate;text-align:start">{{ cvEduPlace }}</div>
                  </div>
                </div>

                <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:16px;margin-bottom:10px">
                  <div style="font-size:12.5px;font-weight:700;color:#1B1B1B;margin-bottom:5px">{{ cvSkillsL }}</div>
                  <div style="font-size:11px;font-weight:500;color:#716D67;margin-bottom:12px;line-height:{{ lhSnug }}">{{ cvSkillsHint }}</div>
                  <div style="display:flex;flex-wrap:wrap;gap:7px">
                    <sc-for list="{{ skillChips }}" as="sk" hint-placeholder-count="12">
                      <button onClick="{{ sk.toggle }}" style="min-height:38px;border-radius:999px;padding:8px 13px;cursor:pointer;background:{{ sk.bg }};color:{{ sk.fg }};border:1.5px solid {{ sk.bd }};font-size:11.5px;font-weight:600;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ sk.label }}</button>
                    </sc-for>
                  </div>
                </div>

                <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:16px;margin-bottom:10px">
                  <div style="font-size:12.5px;font-weight:700;color:#1B1B1B;margin-bottom:12px">{{ cvLangsL }}</div>
                  <div style="display:grid;gap:8px">
                    <sc-for list="{{ langChips }}" as="lg" hint-placeholder-count="4">
                      <button onClick="{{ lg.toggle }}" style="display:flex;align-items:center;gap:11px;min-height:48px;background:{{ lg.bg }};border:1.5px solid {{ lg.bd }};border-radius:12px;padding:10px 13px;cursor:pointer;text-align:start;font-family:{{ ff }};letter-spacing:{{ ls }}">
                        <span style="flex:none;width:20px;height:20px;border-radius:6px;border:1.5px solid {{ lg.boxBd }};background:{{ lg.boxBg }};display:flex;align-items:center;justify-content:center">
                          <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="3.6" stroke-linecap="round" stroke-linejoin="round"><path d="M5 13l4.5 4.5L19 7"></path></svg>
                        </span>
                        <span style="flex:1;min-width:0">
                          <span style="display:block;font-size:12.5px;font-weight:600;color:{{ lg.fg }}">{{ lg.n }}</span>
                          <span style="display:block;font-size:10.5px;font-weight:500;color:#716D67;margin-top:2px">{{ lg.lv }}</span>
                        </span>
                      </button>
                    </sc-for>
                  </div>
                </div>

                <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:16px;margin-bottom:18px">
                  <div style="font-size:12.5px;font-weight:700;color:#1B1B1B;margin-bottom:6px">{{ cvMemberL }}</div>
                  <div style="font-size:11.5px;font-weight:500;line-height:{{ lhBody }};color:#716D67">{{ cvMemberV }}</div>
                </div>

                <div style="font-size:10px;font-weight:800;color:#716D67;letter-spacing:{{ lsE }};margin-bottom:9px">{{ cvSectionsL }}</div>
                <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:4px 16px;margin-bottom:18px">
                  <sc-for list="{{ cvRows }}" as="r" hint-placeholder-count="5">
                    <button onClick="{{ r.toggle }}" style="width:100%;display:flex;align-items:center;justify-content:space-between;gap:12px;min-height:52px;background:none;border:none;border-bottom:1px solid #E7E2DA;cursor:pointer;text-align:start;padding:0;font-family:{{ ff }};letter-spacing:{{ ls }}">
                      <span style="font-size:12.5px;font-weight:500;color:#1B1B1B">{{ r.l }}</span>
                      <span style="flex:none;width:40px;height:24px;border-radius:999px;background:{{ r.trackBg }};display:flex;align-items:center;padding:2px;box-sizing:border-box">
                        <span style="width:20px;height:20px;border-radius:999px;background:#fff;margin-inline-start:{{ r.knob }}"></span>
                      </span>
                    </button>
                  </sc-for>
                </div>
                </div>
                </sc-if>
                <sc-if value="{{ cvIsGen }}" hint-placeholder-val="{{ false }}">
                  <div>
                    <div style="background:rgba(255,170,24,.1);border-radius:12px;padding:13px 15px;font-size:11.5px;font-weight:500;line-height:{{ lhBody }};color:#1B1B1B;margin-bottom:12px">{{ cvGenNoteL }}</div>
                    <button onClick="{{ cvExport }}" style="width:100%;height:54px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};transition:transform .15s cubic-bezier(.4,0,.2,1)" style-active="transform:scale(.97)">{{ cvExportL }}</button>
                  </div>
                </sc-if>
                <sc-if value="{{ pmLocked }}" hint-placeholder-val="{{ true }}">
                  <div style="display:flex;align-items:center;gap:9px;background:#F5F2EC;border-radius:12px;padding:12px 14px;margin-top:10px">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#716D67" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" style="flex:none"><rect x="5" y="11" width="14" height="9" rx="2"></rect><path d="M8 11V8a4 4 0 0 1 8 0v3"></path></svg>
                    <span style="font-size:11.5px;font-weight:700;color:#716D67">{{ pmLockL }}</span>
                  </div>
                </sc-if>
              </div>
            </div>
          </sc-if>

          <sc-if value="{{ isCpd }}" hint-placeholder-val="{{ false }}">
            <div style="padding:12px 20px 30px">
              <button onClick="{{ gBack }}" aria-label="{{ gBackL }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center;margin:0 0 6px -10px">
                <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
              </button>
              <div style="font-family:{{ ffDisp }};font-weight:700;font-size:22px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:6px">{{ cpdTitle }}</div>
              <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:16px">{{ cpdSub }}</div>
              <div style="display:flex;gap:8px;margin-bottom:16px">
                <sc-for list="{{ cpdYears }}" as="y" hint-placeholder-count="2">
                  <button onClick="{{ y.pick }}" style="min-height:44px;padding:0 18px;border-radius:12px;border:1.5px solid {{ y.bd }};background:{{ y.bg }};color:{{ y.fg }};font-size:12.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};direction:ltr">{{ y.label }}</button>
                </sc-for>
              </div>
              <div style="background:#1B1B1B;border-radius:20px;padding:20px;margin-bottom:16px">
                <div style="display:flex;align-items:baseline;gap:8px;margin-bottom:12px">
                  <span style="font-family:{{ ffDisp }};font-weight:700;font-size:38px;line-height:1;color:#fff;direction:ltr">{{ cpdTotalL }}</span>
                  <span style="font-size:12px;font-weight:600;color:rgba(255,255,255,.6)">{{ cpdTargetL }}</span>
                </div>
                <div style="height:7px;border-radius:4px;background:rgba(255,255,255,.14);overflow:hidden"><div style="height:100%;border-radius:4px;background:{{ grad }};width:{{ cpdBarPct }}%"></div></div>
              </div>
              <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:4px 16px;margin-bottom:16px">
                <sc-for list="{{ cpdRows }}" as="c" hint-placeholder-count="3">
                  <div style="display:flex;gap:12px;align-items:flex-start;padding:14px 0;border-bottom:1px solid #E7E2DA">
                    <span style="flex:1;min-width:0">
                      <span style="display:block;font-size:12.5px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ c.n }}</span>
                      <span style="display:block;font-size:10.5px;font-weight:500;color:#716D67;margin-top:3px">{{ c.d }} · {{ c.by }}</span>
                    </span>
                    <span style="flex:none;font-size:11px;font-weight:800;color:#1B1B1B;background:#FFC62E;padding:5px 9px;border-radius:999px;direction:ltr;unicode-bidi:isolate">{{ c.p }} {{ cpdColPts }}</span>
                  </div>
                </sc-for>
              </div>
              <button onClick="{{ cpdExport }}" style="width:100%;height:52px;border:1.5px solid #E7E2DA;border-radius:14px;background:#fff;color:#1B1B1B;font-size:13px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ cpdExportL }}</button>
            </div>
          </sc-if>

          <sc-if value="{{ isSys }}" hint-placeholder-val="{{ false }}">
            <div style="min-height:100%;display:flex;flex-direction:column;padding:16px 24px 30px;box-sizing:border-box">
              <div style="display:flex;justify-content:space-between;align-items:center;min-height:44px">
                <button onClick="{{ gBack }}" aria-label="{{ gBackL }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center;margin-inline-start:-10px">
                  <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                </button>
                <sc-if value="{{ sysIsBlocking }}" hint-placeholder-val="{{ false }}">
                  <span style="font-size:9.5px;font-weight:700;color:#716D67;background:#F5F2EC;padding:5px 9px;border-radius:999px;line-height:1.4">{{ sysBlockingL }}</span>
                </sc-if>
              </div>
              <div style="flex:1;display:flex;flex-direction:column;justify-content:center;padding:24px 0 32px">
                <div style="width:62px;height:62px;border-radius:18px;background:{{ sys.bg }};display:flex;align-items:center;justify-content:center;margin-bottom:20px">
                  <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="{{ sys.tone }}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <sc-for list="{{ sys.paths }}" as="p" hint-placeholder-count="2">
                      <path d="{{ p }}"></path>
                    </sc-for>
                  </svg>
                </div>
                <div style="font-family:{{ ffDisp }};font-weight:700;font-size:24px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:10px">{{ sys.title }}</div>
                <div style="font-size:13.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67">{{ sys.body }}</div>
              </div>
              <button onClick="{{ sys.p1go }}" style="width:100%;height:54px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};transition:transform .15s cubic-bezier(.4,0,.2,1)" style-active="transform:scale(.97)">{{ sys.p1 }}</button>
              <sc-if value="{{ sysHasP2 }}" hint-placeholder-val="{{ true }}">
                <button onClick="{{ sys.p2go }}" style="width:100%;height:48px;margin-top:9px;border:none;background:transparent;color:#716D67;font-size:13px;font-weight:600;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ sys.p2 }}</button>
              </sc-if>
            </div>
          </sc-if>

          <sc-if value="{{ isChecklist }}" hint-placeholder-val="{{ false }}">
            <div style="padding:12px 20px 30px">
              <button onClick="{{ gBack }}" aria-label="{{ gBackL }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center;margin:0 0 6px -10px">
                <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
              </button>
              <div style="display:flex;align-items:center;gap:18px;margin-bottom:18px">
                <div style="flex:none;position:relative;width:74px;height:74px">
                  <svg width="74" height="74" viewBox="0 0 36 36" style="transform:rotate(-90deg)">
                    <circle cx="18" cy="18" r="15.9" fill="none" stroke="#E7E2DA" stroke-width="3.4"></circle>
                    <circle cx="18" cy="18" r="15.9" fill="none" stroke="#FF6B1A" stroke-width="3.4" stroke-linecap="round" stroke-dasharray="{{ ringDash }}"></circle>
                  </svg>
                  <div style="position:absolute;inset:0;display:flex;align-items:center;justify-content:center;font-size:15px;font-weight:800;color:#1B1B1B;direction:ltr">{{ ringPct }}%</div>
                </div>
                <div style="min-width:0">
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:21px;line-height:{{ lhTight }};color:#1B1B1B">{{ checkTitle }}</div>
                  <div style="font-size:11.5px;font-weight:600;color:#716D67;margin-top:5px">{{ doneCountL }}</div>
                </div>
              </div>
              <div style="font-size:13px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:20px">{{ checkSub }}</div>
              <div style="display:grid;gap:10px;margin-bottom:20px">
                <sc-for list="{{ checkItems }}" as="ci" hint-placeholder-count="4">
                  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:14px 16px;display:flex;align-items:center;gap:13px">
                    <button onClick="{{ ci.toggle }}" aria-label="{{ ci.label }}" style="flex:none;width:26px;height:26px;border-radius:999px;border:1.5px solid {{ ci.boxBd }};background:{{ ci.boxBg }};cursor:pointer;display:flex;align-items:center;justify-content:center;padding:0">
                      <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="3.4" stroke-linecap="round" stroke-linejoin="round"><path d="M5 13l4.5 4.5L19 7"></path></svg>
                    </button>
                    <span style="flex:1;min-width:0">
                      <span style="display:block;font-size:13.5px;font-weight:600;line-height:{{ lhSnug }};color:{{ ci.fg }};text-decoration:{{ ci.deco }}">{{ ci.label }}</span>
                      <span style="display:block;font-size:11.5px;font-weight:400;color:#716D67;margin-top:2px">{{ ci.sub }}</span>
                    </span>
                    <button onClick="{{ ci.go }}" aria-label="{{ ci.label }}" style="flex:none;width:36px;height:36px;background:none;border:none;cursor:pointer;color:#FF6B1A;display:flex;align-items:center;justify-content:center">
                      <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M9 5l7 7-7 7"></path></svg>
                    </button>
                  </div>
                </sc-for>
              </div>
              <button onClick="{{ checkDismiss }}" style="width:100%;height:48px;border:1.5px solid #E7E2DA;border-radius:14px;background:#fff;color:#1B1B1B;font-size:13px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ checkDismissL }}</button>
            </div>
          </sc-if>

          <sc-if value="{{ isVerifyEmail }}" hint-placeholder-val="{{ false }}">
            <div style="padding:12px 24px 30px">
              <button onClick="{{ gBack }}" aria-label="{{ gBackL }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center;margin:0 0 10px -10px">
                <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
              </button>
              <div style="font-family:{{ ffDisp }};font-weight:700;font-size:24px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:10px">{{ veTitle }}</div>
              <div style="font-size:13.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:26px">{{ veBody }}</div>
              <div style="display:flex;gap:8px;margin-bottom:22px;direction:ltr">
                <sc-for list="{{ veCode }}" as="d" hint-placeholder-count="6">
                  <div style="flex:1;height:56px;border:1.5px solid #E7E2DA;border-radius:12px;background:#fff;display:flex;align-items:center;justify-content:center;font-size:20px;font-weight:700;color:#1B1B1B">{{ d }}</div>
                </sc-for>
              </div>
              <button onClick="{{ veVerify }}" style="width:100%;height:54px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};transition:transform .15s cubic-bezier(.4,0,.2,1)" style-active="transform:scale(.97)">{{ veVerifyL }}</button>
              <sc-if value="{{ veResendWait }}" hint-placeholder-val="{{ true }}">
                <div style="text-align:center;margin-top:18px;font-size:12.5px;font-weight:600;color:#716D67;direction:ltr;unicode-bidi:isolate">{{ veWaitL }}</div>
              </sc-if>
              <sc-if value="{{ veResendReady }}" hint-placeholder-val="{{ false }}">
                <button onClick="{{ veResend }}" style="width:100%;height:46px;margin-top:12px;border:none;background:transparent;color:#FF6B1A;font-size:13px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ veResendL }}</button>
              </sc-if>
              <button onClick="{{ ggLater }}" style="width:100%;height:44px;margin-top:4px;border:none;background:transparent;color:#716D67;font-size:12.5px;font-weight:600;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ veChangeL }}</button>
            </div>
          </sc-if>

          <sc-if value="{{ isResetPw }}" hint-placeholder-val="{{ false }}">
            <div style="padding:12px 24px 30px">
              <button onClick="{{ gBack }}" aria-label="{{ gBackL }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center;margin:0 0 10px -10px">
                <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
              </button>
              <div style="font-family:{{ ffDisp }};font-weight:700;font-size:24px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:10px">{{ rpTitle }}</div>
              <div style="font-size:13.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:22px">{{ rpBody }}</div>
              <div style="height:50px;border:1.5px solid #E7E2DA;border-radius:12px;background:#fff;display:flex;align-items:center;padding:0 14px;font-size:15px;color:#1B1B1B;margin-bottom:10px;letter-spacing:.28em">••••••••••</div>
              <div style="height:50px;border:1.5px solid #E7E2DA;border-radius:12px;background:#fff;display:flex;align-items:center;padding:0 14px;font-size:15px;color:#1B1B1B;margin-bottom:18px;letter-spacing:.28em">••••••••••</div>
              <div style="display:grid;gap:7px;margin-bottom:24px">
                <sc-for list="{{ rpRules }}" as="r" hint-placeholder-count="3">
                  <div style="display:flex;align-items:center;gap:9px;background:{{ r.bg }};border-radius:10px;padding:10px 12px">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="{{ r.fg }}" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" style="flex:none"><path d="M5 13l4.5 4.5L19 7"></path></svg>
                    <span style="font-size:12px;font-weight:600;color:{{ r.fg }};line-height:{{ lhSnug }}">{{ r.l }}</span>
                  </div>
                </sc-for>
              </div>
              <button onClick="{{ rpSave }}" style="width:100%;height:54px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};transition:transform .15s cubic-bezier(.4,0,.2,1)" style-active="transform:scale(.97)">{{ rpSaveL }}</button>
            </div>
          </sc-if>

          <sc-if value="{{ isGuestGate }}" hint-placeholder-val="{{ false }}">
            <div>
              <div style="background:#1B1B1B;padding:22px 24px 26px">
                <div style="font-size:10.5px;font-weight:700;color:#FFC62E;line-height:1.4;margin-bottom:10px">{{ ggEyebrow }}</div>
                <div style="font-family:{{ ffDisp }};font-weight:700;font-size:25px;line-height:{{ lhTight }};color:#fff">{{ ggTitle }}</div>
              </div>
              <div style="padding:22px 24px 30px">
                <div style="display:grid;gap:9px;margin-bottom:20px">
                  <sc-for list="{{ ggPeek }}" as="s" hint-placeholder-count="4">
                    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:14px 16px;display:flex;align-items:center;gap:12px;filter:{{ s.filter }};opacity:{{ s.op }}">
                      <span style="flex:none;width:26px;height:26px;border-radius:999px;background:{{ grad }};color:#fff;font-size:12px;font-weight:800;display:flex;align-items:center;justify-content:center">{{ s.n }}</span>
                      <span style="font-size:13px;font-weight:600;color:#1B1B1B;line-height:{{ lhSnug }}">{{ s.l }}</span>
                    </div>
                  </sc-for>
                </div>
                <div style="font-size:13.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:8px">{{ ggBody }}</div>
                <div style="font-size:11.5px;font-weight:700;color:#2D9B68;margin-bottom:20px">{{ ggFreeL }}</div>
                <button onClick="{{ ggCta }}" style="width:100%;height:54px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};transition:transform .15s cubic-bezier(.4,0,.2,1)" style-active="transform:scale(.97)">{{ ggCtaL }}</button>
                <button onClick="{{ ggLater }}" style="width:100%;height:48px;margin-top:8px;border:none;background:transparent;color:#716D67;font-size:13px;font-weight:600;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ ggLaterL }}</button>
              </div>
            </div>
          </sc-if>

          <sc-if value="{{ isNotifPrime }}" hint-placeholder-val="{{ false }}">
            <div style="min-height:100%;display:flex;flex-direction:column;justify-content:flex-end;padding:20px 0 0;box-sizing:border-box">
              <div style="background:#fff;border-radius:26px 26px 0 0;border-top:1.5px solid #E7E2DA;padding:10px 24px 30px">
                <div style="width:38px;height:4px;border-radius:2px;background:#E7E2DA;margin:0 auto 20px"></div>
                <div style="width:52px;height:52px;border-radius:16px;background:rgba(255,107,26,.08);color:#FF6B1A;display:flex;align-items:center;justify-content:center;margin-bottom:16px">
                  <svg width="25" height="25" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 15V10a6 6 0 1 0-12 0v5l-1.5 2.5h15z"></path><path d="M10 20a2 2 0 0 0 4 0"></path></svg>
                </div>
                <div style="font-family:{{ ffDisp }};font-weight:700;font-size:22px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:10px">{{ npTitle }}</div>
                <div style="font-size:13.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:18px">{{ npBody }}</div>
                <div style="display:grid;gap:8px;margin-bottom:22px">
                  <sc-for list="{{ npItems }}" as="n" hint-placeholder-count="3">
                    <div style="display:flex;gap:10px;align-items:flex-start">
                      <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#2D9B68" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round" style="flex:none;margin-top:3px"><path d="M5 13l4.5 4.5L19 7"></path></svg>
                      <span style="font-size:12.5px;font-weight:500;line-height:{{ lhBody }};color:#1B1B1B">{{ n }}</span>
                    </div>
                  </sc-for>
                </div>
                <button onClick="{{ npYes }}" style="width:100%;height:54px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};transition:transform .15s cubic-bezier(.4,0,.2,1)" style-active="transform:scale(.97)">{{ npYesL }}</button>
                <button onClick="{{ gBack }}" style="width:100%;height:48px;margin-top:8px;border:none;background:transparent;color:#716D67;font-size:13px;font-weight:600;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ npNoL }}</button>
              </div>
            </div>
          </sc-if>

          <sc-if value="{{ isRecent }}" hint-placeholder-val="{{ false }}">
            <div style="padding:12px 20px 30px">
              <button onClick="{{ gBack }}" aria-label="{{ gBackL }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center;margin:0 0 6px -10px">
                <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
              </button>
              <div style="font-family:{{ ffDisp }};font-weight:700;font-size:22px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:18px">{{ recentTitle }}</div>
              <div style="display:grid;gap:10px;margin-bottom:18px">
                <sc-for list="{{ recentItems }}" as="ri" hint-placeholder-count="5">
                  <button onClick="{{ ri.go }}" style="text-align:start;background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:14px 16px;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">
                    <span style="display:flex;align-items:center;gap:8px;margin-bottom:6px">
                      <span style="font-size:9.5px;font-weight:800;color:#716D67;background:#F5F2EC;padding:4px 8px;border-radius:999px;line-height:1.4">{{ ri.k }}</span>
                      <span style="font-size:11px;font-weight:500;color:#716D67">{{ ri.m }}</span>
                    </span>
                    <span style="display:block;font-size:13.5px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ ri.n }}</span>
                  </button>
                </sc-for>
              </div>
              <button onClick="{{ recentClear }}" style="width:100%;height:46px;border:1.5px solid #E7E2DA;border-radius:14px;background:#fff;color:#716D67;font-size:12.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ recentClearL }}</button>
            </div>
          </sc-if>

          <sc-if value="{{ isRoadmaps }}" hint-placeholder-val="{{ false }}">
            <div style="padding:12px 20px 30px">
              <button onClick="{{ gBack }}" aria-label="{{ gBackL }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center;margin:0 0 6px -10px">
                <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
              </button>
              <div style="font-family:{{ ffDisp }};font-weight:700;font-size:22px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:6px">{{ roadmapsTitle }}</div>
              <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:18px">{{ roadmapsSub }}</div>
              <div style="display:grid;gap:11px;margin-bottom:16px">
                <sc-for list="{{ roadmapList }}" as="rm" hint-placeholder-count="3">
                  <button onClick="{{ rm.open }}" style="text-align:start;background:#fff;border:1.5px solid {{ rm.bd }};border-radius:18px;padding:16px;cursor:pointer;box-shadow:0 1px 3px rgba(0,0,0,.05);font-family:{{ ff }};letter-spacing:{{ ls }}">
                    <span style="display:flex;align-items:center;justify-content:space-between;gap:10px;margin-bottom:8px">
                      <span style="font-size:11px;font-weight:600;color:#716D67">{{ rm.d }}</span>
                      <span style="display:flex;align-items:center;gap:6px">
                        <sc-if value="{{ rm.cur }}" hint-placeholder-val="{{ false }}">
                          <span style="font-size:9px;font-weight:800;color:#fff;background:{{ grad }};padding:3px 7px;border-radius:999px;letter-spacing:{{ lsB }}">{{ rm.badge }}</span>
                        </sc-if>
                        <span style="font-size:11px;font-weight:800;color:#1B1B1B;background:#FFC62E;padding:4px 8px;border-radius:999px;direction:ltr;unicode-bidi:isolate">{{ rm.fit }}</span>
                      </span>
                    </span>
                    <span style="display:block;font-size:15px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B;margin-bottom:4px">{{ rm.dest }}</span>
                    <span style="display:block;font-size:11.5px;font-weight:500;color:#716D67">{{ rm.stage }}</span>
                  </button>
                </sc-for>
              </div>
              <button onClick="{{ newRoadmap }}" style="width:100%;height:52px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:13.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};transition:transform .15s cubic-bezier(.4,0,.2,1)" style-active="transform:scale(.97)">{{ newRoadmapL }}</button>
            </div>
          </sc-if>

          <sc-if value="{{ isSearch }}" hint-placeholder-val="{{ false }}">
            <div style="padding:12px 20px 30px">
              <div style="display:flex;align-items:center;gap:8px;margin-bottom:10px">
                <button onClick="{{ gBack }}" aria-label="{{ gBackL }}" style="flex:none;width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center;margin-inline-start:-10px">
                  <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                </button>
                <div style="flex:1;height:46px;border:1.5px solid #FF6B1A;border-radius:12px;background:#fff;display:flex;align-items:center;gap:9px;padding:0 13px">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#716D67" stroke-width="2.2" stroke-linecap="round" style="flex:none"><circle cx="11" cy="11" r="6.5"></circle><path d="M16 16l4.5 4.5"></path></svg>
                  <span style="font-size:13px;color:#716D67;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">{{ searchPh }}</span>
                </div>
              </div>
              <div style="font-size:11px;font-weight:600;color:#716D67;background:#F5F2EC;border-radius:8px;padding:9px 11px;margin-bottom:22px;line-height:{{ lhSnug }}">{{ searchScopeL }}</div>
              <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:10px;line-height:1.4">{{ recentSearchL }}</div>
              <div style="display:grid;gap:2px;margin-bottom:24px">
                <sc-for list="{{ recentSearches }}" as="rs" hint-placeholder-count="3">
                  <button onClick="{{ rs.go }}" style="display:flex;align-items:center;gap:10px;min-height:46px;background:none;border:none;cursor:pointer;text-align:start;padding:0;font-family:{{ ff }};letter-spacing:{{ ls }}">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#716D67" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" style="flex:none"><circle cx="12" cy="12" r="9"></circle><path d="M12 8v4l3 2"></path></svg>
                    <span style="font-size:13.5px;font-weight:500;color:#1B1B1B">{{ rs.s }}</span>
                  </button>
                </sc-for>
              </div>
              <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:10px;line-height:1.4">{{ suggestL }}</div>
              <div style="display:grid;gap:9px">
                <sc-for list="{{ suggestions }}" as="sg" hint-placeholder-count="4">
                  <button onClick="{{ sg.go }}" style="display:flex;align-items:center;justify-content:space-between;gap:12px;background:#fff;border:1.5px solid #E7E2DA;border-radius:14px;padding:14px 16px;cursor:pointer;text-align:start;font-family:{{ ff }};letter-spacing:{{ ls }}">
                    <span style="font-size:13px;font-weight:600;color:#1B1B1B;line-height:{{ lhSnug }}">{{ sg.s }}</span>
                    <span style="flex:none;font-size:11px;font-weight:700;color:#716D67">{{ sg.m }}</span>
                  </button>
                </sc-for>
              </div>
            </div>
          </sc-if>

          <sc-if value="{{ isLessonDone }}" hint-placeholder-val="{{ false }}">
            <div style="padding:44px 24px 30px">
              <div style="width:60px;height:60px;border-radius:999px;background:rgba(45,155,104,.1);color:#2D9B68;display:flex;align-items:center;justify-content:center;margin-bottom:18px">
                <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="M5 13l4.5 4.5L19 7"></path></svg>
              </div>
              <div style="font-family:{{ ffDisp }};font-weight:700;font-size:24px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:8px">{{ ldTitle }}</div>
              <div style="font-size:13px;font-weight:500;line-height:{{ lhBody }};color:#716D67;margin-bottom:6px">{{ ldLesson }}</div>
              <div style="font-size:11.5px;font-weight:700;color:#FF6B1A;margin-bottom:24px;direction:ltr;unicode-bidi:isolate;text-align:start">{{ ldProgressL }}</div>
              <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:16px;margin-bottom:20px">
                <div style="font-size:13px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B;margin-bottom:12px">{{ ldNext }}</div>
                <div style="height:5px;border-radius:3px;background:#E7E2DA;overflow:hidden;margin-bottom:9px"><div style="height:100%;border-radius:3px;background:{{ grad }};width:{{ ldAutoWidth }}%;transition:width 1s linear"></div></div>
                <div style="font-size:11.5px;font-weight:600;color:#716D67;direction:ltr;unicode-bidi:isolate;text-align:start">{{ ldAutoL }}</div>
              </div>
              <button onClick="{{ ldNextGo }}" style="width:100%;height:54px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};transition:transform .15s cubic-bezier(.4,0,.2,1)" style-active="transform:scale(.97)">{{ ldNextL }}</button>
              <button onClick="{{ ldCancel }}" style="width:100%;height:48px;margin-top:9px;border:1.5px solid #E7E2DA;border-radius:14px;background:#fff;color:#1B1B1B;font-size:13px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ ldCancelL }}</button>
            </div>
          </sc-if>

          <sc-if value="{{ isCourseDone }}" hint-placeholder-val="{{ false }}">
            <div>
              <div style="background:#1B1B1B;padding:36px 24px 30px;text-align:center;position:relative;overflow:hidden">
                <div style="position:absolute;inset:0;background:radial-gradient(220px 140px at 50% 0%,rgba(255,198,46,.2),transparent 70%);pointer-events:none"></div>
                <div style="position:relative">
                  <div style="width:64px;height:64px;border-radius:20px;background:{{ grad }};display:flex;align-items:center;justify-content:center;margin:0 auto 18px">
                    <svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M5 13l4.5 4.5L19 7"></path></svg>
                  </div>
                  <div style="font-size:10.5px;font-weight:700;color:#FFC62E;line-height:1.4;margin-bottom:10px">{{ cdEarnedL }}</div>
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:24px;line-height:{{ lhTight }};color:#fff;margin-bottom:10px">{{ cdTitleL }}</div>
                  <div style="font-size:13px;font-weight:500;line-height:{{ lhBody }};color:rgba(255,255,255,.72)">{{ cdCourse }}</div>
                </div>
              </div>
              <div style="padding:22px 24px 30px">
                <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:16px;margin-bottom:18px">
                  <div style="font-size:12.5px;font-weight:700;color:#1B1B1B;margin-bottom:8px;direction:ltr;unicode-bidi:isolate;text-align:start">{{ cdMeta }}</div>
                  <div style="display:flex;align-items:center;gap:8px">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#2D9B68" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round" style="flex:none"><path d="M5 13l4.5 4.5L19 7"></path></svg>
                    <span style="font-size:11.5px;font-weight:600;color:#2D9B68;line-height:{{ lhSnug }}">{{ cdVerifiedL }}</span>
                  </div>
                </div>
                <button onClick="{{ cdView }}" style="width:100%;height:54px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};transition:transform .15s cubic-bezier(.4,0,.2,1)" style-active="transform:scale(.97)">{{ cdViewL }}</button>
                <button onClick="{{ cdShare }}" style="width:100%;height:50px;margin-top:9px;border:1.5px solid #E7E2DA;border-radius:14px;background:#fff;color:#1B1B1B;font-size:13px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ cdShareL }}</button>
                <button onClick="{{ cdNextGo }}" style="width:100%;height:46px;margin-top:6px;border:none;background:transparent;color:#716D67;font-size:12.5px;font-weight:600;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ cdNextL }}</button>
              </div>
            </div>
          </sc-if>

          <sc-if value="{{ isEditProfile }}" hint-placeholder-val="{{ false }}">
            <div style="padding:12px 20px 30px">
              <button onClick="{{ gBack }}" aria-label="{{ gBackL }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center;margin:0 0 6px -10px">
                <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
              </button>
              <div style="font-family:{{ ffDisp }};font-weight:700;font-size:22px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:20px">{{ epTitle }}</div>
              <div style="display:grid;gap:14px;margin-bottom:18px">
                <sc-for list="{{ epFields }}" as="f" hint-placeholder-count="5">
                  <div>
                    <label style="display:block;font-size:11.5px;font-weight:600;color:#716D67;margin-bottom:7px">{{ f.l }}</label>
                    <div style="height:48px;border:1.5px solid #E7E2DA;border-radius:12px;background:#fff;display:flex;align-items:center;padding:0 14px;font-size:13.5px;font-weight:500;color:#1B1B1B">{{ f.v }}</div>
                  </div>
                </sc-for>
              </div>
              <label style="display:block;font-size:11.5px;font-weight:600;color:#716D67;margin-bottom:7px">{{ epBioL }}</label>
              <div style="min-height:86px;border:1.5px solid #E7E2DA;border-radius:12px;background:#fff;padding:13px 14px;font-size:13px;line-height:{{ lhBody }};color:#1B1B1B;margin-bottom:22px">{{ epBio }}</div>
              <button onClick="{{ epSave }}" style="width:100%;height:54px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};transition:transform .15s cubic-bezier(.4,0,.2,1)" style-active="transform:scale(.97)">{{ epSaveL }}</button>
            </div>
          </sc-if>

          <sc-if value="{{ isInvite }}" hint-placeholder-val="{{ false }}">
            <div>
              <div style="background:#1B1B1B;padding:22px 24px 26px">
                <button onClick="{{ gBack }}" aria-label="{{ gBackL }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#fff;display:flex;align-items:center;justify-content:center;margin:0 0 6px -10px">
                  <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                </button>
                <div style="font-family:{{ ffDisp }};font-weight:700;font-size:25px;line-height:{{ lhTight }};color:#fff;margin-bottom:10px">{{ invTitle }}</div>
                <div style="font-size:13.5px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.7)">{{ invBody }}</div>
              </div>
              <div style="padding:22px 24px 30px">
                <div style="background:#fff;border:1.5px dashed #FF6B1A;border-radius:18px;padding:18px;text-align:center;margin-bottom:16px">
                  <div style="font-size:10px;font-weight:800;color:#716D67;letter-spacing:{{ lsE }};margin-bottom:9px">{{ invCodeL }}</div>
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:24px;color:#1B1B1B;direction:ltr;unicode-bidi:isolate">{{ invCode }}</div>
                </div>
                <button onClick="{{ invWa }}" style="width:100%;height:54px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};transition:transform .15s cubic-bezier(.4,0,.2,1)" style-active="transform:scale(.97)">{{ invWaL }}</button>
                <button onClick="{{ invCopy }}" style="width:100%;height:50px;margin-top:9px;border:1.5px solid #E7E2DA;border-radius:14px;background:#fff;color:#1B1B1B;font-size:13px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ invCopyL }}</button>
                <div style="margin-top:18px;background:rgba(45,155,104,.1);border-radius:12px;padding:14px 15px">
                  <div style="font-size:12px;font-weight:700;color:#2D9B68;line-height:{{ lhSnug }};margin-bottom:6px">{{ invStatL }}</div>
                  <div style="display:flex;align-items:center;gap:8px">
                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#2D9B68" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" style="flex:none"><rect x="5" y="6" width="14" height="14" rx="2"></rect><path d="M8 3v4M16 3v4M5 11h14"></path></svg>
                    <span style="font-size:11.5px;font-weight:600;color:#2D9B68;line-height:{{ lhSnug }}">{{ invRenewL }}</span>
                  </div>
                </div>
                <div style="margin-top:12px;font-size:11px;font-weight:400;line-height:{{ lhBody }};color:#6B6862">{{ invRuleL }}</div>
              </div>
            </div>
          </sc-if>

          <sc-if value="{{ isShareSheet }}" hint-placeholder-val="{{ false }}">
            <div style="min-height:100%;display:flex;flex-direction:column;justify-content:flex-end;padding:20px 0 0;box-sizing:border-box">
              <div style="background:#fff;border-radius:26px 26px 0 0;border-top:1.5px solid #E7E2DA;padding:10px 20px 30px">
                <div style="width:38px;height:4px;border-radius:2px;background:#E7E2DA;margin:0 auto 18px"></div>
                <div style="font-family:{{ ffDisp }};font-weight:700;font-size:20px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:16px">{{ shTitle }}</div>
                <div style="font-size:10px;font-weight:800;color:#716D67;letter-spacing:{{ lsE }};margin-bottom:8px">{{ shPreviewL }}</div>
                <div style="background:rgba(45,155,104,.07);border:1.5px solid rgba(45,155,104,.25);border-radius:16px;border-end-end-radius:4px;padding:14px 16px;font-size:12.5px;font-weight:500;line-height:{{ lhBody }};color:#1B1B1B;margin-bottom:18px">{{ shMsg }}</div>
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:16px">
                  <sc-for list="{{ shTargets }}" as="st" hint-placeholder-count="4">
                    <button onClick="{{ st.go }}" style="min-height:52px;border:none;border-radius:14px;background:{{ st.bg }};color:{{ st.tone }};font-size:13px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};transition:transform .15s cubic-bezier(.4,0,.2,1)" style-active="transform:scale(.97)">{{ st.l }}</button>
                  </sc-for>
                </div>
                <div style="font-size:11.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:12px">{{ shNote }}</div>
                <button onClick="{{ gBack }}" style="width:100%;min-height:48px;border:1.5px solid #E7E2DA;border-radius:14px;background:#fff;color:#1B1B1B;font-size:13px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.cancel }}</button>
              </div>
            </div>
          </sc-if>

          <sc-if value="{{ isRatePrompt }}" hint-placeholder-val="{{ false }}">
            <div style="min-height:100%;display:flex;flex-direction:column;justify-content:center;padding:24px;box-sizing:border-box">
              <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:24px;padding:24px;box-shadow:0 20px 50px rgba(0,0,0,.12)">
                <div style="display:flex;gap:5px;margin-bottom:16px">
                  <sc-for list="{{ rateStars }}" as="s" hint-placeholder-count="5">
                    <svg width="26" height="26" viewBox="0 0 24 24" fill="{{ s.fill }}" stroke="none"><path d="M12 3.5l2.7 5.6 6.1.8-4.4 4.3 1.1 6-5.5-3-5.5 3 1.1-6L3.2 9.9l6.1-.8z"></path></svg>
                  </sc-for>
                </div>
                <div style="font-family:{{ ffDisp }};font-weight:700;font-size:22px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:10px">{{ rateTitle }}</div>
                <div style="font-size:13px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:20px">{{ rateBody }}</div>
                <button onClick="{{ rateYes }}" style="width:100%;height:52px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:13.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};transition:transform .15s cubic-bezier(.4,0,.2,1)" style-active="transform:scale(.97)">{{ rateYesL }}</button>
                <button onClick="{{ gBack }}" style="width:100%;height:46px;margin-top:8px;border:1.5px solid #E7E2DA;border-radius:14px;background:#fff;color:#1B1B1B;font-size:12.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ rateFeedbackL }}</button>
                <button onClick="{{ gBack }}" style="width:100%;height:42px;margin-top:4px;border:none;background:transparent;color:#716D67;font-size:12.5px;font-weight:600;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ rateNoL }}</button>
              </div>
              <div style="font-size:11px;font-weight:500;line-height:{{ lhBody }};color:#716D67;text-align:center;margin-top:16px;padding:0 10px">{{ rateOnceL }}</div>
            </div>
          </sc-if>

          <sc-if value="{{ isLogout }}" hint-placeholder-val="{{ false }}">
            <div style="min-height:100%;display:flex;flex-direction:column;justify-content:flex-end;padding:20px 0 0;box-sizing:border-box">
              <div style="background:#fff;border-radius:26px 26px 0 0;border-top:1.5px solid #E7E2DA;padding:10px 24px 30px">
                <div style="width:38px;height:4px;border-radius:2px;background:#E7E2DA;margin:0 auto 20px"></div>
                <div style="font-family:{{ ffDisp }};font-weight:700;font-size:22px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:10px">{{ loTitle }}</div>
                <div style="font-size:13.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:18px">{{ loBody }}</div>
                <div style="display:flex;align-items:center;gap:11px;background:#F5F2EC;border-radius:12px;padding:13px 15px;margin-bottom:22px">
                  <span style="flex:none;width:22px;height:22px;border-radius:6px;border:1.5px solid #FF6B1A;background:{{ grad }};display:flex;align-items:center;justify-content:center">
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="3.4" stroke-linecap="round" stroke-linejoin="round"><path d="M5 13l4.5 4.5L19 7"></path></svg>
                  </span>
                  <span style="font-size:12.5px;font-weight:600;color:#1B1B1B;line-height:{{ lhSnug }}">{{ loKeepL }}</span>
                </div>
                <button onClick="{{ loConfirm }}" style="width:100%;height:52px;border:1.5px solid #FF2D32;border-radius:14px;background:rgba(255,45,50,.06);color:#FF2D32;font-size:13.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};transition:transform .15s cubic-bezier(.4,0,.2,1)" style-active="transform:scale(.97)">{{ loConfirmL }}</button>
                <button onClick="{{ gBack }}" style="width:100%;height:50px;margin-top:9px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:13.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ loCancelL }}</button>
              </div>
            </div>
          </sc-if>

          <sc-if value="{{ isDeleteAcct }}" hint-placeholder-val="{{ false }}">
            <div style="padding:12px 24px 30px">
              <button onClick="{{ daCancel }}" aria-label="{{ gBackL }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center;margin:0 0 8px -10px">
                <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
              </button>
              <sc-if value="{{ daIs1 }}" hint-placeholder-val="{{ true }}">
                <div>
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:24px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:10px">{{ daTitle1 }}</div>
                  <div style="font-size:13.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:16px">{{ daBody1 }}</div>
                  <div style="display:grid;gap:9px;margin-bottom:16px">
                    <sc-for list="{{ daLoses }}" as="dl" hint-placeholder-count="5">
                      <div style="display:flex;gap:10px;align-items:flex-start">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#FF2D32" stroke-width="2.8" stroke-linecap="round" style="flex:none;margin-top:3px"><path d="M6 6l12 12M18 6L6 18"></path></svg>
                        <span style="font-size:12.5px;font-weight:500;line-height:{{ lhBody }};color:#1B1B1B">{{ dl }}</span>
                      </div>
                    </sc-for>
                  </div>
                  <div style="background:#F5F2EC;border-radius:12px;padding:13px 15px;font-size:11.5px;font-weight:500;line-height:{{ lhBody }};color:#716D67;margin-bottom:14px">{{ daKeepsL }}</div>
                  <div style="background:rgba(73,111,168,.08);border-radius:12px;padding:13px 15px;font-size:12px;font-weight:600;line-height:{{ lhBody }};color:#496FA8;margin-bottom:22px">{{ daAltL }}</div>
                  <button onClick="{{ daNext }}" style="width:100%;height:52px;border:1.5px solid #FF2D32;border-radius:14px;background:rgba(255,45,50,.06);color:#FF2D32;font-size:13.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ daNextL }}</button>
                  <button onClick="{{ daCancel }}" style="width:100%;height:50px;margin-top:9px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:13.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ daCancelL }}</button>
                </div>
              </sc-if>
              <sc-if value="{{ daIs2 }}" hint-placeholder-val="{{ false }}">
                <div>
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:24px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:10px">{{ daTitle2 }}</div>
                  <div style="font-size:13.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:20px">{{ daBody2 }}</div>
                  <div style="height:52px;border:1.5px solid #E7E2DA;border-radius:12px;background:#fff;display:flex;align-items:center;padding:0 14px;font-size:14px;font-weight:700;color:#716D67;margin-bottom:22px;direction:ltr;unicode-bidi:isolate;letter-spacing:.16em">{{ daFieldPh }}</div>
                  <button onClick="{{ daConfirm }}" style="width:100%;height:52px;border:none;border-radius:14px;background:#FF2D32;color:#fff;font-size:13.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ daConfirmL }}</button>
                  <button onClick="{{ daCancel }}" style="width:100%;height:50px;margin-top:9px;border:1.5px solid #E7E2DA;border-radius:14px;background:#fff;color:#1B1B1B;font-size:13.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ daCancelL }}</button>
                </div>
              </sc-if>
            </div>
          </sc-if>

          <sc-if value="{{ xCompare }}" hint-placeholder-val="{{ false }}">
            <div>
              <div style="background:#1B1B1B;padding:12px 14px 22px">
                <button onClick="{{ closeX }}" aria-label="{{ t.back }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#fff;display:flex;align-items:center;justify-content:center;margin-bottom:4px">
                  <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                </button>
                <div style="padding:0 6px;font-family:{{ ffDisp }};font-weight:700;font-size:23px;line-height:{{ lhTight }};color:#fff">{{ t.compareTitle }}</div>
              </div>
              <sc-if value="{{ cmpHasAny }}" hint-placeholder-val="{{ true }}">
                <div style="padding:18px 0 30px;overflow-x:auto;scrollbar-width:thin">
                  <div style="display:grid;grid-template-columns:{{ cmpGrid }};gap:12px;padding:0 20px;min-width:min-content">
                    <sc-for list="{{ cmpCols }}" as="c" hint-placeholder-count="2">
                      <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:14px">
                        <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:8px;margin-bottom:10px">
                          <span role="img" aria-label="{{ c.country }}" style="flex:none;width:34px;height:24px;border-radius:4px;border:1px solid #E7E2DA;background:{{ c.bg }}"></span>
                          <button onClick="{{ c.drop }}" aria-label="{{ t.clearAll }}" style="flex:none;width:26px;height:26px;border-radius:999px;border:1px solid #E7E2DA;background:#fff;color:#716D67;cursor:pointer;display:flex;align-items:center;justify-content:center;margin:-4px -4px 0 0">
                            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round"><path d="M6 6l12 12M18 6L6 18"></path></svg>
                          </button>
                        </div>
                        <div style="font-size:12.5px;font-weight:700;line-height:{{ lhSnug }};color:#1B1B1B;margin-bottom:4px;direction:ltr;unicode-bidi:isolate;text-align:start">{{ c.uni }}</div>
                        <div style="font-size:11.5px;font-weight:500;line-height:{{ lhSnug }};color:#716D67;margin-bottom:12px">{{ c.name }}</div>
                        <div style="display:grid;gap:9px;font-size:11.5px">
                          <div><div style="font-weight:600;color:#716D67;margin-bottom:2px">{{ t.fTuition }}</div><div style="font-weight:700;color:#1B1B1B;direction:ltr;unicode-bidi:isolate;text-align:start">{{ c.cost }}</div></div>
                          <div><div style="font-weight:600;color:#716D67;margin-bottom:2px">{{ t.fDuration }}</div><div style="font-weight:600;color:#1B1B1B">{{ c.dur }}</div></div>
                          <div><div style="font-weight:600;color:#716D67;margin-bottom:2px">{{ t.fDeadline }}</div><div style="font-weight:600;color:#1B1B1B">{{ c.deadline }}</div></div>
                          <div><div style="font-weight:600;color:#716D67;margin-bottom:2px">{{ t.fLanguage }}</div><div style="font-weight:600;color:#1B1B1B">{{ c.lang }}</div></div>
                          <div><div style="font-weight:600;color:#716D67;margin-bottom:2px">{{ t.fIelts }}</div><div style="font-weight:600;color:#1B1B1B;direction:ltr;unicode-bidi:isolate;text-align:start">{{ c.ielts }}</div></div>
                          <div><div style="font-weight:600;color:#716D67;margin-bottom:2px">{{ t.fScholarship }}</div><div style="font-weight:600;color:#1B1B1B">{{ c.sch }}</div></div>
                          <div><div style="font-weight:600;color:#716D67;margin-bottom:2px">{{ t.fInterview }}</div><div style="font-weight:600;color:#1B1B1B">{{ c.iv }}</div></div>
                        </div>
                      </div>
                    </sc-for>
                  </div>
                </div>
              </sc-if>
              <sc-if value="{{ cmpEmpty }}" hint-placeholder-val="{{ false }}">
                <div style="padding:40px 28px;text-align:center">
                  <div style="font-size:17px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B;margin-bottom:6px">{{ t.cmpEmptyTitle }}</div>
                  <div style="font-size:13px;font-weight:400;line-height:{{ lhBody }};color:#716D67">{{ t.cmpEmptyBody }}</div>
                </div>
              </sc-if>
            </div>
          </sc-if>

          <sc-if value="{{ xRequests }}" hint-placeholder-val="{{ false }}">
            <div style="padding:12px 20px 30px">
              <button onClick="{{ closeX }}" aria-label="{{ t.back }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center;margin-bottom:8px">
                <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
              </button>
              <div style="font-family:{{ ffDisp }};font-weight:700;font-size:22px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:16px">{{ reqTitle }}</div>
              <sc-if value="{{ hasReqs }}" hint-placeholder-val="{{ true }}">
                <div style="display:grid;gap:12px;margin-bottom:24px">
                  <sc-for list="{{ reqRows }}" as="rq" hint-placeholder-count="2">
                    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:16px">
                      <div style="display:flex;align-items:center;gap:11px;margin-bottom:10px">
                        <span style="flex:none;width:40px;height:40px;border-radius:999px;background:#F5F2EC;border:1.5px solid #E7E2DA;color:#716D67;font-size:13px;font-weight:700;display:flex;align-items:center;justify-content:center">{{ rq.n }}</span>
                        <span style="min-width:0;flex:1">
                          <span style="display:block;font-size:13.5px;font-weight:600;color:#1B1B1B;line-height:{{ lhSnug }}">{{ rq.who }}</span>
                          <span style="display:block;font-size:11.5px;font-weight:600;color:#716D67;margin-top:3px">{{ rq.when }}</span>
                        </span>
                        <span style="flex:none;font-size:10.5px;font-weight:700;color:#496FA8;background:rgba(73,111,168,.1);padding:5px 9px;border-radius:999px">{{ rq.subj }}</span>
                      </div>
                      <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:14px">{{ rq.note }}</div>
                      <div style="display:flex;gap:8px">
                        <button onClick="{{ rq.accept }}" style="flex:1;height:44px;border:none;border-radius:12px;background:{{ grad }};color:#fff;font-size:12.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ acceptL }}</button>
                        <button onClick="{{ rq.decline }}" style="flex:1;height:44px;border:1.5px solid #E7E2DA;border-radius:12px;background:#fff;color:#716D67;font-size:12.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ declineL }}</button>
                      </div>
                    </div>
                  </sc-for>
                </div>
              </sc-if>
              <sc-if value="{{ noReqs }}" hint-placeholder-val="{{ false }}">
                <div style="padding:26px 10px;text-align:center;margin-bottom:14px">
                  <div style="font-size:16px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B;margin-bottom:5px">{{ reqEmptyT }}</div>
                  <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67">{{ reqEmptyB }}</div>
                </div>
              </sc-if>
              <div style="display:flex;align-items:baseline;justify-content:space-between;gap:10px;margin-bottom:4px">
                <div style="font-size:11px;font-weight:600;color:#FF6B1A;line-height:1.4">{{ availTitle }}</div>
                <button onClick="{{ avClearAll }}" style="background:none;border:none;min-height:44px;padding:0;cursor:pointer;font-size:11.5px;font-weight:600;color:#716D67;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ avClearAllL }}</button>
              </div>
              <div style="font-size:12px;font-weight:600;color:#1B1B1B;margin-bottom:12px;direction:ltr;unicode-bidi:isolate;text-align:start">{{ avCountL }}</div>
              <div style="display:flex;gap:6px;overflow-x:auto;scrollbar-width:none;margin-bottom:14px">
                <sc-for list="{{ avDayChips }}" as="d" hint-placeholder-count="7">
                  <button onClick="{{ d.pick }}" style="flex:none;min-width:56px;min-height:52px;border-radius:12px;padding:8px 10px;cursor:pointer;background:{{ d.bg }};color:{{ d.fg }};border:1.5px solid {{ d.bd }};font-size:11.5px;font-weight:700;font-family:{{ ff }};letter-spacing:{{ ls }};display:flex;flex-direction:column;align-items:center;justify-content:center;gap:3px">
                    <span>{{ d.label }}</span>
                    <sc-if value="{{ d.hasN }}" hint-placeholder-val="{{ false }}">
                      <span style="font-size:9.5px;font-weight:800;opacity:.7;direction:ltr">{{ d.n }}</span>
                    </sc-if>
                  </button>
                </sc-for>
              </div>
              <div style="font-size:12.5px;font-weight:700;color:#1B1B1B;margin-bottom:3px">{{ avDayFullL }}</div>
              <div style="font-size:11px;font-weight:400;color:#716D67;margin-bottom:11px;line-height:{{ lhSnug }}">{{ avPickHoursL }}</div>
              <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:7px;margin-bottom:16px">
                <sc-for list="{{ avHourCells }}" as="h" hint-placeholder-count="15">
                  <button onClick="{{ h.toggle }}" style="min-height:44px;border-radius:11px;cursor:pointer;background:{{ h.bg }};color:{{ h.fg }};border:1.5px solid {{ h.bd }};font-size:11.5px;font-weight:700;font-family:{{ ff }};letter-spacing:{{ ls }};direction:ltr;unicode-bidi:isolate">{{ h.label }}</button>
                </sc-for>
              </div>
              <div style="font-size:10.5px;font-weight:500;line-height:{{ lhBody }};color:#716D67;background:#F5F2EC;border-radius:9px;padding:9px 11px;margin-bottom:16px">{{ avTzL }}</div>
              <div style="font-size:10px;font-weight:800;color:#716D67;letter-spacing:{{ lsE }};margin-bottom:9px">{{ avChosenL }}</div>
              <sc-if value="{{ avNone }}" hint-placeholder-val="{{ false }}">
                <div style="background:rgba(255,45,50,.06);border-radius:12px;padding:13px 14px;font-size:11.5px;font-weight:500;line-height:{{ lhBody }};color:#1B1B1B;margin-bottom:16px">{{ avNoneL }}</div>
              </sc-if>
              <sc-if value="{{ avHasAny }}" hint-placeholder-val="{{ true }}">
                <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:4px 14px;margin-bottom:16px">
                  <sc-for list="{{ avSummaryRows }}" as="s" hint-placeholder-count="3">
                    <div style="display:flex;align-items:flex-start;gap:10px;padding:12px 0;border-bottom:1px solid #F1ECE4">
                      <span style="flex:1;min-width:0">
                        <span style="display:block;font-size:12px;font-weight:700;color:#1B1B1B">{{ s.day }}</span>
                        <span style="display:block;font-size:11px;font-weight:500;color:#716D67;margin-top:3px;direction:ltr;unicode-bidi:isolate;text-align:start">{{ s.hours }}</span>
                      </span>
                      <button onClick="{{ s.clear }}" style="flex:none;min-height:34px;padding:0 11px;border:1.5px solid #E7E2DA;border-radius:9px;background:#fff;color:#716D67;font-size:10.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ avDayClearL }}</button>
                    </div>
                  </sc-for>
                </div>
              </sc-if>
              <button onClick="{{ saveAvail }}" style="width:100%;height:48px;border:1.5px solid #E7E2DA;border-radius:12px;background:#fff;color:#1B1B1B;font-size:13px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ saveAvailL }}</button>
            </div>
          </sc-if>

          <sc-if value="{{ xOnboardDone }}" hint-placeholder-val="{{ false }}">
            <div style="padding:52px 24px 30px">
              <div style="width:64px;height:64px;border-radius:999px;background:rgba(45,155,104,.1);color:#2D9B68;display:flex;align-items:center;justify-content:center;margin:0 auto 18px">
                <svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="M5 13l4.5 4.5L19 7"></path></svg>
              </div>
              <div style="text-align:center;font-family:{{ ffDisp }};font-weight:700;font-size:24px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:10px">{{ oL.doneTitle }}</div>
              <div style="text-align:center;font-size:13.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:22px">{{ oL.doneBody }}</div>
              <div style="display:grid;gap:10px;margin-bottom:22px">
                <sc-for list="{{ nextSteps }}" as="s" hint-placeholder-count="4">
                  <div style="display:flex;gap:12px;background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:15px;align-items:center">
                    <span style="flex:none;width:26px;height:26px;border-radius:8px;background:{{ grad }};color:#fff;font-size:12px;font-weight:800;display:flex;align-items:center;justify-content:center">{{ s.n }}</span>
                    <span style="min-width:0">
                      <span style="display:block;font-size:13px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ s.t }}</span>
                      <span style="display:block;font-size:11.5px;font-weight:400;color:#716D67;margin-top:2px;line-height:{{ lhSnug }}">{{ s.d }}</span>
                    </span>
                  </div>
                </sc-for>
              </div>
              <button onClick="{{ openEarnings }}" style="width:100%;height:52px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ oL.goDash }}</button>
              <button onClick="{{ closeX }}" style="width:100%;height:44px;margin-top:8px;border:none;background:transparent;color:#716D67;font-size:13px;font-weight:600;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ oL.backConnect }}</button>
            </div>
          </sc-if>

          <sc-if value="{{ xOnboard }}" hint-placeholder-val="{{ false }}">
            <div style="padding:12px 20px 30px">
              <div style="display:flex;align-items:center;gap:10px;margin-bottom:16px">
                <button onClick="{{ oPrev }}" aria-label="{{ t.back }}" style="flex:none;width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center">
                  <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                </button>
                <span style="font-size:12px;font-weight:700;color:#716D67">{{ t.becomeTitle }}</span>
              </div>
              <div style="display:flex;gap:6px;margin-bottom:20px">
                <sc-for list="{{ onboardSteps }}" as="s" hint-placeholder-count="6">
                  <button onClick="{{ s.go }}" aria-label="{{ s.label }}" style="flex:1;height:30px;border:none;border-radius:8px;cursor:pointer;background:{{ s.bg }};color:{{ s.fg }};font-size:11px;font-weight:800;font-family:{{ ff }}">{{ s.n }}</button>
                </sc-for>
              </div>
              <div style="font-family:{{ ffDisp }};font-weight:700;font-size:22px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:18px">{{ oStepTitle }}</div>

              <sc-if value="{{ oS1 }}" hint-placeholder-val="{{ true }}">
                <div>
                  <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin:-6px 0 16px">{{ oL.introS1 }}</div>
                  <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px">
                    <div>
                      <label style="display:block;font-size:12px;font-weight:600;color:#1B1B1B;margin-bottom:8px">{{ oL.firstName }}</label>
                      <div style="height:48px;border:1.5px solid #E7E2DA;border-radius:12px;background:#fff;display:flex;align-items:center;padding:0 14px;font-size:13.5px;color:#716D67;margin-bottom:14px">Yasmine</div>
                    </div>
                    <div>
                      <label style="display:block;font-size:12px;font-weight:600;color:#1B1B1B;margin-bottom:8px">{{ oL.lastName }}</label>
                      <div style="height:48px;border:1.5px solid #E7E2DA;border-radius:12px;background:#fff;display:flex;align-items:center;padding:0 14px;font-size:13.5px;color:#716D67;margin-bottom:14px">Hassan</div>
                    </div>
                  </div>
                  <label style="display:block;font-size:12px;font-weight:600;color:#1B1B1B;margin-bottom:8px">{{ oL.email }}</label>
                  <div style="height:48px;border:1.5px solid #E7E2DA;border-radius:12px;background:#fff;display:flex;align-items:center;padding:0 14px;font-size:13.5px;color:#716D67;margin-bottom:14px;direction:ltr">dr.yasmine@example.com</div>
                  <label style="display:block;font-size:12px;font-weight:600;color:#1B1B1B;margin-bottom:8px">{{ oL.phone }}</label>
                  <div style="height:48px;border:1.5px solid #E7E2DA;border-radius:12px;background:#fff;display:flex;align-items:center;padding:0 14px;font-size:13.5px;color:#716D67;margin-bottom:14px;direction:ltr">+20 10 1234 5678</div>
                  <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px">
                    <div>
                      <label style="display:block;font-size:12px;font-weight:600;color:#1B1B1B;margin-bottom:8px">{{ oL.country }}</label>
                      <div style="height:48px;border:1.5px solid #E7E2DA;border-radius:12px;background:#fff;display:flex;align-items:center;padding:0 14px;font-size:13.5px;color:#716D67;margin-bottom:14px">{{ oL.countryV }}</div>
                    </div>
                    <div>
                      <label style="display:block;font-size:12px;font-weight:600;color:#1B1B1B;margin-bottom:8px">{{ oL.city }}</label>
                      <div style="height:48px;border:1.5px solid #E7E2DA;border-radius:12px;background:#fff;display:flex;align-items:center;padding:0 14px;font-size:13.5px;color:#716D67;margin-bottom:14px">{{ oL.cityV }}</div>
                    </div>
                  </div>
                  <label style="display:block;font-size:12px;font-weight:600;color:#1B1B1B;margin-bottom:8px">{{ oL.title }}</label>
                  <div style="height:48px;border:1.5px solid #E7E2DA;border-radius:12px;background:#fff;display:flex;align-items:center;padding:0 14px;font-size:13.5px;color:#716D67;margin-bottom:18px">{{ oL.titleV }}</div>
                  <button onClick="{{ oNext }}" style="width:100%;height:52px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.continue }}</button>
                  <button onClick="{{ saveDraft }}" style="width:100%;height:44px;margin-top:8px;border:none;background:transparent;color:#716D67;font-size:13px;font-weight:600;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.saveDraft }}</button>
                </div>
              </sc-if>

              <sc-if value="{{ oS2 }}" hint-placeholder-val="{{ false }}">
                <div>
                  <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin:-6px 0 16px">{{ oL.introS2 }}</div>
                  <label style="display:block;font-size:12px;font-weight:600;color:#1B1B1B;margin-bottom:8px">{{ oL.degree }}</label>
                  <div style="height:48px;border:1.5px solid #E7E2DA;border-radius:12px;background:#fff;display:flex;align-items:center;padding:0 14px;font-size:13.5px;color:#716D67;margin-bottom:14px">{{ oL.degreeV }}</div>
                  <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px">
                    <div>
                      <label style="display:block;font-size:12px;font-weight:600;color:#1B1B1B;margin-bottom:8px">{{ oL.uni }}</label>
                      <div style="height:48px;border:1.5px solid #E7E2DA;border-radius:12px;background:#fff;display:flex;align-items:center;padding:0 14px;font-size:13.5px;color:#716D67;margin-bottom:14px">{{ oL.uniV }}</div>
                    </div>
                    <div>
                      <label style="display:block;font-size:12px;font-weight:600;color:#1B1B1B;margin-bottom:8px">{{ oL.gradYear }}</label>
                      <div style="height:48px;border:1.5px solid #E7E2DA;border-radius:12px;background:#fff;display:flex;align-items:center;padding:0 14px;font-size:13.5px;color:#716D67;margin-bottom:14px;direction:ltr">{{ oL.gradYearV }}</div>
                    </div>
                  </div>
                  <div style="font-size:12px;font-weight:600;color:#1B1B1B;margin-bottom:8px">{{ oL.spec }}</div>
                  <div style="display:flex;flex-wrap:wrap;gap:8px;margin-bottom:14px">
                    <sc-for list="{{ oSpecChips }}" as="o" hint-placeholder-count="6">
                      <button onClick="{{ o.pick }}" style="border-radius:999px;min-height:44px;padding:10px 13px;cursor:pointer;background:{{ o.bg }};color:{{ o.fg }};border:1.5px solid {{ o.bd }};font-size:12.5px;font-weight:600;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ o.label }}</button>
                    </sc-for>
                  </div>
                  <label style="display:block;font-size:12px;font-weight:600;color:#1B1B1B;margin-bottom:8px">{{ oL.postgrad }}</label>
                  <div style="min-height:74px;border:1.5px solid #E7E2DA;border-radius:12px;background:#fff;padding:13px 14px;font-size:13px;line-height:{{ lhBody }};color:#716D67;margin-bottom:18px">{{ oL.postgradV }}</div>
                  <button onClick="{{ oNext }}" style="width:100%;height:52px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.continue }}</button>
                  <button onClick="{{ saveDraft }}" style="width:100%;height:44px;margin-top:8px;border:none;background:transparent;color:#716D67;font-size:13px;font-weight:600;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.saveDraft }}</button>
                </div>
              </sc-if>

              <sc-if value="{{ oS3 }}" hint-placeholder-val="{{ false }}">
                <div>
                  <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin:-6px 0 16px">{{ oL.subjNote }}</div>
                  <div style="font-size:12px;font-weight:600;color:#1B1B1B;margin-bottom:8px">{{ oL.subjects }}</div>
                  <div style="display:flex;flex-wrap:wrap;gap:8px;margin-bottom:20px">
                    <sc-for list="{{ oSubjectChips }}" as="o" hint-placeholder-count="7">
                      <button onClick="{{ o.pick }}" style="border-radius:999px;min-height:44px;padding:10px 13px;cursor:pointer;background:{{ o.bg }};color:{{ o.fg }};border:1.5px solid {{ o.bd }};font-size:12.5px;font-weight:600;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ o.label }}</button>
                    </sc-for>
                  </div>
                  <div style="font-size:12px;font-weight:600;color:#1B1B1B;margin-bottom:8px">{{ oL.langs }}</div>
                  <div style="display:flex;flex-wrap:wrap;gap:8px;margin-bottom:20px">
                    <sc-for list="{{ oLangChips }}" as="o" hint-placeholder-count="3">
                      <button onClick="{{ o.pick }}" style="border-radius:999px;min-height:44px;padding:10px 13px;cursor:pointer;background:{{ o.bg }};color:{{ o.fg }};border:1.5px solid {{ o.bd }};font-size:12.5px;font-weight:600;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ o.label }}</button>
                    </sc-for>
                  </div>
                  <button onClick="{{ oNext }}" style="width:100%;height:52px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.continue }}</button>
                  <button onClick="{{ saveDraft }}" style="width:100%;height:44px;margin-top:8px;border:none;background:transparent;color:#716D67;font-size:13px;font-weight:600;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.saveDraft }}</button>
                </div>
              </sc-if>

              <sc-if value="{{ oS4 }}" hint-placeholder-val="{{ false }}">
                <div>
                  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:18px;margin-bottom:16px">
                    <div style="font-size:11px;font-weight:600;color:#716D67;margin-bottom:9px;line-height:1.4">{{ t.yourRate }}</div>
                    <div style="display:flex;flex-wrap:wrap;gap:8px;margin-bottom:18px">
                      <sc-for list="{{ rateOpts }}" as="o" hint-placeholder-count="4">
                        <button onClick="{{ o.pick }}" style="border-radius:999px;min-height:44px;padding:10px 13px;cursor:pointer;background:{{ o.bg }};color:{{ o.fg }};border:1.5px solid {{ o.bd }};font-size:12.5px;font-weight:700;font-family:{{ ff }};direction:ltr;unicode-bidi:isolate">{{ o.label }}</button>
                      </sc-for>
                    </div>
                    <div style="background:#F5F2EC;border-radius:14px;padding:14px">
                      <div style="display:flex;justify-content:space-between;gap:12px;padding-bottom:9px;border-bottom:1px solid #E7E2DA">
                        <span style="font-size:12px;font-weight:500;color:#716D67">{{ t.sessionFee }}</span>
                        <span style="font-size:12.5px;font-weight:700;color:#1B1B1B;direction:ltr;unicode-bidi:isolate">{{ rateGross }}</span>
                      </div>
                      <div style="display:flex;justify-content:space-between;gap:12px;padding:9px 0;border-bottom:1px solid #E7E2DA">
                        <span style="font-size:12px;font-weight:500;color:#716D67">{{ t.platformFee }}</span>
                        <span style="font-size:12.5px;font-weight:700;color:#FF2D32;direction:ltr;unicode-bidi:isolate">− {{ rateFee }}</span>
                      </div>
                      <div style="display:flex;justify-content:space-between;gap:12px;padding-top:9px">
                        <span style="font-size:12px;font-weight:700;color:#1B1B1B">{{ t.youKeep }}</span>
                        <span style="font-family:{{ ffDisp }};font-size:16px;font-weight:700;color:#2D9B68;direction:ltr;unicode-bidi:isolate">{{ rateNet }}</span>
                      </div>
                    </div>
                  </div>
                  <button onClick="{{ oNext }}" style="width:100%;height:52px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.continue }}</button>
                  <button onClick="{{ saveDraft }}" style="width:100%;height:44px;margin-top:8px;border:none;background:transparent;color:#716D67;font-size:13px;font-weight:600;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.saveDraft }}</button>
                </div>
              </sc-if>
              <sc-if value="{{ oS5 }}" hint-placeholder-val="{{ false }}">
                <div>
                  <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin:-6px 0 16px">{{ oL.availNote }}</div>
                  <div style="display:flex;align-items:baseline;justify-content:space-between;gap:10px;margin-bottom:8px">
                    <div style="font-size:12px;font-weight:600;color:#1B1B1B">{{ oL.days }}</div>
                    <button onClick="{{ avClearAll }}" style="background:none;border:none;min-height:44px;padding:0;cursor:pointer;font-size:11.5px;font-weight:600;color:#716D67;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ avClearAllL }}</button>
                  </div>
                  <div style="display:flex;gap:6px;overflow-x:auto;scrollbar-width:none;margin-bottom:16px">
                    <sc-for list="{{ avDayChips }}" as="d" hint-placeholder-count="7">
                      <button onClick="{{ d.pick }}" style="flex:none;min-width:56px;min-height:52px;border-radius:12px;padding:8px 10px;cursor:pointer;background:{{ d.bg }};color:{{ d.fg }};border:1.5px solid {{ d.bd }};font-size:11.5px;font-weight:700;font-family:{{ ff }};letter-spacing:{{ ls }};display:flex;flex-direction:column;align-items:center;justify-content:center;gap:3px">
                        <span>{{ d.label }}</span>
                        <sc-if value="{{ d.hasN }}" hint-placeholder-val="{{ false }}">
                          <span style="font-size:9.5px;font-weight:800;opacity:.7;direction:ltr">{{ d.n }}</span>
                        </sc-if>
                      </button>
                    </sc-for>
                  </div>
                  <div style="font-size:12.5px;font-weight:700;color:#1B1B1B;margin-bottom:3px">{{ avDayFullL }}</div>
                  <div style="font-size:11px;font-weight:400;color:#716D67;margin-bottom:11px;line-height:{{ lhSnug }}">{{ avPickHoursL }}</div>
                  <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:7px;margin-bottom:14px">
                    <sc-for list="{{ avHourCells }}" as="h" hint-placeholder-count="15">
                      <button onClick="{{ h.toggle }}" style="min-height:44px;border-radius:11px;cursor:pointer;background:{{ h.bg }};color:{{ h.fg }};border:1.5px solid {{ h.bd }};font-size:11.5px;font-weight:700;font-family:{{ ff }};letter-spacing:{{ ls }};direction:ltr;unicode-bidi:isolate">{{ h.label }}</button>
                    </sc-for>
                  </div>
                  <div style="font-size:12px;font-weight:600;color:#1B1B1B;margin-bottom:10px;direction:ltr;unicode-bidi:isolate;text-align:start">{{ avCountL }}</div>
                  <sc-if value="{{ avHasAny }}" hint-placeholder-val="{{ true }}">
                    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:4px 14px;margin-bottom:16px">
                      <sc-for list="{{ avSummaryRows }}" as="s" hint-placeholder-count="3">
                        <div style="display:flex;align-items:flex-start;gap:10px;padding:12px 0;border-bottom:1px solid #F1ECE4">
                          <span style="flex:1;min-width:0">
                            <span style="display:block;font-size:12px;font-weight:700;color:#1B1B1B">{{ s.day }}</span>
                            <span style="display:block;font-size:11px;font-weight:500;color:#716D67;margin-top:3px;direction:ltr;unicode-bidi:isolate;text-align:start">{{ s.hours }}</span>
                          </span>
                          <button onClick="{{ s.clear }}" style="flex:none;min-height:34px;padding:0 11px;border:1.5px solid #E7E2DA;border-radius:9px;background:#fff;color:#716D67;font-size:10.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ avDayClearL }}</button>
                        </div>
                      </sc-for>
                    </div>
                  </sc-if>
                  <sc-if value="{{ avNone }}" hint-placeholder-val="{{ false }}">
                    <div style="background:rgba(255,45,50,.06);border-radius:12px;padding:13px 14px;font-size:11.5px;font-weight:500;line-height:{{ lhBody }};color:#1B1B1B;margin-bottom:16px">{{ avNoneL }}</div>
                  </sc-if>
                  <div style="font-size:10.5px;font-weight:500;line-height:{{ lhBody }};color:#716D67;background:#F5F2EC;border-radius:9px;padding:9px 11px;margin-bottom:18px">{{ avTzL }}</div>
                  <button onClick="{{ oNext }}" style="width:100%;height:52px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.continue }}</button>
                  <button onClick="{{ saveDraft }}" style="width:100%;height:44px;margin-top:8px;border:none;background:transparent;color:#716D67;font-size:13px;font-weight:600;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.saveDraft }}</button>
                </div>
              </sc-if>

              <sc-if value="{{ oS6 }}" hint-placeholder-val="{{ false }}">
                <div>
                  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:18px;margin-bottom:16px;text-align:center">
                    <div style="text-align:start;margin-bottom:12px">
                      <div style="border:1.5px dashed #C9C2B8;border-radius:14px;padding:13px 14px;margin-bottom:10px;display:flex;align-items:center;gap:12px">
                        <span style="flex:1;min-width:0">
                          <span style="display:block;font-size:12.5px;font-weight:700;color:#1B1B1B;line-height:{{ lhSnug }}">{{ oL.mPhoto }}</span>
                          <span style="display:block;font-size:10.5px;font-weight:500;color:#716D67;margin-top:3px;direction:ltr;unicode-bidi:isolate;text-align:start">JPG / PNG · min 400×400</span>
                        </span>
                        <span style="flex:none;font-size:11px;font-weight:700;color:#1B1B1B;border:1.5px solid #E7E2DA;border-radius:999px;padding:7px 12px">{{ oL.browse }}</span>
                      </div>
                      <div style="border:1.5px dashed #C9C2B8;border-radius:14px;padding:13px 14px;margin-bottom:10px;display:flex;align-items:center;gap:12px">
                        <span style="flex:1;min-width:0">
                          <span style="display:block;font-size:12.5px;font-weight:700;color:#1B1B1B;line-height:{{ lhSnug }}">{{ oL.mVideo }}</span>
                          <span style="display:block;font-size:10.5px;font-weight:500;color:#716D67;margin-top:3px;direction:ltr;unicode-bidi:isolate;text-align:start">MP4 / MOV · max 5 min</span>
                        </span>
                        <span style="flex:none;font-size:11px;font-weight:700;color:#1B1B1B;border:1.5px solid #E7E2DA;border-radius:999px;padding:7px 12px">{{ oL.browse }}</span>
                      </div>
                      <div style="border:1.5px dashed #C9C2B8;border-radius:14px;padding:13px 14px;display:flex;align-items:center;gap:12px">
                        <span style="flex:1;min-width:0">
                          <span style="display:block;font-size:12.5px;font-weight:700;color:#1B1B1B;line-height:{{ lhSnug }}">{{ oL.mCv }}</span>
                          <span style="display:block;font-size:10.5px;font-weight:500;color:#716D67;margin-top:3px;direction:ltr;unicode-bidi:isolate;text-align:start">PDF · qualifications & publications</span>
                        </span>
                        <span style="flex:none;font-size:11px;font-weight:700;color:#1B1B1B;border:1.5px solid #E7E2DA;border-radius:999px;padding:7px 12px">{{ oL.browse }}</span>
                      </div>
                    </div>
                    <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67">{{ t.mediaNote }}</div>
                  </div>
                  <button onClick="{{ oNext }}" style="width:100%;height:52px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.continue }}</button>
                </div>
              </sc-if>

              <sc-if value="{{ oS7 }}" hint-placeholder-val="{{ false }}">
                <div>
                  <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin:-6px 0 16px">{{ oL.docsNote }}</div>
                  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:6px 16px;margin-bottom:14px">
                    <sc-for list="{{ docRows }}" as="d" hint-placeholder-count="3">
                      <div style="padding:13px 0;border-bottom:1px solid #E7E2DA;display:flex;align-items:center;gap:12px">
                        <span style="flex:1;min-width:0">
                          <span style="display:block;font-size:13px;font-weight:600;color:#1B1B1B;margin-bottom:3px;line-height:{{ lhSnug }}">{{ d.t }}</span>
                          <span style="display:block;font-size:11.5px;font-weight:400;color:#716D67;line-height:{{ lhSnug }}">{{ d.d }}</span>
                        </span>
                        <span style="flex:none;font-size:11px;font-weight:700;color:#1B1B1B;border:1.5px solid #E7E2DA;border-radius:999px;padding:7px 12px">{{ oL.browse }}</span>
                      </div>
                    </sc-for>
                  </div>
                  <button onClick="{{ toggleAgree }}" style="width:100%;display:flex;gap:12px;align-items:flex-start;background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:15px;cursor:pointer;text-align:start;font-family:{{ ff }};letter-spacing:{{ ls }};margin-bottom:18px">
                    <span style="flex:none;width:22px;height:22px;border-radius:7px;border:1.5px solid #E7E2DA;background:{{ oAgreeBoxBg }};display:flex;align-items:center;justify-content:center;margin-top:1px">
                      <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="{{ oAgreeTickFg }}" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 13l4.5 4.5L19 7"></path></svg>
                    </span>
                    <span style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#1B1B1B">{{ oL.agreeText }}</span>
                  </button>
                  <button onClick="{{ oNext }}" style="width:100%;height:52px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.continue }}</button>
                </div>
              </sc-if>

              <sc-if value="{{ oS8 }}" hint-placeholder-val="{{ false }}">
                <div>
                  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:6px 16px;margin-bottom:14px">
                    <sc-for list="{{ reviewRows }}" as="r" hint-placeholder-count="5">
                      <div style="display:flex;justify-content:space-between;gap:16px;padding:12px 0;border-bottom:1px solid #E7E2DA">
                        <span style="font-size:12.5px;font-weight:500;color:#716D67">{{ r.k }}</span>
                        <span style="font-size:13px;font-weight:600;color:#1B1B1B;text-align:end">{{ r.v }}</span>
                      </div>
                    </sc-for>
                  </div>
                  <div style="font-size:12px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:16px">{{ oL.reviewNote }}</div>
                  <button onClick="{{ submitApp }}" style="width:100%;height:52px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 8px 28px rgba(255,107,26,.35);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.submitApplication }}</button>
                  <div style="font-size:11.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-top:14px;text-align:center">{{ t.reviewTimeline }}</div>
                </div>
              </sc-if>
            </div>
          </sc-if>

          <sc-if value="{{ xEarnings }}" hint-placeholder-val="{{ false }}">
            <div>
              <div style="background:#1B1B1B;padding:12px 14px 26px">
                <button onClick="{{ closeX }}" aria-label="{{ t.back }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#fff;display:flex;align-items:center;justify-content:center;margin-bottom:6px">
                  <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                </button>
                <div style="padding:0 6px">
                  <div style="font-size:10.5px;font-weight:700;color:#FFC62E;margin-bottom:10px;line-height:1.4">{{ t.availableBalance }}</div>
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:32px;line-height:{{ lhTight }};color:#fff;direction:ltr;unicode-bidi:isolate;text-align:start">{{ balance }}</div>
                  <div style="font-size:12px;font-weight:500;color:rgba(255,255,255,.55);margin-top:8px">{{ t.pendingClearing }} {{ pending }}</div>
                </div>
              </div>
              <div style="padding:20px 20px 30px">
                <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:18px;margin-bottom:20px">
                  <div style="font-size:11px;font-weight:600;color:#716D67;margin-bottom:16px;line-height:1.4">{{ t.lastSixMonths }}</div>
                  <div style="display:flex;align-items:flex-end;gap:10px;height:104px">
                    <sc-for list="{{ bars }}" as="b" hint-placeholder-count="6">
                      <div style="flex:1;display:flex;flex-direction:column;align-items:center;gap:7px;height:100%;justify-content:flex-end">
                        <div style="width:100%;border-radius:6px 6px 0 0;background:{{ grad }};height:{{ b.h }}%"></div>
                        <span style="font-size:10px;font-weight:700;color:#716D67">{{ b.label }}</span>
                      </div>
                    </sc-for>
                  </div>
                </div>
                <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:12px;line-height:1.4">{{ t.perSession }}</div>
                <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:6px 16px;margin-bottom:18px">
                  <sc-for list="{{ earnRows }}" as="r" hint-placeholder-count="4">
                    <div style="padding:13px 0;border-bottom:1px solid #E7E2DA">
                      <div style="font-size:12.5px;font-weight:600;color:#1B1B1B;margin-bottom:7px">{{ r.when }}</div>
                      <div style="display:flex;justify-content:space-between;gap:10px;font-size:11.5px">
                        <span style="font-weight:500;color:#716D67;direction:ltr;unicode-bidi:isolate">{{ r.gross }}</span>
                        <span style="font-weight:600;color:#FF2D32;direction:ltr;unicode-bidi:isolate">{{ r.fee }}</span>
                        <span style="font-weight:700;color:#2D9B68;direction:ltr;unicode-bidi:isolate">{{ r.net }}</span>
                      </div>
                    </div>
                  </sc-for>
                </div>
                <div style="background:#F5F2EC;border-radius:14px;padding:14px 16px;font-size:12px;font-weight:500;line-height:{{ lhBody }};color:#716D67;margin-bottom:16px">{{ t.splitNote }}</div>
                <button onClick="{{ withdrawTap }}" style="width:100%;height:52px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.withdrawWeb }}</button>
              </div>
            </div>
          </sc-if>

          <sc-if value="{{ xInstructor }}" hint-placeholder-val="{{ false }}">
            <div style="padding:12px 20px 30px">
              <button onClick="{{ closeX }}" aria-label="{{ t.back }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center;margin-bottom:8px">
                <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
              </button>
              <div style="font-family:{{ ffDisp }};font-weight:700;font-size:22px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:18px">{{ t.instructorTitle }}</div>
              <div style="display:grid;gap:12px">
                <sc-for list="{{ instRows }}" as="r" hint-placeholder-count="2">
                  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:16px">
                    <div style="font-size:14px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B;margin-bottom:12px">{{ r.course }}</div>
                    <div style="display:flex;gap:16px;margin-bottom:12px">
                      <div><div style="font-family:{{ ffDisp }};font-weight:700;font-size:17px;color:#1B1B1B;direction:ltr;unicode-bidi:isolate;text-align:start">{{ r.students }}</div><div style="font-size:10px;font-weight:600;color:#716D67;margin-top:3px">{{ t.enrolled }}</div></div>
                      <div><div style="font-family:{{ ffDisp }};font-weight:700;font-size:17px;color:#1B1B1B;direction:ltr;unicode-bidi:isolate;text-align:start">{{ r.rating }}</div><div style="font-size:10px;font-weight:600;color:#716D67;margin-top:3px">{{ t.rating }}</div></div>
                      <div><div style="font-family:{{ ffDisp }};font-weight:700;font-size:17px;color:#1B1B1B;direction:ltr;unicode-bidi:isolate;text-align:start">{{ r.pctLabel }}</div><div style="font-size:10px;font-weight:600;color:#716D67;margin-top:3px">{{ t.avgCompletion }}</div></div>
                    </div>
                    <div style="height:6px;border-radius:4px;background:#E7E2DA;overflow:hidden"><div style="height:100%;border-radius:4px;background:{{ grad }};width:{{ r.pct }}%"></div></div>
                  </div>
                </sc-for>
              </div>
            </div>
          </sc-if>

          <sc-if value="{{ xVerify }}" hint-placeholder-val="{{ false }}">
            <div style="padding:12px 20px 30px">
              <button onClick="{{ closeX }}" aria-label="{{ t.back }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center;margin-bottom:8px">
                <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
              </button>
              <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:22px;padding:24px;text-align:center;box-shadow:0 3px 12px rgba(0,0,0,.07)">
                <div style="width:56px;height:56px;border-radius:999px;background:rgba(45,155,104,.1);color:#2D9B68;display:flex;align-items:center;justify-content:center;margin:0 auto 16px">
                  <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="M5 13l4.5 4.5L19 7"></path></svg>
                </div>
                <div style="font-size:11px;font-weight:700;color:#2D9B68;margin-bottom:10px;line-height:1.4">{{ t.verified }}</div>
                <div style="font-family:{{ ffDisp }};font-weight:700;font-size:21px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:8px">{{ t.profileName }}</div>
                <div style="font-size:13px;font-weight:500;line-height:{{ lhSnug }};color:#716D67;margin-bottom:20px">{{ t.certTitleSample }}</div>
                <div style="background:#F5F2EC;border-radius:14px;padding:6px 14px;text-align:start">
                  <div style="display:flex;justify-content:space-between;gap:12px;padding:11px 0;border-bottom:1px solid #E7E2DA"><span style="font-size:11.5px;font-weight:500;color:#716D67">{{ t.certCode }}</span><span style="font-size:12px;font-weight:700;color:#1B1B1B;direction:ltr;unicode-bidi:isolate">EJ-2026-0481</span></div>
                  <div style="display:flex;justify-content:space-between;gap:12px;padding:11px 0;border-bottom:1px solid #E7E2DA"><span style="font-size:11.5px;font-weight:500;color:#716D67">{{ t.issuedOn }}</span><span style="font-size:12px;font-weight:700;color:#1B1B1B">{{ t.issuedDate }}</span></div>
                  <div style="display:flex;justify-content:space-between;gap:12px;padding:11px 0"><span style="font-size:11.5px;font-weight:500;color:#716D67">{{ t.issuedBy }}</span><span style="font-size:12px;font-weight:700;color:#1B1B1B">{{ t.appName }}</span></div>
                </div>
              </div>
              <div style="font-size:11.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-top:16px;text-align:center">{{ t.publicPageNote }}</div>
            </div>
          </sc-if>

          <sc-if value="{{ onRoadmap }}" hint-placeholder-val="{{ false }}">
            <div>
              <sc-if value="{{ rResult }}" hint-placeholder-val="{{ false }}">
                <div>
                  <div style="background:#1B1B1B;padding:12px 14px 26px;position:relative;overflow:hidden">
                    <div style="position:absolute;inset:0;background:radial-gradient(260px 160px at 78% 8%,rgba(255,198,46,.22),transparent 70%);pointer-events:none"></div>
                    <div style="position:relative">
                      <button onClick="{{ restart }}" aria-label="{{ t.startOver }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#fff;display:flex;align-items:center;justify-content:center;margin-bottom:6px">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M6 6l12 12M18 6L6 18"></path></svg>
                      </button>
                      <div style="padding:0 6px">
                        <div style="display:flex;align-items:center;gap:8px;margin-bottom:12px">
                          <span style="font-size:10.5px;font-weight:700;color:#FFC62E;line-height:1.4">{{ t.bestRoute }}</span>
                          <sc-if value="{{ isLive }}" hint-placeholder-val="{{ false }}">
                            <span style="font-size:9.5px;font-weight:700;color:#7FD4A6;background:rgba(45,155,104,.18);padding:4px 8px;border-radius:999px">{{ liveBadge }}</span>
                          </sc-if>
                        </div>
                        <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:12px;margin-bottom:12px">
                          <div style="font-family:{{ ffDisp }};font-weight:700;font-size:30px;line-height:{{ lhTight }};color:#fff">{{ res.country }}</div>
                          <span style="flex:none;font-size:12px;font-weight:800;color:#fff;background:{{ grad }};padding:7px 12px;border-radius:999px;direction:ltr;unicode-bidi:isolate">{{ res.fit }}</span>
                        </div>
                        <div style="font-size:14.5px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.72);margin-bottom:20px">{{ res.why }}</div>
                        <div style="height:1px;background:rgba(255,255,255,.12);margin-bottom:16px"></div>
                        <div style="font-size:10.5px;font-weight:700;color:rgba(255,255,255,.45);margin-bottom:10px;line-height:1.4">{{ t.alsoWorth }}</div>
                        <div style="display:grid;gap:8px">
                          <sc-for list="{{ res.alts }}" as="a" hint-placeholder-count="2">
                            <div style="background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.1);border-radius:14px;padding:13px">
                              <div style="font-size:13px;font-weight:600;color:#fff;line-height:{{ lhSnug }}">{{ a.c }}</div>
                              <div style="font-size:11.5px;font-weight:400;color:rgba(255,255,255,.55);margin-top:3px;line-height:{{ lhSnug }}">{{ a.w }}</div>
                            </div>
                          </sc-for>
                        </div>
                      </div>
                    </div>
                  </div>

                  <div style="padding:20px 20px 30px">
                    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:20px;margin-bottom:24px">
                      <div style="font-family:{{ ffDisp }};font-weight:700;font-size:20px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:18px">{{ res.headline }}</div>
                      <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:10px">
                        <div>
                          <div style="font-family:{{ ffDisp }};font-weight:700;font-size:15px;color:#FF6B1A;line-height:1.3;direction:ltr;unicode-bidi:isolate;text-align:start">{{ res.time }}</div>
                          <div style="font-size:10px;font-weight:600;color:#716D67;margin-top:5px;line-height:1.4">{{ t.totalTime }}</div>
                        </div>
                        <div>
                          <div style="font-family:{{ ffDisp }};font-weight:700;font-size:15px;color:#FF6B1A;line-height:1.3;direction:ltr;unicode-bidi:isolate;text-align:start">{{ res.cost }}</div>
                          <div style="font-size:10px;font-weight:600;color:#716D67;margin-top:5px;line-height:1.4">{{ t.estCost }}</div>
                        </div>
                        <div>
                          <div style="font-family:{{ ffDisp }};font-weight:700;font-size:15px;color:#FF6B1A;line-height:1.3">{{ res.diff }}</div>
                          <div style="font-size:10px;font-weight:600;color:#716D67;margin-top:5px;line-height:1.4">{{ t.difficulty }}</div>
                        </div>
                      </div>
                    </div>

                    <sc-if value="{{ resGuideShow }}" hint-placeholder-val="{{ false }}">
                      <button onClick="{{ openResGuide }}" style="width:100%;margin:-8px 0 22px;text-align:start;display:flex;align-items:center;justify-content:space-between;gap:10px;background:#fff;border:1.5px solid #E7E2DA;border-radius:14px;padding:14px 16px;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">
                        <span style="font-size:13px;font-weight:700;color:#1B1B1B">{{ resGuideL }}</span>
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#FF6B1A" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" style="flex:none;transform:scaleX({{ flip }})"><path d="M9 5l7 7-7 7"></path></svg>
                      </button>
                    </sc-if>
                    <div style="display:flex;align-items:center;justify-content:space-between;gap:12px;margin-bottom:12px">
                      <span style="font-size:11px;font-weight:600;color:#FF6B1A;line-height:1.4">{{ t.theRoute }}</span>
                      <span style="font-size:11px;font-weight:700;color:#716D67">{{ planLabel }}</span>
                    </div>
                    <div style="height:6px;border-radius:4px;background:#E7E2DA;overflow:hidden;margin-bottom:14px"><div style="height:100%;border-radius:4px;background:{{ grad }};width:{{ planPct }}%"></div></div>
                    <div style="display:grid;gap:10px;margin-bottom:24px">
                      <sc-for list="{{ res.stages }}" as="s" hint-placeholder-count="5">
                        <div style="background:{{ s.doneBg }};border:1.5px solid {{ s.doneBorder }};border-radius:18px;padding:16px;display:flex;gap:13px">
                          <div style="flex:none;width:28px;height:28px;border-radius:9px;background:{{ s.tileBg }};color:#fff;font-size:13px;font-weight:800;display:flex;align-items:center;justify-content:center">{{ s.tick }}</div>
                          <div style="min-width:0;flex:1">
                            <div style="font-size:9.5px;font-weight:700;color:#716D67;margin-bottom:5px;line-height:1.4">{{ s.phase }}</div>
                            <div style="font-size:14.5px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B;margin-bottom:5px">{{ s.title }}</div>
                            <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:10px">{{ s.detail }}</div>
                            <div style="display:flex;flex-wrap:wrap;gap:7px;align-items:center">
                              <span style="font-size:10.5px;font-weight:700;color:#496FA8;background:rgba(73,111,168,.1);padding:5px 9px;border-radius:999px">{{ s.dur }}</span>
                              <span style="font-size:10.5px;font-weight:700;color:#716D67;background:#F5F2EC;padding:5px 9px;border-radius:999px">{{ s.cost }}</span>
                              <button onClick="{{ s.toggle }}" style="margin-inline-start:auto;border:1.5px solid {{ s.doneBorder }};background:#fff;color:{{ s.doneFg }};border-radius:999px;padding:6px 11px;font-size:10.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ s.doneLabel }}</button>
                            </div>
                          </div>
                        </div>
                      </sc-for>
                    </div>

                    <div style="background:rgba(255,45,50,.08);border:1.5px solid rgba(255,45,50,.28);border-radius:18px;padding:16px;margin-bottom:12px">
                      <div style="font-size:10.5px;font-weight:700;color:#FF2D32;margin-bottom:7px;line-height:1.4">{{ t.watchOut }}</div>
                      <div style="font-size:13px;font-weight:500;line-height:{{ lhBody }};color:#1B1B1B">{{ res.watch }}</div>
                    </div>
                    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:16px;margin-bottom:24px">
                      <div style="font-size:10.5px;font-weight:700;color:#FF6B1A;margin-bottom:7px;line-height:1.4">{{ t.startNow }}</div>
                      <div style="font-size:13px;font-weight:500;line-height:{{ lhBody }};color:#1B1B1B">{{ res.now }}</div>
                    </div>

                    <div style="background:#1B1B1B;border-radius:20px;padding:20px;margin-bottom:20px">
                      <div style="font-size:10.5px;font-weight:700;color:#FFC62E;margin-bottom:8px;line-height:1.4">{{ t.whatIf }}</div>
                      <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.6);margin-bottom:14px">{{ t.whatIfSub }}</div>
                      <div style="display:flex;flex-wrap:wrap;gap:8px">
                        <sc-for list="{{ whatIf }}" as="w" hint-placeholder-count="3">
                          <button onClick="{{ w.pick }}" style="border-radius:999px;min-height:44px;padding:10px 13px;cursor:pointer;background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.16);color:#fff;font-size:12px;font-weight:600;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ w.label }}</button>
                        </sc-for>
                      </div>
                    </div>

                    <div style="display:grid;gap:10px">
                      <button onClick="{{ goMasters }}" style="display:flex;align-items:center;justify-content:space-between;gap:12px;background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:16px;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};text-align:start">
                        <span style="min-width:0">
                          <span style="display:block;font-size:13.5px;font-weight:600;color:#1B1B1B">{{ t.nextProgrammes }}</span>
                          <span style="display:block;font-size:12px;font-weight:400;color:#716D67;margin-top:3px;line-height:{{ lhSnug }}">{{ t.nextProgrammesSub }}</span>
                        </span>
                        <span style="color:#716D67"><svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M9 5l7 7-7 7"></path></svg></span>
                      </button>
                      <button onClick="{{ goConnect }}" style="display:flex;align-items:center;justify-content:space-between;gap:12px;background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:16px;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};text-align:start">
                        <span style="min-width:0">
                          <span style="display:block;font-size:13.5px;font-weight:600;color:#1B1B1B">{{ t.nextMentor }}</span>
                          <span style="display:block;font-size:12px;font-weight:400;color:#716D67;margin-top:3px;line-height:{{ lhSnug }}">{{ t.nextMentorSub }}</span>
                        </span>
                        <span style="color:#716D67"><svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M9 5l7 7-7 7"></path></svg></span>
                      </button>
                      <button onClick="{{ waShare }}" style="height:52px;border-radius:14px;border:none;background:#25D366;color:#fff;font-size:13.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.shareWhatsapp }}</button>
                      <button onClick="{{ restart }}" style="height:52px;border-radius:14px;border:1.5px solid #E7E2DA;background:#fff;color:#716D67;font-size:13.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.startOver }}</button>
                    </div>
                    <div style="font-size:11px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-top:18px">{{ t.disclaimer }}</div>
                  </div>
                </div>
              </sc-if>

              <sc-if value="{{ rS1 }}" hint-placeholder-val="{{ false }}">
                <div style="padding:12px 20px 30px">
                  <div style="display:flex;align-items:center;gap:10px;margin-bottom:14px">
                    <button onClick="{{ rBack }}" aria-label="{{ t.back }}" style="flex:none;width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center">
                      <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                    </button>
                    <span style="font-size:12px;font-weight:700;color:#716D67">{{ rStepLabel }}</span>
                  </div>
                  <div style="height:5px;border-radius:3px;background:#E7E2DA;overflow:hidden;margin-bottom:22px"><div style="height:100%;border-radius:3px;background:{{ grad }};width:{{ rProgress }}%"></div></div>
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:23px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:18px">{{ t.q1 }}</div>
                  <div style="display:grid;gap:10px;margin-bottom:22px">
                    <sc-for list="{{ forkCards }}" as="f" hint-placeholder-count="4">
                      <button onClick="{{ f.pick }}" style="text-align:start;background:{{ f.bg }};border:1.5px solid {{ f.bd }};border-radius:18px;padding:17px;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">
                        <span style="display:block;font-size:14.5px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ f.title }}</span>
                        <span style="display:block;font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-top:4px">{{ f.blurb }}</span>
                      </button>
                    </sc-for>
                  </div>
                  <button onClick="{{ rNext }}" style="width:100%;height:52px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.continue }}</button>
                </div>
              </sc-if>

              <sc-if value="{{ rS2 }}" hint-placeholder-val="{{ false }}">
                <div style="padding:12px 20px 30px">
                  <div style="display:flex;align-items:center;gap:10px;margin-bottom:14px">
                    <button onClick="{{ rBack }}" aria-label="{{ t.back }}" style="flex:none;width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center">
                      <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                    </button>
                    <span style="font-size:12px;font-weight:700;color:#716D67">{{ rStepLabel }}</span>
                  </div>
                  <div style="height:5px;border-radius:3px;background:#E7E2DA;overflow:hidden;margin-bottom:22px"><div style="height:100%;border-radius:3px;background:{{ grad }};width:{{ rProgress }}%"></div></div>
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:23px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:8px">{{ t.q2 }}</div>
                  <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:18px">{{ pathHint }}</div>
                  <div style="display:flex;flex-wrap:wrap;gap:8px;margin-bottom:22px">
                    <sc-for list="{{ pathOpts }}" as="o" hint-placeholder-count="5">
                      <button onClick="{{ o.pick }}" style="border-radius:999px;min-height:44px;padding:11px 14px;cursor:pointer;background:{{ o.bg }};color:{{ o.fg }};border:1.5px solid {{ o.bd }};font-size:12.5px;font-weight:600;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ o.label }}</button>
                    </sc-for>
                  </div>
                  <button onClick="{{ rNext }}" style="width:100%;height:52px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.continue }}</button>
                </div>
              </sc-if>

              <sc-if value="{{ rS3 }}" hint-placeholder-val="{{ false }}">
                <div style="padding:12px 20px 30px">
                  <div style="display:flex;align-items:center;gap:10px;margin-bottom:14px">
                    <button onClick="{{ rBack }}" aria-label="{{ t.back }}" style="flex:none;width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center">
                      <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                    </button>
                    <span style="font-size:12px;font-weight:700;color:#716D67">{{ rStepLabel }}</span>
                  </div>
                  <div style="height:5px;border-radius:3px;background:#E7E2DA;overflow:hidden;margin-bottom:22px"><div style="height:100%;border-radius:3px;background:{{ grad }};width:{{ rProgress }}%"></div></div>
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:23px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:18px">{{ t.q3 }}</div>
                  <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:10px;line-height:1.4">{{ t.currentStage }}</div>
                  <div style="display:flex;flex-wrap:wrap;gap:8px;margin-bottom:20px">
                    <sc-for list="{{ stageOpts }}" as="o" hint-placeholder-count="5">
                      <button onClick="{{ o.pick }}" style="border-radius:999px;min-height:44px;padding:10px 13px;cursor:pointer;background:{{ o.bg }};color:{{ o.fg }};border:1.5px solid {{ o.bd }};font-size:12.5px;font-weight:600;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ o.label }}</button>
                    </sc-for>
                  </div>
                  <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:10px;line-height:1.4">{{ t.yearsSince }}</div>
                  <div style="display:flex;flex-wrap:wrap;gap:8px;margin-bottom:22px">
                    <sc-for list="{{ yearOpts }}" as="o" hint-placeholder-count="5">
                      <button onClick="{{ o.pick }}" style="border-radius:999px;min-height:44px;padding:10px 13px;cursor:pointer;background:{{ o.bg }};color:{{ o.fg }};border:1.5px solid {{ o.bd }};font-size:12.5px;font-weight:600;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ o.label }}</button>
                    </sc-for>
                  </div>
                  <button onClick="{{ rNext }}" style="width:100%;height:52px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.continue }}</button>
                </div>
              </sc-if>

              <sc-if value="{{ rS4 }}" hint-placeholder-val="{{ false }}">
                <div style="padding:12px 20px 30px">
                  <div style="display:flex;align-items:center;gap:10px;margin-bottom:14px">
                    <button onClick="{{ rBack }}" aria-label="{{ t.back }}" style="flex:none;width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center">
                      <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                    </button>
                    <span style="font-size:12px;font-weight:700;color:#716D67">{{ rStepLabel }}</span>
                  </div>
                  <div style="height:5px;border-radius:3px;background:#E7E2DA;overflow:hidden;margin-bottom:22px"><div style="height:100%;border-radius:3px;background:{{ grad }};width:{{ rProgress }}%"></div></div>
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:23px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:8px">{{ t.q4 }}</div>
                  <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:18px">{{ t.q4sub }}</div>
                  <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:10px;line-height:1.4">{{ t.budgetLabel }}</div>
                  <div style="display:flex;flex-wrap:wrap;gap:8px;margin-bottom:20px">
                    <sc-for list="{{ budgetOpts }}" as="o" hint-placeholder-count="5">
                      <button onClick="{{ o.pick }}" style="border-radius:999px;min-height:44px;padding:10px 13px;cursor:pointer;background:{{ o.bg }};color:{{ o.fg }};border:1.5px solid {{ o.bd }};font-size:12.5px;font-weight:600;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ o.label }}</button>
                    </sc-for>
                  </div>
                  <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:10px;line-height:1.4">{{ t.timeLabel }}</div>
                  <div style="display:flex;flex-wrap:wrap;gap:8px;margin-bottom:22px">
                    <sc-for list="{{ timeOpts }}" as="o" hint-placeholder-count="5">
                      <button onClick="{{ o.pick }}" style="border-radius:999px;min-height:44px;padding:10px 13px;cursor:pointer;background:{{ o.bg }};color:{{ o.fg }};border:1.5px solid {{ o.bd }};font-size:12.5px;font-weight:600;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ o.label }}</button>
                    </sc-for>
                  </div>
                  <button onClick="{{ rNext }}" style="width:100%;height:52px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.continue }}</button>
                </div>
              </sc-if>

              <sc-if value="{{ rS5 }}" hint-placeholder-val="{{ false }}">
                <div style="padding:12px 20px 30px">
                  <div style="display:flex;align-items:center;gap:10px;margin-bottom:14px">
                    <button onClick="{{ rBack }}" aria-label="{{ t.back }}" style="flex:none;width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center">
                      <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                    </button>
                    <span style="font-size:12px;font-weight:700;color:#716D67">{{ rStepLabel }}</span>
                  </div>
                  <div style="height:5px;border-radius:3px;background:#E7E2DA;overflow:hidden;margin-bottom:22px"><div style="height:100%;border-radius:3px;background:{{ grad }};width:{{ rProgress }}%"></div></div>
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:23px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:18px">{{ t.q5 }}</div>
                  <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:10px;line-height:1.4">{{ t.regionLabel }}</div>
                  <div style="display:flex;flex-wrap:wrap;gap:8px;margin-bottom:20px">
                    <sc-for list="{{ regionOpts }}" as="o" hint-placeholder-count="6">
                      <button onClick="{{ o.pick }}" style="border-radius:999px;min-height:44px;padding:10px 13px;cursor:pointer;background:{{ o.bg }};color:{{ o.fg }};border:1.5px solid {{ o.bd }};font-size:12.5px;font-weight:600;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ o.label }}</button>
                    </sc-for>
                  </div>
                  <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:10px;line-height:1.4">{{ t.priorityLabel }}</div>
                  <div style="display:flex;flex-wrap:wrap;gap:8px;margin-bottom:22px">
                    <sc-for list="{{ priorityOpts }}" as="o" hint-placeholder-count="5">
                      <button onClick="{{ o.pick }}" style="border-radius:999px;min-height:44px;padding:10px 13px;cursor:pointer;background:{{ o.bg }};color:{{ o.fg }};border:1.5px solid {{ o.bd }};font-size:12.5px;font-weight:600;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ o.label }}</button>
                    </sc-for>
                  </div>
                  <sc-if value="{{ generating }}" hint-placeholder-val="{{ false }}">
                    <div style="text-align:center;padding:10px 0 4px">
                      <span style="width:26px;height:26px;border:3px solid #E7E2DA;border-top-color:#FF6B1A;border-radius:50%;display:inline-block;animation:spin .8s linear infinite;margin-bottom:14px"></span>
                      <div style="font-size:13.5px;font-weight:600;color:#1B1B1B">{{ genLine }}</div>
                    </div>
                  </sc-if>
                  <sc-if value="{{ hasGenError }}" hint-placeholder-val="{{ false }}">
                    <div style="background:#F5F2EC;border:1.5px solid #E7E2DA;border-radius:16px;padding:14px 16px;margin-bottom:12px;font-size:12.5px;font-weight:500;line-height:{{ lhBody }};color:#716D67">{{ genError }}</div>
                  </sc-if>
                  <button onClick="{{ generate }}" style="width:100%;height:52px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 8px 28px rgba(255,107,26,.35);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.buildRoute }}</button>
                </div>
              </sc-if>
            </div>
          </sc-if>

          <sc-if value="{{ rIntro }}" hint-placeholder-val="{{ false }}">
            <div>
              <div style="background:#1B1B1B;padding:18px 20px 30px">
                <div style="font-size:11px;font-weight:600;color:#FFC62E;line-height:1;margin-bottom:14px">{{ t.careerEyebrow }}</div>
                <div style="font-family:{{ ffDisp }};font-weight:700;font-size:28px;line-height:{{ lhTight }};color:#fff;margin-bottom:10px">{{ t.careerTitle }}</div>
                <div style="font-size:14px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.68)">{{ t.careerSub }}</div>
              </div>
              <div style="padding:24px 20px 30px">
                <div style="font-size:11px;font-weight:600;color:#FF6B1A;line-height:1;margin-bottom:14px">{{ t.toolsLabel }}</div>
                <div style="display:grid;gap:10px;margin-bottom:14px">
                  <button onClick="{{ openRoadmaps }}" style="display:flex;align-items:center;justify-content:space-between;gap:12px;background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:16px;cursor:pointer;text-align:start;font-family:{{ ff }};letter-spacing:{{ ls }}">
                    <span style="min-width:0">
                      <span style="display:block;font-size:14px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ roadmapsTitle }}</span>
                      <span style="display:block;font-size:11.5px;font-weight:500;color:#716D67;margin-top:3px;line-height:{{ lhSnug }}">{{ roadmapsSub }}</span>
                    </span>
                    <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="#716D67" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="flex:none;transform:scaleX({{ flip }})"><path d="M9 5l7 7-7 7"></path></svg>
                  </button>
                  <button onClick="{{ openRecent }}" style="display:flex;align-items:center;justify-content:space-between;gap:12px;background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:16px;cursor:pointer;text-align:start;font-family:{{ ff }};letter-spacing:{{ ls }}">
                    <span style="min-width:0;font-size:14px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ recentTitle }}</span>
                    <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="#716D67" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="flex:none;transform:scaleX({{ flip }})"><path d="M9 5l7 7-7 7"></path></svg>
                  </button>
                  <button onClick="{{ openPlan }}" style="display:flex;align-items:center;justify-content:space-between;gap:12px;background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:16px;cursor:pointer;text-align:start;font-family:{{ ff }};letter-spacing:{{ ls }}">
                    <span style="min-width:0">
                      <span style="display:block;font-size:14px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ planTitle }}</span>
                      <span style="display:block;font-size:11.5px;font-weight:500;color:#716D67;margin-top:3px;direction:ltr;unicode-bidi:isolate;text-align:start">{{ planCountL }}</span>
                    </span>
                    <span style="flex:none;font-family:{{ ffDisp }};font-weight:700;font-size:18px;color:#FF6B1A;direction:ltr">{{ planPctL }}%</span>
                  </button>
                  <button onClick="{{ openAfford }}" style="display:flex;align-items:center;justify-content:space-between;gap:12px;background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:16px;cursor:pointer;text-align:start;font-family:{{ ff }};letter-spacing:{{ ls }}">
                    <span style="min-width:0">
                      <span style="display:block;font-size:14px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ affordTitle }}</span>
                      <span style="display:block;font-size:11.5px;font-weight:500;color:#716D67;margin-top:3px;direction:ltr;unicode-bidi:isolate;text-align:start">{{ affordTotalL }}</span>
                    </span>
                    <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="#716D67" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="flex:none;transform:scaleX({{ flip }})"><path d="M9 5l7 7-7 7"></path></svg>
                  </button>
                </div>
                <button onClick="{{ startRoadmap }}" style="width:100%;text-align:start;border:none;cursor:pointer;border-radius:20px;padding:22px;background:{{ grad }};box-shadow:0 8px 28px rgba(255,107,26,.35);font-family:{{ ff }};letter-spacing:{{ ls }};margin-bottom:12px">
                  <span style="display:block;font-size:10.5px;font-weight:700;color:rgba(255,255,255,.8);line-height:1;margin-bottom:12px">{{ t.roadmapCtaEyebrow }}</span>
                  <span style="display:block;font-family:{{ ffDisp }};font-weight:700;font-size:24px;line-height:{{ lhTight }};color:#fff;margin-bottom:8px">{{ t.roadmapCtaTitle }}</span>
                  <span style="display:block;font-size:13.5px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.9);margin-bottom:18px">{{ t.roadmapFunnelBody }}</span>
                  <span style="display:inline-flex;align-items:center;gap:8px;background:#fff;color:#1B1B1B;border-radius:12px;padding:12px 18px;font-size:13px;font-weight:700">{{ t.roadmapCtaAction }}<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M4 12h15"></path><path d="M13 6l6 6-6 6"></path></svg></span>
                </button>

                <div style="display:grid;gap:10px">
                  <div>
                    <div style="font-size:11px;font-weight:600;color:#FF6B1A;line-height:1;margin:10px 0 14px">{{ t.tileCountries }}</div>
                    <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:10px">
                      <sc-for list="{{ countriesTop }}" as="c" hint-placeholder-count="4">
                        <button onClick="{{ c.open }}" style="text-align:start;background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:13px;cursor:pointer;box-shadow:0 1px 3px rgba(0,0,0,.05);font-family:{{ ff }};letter-spacing:{{ ls }}">
                          <span role="img" aria-label="{{ c.name }}" style="display:block;width:34px;height:24px;border-radius:4px;border:1px solid #E7E2DA;background:{{ c.bg }};margin-bottom:9px"></span>
                          <span style="display:block;font-size:12.5px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ c.name }}</span>
                          <span style="display:block;font-size:10px;font-weight:800;color:#716D67;margin-top:4px;direction:ltr;unicode-bidi:isolate;text-align:start">{{ c.exam }}</span>
                        </button>
                      </sc-for>
                    </div>
                    <button onClick="{{ openCountries }}" style="width:100%;height:46px;border:1.5px solid #E7E2DA;border-radius:12px;background:#fff;color:#1B1B1B;font-size:12.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ moreCountriesL }}</button>
                  </div>
                </div>
              </div>
            </div>
          </sc-if>

          <sc-if value="{{ isCourses }}" hint-placeholder-val="{{ false }}">
            <div>
              <sc-if value="{{ isCourseHub }}" hint-placeholder-val="{{ true }}">
                <div>
                  <div style="background:#1B1B1B;padding:18px 20px 26px">
                    <div style="font-size:11px;font-weight:600;color:#FFC62E;line-height:1.4;margin-bottom:12px">{{ t.coursesEyebrow }}</div>
                    <div style="font-family:{{ ffDisp }};font-weight:700;font-size:25px;line-height:{{ lhTight }};color:#fff;margin-bottom:10px">{{ t.coursesTitle }}</div>
                    <div style="font-size:13.5px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.65)">{{ t.pickDept }}</div>
                  </div>
                  <div style="padding:20px 20px 0;display:grid;gap:10px">
                    <button onClick="{{ openReview }}" style="display:flex;align-items:center;justify-content:space-between;gap:12px;background:#1B1B1B;border:none;border-radius:18px;padding:16px;cursor:pointer;text-align:start;font-family:{{ ff }};letter-spacing:{{ ls }}">
                      <span style="min-width:0">
                        <span style="display:block;font-size:10px;font-weight:800;color:#FFC62E;letter-spacing:{{ lsE }};margin-bottom:7px">{{ reviewStreakL }}</span>
                        <span style="display:block;font-size:14px;font-weight:600;line-height:{{ lhSnug }};color:#fff">{{ reviewDueL }}</span>
                      </span>
                      <span style="flex:none;font-family:{{ ffDisp }};font-weight:700;font-size:18px;color:#FFC62E;direction:ltr">{{ reviewPct }}%</span>
                    </button>
                    <button onClick="{{ openTracks }}" style="display:flex;align-items:center;justify-content:space-between;gap:12px;background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:16px;cursor:pointer;text-align:start;font-family:{{ ff }};letter-spacing:{{ ls }}">
                      <span style="min-width:0">
                        <span style="display:block;font-size:14px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ tracksTitle }}</span>
                        <span style="display:block;font-size:11.5px;font-weight:500;color:#716D67;margin-top:3px">{{ t.pickDept }}</span>
                      </span>
                      <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="#716D67" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="flex:none;transform:scaleX({{ flip }})"><path d="M9 5l7 7-7 7"></path></svg>
                    </button>
                  </div>
                  <div style="padding:20px;display:grid;gap:12px">
                    <sc-for list="{{ deptCards }}" as="d" hint-placeholder-count="3">
                      <button onClick="{{ d.go }}" style="text-align:start;border:none;border-radius:20px;padding:0;overflow:hidden;cursor:pointer;box-shadow:0 1px 3px rgba(0,0,0,.05);font-family:{{ ff }};letter-spacing:{{ ls }};background:#fff">
                        <span style="display:block;height:92px;background:{{ d.art }};position:relative">
                          <span style="position:absolute;inset-inline-start:14px;bottom:12px;font-family:{{ ffDisp }};font-weight:700;font-size:20px;color:#fff">{{ d.title }}</span>
                          <span style="position:absolute;inset-inline-end:14px;bottom:14px;font-size:10.5px;font-weight:700;color:#fff;background:rgba(255,255,255,.2);padding:5px 9px;border-radius:999px">{{ d.count }}</span>
                        </span>
                        <span style="display:block;padding:14px 16px;font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67">{{ d.blurb }}</span>
                      </button>
                    </sc-for>
                  </div>
                </div>
              </sc-if>

              <sc-if value="{{ isCourseList }}" hint-placeholder-val="{{ false }}">
                <div>
                  <div style="background:#1B1B1B;padding:12px 14px 22px">
                    <button onClick="{{ backToHub2 }}" aria-label="{{ t.back }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#fff;display:flex;align-items:center;justify-content:center;margin-bottom:4px">
                      <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                    </button>
                    <div style="padding:0 6px;font-family:{{ ffDisp }};font-weight:700;font-size:24px;line-height:{{ lhTight }};color:#fff">{{ deptTitle }}</div>
                  </div>
                  <div style="padding:16px 0 4px">
                    <div style="font-size:10.5px;font-weight:700;color:#716D67;padding:0 20px;margin-bottom:9px;line-height:1.4">{{ t.filterBy }}</div>
                    <div style="display:flex;gap:8px;overflow-x:auto;padding:0 20px;scrollbar-width:thin">
                      <sc-for list="{{ fmtChips }}" as="chip" hint-placeholder-count="4">
                        <button onClick="{{ chip.onPick }}" style="flex:none;border-radius:999px;min-height:44px;padding:8px 12px;cursor:pointer;background:{{ chip.bg }};color:{{ chip.fg }};border:1.5px solid {{ chip.border }};font-size:11.5px;font-weight:600;font-family:{{ ff }};letter-spacing:{{ ls }};white-space:nowrap">{{ chip.label }}</button>
                      </sc-for>
                    </div>
                    <div style="font-size:12px;font-weight:700;color:#716D67;padding:14px 20px 0">{{ foundLabel }}</div>
                  </div>
                  <div style="padding:10px 20px 30px;display:grid;gap:14px">
                    <sc-for list="{{ courses }}" as="c" hint-placeholder-count="4">
                      <button onClick="{{ c.open }}" style="text-align:start;background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:0;overflow:hidden;cursor:pointer;box-shadow:0 1px 3px rgba(0,0,0,.05);font-family:{{ ff }};letter-spacing:{{ ls }};transition:transform .15s cubic-bezier(.4,0,.2,1),box-shadow .15s cubic-bezier(.4,0,.2,1)" style-active="transform:scale(.98);box-shadow:0 8px 28px rgba(0,0,0,.1)">
                        <span style="display:block;height:104px;background:{{ c.art }};position:relative">
                          <span style="position:absolute;inset-inline-start:12px;top:12px;background:{{ c.fmtBg }};color:{{ c.fmtFg }};font-size:9.5px;font-weight:800;letter-spacing:{{ lsF }};padding:5px 9px;border-radius:6px">{{ c.fmt }}</span>
                          <span style="position:absolute;inset-inline-start:12px;bottom:12px;color:#fff;font-size:11px;font-weight:700">{{ c.cat }}</span>
                        </span>
                        <span style="display:block;padding:16px">
                          <span style="display:block;font-size:15px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B;margin-bottom:6px">{{ c.title }}</span>
                          <span style="display:block;font-size:12px;font-weight:500;color:#716D67;margin-bottom:10px">{{ c.tutor }}</span>
                          <span style="display:flex;align-items:center;gap:9px;margin-bottom:12px;font-size:11.5px;font-weight:600;color:#716D67">
                            <span style="color:#FFAA18;direction:ltr;unicode-bidi:isolate">★ {{ c.rating }}</span>
                            <span style="direction:ltr;unicode-bidi:isolate">{{ c.count }}</span>
                            <span style="width:3px;height:3px;border-radius:50%;background:#E7E2DA"></span>
                            <span style="direction:ltr;unicode-bidi:isolate">{{ c.hours }}</span>
                            <sc-if value="{{ c.acc }}" hint-placeholder-val="{{ false }}">
                              <span style="font-size:9.5px;font-weight:700;color:#2D9B68;background:rgba(45,155,104,.1);padding:4px 7px;border-radius:999px">{{ c.accLabel }}</span>
                            </sc-if>
                          </span>
                          <span style="display:flex;align-items:center;justify-content:space-between;gap:10px;padding-top:12px;border-top:1px solid #E7E2DA">
                            <span style="display:flex;align-items:center;gap:6px;font-size:11.5px;font-weight:700;color:{{ c.planFg }}">
                              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" style="flex:none">
                                <path d="{{ c.planIcon }}"></path>
                              </svg>
                              {{ c.planLabel }}
                            </span>
                            <span style="font-size:12.5px;font-weight:700;color:{{ c.ctaFg }};background:{{ c.ctaBg }};padding:8px 14px;border-radius:10px">{{ c.ctaLabel }}</span>
                          </span>
                        </span>
                      </button>
                    </sc-for>
                  </div>
                </div>
              </sc-if>

              <sc-if value="{{ isCourseDetail }}" hint-placeholder-val="{{ false }}">
                <div>
                  <div style="height:180px;background:{{ course.art }};position:relative">
                    <button onClick="{{ openCourseList }}" aria-label="{{ t.back }}" style="position:absolute;top:10px;inset-inline-start:8px;width:44px;height:44px;background:rgba(0,0,0,.3);border:none;border-radius:999px;cursor:pointer;color:#fff;display:flex;align-items:center;justify-content:center">
                      <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                    </button>
                    <button onClick="{{ openPlayer }}" aria-label="{{ course.cta }}" style="position:absolute;inset:0;margin:auto;width:64px;height:64px;border-radius:999px;background:rgba(255,255,255,.92);border:none;cursor:pointer;display:flex;align-items:center;justify-content:center;color:#1B1B1B">
                      <svg width="26" height="26" viewBox="0 0 24 24" fill="currentColor" style="transform:scaleX({{ flip }})"><path d="M8 5l12 7-12 7z"></path></svg>
                    </button>
                  </div>
                  <div style="padding:20px 20px 26px">
                    <div style="font-family:{{ ffDisp }};font-weight:700;font-size:23px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:10px">{{ course.title }}</div>
                    <div style="display:flex;align-items:center;gap:9px;flex-wrap:wrap;font-size:12px;font-weight:600;color:#716D67;margin-bottom:12px">
                      <span>{{ course.meta }}</span>
                      <span style="color:#FFAA18;direction:ltr;unicode-bidi:isolate">★ {{ course.rating }}</span>
                      <span style="direction:ltr;unicode-bidi:isolate">{{ course.count }}</span>
                    </div>
                    <p style="font-size:13.5px;font-weight:400;line-height:{{ lhBody }};color:#1B1B1B;margin:0 0 18px">{{ course.blurb }}</p>
                    <div style="display:flex;align-items:center;gap:8px;margin-bottom:18px;background:{{ course.planBg }};border-radius:12px;padding:12px 14px">
                      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="{{ course.planFg }}" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" style="flex:none">
                        <path d="{{ course.planIcon }}"></path>
                      </svg>
                      <span style="font-size:12.5px;font-weight:700;color:{{ course.planFg }};line-height:{{ lhSnug }}">{{ course.planLabel }}</span>
                    </div>
                    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:6px 16px;margin-bottom:22px">
                      <div style="padding:11px 0;border-bottom:1px solid #E7E2DA;font-size:12.5px;font-weight:500;color:#1B1B1B">{{ t.incLifetime }}</div>
                      <div style="padding:11px 0;border-bottom:1px solid #E7E2DA;font-size:12.5px;font-weight:500;color:#1B1B1B">{{ t.incHandouts }}</div>
                      <div style="padding:11px 0;border-bottom:1px solid #E7E2DA;font-size:12.5px;font-weight:500;color:#1B1B1B">{{ t.incCert }}</div>
                      <div style="padding:11px 0;font-size:12.5px;font-weight:500;color:#1B1B1B">{{ t.incCpd }}</div>
                    </div>
                    <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:10px;line-height:1.4">{{ t.whatYouLearn }}</div>
                    <div style="display:grid;gap:9px;margin-bottom:22px">
                      <sc-for list="{{ learnPoints }}" as="lp" hint-placeholder-count="4">
                        <div style="display:flex;gap:10px;align-items:flex-start">
                          <span style="flex:none;color:#2D9B68;margin-top:2px"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="M5 13l4.5 4.5L19 7"></path></svg></span>
                          <span style="font-size:13px;font-weight:400;line-height:{{ lhBody }};color:#1B1B1B">{{ lp }}</span>
                        </div>
                      </sc-for>
                    </div>

                    <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:10px;line-height:1.4">{{ t.instructorLabel }}</div>
                    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:16px;display:flex;gap:13px;align-items:center;margin-bottom:22px">
                      <span role="img" aria-label="{{ course.tutor }}" style="flex:none;width:50px;height:50px;border-radius:999px;border:1.5px solid #E7E2DA;background:#F5F2EC center/cover no-repeat url(https://i.pravatar.cc/240?img=47)"></span>
                      <span style="flex:1;min-width:0">
                        <span style="display:block;font-size:14px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ course.tutor }}</span>
                        <span style="display:block;font-size:12px;font-weight:400;line-height:{{ lhSnug }};color:#716D67;margin-top:4px">{{ course.bio }}</span>
                      </span>
                    </div>
                    <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:12px;line-height:1.4">{{ t.curriculum }}</div>
                    <div style="display:grid;gap:12px;margin-bottom:22px">
                      <sc-for list="{{ modules }}" as="m" hint-placeholder-count="3">
                        <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:6px 16px">
                          <div style="padding:13px 0;border-bottom:1px solid #E7E2DA;font-size:12.5px;font-weight:700;color:#1B1B1B">{{ m.title }}</div>
                          <sc-for list="{{ m.lessons }}" as="l" hint-placeholder-count="3">
                            <div style="display:flex;align-items:center;gap:10px;padding:12px 0;border-bottom:1px solid #E7E2DA">
                              <span style="flex:1;min-width:0;font-size:12.5px;font-weight:500;line-height:{{ lhSnug }};color:#1B1B1B">{{ l.title }}</span>
                              <sc-if value="{{ l.free }}" hint-placeholder-val="{{ false }}">
                                <span style="flex:none;font-size:9.5px;font-weight:800;letter-spacing:{{ lsB }};color:#2D9B68;background:rgba(45,155,104,.1);padding:4px 7px;border-radius:5px">{{ l.freeLabel }}</span>
                              </sc-if>
                              <span style="flex:none;font-size:11px;font-weight:600;color:#716D67;direction:ltr;unicode-bidi:isolate">{{ l.mins }}</span>
                            </div>
                          </sc-for>
                        </div>
                      </sc-for>
                    </div>

                    <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px">
                      <button onClick="{{ openFlash }}" style="height:52px;border-radius:14px;border:1.5px solid #E7E2DA;background:#fff;color:#1B1B1B;font-size:13px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.flashcards }}</button>
                      <button onClick="{{ openQuiz }}" style="height:52px;border-radius:14px;border:1.5px solid #E7E2DA;background:#fff;color:#1B1B1B;font-size:13px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.quiz }}</button>
                    </div>
                  </div>
                  <div style="padding:0 20px 26px">
                    <sc-if value="{{ course.locked }}" hint-placeholder-val="{{ false }}">
                      <div style="background:#F5F2EC;border-radius:14px;padding:15px 16px;display:flex;gap:11px;align-items:flex-start;margin-bottom:12px">
                        <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="#716D67" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" style="flex:none;margin-top:2px"><rect x="5" y="11" width="14" height="9" rx="2"></rect><path d="M8 11V8a4 4 0 0 1 8 0v3"></path></svg>
                        <span style="font-size:12.5px;font-weight:500;line-height:{{ lhBody }};color:#716D67">{{ course.lockNote }}</span>
                      </div>
                    </sc-if>
                    <sc-if value="{{ course.locked }}" hint-placeholder-val="{{ false }}">
                      <div>
                        <div style="background:#F5F2EC;border-radius:14px;padding:14px 15px;font-size:12px;font-weight:500;line-height:{{ lhBody }};color:#6B6862;margin-bottom:12px">{{ course.lockNote }}</div>
                        <button onClick="{{ openStore }}" style="width:100%;height:54px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};transition:transform .15s cubic-bezier(.4,0,.2,1)" style-active="transform:scale(.97)">{{ course.cta }} · {{ course.priceL }}</button>
                      </div>
                    </sc-if>
                    <sc-if value="{{ course.unlocked }}" hint-placeholder-val="{{ true }}">
                      <button onClick="{{ openPlayer }}" style="width:100%;height:54px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};transition:transform .15s cubic-bezier(.4,0,.2,1)" style-active="transform:scale(.97)">{{ course.cta }}</button>
                    </sc-if>
                  </div>
                </div>
              </sc-if>

              <sc-if value="{{ isCoursePlayer }}" hint-placeholder-val="{{ false }}">
                <div>
                  <div style="background:#000;aspect-ratio:16/9;position:relative;display:flex;align-items:center;justify-content:center">
                    <button onClick="{{ backToDetail }}" aria-label="{{ t.back }}" style="position:absolute;top:10px;inset-inline-start:8px;width:44px;height:44px;background:rgba(255,255,255,.14);border:none;border-radius:999px;cursor:pointer;color:#fff;display:flex;align-items:center;justify-content:center">
                      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M6 6l12 12M18 6L6 18"></path></svg>
                    </button>
                    <div style="width:58px;height:58px;border-radius:999px;background:rgba(255,255,255,.9);display:flex;align-items:center;justify-content:center;color:#1B1B1B">
                      <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor"><path d="M9 6h3v12H9zM14 6h3v12h-3z"></path></svg>
                    </div>
                    <div style="position:absolute;inset-inline:14px;bottom:12px">
                      <div style="height:4px;border-radius:2px;background:rgba(255,255,255,.25);overflow:hidden;margin-bottom:8px"><div style="height:100%;width:38%;background:{{ grad }}"></div></div>
                      <div style="display:flex;justify-content:space-between;font-size:10.5px;font-weight:600;color:rgba(255,255,255,.75);direction:ltr"><span>7:12</span><span>18:40</span></div>
                    </div>
                  </div>
                  <div style="padding:18px 20px 30px">
                    <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:8px;line-height:1.4">{{ t.nowPlaying }}</div>
                    <div style="font-family:{{ ffDisp }};font-weight:700;font-size:20px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:18px">{{ course.title }}</div>
                    <div style="display:grid;gap:10px;margin-bottom:22px">
                      <button onClick="{{ openFlash }}" style="display:flex;align-items:center;justify-content:space-between;gap:12px;background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:16px;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};text-align:start">
                        <span style="font-size:13.5px;font-weight:600;color:#1B1B1B">{{ t.flashcards }}</span>
                        <span style="color:#716D67"><svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M9 5l7 7-7 7"></path></svg></span>
                      </button>
                      <button onClick="{{ openQuiz }}" style="display:flex;align-items:center;justify-content:space-between;gap:12px;background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:16px;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};text-align:start">
                        <span style="font-size:13.5px;font-weight:600;color:#1B1B1B">{{ t.quiz }}</span>
                        <span style="color:#716D67"><svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M9 5l7 7-7 7"></path></svg></span>
                      </button>
                      <button onClick="{{ openHandoutsNav }}" style="display:flex;align-items:center;justify-content:space-between;gap:12px;width:100%;background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:16px;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};text-align:start">
                        <span style="font-size:13.5px;font-weight:600;color:#1B1B1B">{{ t.handouts }}</span>
                        <span style="font-size:11px;font-weight:700;color:#716D67;background:#F5F2EC;padding:5px 9px;border-radius:999px;direction:ltr;unicode-bidi:isolate">PDF · 3</span>
                      </button>
                    </div>
                    <div style="background:#F5F2EC;border-radius:14px;padding:14px 16px;font-size:12px;font-weight:500;line-height:{{ lhBody }};color:#716D67">{{ t.playerNote }}</div>
                  </div>
                </div>
              </sc-if>

              <sc-if value="{{ isFlash }}" hint-placeholder-val="{{ false }}">
                <div style="padding:14px 20px 30px">
                  <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:20px">
                    <button onClick="{{ backToDetail }}" aria-label="{{ t.back }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center">
                      <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                    </button>
                    <span style="font-size:12px;font-weight:700;color:#716D67;direction:ltr;unicode-bidi:isolate">{{ cardPos }}</span>
                  </div>
                  <button onClick="{{ flip }}" style="width:100%;min-height:260px;background:#fff;border:1.5px solid #E7E2DA;border-radius:24px;padding:26px 22px;cursor:pointer;display:flex;flex-direction:column;justify-content:center;gap:14px;box-shadow:0 3px 12px rgba(0,0,0,.07);font-family:{{ ff }};letter-spacing:{{ ls }};text-align:center">
                    <span style="font-size:10.5px;font-weight:700;color:#FF6B1A">{{ cardSide }}</span>
                    <span style="font-size:18px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ cardFace }}</span>
                    <span style="font-size:11px;font-weight:500;color:#716D67">{{ t.tapToFlip }}</span>
                  </button>
                  <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-top:20px">
                    <button onClick="{{ cardAgain }}" style="height:52px;border-radius:14px;border:1.5px solid #FF2D32;background:rgba(255,45,50,.08);color:#FF2D32;font-size:13.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.again }}</button>
                    <button onClick="{{ cardGot }}" style="height:52px;border-radius:14px;border:1.5px solid #2D9B68;background:rgba(45,155,104,.1);color:#2D9B68;font-size:13.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.gotIt }}</button>
                  </div>
                </div>
              </sc-if>

              <sc-if value="{{ isQuiz }}" hint-placeholder-val="{{ false }}">
                <div style="padding:14px 20px 30px">
                  <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:18px">
                    <button onClick="{{ backToDetail }}" aria-label="{{ t.back }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center">
                      <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                    </button>
                    <span style="font-size:12px;font-weight:700;color:#716D67;direction:ltr;unicode-bidi:isolate">{{ quizPos }}</span>
                  </div>
                  <div style="font-size:17px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B;margin-bottom:20px">{{ quizQ }}</div>
                  <div style="display:grid;gap:10px;margin-bottom:20px">
                    <sc-for list="{{ quizOpts }}" as="o" hint-placeholder-count="4">
                      <button onClick="{{ o.pick }}" style="width:100%;text-align:start;background:{{ o.bg }};border:1.5px solid {{ o.bd }};color:{{ o.fg }};border-radius:14px;padding:15px 16px;cursor:pointer;font-size:13.5px;font-weight:500;line-height:{{ lhSnug }};font-family:{{ ff }};letter-spacing:{{ ls }}">{{ o.label }}</button>
                    </sc-for>
                  </div>
                  <sc-if value="{{ quizAnswered }}" hint-placeholder-val="{{ false }}">
                    <div>
                      <div style="display:inline-block;font-size:11px;font-weight:700;color:{{ quizVerdictFg }};background:{{ quizVerdictBg }};padding:6px 11px;border-radius:999px;margin-bottom:12px">{{ quizVerdict }}</div>
                      <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:16px;font-size:13px;font-weight:400;line-height:{{ lhBody }};color:#1B1B1B;margin-bottom:14px">{{ quizWhy }}</div>
                      <button onClick="{{ quizNext }}" style="width:100%;height:52px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.nextQuestion }}</button>
                    </div>
                  </sc-if>
                </div>
              </sc-if>

            </div>
          </sc-if>

          <sc-if value="{{ isMasters }}" hint-placeholder-val="{{ false }}">
            <div>
              <sc-if value="{{ isMastersList }}" hint-placeholder-val="{{ true }}">
                <div>
                  <div style="background:#1B1B1B;padding:18px 20px 0">
                    <div style="display:flex;align-items:flex-end;justify-content:space-between;gap:12px;margin-bottom:14px">
                      <div style="min-width:0">
                        <div style="font-size:11px;font-weight:600;color:#FFC62E;line-height:1.4;margin-bottom:8px">{{ t.mastersEyebrow }}</div>
                        <div style="font-family:{{ ffDisp }};font-weight:700;font-size:25px;line-height:{{ lhTight }};color:#fff">{{ t.mastersTitle }}</div>
                      </div>
                    </div>
                    <div style="background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.12);border-radius:12px;height:46px;display:flex;align-items:center;gap:10px;padding:0 14px;margin-bottom:14px">
                      <span style="color:rgba(255,255,255,.5);flex:none"><svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="6.5"></circle><path d="M16 16l4.5 4.5"></path></svg></span>
                      <input value="{{ searchValue }}" onChange="{{ onSearch }}" placeholder="{{ t.searchPlaceholder }}" aria-label="{{ t.searchPlaceholder }}" style="flex:1;min-width:0;background:transparent;border:none;outline:none;color:#fff;font-size:13.5px;font-family:{{ ff }};letter-spacing:{{ ls }}">
                    </div>
                    <div style="display:flex;gap:8px;margin-bottom:10px">
                      <button onClick="{{ openTracker }}" style="flex:1;min-height:44px;border-radius:12px;border:1px solid rgba(255,255,255,.16);background:rgba(255,255,255,.08);color:#fff;font-size:11.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ trackerTitle }}</button>
                      <button onClick="{{ openMatch }}" style="flex:1;min-height:44px;border-radius:12px;border:1px solid rgba(255,255,255,.16);background:rgba(255,255,255,.08);color:#fff;font-size:11.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ matchTitle }}</button>
                    </div>
                    <button onClick="{{ openAlerts }}" style="width:100%;min-height:44px;margin-bottom:10px;border-radius:12px;border:1px solid rgba(255,198,46,.4);background:rgba(255,198,46,.12);color:#FFC62E;font-size:11.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ alTitle }}</button>
                    <div style="display:flex;gap:6px">
                      <sc-for list="{{ quickTabs }}" as="qt" hint-placeholder-count="4">
                        <button onClick="{{ qt.go }}" style="flex:1;min-width:0;border:none;border-radius:12px;cursor:pointer;background:{{ qt.bg }};color:{{ qt.fg }};font-family:{{ ff }};letter-spacing:{{ ls }};padding:9px 4px;display:flex;flex-direction:column;align-items:center;gap:3px">
                          <span style="font-size:15px;font-weight:800;line-height:1">{{ qt.count }}</span>
                          <span style="font-size:9.5px;font-weight:600;line-height:1.3;text-align:center">{{ qt.label }}</span>
                        </button>
                      </sc-for>
                    </div>
                    <div style="font-size:11.5px;font-weight:500;line-height:{{ lhSnug }};color:rgba(255,255,255,.55);padding:12px 0 14px">{{ quickHint }}</div>
                  </div>
                  <div style="display:flex;align-items:center;gap:10px;padding:14px 20px 12px;border-bottom:1px solid #E7E2DA">
                    <button onClick="{{ openSheet }}" style="flex:none;height:38px;padding:0 14px;border-radius:11px;cursor:pointer;background:#1B1B1B;color:#fff;border:none;font-size:12.5px;font-weight:700;font-family:{{ ff }};letter-spacing:{{ ls }};display:flex;align-items:center;gap:7px">
                      <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M4 6h16M7 12h10M10 18h4"></path></svg>{{ t.filters }} {{ filterCount }}
                    </button>
                    <span style="flex:1;min-width:0;font-size:12.5px;font-weight:600;color:#716D67;text-align:end">{{ resultCount }}</span>
                  </div>
                  <sc-if value="{{ mPager }}" hint-placeholder-val="{{ true }}">
                    <div style="padding:0 20px 6px">
                      <div style="display:flex;align-items:center;justify-content:space-between;gap:10px;margin-bottom:9px">
                        <span style="font-size:11px;font-weight:700;color:#1B1B1B;direction:ltr;unicode-bidi:isolate;text-align:start">{{ mRangeL }}</span>
                        <span style="font-size:11px;font-weight:600;color:#716D67;direction:ltr;unicode-bidi:isolate">{{ mPageL }}</span>
                      </div>
                      <div style="display:flex;align-items:center;gap:7px">
                        <button onClick="{{ mPrev }}" style="flex:none;min-height:44px;padding:0 13px;border-radius:11px;border:1.5px solid #E7E2DA;background:{{ mPrevBg }};color:{{ mPrevFg }};font-size:11.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ mPrevL }}</button>
                        <div style="flex:1;display:flex;gap:6px;justify-content:center;overflow-x:auto;scrollbar-width:none">
                          <sc-for list="{{ mPageDots }}" as="p" hint-placeholder-count="4">
                            <button onClick="{{ p.pick }}" aria-label="{{ p.label }}" style="flex:none;min-width:44px;min-height:44px;border-radius:11px;border:1.5px solid {{ p.bd }};background:{{ p.bg }};color:{{ p.fg }};font-size:12px;font-weight:800;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};direction:ltr">{{ p.label }}</button>
                          </sc-for>
                        </div>
                        <button onClick="{{ mNext }}" style="flex:none;min-height:44px;padding:0 13px;border-radius:11px;border:1.5px solid #E7E2DA;background:{{ mNextBg }};color:{{ mNextFg }};font-size:11.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ mNextL }}</button>
                      </div>
                    </div>
                  </sc-if>
                  <div style="display:flex;gap:8px;overflow-x:auto;padding:12px 20px 4px;scrollbar-width:thin">
                    <sc-for list="{{ sortChips }}" as="chip" hint-placeholder-count="4">
                      <button onClick="{{ chip.onPick }}" style="flex:none;border-radius:999px;min-height:44px;padding:8px 12px;cursor:pointer;background:{{ chip.bg }};color:{{ chip.fg }};border:1.5px solid {{ chip.border }};font-size:11.5px;font-weight:600;font-family:{{ ff }};letter-spacing:{{ ls }};white-space:nowrap">{{ chip.label }}</button>
                    </sc-for>
                  </div>
                  <div style="padding:0 20px 14px">
                    <a href="Ejadah%20App%20%E2%80%94%20Programme%20Profile.dc.html" style="display:block;text-decoration:none;background:#1B1B1B;border-radius:20px;padding:18px;position:relative;overflow:hidden">
                      <span style="position:absolute;inset:0;background:radial-gradient(220px 120px at 88% 0%,rgba(255,198,46,.18),transparent 70%);pointer-events:none"></span>
                      <span style="position:relative;display:block">
                        <span style="display:flex;align-items:center;gap:8px;margin-bottom:12px;flex-wrap:wrap">
                          <img src="https://flagcdn.com/w80/gb.png" alt="United Kingdom" style="width:36px;height:25px;border-radius:4px;object-fit:cover;border:1px solid rgba(255,255,255,.25)">
                          <span style="font-size:10px;font-weight:700;letter-spacing:{{ lsF }};color:#1B1B1B;background:#FFC62E;padding:4px 8px;border-radius:999px;line-height:1">FULL PROFILE</span>
                          <span style="font-size:10px;font-weight:700;letter-spacing:{{ lsF }};color:rgba(255,255,255,.75);background:rgba(255,255,255,.1);padding:4px 8px;border-radius:999px;line-height:1">#8 QS DENTISTRY</span>
                        </span>
                        <span style="display:block;font-size:12.5px;font-weight:600;color:#FFC62E;margin-bottom:4px">King's College London</span>
                        <span style="display:block;font-family:{{ ffDisp }};font-weight:700;font-size:22px;line-height:{{ lhTight }};color:#fff;margin-bottom:8px"><span style="direction:ltr;unicode-bidi:isolate;display:inline-block">MSc Endodontology</span></span>
                        <span style="display:block;font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.65);margin-bottom:14px">{{ t.kingsBlurb }}</span>
                        <span style="display:flex;align-items:center;justify-content:space-between;gap:12px">
                          <span style="font-size:11.5px;font-weight:600;color:rgba(255,255,255,.55);direction:ltr;unicode-bidi:isolate">£26,000/yr · 1 year FT · ~15%</span>
                          <span style="display:inline-flex;align-items:center;gap:6px;font-size:12.5px;font-weight:700;color:#FFC62E">{{ t.viewDetails }}<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M9 5l7 7-7 7"></path></svg></span>
                        </span>
                      </span>
                    </a>
                  </div>
                  <sc-if value="{{ hasResults }}" hint-placeholder-val="{{ true }}">
                    <div style="padding:0 20px 30px;display:grid;gap:12px">
                      <sc-for list="{{ results }}" as="p" hint-placeholder-count="3">
                        <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:16px;box-shadow:0 1px 3px rgba(0,0,0,.05)">
                          <div style="display:flex;gap:12px;align-items:flex-start;margin-bottom:12px">
                            <div role="img" aria-label="{{ p.countryLabel }}" style="flex:none;width:40px;height:28px;border-radius:5px;border:1px solid #E7E2DA;background:#F5F2EC center/cover no-repeat url({{ p.flagSrc }})"></div>
                            <div style="flex:1;min-width:0">
                              <div style="font-size:14.5px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B"><span style="direction:ltr;unicode-bidi:isolate;display:inline-block">{{ p.uni }}</span></div>
                              <div style="font-size:12px;font-weight:500;color:#716D67;margin-top:2px;line-height:{{ lhSnug }}">{{ p.countryLabel }} · <span style="direction:ltr;unicode-bidi:isolate;display:inline-block">{{ p.city }}</span></div>
                            </div>
                            <button onClick="{{ p.onSave }}" aria-label="{{ t.saveProg }}" style="flex:none;width:44px;height:44px;margin:-8px -8px 0 0;background:none;border:none;cursor:pointer;display:flex;align-items:center;justify-content:center">
                              <svg width="19" height="19" viewBox="0 0 24 24" fill="{{ p.savedFill }}" stroke="{{ p.savedStroke }}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20s-7-4.5-7-9.2A4 4 0 0 1 12 8a4 4 0 0 1 7 2.8C19 15.5 12 20 12 20z"></path></svg>
                            </button>
                          </div>
                          <div style="font-size:13.5px;font-weight:400;line-height:{{ lhBody }};color:#1B1B1B;margin-bottom:12px"><span style="direction:ltr;unicode-bidi:isolate;display:inline-block">{{ p.name }}</span></div>
                          <div style="display:flex;flex-wrap:wrap;gap:7px;margin-bottom:14px">
                            <span style="font-size:11px;font-weight:700;color:#496FA8;background:rgba(73,111,168,.1);padding:5px 9px;border-radius:999px;line-height:1;direction:ltr;unicode-bidi:isolate">{{ p.degree }}</span>
                            <span style="font-size:11px;font-weight:600;color:#716D67;background:#F5F2EC;padding:5px 9px;border-radius:999px;line-height:1">{{ p.specLabel }}</span>
                            <span style="font-size:11px;font-weight:600;color:#716D67;background:#F5F2EC;padding:5px 9px;border-radius:999px;line-height:1;direction:ltr;unicode-bidi:isolate">{{ p.dur }}</span>
                            <span style="font-size:11px;font-weight:700;color:{{ p.stFg }};background:{{ p.stBg }};padding:5px 9px;border-radius:999px;line-height:1">{{ p.stText }}</span>
                          </div>
                          <div style="display:flex;align-items:center;justify-content:space-between;gap:10px">
                            <div>
                              <div style="font-family:{{ ffDisp }};font-weight:700;font-size:18px;line-height:1.2;color:#1B1B1B;direction:ltr;unicode-bidi:isolate;text-align:start">{{ p.cost }}</div>
                              <div style="font-size:10.5px;font-weight:500;color:#716D67;margin-top:3px;line-height:1.3">{{ p.usd }}</div>
                            </div>
                            <div style="display:flex;gap:8px">
                              <button onClick="{{ p.onCompare }}" aria-label="{{ t.compareMode }}" style="width:40px;height:40px;border-radius:12px;cursor:pointer;background:{{ p.cmpBg }};color:{{ p.cmpFg }};border:1.5px solid {{ p.cmpBorder }};font-size:15px;font-weight:700;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ p.cmpLabel }}</button>
                              <button onClick="{{ p.onOpen }}" style="height:40px;padding:0 14px;border-radius:12px;border:none;cursor:pointer;background:#1B1B1B;color:#fff;font-size:12px;font-weight:700;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.viewDetails }}</button>
                            </div>
                          </div>
                        </div>
                      </sc-for>
                    </div>
                  </sc-if>
                  <sc-if value="{{ noResults }}" hint-placeholder-val="{{ false }}">
                    <div style="padding:40px 28px;text-align:center">
                      <span style="color:#716D67;display:inline-block;margin-bottom:14px"><svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="6.5"></circle><path d="M16 16l4.5 4.5"></path></svg></span>
                      <div style="font-size:18px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B;margin-bottom:6px">{{ t.emptyMastersTitle }}</div>
                      <div style="font-size:13px;font-weight:400;line-height:{{ lhBody }};color:#716D67">{{ t.emptyMastersBody }}</div>
                    </div>
                  </sc-if>
                  <sc-if value="{{ truncated }}" hint-placeholder-val="{{ false }}">
                    <div style="padding:0 20px 24px;font-size:11.5px;font-weight:600;color:#716D67;text-align:center">{{ truncatedNote }}</div>
                  </sc-if>
                  <sc-if value="{{ sheetOpen }}" hint-placeholder-val="{{ false }}">
                    <div style="position:sticky;bottom:0;z-index:9">
                      <div style="background:#fff;border-top:1.5px solid #E7E2DA;border-radius:24px 24px 0 0;padding:14px 20px 22px;box-shadow:0 -12px 40px rgba(0,0,0,.18);animation:sheetUp .3s cubic-bezier(.4,0,.2,1)">
                        <div style="width:38px;height:4px;border-radius:2px;background:#E7E2DA;margin:0 auto 14px"></div>
                        <div style="display:flex;align-items:center;justify-content:space-between;gap:12px;margin-bottom:16px">
                          <span style="font-family:{{ ffDisp }};font-weight:700;font-size:19px;color:#1B1B1B">{{ t.filters }}</span>
                          <span style="display:flex;gap:8px">
                            <button onClick="{{ clearFilters }}" style="height:34px;padding:0 12px;border-radius:10px;border:1.5px solid #E7E2DA;background:#fff;color:#716D67;font-size:11.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.clearAll }}</button>
                            <button onClick="{{ closeSheet }}" style="height:34px;padding:0 14px;border:none;border-radius:10px;background:{{ grad }};color:#fff;font-size:11.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.apply }}</button>
                          </span>
                        </div>
                        <div style="max-height:330px;overflow-y:auto;scrollbar-width:thin;display:grid;gap:16px">
                          <div>
                            <div style="font-size:10.5px;font-weight:700;color:#716D67;margin-bottom:9px;line-height:1.4">{{ t.fSpecialty }}</div>
                            <div style="display:flex;flex-wrap:wrap;gap:7px">
                              <sc-for list="{{ specChips }}" as="chip" hint-placeholder-count="6">
                                <button onClick="{{ chip.onPick }}" style="border-radius:999px;min-height:44px;padding:8px 12px;cursor:pointer;background:{{ chip.bg }};color:{{ chip.fg }};border:1.5px solid {{ chip.border }};font-size:11.5px;font-weight:600;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ chip.label }}</button>
                              </sc-for>
                            </div>
                          </div>
                          <div>
                            <div style="font-size:10.5px;font-weight:700;color:#716D67;margin-bottom:9px;line-height:1.4">{{ t.fRegion }}</div>
                            <div style="display:flex;flex-wrap:wrap;gap:7px">
                              <sc-for list="{{ regionChips }}" as="chip" hint-placeholder-count="6">
                                <button onClick="{{ chip.onPick }}" style="border-radius:999px;min-height:44px;padding:8px 12px;cursor:pointer;background:{{ chip.bg }};color:{{ chip.fg }};border:1.5px solid {{ chip.border }};font-size:11.5px;font-weight:600;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ chip.label }}</button>
                              </sc-for>
                            </div>
                          </div>
                          <div>
                            <div style="font-size:10.5px;font-weight:700;color:#716D67;margin-bottom:9px;line-height:1.4">{{ t.fDegreeType }}</div>
                            <div style="display:flex;flex-wrap:wrap;gap:7px">
                              <sc-for list="{{ degreeChips }}" as="chip" hint-placeholder-count="5">
                                <button onClick="{{ chip.onPick }}" style="border-radius:999px;min-height:44px;padding:8px 12px;cursor:pointer;background:{{ chip.bg }};color:{{ chip.fg }};border:1.5px solid {{ chip.border }};font-size:11.5px;font-weight:600;font-family:{{ ff }};letter-spacing:{{ ls }};direction:ltr;unicode-bidi:isolate">{{ chip.label }}</button>
                              </sc-for>
                            </div>
                          </div>
                          <div>
                            <div style="font-size:10.5px;font-weight:700;color:#716D67;margin-bottom:9px;line-height:1.4">{{ t.fBudget }}</div>
                            <div style="display:flex;flex-wrap:wrap;gap:7px">
                              <sc-for list="{{ budgetChips }}" as="chip" hint-placeholder-count="4">
                                <button onClick="{{ chip.onPick }}" style="border-radius:999px;min-height:44px;padding:8px 12px;cursor:pointer;background:{{ chip.bg }};color:{{ chip.fg }};border:1.5px solid {{ chip.border }};font-size:11.5px;font-weight:600;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ chip.label }}</button>
                              </sc-for>
                            </div>
                          </div>
                          <div style="display:grid;gap:2px">
                            <sc-for list="{{ toggleRows }}" as="row" hint-placeholder-count="3">
                              <button onClick="{{ row.go }}" style="display:flex;align-items:center;justify-content:space-between;gap:12px;width:100%;background:none;border:none;border-top:1px solid #E7E2DA;padding:13px 0;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};text-align:start">
                                <span style="font-size:13px;font-weight:600;color:#1B1B1B">{{ row.label }}</span>
                                <span style="flex:none;width:42px;height:24px;border-radius:999px;background:{{ row.trackBg }};display:flex;align-items:center;padding:3px;box-sizing:border-box">
                                  <span style="width:18px;height:18px;border-radius:999px;background:#fff;margin-inline-start:{{ row.knob }};box-shadow:0 1px 3px rgba(0,0,0,.2)"></span>
                                </span>
                              </button>
                            </sc-for>
                          </div>
                        </div>
                      </div>
                    </div>
                  </sc-if>
                  <sc-if value="{{ compareVisible }}" hint-placeholder-val="{{ false }}">
                    <div style="position:sticky;bottom:0;margin:0 20px 20px;background:#1B1B1B;border-radius:16px;padding:12px 14px;display:flex;align-items:center;justify-content:space-between;gap:12px;box-shadow:0 8px 28px rgba(0,0,0,.25)">
                      <span style="font-size:12.5px;font-weight:600;color:rgba(255,255,255,.75)">{{ compareText }}</span>
                      <span style="display:flex;gap:8px">
                        <button onClick="{{ clearCompare }}" style="height:38px;padding:0 12px;border-radius:11px;background:transparent;border:1px solid rgba(255,255,255,.2);color:rgba(255,255,255,.75);font-size:12px;font-weight:600;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.clearAll }}</button>
                        <button onClick="{{ openCompare }}" style="height:38px;padding:0 16px;border-radius:11px;border:none;background:{{ grad }};color:#fff;font-size:12px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.compareCta }}</button>
                      </span>
                    </div>
                  </sc-if>
                </div>
              </sc-if>

              <sc-if value="{{ isMastersDetail }}" hint-placeholder-val="{{ false }}">
                <div>
                  <div style="background:#1B1B1B;padding:12px 14px 26px">
                    <button onClick="{{ closeDetail }}" aria-label="{{ t.back }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#fff;display:flex;align-items:center;justify-content:center;margin-bottom:6px">
                      <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                    </button>
                    <div style="padding:0 6px">
                      <div style="display:flex;align-items:center;gap:10px;margin-bottom:14px">
                        <div role="img" aria-label="{{ detail.countryLabel }}" style="width:40px;height:28px;border-radius:5px;border:1px solid rgba(255,255,255,.25);background:rgba(255,255,255,.1) center/cover no-repeat url({{ detail.flagSrc }})"></div>
                        <span style="font-size:11px;font-weight:700;color:#1B1B1B;background:#FFC62E;padding:5px 10px;border-radius:999px;line-height:1;direction:ltr;unicode-bidi:isolate">{{ detail.degree }}</span>
                        <span style="font-size:11px;font-weight:700;color:{{ detail.stFg }};background:{{ detail.stBg }};padding:5px 10px;border-radius:999px;line-height:1">{{ detail.stText }}</span>
                      </div>
                      <div style="font-family:{{ ffDisp }};font-weight:700;font-size:24px;line-height:{{ lhTight }};color:#fff;margin-bottom:6px"><span style="direction:ltr;unicode-bidi:isolate;display:inline-block">{{ detail.name }}</span></div>
                      <div style="font-size:14px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.7)"><span style="direction:ltr;unicode-bidi:isolate;display:inline-block">{{ detail.uni }}</span> · {{ detail.countryLabel }} · <span style="direction:ltr;unicode-bidi:isolate;display:inline-block">{{ detail.city }}</span></div>
                    </div>
                  </div>
                  <div style="padding:22px 20px 30px">
                    <div style="font-size:11px;font-weight:600;color:#FF6B1A;line-height:1;margin-bottom:14px">{{ t.keyFacts }}</div>
                    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:6px 16px;margin-bottom:20px">
                      <div style="display:flex;justify-content:space-between;gap:16px;padding:12px 0;border-bottom:1px solid #E7E2DA"><span style="font-size:12.5px;font-weight:500;color:#716D67">{{ t.fTuition }}</span><span style="font-size:13px;font-weight:600;color:#1B1B1B;text-align:end;direction:ltr;unicode-bidi:isolate">{{ detail.costLine }}</span></div>
                      <div style="display:flex;justify-content:space-between;gap:16px;padding:12px 0;border-bottom:1px solid #E7E2DA"><span style="font-size:12.5px;font-weight:500;color:#716D67">{{ t.fDuration }}</span><span style="font-size:13px;font-weight:600;color:#1B1B1B;text-align:end;direction:ltr;unicode-bidi:isolate">{{ detail.dur }}</span></div>
                      <div style="display:flex;justify-content:space-between;gap:16px;padding:12px 0;border-bottom:1px solid #E7E2DA"><span style="font-size:12.5px;font-weight:500;color:#716D67">{{ t.fLanguage }}</span><span style="font-size:13px;font-weight:600;color:#1B1B1B;text-align:end;direction:ltr;unicode-bidi:isolate">{{ detail.lang }}</span></div>
                      <div style="display:flex;justify-content:space-between;gap:16px;padding:12px 0;border-bottom:1px solid #E7E2DA"><span style="font-size:12.5px;font-weight:500;color:#716D67">{{ t.fIntake }}</span><span style="font-size:13px;font-weight:600;color:#1B1B1B;text-align:end;direction:ltr;unicode-bidi:isolate">{{ detail.intake }}</span></div>
                      <div style="display:flex;justify-content:space-between;gap:16px;padding:12px 0;border-bottom:1px solid #E7E2DA"><span style="font-size:12.5px;font-weight:500;color:#716D67">{{ t.fDeadline }}</span><span style="font-size:13px;font-weight:600;color:#1B1B1B;text-align:end;direction:ltr;unicode-bidi:isolate">{{ detail.deadline }}</span></div>
                      <div style="display:flex;justify-content:space-between;gap:16px;padding:12px 0;border-bottom:1px solid #E7E2DA"><span style="font-size:12.5px;font-weight:500;color:#716D67">{{ t.fIelts }}</span><span style="font-size:13px;font-weight:600;color:#1B1B1B;text-align:end;direction:ltr;unicode-bidi:isolate">{{ detail.ielts }}</span></div>
                      <div style="display:flex;justify-content:space-between;gap:16px;padding:12px 0;border-bottom:1px solid #E7E2DA"><span style="font-size:12.5px;font-weight:500;color:#716D67">{{ t.fGpa }}</span><span style="font-size:13px;font-weight:600;color:#1B1B1B;text-align:end">{{ detail.gpa }}</span></div>
                      <div style="display:flex;justify-content:space-between;gap:16px;padding:12px 0;border-bottom:1px solid #E7E2DA"><span style="font-size:12.5px;font-weight:500;color:#716D67">{{ t.fThesis }}</span><span style="font-size:13px;font-weight:600;color:#1B1B1B;text-align:end">{{ detail.thesis }}</span></div>
                      <div style="display:flex;justify-content:space-between;gap:16px;padding:12px 0;border-bottom:1px solid #E7E2DA"><span style="font-size:12.5px;font-weight:500;color:#716D67">{{ t.fInterview }}</span><span style="font-size:13px;font-weight:600;color:#1B1B1B;text-align:end">{{ detail.iv }}</span></div>
                      <div style="display:flex;justify-content:space-between;gap:16px;padding:12px 0"><span style="font-size:12.5px;font-weight:500;color:#716D67">{{ t.fScholarship }}</span><span style="font-size:13px;font-weight:600;color:#1B1B1B;text-align:end">{{ detail.sch }}</span></div>
                    </div>

                    <div style="background:#F5F2EC;border-radius:16px;padding:14px 16px;display:flex;gap:10px;align-items:flex-start">
                      <span style="color:#716D67;flex:none;margin-top:1px"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 4l9 16H3z"></path><path d="M12 10v4"></path></svg></span>
                      <span style="font-size:12.5px;font-weight:500;line-height:{{ lhBody }};color:#716D67">{{ t.sourceMissing }}</span>
                    </div>
                  </div>
                  <div style="padding:0 20px 26px;display:flex;gap:10px">
                    <button onClick="{{ detail.onSave }}" style="flex:none;width:52px;height:52px;border-radius:14px;border:1.5px solid #E7E2DA;background:#fff;cursor:pointer;display:flex;align-items:center;justify-content:center">
                      <svg width="20" height="20" viewBox="0 0 24 24" fill="{{ detail.savedFill }}" stroke="{{ detail.savedStroke }}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20s-7-4.5-7-9.2A4 4 0 0 1 12 8a4 4 0 0 1 7 2.8C19 15.5 12 20 12 20z"></path></svg>
                    </button>
                    <button onClick="{{ applyTap }}" style="flex:1;height:52px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.apply }}</button>
                  </div>
                </div>
              </sc-if>
            </div>
          </sc-if>

          <sc-if value="{{ isPeopleList }}" hint-placeholder-val="{{ false }}">
            <div>
              <div style="background:#1B1B1B;padding:12px 14px 24px">
                <button onClick="{{ backToHub }}" aria-label="{{ t.back }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#fff;display:flex;align-items:center;justify-content:center;margin-bottom:4px">
                  <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                </button>
                <div style="padding:0 6px">
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:25px;line-height:{{ lhTight }};color:#fff;margin-bottom:8px">{{ kindTitle }}</div>
                  <div style="font-size:13.5px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.65);margin-bottom:14px">{{ kindSub }}</div>
                  <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:8px;margin-bottom:14px">
                    <sc-for list="{{ tutorStats }}" as="s" hint-placeholder-count="4">
                      <div style="background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.1);border-radius:12px;padding:10px 6px;text-align:center">
                        <div style="font-family:{{ ffDisp }};font-weight:700;font-size:15px;color:#fff;direction:ltr;unicode-bidi:isolate">{{ s.v }}</div>
                        <div style="font-size:8.5px;font-weight:600;color:rgba(255,255,255,.5);margin-top:4px;line-height:1.4">{{ s.l }}</div>
                      </div>
                    </sc-for>
                  </div>
                  <div style="display:inline-block;font-size:11px;font-weight:600;color:#FFC62E;background:rgba(255,198,46,.14);padding:7px 11px;border-radius:999px;line-height:1.4">{{ kindHint }}</div>
                </div>
              </div>
              <sc-if value="{{ showTutorFilters }}" hint-placeholder-val="{{ false }}">
                <div style="padding:16px 20px 0">
                  <div style="height:44px;border:1.5px solid #E7E2DA;border-radius:12px;background:#fff;display:flex;align-items:center;gap:9px;padding:0 13px">
                    <span style="color:#716D67;flex:none"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="6.5"></circle><path d="M16 16l4.5 4.5"></path></svg></span>
                    <input value="{{ tQVal }}" onChange="{{ onTQ }}" placeholder="{{ searchTutorsPh }}" aria-label="{{ searchTutorsPh }}" style="flex:1;min-width:0;background:transparent;border:none;outline:none;color:#1B1B1B;font-size:13px;font-family:{{ ff }};letter-spacing:{{ ls }}">
                  </div>
                </div>
                <div style="display:flex;gap:8px;overflow-x:auto;padding:12px 20px 0;scrollbar-width:thin">
                  <sc-for list="{{ tutorFilterChips }}" as="chip" hint-placeholder-count="5">
                    <button onClick="{{ chip.pick }}" style="flex:none;border-radius:999px;padding:9px 13px;cursor:pointer;background:{{ chip.bg }};color:{{ chip.fg }};border:1.5px solid {{ chip.bd }};font-size:12px;font-weight:600;font-family:{{ ff }};letter-spacing:{{ ls }};white-space:nowrap">{{ chip.label }}</button>
                  </sc-for>
                </div>
                <sc-if value="{{ showYearRow }}" hint-placeholder-val="{{ false }}">
                <div style="display:flex;gap:8px;overflow-x:auto;padding:10px 20px 0;scrollbar-width:thin">
                  <sc-for list="{{ yearFilterChips }}" as="yc" hint-placeholder-count="6">
                    <button onClick="{{ yc.pick }}" style="flex:none;border-radius:999px;min-height:44px;padding:8px 12px;cursor:pointer;background:{{ yc.bg }};color:{{ yc.fg }};border:1.5px solid {{ yc.bd }};font-size:11.5px;font-weight:600;font-family:{{ ff }};letter-spacing:{{ ls }};white-space:nowrap">{{ yc.label }}</button>
                  </sc-for>
                </div>
                <div style="display:flex;gap:8px;overflow-x:auto;padding:10px 20px 0;scrollbar-width:thin">
                  <sc-for list="{{ tvToggles }}" as="tv" hint-placeholder-count="2">
                    <button onClick="{{ tv.pick }}" style="flex:none;border-radius:999px;min-height:44px;padding:8px 12px;cursor:pointer;background:{{ tv.bg }};color:{{ tv.fg }};border:1.5px solid {{ tv.bd }};font-size:11.5px;font-weight:600;font-family:{{ ff }};letter-spacing:{{ ls }};white-space:nowrap">{{ tv.label }}</button>
                  </sc-for>
                </div>
                </sc-if>
                <div style="font-size:12px;font-weight:700;color:#716D67;padding:12px 20px 0">{{ tutorsFound }}</div>
              </sc-if>
              <div style="padding:20px;display:grid;gap:12px">
                <sc-for list="{{ people }}" as="w" hint-placeholder-count="5">
                  <button onClick="{{ w.open }}" style="text-align:start;background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:16px;cursor:pointer;box-shadow:0 1px 3px rgba(0,0,0,.05);font-family:{{ ff }};letter-spacing:{{ ls }};display:block;width:100%">
                    <span style="display:flex;gap:12px;align-items:flex-start;margin-bottom:10px">
                      <span role="img" aria-label="{{ w.name }}" style="flex:none;width:52px;height:52px;border-radius:999px;border:1.5px solid #E7E2DA;background:#F5F2EC center/cover no-repeat url({{ w.photo }})"></span>
                      <span style="flex:1;min-width:0">
                        <span style="display:flex;align-items:center;gap:7px;flex-wrap:wrap">
                          <span style="font-size:14.5px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ w.name }}</span>
                          <sc-if value="{{ w.featured }}" hint-placeholder-val="{{ false }}">
                            <span style="font-size:9px;font-weight:800;letter-spacing:{{ lsB }};color:#1B1B1B;background:#FFC62E;padding:3px 7px;border-radius:999px">{{ w.featuredL }}</span>
                          </sc-if>
                        </span>
                        <span style="display:block;font-size:11.5px;font-weight:500;color:#716D67;margin-top:4px;line-height:{{ lhSnug }}">{{ w.role }}</span>
                      </span>
                      <span style="flex:none;text-align:end">
                        <span style="display:block;font-family:{{ ffDisp }};font-weight:700;font-size:16px;color:#1B1B1B;direction:ltr;unicode-bidi:isolate">{{ w.rate }}</span>
                        <span style="display:block;font-size:10px;font-weight:500;color:#716D67;margin-top:2px">{{ w.perHour }}</span>
                      </span>
                    </span>
                    <sc-if value="{{ w.hasChips }}" hint-placeholder-val="{{ false }}">
                      <span style="display:flex;flex-wrap:wrap;gap:6px;margin-bottom:10px">
                        <span style="font-size:10.5px;font-weight:700;color:#496FA8;background:rgba(73,111,168,.1);padding:5px 9px;border-radius:999px">{{ w.subj }}</span>
                        <span style="font-size:10.5px;font-weight:600;color:#716D67;background:#F5F2EC;padding:5px 9px;border-radius:999px">{{ w.uniShort }}</span>
                        <span style="font-size:10.5px;font-weight:600;color:#716D67;background:#F5F2EC;padding:5px 9px;border-radius:999px">{{ w.yearsLabel }}</span>
                      </span>
                    </sc-if>
                    <sc-if value="{{ w.hasBio }}" hint-placeholder-val="{{ false }}">
                      <span style="display:block;font-size:12px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:10px">{{ w.bio }}</span>
                    </sc-if>
                    <span style="display:flex;flex-wrap:wrap;gap:6px;margin-bottom:10px">
                      <sc-for list="{{ w.tags }}" as="tg" hint-placeholder-count="3">
                        <span style="font-size:10.5px;font-weight:600;color:#716D67;background:#F5F2EC;padding:5px 9px;border-radius:999px">{{ tg }}</span>
                      </sc-for>
                    </span>
                    <span style="display:block;font-size:11px;font-weight:600;color:#716D67;line-height:1.7">{{ w.metaA }}</span>
                    <span style="display:block;font-size:11px;font-weight:600;color:#716D67;line-height:1.7;margin-bottom:12px">{{ w.metaB }}</span>
                    <span style="display:flex;align-items:center;justify-content:space-between;gap:10px;padding-top:12px;border-top:1px solid #E7E2DA">
                      <span style="font-size:11.5px;font-weight:700;color:{{ w.nextFg }};line-height:{{ lhSnug }}">{{ w.next }}</span>
                      <span style="flex:none;font-size:12.5px;font-weight:700;color:#fff;background:{{ grad }};padding:9px 18px;border-radius:10px">{{ w.bookL }}</span>
                    </span>
                  </button>
                </sc-for>
              </div>
              <sc-if value="{{ isMentorKind }}" hint-placeholder-val="{{ false }}">
                <div style="padding:0 20px 24px;display:grid;gap:12px">
                  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:16px">
                    <div style="font-size:10.5px;font-weight:700;color:#FF6B1A;margin-bottom:10px;line-height:1.4">{{ mvtL }}</div>
                    <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:6px">{{ mvtA }}</div>
                    <div style="font-size:12.5px;font-weight:500;line-height:{{ lhBody }};color:#1B1B1B">{{ mvtB }}</div>
                  </div>
                  <div style="background:#1B1B1B;border-radius:18px;padding:18px">
                    <div style="font-size:10.5px;font-weight:700;color:#FFC62E;margin-bottom:8px;line-height:1.4">{{ becomeMentorT }}</div>
                    <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.7);margin-bottom:14px">{{ becomeMentorB }}</div>
                    <button onClick="{{ openOnboard }}" style="height:46px;padding:0 18px;border:none;border-radius:12px;background:#fff;color:#1B1B1B;font-size:12.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ applyMentorL }}</button>
                  </div>
                </div>
              </sc-if>
            </div>
          </sc-if>

          <sc-if value="{{ isTutorProfile }}" hint-placeholder-val="{{ false }}">
            <div>
              <div style="background:#1B1B1B;padding:12px 14px 26px">
                <button onClick="{{ backToList }}" aria-label="{{ t.back }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#fff;display:flex;align-items:center;justify-content:center;margin-bottom:6px">
                  <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                </button>
                <div style="padding:0 6px">
                  <div style="display:flex;gap:14px;align-items:center;margin-bottom:18px">
                    <div role="img" aria-label="{{ who.name }}" style="flex:none;width:82px;height:82px;border-radius:999px;border:1px solid rgba(255,255,255,.2);background:rgba(255,255,255,.08) center/cover no-repeat url({{ who.photo }})"></div>
                    <div style="min-width:0">
                      <div style="font-family:{{ ffDisp }};font-weight:700;font-size:22px;line-height:{{ lhTight }};color:#fff">{{ who.name }}</div>
                      <div style="font-size:12px;font-weight:700;color:#FFC62E;margin-top:6px">{{ who.specialty }}</div>
                      <div style="font-size:11.5px;font-weight:500;color:rgba(255,255,255,.55);margin-top:5px">{{ who.langs }}</div>
                    </div>
                  </div>
                  <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:8px">
                    <div style="background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.1);border-radius:12px;padding:10px 8px;text-align:center">
                      <div style="font-family:{{ ffDisp }};font-weight:700;font-size:15px;color:#fff;direction:ltr;unicode-bidi:isolate">★ {{ who.rating }}</div>
                      <div style="font-size:9px;font-weight:600;color:rgba(255,255,255,.45);margin-top:4px">{{ t.rating }}</div>
                    </div>
                    <div style="background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.1);border-radius:12px;padding:10px 8px;text-align:center">
                      <div style="font-family:{{ ffDisp }};font-weight:700;font-size:15px;color:#fff;direction:ltr;unicode-bidi:isolate">{{ who.sessions }}</div>
                      <div style="font-size:9px;font-weight:600;color:rgba(255,255,255,.45);margin-top:4px">{{ statBLabel }}</div>
                    </div>
                    <div style="background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.1);border-radius:12px;padding:10px 8px;text-align:center">
                      <div style="font-family:{{ ffDisp }};font-weight:700;font-size:15px;color:#fff;direction:ltr;unicode-bidi:isolate">{{ who.years }}</div>
                      <div style="font-size:9px;font-weight:600;color:rgba(255,255,255,.45);margin-top:4px">{{ statCLabel }}</div>
                    </div>
                    <div style="background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.1);border-radius:12px;padding:10px 8px;text-align:center">
                      <div style="color:#7FD4A6;display:flex;justify-content:center"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="M5 13l4.5 4.5L19 7"></path></svg></div>
                      <div style="font-size:9px;font-weight:600;color:rgba(255,255,255,.45);margin-top:4px">{{ who.verified }}</div>
                    </div>
                  </div>
                </div>
              </div>
              <div style="padding:20px 20px 26px">
                <div style="display:flex;gap:8px;margin-bottom:20px">
                  <sc-for list="{{ profTabs }}" as="pt" hint-placeholder-count="3">
                    <button onClick="{{ pt.go }}" style="flex:1;height:40px;border-radius:12px;cursor:pointer;background:{{ pt.bg }};color:{{ pt.fg }};border:1.5px solid {{ pt.bd }};font-size:12.5px;font-weight:700;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ pt.label }}</button>
                  </sc-for>
                </div>

                <sc-if value="{{ profAbout }}" hint-placeholder-val="{{ true }}">
                <div>
                <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:10px;line-height:1.4">{{ t.aboutTutor }}</div>
                <p style="font-size:13.5px;font-weight:400;line-height:{{ lhBody }};color:#1B1B1B;margin:0 0 22px">{{ kindBio }}</p>

                <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:10px;line-height:1.4">{{ t.whatYouGet }}</div>
                <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:6px 16px;margin-bottom:22px">
                  <div style="display:flex;gap:10px;align-items:flex-start;padding:13px 0;border-bottom:1px solid #E7E2DA">
                    <span style="flex:none;color:#2D9B68;margin-top:2px"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="M5 13l4.5 4.5L19 7"></path></svg></span>
                    <span style="font-size:13px;font-weight:400;line-height:{{ lhBody }};color:#1B1B1B">{{ kindB1 }}</span>
                  </div>
                  <div style="display:flex;gap:10px;align-items:flex-start;padding:13px 0;border-bottom:1px solid #E7E2DA">
                    <span style="flex:none;color:#2D9B68;margin-top:2px"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="M5 13l4.5 4.5L19 7"></path></svg></span>
                    <span style="font-size:13px;font-weight:400;line-height:{{ lhBody }};color:#1B1B1B">{{ kindB2 }}</span>
                  </div>
                  <div style="display:flex;gap:10px;align-items:flex-start;padding:13px 0">
                    <span style="flex:none;color:#2D9B68;margin-top:2px"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="M5 13l4.5 4.5L19 7"></path></svg></span>
                    <span style="font-size:13px;font-weight:400;line-height:{{ lhBody }};color:#1B1B1B">{{ kindB3 }}</span>
                  </div>
                </div>

                <sc-if value="{{ hasDeepProfile }}" hint-placeholder-val="{{ false }}">
                <div>
                  <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:10px;line-height:1.4">{{ approachL }}</div>
                  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:16px;font-size:13px;font-weight:400;line-height:{{ lhBody }};color:#1B1B1B;margin-bottom:22px">{{ who.approach }}</div>
                  <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:10px;line-height:1.4">{{ outcomesL }}</div>
                  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:6px 16px;margin-bottom:22px">
                    <sc-for list="{{ who.outcomes }}" as="oc" hint-placeholder-count="4">
                      <div style="display:flex;gap:10px;align-items:flex-start;padding:12px 0;border-bottom:1px solid #E7E2DA">
                        <span style="flex:none;color:#2D9B68;margin-top:2px"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="M5 13l4.5 4.5L19 7"></path></svg></span>
                        <span style="font-size:12.5px;font-weight:500;line-height:{{ lhSnug }};color:#1B1B1B">{{ oc }}</span>
                      </div>
                    </sc-for>
                  </div>
                </div>
                </sc-if>

                <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:10px;line-height:1.4">{{ qualsLabel }}</div>
                <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:6px 16px;margin-bottom:22px">
                  <sc-for list="{{ quals }}" as="q" hint-placeholder-count="5">
                    <div style="padding:12px 0;border-bottom:1px solid #E7E2DA;font-size:12.5px;font-weight:500;line-height:{{ lhSnug }};color:#1B1B1B">{{ q }}</div>
                  </sc-for>
                </div>

                </div>
                </sc-if>

                <sc-if value="{{ profPkg }}" hint-placeholder-val="{{ false }}">
                <div>
                <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:10px;line-height:1.4">{{ packagesLabel }}</div>
                <div style="display:grid;gap:10px;margin-bottom:14px">
                  <sc-for list="{{ packages }}" as="p" hint-placeholder-count="4">
                    <button onClick="{{ p.pick }}" style="text-align:start;width:100%;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};background:{{ p.bg }};border:1.5px solid {{ p.bd }};border-radius:16px;padding:15px;display:flex;align-items:center;gap:12px">
                      <span style="flex:1;min-width:0">
                        <span style="display:block;font-size:13.5px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ p.n }}</span>
                        <span style="display:block;font-size:11.5px;font-weight:500;color:#716D67;margin-top:3px;line-height:{{ lhSnug }}">{{ p.cLine }}</span>
                      </span>
                      <span style="flex:none;text-align:end">
                        <span style="display:block;font-family:{{ ffDisp }};font-weight:700;font-size:16px;color:#1B1B1B;direction:ltr;unicode-bidi:isolate">{{ p.p }}</span>
                        <span style="display:block;font-size:10px;font-weight:700;color:#2D9B68;margin-top:3px">{{ p.save }}</span>
                      </span>
                    </button>
                  </sc-for>
                </div>
                <button onClick="{{ openCustom }}" style="width:100%;display:flex;align-items:center;justify-content:space-between;gap:12px;background:#1B1B1B;border:none;border-radius:16px;padding:16px;cursor:pointer;text-align:start;font-family:{{ ff }};letter-spacing:{{ ls }};margin-bottom:10px">
                  <span style="min-width:0">
                    <span style="display:block;font-size:10px;font-weight:800;color:#FFC62E;letter-spacing:{{ lsE }};margin-bottom:7px">{{ cuLadderL }}</span>
                    <span style="display:block;font-size:14px;font-weight:700;line-height:{{ lhSnug }};color:#fff">{{ cuTitle }}</span>
                    <span style="display:block;font-size:11.5px;font-weight:500;color:rgba(255,255,255,.62);margin-top:4px;line-height:{{ lhSnug }}">{{ cuSlotsHint }}</span>
                  </span>
                  <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="#FFC62E" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" style="flex:none;transform:scaleX({{ flip }})"><path d="M9 5l7 7-7 7"></path></svg>
                </button>
                <div style="display:flex;gap:8px;margin-bottom:10px">
                  <button onClick="{{ openThread }}" style="flex:1;min-height:46px;border-radius:12px;border:1.5px solid #E7E2DA;background:#fff;color:#1B1B1B;font-size:11.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ threadHistoryL }}</button>
                  <button onClick="{{ openIntro }}" style="flex:1;min-height:46px;border-radius:12px;border:1.5px solid #2D9B68;background:rgba(45,155,104,.08);color:#2D9B68;font-size:11.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ introTitle }}</button>
                </div>
                <button onClick="{{ startBooking }}" style="width:100%;height:52px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:13.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};margin-bottom:22px">{{ pkgCta }}</button>
                </div>
                </sc-if>

                <sc-if value="{{ profAbout }}" hint-placeholder-val="{{ true }}">
                <div>

                <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:10px;line-height:1.4">{{ policiesLabel }}</div>
                <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:6px 16px;margin-bottom:22px">
                  <sc-for list="{{ policies }}" as="pl" hint-placeholder-count="3">
                    <div style="padding:13px 0;border-bottom:1px solid #E7E2DA">
                      <div style="font-size:12.5px;font-weight:700;color:#1B1B1B;margin-bottom:4px">{{ pl.t }}</div>
                      <div style="font-size:12px;font-weight:400;line-height:{{ lhBody }};color:#716D67">{{ pl.d }}</div>
                    </div>
                  </sc-for>
                </div>

                <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:10px;line-height:1.4">{{ subjAreasL }}</div>
                <div style="display:flex;flex-wrap:wrap;gap:7px;margin-bottom:22px">
                  <sc-for list="{{ who.tags }}" as="tg" hint-placeholder-count="3">
                    <span style="font-size:12px;font-weight:600;color:#716D67;background:#fff;border:1.5px solid #E7E2DA;padding:9px 13px;border-radius:999px">{{ tg }}</span>
                  </sc-for>
                </div>

                </div>
                </sc-if>

                <sc-if value="{{ profRev }}" hint-placeholder-val="{{ false }}">
                <div>
                <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:10px;line-height:1.4">{{ t.reviewsLabel }}</div>
                <div style="display:grid;gap:10px;margin-bottom:22px">
                  <sc-for list="{{ reviews }}" as="rv" hint-placeholder-count="3">
                    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:15px">
                      <div style="display:flex;align-items:center;justify-content:space-between;gap:10px;margin-bottom:7px">
                        <span style="font-size:12.5px;font-weight:700;color:#1B1B1B">{{ rv.author }}</span>
                        <span style="display:flex;align-items:center;gap:8px">
                          <span style="font-size:11.5px;font-weight:700;color:#FFAA18;direction:ltr;unicode-bidi:isolate">★ {{ rv.rating }}</span>
                          <span style="font-size:10.5px;font-weight:500;color:#716D67">{{ rv.when }}</span>
                        </span>
                      </div>
                      <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67">{{ rv.text }}</div>
                    </div>
                  </sc-for>
                </div>
                </div>
                </sc-if>

                <sc-if value="{{ profAbout }}" hint-placeholder-val="{{ true }}">
                <div>

                <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:10px;line-height:1.4">{{ t.nextAvailable }}</div>
                <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:16px;margin-bottom:22px">
                  <div style="font-size:13px;font-weight:600;color:#1B1B1B;margin-bottom:5px">{{ who.next }}</div>
                  <div style="font-size:11.5px;font-weight:400;line-height:{{ lhSnug }};color:#716D67">{{ t.timezoneNote }}</div>
                </div>
                </div>
                </sc-if>

                <div style="display:flex;align-items:center;gap:12px">
                  <div style="flex:1;min-width:0">
                    <div style="font-family:{{ ffDisp }};font-weight:700;font-size:19px;line-height:1.2;color:#1B1B1B;direction:ltr;unicode-bidi:isolate;text-align:start">{{ stickyPrice }}</div>
                    <div style="font-size:11px;font-weight:500;color:#716D67;margin-top:2px">{{ stickyPer }}</div>
                  </div>
                  <button onClick="{{ startBooking }}" style="flex:none;height:52px;padding:0 24px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.bookSession }}</button>
                </div>
                <button onClick="{{ openMsg }}" style="width:100%;height:48px;margin-top:10px;border:1.5px solid #E7E2DA;border-radius:14px;background:#fff;color:#1B1B1B;font-size:13px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ messageFirst }}</button>
                <div style="font-size:11.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-top:12px;text-align:center">{{ guaranteeNote }}</div>
              <sc-if value="{{ msgOpen }}" hint-placeholder-val="{{ false }}">
                <div style="position:sticky;bottom:0;z-index:9;margin-top:16px">
                  <div style="background:#fff;border-top:1.5px solid #E7E2DA;border-radius:24px 24px 0 0;padding:14px 20px 22px;box-shadow:0 -12px 40px rgba(0,0,0,.18)">
                    <div style="width:38px;height:4px;border-radius:2px;background:#E7E2DA;margin:0 auto 14px"></div>
                    <div style="font-size:15px;font-weight:700;color:#1B1B1B;margin-bottom:10px;line-height:{{ lhSnug }}">{{ msgTitle }}</div>
                    <div style="min-height:88px;border:1.5px solid #E7E2DA;border-radius:12px;background:#FFF9EF;padding:13px;font-size:13px;line-height:{{ lhBody }};color:#716D67;margin-bottom:14px">{{ msgPh }}</div>
                    <button onClick="{{ sendMsg }}" style="width:100%;height:50px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:13.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ sendL }}</button>
                    <button onClick="{{ closeMsg }}" style="width:100%;height:44px;margin-top:6px;border:none;background:transparent;color:#716D67;font-size:12.5px;font-weight:600;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.cancel }}</button>
                  </div>
                </div>
              </sc-if>
              </div>
            </div>
          </sc-if>

          <sc-if value="{{ isBooking }}" hint-placeholder-val="{{ false }}">
            <div style="padding:12px 20px 30px">
              <div style="display:flex;align-items:center;gap:10px;margin-bottom:14px">
                <button onClick="{{ prevStep }}" aria-label="{{ t.back }}" style="flex:none;width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center">
                  <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                </button>
                <span style="font-size:12px;font-weight:700;color:#716D67">{{ bStepLabel }}</span>
              </div>
              <div style="height:5px;border-radius:3px;background:#E7E2DA;overflow:hidden;margin-bottom:22px"><div style="height:100%;border-radius:3px;background:{{ grad }};width:{{ bProgress }}%"></div></div>

              <sc-if value="{{ bStep1 }}" hint-placeholder-val="{{ true }}">
                <div>
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:21px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:16px">{{ bSubjTitle }}</div>
                  <div style="display:flex;flex-wrap:wrap;gap:8px;margin-bottom:24px">
                    <sc-for list="{{ subjChips }}" as="sj" hint-placeholder-count="4">
                      <button onClick="{{ sj.pick }}" style="border-radius:999px;min-height:44px;padding:11px 14px;cursor:pointer;background:{{ sj.bg }};color:{{ sj.fg }};border:1.5px solid {{ sj.bd }};font-size:12.5px;font-weight:600;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ sj.label }}</button>
                    </sc-for>
                  </div>
                  <button onClick="{{ nextStep }}" style="width:100%;height:52px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.continue }}</button>
                </div>
              </sc-if>
              <sc-if value="{{ bStep2 }}" hint-placeholder-val="{{ false }}">
                <div>
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:21px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:16px">{{ bDurTitle }}</div>
                  <div style="display:flex;gap:8px;margin-bottom:14px">
                    <sc-for list="{{ durOpts }}" as="d" hint-placeholder-count="3">
                      <button onClick="{{ d.pick }}" style="flex:1;height:46px;border-radius:12px;cursor:pointer;background:{{ d.bg }};color:{{ d.fg }};border:1.5px solid {{ d.bd }};font-size:12.5px;font-weight:700;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ d.label }}</button>
                    </sc-for>
                  </div>
                  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:14px;padding:14px 16px;display:flex;align-items:center;justify-content:space-between;gap:12px;margin-bottom:24px">
                    <span style="font-size:12.5px;font-weight:600;color:#716D67">{{ bTotalL }}</span>
                    <span style="font-family:{{ ffDisp }};font-weight:700;font-size:17px;color:#1B1B1B;direction:ltr;unicode-bidi:isolate">{{ durPrice }}</span>
                  </div>
                  <button onClick="{{ nextStep }}" style="width:100%;height:52px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.continue }}</button>
                </div>
              </sc-if>
              <sc-if value="{{ bStep3 }}" hint-placeholder-val="{{ false }}">
                <div>
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:21px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:16px">{{ t.pickDate }}</div>
                  <div style="display:flex;gap:8px;overflow-x:auto;padding-bottom:6px;margin-bottom:22px;scrollbar-width:thin">
                    <sc-for list="{{ days }}" as="d" hint-placeholder-count="5">
                      <button onClick="{{ d.pick }}" style="flex:none;width:60px;padding:12px 0;border-radius:14px;cursor:pointer;background:{{ d.bg }};color:{{ d.fg }};border:1.5px solid {{ d.bd }};font-family:{{ ff }};letter-spacing:{{ ls }};display:flex;flex-direction:column;align-items:center;gap:4px">
                        <span style="font-size:10px;font-weight:600">{{ d.w }}</span>
                        <span style="font-size:17px;font-weight:800;direction:ltr;unicode-bidi:isolate">{{ d.d }}</span>
                      </button>
                    </sc-for>
                  </div>
                  <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:12px;line-height:1.4">{{ t.pickSlot }}</div>
                  <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:8px;margin-bottom:24px">
                    <sc-for list="{{ slots }}" as="s" hint-placeholder-count="6">
                      <button onClick="{{ s.pick }}" style="height:46px;border-radius:12px;cursor:pointer;background:{{ s.bg }};color:{{ s.fg }};border:1.5px solid {{ s.bd }};font-size:13px;font-weight:700;font-family:{{ ff }};direction:ltr;unicode-bidi:isolate">{{ s.label }}</button>
                    </sc-for>
                  </div>
                  <button onClick="{{ nextStep }}" style="width:100%;height:52px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.continue }}</button>
                </div>
              </sc-if>

              <sc-if value="{{ bStep4 }}" hint-placeholder-val="{{ false }}">
                <div>
                  <sc-if value="{{ bFromPlan }}" hint-placeholder-val="{{ false }}">
                    <div style="background:rgba(45,155,104,.1);border-radius:14px;padding:14px 15px;margin-bottom:18px">
                      <div style="display:flex;align-items:flex-start;gap:9px;margin-bottom:10px">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#2D9B68" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" style="flex:none;margin-top:2px"><path d="M5 13l4.5 4.5L19 7"></path></svg>
                        <span style="font-size:12px;font-weight:700;line-height:{{ lhBody }};color:#1B1B1B">{{ bPlanSummaryL }}</span>
                      </div>
                      <button onClick="{{ bPlanEdit }}" style="min-height:38px;padding:0 12px;border:1.5px solid #2D9B68;border-radius:10px;background:#fff;color:#2D9B68;font-size:11px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ bPlanEditL }}</button>
                    </div>
                  </sc-if>
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:21px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:16px">{{ bGoalTitle }}</div>
                  <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:12px;line-height:1.4">{{ t.topic }}</div>
                  <div style="display:flex;flex-wrap:wrap;gap:8px;margin-bottom:20px">
                    <sc-for list="{{ topics }}" as="tp" hint-placeholder-count="4">
                      <button onClick="{{ tp.pick }}" style="border-radius:999px;padding:10px 14px;cursor:pointer;background:{{ tp.bg }};color:{{ tp.fg }};border:1.5px solid {{ tp.bd }};font-size:12.5px;font-weight:600;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ tp.label }}</button>
                    </sc-for>
                  </div>
                  <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:9px;line-height:1.4">{{ t.notesLabel }}</div>
                  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:12px;padding:14px;min-height:88px;font-size:13px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:24px">{{ t.notesPlaceholder }}</div>
                  <button onClick="{{ nextStep }}" style="width:100%;height:52px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.continue }}</button>
                </div>
              </sc-if>
              <sc-if value="{{ bStep5 }}" hint-placeholder-val="{{ false }}">
                <div>
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:21px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:8px">{{ bFilesTitle }}</div>
                  <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:14px">{{ bFilesNote }}</div>
                  <div style="border:1.5px dashed #C9C2B8;border-radius:16px;background:#fff;padding:28px 16px;text-align:center;margin-bottom:14px">
                    <div style="font-size:12.5px;font-weight:600;color:#716D67;line-height:{{ lhBody }}">{{ bDropLabel }}</div>
                  </div>
                  <div style="background:rgba(255,45,50,.08);border:1.5px solid rgba(255,45,50,.28);border-radius:14px;padding:13px 15px;font-size:12px;font-weight:500;line-height:{{ lhBody }};color:#1B1B1B;margin-bottom:24px">{{ bFilesWarn }}</div>
                  <button onClick="{{ nextStep }}" style="width:100%;height:52px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.continue }}</button>
                </div>
              </sc-if>
              <sc-if value="{{ bStep6 }}" hint-placeholder-val="{{ false }}">
                <div>
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:21px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:16px">{{ bFmtTitle }}</div>
                  <div style="display:grid;gap:8px;margin-bottom:24px">
                    <sc-for list="{{ fmtOpts }}" as="fo" hint-placeholder-count="2">
                      <button onClick="{{ fo.pick }}" style="height:46px;border-radius:12px;cursor:pointer;background:{{ fo.bg }};color:{{ fo.fg }};border:1.5px solid {{ fo.bd }};font-size:12.5px;font-weight:600;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ fo.label }}</button>
                    </sc-for>
                  </div>
                  <button onClick="{{ nextStep }}" style="width:100%;height:52px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.continue }}</button>
                </div>
              </sc-if>

              <sc-if value="{{ bStep7 }}" hint-placeholder-val="{{ false }}">
                <div>
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:21px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:16px">{{ t.reviewBooking }}</div>
                  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:6px 16px;margin-bottom:16px">
                    <sc-for list="{{ bookSummary }}" as="r" hint-placeholder-count="5">
                      <div style="display:flex;justify-content:space-between;gap:16px;padding:13px 0;border-bottom:1px solid #E7E2DA">
                        <span style="font-size:12.5px;font-weight:500;color:#716D67">{{ r.k }}</span>
                        <span style="font-size:13px;font-weight:600;color:#1B1B1B;text-align:end">{{ r.v }}</span>
                      </div>
                    </sc-for>
                  </div>
                  <button onClick="{{ nextStep }}" style="width:100%;height:52px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.continue }}</button>
                </div>
              </sc-if>
              <sc-if value="{{ bStep8 }}" hint-placeholder-val="{{ false }}">
                <div>
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:21px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:16px">{{ bPayTitle }}</div>
                  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:18px;display:flex;align-items:center;justify-content:space-between;gap:12px;margin-bottom:14px">
                    <span style="font-size:13px;font-weight:600;color:#716D67">{{ bTotalL }}</span>
                    <span style="font-family:{{ ffDisp }};font-weight:700;font-size:22px;color:#1B1B1B;direction:ltr;unicode-bidi:isolate">{{ bookTotal }}</span>
                  </div>
                  <div style="background:#F5F2EC;border-radius:14px;padding:14px 16px;font-size:12px;font-weight:500;line-height:{{ lhBody }};color:#716D67;margin-bottom:18px">{{ t.payNote }}</div>
                  <button onClick="{{ bookSuccess }}" style="width:100%;height:52px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.payCta }}</button>
                  <button onClick="{{ payCancel }}" style="width:100%;height:44px;margin-top:8px;border:none;background:transparent;color:#716D67;font-size:13px;font-weight:600;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.maybeLater }}</button>
                </div>
              </sc-if>
            </div>
          </sc-if>

          <sc-if value="{{ isBookings }}" hint-placeholder-val="{{ false }}">
            <div style="padding:12px 20px 30px">
              <button onClick="{{ backToHub }}" aria-label="{{ t.back }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center;margin-bottom:8px">
                <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
              </button>
              <div style="font-family:{{ ffDisp }};font-weight:700;font-size:22px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:16px">{{ t.rowBookings }}</div>
              <sc-if value="{{ hasPkgBalance }}" hint-placeholder-val="{{ false }}">
                <div style="background:#1B1B1B;border-radius:18px;padding:16px;margin-bottom:16px;display:flex;align-items:center;gap:12px">
                  <span style="flex:1;min-width:0">
                    <span style="display:block;font-size:10.5px;font-weight:700;color:#FFC62E;margin-bottom:5px;line-height:1.4">{{ pkgBalName }}</span>
                    <span style="display:block;font-size:14px;font-weight:700;color:#fff;line-height:{{ lhSnug }}">{{ pkgBalLeft }}</span>
                  </span>
                  <button onClick="{{ rebook }}" style="flex:none;height:44px;padding:0 16px;border:none;border-radius:12px;background:{{ grad }};color:#fff;font-size:12.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ rebookL }}</button>
                </div>
              </sc-if>
              <div style="display:flex;gap:8px;margin-bottom:18px">
                <sc-for list="{{ bookingTabs }}" as="bt" hint-placeholder-count="3">
                  <button onClick="{{ bt.go }}" style="flex:1;height:38px;border-radius:11px;cursor:pointer;background:{{ bt.bg }};color:{{ bt.fg }};border:1.5px solid {{ bt.bd }};font-size:12px;font-weight:700;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ bt.label }}</button>
                </sc-for>
              </div>
              <sc-if value="{{ hasBookings }}" hint-placeholder-val="{{ true }}">
                <div style="display:grid;gap:12px">
                  <sc-for list="{{ bookingRows }}" as="b" hint-placeholder-count="1">
                    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:16px">
                      <div style="display:flex;align-items:center;justify-content:space-between;gap:12px;margin-bottom:8px">
                        <span style="font-size:12.5px;font-weight:700;color:#1B1B1B">{{ b.when }}</span>
                        <span style="font-size:10.5px;font-weight:700;color:{{ b.tone }}">{{ b.state }}</span>
                      </div>
                      <div style="font-size:14.5px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B;margin-bottom:4px">{{ b.name }}</div>
                      <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:14px">{{ b.meta }}</div>
                      <div style="display:flex;gap:8px">
                        <button onClick="{{ joinSession }}" style="flex:1;height:44px;border-radius:12px;border:none;background:#1B1B1B;color:#fff;font-size:12.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.join }}</button>
                        <button onClick="{{ openResched }}" style="flex:1;height:44px;border-radius:12px;border:1.5px solid #E7E2DA;background:#fff;color:#716D67;font-size:12.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.reschedule }}</button>
                      </div>
                      <button onClick="{{ openCancelBk }}" style="width:100%;height:38px;margin-top:6px;border:none;background:transparent;color:#FF2D32;font-size:12px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ bkCancelL }}</button>
                    </div>
                  </sc-for>
                </div>
              </sc-if>
              <sc-if value="{{ noBookings }}" hint-placeholder-val="{{ false }}">
                <div style="padding:34px 10px;text-align:center">
                  <div style="font-size:17px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B;margin-bottom:6px">{{ t.emptyBookTitle }}</div>
                  <div style="font-size:13px;font-weight:400;line-height:{{ lhBody }};color:#716D67">{{ t.emptyBookBody }}</div>
                </div>
              </sc-if>

              <sc-if value="{{ bkResched }}" hint-placeholder-val="{{ false }}">
                <div style="position:sticky;bottom:0;z-index:9;margin-top:16px">
                  <div style="background:#fff;border-top:1.5px solid #E7E2DA;border-radius:24px 24px 0 0;padding:14px 20px 22px;box-shadow:0 -12px 40px rgba(0,0,0,.18)">
                    <div style="width:38px;height:4px;border-radius:2px;background:#E7E2DA;margin:0 auto 14px"></div>
                    <div style="font-size:15px;font-weight:700;color:#1B1B1B;margin-bottom:6px;line-height:{{ lhSnug }}">{{ reschedTitle }}</div>
                    <div style="font-size:11.5px;font-weight:500;color:#716D67;margin-bottom:14px;line-height:{{ lhSnug }}">{{ reschedFree }}</div>
                    <div style="display:flex;gap:8px;overflow-x:auto;padding-bottom:6px;margin-bottom:12px;scrollbar-width:thin">
                      <sc-for list="{{ days }}" as="d" hint-placeholder-count="5">
                        <button onClick="{{ d.pick }}" style="flex:none;width:56px;padding:10px 0;border-radius:12px;cursor:pointer;background:{{ d.bg }};color:{{ d.fg }};border:1.5px solid {{ d.bd }};font-family:{{ ff }};letter-spacing:{{ ls }};display:flex;flex-direction:column;align-items:center;gap:3px">
                          <span style="font-size:9.5px;font-weight:600">{{ d.w }}</span>
                          <span style="font-size:15px;font-weight:800;direction:ltr;unicode-bidi:isolate">{{ d.d }}</span>
                        </button>
                      </sc-for>
                    </div>
                    <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:8px;margin-bottom:16px">
                      <sc-for list="{{ slots }}" as="s" hint-placeholder-count="6">
                        <button onClick="{{ s.pick }}" style="height:42px;border-radius:11px;cursor:pointer;background:{{ s.bg }};color:{{ s.fg }};border:1.5px solid {{ s.bd }};font-size:12.5px;font-weight:700;font-family:{{ ff }};direction:ltr;unicode-bidi:isolate">{{ s.label }}</button>
                      </sc-for>
                    </div>
                    <button onClick="{{ confirmResched }}" style="width:100%;height:50px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:13.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ confirmReschedL }}</button>
                    <button onClick="{{ closeBkAction }}" style="width:100%;height:44px;margin-top:6px;border:none;background:transparent;color:#716D67;font-size:12.5px;font-weight:600;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.cancel }}</button>
                  </div>
                </div>
              </sc-if>

              <sc-if value="{{ bkCancel }}" hint-placeholder-val="{{ false }}">
                <div style="position:sticky;bottom:0;z-index:9;margin-top:16px">
                  <div style="background:#fff;border-top:1.5px solid #E7E2DA;border-radius:24px 24px 0 0;padding:14px 20px 22px;box-shadow:0 -12px 40px rgba(0,0,0,.18)">
                    <div style="width:38px;height:4px;border-radius:2px;background:#E7E2DA;margin:0 auto 14px"></div>
                    <div style="font-size:15px;font-weight:700;color:#1B1B1B;margin-bottom:12px;line-height:{{ lhSnug }}">{{ bkCancelL }}</div>
                    <div style="background:rgba(255,45,50,.08);border:1.5px solid rgba(255,45,50,.28);border-radius:14px;padding:13px 15px;font-size:12.5px;font-weight:500;line-height:{{ lhBody }};color:#1B1B1B;margin-bottom:16px">{{ cancelPolicyLine }}</div>
                    <button onClick="{{ confirmCancelBk }}" style="width:100%;height:50px;border:1.5px solid #FF2D32;border-radius:14px;background:rgba(255,45,50,.08);color:#FF2D32;font-size:13.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ confirmCancelL }}</button>
                    <button onClick="{{ closeBkAction }}" style="width:100%;height:44px;margin-top:6px;border:none;background:transparent;color:#716D67;font-size:12.5px;font-weight:600;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ keepL }}</button>
                  </div>
                </div>
              </sc-if>
            </div>
          </sc-if>

          <sc-if value="{{ isHub }}" hint-placeholder-val="{{ false }}">
            <div>
              <div style="background:#1B1B1B;padding:18px 20px 30px">
                <div style="font-size:11px;font-weight:600;color:#FFC62E;line-height:1;margin-bottom:14px">{{ t.connectEyebrow }}</div>
                <div style="font-family:{{ ffDisp }};font-weight:700;font-size:28px;line-height:{{ lhTight }};color:#fff;margin-bottom:10px">{{ t.connectTitle }}</div>
                <div style="font-size:14px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.68)">{{ t.connectSub }}</div>
              </div>
              <div style="padding:24px 20px 30px;display:grid;gap:10px">
                <button onClick="{{ openTutoring }}" style="text-align:start;background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:18px;cursor:pointer;box-shadow:0 1px 3px rgba(0,0,0,.05);font-family:{{ ff }};letter-spacing:{{ ls }};display:flex;align-items:center;gap:14px">
                  <span style="flex:none;width:44px;height:44px;border-radius:14px;background:#F5F2EC;color:#FF6B1A;display:flex;align-items:center;justify-content:center"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 8.5 12 4l10 4.5-10 4.5z"></path><path d="M6 10.8V16c0 1.7 2.7 3 6 3s6-1.3 6-3v-5.2"></path></svg></span>
                  <span style="flex:1;min-width:0">
                    <span style="display:block;font-size:15px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ t.tutoringTitle }}</span>
                    <span style="display:block;font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-top:3px">{{ t.tutoringBlurb }}</span>
                  </span>
                  <span style="flex:none;color:#716D67"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M9 5l7 7-7 7"></path></svg></span>
                </button>
                <button style="text-align:start;background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:18px;cursor:pointer;box-shadow:0 1px 3px rgba(0,0,0,.05);font-family:{{ ff }};letter-spacing:{{ ls }};display:flex;align-items:center;gap:14px" onClick="{{ openMentoring }}">
                  <span style="flex:none;width:44px;height:44px;border-radius:14px;background:#F5F2EC;color:#FF6B1A;display:flex;align-items:center;justify-content:center"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"></circle><path d="M15.5 8.5l-2 5-5 2 2-5z"></path></svg></span>
                  <span onClick="{{ openMentoring }}" style="flex:1;min-width:0">
                    <span style="display:block;font-size:15px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ t.mentoringTitle }}</span>
                    <span style="display:block;font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-top:3px">{{ t.mentoringBlurb }}</span>
                  </span>
                  <span style="flex:none;color:#716D67"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M9 5l7 7-7 7"></path></svg></span>
                </button>
                <button style="text-align:start;background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:18px;cursor:pointer;box-shadow:0 1px 3px rgba(0,0,0,.05);font-family:{{ ff }};letter-spacing:{{ ls }};display:flex;align-items:center;gap:14px" onClick="{{ openConsulting }}">
                  <span style="flex:none;width:44px;height:44px;border-radius:14px;background:#F5F2EC;color:#FF6B1A;display:flex;align-items:center;justify-content:center"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19V9m5 10V5m5 14v-7m5 7V8"</path></svg></span>
                  <span style="flex:1;min-width:0">
                    <span style="display:block;font-size:15px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ t.consultingTitle }}</span>
                    <span style="display:block;font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-top:3px">{{ t.consultingBlurb }}</span>
                  </span>
                  <span style="flex:none;color:#716D67"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M9 5l7 7-7 7"></path></svg></span>
                </button>
                <div style="height:1px;background:#E7E2DA;margin:8px 0"></div>
                <button onClick="{{ openBookings }}" style="text-align:start;background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:18px;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};display:flex;align-items:center;justify-content:space-between;gap:12px">
                  <span style="min-width:0">
                    <span style="display:block;font-size:15px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ t.bookingsTitle }}</span>
                    <span style="display:block;font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-top:3px">{{ t.bookingsBlurb }}</span>
                  </span>
                  <span style="flex:none;color:#716D67"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M9 5l7 7-7 7"></path></svg></span>
                </button>
                <div style="background:#1B1B1B;border-radius:20px;padding:20px;margin-top:8px">
                  <div style="font-size:10.5px;font-weight:600;color:#FFC62E;line-height:1.4;margin-bottom:10px">{{ t.becomeTitle }}</div>
                  <div style="font-size:13px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.7);margin-bottom:16px">{{ t.becomeBlurb }}</div>
                  <div style="display:grid;gap:8px">
                    <button onClick="{{ openOnboard }}" style="height:46px;border:none;border-radius:12px;background:#fff;color:#1B1B1B;font-size:12.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.applyToTeach }}</button>
                    <div style="display:flex;gap:8px">
                      <button onClick="{{ openRequests }}" style="flex:1;height:44px;border:1px solid rgba(255,255,255,.2);border-radius:12px;background:transparent;color:rgba(255,255,255,.85);font-size:12px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.requestsLink }}</button>
                      <button onClick="{{ openEarnings }}" style="flex:1;height:44px;border:1px solid rgba(255,255,255,.2);border-radius:12px;background:transparent;color:rgba(255,255,255,.85);font-size:12px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.earningsLink }}</button>
                      <button onClick="{{ openInstructor }}" style="flex:1;height:44px;border:1px solid rgba(255,255,255,.2);border-radius:12px;background:transparent;color:rgba(255,255,255,.85);font-size:12px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.instructorLink }}</button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </sc-if>

          <sc-if value="{{ isProfile }}" hint-placeholder-val="{{ false }}">
            <div>
              <sc-if value="{{ isProfileHome }}" hint-placeholder-val="{{ true }}">
                <div>
                  <div style="background:#1B1B1B;padding:12px 20px 24px">
                    <div style="display:flex;align-items:center;justify-content:space-between;gap:10px;margin-bottom:12px">
                      <div style="display:flex;gap:4px;background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.1);padding:3px;border-radius:999px">
                        <button onClick="{{ setEn }}" style="min-height:28px;padding:0 11px;border-radius:999px;cursor:pointer;border:none;background:{{ enPillBg }};color:{{ enPillFg }};font:700 11px/1 Inter,sans-serif">EN</button>
                        <button onClick="{{ setAr }}" style="min-height:28px;padding:0 11px;border-radius:999px;cursor:pointer;border:none;background:{{ arPillBg }};color:{{ arPillFg }};font:700 11px/1 'IBM Plex Sans Arabic',sans-serif;letter-spacing:0">عربي</button>
                      </div>
                      <button onClick="{{ openNotifsTab }}" aria-label="{{ t.notifications }}" style="flex:none;width:44px;height:44px;border-radius:999px;background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.12);color:rgba(255,255,255,.8);display:flex;align-items:center;justify-content:center;cursor:pointer;position:relative">
                        <svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 15V10a6 6 0 1 0-12 0v5l-1.5 2.5h15z"></path><path d="M10 20a2 2 0 0 0 4 0"></path></svg>
                        <span style="position:absolute;top:9px;inset-inline-end:10px;width:8px;height:8px;border-radius:50%;background:#FF2D32;border:1.5px solid #1B1B1B"></span>
                      </button>
                    </div>
                    <div style="display:flex;align-items:center;gap:14px">
                      <div role="img" aria-label="{{ t.profileName }}" style="width:58px;height:58px;border-radius:999px;background:{{ avatarBgLg }};border:1.5px solid rgba(255,255,255,.18);color:#fff;font-size:19px;font-weight:700;display:flex;align-items:center;justify-content:center;flex:none;overflow:hidden">
                        <sc-if value="{{ noAvatar }}" hint-placeholder-val="{{ false }}">
                          <span>{{ t.initials }}</span>
                        </sc-if>
                      </div>
                      <div style="min-width:0">
                        <div style="font-family:{{ ffDisp }};font-weight:700;font-size:21px;line-height:{{ lhTight }};color:#fff">{{ t.profileName }}</div>
                        <div style="font-size:12.5px;font-weight:500;color:rgba(255,255,255,.6);margin-top:4px;line-height:{{ lhSnug }}">{{ t.profileStage }}</div>
                        <button onClick="{{ openGrantFromProfile }}" style="display:inline-flex;align-items:center;gap:6px;margin-top:9px;background:rgba(255,198,46,.16);border:1px solid rgba(255,198,46,.35);border-radius:999px;padding:5px 11px;min-height:30px;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">
                          <span style="width:5px;height:5px;border-radius:50%;background:#FFC62E"></span>
                          <span style="font-size:10.5px;font-weight:700;color:#FFC62E;line-height:1">{{ grantBadgeL }}</span>
                        </button>
                      </div>
                    </div>
                    <div style="display:none">
                      <button onClick="{{ setEn }}" style="flex:1;height:34px;border-radius:999px;cursor:pointer;border:none;background:{{ enPillBg }};color:{{ enPillFg }};font:700 12.5px/1 Inter,sans-serif">EN</button>
                      <button onClick="{{ setAr }}" style="flex:1;height:34px;border-radius:999px;cursor:pointer;border:none;background:{{ arPillBg }};color:{{ arPillFg }};font:700 12.5px/1 'IBM Plex Sans Arabic',sans-serif;letter-spacing:0">عربي</button>
                    </div>
                  </div>
                  <div style="padding:22px 20px 30px">
                    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:16px;margin-bottom:20px;box-shadow:0 1px 3px rgba(0,0,0,.05)">
                      <div style="display:flex;align-items:center;justify-content:space-between;gap:10px;margin-bottom:8px">
                        <span style="font-size:13px;font-weight:700;color:#1B1B1B">{{ pcPctL }}</span>
                        <span style="font-size:12px;font-weight:800;color:#FF6B1A">{{ pcPct }}%</span>
                      </div>
                      <div style="height:6px;border-radius:4px;background:#E7E2DA;overflow:hidden;margin-bottom:8px"><div style="height:100%;border-radius:4px;background:{{ grad }};width:{{ pcPct }}%"></div></div>
                      <div style="font-size:11.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:10px">{{ pcSub }}</div>
                      <div style="display:grid;gap:6px">
                        <sc-for list="{{ pcItems }}" as="pc" hint-placeholder-count="3">
                          <button onClick="{{ pc.go }}" style="display:flex;align-items:center;justify-content:space-between;gap:10px;min-height:44px;padding:0 12px;background:#F5F2EC;border:none;border-radius:12px;cursor:pointer;text-align:start;font-family:{{ ff }};letter-spacing:{{ ls }}">
                            <span style="font-size:12px;font-weight:600;color:#1B1B1B">{{ pc.label }}</span>
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#FF6B1A" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" style="flex:none;transform:scaleX({{ flip }})"><path d="M9 5l7 7-7 7"></path></svg>
                          </button>
                        </sc-for>
                      </div>
                    </div>
                    <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:10px;line-height:1.4">{{ t.myLearning }}</div>
                    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:0 16px;margin-bottom:20px">
                      <sc-for list="{{ learnRows }}" as="r" hint-placeholder-count="3">
                        <button onClick="{{ r.go }}" style="width:100%;display:flex;align-items:center;justify-content:space-between;gap:12px;min-height:56px;background:none;border:none;border-bottom:1px solid #E7E2DA;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};text-align:start;padding:0">
                          <span style="display:flex;align-items:center;gap:12px;flex:1;min-width:0">
                            <span style="flex:none;width:36px;height:36px;border-radius:10px;background:#F5F2EC;display:flex;align-items:center;justify-content:center">
                              <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="#FF6B1A" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><path d="{{ r.icon }}"></path></svg>
                            </span>
                            <span style="min-width:0">
                              <span style="display:block;font-size:13.5px;font-weight:600;color:#1B1B1B">{{ r.label }}</span>
                              <span style="display:block;font-size:11px;font-weight:400;color:#716D67;margin-top:2px;line-height:1.45">{{ r.sub }}</span>
                            </span>
                          </span>
                          <span style="color:#716D67"><svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M9 5l7 7-7 7"></path></svg></span>
                        </button>
                      </sc-for>
                    </div>
                    <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:10px;line-height:1.4">{{ t.myCareer }}</div>
                    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:0 16px;margin-bottom:20px">
                      <sc-for list="{{ careerRows }}" as="r" hint-placeholder-count="3">
                        <button onClick="{{ r.go }}" style="width:100%;display:flex;align-items:center;justify-content:space-between;gap:12px;min-height:56px;background:none;border:none;border-bottom:1px solid #E7E2DA;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};text-align:start;padding:0">
                          <span style="display:flex;align-items:center;gap:12px;flex:1;min-width:0">
                            <span style="flex:none;width:36px;height:36px;border-radius:10px;background:#F5F2EC;display:flex;align-items:center;justify-content:center">
                              <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="#FF6B1A" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><path d="{{ r.icon }}"></path></svg>
                            </span>
                            <span style="min-width:0">
                              <span style="display:block;font-size:13.5px;font-weight:600;color:#1B1B1B">{{ r.label }}</span>
                              <span style="display:block;font-size:11px;font-weight:400;color:#716D67;margin-top:2px;line-height:1.45">{{ r.sub }}</span>
                            </span>
                          </span>
                          <span style="color:#716D67"><svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M9 5l7 7-7 7"></path></svg></span>
                        </button>
                      </sc-for>
                    </div>
                    <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:10px;line-height:1.4">{{ t.account }}</div>
                    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:0 16px;margin-bottom:20px">
                      <sc-for list="{{ accountRows }}" as="r" hint-placeholder-count="4">
                        <button onClick="{{ r.go }}" style="width:100%;display:flex;align-items:center;justify-content:space-between;gap:12px;min-height:56px;background:none;border:none;border-bottom:1px solid #E7E2DA;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};text-align:start;padding:0">
                          <span style="display:flex;align-items:center;gap:12px;flex:1;min-width:0">
                            <span style="flex:none;width:36px;height:36px;border-radius:10px;background:#F5F2EC;display:flex;align-items:center;justify-content:center">
                              <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="#FF6B1A" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><path d="{{ r.icon }}"></path></svg>
                            </span>
                            <span style="min-width:0">
                              <span style="display:block;font-size:13.5px;font-weight:600;color:#1B1B1B">{{ r.label }}</span>
                              <span style="display:block;font-size:11px;font-weight:400;color:#716D67;margin-top:2px;line-height:1.45">{{ r.sub }}</span>
                            </span>
                          </span>
                          <span style="display:flex;align-items:center;gap:8px">
                            <sc-if value="{{ r.web }}" hint-placeholder-val="{{ false }}">
                              <span style="font-size:10px;font-weight:700;color:#716D67;background:#F5F2EC;padding:4px 8px;border-radius:999px">{{ r.webLabel }}</span>
                            </sc-if>
                            <span style="color:#716D67"><svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M9 5l7 7-7 7"></path></svg></span>
                          </span>
                        </button>
                      </sc-for>
                    </div>
                    <div style="display:flex;gap:8px;margin-bottom:10px">
                      <button onClick="{{ openEditProfile }}" style="flex:1;min-height:48px;border-radius:13px;border:1.5px solid #E7E2DA;background:#fff;color:#1B1B1B;font-size:12.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ epTitle }}</button>
                      <button onClick="{{ openInvite }}" style="flex:1;min-height:48px;border-radius:13px;border:1.5px solid #FF6B1A;background:rgba(255,107,26,.06);color:#FF6B1A;font-size:12.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ invTitle }}</button>
                    </div>
                    <button onClick="{{ openLogout }}" style="width:100%;height:52px;border-radius:14px;border:1.5px solid #FF2D32;background:rgba(255,45,50,.08);color:#FF2D32;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.signOut }}</button>
                  </div>
                </div>
              </sc-if>

              <sc-if value="{{ isNfc }}" hint-placeholder-val="{{ false }}">
                <div style="padding:12px 20px 30px">
                  <button onClick="{{ goProfileHome }}" aria-label="{{ t.back }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center;margin-bottom:8px">
                    <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                  </button>
                  <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:14px;line-height:1.4">{{ t.rowNfc }}</div>
                  <div style="border-radius:24px;padding:24px;background:{{ grad }};box-shadow:0 8px 28px rgba(255,107,26,.35);margin-bottom:18px">
                    <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:14px;margin-bottom:24px">
                      <div style="min-width:0">
                        <div style="font-family:{{ ffDisp }};font-weight:700;font-size:23px;line-height:{{ lhTight }};color:#fff">{{ t.profileName }}</div>
                        <div style="font-size:12.5px;font-weight:600;color:rgba(255,255,255,.9);margin-top:6px;line-height:{{ lhSnug }}">{{ t.nfcTitle }}</div>
                        <div style="font-size:12px;font-weight:500;color:rgba(255,255,255,.75);margin-top:2px;line-height:{{ lhSnug }}">{{ t.nfcClinic }}</div>
                      </div>
                      <div style="flex:none;width:58px;height:58px;border-radius:10px;background:#fff;display:grid;grid-template-columns:repeat(5,1fr);grid-template-rows:repeat(5,1fr);gap:2px;padding:6px;box-sizing:border-box">
                        <span style="background:#1B1B1B"></span><span style="background:#1B1B1B"></span><span></span><span style="background:#1B1B1B"></span><span style="background:#1B1B1B"></span>
                        <span style="background:#1B1B1B"></span><span></span><span style="background:#1B1B1B"></span><span></span><span style="background:#1B1B1B"></span>
                        <span></span><span style="background:#1B1B1B"></span><span style="background:#1B1B1B"></span><span style="background:#1B1B1B"></span><span></span>
                        <span style="background:#1B1B1B"></span><span></span><span style="background:#1B1B1B"></span><span></span><span style="background:#1B1B1B"></span>
                        <span style="background:#1B1B1B"></span><span style="background:#1B1B1B"></span><span></span><span style="background:#1B1B1B"></span><span style="background:#1B1B1B"></span>
                      </div>
                    </div>
                    <div style="display:flex;flex-wrap:wrap;gap:7px">
                      <span style="font-size:10.5px;font-weight:700;color:#1B1B1B;background:rgba(255,255,255,.9);padding:5px 10px;border-radius:999px">{{ t.specEndo }}</span>
                      <span style="font-size:10.5px;font-weight:700;color:#1B1B1B;background:rgba(255,255,255,.9);padding:5px 10px;border-radius:999px">{{ t.specDigital }}</span>
                    </div>
                  </div>
                  <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:12px">
                    <button onClick="{{ nfcShare }}" style="height:52px;border-radius:14px;border:1.5px solid #E7E2DA;background:#fff;color:#1B1B1B;font-size:13px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.share }}</button>
                    <button onClick="{{ nfcWrite }}" style="height:52px;border-radius:14px;border:1.5px solid #E7E2DA;background:#fff;color:#1B1B1B;font-size:13px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.writeNfc }}</button>
                  </div>
                  <div style="display:flex;gap:10px">
                    <button onClick="{{ openPublicCard }}" style="flex:1;height:52px;border:1.5px solid #E7E2DA;border-radius:14px;background:#fff;color:#1B1B1B;font-size:13px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.publicCardTitle }}</button>
                    <button onClick="{{ openNfcEdit }}" style="flex:1;height:52px;border:none;border-radius:14px;background:#1B1B1B;color:#fff;font-size:13px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.editCard }}</button>
                  </div>
                  <div style="background:#F5F2EC;border-radius:14px;padding:14px 16px;margin-top:16px;font-size:12px;font-weight:500;line-height:{{ lhBody }};color:#716D67">{{ t.nfcNote }}</div>
                </div>
              </sc-if>

              <sc-if value="{{ isCerts }}" hint-placeholder-val="{{ false }}">
                <div style="padding:12px 20px 30px">
                  <button onClick="{{ goProfileHome }}" aria-label="{{ t.back }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center;margin-bottom:8px">
                    <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                  </button>
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:22px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:6px">{{ t.rowCertificates }}</div>
                  <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:16px">{{ certSub }}</div>
                  <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:8px;margin-bottom:16px">
                    <sc-for list="{{ certStats }}" as="s" hint-placeholder-count="4">
                      <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:12px;padding:10px 6px;text-align:center">
                        <div style="font-family:{{ ffDisp }};font-weight:700;font-size:15px;color:#1B1B1B;direction:ltr;unicode-bidi:isolate">{{ s.v }}</div>
                        <div style="font-size:8.5px;font-weight:600;color:#716D67;margin-top:4px;line-height:1.4">{{ s.l }}</div>
                      </div>
                    </sc-for>
                  </div>
                  <div style="display:flex;gap:8px;margin-bottom:10px">
                    <sc-for list="{{ certChips }}" as="chip" hint-placeholder-count="2">
                      <button onClick="{{ chip.pick }}" style="flex:1;height:40px;border-radius:12px;cursor:pointer;background:{{ chip.bg }};color:{{ chip.fg }};border:1.5px solid {{ chip.bd }};font-size:12px;font-weight:700;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ chip.label }}</button>
                    </sc-for>
                  </div>
                  <div style="font-size:12px;font-weight:700;color:#716D67;margin-bottom:14px">{{ certsFound }}</div>
                  <div style="display:grid;gap:12px;margin-bottom:16px">
                    <sc-for list="{{ certs }}" as="c" hint-placeholder-count="4">
                      <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;overflow:hidden">
                        <div style="background:#1B1B1B;padding:16px 16px 18px;text-align:center">
                          <div style="font-size:8.5px;font-weight:800;letter-spacing:.22em;color:#FFC62E;margin-bottom:9px">EJADAH INTERNATIONAL ACADEMY</div>
                          <div style="font-size:10px;font-weight:500;color:rgba(255,255,255,.5);margin-bottom:4px">{{ certifyL }}</div>
                          <div style="font-family:{{ ffDisp }};font-weight:700;font-size:15px;color:#fff;margin-bottom:4px">{{ t.profileName }}</div>
                          <div style="font-size:10px;font-weight:500;color:rgba(255,255,255,.5);margin-bottom:6px">{{ completedL }}</div>
                          <div style="font-size:12.5px;font-weight:700;line-height:{{ lhSnug }};color:#fff">{{ c.title }}</div>
                        </div>
                        <div style="padding:14px 16px 16px">
                          <div style="display:flex;flex-wrap:wrap;gap:6px;margin-bottom:10px">
                            <span style="font-size:10px;font-weight:700;color:{{ c.vFg }};background:{{ c.vBg }};padding:5px 9px;border-radius:999px">{{ c.vBadge }}</span>
                            <span style="font-size:10px;font-weight:600;color:#496FA8;background:rgba(73,111,168,.1);padding:5px 9px;border-radius:999px">{{ c.cat }}</span>
                            <sc-if value="{{ c.hasPts }}" hint-placeholder-val="{{ false }}">
                              <span style="font-size:10px;font-weight:700;color:#1B1B1B;background:#FFC62E;padding:5px 9px;border-radius:999px;direction:ltr;unicode-bidi:isolate">{{ c.pts }}</span>
                            </sc-if>
                          </div>
                          <div style="font-size:11px;font-weight:500;color:#716D67;margin-bottom:12px;line-height:{{ lhSnug }}">{{ c.date }} · <span style="direction:ltr;unicode-bidi:isolate">{{ c.hrs }}</span> · <span style="direction:ltr;unicode-bidi:isolate">{{ c.code }}</span></div>
                          <sc-if value="{{ c.ej }}" hint-placeholder-val="{{ true }}">
                            <div>
                              <div style="font-size:9.5px;font-weight:700;color:#716D67;margin-bottom:7px;line-height:1.4">{{ verL }}</div>
                              <div style="display:flex;flex-wrap:wrap;gap:6px;margin-bottom:12px">
                                <sc-for list="{{ c.vers }}" as="v" hint-placeholder-count="3">
                                  <button onClick="{{ v.req }}" style="border-radius:999px;padding:6px 10px;cursor:pointer;background:{{ v.bg }};color:{{ v.fg }};border:1.5px solid {{ v.bd }};font-size:10px;font-weight:700;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ v.n }}</button>
                                </sc-for>
                              </div>
                            </div>
                          </sc-if>
                          <div style="display:flex;gap:8px">
                            <button onClick="{{ dlCert }}" style="flex:1;height:44px;border-radius:11px;border:1.5px solid #E7E2DA;background:#fff;color:#1B1B1B;font-size:11.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ pdfL }}</button>
                            <button onClick="{{ copyCert }}" style="flex:1;height:44px;border-radius:11px;border:1.5px solid #E7E2DA;background:#fff;color:#1B1B1B;font-size:11.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ copyL }}</button>
                            <sc-if value="{{ c.ej }}" hint-placeholder-val="{{ true }}">
                              <button onClick="{{ openVerify }}" style="flex:1;height:44px;border-radius:11px;border:none;background:#1B1B1B;color:#fff;font-size:11.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.shareVerify }}</button>
                            </sc-if>
                          </div>
                        </div>
                      </div>
                    </sc-for>
                  </div>
                  <button onClick="{{ addExternalCert }}" style="width:100%;height:48px;border:1.5px dashed #C9C2B8;border-radius:14px;background:#fff;color:#716D67;font-size:12.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ addCertL }}</button>
                  <div style="font-size:11px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin:10px 2px 16px">{{ addCertNote }}</div>
                  <div style="background:#1B1B1B;border-radius:18px;padding:18px">
                    <div style="font-size:10.5px;font-weight:700;color:#FFC62E;margin-bottom:8px;line-height:1.4">{{ liT }}</div>
                    <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:rgba(255,255,255,.7);margin-bottom:14px">{{ liB }}</div>
                    <button onClick="{{ liConnect }}" style="height:44px;padding:0 16px;border:none;border-radius:12px;background:#fff;color:#1B1B1B;font-size:12.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ liBtn }}</button>
                  </div>
                </div>
              </sc-if>

              <sc-if value="{{ isNotifs }}" hint-placeholder-val="{{ false }}">
                <div style="padding:12px 20px 30px">
                  <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:8px">
                    <button onClick="{{ goProfileHome }}" aria-label="{{ t.back }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center">
                      <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                    </button>
                    <button onClick="{{ markRead }}" style="background:none;border:none;min-height:44px;cursor:pointer;font-size:12.5px;font-weight:700;color:#FF6B1A;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.markAllRead }}</button>
                  </div>
                  <div style="display:grid;gap:10px">
                    <sc-for list="{{ notifs }}" as="n" hint-placeholder-count="4">
                      <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:15px;display:flex;gap:12px;align-items:flex-start">
                        <span style="flex:none;width:8px;height:8px;border-radius:999px;background:{{ n.dotBg }};margin-top:6px"></span>
                        <span style="min-width:0">
                          <span style="display:block;font-size:10px;font-weight:700;color:#716D67;margin-bottom:5px">{{ n.g }}</span>
                          <span style="display:block;font-size:13.5px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ n.title }}</span>
                          <span style="display:block;font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-top:3px">{{ n.body }}</span>
                        </span>
                      </div>
                    </sc-for>
                  </div>
                </div>
              </sc-if>

              <sc-if value="{{ isNfcEdit }}" hint-placeholder-val="{{ false }}">
                <div style="padding:12px 20px 30px">
                  <button onClick="{{ goProfileHome }}" aria-label="{{ t.back }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center;margin-bottom:8px">
                    <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                  </button>
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:22px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:16px">{{ t.editCardTitle }}</div>
                  <div style="border-radius:18px;padding:16px;background:{{ grad }};margin-bottom:20px">
                    <div style="font-family:{{ ffDisp }};font-weight:700;font-size:18px;line-height:{{ lhTight }};color:#fff">{{ t.profileName }}</div>
                    <div style="font-size:11.5px;font-weight:600;color:rgba(255,255,255,.9);margin-top:5px">{{ t.nfcTitle }}</div>
                  </div>
                  <label style="display:block;font-size:12px;font-weight:600;color:#1B1B1B;margin-bottom:8px">{{ t.fullName }}</label>
                  <div style="height:48px;border:1.5px solid #E7E2DA;border-radius:12px;background:#fff;display:flex;align-items:center;padding:0 14px;font-size:14px;color:#1B1B1B;margin-bottom:14px">{{ t.profileName }}</div>
                  <label style="display:block;font-size:12px;font-weight:600;color:#1B1B1B;margin-bottom:8px">{{ t.fieldTitle }}</label>
                  <div style="height:48px;border:1.5px solid #E7E2DA;border-radius:12px;background:#fff;display:flex;align-items:center;padding:0 14px;font-size:14px;color:#1B1B1B;margin-bottom:14px">{{ t.nfcTitle }}</div>
                  <label style="display:block;font-size:12px;font-weight:600;color:#1B1B1B;margin-bottom:8px">{{ t.fieldClinic }}</label>
                  <div style="height:48px;border:1.5px solid #E7E2DA;border-radius:12px;background:#fff;display:flex;align-items:center;padding:0 14px;font-size:14px;color:#1B1B1B;margin-bottom:14px">{{ t.nfcClinic }}</div>
                  <label style="display:block;font-size:12px;font-weight:600;color:#1B1B1B;margin-bottom:8px">{{ t.fieldBio }}</label>
                  <div style="min-height:82px;border:1.5px solid #E7E2DA;border-radius:12px;background:#fff;padding:14px;font-size:13px;line-height:{{ lhBody }};color:#716D67;margin-bottom:20px">{{ t.tutorBio }}</div>
                  <button onClick="{{ goProfileHome }}" style="width:100%;height:52px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.saveChanges }}</button>
                </div>
              </sc-if>

              <sc-if value="{{ isPublicCard }}" hint-placeholder-val="{{ false }}">
                <div style="padding:12px 20px 30px">
                  <button onClick="{{ goProfileHome }}" aria-label="{{ t.back }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center;margin-bottom:8px">
                    <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                  </button>
                  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:22px;overflow:hidden;box-shadow:0 3px 12px rgba(0,0,0,.07)">
                    <div style="height:104px;background:{{ grad }}"></div>
                    <div style="padding:0 20px 22px;margin-top:-38px">
                      <div role="img" aria-label="{{ t.profileName }}" style="width:76px;height:76px;border-radius:999px;border:3px solid #fff;background:#F5F2EC center/cover no-repeat url(https://i.pravatar.cc/240?img=26);margin-bottom:12px"></div>
                      <div style="font-family:{{ ffDisp }};font-weight:700;font-size:21px;line-height:{{ lhTight }};color:#1B1B1B">{{ t.profileName }}</div>
                      <div style="font-size:12.5px;font-weight:600;color:#FF6B1A;margin-top:6px">{{ t.nfcTitle }}</div>
                      <div style="font-size:12px;font-weight:500;color:#716D67;margin-top:4px">{{ t.nfcClinic }}</div>
                      <div style="display:flex;flex-wrap:wrap;gap:7px;margin-top:14px">
                        <span style="font-size:10.5px;font-weight:700;color:#716D67;background:#F5F2EC;padding:6px 10px;border-radius:999px">{{ t.specEndo }}</span>
                        <span style="font-size:10.5px;font-weight:700;color:#716D67;background:#F5F2EC;padding:6px 10px;border-radius:999px">{{ t.specDigital }}</span>
                      </div>
                    </div>
                  </div>
                  <div style="font-size:11.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-top:16px;text-align:center">{{ t.nfcNote }}</div>
                </div>
              </sc-if>

              <sc-if value="{{ isPayResult }}" hint-placeholder-val="{{ false }}">
                <div style="padding:60px 24px 30px;text-align:center">
                  <sc-if value="{{ isPaySuccess }}" hint-placeholder-val="{{ true }}">
                    <div>
                      <div style="width:64px;height:64px;border-radius:999px;background:rgba(45,155,104,.1);color:#2D9B68;display:flex;align-items:center;justify-content:center;margin:0 auto 18px">
                        <svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="M5 13l4.5 4.5L19 7"></path></svg>
                      </div>
                      <div style="font-family:{{ ffDisp }};font-weight:700;font-size:24px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:10px">{{ t.paidTitle }}</div>
                      <div style="font-size:13.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:24px">{{ t.paidBody }}</div>
                      <button onClick="{{ goCoursePlayer }}" style="width:100%;height:52px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.backToCourse }}</button>
                    </div>
                  </sc-if>
                  <sc-if value="{{ isBookSuccess }}" hint-placeholder-val="{{ false }}">
                    <div>
                      <div style="width:64px;height:64px;border-radius:999px;background:rgba(45,155,104,.1);color:#2D9B68;display:flex;align-items:center;justify-content:center;margin:0 auto 18px">
                        <svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="M5 13l4.5 4.5L19 7"></path></svg>
                      </div>
                      <div style="font-family:{{ ffDisp }};font-weight:700;font-size:24px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:8px">{{ t.bookedTitle }}</div>
                      <div style="font-size:13px;font-weight:700;color:#1B1B1B;margin-bottom:10px;direction:ltr;unicode-bidi:isolate">{{ bookedWhen }} · {{ who.name }}</div>
                      <div style="font-size:11px;font-weight:600;color:#716D67;margin-bottom:10px;direction:ltr;unicode-bidi:isolate">{{ bookRef }}</div>
                      <div style="font-size:13.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:24px">{{ t.bookedBody }}</div>
                      <button onClick="{{ goBookings }}" style="width:100%;height:52px;border:none;border-radius:14px;background:{{ grad }};box-shadow:0 4px 20px rgba(255,107,26,.28);color:#fff;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.seeBookings }}</button>
                    </div>
                  </sc-if>
                  <sc-if value="{{ isPayCancel }}" hint-placeholder-val="{{ false }}">
                    <div>
                      <div style="width:64px;height:64px;border-radius:999px;background:#F5F2EC;color:#716D67;display:flex;align-items:center;justify-content:center;margin:0 auto 18px">
                        <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round"><path d="M6 6l12 12M18 6L6 18"></path></svg>
                      </div>
                      <div style="font-family:{{ ffDisp }};font-weight:700;font-size:24px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:10px">{{ t.cancelTitle }}</div>
                      <div style="font-size:13.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:24px">{{ t.cancelBody }}</div>
                      <button onClick="{{ goProfileHome }}" style="width:100%;height:52px;border:1.5px solid #E7E2DA;border-radius:14px;background:#fff;color:#1B1B1B;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.tryPayAgain }}</button>
                    </div>
                  </sc-if>
                </div>
              </sc-if>

              <sc-if value="{{ isPricing }}" hint-placeholder-val="{{ false }}">
                <div style="padding:12px 20px 30px">
                  <button onClick="{{ goProfileHome }}" aria-label="{{ t.back }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center;margin-bottom:8px">
                    <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                  </button>
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:22px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:18px">{{ t.plansTitle }}</div>
                  <div style="display:grid;gap:12px">
                    <sc-for list="{{ plans }}" as="p" hint-placeholder-count="3">
                      <div style="background:{{ p.bg }};border:1.5px solid {{ p.bd }};border-radius:20px;padding:18px">
                        <div style="font-size:12.5px;font-weight:700;color:{{ p.fg }};margin-bottom:8px">{{ p.name }}</div>
                        <div style="display:flex;align-items:baseline;gap:6px;margin-bottom:14px">
                          <span style="font-family:{{ ffDisp }};font-weight:700;font-size:24px;color:{{ p.fg }};direction:ltr;unicode-bidi:isolate">{{ p.price }}</span>
                          <span style="font-size:11.5px;font-weight:500;color:{{ p.sub }}">{{ p.per }}</span>
                        </div>
                        <div style="display:grid;gap:8px;margin-bottom:16px">
                          <sc-for list="{{ p.items }}" as="it" hint-placeholder-count="3">
                            <div style="display:flex;gap:9px;align-items:flex-start">
                              <span style="flex:none;color:#2D9B68;margin-top:2px"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="M5 13l4.5 4.5L19 7"></path></svg></span>
                              <span style="font-size:12.5px;font-weight:400;line-height:{{ lhSnug }};color:{{ p.fg }}">{{ it }}</span>
                            </div>
                          </sc-for>
                        </div>
                        <button onClick="{{ p.go }}" style="width:100%;height:46px;border:none;border-radius:12px;background:{{ p.ctaBg }};color:{{ p.ctaFg }};font-size:13px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ p.cta }}</button>
                      </div>
                    </sc-for>
                  </div>
                  <div style="background:#F5F2EC;border-radius:14px;padding:14px 16px;margin-top:16px;font-size:12px;font-weight:500;line-height:{{ lhBody }};color:#716D67">{{ t.payNote }}</div>
                </div>
              </sc-if>

              <sc-if value="{{ isShortlist }}" hint-placeholder-val="{{ false }}">
                <div style="padding:12px 20px 30px">
                  <button onClick="{{ goProfileHome }}" aria-label="{{ t.back }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center;margin-bottom:8px">
                    <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                  </button>
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:22px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:6px">{{ t.shortlistTitle }}</div>
                  <div style="font-size:12.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:18px">{{ savedSummary }}</div>
                  <sc-if value="{{ hasSaved }}" hint-placeholder-val="{{ false }}">
                    <div style="display:grid;gap:12px">
                      <sc-for list="{{ savedList }}" as="s" hint-placeholder-count="2">
                        <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:16px">
                          <div style="display:flex;align-items:center;gap:11px;margin-bottom:10px">
                            <span role="img" aria-label="{{ s.countryLabel }}" style="flex:none;width:34px;height:24px;border-radius:4px;border:1px solid #E7E2DA;background:{{ s.flagBg }}"></span>
                            <span style="font-size:13.5px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B;direction:ltr;unicode-bidi:isolate;text-align:start">{{ s.uni }}</span>
                          </div>
                          <div style="font-size:12.5px;font-weight:400;line-height:{{ lhSnug }};color:#716D67;margin-bottom:10px">{{ s.name }}</div>
                          <div style="display:flex;align-items:center;justify-content:space-between;gap:10px">
                            <span style="font-size:10.5px;font-weight:700;color:{{ s.stFg }};background:{{ s.stBg }};padding:5px 9px;border-radius:999px">{{ s.stText }}</span>
                            <span style="font-size:12.5px;font-weight:700;color:#1B1B1B;direction:ltr;unicode-bidi:isolate">{{ s.cost }}</span>
                          </div>
                        </div>
                      </sc-for>
                    </div>
                  </sc-if>
                  <sc-if value="{{ noSaved }}" hint-placeholder-val="{{ true }}">
                    <div style="padding:34px 10px;text-align:center">
                      <div style="font-size:17px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B;margin-bottom:6px">{{ t.emptySavedTitle }}</div>
                      <div style="font-size:13px;font-weight:400;line-height:{{ lhBody }};color:#716D67">{{ t.emptySavedBody }}</div>
                    </div>
                  </sc-if>
                </div>
              </sc-if>

              <sc-if value="{{ isHandouts }}" hint-placeholder-val="{{ false }}">
                <div style="padding:12px 20px 30px">
                  <button onClick="{{ goProfileHome }}" aria-label="{{ t.back }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center;margin-bottom:8px">
                    <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                  </button>
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:22px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:18px">{{ t.handoutsTitle }}</div>
                  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:0 16px">
                    <sc-for list="{{ handouts }}" as="h" hint-placeholder-count="3">
                      <div style="display:flex;align-items:center;gap:12px;padding:15px 0;border-bottom:1px solid #E7E2DA">
                        <span style="flex:none;width:34px;height:40px;border-radius:6px;background:#F5F2EC;border:1.5px solid #E7E2DA;display:flex;align-items:center;justify-content:center;font-size:9px;font-weight:800;color:#716D67">PDF</span>
                        <span style="flex:1;min-width:0">
                          <span style="display:block;font-size:13px;font-weight:600;line-height:{{ lhSnug }};color:#1B1B1B">{{ h.name }}</span>
                          <span style="display:block;font-size:11px;font-weight:500;color:#716D67;margin-top:3px;direction:ltr;unicode-bidi:isolate">{{ h.size }}</span>
                        </span>
                        <button onClick="{{ downloadTap }}" aria-label="{{ t.download }}" style="flex:none;width:44px;height:44px;border-radius:12px;border:1.5px solid #E7E2DA;background:#fff;color:#1B1B1B;cursor:pointer;display:flex;align-items:center;justify-content:center">
                          <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 4v11"></path><path d="M7 11l5 5 5-5"></path><path d="M5 20h14"></path></svg>
                        </button>
                      </div>
                    </sc-for>
                  </div>
                </div>
              </sc-if>

              <sc-if value="{{ isSettings }}" hint-placeholder-val="{{ false }}">
                <div style="padding:12px 20px 30px">
                  <button onClick="{{ goProfileHome }}" aria-label="{{ t.back }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center;margin-bottom:8px">
                    <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                  </button>
                  <div style="font-family:{{ ffDisp }};font-weight:700;font-size:22px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:20px">{{ t.rowSettings }}</div>

                  <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:10px;line-height:1.4">{{ t.languageLabel }}</div>
                  <div style="display:flex;gap:8px;margin-bottom:22px">
                    <button onClick="{{ setEn }}" style="flex:1;height:44px;border-radius:12px;cursor:pointer;border:1.5px solid {{ enBorder }};background:{{ enBg }};color:{{ enFg }};font:700 13px/1 Inter,sans-serif">EN</button>
                    <button onClick="{{ setAr }}" style="flex:1;height:44px;border-radius:12px;cursor:pointer;border:1.5px solid {{ arBorder }};background:{{ arBg }};color:{{ arFg }};font:700 13px/1 'IBM Plex Sans Arabic',sans-serif;letter-spacing:0">عربي</button>
                  </div>

                  <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:10px;line-height:1.4">{{ t.notifPrefs }}</div>
                  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:0 16px;margin-bottom:22px">
                    <sc-for list="{{ settingRows }}" as="r" hint-placeholder-count="4">
                      <button onClick="{{ r.go }}" style="display:flex;align-items:center;justify-content:space-between;gap:12px;width:100%;background:none;border:none;border-bottom:1px solid #E7E2DA;padding:14px 0;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};text-align:start">
                        <span style="font-size:13px;font-weight:500;color:#1B1B1B">{{ r.label }}</span>
                        <span style="flex:none;width:42px;height:24px;border-radius:999px;background:{{ r.trackBg }};display:flex;align-items:center;padding:3px;box-sizing:border-box">
                          <span style="width:18px;height:18px;border-radius:999px;background:#fff;margin-inline-start:{{ r.knob }};box-shadow:0 1px 3px rgba(0,0,0,.2)"></span>
                        </span>
                      </button>
                    </sc-for>
                  </div>

                  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:18px;padding:0 16px;margin-bottom:22px">
                    <button onClick="{{ clearCacheGo }}" style="width:100%;display:flex;align-items:center;justify-content:space-between;gap:12px;padding:15px 0;border:none;border-bottom:1px solid #E7E2DA;background:none;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};text-align:start">
                      <span style="font-size:13px;font-weight:500;color:#1B1B1B">{{ t.clearCache }}</span>
                      <span style="font-size:11.5px;font-weight:600;color:#716D67;direction:ltr;unicode-bidi:isolate">124 MB</span>
                    </button>
                    <button onClick="{{ webOpen }}" style="width:100%;display:flex;align-items:center;justify-content:space-between;gap:12px;padding:15px 0;border:none;border-bottom:1px solid #E7E2DA;background:none;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};text-align:start">
                      <span style="font-size:13px;font-weight:500;color:#1B1B1B">{{ t.privacy }}</span>
                      <span style="color:#716D67"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M9 5l7 7-7 7"></path></svg></span>
                    </button>
                    <button onClick="{{ webOpen }}" style="width:100%;display:flex;align-items:center;justify-content:space-between;gap:12px;padding:15px 0;border:none;background:none;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }};text-align:start">
                      <span style="font-size:13px;font-weight:500;color:#1B1B1B">{{ t.terms }}</span>
                      <span style="color:#716D67"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M9 5l7 7-7 7"></path></svg></span>
                    </button>
                  </div>

                  <button onClick="{{ openDelete }}" style="width:100%;height:52px;border-radius:14px;border:1.5px solid #FF2D32;background:rgba(255,45,50,.08);color:#FF2D32;font-size:13.5px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.deleteAccount }}</button>
                  <div style="text-align:center;font-size:11px;font-weight:500;color:#716D67;margin-top:16px;direction:ltr;unicode-bidi:isolate">Ejadah 1.0.0 (build 14)</div>
                </div>
              </sc-if>

              <sc-if value="{{ isMembership }}" hint-placeholder-val="{{ false }}">
                <div style="padding:12px 20px 30px">
                  <button onClick="{{ goProfileHome }}" aria-label="{{ t.back }}" style="width:44px;height:44px;background:none;border:none;cursor:pointer;color:#1B1B1B;display:flex;align-items:center;justify-content:center;margin-bottom:8px">
                    <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transform:scaleX({{ flip }})"><path d="M15 5l-7 7 7 7"></path></svg>
                  </button>
                  <div style="background:#1B1B1B;border-radius:20px;padding:22px;margin-bottom:18px">
                    <div style="font-size:10.5px;font-weight:700;color:#FFC62E;margin-bottom:10px;line-height:1.4">{{ t.currentPlan }}</div>
                    <div style="font-family:{{ ffDisp }};font-weight:700;font-size:24px;line-height:{{ lhTight }};color:#fff;margin-bottom:6px">{{ plan.name }}</div>
                    <div style="font-size:12.5px;font-weight:500;color:rgba(255,255,255,.6);line-height:{{ lhSnug }}">{{ plan.renews }}</div>
                  </div>
                  <div style="font-size:11px;font-weight:600;color:#FF6B1A;margin-bottom:12px;line-height:1.4">{{ t.included }}</div>
                  <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:20px;padding:6px 16px;margin-bottom:18px">
                    <sc-for list="{{ planIncludes }}" as="perk" hint-placeholder-count="6">
                      <div style="display:flex;gap:10px;align-items:flex-start;padding:13px 0;border-bottom:1px solid #E7E2DA">
                        <span style="flex:none;color:#2D9B68;margin-top:2px"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="M5 13l4.5 4.5L19 7"></path></svg></span>
                        <span style="font-size:13px;font-weight:400;line-height:{{ lhBody }};color:#1B1B1B">{{ perk }}</span>
                      </div>
                    </sc-for>
                  </div>
                  <div style="background:#F5F2EC;border-radius:12px;padding:13px 15px;font-size:11.5px;font-weight:500;line-height:{{ lhBody }};color:#716D67">{{ membershipNote }}</div>
                </div>
              </sc-if>
            </div>
          </sc-if>

          <sc-if value="{{ isStub }}" hint-placeholder-val="{{ false }}">
            <div style="padding:60px 28px;text-align:center">
              <div style="width:56px;height:56px;border-radius:16px;background:#F5F2EC;border:1.5px solid #E7E2DA;color:#716D67;display:flex;align-items:center;justify-content:center;margin:0 auto 18px">
                <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"></circle><path d="M12 8v4l3 2"></path></svg>
              </div>
              <div style="font-family:{{ ffDisp }};font-weight:700;font-size:22px;line-height:{{ lhTight }};color:#1B1B1B;margin-bottom:8px">{{ stubTitle }}</div>
              <div style="font-size:13.5px;font-weight:400;line-height:{{ lhBody }};color:#716D67;margin-bottom:22px">{{ t.stubBody }}</div>
              <button onClick="{{ goHome }}" style="height:52px;padding:0 26px;border:1.5px solid #E7E2DA;border-radius:14px;background:#fff;color:#1B1B1B;font-size:14px;font-weight:700;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ t.backHome }}</button>
            </div>
          </sc-if>

        </div>

        <sc-if value="{{ hasToast }}" hint-placeholder-val="{{ false }}">
          <div style="position:relative;height:0">
            <div style="position:absolute;inset-inline:16px;bottom:10px;background:#1B1B1B;border-radius:14px;min-height:52px;display:flex;align-items:center;gap:12px;padding:12px 16px;box-shadow:0 8px 28px rgba(0,0,0,.28);z-index:20">
              <span style="width:4px;align-self:stretch;border-radius:2px;background:#2D9B68;flex:none"></span>
              <span style="font-size:12.5px;font-weight:500;line-height:{{ lhSnug }};color:#fff">{{ toastMsg }}</span>
            </div>
          </div>
        </sc-if>
        <sc-if value="{{ hasToast }}" hint-placeholder-val="{{ false }}">
          <div style="position:absolute;inset-inline:18px;bottom:96px;z-index:30;background:#1B1B1B;border-radius:14px;padding:13px 16px;display:flex;align-items:center;gap:11px;box-shadow:0 8px 28px rgba(0,0,0,.3)">
            <span style="width:4px;height:22px;border-radius:2px;background:#FFC62E;flex:none"></span>
            <span style="flex:1;min-width:0;font-size:12.5px;font-weight:600;color:#fff;line-height:1.5">{{ toastMsg }}</span>
            <sc-if value="{{ hasUndo }}" hint-placeholder-val="{{ false }}">
              <button onClick="{{ doUndo }}" style="flex:none;min-height:36px;padding:0 12px;border:1px solid rgba(255,255,255,.24);border-radius:9px;background:rgba(255,255,255,.1);color:#FFC62E;font-size:11.5px;font-weight:800;cursor:pointer;font-family:{{ ff }};letter-spacing:{{ ls }}">{{ undoL }}</button>
            </sc-if>
          </div>
        </sc-if>

        <div style="flex:none;background:#1B1B1B;border-top:1px solid rgba(255,255,255,.08);padding:8px 2px 18px;display:{{ tabBarDisplay }};grid-template-columns:repeat(6,1fr)">
          <button onClick="{{ goHome }}" aria-label="{{ t.tabHome }}" style="background:none;border:none;cursor:pointer;padding:6px 0;display:flex;flex-direction:column;align-items:center;gap:5px;min-height:44px;font-family:{{ ff }};letter-spacing:{{ ls }}">
            <span style="width:20px;height:3px;border-radius:2px;background:{{ barHome }}"></span>
            <span style="color:{{ fgHome }}"><svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 10.5 12 3l9 7.5V21H3z"></path></svg></span>
            <span style="font-size:9.5px;font-weight:600;color:{{ lbHome }};line-height:1;white-space:nowrap">{{ t.tabHome }}</span>
          </button>
          <button onClick="{{ goConnect }}" aria-label="{{ t.tabConnect }}" style="background:none;border:none;cursor:pointer;padding:6px 0;display:flex;flex-direction:column;align-items:center;gap:5px;min-height:44px;font-family:{{ ff }};letter-spacing:{{ ls }}">
            <span style="width:20px;height:3px;border-radius:2px;background:{{ barConnect }}"></span>
            <span style="color:{{ fgConnect }}"><svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="8" r="3.2"></circle><path d="M3 20c0-3.3 2.7-5.5 6-5.5s6 2.2 6 5.5"></path><circle cx="17.5" cy="9" r="2.6"></circle><path d="M17 14.6c2.4.3 4 2.3 4 5.4"></path></svg></span>
            <span style="font-size:9.5px;font-weight:600;color:{{ lbConnect }};line-height:1;white-space:nowrap">{{ t.tabConnect }}</span>
          </button>
          <button onClick="{{ goCourses }}" aria-label="{{ t.tabCourses }}" style="background:none;border:none;cursor:pointer;padding:6px 0;display:flex;flex-direction:column;align-items:center;gap:5px;min-height:44px;font-family:{{ ff }};letter-spacing:{{ ls }}">
            <span style="width:20px;height:3px;border-radius:2px;background:{{ barCourses }}"></span>
            <span style="color:{{ fgCourses }}"><svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 4h9a2 2 0 0 1 2 2v14H7a2 2 0 0 1-2-2z"></path><path d="M16 6h3v14h-3"></path></svg></span>
            <span style="font-size:9.5px;font-weight:600;color:{{ lbCourses }};line-height:1;white-space:nowrap">{{ t.tabCourses }}</span>
          </button>
          <button onClick="{{ goCareer }}" aria-label="{{ t.tabCareer }}" style="background:none;border:none;cursor:pointer;padding:6px 0;display:flex;flex-direction:column;align-items:center;gap:5px;min-height:44px;font-family:{{ ff }};letter-spacing:{{ ls }}">
            <span style="width:20px;height:3px;border-radius:2px;background:{{ barCareer }}"></span>
            <span style="color:{{ fgCareer }}"><svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"></circle><path d="M15.5 8.5l-2 5-5 2 2-5z"></path></svg></span>
            <span style="font-size:9.5px;font-weight:600;color:{{ lbCareer }};line-height:1;white-space:nowrap">{{ t.tabCareer }}</span>
          </button>
          <button onClick="{{ goMasters }}" aria-label="{{ t.tabMasters }}" style="background:none;border:none;cursor:pointer;padding:6px 0;display:flex;flex-direction:column;align-items:center;gap:5px;min-height:44px;font-family:{{ ff }};letter-spacing:{{ ls }}">
            <span style="width:20px;height:3px;border-radius:2px;background:{{ barMasters }}"></span>
            <span style="color:{{ fgMasters }}"><svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 8.5 12 4l10 4.5-10 4.5z"></path><path d="M6 10.8V16c0 1.7 2.7 3 6 3s6-1.3 6-3v-5.2"></path></svg></span>
            <span style="font-size:9.5px;font-weight:600;color:{{ lbMasters }};line-height:1;white-space:nowrap">{{ t.tabMasters }}</span>
          </button>
          <button onClick="{{ goProfile }}" aria-label="{{ t.tabProfile }}" style="background:none;border:none;cursor:pointer;padding:6px 0;display:flex;flex-direction:column;align-items:center;gap:5px;min-height:44px;font-family:{{ ff }};letter-spacing:{{ ls }}">
            <span style="width:20px;height:3px;border-radius:2px;background:{{ barProfile }}"></span>
            <span style="color:{{ fgProfile }}"><svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="9" r="4.4"></circle><path d="M6 20.5c0-3 2.7-5 6-5s6 2 6 5"></path></svg></span>
            <span style="font-size:9.5px;font-weight:600;color:{{ lbProfile }};line-height:1;white-space:nowrap">{{ t.tabProfile }}</span>
          </button>
        </div>

      </div>
    </div>
  </div>

  <div style="width:300px;flex:none;position:sticky;top:40px">
    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:18px;margin-bottom:16px">
      <div style="font:600 10.5px/1 Inter,sans-serif;letter-spacing:.12em;text-transform:uppercase;color:#716D67;margin-bottom:12px">Gradient budget · this screen</div>
      <div style="font:700 30px/1 'Playfair Display',serif;color:#1B1B1B">3 <span style="font:500 13px/1 Inter,sans-serif;color:#716D67">of 6 permitted</span></div>
      <div style="font:400 12px/1.7 Inter,sans-serif;color:#716D67;margin-top:10px">Roadmap CTA · active tab indicator · avatar tile. Progress bars inside cards reuse the CTA gradient only when a roadmap exists, which replaces the CTA card.</div>
    </div>
    <div style="background:#fff;border:1.5px solid #E7E2DA;border-radius:16px;padding:18px">
      <div style="font:600 10.5px/1 Inter,sans-serif;letter-spacing:.12em;text-transform:uppercase;color:#716D67;margin-bottom:12px">Next in build order</div>
      <ol style="margin:0;padding-inline-start:18px;font:400 12.5px/1.9 Inter,sans-serif;color:#1B1B1B">
        <li>Masters — 199 records, filters, compare, shortlist</li>
        <li>Career — roadmap funnel, result, what-if, country guides</li>
        <li>Courses — catalogue, player, handouts, flashcards, quizzes</li>
        <li>Connect — the three marketplaces, booking, earnings</li>
        <li>Profile — NFC card, certificates, notifications, membership</li>
      </ol>
      <div style="font:400 12px/1.7 Inter,sans-serif;color:#716D67;margin-top:12px">Six tabs: Home, Connect, Courses, Career, Masters, Profile. Courses, Masters and Profile show a designed placeholder until their screens land.</div>
    </div>
  </div>

</div>



<template id="__bundler_thumbnail">
  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#FF2D32"></stop><stop offset=".5" stop-color="#FF6B1A"></stop><stop offset="1" stop-color="#FFC62E"></stop></linearGradient></defs><rect width="100" height="100" rx="22" fill="url(#g)"></rect><text x="50" y="63" font-family="Georgia,serif" font-size="34" font-weight="bold" fill="#fff" text-anchor="middle">EJ</text></svg>
</template>
```

## Logic

_Template-only component — no logic class._
