import { useState } from "react";
import { useNavigate } from "react-router";
import { CheckCircle, Upload, ArrowRight, Eye } from "lucide-react";
import { brand, gradientFlow } from "@/app/shared";

export default function NFCProfileEdit() {
  const nav = useNavigate();
  const [saved, setSaved] = useState(false);
  const [state, setState] = useState({ name: "Dr. Yousef Al-Rashidi", title: "General Dentist · BDS Cairo University", specialty: "General Dentistry", city: "Cairo", country: "Egypt", bio: "General dentist with 4 years of clinical experience. Currently preparing for the ORE and passionate about endodontics and digital dentistry.", linkedin: "", instagram: "", website: "", phone: "+20 100 000 0000", email: "dr.yousef@example.com", privacy: "public" });

  const sections = [
    { key: "bio", label: "Bio" }, { key: "experience", label: "Experience" },
    { key: "education", label: "Education" }, { key: "certificates", label: "Certificates" },
    { key: "skills", label: "Skills" }, { key: "contact", label: "Contact Info" },
  ];
  const [sectionVisibility, setSectionVisibility] = useState<Record<string, "public" | "private">>(Object.fromEntries(sections.map((s) => [s.key, "public" as const])));

  if (saved) return (
    <div style={{ background: brand.offWhite, minHeight: "100vh", display: "flex", alignItems: "center", justifyContent: "center" }}>
      <div style={{ textAlign: "center" as const }}>
        <div style={{ width: 72, height: 72, borderRadius: "50%", background: gradientFlow, display: "flex", alignItems: "center", justifyContent: "center", margin: "0 auto 16px" }}><CheckCircle size={34} color="#fff" /></div>
        <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 24, color: brand.charcoal, marginBottom: 8 }}>Profile Updated!</div>
        <div style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, marginBottom: 24 }}>Your changes are live on your NFC profile.</div>
        <button onClick={() => nav("/profile/1")} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "12px 28px", cursor: "pointer" }}>View My Profile</button>
      </div>
    </div>
  );

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      <div style={{ background: brand.charcoal, padding: "32px 24px" }}>
        <div style={{ maxWidth: 860, margin: "0 auto", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
          <div>
            <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 26, color: "#fff" }}>Edit Profile</h1>
            <p style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.5)", marginTop: 4 }}>Changes apply to your NFC digital profile instantly</p>
          </div>
          <div style={{ display: "flex", gap: 10 }}>
            <button onClick={() => nav("/profile/1")} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 13, color: "rgba(255,255,255,0.7)", background: "rgba(255,255,255,0.08)", border: "none", borderRadius: 10, padding: "10px 16px", cursor: "pointer", display: "flex", alignItems: "center", gap: 5 }}><Eye size={14} /> Preview</button>
            <button onClick={() => setSaved(true)} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "10px 20px", cursor: "pointer" }}>Save Changes</button>
          </div>
        </div>
      </div>

      <div style={{ maxWidth: 860, margin: "0 auto", padding: "32px 24px" }}>
        <div style={{ display: "flex", gap: 24, flexWrap: "wrap" }}>
          <div style={{ flex: 1, minWidth: 300 }}>
            {/* Photo */}
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px", marginBottom: 18 }}>
              <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal, marginBottom: 16 }}>Profile Photo</h2>
              <div style={{ display: "flex", gap: 16, alignItems: "center" }}>
                <img src="https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=100&q=80" alt="" style={{ width: 72, height: 72, borderRadius: "50%", objectFit: "cover" }} />
                <div>
                  <button style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "9px 16px", cursor: "pointer", display: "flex", alignItems: "center", gap: 5, marginBottom: 6 }}>
                    <Upload size={13} /> Upload New Photo
                  </button>
                  <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>JPG or PNG · Min 400×400px</div>
                </div>
              </div>
            </div>

            {/* Basic info */}
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px", marginBottom: 18 }}>
              <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal, marginBottom: 16 }}>Basic Information</h2>
              {[["Full Name", "name", "Dr. Yousef Al-Rashidi"], ["Professional Title", "title", "e.g. General Dentist · BDS Cairo University"], ["Specialty", "specialty", "General Dentistry"], ["City", "city", "Cairo"], ["Country", "country", "Egypt"]].map(([label, key, placeholder]) => (
                <div key={key as string} style={{ marginBottom: 14 }}>
                  <label style={{ display: "block", fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal, marginBottom: 5 }}>{label as string}</label>
                  <input value={(state as any)[key as string]} onChange={(e) => setState({ ...state, [key as string]: e.target.value })} placeholder={placeholder as string}
                    style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "11px 14px", outline: "none", boxSizing: "border-box" as const }} />
                </div>
              ))}
              <div>
                <label style={{ display: "block", fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal, marginBottom: 5 }}>Bio</label>
                <textarea value={state.bio} onChange={(e) => setState({ ...state, bio: e.target.value })} rows={4}
                  style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "11px 14px", outline: "none", resize: "vertical", boxSizing: "border-box" as const }} />
              </div>
            </div>

            {/* Social */}
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px", marginBottom: 18 }}>
              <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal, marginBottom: 16 }}>Contact & Social</h2>
              {[["Email", "email"], ["Phone", "phone"], ["LinkedIn URL", "linkedin"], ["Instagram", "instagram"], ["Website", "website"]].map(([label, key]) => (
                <div key={key as string} style={{ marginBottom: 12 }}>
                  <label style={{ display: "block", fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal, marginBottom: 5 }}>{label as string}</label>
                  <input value={(state as any)[key as string]} onChange={(e) => setState({ ...state, [key as string]: e.target.value })} placeholder={`Your ${label as string}`}
                    style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "11px 14px", outline: "none", boxSizing: "border-box" as const }} />
                </div>
              ))}
            </div>
          </div>

          {/* Privacy sidebar */}
          <div style={{ width: 260, flexShrink: 0 }}>
            <div style={{ position: "sticky", top: 88, display: "flex", flexDirection: "column" as const, gap: 16 }}>
              <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "20px" }}>
                <h3 style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal, marginBottom: 14 }}>Section Privacy</h3>
                {sections.map((sec) => (
                  <div key={sec.key} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "9px 0", borderBottom: `1px solid ${brand.borderGray}` }}>
                    <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal }}>{sec.label}</span>
                    <button onClick={() => setSectionVisibility((prev) => ({ ...prev, [sec.key]: prev[sec.key] === "public" ? "private" : "public" }))}
                      style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 600, color: sectionVisibility[sec.key] === "public" ? "#2D9B68" : brand.warmGray, background: sectionVisibility[sec.key] === "public" ? "rgba(45,155,104,0.08)" : brand.paleGray, border: "none", borderRadius: 6, padding: "4px 10px", cursor: "pointer" }}>
                      {sectionVisibility[sec.key] === "public" ? "Public" : "Private"}
                    </button>
                  </div>
                ))}
              </div>
              <div style={{ background: brand.charcoal, borderRadius: 16, padding: "18px" }}>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff", marginBottom: 8 }}>NFC Card</div>
                <p style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.55)", lineHeight: 1.55, marginBottom: 12 }}>Your digital profile updates instantly — no new card needed.</p>
                <button onClick={() => nav("/profile/card")} style={{ width: "100%", fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: "#fff", background: gradientFlow, border: "none", borderRadius: 8, padding: "10px", cursor: "pointer" }}>View NFC Card</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
