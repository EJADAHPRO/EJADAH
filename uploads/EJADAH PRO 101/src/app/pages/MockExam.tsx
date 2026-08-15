import { useState, useEffect } from "react";
import { useNavigate } from "react-router";
import {
  Clock, Flag, ChevronLeft, ChevronRight, CheckCircle,
  X, BarChart2, ArrowRight, RotateCcw, AlertTriangle,
} from "lucide-react";
import { brand, gradientFlow } from "@/app/shared";

const mockQuestions = [
  { id: 1, text: "Which nerve provides sensory innervation to the anterior two-thirds of the tongue?", options: ["Glossopharyngeal nerve", "Lingual nerve (V3)", "Chorda tympani", "Hypoglossal nerve"], correct: 1, specialty: "Anatomy" },
  { id: 2, text: "A 25-year-old patient presents with a painless, slow-growing, well-demarcated swelling of the mandible. Radiograph shows a multilocular radiolucency with a 'soap bubble' appearance. The most likely diagnosis is:", options: ["Ameloblastoma", "Dentigerous cyst", "Odontogenic keratocyst", "Central giant cell granuloma"], correct: 0, specialty: "Oral Pathology" },
  { id: 3, text: "The primary defence mechanism of the periodontium against bacterial invasion is:", options: ["Collagen fibres of the PDL", "Junctional epithelium and gingival crevicular fluid", "Alveolar bone remodelling", "Cementum of the root surface"], correct: 1, specialty: "Periodontics" },
  { id: 4, text: "Which of the following antibiotics is CONTRAINDICATED in patients taking warfarin due to its effect on INR?", options: ["Amoxicillin", "Metronidazole", "Erythromycin", "Both B and C"], correct: 3, specialty: "Pharmacology" },
  { id: 5, text: "The apical limit of root canal preparation and obturation should ideally be at the:", options: ["Radiographic apex", "Cemento-dentinal junction (CDJ)", "Apical foramen", "1 mm beyond the radiographic apex"], correct: 1, specialty: "Endodontics" },
];

const TOTAL_TIME = 15 * 60; // 15 minutes for demo

type ExamState = "intro" | "active" | "results";

function formatTime(seconds: number) {
  const m = Math.floor(seconds / 60);
  const s = seconds % 60;
  return `${m}:${String(s).padStart(2, "0")}`;
}

export default function MockExam() {
  const nav = useNavigate();
  const [examState, setExamState] = useState<ExamState>("intro");
  const [qIdx, setQIdx] = useState(0);
  const [answers, setAnswers] = useState<Record<number, number>>({});
  const [flagged, setFlagged] = useState<number[]>([]);
  const [timeLeft, setTimeLeft] = useState(TOTAL_TIME);

  useEffect(() => {
    if (examState !== "active") return;
    const interval = setInterval(() => {
      setTimeLeft((t) => {
        if (t <= 1) { setExamState("results"); return 0; }
        return t - 1;
      });
    }, 1000);
    return () => clearInterval(interval);
  }, [examState]);

  const q = mockQuestions[qIdx];
  const score = Object.entries(answers).filter(([qid, ans]) => mockQuestions.find((q) => q.id === parseInt(qid))?.correct === ans).length;
  const pct = Math.round((score / mockQuestions.length) * 100);
  const passed = pct >= 70;

  if (examState === "intro") return (
    <div style={{ background: brand.offWhite, minHeight: "100vh", display: "flex", alignItems: "center", justifyContent: "center", padding: 24 }}>
      <div style={{ maxWidth: 580, width: "100%" }}>
        <div style={{ background: brand.white, borderRadius: 24, border: `1px solid ${brand.borderGray}`, padding: "40px 36px", textAlign: "center" as const, boxShadow: "0 8px 32px rgba(27,27,27,0.08)" }}>
          <div style={{ fontSize: 48, marginBottom: 16 }}>📝</div>
          <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 28, color: brand.charcoal, marginBottom: 8 }}>EDLE Simulation Exam</h1>
          <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, marginBottom: 28, lineHeight: 1.6 }}>
            A timed mock exam simulating the Egyptian Dental Licensing Exam format. Answer all questions before time runs out. You cannot pause the exam.
          </p>
          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 14, marginBottom: 28 }}>
            {[["Questions", `${mockQuestions.length} (demo)`], ["Time Limit", "15 minutes"], ["Pass Mark", "70%"], ["Subjects", "All EDLE Subjects"]].map(([l, v]) => (
              <div key={l} style={{ background: brand.offWhite, borderRadius: 12, padding: "14px" }}>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 16, color: brand.charcoal }}>{v}</div>
                <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginTop: 3 }}>{l}</div>
              </div>
            ))}
          </div>
          <div style={{ background: "rgba(255,170,24,0.08)", border: `1px solid ${brand.amber}30`, borderRadius: 12, padding: "14px 16px", marginBottom: 24, display: "flex", gap: 8, alignItems: "flex-start", textAlign: "left" as const }}>
            <AlertTriangle size={14} color={brand.amber} style={{ marginTop: 1, flexShrink: 0 }} />
            <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, lineHeight: 1.5 }}>
              Once you start, the timer begins immediately. Explanations will only be shown after you submit or time runs out.
            </span>
          </div>
          <button onClick={() => setExamState("active")} style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 16, color: "#fff", background: gradientFlow, border: "none", borderRadius: 14, padding: "16px", cursor: "pointer", boxShadow: "0 4px 16px rgba(255,107,26,0.35)" }}>
            Start Exam
          </button>
          <button onClick={() => nav("/exams/edle")} style={{ marginTop: 12, width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.warmGray, background: "none", border: "none", cursor: "pointer" }}>Cancel</button>
        </div>
      </div>
    </div>
  );

  if (examState === "results") return (
    <div style={{ background: brand.offWhite, minHeight: "100vh", padding: "40px 24px" }}>
      <div style={{ maxWidth: 720, margin: "0 auto" }}>
        <div style={{ textAlign: "center" as const, marginBottom: 32 }}>
          <div style={{ width: 88, height: 88, borderRadius: "50%", background: passed ? "rgba(45,155,104,0.1)" : "rgba(255,45,50,0.1)", border: `3px solid ${passed ? "#2D9B68" : brand.red}`, display: "flex", alignItems: "center", justifyContent: "center", margin: "0 auto 20px" }}>
            {passed ? <CheckCircle size={42} color="#2D9B68" /> : <X size={42} color={brand.red} />}
          </div>
          <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 30, color: brand.charcoal, marginBottom: 6 }}>{passed ? "Passed!" : "Not Passed"}</h2>
          <p style={{ fontFamily: "Inter", fontSize: 15, color: brand.warmGray }}>Score: {score}/{mockQuestions.length} ({pct}%) · Pass mark: 70%</p>
        </div>
        {/* Score grid */}
        <div style={{ display: "grid", gridTemplateColumns: "repeat(4, 1fr)", gap: 14, marginBottom: 28 }}>
          {[["Score", `${pct}%`, passed ? "#2D9B68" : brand.red], ["Correct", String(score), "#2D9B68"], ["Incorrect", String(mockQuestions.length - score), brand.red], ["Time Used", formatTime(TOTAL_TIME - timeLeft), brand.charcoal]].map(([l, v, c]) => (
            <div key={l as string} style={{ background: brand.white, border: `1px solid ${brand.borderGray}`, borderRadius: 16, padding: "18px 16px", textAlign: "center" as const }}>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 26, color: c as string }}>{v as string}</div>
              <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginTop: 4 }}>{l as string}</div>
            </div>
          ))}
        </div>
        {/* Question review */}
        <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px", marginBottom: 24 }}>
          <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 18 }}>Question Review</div>
          {mockQuestions.map((question, i) => {
            const ans = answers[question.id];
            const correct = ans === question.correct;
            const unanswered = ans === undefined;
            return (
              <div key={question.id} style={{ background: unanswered ? brand.offWhite : correct ? "rgba(45,155,104,0.05)" : "rgba(255,45,50,0.04)", border: `1px solid ${unanswered ? brand.borderGray : correct ? "rgba(45,155,104,0.2)" : "rgba(255,45,50,0.2)"}`, borderRadius: 14, padding: "16px", marginBottom: 10 }}>
                <div style={{ display: "flex", gap: 10, alignItems: "flex-start" }}>
                  <div style={{ width: 22, height: 22, borderRadius: "50%", background: unanswered ? brand.paleGray : correct ? "rgba(45,155,104,0.12)" : "rgba(255,45,50,0.12)", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                    {unanswered ? <span style={{ fontSize: 10, color: brand.warmGray }}>—</span> : correct ? <CheckCircle size={12} color="#2D9B68" /> : <X size={12} color={brand.red} />}
                  </div>
                  <div style={{ flex: 1 }}>
                    <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal, marginBottom: 4 }}>Q{i + 1}: {question.text.substring(0, 70)}…</div>
                    <div style={{ fontFamily: "Inter", fontSize: 12, color: "#2D9B68" }}>✓ Correct: {question.options[question.correct]}</div>
                    {!correct && ans !== undefined && <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.red, marginTop: 2 }}>✗ Your answer: {question.options[ans]}</div>}
                    {unanswered && <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginTop: 2 }}>Not answered</div>}
                  </div>
                  <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, background: brand.paleGray, borderRadius: 5, padding: "2px 8px", flexShrink: 0 }}>{question.specialty}</span>
                </div>
              </div>
            );
          })}
        </div>
        <div style={{ display: "flex", gap: 12, justifyContent: "center", flexWrap: "wrap" }}>
          <button onClick={() => { setAnswers({}); setQIdx(0); setTimeLeft(TOTAL_TIME); setFlagged([]); setExamState("intro"); }} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.charcoal, background: brand.white, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 22px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}>
            <RotateCcw size={14} /> Retake
          </button>
          <button onClick={() => nav("/exams/analytics")} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "12px 24px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}>
            <BarChart2 size={14} /> Full Analytics <ArrowRight size={14} />
          </button>
        </div>
      </div>
    </div>
  );

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Top bar */}
      <div style={{ background: brand.charcoal, position: "sticky", top: 0, zIndex: 50 }}>
        <div style={{ maxWidth: 1000, margin: "0 auto", padding: "0 24px", height: 52, display: "flex", alignItems: "center", gap: 16 }}>
          <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: "#fff" }}>EDLE Mock Exam</div>
          <div style={{ flex: 1 }} />
          <div style={{ display: "flex", alignItems: "center", gap: 6, fontFamily: "Inter", fontWeight: 700, fontSize: 16, color: timeLeft < 120 ? brand.red : brand.gold }}>
            <Clock size={16} /> {formatTime(timeLeft)}
          </div>
          <div style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.5)" }}>Q{qIdx + 1}/{mockQuestions.length}</div>
          <button onClick={() => setExamState("results")} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: "#fff", background: brand.red, border: "none", borderRadius: 8, padding: "7px 14px", cursor: "pointer" }}>Submit</button>
        </div>
        <div style={{ height: 3, background: "rgba(255,255,255,0.1)" }}>
          <div style={{ height: "100%", width: `${((qIdx + 1) / mockQuestions.length) * 100}%`, background: gradientFlow, transition: "width 0.3s" }} />
        </div>
      </div>

      <div style={{ maxWidth: 1000, margin: "0 auto", padding: "32px 24px", display: "flex", gap: 24 }}>
        <div style={{ flex: 1 }}>
          <div style={{ display: "flex", gap: 8, marginBottom: 14 }}>
            <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, background: brand.paleGray, borderRadius: 5, padding: "2px 8px" }}>{q.specialty}</span>
            <button onClick={() => setFlagged((prev) => prev.includes(q.id) ? prev.filter((f) => f !== q.id) : [...prev, q.id])} style={{ background: "none", border: "none", cursor: "pointer", color: flagged.includes(q.id) ? brand.amber : brand.borderGray, marginLeft: "auto" }}>
              <Flag size={16} fill={flagged.includes(q.id) ? brand.amber : "none"} />
            </button>
          </div>
          <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px 26px", marginBottom: 14 }}>
            <p style={{ fontFamily: "Inter", fontSize: 16, color: brand.charcoal, lineHeight: 1.7, margin: 0 }}>{q.text}</p>
          </div>
          <div style={{ display: "flex", flexDirection: "column" as const, gap: 10, marginBottom: 20 }}>
            {q.options.map((opt, i) => {
              const isSelected = answers[q.id] === i;
              return (
                <button key={i} onClick={() => setAnswers({ ...answers, [q.id]: i })} style={{ fontFamily: "Inter", fontSize: 14, color: isSelected ? "#fff" : brand.charcoal, background: isSelected ? gradientFlow : brand.white, border: `1.5px solid ${isSelected ? "transparent" : brand.borderGray}`, borderRadius: 12, padding: "14px 18px", cursor: "pointer", textAlign: "left" as const, display: "flex", alignItems: "center", gap: 10, transition: "all 0.15s", boxShadow: isSelected ? "0 3px 12px rgba(255,107,26,0.25)" : "none" }}>
                  <span style={{ fontWeight: 700, flexShrink: 0 }}>{String.fromCharCode(65 + i)}.</span>
                  {opt}
                </button>
              );
            })}
          </div>
          <div style={{ display: "flex", justifyContent: "space-between" }}>
            <button onClick={() => setQIdx(Math.max(0, qIdx - 1))} disabled={qIdx === 0} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 14, color: qIdx === 0 ? brand.borderGray : brand.charcoal, background: "none", border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "11px 20px", cursor: qIdx === 0 ? "default" : "pointer", display: "flex", alignItems: "center", gap: 6 }}>
              <ChevronLeft size={15} /> Previous
            </button>
            {qIdx < mockQuestions.length - 1 ? (
              <button onClick={() => setQIdx(qIdx + 1)} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "11px 22px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}>
                Next <ChevronRight size={15} />
              </button>
            ) : (
              <button onClick={() => setExamState("results")} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: "#2D9B68", border: "none", borderRadius: 12, padding: "11px 22px", cursor: "pointer" }}>
                Submit Exam
              </button>
            )}
          </div>
        </div>
        {/* Q map */}
        <div style={{ width: 180, flexShrink: 0 }}>
          <div style={{ position: "sticky", top: 68 }}>
            <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: brand.warmGray, marginBottom: 10 }}>Questions</div>
            <div style={{ display: "grid", gridTemplateColumns: "repeat(5, 1fr)", gap: 5 }}>
              {mockQuestions.map((question, i) => {
                const isCurr = i === qIdx;
                const isAns = answers[question.id] !== undefined;
                const isFlagged = flagged.includes(question.id);
                return (
                  <button key={i} onClick={() => setQIdx(i)} style={{ width: "100%", aspectRatio: "1", fontFamily: "Inter", fontWeight: 700, fontSize: 10, color: isCurr ? "#fff" : brand.charcoal, background: isCurr ? brand.amber : isAns ? brand.paleGray : brand.white, border: `1.5px solid ${isCurr ? brand.amber : isAns ? brand.warmGray : brand.borderGray}`, borderRadius: 6, cursor: "pointer", position: "relative" }}>
                    {i + 1}
                    {isFlagged && <div style={{ position: "absolute", top: 1, right: 1, width: 4, height: 4, borderRadius: "50%", background: brand.amber }} />}
                  </button>
                );
              })}
            </div>
            <div style={{ marginTop: 14, display: "flex", flexDirection: "column" as const, gap: 5 }}>
              {[["Answered", Object.keys(answers).length], ["Flagged", flagged.length], ["Unanswered", mockQuestions.length - Object.keys(answers).length]].map(([l, v]) => (
                <div key={l as string} style={{ display: "flex", justifyContent: "space-between", fontFamily: "Inter", fontSize: 12 }}>
                  <span style={{ color: brand.warmGray }}>{l as string}</span>
                  <span style={{ fontWeight: 700, color: brand.charcoal }}>{v as number}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
