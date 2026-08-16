import { useState } from "react";
import { useNavigate, useParams } from "react-router";
import {
  ChevronLeft, Download, Printer, Search, Bookmark,
  ChevronDown, ChevronRight, BookOpen, Highlighter,
  StickyNote, Share2, Star, ArrowRight,
} from "lucide-react";
import { brand, gradientFlow } from "@/figma/app/shared";

const sections = [
  {
    id: "s1", title: "1. Anatomy of the Root Canal System", type: "theory",
    content: [
      { type: "heading", text: "Root Canal Morphology" },
      { type: "para", text: "The root canal system is a complex three-dimensional network of spaces within the root of a tooth. It consists of the main canal, lateral canals, accessory canals, anastomoses, and apical ramifications. Understanding this complexity is essential for achieving complete debridement and obturation." },
      { type: "pearl", text: "Clinical Pearl: Mandibular first molars have a 40% incidence of a middle mesial canal. Always verify with CBCT when standard access does not reveal adequate canal space." },
      { type: "heading", text: "Vertucci's Classification" },
      { type: "para", text: "Vertucci (1984) described 8 canal configurations based on the number of canals at the apex and their interconnections. Type I (single canal) and Type II (two canals joining) are most common, but Types IV, V, and VIII are clinically significant and often missed." },
      { type: "table", headers: ["Type", "Pattern", "Frequency (Maxillary Lateral)"], rows: [["I", "1-1", "25%"], ["II", "2-1", "18%"], ["III", "1-2-1", "12%"], ["IV", "2-2", "28%"], ["V", "1-2", "11%"]] },
      { type: "ref", text: "Vertucci FJ. Root canal anatomy of the human permanent teeth. Oral Surg Oral Med Oral Pathol. 1984;58(5):589–599." },
    ],
  },
  {
    id: "s2", title: "2. Pulp Biology & Diagnosis", type: "clinical",
    content: [
      { type: "heading", text: "Pulp Diagnosis Categories" },
      { type: "para", text: "Accurate pulp diagnosis is the foundation of all endodontic treatment planning. The American Association of Endodontists (AAE) classification system standardises diagnosis across clinical practice." },
      { type: "pearl", text: "Exam Pearl: In the EDLE, 'symptomatic irreversible pulpitis' is the most tested diagnosis. Know its criteria: spontaneous pain, lingering response to cold (>30 seconds), normal periapical radiograph." },
      { type: "list", items: ["Normal pulp: No symptoms, normal response to all tests", "Reversible pulpitis: Sharp brief pain to cold, no spontaneous pain", "Symptomatic irreversible pulpitis: Spontaneous or lingering pain", "Asymptomatic irreversible pulpitis: No symptoms, irreversible changes", "Necrotic pulp: No response to vitality tests"] },
    ],
  },
  {
    id: "s3", title: "3. Access Cavity Preparation", type: "clinical",
    content: [
      { type: "heading", text: "Principles of Access Design" },
      { type: "para", text: "The ideal access cavity must provide straight-line access to the root canal orifices, allow complete removal of the pulp chamber roof, and preserve coronal tooth structure. Overzealous preparation weakens the tooth; inadequate preparation compromises instrumentation." },
      { type: "pearl", text: "Clinical Pearl: The 'ninja access' or contracted access concept (conservative endodontics) has gained evidence. However, it should only be used when CBCT confirms uncomplicated anatomy. Traditional access remains the standard for calcified or complex cases." },
      { type: "heading", text: "Common Access Errors" },
      { type: "list", items: ["Perforation of the pulp chamber floor (most common in mandibular molars)", "Missed canals due to insufficient extension", "Transportation of canals due to non-straight-line access", "Excess tooth structure removal weakening cusps"] },
    ],
  },
  {
    id: "s4", title: "4. Rotary Instrumentation Systems", type: "clinical",
    content: [
      { type: "heading", text: "File Metallurgy" },
      { type: "para", text: "Modern rotary files are manufactured from nickel-titanium (NiTi) alloy, which allows superelastic deformation and reduces the risk of canal transportation. Heat treatment processes (M-Wire, R-Phase, Blue/Gold treatment) further enhance flexibility and cyclic fatigue resistance." },
      { type: "pearl", text: "Exam Key Concept: ProTaper Gold files (M-Wire NiTi) have significantly better cyclic fatigue resistance than conventional NiTi. The gold heat treatment increases flexibility without changing the file design." },
      { type: "ref", text: "Shen Y et al. Defects in nickel-titanium instruments after clinical use. J Endod. 2009;35(1):133–138." },
    ],
  },
];

const highlights: Record<string, string> = {};

export default function Handouts() {
  const { id } = useParams();
  const nav = useNavigate();
  const [openSections, setOpenSections] = useState<string[]>(["s1"]);
  const [search, setSearch] = useState("");
  const [activeNote, setActiveNote] = useState<string | null>(null);
  const [notes, setNotes] = useState<Record<string, string>>({});
  const [bookmarked, setBookmarked] = useState<string[]>([]);

  const toggleSection = (sid: string) =>
    setOpenSections((prev) => prev.includes(sid) ? prev.filter((s) => s !== sid) : [...prev, sid]);

  const filteredSections = sections.filter((s) =>
    search === "" || s.title.toLowerCase().includes(search.toLowerCase()) ||
    s.content.some((c) => ("text" in c && typeof c.text === "string" && c.text.toLowerCase().includes(search.toLowerCase())) || ("items" in c && Array.isArray(c.items) && c.items.some((i) => i.toLowerCase().includes(search.toLowerCase()))))
  );

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Top bar */}
      <div style={{ background: brand.white, borderBottom: `1px solid ${brand.borderGray}`, position: "sticky", top: 0, zIndex: 50 }}>
        <div style={{ maxWidth: 1100, margin: "0 auto", padding: "0 24px", height: 56, display: "flex", alignItems: "center", gap: 16 }}>
          <button onClick={() => nav(`/courses/${id}`)} style={{ background: "none", border: "none", cursor: "pointer", color: brand.warmGray, display: "flex", alignItems: "center", gap: 5, fontFamily: "Inter", fontSize: 13 }}>
            <ChevronLeft size={15} /> Back to Course
          </button>
          <div style={{ height: 20, width: 1, background: brand.borderGray }} />
          <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.charcoal }}>Course Handout</div>
          <div style={{ flex: 1 }} />
          {/* Search */}
          <div style={{ position: "relative" }}>
            <Search size={14} style={{ position: "absolute", left: 10, top: "50%", transform: "translateY(-50%)", color: brand.warmGray }} />
            <input value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Search handout…"
              style={{ fontFamily: "Inter", fontSize: 13, background: brand.offWhite, border: `1px solid ${brand.borderGray}`, borderRadius: 8, padding: "7px 12px 7px 30px", outline: "none", width: 200 }} />
          </div>
          <button style={{ background: "none", border: `1px solid ${brand.borderGray}`, borderRadius: 8, padding: "6px 12px", cursor: "pointer", display: "flex", alignItems: "center", gap: 5, fontFamily: "Inter", fontSize: 12, color: brand.charcoal }}>
            <Printer size={13} /> Print
          </button>
          <button style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: "#fff", background: gradientFlow, border: "none", borderRadius: 8, padding: "7px 14px", cursor: "pointer", display: "flex", alignItems: "center", gap: 5 }}>
            <Download size={13} /> Download PDF
          </button>
        </div>
      </div>

      <div style={{ maxWidth: 1100, margin: "0 auto", padding: "32px 24px", display: "flex", gap: 28 }}>
        {/* TOC sidebar */}
        <div className="hidden lg:block" style={{ width: 240, flexShrink: 0 }}>
          <div style={{ position: "sticky", top: 72 }}>
            <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.warmGray, letterSpacing: "0.08em", textTransform: "uppercase" as const, marginBottom: 12 }}>Contents</div>
            {sections.map((s) => (
              <button key={s.id} onClick={() => { document.getElementById(s.id)?.scrollIntoView({ behavior: "smooth" }); setOpenSections((prev) => [...new Set([...prev, s.id])]); }}
                style={{ display: "block", width: "100%", textAlign: "left" as const, fontFamily: "Inter", fontSize: 12, color: brand.charcoal, background: "none", border: "none", borderLeft: `2px solid ${openSections.includes(s.id) ? brand.orange : brand.borderGray}`, padding: "7px 12px", cursor: "pointer", marginBottom: 4, lineHeight: 1.4, transition: "border-color 0.15s" }}>
                {s.title}
              </button>
            ))}
            <div style={{ marginTop: 20, padding: "14px", background: brand.paleGray, borderRadius: 12 }}>
              <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal, marginBottom: 8 }}>Quick Actions</div>
              {[["Highlight Text", <Highlighter size={12} />], ["Add Note", <StickyNote size={12} />], ["Bookmark", <Bookmark size={12} />]].map(([label, icon]) => (
                <div key={label as string} style={{ display: "flex", gap: 8, alignItems: "center", fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginBottom: 6, cursor: "pointer" }}>
                  {icon} {label as string}
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Main content */}
        <div style={{ flex: 1, minWidth: 0 }}>
          {/* Course header */}
          <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px 28px", marginBottom: 24 }}>
            <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: brand.orange, letterSpacing: "0.08em", textTransform: "uppercase" as const, marginBottom: 6 }}>Endodontics</div>
            <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 26, color: brand.charcoal, marginBottom: 6 }}>Comprehensive Endodontics: From Basic to Advanced</h1>
            <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray }}>Dr. Amira Soliman · Module 1–4 Handout · {sections.length} sections</div>
          </div>

          {/* Sections */}
          {filteredSections.map((section) => {
            const isOpen = openSections.includes(section.id);
            const isBookmarked = bookmarked.includes(section.id);
            return (
              <div key={section.id} id={section.id} style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, marginBottom: 16, overflow: "hidden" }}>
                {/* Section header */}
                <div onClick={() => toggleSection(section.id)} style={{ display: "flex", alignItems: "center", padding: "18px 24px", cursor: "pointer", borderBottom: isOpen ? `1px solid ${brand.borderGray}` : "none" }}>
                  <div style={{ flex: 1, display: "flex", gap: 12, alignItems: "center" }}>
                    <div style={{ width: 6, height: 6, borderRadius: "50%", background: section.type === "clinical" ? brand.orange : brand.amber, flexShrink: 0 }} />
                    <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: brand.charcoal }}>{section.title}</span>
                    <span style={{ fontFamily: "Inter", fontSize: 10, fontWeight: 600, color: section.type === "clinical" ? brand.orange : brand.amber, background: section.type === "clinical" ? "rgba(255,107,26,0.08)" : "rgba(255,170,24,0.08)", borderRadius: 4, padding: "2px 7px", textTransform: "uppercase" as const }}>{section.type}</span>
                  </div>
                  <div style={{ display: "flex", gap: 8, alignItems: "center" }}>
                    <button onClick={(e) => { e.stopPropagation(); setBookmarked((prev) => isBookmarked ? prev.filter((b) => b !== section.id) : [...prev, section.id]); }}
                      style={{ background: "none", border: "none", cursor: "pointer", color: isBookmarked ? brand.amber : brand.borderGray }}>
                      <Bookmark size={15} fill={isBookmarked ? brand.amber : "none"} />
                    </button>
                    {isOpen ? <ChevronDown size={16} color={brand.warmGray} /> : <ChevronRight size={16} color={brand.warmGray} />}
                  </div>
                </div>

                {/* Section body */}
                {isOpen && (
                  <div style={{ padding: "20px 28px 24px" }}>
                    {section.content.map((block, bi) => {
                      if (block.type === "heading") return (
                        <h3 key={bi} style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal, marginBottom: 10, marginTop: bi > 0 ? 20 : 0 }}>{(block as any).text}</h3>
                      );
                      if (block.type === "para") return (
                        <p key={bi} style={{ fontFamily: "Inter", fontSize: 14, color: brand.charcoal, lineHeight: 1.75, marginBottom: 14 }}>{(block as any).text}</p>
                      );
                      if (block.type === "pearl") return (
                        <div key={bi} style={{ background: `linear-gradient(135deg, rgba(255,107,26,0.06), rgba(255,198,46,0.06))`, border: `1px solid rgba(255,107,26,0.2)`, borderLeft: `4px solid ${brand.orange}`, borderRadius: "0 12px 12px 0", padding: "14px 18px", marginBottom: 14 }}>
                          <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: brand.orange, letterSpacing: "0.06em", marginBottom: 5 }}>💡 CLINICAL / EXAM PEARL</div>
                          <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.charcoal, lineHeight: 1.65, margin: 0 }}>{(block as any).text}</p>
                        </div>
                      );
                      if (block.type === "list") return (
                        <ul key={bi} style={{ margin: "0 0 14px 0", padding: 0, listStyle: "none" }}>
                          {(block as any).items.map((item: string, i: number) => (
                            <li key={i} style={{ display: "flex", gap: 10, alignItems: "flex-start", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, lineHeight: 1.6, marginBottom: 8 }}>
                              <div style={{ width: 6, height: 6, borderRadius: "50%", background: gradientFlow, flexShrink: 0, marginTop: 7 }} />
                              {item}
                            </li>
                          ))}
                        </ul>
                      );
                      if (block.type === "table") return (
                        <div key={bi} style={{ overflowX: "auto", marginBottom: 14 }}>
                          <table style={{ width: "100%", borderCollapse: "collapse" as const }}>
                            <thead>
                              <tr style={{ background: brand.paleGray }}>
                                {(block as any).headers.map((h: string) => (
                                  <th key={h} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.charcoal, padding: "10px 14px", textAlign: "left" as const, border: `1px solid ${brand.borderGray}` }}>{h}</th>
                                ))}
                              </tr>
                            </thead>
                            <tbody>
                              {(block as any).rows.map((row: string[], ri: number) => (
                                <tr key={ri} style={{ background: ri % 2 === 0 ? brand.white : brand.offWhite }}>
                                  {row.map((cell, ci) => (
                                    <td key={ci} style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, padding: "9px 14px", border: `1px solid ${brand.borderGray}` }}>{cell}</td>
                                  ))}
                                </tr>
                              ))}
                            </tbody>
                          </table>
                        </div>
                      );
                      if (block.type === "ref") return (
                        <div key={bi} style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, fontStyle: "italic", borderTop: `1px solid ${brand.borderGray}`, paddingTop: 12, marginTop: 14 }}>
                          📎 Reference: {(block as any).text}
                        </div>
                      );
                      return null;
                    })}

                    {/* Note for this section */}
                    {activeNote === section.id ? (
                      <div style={{ marginTop: 16 }}>
                        <textarea value={notes[section.id] ?? ""} onChange={(e) => setNotes({ ...notes, [section.id]: e.target.value })} placeholder="Add your notes for this section…" rows={3}
                          style={{ width: "100%", fontFamily: "Inter", fontSize: 13, color: brand.charcoal, background: "rgba(255,198,46,0.06)", border: `1px solid ${brand.amber}`, borderRadius: 10, padding: "10px 14px", outline: "none", resize: "vertical", boxSizing: "border-box" as const }} />
                        <button onClick={() => setActiveNote(null)} style={{ marginTop: 6, fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.amber, background: "none", border: "none", cursor: "pointer" }}>Save Note</button>
                      </div>
                    ) : (
                      <button onClick={() => setActiveNote(section.id)} style={{ marginTop: 12, fontFamily: "Inter", fontSize: 12, color: brand.warmGray, background: "none", border: `1px dashed ${brand.borderGray}`, borderRadius: 8, padding: "6px 12px", cursor: "pointer", display: "flex", alignItems: "center", gap: 5 }}>
                        <StickyNote size={12} /> {notes[section.id] ? "Edit note" : "Add note"}
                      </button>
                    )}
                    {notes[section.id] && activeNote !== section.id && (
                      <div style={{ marginTop: 10, background: "rgba(255,198,46,0.06)", border: `1px solid ${brand.amber}30`, borderRadius: 8, padding: "10px 12px", fontFamily: "Inter", fontSize: 13, color: brand.charcoal }}>
                        📝 {notes[section.id]}
                      </div>
                    )}
                  </div>
                )}
              </div>
            );
          })}

          {/* Nav to next */}
          <div style={{ display: "flex", gap: 12, justifyContent: "center", marginTop: 24 }}>
            <button onClick={() => nav(`/courses/${id}/flashcards`)} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "12px 24px", cursor: "pointer", display: "flex", alignItems: "center", gap: 8 }}>
              <BookOpen size={15} /> Go to Flashcards <ArrowRight size={14} />
            </button>
            <button onClick={() => nav(`/courses/${id}/quiz`)} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 14, color: brand.charcoal, background: brand.white, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 20px", cursor: "pointer" }}>
              Take Quiz
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
