import { useState } from "react";
import { useNavigate, useParams } from "react-router";
import {
  ChevronLeft, ChevronRight, Flag, Clock, CheckCircle, X,
  Filter, Settings, BarChart2, BookOpen, Highlighter,
  StickyNote, Calculator,
} from "lucide-react";
import { brand, gradientFlow } from "@/figma/app/shared";

const questions = [
  { id: 1, text: "A patient presents with trismus, fever, and a fluctuant swelling in the submandibular space. The most appropriate immediate management is:", options: ["High-dose oral antibiotics and close monitoring", "Incision and drainage under local anaesthesia", "Hospital admission, IV antibiotics and surgical drainage", "Aspiration of the abscess under sedation"], correct: 2, explanation: "Ludwig's angina (bilateral submandibular space infection) requires immediate hospital admission, IV antibiotics, airway monitoring, and surgical drainage. Oral antibiotics alone are inadequate and potentially dangerous given the risk of airway compromise.", reference: "Peterson LJ. Oral and Maxillofacial Surgery, 5th ed.", difficulty: "Hard", specialty: "Oral Surgery", year: "2023", repetitions: 4 },
  { id: 2, text: "Which local anaesthetic has the longest duration of action?", options: ["Lidocaine 2%", "Mepivacaine 3%", "Bupivacaine 0.5%", "Articaine 4%"], correct: 2, explanation: "Bupivacaine has the longest duration among commonly used dental local anaesthetics — 4–8 hours for infiltration. It is particularly useful for post-operative pain control. Its pKa of 8.1 and high protein binding account for its prolonged action.", reference: "Malamed SF. Handbook of Local Anesthesia, 7th ed.", difficulty: "Medium", specialty: "Pharmacology", year: "2022", repetitions: 7 },
  { id: 3, text: "The radiographic appearance of a dentigerous cyst is:", options: ["Multilocular radiolucency with scalloped borders", "Well-defined unilocular radiolucency associated with the crown of an unerupted tooth", "Diffuse radiolucency with poorly defined borders", "Mixed radiopaque-radiolucent lesion"], correct: 1, explanation: "A dentigerous cyst classically presents as a well-defined (corticated), unilocular radiolucency attached at the cemento-enamel junction of an unerupted tooth, enclosing the crown. The most common site is the mandibular third molar.", reference: "Neville BW. Oral and Maxillofacial Pathology, 4th ed.", difficulty: "Easy", specialty: "Oral Pathology", year: "2023", repetitions: 12 },
  { id: 4, text: "Which of the following best describes the mechanism of action of tetracyclines in periodontal disease management?", options: ["Cell wall synthesis inhibition", "Inhibition of bacterial DNA gyrase", "Inhibition of protein synthesis at the 30S ribosomal subunit, plus anti-collagenase effects", "Disruption of bacterial cell membrane integrity"], correct: 2, explanation: "Tetracyclines work by inhibiting bacterial protein synthesis at the 30S ribosomal subunit. Uniquely, sub-antimicrobial doses also inhibit host-derived matrix metalloproteinases (MMPs/collagenases), providing an anti-inflammatory benefit independent of antibiotic action — the basis of doxycycline 20mg twice daily (Periostat).", reference: "Lindhe J. Clinical Periodontology and Implant Dentistry, 6th ed.", difficulty: "Hard", specialty: "Pharmacology", year: "2021", repetitions: 3 },
  { id: 5, text: "The MOST common complication following a mandibular third molar extraction is:", options: ["Dry socket (alveolar osteitis)", "Inferior alveolar nerve paraesthesia", "Fracture of the mandible", "Infection"], correct: 0, explanation: "Alveolar osteitis (dry socket) is the most common post-extraction complication, occurring in 2–5% of routine extractions and 20–30% of mandibular third molar extractions. It results from premature dissolution of the clot and exposure of the alveolar bone, causing severe pain 2–4 days post-operatively.", reference: "Chiapasco M. Manual of Oral Surgery.", difficulty: "Easy", specialty: "Oral Surgery", year: "2023", repetitions: 9 },
];

const subjects = [
  "All Subjects",
  "Anatomy", "Physiology", "Biochemistry", "Microbiology",
  "Oral Biology & Histology", "Pharmacology", "Dental Biomaterials", "Operative Dentistry",
  "Endodontics", "Fixed Prosthodontics", "Removable Prosthodontics", "Periodontology & Oral Medicine",
  "Oral Radiology", "Oral Pathology", "Oral & Maxillofacial Surgery", "Orthodontics",
  "Pediatric Dentistry", "Implant Dentistry", "Aesthetic Dentistry", "Digital Dentistry",
];
const difficulties = ["All", "Easy", "Medium", "Hard"];
const years = ["All Years", "2023", "2022", "2021", "2020", "2019"];

const diffColor: Record<string, string> = { Easy: "#2D9B68", Medium: brand.amber, Hard: brand.red };

export default function QuestionBank() {
  const { id } = useParams();
  const nav = useNavigate();

  const [qIdx, setQIdx] = useState(0);
  const [answers, setAnswers] = useState<Record<number, number>>({});
  const [flagged, setFlagged] = useState<number[]>([]);
  const [showExplanation, setShowExplanation] = useState(false);
  const [subject, setSubject] = useState("All Subjects");
  const [difficulty, setDifficulty] = useState("All");
  const [showFilters, setShowFilters] = useState(false);
  const [studyMode, setStudyMode] = useState(true);
  const [noteText, setNoteText] = useState("");
  const [showNote, setShowNote] = useState(false);

  const filtered = questions.filter((q) => {
    const matchSub = subject === "All Subjects" || q.specialty === subject;
    const matchDiff = difficulty === "All" || q.difficulty === difficulty;
    return matchSub && matchDiff;
  });

  const q = filtered[qIdx % Math.max(filtered.length, 1)];
  if (!q) return null;

  const answered = answers[q.id] !== undefined;
  const isCorrect = answers[q.id] === q.correct;

  const answer = (i: number) => {
    if (answered) return;
    setAnswers({ ...answers, [q.id]: i });
    if (studyMode) setShowExplanation(true);
  };

  const next = () => { setQIdx((i) => Math.min(i + 1, filtered.length - 1)); setShowExplanation(false); setShowNote(false); };
  const prev = () => { setQIdx((i) => Math.max(i - 1, 0)); setShowExplanation(false); setShowNote(false); };

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Top bar */}
      <div style={{ background: brand.white, borderBottom: `1px solid ${brand.borderGray}`, position: "sticky", top: 0, zIndex: 50 }}>
        <div style={{ maxWidth: 1200, margin: "0 auto", padding: "0 24px", height: 52, display: "flex", alignItems: "center", gap: 14 }}>
          <button onClick={() => nav("/exams/edle")} style={{ background: "none", border: "none", cursor: "pointer", color: brand.warmGray, display: "flex", alignItems: "center", gap: 5, fontFamily: "Inter", fontSize: 13 }}>
            <ChevronLeft size={15} /> EDLE Dashboard
          </button>
          <div style={{ height: 18, width: 1, background: brand.borderGray }} />
          <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal }}>Question Bank · {filtered.length} questions</div>
          <div style={{ flex: 1 }} />
          {/* Mode toggle */}
          <button onClick={() => setStudyMode(!studyMode)} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 12, color: studyMode ? brand.orange : brand.warmGray, background: studyMode ? "rgba(255,107,26,0.08)" : brand.offWhite, border: `1px solid ${studyMode ? brand.orange : brand.borderGray}`, borderRadius: 8, padding: "5px 12px", cursor: "pointer" }}>
            {studyMode ? "Study Mode" : "Exam Mode"}
          </button>
          <button onClick={() => setShowFilters(!showFilters)} style={{ background: "none", border: `1px solid ${brand.borderGray}`, borderRadius: 8, padding: "6px 12px", cursor: "pointer", display: "flex", alignItems: "center", gap: 5, fontFamily: "Inter", fontSize: 12, color: brand.charcoal }}>
            <Filter size={13} /> Filters
          </button>
          <button onClick={() => nav("/exams/analytics")} style={{ background: "none", border: `1px solid ${brand.borderGray}`, borderRadius: 8, padding: "6px 10px", cursor: "pointer", color: brand.warmGray }}>
            <BarChart2 size={15} />
          </button>
        </div>
        {/* Progress bar */}
        <div style={{ height: 3, background: brand.borderGray }}>
          <div style={{ height: "100%", width: `${((qIdx + 1) / filtered.length) * 100}%`, background: gradientFlow, transition: "width 0.3s" }} />
        </div>
      </div>

      {/* Filter panel */}
      {showFilters && (
        <div style={{ background: brand.white, borderBottom: `1px solid ${brand.borderGray}`, padding: "14px 24px" }}>
          <div style={{ maxWidth: 1200, margin: "0 auto", display: "flex", gap: 20, flexWrap: "wrap", alignItems: "center" }}>
            <div>
              <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginBottom: 5 }}>Subject</div>
              <select value={subject} onChange={(e) => { setSubject(e.target.value); setQIdx(0); }} style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, background: brand.offWhite, border: `1px solid ${brand.borderGray}`, borderRadius: 8, padding: "7px 12px", outline: "none" }}>
                {subjects.map((s) => <option key={s}>{s}</option>)}
              </select>
            </div>
            <div>
              <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginBottom: 5 }}>Difficulty</div>
              <div style={{ display: "flex", gap: 6 }}>
                {difficulties.map((d) => (
                  <button key={d} onClick={() => { setDifficulty(d); setQIdx(0); }} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 12, color: difficulty === d ? "#fff" : brand.charcoal, background: difficulty === d ? (d === "Easy" ? "#2D9B68" : d === "Medium" ? brand.amber : d === "Hard" ? brand.red : gradientFlow) : brand.offWhite, border: `1px solid ${brand.borderGray}`, borderRadius: 8, padding: "5px 12px", cursor: "pointer" }}>{d}</button>
                ))}
              </div>
            </div>
            <div>
              <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginBottom: 5 }}>Year</div>
              <select style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, background: brand.offWhite, border: `1px solid ${brand.borderGray}`, borderRadius: 8, padding: "7px 12px", outline: "none" }}>
                {years.map((y) => <option key={y}>{y}</option>)}
              </select>
            </div>
          </div>
        </div>
      )}

      <div style={{ maxWidth: 1200, margin: "0 auto", padding: "28px 24px", display: "flex", gap: 24 }}>
        {/* Question main */}
        <div style={{ flex: 1 }}>
          {/* Q meta */}
          <div style={{ display: "flex", gap: 10, alignItems: "center", marginBottom: 14, flexWrap: "wrap" }}>
            <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>Q{qIdx + 1} of {filtered.length}</span>
            <span style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 700, color: diffColor[q.difficulty], background: `${diffColor[q.difficulty]}12`, borderRadius: 5, padding: "2px 8px" }}>{q.difficulty}</span>
            <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, background: brand.paleGray, borderRadius: 5, padding: "2px 8px" }}>{q.specialty}</span>
            <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, background: brand.paleGray, borderRadius: 5, padding: "2px 8px" }}>Year: {q.year}</span>
            <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>Appeared {q.repetitions}× in past exams</span>
            <button onClick={() => setFlagged((prev) => prev.includes(q.id) ? prev.filter((f) => f !== q.id) : [...prev, q.id])}
              style={{ background: "none", border: "none", cursor: "pointer", color: flagged.includes(q.id) ? brand.amber : brand.borderGray, marginLeft: "auto" }}>
              <Flag size={16} fill={flagged.includes(q.id) ? brand.amber : "none"} />
            </button>
          </div>

          {/* Question */}
          <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px 26px", marginBottom: 14 }}>
            <p style={{ fontFamily: "Inter", fontSize: 16, color: brand.charcoal, lineHeight: 1.7, margin: 0 }}>{q.text}</p>
          </div>

          {/* Options */}
          <div style={{ display: "flex", flexDirection: "column" as const, gap: 10, marginBottom: 18 }}>
            {q.options.map((opt, i) => {
              let bg = brand.white, border = brand.borderGray, color = brand.charcoal;
              if (answered) {
                if (i === q.correct) { bg = "rgba(45,155,104,0.06)"; border = "#2D9B68"; color = "#2D9B68"; }
                else if (i === answers[q.id]) { bg = "rgba(255,45,50,0.06)"; border = brand.red; color = brand.red; }
              } else if (answers[q.id] === i) { bg = "rgba(255,107,26,0.06)"; border = brand.orange; }
              return (
                <button key={i} onClick={() => answer(i)} style={{ fontFamily: "Inter", fontSize: 14, color, background: bg, border: `1.5px solid ${border}`, borderRadius: 12, padding: "14px 18px", cursor: answered ? "default" : "pointer", textAlign: "left" as const, display: "flex", alignItems: "center", gap: 10, transition: "all 0.15s" }}>
                  <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, flexShrink: 0, width: 20 }}>{String.fromCharCode(65 + i)}.</span>
                  <span style={{ flex: 1 }}>{opt}</span>
                  {answered && i === q.correct && <CheckCircle size={14} color="#2D9B68" />}
                  {answered && i === answers[q.id] && i !== q.correct && <X size={14} color={brand.red} />}
                </button>
              );
            })}
          </div>

          {/* Explanation */}
          {showExplanation && (
            <div style={{ background: isCorrect ? "rgba(45,155,104,0.05)" : "rgba(255,45,50,0.04)", border: `1px solid ${isCorrect ? "rgba(45,155,104,0.2)" : "rgba(255,45,50,0.2)"}`, borderRadius: 16, padding: "18px 20px", marginBottom: 16 }}>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: isCorrect ? "#2D9B68" : brand.red, marginBottom: 8 }}>
                {isCorrect ? "✓ Correct!" : "✗ Incorrect"} — Explanation
              </div>
              <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.charcoal, lineHeight: 1.7, marginBottom: 10 }}>{q.explanation}</p>
              <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, fontStyle: "italic" }}>📎 {q.reference}</div>
            </div>
          )}

          {/* Note */}
          {showNote && (
            <div style={{ marginBottom: 16 }}>
              <textarea value={noteText} onChange={(e) => setNoteText(e.target.value)} placeholder="Add a note for this question…" rows={3}
                style={{ width: "100%", fontFamily: "Inter", fontSize: 13, color: brand.charcoal, background: "rgba(255,170,24,0.05)", border: `1px solid ${brand.amber}30`, borderRadius: 10, padding: "10px 14px", outline: "none", resize: "vertical", boxSizing: "border-box" as const }} />
            </div>
          )}

          {/* Toolbar */}
          <div style={{ display: "flex", gap: 8, marginBottom: 16, flexWrap: "wrap" }}>
            {!studyMode && answered && <button onClick={() => setShowExplanation(!showExplanation)} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 12, color: brand.orange, background: "rgba(255,107,26,0.07)", border: "none", borderRadius: 8, padding: "7px 12px", cursor: "pointer", display: "flex", alignItems: "center", gap: 5 }}><BookOpen size={12} /> Explanation</button>}
            <button onClick={() => setShowNote(!showNote)} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 12, color: brand.warmGray, background: brand.white, border: `1px solid ${brand.borderGray}`, borderRadius: 8, padding: "7px 12px", cursor: "pointer", display: "flex", alignItems: "center", gap: 5 }}><StickyNote size={12} /> Note</button>
            <button style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 12, color: brand.warmGray, background: brand.white, border: `1px solid ${brand.borderGray}`, borderRadius: 8, padding: "7px 12px", cursor: "pointer", display: "flex", alignItems: "center", gap: 5 }}><Calculator size={12} /> Calculator</button>
            <button style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 12, color: brand.warmGray, background: brand.white, border: `1px solid ${brand.borderGray}`, borderRadius: 8, padding: "7px 12px", cursor: "pointer" }}>Reference Values</button>
          </div>

          {/* Navigation */}
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
            <button onClick={prev} disabled={qIdx === 0} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 14, color: qIdx === 0 ? brand.borderGray : brand.charcoal, background: "none", border: `1.5px solid ${qIdx === 0 ? brand.borderGray : brand.borderGray}`, borderRadius: 12, padding: "11px 20px", cursor: qIdx === 0 ? "default" : "pointer", display: "flex", alignItems: "center", gap: 6 }}>
              <ChevronLeft size={15} /> Previous
            </button>
            <button onClick={next} disabled={qIdx === filtered.length - 1} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "11px 22px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}>
              Next <ChevronRight size={15} />
            </button>
          </div>
        </div>

        {/* Q map sidebar */}
        <div style={{ width: 190, flexShrink: 0 }}>
          <div style={{ position: "sticky", top: 72 }}>
            <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: brand.warmGray, marginBottom: 10 }}>Question Map</div>
            <div style={{ display: "grid", gridTemplateColumns: "repeat(5, 1fr)", gap: 5, marginBottom: 14 }}>
              {filtered.map((question, i) => {
                const ans = answers[question.id];
                const isAns = ans !== undefined;
                const isRight = ans === question.correct;
                const isCurr = i === qIdx;
                const isFlagged = flagged.includes(question.id);
                let bg = brand.offWhite, border = brand.borderGray;
                if (isCurr) { bg = brand.amber; border = brand.amber; }
                else if (isAns && studyMode) { bg = isRight ? "rgba(45,155,104,0.15)" : "rgba(255,45,50,0.12)"; border = isRight ? "#2D9B68" : brand.red; }
                else if (isAns) { bg = brand.paleGray; border = brand.warmGray; }
                return (
                  <button key={i} onClick={() => { setQIdx(i); setShowExplanation(false); }} style={{ width: "100%", aspectRatio: "1", fontFamily: "Inter", fontWeight: 700, fontSize: 10, color: isCurr ? "#fff" : brand.charcoal, background: bg, border: `1.5px solid ${border}`, borderRadius: 6, cursor: "pointer", position: "relative" }}>
                    {i + 1}
                    {isFlagged && <div style={{ position: "absolute", top: 1, right: 1, width: 4, height: 4, borderRadius: "50%", background: brand.amber }} />}
                  </button>
                );
              })}
            </div>
            <div style={{ display: "flex", flexDirection: "column" as const, gap: 5 }}>
              {[["Answered", Object.keys(answers).length, brand.charcoal], ["Flagged", flagged.length, brand.amber], ["Correct", Object.entries(answers).filter(([qid, ans]) => { const question = filtered.find((q) => q.id === parseInt(qid)); return question && ans === question.correct; }).length, "#2D9B68"]].map(([l, v, c]) => (
                <div key={l as string} style={{ display: "flex", justifyContent: "space-between", fontFamily: "Inter", fontSize: 12 }}>
                  <span style={{ color: brand.warmGray }}>{l as string}</span>
                  <span style={{ fontWeight: 700, color: c as string }}>{v as number}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}


