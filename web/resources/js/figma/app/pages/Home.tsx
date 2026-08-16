import { useNavigate } from "react-router";
import {
  ArrowRight, Star, CheckCircle, BookOpen, MapPin, Video,
  Globe, Users, GraduationCap, Sparkles, Play, Clock,
  TrendingUp, Award, Zap, Radio, LayoutDashboard,
} from "lucide-react";
import {
  brand, gradientFlow, gradientGlow,
  GradientBadge, LiveBadge, StarRating, SectionHeader,
} from "@/figma/app/shared";
import { useAuth, roleLabels } from "@/figma/app/auth";

// ─── Hero ────────────────────────────────────────────────────────────────────
function Hero() {
  const nav = useNavigate();
  return (
    <section style={{ background: brand.charcoal, position: "relative", overflow: "hidden", minHeight: 600, display: "flex", alignItems: "center" }}>
      <div style={{ position: "absolute", inset: 0 }}>
        <img src="https://images.unsplash.com/photo-1681939282781-341ac4f61996?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=1400&q=80" alt="" style={{ width: "100%", height: "100%", objectFit: "cover", opacity: 0.28 }} />
        <div style={{ position: "absolute", inset: 0, background: `linear-gradient(105deg, ${brand.deepCharcoal} 0%, rgba(18,18,18,0.8) 55%, rgba(255,45,50,0.1) 100%)` }} />
      </div>
      <div style={{ position: "absolute", right: -80, top: -80, width: 480, height: 480, borderRadius: "50%", background: "radial-gradient(circle, rgba(255,107,26,0.14) 0%, transparent 65%)", pointerEvents: "none" }} />

      <div style={{ maxWidth: 1280, margin: "0 auto", padding: "72px 24px", position: "relative", width: "100%" }}>
        <div style={{ maxWidth: 680 }}>
          <div style={{ display: "inline-flex", alignItems: "center", gap: 8, background: "rgba(255,255,255,0.06)", border: "1px solid rgba(255,255,255,0.12)", borderRadius: 40, padding: "6px 14px 6px 8px", marginBottom: 24 }}>
            <GradientBadge small><Sparkles size={10} /> Premier Dental Education</GradientBadge>
            <span style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.6)" }}>Egypt's #1 platform for dental professionals</span>
          </div>

          <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(34px,5vw,58px)", color: "#fff", lineHeight: 1.1, marginBottom: 20 }}>
            Your Career in Dentistry,{" "}
            <span style={{ background: gradientFlow, WebkitBackgroundClip: "text", WebkitTextFillColor: "transparent" }}>Built Without Limits.</span>
          </h1>

          <p style={{ fontFamily: "Inter", fontSize: 17, color: "rgba(255,255,255,0.72)", lineHeight: 1.65, marginBottom: 36, maxWidth: 520 }}>
            1-on-1 tutoring with verified specialists. 200+ Masters programs worldwide. Career pathways to 23 countries. All in one platform built for Egyptian dental professionals.
          </p>

          <div style={{ display: "flex", flexWrap: "wrap", gap: 12, marginBottom: 48 }}>
            <button onClick={() => nav("/tutoring")} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "14px 30px", cursor: "pointer", display: "flex", alignItems: "center", gap: 8, boxShadow: "0 4px 20px rgba(255,107,26,0.4)" }}>
              Find a Tutor <ArrowRight size={16} />
            </button>
            <button onClick={() => nav("/career/roadmap")} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 15, color: "#fff", background: "rgba(255,255,255,0.08)", border: "1.5px solid rgba(255,255,255,0.2)", borderRadius: 12, padding: "14px 26px", cursor: "pointer" }}>
              Build My Roadmap
            </button>
          </div>

          <div style={{ display: "flex", flexWrap: "wrap", gap: 32 }}>
            {[["40,000+", "Dental Professionals"], ["200+", "Masters Programs"], ["150+", "Verified Tutors"], ["23", "Countries Served"]].map(([v, l]) => (
              <div key={l}>
                <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 24, color: brand.gold }}>{v}</div>
                <div style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.5)", marginTop: 2 }}>{l}</div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}

// ─── Tutoring Feature ────────────────────────────────────────────────────────
const featuredTutors = [
  {
    id: "u1", name: "Prof. Sherif Kamel", title: "Head of Oral Biology · Cairo University", specialty: "Oral Histology", rating: 4.9, reviews: 187, sessions: 820, price: "EGP 900", currency: "EGP", available: true, online: true, avatar: "https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=200&q=80", university: "Cairo University",
  },
  {
    id: "u2", name: "Dr. Yasmine Nour", title: "BUE Faculty · Dental Anatomy", specialty: "Dental Anatomy", rating: 4.8, reviews: 143, sessions: 560, price: "EGP 500", currency: "EGP", available: true, online: true, avatar: "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=200&q=80", university: "British University in Egypt (BUE)",
  },
  {
    id: "i1", name: "Dr. Omar Farid", title: "Implant Specialist · MSc King's College London", specialty: "Implantology", rating: 4.8, reviews: 178, sessions: 720, price: "$70", currency: "USD", available: true, online: true, avatar: "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=200&q=80", university: null,
  },
  {
    id: "u6", name: "Prof. Rasha El-Gohary", title: "Professor of Oral Medicine · Alexandria University", specialty: "Oral Medicine", rating: 4.9, reviews: 201, sessions: 890, price: "EGP 750", currency: "EGP", available: false, online: true, avatar: "https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=200&q=80", university: "Alexandria University",
  },
];

function TutoringSection() {
  const nav = useNavigate();
  return (
    <section style={{ background: brand.offWhite, padding: "72px 0" }}>
      <div style={{ maxWidth: 1280, margin: "0 auto", padding: "0 24px" }}>

        {/* Header */}
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-end", marginBottom: 16, flexWrap: "wrap", gap: 12 }}>
          <div>
            <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, letterSpacing: "0.12em", color: brand.orange, textTransform: "uppercase" as const, marginBottom: 10 }}>1-on-1 Tutoring</div>
            <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(26px,3.5vw,38px)", color: brand.charcoal, lineHeight: 1.15, maxWidth: 600 }}>
              1-on-1 Tutoring with Verified Dental Specialists & University Faculty
            </h2>
          </div>
          <button onClick={() => nav("/tutoring")} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.orange, background: "none", border: `1.5px solid ${brand.orange}`, borderRadius: 10, padding: "9px 18px", cursor: "pointer", display: "flex", alignItems: "center", gap: 5, flexShrink: 0 }}>
            Browse All Tutors <ArrowRight size={13} />
          </button>
        </div>

        <p style={{ fontFamily: "Inter", fontSize: 15, color: brand.warmGray, marginBottom: 36, maxWidth: 620, lineHeight: 1.65 }}>
          Pre-clinical sciences, clinical specialties, and international exam prep — in EGP or USD, online or in-person. Tutors from Cairo University, BUE, Ain Shams, Alexandria, and more.
        </p>

        {/* Proof chips */}
        <div style={{ display: "flex", gap: 10, flexWrap: "wrap", marginBottom: 36 }}>
          {[
            { label: "University Faculty Tutors", color: "#1A4FBE" },
            { label: "EGP & USD pricing", color: brand.charcoal },
            { label: "Pre-clinical Sciences", color: brand.orange },
            { label: "Clinical Specialties", color: brand.charcoal },
            { label: "Exam Preparation", color: brand.charcoal },
            { label: "Online & In-person", color: brand.charcoal },
          ].map(({ label, color }) => (
            <span key={label} style={{ fontFamily: "Inter", fontSize: 12, fontWeight: 500, color, background: color === "#1A4FBE" ? "rgba(26,79,190,0.07)" : brand.white, border: `1px solid ${color === "#1A4FBE" ? "rgba(26,79,190,0.2)" : brand.borderGray}`, borderRadius: 20, padding: "5px 13px", display: "flex", alignItems: "center", gap: 5 }}>
              <CheckCircle size={11} color={color === "#1A4FBE" ? "#1A4FBE" : brand.orange} />
              {label}
            </span>
          ))}
        </div>

        {/* Tutor cards */}
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(280px, 1fr))", gap: 18, marginBottom: 32 }}>
          {featuredTutors.map((t) => (
            <div key={t.id} onClick={() => nav(`/tutoring/${t.id}`)} style={{ background: brand.white, borderRadius: 22, border: `1px solid ${brand.borderGray}`, overflow: "hidden", cursor: "pointer", transition: "transform 0.2s, box-shadow 0.2s", boxShadow: "0 2px 12px rgba(27,27,27,0.05)" }}
              onMouseEnter={e => { const el = e.currentTarget as HTMLElement; el.style.transform = "translateY(-4px)"; el.style.boxShadow = "0 12px 30px rgba(27,27,27,0.1)"; }}
              onMouseLeave={e => { const el = e.currentTarget as HTMLElement; el.style.transform = "none"; el.style.boxShadow = "0 2px 12px rgba(27,27,27,0.05)"; }}
            >
              <div style={{ height: 4, background: gradientFlow }} />
              <div style={{ padding: "20px" }}>
                <div style={{ display: "flex", gap: 12, alignItems: "flex-start", marginBottom: 14 }}>
                  <div style={{ position: "relative", flexShrink: 0 }}>
                    <img src={t.avatar} alt={t.name} style={{ width: 56, height: 56, borderRadius: 13, objectFit: "cover" }} />
                    <div style={{ position: "absolute", bottom: 3, right: 3, width: 11, height: 11, borderRadius: "50%", background: t.available ? "#2D9B68" : brand.warmGray, border: "2px solid #fff" }} />
                  </div>
                  <div>
                    <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal, marginBottom: 3 }}>{t.name}</div>
                    <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginBottom: 8 }}>{t.title}</div>
                    <div style={{ display: "flex", gap: 5, flexWrap: "wrap" }}>
                      <GradientBadge small>{t.specialty}</GradientBadge>
                      {t.university && (
                        <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 9, color: "#1A4FBE", background: "rgba(26,79,190,0.08)", border: "1px solid rgba(26,79,190,0.18)", borderRadius: 5, padding: "2px 7px", display: "flex", alignItems: "center", gap: 3 }}>
                          <BookOpen size={8} /> {t.university.replace("British University in Egypt (BUE)", "BUE").replace(" University", " Uni")}
                        </span>
                      )}
                    </div>
                  </div>
                </div>

                <div style={{ display: "flex", gap: 12, alignItems: "center", marginBottom: 14, flexWrap: "wrap" }}>
                  <div style={{ display: "flex", alignItems: "center", gap: 3 }}>
                    <Star size={12} fill={brand.amber} color={brand.amber} />
                    <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.charcoal }}>{t.rating}</span>
                    <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>({t.reviews})</span>
                  </div>
                  <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, display: "flex", alignItems: "center", gap: 3 }}>
                    <Clock size={11} /> {t.sessions.toLocaleString()} sessions
                  </span>
                  {t.online && <span style={{ fontFamily: "Inter", fontSize: 10, fontWeight: 600, color: brand.orange, background: "rgba(255,107,26,0.08)", borderRadius: 5, padding: "2px 7px", display: "flex", alignItems: "center", gap: 3 }}><Video size={9} /> Online</span>}
                </div>

                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", paddingTop: 12, borderTop: `1px solid ${brand.borderGray}` }}>
                  <div>
                    <span style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal }}>{t.price}</span>
                    <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}> / hour</span>
                  </div>
                  <button onClick={e => { e.stopPropagation(); nav(`/tutoring/${t.id}/book`); }} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: "#fff", background: gradientFlow, border: "none", borderRadius: 9, padding: "8px 16px", cursor: "pointer", display: "flex", alignItems: "center", gap: 5, boxShadow: "0 2px 8px rgba(255,107,26,0.28)" }}>
                    Book <ArrowRight size={11} />
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Become a tutor nudge */}
        <div style={{ background: brand.charcoal, borderRadius: 20, padding: "26px 30px", display: "flex", gap: 24, alignItems: "center", flexWrap: "wrap" }}>
          <div style={{ flex: 1, minWidth: 240 }}>
            <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, letterSpacing: "0.1em", color: brand.amber, textTransform: "uppercase" as const, marginBottom: 8 }}>For Dental Professionals</div>
            <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: "#fff", marginBottom: 6 }}>Earn EGP 7,000–30,000/month. Teach on your schedule.</div>
            <div style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.55)" }}>Join 150+ tutors and university faculty already earning on Ejadah.</div>
          </div>
          <button onClick={() => nav("/tutoring/become-a-tutor")} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "13px 26px", cursor: "pointer", display: "flex", alignItems: "center", gap: 8, flexShrink: 0, boxShadow: "0 4px 16px rgba(255,107,26,0.4)" }}>
            Become a Tutor <ArrowRight size={15} />
          </button>
        </div>
      </div>
    </section>
  );
}

// ─── Masters Database ─────────────────────────────────────────────────────────
const masterHighlights = [
  { flag: "🇬🇧", country: "United Kingdom", programs: 38, from: "$33,000", slug: "uk", note: "ORE-recognised · GDC route" },
  { flag: "🇦🇪", country: "United Arab Emirates", programs: 22, from: "$18,000", slug: "uae", note: "Prometric pathway · Tax-free" },
  { flag: "🇦🇺", country: "Australia", programs: 19, from: "$36,000", slug: "australia", note: "ADC pathway · High salaries" },
  { flag: "🇩🇪", country: "Germany", programs: 24, from: "$4,200", slug: "germany", note: "Low tuition · EU work rights" },
  { flag: "🇨🇦", country: "Canada", programs: 17, from: "$20,000", slug: "canada", note: "NDEB pathway · PR-friendly" },
  { flag: "🇮🇪", country: "Ireland", country_short: "Ireland", programs: 11, from: "$16,000", slug: "ireland", note: "English-taught · EU entry" },
];

function MastersSection() {
  const nav = useNavigate();
  return (
    <section style={{ background: brand.deepCharcoal, padding: "72px 0", position: "relative", overflow: "hidden" }}>
      <div style={{ position: "absolute", inset: 0, background: "radial-gradient(ellipse at 80% 40%, rgba(255,107,26,0.07) 0%, transparent 55%)", pointerEvents: "none" }} />
      <div style={{ maxWidth: 1280, margin: "0 auto", padding: "0 24px", position: "relative" }}>

        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-end", marginBottom: 14, flexWrap: "wrap", gap: 12 }}>
          <div>
            <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, letterSpacing: "0.12em", color: brand.amber, textTransform: "uppercase" as const, marginBottom: 10 }}>Postgraduate Opportunities</div>
            <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(24px,3.5vw,38px)", color: "#fff", lineHeight: 1.15 }}>
              200+ Masters Programs.<br />Every Country. Costs in USD.
            </h2>
          </div>
          <button onClick={() => nav("/masters")} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.gold, background: "rgba(255,198,46,0.1)", border: `1.5px solid rgba(255,198,46,0.25)`, borderRadius: 10, padding: "9px 18px", cursor: "pointer", display: "flex", alignItems: "center", gap: 5, flexShrink: 0 }}>
            Open Masters Database <ArrowRight size={13} />
          </button>
        </div>

        <p style={{ fontFamily: "Inter", fontSize: 15, color: "rgba(255,255,255,0.55)", marginBottom: 40, maxWidth: 600, lineHeight: 1.65 }}>
          Compare postgraduate dental programs by specialty, country, tuition, IELTS requirements, and Egyptian recognition — with costs converted to USD.
        </p>

        {/* Stats bar */}
        <div style={{ display: "flex", gap: 0, background: "rgba(255,255,255,0.04)", border: "1px solid rgba(255,255,255,0.08)", borderRadius: 16, marginBottom: 32, overflow: "hidden", flexWrap: "wrap" }}>
          {[["200+", "Programs Listed"], ["119", "Countries"], ["12", "Specialties"], ["Egyptian Recognition", "Filter Available"]].map(([v, l], i) => (
            <div key={l} style={{ flex: 1, minWidth: 120, padding: "20px 24px", borderRight: i < 3 ? "1px solid rgba(255,255,255,0.08)" : "none" }}>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.gold, marginBottom: 4 }}>{v}</div>
              <div style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.45)" }}>{l}</div>
            </div>
          ))}
        </div>

        {/* Country grid */}
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(240px, 1fr))", gap: 14 }}>
          {masterHighlights.map((c) => (
            <div key={c.country} onClick={() => nav("/masters")} style={{ background: "rgba(255,255,255,0.04)", border: "1px solid rgba(255,255,255,0.08)", borderRadius: 18, padding: "20px 22px", cursor: "pointer", transition: "all 0.2s" }}
              onMouseEnter={e => { const el = e.currentTarget as HTMLElement; el.style.background = "rgba(255,255,255,0.08)"; el.style.borderColor = "rgba(255,198,46,0.3)"; }}
              onMouseLeave={e => { const el = e.currentTarget as HTMLElement; el.style.background = "rgba(255,255,255,0.04)"; el.style.borderColor = "rgba(255,255,255,0.08)"; }}
            >
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 12 }}>
                <span style={{ fontSize: 28 }}>{c.flag}</span>
                <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: "rgba(255,255,255,0.4)", background: "rgba(255,255,255,0.06)", borderRadius: 6, padding: "3px 9px" }}>{c.programs} programs</span>
              </div>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: "#fff", marginBottom: 4 }}>{c.country}</div>
              <div style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.45)", marginBottom: 12 }}>{c.note}</div>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                <div>
                  <span style={{ fontFamily: "Inter", fontSize: 10, color: "rgba(255,255,255,0.35)" }}>From </span>
                  <span style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 16, color: brand.gold }}>{c.from}</span>
                  <span style={{ fontFamily: "Inter", fontSize: 10, color: "rgba(255,255,255,0.35)" }}>/year</span>
                </div>
                <ArrowRight size={14} color="rgba(255,255,255,0.3)" />
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

// ─── Career Abroad ────────────────────────────────────────────────────────────
const careerCountries = [
  { flag: "🇬🇧", name: "United Kingdom", badge: "ORE Route", slug: "uk", desc: "GDC registration, ORE Part 1 & 2, NHS or private pathway", color: "#012169" },
  { flag: "🇦🇪", name: "UAE", badge: "Fast Track", slug: "uae", desc: "DataFlow, Prometric DHA/DOH/MOH, tax-free salaries", color: "#00732F" },
  { flag: "🇦🇺", name: "Australia", badge: "ADC Pathway", slug: "australia", desc: "ADC Written + Practical, AHPRA registration, skilled migration", color: "#00843D" },
  { flag: "🇩🇪", name: "Germany", badge: "Approbation", slug: "germany", desc: "B2 German, Approbation process, highest EU dental salaries", color: "#DD0000" },
  { flag: "🇨🇦", name: "Canada", badge: "NDEB Route", slug: "canada", desc: "NDEB AFK → Written → OSCE, PR via Express Entry", color: "#FF0000" },
  { flag: "🇸🇦", name: "Saudi Arabia", badge: "Direct Hire", slug: "ksa", desc: "SLE Prometric, SCFHS registration, tax-free + housing", color: "#006C35" },
  { flag: "🇺🇸", name: "United States", badge: "Advanced DDS", slug: "usa", desc: "INBDE, Advanced Standing DDS program, highest salaries globally", color: "#3C3B6E" },
  { flag: "🇮🇪", name: "Ireland", badge: "EU Gateway", slug: "ireland", desc: "RCSI qualifying exam, Critical Skills visa, EU reciprocity", color: "#169B62" },
  { flag: "🇶🇦", name: "Qatar", badge: "Fast Track", slug: "qatar", desc: "QCHP Prometric, DataFlow, excellent tax-free packages in Doha", color: "#8D1B3D" },
  { flag: "🇰🇼", name: "Kuwait", badge: "Fast Track", slug: "kuwait", desc: "MOH Kuwait Prometric, Egyptian dentists widely employed", color: "#007A3D" },
  { flag: "🇳🇿", name: "New Zealand", badge: "ADC Pathway", slug: "new-zealand", desc: "ADC exam accepted by DCNZ, Skilled Migrant residency pathway", color: "#00247D" },
  { flag: "🇸🇬", name: "Singapore", badge: "SDC Exam", slug: "singapore", desc: "SDC Qualifying Exam Part 1 & 2, high-income private sector", color: "#EF3340" },
];

function CareerAbroadSection() {
  const nav = useNavigate();
  return (
    <section style={{ background: brand.offWhite, padding: "72px 0" }}>
      <div style={{ maxWidth: 1280, margin: "0 auto", padding: "0 24px" }}>

        <div style={{ display: "flex", gap: 48, alignItems: "flex-start", flexWrap: "wrap", marginBottom: 48 }}>
          <div style={{ flex: 1, minWidth: 280 }}>
            <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, letterSpacing: "0.12em", color: brand.orange, textTransform: "uppercase" as const, marginBottom: 10 }}>Career Abroad</div>
            <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(24px,3.5vw,38px)", color: brand.charcoal, lineHeight: 1.15, marginBottom: 16 }}>
              Practice Dentistry Anywhere in the World
            </h2>
            <p style={{ fontFamily: "Inter", fontSize: 15, color: brand.warmGray, lineHeight: 1.65, marginBottom: 24 }}>
              Step-by-step licensing guides across 23 countries — cost breakdowns in USD, exam preparation, and personalised roadmaps for Egyptian dentists going abroad.
            </p>
            <div style={{ display: "flex", gap: 10, flexWrap: "wrap" }}>
              <button onClick={() => nav("/career/roadmap")} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 11, padding: "12px 22px", cursor: "pointer", display: "flex", alignItems: "center", gap: 7, boxShadow: "0 3px 12px rgba(255,107,26,0.3)" }}>
                <Sparkles size={14} /> Build My Roadmap
              </button>
              <button onClick={() => nav("/career")} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.charcoal, background: brand.white, border: `1.5px solid ${brand.borderGray}`, borderRadius: 11, padding: "12px 20px", cursor: "pointer", display: "flex", alignItems: "center", gap: 7 }}>
                Explore Countries <ArrowRight size={14} />
              </button>
            </div>
          </div>

          {/* AI Roadmap card */}
          <div style={{ background: brand.charcoal, borderRadius: 24, padding: "28px", width: 320, flexShrink: 0 }}>
            <div style={{ display: "inline-flex", alignItems: "center", gap: 6, background: "rgba(255,170,24,0.15)", border: "1px solid rgba(255,170,24,0.25)", borderRadius: 8, padding: "4px 10px", marginBottom: 16 }}>
              <Sparkles size={12} color={brand.amber} />
              <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: brand.amber }}>AI-Powered</span>
            </div>
            <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: "#fff", marginBottom: 10, lineHeight: 1.3 }}>Your Personalised Career Roadmap</div>
            <div style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.55)", marginBottom: 20, lineHeight: 1.6 }}>Tell us your stage, goal country, and budget. Get a detailed step-by-step roadmap with timelines, costs, and Masters recommendations.</div>
            {[["Stage", "General Dentist · 3 years exp."], ["Goal", "Work in the UK"], ["Output", "ORE pathway · 18-month plan"]].map(([k, v]) => (
              <div key={k} style={{ display: "flex", justifyContent: "space-between", padding: "9px 0", borderBottom: "1px solid rgba(255,255,255,0.06)" }}>
                <span style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.4)" }}>{k}</span>
                <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: "#fff" }}>{v}</span>
              </div>
            ))}
            <button onClick={() => nav("/career/roadmap")} style={{ width: "100%", marginTop: 20, fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "12px", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 6, boxShadow: "0 3px 12px rgba(255,107,26,0.35)" }}>
              Generate My Roadmap <ArrowRight size={13} />
            </button>
          </div>
        </div>

        {/* Country cards */}
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(260px, 1fr))", gap: 16, marginBottom: 24 }}>
          {careerCountries.map((c) => (
            <div key={c.name} onClick={() => nav(`/career/${c.slug}`)} style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "22px", cursor: "pointer", transition: "transform 0.2s, box-shadow 0.2s" }}
              onMouseEnter={e => { const el = e.currentTarget as HTMLElement; el.style.transform = "translateY(-4px)"; el.style.boxShadow = "0 10px 28px rgba(27,27,27,0.1)"; }}
              onMouseLeave={e => { const el = e.currentTarget as HTMLElement; el.style.transform = "none"; el.style.boxShadow = "none"; }}
            >
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 14 }}>
                <span style={{ fontSize: 32 }}>{c.flag}</span>
                <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 10, color: "#fff", background: gradientFlow, borderRadius: 6, padding: "3px 9px" }}>{c.badge}</span>
              </div>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 16, color: brand.charcoal, marginBottom: 6 }}>{c.name}</div>
              <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, lineHeight: 1.55, marginBottom: 16 }}>{c.desc}</div>
              <div style={{ display: "flex", alignItems: "center", gap: 5, fontFamily: "Inter", fontSize: 12, fontWeight: 600, color: brand.orange }}>
                View Pathway <ArrowRight size={12} />
              </div>
            </div>
          ))}
        </div>

        {/* View all CTA */}
        <div style={{ textAlign: "center" as const }}>
          <button onClick={() => nav("/career")} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.warmGray, background: brand.white, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "13px 28px", cursor: "pointer", display: "inline-flex", alignItems: "center", gap: 8 }}>
            View all 23 countries <ArrowRight size={14} color={brand.orange} />
          </button>
          <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginTop: 10, opacity: 0.7 }}>
            Including Jordan, Norway, Denmark, Malaysia, South Africa, Switzerland, and more
          </div>
        </div>
      </div>
    </section>
  );
}

// ─── Exam Prep Strip ──────────────────────────────────────────────────────────
function ExamStrip() {
  const nav = useNavigate();
  const exams = [
    { short: "EDLE", name: "Egyptian Dental Licensing", flag: "🇪🇬", qs: "14,000+" },
    { short: "ORE", name: "Overseas Registration Exam", flag: "🇬🇧", qs: "6,200+" },
    { short: "DHA/DOH", name: "Prometric Gulf Exams", flag: "🇦🇪", qs: "9,000+" },
    { short: "ADC", name: "Australian Dental Council", flag: "🇦🇺", qs: "4,800+" },
    { short: "NDEB", name: "National Dental Board Canada", flag: "🇨🇦", qs: "5,100+" },
    { short: "INBDE", name: "International Board Exam USA", flag: "🇺🇸", qs: "8,500+" },
  ];
  return (
    <section style={{ background: `linear-gradient(135deg, ${brand.deepCharcoal} 0%, #1e1a17 100%)`, padding: "60px 0" }}>
      <div style={{ maxWidth: 1280, margin: "0 auto", padding: "0 24px" }}>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 28, flexWrap: "wrap", gap: 12 }}>
          <div>
            <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, letterSpacing: "0.12em", color: brand.amber, textTransform: "uppercase" as const, marginBottom: 8 }}>Licensing Exams</div>
            <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(20px,3vw,30px)", color: "#fff" }}>Prepare for Any Licensing Exam</h2>
          </div>
          <button onClick={() => nav("/exams")} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.amber, background: "rgba(255,170,24,0.1)", border: "1.5px solid rgba(255,170,24,0.25)", borderRadius: 10, padding: "9px 16px", cursor: "pointer", display: "flex", alignItems: "center", gap: 5 }}>
            All Exams <ArrowRight size={13} />
          </button>
        </div>
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(220px, 1fr))", gap: 12 }}>
          {exams.map((e) => (
            <div key={e.short} onClick={() => nav("/exams")} style={{ background: "rgba(255,255,255,0.04)", border: "1px solid rgba(255,255,255,0.08)", borderRadius: 16, padding: "18px 20px", cursor: "pointer", display: "flex", gap: 14, alignItems: "center", transition: "all 0.2s" }}
              onMouseEnter={el => { (el.currentTarget as HTMLElement).style.background = "rgba(255,255,255,0.07)"; (el.currentTarget as HTMLElement).style.borderColor = "rgba(255,198,46,0.3)"; }}
              onMouseLeave={el => { (el.currentTarget as HTMLElement).style.background = "rgba(255,255,255,0.04)"; (el.currentTarget as HTMLElement).style.borderColor = "rgba(255,255,255,0.08)"; }}
            >
              <span style={{ fontSize: 24, flexShrink: 0 }}>{e.flag}</span>
              <div>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.gold }}>{e.short}</div>
                <div style={{ fontFamily: "Inter", fontSize: 11, color: "rgba(255,255,255,0.45)", marginTop: 2 }}>{e.qs} questions</div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

// ─── Testimonials ─────────────────────────────────────────────────────────────
const testimonials = [
  { name: "Dr. Nour Abdelfattah", role: "General Dentist, Alexandria", highlight: "Passed ORE · Now working in UK", text: "Ejadah completely transformed my approach to the ORE. The question bank is the most detailed I've used — and the tutoring sessions with Dr. Omar filled every gap my self-study missed.", rating: 5, avatar: "https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=100&q=80" },
  { name: "Dr. Khaled Magdi", role: "Fresh Graduate, Cairo", highlight: "Found a tutor from Cairo University", text: "I was struggling with Oral Histology in my final year. My tutor through Ejadah was literally from my own faculty — knew exactly which slides the exam focused on. Passed with distinction.", rating: 5, avatar: "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=100&q=80" },
  { name: "Dr. Maha Sayed", role: "Consultant Prosthodontist", highlight: "Enrolled in UK Masters via Ejadah", text: "The Masters Database made comparing programs in USD so much easier. My consultant guided me through King's shortlisting, the personal statement, and ORE prep. I start in September.", rating: 5, avatar: "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=100&q=80" },
  { name: "Dr. Youssef Barakat", role: "Intern, Ain Shams University", highlight: "EGP 350/hr tutoring · Operative Dentistry", text: "I booked 4 sessions before my practical exam. My tutor was a lecturer from Ain Shams — he knew exactly what the faculty looks for. I went from barely passing to one of the top marks.", rating: 5, avatar: "https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=100&q=80" },
];

function Testimonials() {
  return (
    <section style={{ background: brand.paleGray, padding: "72px 0" }}>
      <div style={{ maxWidth: 1280, margin: "0 auto", padding: "0 24px" }}>
        <SectionHeader label="Community" title="What Ejadah Members Say" />
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(280px, 1fr))", gap: 18 }}>
          {testimonials.map((t) => (
            <div key={t.name} style={{ background: brand.white, borderRadius: 22, border: `1px solid ${brand.borderGray}`, padding: "26px 24px", display: "flex", flexDirection: "column" as const }}>
              <div style={{ display: "flex", gap: 2, marginBottom: 6 }}>
                {[1,2,3,4,5].map(i => <Star key={i} size={13} fill={brand.amber} color={brand.amber} />)}
              </div>
              <div style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 600, color: brand.orange, marginBottom: 14 }}>{t.highlight}</div>
              <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.charcoal, lineHeight: 1.65, flex: 1, marginBottom: 20, fontStyle: "italic" }}>"{t.text}"</p>
              <div style={{ display: "flex", gap: 12, alignItems: "center" }}>
                <img src={t.avatar} alt={t.name} style={{ width: 42, height: 42, borderRadius: "50%", objectFit: "cover" }} />
                <div>
                  <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.charcoal }}>{t.name}</div>
                  <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{t.role}</div>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

// ─── CTA ─────────────────────────────────────────────────────────────────────
function CTABanner() {
  const nav = useNavigate();
  return (
    <section style={{ background: gradientFlow, padding: "80px 24px", textAlign: "center" as const, position: "relative", overflow: "hidden" }}>
      <div style={{ position: "absolute", top: -100, left: "50%", transform: "translateX(-50%)", width: 480, height: 480, borderRadius: "50%", background: "rgba(255,255,255,0.07)", pointerEvents: "none" }} />
      <div style={{ position: "absolute", bottom: -60, right: -60, width: 280, height: 280, borderRadius: "50%", background: "rgba(255,255,255,0.05)", pointerEvents: "none" }} />
      <div style={{ position: "relative" }}>
        <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, letterSpacing: "0.12em", color: "rgba(255,255,255,0.7)", textTransform: "uppercase" as const, marginBottom: 16 }}>Join 40,000+ Dental Professionals</div>
        <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(28px,4vw,48px)", color: "#fff", marginBottom: 18, lineHeight: 1.12 }}>Start Your Dental Education Journey</h2>
        <p style={{ fontFamily: "Inter", fontSize: 16, color: "rgba(255,255,255,0.82)", marginBottom: 36, maxWidth: 520, margin: "0 auto 36px", lineHeight: 1.65 }}>
          Book your first tutoring session. Explore Masters programs. Build your career abroad roadmap. All free to start.
        </p>
        <div style={{ display: "flex", gap: 14, justifyContent: "center", flexWrap: "wrap" }}>
          <button onClick={() => nav("/register")} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: brand.orange, background: "#fff", border: "none", borderRadius: 12, padding: "14px 32px", cursor: "pointer", boxShadow: "0 4px 16px rgba(0,0,0,0.15)" }}>
            Create Free Account
          </button>
          <button onClick={() => nav("/tutoring")} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 15, color: "#fff", background: "rgba(255,255,255,0.15)", border: "1.5px solid rgba(255,255,255,0.4)", borderRadius: 12, padding: "14px 28px", cursor: "pointer" }}>
            Find a Tutor
          </button>
        </div>
      </div>
    </section>
  );
}

// ─── Logged-in dashboard home ─────────────────────────────────────────────────
const continueCourses = [
  { title: "Endodontic Retreatment: Advanced Techniques", instructor: "Dr. Sarah El-Sayed", specialty: "Endodontics", thumb: "https://images.unsplash.com/photo-1588776814546-daab30f310ce?w=400&q=80", progress: 68, remaining: "3h 20m left", id: "1" },
  { title: "Digital Smile Design Masterclass", instructor: "Dr. Karim Nasser", specialty: "Digital Dentistry", thumb: "https://images.unsplash.com/photo-1657470179447-0f5aa16daa91?w=400&q=80", progress: 41, remaining: "7h 10m left", id: "2" },
  { title: "Egyptian Licensing Exam — Full Prep", instructor: "Ejadah Exam Team", specialty: "Exam Prep", thumb: "https://images.unsplash.com/photo-1681939282781-341ac4f61996?w=400&q=80", progress: 22, remaining: "12h 45m left", id: "3" },
];

function LoggedInHome() {
  const nav = useNavigate();
  const { user } = useAuth();
  if (!user) return null;

  const hour = new Date().getHours();
  const greeting = hour < 12 ? "Good morning" : hour < 17 ? "Good afternoon" : "Good evening";
  const initial = (user.firstName[0] ?? "").toUpperCase();

  return (
    <div style={{ fontFamily: "Inter, sans-serif", background: brand.offWhite }}>
      {/* Personalized hero */}
      <section style={{ background: brand.charcoal, padding: "48px 0", position: "relative", overflow: "hidden" }}>
        <div style={{ position: "absolute", inset: 0, background: "radial-gradient(ellipse at 70% 50%, rgba(255,107,26,0.1) 0%, transparent 60%)", pointerEvents: "none" }} />
        <div style={{ maxWidth: 1280, margin: "0 auto", padding: "0 24px", position: "relative" }}>
          <div style={{ display: "flex", gap: 20, alignItems: "center", flexWrap: "wrap" }}>
            {/* Avatar */}
            <div style={{ width: 64, height: 64, borderRadius: 18, background: gradientFlow, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0, boxShadow: "0 4px 18px rgba(255,107,26,0.35)" }}>
              <span style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 26, color: "#fff" }}>{initial}</span>
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.5)", marginBottom: 4 }}>{greeting} 👋</div>
              <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(22px,3vw,34px)", color: "#fff", marginBottom: 6 }}>
                Welcome back, Dr. {user.firstName}
              </h1>
              <div style={{ display: "flex", gap: 12, flexWrap: "wrap" }}>
                <span style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.5)" }}>{roleLabels[user.role] ?? user.role}</span>
                <span style={{ color: "rgba(255,255,255,0.25)" }}>·</span>
                <span style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.5)" }}>{user.country}</span>
                <span style={{ color: "rgba(255,255,255,0.25)" }}>·</span>
                <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.amber }}>Member since {new Date(user.joinedAt).toLocaleDateString("en-GB", { month: "long", year: "numeric" })}</span>
              </div>
            </div>
            <div style={{ display: "flex", gap: 10, flexShrink: 0, flexWrap: "wrap" }}>
              <button onClick={() => nav("/dashboard")} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal, background: "#fff", border: "none", borderRadius: 10, padding: "10px 18px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}>
                <LayoutDashboard size={14} /> Dashboard
              </button>
              <button onClick={() => nav("/tutoring")} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "10px 18px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6, boxShadow: "0 2px 12px rgba(255,107,26,0.35)" }}>
                Find a Tutor <ArrowRight size={13} />
              </button>
            </div>
          </div>

          {/* Quick stats */}
          <div style={{ display: "flex", gap: 16, marginTop: 28, flexWrap: "wrap" }}>
            {[["3", "Courses In Progress"], ["68%", "Avg. Completion"], ["0", "Sessions Booked"], ["0", "Certificates Earned"]].map(([v, l]) => (
              <div key={l} style={{ background: "rgba(255,255,255,0.06)", border: "1px solid rgba(255,255,255,0.08)", borderRadius: 14, padding: "14px 20px", minWidth: 120 }}>
                <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.gold }}>{v}</div>
                <div style={{ fontFamily: "Inter", fontSize: 11, color: "rgba(255,255,255,0.45)", marginTop: 3 }}>{l}</div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Continue learning */}
      <section style={{ background: brand.offWhite, padding: "48px 0" }}>
        <div style={{ maxWidth: 1280, margin: "0 auto", padding: "0 24px" }}>
          <SectionHeader label="In Progress" title="Continue Learning" action="View All" onAction={() => nav("/dashboard")} />
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(300px, 1fr))", gap: 18 }}>
            {continueCourses.map((c) => (
              <div key={c.id} onClick={() => nav(`/courses/${c.id}`)} style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, overflow: "hidden", cursor: "pointer", transition: "transform 0.2s, box-shadow 0.2s" }}
                onMouseEnter={e => { (e.currentTarget as HTMLElement).style.transform = "translateY(-4px)"; (e.currentTarget as HTMLElement).style.boxShadow = "0 10px 28px rgba(27,27,27,0.1)"; }}
                onMouseLeave={e => { (e.currentTarget as HTMLElement).style.transform = "none"; (e.currentTarget as HTMLElement).style.boxShadow = "none"; }}
              >
                <div style={{ position: "relative", height: 140 }}>
                  <img src={c.thumb} alt={c.title} style={{ width: "100%", height: "100%", objectFit: "cover" }} />
                  <div style={{ position: "absolute", top: 10, left: 10 }}><GradientBadge small>{c.specialty}</GradientBadge></div>
                  {/* Progress bar overlay */}
                  <div style={{ position: "absolute", bottom: 0, left: 0, right: 0, height: 3, background: "rgba(255,255,255,0.2)" }}>
                    <div style={{ height: "100%", width: `${c.progress}%`, background: gradientFlow }} />
                  </div>
                </div>
                <div style={{ padding: "16px 18px" }}>
                  <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.charcoal, marginBottom: 4, lineHeight: 1.4 }}>{c.title}</div>
                  <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginBottom: 14 }}>{c.instructor}</div>
                  <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                    <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
                      <div style={{ width: 100, height: 5, background: brand.borderGray, borderRadius: 3, overflow: "hidden" }}>
                        <div style={{ height: "100%", width: `${c.progress}%`, background: gradientFlow, borderRadius: 3 }} />
                      </div>
                      <span style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 600, color: brand.orange }}>{c.progress}%</span>
                    </div>
                    <button onClick={e => { e.stopPropagation(); nav(`/courses/${c.id}/play`); }} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: "#fff", background: gradientFlow, border: "none", borderRadius: 8, padding: "7px 14px", cursor: "pointer", display: "flex", alignItems: "center", gap: 5 }}>
                      <Play size={11} fill="#fff" /> Continue
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Quick action cards */}
      <section style={{ background: brand.white, padding: "48px 0", borderTop: `1px solid ${brand.borderGray}` }}>
        <div style={{ maxWidth: 1280, margin: "0 auto", padding: "0 24px" }}>
          <SectionHeader label="For You" title="What Would You Like to Do?" />
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(240px, 1fr))", gap: 16 }}>
            {[
              { icon: "👨‍🏫", title: "Book a Tutoring Session", desc: "1-on-1 with verified specialists and university faculty", path: "/tutoring", cta: "Find a Tutor", gradient: true },
              { icon: "🗺️", title: "Build My Career Roadmap", desc: "AI-powered personalised plan for working abroad", path: "/career/roadmap", cta: "Generate Roadmap", gradient: false },
              { icon: "🎓", title: "Browse Masters Programs", desc: "200+ programs in 119 countries, costs in USD", path: "/masters", cta: "Open Database", gradient: false },
              { icon: "📝", title: "Practice Exam Questions", desc: "EDLE, ORE, ADC, Prometric — 14,000+ questions", path: "/exams", cta: "Start Practicing", gradient: false },
            ].map((item) => (
              <div key={item.title} onClick={() => nav(item.path)} style={{ background: brand.offWhite, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px", cursor: "pointer", transition: "transform 0.2s, box-shadow 0.2s" }}
                onMouseEnter={e => { (e.currentTarget as HTMLElement).style.transform = "translateY(-4px)"; (e.currentTarget as HTMLElement).style.boxShadow = "0 10px 24px rgba(27,27,27,0.08)"; }}
                onMouseLeave={e => { (e.currentTarget as HTMLElement).style.transform = "none"; (e.currentTarget as HTMLElement).style.boxShadow = "none"; }}
              >
                <div style={{ fontSize: 32, marginBottom: 14 }}>{item.icon}</div>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: brand.charcoal, marginBottom: 8 }}>{item.title}</div>
                <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, lineHeight: 1.55, marginBottom: 18 }}>{item.desc}</div>
                <div style={{ display: "inline-flex", alignItems: "center", gap: 5, fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: item.gradient ? "#fff" : brand.orange, background: item.gradient ? gradientFlow : "transparent", borderRadius: 8, padding: item.gradient ? "7px 14px" : "0", boxShadow: item.gradient ? "0 2px 8px rgba(255,107,26,0.28)" : "none" }}>
                  {item.cta} <ArrowRight size={12} />
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Tutoring + Masters + Career previews — same as marketing but compact */}
      <TutoringSection />
      <MastersSection />
      <CareerAbroadSection />
      <ExamStrip />
      <Testimonials />
    </div>
  );
}

// ─── Page ─────────────────────────────────────────────────────────────────────
export default function Home() {
  const { user } = useAuth();
  if (user) return <LoggedInHome />;
  return (
    <div style={{ fontFamily: "Inter, sans-serif", background: brand.offWhite }}>
      <Hero />
      <TutoringSection />
      <MastersSection />
      <CareerAbroadSection />
      <ExamStrip />
      <Testimonials />
      <CTABanner />
    </div>
  );
}
