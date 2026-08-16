import { useState } from "react";
import { useNavigate, useParams } from "react-router";
import {
  ChevronLeft, Bookmark, Share2, Copy, ExternalLink,
  CheckCircle, AlertTriangle, Zap, MessageSquare, BookOpen,
} from "lucide-react";
import { brand, gradientFlow, GradientBadge } from "@/figma/app/shared";

const papers: Record<string, any> = {
  "1": {
    id: "1", title: "Efficacy of Sodium Hypochlorite Concentration in Root Canal Disinfection: A Systematic Review and Meta-Analysis",
    journal: "Journal of Endodontics", volume: "51(3)", pages: "318–332",
    authors: "Zehnder M, Belibasakis G, Abou-Rass M", date: "March 2025",
    specialty: "Endodontics", studyType: "Systematic Review", evidenceLevel: "1a",
    doi: "10.1016/j.joen.2025.01.004", clinicalRelevance: "High",
    abstract: "This systematic review with meta-analysis evaluated the antimicrobial efficacy of different sodium hypochlorite (NaOCl) concentrations (0.5%–5.25%) in root canal disinfection across 42 randomised controlled trials published between 2000 and 2024. Primary outcomes included bacterial count reduction, clinical success rates, and cytotoxicity profiles.\n\nInclusion criteria required in vitro or in vivo studies with standardised microbiological sampling at baseline and after irrigation. Risk of bias was assessed using the Cochrane Risk of Bias tool (RoB 2) for RCTs and ROBIS for systematic reviews.",
    keyFindings: [
      "Warmed 2.5% NaOCl (37°C) demonstrated equivalent antimicrobial efficacy to 5.25% NaOCl at room temperature",
      "Temperature increase from 20°C to 37°C effectively doubled the antimicrobial activity of all tested concentrations",
      "No statistically significant difference in 2-year clinical success rates between 1–5.25% NaOCl",
      "Cytotoxicity risk was significantly lower at concentrations ≤2.5%, particularly relevant for open apex cases",
      "Passive Ultrasonic Irrigation (PUI) significantly enhanced efficacy of all concentrations tested",
    ],
    strengths: ["Large sample size (42 RCTs, n=4,284 patients)", "Robust risk-of-bias assessment", "Clinically relevant outcome measures"],
    limitations: ["Heterogeneity in microbiological sampling methods", "Variable follow-up periods across studies", "Limited high-quality evidence for concentrations <1%"],
    clinicalImplications: "Clinicians can safely use 2.5% NaOCl warmed to 37°C as their standard irrigant, achieving similar antimicrobial efficacy to higher concentrations with reduced risk of periapical extrusion injury. The routine use of 5.25% NaOCl can be reserved for complex cases with necrotic pulp and mature apical foramen.",
    references: ["Zehnder M. Root canal irrigants. J Endod. 2006;32:389-398", "Gomes BPFA et al. In vitro antimicrobial activity of several concentrations of sodium hypochlorite. Int Endod J. 2001;34:294-300"],
  },
  "2": {
    id: "2", title: "Short-Term Implant Survival Rates in Patients with Controlled Type 2 Diabetes: A 5-Year Prospective Cohort Study",
    journal: "Clinical Oral Implants Research", volume: "36(2)", pages: "145–162",
    authors: "Tarnow D, Elian N, Fletcher P, Magner A", date: "February 2025",
    specialty: "Implantology", studyType: "Prospective Cohort", evidenceLevel: "2b",
    doi: "10.1111/clr.14129", clinicalRelevance: "High",
    abstract: "A 5-year prospective cohort study enrolled 118 patients with well-controlled Type 2 diabetes (HbA1c <7.5%) receiving 286 dental implants, matched to a non-diabetic control group (n=118, 290 implants). All implants were placed by a single experienced surgeon following standardised protocol. Primary outcome was implant survival at 5 years; secondary outcomes included marginal bone loss, peri-implant health, and patient-reported outcomes.",
    keyFindings: [
      "Overall 5-year survival rate: 96.2% in controlled diabetics vs 97.8% in matched non-diabetic controls",
      "Difference not statistically significant (p=0.31)",
      "Marginal bone loss at 5 years: 0.8mm (diabetics) vs 0.5mm (controls) — statistically significant",
      "HbA1c <7.5% appears to be a safe threshold for implant placement",
      "Peri-implantitis incidence: 8.4% in diabetics vs 5.2% in controls",
    ],
    strengths: ["Prospective design with matched controls", "Single surgeon eliminating operator variability", "5-year follow-up with only 6% dropout"],
    limitations: ["Single-centre study", "All patients had well-controlled diabetes — cannot extrapolate to poorly controlled patients", "Sample size may be underpowered for secondary outcomes"],
    clinicalImplications: "Dental implants can be placed safely in patients with well-controlled Type 2 diabetes (HbA1c <7.5%). Slightly higher marginal bone loss warrants more frequent monitoring intervals (3–4 months rather than 6 months). Poorly controlled diabetics (HbA1c >8.5%) should not be included based on existing evidence.",
    references: ["Oates TW et al. Glycemic control and implant stabilization in type 2 diabetes mellitus. J Dent Res. 2009;88:367-371"],
  },
};

export default function ResearchDetails() {
  const { id } = useParams();
  const nav = useNavigate();
  const paper = papers[id ?? "1"] ?? papers["1"];
  const [saved, setSaved] = useState(false);
  const [copied, setCopied] = useState(false);

  const copyDoi = () => { navigator.clipboard.writeText(`https://doi.org/${paper.doi}`); setCopied(true); setTimeout(() => setCopied(false), 2000); };

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Top bar */}
      <div style={{ background: brand.white, borderBottom: `1px solid ${brand.borderGray}`, position: "sticky", top: 0, zIndex: 50 }}>
        <div style={{ maxWidth: 1000, margin: "0 auto", padding: "0 24px", height: 52, display: "flex", alignItems: "center", gap: 14 }}>
          <button onClick={() => nav("/research")} style={{ background: "none", border: "none", cursor: "pointer", color: brand.warmGray, display: "flex", alignItems: "center", gap: 5, fontFamily: "Inter", fontSize: 13 }}>
            <ChevronLeft size={15} /> Research Hub
          </button>
          <div style={{ flex: 1 }} />
          <button onClick={() => setSaved(!saved)} style={{ background: "none", border: "none", cursor: "pointer", color: saved ? brand.amber : brand.warmGray }}><Bookmark size={18} fill={saved ? brand.amber : "none"} /></button>
          <button onClick={copyDoi} style={{ background: "none", border: `1px solid ${brand.borderGray}`, borderRadius: 8, padding: "6px 12px", cursor: "pointer", fontFamily: "Inter", fontSize: 12, color: copied ? "#2D9B68" : brand.charcoal, display: "flex", alignItems: "center", gap: 5 }}>
            <Copy size={12} /> {copied ? "Copied!" : "Copy DOI"}
          </button>
          <button style={{ background: "none", border: `1px solid ${brand.borderGray}`, borderRadius: 8, padding: "6px 12px", cursor: "pointer", fontFamily: "Inter", fontSize: 12, color: brand.charcoal, display: "flex", alignItems: "center", gap: 5 }}>
            <ExternalLink size={12} /> Full Text
          </button>
        </div>
      </div>

      <div style={{ maxWidth: 1000, margin: "0 auto", padding: "36px 24px" }}>
        <div style={{ display: "flex", gap: 28, flexWrap: "wrap" }}>
          {/* Main content */}
          <div style={{ flex: 1, minWidth: 300 }}>
            {/* Header */}
            <div style={{ marginBottom: 28 }}>
              <div style={{ display: "flex", gap: 8, flexWrap: "wrap", marginBottom: 14 }}>
                <GradientBadge small>{paper.specialty}</GradientBadge>
                <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, background: brand.paleGray, borderRadius: 5, padding: "2px 8px" }}>{paper.studyType}</span>
                <span style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 700, color: "#2D9B68", background: "rgba(45,155,104,0.08)", borderRadius: 5, padding: "2px 8px" }}>Evidence Level {paper.evidenceLevel}</span>
                <span style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 600, color: "#2D9B68", background: "rgba(45,155,104,0.08)", borderRadius: 5, padding: "2px 8px" }}>{paper.clinicalRelevance} Clinical Relevance</span>
              </div>
              <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(20px,3vw,28px)", color: brand.charcoal, lineHeight: 1.3, marginBottom: 10 }}>{paper.title}</h1>
              <div style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, marginBottom: 4 }}>{paper.authors}</div>
              <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray }}>
                <em>{paper.journal}</em> · Vol. {paper.volume} · pp. {paper.pages} · {paper.date}
              </div>
            </div>

            {/* AI Key Findings */}
            <div style={{ background: `linear-gradient(135deg, rgba(255,107,26,0.06), rgba(255,198,46,0.06))`, border: `1px solid rgba(255,107,26,0.18)`, borderRadius: 18, padding: "20px 22px", marginBottom: 20 }}>
              <div style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 14 }}>
                <Zap size={15} color={brand.orange} />
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.orange }}>AI-Generated Key Findings</div>
                <div style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray, background: brand.paleGray, borderRadius: 4, padding: "2px 6px" }}>Verified against full text</div>
              </div>
              {paper.keyFindings.map((f: string, i: number) => (
                <div key={i} style={{ display: "flex", gap: 10, marginBottom: 10, alignItems: "flex-start" }}>
                  <div style={{ width: 20, height: 20, borderRadius: "50%", background: gradientFlow, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0, marginTop: 1 }}>
                    <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 9, color: "#fff" }}>{i + 1}</span>
                  </div>
                  <span style={{ fontFamily: "Inter", fontSize: 14, color: brand.charcoal, lineHeight: 1.6 }}>{f}</span>
                </div>
              ))}
            </div>

            {/* Abstract */}
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px 26px", marginBottom: 18 }}>
              <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 14 }}>Abstract</h2>
              {paper.abstract.split("\n\n").map((para: string, i: number) => (
                <p key={i} style={{ fontFamily: "Inter", fontSize: 14, color: brand.charcoal, lineHeight: 1.75, marginBottom: 12 }}>{para}</p>
              ))}
            </div>

            {/* Clinical implications */}
            <div style={{ background: "rgba(45,155,104,0.05)", border: `1px solid rgba(45,155,104,0.2)`, borderRadius: 18, padding: "20px 22px", marginBottom: 18 }}>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#2D9B68", marginBottom: 10 }}>🏥 Clinical Implications for Practice</div>
              <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.charcoal, lineHeight: 1.7 }}>{paper.clinicalImplications}</p>
            </div>

            {/* Strengths & Limitations */}
            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 14, marginBottom: 18 }}>
              <div style={{ background: brand.white, borderRadius: 16, border: `1px solid ${brand.borderGray}`, padding: "18px 18px" }}>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: "#2D9B68", marginBottom: 10 }}>✓ Strengths</div>
                {paper.strengths.map((s: string, i: number) => (
                  <div key={i} style={{ display: "flex", gap: 7, fontFamily: "Inter", fontSize: 12, color: brand.charcoal, lineHeight: 1.5, marginBottom: 7 }}>
                    <CheckCircle size={11} color="#2D9B68" style={{ flexShrink: 0, marginTop: 2 }} />{s}
                  </div>
                ))}
              </div>
              <div style={{ background: brand.white, borderRadius: 16, border: `1px solid ${brand.borderGray}`, padding: "18px 18px" }}>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.amber, marginBottom: 10 }}>⚠ Limitations</div>
                {paper.limitations.map((l: string, i: number) => (
                  <div key={i} style={{ display: "flex", gap: 7, fontFamily: "Inter", fontSize: 12, color: brand.charcoal, lineHeight: 1.5, marginBottom: 7 }}>
                    <AlertTriangle size={11} color={brand.amber} style={{ flexShrink: 0, marginTop: 2 }} />{l}
                  </div>
                ))}
              </div>
            </div>

            {/* References */}
            <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "20px 22px" }}>
              <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal, marginBottom: 12 }}>Key References</h2>
              {paper.references.map((ref: string, i: number) => (
                <div key={i} style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, fontStyle: "italic", lineHeight: 1.55, marginBottom: 8, paddingLeft: 14, borderLeft: `2px solid ${brand.borderGray}` }}>{ref}</div>
              ))}
            </div>
          </div>

          {/* Sidebar */}
          <div style={{ width: 260, flexShrink: 0 }}>
            <div style={{ position: "sticky", top: 68, display: "flex", flexDirection: "column" as const, gap: 14 }}>
              <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "18px" }}>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal, marginBottom: 12 }}>Article Details</div>
                {[["DOI", paper.doi], ["Journal", paper.journal], ["Date", paper.date], ["Study Type", paper.studyType], ["Evidence Level", paper.evidenceLevel]].map(([l, v]) => (
                  <div key={l as string} style={{ display: "flex", flexDirection: "column" as const, marginBottom: 10 }}>
                    <span style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em" }}>{l as string}</span>
                    <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal, marginTop: 2 }}>{v as string}</span>
                  </div>
                ))}
              </div>
              <div style={{ background: brand.charcoal, borderRadius: 16, padding: "16px" }}>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff", marginBottom: 8 }}>Generate Flashcards</div>
                <p style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.55)", lineHeight: 1.5, marginBottom: 12 }}>Let Ejadah AI turn the key findings into study flashcards.</p>
                <button style={{ width: "100%", fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: "#fff", background: gradientFlow, border: "none", borderRadius: 8, padding: "9px", cursor: "pointer" }}>Create Flashcards</button>
              </div>
              <button onClick={() => nav("/research")} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 13, color: brand.orange, background: "rgba(255,107,26,0.07)", border: "none", borderRadius: 12, padding: "11px", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 6 }}>
                <BookOpen size={14} /> More Research
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
