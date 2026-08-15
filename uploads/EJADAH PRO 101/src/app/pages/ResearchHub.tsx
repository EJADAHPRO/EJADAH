import { useState } from "react";
import { useNavigate } from "react-router";
import {
  Search, Filter, BookOpen, Calendar, Star, Bookmark,
  ChevronRight, Bell, TrendingUp, Users, FileText, Zap,
} from "lucide-react";
import { brand, gradientFlow, GradientBadge, SectionHeader } from "@/app/shared";

const papers = [
  { id: "1", title: "Efficacy of Sodium Hypochlorite Concentration in Root Canal Disinfection: A Systematic Review and Meta-Analysis", journal: "Journal of Endodontics", authors: "Zehnder M, Belibasakis G, Abou-Rass M", date: "March 2025", specialty: "Endodontics", studyType: "Systematic Review", evidenceLevel: "1a", doi: "10.1016/j.joen.2025.01.004", clinicalRelevance: "High", saved: false, abstract: "This systematic review evaluated the antimicrobial efficacy of different NaOCl concentrations (0.5%–5.25%) in root canal disinfection across 42 randomised controlled trials. Results indicate that 2.5% NaOCl warmed to 37°C provides equivalent antimicrobial efficacy to 5.25% at room temperature, with significantly reduced cytotoxicity.", keyFindings: ["Warmed 2.5% NaOCl = 5.25% NaOCl efficacy", "Temperature increase from 20°C to 37°C doubles antimicrobial activity", "No significant difference in clinical outcomes between concentrations", "Cytotoxicity risk significantly lower at 1–2.5% concentrations"] },
  { id: "2", title: "Short-Term Implant Survival Rates in Patients with Controlled Type 2 Diabetes: A 5-Year Prospective Cohort Study", journal: "Clinical Oral Implants Research", authors: "Tarnow D, Elian N, Fletcher P, Magner A", date: "February 2025", specialty: "Implantology", studyType: "Prospective Cohort", evidenceLevel: "2b", doi: "10.1111/clr.14129", clinicalRelevance: "High", saved: true, abstract: "A 5-year prospective study of 286 implants placed in 118 patients with well-controlled Type 2 diabetes (HbA1c <7.5%). Overall survival rate was 96.2%, compared to 97.8% in a matched non-diabetic cohort. Marginal bone loss was slightly higher in diabetic patients (0.8mm vs 0.5mm at 5 years).", keyFindings: ["96.2% survival rate in well-controlled diabetics", "No statistically significant difference vs controls", "HbA1c <7.5% appears to be safe threshold for implant placement", "Marginal bone loss slightly elevated — monitor carefully"] },
  { id: "3", title: "Efficacy of Non-Surgical Periodontal Therapy in Stage III–IV Periodontitis: Updated Systematic Review 2025", journal: "Journal of Clinical Periodontology", authors: "Sanz M, Herrera D, Kebschull M, Chapple I", date: "January 2025", specialty: "Periodontics", studyType: "Systematic Review", evidenceLevel: "1a", doi: "10.1111/jcpe.13940", clinicalRelevance: "High", saved: false, abstract: "Updated systematic review incorporating 28 new RCTs published since the 2022 EFP guidelines. Non-surgical therapy remains the cornerstone of periodontal management, with adjunctive systemic antibiotics providing additional benefit in Stage III–IV generalised periodontitis.", keyFindings: ["Adjunctive antibiotics provide 0.5–1mm additional PPD reduction", "Amoxicillin + metronidazole remains most effective regimen", "Systemic antibiotics should be reserved for Stage III–IV generalised disease", "Full-mouth disinfection shows no benefit over quadrant scaling"] },
  { id: "4", title: "Digital vs Conventional Impression Accuracy for Full-Arch Fixed Dental Prostheses: RCT", journal: "Journal of Prosthetic Dentistry", authors: "Chochlidakis K, Papaspyridakos P, Geminiani A, Chen CJ", date: "December 2024", specialty: "Prosthodontics", studyType: "RCT", evidenceLevel: "1b", doi: "10.1016/j.prosdent.2024.11.003", clinicalRelevance: "Medium", saved: false, abstract: "Randomised controlled trial comparing intraoral scanning (iOS) versus conventional polyvinylsiloxane (PVS) impressions for full-arch fixed dental prostheses. Digital impressions showed superior patient satisfaction and comparable accuracy for short-span FDPs, but conventional impressions remained more accurate for full-arch reconstructions.", keyFindings: ["iOS comparable accuracy for ≤4-unit FDPs", "Conventional impressions still superior for full-arch", "Patient satisfaction significantly higher with digital", "Workflow time reduced by 42% with digital impressions"] },
  { id: "5", title: "Fluoride Varnish Frequency and Caries Prevention in High-Risk Children: A Cochrane Review Update", journal: "Cochrane Database of Systematic Reviews", authors: "Marinho VCC, Chong LY, Worthington HV, Walsh T", date: "November 2024", specialty: "Pedodontics", studyType: "Cochrane Review", evidenceLevel: "1a", doi: "10.1002/14651858.CD002279.pub4", clinicalRelevance: "High", saved: false, abstract: "Updated Cochrane review of 22 studies (n=12,800 children) evaluating fluoride varnish application frequency. Results confirm that 2–4 applications/year significantly reduce caries incidence in both primary and permanent teeth. No clear evidence that >4 applications/year provides additional benefit.", keyFindings: ["2–4 applications/year reduces caries by 37% in primary teeth", "43% reduction in permanent teeth caries", "No additional benefit beyond 4 applications/year", "Most effective in high fluorosis-risk communities when used at 2.2% NaF"] },
  { id: "6", title: "Accuracy of CBCT vs Periapical Radiography in Detecting Periapical Pathology: Updated Meta-Analysis", journal: "International Endodontic Journal", authors: "Estrela C, Bueno MR, Azevedo BC, Azevedo JR, Pécora JD", date: "October 2024", specialty: "Endodontics", studyType: "Meta-Analysis", evidenceLevel: "1a", doi: "10.1111/iej.14089", clinicalRelevance: "High", saved: false, abstract: "Meta-analysis of 31 studies comparing CBCT and periapical radiography in periapical lesion detection. CBCT demonstrated 89% sensitivity vs 73% for periapical radiography, with specificity of 93% vs 85%. CBCT particularly superior in maxillary molars and teeth with dense cortical bone.", keyFindings: ["CBCT sensitivity 89% vs 73% for periapical X-ray", "CBCT superior in maxillary posterior region", "Additional radiation exposure from CBCT must be justified", "CBCT recommended when standard radiography is inconclusive"] },
];

const specialties = [
  "All Specialties", "Oral Biology & Histology", "Pharmacology", "Dental Biomaterials", "Operative Dentistry",
  "Endodontics", "Fixed Prosthodontics", "Removable Prosthodontics", "Periodontology & Oral Medicine",
  "Oral Radiology", "Oral Pathology", "Oral & Maxillofacial Surgery", "Orthodontics",
  "Pediatric Dentistry", "Implant Dentistry", "Aesthetic Dentistry", "Digital Dentistry",
];
const studyTypes = ["All Types", "Systematic Review", "RCT", "Cohort Study", "Meta-Analysis", "Case Series"];
const evidenceLevels = ["All Levels", "1a — Systematic Reviews", "1b — RCTs", "2b — Cohort Studies"];

const relevanceColor: Record<string, string> = { High: "#2D9B68", Medium: brand.amber, Low: brand.warmGray };

export default function ResearchHub() {
  const nav = useNavigate();
  const [search, setSearch] = useState("");
  const [specialty, setSpecialty] = useState("All Specialties");
  const [studyType, setStudyType] = useState("All Types");
  const [savedOnly, setSavedOnly] = useState(false);
  const [savedPapers, setSavedPapers] = useState<string[]>(["2"]);

  const filtered = papers.filter((p) => {
    const matchSearch = p.title.toLowerCase().includes(search.toLowerCase()) || p.authors.toLowerCase().includes(search.toLowerCase());
    const matchSpec = specialty === "All Specialties" || p.specialty === specialty;
    const matchType = studyType === "All Types" || p.studyType.includes(studyType.split(" ")[0]);
    const matchSaved = !savedOnly || savedPapers.includes(p.id);
    return matchSearch && matchSpec && matchType && matchSaved;
  });

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Header */}
      <div style={{ background: brand.charcoal, padding: "56px 24px 48px", position: "relative", overflow: "hidden" }}>
        <div style={{ position: "absolute", inset: 0, background: "radial-gradient(ellipse at 70% 40%, rgba(255,107,26,0.07) 0%, transparent 55%)", pointerEvents: "none" }} />
        <div style={{ maxWidth: 1280, margin: "0 auto", position: "relative" }}>
          <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, letterSpacing: "0.1em", color: brand.amber, textTransform: "uppercase" as const, marginBottom: 10 }}>Knowledge</div>
          <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(28px,4vw,42px)", color: "#fff", marginBottom: 12 }}>Dental Research Hub</h1>
          <p style={{ fontFamily: "Inter", fontSize: 16, color: "rgba(255,255,255,0.6)", maxWidth: 520, marginBottom: 28 }}>
            Curated, clinically relevant dental research — AI-summarised, evidence-graded, and updated weekly across all dental specialties.
          </p>
          <div style={{ position: "relative", maxWidth: 560 }}>
            <Search size={16} style={{ position: "absolute", left: 14, top: "50%", transform: "translateY(-50%)", color: "rgba(255,255,255,0.4)" }} />
            <input value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Search titles, authors, journals…"
              style={{ width: "100%", fontFamily: "Inter", fontSize: 14, background: "rgba(255,255,255,0.1)", border: "1px solid rgba(255,255,255,0.15)", borderRadius: 12, padding: "13px 16px 13px 42px", color: "#fff", outline: "none", boxSizing: "border-box" as const }} />
          </div>
          <div style={{ display: "flex", gap: 28, marginTop: 24, flexWrap: "wrap" }}>
            {[["Weekly", "New papers added"], ["6 Specialties", "Covered"], ["AI Summaries", "Every paper"], ["Evidence Graded", "All studies"]].map(([v, l]) => (
              <div key={l}><div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: brand.gold }}>{v}</div><div style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.45)", marginTop: 2 }}>{l}</div></div>
            ))}
          </div>
        </div>
      </div>

      <div style={{ maxWidth: 1280, margin: "0 auto", padding: "32px 24px" }}>
        {/* Filters */}
        <div style={{ background: brand.white, borderRadius: 16, border: `1px solid ${brand.borderGray}`, padding: "16px 20px", marginBottom: 28, display: "flex", gap: 12, flexWrap: "wrap", alignItems: "center" }}>
          <Filter size={14} color={brand.warmGray} />
          <select value={specialty} onChange={(e) => setSpecialty(e.target.value)} style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${specialty !== "All Specialties" ? brand.orange : brand.borderGray}`, borderRadius: 10, padding: "7px 12px", outline: "none", appearance: "none" as const }}>
            {specialties.map((s) => <option key={s}>{s}</option>)}
          </select>
          <select value={studyType} onChange={(e) => setStudyType(e.target.value)} style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${studyType !== "All Types" ? brand.orange : brand.borderGray}`, borderRadius: 10, padding: "7px 12px", outline: "none", appearance: "none" as const }}>
            {studyTypes.map((s) => <option key={s}>{s}</option>)}
          </select>
          <button onClick={() => setSavedOnly(!savedOnly)} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 12, color: savedOnly ? brand.orange : brand.charcoal, background: savedOnly ? "rgba(255,107,26,0.08)" : brand.offWhite, border: `1.5px solid ${savedOnly ? brand.orange : brand.borderGray}`, borderRadius: 10, padding: "7px 14px", cursor: "pointer" }}>
            <Bookmark size={12} style={{ marginRight: 5, verticalAlign: "middle" }} />Saved Only
          </button>
          <div style={{ marginLeft: "auto", fontFamily: "Inter", fontSize: 13, color: brand.warmGray }}>{filtered.length} papers</div>
        </div>

        <div style={{ display: "flex", gap: 24, flexWrap: "wrap" }}>
          {/* Paper list */}
          <div style={{ flex: 1, minWidth: 300 }}>
            <SectionHeader label="Latest" title="Recent Research" />
            <div style={{ display: "flex", flexDirection: "column" as const, gap: 16 }}>
              {filtered.map((paper) => {
                const isSaved = savedPapers.includes(paper.id);
                return (
                  <div key={paper.id} style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "22px 24px", cursor: "pointer", transition: "transform 0.2s, box-shadow 0.2s" }}
                    onMouseEnter={(e) => { (e.currentTarget as HTMLElement).style.transform = "translateY(-2px)"; (e.currentTarget as HTMLElement).style.boxShadow = "0 6px 20px rgba(27,27,27,0.08)"; }}
                    onMouseLeave={(e) => { (e.currentTarget as HTMLElement).style.transform = "none"; (e.currentTarget as HTMLElement).style.boxShadow = "none"; }}
                    onClick={() => nav(`/research/${paper.id}`)}
                  >
                    {/* Meta row */}
                    <div style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 10, flexWrap: "wrap" }}>
                      <GradientBadge small>{paper.specialty}</GradientBadge>
                      <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, background: brand.paleGray, borderRadius: 5, padding: "2px 8px" }}>{paper.studyType}</span>
                      <span style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 700, color: "#2D9B68", background: "rgba(45,155,104,0.08)", borderRadius: 5, padding: "2px 8px" }}>Level {paper.evidenceLevel}</span>
                      <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, display: "flex", alignItems: "center", gap: 4 }}><Calendar size={10} /> {paper.date}</span>
                      <span style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 600, color: relevanceColor[paper.clinicalRelevance], background: `${relevanceColor[paper.clinicalRelevance]}10`, borderRadius: 5, padding: "2px 8px" }}>{paper.clinicalRelevance} Relevance</span>
                      <button onClick={(e) => { e.stopPropagation(); setSavedPapers((prev) => isSaved ? prev.filter((x) => x !== paper.id) : [...prev, paper.id]); }}
                        style={{ marginLeft: "auto", background: "none", border: "none", cursor: "pointer", color: isSaved ? brand.amber : brand.borderGray }}>
                        <Bookmark size={16} fill={isSaved ? brand.amber : "none"} />
                      </button>
                    </div>

                    {/* Title */}
                    <h3 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 17, color: brand.charcoal, lineHeight: 1.35, marginBottom: 6 }}>{paper.title}</h3>
                    <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginBottom: 10 }}>{paper.authors} · <em>{paper.journal}</em></div>

                    {/* Key findings */}
                    <div style={{ background: "rgba(255,107,26,0.04)", border: `1px solid rgba(255,107,26,0.12)`, borderRadius: 10, padding: "12px 14px", marginBottom: 14 }}>
                      <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: brand.orange, marginBottom: 6 }}>⚡ AI KEY FINDINGS</div>
                      {paper.keyFindings.slice(0, 2).map((f, i) => (
                        <div key={i} style={{ display: "flex", gap: 7, fontFamily: "Inter", fontSize: 12, color: brand.charcoal, lineHeight: 1.5, marginBottom: i < 1 ? 5 : 0 }}>
                          <span style={{ color: brand.orange, flexShrink: 0 }}>→</span>{f}
                        </div>
                      ))}
                      {paper.keyFindings.length > 2 && <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginTop: 4 }}>+{paper.keyFindings.length - 2} more findings</div>}
                    </div>

                    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                      <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>DOI: {paper.doi}</div>
                      <button onClick={(e) => { e.stopPropagation(); nav(`/research/${paper.id}`); }} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.orange, background: "rgba(255,107,26,0.07)", border: "none", borderRadius: 8, padding: "6px 12px", cursor: "pointer", display: "flex", alignItems: "center", gap: 4 }}>
                        Read Full <ChevronRight size={12} />
                      </button>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Sidebar */}
          <div style={{ width: 280, flexShrink: 0 }}>
            <div style={{ position: "sticky", top: 88, display: "flex", flexDirection: "column" as const, gap: 16 }}>
              {/* Trending */}
              <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "18px" }}>
                <div style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 14 }}>
                  <TrendingUp size={15} color={brand.orange} />
                  <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal }}>Trending This Week</div>
                </div>
                {papers.slice(0, 4).map((p, i) => (
                  <div key={p.id} onClick={() => nav(`/research/${p.id}`)} style={{ display: "flex", gap: 10, alignItems: "flex-start", padding: "8px 0", borderBottom: i < 3 ? `1px solid ${brand.borderGray}` : "none", cursor: "pointer" }}>
                    <span style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.borderGray, flexShrink: 0 }}>{i + 1}</span>
                    <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.charcoal, lineHeight: 1.4 }}>{p.title.substring(0, 60)}…</div>
                  </div>
                ))}
              </div>

              {/* Set alerts */}
              <div style={{ background: brand.charcoal, borderRadius: 18, padding: "18px" }}>
                <div style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 10 }}>
                  <Bell size={15} color={brand.amber} />
                  <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff" }}>Research Alerts</div>
                </div>
                <p style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.55)", lineHeight: 1.55, marginBottom: 14 }}>Get notified when new papers are published in your specialty.</p>
                <div style={{ display: "flex", flexDirection: "column" as const, gap: 7 }}>
                  {specialties.slice(1, 5).map((s) => (
                    <div key={s} style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                      <span style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.6)" }}>{s}</span>
                      <button style={{ fontFamily: "Inter", fontSize: 10, fontWeight: 600, color: brand.amber, background: "rgba(255,170,24,0.12)", border: "none", borderRadius: 5, padding: "3px 8px", cursor: "pointer" }}>Follow</button>
                    </div>
                  ))}
                </div>
              </div>

              {/* Library link */}
              <div style={{ background: `rgba(255,107,26,0.06)`, border: `1px solid rgba(255,107,26,0.15)`, borderRadius: 16, padding: "16px 18px" }}>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal, marginBottom: 6 }}>📚 Dental Library</div>
                <p style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, lineHeight: 1.5, marginBottom: 12 }}>Browse textbooks, summaries, and clinical references.</p>
                <button onClick={() => nav("/library")} style={{ width: "100%", fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: "#fff", background: gradientFlow, border: "none", borderRadius: 8, padding: "9px", cursor: "pointer" }}>
                  Browse Library
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
