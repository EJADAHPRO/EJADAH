import { useState } from "react";
import { useNavigate, useParams } from "react-router";
import {
  Star, MapPin, Globe, CheckCircle, ArrowRight, MessageSquare,
  Bookmark, Share2, ChevronLeft, Clock, ThumbsUp, Shield,
  FileText, Calendar, ChevronRight,
} from "lucide-react";
import { brand, gradientFlow, GradientBadge } from "@/app/shared";

const consultantData: Record<string, any> = {
  "1": {
    name: "Dr. Mona Khalil",
    title: "Orthodontist · Career Consultant",
    specialty: "Career Abroad",
    country: "Egypt / UK",
    languages: ["Arabic", "English"],
    rating: 4.9, reviewCount: 203, consultations: 480,
    avatar: "https://images.unsplash.com/photo-1619450565660-2a93ba8603fd?w=300&q=80",
    available: true,
    categories: ["Career Abroad", "ORE / LDS Pathway", "UK NHS Career", "CV & Portfolio", "Interview Preparation"],
    bio: "I am an Egyptian orthodontist currently practicing in the NHS and consulting part-time for Egyptian dentists navigating the ORE and UK career pathway. I've personally been through every stage — the ORE Part 1 and 2, GDC registration, associate job search, and NHS contract negotiation.\n\nI consult exclusively on the UK and Ireland pathways and I bring zero fluff — just direct, accurate, experience-based guidance.",
    sessionTypes: [
      { label: "Career Strategy Session", duration: "60 min", price: 550, desc: "Assess where you are, where you want to go, and build a realistic pathway. Best starting point." },
      { label: "CV & Portfolio Review", duration: "45 min", price: 400, desc: "I review your CV and portfolio, then provide a written report with tracked changes and recommendations." },
      { label: "Mock Interview", duration: "60 min", price: 500, desc: "Full NHS associate interview simulation with detailed feedback on presentation, answers, and body language." },
      { label: "Document Checklist Consultation", duration: "30 min", price: 280, desc: "Go through your full GDC application documents — make sure nothing is missing before you submit." },
    ],
    deliverables: ["Personalised Career Roadmap PDF", "CV Rewrite with tracked changes", "Document Checklist per country", "Written exam strategy summary", "Job search resource list"],
    process: ["Book a session type", "Complete a 10-min pre-consultation form", "Attend the session", "Receive written deliverable within 48h", "Free 15-min follow-up if needed"],
    reviewsList: [
      { name: "Dr. Nour Abdelfattah", avatar: "https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=60&q=80", rating: 5, date: "Jun 2025", role: "Now working in Manchester", text: "I came to Dr. Mona completely confused about the ORE — I had conflicting information from 4 different sources. One 60-minute session with her cleared everything up. She sent me a detailed PDF roadmap after the call. Passed ORE Part 1 on my first attempt." },
      { name: "Dr. Khaled Amir", avatar: "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=60&q=80", rating: 5, date: "Apr 2025", role: "ORE Candidate", text: "The mock interview was worth every penny. She plays the role of the interviewer so seriously that the real thing felt easy by comparison. Got offered an associate position in Birmingham." },
      { name: "Dr. Lina Samir", avatar: "https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=60&q=80", rating: 5, date: "Mar 2025", role: "Fresh Graduate", text: "Dr. Mona told me honestly that I wasn't ready to apply yet and exactly what I needed to do first. That kind of direct feedback is rare. Six months later I was ready — and she was right." },
    ],
  },
  "2": {
    name: "Dr. Rania Hassan",
    title: "Periodontist · Research Consultant",
    specialty: "Research & Academia",
    country: "Egypt",
    languages: ["Arabic", "English"],
    rating: 4.8, reviewCount: 134, consultations: 290,
    avatar: "https://images.unsplash.com/photo-1657470179447-0f5aa16daa91?w=300&q=80",
    available: true,
    categories: ["Research Methodology", "Systematic Reviews", "Publication Strategy", "Thesis Writing", "Grant Applications"],
    bio: "I am a consultant periodontist and researcher with 10 years of experience in academic dentistry. I've published 28 peer-reviewed papers, supervised 20+ postgraduate theses, and served as a reviewer for several indexed journals.\n\nI consult on all stages of dental research — from designing a study to getting it published in a good journal.",
    sessionTypes: [
      { label: "Research Planning Session", duration: "60 min", price: 600, desc: "Define your research question, methodology, and publication strategy from the start." },
      { label: "Manuscript Review", duration: "90 min", price: 850, desc: "I read your full manuscript and provide a detailed report covering structure, methods, results, discussion, and language." },
      { label: "Statistical Analysis Guidance", duration: "60 min", price: 650, desc: "Choose the right statistical tests, interpret your results, and understand how to present them." },
      { label: "Journal Selection & Submission", duration: "45 min", price: 450, desc: "Find the right journal for your paper, understand the submission process, and prepare your cover letter." },
    ],
    deliverables: ["Written Research Protocol Review", "Manuscript Review Report", "Journal Recommendations List", "Statistical Analysis Summary", "Submission Checklist"],
    process: ["Book session type", "Upload your document or describe your study", "Attend session", "Receive written report within 72h", "One round of follow-up questions included"],
    reviewsList: [
      { name: "Dr. Ahmed Hamdy", avatar: "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=60&q=80", rating: 5, date: "May 2025", role: "PhD Student", text: "Dr. Rania reviewed my entire systematic review protocol in one session and completely reframed my research question. My supervisor was impressed with the quality of the revision. She also suggested the perfect journal — it got accepted." },
      { name: "Dr. Sara Kamel", avatar: "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=60&q=80", rating: 5, date: "Mar 2025", role: "MSc Student", text: "The statistical guidance session saved my thesis. I had the wrong test for my data type and she caught it immediately. Clear explanations and she followed up to make sure I understood." },
    ],
  },
};

export default function ConsultantProfile() {
  const { id } = useParams();
  const nav = useNavigate();
  const consultant = consultantData[id ?? "1"] ?? consultantData["1"];

  const [selectedSession, setSelectedSession] = useState(0);
  const [saved, setSaved] = useState(false);
  const [activeTab, setActiveTab] = useState<"about" | "sessions" | "reviews">("about");
  const [booked, setBooked] = useState(false);

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      <div style={{ maxWidth: 1280, margin: "0 auto", padding: "20px 24px 0" }}>
        <button onClick={() => nav("/consulting")} style={{ background: "none", border: "none", cursor: "pointer", color: brand.warmGray, fontFamily: "Inter", fontSize: 13, display: "flex", alignItems: "center", gap: 5 }}>
          <ChevronLeft size={15} /> Back to Consultants
        </button>
      </div>

      {/* Hero */}
      <div style={{ background: brand.charcoal, marginTop: 16 }}>
        <div style={{ height: 6, background: `linear-gradient(90deg, ${brand.red}, ${brand.orange})` }} />
        <div style={{ maxWidth: 1280, margin: "0 auto", padding: "40px 24px 36px", display: "flex", gap: 28, alignItems: "flex-start", flexWrap: "wrap" }}>
          <div style={{ display: "flex", gap: 22, alignItems: "flex-start", flex: 1 }}>
            <div style={{ position: "relative", flexShrink: 0 }}>
              <img src={consultant.avatar} alt={consultant.name} style={{ width: 96, height: 96, borderRadius: 20, objectFit: "cover", border: "3px solid rgba(255,255,255,0.12)" }} />
              <div style={{ position: "absolute", bottom: -3, right: -3, width: 19, height: 19, borderRadius: "50%", background: consultant.available ? "#2D9B68" : brand.warmGray, border: "3px solid #1B1B1B" }} />
            </div>
            <div>
              <div style={{ display: "flex", gap: 10, alignItems: "center", flexWrap: "wrap", marginBottom: 6 }}>
                <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(20px,3vw,28px)", color: "#fff" }}>{consultant.name}</h1>
                <div style={{ width: 20, height: 20, borderRadius: "50%", background: gradientFlow, display: "flex", alignItems: "center", justifyContent: "center" }}><CheckCircle size={11} color="#fff" /></div>
              </div>
              <div style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.55)", marginBottom: 12 }}>{consultant.title}</div>
              <div style={{ display: "flex", gap: 10, flexWrap: "wrap", marginBottom: 14 }}>
                <GradientBadge small>{consultant.specialty}</GradientBadge>
                <span style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.5)", display: "flex", alignItems: "center", gap: 4 }}><MapPin size={12} /> {consultant.country}</span>
                <span style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.5)", display: "flex", alignItems: "center", gap: 4 }}><Globe size={12} /> {consultant.languages.join(" · ")}</span>
              </div>
              <div style={{ display: "flex", gap: 20, flexWrap: "wrap" }}>
                <span style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.5)" }}>{consultant.rating}★ ({consultant.reviewCount} reviews)</span>
                <span style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.5)" }}>{consultant.consultations} consultations</span>
              </div>
            </div>
          </div>
          <div style={{ display: "flex", gap: 10, flexShrink: 0 }}>
            <button onClick={() => setSaved(!saved)} style={{ width: 42, height: 42, borderRadius: 12, background: "rgba(255,255,255,0.08)", border: "1px solid rgba(255,255,255,0.12)", display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer", color: saved ? brand.amber : "rgba(255,255,255,0.6)" }}>
              <Bookmark size={17} fill={saved ? brand.amber : "none"} />
            </button>
            <button style={{ width: 42, height: 42, borderRadius: 12, background: "rgba(255,255,255,0.08)", border: "1px solid rgba(255,255,255,0.12)", display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer", color: "rgba(255,255,255,0.6)" }}><Share2 size={17} /></button>
            <button style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: "#fff", background: "rgba(255,255,255,0.1)", border: "1px solid rgba(255,255,255,0.15)", borderRadius: 12, padding: "10px 18px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}>
              <MessageSquare size={14} /> Message
            </button>
          </div>
        </div>
      </div>

      {/* Body */}
      <div style={{ maxWidth: 1280, margin: "0 auto", padding: "32px 24px", display: "flex", gap: 28, alignItems: "flex-start", flexWrap: "wrap" }}>
        <div style={{ flex: 1, minWidth: 300 }}>
          <div style={{ display: "flex", borderBottom: `2px solid ${brand.borderGray}`, marginBottom: 28 }}>
            {(["about", "sessions", "reviews"] as const).map((tab) => (
              <button key={tab} onClick={() => setActiveTab(tab)} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: activeTab === tab ? brand.red : brand.warmGray, background: "none", border: "none", borderBottom: `2px solid ${activeTab === tab ? brand.red : "transparent"}`, marginBottom: -2, padding: "10px 20px", cursor: "pointer", textTransform: "capitalize" as const }}>
                {tab === "reviews" ? `Reviews (${consultant.reviewCount})` : tab === "sessions" ? "Session Types" : "About"}
              </button>
            ))}
          </div>

          {activeTab === "about" && (
            <div>
              <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px 26px", marginBottom: 18 }}>
                <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 14 }}>About</h2>
                {consultant.bio.split("\n\n").map((p: string, i: number) => <p key={i} style={{ fontFamily: "Inter", fontSize: 14, color: brand.charcoal, lineHeight: 1.75, marginBottom: 12 }}>{p}</p>)}
              </div>
              <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px 26px", marginBottom: 18 }}>
                <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 14 }}>Consulting Areas</h2>
                <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
                  {consultant.categories.map((c: string) => <span key={c} style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, background: "rgba(255,45,50,0.06)", border: `1px solid rgba(255,45,50,0.15)`, borderRadius: 8, padding: "6px 12px" }}>{c}</span>)}
                </div>
              </div>
              <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px 26px", marginBottom: 18 }}>
                <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 14 }}>What You'll Receive</h2>
                {consultant.deliverables.map((d: string) => (
                  <div key={d} style={{ display: "flex", gap: 10, alignItems: "center", marginBottom: 10 }}>
                    <FileText size={14} color={brand.orange} style={{ flexShrink: 0 }} />
                    <span style={{ fontFamily: "Inter", fontSize: 14, color: brand.charcoal }}>{d}</span>
                  </div>
                ))}
              </div>
              <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px 26px" }}>
                <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 14 }}>The Process</h2>
                {consultant.process.map((step: string, i: number) => (
                  <div key={step} style={{ display: "flex", gap: 12, alignItems: "flex-start", marginBottom: 12 }}>
                    <div style={{ width: 26, height: 26, borderRadius: "50%", background: gradientFlow, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                      <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: "#fff" }}>{i + 1}</span>
                    </div>
                    <span style={{ fontFamily: "Inter", fontSize: 14, color: brand.charcoal, lineHeight: 1.5, paddingTop: 3 }}>{step}</span>
                  </div>
                ))}
              </div>
            </div>
          )}

          {activeTab === "sessions" && (
            <div style={{ display: "flex", flexDirection: "column" as const, gap: 14 }}>
              {consultant.sessionTypes.map((s: any, i: number) => {
                const isSel = selectedSession === i;
                return (
                  <div key={s.label} onClick={() => setSelectedSession(i)} style={{ background: brand.white, borderRadius: 18, border: `2px solid ${isSel ? brand.red : brand.borderGray}`, padding: "22px 22px", cursor: "pointer", transition: "all 0.15s" }}>
                    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
                      <div style={{ flex: 1 }}>
                        <div style={{ display: "flex", gap: 10, alignItems: "center", marginBottom: 6 }}>
                          <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: isSel ? brand.red : brand.charcoal }}>{s.label}</span>
                          <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, display: "flex", alignItems: "center", gap: 4 }}><Clock size={11} /> {s.duration}</span>
                        </div>
                        <p style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, lineHeight: 1.55 }}>{s.desc}</p>
                      </div>
                      <div style={{ textAlign: "right" as const, flexShrink: 0, marginLeft: 20 }}>
                        <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: isSel ? brand.red : brand.charcoal }}>EGP {s.price}</div>
                        {isSel && <CheckCircle size={16} color={brand.red} style={{ marginTop: 6 }} />}
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          )}

          {activeTab === "reviews" && (
            <div>
              {(consultant.reviewsList ?? []).map((r: any) => (
                <div key={r.name} style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "20px 22px", marginBottom: 12 }}>
                  <div style={{ display: "flex", gap: 12, alignItems: "flex-start", marginBottom: 10 }}>
                    <img src={r.avatar} alt={r.name} style={{ width: 42, height: 42, borderRadius: "50%", objectFit: "cover", flexShrink: 0 }} />
                    <div style={{ flex: 1 }}>
                      <div style={{ display: "flex", justifyContent: "space-between", flexWrap: "wrap" }}>
                        <div><div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal }}>{r.name}</div><div style={{ fontFamily: "Inter", fontSize: 12, color: brand.orange }}>{r.role}</div></div>
                        <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>{r.date}</span>
                      </div>
                      <div style={{ display: "flex", gap: 2, marginTop: 5 }}>{[1,2,3,4,5].map((i) => <Star key={i} size={11} fill={i<=r.rating?brand.amber:"none"} color={i<=r.rating?brand.amber:brand.borderGray} />)}</div>
                    </div>
                  </div>
                  <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.charcoal, lineHeight: 1.65 }}>{r.text}</p>
                  <button style={{ marginTop: 8, background: "none", border: "none", cursor: "pointer", color: brand.warmGray, fontFamily: "Inter", fontSize: 12, display: "flex", alignItems: "center", gap: 4 }}><ThumbsUp size={12} /> Helpful</button>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Sidebar */}
        <div style={{ width: 300, flexShrink: 0 }}>
          <div style={{ position: "sticky", top: 88 }}>
            <div style={{ background: brand.white, borderRadius: 22, border: `1px solid ${brand.borderGray}`, overflow: "hidden", boxShadow: "0 8px 32px rgba(27,27,27,0.1)" }}>
              <div style={{ height: 5, background: `linear-gradient(90deg, ${brand.red}, ${brand.orange})` }} />
              <div style={{ padding: "22px 20px" }}>
                <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.warmGray, marginBottom: 10 }}>Book a consultation</div>
                {/* Session type selector */}
                <div style={{ display: "flex", flexDirection: "column" as const, gap: 8, marginBottom: 18 }}>
                  {consultant.sessionTypes.map((s: any, i: number) => {
                    const isSel = selectedSession === i;
                    return (
                      <button key={s.label} onClick={() => setSelectedSession(i)} style={{ fontFamily: "Inter", fontWeight: isSel ? 600 : 400, fontSize: 12, color: isSel ? "#fff" : brand.charcoal, background: isSel ? gradientFlow : brand.offWhite, border: `1.5px solid ${isSel ? "transparent" : brand.borderGray}`, borderRadius: 10, padding: "10px 12px", cursor: "pointer", textAlign: "left" as const, display: "flex", justifyContent: "space-between", transition: "all 0.15s" }}>
                        <span>{s.label}</span>
                        <span style={{ flexShrink: 0, marginLeft: 8 }}>EGP {s.price}</span>
                      </button>
                    );
                  })}
                </div>

                <div style={{ display: "flex", alignItems: "baseline", gap: 6, marginBottom: 18 }}>
                  <span style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 28, color: brand.charcoal }}>EGP {consultant.sessionTypes[selectedSession].price}</span>
                  <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>· {consultant.sessionTypes[selectedSession].duration}</span>
                </div>

                {booked ? (
                  <div style={{ background: "rgba(45,155,104,0.08)", border: "1px solid rgba(45,155,104,0.25)", borderRadius: 12, padding: "14px", textAlign: "center" as const, marginBottom: 12 }}>
                    <CheckCircle size={24} color="#2D9B68" style={{ marginBottom: 8 }} />
                    <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: "#2D9B68" }}>Booking Requested!</div>
                    <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginTop: 4 }}>Consultant will confirm within 2 hours</div>
                  </div>
                ) : (
                  <button onClick={() => setBooked(true)} style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "13px", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 8, boxShadow: "0 4px 16px rgba(255,107,26,0.35)", marginBottom: 10 }}>
                    Book Consultation <ArrowRight size={14} />
                  </button>
                )}
                <button style={{ width: "100%", fontFamily: "Inter", fontWeight: 500, fontSize: 13, color: brand.charcoal, background: "none", border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "11px", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 6 }}>
                  <MessageSquare size={13} /> Message First
                </button>
                <div style={{ marginTop: 14, display: "flex", gap: 6, alignItems: "flex-start" }}>
                  <Shield size={12} color={brand.warmGray} style={{ marginTop: 1, flexShrink: 0 }} />
                  <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, lineHeight: 1.5 }}>Written deliverable included. Full refund if consultant doesn't confirm within 24h.</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
