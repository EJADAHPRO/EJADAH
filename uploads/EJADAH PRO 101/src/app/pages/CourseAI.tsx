import { useState, useRef } from "react";
import { useNavigate, useParams } from "react-router";
import {
  ChevronLeft, Send, Brain, Paperclip, Zap, BookOpen,
  Copy, Download, ChevronRight, Shield, AlertTriangle,
} from "lucide-react";
import { brand, gradientFlow } from "@/app/shared";

const suggestions = [
  "Explain sodium hypochlorite's mechanism of action in root canal irrigation",
  "Summarise the key points of Lesson 3 on pulp diagnosis",
  "What is the difference between Type I and Type IV Vertucci classification?",
  "Create 5 flashcards on rotary instrumentation systems",
  "What are the most commonly tested EDLE topics in this module?",
  "Explain why glide path preparation reduces rotary file fracture",
];

const courseContext = [
  { icon: "📹", label: "12 videos" },
  { icon: "📄", label: "Handouts" },
  { icon: "🗂️", label: "Flashcards" },
  { icon: "📚", label: "References" },
];

type Msg = { role: "user" | "ai"; text: string; sources?: string[]; actions?: string[] };

const demoReplies: Record<string, { text: string; sources?: string[]; actions?: string[] }> = {
  default: {
    text: "Great question. Based on the course handouts and Dr. Amira's lecture on irrigation protocols:\n\nSodium hypochlorite (NaOCl) works through three mechanisms:\n\n1. **Saponification** — dissolves fatty acids and lipids in the pulp tissue by converting them into soap-like substances\n\n2. **Amino acid neutralisation** — NaOCl reacts with amino acids in proteins, disrupting their structure and breaking down organic tissue\n\n3. **Chloramination** — chlorine groups react with the NH groups of amino acids, releasing nitrogen and causing cell membrane disruption in bacteria\n\nThe tissue-dissolving effect is concentration-dependent: 5.25% is significantly more effective than 1% but also more cytotoxic. Dr. Amira recommends warming NaOCl to 37–60°C to enhance both antimicrobial and organic dissolution efficacy without increasing toxicity.",
    sources: ["Lesson 7: Irrigation Protocols", "Handout Section 5 — Irrigants", "Zehnder M. J Endod 2006;32:389"],
    actions: ["Create flashcard", "Add to notes", "Quiz me on this"],
  },
};

export default function CourseAI() {
  const { id } = useParams();
  const nav = useNavigate();
  const [messages, setMessages] = useState<Msg[]>([]);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);
  const bottomRef = useRef<HTMLDivElement>(null);

  const send = (text: string) => {
    if (!text.trim()) return;
    setMessages((prev) => [...prev, { role: "user", text }]);
    setInput("");
    setLoading(true);
    setTimeout(() => {
      const reply = demoReplies.default;
      setMessages((prev) => [...prev, { role: "ai", text: reply.text, sources: reply.sources, actions: reply.actions }]);
      setLoading(false);
      setTimeout(() => bottomRef.current?.scrollIntoView({ behavior: "smooth" }), 50);
    }, 1000);
  };

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh", display: "flex", flexDirection: "column" }}>
      {/* Top bar */}
      <div style={{ background: brand.white, borderBottom: `1px solid ${brand.borderGray}`, flexShrink: 0 }}>
        <div style={{ maxWidth: 980, margin: "0 auto", padding: "0 24px", height: 56, display: "flex", alignItems: "center", gap: 14 }}>
          <button onClick={() => nav(`/courses/${id}/play`)} style={{ background: "none", border: "none", cursor: "pointer", color: brand.warmGray, display: "flex", alignItems: "center", gap: 5, fontFamily: "Inter", fontSize: 13 }}>
            <ChevronLeft size={15} /> Back to Player
          </button>
          <div style={{ height: 20, width: 1, background: brand.borderGray }} />
          <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
            <div style={{ width: 28, height: 28, borderRadius: 8, background: gradientFlow, display: "flex", alignItems: "center", justifyContent: "center" }}>
              <Brain size={14} color="#fff" />
            </div>
            <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal }}>Course AI</span>
          </div>
          <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>·</div>
          <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>Answers from this course only</div>
          <div style={{ flex: 1 }} />
          {/* Context sources */}
          <div style={{ display: "flex", gap: 6 }}>
            {courseContext.map((c) => (
              <span key={c.label} style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, background: brand.offWhite, border: `1px solid ${brand.borderGray}`, borderRadius: 6, padding: "4px 8px" }}>
                {c.icon} {c.label}
              </span>
            ))}
          </div>
        </div>
      </div>

      <div style={{ flex: 1, maxWidth: 980, margin: "0 auto", width: "100%", padding: "24px", display: "flex", gap: 24, boxSizing: "border-box" as const, minHeight: 0 }}>
        {/* Sidebar */}
        <div className="hidden md:flex" style={{ width: 220, flexShrink: 0, flexDirection: "column", gap: 16 }}>
          {/* Course info */}
          <div style={{ background: brand.white, borderRadius: 16, border: `1px solid ${brand.borderGray}`, padding: "16px" }}>
            <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.charcoal, marginBottom: 8 }}>This Course</div>
            <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, lineHeight: 1.5 }}>Comprehensive Endodontics: From Basic to Advanced</div>
            <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginTop: 6 }}>Dr. Amira Soliman</div>
          </div>

          {/* Suggested questions */}
          <div style={{ background: brand.white, borderRadius: 16, border: `1px solid ${brand.borderGray}`, padding: "16px" }}>
            <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.charcoal, marginBottom: 10 }}>Try asking…</div>
            {suggestions.slice(0, 4).map((s) => (
              <button key={s} onClick={() => send(s)} style={{ display: "block", width: "100%", fontFamily: "Inter", fontSize: 11, color: brand.charcoal, background: brand.offWhite, border: `1px solid ${brand.borderGray}`, borderRadius: 8, padding: "8px 10px", cursor: "pointer", textAlign: "left" as const, marginBottom: 6, lineHeight: 1.4, transition: "border-color 0.15s" }}
                onMouseEnter={(e) => ((e.currentTarget as HTMLElement).style.borderColor = brand.orange)}
                onMouseLeave={(e) => ((e.currentTarget as HTMLElement).style.borderColor = brand.borderGray)}
              >
                <ChevronRight size={10} color={brand.orange} style={{ marginRight: 4 }} />{s}
              </button>
            ))}
          </div>

          {/* Safety notice */}
          <div style={{ background: "rgba(255,170,24,0.06)", border: `1px solid ${brand.amber}30`, borderRadius: 12, padding: "12px 14px" }}>
            <div style={{ display: "flex", gap: 6, alignItems: "flex-start" }}>
              <AlertTriangle size={13} color={brand.amber} style={{ marginTop: 1, flexShrink: 0 }} />
              <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.charcoal, lineHeight: 1.5 }}>
                Course AI answers only from this course's content. Not for clinical diagnosis. Do not share patient information.
              </div>
            </div>
          </div>
        </div>

        {/* Chat */}
        <div style={{ flex: 1, display: "flex", flexDirection: "column", minWidth: 0 }}>
          {messages.length === 0 ? (
            /* Empty state */
            <div style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: "32px 0" }}>
              <div style={{ width: 64, height: 64, borderRadius: 18, background: gradientFlow, display: "flex", alignItems: "center", justifyContent: "center", marginBottom: 18, boxShadow: "0 8px 24px rgba(255,107,26,0.3)" }}>
                <Brain size={30} color="#fff" />
              </div>
              <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.charcoal, marginBottom: 6, textAlign: "center" as const }}>Ask anything about this course</h2>
              <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, marginBottom: 28, textAlign: "center" as const, maxWidth: 360 }}>
                I'm trained on the videos, handouts, flashcards, and references for this specific course.
              </p>
              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10, width: "100%", maxWidth: 560 }}>
                {suggestions.map((s) => (
                  <button key={s} onClick={() => send(s)} style={{ fontFamily: "Inter", fontSize: 12, color: brand.charcoal, background: brand.white, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "11px 14px", cursor: "pointer", textAlign: "left" as const, lineHeight: 1.4, transition: "border-color 0.15s, box-shadow 0.15s" }}
                    onMouseEnter={(e) => { (e.currentTarget as HTMLElement).style.borderColor = brand.amber; (e.currentTarget as HTMLElement).style.boxShadow = `0 4px 14px ${brand.amber}18`; }}
                    onMouseLeave={(e) => { (e.currentTarget as HTMLElement).style.borderColor = brand.borderGray; (e.currentTarget as HTMLElement).style.boxShadow = "none"; }}
                  >
                    <ChevronRight size={11} color={brand.orange} style={{ marginRight: 4 }} />{s}
                  </button>
                ))}
              </div>
            </div>
          ) : (
            <div style={{ flex: 1, overflowY: "auto", paddingBottom: 16 }}>
              {messages.map((msg, i) => (
                <div key={i} style={{ marginBottom: 20, display: "flex", flexDirection: "column" as const, alignItems: msg.role === "user" ? "flex-end" : "flex-start" }}>
                  {msg.role === "user" ? (
                    <div style={{ background: gradientFlow, borderRadius: "18px 18px 4px 18px", padding: "12px 16px", maxWidth: "75%", fontFamily: "Inter", fontSize: 14, color: "#fff", lineHeight: 1.6 }}>{msg.text}</div>
                  ) : (
                    <div style={{ maxWidth: "88%" }}>
                      <div style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 8 }}>
                        <div style={{ width: 26, height: 26, borderRadius: 7, background: gradientFlow, display: "flex", alignItems: "center", justifyContent: "center" }}><Brain size={13} color="#fff" /></div>
                        <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal }}>Course AI</span>
                      </div>
                      <div style={{ background: brand.white, border: `1px solid ${brand.borderGray}`, borderRadius: "4px 18px 18px 18px", padding: "16px 18px", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, lineHeight: 1.75 }}>
                        {msg.text.split("\n").map((line, j) => {
                          const bold = line.replace(/\*\*(.*?)\*\*/g, "<strong>$1</strong>");
                          return <div key={j} dangerouslySetInnerHTML={{ __html: bold }} />;
                        })}
                      </div>
                      {msg.sources && (
                        <div style={{ display: "flex", flexWrap: "wrap", gap: 6, marginTop: 8 }}>
                          {msg.sources.map((s) => (
                            <span key={s} style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, background: brand.paleGray, border: `1px solid ${brand.borderGray}`, borderRadius: 6, padding: "3px 8px", display: "flex", alignItems: "center", gap: 4 }}>
                              <BookOpen size={10} /> {s}
                            </span>
                          ))}
                        </div>
                      )}
                      {msg.actions && (
                        <div style={{ display: "flex", gap: 8, marginTop: 10, flexWrap: "wrap" }}>
                          {msg.actions.map((a) => (
                            <button key={a} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 11, color: brand.orange, background: "rgba(255,107,26,0.07)", border: `1px solid rgba(255,107,26,0.2)`, borderRadius: 7, padding: "5px 10px", cursor: "pointer" }}>{a}</button>
                          ))}
                          <button style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 11, color: brand.warmGray, background: brand.white, border: `1px solid ${brand.borderGray}`, borderRadius: 7, padding: "5px 10px", cursor: "pointer", display: "flex", alignItems: "center", gap: 4 }}>
                            <Copy size={10} /> Copy
                          </button>
                        </div>
                      )}
                    </div>
                  )}
                </div>
              ))}
              {loading && (
                <div style={{ display: "flex", gap: 8, alignItems: "center", padding: "8px 0" }}>
                  <div style={{ width: 26, height: 26, borderRadius: 7, background: gradientFlow, display: "flex", alignItems: "center", justifyContent: "center" }}><Brain size={13} color="#fff" /></div>
                  <div style={{ display: "flex", gap: 4 }}>
                    {[0, 1, 2].map((i) => <div key={i} style={{ width: 7, height: 7, borderRadius: "50%", background: brand.orange, animation: `pulse ${0.6 + i * 0.2}s ease-in-out infinite` }} />)}
                  </div>
                </div>
              )}
              <div ref={bottomRef} />
            </div>
          )}

          {/* Input */}
          <div style={{ background: brand.white, border: `1.5px solid ${brand.borderGray}`, borderRadius: 16, padding: "12px 14px", display: "flex", gap: 10, alignItems: "flex-end", boxShadow: "0 4px 16px rgba(27,27,27,0.05)", marginTop: messages.length > 0 ? 16 : 0 }}>
            <button style={{ background: "none", border: "none", cursor: "pointer", color: brand.warmGray, padding: "4px" }}><Paperclip size={17} /></button>
            <textarea value={input} onChange={(e) => setInput(e.target.value)} onKeyDown={(e) => { if (e.key === "Enter" && !e.shiftKey) { e.preventDefault(); send(input); } }}
              placeholder="Ask about this course… (Shift+Enter for new line)"
              rows={1}
              style={{ flex: 1, fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: "none", border: "none", outline: "none", resize: "none", lineHeight: 1.5, minHeight: 24, maxHeight: 120, overflowY: "auto" }}
            />
            <button onClick={() => send(input)} disabled={!input.trim()}
              style={{ width: 36, height: 36, borderRadius: 10, background: input.trim() ? gradientFlow : brand.borderGray, border: "none", display: "flex", alignItems: "center", justifyContent: "center", cursor: input.trim() ? "pointer" : "default", flexShrink: 0 }}>
              <Send size={15} color="#fff" />
            </button>
          </div>
          <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, textAlign: "center" as const, marginTop: 8 }}>
            Answers sourced from course videos, handouts, and references only · Not clinical advice
          </div>
        </div>
      </div>
    </div>
  );
}
