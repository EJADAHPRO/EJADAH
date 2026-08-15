import { useState } from "react";
import { useNavigate, useParams } from "react-router";
import { CheckCircle, X, AlertTriangle, Search, QrCode, ExternalLink, Award, Clock, BookOpen } from "lucide-react";
import { brand, gradientFlow, GradientBadge } from "@/app/shared";

const certDB: Record<string, {
  id: string; status: "valid" | "expired" | "revoked";
  holder: string; course: string; instructor: string;
  specialty: string; issueDate: string; hours: number;
  format: string; accredited: boolean; accreditor?: string;
  score: number; verifiedAt: string;
}> = {
  "EJA-2025-001842": {
    id: "EJA-2025-001842", status: "valid",
    holder: "Dr. Yousef Al-Rashidi",
    course: "Comprehensive Endodontics: From Basic to Advanced",
    instructor: "Dr. Amira Soliman",
    specialty: "Endodontics",
    issueDate: "June 15, 2025",
    hours: 22, format: "Recorded Course",
    accredited: true, accreditor: "Egyptian Dental Association",
    score: 91, verifiedAt: new Date().toLocaleString(),
  },
  "EJA-2025-000731": {
    id: "EJA-2025-000731", status: "valid",
    holder: "Dr. Yousef Al-Rashidi",
    course: "Digital Smile Design Masterclass",
    instructor: "Dr. Karim Nasser",
    specialty: "Digital Dentistry",
    issueDate: "April 8, 2025",
    hours: 18, format: "Live Course",
    accredited: false,
    score: 88, verifiedAt: new Date().toLocaleString(),
  },
};

const statusConfig = {
  valid:   { color: "#2D9B68", bg: "rgba(45,155,104,0.08)",   border: "rgba(45,155,104,0.25)",   icon: <CheckCircle size={28} color="#2D9B68" />,   label: "Certificate Valid" },
  expired: { color: brand.warmGray, bg: "rgba(113,109,103,0.08)", border: "rgba(113,109,103,0.2)", icon: <AlertTriangle size={28} color={brand.warmGray} />, label: "Certificate Expired" },
  revoked: { color: brand.red, bg: "rgba(255,45,50,0.08)", border: "rgba(255,45,50,0.25)", icon: <X size={28} color={brand.red} />, label: "Certificate Revoked" },
};

function ResultCard({ cert }: { cert: typeof certDB[string] }) {
  const cfg = statusConfig[cert.status];
  return (
    <div style={{ maxWidth: 640, margin: "0 auto" }}>
      {/* Status banner */}
      <div style={{ background: cfg.bg, border: `1.5px solid ${cfg.border}`, borderRadius: 20, padding: "20px 24px", marginBottom: 20, display: "flex", gap: 14, alignItems: "center" }}>
        {cfg.icon}
        <div>
          <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 17, color: cfg.color }}>{cfg.label}</div>
          <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, marginTop: 3 }}>Verified at {cert.verifiedAt}</div>
        </div>
      </div>

      {/* Certificate display */}
      <div style={{ background: `linear-gradient(135deg, ${brand.offWhite} 0%, #fff8e8 100%)`, border: `1px solid ${brand.borderGray}`, borderRadius: 22, padding: "32px 32px", position: "relative", overflow: "hidden", marginBottom: 20 }}>
        <div style={{ position: "absolute", top: -50, right: -50, width: 180, height: 180, borderRadius: "50%", border: "16px solid rgba(255,107,26,0.06)", pointerEvents: "none" }} />
        <div style={{ position: "absolute", bottom: -30, left: -30, width: 100, height: 100, borderRadius: "50%", border: "10px solid rgba(255,198,46,0.08)", pointerEvents: "none" }} />

        {/* Header */}
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 24 }}>
          <div style={{ display: "flex", gap: 10, alignItems: "center" }}>
            <div style={{ width: 32, height: 32, borderRadius: 8, background: gradientFlow, display: "flex", alignItems: "center", justifyContent: "center" }}>
              <Award size={17} color="#fff" />
            </div>
            <div>
              <div style={{ fontFamily: "Inter", fontWeight: 800, fontSize: 12, color: brand.charcoal, letterSpacing: "0.08em" }}>EJADAH INTERNATIONAL ACADEMY</div>
              <div style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray }}>Certificate of Completion</div>
            </div>
          </div>
          <div style={{ width: 56, height: 56, background: brand.charcoal, borderRadius: 8, display: "flex", alignItems: "center", justifyContent: "center" }}>
            <QrCode size={32} color="#fff" />
          </div>
        </div>

        <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginBottom: 4 }}>This is to certify that</div>
        <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 24, color: brand.charcoal, marginBottom: 4 }}>{cert.holder}</div>
        <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginBottom: 6 }}>has successfully completed</div>
        <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal, lineHeight: 1.3, marginBottom: 20 }}>{cert.course}</div>

        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(140px, 1fr))", gap: 14, marginBottom: 24 }}>
          {[
            ["Instructor", cert.instructor],
            ["Specialty", cert.specialty],
            ["Issue Date", cert.issueDate],
            ["Format", cert.format],
            ["Duration", `${cert.hours} hours`],
            ["Score", `${cert.score}%`],
          ].map(([label, value]) => (
            <div key={label}>
              <div style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray, marginBottom: 2 }}>{label}</div>
              <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal }}>{value}</div>
            </div>
          ))}
        </div>

        {cert.accredited && (
          <div style={{ display: "flex", gap: 8, alignItems: "center", background: `${brand.amber}10`, border: `1px solid ${brand.amber}25`, borderRadius: 10, padding: "10px 14px" }}>
            <Award size={14} color={brand.amber} />
            <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal }}>Accredited by {cert.accreditor} · CPD eligible</span>
          </div>
        )}

        <div style={{ marginTop: 20, paddingTop: 16, borderTop: `1px solid ${brand.borderGray}`, fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>
          Certificate ID: <strong style={{ color: brand.charcoal }}>{cert.id}</strong> · Verify at ejadah.com/verify
        </div>
      </div>

      {/* Actions */}
      <div style={{ display: "flex", gap: 10, justifyContent: "center", flexWrap: "wrap" }}>
        <button style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "11px 20px", cursor: "pointer" }}>Download PDF</button>
        <button style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 13, color: "#0077B5", background: "rgba(0,119,181,0.07)", border: "1px solid rgba(0,119,181,0.2)", borderRadius: 10, padding: "11px 16px", cursor: "pointer", display: "flex", alignItems: "center", gap: 5 }}>
          <ExternalLink size={13} /> Share on LinkedIn
        </button>
      </div>
    </div>
  );
}

export default function CertificateVerify() {
  const { id } = useParams();
  const nav = useNavigate();
  const [inputId, setInputId] = useState(id ?? "");
  const [searched, setSearched] = useState(!!id);
  const cert = certDB[inputId];

  const handleSearch = () => { if (inputId.trim()) setSearched(true); };

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Header */}
      <div style={{ background: brand.charcoal, padding: "48px 24px 40px", textAlign: "center" as const }}>
        <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, letterSpacing: "0.1em", color: brand.amber, textTransform: "uppercase" as const, marginBottom: 10 }}>Verification</div>
        <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(24px,4vw,36px)", color: "#fff", marginBottom: 10 }}>Certificate Verification</h1>
        <p style={{ fontFamily: "Inter", fontSize: 15, color: "rgba(255,255,255,0.55)", marginBottom: 28 }}>Enter a certificate ID or scan a QR code to verify authenticity</p>

        {/* Search */}
        <div style={{ maxWidth: 480, margin: "0 auto", display: "flex", gap: 10 }}>
          <input value={inputId} onChange={(e) => setInputId(e.target.value.toUpperCase())} onKeyDown={(e) => e.key === "Enter" && handleSearch()}
            placeholder="e.g. EJA-2025-001842"
            style={{ flex: 1, fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: "#fff", border: "none", borderRadius: 12, padding: "13px 18px", outline: "none" }} />
          <button onClick={handleSearch} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "13px 20px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}>
            <Search size={15} /> Verify
          </button>
        </div>
        <div style={{ marginTop: 12, fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.4)" }}>
          Try: EJA-2025-001842 or EJA-2025-000731
        </div>
      </div>

      <div style={{ maxWidth: 900, margin: "0 auto", padding: "40px 24px" }}>
        {!searched ? (
          <div style={{ textAlign: "center" as const, padding: "40px 0" }}>
            <div style={{ width: 72, height: 72, borderRadius: 20, background: brand.white, border: `1px solid ${brand.borderGray}`, display: "flex", alignItems: "center", justifyContent: "center", margin: "0 auto 16px", boxShadow: "0 4px 16px rgba(27,27,27,0.06)" }}>
              <QrCode size={34} color={brand.orange} />
            </div>
            <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 8 }}>Enter a Certificate ID above</div>
            <div style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray }}>Or scan the QR code on any Ejadah certificate with your phone camera</div>
          </div>
        ) : cert ? (
          <ResultCard cert={cert} />
        ) : (
          <div style={{ maxWidth: 500, margin: "0 auto", textAlign: "center" as const }}>
            <div style={{ width: 72, height: 72, borderRadius: "50%", background: "rgba(255,45,50,0.08)", border: `2px solid ${brand.red}`, display: "flex", alignItems: "center", justifyContent: "center", margin: "0 auto 16px" }}>
              <X size={32} color={brand.red} />
            </div>
            <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.charcoal, marginBottom: 8 }}>Certificate Not Found</div>
            <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, lineHeight: 1.6, marginBottom: 20 }}>
              No certificate with ID <strong>{inputId}</strong> was found in our system. Please check the ID and try again. If you believe this is an error, contact support.
            </p>
            <button onClick={() => { setSearched(false); setInputId(""); }} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "11px 22px", cursor: "pointer" }}>Try Again</button>
          </div>
        )}
      </div>
    </div>
  );
}
