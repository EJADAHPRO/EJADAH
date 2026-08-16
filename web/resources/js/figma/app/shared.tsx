import { useState, useEffect, useRef } from "react";
import { Link, useLocation, useNavigate } from "react-router";
import ejadahLogo from "@/figma/imports/Ejadah-Icon__1_.jpg";
import {
  Search, Bell, Globe, ChevronDown, ArrowRight, Play, Star, Clock,
  Users, Award, Bookmark, CheckCircle, MapPin, Menu, X, Sparkles, Radio,
  LogOut, LayoutDashboard, User, BookOpen as BookOpenIcon,
} from "lucide-react";
import { useAuth, userInitials, roleLabels } from "@/figma/app/auth";

// ─── Brand Tokens ────────────────────────────────────────────────────────────
export const brand = {
  red: "#FF2D32",
  orange: "#FF6B1A",
  amber: "#FFAA18",
  gold: "#FFC62E",
  offWhite: "#FFF9EF",
  white: "#FFFFFF",
  paleGray: "#F5F2EC",
  borderGray: "#E7E2DA",
  warmGray: "#716D67",
  charcoal: "#1B1B1B",
  deepCharcoal: "#121212",
};

export const gradientFlow = `linear-gradient(135deg, ${brand.red} 0%, ${brand.orange} 50%, ${brand.gold} 100%)`;
export const gradientGlow = `linear-gradient(135deg, ${brand.orange} 0%, ${brand.amber} 60%, ${brand.gold} 100%)`;

// ─── Egyptian Dental Universities (canonical list) ────────────────────────────
export const EG_DENTAL_UNIVERSITIES = [
  // Government Universities
  "Cairo University",
  "Alexandria University",
  "Ain Shams University",
  "Mansoura University",
  "Tanta University",
  "Assiut University",
  "Suez Canal University",
  "Zagazig University",
  "Minia University",
  "Fayoum University",
  "Beni Suef University",
  "Kafrelsheikh University",
  "South Valley University - Qena",
  "Menoufia University",
  "Benha University",
  "Sohag University",
  // Al-Azhar
  "Al-Azhar University - Dental Medicine Boys Cairo",
  "Al-Azhar University - Dental Medicine Girls Cairo",
  "Al-Azhar University - Dental Medicine Boys Assiut",
  // Private Universities
  "6th of October University",
  "Misr University for Science and Technology (MUST)",
  "Misr International University (MIU)",
  "October University for Modern Sciences and Arts (MSA)",
  "Ahram Canadian University",
  "The British University in Egypt (BUE)",
  "Modern University for Technology and Information (MTI)",
  "Future University in Egypt (FUE)",
  "Pharos University in Alexandria",
  "Nahda University",
  "Delta University for Science and Technology",
  "Egyptian Russian University",
  "Badr University in Cairo",
  "Badr University in Assiut",
  "New Giza University",
  "Deraya University",
  "Horus University",
  "Sphinx University",
  "Sinai University - Arish Campus",
  "Sinai University - Qantara Campus",
  "Al-Ryada University for Science and Technology",
  "Arab Academy for Science, Technology & Maritime Transport - El Alamein",
  // New Administrative Capital & New Cities
  "Galala University",
  "King Salman International University",
  "New Mansoura University",
  "Alamein International University",
  "Alexandria National University",
  "Assiut National University",
  "Benha National University",
  "Minia National University",
  "Suez National University",
  "Cairo National University",
  "Ain Shams National University",
  "Tanta National University",
] as const;

// ─── Logo ────────────────────────────────────────────────────────────────────
export function EjadahMark({ size = 40 }: { size?: number }) {
  return (
    <img
      src={ejadahLogo}
      alt="Ejadah mark"
      style={{ width: size, height: size, objectFit: "contain", borderRadius: 6 }}
    />
  );
}

export function EjadahWordmark({ light = false }: { light?: boolean }) {
  return (
    <div className="flex items-center gap-2.5">
      <EjadahMark size={38} />
      <div style={{ lineHeight: 1.15 }}>
        <div style={{ fontFamily: "Inter,sans-serif", fontWeight: 700, fontSize: 13, letterSpacing: "0.08em", color: light ? brand.white : brand.charcoal }}>
          EJADAH
        </div>
        <div style={{ fontFamily: "Inter,sans-serif", fontWeight: 400, fontSize: 10, letterSpacing: "0.06em", color: light ? "rgba(255,255,255,0.65)" : brand.warmGray }}>
          INTERNATIONAL ACADEMY
        </div>
      </div>
    </div>
  );
}

// ─── Shared UI primitives ────────────────────────────────────────────────────
export function GradientBadge({ children, small }: { children: React.ReactNode; small?: boolean }) {
  return (
    <span style={{ background: gradientFlow, color: "#fff", fontFamily: "Inter,sans-serif", fontWeight: 600, fontSize: small ? 10 : 11, letterSpacing: "0.06em", padding: small ? "2px 8px" : "3px 10px", borderRadius: 20, display: "inline-flex", alignItems: "center", gap: 4, whiteSpace: "nowrap" }}>
      {children}
    </span>
  );
}

export function LiveBadge() {
  return (
    <span style={{ background: brand.red, color: "#fff", fontFamily: "Inter,sans-serif", fontWeight: 700, fontSize: 10, letterSpacing: "0.08em", padding: "3px 8px", borderRadius: 4, display: "inline-flex", alignItems: "center", gap: 5 }}>
      <span style={{ width: 6, height: 6, borderRadius: "50%", background: "#fff", animation: "pulse 1.5s infinite", flexShrink: 0 }} />
      LIVE
    </span>
  );
}

export function StarRating({ rating, count }: { rating: number; count?: number }) {
  return (
    <div className="flex items-center gap-1">
      <div className="flex">
        {[1, 2, 3, 4, 5].map((i) => (
          <Star key={i} size={12} fill={i <= Math.round(rating) ? brand.amber : "none"} color={i <= Math.round(rating) ? brand.amber : brand.borderGray} />
        ))}
      </div>
      <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>{rating.toFixed(1)}{count ? ` (${count.toLocaleString()})` : ""}</span>
    </div>
  );
}

export function ProgressPath({ percent }: { percent: number }) {
  return (
    <div style={{ background: brand.borderGray, borderRadius: 4, height: 6, overflow: "hidden" }}>
      <div style={{ height: "100%", width: `${percent}%`, background: gradientFlow, borderRadius: 4, transition: "width 0.6s ease" }} />
    </div>
  );
}

export function SectionHeader({ label, title, subtitle, action, onAction }: { label?: string; title: string; subtitle?: string; action?: string; onAction?: () => void }) {
  return (
    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-end", marginBottom: 28 }}>
      <div>
        {label && <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, letterSpacing: "0.1em", color: brand.orange, textTransform: "uppercase" as const, marginBottom: 8 }}>{label}</div>}
        <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(22px,3vw,30px)", color: brand.charcoal, lineHeight: 1.2 }}>{title}</h2>
        {subtitle && <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, marginTop: 6, maxWidth: 480 }}>{subtitle}</p>}
      </div>
      {action && (
        <button onClick={onAction} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 13, color: brand.orange, background: "none", border: "none", cursor: "pointer", display: "flex", alignItems: "center", gap: 4, whiteSpace: "nowrap" as const, flexShrink: 0 }}>
          {action} <ArrowRight size={14} />
        </button>
      )}
    </div>
  );
}

// ─── Mega-menu data ───────────────────────────────────────────────────────────
const megaNav = [
  {
    label: "Learn",
    sections: [
      { heading: "Courses", links: [["Explore Courses", "/courses"], ["Course Details", "/courses/1"], ["Course Player", "/courses/1/play"], ["Handouts", "/courses/1/handouts"], ["Flashcards", "/courses/1/flashcards"], ["Quiz", "/courses/1/quiz"], ["Course AI", "/courses/1/ai"]] },
      { heading: "Live", links: [["Live Academy", "/live"], ["Live Classroom", "/live/1/classroom"], ["Clinical Demos", "/live/clinical"]] },
    ],
  },
  {
    label: "Exams",
    sections: [
      { heading: "Licensing Exams", links: [["Exam Hub", "/exams"], ["EDLE Dashboard", "/exams/edle"], ["Question Bank", "/exams/edle/practice"], ["Mock Exam", "/exams/edle/mock"]] },
      { heading: "Tools", links: [["Exam Analytics", "/exams/analytics"], ["Free Tests", "/exams/free"], ["Certificate Center", "/certificates"], ["Verify Certificate", "/verify"]] },
    ],
  },
  {
    label: "Services",
    sections: [
      { heading: "1-on-1", links: [["Tutoring", "/tutoring"], ["Tutor Profile", "/tutoring/1"], ["Book a Tutor", "/tutoring/1/book"], ["Become a Tutor", "/tutoring/become-a-tutor"]] },
      { heading: "More Services", links: [["Mentoring", "/mentoring"], ["Mentor Profile", "/mentoring/1"], ["Consulting", "/consulting"], ["Consultant Profile", "/consulting/1"], ["Private Training", "/private-training"]] },
    ],
  },
  {
    label: "Career",
    sections: [
      { heading: "Abroad", links: [["Career Abroad", "/career"], ["UK Pathway", "/career/uk"], ["UAE Pathway", "/career/uae"], ["My Roadmap", "/career/roadmap"]] },
      { heading: "Postgraduate", links: [["Master's Database", "/masters"], ["Program Details", "/masters/1"]] },
    ],
  },
  {
    label: "Community",
    sections: [
      { heading: "Connect", links: [["Community Feed", "/community"], ["Dental AI", "/ai"]] },
      { heading: "My Account", links: [["Dashboard", "/dashboard"], ["Certificates", "/certificates"]] },
    ],
  },
  {
    label: "Knowledge",
    sections: [
      { heading: "Research", links: [["Research Hub", "/research"], ["Research Details", "/research/1"]] },
      { heading: "Study Companions", links: [["Study Companions", "/library"], ["Endodontics Companion", "/library/1"], ["Orthodontics Companion", "/library/3"]] },
    ],
  },
];

// Flat mobile links covering every built page
const allMobileLinks = [
  ["🏠 Home", "/"],
  ["📚 Courses", "/courses"],
  ["▶️ Course Player", "/courses/1/play"],
  ["📄 Handouts", "/courses/1/handouts"],
  ["🃏 Flashcards", "/courses/1/flashcards"],
  ["✏️ Quiz", "/courses/1/quiz"],
  ["🤖 Course AI", "/courses/1/ai"],
  ["📡 Live Academy", "/live"],
  ["🏥 Live Classroom", "/live/1/classroom"],
  ["🎥 Clinical Demos", "/live/clinical"],
  ["📝 Exam Hub", "/exams"],
  ["🇪🇬 EDLE Dashboard", "/exams/edle"],
  ["🗂️ Question Bank", "/exams/edle/practice"],
  ["⏱️ Mock Exam", "/exams/edle/mock"],
  ["📊 Exam Analytics", "/exams/analytics"],
  ["🆓 Free Tests", "/exams/free"],
  ["🎓 Certificates", "/certificates"],
  ["✅ Verify Cert", "/verify"],
  ["👥 Community", "/community"],
  ["🧠 Dental AI", "/ai"],
  ["📋 Dashboard", "/dashboard"],
  ["📐 Tutoring", "/tutoring"],
  ["👤 Tutor Profile", "/tutoring/1"],
  ["📅 Book Tutor", "/tutoring/1/book"],
  ["🚀 Become Tutor", "/tutoring/become-a-tutor"],
  ["🤝 Mentoring", "/mentoring"],
  ["👤 Mentor Profile", "/mentoring/1"],
  ["💼 Consulting", "/consulting"],
  ["👤 Consultant", "/consulting/1"],
  ["🏋️ Private Training", "/private-training"],
  ["✈️ Career Abroad", "/career"],
  ["🇬🇧 UK Pathway", "/career/uk"],
  ["🇦🇪 UAE Pathway", "/career/uae"],
  ["🗺️ My Roadmap", "/career/roadmap"],
  ["🎓 Master's DB", "/masters"],
  ["📋 Program Details", "/masters/1"],
  ["🔬 Research Hub", "/research"],
  ["📄 Research Details", "/research/1"],
  ["📚 Study Companions", "/library"],
  ["🦷 Endodontics Companion", "/library/1"],
  ["🔬 Orthodontics Companion", "/library/3"],
  ["🏆 Achievements", "/achievements"],
  ["👩‍🏫 Instructor Dashboard", "/instructor"],
  ["💰 Tutor Earnings", "/tutor/earnings"],
  ["🔐 Login", "/login"],
  ["📋 Register", "/register"],
  ["🚀 Onboarding", "/onboarding"],
  ["💳 Membership", "/membership"],
  ["🛒 Checkout", "/checkout"],
  ["🔔 Notifications", "/notifications"],
  ["🔍 Search", "/search"],
  ["🏛️ Accreditations", "/accreditations"],
  ["👤 NFC Profile", "/profile/1"],
  ["✏️ Edit Profile", "/profile/edit"],
  ["📇 NFC Card", "/profile/card"],
  ["⚙️ Admin", "/admin"],
  ["🎨 Brand Guide", "/brand"],
  ["🧩 Design System", "/design-system"],
  ["🌐 RTL Demo", "/rtl-demo"],
  ["📊 Compare Programs", "/masters/compare"],
];

// ─── Inline search index (all pages) ─────────────────────────────────────────
const SEARCH_INDEX = [
  { icon: "🏠", label: "Home", path: "/" },
  { icon: "🔔", label: "Notifications", path: "/notifications" },
  { icon: "🏛️", label: "Accreditations", path: "/accreditations" },
  { icon: "📚", label: "Explore Courses", path: "/courses" },
  { icon: "📖", label: "Course Detail", path: "/courses/1" },
  { icon: "▶️", label: "Course Player", path: "/courses/1/play" },
  { icon: "📄", label: "Handouts", path: "/courses/1/handouts" },
  { icon: "🃏", label: "Flashcards", path: "/courses/1/flashcards" },
  { icon: "✏️", label: "Quiz", path: "/courses/1/quiz" },
  { icon: "🤖", label: "Course AI", path: "/courses/1/ai" },
  { icon: "📡", label: "Live Academy", path: "/live" },
  { icon: "🏥", label: "Live Classroom", path: "/live/1/classroom" },
  { icon: "🎥", label: "Clinical Demos", path: "/live/clinical" },
  { icon: "🧠", label: "Dental AI", path: "/ai" },
  { icon: "📝", label: "Exam Hub", path: "/exams" },
  { icon: "🇪🇬", label: "EDLE Dashboard", path: "/exams/edle" },
  { icon: "🗂️", label: "Question Bank", path: "/exams/edle/practice" },
  { icon: "⏱️", label: "Mock Exam", path: "/exams/edle/mock" },
  { icon: "📊", label: "Exam Analytics", path: "/exams/analytics" },
  { icon: "🆓", label: "Free Tests", path: "/exams/free" },
  { icon: "🎓", label: "Certificates", path: "/certificates" },
  { icon: "✅", label: "Verify Certificate", path: "/verify" },
  { icon: "📐", label: "Tutoring", path: "/tutoring" },
  { icon: "👤", label: "Tutor Profile", path: "/tutoring/1" },
  { icon: "📅", label: "Book a Tutor", path: "/tutoring/1/book" },
  { icon: "🚀", label: "Become a Tutor", path: "/tutoring/become-a-tutor" },
  { icon: "🤝", label: "Mentoring", path: "/mentoring" },
  { icon: "👤", label: "Mentor Profile", path: "/mentoring/1" },
  { icon: "💼", label: "Consulting", path: "/consulting" },
  { icon: "👤", label: "Consultant Profile", path: "/consulting/1" },
  { icon: "🏋️", label: "Private Training", path: "/private-training" },
  { icon: "✈️", label: "Career Abroad", path: "/career" },
  { icon: "🗺️", label: "My Roadmap", path: "/career/roadmap" },
  { icon: "🇬🇧", label: "UK Pathway", path: "/career/uk" },
  { icon: "🇦🇪", label: "UAE Pathway", path: "/career/uae" },
  { icon: "🇸🇦", label: "KSA Pathway", path: "/career/ksa" },
  { icon: "🇩🇪", label: "Germany Pathway", path: "/career/germany" },
  { icon: "🇦🇺", label: "Australia Pathway", path: "/career/australia" },
  { icon: "🇨🇦", label: "Canada Pathway", path: "/career/canada" },
  { icon: "🇺🇸", label: "USA Pathway", path: "/career/usa" },
  { icon: "🇮🇪", label: "Ireland Pathway", path: "/career/ireland" },
  { icon: "🇶🇦", label: "Qatar Pathway", path: "/career/qatar" },
  { icon: "🇰🇼", label: "Kuwait Pathway", path: "/career/kuwait" },
  { icon: "🇳🇿", label: "New Zealand Pathway", path: "/career/new-zealand" },
  { icon: "🇸🇬", label: "Singapore Pathway", path: "/career/singapore" },
  { icon: "🎓", label: "Master's Database", path: "/masters" },
  { icon: "📋", label: "King's MSc Endodontology", path: "/masters/1" },
  { icon: "⚖️", label: "Compare Programs", path: "/masters/compare" },
  { icon: "🔬", label: "Research Hub", path: "/research" },
  { icon: "📚", label: "Study Companions", path: "/library" },
  { icon: "👥", label: "Community", path: "/community" },
  { icon: "🏆", label: "Achievements", path: "/achievements" },
  { icon: "📋", label: "Dashboard", path: "/dashboard" },
  { icon: "📅", label: "My Bookings", path: "/bookings" },
  { icon: "👤", label: "My Profile", path: "/profile/1" },
  { icon: "✏️", label: "Edit Profile", path: "/profile/edit" },
  { icon: "📇", label: "NFC Card", path: "/profile/card" },
  { icon: "💳", label: "Membership", path: "/membership" },
  { icon: "🛒", label: "Checkout", path: "/checkout" },
  { icon: "👩‍🏫", label: "Instructor Dashboard", path: "/instructor" },
  { icon: "💰", label: "Tutor Earnings", path: "/tutor/earnings" },
  { icon: "🔐", label: "Sign In", path: "/login" },
  { icon: "📋", label: "Register", path: "/register" },
  { icon: "🚀", label: "Onboarding", path: "/onboarding" },
  { icon: "⚙️", label: "Admin Dashboard", path: "/admin" },
  { icon: "🎨", label: "Brand Guide", path: "/brand" },
  { icon: "🧩", label: "Design System", path: "/design-system" },
  { icon: "🌐", label: "RTL Demo", path: "/rtl-demo" },
];

export function Navbar() {
  const [scrolled, setScrolled] = useState(false);
  const [menuOpen, setMenuOpen] = useState(false);
  const [userMenuOpen, setUserMenuOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState("");
  const [winWidth, setWinWidth] = useState(() => typeof window !== "undefined" ? window.innerWidth : 1024);
  const location = useLocation();
  const nav = useNavigate();
  const { user, logout } = useAuth();
  const userMenuRef = useRef<HTMLDivElement>(null);
  const searchRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 20);
    const onResize = () => setWinWidth(window.innerWidth);
    window.addEventListener("scroll", onScroll);
    window.addEventListener("resize", onResize);
    return () => { window.removeEventListener("scroll", onScroll); window.removeEventListener("resize", onResize); };
  }, []);

  useEffect(() => { setMenuOpen(false); setUserMenuOpen(false); setSearchQuery(""); }, [location]);

  useEffect(() => {
    const handler = (e: MouseEvent) => {
      if (userMenuRef.current && !userMenuRef.current.contains(e.target as Node)) setUserMenuOpen(false);
    };
    document.addEventListener("mousedown", handler);
    return () => document.removeEventListener("mousedown", handler);
  }, []);

  const isDesktop = winWidth >= 1024;
  const initials = user ? userInitials(user) : "";

  const drawerSections = [
    {
      heading: "Home",
      links: [["🏠 Home", "/"], ["🔍 Search", "/search"], ["🔔 Notifications", "/notifications"], ["🏛️ Accreditations", "/accreditations"]],
    },
    {
      heading: "Learn",
      links: [
        ["📚 Explore Courses", "/courses"],
        ["📖 Course Detail", "/courses/1"],
        ["▶️ Course Player", "/courses/1/play"],
        ["📄 Handouts", "/courses/1/handouts"],
        ["🃏 Flashcards", "/courses/1/flashcards"],
        ["✏️ Quiz", "/courses/1/quiz"],
        ["🤖 Course AI", "/courses/1/ai"],
        ["📡 Live Academy", "/live"],
        ["🏥 Live Classroom", "/live/1/classroom"],
        ["🎥 Clinical Demos", "/live/clinical"],
        ["🧠 Dental AI", "/ai"],
      ],
    },
    {
      heading: "Exams & Certificates",
      links: [
        ["📝 Exam Hub", "/exams"],
        ["🇪🇬 EDLE Dashboard", "/exams/edle"],
        ["🗂️ Question Bank", "/exams/edle/practice"],
        ["⏱️ Mock Exam", "/exams/edle/mock"],
        ["📊 Exam Analytics", "/exams/analytics"],
        ["🆓 Free Tests", "/exams/free"],
        ["🎓 Certificates", "/certificates"],
        ["✅ Verify Certificate", "/verify"],
      ],
    },
    {
      heading: "Services",
      links: [
        ["📐 Tutoring", "/tutoring"],
        ["👤 Tutor Profile", "/tutoring/1"],
        ["📅 Book a Tutor", "/tutoring/1/book"],
        ["🚀 Become a Tutor", "/tutoring/become-a-tutor"],
        ["🤝 Mentoring", "/mentoring"],
        ["👤 Mentor Profile", "/mentoring/1"],
        ["💼 Consulting", "/consulting"],
        ["👤 Consultant Profile", "/consulting/1"],
        ["🏋️ Private Training", "/private-training"],
      ],
    },
    {
      heading: "Career & Masters",
      links: [
        ["✈️ Career Abroad", "/career"],
        ["🗺️ My Roadmap", "/career/roadmap"],
        ["🇬🇧 UK Pathway", "/career/uk"],
        ["🇦🇪 UAE Pathway", "/career/uae"],
        ["🇸🇦 KSA Pathway", "/career/ksa"],
        ["🇩🇪 Germany Pathway", "/career/germany"],
        ["🎓 Master's Database", "/masters"],
        ["📋 King's Endodontology (MSc)", "/masters/1"],
        ["⚖️ Compare Programs", "/masters/compare"],
      ],
    },
    {
      heading: "Knowledge & Community",
      links: [
        ["🔬 Research Hub", "/research"],
        ["📄 Research Details", "/research/1"],
        ["📚 Study Companions", "/library"],
        ["🦷 Endodontics Companion", "/library/1"],
        ["🔬 Orthodontics Companion", "/library/3"],
        ["👥 Community", "/community"],
        ["🏆 Achievements", "/achievements"],
      ],
    },
    ...(user ? [{
      heading: "My Account",
      links: [
        ["📋 Dashboard", "/dashboard"],
        ["📅 My Bookings", "/bookings"],
        ["🎓 My Certificates", "/certificates"],
        ["🔔 Notifications", "/notifications"],
        ["👤 My Profile", "/profile/1"],
        ["✏️ Edit Profile", "/profile/edit"],
        ["📇 NFC Card", "/profile/card"],
        ["💳 Membership", "/membership"],
        ["🛒 Checkout", "/checkout"],
        ["👩‍🏫 Instructor Dashboard", "/instructor"],
        ["💰 Tutor Earnings", "/tutor/earnings"],
      ],
    }] : [{
      heading: "Account",
      links: [
        ["🔐 Sign In", "/login"],
        ["📋 Register", "/register"],
        ["🚀 Onboarding", "/onboarding"],
        ["💳 Membership", "/membership"],
      ],
    }]),
    {
      heading: "System & Dev",
      links: [
        ["⚙️ Admin Dashboard", "/admin"],
        ["🎨 Brand Guide", "/brand"],
        ["🧩 Design System", "/design-system"],
        ["🌐 RTL Demo", "/rtl-demo"],
      ],
    },
  ];

  return (
    <>
      <nav style={{ position: "sticky", top: 0, zIndex: 100, background: scrolled ? "rgba(255,249,239,0.97)" : brand.offWhite, borderBottom: `1px solid ${brand.borderGray}`, backdropFilter: "blur(12px)", boxShadow: scrolled ? "0 2px 20px rgba(27,27,27,0.08)" : "none", transition: "box-shadow 0.2s" }}>
        <div style={{ maxWidth: 1280, margin: "0 auto", padding: "0 24px", display: "flex", alignItems: "center", height: 68, gap: 0 }}>
          <Link to="/" style={{ marginRight: "auto", flexShrink: 0, textDecoration: "none" }}>
            <EjadahWordmark />
          </Link>

          {/* Desktop quick links */}
          {isDesktop && (
            <div style={{ display: "flex", alignItems: "center", gap: 2, marginRight: 16 }}>
              {[["Learn", "/courses"], ["Exams", "/exams"], ["Tutoring", "/tutoring"], ["Career", "/career"], ["Masters", "/masters"]].map(([label, path]) => {
                const active = location.pathname === path || location.pathname.startsWith(path + "/");
                return (
                  <Link key={path} to={path} style={{ fontFamily: "Inter,sans-serif", fontWeight: 500, fontSize: 13, color: active ? brand.red : brand.charcoal, textDecoration: "none", padding: "6px 12px", borderRadius: 8, background: active ? "rgba(255,45,50,0.06)" : "transparent", transition: "all 0.15s", whiteSpace: "nowrap" as const }}
                    onMouseEnter={e => (e.currentTarget.style.background = active ? "rgba(255,45,50,0.06)" : "rgba(27,27,27,0.05)")}
                    onMouseLeave={e => (e.currentTarget.style.background = active ? "rgba(255,45,50,0.06)" : "transparent")}
                  >{label as string}</Link>
                );
              })}
            </div>
          )}

          {/* Right side */}
          <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
            {isDesktop && (
              <Link to="/search" style={{ display: "flex", alignItems: "center", padding: 8, color: brand.warmGray, textDecoration: "none" }}><Search size={18} /></Link>
            )}

            {user ? (
              <>
                {/* Notification bell */}
                <Link to="/notifications" style={{ position: "relative", display: "flex", alignItems: "center", padding: 8, color: brand.warmGray, textDecoration: "none" }}>
                  <Bell size={18} />
                  <span style={{ position: "absolute", top: 6, right: 6, width: 7, height: 7, borderRadius: "50%", background: brand.red, border: `1.5px solid ${brand.offWhite}` }} />
                </Link>

                {/* Avatar + user dropdown */}
                <div ref={userMenuRef} style={{ position: "relative" }}>
                  <button onClick={() => setUserMenuOpen(o => !o)} style={{ display: "flex", alignItems: "center", gap: 8, background: userMenuOpen ? brand.offWhite : "transparent", border: `1.5px solid ${userMenuOpen ? brand.borderGray : "transparent"}`, borderRadius: 12, padding: "5px 10px 5px 5px", cursor: "pointer", transition: "all 0.15s" }}>
                    <div style={{ width: 32, height: 32, borderRadius: 10, background: gradientFlow, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                      <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: "#fff" }}>{initials}</span>
                    </div>
                    {isDesktop && (
                      <>
                        <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal }}>{user.firstName}</span>
                        <ChevronDown size={12} color={brand.warmGray} style={{ transform: userMenuOpen ? "rotate(180deg)" : "none", transition: "transform 0.2s" }} />
                      </>
                    )}
                  </button>

                  {userMenuOpen && (
                    <div style={{ position: "absolute", top: "calc(100% + 8px)", right: 0, background: brand.white, border: `1px solid ${brand.borderGray}`, borderRadius: 18, boxShadow: "0 12px 40px rgba(27,27,27,0.12)", padding: "8px", minWidth: 220, zIndex: 300 }}>
                      {/* User info */}
                      <div style={{ padding: "12px 14px 10px", borderBottom: `1px solid ${brand.borderGray}`, marginBottom: 6 }}>
                        <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal }}>{user.firstName} {user.lastName}</div>
                        <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginTop: 2 }}>{roleLabels[user.role] ?? user.role}</div>
                        <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.orange, marginTop: 2 }}>{user.country}</div>
                      </div>
                      {[
                        { icon: <LayoutDashboard size={14} />, label: "Dashboard", path: "/dashboard" },
                        { icon: <User size={14} />, label: "My Profile", path: "/profile/1" },
                        { icon: <BookOpenIcon size={14} />, label: "My Bookings", path: "/bookings" },
                        { icon: <BookOpenIcon size={14} />, label: "My Courses", path: "/courses" },
                        { icon: <Bell size={14} />, label: "Notifications", path: "/notifications" },
                      ].map(item => (
                        <Link key={item.path} to={item.path} style={{ display: "flex", alignItems: "center", gap: 10, fontFamily: "Inter", fontSize: 13, color: brand.charcoal, textDecoration: "none", padding: "9px 14px", borderRadius: 10, transition: "background 0.12s" }}
                          onMouseEnter={e => (e.currentTarget.style.background = brand.offWhite)}
                          onMouseLeave={e => (e.currentTarget.style.background = "transparent")}
                        >
                          <span style={{ color: brand.warmGray }}>{item.icon}</span> {item.label}
                        </Link>
                      ))}
                      <div style={{ borderTop: `1px solid ${brand.borderGray}`, marginTop: 6, paddingTop: 6 }}>
                        <button onClick={() => { logout(); nav("/"); }} style={{ display: "flex", alignItems: "center", gap: 10, fontFamily: "Inter", fontSize: 13, color: brand.red, background: "none", border: "none", padding: "9px 14px", borderRadius: 10, cursor: "pointer", width: "100%", transition: "background 0.12s" }}
                          onMouseEnter={e => ((e.currentTarget as HTMLElement).style.background = "rgba(255,45,50,0.06)")}
                          onMouseLeave={e => ((e.currentTarget as HTMLElement).style.background = "transparent")}
                        >
                          <LogOut size={14} /> Sign Out
                        </button>
                      </div>
                    </div>
                  )}
                </div>
              </>
            ) : (
              isDesktop ? (
                <>
                  <Link to="/login" style={{ fontFamily: "Inter,sans-serif", fontWeight: 500, fontSize: 13, color: brand.charcoal, textDecoration: "none", padding: "7px 14px", border: `1.5px solid ${brand.borderGray}`, borderRadius: 10 }}>
                    Sign In
                  </Link>
                  <Link to="/register" style={{ fontFamily: "Inter,sans-serif", fontWeight: 600, fontSize: 13, color: "#fff", background: gradientFlow, borderRadius: 10, padding: "7px 16px", textDecoration: "none", marginLeft: 2 }}>
                    Join Ejadah
                  </Link>
                </>
              ) : null
            )}

            {/* Hamburger — always visible */}
            <button onClick={() => setMenuOpen(o => !o)} style={{ background: menuOpen ? brand.offWhite : "none", border: menuOpen ? `1.5px solid ${brand.borderGray}` : "1.5px solid transparent", borderRadius: 10, cursor: "pointer", color: brand.charcoal, display: "flex", alignItems: "center", justifyContent: "center", width: 40, height: 40, marginLeft: 4, transition: "all 0.15s" }}>
              {menuOpen ? <X size={20} /> : <Menu size={20} />}
            </button>
          </div>
        </div>
      </nav>

      {/* Drawer */}
      {menuOpen && (
        <>
          <div onClick={() => setMenuOpen(false)} style={{ position: "fixed", inset: 0, zIndex: 200, background: "rgba(27,27,27,0.35)", backdropFilter: "blur(2px)" }} />
          <div style={{ position: "fixed", top: 0, right: 0, bottom: 0, zIndex: 201, width: Math.min(340, winWidth - 40), background: brand.white, boxShadow: "-8px 0 40px rgba(27,27,27,0.15)", display: "flex", flexDirection: "column" as const, overflowY: "auto" }}>
            {/* Drawer header */}
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "18px 20px", borderBottom: `1px solid ${brand.borderGray}`, flexShrink: 0 }}>
              {user ? (
                <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
                  <div style={{ width: 36, height: 36, borderRadius: 10, background: gradientFlow, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                    <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff" }}>{initials}</span>
                  </div>
                  <div>
                    <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal }}>{user.firstName} {user.lastName}</div>
                    <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{roleLabels[user.role] ?? user.role}</div>
                  </div>
                </div>
              ) : (
                <EjadahWordmark />
              )}
              <button onClick={() => setMenuOpen(false)} style={{ background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 9, cursor: "pointer", color: brand.charcoal, display: "flex", alignItems: "center", justifyContent: "center", width: 34, height: 34 }}>
                <X size={17} />
              </button>
            </div>

            {/* Inline search */}
            <div style={{ padding: "14px 20px 0", flexShrink: 0 }}>
              <div style={{ display: "flex", alignItems: "center", gap: 8, background: brand.offWhite, border: `1.5px solid ${searchQuery ? brand.orange : brand.borderGray}`, borderRadius: 11, padding: "8px 14px", transition: "border-color 0.15s" }}>
                <Search size={15} color={searchQuery ? brand.orange : brand.warmGray} style={{ flexShrink: 0 }} />
                <input
                  ref={searchRef}
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  placeholder="Search pages, topics…"
                  style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, background: "none", border: "none", outline: "none", flex: 1, minWidth: 0 }}
                />
                {searchQuery && (
                  <button onClick={() => { setSearchQuery(""); searchRef.current?.focus(); }} style={{ background: "none", border: "none", cursor: "pointer", color: brand.warmGray, display: "flex", alignItems: "center", padding: 0 }}>
                    <X size={14} />
                  </button>
                )}
              </div>
            </div>

            {/* Sections or search results */}
            <div style={{ flex: 1, overflowY: "auto", padding: "14px 20px 20px" }}>
              {searchQuery.trim() ? (
                // ── Search results ──
                (() => {
                  const q = searchQuery.toLowerCase();
                  const hits = SEARCH_INDEX.filter((item) =>
                    item.label.toLowerCase().includes(q) || item.path.toLowerCase().includes(q)
                  );
                  return hits.length > 0 ? (
                    <div style={{ display: "flex", flexDirection: "column" as const, gap: 2 }}>
                      <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginBottom: 6 }}>
                        {hits.length} result{hits.length !== 1 ? "s" : ""} for "<strong style={{ color: brand.charcoal }}>{searchQuery}</strong>"
                      </div>
                      {hits.map((item) => {
                        const active = location.pathname === item.path;
                        const labelLower = item.label.toLowerCase();
                        const idx = labelLower.indexOf(q);
                        const highlighted = idx >= 0
                          ? <>{item.label.slice(0, idx)}<mark style={{ background: `${brand.amber}50`, color: "inherit", borderRadius: 2, padding: "0 1px" }}>{item.label.slice(idx, idx + q.length)}</mark>{item.label.slice(idx + q.length)}</>
                          : item.label;
                        return (
                          <Link key={item.path} to={item.path}
                            style={{ display: "flex", alignItems: "center", gap: 10, padding: "9px 10px", borderRadius: 9, textDecoration: "none", background: active ? "rgba(255,107,26,0.07)" : "transparent", transition: "background 0.12s" }}
                            onMouseEnter={e => { if (!active) e.currentTarget.style.background = brand.offWhite; }}
                            onMouseLeave={e => { if (!active) e.currentTarget.style.background = active ? "rgba(255,107,26,0.07)" : "transparent"; }}
                          >
                            <span style={{ fontSize: 16, flexShrink: 0 }}>{item.icon}</span>
                            <div style={{ flex: 1, minWidth: 0 }}>
                              <div style={{ fontFamily: "Inter", fontSize: 13, fontWeight: active ? 600 : 500, color: active ? brand.orange : brand.charcoal }}>{highlighted}</div>
                              <div style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" as const }}>{item.path}</div>
                            </div>
                          </Link>
                        );
                      })}
                    </div>
                  ) : (
                    <div style={{ textAlign: "center" as const, padding: "40px 0" }}>
                      <div style={{ fontSize: 32, marginBottom: 10 }}>🔍</div>
                      <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.charcoal, marginBottom: 4 }}>No results</div>
                      <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>Try a different keyword</div>
                    </div>
                  );
                })()
              ) : (
                // ── Normal sections ──
                drawerSections.map((section) => (
                  <div key={section.heading} style={{ marginBottom: 20 }}>
                    <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 10, letterSpacing: "0.1em", color: brand.orange, textTransform: "uppercase" as const, marginBottom: 6 }}>{section.heading}</div>
                    <div style={{ display: "flex", flexDirection: "column" as const, gap: 1 }}>
                      {section.links.map(([label, path]) => {
                        const active = location.pathname === path;
                        return (
                          <Link key={path} to={path} style={{ fontFamily: "Inter", fontSize: 13, fontWeight: active ? 600 : 400, color: active ? brand.orange : brand.charcoal, padding: "8px 10px", borderRadius: 9, textDecoration: "none", background: active ? "rgba(255,107,26,0.07)" : "transparent", transition: "background 0.12s" }}
                            onMouseEnter={e => { if (!active) e.currentTarget.style.background = brand.offWhite; }}
                            onMouseLeave={e => { if (!active) e.currentTarget.style.background = "transparent"; }}
                          >{label}</Link>
                        );
                      })}
                    </div>
                  </div>
                ))
              )}
            </div>

            {/* Footer CTAs */}
            <div style={{ padding: "14px 20px 24px", borderTop: `1px solid ${brand.borderGray}`, flexShrink: 0, display: "flex", flexDirection: "column" as const, gap: 8 }}>
              {user ? (
                <>
                  <Link to="/dashboard" onClick={() => setMenuOpen(false)} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.charcoal, border: `1.5px solid ${brand.borderGray}`, borderRadius: 11, padding: "11px", textDecoration: "none", textAlign: "center" as const }}>
                    Dashboard
                  </Link>
                  <button onClick={() => { logout(); nav("/"); setMenuOpen(false); }} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.red, background: "rgba(255,45,50,0.06)", border: "none", borderRadius: 11, padding: "11px", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 6 }}>
                    <LogOut size={15} /> Sign Out
                  </button>
                </>
              ) : (
                <>
                  <Link to="/login" onClick={() => setMenuOpen(false)} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.charcoal, border: `1.5px solid ${brand.borderGray}`, borderRadius: 11, padding: "11px", textDecoration: "none", textAlign: "center" as const }}>
                    Sign In
                  </Link>
                  <Link to="/register" onClick={() => setMenuOpen(false)} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: gradientFlow, borderRadius: 11, padding: "11px", textDecoration: "none", textAlign: "center" as const, boxShadow: "0 3px 12px rgba(255,107,26,0.3)" }}>
                    Join Ejadah — It's Free
                  </Link>
                </>
              )}
            </div>
          </div>
        </>
      )}
    </>
  );
}

// ─── Footer ──────────────────────────────────────────────────────────────────
const footerCols = [
  {
    heading: "Learn",
    links: [
      ["Explore Courses", "/courses"],
      ["Live Academy", "/live"],
      ["Clinical Demos", "/live/clinical"],
      ["Handouts", "/courses/1/handouts"],
      ["Flashcards", "/courses/1/flashcards"],
      ["Quiz", "/courses/1/quiz"],
      ["Course AI", "/courses/1/ai"],
    ],
  },
  {
    heading: "Exams",
    links: [
      ["Exam Hub", "/exams"],
      ["EDLE Dashboard", "/exams/edle"],
      ["Question Bank", "/exams/edle/practice"],
      ["Mock Exam", "/exams/edle/mock"],
      ["Exam Analytics", "/exams/analytics"],
      ["Free Tests", "/exams/free"],
      ["Certificates", "/certificates"],
      ["Verify Certificate", "/verify"],
    ],
  },
  {
    heading: "Professional Services",
    links: [
      ["Tutoring", "/tutoring"],
      ["Book a Tutor", "/tutoring/1/book"],
      ["Become a Tutor", "/tutoring/become-a-tutor"],
      ["Mentoring", "/mentoring"],
      ["Consulting", "/consulting"],
      ["Private Training", "/private-training"],
    ],
  },
  {
    heading: "Career & Community",
    links: [
      ["Career Abroad", "/career"],
      ["UK Pathway", "/career/uk"],
      ["UAE Pathway", "/career/uae"],
      ["My Roadmap", "/career/roadmap"],
      ["Master's Programs", "/masters"],
      ["Community", "/community"],
      ["Dental AI", "/ai"],
      ["Dashboard", "/dashboard"],
    ],
  },
  {
    heading: "Knowledge",
    links: [
      ["Research Hub", "/research"],
      ["Research Details", "/research/1"],
      ["Study Companions", "/library"],
      ["Endodontics Companion", "/library/1"],
      ["Orthodontics Companion", "/library/3"],
    ],
  },
];

export function Footer() {
  return (
    <footer style={{ background: brand.deepCharcoal, color: "rgba(255,255,255,0.7)", padding: "64px 0 0" }}>
      <div style={{ maxWidth: 1280, margin: "0 auto", padding: "0 24px" }}>
        <div style={{ display: "grid", gridTemplateColumns: "2fr repeat(5, 1fr)", gap: 28, marginBottom: 48 }}>
          {/* Brand */}
          <div>
            <div style={{ marginBottom: 18 }}><EjadahWordmark light /></div>
            <p style={{ fontFamily: "Inter", fontSize: 13, lineHeight: 1.7, color: "rgba(255,255,255,0.5)", maxWidth: 260, marginBottom: 20 }}>
              International dental education, clinical development, and professional opportunity. Cairo, Egypt.
            </p>
            <div style={{ display: "flex", gap: 10 }}>
              {["📘", "📷", "💼", "🐦"].map((icon, i) => (
                <div key={i} style={{ width: 34, height: 34, borderRadius: 10, background: "rgba(255,255,255,0.06)", border: "1px solid rgba(255,255,255,0.1)", display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer", fontSize: 15 }}>{icon}</div>
              ))}
            </div>
          </div>

          {/* Link columns */}
          {footerCols.map((col) => (
            <div key={col.heading}>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 10, letterSpacing: "0.1em", color: "rgba(255,255,255,0.35)", textTransform: "uppercase" as const, marginBottom: 14 }}>{col.heading}</div>
              {col.links.map(([label, path]) => (
                <Link key={path} to={path}
                  style={{ display: "block", fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.5)", marginBottom: 9, textDecoration: "none", transition: "color 0.15s" }}
                  onMouseEnter={(e) => ((e.target as HTMLElement).style.color = brand.amber)}
                  onMouseLeave={(e) => ((e.target as HTMLElement).style.color = "rgba(255,255,255,0.5)")}
                >{label}</Link>
              ))}
            </div>
          ))}
        </div>

        <div style={{ borderTop: "1px solid rgba(255,255,255,0.06)", padding: "20px 0", display: "flex", justifyContent: "space-between", alignItems: "center", flexWrap: "wrap", gap: 12 }}>
          <div style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.3)" }}>© 2025 Ejadah International Academy. Cairo, Egypt.</div>
          <div style={{ display: "flex", gap: 20 }}>
            {["Terms", "Privacy", "Refund Policy"].map((l) => (
              <span key={l} style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.3)", cursor: "pointer" }}>{l}</span>
            ))}
          </div>
        </div>
      </div>
    </footer>
  );
}

export const globalStyle = `
  @keyframes pulse { 0%, 100% { opacity: 1; transform: scale(1); } 50% { opacity: 0.7; transform: scale(0.9); } }
  ::-webkit-scrollbar { display: none; }
  * { scrollbar-width: none; }
`;
