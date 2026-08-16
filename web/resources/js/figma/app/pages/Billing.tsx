import { useState } from "react";
import { useNavigate } from "react-router";
import { CreditCard, Download, AlertTriangle, CheckCircle, ChevronRight, Zap } from "lucide-react";
import { brand, gradientFlow } from "@/figma/app/shared";
import { getPlan, PLANS, formatPrice } from "@/figma/app/pricingData";

const MOCK_PLAN_ID = "exam-pro";
// Annotated rather than inferred: the page renders both cycles, and a bare
// literal narrows the type so far that TypeScript calls the annual branch dead.
const MOCK_BILLING: "monthly" | "annual" = "monthly";

const MOCK_INVOICES = [
  { id: "INV-2025-007", date: "1 Jul 2025", amount: "EGP 499", status: "paid", plan: "Exam Pro · Monthly" },
  { id: "INV-2025-006", date: "1 Jun 2025", amount: "EGP 499", status: "paid", plan: "Exam Pro · Monthly" },
  { id: "INV-2025-005", date: "1 May 2025", amount: "EGP 499", status: "paid", plan: "Exam Pro · Monthly" },
  { id: "INV-2025-004", date: "1 Apr 2025", amount: "EGP 499", status: "paid", plan: "Exam Pro · Monthly" },
  { id: "INV-2025-003", date: "1 Mar 2025", amount: "EGP 450", status: "paid", plan: "Student Pass · Monthly" },
  { id: "INV-2025-002", date: "1 Feb 2025", amount: "EGP 450", status: "failed", plan: "Student Pass · Monthly" },
];

export default function Billing() {
  const nav = useNavigate();
  const plan = getPlan(MOCK_PLAN_ID) ?? PLANS[1];
  const [showCard, setShowCard] = useState(false);

  const nextBilling = "1 August 2025";
  const cardLast4 = "4242";

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Header */}
      <div style={{ background: brand.charcoal, padding: "32px 24px 28px" }}>
        <div style={{ maxWidth: 900, margin: "0 auto" }}>
          <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: "rgba(255,255,255,0.4)", marginBottom: 6, letterSpacing: "0.04em" }}>Account</div>
          <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(22px,3vw,28px)", color: "#fff", marginBottom: 0 }}>Billing & Subscription</h1>
        </div>
      </div>

      <div style={{ maxWidth: 900, margin: "0 auto", padding: "28px 24px 60px", display: "flex", gap: 24, flexWrap: "wrap", alignItems: "flex-start" }}>

        {/* Left column */}
        <div style={{ flex: 1, minWidth: 280, display: "flex", flexDirection: "column" as const, gap: 20 }}>

          {/* Current plan */}
          <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "22px", position: "relative", overflow: "hidden" }}>
            <div style={{ position: "absolute", top: 0, left: 0, right: 0, height: 3, background: `linear-gradient(90deg, ${plan.color}, ${brand.orange})` }} />
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", flexWrap: "wrap", gap: 12 }}>
              <div>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em", marginBottom: 8 }}>Current Plan</div>
                <div style={{ display: "flex", gap: 10, alignItems: "center" }}>
                  <span style={{ fontSize: 28 }}>{plan.emoji}</span>
                  <div>
                    <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal }}>{plan.name}</div>
                    <div style={{ fontFamily: "Inter", fontSize: 12, color: plan.color }}>Active · {MOCK_BILLING === "annual" ? "Annual" : "Monthly"} billing</div>
                  </div>
                </div>
              </div>
              <div style={{ textAlign: "right" as const }}>
                <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 800, fontSize: 24, color: plan.color }}>{formatPrice(plan, MOCK_BILLING === "annual")}</div>
                <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>per month</div>
              </div>
            </div>

            <div style={{ marginTop: 16, display: "flex", gap: 10, flexWrap: "wrap" as const }}>
              <button onClick={() => nav("/pricing")} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "10px 18px", cursor: "pointer" }}>
                <Zap size={13} style={{ marginRight: 5, verticalAlign: "middle" }} />Upgrade Plan
              </button>
              <button onClick={() => nav("/pricing/compare")} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 10, padding: "10px 18px", cursor: "pointer" }}>
                Compare Plans
              </button>
              <button onClick={() => nav("/billing/cancel")} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.warmGray, background: "none", border: "none", cursor: "pointer", padding: "10px 14px" }}>
                Cancel subscription
              </button>
            </div>
          </div>

          {/* Next billing */}
          <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "20px" }}>
            <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em", marginBottom: 14 }}>Billing Details</div>
            {[
              ["Next billing date", nextBilling],
              ["Amount", formatPrice(plan, MOCK_BILLING === "annual") + (MOCK_BILLING === "annual" ? "/year" : "/month")],
              ["Auto-renewal", "Enabled"],
            ].map(([label, value]) => (
              <div key={label as string} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "10px 0", borderBottom: `1px solid ${brand.borderGray}` }}>
                <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray }}>{label as string}</span>
                <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal }}>{value as string}</span>
              </div>
            ))}
          </div>

          {/* Payment method */}
          <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "20px" }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 14 }}>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em" }}>Payment Method</div>
              <button onClick={() => setShowCard(!showCard)} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.orange, background: "none", border: "none", cursor: "pointer" }}>
                {showCard ? "Cancel" : "Update card"}
              </button>
            </div>

            <div style={{ display: "flex", gap: 12, alignItems: "center", padding: "12px", background: brand.offWhite, borderRadius: 12 }}>
              <CreditCard size={20} color={brand.charcoal} />
              <div>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal }}>Visa ending in {cardLast4}</div>
                <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>Expires 08/2027</div>
              </div>
            </div>

            {showCard && (
              <div style={{ marginTop: 14, display: "flex", flexDirection: "column" as const, gap: 12 }}>
                {[{ label: "Name on Card", placeholder: "Full name" }, { label: "Card Number", placeholder: "1234 5678 9012 3456" }].map((f) => (
                  <div key={f.label}>
                    <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.warmGray, marginBottom: 5 }}>{f.label}</div>
                    <input placeholder={f.placeholder} style={{ width: "100%", fontFamily: "Inter", fontSize: 13, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 10, padding: "10px 12px", outline: "none", boxSizing: "border-box" as const }}
                      onFocus={(e) => (e.target.style.borderColor = brand.orange)} onBlur={(e) => (e.target.style.borderColor = brand.borderGray)} />
                  </div>
                ))}
                <div style={{ display: "flex", gap: 10 }}>
                  {[{ label: "Expiry", placeholder: "MM/YY" }, { label: "CVV", placeholder: "•••" }].map((f) => (
                    <div key={f.label} style={{ flex: 1 }}>
                      <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.warmGray, marginBottom: 5 }}>{f.label}</div>
                      <input placeholder={f.placeholder} style={{ width: "100%", fontFamily: "Inter", fontSize: 13, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 10, padding: "10px 12px", outline: "none", boxSizing: "border-box" as const }}
                        onFocus={(e) => (e.target.style.borderColor = brand.orange)} onBlur={(e) => (e.target.style.borderColor = brand.borderGray)} />
                    </div>
                  ))}
                </div>
                <button onClick={() => setShowCard(false)} style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "11px", cursor: "pointer" }}>
                  Save Card
                </button>
              </div>
            )}
          </div>

          {/* Invoice history */}
          <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "20px" }}>
            <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em", marginBottom: 14 }}>Invoice History</div>
            {MOCK_INVOICES.map((inv) => (
              <div key={inv.id} style={{ display: "flex", alignItems: "center", padding: "11px 0", borderBottom: `1px solid ${brand.borderGray}`, gap: 12 }}>
                <div style={{ flex: 1 }}>
                  <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal }}>{inv.id}</div>
                  <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{inv.date} · {inv.plan}</div>
                </div>
                <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
                  <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal }}>{inv.amount}</span>
                  <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 10, padding: "3px 8px", borderRadius: 20, background: inv.status === "paid" ? "#2D9B6814" : "#FF2D3214", color: inv.status === "paid" ? "#2D9B68" : "#FF2D32" }}>
                    {inv.status === "paid" ? "✓ Paid" : "✗ Failed"}
                  </span>
                  <button style={{ background: "none", border: "none", cursor: "pointer", color: brand.warmGray }}>
                    <Download size={14} />
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Sidebar */}
        <div style={{ width: 240, flexShrink: 0 }}>
          <div style={{ position: "sticky", top: 90, display: "flex", flexDirection: "column" as const, gap: 14 }}>

            <div style={{ background: brand.white, borderRadius: 16, border: `1px solid ${brand.borderGray}`, padding: "18px" }}>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em", marginBottom: 12 }}>Plan benefits</div>
              {plan.highlights.map((h) => (
                <div key={h} style={{ display: "flex", gap: 7, alignItems: "flex-start", marginBottom: 9 }}>
                  <CheckCircle size={12} color={plan.color} style={{ flexShrink: 0, marginTop: 1 }} />
                  <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, lineHeight: 1.4 }}>{h}</span>
                </div>
              ))}
            </div>

            <div style={{ background: `${brand.orange}0C`, border: `1px solid ${brand.orange}25`, borderRadius: 14, padding: "16px" }}>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.orange, marginBottom: 6, display: "flex", gap: 5, alignItems: "center" }}><Zap size={13} /> Save with Annual</div>
              <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, lineHeight: 1.6, marginBottom: 12 }}>Switch to annual billing and save up to 28% compared to monthly.</div>
              <button onClick={() => nav(`/checkout/subscription?plan=${plan.id}&billing=annual`)}
                style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: "#fff", background: gradientFlow, border: "none", borderRadius: 9, padding: "9px", cursor: "pointer" }}>
                Switch to Annual
              </button>
            </div>

            <button onClick={() => nav("/billing/cancel")} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.warmGray, background: brand.white, border: `1px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 5 }}>
              <AlertTriangle size={14} color={brand.warmGray} /> Cancel subscription <ChevronRight size={13} />
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
