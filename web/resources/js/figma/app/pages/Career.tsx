import { useState } from "react";
import { useNavigate } from "react-router";
import { Clock, ArrowRight, FileText, BookOpen, Users, Plane, Shield } from "lucide-react";
import { brand, gradientFlow, SectionHeader } from "@/figma/app/shared";

const SLUG_ISO: Record<string, string> = {
  "uae": "ae", "ksa": "sa", "qatar": "qa", "kuwait": "kw", "oman": "om",
  "bahrain": "bh", "jordan": "jo", "uk": "gb", "ireland": "ie", "australia": "au",
  "canada": "ca", "new-zealand": "nz", "singapore": "sg", "malaysia": "my",
  "south-africa": "za", "germany": "de", "netherlands": "nl", "sweden": "se",
  "switzerland": "ch", "norway": "no", "denmark": "dk", "usa": "us", "france": "fr",
  "italy": "it", "spain": "es", "japan": "jp", "south-korea": "kr",
};

function FlagImg({ slug, name, size = 32 }: { slug: string; name: string; size?: number }) {
  const iso = SLUG_ISO[slug] || "un";
  return (
    <img
      src={`https://flagcdn.com/w40/${iso}.png`}
      width={Math.round(size * 1.4)}
      height={size}
      alt={name}
      style={{ borderRadius: 4, objectFit: "cover", display: "block", flexShrink: 0 }}
    />
  );
}

const countries = [
  // Fast Track — Gulf & Arab
  { slug: "uae",          name: "United Arab Emirates", flag: "🇦🇪", exam: "DHA / DOH / MOH Prometric", timeline: "3–6 months",   difficulty: "Medium",    recognition: "Fast Track",         market: "Very Strong", popular: true  },
  { slug: "ksa",          name: "Saudi Arabia",          flag: "🇸🇦", exam: "MOH / SLE Prometric",       timeline: "2–5 months",   difficulty: "Medium",    recognition: "Fast Track",         market: "Very Strong", popular: true  },
  { slug: "qatar",        name: "Qatar",                 flag: "🇶🇦", exam: "QCHP Prometric",            timeline: "2–4 months",   difficulty: "Medium",    recognition: "Fast Track",         market: "Strong",      popular: false },
  { slug: "kuwait",       name: "Kuwait",                flag: "🇰🇼", exam: "MOH Kuwait Prometric",      timeline: "3–6 months",   difficulty: "Medium",    recognition: "Fast Track",         market: "Strong",      popular: false },
  { slug: "oman",         name: "Oman",                  flag: "🇴🇲", exam: "OMSB / MOH Prometric",      timeline: "3–6 months",   difficulty: "Medium",    recognition: "Fast Track",         market: "Moderate",    popular: false },
  { slug: "bahrain",      name: "Bahrain",               flag: "🇧🇭", exam: "NHRA Prometric",            timeline: "2–4 months",   difficulty: "Medium",    recognition: "Fast Track",         market: "Moderate",    popular: false },
  { slug: "jordan",       name: "Jordan",                flag: "🇯🇴", exam: "JDA Licensing (minimal)",   timeline: "1–3 months",   difficulty: "Medium",    recognition: "Fast Track",         market: "Moderate",    popular: false },
  // Via Exam
  { slug: "uk",           name: "United Kingdom",        flag: "🇬🇧", exam: "ORE / LDS RCS",             timeline: "12–24 months", difficulty: "High",      recognition: "Via Licensing Exam", market: "Strong",      popular: true  },
  { slug: "ireland",      name: "Ireland",               flag: "🇮🇪", exam: "RCSI Qualifying Exam",      timeline: "6–18 months",  difficulty: "Medium",    recognition: "Via Licensing Exam", market: "Growing",     popular: false },
  { slug: "australia",    name: "Australia",             flag: "🇦🇺", exam: "ADC Examination",           timeline: "18–30 months", difficulty: "High",      recognition: "Via Licensing Exam", market: "Strong",      popular: true  },
  { slug: "canada",       name: "Canada",                flag: "🇨🇦", exam: "NDEB",                      timeline: "24–36 months", difficulty: "High",      recognition: "Via Licensing Exam", market: "Strong",      popular: false },
  { slug: "new-zealand",  name: "New Zealand",           flag: "🇳🇿", exam: "DCNZ / ADC Pathway",        timeline: "12–24 months", difficulty: "High",      recognition: "Via Licensing Exam", market: "Strong",      popular: false },
  { slug: "singapore",    name: "Singapore",             flag: "🇸🇬", exam: "SDC Qualifying Exam",       timeline: "6–18 months",  difficulty: "High",      recognition: "Via Licensing Exam", market: "Selective",   popular: false },
  { slug: "malaysia",     name: "Malaysia",              flag: "🇲🇾", exam: "MDC Registration",          timeline: "3–8 months",   difficulty: "Medium",    recognition: "Via Licensing Exam", market: "Moderate",    popular: false },
  { slug: "south-africa", name: "South Africa",          flag: "🇿🇦", exam: "HPCSA Assessment",          timeline: "6–12 months",  difficulty: "Medium",    recognition: "Via Licensing Exam", market: "Moderate",    popular: false },
  // Language + Exam
  { slug: "germany",      name: "Germany",               flag: "🇩🇪", exam: "Approbation / Kenntnisprüfung", timeline: "12–24 months", difficulty: "High",   recognition: "Language + Exam",    market: "Very Strong", popular: false },
  { slug: "netherlands",  name: "Netherlands",           flag: "🇳🇱", exam: "BIG-register Assessment",   timeline: "6–18 months",  difficulty: "High",      recognition: "Language + Exam",    market: "Strong",      popular: false },
  { slug: "sweden",       name: "Sweden",                flag: "🇸🇪", exam: "Socialstyrelsen Assessment", timeline: "12–24 months", difficulty: "High",      recognition: "Language + Exam",    market: "Strong",      popular: false },
  { slug: "switzerland",  name: "Switzerland",           flag: "🇨🇭", exam: "MEBEKO / Cantonal Exam",    timeline: "6–18 months",  difficulty: "High",      recognition: "Language + Exam",    market: "Strong",      popular: false },
  { slug: "norway",       name: "Norway",                flag: "🇳🇴", exam: "Helsedirektoratet Assessment", timeline: "12–24 months", difficulty: "High",   recognition: "Language + Exam",    market: "Strong",      popular: false },
  { slug: "denmark",      name: "Denmark",               flag: "🇩🇰", exam: "Sundhedsstyrelsen Assessment", timeline: "12–18 months", difficulty: "High",   recognition: "Language + Exam",    market: "Strong",      popular: false },
  // Complex
  { slug: "usa",          name: "United States",         flag: "🇺🇸", exam: "INBDE + State Board",       timeline: "24–48 months", difficulty: "Very High", recognition: "Complex Pathway",    market: "Selective",   popular: false },
  { slug: "france",       name: "France",                flag: "🇫🇷", exam: "PAE (quota-based)",          timeline: "18–36 months", difficulty: "High",      recognition: "Complex Pathway",    market: "Moderate",    popular: false },
];

const stages = ["Student", "Intern", "Fresh Graduate", "General Dentist", "Specialist", "Master's Holder"];

const recognitionFilters = ["All", "Fast Track", "Via Licensing Exam", "Language + Exam", "Complex Pathway"] as const;

const difficultyColor: Record<string, string> = { "Medium": brand.amber, "High": brand.orange, "Very High": brand.red };

const recColor: Record<string, string> = {
  "Fast Track": "#2D9B68",
  "Via Licensing Exam": brand.amber,
  "Language + Exam": brand.orange,
  "Complex Pathway": brand.red,
};
const recBg: Record<string, string> = {
  "Fast Track": "rgba(45,155,104,0.1)",
  "Via Licensing Exam": `${brand.amber}18`,
  "Language + Exam": `${brand.orange}12`,
  "Complex Pathway": `${brand.red}10`,
};

export default function Career() {
  const nav = useNavigate();
  const [selectedStage, setSelectedStage] = useState("Fresh Graduate");
  const [recognitionFilter, setRecognitionFilter] = useState<string>("All");
  const [regionFilter, setRegionFilter] = useState("All");
  const [timelineFilter, setTimelineFilter] = useState("All");
  const [difficultyFilter, setDifficultyFilter] = useState("All");

  const regionMap: Record<string, string[]> = {
    Gulf: ["uae", "ksa", "qatar", "kuwait", "oman", "bahrain"],
    "Arab World": ["jordan"],
    Europe: ["uk", "ireland", "germany", "netherlands", "sweden", "switzerland", "norway", "denmark", "france", "belgium"],
    "Asia-Pacific": ["australia", "new-zealand", "singapore", "malaysia"],
    Americas: ["usa", "canada"],
    Africa: ["south-africa"],
  };

  const timelineMatch = (timeline: string, f: string) => {
    const months = parseInt(timeline);
    if (f === "< 6 months") return months < 6;
    if (f === "6–18 months") return months >= 6 && months <= 18;
    if (f === "18+ months") return months > 18;
    return true;
  };

  const clearCareerFilters = () => { setRecognitionFilter("All"); setRegionFilter("All"); setTimelineFilter("All"); setDifficultyFilter("All"); };
  const activeCareerFilters = [recognitionFilter !== "All", regionFilter !== "All", timelineFilter !== "All", difficultyFilter !== "All"].filter(Boolean).length;

  const filtered = countries.filter((c) => {
    const matchRecognition = recognitionFilter === "All" || c.recognition === recognitionFilter;
    const matchRegion = regionFilter === "All" || (regionMap[regionFilter] ?? []).includes(c.slug);
    const matchTimeline = timelineFilter === "All" || timelineMatch(c.timeline, timelineFilter);
    const matchDifficulty = difficultyFilter === "All" || c.difficulty === difficultyFilter;
    return matchRecognition && matchRegion && matchTimeline && matchDifficulty;
  });

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Header */}
      <div style={{ background: `linear-gradient(135deg, ${brand.charcoal} 0%, #24201D 100%)`, padding: "56px 24px 48px", position: "relative", overflow: "hidden" }}>
        <div style={{ position: "absolute", inset: 0, background: "radial-gradient(ellipse at 30% 50%, rgba(255,107,26,0.08) 0%, transparent 60%)", pointerEvents: "none" }} />
        <div style={{ maxWidth: 1280, margin: "0 auto", position: "relative" }}>
          <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 12 }}>
            <Plane size={16} color={brand.amber} />
            <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, letterSpacing: "0.1em", color: brand.amber, textTransform: "uppercase" as const }}>Career Abroad</span>
          </div>
          <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(28px,4vw,44px)", color: "#fff", marginBottom: 14 }}>Dental Career Beyond Egypt</h1>
          <p style={{ fontFamily: "Inter", fontSize: 16, color: "rgba(255,255,255,0.6)", maxWidth: 560, marginBottom: 28 }}>Step-by-step pathways for Egyptian dentists pursuing licensure and practice in 23 countries — personalised by your career stage.</p>
          {/* Stage filter */}
          <div>
            <div style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.5)", marginBottom: 12 }}>I am a:</div>
            <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
              {stages.map((s) => (
                <button key={s} onClick={() => setSelectedStage(s)} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 13, color: selectedStage === s ? "#fff" : "rgba(255,255,255,0.6)", background: selectedStage === s ? gradientFlow : "rgba(255,255,255,0.07)", border: `1.5px solid ${selectedStage === s ? "transparent" : "rgba(255,255,255,0.12)"}`, borderRadius: 20, padding: "7px 16px", cursor: "pointer", transition: "all 0.15s" }}>{s}</button>
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* Recognition legend strip */}
      <div style={{ background: brand.white, borderBottom: `1px solid ${brand.borderGray}` }}>
        <div style={{ maxWidth: 1280, margin: "0 auto", padding: "12px 24px", display: "flex", gap: 16, flexWrap: "wrap", alignItems: "center" }}>
          <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal }}>Egyptian BDS Recognition:</span>
          {[
            { tier: "Fast Track", desc: "2–6 months" },
            { tier: "Via Licensing Exam", desc: "6–24 months" },
            { tier: "Language + Exam", desc: "12–24 months" },
            { tier: "Complex Pathway", desc: "24–48 months" },
          ].map((r) => (
            <div key={r.tier} style={{ display: "flex", alignItems: "center", gap: 5 }}>
              <div style={{ width: 8, height: 8, borderRadius: "50%", background: recColor[r.tier] }} />
              <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}><span style={{ fontWeight: 600, color: recColor[r.tier] }}>{r.tier}</span> {r.desc}</span>
            </div>
          ))}
        </div>
      </div>

      <div style={{ maxWidth: 1280, margin: "0 auto", padding: "40px 24px" }}>
        <div style={{ display: "flex", gap: 32, flexWrap: "wrap" }}>
          {/* Country grid */}
          <div style={{ flex: "1 1 480px" }}>
            <div style={{ background: brand.white, borderRadius: 16, border: `1px solid ${brand.borderGray}`, padding: "16px 18px", marginBottom: 20 }}>
              {/* Row 1: Recognition + region */}
              <div style={{ display: "flex", gap: 16, flexWrap: "wrap", alignItems: "center", marginBottom: 12 }}>
                <div style={{ display: "flex", gap: 6, alignItems: "center" }}>
                  <span style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 600, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em" }}>Recognition</span>
                  {recognitionFilters.map((f) => (
                    <button key={f} onClick={() => setRecognitionFilter(f)} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: recognitionFilter === f ? "#fff" : brand.charcoal, background: recognitionFilter === f ? gradientFlow : brand.offWhite, border: `1.5px solid ${recognitionFilter === f ? "transparent" : brand.borderGray}`, borderRadius: 8, padding: "4px 11px", cursor: "pointer", whiteSpace: "nowrap" as const }}>{f}</button>
                  ))}
                </div>
                <div style={{ width: 1, background: brand.borderGray, alignSelf: "stretch" }} />
                <div style={{ display: "flex", gap: 6, alignItems: "center" }}>
                  <span style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 600, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em" }}>Region</span>
                  {["All", "Gulf", "Arab World", "Europe", "Asia-Pacific", "Americas", "Africa"].map((r) => (
                    <button key={r} onClick={() => setRegionFilter(r)} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: regionFilter === r ? "#fff" : brand.charcoal, background: regionFilter === r ? brand.amber : brand.offWhite, border: `1.5px solid ${regionFilter === r ? brand.amber : brand.borderGray}`, borderRadius: 8, padding: "4px 11px", cursor: "pointer", whiteSpace: "nowrap" as const }}>{r}</button>
                  ))}
                </div>
              </div>

              {/* Row 2: Timeline + difficulty + clear */}
              <div style={{ display: "flex", gap: 16, flexWrap: "wrap", alignItems: "center" }}>
                <div style={{ display: "flex", gap: 6, alignItems: "center" }}>
                  <span style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 600, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em" }}>Timeline</span>
                  {["All", "< 6 months", "6–18 months", "18+ months"].map((t) => (
                    <button key={t} onClick={() => setTimelineFilter(t)} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: timelineFilter === t ? "#fff" : brand.charcoal, background: timelineFilter === t ? "#2D9B68" : brand.offWhite, border: `1.5px solid ${timelineFilter === t ? "#2D9B68" : brand.borderGray}`, borderRadius: 8, padding: "4px 11px", cursor: "pointer", whiteSpace: "nowrap" as const }}>{t}</button>
                  ))}
                </div>
                <div style={{ width: 1, background: brand.borderGray, alignSelf: "stretch" }} />
                <div style={{ display: "flex", gap: 6, alignItems: "center" }}>
                  <span style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 600, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em" }}>Difficulty</span>
                  {["All", "Medium", "High", "Very High"].map((d) => {
                    const dc: Record<string, string> = { Medium: brand.amber, High: brand.orange, "Very High": brand.red };
                    return (
                      <button key={d} onClick={() => setDifficultyFilter(d)} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: difficultyFilter === d ? "#fff" : brand.charcoal, background: difficultyFilter === d ? (dc[d] ?? brand.charcoal) : brand.offWhite, border: `1.5px solid ${difficultyFilter === d ? (dc[d] ?? brand.charcoal) : brand.borderGray}`, borderRadius: 8, padding: "4px 11px", cursor: "pointer" }}>{d}</button>
                    );
                  })}
                </div>
                <div style={{ marginLeft: "auto", display: "flex", gap: 8, alignItems: "center" }}>
                  {activeCareerFilters > 0 && (
                    <button onClick={clearCareerFilters} style={{ fontFamily: "Inter", fontSize: 12, fontWeight: 600, color: brand.red, background: `${brand.red}08`, border: `1px solid ${brand.red}20`, borderRadius: 8, padding: "5px 10px", cursor: "pointer" }}>Clear {activeCareerFilters}</button>
                  )}
                  <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray }}><strong>{filtered.length}</strong> of {countries.length} countries</span>
                </div>
              </div>
            </div>
            <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(290px, 1fr))", gap: 14 }}>
              {filtered.map((c) => (
                <div
                  key={c.slug}
                  onClick={() => nav(`/career/${c.slug}`)}
                  style={{ background: brand.white, borderRadius: 18, border: `1.5px solid ${brand.borderGray}`, padding: "20px 18px", cursor: "pointer", transition: "all 0.18s", position: "relative" as const }}
                  onMouseEnter={(e) => { (e.currentTarget as HTMLElement).style.borderColor = brand.orange; (e.currentTarget as HTMLElement).style.boxShadow = "0 4px 16px rgba(255,107,26,0.1)"; }}
                  onMouseLeave={(e) => { (e.currentTarget as HTMLElement).style.borderColor = brand.borderGray; (e.currentTarget as HTMLElement).style.boxShadow = "none"; }}
                >
                  {c.popular && (
                    <span style={{ position: "absolute" as const, top: 14, right: 14, fontFamily: "Inter", fontWeight: 700, fontSize: 9, color: "#fff", background: gradientFlow, borderRadius: 4, padding: "2px 7px", letterSpacing: "0.06em" }}>POPULAR</span>
                  )}
                  <div style={{ display: "flex", gap: 12, alignItems: "center", marginBottom: 14 }}>
                    <FlagImg slug={c.slug} name={c.name} size={30} />
                    <div>
                      <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: brand.charcoal }}>{c.name}</div>
                      <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginTop: 1 }}>{c.exam}</div>
                    </div>
                  </div>

                  {/* Recognition tier badge */}
                  <div style={{ display: "inline-flex", alignItems: "center", gap: 5, background: recBg[c.recognition], borderRadius: 8, padding: "4px 10px", marginBottom: 12 }}>
                    <Shield size={11} color={recColor[c.recognition]} />
                    <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: recColor[c.recognition] }}>{c.recognition}</span>
                  </div>

                  <div style={{ display: "flex", gap: 12, flexWrap: "wrap" }}>
                    <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, display: "flex", alignItems: "center", gap: 4 }}><Clock size={11} /> {c.timeline}</span>
                    <span style={{ fontFamily: "Inter", fontSize: 12, fontWeight: 600, color: difficultyColor[c.difficulty] }}>{c.difficulty}</span>
                    <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>Market: {c.market}</span>
                  </div>

                  <button
                    onClick={(e) => { e.stopPropagation(); nav(`/career/${c.slug}`); }}
                    style={{ marginTop: 14, width: "100%", fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.orange, background: "rgba(255,107,26,0.07)", border: "none", borderRadius: 10, padding: "10px", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 6, transition: "background 0.15s" }}
                    onMouseEnter={(e) => { (e.currentTarget as HTMLElement).style.background = gradientFlow; (e.currentTarget as HTMLElement).style.color = "#fff"; }}
                    onMouseLeave={(e) => { (e.currentTarget as HTMLElement).style.background = "rgba(255,107,26,0.07)"; (e.currentTarget as HTMLElement).style.color = brand.orange; }}
                  >
                    View Full Pathway <ArrowRight size={13} />
                  </button>
                </div>
              ))}
            </div>
          </div>

          {/* Sidebar tools */}
          <div style={{ flex: "0 1 300px" }}>
            <SectionHeader label="Tools" title="Career Resources" />
            {[
              { icon: <FileText size={18} color={brand.orange} />, title: "Document Checklist", desc: "Degree, transcripts, good standing letters, ID — all organized by country.", action: "Download Checklist", path: "/career/roadmap" },
              { icon: <BookOpen size={18} color={brand.amber} />, title: "Exam Preparation", desc: "Structured question banks for ORE, INBDE, ADC, Prometric, and more.", action: "Start Preparing", path: "/exams" },
              { icon: <Users size={18} color={brand.red} />, title: "Book a Career Mentor", desc: "Speak with an Egyptian dentist currently practicing in your target country.", action: "Find a Mentor", path: "/mentoring" },
              { icon: <Plane size={18} color={brand.gold} />, title: "Master's Programs Abroad", desc: "Search 200+ accredited postgraduate programs by specialty and country.", action: "Browse Programs", path: "/masters" },
            ].map((tool) => (
              <div key={tool.title} style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "20px 18px", marginBottom: 14 }}>
                <div style={{ display: "flex", gap: 12, alignItems: "flex-start", marginBottom: 12 }}>
                  <div style={{ width: 40, height: 40, borderRadius: 12, background: brand.offWhite, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>{tool.icon}</div>
                  <div>
                    <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal }}>{tool.title}</div>
                    <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginTop: 4, lineHeight: 1.5 }}>{tool.desc}</div>
                  </div>
                </div>
                <button onClick={() => nav(tool.path)} style={{ width: "100%", fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.orange, background: "rgba(255,107,26,0.08)", border: "none", borderRadius: 8, padding: "9px", cursor: "pointer" }}>{tool.action}</button>
              </div>
            ))}

            {/* Quick stats */}
            <div style={{ background: brand.charcoal, borderRadius: 18, padding: "20px 18px" }}>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff", marginBottom: 14 }}>Recognition Matrix</div>
              {[
                { label: "Fast Track countries", value: "7", color: "#2D9B68" },
                { label: "Via Exam countries", value: "8", color: brand.amber },
                { label: "Language + Exam", value: "6", color: brand.orange },
                { label: "Complex pathway", value: "2", color: brand.red },
              ].map((s) => (
                <div key={s.label} style={{ display: "flex", justifyContent: "space-between", padding: "8px 0", borderBottom: `1px solid rgba(255,255,255,0.06)` }}>
                  <span style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.55)" }}>{s.label}</span>
                  <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: s.color }}>{s.value}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
