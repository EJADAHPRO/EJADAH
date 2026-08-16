import { useState } from "react";
import { useNavigate } from "react-router";
import { CheckCircle, ArrowRight, Star, Zap } from "lucide-react";
import { brand, gradientFlow, gradientGlow, GradientBadge } from "@/figma/app/shared";

const plans = [
  {
    name: "Free", price: { monthly: 0, annual: 0 }, currency: "EGP", color: brand.warmGray,
    features: [
      ["Free tests & daily questions", true],
      ["Sample courses (5)", true],
      ["Live clinical demonstrations", true],
      ["Basic community access", true],
      ["Limited AI assistant (10 queries/mo)", true],
      ["Full course library", false],
      ["Exam preparation suite", false],
      ["Certificate downloads", false],
      ["Research hub access", false],
      ["Tutor discounts", false],
    ],
    cta: "Get Started Free", highlight: false,
  },
  {
    name: "Professional", price: { monthly: 299, annual: 249 }, currency: "EGP", color: brand.orange,
    features: [
      ["Everything in Free", true],
      ["Full recorded course library", true],
      ["Handouts & flashcards", true],
      ["Certificate downloads", true],
      ["Research hub access", true],
      ["Full community access", true],
      ["Limited exam prep (3 banks)", true],
      ["Full exam preparation suite", false],
      ["Unlimited AI assistant", false],
      ["Live webinar access", false],
    ],
    cta: "Start Professional", highlight: false,
  },
  {
    name: "Premium", price: { monthly: 499, annual: 399 }, currency: "EGP", color: brand.red,
    features: [
      ["Everything in Professional", true],
      ["Full exam preparation suite", true],
      ["Ejadah Dental AI (unlimited)", true],
      ["Live webinar access", true],
      ["10% tutor discount", true],
      ["Exclusive research digest", true],
      ["Priority booking", true],
      ["Premium profile badge", true],
      ["Early access to new courses", true],
      ["Dedicated support", true],
    ],
    cta: "Go Premium", highlight: true,
  },
  {
    name: "Institutional", price: { monthly: null, annual: null }, currency: "EGP", color: brand.charcoal,
    features: [
      ["Multi-user accounts", true],
      ["Admin dashboard", true],
      ["Group enrollment", true],
      ["Analytics & reporting", true],
      ["Custom training programs", true],
      ["Branded certificates", true],
      ["Dedicated account manager", true],
      ["API access", true],
      ["Custom integrations", true],
      ["SLA & support agreement", true],
    ],
    cta: "Contact Sales", highlight: false,
  },
];

const featureTable = [
  { feature: "Courses", free: "5 sample", pro: "Full library", premium: "Full library", inst: "Custom" },
  { feature: "Live Sessions", free: "Clinical demos only", pro: "Webinars", premium: "All live + webinars", inst: "Custom" },
  { feature: "Exam Prep", free: "Free tests only", pro: "3 question banks", premium: "All 11 exams", inst: "Custom" },
  { feature: "Certificates", free: "✗", pro: "✓", premium: "✓", inst: "✓ + branded" },
  { feature: "AI Assistant", free: "10 queries/mo", pro: "50 queries/mo", premium: "Unlimited", inst: "Unlimited" },
  { feature: "Community", free: "Read only", pro: "Full access", premium: "Full + exclusive groups", inst: "Full" },
  { feature: "Research Hub", free: "✗", pro: "✓", premium: "✓ + digest alerts", inst: "✓" },
  { feature: "Tutor Discount", free: "✗", pro: "✗", premium: "10%", inst: "20%" },
  { feature: "Support", free: "Community", pro: "Email", premium: "Priority email", inst: "Dedicated manager" },
];

export default function Membership() {
  const nav = useNavigate();
  const [billing, setBilling] = useState<"monthly" | "annual">("annual");

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Hero */}
      <div style={{ background: brand.charcoal, padding: "56px 24px 48px", textAlign: "center" as const, position: "relative", overflow: "hidden" }}>
        <div style={{ position: "absolute", inset: 0, background: `radial-gradient(ellipse at 50% 40%, rgba(255,107,26,0.1) 0%, transparent 60%)`, pointerEvents: "none" }} />
        <div style={{ position: "relative" }}>
          <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, letterSpacing: "0.1em", color: brand.amber, textTransform: "uppercase" as const, marginBottom: 10 }}>Membership</div>
          <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(28px,4vw,44px)", color: "#fff", marginBottom: 12 }}>Choose Your Learning Plan</h1>
          <p style={{ fontFamily: "Inter", fontSize: 16, color: "rgba(255,255,255,0.6)", maxWidth: 480, margin: "0 auto 28px" }}>Join 40,000+ dental professionals. Start free, upgrade when you're ready.</p>
          {/* Billing toggle */}
          <div style={{ display: "inline-flex", background: "rgba(255,255,255,0.08)", border: "1px solid rgba(255,255,255,0.12)", borderRadius: 12, padding: 4, gap: 4 }}>
            {(["monthly", "annual"] as const).map((b) => (
              <button key={b} onClick={() => setBilling(b)} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: billing === b ? brand.charcoal : "rgba(255,255,255,0.6)", background: billing === b ? "#fff" : "transparent", border: "none", borderRadius: 9, padding: "8px 20px", cursor: "pointer", transition: "all 0.2s" }}>
                {b === "monthly" ? "Monthly" : "Annual"}
                {b === "annual" && <span style={{ fontFamily: "Inter", fontSize: 10, fontWeight: 700, color: "#2D9B68", background: "rgba(45,155,104,0.15)", borderRadius: 4, padding: "1px 5px", marginLeft: 6 }}>Save 20%</span>}
              </button>
            ))}
          </div>
        </div>
      </div>

      <div style={{ maxWidth: 1200, margin: "0 auto", padding: "40px 24px" }}>
        {/* Plan cards */}
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(240px, 1fr))", gap: 20, marginBottom: 48 }}>
          {plans.map((plan) => (
            <div key={plan.name} style={{ background: plan.highlight ? brand.charcoal : brand.white, borderRadius: 24, border: plan.highlight ? "none" : `1px solid ${brand.borderGray}`, padding: "28px 24px", position: "relative", overflow: "hidden", boxShadow: plan.highlight ? "0 16px 48px rgba(27,27,27,0.2)" : "0 2px 10px rgba(27,27,27,0.04)" }}>
              {plan.highlight && (
                <div style={{ position: "absolute", inset: 0, borderRadius: 24, padding: 2, background: gradientFlow, WebkitMask: "linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0)", WebkitMaskComposite: "xor", maskComposite: "exclude", pointerEvents: "none" }} />
              )}
              {plan.highlight && <div style={{ position: "absolute", top: 14, right: 14 }}><GradientBadge small>Most Popular</GradientBadge></div>}
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: plan.highlight ? "rgba(255,255,255,0.6)" : brand.warmGray, letterSpacing: "0.06em", textTransform: "uppercase" as const, marginBottom: 8 }}>{plan.name}</div>
              <div style={{ display: "flex", alignItems: "baseline", gap: 4, marginBottom: 16 }}>
                {plan.price.monthly === null ? (
                  <span style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 28, color: plan.highlight ? "#fff" : brand.charcoal }}>Custom</span>
                ) : plan.price.monthly === 0 ? (
                  <span style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 28, color: plan.highlight ? "#fff" : brand.charcoal }}>Free</span>
                ) : (
                  <>
                    <span style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 32, color: plan.highlight ? "#fff" : brand.charcoal }}>EGP {billing === "annual" ? plan.price.annual : plan.price.monthly}</span>
                    <span style={{ fontFamily: "Inter", fontSize: 13, color: plan.highlight ? "rgba(255,255,255,0.5)" : brand.warmGray }}>/mo</span>
                  </>
                )}
              </div>
              {billing === "annual" && plan.price.annual && plan.price.monthly ? (
                <div style={{ fontFamily: "Inter", fontSize: 11, color: "#2D9B68", marginBottom: 16 }}>Billed EGP {plan.price.annual * 12}/year · Save EGP {(plan.price.monthly - plan.price.annual) * 12}</div>
              ) : <div style={{ height: 16, marginBottom: 16 }} />}
              <div style={{ height: 1, background: plan.highlight ? "rgba(255,255,255,0.1)" : brand.borderGray, marginBottom: 18 }} />
              <div style={{ marginBottom: 22 }}>
                {plan.features.map(([label, included]) => (
                  <div key={label as string} style={{ display: "flex", gap: 8, alignItems: "flex-start", marginBottom: 9 }}>
                    <CheckCircle size={13} color={included ? (plan.highlight ? brand.amber : brand.orange) : brand.borderGray} style={{ flexShrink: 0, marginTop: 2 }} />
                    <span style={{ fontFamily: "Inter", fontSize: 13, color: included ? (plan.highlight ? "rgba(255,255,255,0.85)" : brand.charcoal) : brand.warmGray, opacity: included ? 1 : 0.5 }}>{label as string}</span>
                  </div>
                ))}
              </div>
              <button onClick={() => nav(plan.name === "Institutional" ? "/consulting" : "/checkout")} style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: plan.highlight ? "#fff" : brand.charcoal, background: plan.highlight ? gradientFlow : "transparent", border: plan.highlight ? "none" : `2px solid ${brand.borderGray}`, borderRadius: 12, padding: "13px", cursor: "pointer", boxShadow: plan.highlight ? "0 4px 16px rgba(255,107,26,0.35)" : "none" }}>
                {plan.cta}
              </button>
            </div>
          ))}
        </div>

        {/* Feature comparison table */}
        <div style={{ background: brand.white, borderRadius: 22, border: `1px solid ${brand.borderGray}`, overflow: "hidden", marginBottom: 40 }}>
          <div style={{ padding: "24px 28px", borderBottom: `1px solid ${brand.borderGray}` }}>
            <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.charcoal }}>Feature Comparison</h2>
          </div>
          <div style={{ overflowX: "auto" }}>
            <table style={{ width: "100%", borderCollapse: "collapse" as const }}>
              <thead>
                <tr style={{ background: brand.offWhite }}>
                  <th style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal, padding: "14px 20px", textAlign: "left" as const, borderBottom: `1px solid ${brand.borderGray}` }}>Feature</th>
                  {["Free", "Professional", "Premium", "Institutional"].map((h) => (
                    <th key={h} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: h === "Premium" ? brand.red : brand.charcoal, padding: "14px 16px", textAlign: "center" as const, borderBottom: `1px solid ${brand.borderGray}` }}>{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {featureTable.map((row, i) => (
                  <tr key={row.feature} style={{ background: i % 2 === 0 ? brand.white : brand.offWhite }}>
                    <td style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, padding: "12px 20px", borderBottom: `1px solid ${brand.borderGray}` }}>{row.feature}</td>
                    {[row.free, row.pro, row.premium, row.inst].map((val, j) => (
                      <td key={j} style={{ fontFamily: "Inter", fontSize: 12, color: val === "✗" ? brand.borderGray : brand.charcoal, padding: "12px 16px", textAlign: "center" as const, borderBottom: `1px solid ${brand.borderGray}`, fontWeight: j === 2 ? 600 : 400 }}>{val}</td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* FAQ */}
        <div style={{ textAlign: "center" as const }}>
          <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 24, color: brand.charcoal, marginBottom: 8 }}>Questions?</h2>
          <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, marginBottom: 20 }}>All plans include a 7-day money-back guarantee. Cancel anytime.</p>
          <button onClick={() => nav("/community")} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.orange, background: "rgba(255,107,26,0.07)", border: "none", borderRadius: 10, padding: "11px 22px", cursor: "pointer" }}>Contact Support</button>
        </div>
      </div>
    </div>
  );
}
