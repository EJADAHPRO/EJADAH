import { useState } from "react";
import { useNavigate } from "react-router";
import { Users, BookOpen, DollarSign, BarChart2, Search, Eye, Edit2, Trash2, MoreHorizontal, CheckCircle, XCircle, Clock, Filter, PlusCircle, Star, Video, BookMarked, FileText, Headphones } from "lucide-react";
import { brand, gradientFlow } from "@/app/shared";

type ContentType = "course" | "companion" | "live" | "article" | "quiz";
type ContentStatus = "published" | "draft" | "pending" | "rejected";

interface ContentItem {
  id: string;
  type: ContentType;
  title: string;
  author: string;
  department: string;
  status: ContentStatus;
  enrolled: number;
  rating: number;
  revenue: string;
  updated: string;
  flagged?: boolean;
}

const MOCK_CONTENT: ContentItem[] = [
  { id: "C001", type: "course",     title: "Advanced Endodontic Techniques",         author: "Dr. Laila Shawki",    department: "Endodontics",                    status: "published", enrolled: 3840, rating: 4.9, revenue: "EGP 184,000", updated: "Jul 2026" },
  { id: "C002", type: "companion",  title: "Endodontics Study Companion",             author: "Dr. Amira Soliman",   department: "Endodontics",                    status: "published", enrolled: 1240, rating: 4.9, revenue: "EGP 619,000", updated: "Jul 2026" },
  { id: "C003", type: "course",     title: "Implant Foundations Masterclass",         author: "Dr. Omar Farid",      department: "Implant Dentistry",              status: "published", enrolled: 2100, rating: 4.7, revenue: "EGP 126,000", updated: "Jun 2026" },
  { id: "C004", type: "live",       title: "EDLE Prep Live — July Session",           author: "Dr. Karim Adly",      department: "Exams",                          status: "published", enrolled: 820,  rating: 4.8, revenue: "EGP 41,000",  updated: "Jul 2026" },
  { id: "C005", type: "course",     title: "Orthodontic Wire Bending Masterclass",    author: "Dr. Nour Ahmed",      department: "Orthodontics",                   status: "pending",   enrolled: 0,    rating: 0,   revenue: "EGP 0",       updated: "Jul 2026" },
  { id: "C006", type: "companion",  title: "Periodontology & Oral Medicine Companion",author: "Dr. Hana El-Gohary",  department: "Periodontology & Oral Medicine",  status: "published", enrolled: 980,  rating: 4.7, revenue: "EGP 489,000", updated: "Jul 2026" },
  { id: "C007", type: "article",    title: "Understanding Pulp Diagnosis Classification",author: "Dr. Sara Mostafa", department: "Endodontics",                    status: "published", enrolled: 0,    rating: 4.6, revenue: "EGP 0",       updated: "Jun 2026" },
  { id: "C008", type: "quiz",       title: "EDLE Practice Bank — Endo Set 3",         author: "Ejadah Team",         department: "Exams",                          status: "published", enrolled: 6200, rating: 4.8, revenue: "EGP 0",       updated: "May 2026" },
  { id: "C009", type: "course",     title: "Fixed Prosthodontics: Crown & Bridge",    author: "Dr. Mohamed Fathi",   department: "Fixed Prosthodontics",           status: "draft",     enrolled: 0,    rating: 0,   revenue: "EGP 0",       updated: "Jul 2026" },
  { id: "C010", type: "companion",  title: "Oral Pathology Study Companion",          author: "Dr. Sara Mostafa",    department: "Oral Pathology",                 status: "published", enrolled: 730,  rating: 4.8, revenue: "EGP 364,000", updated: "Jul 2026" },
  { id: "C011", type: "course",     title: "Pediatric Dentistry Essentials",          author: "Dr. Rania Hassan",    department: "Pediatric Dentistry",            status: "rejected",  enrolled: 0,    rating: 0,   revenue: "EGP 0",       updated: "Jun 2026", flagged: true },
  { id: "C012", type: "live",       title: "Clinical Case Discussion — Perio",        author: "Dr. Youssef Naguib",  department: "Periodontology & Oral Medicine",  status: "pending",   enrolled: 0,    rating: 0,   revenue: "EGP 0",       updated: "Jul 2026" },
];

const typeColors: Record<ContentType, { color: string; label: string; icon: React.ReactNode }> = {
  course: { color: brand.orange, label: "Course", icon: <Video size={11} /> },
  companion: { color: "#8B5CF6", label: "Companion", icon: <BookMarked size={11} /> },
  live: { color: "#2D9B68", label: "Live", icon: <Headphones size={11} /> },
  article: { color: "#496FA8", label: "Article", icon: <FileText size={11} /> },
  quiz: { color: brand.amber, label: "Quiz", icon: <Star size={11} /> },
};

const statusColors: Record<ContentStatus, { bg: string; text: string; label: string; icon: React.ReactNode }> = {
  published: { bg: "#2D9B6812", text: "#2D9B68", label: "Published", icon: <CheckCircle size={11} /> },
  draft: { bg: `${brand.warmGray}14`, text: brand.warmGray, label: "Draft", icon: <Clock size={11} /> },
  pending: { bg: `${brand.amber}14`, text: brand.amber, label: "Pending Review", icon: <Clock size={11} /> },
  rejected: { bg: "#FF2D3214", text: "#FF2D32", label: "Rejected", icon: <XCircle size={11} /> },
};

const NAV_ITEMS = [
  { label: "Overview", icon: <BarChart2 size={15} />, path: "/admin" },
  { label: "Users", icon: <Users size={15} />, path: "/admin/users" },
  { label: "Content", icon: <BookOpen size={15} />, path: "/admin/content" },
  { label: "Analytics", icon: <BarChart2 size={15} />, path: "/admin/analytics" },
  { label: "Billing", icon: <DollarSign size={15} />, path: "/admin/billing" },
];

const PENDING = MOCK_CONTENT.filter(c => c.status === "pending");

export default function AdminContent() {
  const nav = useNavigate();
  const [search, setSearch] = useState("");
  const [typeFilter, setTypeFilter] = useState<"all" | ContentType>("all");
  const [statusFilter, setStatusFilter] = useState<"all" | ContentStatus>("all");
  const [actionMenu, setActionMenu] = useState<string | null>(null);
  const [approving, setApproving] = useState<string | null>(null);

  const filtered = MOCK_CONTENT.filter((c) => {
    const q = search.toLowerCase();
    const matchSearch = c.title.toLowerCase().includes(q) || c.author.toLowerCase().includes(q) || c.department.toLowerCase().includes(q);
    const matchType = typeFilter === "all" || c.type === typeFilter;
    const matchStatus = statusFilter === "all" || c.status === statusFilter;
    return matchSearch && matchType && matchStatus;
  });

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
            const active = item.path === "/admin/content";
            return (
              <button key={item.label} onClick={() => nav(item.path)}
                style={{ width: "100%", display: "flex", gap: 10, alignItems: "center", padding: "10px 12px", borderRadius: 10, cursor: "pointer", marginBottom: 3, background: active ? "rgba(255,255,255,0.1)" : "transparent", border: "none", color: active ? "#fff" : "rgba(255,255,255,0.5)", fontFamily: "Inter", fontSize: 13, fontWeight: active ? 700 : 400 }}>
                {item.icon} {item.label}
                {item.label === "Content" && PENDING.length > 0 && (
                  <span style={{ marginLeft: "auto", background: brand.amber, color: "#fff", borderRadius: 10, fontFamily: "Inter", fontWeight: 800, fontSize: 10, padding: "1px 6px" }}>{PENDING.length}</span>
                )}
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
            <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 24, color: brand.charcoal, marginBottom: 4 }}>Content</h1>
            <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray }}>184 items · {PENDING.length} pending review · 24,800 total enrolments</div>
          </div>
          <button style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "9px 16px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}>
            <PlusCircle size={13} /> New Content
          </button>
        </div>

        {/* Stats */}
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(120px, 1fr))", gap: 12, marginBottom: 22 }}>
          {[
            { label: "Total Items", value: "184", color: brand.charcoal },
            { label: "Published", value: "156", color: "#2D9B68" },
            { label: "Pending Review", value: PENDING.length.toString(), color: brand.amber },
            { label: "Drafts", value: "18", color: brand.warmGray },
            { label: "Rejected", value: "10", color: "#FF2D32" },
            { label: "Total Enrolments", value: "24,800", color: "#496FA8" },
          ].map((s) => (
            <div key={s.label} style={{ background: brand.white, borderRadius: 14, border: `1px solid ${brand.borderGray}`, padding: "14px 16px" }}>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 800, fontSize: 20, color: s.color }}>{s.value}</div>
              <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginTop: 2 }}>{s.label}</div>
            </div>
          ))}
        </div>

        {/* Pending review banner */}
        {PENDING.length > 0 && (
          <div style={{ background: `${brand.amber}12`, border: `1px solid ${brand.amber}30`, borderRadius: 14, padding: "14px 18px", marginBottom: 18, display: "flex", gap: 12, alignItems: "center", flexWrap: "wrap" }}>
            <Clock size={16} color={brand.amber} style={{ flexShrink: 0 }} />
            <div style={{ flex: 1 }}>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal }}>
                {PENDING.length} item{PENDING.length > 1 ? "s" : ""} waiting for review
              </div>
              <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>
                {PENDING.map(c => c.title).join(" · ")}
              </div>
            </div>
            <button onClick={() => setStatusFilter("pending")}
              style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.amber, background: `${brand.amber}14`, border: "none", borderRadius: 9, padding: "7px 14px", cursor: "pointer" }}>
              Review Now →
            </button>
          </div>
        )}

        {/* Filters */}
        <div style={{ display: "flex", gap: 10, marginBottom: 16, flexWrap: "wrap" as const }}>
          <div style={{ position: "relative", flex: 1, minWidth: 200 }}>
            <Search size={13} style={{ position: "absolute", left: 10, top: "50%", transform: "translateY(-50%)", color: brand.warmGray }} />
            <input value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Search title, author, department…"
              style={{ width: "100%", fontFamily: "Inter", fontSize: 13, background: brand.white, border: `1.5px solid ${brand.borderGray}`, borderRadius: 10, padding: "9px 10px 9px 30px", outline: "none", color: brand.charcoal, boxSizing: "border-box" as const }}
              onFocus={(e) => (e.target.style.borderColor = brand.orange)} onBlur={(e) => (e.target.style.borderColor = brand.borderGray)} />
          </div>
          <div style={{ display: "flex", gap: 6, flexWrap: "wrap" }}>
            {(["all", "course", "companion", "live", "article", "quiz"] as const).map((t) => (
              <button key={t} onClick={() => setTypeFilter(t)}
                style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: typeFilter === t ? "#fff" : brand.warmGray, background: typeFilter === t ? (t === "all" ? gradientFlow : typeColors[t].color) : brand.white, border: `1.5px solid ${typeFilter === t ? "transparent" : brand.borderGray}`, borderRadius: 20, padding: "5px 12px", cursor: "pointer", display: "flex", alignItems: "center", gap: 4 }}>
                {t !== "all" && typeColors[t].icon}{t === "all" ? "All Types" : typeColors[t].label}
              </button>
            ))}
          </div>
          <div style={{ display: "flex", gap: 6, flexWrap: "wrap" }}>
            {(["all", "published", "pending", "draft", "rejected"] as const).map((s) => (
              <button key={s} onClick={() => setStatusFilter(s)}
                style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: statusFilter === s ? "#fff" : brand.warmGray, background: statusFilter === s ? brand.charcoal : brand.white, border: `1.5px solid ${statusFilter === s ? brand.charcoal : brand.borderGray}`, borderRadius: 20, padding: "5px 12px", cursor: "pointer" }}>
                {s === "all" ? "All Status" : statusColors[s].label}
              </button>
            ))}
          </div>
        </div>

        {/* Table */}
        <div style={{ background: brand.white, borderRadius: 16, border: `1px solid ${brand.borderGray}`, overflow: "hidden" }}>
          <div style={{ display: "grid", gridTemplateColumns: "2.2fr 1fr 0.8fr 0.8fr 0.7fr 0.7fr 0.8fr 0.5fr", padding: "10px 20px", background: brand.offWhite, borderBottom: `1px solid ${brand.borderGray}` }}>
            {["Title", "Author", "Type", "Dept.", "Enrolled", "Rating", "Status", ""].map((h) => (
              <div key={h} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.05em" }}>{h}</div>
            ))}
          </div>

          {filtered.map((item, i) => (
            <div key={item.id} style={{ display: "grid", gridTemplateColumns: "2.2fr 1fr 0.8fr 0.8fr 0.7fr 0.7fr 0.8fr 0.5fr", padding: "13px 20px", borderBottom: i < filtered.length - 1 ? `1px solid ${brand.borderGray}` : "none", alignItems: "center", background: item.flagged ? "#FF2D3205" : "transparent" }}>
              {/* Title */}
              <div style={{ display: "flex", gap: 8, alignItems: "flex-start" }}>
                <div>
                  <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal, lineHeight: 1.3 }}>{item.title}</div>
                  <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{item.id} · Updated {item.updated}</div>
                  {item.flagged && <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 10, color: "#FF2D32", marginTop: 2 }}>⚠ Flagged</div>}
                </div>
              </div>
              {/* Author */}
              <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" as const }}>{item.author}</div>
              {/* Type */}
              <div>
                <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: typeColors[item.type].color, background: `${typeColors[item.type].color}12`, borderRadius: 6, padding: "3px 8px", display: "inline-flex", alignItems: "center", gap: 4 }}>
                  {typeColors[item.type].icon} {typeColors[item.type].label}
                </span>
              </div>
              {/* Dept */}
              <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.charcoal, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" as const }}>{item.department}</div>
              {/* Enrolled */}
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.charcoal }}>{item.enrolled > 0 ? item.enrolled.toLocaleString() : "—"}</div>
              {/* Rating */}
              <div style={{ fontFamily: "Inter", fontSize: 12, color: item.rating > 0 ? brand.amber : brand.borderGray }}>
                {item.rating > 0 ? `★ ${item.rating}` : "—"}
              </div>
              {/* Status + actions for pending */}
              <div style={{ display: "flex", flexDirection: "column" as const, gap: 6 }}>
                <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: statusColors[item.status].text, background: statusColors[item.status].bg, borderRadius: 6, padding: "3px 8px", display: "inline-flex", alignItems: "center", gap: 4, width: "fit-content" }}>
                  {statusColors[item.status].icon} {statusColors[item.status].label}
                </span>
                {item.status === "pending" && (
                  <div style={{ display: "flex", gap: 4 }}>
                    <button onClick={() => setApproving(item.id)}
                      style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 10, color: "#2D9B68", background: "#2D9B6812", border: "none", borderRadius: 6, padding: "4px 8px", cursor: "pointer" }}>✓ Approve</button>
                    <button style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 10, color: "#FF2D32", background: "#FF2D3212", border: "none", borderRadius: 6, padding: "4px 8px", cursor: "pointer" }}>✕ Reject</button>
                  </div>
                )}
              </div>
              {/* Menu */}
              <div style={{ position: "relative", display: "flex", justifyContent: "flex-end" }}>
                <button onClick={() => setActionMenu(actionMenu === item.id ? null : item.id)}
                  style={{ width: 28, height: 28, borderRadius: 8, background: brand.offWhite, border: "none", display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer" }}>
                  <MoreHorizontal size={14} color={brand.warmGray} />
                </button>
                {actionMenu === item.id && (
                  <div style={{ position: "absolute", top: 32, right: 0, zIndex: 50, background: brand.white, border: `1px solid ${brand.borderGray}`, borderRadius: 12, boxShadow: "0 8px 24px rgba(0,0,0,0.1)", padding: "8px", minWidth: 140 }}>
                    {[
                      { label: "View", icon: <Eye size={12} /> },
                      { label: "Edit", icon: <Edit2 size={12} /> },
                      { label: "Delete", icon: <Trash2 size={12} />, color: "#FF2D32" },
                    ].map((a) => (
                      <button key={a.label} onClick={() => setActionMenu(null)}
                        style={{ width: "100%", display: "flex", gap: 8, alignItems: "center", fontFamily: "Inter", fontSize: 12, color: a.color ?? brand.charcoal, background: "none", border: "none", borderRadius: 8, padding: "8px 10px", cursor: "pointer", textAlign: "left" as const }}
                        onMouseEnter={(e) => ((e.currentTarget as HTMLElement).style.background = brand.offWhite)}
                        onMouseLeave={(e) => ((e.currentTarget as HTMLElement).style.background = "transparent")}>
                        {a.icon} {a.label}
                      </button>
                    ))}
                  </div>
                )}
              </div>
            </div>
          ))}

          {filtered.length === 0 && (
            <div style={{ padding: "40px", textAlign: "center" as const, fontFamily: "Inter", fontSize: 13, color: brand.warmGray }}>
              No content matches your filters.
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
