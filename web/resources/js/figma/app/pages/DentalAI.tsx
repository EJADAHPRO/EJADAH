import { useState, useRef } from "react";
import { Send, Plus, Paperclip, BookOpen, Zap, FileText, Brain, ChevronRight, Copy, Download, Sparkles } from "lucide-react";
import { brand, gradientFlow, gradientGlow, GradientBadge } from "@/figma/app/shared";

const suggestions = [
  "Explain the mechanism of sodium hypochlorite in root canal irrigation",
  "Summarize the evidence for immediate implant placement",
  "What are the indications for pulpotomy vs pulpectomy?",
  "Create flashcards on orthodontic force systems",
  "Compare GIC and composite for class V restorations",
  "Explain the pharmacology of local anesthetics in dentistry",
];

const savedChats = [
  { title: "Endodontics — irrigation protocols", time: "2h ago" },
  { title: "ORE exam — anatomy revision", time: "Yesterday" },
  { title: "Implant prosthetics terminology", time: "Jun 18" },
  { title: "Periodontal disease classification 2017", time: "Jun 15" },
];

type Message = { role: "user" | "ai"; text: string; sources?: string[] };

const demoResponses: Record<string, { text: string; sources: string[] }> = {
  default: {
    text: "Thank you for your question. Based on current dental literature and educational content, I can provide a detailed explanation. The evidence-based approach to this topic involves understanding the underlying biology, clinical application, and patient factors that influence treatment decisions.\n\nKey points to consider:\n• The mechanism involves both direct cellular effects and indirect immunological modulation\n• Clinical success rates in systematic reviews range from 85–95% under ideal conditions\n• Operator technique and case selection remain the most significant variables\n\nWould you like me to generate flashcards from this explanation, or create a quiz to test your understanding?",
    sources: ["Hargreaves & Berman. Cohen's Pathways of the Pulp, 12th Ed.", "Estrela C et al. J Endod 2022", "ESE Guidelines 2023"],
  },
};

export default function DentalAI() {
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const sendMessage = (text: string) => {
    if (!text.trim()) return;
    const userMsg: Message = { role: "user", text };
    setMessages((prev) => [...prev, userMsg]);
    setInput("");
    setLoading(true);
    setTimeout(() => {
      const resp = demoResponses.default;
      setMessages((prev) => [...prev, { role: "ai", text: resp.text, sources: resp.sources }]);
      setLoading(false);
      setTimeout(() => messagesEndRef.current?.scrollIntoView({ behavior: "smooth" }), 50);
    }, 1200);
  };

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh", display: "flex", flexDirection: "column" }}>
      {/* Header */}
      <div style={{ background: brand.charcoal, padding: "32px 24px", borderBottom: "1px solid rgba(255,255,255,0.06)" }}>
        <div style={{ maxWidth: 1280, margin: "0 auto", display: "flex", alignItems: "center", gap: 16 }}>
          <div style={{ width: 52, height: 52, borderRadius: 16, background: gradientFlow, display: "flex", alignItems: "center", justifyContent: "center", boxShadow: "0 4px 20px rgba(255,107,26,0.4)" }}>
            <Brain size={26} color="#fff" />
          </div>
          <div>
            <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 24, color: "#fff" }}>Ejadah Dental AI</h1>
            <p style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.5)" }}>Your educational companion — powered by dental literature and Ejadah curriculum</p>
          </div>
          <div style={{ marginLeft: "auto", fontFamily: "Inter", fontSize: 11, color: "rgba(255,255,255,0.35)", background: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.1)", borderRadius: 8, padding: "6px 12px" }}>
            For educational use only · Not clinical diagnosis
          </div>
        </div>
      </div>

      <div style={{ flex: 1, maxWidth: 1280, margin: "0 auto", width: "100%", padding: "24px", display: "flex", gap: 24, boxSizing: "border-box" as const }}>
        {/* Sidebar */}
        <div className="hidden md:flex" style={{ width: 260, flexDirection: "column", flexShrink: 0 }}>
          <button onClick={() => setMessages([])} style={{ width: "100%", fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "12px", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 6, marginBottom: 20, boxShadow: "0 4px 14px rgba(255,107,26,0.3)" }}>
            <Plus size={15} /> New Chat
          </button>
          <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: brand.warmGray, letterSpacing: "0.08em", textTransform: "uppercase" as const, marginBottom: 10 }}>Recent Chats</div>
          {savedChats.map((chat) => (
            <div key={chat.title} style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, padding: "10px 12px", borderRadius: 10, cursor: "pointer", marginBottom: 4, transition: "background 0.15s", lineHeight: 1.4 }}
              onMouseEnter={(e) => ((e.currentTarget as HTMLElement).style.background = brand.paleGray)}
              onMouseLeave={(e) => ((e.currentTarget as HTMLElement).style.background = "transparent")}
            >
              <div style={{ fontWeight: 500 }}>{chat.title}</div>
              <div style={{ fontSize: 11, color: brand.warmGray, marginTop: 2 }}>{chat.time}</div>
            </div>
          ))}
          <div style={{ marginTop: "auto", padding: "16px 0", borderTop: `1px solid ${brand.borderGray}` }}>
            <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, lineHeight: 1.5 }}>AI responses are based on dental literature and Ejadah curriculum. Always apply clinical judgement.</div>
          </div>
        </div>

        {/* Chat area */}
        <div style={{ flex: 1, display: "flex", flexDirection: "column", minWidth: 0 }}>
          {messages.length === 0 ? (
            /* Empty state */
            <div style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: "40px 0" }}>
              <div style={{ width: 72, height: 72, borderRadius: 22, background: gradientFlow, display: "flex", alignItems: "center", justifyContent: "center", marginBottom: 20, boxShadow: "0 8px 28px rgba(255,107,26,0.3)" }}>
                <Sparkles size={32} color="#fff" />
              </div>
              <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 26, color: brand.charcoal, marginBottom: 8, textAlign: "center" as const }}>What would you like to learn?</h2>
              <p style={{ fontFamily: "Inter", fontSize: 15, color: brand.warmGray, marginBottom: 36, textAlign: "center" as const, maxWidth: 440 }}>Ask any dental education question, upload a lecture or PDF, or generate flashcards and quizzes instantly.</p>
              <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(260px, 1fr))", gap: 10, width: "100%", maxWidth: 700 }}>
                {suggestions.map((s) => (
                  <button key={s} onClick={() => sendMessage(s)} style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, background: brand.white, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 16px", cursor: "pointer", textAlign: "left" as const, lineHeight: 1.4, transition: "border-color 0.15s, box-shadow 0.15s" }}
                    onMouseEnter={(e) => { (e.currentTarget as HTMLElement).style.borderColor = brand.amber; (e.currentTarget as HTMLElement).style.boxShadow = "0 4px 14px rgba(255,170,24,0.1)"; }}
                    onMouseLeave={(e) => { (e.currentTarget as HTMLElement).style.borderColor = brand.borderGray; (e.currentTarget as HTMLElement).style.boxShadow = "none"; }}
                  >
                    <ChevronRight size={12} color={brand.orange} style={{ marginRight: 6 }} />{s}
                  </button>
                ))}
              </div>
            </div>
          ) : (
            /* Messages */
            <div style={{ flex: 1, overflowY: "auto", paddingBottom: 16 }}>
              {messages.map((msg, i) => (
                <div key={i} style={{ marginBottom: 20, display: "flex", flexDirection: "column" as const, alignItems: msg.role === "user" ? "flex-end" : "flex-start" }}>
                  {msg.role === "user" ? (
                    <div style={{ background: gradientFlow, borderRadius: "18px 18px 4px 18px", padding: "13px 18px", maxWidth: "75%", fontFamily: "Inter", fontSize: 14, color: "#fff", lineHeight: 1.6 }}>{msg.text}</div>
                  ) : (
                    <div style={{ maxWidth: "85%" }}>
                      <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 10 }}>
                        <div style={{ width: 28, height: 28, borderRadius: 8, background: gradientFlow, display: "flex", alignItems: "center", justifyContent: "center" }}><Brain size={14} color="#fff" /></div>
                        <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal }}>Ejadah AI</span>
                      </div>
                      <div style={{ background: brand.white, border: `1px solid ${brand.borderGray}`, borderRadius: "4px 18px 18px 18px", padding: "18px 20px", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, lineHeight: 1.7 }}>
                        {msg.text.split("\n").map((line, j) => <div key={j}>{line}</div>)}
                      </div>
                      {msg.sources && (
                        <div style={{ marginTop: 10, display: "flex", flexWrap: "wrap", gap: 6 }}>
                          {msg.sources.map((s) => (
                            <span key={s} style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, background: brand.paleGray, borderRadius: 6, padding: "3px 9px", display: "flex", alignItems: "center", gap: 4 }}><BookOpen size={10} /> {s}</span>
                          ))}
                        </div>
                      )}
                      <div style={{ display: "flex", gap: 8, marginTop: 10 }}>
                        {[["Copy", <Copy size={12} />], ["Save", <Download size={12} />], ["Flashcards", <Zap size={12} />]].map(([label, icon]) => (
                          <button key={label as string} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 11, color: brand.warmGray, background: brand.white, border: `1px solid ${brand.borderGray}`, borderRadius: 6, padding: "5px 10px", cursor: "pointer", display: "flex", alignItems: "center", gap: 4 }}>
                            {icon} {label as string}
                          </button>
                        ))}
                      </div>
                    </div>
                  )}
                </div>
              ))}
              {loading && (
                <div style={{ display: "flex", alignItems: "center", gap: 10, padding: "10px 0" }}>
                  <div style={{ width: 28, height: 28, borderRadius: 8, background: gradientFlow, display: "flex", alignItems: "center", justifyContent: "center" }}><Brain size={14} color="#fff" /></div>
                  <div style={{ display: "flex", gap: 4 }}>
                    {[0, 1, 2].map((i) => <div key={i} style={{ width: 6, height: 6, borderRadius: "50%", background: brand.orange, animation: `pulse ${0.6 + i * 0.2}s ease-in-out infinite` }} />)}
                  </div>
                </div>
              )}
              <div ref={messagesEndRef} />
            </div>
          )}

          {/* Input */}
          <div style={{ background: brand.white, border: `1.5px solid ${brand.borderGray}`, borderRadius: 16, padding: "12px 14px", display: "flex", gap: 10, alignItems: "flex-end", boxShadow: "0 4px 16px rgba(27,27,27,0.06)", marginTop: messages.length > 0 ? 16 : 0 }}>
            <button style={{ background: "none", border: "none", cursor: "pointer", color: brand.warmGray, padding: "4px" }}><Paperclip size={18} /></button>
            <textarea
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onKeyDown={(e) => { if (e.key === "Enter" && !e.shiftKey) { e.preventDefault(); sendMessage(input); } }}
              placeholder="Ask a dental education question… (Shift+Enter for new line)"
              rows={1}
              style={{ flex: 1, fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: "none", border: "none", outline: "none", resize: "none", lineHeight: 1.5, minHeight: 24, maxHeight: 120, overflowY: "auto" }}
            />
            <button onClick={() => sendMessage(input)} disabled={!input.trim()} style={{ width: 38, height: 38, borderRadius: 10, background: input.trim() ? gradientFlow : brand.borderGray, border: "none", display: "flex", alignItems: "center", justifyContent: "center", cursor: input.trim() ? "pointer" : "default", transition: "background 0.15s", flexShrink: 0 }}>
              <Send size={16} color="#fff" />
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
