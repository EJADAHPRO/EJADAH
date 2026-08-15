import { useState } from "react";
import { useNavigate, useSearchParams } from "react-router";
import { Lock, CreditCard, CheckCircle, ChevronRight, ArrowLeft, Shield } from "lucide-react";
import { brand, gradientFlow } from "@/app/shared";
import { getPlan, formatPrice, PLANS } from "@/app/pricingData";

type Step = 1 | 2 | 3;

const PAYMENT_METHODS = [
  { id: "card", label: "Credit / Debit Card", icon: "💳" },
  { id: "fawry", label: "Fawry", icon: "🟠" },
  { id: "vodafone", label: "Vodafone Cash", icon: "🔴" },
  { id: "instapay", label: "InstaPay", icon: "🏦" },
];

export default function CheckoutSubscription() {
  const nav = useNavigate();
  const [params] = useSearchParams();
  const planId = params.get("plan") ?? "exam-pro";
  const billing = params.get("billing") ?? "monthly";
  const annual = billing === "annual";

  const plan = getPlan(planId) ?? PLANS[1];

  const [step, setStep] = useState<Step>(1);
  const [payMethod, setPayMethod] = useState("card");
  const [card, setCard] = useState({ name: "", number: "", expiry: "", cvv: "" });
  const [agreed, setAgreed] = useState(false);
  const [processing, setProcessing] = useState(false);

  const price = formatPrice(plan, annual);
  const annualTotal = plan.currency === "EGP"
    ? `EGP ${(plan.annualEGP ?? 0).toLocaleString()}`
    : `$${plan.annualUSD ?? 0}`;

  function handlePay() {
    setProcessing(true);
    setTimeout(() => nav(`/checkout/success?plan=${plan.id}&billing=${billing}`), 1800);
  }

  const steps = ["Plan", "Payment", "Review"];

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Header */}
      <div style={{ background: brand.charcoal, padding: "20px 24px" }}>
        <div style={{ maxWidth: 860, margin: "0 auto", display: "flex", alignItems: "center", justifyContent: "space-between", flexWrap: "wrap", gap: 12 }}>
          <button onClick={() => step > 1 ? setStep((step - 1) as Step) : nav("/pricing")} style={{ background: "none", border: "none", cursor: "pointer", color: "rgba(255,255,255,0.5)", fontFamily: "Inter", fontSize: 13, display: "flex", alignItems: "center", gap: 5 }}>
            <ArrowLeft size={14} /> {step > 1 ? "Back" : "Back to Plans"}
          </button>
          <div style={{ display: "flex", gap: 6, alignItems: "center" }}>
            {steps.map((s, i) => (
              <div key={s} style={{ display: "flex", alignItems: "center", gap: 6 }}>
                <div style={{ width: 26, height: 26, borderRadius: "50%", background: i + 1 < step ? "#2D9B68" : i + 1 === step ? gradientFlow : "rgba(255,255,255,0.1)", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 11, fontFamily: "Inter", fontWeight: 700, color: "#fff" }}>
                  {i + 1 < step ? "✓" : i + 1}
                </div>
                <span style={{ fontFamily: "Inter", fontSize: 12, color: i + 1 === step ? "#fff" : "rgba(255,255,255,0.35)" }}>{s}</span>
                {i < steps.length - 1 && <ChevronRight size={12} color="rgba(255,255,255,0.2)" style={{ marginLeft: 2 }} />}
              </div>
            ))}
          </div>
          <div style={{ display: "flex", alignItems: "center", gap: 5, fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.35)" }}>
            <Lock size={12} /> Secure checkout
          </div>
        </div>
      </div>

      <div style={{ maxWidth: 860, margin: "0 auto", padding: "28px 24px 60px", display: "flex", gap: 24, flexWrap: "wrap", alignItems: "flex-start" }}>

        {/* Main */}
        <div style={{ flex: 1, minWidth: 300 }}>

          {/* Step 1 — Plan confirmation */}
          {step === 1 && (
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "26px" }}>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 20 }}>Confirm your plan</div>

              <div style={{ display: "flex", flexDirection: "column" as const, gap: 10, marginBottom: 24 }}>
                {PLANS.map((p) => (
                  <div key={p.id} onClick={() => nav(`/checkout/subscription?plan=${p.id}&billing=${billing}`)}
                    style={{ display: "flex", gap: 12, alignItems: "center", padding: "14px 16px", borderRadius: 14, border: `2px solid ${p.id === plan.id ? plan.color : brand.borderGray}`, cursor: "pointer", background: p.id === plan.id ? `${plan.color}06` : brand.white, transition: "border-color 0.15s" }}>
                    <span style={{ fontSize: 22, flexShrink: 0 }}>{p.emoji}</span>
                    <div style={{ flex: 1 }}>
                      <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal }}>{p.name}</div>
                      <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>{p.tagline}</div>
                    </div>
                    <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 16, color: p.color }}>{formatPrice(p, annual)}/mo</div>
                    {p.id === plan.id && <CheckCircle size={18} color={plan.color} fill={plan.color} style={{ flexShrink: 0 }} />}
                  </div>
                ))}
              </div>

              <div style={{ background: brand.offWhite, borderRadius: 14, padding: "16px", marginBottom: 20 }}>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 8 }}>
                  <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal }}>{plan.name} · {annual ? "Annual" : "Monthly"}</span>
                  <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal }}>{annual ? annualTotal : price}</span>
                </div>
                {annual && (
                  <div style={{ fontFamily: "Inter", fontSize: 12, color: "#2D9B68" }}>
                    ✓ You save vs monthly billing
                  </div>
                )}
                <div style={{ borderTop: `1px solid ${brand.borderGray}`, marginTop: 12, paddingTop: 12, display: "flex", justifyContent: "space-between" }}>
                  <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal }}>Total today</span>
                  <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 16, color: plan.color }}>{annual ? annualTotal : price}</span>
                </div>
              </div>

              <button onClick={() => setStep(2)} style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: "#fff", background: gradientFlow, border: "none", borderRadius: 14, padding: "14px", cursor: "pointer", boxShadow: "0 4px 16px rgba(255,107,26,0.35)" }}>
                Continue to Payment →
              </button>
            </div>
          )}

          {/* Step 2 — Payment */}
          {step === 2 && (
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "26px" }}>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 20 }}>Payment method</div>

              <div style={{ display: "flex", flexDirection: "column" as const, gap: 8, marginBottom: 24 }}>
                {PAYMENT_METHODS.map((m) => (
                  <div key={m.id} onClick={() => setPayMethod(m.id)}
                    style={{ display: "flex", gap: 12, alignItems: "center", padding: "13px 16px", borderRadius: 12, border: `2px solid ${payMethod === m.id ? brand.orange : brand.borderGray}`, cursor: "pointer", background: payMethod === m.id ? `${brand.orange}06` : brand.white }}>
                    <span style={{ fontSize: 20 }}>{m.icon}</span>
                    <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.charcoal, flex: 1 }}>{m.label}</span>
                    {payMethod === m.id && <div style={{ width: 16, height: 16, borderRadius: "50%", background: brand.orange, border: `3px solid ${brand.orange}`, outline: `2px solid ${brand.orange}30` }} />}
                  </div>
                ))}
              </div>

              {payMethod === "card" && (
                <div style={{ display: "flex", flexDirection: "column" as const, gap: 14, marginBottom: 24 }}>
                  {[
                    { label: "Cardholder Name", key: "name", placeholder: "As it appears on card", type: "text" },
                    { label: "Card Number", key: "number", placeholder: "1234 5678 9012 3456", type: "text" },
                  ].map((field) => (
                    <div key={field.key}>
                      <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.warmGray, marginBottom: 6 }}>{field.label}</div>
                      <input value={card[field.key as keyof typeof card]} onChange={(e) => setCard({ ...card, [field.key]: e.target.value })}
                        placeholder={field.placeholder} type={field.type}
                        style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 10, padding: "11px 14px", outline: "none", boxSizing: "border-box" as const }}
                        onFocus={(e) => (e.target.style.borderColor = brand.orange)}
                        onBlur={(e) => (e.target.style.borderColor = brand.borderGray)}
                      />
                    </div>
                  ))}
                  <div style={{ display: "flex", gap: 12 }}>
                    {[{ label: "Expiry", key: "expiry", placeholder: "MM / YY" }, { label: "CVV", key: "cvv", placeholder: "•••" }].map((field) => (
                      <div key={field.key} style={{ flex: 1 }}>
                        <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.warmGray, marginBottom: 6 }}>{field.label}</div>
                        <input value={card[field.key as keyof typeof card]} onChange={(e) => setCard({ ...card, [field.key]: e.target.value })}
                          placeholder={field.placeholder}
                          style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 10, padding: "11px 14px", outline: "none", boxSizing: "border-box" as const }}
                          onFocus={(e) => (e.target.style.borderColor = brand.orange)}
                          onBlur={(e) => (e.target.style.borderColor = brand.borderGray)}
                        />
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {payMethod === "fawry" && (
                <div style={{ background: `#FF6B0010`, border: `1px solid #FF6B0030`, borderRadius: 12, padding: "16px", marginBottom: 24 }}>
                  <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal, marginBottom: 4 }}>Pay via Fawry</div>
                  <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, lineHeight: 1.6 }}>After clicking Continue, you'll receive a Fawry reference code. Use it at any Fawry outlet or the Fawry app to complete payment.</div>
                </div>
              )}

              {(payMethod === "vodafone" || payMethod === "instapay") && (
                <div style={{ background: brand.offWhite, border: `1px solid ${brand.borderGray}`, borderRadius: 12, padding: "16px", marginBottom: 24 }}>
                  <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal, marginBottom: 4 }}>Pay via {payMethod === "vodafone" ? "Vodafone Cash" : "InstaPay"}</div>
                  <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, lineHeight: 1.6 }}>Enter your registered mobile number and we'll send a payment request to your wallet.</div>
                  <input placeholder="01X XXXX XXXX" style={{ marginTop: 12, width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.white, border: `1.5px solid ${brand.borderGray}`, borderRadius: 10, padding: "11px 14px", outline: "none", boxSizing: "border-box" as const }}
                    onFocus={(e) => (e.target.style.borderColor = brand.orange)}
                    onBlur={(e) => (e.target.style.borderColor = brand.borderGray)}
                  />
                </div>
              )}

              <button onClick={() => setStep(3)} style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: "#fff", background: gradientFlow, border: "none", borderRadius: 14, padding: "14px", cursor: "pointer" }}>
                Review Order →
              </button>
            </div>
          )}

          {/* Step 3 — Review */}
          {step === 3 && (
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "26px" }}>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 20 }}>Review & confirm</div>

              {[
                ["Plan", `${plan.emoji} ${plan.name} · ${annual ? "Annual" : "Monthly"}`],
                ["Billing", annual ? `${annualTotal} billed today` : `${price} billed monthly`],
                ["Renews", annual ? "Annually — cancel before renewal to avoid charge" : "Monthly — cancel anytime before next billing date"],
                ["Payment", PAYMENT_METHODS.find((m) => m.id === payMethod)?.label ?? "Card"],
              ].map(([label, value]) => (
                <div key={label as string} style={{ display: "flex", justifyContent: "space-between", padding: "12px 0", borderBottom: `1px solid ${brand.borderGray}`, gap: 12 }}>
                  <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray }}>{label as string}</span>
                  <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal, textAlign: "right" as const }}>{value as string}</span>
                </div>
              ))}

              <div style={{ display: "flex", gap: 10, alignItems: "flex-start", marginTop: 20, marginBottom: 22, padding: "14px", background: brand.offWhite, borderRadius: 12 }}>
                <input type="checkbox" checked={agreed} onChange={(e) => setAgreed(e.target.checked)} style={{ marginTop: 2, flexShrink: 0, accentColor: brand.orange, width: 16, height: 16 }} />
                <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, lineHeight: 1.6 }}>
                  I agree to Ejadah's <span style={{ color: brand.orange, cursor: "pointer" }}>Terms of Service</span> and <span style={{ color: brand.orange, cursor: "pointer" }}>Refund Policy</span>. I understand my subscription will renew automatically and I can cancel anytime before the renewal date.
                </span>
              </div>

              <button onClick={handlePay} disabled={!agreed || processing}
                style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: "#fff", background: agreed && !processing ? gradientFlow : brand.borderGray, border: "none", borderRadius: 14, padding: "14px", cursor: agreed && !processing ? "pointer" : "not-allowed", display: "flex", alignItems: "center", justifyContent: "center", gap: 10, boxShadow: agreed ? "0 4px 16px rgba(255,107,26,0.35)" : "none" }}>
                {processing ? (
                  <><div style={{ width: 18, height: 18, border: "2px solid rgba(255,255,255,0.4)", borderTopColor: "#fff", borderRadius: "50%", animation: "spin 0.7s linear infinite" }} /> Processing…</>
                ) : (
                  <><Lock size={15} /> Confirm & Pay {annual ? annualTotal : price}</>
                )}
              </button>

              <div style={{ display: "flex", justifyContent: "center", gap: 5, marginTop: 14, fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>
                <Shield size={12} /> SSL secured · Your payment data is never stored on Ejadah servers
              </div>
            </div>
          )}
        </div>

        {/* Sidebar summary */}
        <div style={{ width: 260, flexShrink: 0 }}>
          <div style={{ position: "sticky", top: 96, background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "20px" }}>
            <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em", marginBottom: 14 }}>Order Summary</div>
            <div style={{ display: "flex", gap: 10, alignItems: "center", marginBottom: 16, padding: "12px", background: brand.offWhite, borderRadius: 12 }}>
              <span style={{ fontSize: 24 }}>{plan.emoji}</span>
              <div>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal }}>{plan.name}</div>
                <div style={{ fontFamily: "Inter", fontSize: 11, color: plan.color }}>{annual ? "Annual plan" : "Monthly plan"}</div>
              </div>
            </div>
            {plan.highlights.slice(0, 4).map((h) => (
              <div key={h} style={{ display: "flex", gap: 7, alignItems: "flex-start", marginBottom: 8 }}>
                <CheckCircle size={12} color={plan.color} style={{ flexShrink: 0, marginTop: 1 }} />
                <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, lineHeight: 1.4 }}>{h}</span>
              </div>
            ))}
            <div style={{ borderTop: `1px solid ${brand.borderGray}`, marginTop: 14, paddingTop: 14, display: "flex", justifyContent: "space-between" }}>
              <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal }}>Total</span>
              <span style={{ fontFamily: "Inter", fontWeight: 800, fontSize: 16, color: plan.color }}>{annual ? annualTotal : price}</span>
            </div>
          </div>
        </div>
      </div>

      <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
    </div>
  );
}
