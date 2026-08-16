import { useState } from "react";
import { useNavigate } from "react-router";
import {
  Award, Download, Share2, QrCode, CheckCircle, ExternalLink,
  Printer, Copy, ArrowRight, Clock, BookOpen, Star,
} from "lucide-react";
import { brand, gradientFlow, GradientBadge } from "@/figma/app/shared";

const certificates = [
  {
    id: "EJA-2025-001842",
    title: "Comprehensive Endodontics: From Basic to Advanced",
    instructor: "Dr. Amira Soliman",
    specialty: "Endodontics",
    issueDate: "June 15, 2025",
    hours: 22,
    format: "Recorded Course",
    accredited: true,
    accreditor: "Egyptian Dental Association",
    cpdPoints: 22,
    status: "valid",
    score: 91,
  },
  {
    id: "EJA-2025-000731",
    title: "Digital Smile Design Masterclass",
    instructor: "Dr. Karim Nasser",
    specialty: "Digital Dentistry",
    issueDate: "April 8, 2025",
    hours: 18,
    format: "Live Course",
    accredited: false,
    accreditor: null,
    cpdPoints: 0,
    status: "valid",
    score: 88,
  },
  {
    id: "EJA-2025-000290",
    title: "Oral Surgery: Exodontia Module",
    instructor: "Dr. Hany Ibrahim",
    specialty: "Oral Surgery",
    issueDate: "February 21, 2025",
    hours: 12,
    format: "Live Course",
    accredited: true,
    accreditor: "Egyptian Dental Syndicate",
    cpdPoints: 12,
    status: "valid",
    score: 85,
  },
  {
    id: "EJA-2024-003104",
    title: "Periodontal Disease Management",
    instructor: "Dr. Rania Hassan",
    specialty: "Periodontics",
    issueDate: "November 3, 2024",
    hours: 16,
    format: "Recorded Course",
    accredited: false,
    accreditor: null,
    cpdPoints: 0,
    status: "valid",
    score: 79,
  },
  {
    id: "EJA-2024-001506",
    title: "Dental Photography Fundamentals",
    instructor: "Dr. Sara El-Sayed",
    specialty: "Dental Photography",
    issueDate: "August 14, 2024",
    hours: 8,
    format: "Recorded Course",
    accredited: false,
    accreditor: null,
    cpdPoints: 0,
    status: "valid",
    score: 95,
  },
];

const statusColors: Record<string, string> = { valid: "#2D9B68", expired: brand.warmGray, revoked: brand.red };
const statusLabels: Record<string, string> = { valid: "Valid", expired: "Expired", revoked: "Revoked" };

function CertificateCard({ cert }: { cert: typeof certificates[0] }) {
  const nav = useNavigate();
  const [copied, setCopied] = useState(false);

  const copyLink = () => {
    navigator.clipboard.writeText(`https://ejadah.com/verify/${cert.id}`);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div style={{
      background: brand.white,
      borderRadius: 22,
      border: `1px solid ${brand.borderGray}`,
      overflow: "hidden",
      boxShadow: "0 2px 12px rgba(27,27,27,0.05)",
    }}>
      {/* Certificate preview band */}
      <div style={{
        background: `linear-gradient(135deg, ${brand.offWhite} 0%, #fff8e8 100%)`,
        borderBottom: `1px solid ${brand.borderGray}`,
        padding: "24px 28px",
        position: "relative",
        overflow: "hidden",
      }}>
        {/* Decorative arc */}
        <div style={{ position: "absolute", top: -40, right: -40, width: 140, height: 140, borderRadius: "50%", border: `12px solid rgba(255,107,26,0.08)`, pointerEvents: "none" }} />
        <div style={{ position: "absolute", bottom: -20, left: -20, width: 80, height: 80, borderRadius: "50%", border: `8px solid rgba(255,198,46,0.1)`, pointerEvents: "none" }} />

        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
          <div style={{ flex: 1 }}>
            {/* Logo mark */}
            <div style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 12 }}>
              <div style={{ width: 28, height: 28, borderRadius: 7, background: gradientFlow, display: "flex", alignItems: "center", justifyContent: "center" }}>
                <Award size={15} color="#fff" />
              </div>
              <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: brand.warmGray, letterSpacing: "0.08em" }}>EJADAH INTERNATIONAL ACADEMY</span>
            </div>
            <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginBottom: 4 }}>This is to certify that</div>
            <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal, marginBottom: 8 }}>Dr. Yousef Al-Rashidi</div>
            <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginBottom: 4 }}>has successfully completed</div>
            <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 15, color: brand.charcoal, lineHeight: 1.3, maxWidth: 340 }}>{cert.title}</div>
          </div>
          {/* QR placeholder */}
          <div style={{ width: 64, height: 64, background: brand.charcoal, borderRadius: 10, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
            <QrCode size={36} color="#fff" />
          </div>
        </div>

        <div style={{ display: "flex", gap: 20, marginTop: 14, flexWrap: "wrap" }}>
          <div>
            <div style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray }}>Issued</div>
            <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal }}>{cert.issueDate}</div>
          </div>
          <div>
            <div style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray }}>Duration</div>
            <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal }}>{cert.hours} hours</div>
          </div>
          {cert.accredited && (
            <div>
              <div style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray }}>CPD Points</div>
              <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.amber }}>{cert.cpdPoints} pts</div>
            </div>
          )}
          <div style={{ marginLeft: "auto" }}>
            <div style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray }}>Status</div>
            <div style={{ display: "flex", alignItems: "center", gap: 4 }}>
              <div style={{ width: 6, height: 6, borderRadius: "50%", background: statusColors[cert.status] }} />
              <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: statusColors[cert.status] }}>{statusLabels[cert.status]}</span>
            </div>
          </div>
        </div>
      </div>

      {/* Actions */}
      <div style={{ padding: "16px 22px" }}>
        <div style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 14, flexWrap: "wrap" }}>
          <GradientBadge small>{cert.specialty}</GradientBadge>
          {cert.accredited && (
            <span style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 600, color: brand.amber, background: `${brand.amber}12`, borderRadius: 6, padding: "2px 8px", display: "flex", alignItems: "center", gap: 4 }}>
              <Award size={10} /> {cert.accreditor}
            </span>
          )}
          <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginLeft: "auto" }}>ID: {cert.id}</span>
        </div>

        <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
          <button style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: "#fff", background: gradientFlow, border: "none", borderRadius: 8, padding: "8px 14px", cursor: "pointer", display: "flex", alignItems: "center", gap: 5 }}>
            <Download size={12} /> Download PDF
          </button>
          <button onClick={copyLink} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 12, color: copied ? "#2D9B68" : brand.charcoal, background: brand.offWhite, border: `1px solid ${brand.borderGray}`, borderRadius: 8, padding: "8px 12px", cursor: "pointer", display: "flex", alignItems: "center", gap: 5 }}>
            <Copy size={12} /> {copied ? "Copied!" : "Copy Link"}
          </button>
          <button style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 12, color: "#0077B5", background: "rgba(0,119,181,0.07)", border: `1px solid rgba(0,119,181,0.2)`, borderRadius: 8, padding: "8px 12px", cursor: "pointer", display: "flex", alignItems: "center", gap: 5 }}>
            <ExternalLink size={12} /> LinkedIn
          </button>
          <button onClick={() => nav(`/verify/${cert.id}`)} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 12, color: brand.warmGray, background: "none", border: `1px solid ${brand.borderGray}`, borderRadius: 8, padding: "8px 12px", cursor: "pointer", display: "flex", alignItems: "center", gap: 5 }}>
            <CheckCircle size={12} /> Verify
          </button>
          <button style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 12, color: brand.warmGray, background: "none", border: `1px solid ${brand.borderGray}`, borderRadius: 8, padding: "8px 12px", cursor: "pointer", display: "flex", alignItems: "center", gap: 5 }}>
            <Printer size={12} /> Print
          </button>
        </div>
      </div>
    </div>
  );
}

export default function Certificates() {
  const [filter, setFilter] = useState<"all" | "accredited">("all");
  const totalCPD = certificates.filter((c) => c.accredited).reduce((a, c) => a + c.cpdPoints, 0);
  const filtered = filter === "accredited" ? certificates.filter((c) => c.accredited) : certificates;

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Header */}
      <div style={{ background: brand.charcoal, padding: "48px 24px 40px" }}>
        <div style={{ maxWidth: 1100, margin: "0 auto" }}>
          <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, letterSpacing: "0.1em", color: brand.amber, textTransform: "uppercase" as const, marginBottom: 10 }}>My Learning</div>
          <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(26px,4vw,38px)", color: "#fff", marginBottom: 10 }}>Certificate Center</h1>
          <p style={{ fontFamily: "Inter", fontSize: 15, color: "rgba(255,255,255,0.55)", maxWidth: 480, marginBottom: 28 }}>All your Ejadah certificates in one place — download, share, and verify.</p>
          {/* Stats */}
          <div style={{ display: "flex", gap: 28, flexWrap: "wrap" }}>
            {[
              { v: String(certificates.length), l: "Certificates Earned", c: brand.gold },
              { v: String(certificates.filter((c) => c.accredited).length), l: "Accredited", c: brand.amber },
              { v: `${totalCPD} pts`, l: "Total CPD Points", c: brand.orange },
              { v: `${Math.round(certificates.reduce((a, c) => a + c.hours, 0))}h`, l: "Total Learning Hours", c: brand.gold },
            ].map((s) => (
              <div key={s.l}>
                <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 24, color: s.c }}>{s.v}</div>
                <div style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.45)", marginTop: 2 }}>{s.l}</div>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div style={{ maxWidth: 1100, margin: "0 auto", padding: "32px 24px" }}>
        {/* Filter */}
        <div style={{ display: "flex", gap: 10, marginBottom: 24, alignItems: "center" }}>
          {[["all", "All Certificates"], ["accredited", "Accredited Only"]].map(([v, l]) => (
            <button key={v} onClick={() => setFilter(v as "all" | "accredited")} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 13, color: filter === v ? "#fff" : brand.charcoal, background: filter === v ? gradientFlow : brand.white, border: `1.5px solid ${filter === v ? "transparent" : brand.borderGray}`, borderRadius: 10, padding: "7px 16px", cursor: "pointer", transition: "all 0.15s" }}>{l as string}</button>
          ))}
          <div style={{ marginLeft: "auto", fontFamily: "Inter", fontSize: 13, color: brand.warmGray }}>{filtered.length} certificate{filtered.length !== 1 ? "s" : ""}</div>
        </div>

        {/* Certificate cards */}
        <div style={{ display: "flex", flexDirection: "column" as const, gap: 20 }}>
          {filtered.map((cert) => <CertificateCard key={cert.id} cert={cert} />)}
        </div>

        {/* LinkedIn import CTA */}
        <div style={{ marginTop: 40, background: "rgba(0,119,181,0.06)", border: "1px solid rgba(0,119,181,0.15)", borderRadius: 20, padding: "24px 28px", display: "flex", gap: 20, alignItems: "center", flexWrap: "wrap" }}>
          <div style={{ flex: 1 }}>
            <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: brand.charcoal, marginBottom: 4 }}>Add to LinkedIn Profile</div>
            <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray }}>Share your Ejadah certificates directly to your LinkedIn profile with one click. Verified and timestamped.</div>
          </div>
          <button style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: "#fff", background: "#0077B5", border: "none", borderRadius: 10, padding: "11px 20px", cursor: "pointer", flexShrink: 0 }}>
            Connect LinkedIn
          </button>
        </div>
      </div>
    </div>
  );
}
