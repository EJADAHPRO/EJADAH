import { useNavigate } from "react-router";
import { Users, Star, DollarSign, BookOpen, Video, TrendingUp, MessageSquare, Calendar, ArrowRight, CheckCircle, Clock } from "lucide-react";
import { brand, gradientFlow, GradientBadge } from "@/figma/app/shared";

const stats = [
  { label: "Total Students", value: "8,420", icon: <Users size={20} />, color: brand.orange, change: "+14% this month" },
  { label: "Active Courses", value: "6", icon: <BookOpen size={20} />, color: brand.amber, change: "2 in review" },
  { label: "Total Earnings", value: "EGP 142,800", icon: <DollarSign size={20} />, color: "#2D9B68", change: "+EGP 18,400 this month" },
  { label: "Average Rating", value: "4.87★", icon: <Star size={20} />, color: brand.gold, change: "Based on 2,840 reviews" },
];

const courses = [
  { id: "1", title: "Comprehensive Endodontics: From Basic to Advanced", students: 3420, rating: 4.8, revenue: "EGP 58,200", completion: 74, status: "Published" },
  { id: "2", title: "EDLE Endodontics Complete Revision", students: 2100, rating: 4.9, revenue: "EGP 31,500", completion: 68, status: "Published" },
  { id: "3", title: "Rotary Instrumentation Masterclass", students: 1840, rating: 4.7, revenue: "EGP 27,600", completion: 81, status: "Published" },
  { id: "4", title: "Retreatment: Advanced Techniques", students: 1060, rating: 4.9, revenue: "EGP 25,500", completion: 72, status: "Published" },
  { id: "5", title: "Regenerative Endodontics 2025", students: 0, rating: 0, revenue: "EGP 0", completion: 0, status: "In Review" },
];

const upcomingLive = [
  { title: "Live Q&A: Endodontic Emergencies", date: "Today, 8:00 PM", registered: 284 },
  { title: "Advanced Rotary Systems — Live Demo", date: "Jun 26, 7:00 PM", registered: 512 },
];

const recentReviews = [
  { student: "Dr. Khaled M.", rating: 5, text: "Best endodontics course I've taken. The CBCT case discussions are brilliant.", course: "Comprehensive Endodontics", time: "2h ago" },
  { student: "Dr. Sara A.", rating: 5, text: "Finally understand the decision-making behind retreatment. Thank you!", course: "Retreatment", time: "Yesterday" },
  { student: "Dr. Nour H.", rating: 4, text: "Excellent content. Would love more on calcified canals specifically.", course: "Rotary Instrumentation", time: "2 days ago" },
];

const monthlyData = [42, 58, 71, 65, 89, 102, 98];
const months = ["Dec", "Jan", "Feb", "Mar", "Apr", "May", "Jun"];
const maxVal = Math.max(...monthlyData);

export default function InstructorDashboard() {
  const nav = useNavigate();

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Header */}
      <div style={{ background: brand.charcoal, padding: "40px 24px 32px" }}>
        <div style={{ maxWidth: 1280, margin: "0 auto", display: "flex", justifyContent: "space-between", alignItems: "center", flexWrap: "wrap", gap: 16 }}>
          <div>
            <div style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.5)", marginBottom: 4 }}>Instructor Dashboard</div>
            <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(22px,3vw,32px)", color: "#fff" }}>Dr. Amira Soliman</h1>
            <div style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.5)", marginTop: 4 }}>Endodontist · Verified Instructor</div>
          </div>
          <div style={{ display: "flex", gap: 10 }}>
            <button style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 13, color: "rgba(255,255,255,0.7)", background: "rgba(255,255,255,0.08)", border: "1px solid rgba(255,255,255,0.12)", borderRadius: 10, padding: "10px 16px", cursor: "pointer" }}>
              <MessageSquare size={14} style={{ marginRight: 6, verticalAlign: "middle" }} />Messages
            </button>
            <button onClick={() => nav("/courses/1")} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "10px 18px", cursor: "pointer" }}>
              + New Course
            </button>
          </div>
        </div>
      </div>

      <div style={{ maxWidth: 1280, margin: "0 auto", padding: "28px 24px" }}>
        {/* Stats */}
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(220px, 1fr))", gap: 14, marginBottom: 28 }}>
          {stats.map((s) => (
            <div key={s.label} style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "20px 20px" }}>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 10 }}>
                <div style={{ width: 42, height: 42, borderRadius: 12, background: `${s.color}14`, display: "flex", alignItems: "center", justifyContent: "center", color: s.color }}>{s.icon}</div>
              </div>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 24, color: brand.charcoal }}>{s.value}</div>
              <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal, marginTop: 3 }}>{s.label}</div>
              <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginTop: 4 }}>{s.change}</div>
            </div>
          ))}
        </div>

        <div style={{ display: "flex", gap: 24, flexWrap: "wrap" }}>
          <div style={{ flex: 1, minWidth: 300 }}>
            {/* Revenue chart */}
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px", marginBottom: 20 }}>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 20 }}>
                <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal }}>Monthly Enrollments</div>
                <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>Last 7 months</div>
              </div>
              <div style={{ display: "flex", gap: 8, alignItems: "flex-end", height: 120 }}>
                {monthlyData.map((val, i) => (
                  <div key={i} style={{ flex: 1, display: "flex", flexDirection: "column" as const, alignItems: "center", gap: 6 }}>
                    <div style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray }}>{val}</div>
                    <div style={{ width: "100%", height: (val / maxVal) * 90, background: i === monthlyData.length - 1 ? gradientFlow : `${brand.orange}40`, borderRadius: "4px 4px 0 0", minHeight: 8 }} />
                    <div style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray }}>{months[i]}</div>
                  </div>
                ))}
              </div>
            </div>

            {/* Courses table */}
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px", marginBottom: 20 }}>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 18 }}>
                <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal }}>My Courses</div>
                <button style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 12, color: brand.orange, background: "none", border: "none", cursor: "pointer" }}>Manage All</button>
              </div>
              {courses.map((c, i) => (
                <div key={c.id} style={{ display: "flex", gap: 14, alignItems: "center", padding: "12px 0", borderBottom: i < courses.length - 1 ? `1px solid ${brand.borderGray}` : "none" }}>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" as const }}>{c.title}</div>
                    <div style={{ display: "flex", gap: 12, marginTop: 4 }}>
                      <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{c.students.toLocaleString()} students</span>
                      {c.rating > 0 && <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.amber }}>★ {c.rating}</span>}
                      <span style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 700, color: c.status === "Published" ? "#2D9B68" : brand.amber }}>{c.status}</span>
                    </div>
                  </div>
                  <div style={{ textAlign: "right" as const, flexShrink: 0 }}>
                    <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal }}>{c.revenue}</div>
                    {c.completion > 0 && <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{c.completion}% avg. completion</div>}
                  </div>
                </div>
              ))}
            </div>

            {/* Recent reviews */}
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px" }}>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal, marginBottom: 16 }}>Recent Reviews</div>
              {recentReviews.map((r, i) => (
                <div key={i} style={{ padding: "12px 0", borderBottom: i < recentReviews.length - 1 ? `1px solid ${brand.borderGray}` : "none" }}>
                  <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 4 }}>
                    <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal }}>{r.student}</span>
                    <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{r.time}</span>
                  </div>
                  <div style={{ display: "flex", gap: 2, marginBottom: 4 }}>{[1,2,3,4,5].map((i) => <Star key={i} size={11} fill={i<=r.rating?brand.amber:"none"} color={i<=r.rating?brand.amber:brand.borderGray} />)}</div>
                  <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, lineHeight: 1.55 }}>{r.text}</div>
                  <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.orange, marginTop: 4 }}>{r.course}</div>
                </div>
              ))}
            </div>
          </div>

          {/* Sidebar */}
          <div style={{ width: 290, flexShrink: 0 }}>
            {/* Upcoming live */}
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "20px", marginBottom: 16 }}>
              <div style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 14 }}>
                <Video size={15} color={brand.red} />
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal }}>Upcoming Live Sessions</div>
              </div>
              {upcomingLive.map((s) => (
                <div key={s.title} style={{ background: brand.offWhite, borderRadius: 12, padding: "12px 14px", marginBottom: 10 }}>
                  <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal, marginBottom: 3 }}>{s.title}</div>
                  <div style={{ display: "flex", justifyContent: "space-between" }}>
                    <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.amber }}>{s.date}</span>
                    <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{s.registered} registered</span>
                  </div>
                </div>
              ))}
              <button style={{ width: "100%", marginTop: 6, fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: "#fff", background: brand.red, border: "none", borderRadius: 10, padding: "10px", cursor: "pointer" }}>Schedule Live Session</button>
            </div>

            {/* Payout */}
            <div style={{ background: brand.charcoal, borderRadius: 20, padding: "20px", marginBottom: 16 }}>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", marginBottom: 4 }}>Next Payout</div>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 28, color: brand.gold, marginBottom: 4 }}>EGP 18,400</div>
              <div style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.5)", marginBottom: 14 }}>Processing June 30, 2025</div>
              <div style={{ display: "flex", flexDirection: "column" as const, gap: 8 }}>
                {[["Course Sales", "EGP 15,200"], ["Live Sessions", "EGP 2,400"], ["Platform Fee (30%)", "- EGP 5,280"]].map(([l, v]) => (
                  <div key={l} style={{ display: "flex", justifyContent: "space-between", fontFamily: "Inter", fontSize: 12 }}>
                    <span style={{ color: "rgba(255,255,255,0.5)" }}>{l}</span>
                    <span style={{ color: l.includes("Fee") ? brand.red : "#fff", fontWeight: 600 }}>{v}</span>
                  </div>
                ))}
              </div>
            </div>

            {/* Quick links */}
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "18px" }}>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal, marginBottom: 12 }}>Quick Links</div>
              {[["My Courses", "/courses"], ["Community", "/community"], ["Tutoring Dashboard", "/tutoring"], ["Analytics", "/exams/analytics"]].map(([l, p]) => (
                <button key={l as string} onClick={() => nav(p as string)} style={{ width: "100%", display: "flex", justifyContent: "space-between", alignItems: "center", fontFamily: "Inter", fontSize: 13, color: brand.charcoal, background: brand.offWhite, border: "none", borderRadius: 8, padding: "9px 12px", cursor: "pointer", marginBottom: 6, textAlign: "left" as const }}>
                  {l as string} <ArrowRight size={12} color={brand.orange} />
                </button>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
