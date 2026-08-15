import { useState } from "react";
import { useNavigate } from "react-router";
import {
  Search, Star, MapPin, Globe, ArrowRight, CheckCircle,
  Clock, Filter, Bookmark, ChevronRight,
} from "lucide-react";
import { brand, gradientFlow, GradientBadge } from "@/app/shared";

const consultants = [
  {
    id: "1",
    name: "Dr. Mona Khalil",
    title: "Orthodontist · Career Consultant",
    specialty: "Career Abroad",
    categories: ["Career Abroad", "ORE / LDS Pathway", "UK NHS Career", "CV & Portfolio", "Interview Preparation"],
    country: "Egypt / UK",
    languages: ["Arabic", "English"],
    rating: 4.9, reviews: 203, consultations: 480,
    priceSession: 550,
    deliverables: ["Personalised Career Roadmap", "CV Review & Rewrite", "Document Checklist", "Exam Strategy"],
    sessionTypes: ["60-min Consultation", "Document Review", "Mock Interview"],
    avatar: "https://images.unsplash.com/photo-1619450565660-2a93ba8603fd?w=160&q=80",
    available: true,
    summary: "I help Egyptian dentists navigate the full ORE/LDS pathway and land NHS associate positions. I've been through this process myself and now consult full-time.",
  },
  {
    id: "2",
    name: "Dr. Rania Hassan",
    title: "Periodontist · Research Consultant",
    specialty: "Research & Academia",
    categories: ["Research Methodology", "Systematic Reviews", "Publication Strategy", "Thesis Writing", "Grant Applications"],
    country: "Egypt",
    languages: ["Arabic", "English"],
    rating: 4.8, reviews: 134, consultations: 290,
    priceSession: 600,
    deliverables: ["Research Protocol Review", "Statistical Analysis Guidance", "Journal Selection", "Writing Feedback"],
    sessionTypes: ["60-min Consultation", "Manuscript Review", "Research Planning"],
    avatar: "https://images.unsplash.com/photo-1657470179447-0f5aa16daa91?w=160&q=80",
    available: true,
    summary: "I guide dentists through every stage of academic research — from designing a study to publishing in indexed journals. I've reviewed 50+ theses and manuscripts.",
  },
  {
    id: "3",
    name: "Dr. Karim Nasser",
    title: "Digital Dentistry Specialist",
    specialty: "Digital Dentistry",
    categories: ["Digital Workflow Setup", "CAD/CAM Implementation", "Equipment Selection", "Intraoral Scanning", "Digital Photography"],
    country: "Egypt",
    languages: ["Arabic", "English"],
    rating: 4.7, reviews: 88, consultations: 175,
    priceSession: 800,
    deliverables: ["Digital Workflow Audit", "Equipment Recommendations", "Implementation Plan", "ROI Analysis"],
    sessionTypes: ["90-min Deep Dive", "Clinic Audit", "Equipment Comparison"],
    avatar: "https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=160&q=80",
    available: false,
    summary: "I help clinics transition to digital workflows — from selecting the right scanner and CAD/CAM system to training teams and measuring return on investment.",
  },
  {
    id: "4",
    name: "Dr. Tarek Saleh",
    title: "Orthodontist · Practice Consultant",
    specialty: "Practice Management",
    categories: ["Practice Setup", "Business Strategy", "Team Management", "Marketing", "Patient Experience"],
    country: "Egypt",
    languages: ["Arabic", "English"],
    rating: 4.8, reviews: 156, consultations: 340,
    priceSession: 700,
    deliverables: ["Practice Audit Report", "Growth Strategy Plan", "Fee Structure Review", "Marketing Roadmap"],
    sessionTypes: ["60-min Strategy Session", "Practice Audit", "Financial Review"],
    avatar: "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=160&q=80",
    available: true,
    summary: "I've helped 40+ dental clinics in Egypt build sustainable, profitable practices. I combine clinical knowledge with real business strategy — not generic advice.",
  },
  {
    id: "5",
    name: "Dr. Sara El-Sayed",
    title: "Endodontist · Master's Program Consultant",
    specialty: "Postgraduate Programs",
    categories: ["Master's Applications", "Postgraduate Planning", "Country Comparison", "Scholarship Search", "Application Writing"],
    country: "Egypt",
    languages: ["Arabic", "English"],
    rating: 4.9, reviews: 117, consultations: 220,
    priceSession: 500,
    deliverables: ["Program Shortlist", "Application Review", "SOP Writing Guidance", "Timeline Planning"],
    sessionTypes: ["60-min Consultation", "Application Review", "SOP Coaching"],
    avatar: "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=160&q=80",
    available: true,
    summary: "I help dentists find the right postgraduate program and build a competitive application. I've personally been through UK and European application processes.",
  },
  {
    id: "6",
    name: "Dr. Omar Farid",
    title: "Implantologist · Clinical Consultant",
    specialty: "Clinical Education",
    categories: ["Clinical Protocol Review", "Case Planning", "Technique Assessment", "Clinical Course Selection", "Skill Development Plan"],
    country: "Egypt / UK",
    languages: ["Arabic", "English"],
    rating: 4.8, reviews: 94, consultations: 195,
    priceSession: 750,
    deliverables: ["Clinical Skills Assessment", "Learning Roadmap", "Course Recommendations", "Case Review Report"],
    sessionTypes: ["60-min Clinical Review", "Case Discussion", "Skills Assessment"],
    avatar: "https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=160&q=80",
    available: true,
    summary: "I help dentists identify exactly where their clinical gaps are and build a structured plan to close them — whether through courses, cases, or direct coaching.",
  },
];

const categories = ["All Categories", "Career Abroad", "Research & Academia", "Digital Dentistry", "Practice Management", "Postgraduate Programs", "Clinical Education"];

function ConsultantCard({ c }: { c: typeof consultants[0] }) {
  const nav = useNavigate();
  const [saved, setSaved] = useState(false);
  return (
    <div style={{ background: brand.white, borderRadius: 22, border: `1px solid ${brand.borderGray}`, overflow: "hidden", boxShadow: "0 2px 12px rgba(27,27,27,0.05)", transition: "transform 0.2s, box-shadow 0.2s" }}
      onMouseEnter={(e) => { (e.currentTarget as HTMLElement).style.transform = "translateY(-4px)"; (e.currentTarget as HTMLElement).style.boxShadow = "0 10px 28px rgba(27,27,27,0.1)"; }}
      onMouseLeave={(e) => { (e.currentTarget as HTMLElement).style.transform = "none"; (e.currentTarget as HTMLElement).style.boxShadow = "0 2px 12px rgba(27,27,27,0.05)"; }}
    >
      <div style={{ height: 5, background: `linear-gradient(90deg, ${brand.red}, ${brand.orange})` }} />
      <div style={{ padding: "22px 22px 18px" }}>
        <div style={{ display: "flex", gap: 14, alignItems: "flex-start", marginBottom: 14 }}>
          <div style={{ position: "relative", flexShrink: 0 }}>
            <img src={c.avatar} alt={c.name} style={{ width: 60, height: 60, borderRadius: 14, objectFit: "cover" }} />
            <div style={{ position: "absolute", bottom: 3, right: 3, width: 11, height: 11, borderRadius: "50%", background: c.available ? "#2D9B68" : brand.warmGray, border: "2px solid #fff" }} />
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ display: "flex", justifyContent: "space-between" }}>
              <div>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal, marginBottom: 2 }}>{c.name}</div>
                <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginBottom: 6 }}>{c.title}</div>
                <div style={{ display: "flex", gap: 6, flexWrap: "wrap" }}>
                  <GradientBadge small>{c.specialty}</GradientBadge>
                  <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, display: "flex", alignItems: "center", gap: 3 }}><MapPin size={10} /> {c.country}</span>
                </div>
              </div>
              <button onClick={(e) => { e.stopPropagation(); setSaved(!saved); }} style={{ background: "none", border: "none", cursor: "pointer", color: saved ? brand.amber : brand.warmGray }}>
                <Bookmark size={15} fill={saved ? brand.amber : "none"} />
              </button>
            </div>
          </div>
        </div>
        <p style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, lineHeight: 1.6, marginBottom: 12, display: "-webkit-box", WebkitLineClamp: 2, WebkitBoxOrient: "vertical", overflow: "hidden" }}>{c.summary}</p>

        {/* Consulting categories */}
        <div style={{ display: "flex", gap: 5, flexWrap: "wrap", marginBottom: 12 }}>
          {c.categories.slice(0, 3).map((cat) => <span key={cat} style={{ fontFamily: "Inter", fontSize: 11, color: brand.charcoal, background: "rgba(255,45,50,0.06)", border: `1px solid rgba(255,45,50,0.15)`, borderRadius: 6, padding: "3px 8px" }}>{cat}</span>)}
          {c.categories.length > 3 && <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>+{c.categories.length - 3}</span>}
        </div>

        {/* Deliverables */}
        <div style={{ marginBottom: 14 }}>
          <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: brand.warmGray, marginBottom: 6 }}>DELIVERABLES</div>
          <div style={{ display: "flex", flexDirection: "column" as const, gap: 4 }}>
            {c.deliverables.slice(0, 2).map((d) => (
              <div key={d} style={{ display: "flex", gap: 6, alignItems: "center" }}>
                <CheckCircle size={11} color={brand.orange} style={{ flexShrink: 0 }} />
                <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.charcoal }}>{d}</span>
              </div>
            ))}
            {c.deliverables.length > 2 && <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginLeft: 17 }}>+{c.deliverables.length - 2} more</span>}
          </div>
        </div>

        {/* Stats + price */}
        <div style={{ display: "flex", gap: 14, marginBottom: 14 }}>
          <div style={{ display: "flex", alignItems: "center", gap: 4 }}>
            <Star size={12} fill={brand.amber} color={brand.amber} />
            <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal }}>{c.rating}</span>
            <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>({c.reviews})</span>
          </div>
          <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>{c.consultations} consultations</span>
          <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, display: "flex", alignItems: "center", gap: 3 }}><Globe size={11} /> {c.languages.join(" / ")}</span>
        </div>

        <div style={{ height: 1, background: brand.borderGray, marginBottom: 14 }} />
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
          <div>
            <span style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal }}>EGP {c.priceSession}</span>
            <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}> / session</span>
          </div>
          <button onClick={() => nav(`/consulting/${c.id}`)} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "9px 18px", cursor: "pointer", display: "flex", alignItems: "center", gap: 5, boxShadow: "0 3px 10px rgba(255,107,26,0.3)" }}>
            Book Consultation <ChevronRight size={13} />
          </button>
        </div>
      </div>
    </div>
  );
}

export default function Consulting() {
  const nav = useNavigate();
  const [search, setSearch] = useState("");
  const [category, setCategory] = useState("All Categories");

  const filtered = consultants.filter((c) => {
    const matchSearch = c.name.toLowerCase().includes(search.toLowerCase()) || c.specialty.toLowerCase().includes(search.toLowerCase());
    const matchCat = category === "All Categories" || c.specialty === category || c.categories.some((cat) => cat.toLowerCase().includes(category.toLowerCase().split(" ")[0].toLowerCase()));
    return matchSearch && matchCat;
  });

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Hero */}
      <div style={{ background: brand.charcoal, padding: "56px 24px 48px", position: "relative", overflow: "hidden" }}>
        <div style={{ position: "absolute", inset: 0, background: "radial-gradient(ellipse at 65% 40%, rgba(255,45,50,0.08) 0%, transparent 55%)", pointerEvents: "none" }} />
        <div style={{ maxWidth: 1280, margin: "0 auto", position: "relative" }}>
          <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, letterSpacing: "0.1em", color: brand.red, textTransform: "uppercase" as const, marginBottom: 10 }}>Professional Services</div>
          <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(28px,4vw,44px)", color: "#fff", marginBottom: 14 }}>Dental Consulting</h1>
          <p style={{ fontFamily: "Inter", fontSize: 16, color: "rgba(255,255,255,0.6)", maxWidth: 560, marginBottom: 32 }}>
            Expert consultations with verified dental specialists across career, research, clinical education, digital dentistry, and practice management. Get structured, deliverable-based advice — not generic guidance.
          </p>
          <div style={{ position: "relative", maxWidth: 520 }}>
            <Search size={16} style={{ position: "absolute", left: 14, top: "50%", transform: "translateY(-50%)", color: "rgba(255,255,255,0.4)" }} />
            <input value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Search by name, specialty, or topic…" style={{ width: "100%", fontFamily: "Inter", fontSize: 14, background: "rgba(255,255,255,0.1)", border: "1px solid rgba(255,255,255,0.15)", borderRadius: 12, padding: "13px 16px 13px 42px", color: "#fff", outline: "none", boxSizing: "border-box" as const }} />
          </div>
          <div style={{ display: "flex", gap: 28, marginTop: 28, flexWrap: "wrap" }}>
            {[["120+", "Expert Consultants"], ["6,000+", "Consultations Done"], ["4.8★", "Average Rating"], ["48h", "Avg. Turnaround"]].map(([v, l]) => (
              <div key={l}><div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.gold }}>{v}</div><div style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.45)", marginTop: 2 }}>{l}</div></div>
            ))}
          </div>
        </div>
      </div>

      <div style={{ maxWidth: 1280, margin: "0 auto", padding: "32px 24px" }}>
        {/* Category filter */}
        <div style={{ background: brand.white, borderRadius: 16, border: `1px solid ${brand.borderGray}`, padding: "16px 20px", marginBottom: 28, display: "flex", gap: 10, flexWrap: "wrap", alignItems: "center" }}>
          <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, display: "flex", alignItems: "center", gap: 6 }}><Filter size={14} /> Category:</span>
          {categories.map((cat) => (
            <button key={cat} onClick={() => setCategory(cat)} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 12, color: category === cat ? "#fff" : brand.charcoal, background: category === cat ? gradientFlow : brand.offWhite, border: `1.5px solid ${category === cat ? "transparent" : brand.borderGray}`, borderRadius: 20, padding: "5px 14px", cursor: "pointer", transition: "all 0.15s" }}>{cat}</button>
          ))}
          <div style={{ marginLeft: "auto", fontFamily: "Inter", fontSize: 13, color: brand.warmGray }}>{filtered.length} consultant{filtered.length !== 1 ? "s" : ""}</div>
        </div>

        {/* How it works */}
        <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "20px 28px", marginBottom: 32, display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(200px, 1fr))", gap: 20 }}>
          <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 16, color: brand.charcoal, display: "flex", alignItems: "center" }}>How it works</div>
          {[
            { n: "1", label: "Choose a consultant", desc: "Browse by specialty and deliverables" },
            { n: "2", label: "Define your question", desc: "Share your situation and what you need" },
            { n: "3", label: "Book a session", desc: "Pick a time — most confirm within 2h" },
            { n: "4", label: "Receive deliverables", desc: "Structured output after every consultation" },
          ].map((s) => (
            <div key={s.n} style={{ display: "flex", gap: 12, alignItems: "flex-start" }}>
              <div style={{ width: 28, height: 28, borderRadius: "50%", background: gradientFlow, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: "#fff" }}>{s.n}</span>
              </div>
              <div>
                <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal }}>{s.label}</div>
                <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginTop: 2 }}>{s.desc}</div>
              </div>
            </div>
          ))}
        </div>

        {/* Grid */}
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(340px, 1fr))", gap: 20 }}>
          {filtered.map((c) => <ConsultantCard key={c.id} c={c} />)}
        </div>
      </div>
    </div>
  );
}
