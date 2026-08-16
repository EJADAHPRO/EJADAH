import { useState } from "react";
import { useNavigate, useSearchParams } from "react-router";
import { Lock, Shield, Calendar, Clock, User, CheckCircle, ArrowLeft } from "lucide-react";
import { brand, gradientFlow } from "@/figma/app/shared";

const SERVICE_TYPES: Record<string, { label: string; description: string; emoji: string; color: string; basePrice: number; currency: string; duration: string }> = {
  tutoring: { label: "Tutoring Session", description: "1-on-1 academic coaching with a verified tutor", emoji: "📚", color: "#2D9B68", basePrice: 450, currency: "EGP", duration: "60 min" },
  mentoring: { label: "Mentoring Session", description: "Career guidance with an experienced mentor", emoji: "🌱", color: "#496FA8", basePrice: 650, currency: "EGP", duration: "60 min" },
  consulting: { label: "Consulting Session", description: "Expert advice on clinical or business cases", emoji: "💼", color: brand.orange, basePrice: 900, currency: "EGP", duration: "60 min" },
};

const PAYMENT_METHODS = [
  { id: "card", label: "Credit / Debit Card", icon: "💳" },
  { id: "fawry", label: "Fawry", icon: "🟠" },
  { id: "vodafone", label: "Vodafone Cash", icon: "🔴" },
  { id: "instapay", label: "InstaPay", icon: "🏦" },
];

export default function CheckoutService() {
  const nav = useNavigate();
  const [params] = useSearchParams();
  const serviceType = params.get("type") ?? "tutoring";
  const providerName = params.get("provider") ?? "Dr. Mahmoud Khalil";
  const dateParam = params.get("date") ?? "Monday, 28 July 2025";
  const timeParam = params.get("time") ?? "10:00 AM";

  const service = SERVICE_TYPES[serviceType] ?? SERVICE_TYPES.tutoring;

  const [payMethod, setPayMethod] = useState("card");
  const [card, setCard] = useState({ name: "", number: "", expiry: "", cvv: "" });
  const [notes, setNotes] = useState("");
  const [agreed, setAgreed] = useState(false);
  const [processing, setProcessing] = useState(false);

  const platformFee = Math.round(service.basePrice * 0.05);
  const total = service.basePrice + platformFee;

  function handlePay() {
    setProcessing(true);
    setTimeout(() => nav(`/checkout/success?type=service&serviceType=${serviceType}`), 1800);
  }

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Header */}
      <div style={{ background: brand.charcoal, padding: "20px 24px" }}>
        <div style={{ maxWidth: 820, margin: "0 auto", display: "flex", alignItems: "center", justifyContent: "space-between" }}>
          <button onClick={() => nav(-1)} style={{ background: "none", border: "none", cursor: "pointer", color: "rgba(255,255,255,0.45)", fontFamily: "Inter", fontSize: 13, display: "flex", alignItems: "center", gap: 5 }}>
            <ArrowLeft size={14} /> Back
          </button>
          <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff" }}>Complete Your Booking</div>
          <div style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.35)", display: "flex", alignItems: "center", gap: 5 }}>
            <Lock size={12} /> Secure
          </div>
        </div>
      </div>

      <div style={{ maxWidth: 820, margin: "0 auto", padding: "28px 24px 60px", display: "flex", gap: 24, flexWrap: "wrap", alignItems: "flex-start" }}>

        {/* Main */}
        <div style={{ flex: 1, minWidth: 280, display: "flex", flexDirection: "column" as const, gap: 18 }}>

          {/* Session info */}
          <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "22px" }}>
            <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal, marginBottom: 16 }}>Booking summary</div>

            <div style={{ display: "flex", gap: 12, alignItems: "center", padding: "14px", background: `${service.color}08`, borderRadius: 12, marginBottom: 16, border: `1px solid ${service.color}20` }}>
              <span style={{ fontSize: 30 }}>{service.emoji}</span>
              <div>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal }}>{service.label}</div>
                <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>{service.description}</div>
              </div>
            </div>

            {[
              { icon: <User size={13} />, label: "Provider", value: providerName },
              { icon: <Calendar size={13} />, label: "Date", value: dateParam },
              { icon: <Clock size={13} />, label: "Time", value: `${timeParam} · ${service.duration}` },
            ].map((row) => (
              <div key={row.label} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "10px 0", borderBottom: `1px solid ${brand.borderGray}` }}>
                <div style={{ display: "flex", gap: 7, alignItems: "center", color: brand.warmGray }}>
                  {row.icon}
                  <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray }}>{row.label}</span>
                </div>
                <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal }}>{row.value}</span>
              </div>
            ))}
          </div>

          {/* Notes */}
          <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "22px" }}>
            <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal, marginBottom: 8 }}>Message to provider <span style={{ color: brand.warmGray, fontWeight: 400 }}>(optional)</span></div>
            <textarea value={notes} onChange={(e) => setNotes(e.target.value)} rows={4} placeholder="Share your goals, topics, or questions in advance so your provider can prepare…"
              style={{ width: "100%", fontFamily: "Inter", fontSize: 13, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 10, padding: "11px 13px", outline: "none", resize: "vertical" as const, boxSizing: "border-box" as const, lineHeight: 1.6 }}
              onFocus={(e) => (e.target.style.borderColor = service.color)} onBlur={(e) => (e.target.style.borderColor = brand.borderGray)}
            />
          </div>

          {/* Payment method */}
          <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "22px" }}>
            <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal, marginBottom: 16 }}>Payment method</div>

            <div style={{ display: "flex", flexDirection: "column" as const, gap: 8, marginBottom: 20 }}>
              {PAYMENT_METHODS.map((m) => (
                <div key={m.id} onClick={() => setPayMethod(m.id)}
                  style={{ display: "flex", gap: 12, alignItems: "center", padding: "12px 14px", borderRadius: 12, border: `2px solid ${payMethod === m.id ? service.color : brand.borderGray}`, cursor: "pointer" }}>
                  <span style={{ fontSize: 20 }}>{m.icon}</span>
                  <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal, flex: 1 }}>{m.label}</span>
                  {payMethod === m.id && <div style={{ width: 14, height: 14, borderRadius: "50%", background: service.color }} />}
                </div>
              ))}
            </div>

            {payMethod === "card" && (
              <div style={{ display: "flex", flexDirection: "column" as const, gap: 12 }}>
                {[{ label: "Name on Card", key: "name", placeholder: "Full name" }, { label: "Card Number", key: "number", placeholder: "1234 5678 9012 3456" }].map((f) => (
                  <div key={f.key}>
                    <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.warmGray, marginBottom: 5 }}>{f.label}</div>
                    <input value={card[f.key as keyof typeof card]} onChange={(e) => setCard({ ...card, [f.key]: e.target.value })} placeholder={f.placeholder}
                      style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 10, padding: "10px 13px", outline: "none", boxSizing: "border-box" as const }}
                      onFocus={(e) => (e.target.style.borderColor = service.color)} onBlur={(e) => (e.target.style.borderColor = brand.borderGray)} />
                  </div>
                ))}
                <div style={{ display: "flex", gap: 12 }}>
                  {[{ label: "Expiry", key: "expiry", placeholder: "MM/YY" }, { label: "CVV", key: "cvv", placeholder: "•••" }].map((f) => (
                    <div key={f.key} style={{ flex: 1 }}>
                      <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.warmGray, marginBottom: 5 }}>{f.label}</div>
                      <input value={card[f.key as keyof typeof card]} onChange={(e) => setCard({ ...card, [f.key]: e.target.value })} placeholder={f.placeholder}
                        style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 10, padding: "10px 13px", outline: "none", boxSizing: "border-box" as const }}
                        onFocus={(e) => (e.target.style.borderColor = service.color)} onBlur={(e) => (e.target.style.borderColor = brand.borderGray)} />
                    </div>
                  ))}
                </div>
              </div>
            )}

            {(payMethod !== "card") && (
              <input placeholder={payMethod === "fawry" ? "Email for reference code" : "Mobile number (01X XXXX XXXX)"}
                style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 10, padding: "10px 13px", outline: "none", boxSizing: "border-box" as const }}
                onFocus={(e) => (e.target.style.borderColor = service.color)} onBlur={(e) => (e.target.style.borderColor = brand.borderGray)} />
            )}
          </div>

          {/* Terms + Pay */}
          <div>
            <div style={{ display: "flex", gap: 10, alignItems: "flex-start", marginBottom: 16, padding: "14px", background: brand.white, borderRadius: 14, border: `1px solid ${brand.borderGray}` }}>
              <input type="checkbox" checked={agreed} onChange={(e) => setAgreed(e.target.checked)} style={{ marginTop: 2, accentColor: service.color }} />
              <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, lineHeight: 1.7 }}>
                I agree to Ejadah's <span style={{ color: service.color, cursor: "pointer" }}>Terms of Service</span>, <span style={{ color: service.color, cursor: "pointer" }}>Cancellation Policy</span>, and confirm I'm booking a professional consultation. Cancellations within 24 hours of the session may incur a fee.
              </span>
            </div>

            <button onClick={handlePay} disabled={!agreed || processing}
              style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 16, color: "#fff", background: agreed && !processing ? gradientFlow : brand.borderGray, border: "none", borderRadius: 14, padding: "16px", cursor: agreed && !processing ? "pointer" : "not-allowed", display: "flex", alignItems: "center", justifyContent: "center", gap: 10, boxShadow: agreed ? "0 4px 20px rgba(255,107,26,0.3)" : "none" }}>
              {processing
                ? <><div style={{ width: 18, height: 18, border: "2px solid rgba(255,255,255,0.3)", borderTopColor: "#fff", borderRadius: "50%", animation: "spin 0.7s linear infinite" }} /> Confirming booking…</>
                : <><Lock size={15} /> Confirm & Pay EGP {total.toLocaleString()}</>}
            </button>

            <div style={{ display: "flex", justifyContent: "center", gap: 5, marginTop: 12, fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>
              <Shield size={12} /> Payment held securely until session is completed
            </div>
          </div>
        </div>

        {/* Sidebar */}
        <div style={{ width: 240, flexShrink: 0 }}>
          <div style={{ position: "sticky", top: 90, background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "18px" }}>
            <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em", marginBottom: 12 }}>Price breakdown</div>
            {[
              { label: `${service.label} (${service.duration})`, value: `EGP ${service.basePrice.toLocaleString()}` },
              { label: "Platform fee", value: `EGP ${platformFee.toLocaleString()}` },
            ].map((row) => (
              <div key={row.label} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "10px 0", borderBottom: `1px solid ${brand.borderGray}` }}>
                <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>{row.label}</span>
                <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal }}>{row.value}</span>
              </div>
            ))}
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", paddingTop: 12, marginTop: 4 }}>
              <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal }}>Total</span>
              <span style={{ fontFamily: "Playfair Display, serif", fontWeight: 800, fontSize: 20, color: service.color }}>EGP {total.toLocaleString()}</span>
            </div>

            <div style={{ marginTop: 16, padding: "12px", background: `${service.color}08`, borderRadius: 10, border: `1px solid ${service.color}20` }}>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: service.color, marginBottom: 6 }}>Escrow Protection</div>
              <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, lineHeight: 1.6 }}>Your payment is held until after the session. Dispute within 48 hours if needed.</div>
            </div>

            <div style={{ marginTop: 12 }}>
              {["Free rescheduling 24h+ ahead", "Chat with provider before session", "CPD certificate after session"].map((item) => (
                <div key={item} style={{ display: "flex", gap: 7, alignItems: "center", marginBottom: 7 }}>
                  <CheckCircle size={11} color="#2D9B68" />
                  <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{item}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>

      <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
    </div>
  );
}
