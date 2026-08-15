import { useNavigate } from "react-router";
import { CheckCircle, ExternalLink, Award, Users, BookOpen } from "lucide-react";
import { brand, gradientFlow, GradientBadge } from "@/app/shared";

const accreditors = [
  { name: "Egyptian Dental Association", short: "EDA", type: "Primary Accreditor", country: "Egypt", flag: "🇪🇬", courses: 48, cpdHours: 840, validity: "Ongoing", verified: true, logo: "🏛️", desc: "The official accreditor for continuing dental education in Egypt. Ejadah's accredited courses count toward EDA CPD requirements." },
  { name: "Egyptian Dental Syndicate", short: "EDS", type: "Professional Body", country: "Egypt", flag: "🇪🇬", courses: 36, cpdHours: 620, validity: "Annual", verified: true, logo: "⚕️", desc: "Professional regulatory body for dentists in Egypt. Syndicate-recognised CPD points are required for license renewal." },
  { name: "Royal College of Surgeons of England", short: "RCS England", type: "International Partner", country: "United Kingdom", flag: "🇬🇧", courses: 12, cpdHours: 180, validity: "3 years", verified: true, logo: "🏰", desc: "Selected Ejadah courses carry RCS England recognition — supporting ORE candidates and dentists pursuing MFDS qualification." },
  { name: "Faculty of General Dental Practice", short: "FGDP(UK)", type: "International Partner", country: "United Kingdom", flag: "🇬🇧", courses: 8, cpdHours: 120, validity: "Annual", verified: true, logo: "🎓", desc: "FGDP-recognised CPD for dentists registered or seeking registration with the GDC in the United Kingdom." },
  { name: "Dubai Health Authority", short: "DHA", type: "Regional Accreditor", country: "UAE", flag: "🇦🇪", courses: 18, cpdHours: 240, validity: "Annual", verified: true, logo: "🌟", desc: "DHA-approved courses support dentists working in Dubai or preparing for DHA licensing exams." },
  { name: "Saudi Commission for Health Specialties", short: "SCFHS", type: "Regional Accreditor", country: "Saudi Arabia", flag: "🇸🇦", courses: 14, cpdHours: 190, validity: "Annual", verified: true, logo: "🏥", desc: "SCFHS-recognised CPD for dental professionals working or planning to work in the Kingdom of Saudi Arabia." },
];

const partners = [
  { name: "Cairo University Faculty of Dentistry", type: "Academic Partner", flag: "🇪🇬", desc: "Curriculum collaboration and joint course development" },
  { name: "Ain Shams University", type: "Academic Partner", flag: "🇪🇬", desc: "Research collaboration and postgraduate program support" },
  { name: "King's College London Dental Institute", type: "International Academic", flag: "🇬🇧", desc: "Content advisory and faculty exchange program" },
  { name: "European Federation of Periodontology", short: "EFP", type: "Scientific Partner", flag: "🇪🇺", desc: "Endorsed periodontics education content" },
  { name: "International Team for Implantology", short: "ITI", type: "Scientific Partner", flag: "🌍", desc: "Implantology curriculum alignment and endorsement" },
  { name: "American Association of Endodontists", short: "AAE", type: "Scientific Partner", flag: "🇺🇸", desc: "Evidence-based endodontics content partnership" },
];

export default function Accreditations() {
  const nav = useNavigate();
  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Hero */}
      <div style={{ background: brand.charcoal, padding: "56px 24px 48px", position: "relative", overflow: "hidden" }}>
        <div style={{ position: "absolute", inset: 0, background: `radial-gradient(ellipse at 65% 40%, rgba(255,198,46,0.07) 0%, transparent 55%)`, pointerEvents: "none" }} />
        <div style={{ maxWidth: 1100, margin: "0 auto", position: "relative" }}>
          <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, letterSpacing: "0.1em", color: brand.amber, textTransform: "uppercase" as const, marginBottom: 10 }}>Trust & Quality</div>
          <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(26px,4vw,40px)", color: "#fff", marginBottom: 12 }}>Accreditations & Partners</h1>
          <p style={{ fontFamily: "Inter", fontSize: 16, color: "rgba(255,255,255,0.6)", maxWidth: 520, marginBottom: 28 }}>Ejadah works with leading dental organisations, universities, and regulatory bodies to ensure our education meets international standards.</p>
          <div style={{ display: "flex", gap: 28, flexWrap: "wrap" }}>
            {[["6", "Accrediting Bodies"], ["6", "Academic & Scientific Partners"], ["136+", "Accredited Courses"], ["2,190+", "CPD Hours Recognised"]].map(([v, l]) => (
              <div key={l}><div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 24, color: brand.gold }}>{v}</div><div style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.45)", marginTop: 2 }}>{l}</div></div>
            ))}
          </div>
        </div>
      </div>

      <div style={{ maxWidth: 1100, margin: "0 auto", padding: "40px 24px" }}>
        {/* Accreditors */}
        <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 24, color: brand.charcoal, marginBottom: 20 }}>Accrediting Bodies</div>
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(320px, 1fr))", gap: 18, marginBottom: 48 }}>
          {accreditors.map((a) => (
            <div key={a.name} style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px 24px", boxShadow: "0 2px 10px rgba(27,27,27,0.04)" }}>
              <div style={{ display: "flex", gap: 14, alignItems: "flex-start", marginBottom: 14 }}>
                <div style={{ fontSize: 36, flexShrink: 0 }}>{a.logo}</div>
                <div style={{ flex: 1 }}>
                  <div style={{ display: "flex", gap: 6, alignItems: "center", marginBottom: 4 }}>
                    <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: brand.charcoal }}>{a.short ?? a.name}</div>
                    {a.verified && <CheckCircle size={14} color="#2D9B68" />}
                  </div>
                  <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>{a.name}</div>
                  <div style={{ display: "flex", gap: 6, marginTop: 6 }}>
                    <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.orange, background: "rgba(255,107,26,0.08)", borderRadius: 5, padding: "2px 7px" }}>{a.type}</span>
                    <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{a.flag} {a.country}</span>
                  </div>
                </div>
              </div>
              <p style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, lineHeight: 1.6, marginBottom: 16 }}>{a.desc}</p>
              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 8 }}>
                {[["Courses", a.courses], ["CPD Hours", a.cpdHours], ["Validity", a.validity]].map(([l, v]) => (
                  <div key={l as string} style={{ background: brand.offWhite, borderRadius: 10, padding: "10px 10px", textAlign: "center" as const }}>
                    <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal }}>{v}</div>
                    <div style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray, marginTop: 2 }}>{l as string}</div>
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>

        {/* Partners */}
        <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 24, color: brand.charcoal, marginBottom: 20 }}>Academic & Scientific Partners</div>
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(280px, 1fr))", gap: 14, marginBottom: 40 }}>
          {partners.map((p) => (
            <div key={p.name} style={{ background: brand.white, borderRadius: 16, border: `1px solid ${brand.borderGray}`, padding: "18px 18px" }}>
              <div style={{ display: "flex", gap: 10, alignItems: "flex-start" }}>
                <span style={{ fontSize: 28, flexShrink: 0 }}>{p.flag}</span>
                <div>
                  <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal }}>{p.short ?? p.name}</div>
                  {p.short && <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginTop: 1 }}>{p.name}</div>}
                  <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.amber, background: `${brand.amber}12`, borderRadius: 5, padding: "2px 7px", marginTop: 6, display: "inline-block" }}>{p.type}</span>
                  <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginTop: 6, lineHeight: 1.5 }}>{p.desc}</div>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* CTA */}
        <div style={{ background: brand.charcoal, borderRadius: 22, padding: "36px 32px", display: "flex", gap: 24, alignItems: "center", flexWrap: "wrap" }}>
          <div style={{ flex: 1 }}>
            <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: "#fff", marginBottom: 8 }}>Become an Accreditation Partner</div>
            <p style={{ fontFamily: "Inter", fontSize: 14, color: "rgba(255,255,255,0.6)", lineHeight: 1.6, maxWidth: 480 }}>Is your organisation interested in recognising Ejadah courses for CPD or licensing purposes? Contact our partnerships team.</p>
          </div>
          <button onClick={() => nav("/consulting")} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "13px 24px", cursor: "pointer", flexShrink: 0, display: "flex", alignItems: "center", gap: 8 }}>
            <ExternalLink size={14} /> Contact Partnerships
          </button>
        </div>
      </div>
    </div>
  );
}
