import { useState } from "react";
import { useNavigate, useParams } from "react-router";
import { MapPin, Globe, Mail, Phone, Linkedin, Instagram, QrCode, Download, Share2, CheckCircle, ArrowRight, ExternalLink, Award, BookOpen } from "lucide-react";
import { brand, gradientFlow, GradientBadge } from "@/app/shared";

const profileData: Record<string, any> = {
  "1": {
    name: "Dr. Yousef Al-Rashidi", title: "General Dentist · BDS Cairo University",
    specialty: "General Dentistry", country: "Egypt", city: "Cairo",
    bio: "General dentist with 4 years of clinical experience. Currently preparing for the ORE and passionate about endodontics and digital dentistry. Ejadah Premium member.",
    avatar: "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=200&q=80",
    verified: true, ejadahAlumni: true,
    certificates: [
      { title: "Comprehensive Endodontics", issuer: "Ejadah", date: "Jun 2025", accredited: true },
      { title: "Digital Smile Design", issuer: "Ejadah", date: "Apr 2025", accredited: false },
    ],
    skills: ["Root Canal Treatment", "Digital Dentistry", "Dental Photography", "Oral Surgery"],
    languages: ["Arabic", "English"],
    social: { linkedin: "#", instagram: "#", email: "dr.yousef@example.com", phone: "+20 100 000 0000" },
    stats: { profileViews: 284, nfcScans: 42, cvDownloads: 18, linkClicks: 96 },
    experience: [{ role: "General Dentist", org: "Cairo Dental Clinic", period: "2021 – Present" }],
    education: [{ degree: "BDS", uni: "Cairo University", year: "2021" }],
  },
};

export default function NFCProfile() {
  const { id } = useParams();
  const nav = useNavigate();
  const profile = profileData[id ?? "1"] ?? profileData["1"];
  const [activeTab, setActiveTab] = useState<"about" | "certs" | "contact">("about");

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Hero */}
      <div style={{ background: `linear-gradient(135deg, ${brand.charcoal} 0%, #24201D 100%)`, padding: "0 0 0" }}>
        <div style={{ height: 8, background: gradientFlow }} />
        <div style={{ maxWidth: 700, margin: "0 auto", padding: "40px 24px 36px", textAlign: "center" as const }}>
          <div style={{ position: "relative", display: "inline-block", marginBottom: 16 }}>
            <img src={profile.avatar} alt={profile.name} style={{ width: 100, height: 100, borderRadius: "50%", objectFit: "cover", border: "4px solid rgba(255,255,255,0.12)" }} />
            {profile.verified && <div style={{ position: "absolute", bottom: 4, right: 4, width: 24, height: 24, borderRadius: "50%", background: gradientFlow, border: "3px solid #1B1B1B", display: "flex", alignItems: "center", justifyContent: "center" }}><CheckCircle size={12} color="#fff" /></div>}
          </div>
          <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 26, color: "#fff", marginBottom: 4 }}>{profile.name}</h1>
          <div style={{ fontFamily: "Inter", fontSize: 14, color: "rgba(255,255,255,0.6)", marginBottom: 12 }}>{profile.title}</div>
          <div style={{ display: "flex", gap: 8, justifyContent: "center", flexWrap: "wrap", marginBottom: 16 }}>
            <GradientBadge small>{profile.specialty}</GradientBadge>
            {profile.ejadahAlumni && <span style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 700, color: brand.amber, background: `${brand.amber}18`, borderRadius: 6, padding: "3px 9px" }}>🎓 Ejadah Alumni</span>}
            <span style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.5)", display: "flex", alignItems: "center", gap: 4 }}><MapPin size={12} /> {profile.city}, {profile.country}</span>
          </div>
          <div style={{ display: "flex", gap: 10, justifyContent: "center", flexWrap: "wrap" }}>
            <button onClick={() => nav(`/profile/card`)} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "10px 18px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}><QrCode size={14} /> View NFC Card</button>
            <button style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 13, color: "rgba(255,255,255,0.7)", background: "rgba(255,255,255,0.08)", border: "1px solid rgba(255,255,255,0.12)", borderRadius: 10, padding: "10px 16px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}><Download size={14} /> Download CV</button>
            <button style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 13, color: "rgba(255,255,255,0.7)", background: "rgba(255,255,255,0.08)", border: "1px solid rgba(255,255,255,0.12)", borderRadius: 10, padding: "10px 14px", cursor: "pointer" }}><Share2 size={14} /></button>
          </div>
        </div>
      </div>

      <div style={{ maxWidth: 700, margin: "0 auto", padding: "28px 24px" }}>
        {/* Stats */}
        <div style={{ display: "grid", gridTemplateColumns: "repeat(4, 1fr)", gap: 12, marginBottom: 24 }}>
          {[["Profile Views", profile.stats.profileViews], ["NFC Scans", profile.stats.nfcScans], ["CV Downloads", profile.stats.cvDownloads], ["Link Clicks", profile.stats.linkClicks]].map(([l, v]) => (
            <div key={l as string} style={{ background: brand.white, borderRadius: 14, border: `1px solid ${brand.borderGray}`, padding: "14px 12px", textAlign: "center" as const }}>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal }}>{v}</div>
              <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginTop: 3 }}>{l as string}</div>
            </div>
          ))}
        </div>

        {/* Tabs */}
        <div style={{ display: "flex", borderBottom: `2px solid ${brand.borderGray}`, marginBottom: 24 }}>
          {(["about", "certs", "contact"] as const).map((tab) => (
            <button key={tab} onClick={() => setActiveTab(tab)} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: activeTab === tab ? brand.orange : brand.warmGray, background: "none", border: "none", borderBottom: `2px solid ${activeTab === tab ? brand.orange : "transparent"}`, marginBottom: -2, padding: "10px 18px", cursor: "pointer" }}>
              {tab === "about" ? "About" : tab === "certs" ? "Certificates" : "Contact"}
            </button>
          ))}
        </div>

        {activeTab === "about" && (
          <div>
            <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "20px 22px", marginBottom: 16 }}>
              <h3 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal, marginBottom: 10 }}>About</h3>
              <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.charcoal, lineHeight: 1.7 }}>{profile.bio}</p>
            </div>
            <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "20px 22px", marginBottom: 16 }}>
              <h3 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal, marginBottom: 12 }}>Skills</h3>
              <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>{profile.skills.map((s: string) => <span key={s} style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, background: brand.offWhite, border: `1px solid ${brand.borderGray}`, borderRadius: 8, padding: "6px 12px" }}>{s}</span>)}</div>
            </div>
            <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "20px 22px", marginBottom: 16 }}>
              <h3 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal, marginBottom: 12 }}>Experience</h3>
              {profile.experience.map((e: any) => <div key={e.role} style={{ fontFamily: "Inter", fontSize: 14, color: brand.charcoal }}><strong>{e.role}</strong> · {e.org} · <span style={{ color: brand.warmGray }}>{e.period}</span></div>)}
            </div>
          </div>
        )}

        {activeTab === "certs" && (
          <div>
            {profile.certificates.map((c: any) => (
              <div key={c.title} style={{ background: brand.white, borderRadius: 16, border: `1px solid ${brand.borderGray}`, padding: "18px 20px", marginBottom: 12, display: "flex", gap: 14, alignItems: "center" }}>
                <Award size={24} color={c.accredited ? brand.amber : brand.borderGray} />
                <div style={{ flex: 1 }}>
                  <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.charcoal }}>{c.title}</div>
                  <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginTop: 2 }}>{c.issuer} · {c.date}</div>
                  {c.accredited && <span style={{ fontFamily: "Inter", fontSize: 10, fontWeight: 700, color: brand.amber, background: `${brand.amber}12`, borderRadius: 4, padding: "2px 6px", marginTop: 4, display: "inline-block" }}>CPD Accredited</span>}
                </div>
                <button onClick={() => nav("/certificates")} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.orange, background: "rgba(255,107,26,0.07)", border: "none", borderRadius: 8, padding: "7px 12px", cursor: "pointer" }}>Verify</button>
              </div>
            ))}
          </div>
        )}

        {activeTab === "contact" && (
          <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "20px 22px" }}>
            <h3 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal, marginBottom: 16 }}>Get in Touch</h3>
            {[
              { icon: <Mail size={16} color={brand.orange} />, label: profile.social.email, action: "Send Email" },
              { icon: <Phone size={16} color={brand.orange} />, label: profile.social.phone, action: "Call" },
              { icon: <Linkedin size={16} color="#0077B5" />, label: "LinkedIn Profile", action: "Connect" },
              { icon: <Instagram size={16} color="#E4405F" />, label: "Instagram", action: "Follow" },
            ].map((item) => (
              <div key={item.label} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "12px 0", borderBottom: `1px solid ${brand.borderGray}` }}>
                <div style={{ display: "flex", gap: 10, alignItems: "center" }}>
                  {item.icon}
                  <span style={{ fontFamily: "Inter", fontSize: 14, color: brand.charcoal }}>{item.label}</span>
                </div>
                <button style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.orange, background: "none", border: "none", cursor: "pointer" }}>{item.action}</button>
              </div>
            ))}
            <button style={{ width: "100%", marginTop: 16, fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "13px", cursor: "pointer" }}>💾 Save Contact</button>
          </div>
        )}

        {/* Edit profile link */}
        <div style={{ marginTop: 20, textAlign: "center" as const }}>
          <button onClick={() => nav("/profile/edit")} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 13, color: brand.orange, background: "none", border: "none", cursor: "pointer" }}>Edit My Profile →</button>
        </div>
      </div>
    </div>
  );
}
