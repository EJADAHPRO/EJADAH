import { useState } from "react";
import { useNavigate } from "react-router";
import { TrendingUp, TrendingDown, Users, AlertTriangle, Download, ArrowLeft, BarChart2, DollarSign } from "lucide-react";
import { brand, gradientFlow } from "@/figma/app/shared";
import { PLANS } from "@/figma/app/pricingData";

const PLAN_DIST = [
  { planId: "student-pass", count: 1284, mrr: 384516, trend: 12 },
  { planId: "exam-pro", count: 2891, mrr: 1442009, trend: 18 },
  { planId: "cpd-premium", count: 743, mrr: 593657, trend: 7 },
  { planId: "career-pro", count: 512, mrr: 14848, trend: -2 },
  { planId: "ai-pro", count: 319, mrr: 6061, trend: 5 },
  { planId: "elite", count: 96, mrr: 9504, trend: 22 },
];

const RECENT_TXNS = [
  { id: "TXN-90281", user: "Ahmed Sayed", plan: "Exam Pro", amount: "EGP 499", method: "Card", status: "success", time: "2 min ago" },
  { id: "TXN-90280", user: "Sara Khalil", plan: "Elite", amount: "$99", method: "Card", status: "success", time: "7 min ago" },
  { id: "TXN-90279", user: "Mostafa Nour", plan: "CPD Premium", amount: "EGP 799", method: "Fawry", status: "pending", time: "14 min ago" },
  { id: "TXN-90278", user: "Dina Helmy", plan: "Student Pass", amount: "EGP 299", method: "Vodafone Cash", status: "success", time: "22 min ago" },
  { id: "TXN-90277", user: "Karim Adel", plan: "Career Pro", amount: "$29", method: "Card", status: "failed", time: "31 min ago" },
  { id: "TXN-90276", user: "Nour Ibrahim", plan: "AI Pro", amount: "$19", method: "Card", status: "success", time: "45 min ago" },
  { id: "TXN-90275", user: "Hana Magdy", plan: "Exam Pro", amount: "EGP 4,490", method: "Card", status: "success", time: "1h ago" },
  { id: "TXN-90274", user: "Omar Fawzy", plan: "Elite", amount: "$899", method: "Card", status: "success", time: "1h ago" },
];

const FAILED_PAYMENTS = [
  { user: "Karim Adel", email: "k.adel@mail.com", plan: "Career Pro", amount: "$29", failed: "1 Jul 2025", grace: "4 Jul 2025", hoursLeft: 54 },
  { user: "Rana Samir", email: "r.samir@mail.com", plan: "Exam Pro", amount: "EGP 499", failed: "30 Jun 2025", grace: "3 Jul 2025", hoursLeft: 12 },
  { user: "Baher Younis", email: "b.younis@mail.com", plan: "CPD Premium", amount: "EGP 799", failed: "28 Jun 2025", grace: "1 Jul 2025", hoursLeft: 2 },
];

const STAT_PERIODS = ["Today", "7 days", "30 days", "All time"];

function StatCard({ title, value, sub, icon, trend, color }: { title: string; value: string; sub?: string; icon: React.ReactNode; trend?: number; color: string }) {
  return (
    <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "20px", flex: 1, minWidth: 160 }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 12 }}>
        <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.warmGray, letterSpacing: "0.04em" }}>{title}</div>
        <div style={{ width: 34, height: 34, borderRadius: 10, background: `${color}12`, display: "flex", alignItems: "center", justifyContent: "center", color: color }}>{icon}</div>
      </div>
      <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 800, fontSize: 22, color: brand.charcoal, marginBottom: 2 }}>{value}</div>
      {sub && <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{sub}</div>}
      {trend !== undefined && (
        <div style={{ display: "flex", gap: 4, alignItems: "center", marginTop: 6 }}>
          {trend >= 0 ? <TrendingUp size={12} color="#2D9B68" /> : <TrendingDown size={12} color="#FF2D32" />}
          <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: trend >= 0 ? "#2D9B68" : "#FF2D32" }}>{trend >= 0 ? "+" : ""}{trend}% vs last month</span>
        </div>
      )}
    </div>
  );
}

export default function AdminBilling() {
  const nav = useNavigate();
  const [period, setPeriod] = useState("30 days");

  const totalMRR = PLAN_DIST.reduce((acc, p) => {
    const plan = PLANS.find((pl) => pl.id === p.planId);
    if (!plan) return acc;
    if (plan.currency === "EGP") return acc + p.mrr;
    return acc + p.mrr * 50;
  }, 0);

  const totalSubs = PLAN_DIST.reduce((a, p) => a + p.count, 0);

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Header */}
      <div style={{ background: brand.charcoal, padding: "24px 24px 20px" }}>
        <div style={{ maxWidth: 1100, margin: "0 auto" }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", flexWrap: "wrap", gap: 14, marginBottom: 6 }}>
            <div>
              <button onClick={() => nav(-1)} style={{ background: "none", border: "none", cursor: "pointer", color: "rgba(255,255,255,0.35)", fontFamily: "Inter", fontSize: 12, display: "flex", alignItems: "center", gap: 5, marginBottom: 8 }}>
                <ArrowLeft size={13} /> Admin
              </button>
              <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 24, color: "#fff", margin: 0 }}>Billing Overview</h1>
            </div>
            <div style={{ display: "flex", gap: 8, alignItems: "center" }}>
              <div style={{ display: "flex", background: "rgba(255,255,255,0.07)", borderRadius: 22, padding: 3, gap: 2 }}>
                {STAT_PERIODS.map((p) => (
                  <button key={p} onClick={() => setPeriod(p)}
                    style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: period === p ? brand.charcoal : "rgba(255,255,255,0.4)", background: period === p ? "#fff" : "transparent", border: "none", borderRadius: 18, padding: "6px 12px", cursor: "pointer" }}>
                    {p}
                  </button>
                ))}
              </div>
              <button style={{ display: "flex", gap: 5, alignItems: "center", fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: "#fff", background: "rgba(255,255,255,0.1)", border: "none", borderRadius: 9, padding: "9px 14px", cursor: "pointer" }}>
                <Download size={13} /> Export
              </button>
            </div>
          </div>
        </div>
      </div>

      <div style={{ maxWidth: 1100, margin: "0 auto", padding: "24px 24px 60px" }}>

        {/* Top stats */}
        <div style={{ display: "flex", gap: 14, flexWrap: "wrap", marginBottom: 24 }}>
          <StatCard title="MRR" value={`EGP ${(totalMRR / 1000).toFixed(0)}K`} sub="Monthly recurring revenue" icon={<DollarSign size={16} />} trend={14} color={brand.orange} />
          <StatCard title="ARR" value={`EGP ${(totalMRR * 12 / 1000000).toFixed(1)}M`} sub="Annual run rate" icon={<BarChart2 size={16} />} trend={14} color="#496FA8" />
          <StatCard title="Active Subscribers" value={totalSubs.toLocaleString()} sub="Across all plans" icon={<Users size={16} />} trend={8} color="#2D9B68" />
          <StatCard title="Failed Payments" value={FAILED_PAYMENTS.length.toString()} sub={`${FAILED_PAYMENTS.filter(f => f.hoursLeft < 24).length} critical (< 24h)`} icon={<AlertTriangle size={16} />} trend={-5} color="#FF2D32" />
        </div>

        <div style={{ display: "flex", gap: 20, flexWrap: "wrap", alignItems: "flex-start" }}>
          {/* Left column */}
          <div style={{ flex: 1, minWidth: 340, display: "flex", flexDirection: "column" as const, gap: 20 }}>

            {/* Plan distribution */}
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "22px" }}>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em", marginBottom: 16 }}>Plan Distribution</div>
              {PLAN_DIST.map((row) => {
                const plan = PLANS.find((p) => p.id === row.planId);
                if (!plan) return null;
                const pct = Math.round((row.count / totalSubs) * 100);
                return (
                  <div key={row.planId} style={{ marginBottom: 14 }}>
                    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 5 }}>
                      <div style={{ display: "flex", gap: 7, alignItems: "center" }}>
                        <span style={{ fontSize: 16 }}>{plan.emoji}</span>
                        <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal }}>{plan.name}</span>
                      </div>
                      <div style={{ display: "flex", gap: 14, alignItems: "center" }}>
                        <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{row.count.toLocaleString()} subs</span>
                        <div style={{ display: "flex", gap: 3, alignItems: "center" }}>
                          {row.trend >= 0 ? <TrendingUp size={11} color="#2D9B68" /> : <TrendingDown size={11} color="#FF2D32" />}
                          <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 10, color: row.trend >= 0 ? "#2D9B68" : "#FF2D32" }}>{row.trend >= 0 ? "+" : ""}{row.trend}%</span>
                        </div>
                      </div>
                    </div>
                    <div style={{ height: 6, background: brand.offWhite, borderRadius: 20, overflow: "hidden" }}>
                      <div style={{ height: "100%", width: `${pct}%`, background: plan.color, borderRadius: 20 }} />
                    </div>
                    <div style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray, marginTop: 3 }}>{pct}% of total</div>
                  </div>
                );
              })}
            </div>

            {/* Failed payments */}
            <div style={{ background: brand.white, borderRadius: 20, border: `1.5px solid #FF2D3220`, padding: "22px" }}>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 16 }}>
                <div style={{ display: "flex", gap: 7, alignItems: "center" }}>
                  <AlertTriangle size={14} color="#FF2D32" />
                  <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: "#FF2D32", textTransform: "uppercase" as const, letterSpacing: "0.06em" }}>Failed Payments</span>
                </div>
                <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{FAILED_PAYMENTS.length} accounts</span>
              </div>
              {FAILED_PAYMENTS.map((fp) => (
                <div key={fp.user} style={{ padding: "13px", background: brand.offWhite, borderRadius: 12, marginBottom: 10, border: fp.hoursLeft < 24 ? "1.5px solid #FF2D3225" : `1px solid ${brand.borderGray}` }}>
                  <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 6 }}>
                    <div>
                      <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal }}>{fp.user}</div>
                      <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{fp.email}</div>
                    </div>
                    <div style={{ textAlign: "right" as const }}>
                      <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal }}>{fp.amount}</div>
                      <div style={{ fontFamily: "Inter", fontWeight: 800, fontSize: 10, color: fp.hoursLeft < 24 ? "#FF2D32" : brand.orange }}>{fp.hoursLeft}h left</div>
                    </div>
                  </div>
                  <div style={{ display: "flex", gap: 14, alignItems: "center" }}>
                    <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>Failed: {fp.failed}</span>
                    <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>Grace ends: {fp.grace}</span>
                  </div>
                  <div style={{ height: 4, background: `#FF2D3214`, borderRadius: 20, overflow: "hidden", marginTop: 8 }}>
                    <div style={{ height: "100%", width: `${Math.round((1 - fp.hoursLeft / 72) * 100)}%`, background: fp.hoursLeft < 24 ? "#FF2D32" : brand.orange, borderRadius: 20 }} />
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Right column — transactions */}
          <div style={{ flex: 2, minWidth: 340 }}>
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "22px" }}>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 16 }}>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em" }}>Recent Transactions</div>
                <button style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.orange, background: "none", border: "none", cursor: "pointer" }}>View all</button>
              </div>

              <div style={{ overflowX: "auto" as const }}>
                <table style={{ width: "100%", borderCollapse: "collapse", minWidth: 540 }}>
                  <thead>
                    <tr>
                      {["Transaction", "User", "Plan", "Amount", "Method", "Status", "Time"].map((h) => (
                        <th key={h} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 10, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em", textAlign: "left" as const, padding: "0 10px 12px 0", whiteSpace: "nowrap" as const }}>
                          {h}
                        </th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {RECENT_TXNS.map((txn) => (
                      <tr key={txn.id} style={{ borderTop: `1px solid ${brand.borderGray}` }}>
                        <td style={{ padding: "11px 10px 11px 0", fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: brand.charcoal, whiteSpace: "nowrap" as const }}>{txn.id}</td>
                        <td style={{ padding: "11px 10px 11px 0", fontFamily: "Inter", fontSize: 12, color: brand.charcoal }}>{txn.user}</td>
                        <td style={{ padding: "11px 10px 11px 0", fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{txn.plan}</td>
                        <td style={{ padding: "11px 10px 11px 0", fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.charcoal, whiteSpace: "nowrap" as const }}>{txn.amount}</td>
                        <td style={{ padding: "11px 10px 11px 0", fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{txn.method}</td>
                        <td style={{ padding: "11px 10px 11px 0" }}>
                          <span style={{ fontFamily: "Inter", fontWeight: 800, fontSize: 10, padding: "3px 8px", borderRadius: 20, background: txn.status === "success" ? "#2D9B6814" : txn.status === "pending" ? `${brand.gold}18` : "#FF2D3214", color: txn.status === "success" ? "#2D9B68" : txn.status === "pending" ? "#B8860B" : "#FF2D32" }}>
                            {txn.status}
                          </span>
                        </td>
                        <td style={{ padding: "11px 0 11px 0", fontFamily: "Inter", fontSize: 11, color: brand.warmGray, whiteSpace: "nowrap" as const }}>{txn.time}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>

            {/* Revenue by plan */}
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "22px", marginTop: 20 }}>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em", marginBottom: 16 }}>Revenue by Plan (EGP equiv.)</div>
              {PLAN_DIST.map((row) => {
                const plan = PLANS.find((p) => p.id === row.planId);
                if (!plan) return null;
                const egpMRR = plan.currency === "EGP" ? row.mrr : row.mrr * 50;
                const pct = Math.round((egpMRR / (totalMRR || 1)) * 100);
                return (
                  <div key={row.planId} style={{ display: "flex", gap: 12, alignItems: "center", marginBottom: 10 }}>
                    <span style={{ fontSize: 16, flexShrink: 0 }}>{plan.emoji}</span>
                    <div style={{ flex: 1 }}>
                      <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 4 }}>
                        <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal }}>{plan.name}</span>
                        <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.charcoal }}>EGP {(egpMRR / 1000).toFixed(0)}K</span>
                      </div>
                      <div style={{ height: 6, background: brand.offWhite, borderRadius: 20, overflow: "hidden" }}>
                        <div style={{ height: "100%", width: `${pct}%`, background: `linear-gradient(90deg, ${plan.color}, ${plan.color}AA)`, borderRadius: 20 }} />
                      </div>
                    </div>
                    <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: brand.warmGray, width: 30, textAlign: "right" as const }}>{pct}%</span>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
