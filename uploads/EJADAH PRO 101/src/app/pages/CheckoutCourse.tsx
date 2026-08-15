import { useState } from "react";
import { useNavigate, useSearchParams } from "react-router";
import { Lock, CheckCircle, Shield, ArrowLeft, Star } from "lucide-react";
import { brand, gradientFlow } from "@/app/shared";

const MOCK_COURSES: Record<string, { title: string; instructor: string; duration: string; rating: number; reviews: number; price: number; currency: string; emoji: string; includes: string[] }> = {
  "endo-masterclass": {
    title: "Endodontic Masterclass: Complex Canal Anatomy",
    instructor: "Dr. Mahmoud Khalil, MSc, PhD",
    duration: "12 hours · 38 lectures",
    rating: 4.9,
    reviews: 312,
    price: 1200,
    currency: "EGP",
    emoji: "🦷",
    includes: ["12h on-demand video", "38 downloadable resources", "Certificate of completion", "CPD-accredited: 12 points", "Lifetime access", "Q&A with instructor"],
  },
  "implant-foundations": {
    title: "Implant Dentistry: Surgical Foundations",
    instructor: "Dr. Sara El-Sayed, BDS, FDSRCS",
    duration: "18 hours · 54 lectures",
    rating: 4.8,
    reviews: 198,
    price: 2200,
    currency: "EGP",
    emoji: "🔩",
    includes: ["18h on-demand video", "54 downloadable resources", "Certificate of completion", "CPD-accredited: 18 points", "Lifetime access", "Case library access"],
  },
  "perio-advanced": {
    title: "Advanced Periodontology & Tissue Management",
    instructor: "Dr. Ahmed Naguib, MSc Perio",
    duration: "10 hours · 30 lectures",
    rating: 4.7,
    reviews: 241,
    price: 999,
    currency: "EGP",
    emoji: "🩺",
    includes: ["10h on-demand video", "30 downloadable resources", "Certificate of completion", "CPD-accredited: 10 points", "Lifetime access"],
  },
};

const PAYMENT_METHODS = [
  { id: "card", label: "Credit / Debit Card", icon: "💳" },
  { id: "fawry", label: "Fawry", icon: "🟠" },
  { id: "vodafone", label: "Vodafone Cash", icon: "🔴" },
  { id: "instapay", label: "InstaPay", icon: "🏦" },
];

export default function CheckoutCourse() {
  const nav = useNavigate();
  const [params] = useSearchParams();
  const courseId = params.get("course") ?? "endo-masterclass";
  const course = MOCK_COURSES[courseId] ?? MOCK_COURSES["endo-masterclass"];

  const [payMethod, setPayMethod] = useState("card");
  const [card, setCard] = useState({ name: "", number: "", expiry: "", cvv: "" });
  const [agreed, setAgreed] = useState(false);
  const [processing, setProcessing] = useState(false);
  const [step, setStep] = useState<1 | 2>(1);

  function handlePay() {
    setProcessing(true);
    setTimeout(() => nav(`/checkout/success?type=course&course=${courseId}`), 1800);
  }

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Header */}
      <div style={{ background: brand.charcoal, padding: "20px 24px" }}>
        <div style={{ maxWidth: 820, margin: "0 auto", display: "flex", alignItems: "center", justifyContent: "space-between" }}>
          <button onClick={() => nav(-1)} style={{ background: "none", border: "none", cursor: "pointer", color: "rgba(255,255,255,0.45)", fontFamily: "Inter", fontSize: 13, display: "flex", alignItems: "center", gap: 5 }}>
            <ArrowLeft size={14} /> Back
          </button>
          <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff" }}>Course Checkout</div>
          <div style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.35)", display: "flex", alignItems: "center", gap: 5 }}>
            <Lock size={12} /> Secure
          </div>
        </div>
      </div>

      <div style={{ maxWidth: 820, margin: "0 auto", padding: "28px 24px 60px", display: "flex", gap: 24, flexWrap: "wrap", alignItems: "flex-start" }}>

        {/* Main */}
        <div style={{ flex: 1, minWidth: 280 }}>

          {step === 1 && (
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "26px" }}>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 20 }}>Course details</div>

              {/* Course card */}
              <div style={{ background: brand.offWhite, borderRadius: 14, padding: "18px", marginBottom: 22, display: "flex", gap: 14, alignItems: "flex-start" }}>
                <div style={{ fontSize: 36, flexShrink: 0 }}>{course.emoji}</div>
                <div>
                  <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 16, color: brand.charcoal, marginBottom: 4, lineHeight: 1.3 }}>{course.title}</div>
                  <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginBottom: 6 }}>{course.instructor}</div>
                  <div style={{ display: "flex", gap: 10, alignItems: "center", flexWrap: "wrap" as const }}>
                    <div style={{ display: "flex", gap: 3, alignItems: "center" }}>
                      {[...Array(5)].map((_, i) => <Star key={i} size={11} fill={i < Math.round(course.rating) ? brand.gold : "none"} color={brand.gold} />)}
                      <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: brand.charcoal, marginLeft: 3 }}>{course.rating}</span>
                    </div>
                    <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>({course.reviews.toLocaleString()} reviews)</span>
                    <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>· {course.duration}</span>
                  </div>
                </div>
              </div>

              {/* What's included */}
              <div style={{ marginBottom: 24 }}>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em", marginBottom: 12 }}>What you get</div>
                {course.includes.map((item) => (
                  <div key={item} style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 8 }}>
                    <CheckCircle size={13} color="#2D9B68" />
                    <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal }}>{item}</span>
                  </div>
                ))}
              </div>

              <button onClick={() => setStep(2)} style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: "#fff", background: gradientFlow, border: "none", borderRadius: 14, padding: "14px", cursor: "pointer", boxShadow: "0 4px 16px rgba(255,107,26,0.3)" }}>
                Continue to Payment →
              </button>
            </div>
          )}

          {step === 2 && (
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "26px" }}>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 20 }}>Payment</div>

              <div style={{ display: "flex", flexDirection: "column" as const, gap: 8, marginBottom: 22 }}>
                {PAYMENT_METHODS.map((m) => (
                  <div key={m.id} onClick={() => setPayMethod(m.id)}
                    style={{ display: "flex", gap: 12, alignItems: "center", padding: "13px 16px", borderRadius: 12, border: `2px solid ${payMethod === m.id ? brand.orange : brand.borderGray}`, cursor: "pointer" }}>
                    <span style={{ fontSize: 20 }}>{m.icon}</span>
                    <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.charcoal, flex: 1 }}>{m.label}</span>
                    {payMethod === m.id && <div style={{ width: 14, height: 14, borderRadius: "50%", background: brand.orange }} />}
                  </div>
                ))}
              </div>

              {payMethod === "card" && (
                <div style={{ display: "flex", flexDirection: "column" as const, gap: 13, marginBottom: 22 }}>
                  {[{ label: "Name on Card", key: "name", placeholder: "Full name" }, { label: "Card Number", key: "number", placeholder: "1234 5678 9012 3456" }].map((f) => (
                    <div key={f.key}>
                      <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.warmGray, marginBottom: 5 }}>{f.label}</div>
                      <input value={card[f.key as keyof typeof card]} onChange={(e) => setCard({ ...card, [f.key]: e.target.value })} placeholder={f.placeholder}
                        style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 10, padding: "10px 13px", outline: "none", boxSizing: "border-box" as const }}
                        onFocus={(e) => (e.target.style.borderColor = brand.orange)} onBlur={(e) => (e.target.style.borderColor = brand.borderGray)} />
                    </div>
                  ))}
                  <div style={{ display: "flex", gap: 12 }}>
                    {[{ label: "Expiry", key: "expiry", placeholder: "MM/YY" }, { label: "CVV", key: "cvv", placeholder: "•••" }].map((f) => (
                      <div key={f.key} style={{ flex: 1 }}>
                        <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.warmGray, marginBottom: 5 }}>{f.label}</div>
                        <input value={card[f.key as keyof typeof card]} onChange={(e) => setCard({ ...card, [f.key]: e.target.value })} placeholder={f.placeholder}
                          style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 10, padding: "10px 13px", outline: "none", boxSizing: "border-box" as const }}
                          onFocus={(e) => (e.target.style.borderColor = brand.orange)} onBlur={(e) => (e.target.style.borderColor = brand.borderGray)} />
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {(payMethod === "fawry" || payMethod === "vodafone" || payMethod === "instapay") && (
                <div style={{ background: brand.offWhite, borderRadius: 12, padding: "14px", marginBottom: 22 }}>
                  <input placeholder={payMethod === "fawry" ? "Email for Fawry code" : "Mobile number (01X XXXX XXXX)"}
                    style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.white, border: `1.5px solid ${brand.borderGray}`, borderRadius: 10, padding: "10px 13px", outline: "none", boxSizing: "border-box" as const }}
                    onFocus={(e) => (e.target.style.borderColor = brand.orange)} onBlur={(e) => (e.target.style.borderColor = brand.borderGray)} />
                </div>
              )}

              <div style={{ display: "flex", gap: 10, alignItems: "flex-start", marginBottom: 20, padding: "12px", background: brand.offWhite, borderRadius: 10 }}>
                <input type="checkbox" checked={agreed} onChange={(e) => setAgreed(e.target.checked)} style={{ marginTop: 2, accentColor: brand.orange }} />
                <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, lineHeight: 1.6 }}>
                  I agree to Ejadah's <span style={{ color: brand.orange }}>Terms of Service</span> and <span style={{ color: brand.orange }}>Refund Policy</span>. Digital courses are non-refundable once accessed.
                </span>
              </div>

              <button onClick={handlePay} disabled={!agreed || processing}
                style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: "#fff", background: agreed && !processing ? gradientFlow : brand.borderGray, border: "none", borderRadius: 14, padding: "14px", cursor: agreed && !processing ? "pointer" : "not-allowed", display: "flex", alignItems: "center", justifyContent: "center", gap: 10 }}>
                {processing
                  ? <><div style={{ width: 18, height: 18, border: "2px solid rgba(255,255,255,0.3)", borderTopColor: "#fff", borderRadius: "50%", animation: "spin 0.7s linear infinite" }} /> Processing…</>
                  : <><Lock size={15} /> Pay {course.currency} {course.price.toLocaleString()}</>}
              </button>

              <div style={{ display: "flex", justifyContent: "center", gap: 5, marginTop: 12, fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>
                <Shield size={12} /> 30-day satisfaction guarantee
              </div>
            </div>
          )}
        </div>

        {/* Sidebar */}
        <div style={{ width: 240, flexShrink: 0 }}>
          <div style={{ position: "sticky", top: 90, background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "18px" }}>
            <div style={{ textAlign: "center" as const, marginBottom: 14 }}>
              <div style={{ fontSize: 36, marginBottom: 8 }}>{course.emoji}</div>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 14, color: brand.charcoal, lineHeight: 1.3, marginBottom: 6 }}>{course.title}</div>
              <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>{course.instructor}</div>
            </div>
            <div style={{ borderTop: `1px solid ${brand.borderGray}`, paddingTop: 14, display: "flex", justifyContent: "space-between", alignItems: "center" }}>
              <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal }}>Price</span>
              <span style={{ fontFamily: "Playfair Display, serif", fontWeight: 800, fontSize: 20, color: brand.orange }}>{course.currency} {course.price.toLocaleString()}</span>
            </div>
            <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginTop: 8, textAlign: "center" as const }}>One-time payment · Lifetime access</div>
          </div>
        </div>
      </div>

      <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
    </div>
  );
}
