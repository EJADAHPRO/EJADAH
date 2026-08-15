import { useState } from "react";
import { useNavigate } from "react-router";
import {
  CheckCircle, X, ArrowRight, Star, BookOpen,
  Users, Zap, Clock, ChevronRight,
} from "lucide-react";
import { brand, gradientFlow, GradientBadge } from "@/app/shared";

const freeTests = [
  { id: "level", title: "Level Assessment", desc: "Discover your current EDLE readiness level across all subjects.", questions: 20, duration: "15 min", icon: "🎯", popular: true },
  { id: "sample", title: "Sample EDLE Exam", desc: "Representative mix of real EDLE question types — no account needed.", questions: 25, duration: "20 min", icon: "📝", popular: true },
  { id: "endodontics", title: "Endodontics Quiz", desc: "Test your endodontics knowledge with 10 high-yield questions.", questions: 10, duration: "8 min", icon: "🦷", popular: false },
  { id: "pharmacology", title: "Pharmacology Challenge", desc: "The most commonly failed EDLE subject — are you ready?", questions: 15, duration: "12 min", icon: "💊", popular: false },
  { id: "anatomy", title: "Anatomy Basics", desc: "Classic anatomy questions that appear every exam year.", questions: 10, duration: "8 min", icon: "🦴", popular: false },
  { id: "daily", title: "Daily Question", desc: "One hand-picked question every day, updated at midnight.", questions: 1, duration: "2 min", icon: "⚡", popular: false },
];

const sampleQ = {
  text: "A patient presents with a well-defined radiolucency at the apex of tooth #21. The tooth has no history of trauma and responds within normal limits to cold and electric pulp testing. The most likely diagnosis is:",
  options: ["Symptomatic apical periodontitis", "Periapical cemento-osseous dysplasia (early stage)", "Chronic apical abscess", "Lateral periodontal cyst"],
  correct: 1,
  explanation: "Early periapical cemento-osseous dysplasia (formerly cementoma) is a reactive lesion of the periapical bone that is always associated with vital teeth. In its early lytic stage it presents as a well-defined radiolucency mimicking apical pathosis, but vitality tests are always positive. No treatment is required.",
  specialty: "Oral Pathology",
};

type TestState = "browse" | "question" | "result";

export default function FreeTests() {
  const nav = useNavigate();
  const [testState, setTestState] = useState<TestState>("browse");
  const [selected, setSelected] = useState<number | null>(null);
  const [revealed, setRevealed] = useState(false);
  const [activeTest, setActiveTest] = useState("");

  const startTest = (testId: string) => {
    setActiveTest(testId);
    setTestState("question");
    setSelected(null);
    setRevealed(false);
  };

  if (testState === "result") return (
    <div style={{ background: brand.offWhite, minHeight: "100vh", display: "flex", alignItems: "center", justifyContent: "center", padding: 24 }}>
      <div style={{ maxWidth: 560, width: "100%", textAlign: "center" as const }}>
        <div style={{ width: 80, height: 80, borderRadius: "50%", background: selected === sampleQ.correct ? "rgba(45,155,104,0.1)" : "rgba(255,45,50,0.1)", border: `3px solid ${selected === sampleQ.correct ? "#2D9B68" : brand.red}`, display: "flex", alignItems: "center", justifyContent: "center", margin: "0 auto 20px" }}>
          {selected === sampleQ.correct ? <CheckCircle size={38} color="#2D9B68" /> : <X size={38} color={brand.red} />}
        </div>
        <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 28, color: brand.charcoal, marginBottom: 8 }}>
          {selected === sampleQ.correct ? "Well done!" : "Keep Practising"}
        </h2>
        <p style={{ fontFamily: "Inter", fontSize: 15, color: brand.warmGray, marginBottom: 24 }}>
          {selected === sampleQ.correct ? "You got it right. Ejadah's full question bank has 14,200+ questions with detailed explanations like this one." : "Don't worry — this is a difficult topic. The full question bank has detailed explanations to help you master it."}
        </p>
        {/* Explanation */}
        <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "20px 22px", marginBottom: 24, textAlign: "left" as const }}>
          <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: "#2D9B68", marginBottom: 8 }}>✓ Correct Answer: {sampleQ.options[sampleQ.correct]}</div>
          <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.charcoal, lineHeight: 1.7 }}>{sampleQ.explanation}</p>
        </div>
        {/* CTA */}
        <div style={{ background: brand.charcoal, borderRadius: 20, padding: "24px", marginBottom: 24, textAlign: "left" as const }}>
          <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: "#fff", marginBottom: 8 }}>Unlock 14,200+ Questions</div>
          <p style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.6)", marginBottom: 16, lineHeight: 1.6 }}>Create a free account to access the full EDLE question bank — with explanations, performance tracking, and a personalised study plan.</p>
          <div style={{ display: "flex", gap: 10 }}>
            <button onClick={() => nav("/register")} style={{ flex: 1, fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "12px", cursor: "pointer" }}>Create Free Account</button>
            <button onClick={() => nav("/exams")} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 14, color: "rgba(255,255,255,0.7)", background: "rgba(255,255,255,0.08)", border: "none", borderRadius: 10, padding: "12px 16px", cursor: "pointer" }}>Browse Exams</button>
          </div>
        </div>
        <button onClick={() => setTestState("browse")} style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, background: "none", border: "none", cursor: "pointer" }}>← Back to Free Tests</button>
      </div>
    </div>
  );

  if (testState === "question") return (
    <div style={{ background: brand.offWhite, minHeight: "100vh", display: "flex", alignItems: "center", justifyContent: "center", padding: 24 }}>
      <div style={{ maxWidth: 680, width: "100%" }}>
        <button onClick={() => setTestState("browse")} style={{ background: "none", border: "none", cursor: "pointer", color: brand.warmGray, fontFamily: "Inter", fontSize: 13, marginBottom: 20, display: "flex", alignItems: "center", gap: 5 }}>
          ← Back to Tests
        </button>
        <div style={{ background: brand.white, borderRadius: 22, border: `1px solid ${brand.borderGray}`, padding: "32px 32px", boxShadow: "0 8px 28px rgba(27,27,27,0.07)" }}>
          <div style={{ display: "flex", gap: 10, marginBottom: 18 }}>
            <GradientBadge small>{sampleQ.specialty}</GradientBadge>
            <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, display: "flex", alignItems: "center", gap: 4 }}><Clock size={11} /> 2 min</span>
          </div>
          <p style={{ fontFamily: "Inter", fontSize: 16, color: brand.charcoal, lineHeight: 1.7, marginBottom: 22 }}>{sampleQ.text}</p>
          <div style={{ display: "flex", flexDirection: "column" as const, gap: 10, marginBottom: 22 }}>
            {sampleQ.options.map((opt, i) => {
              let bg = brand.offWhite, border = brand.borderGray, color = brand.charcoal;
              if (revealed) {
                if (i === sampleQ.correct) { bg = "rgba(45,155,104,0.06)"; border = "#2D9B68"; color = "#2D9B68"; }
                else if (i === selected && i !== sampleQ.correct) { bg = "rgba(255,45,50,0.06)"; border = brand.red; color = brand.red; }
              } else if (selected === i) { bg = "rgba(255,107,26,0.06)"; border = brand.orange; }
              return (
                <button key={i} onClick={() => !revealed && setSelected(i)}
                  style={{ fontFamily: "Inter", fontSize: 14, color, background: bg, border: `1.5px solid ${border}`, borderRadius: 12, padding: "14px 18px", cursor: revealed ? "default" : "pointer", textAlign: "left" as const, display: "flex", alignItems: "center", gap: 10, transition: "all 0.15s" }}>
                  <span style={{ fontWeight: 700 }}>{String.fromCharCode(65 + i)}.</span>
                  <span style={{ flex: 1 }}>{opt}</span>
                  {revealed && i === sampleQ.correct && <CheckCircle size={14} color="#2D9B68" />}
                  {revealed && i === selected && i !== sampleQ.correct && <X size={14} color={brand.red} />}
                </button>
              );
            })}
          </div>
          {!revealed && selected !== null && (
            <button onClick={() => { setRevealed(true); }} style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "14px", cursor: "pointer" }}>
              Submit Answer
            </button>
          )}
          {revealed && (
            <button onClick={() => setTestState("result")} style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: "#fff", background: "#2D9B68", border: "none", borderRadius: 12, padding: "14px", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 8 }}>
              See Full Explanation <ArrowRight size={15} />
            </button>
          )}
        </div>
      </div>
    </div>
  );

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Hero */}
      <div style={{ background: brand.charcoal, padding: "56px 24px 48px", position: "relative", overflow: "hidden" }}>
        <div style={{ position: "absolute", inset: 0, background: `radial-gradient(ellipse at 65% 40%, rgba(255,198,46,0.08) 0%, transparent 55%)`, pointerEvents: "none" }} />
        <div style={{ maxWidth: 1280, margin: "0 auto", position: "relative" }}>
          <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, letterSpacing: "0.1em", color: brand.gold, textTransform: "uppercase" as const, marginBottom: 10 }}>No Account Required</div>
          <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(28px,4vw,44px)", color: "#fff", marginBottom: 14 }}>Free Dental Tests</h1>
          <p style={{ fontFamily: "Inter", fontSize: 16, color: "rgba(255,255,255,0.6)", maxWidth: 520, marginBottom: 28 }}>
            Try before you subscribe. Free sample questions, level assessment, and daily challenges — available to everyone, no login required.
          </p>
          <div style={{ display: "flex", gap: 28, flexWrap: "wrap" }}>
            {[["100% Free", "No credit card"], ["Instant Results", "See your score immediately"], ["Real Questions", "From the actual EDLE bank"], ["Expert Explanations", "After every answer"]].map(([v, l]) => (
              <div key={l}><div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: brand.gold }}>{v}</div><div style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.45)", marginTop: 2 }}>{l}</div></div>
            ))}
          </div>
        </div>
      </div>

      <div style={{ maxWidth: 1280, margin: "0 auto", padding: "40px 24px" }}>
        {/* Daily Question highlight */}
        <div style={{ background: `linear-gradient(135deg, rgba(255,107,26,0.08), rgba(255,198,46,0.08))`, border: `1px solid ${brand.amber}25`, borderRadius: 22, padding: "28px 28px", marginBottom: 40, display: "flex", gap: 24, alignItems: "center", flexWrap: "wrap" }}>
          <div style={{ fontSize: 40 }}>⚡</div>
          <div style={{ flex: 1 }}>
            <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.orange, marginBottom: 4 }}>TODAY'S DAILY QUESTION</div>
            <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal, marginBottom: 4 }}>Oral Pathology · Periapical Lesions</div>
            <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray }}>Updated every day at midnight · 14,280 people answered today</div>
          </div>
          <button onClick={() => startTest("daily")} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "13px 24px", cursor: "pointer", display: "flex", alignItems: "center", gap: 8, flexShrink: 0, boxShadow: "0 4px 14px rgba(255,107,26,0.3)" }}>
            Answer Now <ArrowRight size={15} />
          </button>
        </div>

        {/* Test grid */}
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(300px, 1fr))", gap: 18 }}>
          {freeTests.map((test) => (
            <div key={test.id} style={{ background: brand.white, borderRadius: 22, border: `1px solid ${brand.borderGray}`, padding: "24px 22px", position: "relative", transition: "transform 0.2s, box-shadow 0.2s", cursor: "pointer" }}
              onMouseEnter={(e) => { (e.currentTarget as HTMLElement).style.transform = "translateY(-4px)"; (e.currentTarget as HTMLElement).style.boxShadow = "0 10px 28px rgba(27,27,27,0.08)"; }}
              onMouseLeave={(e) => { (e.currentTarget as HTMLElement).style.transform = "none"; (e.currentTarget as HTMLElement).style.boxShadow = "none"; }}
            >
              {test.popular && (
                <div style={{ position: "absolute", top: 16, right: 16, background: gradientFlow, color: "#fff", fontFamily: "Inter", fontWeight: 700, fontSize: 10, borderRadius: 6, padding: "3px 8px" }}>POPULAR</div>
              )}
              <div style={{ fontSize: 36, marginBottom: 14 }}>{test.icon}</div>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal, marginBottom: 6 }}>{test.title}</div>
              <p style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, lineHeight: 1.6, marginBottom: 16 }}>{test.desc}</p>
              <div style={{ display: "flex", gap: 16, marginBottom: 18 }}>
                <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, display: "flex", alignItems: "center", gap: 4 }}>
                  <BookOpen size={12} /> {test.questions} question{test.questions > 1 ? "s" : ""}
                </span>
                <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, display: "flex", alignItems: "center", gap: 4 }}>
                  <Clock size={12} /> {test.duration}
                </span>
              </div>
              <button onClick={() => startTest(test.id)} style={{ width: "100%", fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "12px", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 8 }}>
                Start Free <ChevronRight size={14} />
              </button>
            </div>
          ))}
        </div>

        {/* Sign up nudge */}
        <div style={{ marginTop: 48, background: brand.charcoal, borderRadius: 24, padding: "36px 32px", display: "flex", gap: 28, alignItems: "center", flexWrap: "wrap" }}>
          <div style={{ flex: 1 }}>
            <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 24, color: "#fff", marginBottom: 8 }}>Ready for the full experience?</div>
            <p style={{ fontFamily: "Inter", fontSize: 14, color: "rgba(255,255,255,0.6)", maxWidth: 500, lineHeight: 1.6 }}>
              Create a free account to unlock 14,200+ EDLE questions, mock exams, performance tracking, and your personalised study plan.
            </p>
          </div>
          <div style={{ display: "flex", gap: 10, flexShrink: 0 }}>
            <button onClick={() => nav("/register")} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "13px 24px", cursor: "pointer" }}>Create Free Account</button>
            <button onClick={() => nav("/exams")} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 14, color: "rgba(255,255,255,0.6)", background: "rgba(255,255,255,0.08)", border: "none", borderRadius: 12, padding: "13px 20px", cursor: "pointer" }}>View All Exams</button>
          </div>
        </div>
      </div>
    </div>
  );
}
