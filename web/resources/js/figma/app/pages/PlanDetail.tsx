import { useState } from "react";
import { useNavigate, useParams } from "react-router";
import { Check, X, ChevronDown, ChevronUp, ArrowRight, ArrowLeft, Star } from "lucide-react";
import { brand, gradientFlow } from "@/figma/app/shared";
import { PLANS, FEATURE_GROUPS, getPlan, formatPrice, annualSaving } from "@/figma/app/pricingData";

export default function PlanDetail() {
  const { planId } = useParams();
  const nav = useNavigate();
  const [annual, setAnnual] = useState(true);
  const [openFaq, setOpenFaq] = useState<number | null>(null);

  const plan = getPlan(planId ?? "");
  if (!plan) {
    return (
      <div style={{ background: brand.offWhite, minHeight: "100vh", display: "flex", flexDirection: "column" as const, alignItems: "center", justifyContent: "center", padding: 40, textAlign: "center" as const }}>
        <div style={{ fontSize: 48, marginBottom: 16 }}>🔍</div>
        <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 24, color: brand.charcoal, marginBottom: 12 }}>Plan not found</div>
        <button onClick={() => nav("/pricing")} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "12px 24px", cursor: "pointer" }}>View All Plans</button>
      </div>
    );
  }

  const planIndex = PLANS.findIndex((p) => p.id === plan.id);
  const prevPlan = planIndex > 0 ? PLANS[planIndex - 1] : null;
  const nextPlan = planIndex < PLANS.length - 1 ? PLANS[planIndex + 1] : null;
  const isGold = plan.id === "elite";

  const groupedFeatures: Record<string, [string, boolean | string][]> = {};
  for (const [feature, value] of Object.entries(plan.features)) {
    const group = Object.entries(FEATURE_GROUPS).find(([, features]) => features.includes(feature))?.[0] ?? "Other";
    if (!groupedFeatures[group]) groupedFeatures[group] = [];
    groupedFeatures[group].push([feature, value]);
  }

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>

      {/* ── Hero ── */}
      <div style={{ background: isGold ? `linear-gradient(135deg, ${brand.deepCharcoal}, #2A2510)` : `linear-gradient(135deg, ${brand.deepCharcoal}, #1E1B17)`, padding: "48px 24px 40px", position: "relative", overflow: "hidden" }}>
        {isGold && <div style={{ position: "absolute", inset: 0, background: "radial-gradient(ellipse at 70% 30%, rgba(255,198,46,0.12) 0%, transparent 60%)", pointerEvents: "none" }} />}

        <div style={{ maxWidth: 900, margin: "0 auto", position: "relative" }}>
          <button onClick={() => nav("/pricing")} style={{ background: "none", border: "none", cursor: "pointer", color: "rgba(255,255,255,0.4)", fontFamily: "Inter", fontSize: 13, display: "flex", alignItems: "center", gap: 5, marginBottom: 24 }}>
            <ArrowLeft size={14} /> All Plans
          </button>

          <div style={{ display: "flex", gap: 32, alignItems: "flex-start", flexWrap: "wrap" }}>
            <div style={{ flex: 1, minWidth: 280 }}>
              <div style={{ fontSize: 40, marginBottom: 14 }}>{plan.emoji}</div>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, letterSpacing: "0.12em", color: plan.color, textTransform: "uppercase" as const, marginBottom: 8 }}>{plan.name}</div>
              <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(24px,4vw,40px)", color: "#fff", lineHeight: 1.15, marginBottom: 16, maxWidth: 500 }}>{plan.tagline}</h1>
              <p style={{ fontFamily: "Inter", fontSize: 14, color: "rgba(255,255,255,0.55)", lineHeight: 1.75, maxWidth: 480 }}>{plan.forWhoDetail}</p>
            </div>

            {/* Pricing card */}
            <div style={{ background: "rgba(255,255,255,0.06)", border: `1px solid rgba(255,255,255,0.1)`, borderRadius: 20, padding: "24px", minWidth: 240 }}>
              {/* Toggle */}
              <div style={{ display: "flex", background: "rgba(255,255,255,0.06)", borderRadius: 30, padding: 3, gap: 2, marginBottom: 20 }}>
                {(["monthly", "annual"] as const).map((t) => (
                  <button key={t} onClick={() => setAnnual(t === "annual")}
                    style={{ flex: 1, fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: (annual ? t === "annual" : t === "monthly") ? brand.charcoal : "rgba(255,255,255,0.5)", background: (annual ? t === "annual" : t === "monthly") ? "#fff" : "transparent", border: "none", borderRadius: 26, padding: "7px 12px", cursor: "pointer", textTransform: "capitalize" as const, transition: "all 0.2s" }}>
                    {t}
                  </button>
                ))}
              </div>

              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 38, color: plan.color, lineHeight: 1 }}>{formatPrice(plan, annual)}</div>
              <div style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.4)", marginTop: 6, marginBottom: 20 }}>
                per month{annual ? ` · billed annually` : " · billed monthly"}
                {annual && <><br /><span style={{ color: plan.color, fontWeight: 700 }}>Save {annualSaving(plan)} vs monthly</span></>}
              </div>

              <button onClick={() => nav(`/checkout/subscription?plan=${plan.id}&billing=${annual ? "annual" : "monthly"}`)}
                style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: plan.id === "elite" ? brand.charcoal : "#fff", background: plan.id === "elite" ? `linear-gradient(135deg, ${brand.gold}, ${brand.amber})` : plan.color, border: "none", borderRadius: 12, padding: "13px", cursor: "pointer", boxShadow: `0 4px 16px ${plan.color}40`, marginBottom: 12 }}>
                Get {plan.name}
              </button>
              <div style={{ fontFamily: "Inter", fontSize: 11, color: "rgba(255,255,255,0.35)", textAlign: "center" as const }}>Cancel anytime · No lock-in</div>
            </div>
          </div>
        </div>
      </div>

      <div style={{ maxWidth: 900, margin: "0 auto", padding: "36px 24px 60px", display: "flex", gap: 28, flexWrap: "wrap", alignItems: "flex-start" }}>
        <div style={{ flex: 1, minWidth: 280, display: "flex", flexDirection: "column" as const, gap: 24 }}>

          {/* Highlights */}
          <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px 26px" }}>
            <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal, marginBottom: 16 }}>What you get</div>
            <div style={{ display: "flex", flexDirection: "column" as const, gap: 10 }}>
              {plan.highlights.map((h) => (
                <div key={h} style={{ display: "flex", gap: 10, alignItems: "flex-start", padding: "10px 12px", background: brand.offWhite, borderRadius: 10 }}>
                  <Check size={15} color={plan.color} style={{ flexShrink: 0, marginTop: 1 }} />
                  <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, lineHeight: 1.55 }}>{h}</span>
                </div>
              ))}
            </div>
          </div>

          {/* All features */}
          <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px 26px" }}>
            <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal, marginBottom: 20 }}>Complete feature list</div>
            {Object.entries(groupedFeatures).map(([group, features]) => (
              <div key={group} style={{ marginBottom: 20 }}>
                <div style={{ fontFamily: "Inter", fontWeight: 800, fontSize: 10, color: plan.color, textTransform: "uppercase" as const, letterSpacing: "0.08em", marginBottom: 8 }}>{group}</div>
                {features.map(([feature, value], i) => (
                  <div key={feature} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "9px 0", borderBottom: i < features.length - 1 ? `1px solid ${brand.borderGray}` : "none", gap: 12 }}>
                    <span style={{ fontFamily: "Inter", fontSize: 13, color: value === false ? brand.warmGray : brand.charcoal }}>{feature}</span>
                    <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: value === false ? brand.borderGray : plan.color, flexShrink: 0 }}>
                      {value === true ? "✓" : value === false ? "—" : value as string}
                    </span>
                  </div>
                ))}
              </div>
            ))}
          </div>

          {/* Testimonial */}
          {plan.testimonial && (
            <div style={{ background: brand.charcoal, borderRadius: 20, padding: "24px 26px" }}>
              <div style={{ display: "flex", gap: 3, marginBottom: 14 }}>
                {[1,2,3,4,5].map((i) => <Star key={i} size={14} fill={brand.amber} color={brand.amber} />)}
              </div>
              <p style={{ fontFamily: "Inter", fontSize: 14, color: "rgba(255,255,255,0.8)", lineHeight: 1.75, fontStyle: "italic", marginBottom: 16 }}>"{plan.testimonial.quote}"</p>
              <div style={{ display: "flex", gap: 10, alignItems: "center" }}>
                <div style={{ width: 36, height: 36, borderRadius: "50%", background: plan.color, display: "flex", alignItems: "center", justifyContent: "center" }}>
                  <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: "#fff" }}>{plan.testimonial.name[0]}</span>
                </div>
                <div>
                  <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: "#fff" }}>{plan.testimonial.name}</div>
                  <div style={{ fontFamily: "Inter", fontSize: 11, color: "rgba(255,255,255,0.45)" }}>{plan.testimonial.role}</div>
                </div>
              </div>
            </div>
          )}

          {/* FAQ */}
          <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px 26px" }}>
            <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal, marginBottom: 16 }}>Questions about {plan.name}</div>
            {plan.faq.map((f, i) => (
              <div key={i} style={{ borderBottom: i < plan.faq.length - 1 ? `1px solid ${brand.borderGray}` : "none" }}>
                <button onClick={() => setOpenFaq(openFaq === i ? null : i)}
                  style={{ width: "100%", display: "flex", justifyContent: "space-between", alignItems: "center", gap: 12, padding: "16px 0", background: "none", border: "none", cursor: "pointer", textAlign: "left" as const }}>
                  <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.charcoal }}>{f.q}</span>
                  {openFaq === i ? <ChevronUp size={15} color={brand.warmGray} style={{ flexShrink: 0 }} /> : <ChevronDown size={15} color={brand.warmGray} style={{ flexShrink: 0 }} />}
                </button>
                {openFaq === i && <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, lineHeight: 1.75, paddingBottom: 16 }}>{f.a}</div>}
              </div>
            ))}
          </div>

          {/* Adjacent plans */}
          {(prevPlan || nextPlan) && (
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "22px 24px" }}>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.warmGray, marginBottom: 14 }}>Other plans</div>
              <div style={{ display: "flex", gap: 10, flexWrap: "wrap" }}>
                {prevPlan && (
                  <button onClick={() => nav(`/pricing/${prevPlan.id}`)} style={{ flex: 1, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 14px", cursor: "pointer", textAlign: "left" as const }}>
                    <div style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray, marginBottom: 3 }}>← Less features</div>
                    <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal }}>{prevPlan.emoji} {prevPlan.name}</div>
                    <div style={{ fontFamily: "Inter", fontSize: 11, color: prevPlan.color }}>{formatPrice(prevPlan, annual)}/mo</div>
                  </button>
                )}
                {nextPlan && (
                  <button onClick={() => nav(`/pricing/${nextPlan.id}`)} style={{ flex: 1, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 14px", cursor: "pointer", textAlign: "left" as const }}>
                    <div style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray, marginBottom: 3 }}>More features →</div>
                    <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal }}>{nextPlan.emoji} {nextPlan.name}</div>
                    <div style={{ fontFamily: "Inter", fontSize: 11, color: nextPlan.color }}>{formatPrice(nextPlan, annual)}/mo</div>
                  </button>
                )}
              </div>
            </div>
          )}
        </div>

        {/* Sticky sidebar */}
        <div style={{ width: 260, flexShrink: 0 }}>
          <div style={{ position: "sticky", top: 96, display: "flex", flexDirection: "column" as const, gap: 12 }}>
            <div style={{ background: brand.white, borderRadius: 18, border: `2px solid ${plan.color}40`, padding: "20px" }}>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: plan.color, marginBottom: 2 }}>{formatPrice(plan, annual)}</div>
              <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginBottom: 16 }}>per month{annual ? " · billed annually" : ""}</div>
              <button onClick={() => nav(`/checkout/subscription?plan=${plan.id}&billing=${annual ? "annual" : "monthly"}`)}
                style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: plan.id === "elite" ? brand.charcoal : "#fff", background: plan.id === "elite" ? `linear-gradient(135deg, ${brand.gold}, ${brand.amber})` : plan.color, border: "none", borderRadius: 10, padding: "12px", cursor: "pointer", marginBottom: 10 }}>
                Get {plan.name}
              </button>
              <button onClick={() => nav("/pricing/compare")} style={{ width: "100%", fontFamily: "Inter", fontWeight: 500, fontSize: 13, color: brand.warmGray, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 10, padding: "11px", cursor: "pointer" }}>
                Compare all plans
              </button>
            </div>
            <div style={{ background: brand.offWhite, borderRadius: 14, border: `1px solid ${brand.borderGray}`, padding: "14px 16px" }}>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.charcoal, marginBottom: 8 }}>Best for</div>
              <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, lineHeight: 1.65 }}>{plan.forWho}</div>
            </div>
            {[["🔄 Cancel anytime", "No questions asked"], ["🔐 Secure checkout", "SSL encrypted"], ["📋 Invoice included", "Egyptian tax invoice"]].map(([title, sub]) => (
              <div key={title as string} style={{ display: "flex", gap: 10, alignItems: "flex-start", padding: "10px 0", borderBottom: `1px solid ${brand.borderGray}` }}>
                <span style={{ fontSize: 16 }}>{(title as string).split(" ")[0]}</span>
                <div>
                  <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal }}>{(title as string).slice(3)}</div>
                  <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{sub as string}</div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
