import { useNavigate } from "react-router";
import { Users, BookOpen, DollarSign, TrendingUp, Award, MessageSquare, Bell, Settings, Shield, BarChart2, ArrowRight, AlertTriangle, CheckCircle, Clock, CreditCard, UserCheck, FileText, Zap } from "lucide-react";
import { brand, gradientFlow } from "@/figma/app/shared";

const NAV_ITEMS = [
  { label: "Overview",  icon: <BarChart2 size={15} />, path: "/admin",           active: true },
  { label: "Users",     icon: <Users size={15} />,     path: "/admin/users",     badge: null },
  { label: "Content",   icon: <BookOpen size={15} />,  path: "/admin/content",   badge: "2" },
  { label: "Analytics", icon: <BarChart2 size={15} />, path: "/admin/analytics", badge: null },
  { label: "Billing",   icon: <DollarSign size={15} />,path: "/admin/billing",   badge: null },
];

const KPI = [
  { label: "Total Users",          value: "41,284", change: "+1,240 this month", trend: "up",   color: brand.orange,  icon: <Users size={18} />,      path: "/admin/users" },
  { label: "Monthly Revenue",      value: "EGP 2.4M",change: "+18% vs last month",trend:"up",   color: "#2D9B68",     icon: <DollarSign size={18} />,  path: "/admin/billing" },
  { label: "Active Subscriptions", value: "9,820",  change: "+312 this month",  trend: "up",   color: "#496FA8",     icon: <CreditCard size={18} />,  path: "/admin/billing" },
  { label: "Published Content",    value: "156",    change: "2 pending review",  trend: "warn", color: brand.amber,   icon: <BookOpen size={18} />,    path: "/admin/content" },
  { label: "Churn Rate",           value: "4.2%",   change: "-0.6% vs last month",trend:"up",   color: "#2D9B68",     icon: <TrendingUp size={18} />,  path: "/admin/analytics" },
  { label: "Instructors",          value: "212",    change: "4 pending approval", trend: "warn", color: "#8B5CF6",    icon: <Award size={18} />,       path: "/admin/users" },
];

const RECENT_ACTIVITY = [
  { type: "New User",        desc: "Dr. Ahmed Mostafa registered",                    time: "2 min ago",  color: brand.orange,  icon: <Users size={12} /> },
  { type: "Content Pending", desc: "Orthodontic Wire Bending Masterclass — review needed", time: "14 min ago", color: brand.amber,   icon: <Clock size={12} /> },
  { type: "Payment Failed",  desc: "Subscription renewal failed — Dr. Sara Youssef",  time: "31 min ago", color: "#FF2D32",     icon: <AlertTriangle size={12} /> },
  { type: "Published",       desc: "Advanced Endodontic Techniques by Dr. Laila Shawki",time: "1h ago",  color: "#2D9B68",     icon: <CheckCircle size={12} /> },
  { type: "New Instructor",  desc: "Dr. Mohamed Fathi application submitted",          time: "2h ago",     color: "#8B5CF6",     icon: <UserCheck size={12} /> },
  { type: "Refund Request",  desc: "Order #4821 — EGP 499 requested by user",          time: "3h ago",     color: "#FF2D32",     icon: <CreditCard size={12} /> },
  { type: "Support Ticket",  desc: "Certificate not delivered — Ticket #8291",         time: "4h ago",     color: brand.warmGray,icon: <FileText size={12} /> },
];

const PENDING_ITEMS = [
  { label: "Content pending review", count: 2, color: brand.amber,  path: "/admin/content",  cta: "Review" },
  { label: "Instructor applications", count: 4, color: "#8B5CF6",  path: "/admin/users",    cta: "Review" },
  { label: "Failed payments",         count: 3, color: "#FF2D32",  path: "/admin/billing",  cta: "Fix" },
  { label: "Open support tickets",    count: 7, color: "#496FA8",  path: "/admin/users",    cta: "View" },
];

const TOP_CONTENT = [
  { title: "Advanced Endodontic Techniques", dept: "Endodontics",                    enrolled: 3840, revenue: "EGP 184K" },
  { title: "Endodontics Study Companion",    dept: "Endodontics",                    enrolled: 1240, revenue: "EGP 619K" },
  { title: "Implant Foundations",            dept: "Implant Dentistry",              enrolled: 2100, revenue: "EGP 126K" },
  { title: "EDLE Practice Bank",             dept: "Exams",                          enrolled: 6200, revenue: "—" },
  { title: "Periodontology Companion",       dept: "Periodontology & Oral Medicine", enrolled: 980,  revenue: "EGP 489K" },
];

const monthlyRevenue = [1200, 1380, 1520, 1700, 1480, 1850, 1960, 2100, 2200, 2100, 2400, 2700];
const monthlyUsers   = [1800, 2100, 2500, 2900, 2400, 3100, 3500, 3800, 3200, 3200, 3800, 4240];
const monthLabels    = ["Aug","Sep","Oct","Nov","Dec","Jan","Feb","Mar","Apr","May","Jun","Jul"];
const maxRev = Math.max(...monthlyRevenue);
const maxUsr = Math.max(...monthlyUsers);

export default function AdminDashboard() {
  const nav = useNavigate();

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh", display: "flex" }}>

      {/* Sidebar */}
      <div style={{ width: 210, background: brand.charcoal, flexDirection: "column", flexShrink: 0, padding: "24px 0", display: "flex" }}>
        <div style={{ padding: "0 20px 20px", borderBottom: "1px solid rgba(255,255,255,0.06)" }}>
          <div style={{ fontFamily: "Inter", fontWeight: 800, fontSize: 13, color: "#fff", letterSpacing: "0.06em" }}>EJADAH ADMIN</div>
          <div style={{ fontFamily: "Inter", fontSize: 11, color: "rgba(255,255,255,0.35)", marginTop: 2 }}>Control Panel</div>
        </div>
        <div style={{ flex: 1, padding: "14px 10px" }}>
          {NAV_ITEMS.map((item) => (
            <button key={item.label} onClick={() => nav(item.path)}
              style={{ width: "100%", display: "flex", gap: 10, alignItems: "center", padding: "10px 12px", borderRadius: 10, cursor: "pointer", marginBottom: 3, background: item.active ? "rgba(255,255,255,0.1)" : "transparent", border: "none", color: item.active ? "#fff" : "rgba(255,255,255,0.5)", fontFamily: "Inter", fontSize: 13, fontWeight: item.active ? 700 : 400, transition: "background 0.15s" }}
              onMouseEnter={(e) => { if (!item.active) (e.currentTarget as HTMLElement).style.background = "rgba(255,255,255,0.06)"; }}
              onMouseLeave={(e) => { if (!item.active) (e.currentTarget as HTMLElement).style.background = "transparent"; }}>
              {item.icon}
              <span style={{ flex: 1, textAlign: "left" as const }}>{item.label}</span>
              {item.badge && (
                <span style={{ background: brand.amber, color: "#fff", borderRadius: 10, fontFamily: "Inter", fontWeight: 800, fontSize: 10, padding: "1px 6px" }}>{item.badge}</span>
              )}
            </button>
          ))}

          <div style={{ borderTop: "1px solid rgba(255,255,255,0.06)", marginTop: 12, paddingTop: 12 }}>
            {[
              { label: "Notifications", icon: <Bell size={14} />, path: "/notifications", badge: "14" },
              { label: "Settings",      icon: <Settings size={14} />, path: "/" },
              { label: "Back to Site",  icon: <ArrowRight size={14} />, path: "/" },
            ].map((item) => (
              <button key={item.label} onClick={() => nav(item.path)}
                style={{ width: "100%", display: "flex", gap: 10, alignItems: "center", padding: "9px 12px", borderRadius: 10, cursor: "pointer", marginBottom: 2, background: "transparent", border: "none", color: "rgba(255,255,255,0.4)", fontFamily: "Inter", fontSize: 12, transition: "background 0.15s" }}
                onMouseEnter={(e) => (e.currentTarget as HTMLElement).style.background = "rgba(255,255,255,0.06)"}
                onMouseLeave={(e) => (e.currentTarget as HTMLElement).style.background = "transparent"}>
                {item.icon}
                <span style={{ flex: 1, textAlign: "left" as const }}>{item.label}</span>
                {"badge" in item && item.badge && (
                  <span style={{ background: "#FF2D32", color: "#fff", borderRadius: 10, fontFamily: "Inter", fontWeight: 800, fontSize: 10, padding: "1px 6px" }}>{item.badge}</span>
                )}
              </button>
            ))}
          </div>
        </div>

        <div style={{ padding: "14px 20px", borderTop: "1px solid rgba(255,255,255,0.06)" }}>
          <div style={{ display: "flex", gap: 8, alignItems: "center" }}>
            <div style={{ width: 32, height: 32, borderRadius: "50%", background: gradientFlow, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
              <Shield size={14} color="#fff" />
            </div>
            <div>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: "#fff" }}>Super Admin</div>
              <div style={{ fontFamily: "Inter", fontSize: 10, color: "rgba(255,255,255,0.35)" }}>admin@ejadah.com</div>
            </div>
          </div>
        </div>
      </div>

      {/* Main */}
      <div style={{ flex: 1, overflow: "auto" }}>

        {/* Topbar */}
        <div style={{ background: brand.white, borderBottom: `1px solid ${brand.borderGray}`, padding: "0 28px", height: 56, display: "flex", alignItems: "center", justifyContent: "space-between", position: "sticky", top: 0, zIndex: 10 }}>
          <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal }}>Overview Dashboard</div>
          <div style={{ display: "flex", gap: 10, alignItems: "center" }}>
            <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray }}>July 23, 2026</div>
            <button onClick={() => nav("/admin/analytics")} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: "#fff", background: gradientFlow, border: "none", borderRadius: 9, padding: "7px 14px", cursor: "pointer", display: "flex", alignItems: "center", gap: 5 }}>
              <BarChart2 size={12} /> Full Analytics
            </button>
          </div>
        </div>

        <div style={{ padding: "24px 28px 60px" }}>

          {/* Attention banner */}
          {PENDING_ITEMS.filter(p => p.count > 0).length > 0 && (
            <div style={{ display: "flex", gap: 10, flexWrap: "wrap", marginBottom: 22 }}>
              {PENDING_ITEMS.map((p) => (
                <div key={p.label} style={{ display: "flex", gap: 10, alignItems: "center", background: brand.white, border: `1px solid ${p.color}30`, borderLeft: `4px solid ${p.color}`, borderRadius: 12, padding: "10px 16px", flex: "1 1 200px" }}>
                  <div>
                    <div style={{ fontFamily: "Inter", fontWeight: 800, fontSize: 18, color: p.color }}>{p.count}</div>
                    <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{p.label}</div>
                  </div>
                  <button onClick={() => nav(p.path)}
                    style={{ marginLeft: "auto", fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: p.color, background: `${p.color}10`, border: "none", borderRadius: 8, padding: "6px 12px", cursor: "pointer" }}>
                    {p.cta} →
                  </button>
                </div>
              ))}
            </div>
          )}

          {/* KPI grid */}
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(210px, 1fr))", gap: 14, marginBottom: 24 }}>
            {KPI.map((k) => (
              <button key={k.label} onClick={() => nav(k.path)}
                style={{ background: brand.white, borderRadius: 16, border: `1px solid ${brand.borderGray}`, padding: "18px 20px", cursor: "pointer", textAlign: "left" as const, transition: "box-shadow 0.15s, transform 0.15s" }}
                onMouseEnter={(e) => { (e.currentTarget as HTMLElement).style.boxShadow = `0 6px 20px ${k.color}18`; (e.currentTarget as HTMLElement).style.transform = "translateY(-2px)"; }}
                onMouseLeave={(e) => { (e.currentTarget as HTMLElement).style.boxShadow = "none"; (e.currentTarget as HTMLElement).style.transform = "none"; }}>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 12 }}>
                  <div style={{ width: 38, height: 38, borderRadius: 11, background: `${k.color}14`, display: "flex", alignItems: "center", justifyContent: "center", color: k.color }}>{k.icon}</div>
                  <ArrowRight size={13} color={brand.borderGray} />
                </div>
                <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 800, fontSize: 22, color: brand.charcoal }}>{k.value}</div>
                <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal, marginTop: 2 }}>{k.label}</div>
                <div style={{ fontFamily: "Inter", fontSize: 11, color: k.trend === "warn" ? brand.amber : "#2D9B68", marginTop: 4 }}>
                  {k.trend === "warn" ? "⚠ " : "↑ "}{k.change}
                </div>
              </button>
            ))}
          </div>

          {/* Charts row */}
          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 18, marginBottom: 22 }}>

            {/* Revenue chart */}
            <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "22px" }}>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 18 }}>
                <div>
                  <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em", marginBottom: 4 }}>Revenue (12 months)</div>
                  <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 800, fontSize: 22, color: brand.charcoal }}>EGP 26.6M</div>
                </div>
                <button onClick={() => nav("/admin/analytics")} style={{ fontFamily: "Inter", fontSize: 12, color: brand.orange, background: "none", border: "none", cursor: "pointer" }}>View all →</button>
              </div>
              <div style={{ display: "flex", gap: 4, alignItems: "flex-end", height: 100 }}>
                {monthlyRevenue.map((val, i) => (
                  <div key={i} style={{ flex: 1, display: "flex", flexDirection: "column" as const, alignItems: "center", gap: 3 }}>
                    <div style={{ width: "100%", height: (val / maxRev) * 80, background: i === monthlyRevenue.length - 1 ? brand.orange : `${brand.orange}40`, borderRadius: "3px 3px 0 0", minHeight: 3 }} />
                    <div style={{ fontFamily: "Inter", fontSize: 8, color: brand.warmGray }}>{monthLabels[i]}</div>
                  </div>
                ))}
              </div>
            </div>

            {/* New users chart */}
            <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "22px" }}>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 18 }}>
                <div>
                  <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em", marginBottom: 4 }}>New Users (12 months)</div>
                  <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 800, fontSize: 22, color: brand.charcoal }}>38,500</div>
                </div>
                <button onClick={() => nav("/admin/users")} style={{ fontFamily: "Inter", fontSize: 12, color: "#496FA8", background: "none", border: "none", cursor: "pointer" }}>View all →</button>
              </div>
              <div style={{ display: "flex", gap: 4, alignItems: "flex-end", height: 100 }}>
                {monthlyUsers.map((val, i) => (
                  <div key={i} style={{ flex: 1, display: "flex", flexDirection: "column" as const, alignItems: "center", gap: 3 }}>
                    <div style={{ width: "100%", height: (val / maxUsr) * 80, background: i === monthlyUsers.length - 1 ? "#496FA8" : "#496FA840", borderRadius: "3px 3px 0 0", minHeight: 3 }} />
                    <div style={{ fontFamily: "Inter", fontSize: 8, color: brand.warmGray }}>{monthLabels[i]}</div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Bottom row */}
          <div style={{ display: "grid", gridTemplateColumns: "1.2fr 0.8fr", gap: 18 }}>

            {/* Recent activity */}
            <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "22px" }}>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 16 }}>
                <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal }}>Recent Activity</div>
                <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>Live</span>
              </div>
              {RECENT_ACTIVITY.map((a, i) => (
                <div key={i} style={{ display: "flex", gap: 12, alignItems: "flex-start", padding: "10px 0", borderBottom: i < RECENT_ACTIVITY.length - 1 ? `1px solid ${brand.borderGray}` : "none" }}>
                  <div style={{ width: 28, height: 28, borderRadius: 8, background: `${a.color}14`, display: "flex", alignItems: "center", justifyContent: "center", color: a.color, flexShrink: 0 }}>{a.icon}</div>
                  <div style={{ flex: 1 }}>
                    <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: a.color }}>{a.type}</div>
                    <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.charcoal, lineHeight: 1.4 }}>{a.desc}</div>
                  </div>
                  <div style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray, flexShrink: 0, marginTop: 2 }}>{a.time}</div>
                </div>
              ))}
            </div>

            {/* Right column */}
            <div style={{ display: "flex", flexDirection: "column" as const, gap: 18 }}>

              {/* Top content */}
              <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "20px" }}>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 14 }}>
                  <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 16, color: brand.charcoal }}>Top Content</div>
                  <button onClick={() => nav("/admin/content")} style={{ fontFamily: "Inter", fontSize: 12, color: brand.orange, background: "none", border: "none", cursor: "pointer" }}>All →</button>
                </div>
                {TOP_CONTENT.map((c, i) => (
                  <div key={i} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "8px 0", borderBottom: i < TOP_CONTENT.length - 1 ? `1px solid ${brand.borderGray}` : "none" }}>
                    <div style={{ flex: 1, minWidth: 0 }}>
                      <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{c.title}</div>
                      <div style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray }}>{c.dept}</div>
                    </div>
                    <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: brand.orange, flexShrink: 0, marginLeft: 10 }}>{c.revenue}</div>
                  </div>
                ))}
              </div>

              {/* Quick actions */}
              <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "20px" }}>
                <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 16, color: brand.charcoal, marginBottom: 12 }}>Quick Actions</div>
                <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 8 }}>
                  {[
                    { label: "Add User",      icon: <Users size={13} />,     color: brand.orange, path: "/admin/users" },
                    { label: "Review Content",icon: <BookOpen size={13} />,   color: brand.amber,  path: "/admin/content" },
                    { label: "View Billing",  icon: <DollarSign size={13} />, color: "#2D9B68",    path: "/admin/billing" },
                    { label: "Analytics",     icon: <BarChart2 size={13} />,  color: "#496FA8",    path: "/admin/analytics" },
                    { label: "Community",     icon: <MessageSquare size={13} />, color: "#8B5CF6", path: "/community" },
                    { label: "Certificates",  icon: <Award size={13} />,      color: brand.gold,   path: "/certificates" },
                  ].map((a) => (
                    <button key={a.label} onClick={() => nav(a.path)}
                      style={{ display: "flex", gap: 7, alignItems: "center", fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: a.color, background: `${a.color}0d`, border: `1px solid ${a.color}20`, borderRadius: 10, padding: "9px 10px", cursor: "pointer", transition: "background 0.15s" }}
                      onMouseEnter={(e) => (e.currentTarget as HTMLElement).style.background = `${a.color}1a`}
                      onMouseLeave={(e) => (e.currentTarget as HTMLElement).style.background = `${a.color}0d`}>
                      {a.icon} {a.label}
                    </button>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
