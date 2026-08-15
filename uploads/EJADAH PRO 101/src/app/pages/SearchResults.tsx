import { useState, useMemo, useEffect, useRef } from "react";
import { useNavigate, useLocation } from "react-router";
import {
  Search, Clock, ChevronRight, X, BookOpen, FileText,
  GraduationCap, Stethoscope, Users, Microscope, Globe,
  LayoutDashboard, Award, Briefcase, FlaskConical, Library,
  Radio, Mic2, CreditCard, BellRing, ShieldCheck, Wand2,
} from "lucide-react";
import { brand, gradientFlow } from "@/app/shared";

// ─── All pages / sections in the app ─────────────────────────────────────────
const PAGE_INDEX = [
  // ── Home ──
  { title: "Home", desc: "Ejadah International Academy homepage", path: "/", category: "Navigation", icon: "🏠", keywords: ["home", "start", "main", "ejadah"] },
  { title: "Search", desc: "Search across all content and pages", path: "/search", category: "Navigation", icon: "🔍", keywords: ["search", "find", "look"] },
  { title: "Notifications", desc: "Your alerts and updates", path: "/notifications", category: "Navigation", icon: "🔔", keywords: ["notifications", "alerts", "updates"] },
  { title: "Accreditations", desc: "Ejadah accreditations and quality certifications", path: "/accreditations", category: "Navigation", icon: "🏛️", keywords: ["accreditation", "quality", "certification", "iso"] },

  // ── Learn ──
  { title: "Explore Courses", desc: "Browse all dental courses on Ejadah", path: "/courses", category: "Learn", icon: "📚", keywords: ["courses", "learn", "education", "browse"] },
  { title: "Course Detail", desc: "Sample course detail page", path: "/courses/1", category: "Learn", icon: "📖", keywords: ["course detail", "module"] },
  { title: "Course Player", desc: "Watch a course video lesson", path: "/courses/1/play", category: "Learn", icon: "▶️", keywords: ["play", "video", "watch", "lesson", "player"] },
  { title: "Handouts", desc: "Download course handouts and PDFs", path: "/courses/1/handouts", category: "Learn", icon: "📄", keywords: ["handouts", "pdf", "download", "notes"] },
  { title: "Flashcards", desc: "Study with course flashcards", path: "/courses/1/flashcards", category: "Learn", icon: "🃏", keywords: ["flashcards", "study", "memorize", "revision"] },
  { title: "Quiz", desc: "Course quiz and self-assessment", path: "/courses/1/quiz", category: "Learn", icon: "✏️", keywords: ["quiz", "test", "assessment", "questions"] },
  { title: "Course AI", desc: "AI-powered course assistant", path: "/courses/1/ai", category: "Learn", icon: "🤖", keywords: ["ai", "artificial intelligence", "assistant", "course ai"] },
  { title: "Live Academy", desc: "Live online dental training sessions", path: "/live", category: "Learn", icon: "📡", keywords: ["live", "academy", "online", "streaming", "webinar"] },
  { title: "Live Classroom", desc: "Join an active live classroom session", path: "/live/1/classroom", category: "Learn", icon: "🏥", keywords: ["live classroom", "session", "join", "attend"] },
  { title: "Clinical Demos", desc: "Watch clinical procedure demonstrations", path: "/live/clinical", category: "Learn", icon: "🎥", keywords: ["clinical", "demo", "demonstration", "procedure"] },
  { title: "Dental AI", desc: "AI-powered dental knowledge assistant", path: "/ai", category: "Learn", icon: "🧠", keywords: ["dental ai", "ai", "chatbot", "knowledge", "ask"] },

  // ── Exams ──
  { title: "Exam Hub", desc: "All licensing exams and preparation tools", path: "/exams", category: "Exams", icon: "📝", keywords: ["exams", "licensing", "preparation", "hub"] },
  { title: "EDLE Dashboard", desc: "Egyptian Dental Licensing Exam preparation", path: "/exams/edle", category: "Exams", icon: "🇪🇬", keywords: ["edle", "egyptian", "licensing", "dental", "egypt"] },
  { title: "Question Bank", desc: "Practice with 14,200+ EDLE questions", path: "/exams/edle/practice", category: "Exams", icon: "🗂️", keywords: ["question bank", "practice", "questions", "qbank"] },
  { title: "Mock Exam", desc: "Simulate a full EDLE exam session", path: "/exams/edle/mock", category: "Exams", icon: "⏱️", keywords: ["mock exam", "simulation", "full exam", "timed"] },
  { title: "Exam Analytics", desc: "Track your exam performance over time", path: "/exams/analytics", category: "Exams", icon: "📊", keywords: ["analytics", "performance", "stats", "progress", "tracking"] },
  { title: "Free Tests", desc: "Free sample tests — no account required", path: "/exams/free", category: "Exams", icon: "🆓", keywords: ["free", "tests", "sample", "trial", "demo"] },
  { title: "Certificates", desc: "Your earned certificates", path: "/certificates", category: "Exams", icon: "🎓", keywords: ["certificates", "awards", "completion", "diploma"] },
  { title: "Verify Certificate", desc: "Verify authenticity of an Ejadah certificate", path: "/verify", category: "Exams", icon: "✅", keywords: ["verify", "certificate", "authenticity", "check"] },

  // ── Services ──
  { title: "Tutoring", desc: "1-on-1 tutoring with dental specialists", path: "/tutoring", category: "Services", icon: "📐", keywords: ["tutoring", "tutor", "1-on-1", "private", "lesson"] },
  { title: "Tutor Profile", desc: "View a tutor's profile and availability", path: "/tutoring/1", category: "Services", icon: "👤", keywords: ["tutor profile", "tutor detail"] },
  { title: "Book a Tutor", desc: "Book a tutoring session", path: "/tutoring/1/book", category: "Services", icon: "📅", keywords: ["book tutor", "schedule", "appointment", "booking"] },
  { title: "Become a Tutor", desc: "Apply to teach on Ejadah", path: "/tutoring/become-a-tutor", category: "Services", icon: "🚀", keywords: ["become tutor", "teach", "apply", "onboarding", "earn"] },
  { title: "Mentoring", desc: "Career mentoring from experienced specialists", path: "/mentoring", category: "Services", icon: "🤝", keywords: ["mentoring", "mentor", "career advice", "guidance"] },
  { title: "Mentor Profile", desc: "View a mentor's profile", path: "/mentoring/1", category: "Services", icon: "👤", keywords: ["mentor profile"] },
  { title: "Consulting", desc: "Professional consulting for your dental career", path: "/consulting", category: "Services", icon: "💼", keywords: ["consulting", "consultant", "advice", "professional"] },
  { title: "Consultant Profile", desc: "View a consultant's profile", path: "/consulting/1", category: "Services", icon: "👤", keywords: ["consultant profile"] },
  { title: "Private Training", desc: "Hands-on private clinical training programmes", path: "/private-training", category: "Services", icon: "🏋️", keywords: ["private training", "hands-on", "clinical", "practical"] },

  // ── Career ──
  { title: "Career Abroad", desc: "Career pathways to 23 countries for Egyptian dentists", path: "/career", category: "Career", icon: "✈️", keywords: ["career", "abroad", "international", "migrate", "work", "country"] },
  { title: "My Roadmap", desc: "Build your personalised career roadmap", path: "/career/roadmap", category: "Career", icon: "🗺️", keywords: ["roadmap", "career plan", "personalised", "steps"] },
  { title: "UK Pathway", desc: "How to work as a dentist in the United Kingdom", path: "/career/uk", category: "Career", icon: "🇬🇧", keywords: ["uk", "united kingdom", "britain", "gdc", "ore", "nhs"] },
  { title: "UAE Pathway", desc: "How to work as a dentist in the UAE", path: "/career/uae", category: "Career", icon: "🇦🇪", keywords: ["uae", "dubai", "abu dhabi", "dha", "doh", "haad"] },
  { title: "KSA Pathway", desc: "How to work as a dentist in Saudi Arabia", path: "/career/ksa", category: "Career", icon: "🇸🇦", keywords: ["ksa", "saudi", "riyadh", "schs", "arabia"] },
  { title: "Germany Pathway", desc: "How to work as a dentist in Germany", path: "/career/germany", category: "Career", icon: "🇩🇪", keywords: ["germany", "german", "europe", "approbation"] },
  { title: "Australia Pathway", desc: "How to work as a dentist in Australia", path: "/career/australia", category: "Career", icon: "🇦🇺", keywords: ["australia", "ahpra", "melbourne", "sydney"] },
  { title: "Canada Pathway", desc: "How to work as a dentist in Canada", path: "/career/canada", category: "Career", icon: "🇨🇦", keywords: ["canada", "ndhcb", "toronto", "ontario"] },
  { title: "USA Pathway", desc: "How to work as a dentist in the United States", path: "/career/usa", category: "Career", icon: "🇺🇸", keywords: ["usa", "united states", "america", "nbde", "advanced standing"] },
  { title: "Ireland Pathway", desc: "How to work as a dentist in Ireland", path: "/career/ireland", category: "Career", icon: "🇮🇪", keywords: ["ireland", "irish", "dublin", "dental council ireland"] },
  { title: "Qatar Pathway", desc: "How to work as a dentist in Qatar", path: "/career/qatar", category: "Career", icon: "🇶🇦", keywords: ["qatar", "doha", "qchp"] },
  { title: "Kuwait Pathway", desc: "How to work as a dentist in Kuwait", path: "/career/kuwait", category: "Career", icon: "🇰🇼", keywords: ["kuwait", "kuwaiti"] },
  { title: "New Zealand Pathway", desc: "How to work as a dentist in New Zealand", path: "/career/new-zealand", category: "Career", icon: "🇳🇿", keywords: ["new zealand", "nzda", "auckland"] },
  { title: "Singapore Pathway", desc: "How to work as a dentist in Singapore", path: "/career/singapore", category: "Career", icon: "🇸🇬", keywords: ["singapore", "sdc", "asia"] },

  // ── Masters ──
  { title: "Master's Database", desc: "Browse 119+ postgraduate dental programmes worldwide", path: "/masters", category: "Masters", icon: "🎓", keywords: ["masters", "msc", "postgraduate", "pgd", "database", "programmes"] },
  { title: "King's College London — MSc Endodontology", desc: "Full hero profile: requirements, salary, GDC route, Egyptian syndicate", path: "/masters/1", category: "Masters", icon: "📋", keywords: ["kings", "kcl", "endodontology", "endodontics", "msc", "london", "guys hospital"] },
  { title: "Compare Programs", desc: "Side-by-side comparison of postgraduate programmes", path: "/masters/compare", category: "Masters", icon: "⚖️", keywords: ["compare", "comparison", "programs", "side by side"] },

  // ── Knowledge ──
  { title: "Research Hub", desc: "Latest dental research and systematic reviews", path: "/research", category: "Knowledge", icon: "🔬", keywords: ["research", "papers", "journals", "systematic review", "evidence"] },
  { title: "Research Details", desc: "View a research paper in detail", path: "/research/1", category: "Knowledge", icon: "📄", keywords: ["research detail", "paper detail"] },
  { title: "Dental Library", desc: "Textbooks and reference materials for dentists", path: "/library", category: "Knowledge", icon: "📚", keywords: ["library", "textbooks", "books", "reference", "reading"] },
  { title: "Book Details", desc: "View a library book in detail", path: "/library/1", category: "Knowledge", icon: "📖", keywords: ["book detail", "textbook"] },
  { title: "Community", desc: "Connect and discuss with dental professionals worldwide", path: "/community", category: "Knowledge", icon: "👥", keywords: ["community", "forum", "discussion", "peers", "network"] },
  { title: "Achievements", desc: "Your badges, streaks, and milestones", path: "/achievements", category: "Knowledge", icon: "🏆", keywords: ["achievements", "badges", "gamification", "points", "streak"] },

  // ── Account ──
  { title: "Dashboard", desc: "Your personal learning dashboard", path: "/dashboard", category: "Account", icon: "📋", keywords: ["dashboard", "overview", "my account", "home"] },
  { title: "My Profile", desc: "Your public NFC dental profile", path: "/profile/1", category: "Account", icon: "👤", keywords: ["profile", "nfc", "public", "my profile"] },
  { title: "Edit Profile", desc: "Update your profile details", path: "/profile/edit", category: "Account", icon: "✏️", keywords: ["edit profile", "update", "settings"] },
  { title: "NFC Card", desc: "Your digital NFC business card", path: "/profile/card", category: "Account", icon: "📇", keywords: ["nfc card", "business card", "digital"] },
  { title: "Membership", desc: "Upgrade your Ejadah membership plan", path: "/membership", category: "Account", icon: "💳", keywords: ["membership", "subscription", "upgrade", "plan", "premium"] },
  { title: "Checkout", desc: "Complete your purchase", path: "/checkout", category: "Account", icon: "🛒", keywords: ["checkout", "payment", "buy", "purchase"] },
  { title: "Instructor Dashboard", desc: "Manage your courses as an instructor", path: "/instructor", category: "Account", icon: "👩‍🏫", keywords: ["instructor", "teacher", "create course", "dashboard"] },
  { title: "Tutor Earnings", desc: "Track your tutoring income and sessions", path: "/tutor/earnings", category: "Account", icon: "💰", keywords: ["tutor earnings", "income", "revenue", "sessions", "money"] },
  { title: "Sign In", desc: "Log in to your Ejadah account", path: "/login", category: "Account", icon: "🔐", keywords: ["login", "sign in", "log in", "account"] },
  { title: "Register", desc: "Create a new Ejadah account", path: "/register", category: "Account", icon: "📋", keywords: ["register", "sign up", "create account", "join"] },
  { title: "Onboarding", desc: "Complete your Ejadah account setup", path: "/onboarding", category: "Account", icon: "🚀", keywords: ["onboarding", "setup", "get started"] },

  // ── System ──
  { title: "Admin Dashboard", desc: "Platform administration and analytics", path: "/admin", category: "System", icon: "⚙️", keywords: ["admin", "administration", "manage", "platform"] },
  { title: "Brand Guide", desc: "Ejadah visual identity and brand guidelines", path: "/brand", category: "System", icon: "🎨", keywords: ["brand", "design", "colors", "identity"] },
  { title: "Design System", desc: "UI components and design tokens", path: "/design-system", category: "System", icon: "🧩", keywords: ["design system", "components", "ui", "tokens"] },
  { title: "RTL Demo", desc: "Right-to-left language layout demonstration", path: "/rtl-demo", category: "System", icon: "🌐", keywords: ["rtl", "arabic", "right to left", "demo"] },
];

const CATEGORY_META: Record<string, { icon: React.ReactNode; color: string }> = {
  Navigation: { icon: <Globe size={14} />, color: brand.warmGray },
  Learn:       { icon: <BookOpen size={14} />, color: brand.orange },
  Exams:       { icon: <FileText size={14} />, color: brand.red },
  Services:    { icon: <Briefcase size={14} />, color: brand.amber },
  Career:      { icon: <Globe size={14} />, color: "#2D9B68" },
  Masters:     { icon: <GraduationCap size={14} />, color: "#496FA8" },
  Knowledge:   { icon: <FlaskConical size={14} />, color: "#8B5CF6" },
  Account:     { icon: <LayoutDashboard size={14} />, color: brand.charcoal },
  System:      { icon: <ShieldCheck size={14} />, color: brand.warmGray },
};

const ALL_CATEGORIES = ["All", ...Object.keys(CATEGORY_META)];

function score(item: typeof PAGE_INDEX[0], q: string): number {
  const lower = q.toLowerCase().trim();
  if (!lower) return 1;
  const title = item.title.toLowerCase();
  const desc = item.desc.toLowerCase();
  const cat = item.category.toLowerCase();
  const kw = item.keywords.join(" ");
  if (title === lower) return 100;
  if (title.startsWith(lower)) return 80;
  if (title.includes(lower)) return 60;
  if (kw.includes(lower)) return 40;
  if (desc.includes(lower)) return 20;
  if (cat.includes(lower)) return 10;
  // partial word match
  const words = lower.split(" ");
  const hits = words.filter((w) => title.includes(w) || kw.includes(w) || desc.includes(w)).length;
  return hits > 0 ? hits * 5 : 0;
}

const RECENT_KEY = "ejadah_recent_searches";
function getRecent(): string[] {
  try { return JSON.parse(localStorage.getItem(RECENT_KEY) ?? "[]"); } catch { return []; }
}
function pushRecent(q: string) {
  if (!q.trim()) return;
  const prev = getRecent().filter((r) => r !== q).slice(0, 6);
  localStorage.setItem(RECENT_KEY, JSON.stringify([q, ...prev]));
}

export default function SearchResults() {
  const nav = useNavigate();
  const location = useLocation();
  const inputRef = useRef<HTMLInputElement>(null);

  const [query, setQuery] = useState(() => {
    const params = new URLSearchParams(location.search);
    return params.get("q") ?? "";
  });
  const [category, setCategory] = useState("All");
  const [recent, setRecent] = useState<string[]>(getRecent);
  const [focused, setFocused] = useState(false);

  useEffect(() => { inputRef.current?.focus(); }, []);

  const filtered = useMemo(() => {
    return PAGE_INDEX
      .filter((item) => category === "All" || item.category === category)
      .map((item) => ({ item, s: score(item, query) }))
      .filter(({ s }) => s > 0)
      .sort((a, b) => b.s - a.s)
      .map(({ item }) => item);
  }, [query, category]);

  // Group by category for "All" view
  const grouped = useMemo(() => {
    if (category !== "All" || !query.trim()) return null;
    const map: Record<string, typeof PAGE_INDEX> = {};
    filtered.forEach((item) => {
      if (!map[item.category]) map[item.category] = [];
      map[item.category].push(item);
    });
    return map;
  }, [filtered, category, query]);

  function handleNavigate(path: string) {
    pushRecent(query);
    setRecent(getRecent());
    nav(path);
  }

  function handleSearch(q: string) {
    setQuery(q);
  }

  function clearRecent() {
    localStorage.removeItem(RECENT_KEY);
    setRecent([]);
  }

  const catMeta = (cat: string) => CATEGORY_META[cat] ?? { icon: <BookOpen size={14} />, color: brand.orange };

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>

      {/* ── Search bar ── */}
      <div style={{ background: brand.charcoal, padding: "32px 24px 28px" }}>
        <div style={{ maxWidth: 760, margin: "0 auto" }}>
          <div style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.35)", marginBottom: 14, letterSpacing: "0.05em" }}>
            SEARCH — {PAGE_INDEX.length} pages & sections indexed
          </div>
          <div style={{ position: "relative" }}>
            <Search size={18} style={{ position: "absolute", left: 16, top: "50%", transform: "translateY(-50%)", color: focused ? brand.orange : "rgba(255,255,255,0.4)", transition: "color 0.15s" }} />
            <input
              ref={inputRef}
              value={query}
              onChange={(e) => handleSearch(e.target.value)}
              onFocus={() => setFocused(true)}
              onBlur={() => setFocused(false)}
              onKeyDown={(e) => { if (e.key === "Enter" && filtered.length > 0) handleNavigate(filtered[0].path); }}
              placeholder="Type a page name, topic, or keyword…"
              style={{ width: "100%", fontFamily: "Inter", fontSize: 16, color: "#fff", background: "rgba(255,255,255,0.1)", border: `1.5px solid ${focused ? brand.orange : "rgba(255,255,255,0.15)"}`, borderRadius: 14, padding: "14px 48px", outline: "none", boxSizing: "border-box" as const, transition: "border-color 0.15s" }}
            />
            {query && (
              <button onClick={() => setQuery("")} style={{ position: "absolute", right: 14, top: "50%", transform: "translateY(-50%)", background: "none", border: "none", cursor: "pointer", color: "rgba(255,255,255,0.4)", display: "flex", alignItems: "center" }}>
                <X size={16} />
              </button>
            )}
          </div>
          <div style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.35)", marginTop: 10 }}>
            {query
              ? <>{filtered.length} result{filtered.length !== 1 ? "s" : ""} for "<span style={{ color: "rgba(255,255,255,0.65)" }}>{query}</span>" · Press Enter to open first result</>
              : "Start typing to search all pages and content"}
          </div>
        </div>
      </div>

      {/* ── Category pills ── */}
      <div style={{ background: brand.white, borderBottom: `1px solid ${brand.borderGray}`, overflowX: "auto" as const }}>
        <div style={{ maxWidth: 760, margin: "0 auto", padding: "10px 24px", display: "flex", gap: 7, flexWrap: "nowrap" as const }}>
          {ALL_CATEGORIES.map((c) => {
            const meta = CATEGORY_META[c];
            const active = category === c;
            return (
              <button key={c} onClick={() => setCategory(c)}
                style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 12, color: active ? "#fff" : brand.charcoal, background: active ? gradientFlow : brand.offWhite, border: `1.5px solid ${active ? "transparent" : brand.borderGray}`, borderRadius: 20, padding: "5px 14px", cursor: "pointer", transition: "all 0.15s", whiteSpace: "nowrap" as const, display: "flex", alignItems: "center", gap: 5, flexShrink: 0 }}>
                {meta && <span style={{ opacity: active ? 1 : 0.5 }}>{meta.icon}</span>} {c}
              </button>
            );
          })}
        </div>
      </div>

      <div style={{ maxWidth: 760, margin: "0 auto", padding: "24px 24px 60px" }}>

        {/* ── Empty state — show suggestions ── */}
        {!query && (
          <>
            {recent.length > 0 && (
              <div style={{ marginBottom: 28 }}>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 12 }}>
                  <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em", display: "flex", gap: 6, alignItems: "center" }}>
                    <Clock size={12} /> Recent
                  </div>
                  <button onClick={clearRecent} style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, background: "none", border: "none", cursor: "pointer" }}>Clear</button>
                </div>
                <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
                  {recent.map((r) => (
                    <button key={r} onClick={() => setQuery(r)} style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, background: brand.white, border: `1.5px solid ${brand.borderGray}`, borderRadius: 20, padding: "5px 14px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}>
                      <Clock size={11} color={brand.warmGray} /> {r}
                    </button>
                  ))}
                </div>
              </div>
            )}

            {/* Quick-access grid: one button per category */}
            <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em", marginBottom: 14 }}>Browse by section</div>
            <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(160px, 1fr))", gap: 10, marginBottom: 28 }}>
              {Object.entries(CATEGORY_META).map(([cat, meta]) => {
                const count = PAGE_INDEX.filter((p) => p.category === cat).length;
                return (
                  <button key={cat} onClick={() => setCategory(cat)}
                    style={{ background: brand.white, border: `1.5px solid ${brand.borderGray}`, borderRadius: 14, padding: "14px 16px", cursor: "pointer", textAlign: "left" as const, transition: "border-color 0.15s, box-shadow 0.15s" }}
                    onMouseEnter={(e) => { (e.currentTarget as HTMLElement).style.borderColor = meta.color; (e.currentTarget as HTMLElement).style.boxShadow = `0 4px 12px ${meta.color}18`; }}
                    onMouseLeave={(e) => { (e.currentTarget as HTMLElement).style.borderColor = brand.borderGray; (e.currentTarget as HTMLElement).style.boxShadow = "none"; }}
                  >
                    <div style={{ color: meta.color, marginBottom: 8 }}>{meta.icon}</div>
                    <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal }}>{cat}</div>
                    <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginTop: 2 }}>{count} pages</div>
                  </button>
                );
              })}
            </div>

            {/* Show all pages when a category is selected via pill */}
          </>
        )}

        {/* ── Results ── */}
        {query && filtered.length === 0 && (
          <div style={{ textAlign: "center" as const, padding: "60px 0" }}>
            <div style={{ fontSize: 40, marginBottom: 16 }}>🔍</div>
            <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.charcoal, marginBottom: 8 }}>No results for "{query}"</div>
            <div style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, marginBottom: 24 }}>Try a different keyword — or browse by section above.</div>
            <button onClick={() => setQuery("")} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "10px 22px", cursor: "pointer" }}>Clear search</button>
          </div>
        )}

        {/* Grouped results (query + All category) */}
        {query && grouped && Object.entries(grouped).map(([cat, items]) => (
          <div key={cat} style={{ marginBottom: 28 }}>
            <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 12 }}>
              <span style={{ color: catMeta(cat).color }}>{catMeta(cat).icon}</span>
              <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: catMeta(cat).color, textTransform: "uppercase" as const, letterSpacing: "0.06em" }}>{cat}</span>
              <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.borderGray }}>· {items.length}</span>
            </div>
            <div style={{ display: "flex", flexDirection: "column" as const, gap: 7 }}>
              {items.map((item) => <PageResultCard key={item.path} item={item} query={query} onNavigate={handleNavigate} />)}
            </div>
          </div>
        ))}

        {/* Flat results (specific category selected) */}
        {(query && !grouped) || (!query && category !== "All") ? (
          <div style={{ display: "flex", flexDirection: "column" as const, gap: 7 }}>
            {(query ? filtered : PAGE_INDEX.filter((p) => category === "All" || p.category === category)).map((item) => (
              <PageResultCard key={item.path} item={item} query={query} onNavigate={handleNavigate} />
            ))}
          </div>
        ) : null}

        {/* Show all pages when no query and no specific category */}
        {!query && category === "All" && (
          <div>
            <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em", marginBottom: 14 }}>All pages ({PAGE_INDEX.length})</div>
            <div style={{ display: "flex", flexDirection: "column" as const, gap: 7 }}>
              {PAGE_INDEX.map((item) => (
                <PageResultCard key={item.path} item={item} query="" onNavigate={handleNavigate} />
              ))}
            </div>
          </div>
        )}

      </div>
    </div>
  );
}

// ─── Result card ──────────────────────────────────────────────────────────────
function highlight(text: string, query: string): React.ReactNode {
  if (!query.trim()) return text;
  const idx = text.toLowerCase().indexOf(query.toLowerCase());
  if (idx === -1) return text;
  return (
    <>
      {text.slice(0, idx)}
      <mark style={{ background: `${brand.amber}40`, color: "inherit", borderRadius: 2, padding: "0 1px" }}>{text.slice(idx, idx + query.length)}</mark>
      {text.slice(idx + query.length)}
    </>
  );
}

function PageResultCard({ item, query, onNavigate }: { item: typeof PAGE_INDEX[0]; query: string; onNavigate: (p: string) => void }) {
  const meta = CATEGORY_META[item.category] ?? { icon: <BookOpen size={14} />, color: brand.orange };
  return (
    <div
      onClick={() => onNavigate(item.path)}
      role="button"
      tabIndex={0}
      onKeyDown={(e) => e.key === "Enter" && onNavigate(item.path)}
      style={{ background: brand.white, borderRadius: 14, border: `1.5px solid ${brand.borderGray}`, padding: "13px 16px", cursor: "pointer", display: "flex", gap: 14, alignItems: "center", transition: "all 0.12s" }}
      onMouseEnter={(e) => { const el = e.currentTarget as HTMLElement; el.style.borderColor = meta.color; el.style.boxShadow = `0 4px 14px ${meta.color}15`; el.style.transform = "translateX(3px)"; }}
      onMouseLeave={(e) => { const el = e.currentTarget as HTMLElement; el.style.borderColor = brand.borderGray; el.style.boxShadow = "none"; el.style.transform = "none"; }}
    >
      <div style={{ width: 38, height: 38, borderRadius: 10, background: `${meta.color}12`, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0, fontSize: 18 }}>
        {item.icon}
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 2, flexWrap: "wrap" }}>
          <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.charcoal }}>{highlight(item.title, query)}</span>
          <span style={{ fontFamily: "Inter", fontSize: 10, fontWeight: 700, color: meta.color, background: `${meta.color}12`, borderRadius: 4, padding: "1px 6px", flexShrink: 0 }}>{item.category}</span>
        </div>
        <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" as const }}>{highlight(item.desc, query)}</div>
      </div>
      <div style={{ display: "flex", alignItems: "center", gap: 4, flexShrink: 0 }}>
        <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.borderGray }}>{item.path}</span>
        <ChevronRight size={14} color={brand.borderGray} />
      </div>
    </div>
  );
}
