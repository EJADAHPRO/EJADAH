import { useNavigate } from "react-router";
import { Play, Award, Clock, TrendingUp, BookOpen, Zap, CheckCircle, Star, Calendar, ArrowRight, Flame } from "lucide-react";
import { brand, gradientFlow, gradientGlow, GradientBadge, ProgressPath, StarRating } from "@/app/shared";

const stats = [
  { label: "Learning Hours", value: "142h", icon: <Clock size={20} />, color: brand.orange },
  { label: "Courses Enrolled", value: "8", icon: <BookOpen size={20} />, color: brand.amber },
  { label: "Certificates", value: "5", icon: <Award size={20} />, color: brand.gold },
  { label: "Study Streak", value: "12 days", icon: <Flame size={20} />, color: brand.red },
];

const courses = [
  { id: "1", title: "Comprehensive Endodontics: From Basic to Advanced", instructor: "Dr. Amira Soliman", specialty: "Endodontics", progress: 68, thumb: "https://images.unsplash.com/photo-1588776814546-daab30f310ce?w=200&q=80" },
  { id: "2", title: "Digital Smile Design Masterclass", instructor: "Dr. Karim Nasser", specialty: "Digital Dentistry", progress: 41, thumb: "https://images.unsplash.com/photo-1657470179447-0f5aa16daa91?w=200&q=80" },
  { id: "3", title: "Egyptian Licensing Exam Preparation", instructor: "Ejadah Exam Team", specialty: "Exam Prep", progress: 22, thumb: "https://images.unsplash.com/photo-1681939282781-341ac4f61996?w=200&q=80" },
];

const certs = [
  { title: "Endodontic Fundamentals", issuer: "Ejadah International Academy", date: "Jun 2025", accredited: true },
  { title: "Digital Dentistry Essentials", issuer: "Ejadah International Academy", date: "Apr 2025", accredited: false },
  { title: "Oral Surgery: Exodontia Module", issuer: "Ejadah International Academy", date: "Feb 2025", accredited: true },
];

const upcoming = [
  { title: "Orthodontic Finishing & Retention", date: "Today, 8:00 PM", type: "Live" },
  { title: "EDLE Mock Exam — Session 4", date: "Jun 24, 2:00 PM", type: "Exam" },
  { title: "Tutoring with Dr. Ibrahim", date: "Jun 25, 5:00 PM", type: "Tutoring" },
];

const badges = [
  { name: "First Course", icon: "🎓", earned: true },
  { name: "Clinical Explorer", icon: "🔬", earned: true },
  { name: "Exam Ready", icon: "📝", earned: true },
  { name: "7-Day Streak", icon: "🔥", earned: true },
  { name: "30-Day Streak", icon: "⚡", earned: false },
  { name: "Mastery Badge", icon: "🏆", earned: false },
];

export default function Dashboard() {
  const nav = useNavigate();

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Header */}
      <div style={{ background: brand.charcoal, padding: "40px 24px 32px" }}>
        <div style={{ maxWidth: 1280, margin: "0 auto", display: "flex", justifyContent: "space-between", alignItems: "center", flexWrap: "wrap", gap: 16 }}>
          <div>
            <div style={{ fontFamily: "Inter", fontSize: 14, color: "rgba(255,255,255,0.5)", marginBottom: 6 }}>Welcome back,</div>
            <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(24px,3vw,34px)", color: "#fff" }}>Dr. Yousef Al-Rashidi</h1>
            <div style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.5)", marginTop: 4 }}>General Dentist · Cairo, Egypt</div>
          </div>
          <div style={{ display: "flex", gap: 10 }}>
            <button onClick={() => nav("/exams")} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: "#fff", background: "rgba(255,255,255,0.08)", border: "1px solid rgba(255,255,255,0.15)", borderRadius: 10, padding: "10px 18px", cursor: "pointer" }}>
              Practice Exam
            </button>
            <button onClick={() => nav("/courses")} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "10px 18px", cursor: "pointer" }}>
              Browse Courses
            </button>
          </div>
        </div>
      </div>

      <div style={{ maxWidth: 1280, margin: "0 auto", padding: "32px 24px" }}>
        {/* Stats */}
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(180px, 1fr))", gap: 14, marginBottom: 32 }}>
          {stats.map((s) => (
            <div key={s.label} style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "20px 18px", display: "flex", gap: 14, alignItems: "center" }}>
              <div style={{ width: 44, height: 44, borderRadius: 12, background: `${s.color}14`, display: "flex", alignItems: "center", justifyContent: "center", color: s.color, flexShrink: 0 }}>{s.icon}</div>
              <div>
                <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.charcoal }}>{s.value}</div>
                <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>{s.label}</div>
              </div>
            </div>
          ))}
        </div>

        <div style={{ display: "flex", gap: 24, flexWrap: "wrap" }}>
          {/* Left column */}
          <div style={{ flex: "1 1 480px" }}>
            {/* Continue learning */}
            <div style={{ marginBottom: 28 }}>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 16 }}>
                <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal }}>Continue Learning</div>
                <button onClick={() => nav("/courses")} style={{ fontFamily: "Inter", fontSize: 13, color: brand.orange, background: "none", border: "none", cursor: "pointer" }}>View all →</button>
              </div>
              {courses.map((c) => (
                <div key={c.id} onClick={() => nav(`/courses/${c.id}/play`)} style={{ background: brand.white, borderRadius: 16, border: `1px solid ${brand.borderGray}`, padding: "16px", marginBottom: 12, display: "flex", gap: 14, alignItems: "center", cursor: "pointer", transition: "box-shadow 0.2s" }}
                  onMouseEnter={(e) => ((e.currentTarget as HTMLElement).style.boxShadow = "0 6px 20px rgba(27,27,27,0.08)")}
                  onMouseLeave={(e) => ((e.currentTarget as HTMLElement).style.boxShadow = "none")}
                >
                  <img src={c.thumb} alt={c.title} style={{ width: 56, height: 56, borderRadius: 10, objectFit: "cover", flexShrink: 0 }} />
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal, marginBottom: 2, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" as const }}>{c.title}</div>
                    <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginBottom: 8 }}>{c.instructor}</div>
                    <div style={{ display: "flex", gap: 8, alignItems: "center" }}>
                      <div style={{ flex: 1 }}><ProgressPath percent={c.progress} /></div>
                      <span style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 600, color: brand.orange, flexShrink: 0 }}>{c.progress}%</span>
                    </div>
                  </div>
                  <button onClick={(e) => { e.stopPropagation(); nav(`/courses/${c.id}/play`); }} style={{ background: brand.offWhite, border: `1px solid ${brand.borderGray}`, borderRadius: 8, width: 34, height: 34, display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer", flexShrink: 0 }}>
                    <Play size={14} fill={brand.orange} color={brand.orange} style={{ marginLeft: 2 }} />
                  </button>
                </div>
              ))}
            </div>

            {/* Exam performance */}
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px", marginBottom: 28 }}>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 18 }}>Exam Performance — EDLE</div>
              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12, marginBottom: 18 }}>
                {[["Questions Done", "324 / 14,200", brand.charcoal], ["Average Score", "78%", "#2D9B68"], ["Weakest Subject", "Pharmacology", brand.red], ["Strongest Subject", "Anatomy", brand.orange]].map(([l, v, c]) => (
                  <div key={l as string} style={{ background: brand.offWhite, borderRadius: 12, padding: "14px 16px" }}>
                    <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginBottom: 4 }}>{l as string}</div>
                    <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 16, color: c as string }}>{v as string}</div>
                  </div>
                ))}
              </div>
              <button onClick={() => nav("/exams")} style={{ width: "100%", fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "11px", cursor: "pointer" }}>
                Continue Exam Prep
              </button>
            </div>

            {/* Badges */}
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px" }}>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 16 }}>Your Badges</div>
              <div style={{ display: "flex", gap: 12, flexWrap: "wrap" }}>
                {badges.map((b) => (
                  <div key={b.name} style={{ textAlign: "center" as const, opacity: b.earned ? 1 : 0.35 }}>
                    <div style={{ width: 52, height: 52, borderRadius: 14, background: b.earned ? `linear-gradient(135deg, rgba(255,107,26,0.12), rgba(255,198,46,0.12))` : brand.paleGray, border: `1.5px solid ${b.earned ? brand.amber : brand.borderGray}`, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 22, marginBottom: 5 }}>{b.icon}</div>
                    <div style={{ fontFamily: "Inter", fontSize: 10, color: b.earned ? brand.charcoal : brand.warmGray, fontWeight: b.earned ? 600 : 400 }}>{b.name}</div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Right column */}
          <div style={{ flex: "0 1 300px" }}>
            {/* Upcoming */}
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "22px 20px", marginBottom: 20 }}>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal, marginBottom: 16 }}>Upcoming</div>
              {upcoming.map((u) => (
                <div key={u.title} style={{ display: "flex", gap: 12, alignItems: "flex-start", padding: "10px 0", borderBottom: `1px solid ${brand.borderGray}` }}>
                  <div style={{ width: 8, height: 8, borderRadius: "50%", background: u.type === "Live" ? brand.red : u.type === "Exam" ? brand.amber : brand.orange, marginTop: 5, flexShrink: 0 }} />
                  <div>
                    <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal }}>{u.title}</div>
                    <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginTop: 2 }}>{u.date}</div>
                  </div>
                </div>
              ))}
              <button onClick={() => nav("/live")} style={{ width: "100%", marginTop: 14, fontFamily: "Inter", fontWeight: 500, fontSize: 13, color: brand.orange, background: "rgba(255,107,26,0.07)", border: "none", borderRadius: 8, padding: "10px", cursor: "pointer" }}>
                View Full Calendar
              </button>
            </div>

            {/* Certificates */}
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "22px 20px", marginBottom: 20 }}>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal, marginBottom: 16 }}>My Certificates</div>
              {certs.map((c) => (
                <div key={c.title} style={{ background: brand.offWhite, borderRadius: 12, padding: "12px 14px", marginBottom: 10, border: `1px solid ${brand.borderGray}` }}>
                  <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
                    <div>
                      <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal }}>{c.title}</div>
                      <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginTop: 2 }}>{c.date}</div>
                    </div>
                    <Award size={16} color={c.accredited ? brand.amber : brand.borderGray} />
                  </div>
                </div>
              ))}
            </div>

            {/* Quick links */}
            <div style={{ background: brand.charcoal, borderRadius: 20, padding: "22px 20px" }}>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: "#fff", marginBottom: 16 }}>Explore More</div>
              {[["Dental AI", "/ai"], ["Community", "/community"], ["Career Abroad", "/career"], ["Live Academy", "/live"]].map(([label, path]) => (
                <button key={label as string} onClick={() => nav(path as string)} style={{ width: "100%", fontFamily: "Inter", fontWeight: 500, fontSize: 13, color: "rgba(255,255,255,0.7)", background: "rgba(255,255,255,0.05)", border: "none", borderRadius: 8, padding: "10px 14px", cursor: "pointer", textAlign: "left" as const, marginBottom: 8, display: "flex", justifyContent: "space-between", alignItems: "center", transition: "background 0.15s" }}
                  onMouseEnter={(e) => ((e.currentTarget as HTMLElement).style.background = "rgba(255,255,255,0.1)")}
                  onMouseLeave={(e) => ((e.currentTarget as HTMLElement).style.background = "rgba(255,255,255,0.05)")}
                >
                  {label as string} <ArrowRight size={13} />
                </button>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
