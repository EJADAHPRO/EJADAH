import { useNavigate, useSearchParams } from "react-router";
import { CheckCircle, ArrowRight, Calendar, Book, Home } from "lucide-react";
import { brand, gradientFlow } from "@/figma/app/shared";
import { getPlan } from "@/figma/app/pricingData";

export default function CheckoutSuccess() {
  const nav = useNavigate();
  const [params] = useSearchParams();
  const type = params.get("type") ?? "subscription";
  const planId = params.get("plan");
  const billing = params.get("billing") ?? "monthly";
  const courseId = params.get("course");
  const serviceType = params.get("serviceType");

  const plan = planId ? getPlan(planId) : null;

  const headlines: Record<string, { title: string; subtitle: string; emoji: string; color: string }> = {
    subscription: {
      title: plan ? `Welcome to ${plan.name}!` : "Subscription Activated!",
      subtitle: plan ? `Your ${billing === "annual" ? "annual" : "monthly"} subscription is now active. Start learning now.` : "Your subscription is now live.",
      emoji: plan?.emoji ?? "🎉",
      color: plan?.color ?? brand.orange,
    },
    course: {
      title: "Course Unlocked!",
      subtitle: "Your course is ready to start. Access it anytime from My Courses.",
      emoji: "📚",
      color: "#2D9B68",
    },
    service: {
      title: "Booking Confirmed!",
      subtitle: `Your ${serviceType ?? "session"} booking is confirmed. Check your email and bookings page for details.`,
      emoji: "✅",
      color: "#496FA8",
    },
  };

  const info = headlines[type] ?? headlines.subscription;

  const nextSteps: Record<string, { label: string; icon: React.ReactNode; action: string; path: string }[]> = {
    subscription: [
      { label: "Explore your dashboard", icon: <Home size={14} />, action: "Go to Dashboard", path: "/dashboard" },
      { label: "Browse all courses", icon: <Book size={14} />, action: "Browse Courses", path: "/courses" },
      { label: "View your plan benefits", icon: <CheckCircle size={14} />, action: "My Subscription", path: "/billing" },
    ],
    course: [
      { label: "Start learning now", icon: <Book size={14} />, action: "Go to Course", path: courseId ? `/courses/${courseId}` : "/courses" },
      { label: "Check your CPD tracker", icon: <CheckCircle size={14} />, action: "CPD Tracker", path: "/cpd" },
      { label: "Browse more courses", icon: <ArrowRight size={14} />, action: "More Courses", path: "/courses" },
    ],
    service: [
      { label: "View your bookings", icon: <Calendar size={14} />, action: "My Bookings", path: "/bookings" },
      { label: "Message your provider", icon: <ArrowRight size={14} />, action: "Open Messages", path: "/messages" },
      { label: "Browse more sessions", icon: <ArrowRight size={14} />, action: "Find More", path: `/${serviceType ?? "tutoring"}` },
    ],
  };

  const steps = nextSteps[type] ?? nextSteps.subscription;

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh", display: "flex", flexDirection: "column" as const, alignItems: "center", justifyContent: "center", padding: "40px 24px" }}>

      {/* Confetti burst (CSS only) */}
      <div style={{ position: "fixed", top: 0, left: 0, right: 0, bottom: 0, pointerEvents: "none", overflow: "hidden", zIndex: 0 }}>
        {[...Array(18)].map((_, i) => (
          <div key={i} style={{
            position: "absolute",
            top: "-10%",
            left: `${5 + i * 5.5}%`,
            width: 8 + (i % 4) * 3,
            height: 8 + (i % 3) * 3,
            background: [brand.orange, "#2D9B68", "#496FA8", brand.gold, "#8B5CF6"][i % 5],
            borderRadius: i % 2 === 0 ? "50%" : 2,
            animation: `confettiFall ${2.5 + (i % 3) * 0.6}s ease-in ${(i % 4) * 0.2}s forwards`,
            opacity: 0,
          }} />
        ))}
      </div>

      <div style={{ maxWidth: 560, width: "100%", position: "relative", zIndex: 1 }}>

        {/* Success card */}
        <div style={{ background: brand.white, borderRadius: 24, border: `1px solid ${brand.borderGray}`, padding: "40px 32px", textAlign: "center" as const, boxShadow: "0 8px 40px rgba(0,0,0,0.07)", marginBottom: 20 }}>

          {/* Icon */}
          <div style={{ width: 80, height: 80, borderRadius: "50%", background: `${info.color}14`, border: `3px solid ${info.color}30`, display: "flex", alignItems: "center", justifyContent: "center", margin: "0 auto 20px", fontSize: 36 }}>
            {info.emoji}
          </div>

          <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(22px,4vw,30px)", color: brand.charcoal, marginBottom: 10, lineHeight: 1.2 }}>
            {info.title}
          </div>
          <div style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, lineHeight: 1.7, marginBottom: 28 }}>
            {info.subtitle}
          </div>

          {/* Receipt stub */}
          <div style={{ background: brand.offWhite, borderRadius: 14, padding: "16px", marginBottom: 28, textAlign: "left" as const }}>
            <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em", marginBottom: 10 }}>Receipt</div>
            {[
              ["Order ID", `EJD-${Date.now().toString().slice(-8)}`],
              ["Date", new Date().toLocaleDateString("en-GB", { day: "numeric", month: "long", year: "numeric" })],
              ["Status", "✅ Payment successful"],
              ...(plan ? [["Plan", `${plan.emoji} ${plan.name} · ${billing === "annual" ? "Annual" : "Monthly"}`]] : []),
            ].map(([label, value]) => (
              <div key={label as string} style={{ display: "flex", justifyContent: "space-between", padding: "7px 0", borderBottom: `1px solid ${brand.borderGray}` }}>
                <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>{label as string}</span>
                <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal }}>{value as string}</span>
              </div>
            ))}
          </div>

          <button onClick={() => nav(steps[0].path)}
            style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: "#fff", background: gradientFlow, border: "none", borderRadius: 14, padding: "14px", cursor: "pointer", boxShadow: "0 4px 16px rgba(255,107,26,0.35)", display: "flex", alignItems: "center", justifyContent: "center", gap: 8 }}>
            {steps[0].action} <ArrowRight size={15} />
          </button>
        </div>

        {/* Next steps */}
        <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "22px" }}>
          <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em", marginBottom: 14 }}>What's next</div>
          {steps.map((step) => (
            <button key={step.path} onClick={() => nav(step.path)}
              style={{ width: "100%", display: "flex", gap: 12, alignItems: "center", padding: "12px", background: "none", border: `1px solid ${brand.borderGray}`, borderRadius: 12, cursor: "pointer", marginBottom: 8, textAlign: "left" as const }}>
              <div style={{ width: 32, height: 32, borderRadius: "50%", background: `${info.color}12`, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0, color: info.color }}>
                {step.icon}
              </div>
              <div style={{ flex: 1 }}>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal }}>{step.action}</div>
                <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{step.label}</div>
              </div>
              <ArrowRight size={14} color={brand.warmGray} />
            </button>
          ))}
        </div>

        <div style={{ textAlign: "center" as const, marginTop: 20, fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>
          A receipt has been sent to your registered email address.
        </div>
      </div>

      <style>{`
        @keyframes confettiFall {
          0% { opacity: 1; transform: translateY(0) rotate(0deg); }
          100% { opacity: 0; transform: translateY(110vh) rotate(720deg); }
        }
      `}</style>
    </div>
  );
}
