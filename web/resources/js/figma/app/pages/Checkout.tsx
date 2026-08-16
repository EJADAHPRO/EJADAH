import { useState } from "react";
import { useNavigate } from "react-router";
import { CreditCard, Shield, CheckCircle, ArrowRight, Tag } from "lucide-react";
import { brand, gradientFlow } from "@/figma/app/shared";

export default function Checkout() {
  const nav = useNavigate();
  const [promoCode, setPromoCode] = useState("");
  const [promoApplied, setPromoApplied] = useState(false);
  const [cardNumber, setCardNumber] = useState("");
  const [cardName, setCardName] = useState("");
  const [expiry, setExpiry] = useState("");
  const [cvv, setCvv] = useState("");
  const [payMethod, setPayMethod] = useState("card");
  const [done, setDone] = useState(false);

  const basePrice = 499;
  const discount = promoApplied ? Math.round(basePrice * 0.15) : 0;
  const total = basePrice - discount;

  if (done) return (
    <div style={{ background: brand.offWhite, minHeight: "100vh", display: "flex", alignItems: "center", justifyContent: "center", padding: 24 }}>
      <div style={{ maxWidth: 500, width: "100%", textAlign: "center" as const }}>
        <div style={{ width: 80, height: 80, borderRadius: "50%", background: gradientFlow, display: "flex", alignItems: "center", justifyContent: "center", margin: "0 auto 24px", boxShadow: "0 8px 28px rgba(255,107,26,0.35)" }}>
          <CheckCircle size={38} color="#fff" />
        </div>
        <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 28, color: brand.charcoal, marginBottom: 8 }}>Payment Successful!</h2>
        <p style={{ fontFamily: "Inter", fontSize: 15, color: brand.warmGray, marginBottom: 28, lineHeight: 1.65 }}>Your Premium membership is now active. Welcome to the full Ejadah experience.</p>
        <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "20px 24px", marginBottom: 28, textAlign: "left" as const }}>
          {[["Plan", "Premium Monthly"], ["Amount", `EGP ${total}`], ["Reference", "#EJP-20250622-0187"], ["Next billing", "July 22, 2025"]].map(([l, v]) => (
            <div key={l as string} style={{ display: "flex", justifyContent: "space-between", padding: "8px 0", borderBottom: `1px solid ${brand.borderGray}` }}>
              <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray }}>{l as string}</span>
              <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal }}>{v as string}</span>
            </div>
          ))}
        </div>
        <button onClick={() => nav("/dashboard")} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "14px 32px", cursor: "pointer" }}>Go to Dashboard</button>
      </div>
    </div>
  );

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      <div style={{ maxWidth: 900, margin: "0 auto", padding: "40px 24px" }}>
        <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 28, color: brand.charcoal, marginBottom: 6 }}>Checkout</h1>
        <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, marginBottom: 32 }}>Secure payment · SSL encrypted · Cancel anytime</p>

        <div style={{ display: "flex", gap: 28, flexWrap: "wrap" }}>
          {/* Form */}
          <div style={{ flex: 1, minWidth: 300 }}>
            {/* Payment method */}
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px", marginBottom: 18 }}>
              <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal, marginBottom: 16 }}>Payment Method</h2>
              <div style={{ display: "flex", gap: 10, marginBottom: 20 }}>
                {[["card", "💳 Credit / Debit Card"], ["fawry", "🟡 Fawry"], ["vodafone", "📱 Vodafone Cash"], ["instapay", "🏦 InstaPay"]].map(([v, l]) => (
                  <button key={v as string} onClick={() => setPayMethod(v as string)} style={{ flex: 1, fontFamily: "Inter", fontWeight: 500, fontSize: 11, color: payMethod === v ? "#fff" : brand.charcoal, background: payMethod === v ? gradientFlow : brand.offWhite, border: `1.5px solid ${payMethod === v ? "transparent" : brand.borderGray}`, borderRadius: 10, padding: "10px 6px", cursor: "pointer", textAlign: "center" as const }}>{l as string}</button>
                ))}
              </div>

              {payMethod === "card" && (
                <div style={{ display: "flex", flexDirection: "column" as const, gap: 14 }}>
                  <div>
                    <label style={{ display: "block", fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal, marginBottom: 5 }}>Card Number</label>
                    <div style={{ position: "relative" }}>
                      <CreditCard size={15} style={{ position: "absolute", left: 13, top: "50%", transform: "translateY(-50%)", color: brand.warmGray }} />
                      <input value={cardNumber} onChange={(e) => { const raw = e.target.value.replace(/\D/g, "").slice(0, 16); setCardNumber(raw.match(/.{1,4}/g)?.join(" ") ?? raw); }} placeholder="1234 5678 9012 3456" maxLength={19}
                        style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 14px 12px 40px", outline: "none", boxSizing: "border-box" as const, letterSpacing: "0.05em" }} />
                    </div>
                  </div>
                  <div><label style={{ display: "block", fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal, marginBottom: 5 }}>Cardholder Name</label>
                    <input value={cardName} onChange={(e) => setCardName(e.target.value)} placeholder="Ahmed Mostafa" style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 14px", outline: "none", boxSizing: "border-box" as const }} /></div>
                  <div style={{ display: "flex", gap: 14 }}>
                    <div style={{ flex: 1 }}><label style={{ display: "block", fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal, marginBottom: 5 }}>Expiry</label>
                      <input value={expiry} onChange={(e) => { const r = e.target.value.replace(/\D/g, "").slice(0, 4); setExpiry(r.length > 2 ? `${r.slice(0, 2)} / ${r.slice(2)}` : r); }} placeholder="MM / YY" style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 14px", outline: "none", boxSizing: "border-box" as const }} /></div>
                    <div style={{ flex: 1 }}><label style={{ display: "block", fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal, marginBottom: 5 }}>CVV</label>
                      <input value={cvv} onChange={(e) => setCvv(e.target.value.replace(/\D/g, "").slice(0, 3))} type="password" placeholder="•••" style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 14px", outline: "none", boxSizing: "border-box" as const }} /></div>
                  </div>
                </div>
              )}
              {payMethod !== "card" && (
                <div style={{ background: brand.offWhite, borderRadius: 12, padding: "20px", textAlign: "center" as const, fontFamily: "Inter", fontSize: 13, color: brand.warmGray }}>
                  You'll be redirected to complete payment via {payMethod === "fawry" ? "Fawry" : payMethod === "vodafone" ? "Vodafone Cash" : "InstaPay"} after clicking Pay Now.
                </div>
              )}
            </div>

            {/* Promo code */}
            <div style={{ background: brand.white, borderRadius: 16, border: `1px solid ${brand.borderGray}`, padding: "18px 20px" }}>
              <div style={{ display: "flex", gap: 5, alignItems: "center", marginBottom: 10 }}>
                <Tag size={14} color={brand.orange} />
                <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal }}>Promo Code</span>
              </div>
              <div style={{ display: "flex", gap: 10 }}>
                <input value={promoCode} onChange={(e) => setPromoCode(e.target.value.toUpperCase())} placeholder="e.g. EJADAH15" disabled={promoApplied}
                  style={{ flex: 1, fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${promoApplied ? "#2D9B68" : brand.borderGray}`, borderRadius: 10, padding: "10px 14px", outline: "none" }} />
                <button onClick={() => { if (promoCode.length > 3) setPromoApplied(true); }} disabled={promoApplied} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: "#fff", background: promoApplied ? "#2D9B68" : gradientFlow, border: "none", borderRadius: 10, padding: "10px 16px", cursor: promoApplied ? "default" : "pointer" }}>
                  {promoApplied ? "✓ Applied" : "Apply"}
                </button>
              </div>
              {promoApplied && <div style={{ fontFamily: "Inter", fontSize: 12, color: "#2D9B68", marginTop: 8 }}>15% discount applied! You save EGP {discount}.</div>}
            </div>
          </div>

          {/* Order summary */}
          <div style={{ width: 300, flexShrink: 0 }}>
            <div style={{ position: "sticky", top: 88, background: brand.white, borderRadius: 22, border: `1px solid ${brand.borderGray}`, overflow: "hidden", boxShadow: "0 8px 28px rgba(27,27,27,0.08)" }}>
              <div style={{ height: 5, background: gradientFlow }} />
              <div style={{ padding: "22px 22px" }}>
                <h3 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal, marginBottom: 16 }}>Order Summary</h3>
                <div style={{ background: brand.offWhite, borderRadius: 14, padding: "14px 16px", marginBottom: 16 }}>
                  <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal }}>Premium Plan</div>
                  <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginTop: 3 }}>Monthly subscription · Auto-renews</div>
                </div>
                {[["Plan price", `EGP ${basePrice}`], promoApplied ? ["Promo discount", `- EGP ${discount}`] : null, ["VAT (14%)", `EGP ${Math.round(total * 0.14)}`]].filter(Boolean).map((row) => (
                  <div key={row![0] as string} style={{ display: "flex", justifyContent: "space-between", padding: "9px 0", borderBottom: `1px solid ${brand.borderGray}` }}>
                    <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray }}>{row![0] as string}</span>
                    <span style={{ fontFamily: "Inter", fontSize: 13, color: row![0] === "Promo discount" ? "#2D9B68" : brand.charcoal, fontWeight: 600 }}>{row![1] as string}</span>
                  </div>
                ))}
                <div style={{ display: "flex", justifyContent: "space-between", padding: "14px 0" }}>
                  <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: brand.charcoal }}>Total</span>
                  <span style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.orange }}>EGP {total + Math.round(total * 0.14)}</span>
                </div>
                <button onClick={() => setDone(true)} style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "14px", cursor: "pointer", boxShadow: "0 4px 16px rgba(255,107,26,0.35)", display: "flex", alignItems: "center", justifyContent: "center", gap: 8 }}>
                  Pay Now <ArrowRight size={15} />
                </button>
                <div style={{ marginTop: 14, display: "flex", gap: 6, alignItems: "center" }}>
                  <Shield size={13} color={brand.warmGray} />
                  <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>SSL encrypted · 7-day money-back guarantee</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
