import { useNavigate } from "react-router";
import { ChevronLeft, TrendingUp, TrendingDown, Target, ArrowRight, Zap, BarChart2 } from "lucide-react";
import { brand, gradientFlow } from "@/figma/app/shared";

const gradientGlow = `linear-gradient(135deg, ${brand.orange} 0%, ${brand.amber} 60%, ${brand.gold} 100%)`;

const subjectData = [
  { name: "Endodontics",                    done: 510, total: 880,  correct: 88, trend: "up" },
  { name: "Oral & Maxillofacial Surgery",   done: 390, total: 1060, correct: 83, trend: "up" },
  { name: "Dental Biomaterials",            done: 400, total: 940,  correct: 80, trend: "stable" },
  { name: "Oral Biology & Histology",       done: 160, total: 540,  correct: 80, trend: "stable" },
  { name: "Anatomy",                        done: 612, total: 1820, correct: 78, trend: "up" },
  { name: "Oral Pathology",                 done: 380, total: 920,  correct: 76, trend: "stable" },
  { name: "Oral Radiology",                 done: 200, total: 480,  correct: 77, trend: "up" },
  { name: "Periodontology & Oral Medicine", done: 550, total: 1400, correct: 74, trend: "up" },
  { name: "Operative Dentistry",            done: 310, total: 820,  correct: 74, trend: "stable" },
  { name: "Microbiology",                   done: 210, total: 680,  correct: 74, trend: "up" },
  { name: "Fixed Prosthodontics",           done: 180, total: 680,  correct: 71, trend: "stable" },
  { name: "Removable Prosthodontics",       done: 140, total: 560,  correct: 69, trend: "stable" },
  { name: "Pediatric Dentistry",            done: 120, total: 520,  correct: 72, trend: "stable" },
  { name: "Implant Dentistry",              done: 180, total: 440,  correct: 79, trend: "up" },
  { name: "Orthodontics",                   done: 180, total: 680,  correct: 66, trend: "down" },
  { name: "Biochemistry",                   done: 180, total: 760,  correct: 65, trend: "down" },
  { name: "Pharmacology",                   done: 290, total: 1100, correct: 58, trend: "down" },
  { name: "Aesthetic Dentistry",            done: 120, total: 360,  correct: 75, trend: "stable" },
  { name: "Digital Dentistry",              done:  80, total: 280,  correct: 70, trend: "stable" },
];

const weeklyData = [
  { day: "Mon", score: 74, questions: 50 },
  { day: "Tue", score: 68, questions: 40 },
  { day: "Wed", score: 71, questions: 60 },
  { day: "Thu", score: 79, questions: 50 },
  { day: "Fri", score: 76, questions: 35 },
  { day: "Sat", score: 82, questions: 80 },
  { day: "Sun", score: 78, questions: 45 },
];

const strengthSubjects = subjectData.filter((s) => s.correct >= 80).slice(0, 4);
const weakSubjects = subjectData.filter((s) => s.correct < 70).slice(0, 4);

export default function ExamAnalytics() {
  const nav = useNavigate();
  const avgScore = Math.round(subjectData.reduce((a, s) => a + s.correct, 0) / subjectData.length);
  const totalDone = subjectData.reduce((a, s) => a + s.done, 0);
  const totalQs = subjectData.reduce((a, s) => a + s.total, 0);
  const maxWeeklyScore = Math.max(...weeklyData.map((d) => d.score));

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Header */}
      <div style={{ background: `linear-gradient(135deg, ${brand.deepCharcoal} 0%, #1a1714 100%)`, padding: "48px 24px 40px" }}>
        <div style={{ maxWidth: 1280, margin: "0 auto" }}>
          <button onClick={() => nav("/exams/edle")} style={{ background: "none", border: "none", cursor: "pointer", color: "rgba(255,255,255,0.5)", fontFamily: "Inter", fontSize: 13, display: "flex", alignItems: "center", gap: 5, marginBottom: 16 }}>
            <ChevronLeft size={15} /> EDLE Dashboard
          </button>
          <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(24px,3.5vw,36px)", color: "#fff", marginBottom: 8 }}>Performance Analytics</h1>
          <p style={{ fontFamily: "Inter", fontSize: 14, color: "rgba(255,255,255,0.5)" }}>Based on {totalDone.toLocaleString()} questions answered across 16 EDLE subjects</p>
          {/* Top stats */}
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(160px, 1fr))", gap: 14, marginTop: 24 }}>
            {[
              { label: "Average Score", value: `${avgScore}%`, color: avgScore >= 70 ? "#2D9B68" : brand.amber, sub: "Across all subjects" },
              { label: "Questions Done", value: totalDone.toLocaleString(), color: brand.gold, sub: `of ${totalQs.toLocaleString()} total` },
              { label: "Readiness Score", value: "71%", color: brand.orange, sub: "Estimated exam readiness" },
              { label: "Study Streak", value: "12 days 🔥", color: brand.amber, sub: "Keep it up!" },
              { label: "Predicted Pass", value: "85%", color: "#2D9B68", sub: "Probability at current rate" },
            ].map((s) => (
              <div key={s.label} style={{ background: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.08)", borderRadius: 16, padding: "16px 16px" }}>
                <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: s.color }}>{s.value}</div>
                <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: "#fff", marginTop: 3 }}>{s.label}</div>
                <div style={{ fontFamily: "Inter", fontSize: 11, color: "rgba(255,255,255,0.4)", marginTop: 2 }}>{s.sub}</div>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div style={{ maxWidth: 1280, margin: "0 auto", padding: "32px 24px" }}>
        <div style={{ display: "flex", gap: 24, flexWrap: "wrap" }}>
          {/* Left column */}
          <div style={{ flex: 1, minWidth: 300 }}>
            {/* Weekly performance chart */}
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px", marginBottom: 20 }}>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 6 }}>Weekly Performance</div>
              <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, marginBottom: 20 }}>Last 7 days · {weeklyData.reduce((a, d) => a + d.questions, 0)} questions</div>
              <div style={{ display: "flex", gap: 8, alignItems: "flex-end", height: 140 }}>
                {weeklyData.map((d) => {
                  const height = (d.score / 100) * 120;
                  const isGood = d.score >= 70;
                  return (
                    <div key={d.day} style={{ flex: 1, display: "flex", flexDirection: "column" as const, alignItems: "center", gap: 6 }}>
                      <div style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 700, color: isGood ? "#2D9B68" : brand.red }}>{d.score}%</div>
                      <div style={{ width: "100%", height: height, background: isGood ? gradientFlow : brand.red, borderRadius: "6px 6px 0 0", opacity: d.day === "Sat" ? 1 : 0.75, transition: "height 0.4s ease", position: "relative" }}>
                        <div style={{ position: "absolute", bottom: -1, left: 0, right: 0, height: 2, background: "rgba(0,0,0,0.1)", borderRadius: 1 }} />
                      </div>
                      <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{d.day}</div>
                      <div style={{ fontFamily: "Inter", fontSize: 10, color: brand.borderGray }}>{d.questions}q</div>
                    </div>
                  );
                })}
              </div>
              {/* Pass mark line label */}
              <div style={{ display: "flex", alignItems: "center", gap: 8, marginTop: 10, paddingTop: 10, borderTop: `1px solid ${brand.borderGray}` }}>
                <div style={{ width: 20, height: 2, background: brand.red, borderRadius: 1 }} />
                <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>70% pass mark</span>
              </div>
            </div>

            {/* Subject breakdown */}
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px" }}>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 20 }}>Subject Breakdown</div>
              <div style={{ display: "flex", flexDirection: "column" as const, gap: 10 }}>
                {subjectData.sort((a, b) => b.correct - a.correct).map((s) => {
                  const pct = Math.round((s.done / s.total) * 100);
                  const scoreColor = s.correct >= 80 ? "#2D9B68" : s.correct >= 70 ? brand.amber : brand.red;
                  return (
                    <div key={s.name} onClick={() => nav("/exams/edle/practice")} style={{ cursor: "pointer", padding: "12px 14px", borderRadius: 12, border: `1px solid ${brand.borderGray}`, background: brand.offWhite, transition: "background 0.15s" }}
                      onMouseEnter={(e) => ((e.currentTarget as HTMLElement).style.background = brand.paleGray)}
                      onMouseLeave={(e) => ((e.currentTarget as HTMLElement).style.background = brand.offWhite)}
                    >
                      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 7 }}>
                        <div style={{ display: "flex", gap: 10, alignItems: "center" }}>
                          <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal }}>{s.name}</span>
                          {s.trend === "up" && <TrendingUp size={12} color="#2D9B68" />}
                          {s.trend === "down" && <TrendingDown size={12} color={brand.red} />}
                        </div>
                        <div style={{ display: "flex", gap: 16, alignItems: "center" }}>
                          <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{s.done}/{s.total}</span>
                          <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: scoreColor }}>{s.correct}%</span>
                        </div>
                      </div>
                      <div style={{ height: 5, background: brand.borderGray, borderRadius: 3, overflow: "hidden" }}>
                        <div style={{ height: "100%", width: `${s.correct}%`, background: scoreColor === "#2D9B68" ? "#2D9B68" : scoreColor === brand.amber ? gradientGlow : brand.red, borderRadius: 3, opacity: 0.7 }} />
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          </div>

          {/* Right column */}
          <div style={{ width: 300, flexShrink: 0 }}>
            {/* Strengths */}
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "20px", marginBottom: 16 }}>
              <div style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 14 }}>
                <TrendingUp size={16} color="#2D9B68" />
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal }}>Your Strengths</div>
              </div>
              {strengthSubjects.map((s) => (
                <div key={s.name} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "9px 0", borderBottom: `1px solid ${brand.borderGray}` }}>
                  <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal }}>{s.name}</span>
                  <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#2D9B68" }}>{s.correct}%</span>
                </div>
              ))}
            </div>

            {/* Weaknesses */}
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "20px", marginBottom: 16 }}>
              <div style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 14 }}>
                <TrendingDown size={16} color={brand.red} />
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal }}>Focus Areas</div>
              </div>
              {weakSubjects.map((s) => (
                <div key={s.name} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "9px 0", borderBottom: `1px solid ${brand.borderGray}` }}>
                  <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal }}>{s.name}</span>
                  <div style={{ display: "flex", gap: 8, alignItems: "center" }}>
                    <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.red }}>{s.correct}%</span>
                    <button onClick={() => nav("/exams/edle/practice")} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 10, color: "#fff", background: brand.red, border: "none", borderRadius: 5, padding: "3px 8px", cursor: "pointer" }}>Practice</button>
                  </div>
                </div>
              ))}
            </div>

            {/* AI recommendation */}
            <div style={{ background: `linear-gradient(135deg, ${brand.charcoal}, #24201D)`, borderRadius: 20, padding: "20px", marginBottom: 16 }}>
              <div style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 12 }}>
                <Zap size={16} color={brand.amber} />
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff" }}>AI Recommendation</div>
              </div>
              <p style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.65)", lineHeight: 1.6, marginBottom: 14 }}>
                Your strongest area is Endodontics (88%) — well above pass mark. Prioritise Pharmacology and Biochemistry this week. Aim for 60 questions per day in those subjects.
              </p>
              <div style={{ background: "rgba(255,255,255,0.06)", borderRadius: 10, padding: "12px 14px", marginBottom: 14 }}>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.amber, marginBottom: 8 }}>Suggested Study Plan</div>
                {[["Today", "50 Pharmacology Qs"], ["Tomorrow", "50 Biochemistry Qs"], ["Day 3", "Mixed weak subjects"], ["Day 4–7", "Full simulation exam"]].map(([day, activity]) => (
                  <div key={day} style={{ display: "flex", justifyContent: "space-between", fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.6)", marginBottom: 5 }}>
                    <span style={{ color: "rgba(255,255,255,0.4)" }}>{day}</span>
                    <span>{activity}</span>
                  </div>
                ))}
              </div>
              <button onClick={() => nav("/exams/edle/practice")} style={{ width: "100%", fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: "#fff", background: gradientGlow, border: "none", borderRadius: 10, padding: "11px", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 6 }}>
                Start Recommended Session <ArrowRight size={13} />
              </button>
            </div>

            {/* Time analysis */}
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "20px" }}>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal, marginBottom: 14 }}>Time Analysis</div>
              {[["Avg. time per question", "45 sec"], ["Fastest subject", "Endodontics (32 sec)"], ["Slowest subject", "Pharmacology (68 sec)"], ["Time saved vs. target", "−12 sec/question"]].map(([l, v]) => (
                <div key={l} style={{ display: "flex", justifyContent: "space-between", padding: "8px 0", borderBottom: `1px solid ${brand.borderGray}`, fontFamily: "Inter", fontSize: 12 }}>
                  <span style={{ color: brand.warmGray }}>{l}</span>
                  <span style={{ fontWeight: 600, color: brand.charcoal }}>{v}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}


