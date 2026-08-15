import image_MRX01185 from '@/imports/MRX01185.jpg'
import { useState } from "react";
import { useNavigate, useParams } from "react-router";
import { Play, Pause, ChevronLeft, ChevronRight, CheckCircle, Lock, MessageSquare, BookOpen, Settings, Maximize, SkipBack, SkipForward, Volume2, X } from "lucide-react";
import { brand, gradientFlow, GradientBadge } from "@/app/shared";

const lessons = [
  { title: "Introduction & Course Overview", duration: "12 min", done: true },
  { title: "Anatomy of the Root Canal System", duration: "28 min", done: true },
  { title: "Pulp Biology & Diagnosis", duration: "35 min", done: false, active: true },
  { title: "Access Cavity Design — Anterior Teeth", duration: "40 min", done: false },
  { title: "Access Cavity Design — Posterior Teeth", duration: "45 min", done: false },
  { title: "Canal Negotiation & Glide Path", duration: "30 min", done: false },
  { title: "Rotary Instrumentation Systems", duration: "52 min", done: false },
  { title: "Irrigation Protocols", duration: "38 min", done: false, locked: true },
  { title: "Obturation Techniques", duration: "44 min", done: false, locked: true },
];

export default function CoursePlayer() {
  const { id } = useParams();
  const nav = useNavigate();
  const [playing, setPlaying] = useState(false);
  const [activeLesson, setActiveLesson] = useState(2);
  const [activeTab, setActiveTab] = useState<"curriculum" | "notes" | "discussion">("curriculum");
  const [progress, setProgress] = useState(35);

  return (
    <div style={{ height: "100vh", display: "flex", flexDirection: "column", background: brand.deepCharcoal, overflow: "hidden" }}>
      {/* Top bar */}
      <div style={{ height: 52, display: "flex", alignItems: "center", padding: "0 20px", borderBottom: "1px solid rgba(255,255,255,0.08)", gap: 16, flexShrink: 0 }}>
        <button onClick={() => nav(`/courses/${id}`)} style={{ background: "none", border: "none", cursor: "pointer", color: "rgba(255,255,255,0.6)", display: "flex", alignItems: "center", gap: 6, fontFamily: "Inter", fontSize: 13 }}>
          <X size={16} /> Exit Player
        </button>
        <div style={{ flex: 1, fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: "#fff" }}>
          Comprehensive Endodontics: From Basic to Advanced
        </div>
        <div style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.45)" }}>Lesson 3 of {lessons.length}</div>
        {/* Progress bar */}
        <div style={{ width: 120, height: 4, background: "rgba(255,255,255,0.1)", borderRadius: 2, overflow: "hidden" }}>
          <div style={{ height: "100%", width: `${progress}%`, background: gradientFlow, borderRadius: 2 }} />
        </div>
        <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.amber }}>{progress}% complete</div>
      </div>

      {/* Main layout */}
      <div style={{ flex: 1, display: "flex", overflow: "hidden" }}>
        {/* Video area */}
        <div style={{ flex: 1, display: "flex", flexDirection: "column", minWidth: 0 }}>
          {/* Video */}
          <div style={{ flex: 1, background: "#000", position: "relative", display: "flex", alignItems: "center", justifyContent: "center" }}>
            <img
              src={image_MRX01185}
              alt="Course video"
              style={{ width: "100%", height: "100%", objectFit: "cover", opacity: 0.7 }}
            />
            {/* Play overlay */}
            {!playing && (
              <div style={{ position: "absolute", inset: 0, display: "flex", alignItems: "center", justifyContent: "center" }}></div>
            )}
            {/* Video controls */}
            <div style={{ position: "absolute", bottom: 0, left: 0, right: 0, background: "linear-gradient(to top, rgba(0,0,0,0.8), transparent)", padding: "20px 20px 16px" }}>
              {/* Seek bar */}
              <div style={{ height: 4, background: "rgba(255,255,255,0.2)", borderRadius: 2, marginBottom: 12, cursor: "pointer", position: "relative" }}>
                <div style={{ height: "100%", width: "35%", background: gradientFlow, borderRadius: 2 }} />
                <div style={{ position: "absolute", left: "35%", top: "50%", transform: "translate(-50%, -50%)", width: 12, height: 12, borderRadius: "50%", background: brand.orange, border: "2px solid #fff" }} />
              </div>
              <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
                <button onClick={() => setPlaying(!playing)} style={{ background: "none", border: "none", cursor: "pointer", color: "#fff", display: "flex" }}>
                  {playing ? <Pause size={20} /> : <Play size={20} fill="#fff" />}
                </button>
                <button style={{ background: "none", border: "none", cursor: "pointer", color: "rgba(255,255,255,0.7)" }}><SkipBack size={18} /></button>
                <button style={{ background: "none", border: "none", cursor: "pointer", color: "rgba(255,255,255,0.7)" }}><SkipForward size={18} /></button>
                <button style={{ background: "none", border: "none", cursor: "pointer", color: "rgba(255,255,255,0.7)" }}><Volume2 size={18} /></button>
                <span style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.7)" }}>12:24 / 35:00</span>
                <div style={{ flex: 1 }} />
                <button style={{ fontFamily: "Inter", fontSize: 11, color: "rgba(255,255,255,0.7)", background: "rgba(255,255,255,0.1)", border: "1px solid rgba(255,255,255,0.2)", borderRadius: 6, padding: "3px 8px", cursor: "pointer" }}>1.0×</button>
                <button style={{ background: "none", border: "none", cursor: "pointer", color: "rgba(255,255,255,0.7)" }}><Settings size={16} /></button>
                <button style={{ background: "none", border: "none", cursor: "pointer", color: "rgba(255,255,255,0.7)" }}><Maximize size={16} /></button>
              </div>
            </div>
          </div>

          {/* Below video */}
          <div style={{ background: "#1a1614", padding: "16px 24px", borderTop: "1px solid rgba(255,255,255,0.06)" }}>
            <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 16, color: "#fff", marginBottom: 4 }}>Pulp Biology & Diagnosis</div>
            <div style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.5)" }}>Module 1 — Foundations</div>
            <div style={{ display: "flex", gap: 10, marginTop: 12 }}>
              <button onClick={() => setActiveLesson(Math.max(0, activeLesson - 1))} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 13, color: "rgba(255,255,255,0.7)", background: "rgba(255,255,255,0.06)", border: "none", borderRadius: 8, padding: "8px 16px", cursor: "pointer", display: "flex", alignItems: "center", gap: 5 }}><ChevronLeft size={14} /> Previous</button>
              <button onClick={() => { setActiveLesson(Math.min(lessons.length - 1, activeLesson + 1)); setProgress(Math.min(100, progress + 15)); }} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 8, padding: "8px 16px", cursor: "pointer", display: "flex", alignItems: "center", gap: 5 }}>
                Mark Complete & Next <ChevronRight size={14} />
              </button>
            </div>
          </div>
        </div>

        {/* Sidebar */}
        <div style={{ width: 340, background: "#1a1614", borderLeft: "1px solid rgba(255,255,255,0.06)", display: "flex", flexDirection: "column", flexShrink: 0, overflow: "hidden" }}>
          {/* Tabs */}
          <div style={{ display: "flex", borderBottom: "1px solid rgba(255,255,255,0.06)" }}>
            {(["curriculum", "notes", "discussion"] as const).map((tab) => (
              <button key={tab} onClick={() => setActiveTab(tab)} style={{ flex: 1, fontFamily: "Inter", fontWeight: 500, fontSize: 12, color: activeTab === tab ? brand.amber : "rgba(255,255,255,0.45)", background: "none", border: "none", borderBottom: `2px solid ${activeTab === tab ? brand.amber : "transparent"}`, padding: "14px 8px", cursor: "pointer", textTransform: "capitalize" as const, transition: "color 0.15s" }}>
                {tab}
              </button>
            ))}
          </div>

          {/* Tab content */}
          <div style={{ flex: 1, overflowY: "auto", padding: "12px 0" }}>
            {activeTab === "curriculum" && lessons.map((lesson, i) => (
              <div key={lesson.title} onClick={() => !lesson.locked && setActiveLesson(i)} style={{ display: "flex", gap: 12, alignItems: "flex-start", padding: "12px 16px", cursor: lesson.locked ? "default" : "pointer", background: i === activeLesson ? "rgba(255,107,26,0.1)" : "transparent", borderLeft: `3px solid ${i === activeLesson ? brand.orange : "transparent"}`, transition: "background 0.15s" }}>
                <div style={{ marginTop: 2, flexShrink: 0 }}>
                  {lesson.done ? <CheckCircle size={16} color={brand.orange} /> : lesson.locked ? <Lock size={16} color="rgba(255,255,255,0.2)" /> : <div style={{ width: 16, height: 16, borderRadius: "50%", border: `2px solid ${i === activeLesson ? brand.orange : "rgba(255,255,255,0.25)"}` }} />}
                </div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontFamily: "Inter", fontWeight: i === activeLesson ? 600 : 400, fontSize: 13, color: lesson.locked ? "rgba(255,255,255,0.3)" : i === activeLesson ? "#fff" : "rgba(255,255,255,0.7)", lineHeight: 1.4, marginBottom: 3 }}>{lesson.title}</div>
                  <div style={{ fontFamily: "Inter", fontSize: 11, color: "rgba(255,255,255,0.35)" }}>{lesson.duration}</div>
                  {lesson.locked && <div style={{ fontFamily: "Inter", fontSize: 10, color: "rgba(255,255,255,0.25)", marginTop: 2 }}>Enroll to unlock</div>}
                </div>
              </div>
            ))}

            {activeTab === "notes" && (
              <div style={{ padding: "16px" }}>
                <textarea placeholder="Take notes for this lesson…" style={{ width: "100%", minHeight: 120, fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.8)", background: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.1)", borderRadius: 10, padding: 12, resize: "vertical", outline: "none", boxSizing: "border-box" as const }} />
                <button style={{ marginTop: 10, fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: "#fff", background: gradientFlow, border: "none", borderRadius: 8, padding: "8px 16px", cursor: "pointer" }}>Save Note</button>
              </div>
            )}

            {activeTab === "discussion" && (
              <div style={{ padding: "16px" }}>
                <div style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.5)", marginBottom: 12 }}>4 questions for this lesson</div>
                {["What is the clinical significance of an open apex in retreatment?", "Preferred instrument for calcified canals?"].map((q) => (
                  <div key={q} style={{ background: "rgba(255,255,255,0.04)", borderRadius: 10, padding: "12px 14px", marginBottom: 10 }}>
                    <div style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.8)", lineHeight: 1.4, marginBottom: 6 }}>{q}</div>
                    <div style={{ fontFamily: "Inter", fontSize: 11, color: "rgba(255,255,255,0.35)" }}>2 answers · 1h ago</div>
                  </div>
                ))}
                <textarea placeholder="Ask the instructor…" style={{ width: "100%", minHeight: 80, fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.8)", background: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.1)", borderRadius: 10, padding: 12, resize: "none", outline: "none", boxSizing: "border-box" as const }} />
                <button style={{ marginTop: 10, fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: "#fff", background: gradientFlow, border: "none", borderRadius: 8, padding: "8px 16px", cursor: "pointer" }}>Post Question</button>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
