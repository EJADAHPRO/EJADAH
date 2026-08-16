import { useState } from "react";
import { useNavigate } from "react-router";
import { Eye, EyeOff, ArrowRight } from "lucide-react";
import { brand, gradientFlow, EjadahWordmark } from "@/figma/app/shared";
import { useAuth } from "@/figma/app/auth";

export default function Login() {
  const nav = useNavigate();
  const { login } = useAuth();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPass, setShowPass] = useState(false);
  const [loading, setLoading] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setTimeout(() => {
      // Derive a name from the email for demo purposes
      const local = email.split("@")[0].replace(/[._]/g, " ");
      const parts = local.split(" ");
      login({
        firstName: parts[0] ? parts[0].charAt(0).toUpperCase() + parts[0].slice(1) : "Dr.",
        lastName: parts[1] ? parts[1].charAt(0).toUpperCase() + parts[1].slice(1) : "",
        email,
        role: "dentist",
        country: "Egypt",
        joinedAt: new Date().toISOString(),
      });
      setLoading(false);
      nav("/");
    }, 900);
  };

  return (
    <div style={{ minHeight: "100vh", background: brand.offWhite, display: "flex" }}>
      {/* Left panel — branding */}
      <div className="hidden lg:flex" style={{ width: "45%", background: `linear-gradient(135deg, ${brand.deepCharcoal} 0%, #24201D 100%)`, flexDirection: "column", alignItems: "center", justifyContent: "center", padding: "60px", position: "relative", overflow: "hidden" }}>
        <div style={{ position: "absolute", top: -120, right: -120, width: 400, height: 400, borderRadius: "50%", background: `radial-gradient(circle, rgba(255,107,26,0.12) 0%, transparent 70%)`, pointerEvents: "none" }} />
        <div style={{ position: "absolute", bottom: -80, left: -80, width: 300, height: 300, borderRadius: "50%", background: `radial-gradient(circle, rgba(255,198,46,0.08) 0%, transparent 70%)`, pointerEvents: "none" }} />
        <div style={{ position: "relative", textAlign: "center" as const }}>
          <div style={{ marginBottom: 32 }}><EjadahWordmark light /></div>
          <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 32, color: "#fff", lineHeight: 1.25, marginBottom: 16 }}>
            Bridging the Gap<br />
            <span style={{ background: gradientFlow, WebkitBackgroundClip: "text", WebkitTextFillColor: "transparent" }}>Beyond Borders.</span>
          </h2>
          <p style={{ fontFamily: "Inter", fontSize: 15, color: "rgba(255,255,255,0.55)", lineHeight: 1.7, maxWidth: 360 }}>
            International dental education, exam preparation, clinical development, and professional connections — all in one platform.
          </p>
          <div style={{ display: "flex", gap: 20, justifyContent: "center", marginTop: 36 }}>
            {[["40K+", "Students"], ["200+", "Instructors"], ["14K+", "Exam Qs"]].map(([v, l]) => (
              <div key={l} style={{ textAlign: "center" as const }}>
                <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.gold }}>{v}</div>
                <div style={{ fontFamily: "Inter", fontSize: 11, color: "rgba(255,255,255,0.4)", marginTop: 2 }}>{l}</div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Right panel — form */}
      <div style={{ flex: 1, display: "flex", alignItems: "center", justifyContent: "center", padding: "40px 24px" }}>
        <div style={{ width: "100%", maxWidth: 420 }}>
          <div className="lg:hidden" style={{ marginBottom: 32, display: "flex", justifyContent: "center" }}>
            <EjadahWordmark />
          </div>

          <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 30, color: brand.charcoal, marginBottom: 6 }}>Welcome back</h1>
          <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, marginBottom: 32 }}>Sign in to your Ejadah account</p>

          <form onSubmit={handleSubmit}>
            <div style={{ marginBottom: 16 }}>
              <label style={{ display: "block", fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal, marginBottom: 6 }}>Email Address</label>
              <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} placeholder="dr.ahmed@example.com" required
                style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.white, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "13px 16px", outline: "none", boxSizing: "border-box" as const, transition: "border-color 0.15s" }}
                onFocus={(e) => (e.target.style.borderColor = brand.orange)}
                onBlur={(e) => (e.target.style.borderColor = brand.borderGray)}
              />
            </div>
            <div style={{ marginBottom: 8 }}>
              <label style={{ display: "block", fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal, marginBottom: 6 }}>Password</label>
              <div style={{ position: "relative" }}>
                <input type={showPass ? "text" : "password"} value={password} onChange={(e) => setPassword(e.target.value)} placeholder="••••••••" required
                  style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.white, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "13px 44px 13px 16px", outline: "none", boxSizing: "border-box" as const, transition: "border-color 0.15s" }}
                  onFocus={(e) => (e.target.style.borderColor = brand.orange)}
                  onBlur={(e) => (e.target.style.borderColor = brand.borderGray)}
                />
                <button type="button" onClick={() => setShowPass(!showPass)} style={{ position: "absolute", right: 12, top: "50%", transform: "translateY(-50%)", background: "none", border: "none", cursor: "pointer", color: brand.warmGray }}>
                  {showPass ? <EyeOff size={16} /> : <Eye size={16} />}
                </button>
              </div>
            </div>
            <div style={{ display: "flex", justifyContent: "flex-end", marginBottom: 24 }}>
              <button type="button" style={{ fontFamily: "Inter", fontSize: 13, color: brand.orange, background: "none", border: "none", cursor: "pointer" }}>Forgot password?</button>
            </div>
            <button type="submit" disabled={loading} style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: "#fff", background: loading ? brand.borderGray : gradientFlow, border: "none", borderRadius: 12, padding: "14px", cursor: loading ? "default" : "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 8, boxShadow: loading ? "none" : "0 4px 16px rgba(255,107,26,0.35)", transition: "all 0.2s" }}>
              {loading ? "Signing in…" : <><span>Sign In</span><ArrowRight size={16} /></>}
            </button>
          </form>

          <div style={{ display: "flex", alignItems: "center", gap: 12, margin: "24px 0" }}>
            <div style={{ flex: 1, height: 1, background: brand.borderGray }} />
            <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>or continue with</span>
            <div style={{ flex: 1, height: 1, background: brand.borderGray }} />
          </div>

          <div style={{ display: "flex", gap: 10 }}>
            {[["🇬 Google", "#fff"], ["📘 Facebook", "#fff"]].map(([label, bg]) => (
              <button key={label as string} style={{ flex: 1, fontFamily: "Inter", fontWeight: 500, fontSize: 13, color: brand.charcoal, background: brand.white, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px", cursor: "pointer" }}>{label as string}</button>
            ))}
          </div>

          <div style={{ textAlign: "center" as const, marginTop: 28, fontFamily: "Inter", fontSize: 14, color: brand.warmGray }}>
            Don't have an account?{" "}
            <button onClick={() => nav("/register")} style={{ color: brand.orange, background: "none", border: "none", cursor: "pointer", fontWeight: 600, fontSize: 14 }}>Create one free</button>
          </div>
        </div>
      </div>
    </div>
  );
}
