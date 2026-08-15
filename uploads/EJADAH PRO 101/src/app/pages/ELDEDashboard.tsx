import { useState } from "react";
import { useNavigate } from "react-router";
import {
  BookOpen, BarChart2, Clock, Target, Zap, ArrowRight,
  CheckCircle, TrendingUp, Calendar, Users, Star, Filter,
  ChevronRight, Flame, Award,
} from "lucide-react";
import { brand, gradientFlow, gradientGlow, GradientBadge } from "@/app/shared";

const subjects = [
  { name: "Anatomy",                        total: 1820, done: 612, correct: 78, color: brand.orange },
  { name: "Physiology",                     total:  980, done: 340, correct: 71, color: brand.amber },
  { name: "Biochemistry",                   total:  760, done: 180, correct: 65, color: brand.red },
  { name: "Microbiology",                   total:  680, done: 210, correct: 74, color: brand.amber },
  { name: "Oral Biology & Histology",       total:  540, done: 160, correct: 80, color: "#2D9B68" },
  { name: "Pharmacology",                   total: 1100, done: 290, correct: 58, color: brand.red },
  { name: "Dental Biomaterials",            total:  940, done: 400, correct: 80, color: "#2D9B68" },
  { name: "Operative Dentistry",            total:  820, done: 310, correct: 74, color: brand.orange },
  { name: "Endodontics",                    total:  880, done: 510, correct: 88, color: "#2D9B68" },
  { name: "Fixed Prosthodontics",           total:  680, done: 180, correct: 71, color: brand.amber },
  { name: "Removable Prosthodontics",       total:  560, done: 140, correct: 69, color: brand.amber },
  { name: "Periodontology & Oral Medicine", total: 1400, done: 550, correct: 74, color: brand.orange },
  { name: "Oral Radiology",                 total:  480, done: 200, correct: 77, color: "#496FA8" },
  { name: "Oral Pathology",                 total:  920, done: 380, correct: 76, color: brand.orange },
  { name: "Oral & Maxillofacial Surgery",   total: 1060, done: 390, correct: 83, color: "#2D9B68" },
  { name: "Orthodontics",                   total:  680, done: 180, correct: 66, color: brand.red },
  { name: "Pediatric Dentistry",            total:  520, done: 120, correct: 72, color: brand.amber },
  { name: "Implant Dentistry",              total:  440, done: 180, correct: 79, color: "#8B5CF6" },
  { name: "Aesthetic Dentistry",            total:  360, done: 120, correct: 75, color: brand.amber },
  { name: "Digital Dentistry",              total:  280, done:  80, correct: 70, color: "#496FA8" },
];

const practiceModesData = [
  { label: "All Questions", desc: "Full bank — 14,200 questions", icon: <BookOpen size={18} />, color: brand.charcoal, path: "/exams/edle/practice" },
  { label: "Unused Only", desc: "Questions you haven't seen", icon: <Zap size={18} />, color: brand.orange, path: "/exams/edle/practice" },
  { label: "Incorrect", desc: "Review your wrong answers", icon: <Target size={18} />, color: brand.red, path: "/exams/edle/practice" },
  { label: "Difficult", desc: "Questions you flagged", icon: <Star size={18} />, color: brand.amber, path: "/exams/edle/practice" },
  { label: "By Year", desc: "Organised by exam year", icon: <Calendar size={18} />, color: "#496FA8", path: "/exams/edle/practice" },
  { label: "Government Trials", desc: "Official government trial exams", icon: <Award size={18} />, color: "#2D9B68", path: "/exams/edle/mock" },
  { label: "Simulation Exam", desc: "Full timed exam simulation", icon: <BarChart2 size={18} />, color: brand.red, path: "/exams/edle/mock" },
  { label: "Free Tests", desc: "Sample questions — no account needed", icon: <CheckCircle size={18} />, color: brand.gold, path: "/exams/free" },
];

const recentActivity = [
  { type: "Session", desc: "Anatomy — 50 questions", score: "82%", time: "Today" },
  { type: "Mock", desc: "Full Simulation — 100 questions", score: "74%", time: "Yesterday" },
  { type: "Session", desc: "Pharmacology — 40 questions", score: "61%", time: "2 days ago" },
];

export default function ELDEDashboard() {
  const nav = useNavigate();
  const [selectedSubject, setSelectedSubject] = useState<string | null>(null);

  const totalDone = subjects.reduce((a, s) => a + s.done, 0);
  const totalQs = subjects.reduce((a, s) => a + s.total, 0);
  const overallProgress = Math.round((totalDone / totalQs) * 100);
  const avgCorrect = Math.round(subjects.reduce((a, s) => a + s.correct, 0) / subjects.length);

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Hero */}
      <div style={{ background: `linear-gradient(135deg, ${brand.deepCharcoal} 0%, #1a1714 100%)`, padding: "48px 24px 40px", position: "relative", overflow: "hidden" }}>
        <div style={{ position: "absolute", inset: 0, background: "radial-gradient(ellipse at 70% 40%, rgba(255,198,46,0.07) 0%, transparent 55%)", pointerEvents: "none" }} />
        <div style={{ maxWidth: 1280, margin: "0 auto", position: "relative" }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", flexWrap: "wrap", gap: 16 }}>
            <div>
              <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, letterSpacing: "0.1em", color: brand.amber, textTransform: "uppercase" as const, marginBottom: 8 }}>🇪🇬 Exam Preparation</div>
              <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(24px,3.5vw,38px)", color: "#fff", marginBottom: 8 }}>Egyptian Dental Licensing Exam</h1>
              <p style={{ fontFamily: "Inter", fontSize: 14, color: "rgba(255,255,255,0.5)", maxWidth: 480 }}>14,200+ questions · 16 subjects · Previous official exams · Government trials · Simulation mode</p>
            </div>
            <div style={{ display: "flex", gap: 10 }}>
              <button onClick={() => nav("/exams/analytics")} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 13, color: "rgba(255,255,255,0.7)", background: "rgba(255,255,255,0.08)", border: "1px solid rgba(255,255,255,0.12)", borderRadius: 10, padding: "10px 16px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}>
                <BarChart2 size={14} /> Analytics
              </button>
              <button onClick={() => nav("/exams/edle/practice")} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff", background: gradientGlow, border: "none", borderRadius: 10, padding: "10px 20px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6, boxShadow: `0 4px 14px ${brand.amber}40` }}>
                Continue Studying <ArrowRight size={14} />
              </button>
            </div>
          </div>

          {/* Stats */}
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(160px, 1fr))", gap: 14, marginTop: 28 }}>
            {[
              { label: "Questions Done", value: totalDone.toLocaleString(), sub: `of ${totalQs.toLocaleString()}`, color: brand.gold },
              { label: "Overall Progress", value: `${overallProgress}%`, sub: "of full bank", color: brand.orange },
              { label: "Average Score", value: `${avgCorrect}%`, sub: "across all subjects", color: avgCorrect >= 70 ? "#2D9B68" : brand.red },
              { label: "Study Streak", value: "12 days", sub: "🔥 Keep going!", color: brand.amber },
              { label: "Readiness Score", value: "71%", sub: "Estimated readiness", color: "#2D9B68" },
            ].map((s) => (
              <div key={s.label} style={{ background: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.08)", borderRadius: 16, padding: "16px 16px" }}>
                <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 24, color: s.color }}>{s.value}</div>
                <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: "#fff", marginTop: 3 }}>{s.label}</div>
                <div style={{ fontFamily: "Inter", fontSize: 11, color: "rgba(255,255,255,0.4)", marginTop: 2 }}>{s.sub}</div>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div style={{ maxWidth: 1280, margin: "0 auto", padding: "32px 24px" }}>
        <div style={{ display: "flex", gap: 28, flexWrap: "wrap" }}>
          {/* Left: practice modes + subjects */}
          <div style={{ flex: 1, minWidth: 300 }}>
            {/* Practice modes */}
            <div style={{ marginBottom: 32 }}>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 16 }}>Practice Modes</div>
              <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(220px, 1fr))", gap: 10 }}>
                {practiceModesData.map((mode) => (
                  <div key={mode.label} onClick={() => nav(mode.path)} style={{ background: brand.white, borderRadius: 14, border: `1px solid ${brand.borderGray}`, padding: "16px 16px", cursor: "pointer", display: "flex", gap: 14, alignItems: "center", transition: "transform 0.15s, box-shadow 0.15s" }}
                    onMouseEnter={(e) => { (e.currentTarget as HTMLElement).style.transform = "translateY(-3px)"; (e.currentTarget as HTMLElement).style.boxShadow = "0 6px 20px rgba(27,27,27,0.08)"; }}
                    onMouseLeave={(e) => { (e.currentTarget as HTMLElement).style.transform = "none"; (e.currentTarget as HTMLElement).style.boxShadow = "none"; }}
                  >
                    <div style={{ width: 40, height: 40, borderRadius: 12, background: `${mode.color}14`, display: "flex", alignItems: "center", justifyContent: "center", color: mode.color, flexShrink: 0 }}>{mode.icon}</div>
                    <div>
                      <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal }}>{mode.label}</div>
                      <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginTop: 2 }}>{mode.desc}</div>
                    </div>
                    <ChevronRight size={14} color={brand.borderGray} style={{ marginLeft: "auto" }} />
                  </div>
                ))}
              </div>
            </div>

            {/* Subjects */}
            <div>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 16 }}>
                <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal }}>By Subject</div>
                <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>Click to practice</div>
              </div>
              <div style={{ display: "flex", flexDirection: "column" as const, gap: 8 }}>
                {subjects.map((s) => {
                  const pct = Math.round((s.done / s.total) * 100);
                  const isSel = selectedSubject === s.name;
                  return (
                    <div key={s.name} onClick={() => { setSelectedSubject(isSel ? null : s.name); nav("/exams/edle/practice"); }}
                      style={{ background: isSel ? "rgba(255,107,26,0.04)" : brand.white, borderRadius: 14, border: `1.5px solid ${isSel ? brand.orange : brand.borderGray}`, padding: "14px 16px", cursor: "pointer", transition: "all 0.15s" }}>
                      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 8 }}>
                        <div style={{ display: "flex", gap: 10, alignItems: "center" }}>
                          <div style={{ width: 10, height: 10, borderRadius: "50%", background: s.color, flexShrink: 0 }} />
                          <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.charcoal }}>{s.name}</span>
                        </div>
                        <div style={{ display: "flex", gap: 16, alignItems: "center" }}>
                          <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>{s.done}/{s.total}</span>
                          <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: s.correct >= 75 ? "#2D9B68" : s.correct >= 60 ? brand.amber : brand.red }}>{s.correct}%</span>
                        </div>
                      </div>
                      <div style={{ height: 5, background: brand.borderGray, borderRadius: 3, overflow: "hidden" }}>
                        <div style={{ height: "100%", width: `${pct}%`, background: gradientFlow, borderRadius: 3, transition: "width 0.4s ease" }} />
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          </div>

          {/* Right: activity + study tools */}
          <div style={{ width: 300, flexShrink: 0 }}>
            {/* Quick start */}
            <div style={{ background: brand.charcoal, borderRadius: 20, padding: "22px 20px", marginBottom: 18 }}>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: "#fff", marginBottom: 16 }}>Quick Start</div>
              {[
                { label: "10 Questions", desc: "5-minute warm-up", icon: "⚡" },
                { label: "25 Questions", desc: "Standard session", icon: "📝" },
                { label: "50 Questions", desc: "Deep practice", icon: "🎯" },
                { label: "100 Questions", desc: "Full simulation", icon: "🏆" },
              ].map((q) => (
                <button key={q.label} onClick={() => nav("/exams/edle/practice")} style={{ width: "100%", display: "flex", justifyContent: "space-between", alignItems: "center", background: "rgba(255,255,255,0.06)", border: "none", borderRadius: 10, padding: "11px 14px", cursor: "pointer", marginBottom: 8, transition: "background 0.15s" }}
                  onMouseEnter={(e) => ((e.currentTarget as HTMLElement).style.background = "rgba(255,255,255,0.1)")}
                  onMouseLeave={(e) => ((e.currentTarget as HTMLElement).style.background = "rgba(255,255,255,0.06)")}
                >
                  <div style={{ display: "flex", gap: 10, alignItems: "center" }}>
                    <span style={{ fontSize: 16 }}>{q.icon}</span>
                    <div style={{ textAlign: "left" as const }}>
                      <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: "#fff" }}>{q.label}</div>
                      <div style={{ fontFamily: "Inter", fontSize: 11, color: "rgba(255,255,255,0.45)" }}>{q.desc}</div>
                    </div>
                  </div>
                  <ChevronRight size={14} color="rgba(255,255,255,0.3)" />
                </button>
              ))}
            </div>

            {/* Recent activity */}
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "20px", marginBottom: 18 }}>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal, marginBottom: 14 }}>Recent Activity</div>
              {recentActivity.map((a, i) => (
                <div key={i} style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", padding: "10px 0", borderBottom: i < recentActivity.length - 1 ? `1px solid ${brand.borderGray}` : "none" }}>
                  <div>
                    <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal }}>{a.desc}</div>
                    <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginTop: 2 }}>{a.time}</div>
                  </div>
                  <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: parseFloat(a.score) >= 70 ? "#2D9B68" : brand.red }}>{a.score}</span>
                </div>
              ))}
            </div>

            {/* Readiness */}
            <div style={{ background: `linear-gradient(135deg, rgba(255,107,26,0.08), rgba(255,198,46,0.08))`, border: `1px solid ${brand.amber}25`, borderRadius: 18, padding: "20px" }}>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal, marginBottom: 10 }}>Exam Readiness</div>
              <div style={{ display: "flex", alignItems: "center", gap: 16, marginBottom: 14 }}>
                <div style={{ width: 64, height: 64, borderRadius: "50%", border: `4px solid ${brand.orange}`, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                  <span style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.orange }}>71%</span>
                </div>
                <div>
                  <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal }}>Approaching Ready</div>
                  <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginTop: 3, lineHeight: 1.4 }}>Focus on Pharmacology and Biochemistry to boost your score.</div>
                </div>
              </div>
              <button onClick={() => nav("/exams/analytics")} style={{ width: "100%", fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "11px", cursor: "pointer" }}>
                View Full Analytics
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
