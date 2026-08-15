import { useState } from "react";
import { useNavigate } from "react-router";
import { DollarSign, Calendar, Clock, Star, Users, TrendingUp, ArrowRight, CheckCircle, X } from "lucide-react";
import { brand, gradientFlow } from "@/app/shared";

const upcoming = [
  { student: "Dr. Khaled Ahmed", subject: "EDLE Endodontics — Retreat.", date: "Today", time: "6:00 PM", duration: 60, price: 350, status: "confirmed" },
  { student: "Dr. Sara Mahmoud", subject: "ORE Endodontics Prep", date: "Tomorrow", time: "5:00 PM", duration: 30, price: 195, status: "confirmed" },
  { student: "Dr. Nour Hassan", subject: "Canal Negotiation Technique", date: "Jun 25", time: "7:00 PM", duration: 60, price: 350, status: "pending" },
];

const completed = [
  { student: "Dr. Tarek Fouad", subject: "Rotary Systems — Clinical Protocol", date: "Jun 20", duration: 60, price: 350, rating: 5, paid: true },
  { student: "Dr. Reem Saleh", subject: "EDLE Mock Questions Review", date: "Jun 18", duration: 30, price: 195, rating: 5, paid: true },
  { student: "Dr. Lina Samir", subject: "Access Cavity Preparation", date: "Jun 15", duration: 60, price: 350, rating: 4, paid: true },
  { student: "Dr. Omar Kamal", subject: "Obturation Techniques", date: "Jun 12", duration: 60, price: 350, rating: 5, paid: true },
];

const weeklyEarnings = [420, 350, 700, 195, 700, 350, 420];
const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
const maxEarning = Math.max(...weeklyEarnings);

export default function TutorEarnings() {
  const nav = useNavigate();
  const [availableDays, setAvailableDays] = useState(["Mon", "Wed", "Thu", "Fri", "Sat"]);

  const totalThisMonth = 8400;
  const pendingPayout = 3135;
  const totalSessions = completed.length + upcoming.filter((s) => s.status === "confirmed").length;

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Header */}
      <div style={{ background: brand.charcoal, padding: "40px 24px 32px" }}>
        <div style={{ maxWidth: 1200, margin: "0 auto", display: "flex", justifyContent: "space-between", alignItems: "center", flexWrap: "wrap", gap: 16 }}>
          <div>
            <div style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.5)", marginBottom: 4 }}>Tutor Earnings Dashboard</div>
            <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(22px,3vw,32px)", color: "#fff" }}>Dr. Amira Soliman</h1>
            <div style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.5)", marginTop: 4 }}>Endodontics · 4.9★ · 1,240 sessions</div>
          </div>
          <button style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "12px 22px", cursor: "pointer" }}>
            Request Withdrawal
          </button>
        </div>
      </div>

      <div style={{ maxWidth: 1200, margin: "0 auto", padding: "28px 24px" }}>
        {/* Stats */}
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(200px, 1fr))", gap: 14, marginBottom: 28 }}>
          {[
            { label: "Earnings This Month", value: `EGP ${totalThisMonth.toLocaleString()}`, sub: "June 2025", color: "#2D9B68", icon: <DollarSign size={20} /> },
            { label: "Pending Payout", value: `EGP ${pendingPayout.toLocaleString()}`, sub: "Processes Jun 30", color: brand.amber, icon: <Clock size={20} /> },
            { label: "Sessions This Month", value: "24", sub: "↑ 4 vs last month", color: brand.orange, icon: <Users size={20} /> },
            { label: "Average Rating", value: "4.9★", sub: "284 total reviews", color: brand.gold, icon: <Star size={20} /> },
          ].map((s) => (
            <div key={s.label} style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "20px" }}>
              <div style={{ width: 40, height: 40, borderRadius: 12, background: `${s.color}14`, display: "flex", alignItems: "center", justifyContent: "center", color: s.color, marginBottom: 12 }}>{s.icon}</div>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.charcoal }}>{s.value}</div>
              <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal, marginTop: 3 }}>{s.label}</div>
              <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginTop: 3 }}>{s.sub}</div>
            </div>
          ))}
        </div>

        <div style={{ display: "flex", gap: 24, flexWrap: "wrap" }}>
          <div style={{ flex: 1, minWidth: 300 }}>
            {/* Weekly bar chart */}
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px", marginBottom: 20 }}>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 18 }}>
                <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal }}>This Week's Earnings</div>
                <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: "#2D9B68" }}>EGP {weeklyEarnings.reduce((a, b) => a + b, 0).toLocaleString()}</div>
              </div>
              <div style={{ display: "flex", gap: 10, alignItems: "flex-end", height: 110 }}>
                {weeklyEarnings.map((val, i) => (
                  <div key={i} style={{ flex: 1, display: "flex", flexDirection: "column" as const, alignItems: "center", gap: 6 }}>
                    <div style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray }}>EGP {val}</div>
                    <div style={{ width: "100%", height: (val / maxEarning) * 80, background: i === 5 || i === 6 ? `${brand.amber}40` : gradientFlow, borderRadius: "4px 4px 0 0", opacity: val === 0 ? 0.2 : 1, minHeight: 4 }} />
                    <div style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray }}>{days[i]}</div>
                  </div>
                ))}
              </div>
            </div>

            {/* Upcoming sessions */}
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px", marginBottom: 20 }}>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal, marginBottom: 16 }}>Upcoming Sessions</div>
              {upcoming.map((s, i) => (
                <div key={i} style={{ background: s.status === "pending" ? `${brand.amber}06` : brand.offWhite, border: `1px solid ${s.status === "pending" ? brand.amber + "30" : brand.borderGray}`, borderRadius: 14, padding: "14px 16px", marginBottom: 10 }}>
                  <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
                    <div style={{ flex: 1 }}>
                      <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal }}>{s.student}</div>
                      <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, margin: "2px 0 6px" }}>{s.subject}</div>
                      <div style={{ display: "flex", gap: 12, flexWrap: "wrap" }}>
                        <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.amber }}>{s.date} · {s.time}</span>
                        <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{s.duration} min</span>
                        <span style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 700, color: s.status === "confirmed" ? "#2D9B68" : brand.amber }}>{s.status === "confirmed" ? "✓ Confirmed" : "⏳ Pending"}</span>
                      </div>
                    </div>
                    <div style={{ textAlign: "right" as const, flexShrink: 0, marginLeft: 12 }}>
                      <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 16, color: brand.charcoal }}>EGP {s.price}</div>
                      {s.status === "pending" && (
                        <div style={{ display: "flex", gap: 5, marginTop: 6 }}>
                          <button style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: "#fff", background: "#2D9B68", border: "none", borderRadius: 6, padding: "4px 8px", cursor: "pointer" }}>Accept</button>
                          <button style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: brand.red, background: "rgba(255,45,50,0.08)", border: "none", borderRadius: 6, padding: "4px 8px", cursor: "pointer" }}>Decline</button>
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              ))}
            </div>

            {/* Completed sessions */}
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px" }}>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal, marginBottom: 16 }}>Completed Sessions</div>
              {completed.map((s, i) => (
                <div key={i} style={{ display: "flex", gap: 14, alignItems: "center", padding: "11px 0", borderBottom: i < completed.length - 1 ? `1px solid ${brand.borderGray}` : "none" }}>
                  <CheckCircle size={16} color="#2D9B68" style={{ flexShrink: 0 }} />
                  <div style={{ flex: 1 }}>
                    <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal }}>{s.student}</div>
                    <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{s.subject} · {s.date} · {s.duration} min</div>
                  </div>
                  <div style={{ textAlign: "right" as const }}>
                    <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#2D9B68" }}>EGP {s.price}</div>
                    <div style={{ display: "flex", gap: 2 }}>{[1,2,3,4,5].map((i) => <Star key={i} size={10} fill={i<=s.rating?brand.amber:"none"} color={i<=s.rating?brand.amber:brand.borderGray} />)}</div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Sidebar */}
          <div style={{ width: 280, flexShrink: 0 }}>
            {/* Payout summary */}
            <div style={{ background: brand.charcoal, borderRadius: 20, padding: "22px", marginBottom: 16 }}>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", marginBottom: 6 }}>Pending Payout</div>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 30, color: brand.gold, marginBottom: 4 }}>EGP {pendingPayout.toLocaleString()}</div>
              <div style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.45)", marginBottom: 16 }}>Processes June 30, 2025</div>
              {[["Gross Earnings", "EGP 3,920"], ["Platform Fee (30%)", "- EGP 1,176"], ["Net Payout", "EGP 2,744"]].map(([l, v]) => (
                <div key={l} style={{ display: "flex", justifyContent: "space-between", padding: "6px 0", borderBottom: "1px solid rgba(255,255,255,0.06)" }}>
                  <span style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.5)" }}>{l}</span>
                  <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: l.includes("Net") ? brand.gold : l.includes("Fee") ? brand.red : "#fff" }}>{v}</span>
                </div>
              ))}
              <button style={{ width: "100%", marginTop: 16, fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "11px", cursor: "pointer" }}>Request Early Withdrawal</button>
            </div>

            {/* Availability */}
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "20px", marginBottom: 16 }}>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal, marginBottom: 12 }}>My Availability</div>
              <div style={{ display: "flex", gap: 6, flexWrap: "wrap" }}>
                {days.map((d) => {
                  const active = availableDays.includes(d);
                  return (
                    <button key={d} onClick={() => setAvailableDays((prev) => active ? prev.filter((x) => x !== d) : [...prev, d])} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: active ? "#fff" : brand.warmGray, background: active ? gradientFlow : brand.offWhite, border: `1.5px solid ${active ? "transparent" : brand.borderGray}`, borderRadius: 8, padding: "6px 10px", cursor: "pointer" }}>{d}</button>
                  );
                })}
              </div>
              <button style={{ width: "100%", marginTop: 14, fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.orange, background: "rgba(255,107,26,0.07)", border: "none", borderRadius: 8, padding: "9px", cursor: "pointer" }}>Save Availability</button>
            </div>

            {/* Cancellation stats */}
            <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "18px" }}>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal, marginBottom: 12 }}>Performance</div>
              {[["Completion Rate", "98%", "#2D9B68"], ["Cancellation Rate", "2%", "#2D9B68"], ["Response Time", "< 2 hours", "#2D9B68"], ["Repeat Students", "64%", brand.orange]].map(([l, v, c]) => (
                <div key={l as string} style={{ display: "flex", justifyContent: "space-between", padding: "8px 0", borderBottom: `1px solid ${brand.borderGray}` }}>
                  <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>{l as string}</span>
                  <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: c as string }}>{v as string}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
