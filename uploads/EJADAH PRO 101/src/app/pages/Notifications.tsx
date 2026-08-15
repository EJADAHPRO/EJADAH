import { useState } from "react";
import { useNavigate } from "react-router";
import { Bell, BookOpen, Radio, Award, MessageSquare, Star, Calendar, ChevronRight, CheckCheck } from "lucide-react";
import { brand, gradientFlow, GradientBadge } from "@/app/shared";

const notifications = [
  { id: "1", type: "live", icon: <Radio size={16} color={brand.red} />, title: "Live session starting in 30 minutes", body: "Orthodontic Finishing & Retention with Dr. Mona Khalil", time: "30 min ago", read: false, link: "/live", color: brand.red },
  { id: "2", type: "course", icon: <BookOpen size={16} color={brand.orange} />, title: "New lesson available", body: "Lesson 15: Calcified Canal Management — now live in Comprehensive Endodontics", time: "2h ago", read: false, link: "/courses/1", color: brand.orange },
  { id: "3", type: "cert", icon: <Award size={16} color={brand.amber} />, title: "Certificate issued", body: "Your certificate for Digital Smile Design Masterclass is ready to download", time: "Yesterday", read: false, link: "/certificates", color: brand.amber },
  { id: "4", type: "message", icon: <MessageSquare size={16} color="#496FA8" />, title: "New message from Dr. Amira Soliman", body: "Hi, I've uploaded the handout for tomorrow's session. Please review it beforehand.", time: "Yesterday", read: true, link: "/dashboard", color: "#496FA8" },
  { id: "5", type: "exam", icon: <Star size={16} color="#2D9B68" />, title: "Study streak — 12 days!", body: "You're on a 12-day learning streak. Keep it up to earn the 14-day badge.", time: "2 days ago", read: true, link: "/achievements", color: "#2D9B68" },
  { id: "6", type: "research", icon: <BookOpen size={16} color={brand.amber} />, title: "New research in Endodontics", body: "4 new papers added to your Research Hub this week, including a Cochrane review on NaOCl.", time: "3 days ago", read: true, link: "/research", color: brand.amber },
  { id: "7", type: "booking", icon: <Calendar size={16} color={brand.orange} />, title: "Tutoring session confirmed", body: "Dr. Amira Soliman confirmed your session for June 25 at 6:00 PM GMT+2", time: "3 days ago", read: true, link: "/tutoring/1", color: brand.orange },
  { id: "8", type: "exam", icon: <Star size={16} color={brand.red} />, title: "EDLE exam deadline reminder", body: "June registration closes in 5 days. You've completed 23% of your target question bank.", time: "4 days ago", read: true, link: "/exams/edle", color: brand.red },
];

const filters = ["All", "Unread", "Courses", "Live", "Exams", "Messages"];

export default function Notifications() {
  const nav = useNavigate();
  const [filter, setFilter] = useState("All");
  const [notifs, setNotifs] = useState(notifications);

  const unreadCount = notifs.filter((n) => !n.read).length;

  const filtered = notifs.filter((n) => {
    if (filter === "Unread") return !n.read;
    if (filter === "Courses") return n.type === "course";
    if (filter === "Live") return n.type === "live";
    if (filter === "Exams") return n.type === "exam";
    if (filter === "Messages") return n.type === "message";
    return true;
  });

  const markAllRead = () => setNotifs((prev) => prev.map((n) => ({ ...n, read: true })));
  const markRead = (id: string) => setNotifs((prev) => prev.map((n) => n.id === id ? { ...n, read: true } : n));

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Header */}
      <div style={{ background: brand.charcoal, padding: "40px 24px 32px" }}>
        <div style={{ maxWidth: 760, margin: "0 auto", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
          <div>
            <div style={{ display: "flex", gap: 10, alignItems: "center", marginBottom: 6 }}>
              <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 28, color: "#fff" }}>Notifications</h1>
              {unreadCount > 0 && <span style={{ background: brand.red, color: "#fff", fontFamily: "Inter", fontWeight: 700, fontSize: 12, borderRadius: 10, padding: "2px 9px" }}>{unreadCount}</span>}
            </div>
            <p style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.5)" }}>Stay up to date with your learning activity</p>
          </div>
          {unreadCount > 0 && <button onClick={markAllRead} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 13, color: "rgba(255,255,255,0.6)", background: "rgba(255,255,255,0.08)", border: "none", borderRadius: 8, padding: "8px 14px", cursor: "pointer", display: "flex", alignItems: "center", gap: 5 }}>
            <CheckCheck size={14} /> Mark all read
          </button>}
        </div>
      </div>

      <div style={{ maxWidth: 760, margin: "0 auto", padding: "24px 24px" }}>
        {/* Filters */}
        <div style={{ display: "flex", gap: 8, marginBottom: 24, flexWrap: "wrap" }}>
          {filters.map((f) => (
            <button key={f} onClick={() => setFilter(f)} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 12, color: filter === f ? "#fff" : brand.charcoal, background: filter === f ? gradientFlow : brand.white, border: `1.5px solid ${filter === f ? "transparent" : brand.borderGray}`, borderRadius: 20, padding: "5px 14px", cursor: "pointer", transition: "all 0.15s" }}>{f}</button>
          ))}
        </div>

        {/* Notification list */}
        <div style={{ display: "flex", flexDirection: "column" as const, gap: 10 }}>
          {filtered.map((n) => (
            <div key={n.id} onClick={() => { markRead(n.id); nav(n.link); }}
              style={{ background: n.read ? brand.white : `${n.color}06`, borderRadius: 16, border: `1px solid ${n.read ? brand.borderGray : n.color + "25"}`, padding: "16px 18px", cursor: "pointer", display: "flex", gap: 14, alignItems: "flex-start", transition: "transform 0.15s, box-shadow 0.15s" }}
              onMouseEnter={(e) => { (e.currentTarget as HTMLElement).style.transform = "translateX(4px)"; (e.currentTarget as HTMLElement).style.boxShadow = "0 4px 14px rgba(27,27,27,0.07)"; }}
              onMouseLeave={(e) => { (e.currentTarget as HTMLElement).style.transform = "none"; (e.currentTarget as HTMLElement).style.boxShadow = "none"; }}
            >
              <div style={{ width: 36, height: 36, borderRadius: 10, background: `${n.color}12`, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>{n.icon}</div>
              <div style={{ flex: 1 }}>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 3 }}>
                  <span style={{ fontFamily: "Inter", fontWeight: n.read ? 500 : 700, fontSize: 14, color: brand.charcoal }}>{n.title}</span>
                  <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, flexShrink: 0, marginLeft: 12 }}>{n.time}</span>
                </div>
                <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, lineHeight: 1.5 }}>{n.body}</div>
              </div>
              {!n.read && <div style={{ width: 8, height: 8, borderRadius: "50%", background: n.color, flexShrink: 0, marginTop: 6 }} />}
              <ChevronRight size={14} color={brand.borderGray} style={{ flexShrink: 0 }} />
            </div>
          ))}
          {filtered.length === 0 && (
            <div style={{ textAlign: "center" as const, padding: "60px 0" }}>
              <Bell size={40} color={brand.borderGray} style={{ marginBottom: 12 }} />
              <div style={{ fontFamily: "Playfair Display, serif", fontSize: 20, color: brand.charcoal, marginBottom: 6 }}>No notifications</div>
              <div style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray }}>You're all caught up!</div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
