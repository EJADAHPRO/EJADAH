import { useState } from "react";
import { useNavigate } from "react-router";
import { Check, Minus, ArrowLeft } from "lucide-react";
import { brand, gradientFlow } from "@/app/shared";
import { PLANS, FEATURE_GROUPS, formatPrice } from "@/app/pricingData";

export default function PlanCompare() {
  const nav = useNavigate();
  const [annual, setAnnual] = useState(true);

  const allFeatures = Object.entries(FEATURE_GROUPS).flatMap(([group, features]) =>
    [{ isGroup: true, label: group, feature: "" }, ...features.map((f) => ({ isGroup: false, label: f, feature: f }))]
  );

  function renderValue(val: boolean | string) {
    if (val === true) return <Check size={16} color="#2D9B68" />;
    if (val === false) return <Minus size={16} color={brand.borderGray} />;
    return <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: brand.orange }}>{val}</span>;
  }

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Header */}
      <div style={{ background: brand.charcoal, padding: "36px 24px 28px" }}>
        <div style={{ maxWidth: 1200, margin: "0 auto" }}>
          <button onClick={() => nav("/pricing")} style={{ background: "none", border: "none", cursor: "pointer", color: "rgba(255,255,255,0.4)", fontFamily: "Inter", fontSize: 13, display: "flex", alignItems: "center", gap: 5, marginBottom: 20 }}>
            <ArrowLeft size={14} /> All Plans
          </button>
          <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(24px,3.5vw,36px)", color: "#fff", marginBottom: 20 }}>Compare All Plans</h1>

          {/* Billing toggle */}
          <div style={{ display: "inline-flex", background: "rgba(255,255,255,0.08)", borderRadius: 30, padding: 4, gap: 2 }}>
            {(["Monthly", "Annual"] as const).map((t) => (
              <button key={t} onClick={() => setAnnual(t === "Annual")}
                style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: (annual ? t === "Annual" : t === "Monthly") ? brand.charcoal : "rgba(255,255,255,0.5)", background: (annual ? t === "Annual" : t === "Monthly") ? "#fff" : "transparent", border: "none", borderRadius: 26, padding: "8px 20px", cursor: "pointer", transition: "all 0.2s" }}>
                {t} {t === "Annual" && <span style={{ fontFamily: "Inter", fontSize: 10, color: brand.orange, marginLeft: 4 }}>Save up to 28%</span>}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Scrollable table */}
      <div style={{ maxWidth: 1200, margin: "0 auto", padding: "0 24px 60px", overflowX: "auto" as const }}>
        <table style={{ width: "100%", borderCollapse: "separate", borderSpacing: "0 0", minWidth: 900 }}>
          <thead>
            <tr>
              {/* Feature label column */}
              <th style={{ width: 220, padding: "24px 16px 16px 0", textAlign: "left" as const, verticalAlign: "bottom" as const, background: brand.offWhite, position: "sticky", left: 0, zIndex: 10 }}>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.warmGray, letterSpacing: "0.06em", textTransform: "uppercase" as const }}>Feature</div>
              </th>
              {PLANS.map((plan) => (
                <th key={plan.id} style={{ padding: "16px 12px", textAlign: "center" as const, verticalAlign: "bottom" as const, background: brand.offWhite, minWidth: 130 }}>
                  {plan.badge && (
                    <div style={{ fontFamily: "Inter", fontWeight: 800, fontSize: 10, color: "#fff", background: plan.color, borderRadius: 10, padding: "3px 10px", marginBottom: 6, display: "inline-block" }}>{plan.badge}</div>
                  )}
                  <div style={{ fontSize: 22, marginBottom: 6 }}>{plan.emoji}</div>
                  <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 14, color: brand.charcoal, marginBottom: 4 }}>{plan.name}</div>
                  <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: plan.color, marginBottom: 4 }}>{formatPrice(plan, annual)}</div>
                  <div style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray, marginBottom: 12 }}>/month</div>
                  <button onClick={() => nav(`/checkout/subscription?plan=${plan.id}&billing=${annual ? "annual" : "monthly"}`)}
                    style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: plan.id === "elite" ? brand.charcoal : "#fff", background: plan.id === "elite" ? `linear-gradient(135deg, ${brand.gold}, ${brand.amber})` : plan.badge ? gradientFlow : plan.color, border: "none", borderRadius: 8, padding: "9px 8px", cursor: "pointer" }}>
                    Get {plan.name}
                  </button>
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {allFeatures.map((row, idx) => {
              if (row.isGroup) {
                return (
                  <tr key={`group-${row.label}`}>
                    <td colSpan={PLANS.length + 1} style={{ padding: "20px 0 8px", background: brand.offWhite }}>
                      <div style={{ fontFamily: "Inter", fontWeight: 800, fontSize: 11, letterSpacing: "0.08em", color: brand.orange, textTransform: "uppercase" as const }}>{row.label}</div>
                    </td>
                  </tr>
                );
              }
              const isEven = idx % 2 === 0;
              return (
                <tr key={row.feature} style={{ background: isEven ? brand.white : "transparent" }}>
                  <td style={{ padding: "12px 16px 12px 0", fontFamily: "Inter", fontSize: 13, color: brand.charcoal, background: isEven ? brand.white : "transparent", position: "sticky", left: 0, borderBottom: `1px solid ${brand.borderGray}` }}>
                    {row.label}
                  </td>
                  {PLANS.map((plan) => (
                    <td key={plan.id} style={{ padding: "12px", textAlign: "center" as const, borderBottom: `1px solid ${brand.borderGray}`, background: isEven ? brand.white : "transparent" }}>
                      {renderValue(plan.features[row.feature] ?? false)}
                    </td>
                  ))}
                </tr>
              );
            })}
          </tbody>

          {/* Bottom CTA row */}
          <tfoot>
            <tr>
              <td style={{ padding: "24px 0 0", background: brand.offWhite, position: "sticky", left: 0 }} />
              {PLANS.map((plan) => (
                <td key={plan.id} style={{ padding: "24px 12px 0", textAlign: "center" as const }}>
                  <button onClick={() => nav(`/checkout/subscription?plan=${plan.id}&billing=${annual ? "annual" : "monthly"}`)}
                    style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: plan.id === "elite" ? brand.charcoal : "#fff", background: plan.id === "elite" ? `linear-gradient(135deg, ${brand.gold}, ${brand.amber})` : plan.badge ? gradientFlow : plan.color, border: "none", borderRadius: 10, padding: "12px 8px", cursor: "pointer" }}>
                    Get {plan.name}
                  </button>
                  <div style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray, marginTop: 6 }}>Cancel anytime</div>
                </td>
              ))}
            </tr>
          </tfoot>
        </table>
      </div>
    </div>
  );
}
