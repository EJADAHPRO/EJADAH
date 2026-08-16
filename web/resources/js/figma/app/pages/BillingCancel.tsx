import { useState } from "react";
import { useNavigate } from "react-router";
import { ArrowLeft, AlertTriangle, CheckCircle, Pause, TrendingDown, Gift } from "lucide-react";
import { brand, gradientFlow } from "@/figma/app/shared";
import { getPlan } from "@/figma/app/pricingData";

const MOCK_PLAN_ID = "exam-pro";

const CANCEL_REASONS = [
  "Too expensive",
  "Not using it enough",
  "Missing features I need",
  "Found a better alternative",
  "Technical issues",
  "Taking a break from studying",
  "Completed my goal",
  "Other",
];

type CancelStep = "reasons" | "offers" | "confirm" | "done";

export default function BillingCancel() {
  const nav = useNavigate();
  const plan = getPlan(MOCK_PLAN_ID);

  const [step, setStep] = useState<CancelStep>("reasons");
  const [reason, setReason] = useState("");
  const [feedback, setFeedback] = useState("");
  const [cancelling, setCancelling] = useState(false);

  const SAVE_OFFERS = [
    {
      id: "pause",
      icon: <Pause size={22} color="#496FA8" />,
      title: "Pause for 2 months",
      description: "Take a break and resume exactly where you left off. No charges during the pause period.",
      badge: "Popular choice",
      badgeColor: "#496FA8",
      action: "Pause My Subscription",
    },
    {
      id: "downgrade",
      icon: <TrendingDown size={22} color="#2D9B68" />,
      title: "Switch to Student Pass",
      description: "Cut your cost to EGP 299/month and keep access to core learning features.",
      badge: "Save 40%",
      badgeColor: "#2D9B68",
      action: "Switch Plan",
    },
    {
      id: "discount",
      icon: <Gift size={22} color={brand.orange} />,
      title: "Get 3 months at 50% off",
      description: "We'd love to keep you. Stay on your current plan at half-price for the next 3 months.",
      badge: "Exclusive offer",
      badgeColor: brand.orange,
      action: "Claim Discount",
    },
  ];

  function handleConfirmCancel() {
    setCancelling(true);
    setTimeout(() => setStep("done"), 1800);
  }

  if (step === "done") {
    return (
      <div style={{ background: brand.offWhite, minHeight: "100vh", display: "flex", alignItems: "center", justifyContent: "center", padding: "40px 24px" }}>
        <div style={{ maxWidth: 480, width: "100%", background: brand.white, borderRadius: 24, border: `1px solid ${brand.borderGray}`, padding: "40px 32px", textAlign: "center" as const }}>
          <div style={{ fontSize: 48, marginBottom: 16 }}>👋</div>
          <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 24, color: brand.charcoal, marginBottom: 12 }}>Subscription cancelled</div>
          <div style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, lineHeight: 1.7, marginBottom: 24 }}>
            Your subscription has been cancelled. You'll retain access until <strong>31 July 2025</strong>. We hope to see you again soon.
          </div>
          <div style={{ background: brand.offWhite, borderRadius: 12, padding: "16px", marginBottom: 24 }}>
            {["Access continues until 31 July 2025", "No further charges will be made", "Your progress and certificates are saved", "You can resubscribe anytime"].map((item) => (
              <div key={item} style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 8 }}>
                <CheckCircle size={13} color="#2D9B68" />
                <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.charcoal }}>{item}</span>
              </div>
            ))}
          </div>
          <button onClick={() => nav("/pricing")} style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "13px", cursor: "pointer", marginBottom: 10 }}>
            View Plans to Resubscribe
          </button>
          <button onClick={() => nav("/")} style={{ width: "100%", fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.warmGray, background: "none", border: "none", cursor: "pointer" }}>
            Go to Home
          </button>
        </div>
      </div>
    );
  }

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Header */}
      <div style={{ background: brand.charcoal, padding: "20px 24px" }}>
        <div style={{ maxWidth: 700, margin: "0 auto", display: "flex", alignItems: "center", gap: 12 }}>
          <button onClick={() => step === "reasons" ? nav("/billing") : setStep(step === "offers" ? "reasons" : "offers")}
            style={{ background: "none", border: "none", cursor: "pointer", color: "rgba(255,255,255,0.4)", fontFamily: "Inter", fontSize: 13, display: "flex", alignItems: "center", gap: 5 }}>
            <ArrowLeft size={14} /> Back
          </button>
          <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff" }}>Cancel Subscription</div>
        </div>
      </div>

      <div style={{ maxWidth: 560, margin: "0 auto", padding: "32px 24px 60px" }}>

        {/* Step 1 — Reasons */}
        {step === "reasons" && (
          <div>
            <div style={{ background: `${brand.orange}0C`, border: `1px solid ${brand.orange}25`, borderRadius: 16, padding: "16px 18px", marginBottom: 24, display: "flex", gap: 12, alignItems: "flex-start" }}>
              <AlertTriangle size={18} color={brand.orange} style={{ flexShrink: 0, marginTop: 1 }} />
              <div>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal, marginBottom: 4 }}>You're about to cancel {plan?.name}</div>
                <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, lineHeight: 1.6 }}>You'll lose access to all {plan?.name} features after your current billing period ends on 31 July 2025.</div>
              </div>
            </div>

            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px" }}>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 8 }}>Help us improve</div>
              <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, marginBottom: 20, lineHeight: 1.6 }}>Before you go, could you tell us why you're leaving? Your feedback helps us build a better platform.</div>

              <div style={{ display: "flex", flexDirection: "column" as const, gap: 8, marginBottom: 18 }}>
                {CANCEL_REASONS.map((r) => (
                  <div key={r} onClick={() => setReason(r)}
                    style={{ display: "flex", gap: 10, alignItems: "center", padding: "12px 14px", borderRadius: 11, border: `2px solid ${reason === r ? brand.orange : brand.borderGray}`, cursor: "pointer", background: reason === r ? `${brand.orange}06` : brand.white }}>
                    <div style={{ width: 16, height: 16, borderRadius: "50%", border: `2px solid ${reason === r ? brand.orange : brand.borderGray}`, background: reason === r ? brand.orange : "transparent", flexShrink: 0 }} />
                    <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal }}>{r}</span>
                  </div>
                ))}
              </div>

              <textarea value={feedback} onChange={(e) => setFeedback(e.target.value)} rows={3} placeholder="Any additional comments? (optional)"
                style={{ width: "100%", fontFamily: "Inter", fontSize: 13, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 10, padding: "10px 12px", outline: "none", resize: "vertical" as const, boxSizing: "border-box" as const, marginBottom: 18 }}
                onFocus={(e) => (e.target.style.borderColor = brand.orange)} onBlur={(e) => (e.target.style.borderColor = brand.borderGray)} />

              <button onClick={() => setStep("offers")} disabled={!reason}
                style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: reason ? gradientFlow : brand.borderGray, border: "none", borderRadius: 12, padding: "13px", cursor: reason ? "pointer" : "not-allowed" }}>
                Continue →
              </button>
            </div>
          </div>
        )}

        {/* Step 2 — Save offers */}
        {step === "offers" && (
          <div>
            <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.charcoal, marginBottom: 6, textAlign: "center" as const }}>Before you go…</div>
            <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, marginBottom: 24, textAlign: "center" as const, lineHeight: 1.6 }}>
              We made some offers just for you. One of these might be exactly what you need.
            </div>

            <div style={{ display: "flex", flexDirection: "column" as const, gap: 14, marginBottom: 24 }}>
              {SAVE_OFFERS.map((offer) => (
                <div key={offer.id} style={{ background: brand.white, borderRadius: 16, border: `1px solid ${brand.borderGray}`, padding: "20px" }}>
                  <div style={{ display: "flex", gap: 12, alignItems: "flex-start" }}>
                    <div style={{ width: 42, height: 42, borderRadius: 12, background: brand.offWhite, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                      {offer.icon}
                    </div>
                    <div style={{ flex: 1 }}>
                      <div style={{ display: "flex", gap: 8, alignItems: "center", flexWrap: "wrap" as const, marginBottom: 4 }}>
                        <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal }}>{offer.title}</div>
                        <span style={{ fontFamily: "Inter", fontWeight: 800, fontSize: 10, color: offer.badgeColor, background: `${offer.badgeColor}14`, borderRadius: 20, padding: "2px 8px" }}>{offer.badge}</span>
                      </div>
                      <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, lineHeight: 1.6, marginBottom: 12 }}>{offer.description}</div>
                      <button onClick={() => nav("/billing")}
                        style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: "#fff", background: `linear-gradient(135deg, ${offer.badgeColor}, ${offer.badgeColor}CC)`, border: "none", borderRadius: 9, padding: "9px 18px", cursor: "pointer" }}>
                        {offer.action}
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>

            <button onClick={() => setStep("confirm")} style={{ width: "100%", fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.warmGray, background: brand.white, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px", cursor: "pointer" }}>
              No thanks, continue to cancel
            </button>
          </div>
        )}

        {/* Step 3 — Final confirm */}
        {step === "confirm" && (
          <div style={{ background: brand.white, borderRadius: 20, border: `1.5px solid #FF2D3225`, padding: "28px" }}>
            <div style={{ textAlign: "center" as const, marginBottom: 22 }}>
              <div style={{ fontSize: 40, marginBottom: 10 }}>⚠️</div>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 8 }}>Confirm cancellation</div>
              <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, lineHeight: 1.7 }}>
                Your <strong>{plan?.name}</strong> subscription will end on <strong>31 July 2025</strong>. After that, you'll lose access to all premium features.
              </div>
            </div>

            <div style={{ background: brand.offWhite, borderRadius: 12, padding: "14px", marginBottom: 20 }}>
              {["All premium courses become inaccessible", "MCQ bank limited to 5 questions/day", "No more AI Tutor access", "Career tools and Masters database hidden", "Marketplace services unavailable"].map((item) => (
                <div key={item} style={{ display: "flex", gap: 7, alignItems: "center", marginBottom: 7 }}>
                  <div style={{ width: 5, height: 5, borderRadius: "50%", background: "#FF2D32", flexShrink: 0 }} />
                  <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.charcoal }}>{item}</span>
                </div>
              ))}
            </div>

            <button onClick={handleConfirmCancel} disabled={cancelling}
              style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: cancelling ? brand.borderGray : "#FF2D32", border: "none", borderRadius: 12, padding: "13px", cursor: cancelling ? "not-allowed" : "pointer", marginBottom: 10, display: "flex", alignItems: "center", justifyContent: "center", gap: 8 }}>
              {cancelling
                ? <><div style={{ width: 16, height: 16, border: "2px solid rgba(255,255,255,0.3)", borderTopColor: "#fff", borderRadius: "50%", animation: "spin 0.7s linear infinite" }} /> Cancelling…</>
                : "Cancel My Subscription"}
            </button>
            <button onClick={() => nav("/billing")} style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "13px", cursor: "pointer" }}>
              Keep My Subscription
            </button>
          </div>
        )}
      </div>

      <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
    </div>
  );
}
