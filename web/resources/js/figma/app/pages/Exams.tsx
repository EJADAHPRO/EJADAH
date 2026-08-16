import { useState } from "react";
import { useNavigate } from "react-router";
import { CheckCircle, Clock, Target, TrendingUp, BookOpen, ArrowRight, Play } from "lucide-react";
import { brand, gradientFlow, gradientGlow, GradientBadge, SectionHeader } from "@/figma/app/shared";

const exams = [
  { id: "edle", name: "Egyptian Dental Licensing Exam", short: "EDLE", flag: "🇪🇬", questions: 14200, freeQs: 200, subjects: 16, difficulty: "High", description: "The official Egyptian dental licensing examination — comprehensive question bank covering all subjects tested by the Egyptian Ministry of Health." },
  { id: "inbde", name: "International Board Dental Examination", short: "INBDE", flag: "🇺🇸", questions: 8500, freeQs: 100, subjects: 12, difficulty: "Very High", description: "The US national dental board examination for dental school graduates seeking licensure in the United States." },
  { id: "ore", name: "Overseas Registration Exam", short: "ORE", flag: "🇬🇧", questions: 6200, freeQs: 80, subjects: 10, difficulty: "High", description: "The General Dental Council exam for internationally qualified dentists seeking registration in the UK." },
  { id: "adc", name: "Australian Dental Council", short: "ADC", flag: "🇦🇺", questions: 4800, freeQs: 60, subjects: 9, difficulty: "High", description: "Assessment for internationally trained dental practitioners seeking registration in Australia." },
  { id: "prometric", name: "Prometric Exams", short: "DHA/DOH/MOH", flag: "🇦🇪", questions: 9000, freeQs: 150, subjects: 14, difficulty: "Medium", description: "Prometric-based licensing exams for DHA (Dubai), DOH (Abu Dhabi), and MOH (Saudi Arabia)." },
  { id: "ndeb", name: "National Dental Board Canada", short: "NDEB", flag: "🇨🇦", questions: 5100, freeQs: 70, subjects: 11, difficulty: "High", description: "The National Dental Examining Board of Canada assessment for internationally trained dentists." },
];

const difficultyColor: Record<string, string> = { "Medium": brand.amber, "High": brand.orange, "Very High": brand.red };

function ExamCard({ exam, onStart }: { exam: typeof exams[0]; onStart: () => void }) {
  const nav = useNavigate();
  return (
    <div style={{ background: brand.white, borderRadius: 22, border: `1px solid ${brand.borderGray}`, padding: "28px 24px", cursor: "pointer", transition: "transform 0.2s, box-shadow 0.2s" }}
      onMouseEnter={(e) => { (e.currentTarget as HTMLElement).style.transform = "translateY(-5px)"; (e.currentTarget as HTMLElement).style.boxShadow = "0 12px 32px rgba(27,27,27,0.1)"; }}
      onMouseLeave={(e) => { (e.currentTarget as HTMLElement).style.transform = "none"; (e.currentTarget as HTMLElement).style.boxShadow = "none"; }}
    >
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 16 }}>
        <div style={{ fontSize: 36 }}>{exam.flag}</div>
        <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: difficultyColor[exam.difficulty], background: `${difficultyColor[exam.difficulty]}12`, borderRadius: 8, padding: "4px 10px" }}>{exam.difficulty}</span>
      </div>
      <div style={{ fontFamily: "Inter", fontWeight: 800, fontSize: 22, color: brand.gold, marginBottom: 4 }}>{exam.short}</div>
      <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.charcoal, marginBottom: 8, lineHeight: 1.3 }}>{exam.name}</div>
      <p style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, lineHeight: 1.55, marginBottom: 20 }}>{exam.description}</p>
      <div style={{ display: "flex", gap: 20, marginBottom: 20 }}>
        <div>
          <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal }}>{exam.questions.toLocaleString()}</div>
          <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>Questions</div>
        </div>
        <div>
          <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal }}>{exam.subjects}</div>
          <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>Subjects</div>
        </div>
        <div>
          <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.orange }}>{exam.freeQs}</div>
          <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>Free Qs</div>
        </div>
      </div>
      <div style={{ display: "flex", gap: 8 }}>
        <button onClick={onStart} style={{ flex: 1, fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "11px", cursor: "pointer" }}>Start Preparing</button>
        <button onClick={() => nav("/exams/free")} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 13, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 10, padding: "11px 16px", cursor: "pointer" }}>Free Test</button>
      </div>
    </div>
  );
}

function QuickPractice() {
  const [selected, setSelected] = useState<number | null>(null);
  const [revealed, setRevealed] = useState(false);
  const question = {
    text: "A 35-year-old patient presents with severe throbbing pain, tenderness to percussion, and a periapical radiolucency on tooth #36. Vitality testing shows no response. What is the most likely diagnosis?",
    options: ["Irreversible pulpitis", "Symptomatic apical periodontitis with necrotic pulp", "Acute alveolar abscess", "Chronic periapical abscess with sinus tract"],
    correct: 1,
    explanation: "The combination of pain, tenderness to percussion, periapical radiolucency, and negative vitality test is classic for symptomatic apical periodontitis associated with a necrotic pulp. The absence of a sinus tract and the presence of pain distinguish this from a chronic abscess.",
  };

  return (
    <div style={{ background: brand.white, borderRadius: 24, border: `1px solid ${brand.borderGray}`, padding: "28px", marginBottom: 24 }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 20 }}>
        <div>
          <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, letterSpacing: "0.1em", color: brand.orange, textTransform: "uppercase" as const, marginBottom: 6 }}>Daily Question</div>
          <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>Endodontics · Medium</div>
        </div>
        <div style={{ display: "flex", alignItems: "center", gap: 5, fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}><Clock size={13} /> Timed: 2:00</div>
      </div>
      <p style={{ fontFamily: "Inter", fontSize: 15, color: brand.charcoal, lineHeight: 1.65, marginBottom: 20 }}>{question.text}</p>
      <div style={{ display: "flex", flexDirection: "column" as const, gap: 10, marginBottom: 20 }}>
        {question.options.map((opt, i) => {
          const isCorrect = i === question.correct;
          const isSelected = selected === i;
          let bg = brand.offWhite;
          let border = brand.borderGray;
          let color = brand.charcoal;
          if (revealed) {
            if (isCorrect) { bg = "rgba(45,155,104,0.08)"; border = "#2D9B68"; color = "#2D9B68"; }
            else if (isSelected && !isCorrect) { bg = "rgba(217,45,58,0.08)"; border = brand.red; color = brand.red; }
          } else if (isSelected) {
            bg = "rgba(255,107,26,0.08)"; border = brand.orange;
          }
          return (
            <button key={opt} onClick={() => !revealed && setSelected(i)} style={{ fontFamily: "Inter", fontWeight: 400, fontSize: 14, color, background: bg, border: `1.5px solid ${border}`, borderRadius: 10, padding: "13px 16px", cursor: revealed ? "default" : "pointer", textAlign: "left" as const, transition: "all 0.15s" }}>
              <span style={{ fontWeight: 600, marginRight: 10 }}>{String.fromCharCode(65 + i)}.</span>{opt}
            </button>
          );
        })}
      </div>
      {!revealed && selected !== null && (
        <button onClick={() => setRevealed(true)} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "12px 24px", cursor: "pointer" }}>Submit Answer</button>
      )}
      {revealed && (
        <div style={{ background: "rgba(45,155,104,0.06)", border: "1px solid rgba(45,155,104,0.2)", borderRadius: 12, padding: "16px 18px" }}>
          <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: "#2D9B68", marginBottom: 8 }}>✓ Explanation</div>
          <p style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, lineHeight: 1.6 }}>{question.explanation}</p>
        </div>
      )}
    </div>
  );
}

export default function Exams() {
  const nav = useNavigate();

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Header */}
      <div style={{ background: `linear-gradient(135deg, ${brand.deepCharcoal} 0%, #1e1a17 100%)`, padding: "56px 24px 48px", position: "relative", overflow: "hidden" }}>
        <div style={{ position: "absolute", inset: 0, background: "radial-gradient(ellipse at 70% 50%, rgba(255,198,46,0.07) 0%, transparent 60%)", pointerEvents: "none" }} />
        <div style={{ maxWidth: 1280, margin: "0 auto", position: "relative" }}>
          <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, letterSpacing: "0.1em", color: brand.amber, textTransform: "uppercase" as const, marginBottom: 10 }}>Exam Preparation</div>
          <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(28px,4vw,44px)", color: "#fff", marginBottom: 14 }}>Prepare for Every Licensing Exam</h1>
          <p style={{ fontFamily: "Inter", fontSize: 16, color: "rgba(255,255,255,0.6)", maxWidth: 560, marginBottom: 28 }}>Question banks, mock exams, AI-powered explanations, and personalized study plans for every major dental licensing exam worldwide.</p>
          <div style={{ display: "flex", gap: 32, flexWrap: "wrap" }}>
            {[["47,800+", "Total Questions"], ["11", "Exams Covered"], ["92%", "Pass Rate"], ["50,000+", "Students Passed"]].map(([v, l]) => (
              <div key={l}>
                <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 26, color: brand.gold }}>{v}</div>
                <div style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.45)" }}>{l}</div>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div style={{ maxWidth: 1280, margin: "0 auto", padding: "40px 24px" }}>
        {/* Daily question */}
        <div style={{ display: "flex", gap: 32, flexWrap: "wrap", marginBottom: 40 }}>
          <div style={{ flex: "1 1 520px" }}>
            <SectionHeader label="Practice" title="Try a Question" />
            <QuickPractice />
          </div>
          {/* Performance snapshot */}
          <div style={{ flex: "0 1 280px" }}>
            <SectionHeader label="Your Stats" title="Performance" />
            <div style={{ background: brand.white, borderRadius: 22, border: `1px solid ${brand.borderGray}`, padding: 24 }}>
              {[["Questions Attempted", "324", brand.charcoal], ["Correct Answers", "78%", "#2D9B68"], ["Weakest Subject", "Pharmacology", brand.red], ["Study Streak", "12 days 🔥", brand.amber]].map(([label, value, color]) => (
                <div key={label as string} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "10px 0", borderBottom: `1px solid ${brand.borderGray}` }}>
                  <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray }}>{label as string}</span>
                  <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: color as string }}>{value as string}</span>
                </div>
              ))}
              <button style={{ width: "100%", marginTop: 16, fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "11px", cursor: "pointer" }}>
                View Full Analytics
              </button>
            </div>
          </div>
        </div>

        {/* Exam cards */}
        <SectionHeader label="All Exams" title="Choose Your Exam" />
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(300px, 1fr))", gap: 20 }}>
          {exams.map((exam) => (
            <ExamCard key={exam.id} exam={exam} onStart={() => nav(exam.id === "edle" ? "/exams/edle" : "/exams/edle/practice")} />
          ))}
        </div>
      </div>
    </div>
  );
}
