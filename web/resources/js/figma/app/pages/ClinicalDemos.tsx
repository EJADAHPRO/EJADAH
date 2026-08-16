import { useState } from "react";
import { useNavigate } from "react-router";
import {
  Play, Radio, Users, MessageSquare, Send, Eye,
  CheckCircle, Shield, Download, ChevronRight,
  Calendar, Clock, Star,
} from "lucide-react";
import { brand, gradientFlow, GradientBadge, LiveBadge } from "@/figma/app/shared";

const liveDemos = [
  {
    id: "1", title: "Full-Arch Implant Rehabilitation: All-on-4 Live Surgery",
    surgeon: "Dr. Omar Farid", specialty: "Implantology",
    institution: "Cairo Implant Center",
    watching: 1240, thumb: "https://images.unsplash.com/photo-1619450565660-2a93ba8603fd?w=900&q=80",
    live: true, accredited: true, duration: "2h 30m", started: "45 min ago",
    consent: true, anonymised: true,
  },
];

const upcoming = [
  { title: "Rotary Endodontics: Navigating Calcified Canals", surgeon: "Dr. Amira Soliman", date: "Today, 7:00 PM", specialty: "Endodontics", registered: 842, thumb: "https://images.unsplash.com/photo-1588776814546-daab30f310ce?w=400&q=80" },
  { title: "Full-Thickness Flap for Periapical Surgery", surgeon: "Dr. Hany Ibrahim", date: "Jun 24, 6:00 PM", specialty: "Oral Surgery", registered: 620, thumb: "https://images.unsplash.com/photo-1682750433449-648ed127bb54?w=400&q=80" },
  { title: "Digital Smile Design: From Scan to Final Restoration", surgeon: "Dr. Laila Shawki", date: "Jun 26, 5:00 PM", specialty: "Prosthodontics", registered: 1100, thumb: "https://images.unsplash.com/photo-1681939282781-341ac4f61996?w=400&q=80" },
  { title: "Guided Bone Regeneration: Membrane Placement", surgeon: "Dr. Rania Hassan", date: "Jun 28, 7:00 PM", specialty: "Periodontics", registered: 510, thumb: "https://images.unsplash.com/photo-1657470179447-0f5aa16daa91?w=400&q=80" },
];

const pastDemos = [
  { title: "Single-Tooth Implant: Step-by-Step Placement", surgeon: "Dr. Omar Farid", specialty: "Implantology", views: 14200, duration: "1h 45m", date: "Jun 10, 2025", thumb: "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=400&q=80" },
  { title: "Access Cavity Preparation: Mandibular Molar", surgeon: "Dr. Amira Soliman", specialty: "Endodontics", views: 22800, duration: "55 min", date: "Jun 5, 2025", thumb: "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400&q=80" },
  { title: "Full-Mouth Periodontal Debridement", surgeon: "Dr. Rania Hassan", specialty: "Periodontics", views: 9600, duration: "1h 10m", date: "May 28, 2025", thumb: "https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=400&q=80" },
];

const chatMsgs = [
  { name: "Dr. Sara", text: "What's the torque setting you're using?", time: "7:18 PM" },
  { name: "Dr. Omar", text: "35 Ncm for initial placement, then we'll verify with torque wrench.", time: "7:19 PM", isInstructor: true },
  { name: "Dr. Khaled", text: "Which prosthetic platform are you using here?", time: "7:20 PM" },
];

export default function ClinicalDemos() {
  const nav = useNavigate();
  const demo = liveDemos[0];
  const [chatInput, setChatInput] = useState("");
  const [msgs, setMsgs] = useState(chatMsgs);
  const [question, setQuestion] = useState("");

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Header */}
      <div style={{ background: brand.deepCharcoal, padding: "40px 24px 36px", position: "relative", overflow: "hidden" }}>
        <div style={{ position: "absolute", inset: 0, background: "radial-gradient(ellipse at 60% 50%, rgba(255,45,50,0.1) 0%, transparent 55%)", pointerEvents: "none" }} />
        <div style={{ maxWidth: 1280, margin: "0 auto", position: "relative" }}>
          <div style={{ display: "flex", gap: 12, alignItems: "center", marginBottom: 12 }}>
            <LiveBadge />
            <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, letterSpacing: "0.1em", color: brand.amber, textTransform: "uppercase" as const }}>Live Clinical Demonstrations</span>
          </div>
          <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(24px,3.5vw,38px)", color: "#fff", marginBottom: 10 }}>
            Watch Real Procedures. Learn from Expert Surgeons.
          </h1>
          <p style={{ fontFamily: "Inter", fontSize: 15, color: "rgba(255,255,255,0.55)", maxWidth: 520 }}>
            Free live and recorded clinical demonstrations — patient-consented, identity-protected, educational use only.
          </p>
          <div style={{ display: "flex", gap: 28, marginTop: 20, flexWrap: "wrap" }}>
            {[["Free", "All demonstrations"], ["Live & Recorded", "Both formats"], ["Consented", "Full patient privacy"], ["CPD Eligible", "Selected demos"]].map(([v, l]) => (
              <div key={l}>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: brand.gold }}>{v}</div>
                <div style={{ fontFamily: "Inter", fontSize: 11, color: "rgba(255,255,255,0.4)", marginTop: 2 }}>{l}</div>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div style={{ maxWidth: 1280, margin: "0 auto", padding: "32px 24px" }}>
        {/* LIVE NOW */}
        <div style={{ marginBottom: 44 }}>
          <div style={{ display: "flex", gap: 10, alignItems: "center", marginBottom: 18 }}>
            <LiveBadge />
            <span style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.charcoal }}>Happening Now</span>
          </div>
          <div style={{ display: "flex", gap: 24, flexWrap: "wrap" }}>
            {/* Main video */}
            <div style={{ flex: "1 1 500px" }}>
              <div style={{ background: brand.charcoal, borderRadius: 22, overflow: "hidden" }}>
                {/* Video */}
                <div style={{ position: "relative", height: 280 }}>
                  <img src={demo.thumb} alt={demo.title} style={{ width: "100%", height: "100%", objectFit: "cover", opacity: 0.75 }} />
                  <div style={{ position: "absolute", inset: 0, background: "rgba(0,0,0,0.25)", display: "flex", alignItems: "center", justifyContent: "center" }}>
                    <div style={{ width: 60, height: 60, borderRadius: "50%", background: brand.red, display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer", boxShadow: "0 0 0 12px rgba(255,45,50,0.2)" }}>
                      <Play size={24} fill="#fff" color="#fff" style={{ marginLeft: 4 }} />
                    </div>
                  </div>
                  <div style={{ position: "absolute", top: 12, left: 12, display: "flex", gap: 8 }}>
                    <LiveBadge />
                    {demo.accredited && <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 10, color: brand.gold, background: "rgba(0,0,0,0.5)", borderRadius: 4, padding: "3px 8px" }}>CPD Eligible</span>}
                  </div>
                  <div style={{ position: "absolute", top: 12, right: 12, fontFamily: "Inter", fontSize: 12, color: "#fff", background: "rgba(0,0,0,0.5)", borderRadius: 8, padding: "4px 10px", display: "flex", alignItems: "center", gap: 5 }}>
                    <Eye size={12} /> {demo.watching.toLocaleString()} watching
                  </div>
                  <div style={{ position: "absolute", bottom: 12, left: 12, fontFamily: "Inter", fontSize: 11, color: "rgba(255,255,255,0.7)", background: "rgba(0,0,0,0.5)", borderRadius: 6, padding: "3px 10px" }}>
                    Started {demo.started}
                  </div>
                </div>
                <div style={{ padding: "18px 20px" }}>
                  <GradientBadge small>{demo.specialty}</GradientBadge>
                  <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: "#fff", margin: "10px 0 4px", lineHeight: 1.3 }}>{demo.title}</div>
                  <div style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.55)", marginBottom: 14 }}>{demo.surgeon} · {demo.institution}</div>
                  {/* Consent notice */}
                  <div style={{ background: "rgba(45,155,104,0.1)", border: "1px solid rgba(45,155,104,0.2)", borderRadius: 10, padding: "10px 14px", display: "flex", gap: 8, alignItems: "flex-start", marginBottom: 14 }}>
                    <Shield size={13} color="#2D9B68" style={{ marginTop: 1, flexShrink: 0 }} />
                    <span style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.65)", lineHeight: 1.5 }}>Patient consent confirmed · Identity anonymised · Educational use only · No patient data visible</span>
                  </div>
                  <div style={{ display: "flex", gap: 8 }}>
                    <button style={{ flex: 1, fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff", background: brand.red, border: "none", borderRadius: 10, padding: "11px", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 6 }}>
                      <Radio size={14} /> Watch Live
                    </button>
                    <button style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 13, color: "rgba(255,255,255,0.7)", background: "rgba(255,255,255,0.08)", border: "none", borderRadius: 10, padding: "11px 16px", cursor: "pointer" }}>Notes</button>
                  </div>
                </div>
              </div>
            </div>

            {/* Live chat + Q&A */}
            <div style={{ flex: "0 1 300px", display: "flex", flexDirection: "column", gap: 14 }}>
              <div style={{ background: brand.charcoal, borderRadius: 20, overflow: "hidden", flex: 1 }}>
                <div style={{ display: "flex", borderBottom: "1px solid rgba(255,255,255,0.06)" }}>
                  {["Chat", "Q&A"].map((t) => (
                    <button key={t} style={{ flex: 1, fontFamily: "Inter", fontWeight: 500, fontSize: 12, color: t === "Chat" ? brand.amber : "rgba(255,255,255,0.4)", background: "none", border: "none", borderBottom: `2px solid ${t === "Chat" ? brand.amber : "transparent"}`, padding: "12px 8px", cursor: "pointer" }}>{t}</button>
                  ))}
                </div>
                <div style={{ height: 200, overflowY: "auto", padding: "12px 14px" }}>
                  {msgs.map((m, i) => (
                    <div key={i} style={{ marginBottom: 10 }}>
                      <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: m.isInstructor ? brand.amber : "rgba(255,255,255,0.7)" }}>{m.name} </span>
                      <span style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.6)" }}>{m.text}</span>
                    </div>
                  ))}
                </div>
                <div style={{ padding: "8px 12px", borderTop: "1px solid rgba(255,255,255,0.06)", display: "flex", gap: 8 }}>
                  <input value={chatInput} onChange={(e) => setChatInput(e.target.value)} onKeyDown={(e) => { if (e.key === "Enter" && chatInput.trim()) { setMsgs((prev) => [...prev, { name: "You", text: chatInput, time: "Now" }]); setChatInput(""); } }}
                    placeholder="Chat…" style={{ flex: 1, fontFamily: "Inter", fontSize: 12, color: "#fff", background: "rgba(255,255,255,0.06)", border: "1px solid rgba(255,255,255,0.08)", borderRadius: 7, padding: "7px 10px", outline: "none" }} />
                  <button style={{ width: 30, height: 30, borderRadius: 7, background: gradientFlow, border: "none", display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer" }}><Send size={13} color="#fff" /></button>
                </div>
              </div>
              <div style={{ background: brand.white, borderRadius: 16, border: `1px solid ${brand.borderGray}`, padding: "14px 16px" }}>
                <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal, marginBottom: 8 }}>Ask the Surgeon</div>
                <textarea value={question} onChange={(e) => setQuestion(e.target.value)} placeholder="Submit your question — selected questions answered live…" rows={2}
                  style={{ width: "100%", fontFamily: "Inter", fontSize: 12, color: brand.charcoal, background: brand.offWhite, border: `1px solid ${brand.borderGray}`, borderRadius: 8, padding: "8px 10px", outline: "none", resize: "none", boxSizing: "border-box" as const }} />
                <button onClick={() => setQuestion("")} style={{ marginTop: 8, width: "100%", fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: "#fff", background: gradientFlow, border: "none", borderRadius: 8, padding: "8px", cursor: "pointer" }}>Submit Question</button>
              </div>
            </div>
          </div>
        </div>

        {/* Upcoming */}
        <div style={{ marginBottom: 44 }}>
          <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.charcoal, marginBottom: 20 }}>Upcoming Demonstrations</div>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(280px, 1fr))", gap: 16 }}>
            {upcoming.map((d) => (
              <div key={d.title} style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, overflow: "hidden", cursor: "pointer", transition: "transform 0.2s, box-shadow 0.2s" }}
                onMouseEnter={(e) => { (e.currentTarget as HTMLElement).style.transform = "translateY(-4px)"; (e.currentTarget as HTMLElement).style.boxShadow = "0 8px 24px rgba(27,27,27,0.1)"; }}
                onMouseLeave={(e) => { (e.currentTarget as HTMLElement).style.transform = "none"; (e.currentTarget as HTMLElement).style.boxShadow = "none"; }}
              >
                <div style={{ height: 140, position: "relative" }}>
                  <img src={d.thumb} alt={d.title} style={{ width: "100%", height: "100%", objectFit: "cover" }} />
                  <div style={{ position: "absolute", top: 10, left: 10 }}><GradientBadge small>{d.specialty}</GradientBadge></div>
                </div>
                <div style={{ padding: "16px 16px" }}>
                  <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.charcoal, marginBottom: 4, lineHeight: 1.3 }}>{d.title}</div>
                  <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginBottom: 10 }}>{d.surgeon}</div>
                  <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                    <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.amber, display: "flex", alignItems: "center", gap: 4 }}>
                      <Calendar size={11} /> {d.date}
                    </div>
                    <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{d.registered.toLocaleString()} registered</div>
                  </div>
                  <button style={{ width: "100%", marginTop: 12, fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 8, padding: "9px", cursor: "pointer" }}>
                    Register Free
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Past demos */}
        <div>
          <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.charcoal, marginBottom: 20 }}>Recorded Demonstrations</div>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(300px, 1fr))", gap: 16 }}>
            {pastDemos.map((d) => (
              <div key={d.title} style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, overflow: "hidden", cursor: "pointer", transition: "transform 0.2s" }}
                onMouseEnter={(e) => (e.currentTarget as HTMLElement).style.transform = "translateY(-3px)"}
                onMouseLeave={(e) => (e.currentTarget as HTMLElement).style.transform = "none"}
              >
                <div style={{ height: 150, position: "relative" }}>
                  <img src={d.thumb} alt={d.title} style={{ width: "100%", height: "100%", objectFit: "cover" }} />
                  <div style={{ position: "absolute", inset: 0, background: "rgba(0,0,0,0.25)", display: "flex", alignItems: "center", justifyContent: "center" }}>
                    <div style={{ width: 40, height: 40, borderRadius: "50%", background: "rgba(255,255,255,0.9)", display: "flex", alignItems: "center", justifyContent: "center" }}>
                      <Play size={16} fill={brand.orange} color={brand.orange} style={{ marginLeft: 2 }} />
                    </div>
                  </div>
                  <div style={{ position: "absolute", bottom: 8, right: 8, fontFamily: "Inter", fontSize: 11, color: "#fff", background: "rgba(0,0,0,0.6)", borderRadius: 5, padding: "2px 7px" }}>{d.duration}</div>
                </div>
                <div style={{ padding: "14px 16px" }}>
                  <GradientBadge small>{d.specialty}</GradientBadge>
                  <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.charcoal, margin: "8px 0 4px", lineHeight: 1.3 }}>{d.title}</div>
                  <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginBottom: 8 }}>{d.surgeon}</div>
                  <div style={{ display: "flex", justifyContent: "space-between", fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>
                    <span>{d.views.toLocaleString()} views</span>
                    <span>{d.date}</span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
