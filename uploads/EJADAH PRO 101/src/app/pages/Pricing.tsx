import { useState } from "react";
import { useNavigate } from "react-router";
import { Check, X, ChevronDown, ChevronUp, ArrowRight, Zap, Star } from "lucide-react";
import { brand, gradientFlow } from "@/app/shared";
import { PLANS, FEATURE_GROUPS, formatPrice, annualSaving, type Plan } from "@/app/pricingData";

function PlanCard({ plan, annual, featured }: { plan: Plan; annual: boolean; featured?: boolean }) {
  const nav = useNavigate();
  const isGold = plan.id === "elite";
  const borderColor = featured ? plan.color : brand.borderGray;

  return (
    <div style={{ background: isGold ? brand.charcoal : brand.white, borderRadius: 22, border: `2px solid ${borderColor}`, padding: "26px 24px 24px", display: "flex", flexDirection: "column" as const, gap: 0, position: "relative", boxShadow: featured ? `0 8px 32px ${plan.color}25` : "none", transition: "transform 0.15s, box-shadow 0.15s" }}
      onMouseEnter={(e) => { (e.currentTarget as HTMLElement).style.transform = "translateY(-4px)"; (e.currentTarget as HTMLElement).style.boxShadow = `0 16px 40px ${plan.color}20`; }}
      onMouseLeave={(e) => { (e.currentTarget as HTMLElement).style.transform = "none"; (e.currentTarget as HTMLElement).style.boxShadow = featured ? `0 8px 32px ${plan.color}25` : "none"; }}>

      {plan.badge && (
        <div style={{ position: "absolute", top: -13, left: "50%", transform: "translateX(-50%)", background: plan.color, color: isGold ? brand.charcoal : "#fff", fontFamily: "Inter", fontWeight: 800, fontSize: 11, letterSpacing: "0.06em", borderRadius: 20, padding: "4px 14px", whiteSpace: "nowrap" as const }}>
          {plan.badge}
        </div>
      )}

      <div style={{ fontSize: 28, marginBottom: 10 }}>{plan.emoji}</div>
      <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: isGold ? "#fff" : brand.charcoal, marginBottom: 4 }}>{plan.name}</div>
      <div style={{ fontFamily: "Inter", fontSize: 12, color: isGold ? "rgba(255,255,255,0.5)" : brand.warmGray, marginBottom: 20, lineHeight: 1.5 }}>{plan.tagline}</div>

      <div style={{ marginBottom: 20 }}>
        <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 32, color: plan.color, lineHeight: 1 }}>{formatPrice(plan, annual)}</div>
        <div style={{ fontFamily: "Inter", fontSize: 11, color: isGold ? "rgba(255,255,255,0.4)" : brand.warmGray, marginTop: 4 }}>
          per month{annual ? ` · billed annually` : " · billed monthly"}
          {annual && <span style={{ color: plan.color, fontWeight: 700, marginLeft: 6 }}>Save {annualSaving(plan)}</span>}
        </div>
      </div>

      <button onClick={() => nav(`/checkout/subscription?plan=${plan.id}&billing=${annual ? "annual" : "monthly"}`)}
        style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: isGold ? brand.charcoal : "#fff", background: plan.id === "elite" ? `linear-gradient(135deg, ${brand.gold}, ${brand.amber})` : featured ? gradientFlow : plan.color, border: "none", borderRadius: 12, padding: "13px", cursor: "pointer", marginBottom: 20, boxShadow: featured ? `0 4px 16px ${plan.color}40` : "none" }}>
        Get {plan.name}
      </button>

      <div style={{ display: "flex", flexDirection: "column" as const, gap: 8 }}>
        {plan.highlights.map((h) => (
          <div key={h} style={{ display: "flex", gap: 8, alignItems: "flex-start" }}>
            <Check size={14} color={plan.color} style={{ flexShrink: 0, marginTop: 1 }} />
            <span style={{ fontFamily: "Inter", fontSize: 12, color: isGold ? "rgba(255,255,255,0.75)" : brand.charcoal, lineHeight: 1.5 }}>{h}</span>
          </div>
        ))}
      </div>

      <button onClick={() => nav(`/pricing/${plan.id}`)} style={{ marginTop: 18, fontFamily: "Inter", fontSize: 12, color: plan.color, background: "none", border: "none", cursor: "pointer", display: "flex", alignItems: "center", gap: 4, padding: 0 }}>
        See full details <ArrowRight size={12} />
      </button>
    </div>
  );
}

function FAQItem({ q, a }: { q: string; a: string }) {
  const [open, setOpen] = useState(false);
  return (
    <div style={{ borderBottom: `1px solid ${brand.borderGray}` }}>
      <button onClick={() => setOpen(!open)} style={{ width: "100%", display: "flex", justifyContent: "space-between", alignItems: "center", gap: 12, padding: "18px 0", background: "none", border: "none", cursor: "pointer", textAlign: "left" as const }}>
        <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 15, color: brand.charcoal }}>{q}</span>
        {open ? <ChevronUp size={16} color={brand.warmGray} style={{ flexShrink: 0 }} /> : <ChevronDown size={16} color={brand.warmGray} style={{ flexShrink: 0 }} />}
      </button>
      {open && <div style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, lineHeight: 1.75, paddingBottom: 18 }}>{a}</div>}
    </div>
  );
}

export default function Pricing() {
  const nav = useNavigate();
  const [annual, setAnnual] = useState(true);

  const faqs = [
    { q: "Can I switch plans anytime?", a: "Yes — upgrade or downgrade anytime. When you upgrade, we prorate the cost so you only pay for the remaining days in your billing cycle. Downgrading takes effect at the start of your next billing period." },
    { q: "What payment methods are accepted?", a: "We accept all major credit/debit cards, Fawry, Vodafone Cash, and InstaPay. Annual plans can also be paid by bank transfer — contact us for details." },
    { q: "Is there a student discount?", a: "Student Pass is already priced specifically for dental students. If you are at a university with an institutional partnership, your university may provide subsidised access — ask your department." },
    { q: "What happens when I cancel?", a: "Your plan stays active until the end of your current billing period. After that, you revert to free access (free practice tests and basic Dental AI only). No charges after cancellation." },
    { q: "Do EGP plans include VAT?", a: "Prices shown are inclusive of all applicable Egyptian taxes. USD-priced plans do not include local taxes — depending on your country of residence, applicable taxes may be added at checkout." },
    { q: "Can my hospital or university buy seats in bulk?", a: "Yes — institutional pricing is available for 5+ seats across any plan. Contact consulting@ejadah.com with your institution name and number of seats needed." },
    { q: "Are the free sessions in Career Pro and Elite actual consultations?", a: "Yes — they are real 30–60 minute sessions with a qualified Ejadah consultant or specialist tutor. You book them through My Bookings exactly like a paid session, at no charge." },
  ];

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>

      {/* ── Hero ── */}
      <div style={{ background: `linear-gradient(135deg, ${brand.deepCharcoal} 0%, #1E1B17 100%)`, padding: "64px 24px 56px", textAlign: "center" as const, position: "relative", overflow: "hidden" }}>
        <div style={{ position: "absolute", inset: 0, background: "radial-gradient(ellipse at 60% 0%, rgba(255,198,46,0.07) 0%, transparent 60%)", pointerEvents: "none" }} />
        <div style={{ position: "relative" }}>
          <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, letterSpacing: "0.12em", color: brand.orange, textTransform: "uppercase" as const, marginBottom: 16 }}>PRICING</div>
          <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(32px,5vw,52px)", color: "#fff", lineHeight: 1.15, marginBottom: 16, maxWidth: 600, margin: "0 auto 16px" }}>
            One platform. Every tool<br />your career needs.
          </h1>
          <p style={{ fontFamily: "Inter", fontSize: 16, color: "rgba(255,255,255,0.55)", maxWidth: 520, margin: "0 auto 36px", lineHeight: 1.7 }}>
            From dental school to specialist practice abroad — choose the plan that matches where you are and where you're going.
          </p>

          {/* Billing toggle */}
          <div style={{ display: "inline-flex", alignItems: "center", gap: 12, background: "rgba(255,255,255,0.06)", border: "1px solid rgba(255,255,255,0.1)", borderRadius: 40, padding: "6px 8px" }}>
            <button onClick={() => setAnnual(false)} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: !annual ? brand.charcoal : "rgba(255,255,255,0.5)", background: !annual ? "#fff" : "transparent", border: "none", borderRadius: 30, padding: "8px 20px", cursor: "pointer", transition: "all 0.2s" }}>Monthly</button>
            <button onClick={() => setAnnual(true)} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: annual ? brand.charcoal : "rgba(255,255,255,0.5)", background: annual ? "#fff" : "transparent", border: "none", borderRadius: 30, padding: "8px 20px", cursor: "pointer", transition: "all 0.2s", display: "flex", alignItems: "center", gap: 8 }}>
              Annual <span style={{ fontFamily: "Inter", fontWeight: 800, fontSize: 10, color: brand.orange, background: `${brand.orange}20`, borderRadius: 10, padding: "2px 8px" }}>SAVE UP TO 28%</span>
            </button>
          </div>
        </div>
      </div>

      {/* ── Plan cards ── */}
      <div style={{ maxWidth: 1280, margin: "-24px auto 0", padding: "0 24px 60px" }}>
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(280px, 1fr))", gap: 16 }}>
          {PLANS.map((plan) => (
            <PlanCard key={plan.id} plan={plan} annual={annual} featured={plan.badge !== undefined} />
          ))}
        </div>

        {/* Compare CTA */}
        <div style={{ textAlign: "center" as const, marginTop: 28 }}>
          <button onClick={() => nav("/pricing/compare")} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.charcoal, background: brand.white, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 28px", cursor: "pointer", display: "inline-flex", alignItems: "center", gap: 8 }}>
            Compare all plans in detail <ArrowRight size={15} />
          </button>
        </div>
      </div>

      {/* ── Feature comparison summary ── */}
      <div style={{ background: brand.white, borderTop: `1px solid ${brand.borderGray}`, borderBottom: `1px solid ${brand.borderGray}`, padding: "60px 24px" }}>
        <div style={{ maxWidth: 1000, margin: "0 auto" }}>
          <div style={{ textAlign: "center" as const, marginBottom: 40 }}>
            <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, letterSpacing: "0.1em", color: brand.orange, textTransform: "uppercase" as const, marginBottom: 10 }}>WHAT'S INCLUDED</div>
            <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(24px,3vw,34px)", color: brand.charcoal }}>Everything you get, by category</h2>
          </div>

          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(280px, 1fr))", gap: 20 }}>
            {Object.entries(FEATURE_GROUPS).map(([group, features]) => (
              <div key={group} style={{ background: brand.offWhite, borderRadius: 18, padding: "20px 22px" }}>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal, marginBottom: 14 }}>{group}</div>
                <div style={{ display: "flex", flexDirection: "column" as const, gap: 8 }}>
                  {features.map((f) => (
                    <div key={f} style={{ display: "flex", gap: 8, alignItems: "center" }}>
                      <Check size={13} color={brand.orange} style={{ flexShrink: 0 }} />
                      <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>{f}</span>
                    </div>
                  ))}
                </div>
              </div>
            ))}
          </div>

          <div style={{ textAlign: "center" as const, marginTop: 28 }}>
            <button onClick={() => nav("/pricing/compare")} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.orange, background: "none", border: "none", cursor: "pointer", display: "inline-flex", alignItems: "center", gap: 6 }}>
              See which plan includes which features <ArrowRight size={14} />
            </button>
          </div>
        </div>
      </div>

      {/* ── Social proof ── */}
      <div style={{ padding: "60px 24px", maxWidth: 1000, margin: "0 auto" }}>
        <div style={{ textAlign: "center" as const, marginBottom: 36 }}>
          <div style={{ display: "flex", justifyContent: "center", gap: 4, marginBottom: 8 }}>
            {[1,2,3,4,5].map((i) => <Star key={i} size={18} fill={brand.amber} color={brand.amber} />)}
          </div>
          <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(22px,3vw,30px)", color: brand.charcoal, marginBottom: 6 }}>40,000+ dental professionals trust Ejadah</div>
          <div style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray }}>4.8★ average across all plan types</div>
        </div>

        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(260px, 1fr))", gap: 16 }}>
          {PLANS.filter((p) => p.testimonial).slice(0, 3).map((plan) => (
            <div key={plan.id} style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "20px 22px" }}>
              <div style={{ display: "flex", gap: 4, marginBottom: 12 }}>
                {[1,2,3,4,5].map((i) => <Star key={i} size={12} fill={brand.amber} color={brand.amber} />)}
              </div>
              <p style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, lineHeight: 1.7, marginBottom: 14, fontStyle: "italic" }}>"{plan.testimonial!.quote}"</p>
              <div style={{ display: "flex", gap: 10, alignItems: "center" }}>
                <div style={{ width: 32, height: 32, borderRadius: "50%", background: plan.color, display: "flex", alignItems: "center", justifyContent: "center" }}>
                  <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: "#fff" }}>{plan.testimonial!.name[0]}</span>
                </div>
                <div>
                  <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal }}>{plan.testimonial!.name}</div>
                  <div style={{ fontFamily: "Inter", fontSize: 11, color: plan.color }}>{plan.name} · {plan.testimonial!.role}</div>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* ── Trust strip ── */}
      <div style={{ background: brand.paleGray, borderTop: `1px solid ${brand.borderGray}`, borderBottom: `1px solid ${brand.borderGray}`, padding: "24px" }}>
        <div style={{ maxWidth: 900, margin: "0 auto", display: "flex", gap: 28, justifyContent: "center", flexWrap: "wrap" }}>
          {[
            ["🔐", "Secure payment via SSL"],
            ["🔄", "Cancel anytime, no lock-in"],
            ["💳", "Card, Fawry, Vodafone Cash, InstaPay"],
            ["📋", "Egyptian tax invoice on request"],
            ["🤝", "Institutional pricing for 5+ seats"],
          ].map(([icon, label]) => (
            <div key={label as string} style={{ display: "flex", gap: 8, alignItems: "center", fontFamily: "Inter", fontSize: 13, color: brand.warmGray }}>
              <span style={{ fontSize: 16 }}>{icon as string}</span> {label as string}
            </div>
          ))}
        </div>
      </div>

      {/* ── FAQ ── */}
      <div style={{ maxWidth: 760, margin: "0 auto", padding: "60px 24px" }}>
        <div style={{ textAlign: "center" as const, marginBottom: 36 }}>
          <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(22px,3vw,30px)", color: brand.charcoal }}>Frequently asked questions</h2>
        </div>
        {faqs.map((f) => <FAQItem key={f.q} q={f.q} a={f.a} />)}
      </div>

      {/* ── Bottom CTA ── */}
      <div style={{ background: brand.charcoal, padding: "56px 24px", textAlign: "center" as const }}>
        <div style={{ maxWidth: 560, margin: "0 auto" }}>
          <div style={{ fontSize: 36, marginBottom: 16 }}>⚡</div>
          <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(24px,3vw,34px)", color: "#fff", marginBottom: 12 }}>Not sure which plan?</h2>
          <p style={{ fontFamily: "Inter", fontSize: 15, color: "rgba(255,255,255,0.55)", marginBottom: 28, lineHeight: 1.7 }}>Compare every feature side by side — or book a free 10-minute call and we'll recommend the right plan for your situation.</p>
          <div style={{ display: "flex", gap: 12, justifyContent: "center", flexWrap: "wrap" }}>
            <button onClick={() => nav("/pricing/compare")} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "13px 26px", cursor: "pointer", boxShadow: "0 4px 20px rgba(255,107,26,0.4)" }}>
              Compare All Plans
            </button>
            <button onClick={() => nav("/consulting")} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: "rgba(255,255,255,0.7)", background: "rgba(255,255,255,0.08)", border: "1px solid rgba(255,255,255,0.15)", borderRadius: 12, padding: "13px 26px", cursor: "pointer" }}>
              Talk to Us First
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
