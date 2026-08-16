import { useState } from "react";
import { useNavigate } from "react-router";
import { Search, Star, Clock, Users, Award, Bookmark, ChevronDown, Filter } from "lucide-react";
import { brand, gradientFlow, GradientBadge, StarRating, SectionHeader } from "@/figma/app/shared";

const allCourses = [
  { id: "1", title: "Comprehensive Endodontics: From Basic to Advanced", instructor: "Dr. Amira Soliman", specialty: "Endodontics", rating: 4.8, students: 3420, duration: "22h", price: "EGP 1,200", type: "Recorded", accredited: true, thumb: "https://images.unsplash.com/photo-1588776814546-daab30f310ce?w=400&q=80" },
  { id: "2", title: "Implantology Foundation: Evidence-Based Approach", instructor: "Dr. Omar Farid", specialty: "Implantology", rating: 4.9, students: 2100, duration: "30h", price: "EGP 1,800", type: "Live", accredited: true, thumb: "https://images.unsplash.com/photo-1619450565660-2a93ba8603fd?w=400&q=80" },
  { id: "3", title: "Digital Workflow in Prosthodontics", instructor: "Dr. Laila Shawki", specialty: "Prosthodontics", rating: 4.7, students: 1850, duration: "18h", price: "EGP 950", type: "Hybrid", accredited: false, thumb: "https://images.unsplash.com/photo-1681939282781-341ac4f61996?w=400&q=80" },
  { id: "4", title: "Orthodontic Treatment Planning Essentials", instructor: "Dr. Tarek Saleh", specialty: "Orthodontics", rating: 4.8, students: 2780, duration: "25h", price: "EGP 1,400", type: "Recorded", accredited: true, thumb: "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=400&q=80" },
  { id: "5", title: "Oral Surgery: Extractions & Flap Design", instructor: "Dr. Hany Ibrahim", specialty: "Oral Surgery", rating: 4.9, students: 4100, duration: "20h", price: "EGP 1,100", type: "Recorded", accredited: true, thumb: "https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=400&q=80" },
  { id: "6", title: "Periodontal Disease: Diagnosis & Management", instructor: "Dr. Rania Hassan", specialty: "Periodontics", rating: 4.6, students: 1620, duration: "16h", price: "EGP 800", type: "Recorded", accredited: false, thumb: "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400&q=80" },
  { id: "7", title: "Digital Smile Design Masterclass", instructor: "Dr. Karim Nasser", specialty: "Digital Dentistry", rating: 4.8, students: 3200, duration: "24h", price: "EGP 1,600", type: "Live", accredited: true, thumb: "https://images.unsplash.com/photo-1657470179447-0f5aa16daa91?w=400&q=80" },
  { id: "8", title: "Pediatric Dentistry: Child Behavior & Clinical Skills", instructor: "Dr. Yasmine Adel", specialty: "Pediatric Dentistry", rating: 4.7, students: 980, duration: "14h", price: "EGP 700", type: "Recorded", accredited: false, thumb: "https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=400&q=80" },
];

const typeColors: Record<string, string> = { Recorded: brand.warmGray, Live: brand.red, Hybrid: brand.orange };
const specialties = [
  "All", "Oral Biology & Histology", "Pharmacology", "Dental Biomaterials", "Operative Dentistry",
  "Endodontics", "Fixed Prosthodontics", "Removable Prosthodontics", "Periodontology & Oral Medicine",
  "Oral Radiology", "Oral Pathology", "Oral & Maxillofacial Surgery", "Orthodontics",
  "Pediatric Dentistry", "Implant Dentistry", "Aesthetic Dentistry", "Digital Dentistry",
];
const types = ["All", "Recorded", "Live", "Hybrid"];

export default function Courses() {
  const nav = useNavigate();
  const [search, setSearch] = useState("");
  const [specialty, setSpecialty] = useState("All");
  const [type, setType] = useState("All");

  const filtered = allCourses.filter((c) => {
    const matchSearch = c.title.toLowerCase().includes(search.toLowerCase()) || c.instructor.toLowerCase().includes(search.toLowerCase());
    const matchSpecialty = specialty === "All" || c.specialty === specialty;
    const matchType = type === "All" || c.type === type;
    return matchSearch && matchSpecialty && matchType;
  });

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Header */}
      <div style={{ background: brand.charcoal, padding: "56px 24px 48px" }}>
        <div style={{ maxWidth: 1280, margin: "0 auto" }}>
          <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, letterSpacing: "0.1em", color: brand.amber, textTransform: "uppercase" as const, marginBottom: 10 }}>Courses</div>
          <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(28px,4vw,42px)", color: "#fff", marginBottom: 16 }}>Explore All Courses</h1>
          <p style={{ fontFamily: "Inter", fontSize: 16, color: "rgba(255,255,255,0.65)", marginBottom: 28, maxWidth: 520 }}>From recorded lectures to live masterclasses — discover dental education built for serious practitioners.</p>
          {/* Search */}
          <div style={{ position: "relative", maxWidth: 520 }}>
            <Search size={18} style={{ position: "absolute", left: 16, top: "50%", transform: "translateY(-50%)", color: brand.warmGray }} />
            <input value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Search courses, instructors, specialties…" style={{ width: "100%", fontFamily: "Inter", fontSize: 14, background: "rgba(255,255,255,0.1)", border: "1px solid rgba(255,255,255,0.15)", borderRadius: 12, padding: "13px 16px 13px 46px", color: "#fff", outline: "none", boxSizing: "border-box" as const }} />
          </div>
        </div>
      </div>

      <div style={{ maxWidth: 1280, margin: "0 auto", padding: "32px 24px" }}>
        {/* Filters */}
        <div style={{ display: "flex", gap: 12, marginBottom: 28, flexWrap: "wrap", alignItems: "center" }}>
          <div style={{ display: "flex", alignItems: "center", gap: 6, color: brand.warmGray, fontFamily: "Inter", fontSize: 13 }}>
            <Filter size={14} /> Filter by:
          </div>
          <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
            {specialties.map((s) => (
              <button key={s} onClick={() => setSpecialty(s)} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 12, color: specialty === s ? "#fff" : brand.charcoal, background: specialty === s ? gradientFlow : brand.white, border: `1.5px solid ${specialty === s ? "transparent" : brand.borderGray}`, borderRadius: 20, padding: "5px 14px", cursor: "pointer", transition: "all 0.15s" }}>{s}</button>
            ))}
          </div>
          <div style={{ display: "flex", gap: 8 }}>
            {types.map((t) => (
              <button key={t} onClick={() => setType(t)} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 12, color: type === t ? "#fff" : brand.charcoal, background: type === t ? (t === "Live" ? brand.red : t === "Hybrid" ? brand.orange : gradientFlow) : brand.white, border: `1.5px solid ${type === t ? "transparent" : brand.borderGray}`, borderRadius: 8, padding: "5px 14px", cursor: "pointer", transition: "all 0.15s" }}>{t}</button>
            ))}
          </div>
        </div>

        <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, marginBottom: 20 }}>{filtered.length} courses found</div>

        {/* Grid */}
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(280px, 1fr))", gap: 20 }}>
          {filtered.map((c) => (
            <div key={c.id} onClick={() => nav(`/courses/${c.id}`)} style={{ background: brand.white, borderRadius: 22, border: `1px solid ${brand.borderGray}`, overflow: "hidden", boxShadow: "0 2px 12px rgba(27,27,27,0.05)", transition: "transform 0.2s, box-shadow 0.2s", cursor: "pointer" }}
              onMouseEnter={(e) => { (e.currentTarget as HTMLElement).style.transform = "translateY(-5px)"; (e.currentTarget as HTMLElement).style.boxShadow = "0 12px 32px rgba(27,27,27,0.12)"; }}
              onMouseLeave={(e) => { (e.currentTarget as HTMLElement).style.transform = "none"; (e.currentTarget as HTMLElement).style.boxShadow = "0 2px 12px rgba(27,27,27,0.05)"; }}
            >
              <div style={{ position: "relative", height: 160 }}>
                <img src={c.thumb} alt={c.title} style={{ width: "100%", height: "100%", objectFit: "cover" }} />
                <div style={{ position: "absolute", top: 10, left: 10 }}>
                  <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 10, color: "#fff", background: typeColors[c.type] || brand.warmGray, padding: "3px 8px", borderRadius: 4, letterSpacing: "0.05em" }}>{c.type.toUpperCase()}</span>
                </div>
                <button onClick={(e2) => e2.stopPropagation()} style={{ position: "absolute", top: 10, right: 10, background: "rgba(255,255,255,0.9)", border: "none", borderRadius: 8, width: 30, height: 30, display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer" }}>
                  <Bookmark size={13} color={brand.warmGray} />
                </button>
              </div>
              <div style={{ padding: "16px 18px" }}>
                <div style={{ marginBottom: 8 }}><GradientBadge small>{c.specialty}</GradientBadge></div>
                <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.charcoal, lineHeight: 1.4, marginBottom: 6 }}>{c.title}</div>
                <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginBottom: 10 }}>{c.instructor}</div>
                <StarRating rating={c.rating} count={c.students} />
                <div style={{ display: "flex", gap: 14, marginTop: 10 }}>
                  <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, display: "flex", alignItems: "center", gap: 3 }}><Clock size={11} /> {c.duration}</span>
                  {c.accredited && <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.charcoal, display: "flex", alignItems: "center", gap: 3 }}><Award size={11} color={brand.amber} /> Accredited</span>}
                </div>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginTop: 14, paddingTop: 14, borderTop: `1px solid ${brand.borderGray}` }}>
                  <span style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 16, color: brand.charcoal }}>{c.price}</span>
                  <button onClick={(e2) => { e2.stopPropagation(); nav("/checkout"); }} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: "#fff", background: gradientFlow, border: "none", borderRadius: 8, padding: "8px 14px", cursor: "pointer" }}>Enroll</button>
                </div>
              </div>
            </div>
          ))}
        </div>
        {filtered.length === 0 && (
          <div style={{ textAlign: "center" as const, padding: "80px 0", color: brand.warmGray }}>
            <div style={{ fontSize: 48, marginBottom: 16 }}>🔍</div>
            <div style={{ fontFamily: "Playfair Display, serif", fontSize: 22, color: brand.charcoal, marginBottom: 8 }}>No courses found</div>
            <div style={{ fontFamily: "Inter", fontSize: 14 }}>Try adjusting your filters or search term.</div>
          </div>
        )}
      </div>
    </div>
  );
}
