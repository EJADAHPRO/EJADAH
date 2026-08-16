import { useState } from "react";
import { useNavigate } from "react-router";
import { CheckCircle, ArrowRight, ChevronLeft } from "lucide-react";
import { brand, gradientFlow, EjadahWordmark } from "@/figma/app/shared";

const STEPS = [
  { id: 1, title: "Your Specialty", sub: "Which area of dentistry do you focus on?" },
  { id: 2, title: "Your Goals", sub: "What brings you to Ejadah? Select all that apply." },
  { id: 3, title: "Target Exams", sub: "Are you preparing for any licensing exams?" },
  { id: 4, title: "Study Time", sub: "How much time can you dedicate to learning each week?" },
  { id: 5, title: "All Set!", sub: "Your personalised dashboard is ready." },
];

const specialties = [
  "Oral Biology & Histology", "Pharmacology", "Dental Biomaterials", "Operative Dentistry",
  "Endodontics", "Fixed Prosthodontics", "Removable Prosthodontics", "Periodontology & Oral Medicine",
  "Oral Radiology", "Oral Pathology", "Oral & Maxillofacial Surgery", "Orthodontics",
  "Pediatric Dentistry", "Implant Dentistry", "Aesthetic Dentistry", "Digital Dentistry",
  "Research / Academia", "Still exploring",
];
const goals = [
  { value: "exam", label: "Pass a licensing exam", icon: "📝" },
  { value: "clinical", label: "Improve clinical skills", icon: "🦷" },
  { value: "career", label: "Build a career abroad", icon: "✈️" },
  { value: "postgrad", label: "Apply for a Master's", icon: "🎓" },
  { value: "research", label: "Stay updated with research", icon: "🔬" },
  { value: "community", label: "Connect with colleagues", icon: "👥" },
];
const exams = ["EDLE (Egyptian Licensing)", "INBDE (USA)", "ORE (UK)", "ADC (Australia)", "DHA / DOH / MOH (UAE)", "NDEB (Canada)", "Not preparing for exams"];
const studyTimes = [
  { value: "light", label: "Light", desc: "1–3 hours/week", icon: "☀️" },
  { value: "moderate", label: "Moderate", desc: "4–8 hours/week", icon: "📖" },
  { value: "intensive", label: "Intensive", desc: "9–15 hours/week", icon: "🔥" },
  { value: "exam", label: "Exam Mode", desc: "15+ hours/week", icon: "⚡" },
];

interface OnboardState {
  specialty: string;
  goals: string[];
  exams: string[];
  studyTime: string;
}

export default function Onboarding() {
  const nav = useNavigate();
  const [step, setStep] = useState(1);
  const [state, setState] = useState<OnboardState>({ specialty: "", goals: [], exams: [], studyTime: "" });

  const toggle = (arr: string[], val: string): string[] => arr.includes(val) ? arr.filter((x) => x !== val) : [...arr, val];

  const canContinue = () => {
    if (step === 1) return !!state.specialty;
    if (step === 2) return state.goals.length > 0;
    if (step === 4) return !!state.studyTime;
    return true;
  };

  const progressPct = ((step - 1) / (STEPS.length - 1)) * 100;

  return (
    <div style={{ minHeight: "100vh", background: brand.offWhite, display: "flex", flexDirection: "column" as const }}>
      {/* Header */}
      <div style={{ background: brand.white, borderBottom: `1px solid ${brand.borderGray}`, padding: "0 24px", height: 60, display: "flex", alignItems: "center", gap: 16 }}>
        <EjadahWordmark />
        <div style={{ flex: 1 }} />
        <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray }}>Step {step} of {STEPS.length}</div>
        <button onClick={() => nav("/dashboard")} style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, background: "none", border: "none", cursor: "pointer" }}>Skip for now</button>
      </div>

      {/* Progress path */}
      <div style={{ height: 4, background: brand.borderGray }}>
        <div style={{ height: "100%", width: `${progressPct}%`, background: gradientFlow, transition: "width 0.4s ease" }} />
      </div>

      <div style={{ flex: 1, display: "flex", alignItems: "center", justifyContent: "center", padding: "40px 24px" }}>
        <div style={{ width: "100%", maxWidth: 560 }}>
          {step < 5 ? (
            <>
              {/* Step dots */}
              <div style={{ display: "flex", gap: 8, justifyContent: "center", marginBottom: 32 }}>
                {STEPS.slice(0, -1).map((s) => (
                  <div key={s.id} style={{ width: s.id === step ? 24 : 8, height: 8, borderRadius: 4, background: s.id <= step ? gradientFlow : brand.borderGray, transition: "all 0.3s" }} />
                ))}
              </div>

              <div style={{ textAlign: "center" as const, marginBottom: 32 }}>
                <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 28, color: brand.charcoal, marginBottom: 6 }}>{STEPS[step - 1].title}</h2>
                <p style={{ fontFamily: "Inter", fontSize: 15, color: brand.warmGray }}>{STEPS[step - 1].sub}</p>
              </div>

              {/* Step 1: Specialty */}
              {step === 1 && (
                <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(160px, 1fr))", gap: 10 }}>
                  {specialties.map((s) => (
                    <button key={s} onClick={() => setState({ ...state, specialty: s })} style={{ fontFamily: "Inter", fontWeight: state.specialty === s ? 700 : 400, fontSize: 13, color: state.specialty === s ? "#fff" : brand.charcoal, background: state.specialty === s ? gradientFlow : brand.white, border: `1.5px solid ${state.specialty === s ? "transparent" : brand.borderGray}`, borderRadius: 12, padding: "14px 12px", cursor: "pointer", transition: "all 0.15s", display: "flex", alignItems: "center", justifyContent: "center", gap: 6, boxShadow: state.specialty === s ? "0 3px 12px rgba(255,107,26,0.25)" : "none" }}>
                      {state.specialty === s && <CheckCircle size={14} color="#fff" />}{s}
                    </button>
                  ))}
                </div>
              )}

              {/* Step 2: Goals */}
              {step === 2 && (
                <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10 }}>
                  {goals.map((g) => {
                    const sel = state.goals.includes(g.value);
                    return (
                      <button key={g.value} onClick={() => setState({ ...state, goals: toggle(state.goals, g.value) })} style={{ fontFamily: "Inter", fontWeight: sel ? 600 : 400, fontSize: 13, color: sel ? "#fff" : brand.charcoal, background: sel ? gradientFlow : brand.white, border: `1.5px solid ${sel ? "transparent" : brand.borderGray}`, borderRadius: 14, padding: "16px 14px", cursor: "pointer", display: "flex", gap: 10, alignItems: "center", textAlign: "left" as const, transition: "all 0.15s" }}>
                        <span style={{ fontSize: 22, flexShrink: 0 }}>{g.icon}</span>
                        <span>{g.label}</span>
                        {sel && <CheckCircle size={14} color="#fff" style={{ marginLeft: "auto", flexShrink: 0 }} />}
                      </button>
                    );
                  })}
                </div>
              )}

              {/* Step 3: Exams */}
              {step === 3 && (
                <div style={{ display: "flex", flexDirection: "column" as const, gap: 10 }}>
                  {exams.map((e) => {
                    const sel = state.exams.includes(e);
                    return (
                      <button key={e} onClick={() => setState({ ...state, exams: toggle(state.exams, e) })} style={{ fontFamily: "Inter", fontWeight: sel ? 600 : 400, fontSize: 14, color: sel ? "#fff" : brand.charcoal, background: sel ? gradientFlow : brand.white, border: `1.5px solid ${sel ? "transparent" : brand.borderGray}`, borderRadius: 12, padding: "14px 18px", cursor: "pointer", textAlign: "left" as const, display: "flex", alignItems: "center", justifyContent: "space-between", transition: "all 0.15s" }}>
                        {e}{sel && <CheckCircle size={15} color="#fff" />}
                      </button>
                    );
                  })}
                </div>
              )}

              {/* Step 4: Study time */}
              {step === 4 && (
                <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>
                  {studyTimes.map((t) => {
                    const sel = state.studyTime === t.value;
                    return (
                      <button key={t.value} onClick={() => setState({ ...state, studyTime: t.value })} style={{ fontFamily: "Inter", background: sel ? gradientFlow : brand.white, border: `2px solid ${sel ? "transparent" : brand.borderGray}`, borderRadius: 16, padding: "22px 16px", cursor: "pointer", textAlign: "center" as const, transition: "all 0.15s", boxShadow: sel ? "0 4px 16px rgba(255,107,26,0.3)" : "none" }}>
                        <div style={{ fontSize: 32, marginBottom: 8 }}>{t.icon}</div>
                        <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: sel ? "#fff" : brand.charcoal }}>{t.label}</div>
                        <div style={{ fontFamily: "Inter", fontSize: 12, color: sel ? "rgba(255,255,255,0.75)" : brand.warmGray, marginTop: 4 }}>{t.desc}</div>
                      </button>
                    );
                  })}
                </div>
              )}

              {/* Navigation */}
              <div style={{ display: "flex", justifyContent: "space-between", marginTop: 32 }}>
                <button onClick={() => step > 1 ? setStep(step - 1) : nav("/register")} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 14, color: brand.warmGray, background: "none", border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 20px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}>
                  <ChevronLeft size={15} /> Back
                </button>
                <button onClick={() => canContinue() && setStep(step + 1)} disabled={!canContinue()} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: canContinue() ? gradientFlow : brand.borderGray, border: "none", borderRadius: 12, padding: "12px 28px", cursor: canContinue() ? "pointer" : "default", display: "flex", alignItems: "center", gap: 6, boxShadow: canContinue() ? "0 3px 12px rgba(255,107,26,0.3)" : "none" }}>
                  Continue <ArrowRight size={15} />
                </button>
              </div>
            </>
          ) : (
            /* Step 5: All set */
            <div style={{ textAlign: "center" as const }}>
              <div style={{ width: 88, height: 88, borderRadius: "50%", background: gradientFlow, display: "flex", alignItems: "center", justifyContent: "center", margin: "0 auto 24px", boxShadow: "0 8px 28px rgba(255,107,26,0.35)" }}>
                <CheckCircle size={42} color="#fff" />
              </div>
              <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 30, color: brand.charcoal, marginBottom: 10 }}>Welcome to Ejadah!</h2>
              <p style={{ fontFamily: "Inter", fontSize: 15, color: brand.warmGray, lineHeight: 1.65, marginBottom: 28, maxWidth: 400, margin: "0 auto 28px" }}>
                Your dashboard is personalised based on your specialty and goals. Here's what we've lined up for you:
              </p>

              <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px", marginBottom: 28, textAlign: "left" as const }}>
                {[
                  { icon: "🎯", title: "Personalised course feed", desc: `Based on ${state.specialty || "your specialty"}` },
                  { icon: "📝", title: `Exam prep started`, desc: state.exams.length > 0 ? state.exams[0] : "Question bank ready" },
                  { icon: "📊", title: "Learning plan created", desc: `${state.studyTime === "exam" ? "Intensive" : state.studyTime === "intensive" ? "Intensive" : state.studyTime === "moderate" ? "Moderate" : "Light"} study mode` },
                  { icon: "👥", title: "Community access", desc: "Join specialty groups and discussions" },
                ].map((item) => (
                  <div key={item.title} style={{ display: "flex", gap: 14, alignItems: "flex-start", marginBottom: 16 }}>
                    <span style={{ fontSize: 24, flexShrink: 0 }}>{item.icon}</span>
                    <div>
                      <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.charcoal }}>{item.title}</div>
                      <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>{item.desc}</div>
                    </div>
                    <CheckCircle size={16} color="#2D9B68" style={{ marginLeft: "auto", flexShrink: 0 }} />
                  </div>
                ))}
              </div>

              <button onClick={() => nav("/dashboard")} style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 16, color: "#fff", background: gradientFlow, border: "none", borderRadius: 14, padding: "16px", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 10, boxShadow: "0 4px 20px rgba(255,107,26,0.35)" }}>
                Go to My Dashboard <ArrowRight size={18} />
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
