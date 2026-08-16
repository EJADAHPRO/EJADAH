import { useState } from "react";
import { useNavigate } from "react-router";
import { Users, BookOpen, DollarSign, BarChart2, ArrowUpRight, ArrowDownRight } from "lucide-react";
import { brand, gradientFlow } from "@/figma/app/shared";

const NAV_ITEMS = [
  { label: "Overview", icon: <BarChart2 size={15} />, path: "/admin" },
  { label: "Users", icon: <Users size={15} />, path: "/admin/users" },
  { label: "Content", icon: <BookOpen size={15} />, path: "/admin/content" },
  { label: "Analytics", icon: <BarChart2 size={15} />, path: "/admin/analytics" },
  { label: "Billing", icon: <DollarSign size={15} />, path: "/admin/billing" },
];

type Period = "7d" | "30d" | "90d" | "1y";

// Revenue series — 30d sums to ~2.4M (matches AdminDashboard headline)
const REVENUE_SERIES: Record<Period, { label: string; value: number }[]> = {
  "7d": [
    { label: "Mon", value: 72000 }, { label: "Tue", value: 94000 }, { label: "Wed", value: 88000 },
    { label: "Thu", value: 103000 }, { label: "Fri", value: 118000 }, { label: "Sat", value: 61000 }, { label: "Sun", value: 44000 },
  ],
  "30d": [
    { label: "W1", value: 520000 }, { label: "W2", value: 615000 }, { label: "W3", value: 680000 }, { label: "W4", value: 585000 },
  ],
  "90d": [
    { label: "May", value: 2100000 }, { label: "Jun", value: 2400000 }, { label: "Jul", value: 2700000 },
  ],
  "1y": [
    { label: "Aug", value: 1200000 }, { label: "Sep", value: 1380000 }, { label: "Oct", value: 1520000 },
    { label: "Nov", value: 1700000 }, { label: "Dec", value: 1480000 }, { label: "Jan", value: 1850000 },
    { label: "Feb", value: 1960000 }, { label: "Mar", value: 2100000 }, { label: "Apr", value: 2200000 },
    { label: "May", value: 2100000 }, { label: "Jun", value: 2400000 }, { label: "Jul", value: 2700000 },
  ],
};

const USER_SERIES: Record<Period, { label: string; value: number }[]> = {
  "7d": [
    { label: "Mon", value: 148 }, { label: "Tue", value: 204 }, { label: "Wed", value: 177 },
    { label: "Thu", value: 231 }, { label: "Fri", value: 268 }, { label: "Sat", value: 98 }, { label: "Sun", value: 74 },
  ],
  "30d": [
    { label: "W1", value: 890 }, { label: "W2", value: 1020 }, { label: "W3", value: 1180 }, { label: "W4", value: 1150 },
  ],
  "90d": [
    { label: "May", value: 3200 }, { label: "Jun", value: 3800 }, { label: "Jul", value: 4240 },
  ],
  "1y": [
    { label: "Aug", value: 1800 }, { label: "Sep", value: 2100 }, { label: "Oct", value: 2500 },
    { label: "Nov", value: 2900 }, { label: "Dec", value: 2400 }, { label: "Jan", value: 3100 },
    { label: "Feb", value: 3500 }, { label: "Mar", value: 3800 }, { label: "Apr", value: 3200 },
    { label: "May", value: 3200 }, { label: "Jun", value: 3800 }, { label: "Jul", value: 4240 },
  ],
};

// KPI context per period — churn, ARPU, completion don't change by day so we show period-relevant snapshots
const KPI_CONTEXT: Record<Period, { activeSubs: string; churn: string; arpu: string; completion: string; subTrend: string; churnTrend: string }> = {
  "7d":  { activeSubs: "9,820", churn: "4.2%", arpu: "EGP 244", completion: "74%", subTrend: "+38 this week", churnTrend: "-0.1% vs last week" },
  "30d": { activeSubs: "9,820", churn: "4.2%", arpu: "EGP 244", completion: "74%", subTrend: "+312 this month", churnTrend: "-0.6% vs last month" },
  "90d": { activeSubs: "9,820", churn: "4.2%", arpu: "EGP 244", completion: "74%", subTrend: "+890 this quarter", churnTrend: "-1.1% vs last quarter" },
  "1y":  { activeSubs: "9,820", churn: "4.2%", arpu: "EGP 244", completion: "74%", subTrend: "+3,480 this year", churnTrend: "-1.8% vs last year" },
};

const DEPT_BREAKDOWN = [
  { dept: "Endodontics",                    users: 8420, revenue: "EGP 619K", color: brand.orange,    pct: 88 },
  { dept: "Periodontology & Oral Medicine", users: 6180, revenue: "EGP 489K", color: "#2D9B68",       pct: 72 },
  { dept: "Orthodontics",                   users: 5340, revenue: "EGP 398K", color: "#496FA8",       pct: 63 },
  { dept: "Oral Pathology",                 users: 4620, revenue: "EGP 364K", color: "#8B5CF6",       pct: 55 },
  { dept: "Operative Dentistry",            users: 3900, revenue: "EGP 299K", color: "#2D9B68",       pct: 46 },
  { dept: "Oral & Maxillofacial Surgery",   users: 3200, revenue: "EGP 241K", color: brand.amber,     pct: 38 },
  { dept: "Pharmacology",                   users: 2800, revenue: "EGP 210K", color: "#FF2D32",       pct: 33 },
  { dept: "Implant Dentistry",              users: 2200, revenue: "EGP 168K", color: "#496FA8",       pct: 26 },
];

const TOP_CONTENT = [
  { title: "Advanced Endodontic Techniques", type: "Course",    enrolled: 3840, revenue: "EGP 184K", rating: 4.9 },
  { title: "Endodontics Study Companion",    type: "Companion", enrolled: 1240, revenue: "EGP 619K", rating: 4.9 },
  { title: "Implant Foundations",            type: "Course",    enrolled: 2100, revenue: "EGP 126K", rating: 4.7 },
  { title: "EDLE Practice Bank — Endo Set 3",type: "Quiz",      enrolled: 6200, revenue: "—",        rating: 4.8 },
  { title: "Periodontics Study Companion",   type: "Companion", enrolled: 980,  revenue: "EGP 489K", rating: 4.7 },
];

const FUNNEL = [
  { label: "Visitors",    value: 128400, pct: 100, color: "#C5C5C5" },
  { label: "Signed Up",  value: 41284,  pct: 32,  color: "#496FA8" },
  { label: "Trial",      value: 14800,  pct: 12,  color: brand.orange },
  { label: "Subscribed", value: 9820,   pct: 8,   color: "#2D9B68" },
  { label: "Renewed",    value: 7120,   pct: 6,   color: "#8B5CF6" },
];

// Smart formatter: shows M for ≥1M, K for ≥1K
function fmtEGP(n: number): string {
  if (n >= 1_000_000) return `EGP ${(n / 1_000_000).toFixed(1)}M`;
  if (n >= 1000) return `EGP ${Math.round(n / 1000)}K`;
  return `EGP ${n.toLocaleString()}`;
}

function fmtCount(n: number): string {
  if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1)}M`;
  if (n >= 10000) return `${(n / 1000).toFixed(1)}K`;
  return n.toLocaleString();
}

function BarChart({ data, color, height = 160 }: { data: { label: string; value: number }[]; color: string; height?: number }) {
  const max = Math.max(...data.map(d => d.value));
  return (
    <div style={{ display: "flex", alignItems: "flex-end", gap: 6, height }}>
      {data.map((d, i) => (
        <div key={i} style={{ flex: 1, display: "flex", flexDirection: "column" as const, alignItems: "center", gap: 4 }}>
          <div style={{ width: "100%", borderRadius: "6px 6px 0 0", height: `${(d.value / max) * (height - 24)}px`, background: color, opacity: 0.8 }} />
          <div style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray, whiteSpace: "nowrap" as const }}>{d.label}</div>
        </div>
      ))}
    </div>
  );
}

function StatCard({ label, value, sub, trend, color }: { label: string; value: string; sub: string; trend: "up" | "down" | "flat"; color: string }) {
  const trendColor = trend === "up" ? "#2D9B68" : trend === "down" ? "#FF2D32" : brand.warmGray;
  return (
    <div style={{ background: brand.white, borderRadius: 16, border: `1px solid ${brand.borderGray}`, padding: "18px 20px" }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
        <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginBottom: 6 }}>{label}</div>
        <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: trendColor, display: "flex", alignItems: "center", gap: 3 }}>
          {trend === "up" ? <ArrowUpRight size={12} /> : trend === "down" ? <ArrowDownRight size={12} /> : null}
          {sub}
        </span>
      </div>
      <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 800, fontSize: 24, color }}>{value}</div>
    </div>
  );
}

export default function AdminAnalytics() {
  const nav = useNavigate();
  const [period, setPeriod] = useState<Period>("30d");

  const revSeries = REVENUE_SERIES[period];
  const userSeries = USER_SERIES[period];
  const kpi = KPI_CONTEXT[period];

  const totalRevenue = revSeries.reduce((a, b) => a + b.value, 0);
  const totalUsers   = userSeries.reduce((a, b) => a + b.value, 0);

  const periodLabel: Record<Period, string> = { "7d": "this week", "30d": "this month", "90d": "this quarter", "1y": "this year" };
  const revenueChange: Record<Period, string> = { "7d": "+12% vs last week", "30d": "+18% vs last month", "90d": "+22% vs last quarter", "1y": "+31% vs last year" };
  const userChange: Record<Period, string>    = { "7d": "+9% vs last week",  "30d": "+12% vs last month", "90d": "+19% vs last quarter", "1y": "+28% vs last year" };

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh", display: "flex" }}>

      {/* Sidebar */}
      <div style={{ width: 210, background: brand.charcoal, flexDirection: "column", flexShrink: 0, padding: "24px 0", display: "flex" }}>
        <div style={{ padding: "0 20px 20px", borderBottom: "1px solid rgba(255,255,255,0.06)" }}>
          <div style={{ fontFamily: "Inter", fontWeight: 800, fontSize: 13, color: "#fff", letterSpacing: "0.06em" }}>EJADAH ADMIN</div>
          <div style={{ fontFamily: "Inter", fontSize: 11, color: "rgba(255,255,255,0.35)", marginTop: 2 }}>Control Panel</div>
        </div>
        <div style={{ flex: 1, padding: "14px 10px" }}>
          {NAV_ITEMS.map((item) => {
            const active = item.path === "/admin/analytics";
            return (
              <button key={item.label} onClick={() => nav(item.path)}
                style={{ width: "100%", display: "flex", gap: 10, alignItems: "center", padding: "10px 12px", borderRadius: 10, cursor: "pointer", marginBottom: 3, background: active ? "rgba(255,255,255,0.1)" : "transparent", border: "none", color: active ? "#fff" : "rgba(255,255,255,0.5)", fontFamily: "Inter", fontSize: 13, fontWeight: active ? 700 : 400 }}>
                {item.icon} {item.label}
              </button>
            );
          })}
        </div>
        <div style={{ padding: "14px 20px", borderTop: "1px solid rgba(255,255,255,0.06)" }}>
          <button onClick={() => nav("/")} style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.4)", background: "none", border: "none", cursor: "pointer" }}>← Back to Site</button>
        </div>
      </div>

      {/* Main */}
      <div style={{ flex: 1, padding: "28px 28px 60px", overflow: "auto" }}>

        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 24, flexWrap: "wrap", gap: 12 }}>
          <div>
            <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 24, color: brand.charcoal, marginBottom: 4 }}>Analytics</h1>
            <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray }}>Platform performance — {periodLabel[period]}</div>
          </div>
          <div style={{ display: "flex", background: brand.white, borderRadius: 12, border: `1px solid ${brand.borderGray}`, overflow: "hidden" }}>
            {(["7d", "30d", "90d", "1y"] as Period[]).map((p) => (
              <button key={p} onClick={() => setPeriod(p)}
                style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: period === p ? "#fff" : brand.warmGray, background: period === p ? brand.charcoal : "transparent", border: "none", padding: "8px 16px", cursor: "pointer" }}>
                {p}
              </button>
            ))}
          </div>
        </div>

        {/* KPI cards */}
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(180px, 1fr))", gap: 14, marginBottom: 24 }}>
          <StatCard label="Revenue" value={fmtEGP(totalRevenue)} sub={revenueChange[period]} trend="up" color={brand.orange} />
          <StatCard label="New Users" value={fmtCount(totalUsers)} sub={userChange[period]} trend="up" color="#496FA8" />
          <StatCard label="Active Subscriptions" value="9,820" sub={kpi.subTrend} trend="up" color="#2D9B68" />
          <StatCard label="Churn Rate" value={kpi.churn} sub={kpi.churnTrend} trend="down" color="#FF2D32" />
          <StatCard label="Avg. Revenue / Subscriber" value={kpi.arpu} sub="+5% vs prior" trend="up" color="#8B5CF6" />
          <StatCard label="Course Completion" value={kpi.completion} sub="+3% vs prior" trend="up" color={brand.amber} />
        </div>

        {/* Charts */}
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 18, marginBottom: 22 }}>

          <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "22px" }}>
            <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 18 }}>
              <div>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em", marginBottom: 4 }}>Revenue</div>
                <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 800, fontSize: 22, color: brand.charcoal }}>{fmtEGP(totalRevenue)}</div>
              </div>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: "#2D9B68", background: "#2D9B6812", borderRadius: 8, padding: "4px 10px", alignSelf: "flex-start", display: "flex", alignItems: "center", gap: 4 }}>
                <ArrowUpRight size={11} /> {revenueChange[period].split(" ")[0]}
              </div>
            </div>
            <BarChart data={revSeries} color={brand.orange} height={160} />
          </div>

          <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "22px" }}>
            <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 18 }}>
              <div>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em", marginBottom: 4 }}>New Users</div>
                <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 800, fontSize: 22, color: brand.charcoal }}>{fmtCount(totalUsers)}</div>
              </div>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: "#2D9B68", background: "#2D9B6812", borderRadius: 8, padding: "4px 10px", alignSelf: "flex-start", display: "flex", alignItems: "center", gap: 4 }}>
                <ArrowUpRight size={11} /> {userChange[period].split(" ")[0]}
              </div>
            </div>
            <BarChart data={userSeries} color="#496FA8" height={160} />
          </div>
        </div>

        {/* Dept breakdown + Funnel */}
        <div style={{ display: "grid", gridTemplateColumns: "1.2fr 0.8fr", gap: 18, marginBottom: 22 }}>

          <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "22px" }}>
            <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em", marginBottom: 16 }}>Revenue by Department (Monthly)</div>
            {DEPT_BREAKDOWN.map((d) => (
              <div key={d.dept} style={{ marginBottom: 14 }}>
                <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 5 }}>
                  <div style={{ display: "flex", gap: 8, alignItems: "center" }}>
                    <div style={{ width: 8, height: 8, borderRadius: "50%", background: d.color, flexShrink: 0 }} />
                    <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.charcoal }}>{d.dept}</span>
                  </div>
                  <div style={{ display: "flex", gap: 14 }}>
                    <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>{d.users.toLocaleString()} subscribers</span>
                    <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.charcoal }}>{d.revenue}</span>
                  </div>
                </div>
                <div style={{ height: 5, background: brand.offWhite, borderRadius: 10, overflow: "hidden" }}>
                  <div style={{ height: "100%", width: `${d.pct}%`, background: d.color, borderRadius: 10, opacity: 0.75 }} />
                </div>
              </div>
            ))}
          </div>

          <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "22px" }}>
            <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em", marginBottom: 16 }}>Conversion Funnel</div>
            {FUNNEL.map((f, i) => (
              <div key={i} style={{ marginBottom: 16 }}>
                <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 5 }}>
                  <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.charcoal }}>{f.label}</span>
                  <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.charcoal }}>{f.value.toLocaleString()}</span>
                </div>
                <div style={{ height: 7, background: brand.offWhite, borderRadius: 10, overflow: "hidden" }}>
                  <div style={{ height: "100%", width: `${f.pct}%`, background: f.color, borderRadius: 10 }} />
                </div>
                <div style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray, marginTop: 3 }}>{f.pct}% of all visitors</div>
              </div>
            ))}
          </div>
        </div>

        {/* Top content */}
        <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "22px" }}>
          <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em", marginBottom: 16 }}>Top Performing Content</div>
          <div style={{ display: "grid", gridTemplateColumns: "2fr 0.7fr 0.8fr 0.8fr 0.5fr", padding: "0 0 10px" }}>
            {["Title", "Type", "Enrolled", "Revenue", "Rating"].map((h) => (
              <div key={h} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.05em" }}>{h}</div>
            ))}
          </div>
          {TOP_CONTENT.map((c, i) => (
            <div key={i} style={{ display: "grid", gridTemplateColumns: "2fr 0.7fr 0.8fr 0.8fr 0.5fr", padding: "11px 0", borderTop: `1px solid ${brand.borderGray}`, alignItems: "center" }}>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal }}>{c.title}</div>
              <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>{c.type}</div>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.charcoal }}>{c.enrolled.toLocaleString()}</div>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.charcoal }}>{c.revenue}</div>
              <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.amber }}>★ {c.rating}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
