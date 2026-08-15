import { useState } from "react";
import { useNavigate } from "react-router";
import { Users, BookOpen, DollarSign, BarChart2, Shield, Search, Filter, ChevronDown, MoreHorizontal, CheckCircle, XCircle, Clock, Download, Mail, Lock, Unlock, UserCheck, ChevronLeft, ChevronRight, Eye } from "lucide-react";
import { brand, gradientFlow } from "@/app/shared";

type Role = "student" | "tutor" | "mentor" | "consultant" | "instructor" | "admin";
type Status = "active" | "suspended" | "pending" | "trial";

interface UserRow {
  id: string;
  name: string;
  email: string;
  role: Role;
  status: Status;
  plan: string;
  joined: string;
  lastSeen: string;
  revenue: string;
  avatar: string;
}

const MOCK_USERS: UserRow[] = [
  { id: "U001", name: "Dr. Ahmed Mostafa", email: "ahmed.mostafa@email.com", role: "student", status: "active", plan: "Exam Pro", joined: "Jan 2025", lastSeen: "2 min ago", revenue: "EGP 2,994", avatar: "AM" },
  { id: "U002", name: "Dr. Laila Shawki", email: "laila.shawki@email.com", role: "instructor", status: "active", plan: "Instructor", joined: "Mar 2024", lastSeen: "1h ago", revenue: "EGP 18,400", avatar: "LS" },
  { id: "U003", name: "Dr. Omar Farid", email: "omar.farid@email.com", role: "mentor", status: "active", plan: "Pro Mentor", joined: "Jun 2024", lastSeen: "3h ago", revenue: "EGP 12,200", avatar: "OF" },
  { id: "U004", name: "Nour El-Sayed", email: "nour.elsayed@email.com", role: "student", status: "trial", plan: "Free Trial", joined: "Jul 2026", lastSeen: "10 min ago", revenue: "EGP 0", avatar: "NS" },
  { id: "U005", name: "Dr. Hana El-Gohary", email: "hana.gohary@email.com", role: "tutor", status: "active", plan: "Tutor Basic", joined: "Sep 2024", lastSeen: "Yesterday", revenue: "EGP 7,600", avatar: "HG" },
  { id: "U006", name: "Dr. Karim Adly", email: "karim.adly@email.com", role: "consultant", status: "active", plan: "Consultant Pro", joined: "Feb 2025", lastSeen: "2 days ago", revenue: "EGP 22,100", avatar: "KA" },
  { id: "U007", name: "Sara Youssef", email: "sara.youssef@email.com", role: "student", status: "suspended", plan: "Student Pass", joined: "Nov 2024", lastSeen: "3 weeks ago", revenue: "EGP 499", avatar: "SY" },
  { id: "U008", name: "Dr. Mohamed Fathi", email: "m.fathi@email.com", role: "instructor", status: "pending", plan: "—", joined: "Jul 2026", lastSeen: "Just now", revenue: "EGP 0", avatar: "MF" },
  { id: "U009", name: "Rania Hassan", email: "rania.hassan@email.com", role: "student", status: "active", plan: "Exam Pro", joined: "Apr 2025", lastSeen: "5h ago", revenue: "EGP 1,497", avatar: "RH" },
  { id: "U010", name: "Dr. Youssef Naguib", email: "y.naguib@email.com", role: "mentor", status: "active", plan: "Pro Mentor", joined: "Jan 2024", lastSeen: "Yesterday", revenue: "EGP 31,800", avatar: "YN" },
  { id: "U011", name: "Mariam Lotfy", email: "mariam.lotfy@email.com", role: "student", status: "active", plan: "Student Pass", joined: "May 2026", lastSeen: "4h ago", revenue: "EGP 499", avatar: "ML" },
  { id: "U012", name: "Dr. Dina Rashad", email: "dina.rashad@email.com", role: "instructor", status: "active", plan: "Instructor", joined: "Oct 2024", lastSeen: "1 day ago", revenue: "EGP 9,700", avatar: "DR" },
];

const roleColors: Record<Role, string> = {
  student: brand.orange,
  tutor: "#496FA8",
  mentor: "#2D9B68",
  consultant: "#8B5CF6",
  instructor: brand.amber,
  admin: "#FF2D32",
};

const statusColors: Record<Status, { bg: string; text: string; label: string }> = {
  active: { bg: "#2D9B6814", text: "#2D9B68", label: "Active" },
  suspended: { bg: "#FF2D3214", text: "#FF2D32", label: "Suspended" },
  pending: { bg: `${brand.amber}14`, text: brand.amber, label: "Pending" },
  trial: { bg: `${brand.orange}14`, text: brand.orange, label: "Trial" },
};

const NAV_ITEMS = [
  { label: "Overview", icon: <BarChart2 size={15} />, path: "/admin" },
  { label: "Users", icon: <Users size={15} />, path: "/admin/users" },
  { label: "Content", icon: <BookOpen size={15} />, path: "/admin/content" },
  { label: "Analytics", icon: <BarChart2 size={15} />, path: "/admin/analytics" },
  { label: "Billing", icon: <DollarSign size={15} />, path: "/admin/billing" },
];

const PAGE_SIZE = 8;

export default function AdminUsers() {
  const nav = useNavigate();
  const [search, setSearch] = useState("");
  const [roleFilter, setRoleFilter] = useState<"all" | Role>("all");
  const [statusFilter, setStatusFilter] = useState<"all" | Status>("all");
  const [page, setPage] = useState(1);
  const [selectedUser, setSelectedUser] = useState<UserRow | null>(null);
  const [actionMenu, setActionMenu] = useState<string | null>(null);

  const filtered = MOCK_USERS.filter((u) => {
    const q = search.toLowerCase();
    const matchSearch = u.name.toLowerCase().includes(q) || u.email.toLowerCase().includes(q) || u.id.toLowerCase().includes(q);
    const matchRole = roleFilter === "all" || u.role === roleFilter;
    const matchStatus = statusFilter === "all" || u.status === statusFilter;
    return matchSearch && matchRole && matchStatus;
  });

  const totalPages = Math.ceil(filtered.length / PAGE_SIZE);
  const paginated = filtered.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE);

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
            const active = item.path === "/admin/users";
            return (
              <button key={item.label} onClick={() => nav(item.path)}
                style={{ width: "100%", display: "flex", gap: 10, alignItems: "center", padding: "10px 12px", borderRadius: 10, cursor: "pointer", marginBottom: 3, background: active ? "rgba(255,255,255,0.1)" : "transparent", border: "none", color: active ? "#fff" : "rgba(255,255,255,0.5)", fontFamily: "Inter", fontSize: 13, fontWeight: active ? 700 : 400, transition: "background 0.15s" }}>
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

        {/* Header */}
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 24, flexWrap: "wrap", gap: 12 }}>
          <div>
            <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 24, color: brand.charcoal, marginBottom: 4 }}>Users</h1>
            <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray }}>41,284 total users · 29,840 active · 4,820 on trial</div>
          </div>
          <div style={{ display: "flex", gap: 8 }}>
            <button style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.warmGray, background: brand.white, border: `1px solid ${brand.borderGray}`, borderRadius: 10, padding: "9px 14px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}>
              <Download size={13} /> Export
            </button>
            <button style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "9px 16px", cursor: "pointer" }}>
              + Add User
            </button>
          </div>
        </div>

        {/* Stats row */}
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(130px, 1fr))", gap: 12, marginBottom: 22 }}>
          {[
            { label: "Total Users", value: "41,284", color: brand.orange },
            { label: "Active", value: "29,840", color: "#2D9B68" },
            { label: "Trial", value: "4,820", color: brand.amber },
            { label: "Suspended", value: "1,240", color: "#FF2D32" },
            { label: "Instructors & Tutors", value: "386", color: "#8B5CF6" },
            { label: "New This Month", value: "1,240", color: "#496FA8" },
          ].map((s) => (
            <div key={s.label} style={{ background: brand.white, borderRadius: 14, border: `1px solid ${brand.borderGray}`, padding: "14px 16px" }}>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 800, fontSize: 20, color: s.color }}>{s.value}</div>
              <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginTop: 2 }}>{s.label}</div>
            </div>
          ))}
        </div>

        {/* Filters */}
        <div style={{ display: "flex", gap: 10, marginBottom: 16, flexWrap: "wrap" as const, alignItems: "center" }}>
          <div style={{ position: "relative", flex: 1, minWidth: 200 }}>
            <Search size={13} style={{ position: "absolute", left: 10, top: "50%", transform: "translateY(-50%)", color: brand.warmGray }} />
            <input value={search} onChange={(e) => { setSearch(e.target.value); setPage(1); }} placeholder="Search by name, email, or ID…"
              style={{ width: "100%", fontFamily: "Inter", fontSize: 13, background: brand.white, border: `1.5px solid ${brand.borderGray}`, borderRadius: 10, padding: "9px 10px 9px 30px", outline: "none", color: brand.charcoal, boxSizing: "border-box" as const }}
              onFocus={(e) => (e.target.style.borderColor = brand.orange)} onBlur={(e) => (e.target.style.borderColor = brand.borderGray)} />
          </div>
          {/* Role filter */}
          <div style={{ display: "flex", gap: 6, flexWrap: "wrap" as const }}>
            {(["all", "student", "tutor", "mentor", "consultant", "instructor"] as const).map((r) => (
              <button key={r} onClick={() => { setRoleFilter(r); setPage(1); }}
                style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: roleFilter === r ? "#fff" : brand.warmGray, background: roleFilter === r ? (r === "all" ? gradientFlow : roleColors[r as Role]) : brand.white, border: `1.5px solid ${roleFilter === r ? "transparent" : brand.borderGray}`, borderRadius: 20, padding: "5px 12px", cursor: "pointer" }}>
                {r === "all" ? "All Roles" : r.charAt(0).toUpperCase() + r.slice(1)}
              </button>
            ))}
          </div>
          {/* Status filter */}
          <div style={{ display: "flex", gap: 6 }}>
            {(["all", "active", "trial", "suspended", "pending"] as const).map((s) => (
              <button key={s} onClick={() => { setStatusFilter(s); setPage(1); }}
                style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: statusFilter === s ? "#fff" : brand.warmGray, background: statusFilter === s ? brand.charcoal : brand.white, border: `1.5px solid ${statusFilter === s ? brand.charcoal : brand.borderGray}`, borderRadius: 20, padding: "5px 12px", cursor: "pointer" }}>
                {s === "all" ? "All Status" : s.charAt(0).toUpperCase() + s.slice(1)}
              </button>
            ))}
          </div>
        </div>

        {/* Table */}
        <div style={{ background: brand.white, borderRadius: 16, border: `1px solid ${brand.borderGray}`, overflow: "hidden", marginBottom: 16 }}>
          {/* Table header */}
          <div style={{ display: "grid", gridTemplateColumns: "2fr 1.2fr 0.9fr 0.9fr 1fr 0.8fr 0.5fr", gap: 0, padding: "10px 20px", background: brand.offWhite, borderBottom: `1px solid ${brand.borderGray}` }}>
            {["User", "Email", "Role", "Status", "Plan", "Revenue", ""].map((h) => (
              <div key={h} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.05em" }}>{h}</div>
            ))}
          </div>

          {paginated.map((user, i) => (
            <div key={user.id} style={{ display: "grid", gridTemplateColumns: "2fr 1.2fr 0.9fr 0.9fr 1fr 0.8fr 0.5fr", gap: 0, padding: "13px 20px", borderBottom: i < paginated.length - 1 ? `1px solid ${brand.borderGray}` : "none", alignItems: "center", background: selectedUser?.id === user.id ? `${brand.orange}04` : "transparent", cursor: "pointer", transition: "background 0.1s" }}
              onClick={() => setSelectedUser(selectedUser?.id === user.id ? null : user)}>
              {/* User */}
              <div style={{ display: "flex", gap: 10, alignItems: "center" }}>
                <div style={{ width: 34, height: 34, borderRadius: "50%", background: `${roleColors[user.role]}18`, display: "flex", alignItems: "center", justifyContent: "center", fontFamily: "Inter", fontWeight: 800, fontSize: 11, color: roleColors[user.role], flexShrink: 0 }}>{user.avatar}</div>
                <div>
                  <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal }}>{user.name}</div>
                  <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{user.id} · Joined {user.joined}</div>
                </div>
              </div>
              {/* Email */}
              <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" as const }}>{user.email}</div>
              {/* Role */}
              <div>
                <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: roleColors[user.role], background: `${roleColors[user.role]}12`, borderRadius: 6, padding: "3px 8px" }}>{user.role}</span>
              </div>
              {/* Status */}
              <div>
                <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: statusColors[user.status].text, background: statusColors[user.status].bg, borderRadius: 6, padding: "3px 8px" }}>{statusColors[user.status].label}</span>
              </div>
              {/* Plan */}
              <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.charcoal }}>{user.plan}</div>
              {/* Revenue */}
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.charcoal }}>{user.revenue}</div>
              {/* Actions */}
              <div style={{ position: "relative", display: "flex", justifyContent: "flex-end" }} onClick={(e) => e.stopPropagation()}>
                <button onClick={() => setActionMenu(actionMenu === user.id ? null : user.id)}
                  style={{ width: 28, height: 28, borderRadius: 8, background: brand.offWhite, border: "none", display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer" }}>
                  <MoreHorizontal size={14} color={brand.warmGray} />
                </button>
                {actionMenu === user.id && (
                  <div style={{ position: "absolute", top: 32, right: 0, zIndex: 50, background: brand.white, border: `1px solid ${brand.borderGray}`, borderRadius: 12, boxShadow: "0 8px 24px rgba(0,0,0,0.1)", padding: "8px", minWidth: 160 }}>
                    {[
                      { label: "View Profile", icon: <Eye size={12} /> },
                      { label: "Send Email", icon: <Mail size={12} /> },
                      { label: user.status === "suspended" ? "Unsuspend" : "Suspend", icon: user.status === "suspended" ? <Unlock size={12} /> : <Lock size={12} />, color: user.status === "suspended" ? "#2D9B68" : "#FF2D32" },
                      { label: "Approve", icon: <UserCheck size={12} />, color: "#2D9B68", hide: user.status !== "pending" },
                    ].filter(a => !a.hide).map((action) => (
                      <button key={action.label} onClick={() => setActionMenu(null)}
                        style={{ width: "100%", display: "flex", gap: 8, alignItems: "center", fontFamily: "Inter", fontSize: 12, color: action.color ?? brand.charcoal, background: "none", border: "none", borderRadius: 8, padding: "8px 10px", cursor: "pointer", textAlign: "left" as const }}
                        onMouseEnter={(e) => ((e.currentTarget as HTMLElement).style.background = brand.offWhite)}
                        onMouseLeave={(e) => ((e.currentTarget as HTMLElement).style.background = "transparent")}>
                        {action.icon} {action.label}
                      </button>
                    ))}
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>

        {/* Pagination */}
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
          <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>Showing {(page - 1) * PAGE_SIZE + 1}–{Math.min(page * PAGE_SIZE, filtered.length)} of {filtered.length} users</div>
          <div style={{ display: "flex", gap: 6 }}>
            <button disabled={page === 1} onClick={() => setPage(p => p - 1)}
              style={{ width: 32, height: 32, borderRadius: 9, background: brand.white, border: `1px solid ${brand.borderGray}`, display: "flex", alignItems: "center", justifyContent: "center", cursor: page === 1 ? "default" : "pointer", opacity: page === 1 ? 0.4 : 1 }}>
              <ChevronLeft size={14} color={brand.charcoal} />
            </button>
            {Array.from({ length: totalPages }, (_, i) => (
              <button key={i} onClick={() => setPage(i + 1)}
                style={{ width: 32, height: 32, borderRadius: 9, fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: page === i + 1 ? "#fff" : brand.warmGray, background: page === i + 1 ? gradientFlow : brand.white, border: `1px solid ${page === i + 1 ? "transparent" : brand.borderGray}`, cursor: "pointer" }}>
                {i + 1}
              </button>
            ))}
            <button disabled={page === totalPages} onClick={() => setPage(p => p + 1)}
              style={{ width: 32, height: 32, borderRadius: 9, background: brand.white, border: `1px solid ${brand.borderGray}`, display: "flex", alignItems: "center", justifyContent: "center", cursor: page === totalPages ? "default" : "pointer", opacity: page === totalPages ? 0.4 : 1 }}>
              <ChevronRight size={14} color={brand.charcoal} />
            </button>
          </div>
        </div>

        {/* User detail drawer */}
        {selectedUser && (
          <div style={{ marginTop: 22, background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "24px" }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 20 }}>
              <div style={{ display: "flex", gap: 14, alignItems: "center" }}>
                <div style={{ width: 52, height: 52, borderRadius: "50%", background: `${roleColors[selectedUser.role]}18`, display: "flex", alignItems: "center", justifyContent: "center", fontFamily: "Inter", fontWeight: 800, fontSize: 16, color: roleColors[selectedUser.role] }}>{selectedUser.avatar}</div>
                <div>
                  <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal }}>{selectedUser.name}</div>
                  <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>{selectedUser.email} · {selectedUser.id}</div>
                </div>
              </div>
              <button onClick={() => setSelectedUser(null)} style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, background: brand.offWhite, border: "none", borderRadius: 8, padding: "6px 12px", cursor: "pointer" }}>Close ×</button>
            </div>
            <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(160px, 1fr))", gap: 12 }}>
              {[
                { label: "Role", value: selectedUser.role },
                { label: "Status", value: statusColors[selectedUser.status].label },
                { label: "Plan", value: selectedUser.plan },
                { label: "Total Revenue", value: selectedUser.revenue },
                { label: "Joined", value: selectedUser.joined },
                { label: "Last Seen", value: selectedUser.lastSeen },
              ].map((d) => (
                <div key={d.label} style={{ background: brand.offWhite, borderRadius: 12, padding: "14px" }}>
                  <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginBottom: 4 }}>{d.label}</div>
                  <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal }}>{d.value}</div>
                </div>
              ))}
            </div>
            <div style={{ display: "flex", gap: 8, marginTop: 16 }}>
              <button style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "9px 16px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}>
                <Mail size={12} /> Send Email
              </button>
              <button style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: "#FF2D32", background: "#FF2D3210", border: "none", borderRadius: 10, padding: "9px 16px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}>
                <Lock size={12} /> Suspend Account
              </button>
              <button style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal, background: brand.offWhite, border: "none", borderRadius: 10, padding: "9px 16px", cursor: "pointer" }}>
                View Full Profile →
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
