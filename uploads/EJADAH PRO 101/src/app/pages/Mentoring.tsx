import { useState } from "react";
import { useNavigate } from "react-router";
import {
  Star, MapPin, Globe, ArrowRight, Search, CheckCircle,
  Clock, Users, Filter, ChevronDown, Calendar, Bookmark,
} from "lucide-react";
import { brand, gradientFlow, GradientBadge, StarRating } from "@/app/shared";

const mentors = [
  {
    id: "1",
    name: "Dr. Youssef Ramadan",
    title: "Implant Specialist · MSc King's College London",
    specialty: "Implantology",
    country: "Egypt / UK",
    languages: ["Arabic", "English"],
    rating: 4.9, reviews: 142, mentees: 58,
    areas: ["International Career Planning", "Specialty Selection", "Portfolio Building", "Postgraduate Applications", "Clinical Development"],
    packages: [{ label: "Single Session", price: 600 }, { label: "1 Month", price: 2000 }, { label: "3 Months", price: 5500, popular: true }, { label: "6 Months", price: 9500 }],
    avatar: "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=160&q=80",
    available: true,
    bio: "I guide Egyptian dentists through the entire journey of building an international career — from exam preparation and CV writing to relocation and beyond. Having done this myself via the ORE and King's College London, I understand every step.",
    nextSlot: "Today",
  },
  {
    id: "2",
    name: "Dr. Laila Shawki",
    title: "Prosthodontist · Digital Dentistry Lead",
    specialty: "Prosthodontics / Digital",
    country: "Egypt / Germany",
    languages: ["Arabic", "English", "German"],
    rating: 4.8, reviews: 98, mentees: 41,
    areas: ["Digital Dentistry Career", "Research & Academia", "Personal Branding", "Master's Applications", "Clinical Excellence"],
    packages: [{ label: "Single Session", price: 700 }, { label: "1 Month", price: 2400 }, { label: "3 Months", price: 6500, popular: true }, { label: "6 Months", price: 11000 }],
    avatar: "https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=160&q=80",
    available: false,
    bio: "I help dentists who want to build a career in digital dentistry or pursue academic pathways in Europe. I currently work across Egypt and Germany and can give real-world guidance on both systems.",
    nextSlot: "Jun 25",
  },
  {
    id: "3",
    name: "Dr. Hany Ibrahim",
    title: "Oral Surgeon · Associate Professor",
    specialty: "Oral Surgery",
    country: "Egypt",
    languages: ["Arabic", "English"],
    rating: 4.9, reviews: 186, mentees: 72,
    areas: ["Academic Career", "Research Development", "Specialty Residency", "Publication Strategy", "Dental Business"],
    packages: [{ label: "Single Session", price: 800 }, { label: "1 Month", price: 2800 }, { label: "3 Months", price: 7500, popular: true }, { label: "6 Months", price: 13000 }],
    avatar: "https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=160&q=80",
    available: true,
    bio: "As an associate professor and practicing surgeon, I mentor dentists who want to pursue academic or research careers. I've supervised 30+ postgraduate theses and can guide you from residency applications through to publication.",
    nextSlot: "Tomorrow",
  },
  {
    id: "4",
    name: "Dr. Amira Soliman",
    title: "Consultant Endodontist · PhD",
    specialty: "Endodontics",
    country: "Egypt",
    languages: ["Arabic", "English"],
    rating: 4.9, reviews: 124, mentees: 45,
    areas: ["Clinical Development", "Specialty Mastery", "Practice Setup", "Exam Strategy", "Career Roadmapping"],
    packages: [{ label: "Single Session", price: 500 }, { label: "1 Month", price: 1800 }, { label: "3 Months", price: 4800, popular: true }, { label: "6 Months", price: 8200 }],
    avatar: "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=160&q=80",
    available: true,
    bio: "I help dentists who want to build genuine clinical excellence in endodontics — not just pass exams but become truly confident clinicians. I also mentor those considering academic or specialist pathways.",
    nextSlot: "Today",
  },
];

const areaFilters = ["All Areas", "International Career", "Research & Academia", "Clinical Development", "Personal Branding", "Practice Setup", "Master's Programs", "Postgraduate Applications"];

function MentorCard({ mentor }: { mentor: typeof mentors[0] }) {
  const nav = useNavigate();
  const [saved, setSaved] = useState(false);

  return (
    <div style={{ background: brand.white, borderRadius: 22, border: `1px solid ${brand.borderGray}`, overflow: "hidden", boxShadow: "0 2px 12px rgba(27,27,27,0.05)", transition: "transform 0.2s, box-shadow 0.2s" }}
      onMouseEnter={(e) => { (e.currentTarget as HTMLElement).style.transform = "translateY(-4px)"; (e.currentTarget as HTMLElement).style.boxShadow = "0 10px 30px rgba(27,27,27,0.1)"; }}
      onMouseLeave={(e) => { (e.currentTarget as HTMLElement).style.transform = "none"; (e.currentTarget as HTMLElement).style.boxShadow = "0 2px 12px rgba(27,27,27,0.05)"; }}
    >
      {/* Gradient top */}
      <div style={{ height: 5, background: `linear-gradient(90deg, ${brand.amber}, ${brand.gold})` }} />
      <div style={{ padding: "22px 22px 18px" }}>
        {/* Header */}
        <div style={{ display: "flex", gap: 14, alignItems: "flex-start", marginBottom: 14 }}>
          <div style={{ position: "relative", flexShrink: 0 }}>
            <img src={mentor.avatar} alt={mentor.name} style={{ width: 66, height: 66, borderRadius: 16, objectFit: "cover" }} />
            <div style={{ position: "absolute", bottom: 3, right: 3, width: 12, height: 12, borderRadius: "50%", background: mentor.available ? "#2D9B68" : brand.warmGray, border: "2px solid #fff" }} />
          </div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
              <div>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: brand.charcoal, marginBottom: 2 }}>{mentor.name}</div>
                <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginBottom: 6 }}>{mentor.title}</div>
                <div style={{ display: "flex", gap: 6, flexWrap: "wrap" }}>
                  <GradientBadge small>{mentor.specialty}</GradientBadge>
                  <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, display: "flex", alignItems: "center", gap: 3 }}><MapPin size={10} /> {mentor.country}</span>
                </div>
              </div>
              <button onClick={(e) => { e.stopPropagation(); setSaved(!saved); }} style={{ background: "none", border: "none", cursor: "pointer", color: saved ? brand.amber : brand.warmGray, flexShrink: 0 }}>
                <Bookmark size={16} fill={saved ? brand.amber : "none"} />
              </button>
            </div>
          </div>
        </div>

        {/* Bio */}
        <p style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, lineHeight: 1.6, marginBottom: 14, display: "-webkit-box", WebkitLineClamp: 2, WebkitBoxOrient: "vertical", overflow: "hidden" }}>{mentor.bio}</p>

        {/* Mentoring areas */}
        <div style={{ display: "flex", gap: 5, flexWrap: "wrap", marginBottom: 14 }}>
          {mentor.areas.slice(0, 3).map((a) => (
            <span key={a} style={{ fontFamily: "Inter", fontSize: 11, color: brand.charcoal, background: `${brand.amber}12`, border: `1px solid ${brand.amber}30`, borderRadius: 6, padding: "3px 8px" }}>{a}</span>
          ))}
          {mentor.areas.length > 3 && <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, padding: "3px 4px" }}>+{mentor.areas.length - 3}</span>}
        </div>

        {/* Stats */}
        <div style={{ display: "flex", gap: 16, marginBottom: 14, flexWrap: "wrap" }}>
          <div style={{ display: "flex", alignItems: "center", gap: 4 }}>
            <Star size={12} fill={brand.amber} color={brand.amber} />
            <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal }}>{mentor.rating}</span>
            <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>({mentor.reviews})</span>
          </div>
          <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, display: "flex", alignItems: "center", gap: 4 }}><Users size={12} /> {mentor.mentees} mentees</span>
          <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, display: "flex", alignItems: "center", gap: 4 }}><Globe size={12} /> {mentor.languages.join(" · ")}</span>
        </div>

        {/* Packages strip */}
        <div style={{ display: "flex", gap: 6, marginBottom: 16 }}>
          {mentor.packages.map((p) => (
            <div key={p.label} style={{ flex: 1, textAlign: "center" as const, background: p.popular ? `${brand.amber}10` : brand.offWhite, border: `1px solid ${p.popular ? brand.amber : brand.borderGray}`, borderRadius: 10, padding: "8px 4px", position: "relative" }}>
              {p.popular && <div style={{ position: "absolute", top: -8, left: "50%", transform: "translateX(-50%)", background: brand.amber, color: "#fff", fontFamily: "Inter", fontWeight: 700, fontSize: 8, borderRadius: 4, padding: "2px 5px", whiteSpace: "nowrap" as const }}>POPULAR</div>}
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.charcoal }}>{p.label}</div>
              <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginTop: 2 }}>EGP {p.price.toLocaleString()}</div>
            </div>
          ))}
        </div>

        {/* Footer */}
        <div style={{ height: 1, background: brand.borderGray, marginBottom: 14 }} />
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
          <div>
            <div style={{ fontFamily: "Inter", fontSize: 11, color: mentor.available ? "#2D9B68" : brand.warmGray, fontWeight: 600 }}>
              {mentor.available ? "⚡ Available" : `Next: ${mentor.nextSlot}`}
            </div>
          </div>
          <div style={{ display: "flex", gap: 8 }}>
            <button onClick={() => nav(`/mentoring/${mentor.id}`)} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 13, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 10, padding: "9px 14px", cursor: "pointer" }}>View Profile</button>
            <button onClick={() => nav(`/mentoring/${mentor.id}`)} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff", background: `linear-gradient(135deg, ${brand.amber}, ${brand.gold})`, border: "none", borderRadius: 10, padding: "9px 16px", cursor: "pointer", boxShadow: `0 3px 10px ${brand.amber}40` }}>Book</button>
          </div>
        </div>
      </div>
    </div>
  );
}

export default function Mentoring() {
  const nav = useNavigate();
  const [search, setSearch] = useState("");
  const [area, setArea] = useState("All Areas");

  const filtered = mentors.filter((m) => {
    const matchSearch = m.name.toLowerCase().includes(search.toLowerCase()) || m.specialty.toLowerCase().includes(search.toLowerCase());
    const matchArea = area === "All Areas" || m.areas.some((a) => a.toLowerCase().includes(area.toLowerCase().replace("all areas", "")));
    return matchSearch && matchArea;
  });

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Hero */}
      <div style={{ background: `linear-gradient(135deg, ${brand.charcoal} 0%, #24201D 100%)`, padding: "56px 24px 48px", position: "relative", overflow: "hidden" }}>
        <div style={{ position: "absolute", inset: 0, background: `radial-gradient(ellipse at 70% 40%, ${brand.amber}12 0%, transparent 60%)`, pointerEvents: "none" }} />
        <div style={{ maxWidth: 1280, margin: "0 auto", position: "relative" }}>
          <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, letterSpacing: "0.1em", color: brand.amber, textTransform: "uppercase" as const, marginBottom: 10 }}>Professional Services</div>
          <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(28px,4vw,44px)", color: "#fff", marginBottom: 14 }}>Dental Mentoring</h1>
          <p style={{ fontFamily: "Inter", fontSize: 16, color: "rgba(255,255,255,0.6)", maxWidth: 560, marginBottom: 32 }}>
            Long-term mentorship from experienced dental professionals. Whether you're planning a career abroad, entering academia, or developing your clinical identity — find a mentor who's walked the path.
          </p>
          <div style={{ display: "flex", gap: 10, flexWrap: "wrap", maxWidth: 620 }}>
            <div style={{ flex: 1, minWidth: 240, position: "relative" }}>
              <Search size={16} style={{ position: "absolute", left: 14, top: "50%", transform: "translateY(-50%)", color: "rgba(255,255,255,0.4)" }} />
              <input value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Search by name or specialty…" style={{ width: "100%", fontFamily: "Inter", fontSize: 14, background: "rgba(255,255,255,0.1)", border: "1px solid rgba(255,255,255,0.15)", borderRadius: 12, padding: "13px 16px 13px 42px", color: "#fff", outline: "none", boxSizing: "border-box" as const }} />
            </div>
          </div>
          <div style={{ display: "flex", gap: 28, marginTop: 28, flexWrap: "wrap" }}>
            {[["80+", "Verified Mentors"], ["2,400+", "Mentees Guided"], ["4.8★", "Average Rating"], ["90%", "Goal Achievement Rate"]].map(([v, l]) => (
              <div key={l}><div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.gold }}>{v}</div><div style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.45)", marginTop: 2 }}>{l}</div></div>
            ))}
          </div>
        </div>
      </div>

      <div style={{ maxWidth: 1280, margin: "0 auto", padding: "32px 24px" }}>
        {/* Mentoring areas filter */}
        <div style={{ background: brand.white, borderRadius: 16, border: `1px solid ${brand.borderGray}`, padding: "16px 20px", marginBottom: 28, display: "flex", gap: 10, flexWrap: "wrap", alignItems: "center" }}>
          <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, flexShrink: 0, display: "flex", alignItems: "center", gap: 6 }}><Filter size={14} /> Mentoring area:</span>
          {areaFilters.map((f) => (
            <button key={f} onClick={() => setArea(f)} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 12, color: area === f ? "#fff" : brand.charcoal, background: area === f ? `linear-gradient(135deg, ${brand.amber}, ${brand.gold})` : brand.offWhite, border: `1.5px solid ${area === f ? "transparent" : brand.borderGray}`, borderRadius: 20, padding: "5px 14px", cursor: "pointer", transition: "all 0.15s" }}>{f}</button>
          ))}
          <div style={{ marginLeft: "auto", fontFamily: "Inter", fontSize: 13, color: brand.warmGray }}>{filtered.length} mentor{filtered.length !== 1 ? "s" : ""}</div>
        </div>

        {/* How mentoring works */}
        <div style={{ background: `linear-gradient(135deg, ${brand.amber}08, ${brand.gold}08)`, border: `1px solid ${brand.amber}20`, borderRadius: 18, padding: "20px 28px", marginBottom: 32, display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(180px, 1fr))", gap: 20 }}>
          {[
            { icon: "🤝", title: "Choose your mentor", desc: "Browse by specialty, area, and package type" },
            { icon: "🎯", title: "Define your goal", desc: "Share where you are and where you want to go" },
            { icon: "📅", title: "Start sessions", desc: "Regular 1-on-1 sessions — monthly or weekly" },
            { icon: "🚀", title: "Achieve your vision", desc: "Track progress and adapt your plan as you grow" },
          ].map((s) => (
            <div key={s.title} style={{ display: "flex", gap: 12, alignItems: "flex-start" }}>
              <div style={{ fontSize: 24, flexShrink: 0 }}>{s.icon}</div>
              <div>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal }}>{s.title}</div>
                <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginTop: 3, lineHeight: 1.5 }}>{s.desc}</div>
              </div>
            </div>
          ))}
        </div>

        {/* Mentor grid */}
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(340px, 1fr))", gap: 20 }}>
          {filtered.map((m) => <MentorCard key={m.id} mentor={m} />)}
        </div>

        {/* Difference callout */}
        <div style={{ marginTop: 48, display: "grid", gridTemplateColumns: "1fr 1fr", gap: 20 }}>
          <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "28px" }}>
            <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 12 }}>Mentoring vs. Tutoring</div>
            <div style={{ display: "flex", flexDirection: "column" as const, gap: 10 }}>
              {[["Tutoring", "Single subject, exam prep, short sessions"], ["Mentoring", "Career direction, long-term growth, multi-session programs"]].map(([t, d]) => (
                <div key={t as string} style={{ background: brand.offWhite, borderRadius: 10, padding: "12px 14px" }}>
                  <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal }}>{t as string}</div>
                  <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginTop: 3 }}>{d as string}</div>
                </div>
              ))}
            </div>
          </div>
          <div style={{ background: brand.charcoal, borderRadius: 20, padding: "28px" }}>
            <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: "#fff", marginBottom: 10 }}>Become a Mentor</div>
            <p style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.6)", lineHeight: 1.6, marginBottom: 18 }}>Share your expertise and guide the next generation of dental professionals. Set your own packages, schedule, and mentoring focus.</p>
            <button style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff", background: `linear-gradient(135deg, ${brand.amber}, ${brand.gold})`, border: "none", borderRadius: 10, padding: "11px 20px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}>
              Apply as Mentor <ArrowRight size={13} />
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
