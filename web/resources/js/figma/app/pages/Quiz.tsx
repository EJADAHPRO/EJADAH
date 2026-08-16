import { useState } from "react";
import { useNavigate, useParams } from "react-router";
import {
  ChevronLeft, ChevronRight, Flag, Clock, CheckCircle,
  X, BookOpen, ArrowRight, BarChart2, RotateCcw, Zap,
} from "lucide-react";
import { brand, gradientFlow, gradientGlow } from "@/figma/app/shared";

interface Question {
  id: number; text: string; options: string[]; correct: number;
  explanation: string; reference: string; difficulty: "Easy" | "Medium" | "Hard";
  specialty: string; flagged?: boolean;
}

const questions: Question[] = [
  { id: 1, text: "A patient presents with severe spontaneous pain, lingering cold sensitivity, and a normal periapical radiograph on tooth #36. The most appropriate diagnosis is:", options: ["Reversible pulpitis", "Symptomatic irreversible pulpitis", "Asymptomatic apical periodontitis", "Necrotic pulp with symptomatic apical periodontitis"], correct: 1, explanation: "Symptomatic irreversible pulpitis is characterised by spontaneous pain, lingering response to cold (>30 seconds), and a normal periapical radiograph. The inflamed pulp is incapable of healing, but the periapical tissues are not yet involved, hence the normal radiograph.", reference: "AAE Glossary of Endodontic Terms, 10th Edition (2020)", difficulty: "Medium", specialty: "Endodontics" },
  { id: 2, text: "Which of the following file systems uses M-Wire nickel-titanium technology to improve cyclic fatigue resistance?", options: ["Original ProTaper Universal", "K3 file system", "ProTaper Gold", "Hedström files"], correct: 2, explanation: "ProTaper Gold files are manufactured from M-Wire NiTi, which undergoes a proprietary thermomechanical process that significantly increases cyclic fatigue resistance compared to conventional NiTi. The gold colouration results from heat treatment.", reference: "Shen Y et al. Defects in nickel-titanium instruments. J Endod 2009;35:133-138", difficulty: "Hard", specialty: "Endodontics" },
  { id: 3, text: "What is the most common canal configuration in the mesial root of mandibular first molars, according to Vertucci's classification?", options: ["Type I (1-1)", "Type II (2-1)", "Type III (1-2-1)", "Type IV (2-2)"], correct: 3, explanation: "The mesial root of mandibular first molars most commonly has a Type IV configuration (Vertucci), meaning 2 separate canals entering separately and exiting separately. This is present in approximately 45-60% of cases.", reference: "Vertucci FJ. Root canal anatomy of the human permanent teeth. Oral Surg 1984;58:589-599", difficulty: "Medium", specialty: "Endodontics" },
  { id: 4, text: "Sodium hypochlorite (NaOCl) is the primary irrigant in root canal treatment primarily because it:", options: ["Removes the smear layer completely", "Has the ability to dissolve both vital and necrotic organic tissue", "Has no cytotoxic effects at any concentration", "Eliminates all resistant bacterial biofilms alone"], correct: 1, explanation: "NaOCl's primary advantage is its unique ability to dissolve both vital and necrotic organic tissue, including the collagen component of the dentinal matrix. It does NOT remove the smear layer (requires EDTA) and IS cytotoxic. Resistant biofilms often require supplemental protocols.", reference: "Zehnder M. Root canal irrigants. J Endod 2006;32:389-398", difficulty: "Easy", specialty: "Endodontics" },
  { id: 5, text: "A post-treatment disease radiograph shows a persistent periapical lesion 2 years after obturation of tooth #11. The canal appears well-obturated and dense. What is the MOST likely cause?", options: ["Inadequate canal cleaning", "Missed lateral canal", "Extraradicular infection (Actinomyces)", "Coronal microleakage"], correct: 2, explanation: "Persistent periapical lesions with technically adequate root canal treatment most commonly result from extraradicular infection — particularly Actinomyces israelii — which colonises the periapical tissues and is inaccessible to intracanal treatment. Requires surgical intervention.", reference: "Nair PN. Pathogenesis of apical periodontitis. Crit Rev Oral Biol Med 2004;15:348-381", difficulty: "Hard", specialty: "Endodontics" },
];

type Mode = "exam" | "study";
type QuizState = "active" | "review" | "results";

export default function Quiz() {
  const { id } = useParams();
  const nav = useNavigate();

  const [mode, setMode] = useState<Mode>("study");
  const [quizState, setQuizState] = useState<QuizState>("active");
  const [qIdx, setQIdx] = useState(0);
  const [answers, setAnswers] = useState<Record<number, number>>({});
  const [flagged, setFlagged] = useState<number[]>([]);
  const [showExplanation, setShowExplanation] = useState(false);
  const [timeLeft, setTimeLeft] = useState(300); // 5 min total
  const [qs, setQs] = useState(questions);

  const q = qs[qIdx];
  const answered = answers[q.id] !== undefined;
  const isCorrect = answers[q.id] === q.correct;
  const score = Object.entries(answers).filter(([qid, ans]) => {
    const question = qs.find((q) => q.id === parseInt(qid));
    return question && ans === question.correct;
  }).length;

  const submitAnswer = (optIdx: number) => {
    if (mode === "exam" && answered) return;
    setAnswers({ ...answers, [q.id]: optIdx });
    if (mode === "study") setShowExplanation(true);
  };

  const finish = () => setQuizState("results");

  const diffColor: Record<string, string> = { Easy: "#2D9B68", Medium: brand.amber, Hard: brand.red };

  if (quizState === "results") {
    const pct = Math.round((score / qs.length) * 100);
    const passed = pct >= 70;
    return (
      <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
        <div style={{ maxWidth: 720, margin: "0 auto", padding: "40px 24px", textAlign: "center" as const }}>
          <div style={{ width: 88, height: 88, borderRadius: "50%", background: passed ? "rgba(45,155,104,0.1)" : "rgba(217,45,58,0.1)", border: `3px solid ${passed ? "#2D9B68" : brand.red}`, display: "flex", alignItems: "center", justifyContent: "center", margin: "0 auto 20px" }}>
            {passed ? <CheckCircle size={42} color="#2D9B68" /> : <X size={42} color={brand.red} />}
          </div>
          <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 30, color: brand.charcoal, marginBottom: 8 }}>{passed ? "Quiz Passed!" : "Keep Practising"}</h2>
          <p style={{ fontFamily: "Inter", fontSize: 15, color: brand.warmGray, marginBottom: 28 }}>You scored {score} out of {qs.length} — {pct}%</p>

          {/* Score ring */}
          <div style={{ display: "flex", gap: 20, justifyContent: "center", marginBottom: 28, flexWrap: "wrap" }}>
            {[
              { label: "Score", value: `${pct}%`, color: passed ? "#2D9B68" : brand.red },
              { label: "Correct", value: String(score), color: "#2D9B68" },
              { label: "Incorrect", value: String(qs.length - score), color: brand.red },
              { label: "Pass Mark", value: "70%", color: brand.charcoal },
            ].map((s) => (
              <div key={s.label} style={{ background: brand.white, border: `1px solid ${brand.borderGray}`, borderRadius: 16, padding: "18px 24px", textAlign: "center" as const, minWidth: 90 }}>
                <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 26, color: s.color }}>{s.value}</div>
                <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginTop: 4 }}>{s.label}</div>
              </div>
            ))}
          </div>

          {/* Question review */}
          <div style={{ textAlign: "left" as const, marginBottom: 24 }}>
            {qs.map((question, i) => {
              const ans = answers[question.id];
              const correct = ans === question.correct;
              return (
                <div key={question.id} style={{ background: brand.white, borderRadius: 16, border: `1px solid ${correct ? "rgba(45,155,104,0.25)" : "rgba(255,45,50,0.25)"}`, padding: "16px 18px", marginBottom: 10 }}>
                  <div style={{ display: "flex", gap: 10, alignItems: "flex-start" }}>
                    <div style={{ width: 22, height: 22, borderRadius: "50%", background: correct ? "rgba(45,155,104,0.12)" : "rgba(255,45,50,0.12)", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                      {correct ? <CheckCircle size={13} color="#2D9B68" /> : <X size={13} color={brand.red} />}
                    </div>
                    <div>
                      <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal, marginBottom: 4 }}>Q{i + 1}: {question.text.substring(0, 80)}…</div>
                      <div style={{ fontFamily: "Inter", fontSize: 12, color: "#2D9B68" }}>✓ {question.options[question.correct]}</div>
                      {!correct && ans !== undefined && <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.red }}>✗ Your answer: {question.options[ans]}</div>}
                    </div>
                  </div>
                </div>
              );
            })}
          </div>

          <div style={{ display: "flex", gap: 12, justifyContent: "center", flexWrap: "wrap" }}>
            <button onClick={() => { setAnswers({}); setQIdx(0); setShowExplanation(false); setQuizState("active"); }} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.charcoal, background: brand.white, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 22px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}>
              <RotateCcw size={14} /> Retake Quiz
            </button>
            <button onClick={() => nav(`/courses/${id}`)} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "12px 24px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}>
              Back to Course <ArrowRight size={14} />
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Top bar */}
      <div style={{ background: brand.white, borderBottom: `1px solid ${brand.borderGray}`, position: "sticky", top: 0, zIndex: 50 }}>
        <div style={{ maxWidth: 900, margin: "0 auto", padding: "0 24px", height: 56, display: "flex", alignItems: "center", gap: 14 }}>
          <button onClick={() => nav(`/courses/${id}`)} style={{ background: "none", border: "none", cursor: "pointer", color: brand.warmGray, display: "flex", alignItems: "center", gap: 5, fontFamily: "Inter", fontSize: 13 }}>
            <ChevronLeft size={15} /> Exit
          </button>
          <div style={{ height: 20, width: 1, background: brand.borderGray }} />
          <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal }}>Quiz · {qs.length} Questions</div>
          {/* Mode */}
          <div style={{ display: "flex", background: brand.offWhite, border: `1px solid ${brand.borderGray}`, borderRadius: 8, overflow: "hidden" }}>
            {(["study", "exam"] as const).map((m) => (
              <button key={m} onClick={() => { setMode(m); setAnswers({}); setQIdx(0); setShowExplanation(false); }}
                style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 12, color: mode === m ? "#fff" : brand.charcoal, background: mode === m ? gradientFlow : "transparent", border: "none", padding: "6px 14px", cursor: "pointer", textTransform: "capitalize" as const }}>
                {m === "study" ? "Study Mode" : "Exam Mode"}
              </button>
            ))}
          </div>
          <div style={{ flex: 1 }} />
          {mode === "exam" && (
            <div style={{ display: "flex", alignItems: "center", gap: 5, fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.red }}>
              <Clock size={14} /> {Math.floor(timeLeft / 60)}:{String(timeLeft % 60).padStart(2, "0")}
            </div>
          )}
          <button onClick={finish} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 8, padding: "7px 14px", cursor: "pointer" }}>
            Finish Quiz
          </button>
        </div>
        {/* Progress bar */}
        <div style={{ height: 3, background: brand.borderGray }}>
          <div style={{ height: "100%", width: `${((qIdx + 1) / qs.length) * 100}%`, background: gradientFlow, transition: "width 0.3s" }} />
        </div>
      </div>

      <div style={{ maxWidth: 900, margin: "0 auto", padding: "32px 24px", display: "flex", gap: 24 }}>
        {/* Question */}
        <div style={{ flex: 1 }}>
          {/* Q header */}
          <div style={{ display: "flex", gap: 10, alignItems: "center", marginBottom: 16 }}>
            <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.warmGray }}>Q{qIdx + 1} of {qs.length}</div>
            <span style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 700, color: diffColor[q.difficulty], background: `${diffColor[q.difficulty]}15`, borderRadius: 5, padding: "2px 8px" }}>{q.difficulty}</span>
            <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{q.specialty}</span>
            <button onClick={() => setFlagged((prev) => prev.includes(q.id) ? prev.filter((f) => f !== q.id) : [...prev, q.id])}
              style={{ background: "none", border: "none", cursor: "pointer", color: flagged.includes(q.id) ? brand.amber : brand.borderGray, marginLeft: "auto" }}>
              <Flag size={16} fill={flagged.includes(q.id) ? brand.amber : "none"} />
            </button>
          </div>

          {/* Question text */}
          <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px 26px", marginBottom: 16 }}>
            <p style={{ fontFamily: "Inter", fontSize: 16, color: brand.charcoal, lineHeight: 1.65, margin: 0 }}>{q.text}</p>
          </div>

          {/* Options */}
          <div style={{ display: "flex", flexDirection: "column" as const, gap: 10, marginBottom: 20 }}>
            {q.options.map((opt, i) => {
              let bg = brand.white;
              let border = brand.borderGray;
              let color = brand.charcoal;
              let icon = null;
              if (answered) {
                if (i === q.correct) { bg = "rgba(45,155,104,0.06)"; border = "#2D9B68"; color = "#2D9B68"; icon = <CheckCircle size={14} color="#2D9B68" />; }
                else if (i === answers[q.id] && i !== q.correct) { bg = "rgba(255,45,50,0.06)"; border = brand.red; color = brand.red; icon = <X size={14} color={brand.red} />; }
              } else if (answers[q.id] === i) { bg = "rgba(255,107,26,0.06)"; border = brand.orange; }

              return (
                <button key={i} onClick={() => submitAnswer(i)}
                  style={{ fontFamily: "Inter", fontSize: 14, color, background: bg, border: `1.5px solid ${border}`, borderRadius: 12, padding: "14px 18px", cursor: answered && mode === "exam" ? "default" : "pointer", textAlign: "left" as const, display: "flex", alignItems: "center", gap: 10, transition: "all 0.15s" }}>
                  <span style={{ fontWeight: 700, flexShrink: 0 }}>{String.fromCharCode(65 + i)}.</span>
                  <span style={{ flex: 1 }}>{opt}</span>
                  {icon}
                </button>
              );
            })}
          </div>

          {/* Explanation */}
          {(showExplanation || (answered && mode === "study")) && (
            <div style={{ background: isCorrect ? "rgba(45,155,104,0.05)" : "rgba(255,45,50,0.04)", border: `1px solid ${isCorrect ? "rgba(45,155,104,0.2)" : "rgba(255,45,50,0.2)"}`, borderRadius: 16, padding: "18px 20px", marginBottom: 16 }}>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: isCorrect ? "#2D9B68" : brand.red, marginBottom: 8 }}>
                {isCorrect ? "✓ Correct!" : "✗ Incorrect — Here's why:"}
              </div>
              <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.charcoal, lineHeight: 1.65, marginBottom: 10 }}>{q.explanation}</p>
              <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, fontStyle: "italic" }}>
                📎 {q.reference}
              </div>
            </div>
          )}

          {/* Navigation */}
          <div style={{ display: "flex", justifyContent: "space-between" }}>
            <button onClick={() => { setQIdx(Math.max(0, qIdx - 1)); setShowExplanation(false); }}
              disabled={qIdx === 0}
              style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 14, color: qIdx === 0 ? brand.borderGray : brand.charcoal, background: "none", border: `1.5px solid ${qIdx === 0 ? brand.borderGray : brand.borderGray}`, borderRadius: 12, padding: "11px 20px", cursor: qIdx === 0 ? "default" : "pointer", display: "flex", alignItems: "center", gap: 6 }}>
              <ChevronLeft size={15} /> Previous
            </button>
            {qIdx < qs.length - 1 ? (
              <button onClick={() => { setQIdx(qIdx + 1); setShowExplanation(false); }}
                style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "11px 22px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}>
                Next <ChevronRight size={15} />
              </button>
            ) : (
              <button onClick={finish}
                style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: "#2D9B68", border: "none", borderRadius: 12, padding: "11px 22px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}>
                <BarChart2 size={15} /> View Results
              </button>
            )}
          </div>
        </div>

        {/* Question map sidebar */}
        <div style={{ width: 200, flexShrink: 0 }}>
          <div style={{ position: "sticky", top: 72 }}>
            <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.warmGray, marginBottom: 10 }}>Question Map</div>
            <div style={{ display: "grid", gridTemplateColumns: "repeat(5, 1fr)", gap: 6, marginBottom: 16 }}>
              {qs.map((question, i) => {
                const ans = answers[question.id];
                const isAns = ans !== undefined;
                const isRight = ans === question.correct;
                const isCurr = i === qIdx;
                const isFlagged = flagged.includes(question.id);
                let bg = brand.offWhite;
                let border = brand.borderGray;
                if (isCurr) { bg = brand.amber; border = brand.amber; }
                else if (isAns && mode === "study") { bg = isRight ? "rgba(45,155,104,0.15)" : "rgba(255,45,50,0.12)"; border = isRight ? "#2D9B68" : brand.red; }
                else if (isAns) { bg = brand.paleGray; border = brand.warmGray; }
                return (
                  <button key={i} onClick={() => { setQIdx(i); setShowExplanation(false); }}
                    style={{ width: "100%", aspectRatio: "1", fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: isCurr ? "#fff" : brand.charcoal, background: bg, border: `1.5px solid ${border}`, borderRadius: 6, cursor: "pointer", position: "relative" }}>
                    {i + 1}
                    {isFlagged && <div style={{ position: "absolute", top: 1, right: 1, width: 5, height: 5, borderRadius: "50%", background: brand.amber }} />}
                  </button>
                );
              })}
            </div>
            <div style={{ display: "flex", flexDirection: "column" as const, gap: 6 }}>
              {[
                { label: "Answered", count: Object.keys(answers).length, color: brand.charcoal },
                { label: "Flagged", count: flagged.length, color: brand.amber },
                { label: "Remaining", count: qs.length - Object.keys(answers).length, color: brand.warmGray },
              ].map((s) => (
                <div key={s.label} style={{ display: "flex", justifyContent: "space-between", fontFamily: "Inter", fontSize: 12 }}>
                  <span style={{ color: brand.warmGray }}>{s.label}</span>
                  <span style={{ fontWeight: 700, color: s.color }}>{s.count}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
