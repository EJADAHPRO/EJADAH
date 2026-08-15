import { useState } from "react";
import { useNavigate, useParams } from "react-router";
import {
  Mic, MicOff, Video, VideoOff, Hand, MessageSquare,
  Users, BarChart2, Share2, Settings, X, Send,
  ChevronRight, Radio, Clock, CheckCircle, AlertCircle,
  Maximize, Volume2, PhoneOff,
} from "lucide-react";
import { globalStyle } from "@/app/shared";
import { brand, gradientFlow, LiveBadge } from "@/app/shared";

const participants = [
  { name: "Dr. Sara Mahmoud", avatar: "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=60&q=80", handRaised: false, active: false },
  { name: "Dr. Khaled Ahmed", avatar: "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=60&q=80", handRaised: true, active: false },
  { name: "Dr. Nour Ali", avatar: "https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=60&q=80", handRaised: false, active: false },
  { name: "Dr. Tarek Hassan", avatar: "https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=60&q=80", handRaised: false, active: false },
  { name: "Dr. Reem Saleh", avatar: "https://images.unsplash.com/photo-1657470179447-0f5aa16daa91?w=60&q=80", handRaised: true, active: false },
];

const chatMessages = [
  { name: "Dr. Sara", text: "Can you explain more about the glide path concept?", time: "7:32 PM" },
  { name: "Dr. Khaled", text: "Which brand do you prefer for reciprocating motion?", time: "7:34 PM" },
  { name: "Dr. Amira", text: "Great question — we'll cover WaveOne Gold vs Reciproc in the next segment.", time: "7:35 PM", isInstructor: true },
  { name: "Dr. Nour", text: "Thank you, this is incredibly clear!", time: "7:36 PM" },
  { name: "Dr. Tarek", text: "What's the recommended apical size for a standard molar?", time: "7:37 PM" },
];

const agenda = [
  { title: "Introduction & Canal Anatomy Review", done: true },
  { title: "Access Cavity Preparation", done: true },
  { title: "Glide Path & Rotary Instrumentation", done: false, active: true },
  { title: "Irrigation Protocols", done: false },
  { title: "Obturation Techniques", done: false },
  { title: "Q&A Session", done: false },
];

type Panel = "chat" | "participants" | "agenda" | "poll";

export default function LiveClassroom() {
  const nav = useNavigate();
  const { id } = useParams();

  const [micOn, setMicOn] = useState(false);
  const [camOn, setCamOn] = useState(false);
  const [handRaised, setHandRaised] = useState(false);
  const [activePanel, setActivePanel] = useState<Panel>("chat");
  const [chatInput, setChatInput] = useState("");
  const [messages, setMessages] = useState(chatMessages);
  const [pollAnswer, setPollAnswer] = useState<number | null>(null);
  const [attendanceMinutes] = useState(47);
  const totalMinutes = 90;
  const attendancePct = Math.round((attendanceMinutes / totalMinutes) * 100);

  const sendChat = () => {
    if (!chatInput.trim()) return;
    setMessages((prev) => [...prev, { name: "You", text: chatInput, time: "7:38 PM" }]);
    setChatInput("");
  };

  return (
    <>
    <style>{globalStyle}</style>
    <div style={{ height: "100vh", display: "flex", flexDirection: "column", background: brand.deepCharcoal, overflow: "hidden", fontFamily: "Inter, sans-serif" }}>
      {/* Top bar */}
      <div style={{ height: 52, display: "flex", alignItems: "center", padding: "0 20px", borderBottom: "1px solid rgba(255,255,255,0.06)", gap: 16, flexShrink: 0 }}>
        <LiveBadge />
        <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: "#fff" }}>
          Advanced Endodontics: Live Masterclass
        </div>
        <div style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.4)", display: "flex", alignItems: "center", gap: 5 }}>
          <Clock size={12} /> 47 min elapsed
        </div>
        <div style={{ flex: 1 }} />
        <div style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.5)", display: "flex", alignItems: "center", gap: 5 }}>
          <Users size={12} /> 342 attending
        </div>
        {/* Attendance indicator */}
        <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
          <div style={{ fontFamily: "Inter", fontSize: 11, color: attendancePct >= 80 ? "#2D9B68" : brand.amber }}>{attendancePct}% attended</div>
          <div style={{ width: 60, height: 4, background: "rgba(255,255,255,0.1)", borderRadius: 2, overflow: "hidden" }}>
            <div style={{ height: "100%", width: `${attendancePct}%`, background: attendancePct >= 80 ? "#2D9B68" : brand.amber, borderRadius: 2 }} />
          </div>
        </div>
        <button onClick={() => nav(`/live`)} style={{ background: "rgba(255,45,50,0.15)", border: "none", borderRadius: 8, padding: "6px 14px", cursor: "pointer", fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.red, display: "flex", alignItems: "center", gap: 5 }}>
          <PhoneOff size={13} /> Leave
        </button>
      </div>

      {/* Main layout */}
      <div style={{ flex: 1, display: "flex", overflow: "hidden" }}>
        {/* Video area */}
        <div style={{ flex: 1, display: "flex", flexDirection: "column", minWidth: 0 }}>
          {/* Instructor video */}
          <div style={{ flex: 1, position: "relative", background: "#000" }}>
            <img src="https://images.unsplash.com/photo-1619450565660-2a93ba8603fd?w=1200&q=80" alt="Instructor" style={{ width: "100%", height: "100%", objectFit: "cover", opacity: 0.8 }} />
            {/* Instructor name */}
            <div style={{ position: "absolute", bottom: 16, left: 16, background: "rgba(0,0,0,0.6)", borderRadius: 8, padding: "5px 12px", fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: "#fff", display: "flex", alignItems: "center", gap: 6 }}>
              <div style={{ width: 7, height: 7, borderRadius: "50%", background: brand.red, animation: "pulse 1.5s infinite" }} />
              Dr. Amira Soliman · Instructor
            </div>
            {/* Screen share indicator */}
            <div style={{ position: "absolute", top: 16, right: 16, background: "rgba(255,107,26,0.15)", border: `1px solid ${brand.orange}`, borderRadius: 8, padding: "5px 12px", fontFamily: "Inter", fontSize: 11, color: brand.orange }}>
              📊 Presenting: Canal Morphology Slides
            </div>
          </div>

          {/* Participant strip */}
          <div style={{ height: 90, background: "#161310", borderTop: "1px solid rgba(255,255,255,0.06)", display: "flex", gap: 10, padding: "8px 16px", overflowX: "auto", alignItems: "center" }}>
            {participants.map((p) => (
              <div key={p.name} style={{ position: "relative", flexShrink: 0 }}>
                <div style={{ width: 68, height: 68, borderRadius: 10, background: "rgba(255,255,255,0.06)", border: `1.5px solid ${p.handRaised ? brand.amber : "rgba(255,255,255,0.1)"}`, overflow: "hidden", display: "flex", alignItems: "center", justifyContent: "center" }}>
                  <img src={p.avatar} alt={p.name} style={{ width: "100%", height: "100%", objectFit: "cover", opacity: 0.85 }} />
                </div>
                {p.handRaised && (
                  <div style={{ position: "absolute", top: -6, right: -6, background: brand.amber, borderRadius: "50%", width: 18, height: 18, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 10 }}>✋</div>
                )}
                <div style={{ fontFamily: "Inter", fontSize: 9, color: "rgba(255,255,255,0.5)", textAlign: "center" as const, marginTop: 4, width: 68, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" as const }}>{p.name.split(" ")[1]}</div>
              </div>
            ))}
          </div>

          {/* Controls */}
          <div style={{ height: 64, background: "#0F0D0B", borderTop: "1px solid rgba(255,255,255,0.06)", display: "flex", alignItems: "center", justifyContent: "center", gap: 12, padding: "0 24px" }}>
            <button onClick={() => setMicOn(!micOn)} style={{ width: 44, height: 44, borderRadius: 12, background: micOn ? "rgba(255,255,255,0.08)" : brand.red, border: "none", display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer", color: "#fff" }}>
              {micOn ? <Mic size={18} /> : <MicOff size={18} />}
            </button>
            <button onClick={() => setCamOn(!camOn)} style={{ width: 44, height: 44, borderRadius: 12, background: camOn ? "rgba(255,255,255,0.08)" : brand.red, border: "none", display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer", color: "#fff" }}>
              {camOn ? <Video size={18} /> : <VideoOff size={18} />}
            </button>
            <button onClick={() => setHandRaised(!handRaised)} style={{ width: 44, height: 44, borderRadius: 12, background: handRaised ? brand.amber : "rgba(255,255,255,0.08)", border: "none", display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer", color: "#fff", fontSize: 18 }}>
              ✋
            </button>
            <div style={{ width: 1, height: 28, background: "rgba(255,255,255,0.1)" }} />
            {([["chat", <MessageSquare size={17} />], ["participants", <Users size={17} />], ["agenda", <CheckCircle size={17} />], ["poll", <BarChart2 size={17} />]] as [Panel, React.ReactNode][]).map(([panel, icon]) => (
              <button key={panel} onClick={() => setActivePanel(panel)} style={{ width: 44, height: 44, borderRadius: 12, background: activePanel === panel ? gradientFlow : "rgba(255,255,255,0.08)", border: "none", display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer", color: "#fff" }}>
                {icon}
              </button>
            ))}
            <div style={{ width: 1, height: 28, background: "rgba(255,255,255,0.1)" }} />
            <button style={{ width: 44, height: 44, borderRadius: 12, background: "rgba(255,255,255,0.08)", border: "none", display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer", color: "#fff" }}><Volume2 size={17} /></button>
            <button style={{ width: 44, height: 44, borderRadius: 12, background: "rgba(255,255,255,0.08)", border: "none", display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer", color: "#fff" }}><Maximize size={17} /></button>
          </div>
        </div>

        {/* Side panel */}
        <div style={{ width: 320, background: "#1a1614", borderLeft: "1px solid rgba(255,255,255,0.06)", display: "flex", flexDirection: "column", flexShrink: 0, overflow: "hidden" }}>
          {/* Panel tabs */}
          <div style={{ display: "flex", borderBottom: "1px solid rgba(255,255,255,0.06)" }}>
            {(["chat", "participants", "agenda", "poll"] as Panel[]).map((p) => (
              <button key={p} onClick={() => setActivePanel(p)} style={{ flex: 1, fontFamily: "Inter", fontWeight: 500, fontSize: 11, color: activePanel === p ? brand.amber : "rgba(255,255,255,0.4)", background: "none", border: "none", borderBottom: `2px solid ${activePanel === p ? brand.amber : "transparent"}`, padding: "12px 4px", cursor: "pointer", textTransform: "capitalize" as const }}>
                {p}
              </button>
            ))}
          </div>

          {/* Chat panel */}
          {activePanel === "chat" && (
            <div style={{ flex: 1, display: "flex", flexDirection: "column", overflow: "hidden" }}>
              <div style={{ flex: 1, overflowY: "auto", padding: "12px 14px" }}>
                {messages.map((msg, i) => (
                  <div key={i} style={{ marginBottom: 12 }}>
                    <div style={{ display: "flex", gap: 6, alignItems: "baseline", marginBottom: 3 }}>
                      <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: msg.isInstructor ? brand.amber : "rgba(255,255,255,0.8)" }}>{msg.name}</span>
                      {msg.isInstructor && <span style={{ fontFamily: "Inter", fontSize: 9, color: brand.amber, background: "rgba(255,170,24,0.15)", borderRadius: 4, padding: "1px 5px" }}>INSTRUCTOR</span>}
                      <span style={{ fontFamily: "Inter", fontSize: 10, color: "rgba(255,255,255,0.3)", marginLeft: "auto" }}>{msg.time}</span>
                    </div>
                    <div style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.75)", lineHeight: 1.5 }}>{msg.text}</div>
                  </div>
                ))}
              </div>
              <div style={{ padding: "10px 14px", borderTop: "1px solid rgba(255,255,255,0.06)", display: "flex", gap: 8 }}>
                <input value={chatInput} onChange={(e) => setChatInput(e.target.value)} onKeyDown={(e) => e.key === "Enter" && sendChat()} placeholder="Send a message…"
                  style={{ flex: 1, fontFamily: "Inter", fontSize: 13, color: "#fff", background: "rgba(255,255,255,0.06)", border: "1px solid rgba(255,255,255,0.1)", borderRadius: 8, padding: "8px 12px", outline: "none" }} />
                <button onClick={sendChat} style={{ width: 34, height: 34, borderRadius: 8, background: gradientFlow, border: "none", display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer" }}>
                  <Send size={14} color="#fff" />
                </button>
              </div>
            </div>
          )}

          {/* Participants panel */}
          {activePanel === "participants" && (
            <div style={{ flex: 1, overflowY: "auto", padding: "12px" }}>
              <div style={{ fontFamily: "Inter", fontSize: 11, color: "rgba(255,255,255,0.4)", marginBottom: 10 }}>342 attending</div>
              {/* Instructor */}
              <div style={{ background: "rgba(255,170,24,0.08)", border: `1px solid ${brand.amber}25`, borderRadius: 10, padding: "10px 12px", marginBottom: 12 }}>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.amber }}>Dr. Amira Soliman</div>
                <div style={{ fontFamily: "Inter", fontSize: 11, color: "rgba(255,255,255,0.45)" }}>Instructor · Presenting</div>
              </div>
              {participants.map((p) => (
                <div key={p.name} style={{ display: "flex", gap: 10, alignItems: "center", padding: "8px 0", borderBottom: "1px solid rgba(255,255,255,0.04)" }}>
                  <img src={p.avatar} alt={p.name} style={{ width: 32, height: 32, borderRadius: 8, objectFit: "cover" }} />
                  <div style={{ flex: 1, fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.75)" }}>{p.name}</div>
                  {p.handRaised && <span style={{ fontSize: 14 }}>✋</span>}
                </div>
              ))}
            </div>
          )}

          {/* Agenda panel */}
          {activePanel === "agenda" && (
            <div style={{ flex: 1, overflowY: "auto", padding: "16px 14px" }}>
              <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: "rgba(255,255,255,0.5)", marginBottom: 14 }}>Session Agenda</div>
              {agenda.map((item, i) => (
                <div key={i} style={{ display: "flex", gap: 10, alignItems: "flex-start", marginBottom: 14 }}>
                  <div style={{ width: 22, height: 22, borderRadius: "50%", background: item.done ? "rgba(45,155,104,0.15)" : item.active ? gradientFlow : "rgba(255,255,255,0.06)", border: `1.5px solid ${item.done ? "#2D9B68" : item.active ? brand.orange : "rgba(255,255,255,0.1)"}`, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                    {item.done ? <CheckCircle size={11} color="#2D9B68" /> : <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 9, color: item.active ? "#fff" : "rgba(255,255,255,0.4)" }}>{i + 1}</span>}
                  </div>
                  <div style={{ fontFamily: "Inter", fontSize: 13, color: item.active ? "#fff" : item.done ? "rgba(255,255,255,0.4)" : "rgba(255,255,255,0.65)", fontWeight: item.active ? 600 : 400, lineHeight: 1.4, paddingTop: 2 }}>
                    {item.title}
                    {item.active && <div style={{ fontFamily: "Inter", fontSize: 10, color: brand.orange, marginTop: 2 }}>● In Progress</div>}
                  </div>
                </div>
              ))}
              <div style={{ marginTop: 20, background: "rgba(255,255,255,0.04)", borderRadius: 10, padding: "12px 14px" }}>
                <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: "rgba(255,255,255,0.6)", marginBottom: 6 }}>Your Attendance</div>
                <div style={{ display: "flex", justifyContent: "space-between", fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.5)", marginBottom: 6 }}>
                  <span>Time attended</span><span>{attendancePct}%</span>
                </div>
                <div style={{ height: 5, background: "rgba(255,255,255,0.1)", borderRadius: 3, overflow: "hidden" }}>
                  <div style={{ height: "100%", width: `${attendancePct}%`, background: attendancePct >= 80 ? "#2D9B68" : brand.amber, borderRadius: 3 }} />
                </div>
                <div style={{ fontFamily: "Inter", fontSize: 11, color: "rgba(255,255,255,0.35)", marginTop: 6 }}>
                  {attendancePct >= 80 ? "✓ Eligible for certificate" : `Need ${80 - attendancePct}% more attendance for certificate`}
                </div>
              </div>
            </div>
          )}

          {/* Poll panel */}
          {activePanel === "poll" && (
            <div style={{ flex: 1, overflowY: "auto", padding: "16px 14px" }}>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff", marginBottom: 4 }}>Live Poll</div>
              <div style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.5)", marginBottom: 16 }}>Dr. Amira wants to know…</div>
              <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: "#fff", marginBottom: 14, lineHeight: 1.4 }}>
                Which rotary system are you currently using in your practice?
              </div>
              {["ProTaper Gold", "WaveOne Gold", "Reciproc Blue", "Hyflex EDM", "Other / None"].map((opt, i) => {
                const votes = [42, 28, 15, 8, 7];
                const voted = pollAnswer !== null;
                return (
                  <button key={opt} onClick={() => !voted && setPollAnswer(i)} style={{ width: "100%", background: pollAnswer === i ? gradientFlow : "rgba(255,255,255,0.05)", border: `1px solid ${pollAnswer === i ? "transparent" : "rgba(255,255,255,0.08)"}`, borderRadius: 10, padding: "11px 12px", cursor: voted ? "default" : "pointer", marginBottom: 8, textAlign: "left" as const }}>
                    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: voted ? 5 : 0 }}>
                      <span style={{ fontFamily: "Inter", fontWeight: pollAnswer === i ? 700 : 400, fontSize: 13, color: "#fff" }}>{opt}</span>
                      {voted && <span style={{ fontFamily: "Inter", fontSize: 11, color: "rgba(255,255,255,0.55)" }}>{votes[i]}%</span>}
                    </div>
                    {voted && (
                      <div style={{ height: 4, background: "rgba(255,255,255,0.1)", borderRadius: 2, overflow: "hidden" }}>
                        <div style={{ height: "100%", width: `${votes[i]}%`, background: pollAnswer === i ? "rgba(255,255,255,0.5)" : "rgba(255,255,255,0.25)", borderRadius: 2 }} />
                      </div>
                    )}
                  </button>
                );
              })}
              {pollAnswer === null && <div style={{ fontFamily: "Inter", fontSize: 11, color: "rgba(255,255,255,0.3)", marginTop: 8 }}>Your vote is anonymous</div>}
              {pollAnswer !== null && <div style={{ fontFamily: "Inter", fontSize: 11, color: "#2D9B68", marginTop: 8 }}>✓ Vote submitted — 342 responses</div>}
            </div>
          )}
        </div>
      </div>
    </div>
    </>
  );
}
