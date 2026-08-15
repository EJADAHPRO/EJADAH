import { useNavigate } from "react-router";
import { CheckCircle, X, ArrowRight, ExternalLink } from "lucide-react";
import { brand, gradientFlow, GradientBadge } from "@/app/shared";

const programs = [
  { id: "1", university: "King's College London", country: "🇬🇧 UK", specialty: "Endodontics", degree: "MSc", duration: "1 year FT", tuition: "£26,000/yr", language: "English", deadline: "Jan 31, 2026", scholarship: true, recognizedEgypt: true, ranking: 8, clinical: true, partTime: true, fullTime: true },
  { id: "2", university: "University of Melbourne", country: "🇦🇺 Australia", specialty: "Implantology", degree: "MClinDent", duration: "2 years FT", tuition: "AUD 55,000/yr", language: "English", deadline: "Aug 15, 2025", scholarship: false, recognizedEgypt: true, ranking: 14, clinical: true, partTime: false, fullTime: true },
  { id: "3", university: "University of Cologne", country: "🇩🇪 Germany", specialty: "Orthodontics", degree: "MSc", duration: "2 years PT", tuition: "€3,800/yr", language: "German/English", deadline: "Mar 1, 2026", scholarship: true, recognizedEgypt: true, ranking: 22, clinical: true, partTime: true, fullTime: false },
];

const compRows = [
  { label: "Country", key: "country" },
  { label: "Specialty", key: "specialty" },
  { label: "Degree", key: "degree" },
  { label: "Duration", key: "duration" },
  { label: "Tuition", key: "tuition" },
  { label: "Language", key: "language" },
  { label: "Application Deadline", key: "deadline" },
  { label: "World Ranking", key: (p: any) => `#${p.ranking}` },
  { label: "Scholarship Available", key: (p: any) => p.scholarship },
  { label: "Recognised in Egypt", key: (p: any) => p.recognizedEgypt },
  { label: "Clinical Training", key: (p: any) => p.clinical },
  { label: "Part-Time Option", key: (p: any) => p.partTime },
  { label: "Full-Time", key: (p: any) => p.fullTime },
];

export default function ProgramComparison() {
  const nav = useNavigate();

  const renderCell = (val: any) => {
    if (typeof val === "boolean") return val ? <CheckCircle size={18} color="#2D9B68" /> : <X size={18} color={brand.borderGray} />;
    return <span style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 13, color: brand.charcoal }}>{String(val)}</span>;
  };

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      <div style={{ background: brand.charcoal, padding: "40px 24px 32px" }}>
        <div style={{ maxWidth: 1100, margin: "0 auto", display: "flex", justifyContent: "space-between", alignItems: "center", flexWrap: "wrap", gap: 12 }}>
          <div>
            <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 28, color: "#fff", marginBottom: 4 }}>Program Comparison</h1>
            <p style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.5)" }}>Comparing {programs.length} postgraduate dental programs</p>
          </div>
          <button onClick={() => nav("/masters")} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 13, color: "rgba(255,255,255,0.7)", background: "rgba(255,255,255,0.08)", border: "none", borderRadius: 10, padding: "10px 16px", cursor: "pointer" }}>+ Add Program</button>
        </div>
      </div>

      <div style={{ maxWidth: 1100, margin: "0 auto", padding: "32px 24px", overflowX: "auto" }}>
        <table style={{ width: "100%", borderCollapse: "collapse" as const, minWidth: 700 }}>
          {/* Program headers */}
          <thead>
            <tr>
              <th style={{ width: 200, padding: "0 16px 20px 0", textAlign: "left" as const }}>
                <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.warmGray }}>Criteria</div>
              </th>
              {programs.map((p) => (
                <th key={p.id} style={{ padding: "0 16px 20px", verticalAlign: "top", textAlign: "center" as const }}>
                  <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "18px 16px", boxShadow: "0 2px 10px rgba(27,27,27,0.05)" }}>
                    <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal, marginBottom: 4 }}>{p.university}</div>
                    <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginBottom: 10 }}>{p.country}</div>
                    <GradientBadge small>{p.specialty}</GradientBadge>
                    <div style={{ display: "flex", gap: 8, marginTop: 12, justifyContent: "center" }}>
                      <button onClick={() => nav(`/masters/${p.id}`)} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: "#fff", background: gradientFlow, border: "none", borderRadius: 8, padding: "6px 12px", cursor: "pointer" }}>Details</button>
                      <button style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 11, color: brand.charcoal, background: brand.offWhite, border: `1px solid ${brand.borderGray}`, borderRadius: 8, padding: "6px 10px", cursor: "pointer" }}><ExternalLink size={11} /></button>
                    </div>
                  </div>
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {compRows.map((row, ri) => (
              <tr key={row.label} style={{ background: ri % 2 === 0 ? brand.white : brand.offWhite }}>
                <td style={{ padding: "14px 16px 14px 0", borderBottom: `1px solid ${brand.borderGray}` }}>
                  <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal }}>{row.label}</span>
                </td>
                {programs.map((p) => {
                  const val = typeof row.key === "function" ? row.key(p) : (p as any)[row.key];
                  return (
                    <td key={p.id} style={{ padding: "14px 16px", textAlign: "center" as const, borderBottom: `1px solid ${brand.borderGray}` }}>
                      {renderCell(val)}
                    </td>
                  );
                })}
              </tr>
            ))}
          </tbody>
        </table>

        {/* Action row */}
        <div style={{ marginTop: 28, display: "flex", gap: 14, justifyContent: "center", flexWrap: "wrap" }}>
          {programs.map((p) => (
            <button key={p.id} onClick={() => nav(`/masters/${p.id}`)} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "12px 24px", cursor: "pointer", display: "flex", alignItems: "center", gap: 8 }}>
              {p.university.split(" ").slice(-1)} — Apply <ArrowRight size={14} />
            </button>
          ))}
        </div>

        <div style={{ marginTop: 24, textAlign: "center" as const }}>
          <button onClick={() => nav("/masters")} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 13, color: brand.orange, background: "none", border: "none", cursor: "pointer" }}>← Back to Master's Database</button>
        </div>
      </div>
    </div>
  );
}
