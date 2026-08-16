import { useState } from "react";
import { useNavigate } from "react-router";
import { Eye, EyeOff, CheckCircle, ArrowRight } from "lucide-react";
import { brand, gradientFlow, EjadahWordmark, EG_DENTAL_UNIVERSITIES } from "@/figma/app/shared";
import { useAuth } from "@/figma/app/auth";

const roles = [
  { value: "student", label: "Dental Student", icon: "🎓" },
  { value: "intern", label: "Intern", icon: "🏥" },
  { value: "dentist", label: "General Dentist", icon: "🦷" },
  { value: "specialist", label: "Specialist", icon: "⚙️" },
  { value: "academic", label: "Academic / Researcher", icon: "📚" },
];

export default function Register() {
  const nav = useNavigate();
  const { login } = useAuth();
  const [step, setStep] = useState(1);
  const [showPass, setShowPass] = useState(false);
  const [state, setState] = useState({ firstName: "", lastName: "", email: "", password: "", role: "", phone: "", country: "Egypt", university: "", agreed: false });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (step < 2) { setStep(2); return; }
    login({
      firstName: state.firstName,
      lastName: state.lastName,
      email: state.email,
      role: state.role || "dentist",
      country: state.country,
      joinedAt: new Date().toISOString(),
    });
    nav("/");
  };

  return (
    <div style={{ minHeight: "100vh", background: brand.offWhite, display: "flex" }}>
      {/* Left */}
      <div className="hidden lg:flex" style={{ width: "42%", background: `linear-gradient(135deg, ${brand.deepCharcoal} 0%, #24201D 100%)`, flexDirection: "column", alignItems: "center", justifyContent: "center", padding: "60px", position: "relative", overflow: "hidden" }}>
        <div style={{ position: "absolute", top: -100, right: -100, width: 350, height: 350, borderRadius: "50%", background: "radial-gradient(circle, rgba(255,107,26,0.12) 0%, transparent 70%)", pointerEvents: "none" }} />
        <div style={{ position: "relative", textAlign: "center" as const }}>
          <div style={{ marginBottom: 28 }}><EjadahWordmark light /></div>
          <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 28, color: "#fff", marginBottom: 14 }}>Join 40,000+ Dental Professionals</h2>
          <p style={{ fontFamily: "Inter", fontSize: 14, color: "rgba(255,255,255,0.55)", lineHeight: 1.7, maxWidth: 320, marginBottom: 32 }}>Free access to courses, research, community, and exam preparation. No credit card needed.</p>
          {["Access free courses and demos", "Join the dental community", "Practice EDLE questions", "Track your progress", "Earn certificates"].map((item) => (
            <div key={item} style={{ display: "flex", gap: 10, alignItems: "center", marginBottom: 10 }}>
              <CheckCircle size={15} color={brand.orange} />
              <span style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.7)" }}>{item}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Right */}
      <div style={{ flex: 1, display: "flex", alignItems: "center", justifyContent: "center", padding: "40px 24px" }}>
        <div style={{ width: "100%", maxWidth: 440 }}>
          <div className="lg:hidden" style={{ marginBottom: 28, display: "flex", justifyContent: "center" }}><EjadahWordmark /></div>

          {/* Step indicator */}
          <div style={{ display: "flex", gap: 8, marginBottom: 28 }}>
            {[1, 2].map((s) => (
              <div key={s} style={{ display: "flex", alignItems: "center", gap: 6 }}>
                <div style={{ width: 28, height: 28, borderRadius: "50%", background: step >= s ? gradientFlow : brand.borderGray, display: "flex", alignItems: "center", justifyContent: "center" }}>
                  {step > s ? <CheckCircle size={14} color="#fff" /> : <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: step >= s ? "#fff" : brand.warmGray }}>{s}</span>}
                </div>
                <span style={{ fontFamily: "Inter", fontSize: 12, color: step >= s ? brand.charcoal : brand.warmGray, fontWeight: step === s ? 600 : 400 }}>{s === 1 ? "Account Details" : "Your Role"}</span>
                {s < 2 && <div style={{ width: 40, height: 2, background: step > s ? brand.orange : brand.borderGray, marginLeft: 4 }} />}
              </div>
            ))}
          </div>

          <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 28, color: brand.charcoal, marginBottom: 6 }}>{step === 1 ? "Create your account" : "Tell us about you"}</h1>
          <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, marginBottom: 28 }}>{step === 1 ? "Free forever. No credit card required." : "We'll personalise your experience based on your role."}</p>

          <form onSubmit={handleSubmit}>
            {step === 1 ? (
              <>
                <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 14, marginBottom: 14 }}>
                  {[["First Name", "firstName", "Ahmed"], ["Last Name", "lastName", "Mostafa"]].map(([label, key, placeholder]) => (
                    <div key={key}>
                      <label style={{ display: "block", fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal, marginBottom: 5 }}>{label as string} *</label>
                      <input value={(state as any)[key]} onChange={(e) => setState({ ...state, [key]: e.target.value })} placeholder={placeholder as string} required
                        style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.white, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 14px", outline: "none", boxSizing: "border-box" as const }}
                        onFocus={(e) => (e.target.style.borderColor = brand.orange)}
                        onBlur={(e) => (e.target.style.borderColor = brand.borderGray)}
                      />
                    </div>
                  ))}
                </div>
                <div style={{ marginBottom: 14 }}>
                  <label style={{ display: "block", fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal, marginBottom: 5 }}>Email Address *</label>
                  <input type="email" value={state.email} onChange={(e) => setState({ ...state, email: e.target.value })} placeholder="dr.ahmed@example.com" required
                    style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.white, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 14px", outline: "none", boxSizing: "border-box" as const }}
                    onFocus={(e) => (e.target.style.borderColor = brand.orange)}
                    onBlur={(e) => (e.target.style.borderColor = brand.borderGray)}
                  />
                </div>
                <div style={{ marginBottom: 20 }}>
                  <label style={{ display: "block", fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal, marginBottom: 5 }}>Password *</label>
                  <div style={{ position: "relative" }}>
                    <input type={showPass ? "text" : "password"} value={state.password} onChange={(e) => setState({ ...state, password: e.target.value })} placeholder="At least 8 characters" required minLength={8}
                      style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.white, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 42px 12px 14px", outline: "none", boxSizing: "border-box" as const }}
                      onFocus={(e) => (e.target.style.borderColor = brand.orange)}
                      onBlur={(e) => (e.target.style.borderColor = brand.borderGray)}
                    />
                    <button type="button" onClick={() => setShowPass(!showPass)} style={{ position: "absolute", right: 12, top: "50%", transform: "translateY(-50%)", background: "none", border: "none", cursor: "pointer", color: brand.warmGray }}>
                      {showPass ? <EyeOff size={16} /> : <Eye size={16} />}
                    </button>
                  </div>
                  {/* Password strength */}
                  {state.password.length > 0 && (
                    <div style={{ display: "flex", gap: 4, marginTop: 8 }}>
                      {[state.password.length >= 8, /[A-Z]/.test(state.password), /[0-9]/.test(state.password)].map((met, i) => (
                        <div key={i} style={{ flex: 1, height: 3, borderRadius: 2, background: met ? (i === 0 ? brand.amber : i === 1 ? brand.orange : "#2D9B68") : brand.borderGray }} />
                      ))}
                    </div>
                  )}
                </div>
              </>
            ) : (
              <>
                <div style={{ marginBottom: 18 }}>
                  <label style={{ display: "block", fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal, marginBottom: 10 }}>I am a… *</label>
                  <div style={{ display: "flex", flexDirection: "column" as const, gap: 8 }}>
                    {roles.map((r) => (
                      <button type="button" key={r.value} onClick={() => setState({ ...state, role: r.value })} style={{ display: "flex", gap: 12, alignItems: "center", fontFamily: "Inter", fontWeight: state.role === r.value ? 600 : 400, fontSize: 14, color: state.role === r.value ? "#fff" : brand.charcoal, background: state.role === r.value ? gradientFlow : brand.white, border: `1.5px solid ${state.role === r.value ? "transparent" : brand.borderGray}`, borderRadius: 12, padding: "12px 16px", cursor: "pointer", textAlign: "left" as const, transition: "all 0.15s" }}>
                        <span style={{ fontSize: 20 }}>{r.icon}</span>{r.label}
                        {state.role === r.value && <CheckCircle size={16} color="#fff" style={{ marginLeft: "auto" }} />}
                      </button>
                    ))}
                  </div>
                </div>
                <div style={{ marginBottom: 18 }}>
                  <label style={{ display: "block", fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal, marginBottom: 5 }}>University / Institution</label>
                  <select value={state.university} onChange={(e) => setState({ ...state, university: e.target.value })}
                    style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: state.university ? brand.charcoal : brand.warmGray, background: brand.white, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 14px", outline: "none", appearance: "none" as const }}
                    onFocus={(e) => (e.target.style.borderColor = brand.orange)}
                    onBlur={(e) => (e.target.style.borderColor = brand.borderGray)}>
                    <option value="">Select your university…</option>
                    <optgroup label="── Government Universities ──">
                      {EG_DENTAL_UNIVERSITIES.slice(0, 16).map((u) => <option key={u} value={u}>{u}</option>)}
                    </optgroup>
                    <optgroup label="── Al-Azhar University ──">
                      {EG_DENTAL_UNIVERSITIES.slice(16, 19).map((u) => <option key={u} value={u}>{u}</option>)}
                    </optgroup>
                    <optgroup label="── Private Universities ──">
                      {EG_DENTAL_UNIVERSITIES.slice(19, 41).map((u) => <option key={u} value={u}>{u}</option>)}
                    </optgroup>
                    <optgroup label="── New Universities ──">
                      {EG_DENTAL_UNIVERSITIES.slice(41).map((u) => <option key={u} value={u}>{u}</option>)}
                    </optgroup>
                    <option value="Other / International">Other / International</option>
                  </select>
                </div>
                <div style={{ marginBottom: 18 }}>
                  <label style={{ display: "block", fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal, marginBottom: 5 }}>Country</label>
                  <select value={state.country} onChange={(e) => setState({ ...state, country: e.target.value })} style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.white, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 14px", outline: "none", appearance: "none" as const }}>
                    {["Egypt", "Saudi Arabia", "UAE", "United Kingdom", "United States", "Australia", "Canada", "Germany", "Other"].map((c) => <option key={c}>{c}</option>)}
                  </select>
                </div>
                <div style={{ display: "flex", gap: 8, alignItems: "flex-start", marginBottom: 20 }}>
                  <input type="checkbox" id="agreed" checked={state.agreed} onChange={(e) => setState({ ...state, agreed: e.target.checked })} style={{ marginTop: 2 }} />
                  <label htmlFor="agreed" style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, lineHeight: 1.55, cursor: "pointer" }}>
                    I agree to Ejadah's <span style={{ color: brand.orange, cursor: "pointer" }}>Terms of Service</span> and <span style={{ color: brand.orange, cursor: "pointer" }}>Privacy Policy</span>
                  </label>
                </div>
              </>
            )}

            <button type="submit" disabled={step === 2 && !state.agreed} style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: "#fff", background: (step === 2 && !state.agreed) ? brand.borderGray : gradientFlow, border: "none", borderRadius: 12, padding: "14px", cursor: (step === 2 && !state.agreed) ? "default" : "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 8, boxShadow: (step === 2 && !state.agreed) ? "none" : "0 4px 16px rgba(255,107,26,0.35)" }}>
              {step === 1 ? "Continue" : "Create Free Account"} <ArrowRight size={16} />
            </button>
          </form>

          <div style={{ textAlign: "center" as const, marginTop: 24, fontFamily: "Inter", fontSize: 14, color: brand.warmGray }}>
            Already have an account?{" "}
            <button onClick={() => nav("/login")} style={{ color: brand.orange, background: "none", border: "none", cursor: "pointer", fontWeight: 600, fontSize: 14 }}>Sign in</button>
          </div>
        </div>
      </div>
    </div>
  );
}
