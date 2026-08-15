import { useState } from "react";
import { useNavigate } from "react-router";
import { AlertTriangle, Clock, CreditCard, Lock, CheckCircle, ArrowRight } from "lucide-react";
import { brand, gradientFlow } from "@/app/shared";

const GRACE_HOURS = 72;
const HOURS_ELAPSED = 18;
const HOURS_LEFT = GRACE_HOURS - HOURS_ELAPSED;

export default function BillingFailed() {
  const nav = useNavigate();
  const [card, setCard] = useState({ name: "", number: "", expiry: "", cvv: "" });
  const [retrying, setRetrying] = useState(false);
  const [retried, setRetried] = useState(false);

  function handleRetry() {
    setRetrying(true);
    setTimeout(() => {
      setRetrying(false);
      setRetried(true);
      setTimeout(() => nav("/billing"), 2000);
    }, 2000);
  }

  const progressPct = Math.round((HOURS_ELAPSED / GRACE_HOURS) * 100);

  if (retried) {
    return (
      <div style={{ background: brand.offWhite, minHeight: "100vh", display: "flex", alignItems: "center", justifyContent: "center", padding: "40px 24px" }}>
        <div style={{ maxWidth: 460, width: "100%", background: brand.white, borderRadius: 24, border: `1px solid ${brand.borderGray}`, padding: "40px 32px", textAlign: "center" as const }}>
          <div style={{ fontSize: 52, marginBottom: 16 }}>🎉</div>
          <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 24, color: brand.charcoal, marginBottom: 10 }}>Payment successful!</div>
          <div style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, lineHeight: 1.7 }}>Your subscription is back to full access. Taking you to billing…</div>
          <div style={{ marginTop: 20, width: 40, height: 40, borderRadius: "50%", background: "#2D9B6820", display: "flex", alignItems: "center", justifyContent: "center", margin: "20px auto 0" }}>
            <CheckCircle size={22} color="#2D9B68" />
          </div>
        </div>
      </div>
    );
  }

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Header */}
      <div style={{ background: "#FF2D32", padding: "20px 24px" }}>
        <div style={{ maxWidth: 700, margin: "0 auto", display: "flex", gap: 10, alignItems: "center" }}>
          <AlertTriangle size={18} color="#fff" />
          <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: "#fff" }}>Payment Failed — Action Required</div>
        </div>
      </div>

      <div style={{ maxWidth: 580, margin: "0 auto", padding: "28px 24px 60px" }}>

        {/* Alert box */}
        <div style={{ background: "#FF2D320C", border: "1.5px solid #FF2D3230", borderRadius: 18, padding: "22px", marginBottom: 22 }}>
          <div style={{ display: "flex", gap: 12, alignItems: "flex-start", marginBottom: 16 }}>
            <div style={{ width: 42, height: 42, borderRadius: "50%", background: "#FF2D3214", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
              <AlertTriangle size={20} color="#FF2D32" />
            </div>
            <div>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: brand.charcoal, marginBottom: 4 }}>Your payment of EGP 499 failed</div>
              <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, lineHeight: 1.6 }}>
                We couldn't charge your Visa ending in 4242 on <strong>1 July 2025</strong>. Your account remains active during the grace period — please update your payment to avoid losing access.
              </div>
            </div>
          </div>

          {/* Grace period countdown */}
          <div>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 8 }}>
              <div style={{ display: "flex", gap: 5, alignItems: "center", fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.charcoal }}>
                <Clock size={13} color="#FF2D32" /> Grace period
              </div>
              <span style={{ fontFamily: "Inter", fontWeight: 800, fontSize: 13, color: "#FF2D32" }}>{HOURS_LEFT}h remaining</span>
            </div>
            <div style={{ height: 8, background: "#FF2D3214", borderRadius: 20, overflow: "hidden" }}>
              <div style={{ height: "100%", width: `${progressPct}%`, background: "linear-gradient(90deg, #FF2D32, #FF6B1A)", borderRadius: 20, transition: "width 0.5s" }} />
            </div>
            <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginTop: 6 }}>
              Access suspended at: <strong>4 July 2025, 12:00 PM</strong>
            </div>
          </div>
        </div>

        {/* What's at risk */}
        <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "20px", marginBottom: 20 }}>
          <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em", marginBottom: 12 }}>What you'll lose access to</div>
          {["Full MCQ bank (3,200+ questions)", "All premium video courses", "AI Tutor unlimited sessions", "Masters database & Career Abroad tools", "Marketplace — Tutoring, Mentoring, Consulting"].map((item) => (
            <div key={item} style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 8 }}>
              <div style={{ width: 5, height: 5, borderRadius: "50%", background: "#FF2D32", flexShrink: 0 }} />
              <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.charcoal }}>{item}</span>
            </div>
          ))}
        </div>

        {/* Update card form */}
        <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px", marginBottom: 20 }}>
          <div style={{ display: "flex", gap: 10, alignItems: "center", marginBottom: 20 }}>
            <CreditCard size={20} color={brand.orange} />
            <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal }}>Update Payment Method</div>
          </div>

          <div style={{ display: "flex", flexDirection: "column" as const, gap: 13 }}>
            {[{ label: "Name on Card", key: "name", placeholder: "Full name" }, { label: "Card Number", key: "number", placeholder: "1234 5678 9012 3456" }].map((f) => (
              <div key={f.key}>
                <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.warmGray, marginBottom: 5 }}>{f.label}</div>
                <input value={card[f.key as keyof typeof card]} onChange={(e) => setCard({ ...card, [f.key]: e.target.value })} placeholder={f.placeholder}
                  style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 10, padding: "11px 13px", outline: "none", boxSizing: "border-box" as const }}
                  onFocus={(e) => (e.target.style.borderColor = brand.orange)} onBlur={(e) => (e.target.style.borderColor = brand.borderGray)} />
              </div>
            ))}
            <div style={{ display: "flex", gap: 12 }}>
              {[{ label: "Expiry", key: "expiry", placeholder: "MM/YY" }, { label: "CVV", key: "cvv", placeholder: "•••" }].map((f) => (
                <div key={f.key} style={{ flex: 1 }}>
                  <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.warmGray, marginBottom: 5 }}>{f.label}</div>
                  <input value={card[f.key as keyof typeof card]} onChange={(e) => setCard({ ...card, [f.key]: e.target.value })} placeholder={f.placeholder}
                    style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 10, padding: "11px 13px", outline: "none", boxSizing: "border-box" as const }}
                    onFocus={(e) => (e.target.style.borderColor = brand.orange)} onBlur={(e) => (e.target.style.borderColor = brand.borderGray)} />
                </div>
              ))}
            </div>
          </div>

          <button onClick={handleRetry} disabled={retrying}
            style={{ width: "100%", marginTop: 20, fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: "#fff", background: gradientFlow, border: "none", borderRadius: 13, padding: "14px", cursor: retrying ? "not-allowed" : "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 10, boxShadow: "0 4px 16px rgba(255,107,26,0.3)" }}>
            {retrying
              ? <><div style={{ width: 18, height: 18, border: "2px solid rgba(255,255,255,0.3)", borderTopColor: "#fff", borderRadius: "50%", animation: "spin 0.7s linear infinite" }} /> Retrying payment…</>
              : <><Lock size={15} /> Pay EGP 499 &amp; Restore Access <ArrowRight size={15} /></>}
          </button>
          <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, textAlign: "center" as const, marginTop: 10 }}>
            Your card details are encrypted and never stored on Ejadah servers
          </div>
        </div>

        {/* Alternative methods */}
        <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "18px", marginBottom: 20 }}>
          <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em", marginBottom: 12 }}>Or pay via</div>
          {[
            { icon: "🟠", label: "Fawry", desc: "Get a reference code to pay at any Fawry outlet" },
            { icon: "🔴", label: "Vodafone Cash", desc: "Pay from your Vodafone Cash wallet" },
            { icon: "🏦", label: "InstaPay", desc: "Pay instantly via InstaPay" },
          ].map((m) => (
            <button key={m.label} style={{ width: "100%", display: "flex", gap: 12, alignItems: "center", padding: "12px", background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 11, cursor: "pointer", marginBottom: 8, textAlign: "left" as const }}>
              <span style={{ fontSize: 20 }}>{m.icon}</span>
              <div style={{ flex: 1 }}>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal }}>{m.label}</div>
                <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{m.desc}</div>
              </div>
              <ArrowRight size={14} color={brand.warmGray} />
            </button>
          ))}
        </div>

        <div style={{ textAlign: "center" as const }}>
          <button onClick={() => nav("/billing/cancel")} style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, background: "none", border: "none", cursor: "pointer" }}>
            Cancel subscription instead →
          </button>
        </div>
      </div>

      <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
    </div>
  );
}
