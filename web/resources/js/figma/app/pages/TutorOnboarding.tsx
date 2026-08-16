import { useState } from "react";
import { useNavigate } from "react-router";
import {
  ChevronLeft, ChevronRight, CheckCircle, Upload, Plus, X,
  DollarSign, Clock, Star, Users, Shield, Award, Video,
  BookOpen, Calendar, ArrowRight, Globe, MapPin, Zap,
} from "lucide-react";
import { brand, gradientFlow, gradientGlow, GradientBadge } from "@/figma/app/shared";

// ─── Steps ───────────────────────────────────────────────────────────────────
const STEPS = [
  { id: 1, label: "Personal Info", icon: "👤" },
  { id: 2, label: "Qualifications", icon: "🎓" },
  { id: 3, label: "Subjects", icon: "📚" },
  { id: 4, label: "Pricing", icon: "💰" },
  { id: 5, label: "Availability", icon: "📅" },
  { id: 6, label: "Media", icon: "🎥" },
  { id: 7, label: "Verification", icon: "✅" },
  { id: 8, label: "Review & Submit", icon: "🚀" },
];

const SPECIALTIES = ["Endodontics", "Implantology", "Prosthodontics", "Orthodontics", "Oral Surgery", "Periodontics", "Pedodontics", "Digital Dentistry", "Dental Materials", "Oral Medicine", "Oral Pathology", "Restorative Dentistry", "Dental Photography", "Practice Management", "Research & Academia"];
const SUBJECTS_MAP: Record<string, string[]> = {
  "Endodontics": ["Root Canal Treatment", "Retreatment", "Calcified Canals", "Rotary Systems", "Irrigation Protocols", "Obturation", "EDLE Endodontics", "INBDE Endodontics"],
  "Implantology": ["Implant Planning", "Surgical Placement", "Bone Grafting", "Prosthetic Restoration", "All-on-4", "Immediate Loading"],
  "Prosthodontics": ["Fixed Prosthodontics", "Removable Prosthodontics", "Occlusion", "Digital Workflow", "Smile Design"],
  "Orthodontics": ["Orthodontic Mechanics", "Cephalometrics", "Aligner Therapy", "Retention", "EDLE Orthodontics"],
  "Oral Surgery": ["Exodontia", "Flap Design", "Impacted Molars", "Biopsy", "Surgical Anatomy", "ORE Surgery"],
  "Periodontics": ["Periodontal Disease", "Surgical Periodontics", "Implant Perio", "EDLE Periodontics"],
};
const LANGUAGES = ["Arabic", "English", "French", "German", "Italian", "Spanish"];
const DAYS = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
const TIME_SLOTS = ["8:00 AM", "10:00 AM", "12:00 PM", "2:00 PM", "4:00 PM", "6:00 PM", "8:00 PM", "10:00 PM"];

interface OnboardingState {
  // Step 1
  firstName: string; lastName: string; email: string; phone: string;
  country: string; city: string; title: string; bio: string;
  // Step 2
  degree: string; university: string; graduationYear: string;
  specialty: string; postgrad: string; publications: string; certifications: string[];
  // Step 3
  subjects: string[]; languages: string[]; teachingMode: "online" | "offline" | "both";
  // Step 4
  price60: string; price30: string; price15: string; currency: string;
  // Step 5
  availableDays: string[]; availableSlots: string[];
  // Step 6
  hasIntroVideo: boolean; uploadedCV: boolean; uploadedPhoto: boolean;
  // Step 7
  idVerified: boolean; agreedTerms: boolean; agreedCode: boolean;
}

const initial: OnboardingState = {
  firstName: "", lastName: "", email: "", phone: "",
  country: "Egypt", city: "", title: "", bio: "",
  degree: "", university: "", graduationYear: "", specialty: "",
  postgrad: "", publications: "", certifications: [],
  subjects: [], languages: [], teachingMode: "online",
  price60: "", price30: "", price15: "", currency: "EGP",
  availableDays: [], availableSlots: [],
  hasIntroVideo: false, uploadedCV: false, uploadedPhoto: false,
  idVerified: false, agreedTerms: false, agreedCode: false,
};

// ─── Helpers ─────────────────────────────────────────────────────────────────
function Label({ children }: { children: React.ReactNode }) {
  return <label style={{ display: "block", fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal, marginBottom: 6 }}>{children}</label>;
}

function Input({ value, onChange, placeholder, type = "text" }: { value: string; onChange: (v: string) => void; placeholder?: string; type?: string }) {
  return (
    <input
      type={type}
      value={value}
      onChange={(e) => onChange(e.target.value)}
      placeholder={placeholder}
      style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 16px", outline: "none", boxSizing: "border-box" as const, transition: "border-color 0.15s" }}
      onFocus={(e) => (e.target.style.borderColor = brand.orange)}
      onBlur={(e) => (e.target.style.borderColor = brand.borderGray)}
    />
  );
}

function Textarea({ value, onChange, placeholder, rows = 4 }: { value: string; onChange: (v: string) => void; placeholder?: string; rows?: number }) {
  return (
    <textarea
      value={value}
      onChange={(e) => onChange(e.target.value)}
      placeholder={placeholder}
      rows={rows}
      style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 16px", outline: "none", resize: "vertical", lineHeight: 1.6, boxSizing: "border-box" as const }}
      onFocus={(e) => (e.target.style.borderColor = brand.orange)}
      onBlur={(e) => (e.target.style.borderColor = brand.borderGray)}
    />
  );
}

function ChipToggle({ label, selected, onToggle }: { label: string; selected: boolean; onToggle: () => void }) {
  return (
    <button
      onClick={onToggle}
      style={{ fontFamily: "Inter", fontWeight: selected ? 600 : 400, fontSize: 13, color: selected ? "#fff" : brand.charcoal, background: selected ? gradientFlow : brand.offWhite, border: `1.5px solid ${selected ? "transparent" : brand.borderGray}`, borderRadius: 10, padding: "8px 14px", cursor: "pointer", transition: "all 0.15s", boxShadow: selected ? "0 2px 10px rgba(255,107,26,0.25)" : "none" }}
    >
      {selected && <CheckCircle size={11} style={{ marginRight: 5, verticalAlign: "middle" }} color="#fff" />}
      {label}
    </button>
  );
}

function UploadZone({ label, desc, uploaded, onUpload }: { label: string; desc: string; uploaded: boolean; onUpload: () => void }) {
  return (
    <div
      onClick={onUpload}
      style={{ border: `2px dashed ${uploaded ? brand.orange : brand.borderGray}`, borderRadius: 16, padding: "32px 20px", textAlign: "center" as const, cursor: "pointer", background: uploaded ? "rgba(255,107,26,0.03)" : "transparent", transition: "all 0.2s" }}
      onMouseEnter={(e) => { if (!uploaded) (e.currentTarget as HTMLElement).style.borderColor = brand.amber; }}
      onMouseLeave={(e) => { if (!uploaded) (e.currentTarget as HTMLElement).style.borderColor = brand.borderGray; }}
    >
      {uploaded ? (
        <>
          <div style={{ width: 48, height: 48, borderRadius: "50%", background: "rgba(45,155,104,0.1)", display: "flex", alignItems: "center", justifyContent: "center", margin: "0 auto 12px" }}>
            <CheckCircle size={24} color="#2D9B68" />
          </div>
          <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: "#2D9B68" }}>Uploaded successfully</div>
          <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginTop: 4 }}>Click to replace</div>
        </>
      ) : (
        <>
          <div style={{ width: 48, height: 48, borderRadius: 14, background: "rgba(255,107,26,0.08)", display: "flex", alignItems: "center", justifyContent: "center", margin: "0 auto 12px" }}>
            <Upload size={22} color={brand.orange} />
          </div>
          <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.charcoal }}>{label}</div>
          <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginTop: 4 }}>{desc}</div>
          <button style={{ marginTop: 12, fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.orange, background: "rgba(255,107,26,0.08)", border: "none", borderRadius: 8, padding: "8px 16px", cursor: "pointer" }}>Browse Files</button>
        </>
      )}
    </div>
  );
}

// ─── Earnings calculator ──────────────────────────────────────────────────────
function EarningsPreview({ price60, currency }: { price60: string; currency: string }) {
  const defaultPrice = currency === "USD" ? 50 : 400;
  const p = parseFloat(price60) || defaultPrice;
  const commission = 0.3;
  const perSession = currency === "USD" ? +(p * (1 - commission)).toFixed(2) : Math.round(p * (1 - commission));
  const monthlyStarter = currency === "USD" ? +(perSession * 20).toFixed(2) : perSession * 20;
  const monthlyMid     = currency === "USD" ? +(perSession * 50).toFixed(2) : perSession * 50;
  const monthlyTop     = currency === "USD" ? +(perSession * 90).toFixed(2) : perSession * 90;
  const sym = currency === "USD" ? "$" : "EGP ";

  return (
    <div style={{ background: brand.charcoal, borderRadius: 20, padding: "24px", marginTop: 24 }}>
      <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: "rgba(255,255,255,0.6)", marginBottom: 6 }}>Your earnings preview</div>
      <div style={{ fontFamily: "Inter", fontSize: 11, color: "rgba(255,255,255,0.4)", marginBottom: 14 }}>Based on {sym}{p}/hr · 70% goes to you after Ejadah's 30% service fee</div>
      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 12, marginBottom: 16 }}>
        {[["20 sessions/mo", monthlyStarter], ["50 sessions/mo", monthlyMid], ["90 sessions/mo", monthlyTop]].map(([label, val]) => (
          <div key={label as string} style={{ background: "rgba(255,255,255,0.06)", borderRadius: 12, padding: "14px 12px", textAlign: "center" as const }}>
            <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.gold }}>{sym}{(val as number).toLocaleString()}</div>
            <div style={{ fontFamily: "Inter", fontSize: 11, color: "rgba(255,255,255,0.45)", marginTop: 4 }}>{label as string}</div>
          </div>
        ))}
      </div>

      {/* Fee breakdown */}
      <div style={{ background: "rgba(255,255,255,0.05)", borderRadius: 14, padding: "16px 18px" }}>
        <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: "rgba(255,255,255,0.5)", letterSpacing: "0.08em", textTransform: "uppercase" as const, marginBottom: 10 }}>What the 30% covers</div>
        {[
          ["1.", "Payment processing & secure transactions", "Stripe & local gateway fees, fraud protection, chargebacks"],
          ["2.", "Student discovery & marketing", "SEO, paid ads, and platform promotion that bring students to you"],
          ["3.", "Booking system & calendar management", "Real-time scheduling, reminders, and no-show protection"],
          ["4.", "Video infrastructure & call hosting", "Dedicated video sessions with recording and playback"],
          ["5.", "Tutor profile hosting & verification", "Identity checks, credential badges, and profile maintenance"],
          ["6.", "Customer support", "Student and tutor support team available 7 days a week"],
          ["7.", "Liability & trust guarantee", "Session dispute resolution and refund management"],
        ].map(([n, title, detail]) => (
          <div key={n as string} style={{ display: "flex", gap: 10, marginBottom: 8, alignItems: "flex-start" }}>
            <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: brand.amber, flexShrink: 0, width: 16 }}>{n as string}</span>
            <div>
              <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: "rgba(255,255,255,0.7)" }}>{title as string}</div>
              <div style={{ fontFamily: "Inter", fontSize: 10, color: "rgba(255,255,255,0.35)", marginTop: 1, lineHeight: 1.4 }}>{detail as string}</div>
            </div>
          </div>
        ))}
      </div>

      <div style={{ marginTop: 14, fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.4)", lineHeight: 1.5 }}>
        Payouts processed weekly. No minimum payout threshold.
      </div>
    </div>
  );
}

// ─── Submitted screen ─────────────────────────────────────────────────────────
function Submitted({ onDone }: { onDone: () => void }) {
  const nav = useNavigate();
  return (
    <div style={{ textAlign: "center" as const, padding: "48px 0" }}>
      <div style={{ width: 80, height: 80, borderRadius: "50%", background: gradientFlow, display: "flex", alignItems: "center", justifyContent: "center", margin: "0 auto 24px", boxShadow: "0 8px 28px rgba(255,107,26,0.35)" }}>
        <CheckCircle size={38} color="#fff" />
      </div>
      <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 30, color: brand.charcoal, marginBottom: 10 }}>Application Submitted!</h2>
      <p style={{ fontFamily: "Inter", fontSize: 15, color: brand.warmGray, marginBottom: 36, maxWidth: 440, margin: "0 auto 36px", lineHeight: 1.65 }}>
        Thank you for applying to become an Ejadah tutor. Our team will review your application within <strong>3–5 business days</strong>. You'll receive an email with next steps.
      </p>

      {/* Status timeline */}
      <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "28px 24px", maxWidth: 460, margin: "0 auto 32px", textAlign: "left" as const }}>
        <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal, marginBottom: 20 }}>What happens next</div>
        {[
          { icon: "📋", title: "Application Review", desc: "Our team reviews your qualifications and teaching subjects.", status: "In Progress", color: brand.amber },
          { icon: "📞", title: "Onboarding Call", desc: "A 30-minute call with our tutor success team to set up your profile.", status: "Pending", color: brand.borderGray },
          { icon: "✅", title: "Profile Published", desc: "Your tutor profile goes live and students can start booking.", status: "Pending", color: brand.borderGray },
          { icon: "💰", title: "First Earnings", desc: "Complete your first session and receive payment within 7 days.", status: "Pending", color: brand.borderGray },
        ].map((item, i) => (
          <div key={item.title} style={{ display: "flex", gap: 14, alignItems: "flex-start", marginBottom: i < 3 ? 18 : 0, position: "relative" }}>
            {i < 3 && <div style={{ position: "absolute", left: 17, top: 34, width: 2, height: "calc(100% - 10px)", background: brand.borderGray }} />}
            <div style={{ width: 36, height: 36, borderRadius: "50%", background: i === 0 ? `${brand.amber}18` : brand.paleGray, border: `2px solid ${item.color}`, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0, fontSize: 16 }}>{item.icon}</div>
            <div style={{ flex: 1 }}>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.charcoal }}>{item.title}</div>
                <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: item.color, background: `${item.color}15`, borderRadius: 6, padding: "2px 8px" }}>{item.status}</span>
              </div>
              <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, marginTop: 3, lineHeight: 1.5 }}>{item.desc}</div>
            </div>
          </div>
        ))}
      </div>

      <div style={{ display: "flex", gap: 12, justifyContent: "center", flexWrap: "wrap" }}>
        <button onClick={() => nav("/dashboard")} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "13px 28px", cursor: "pointer" }}>Go to Dashboard</button>
        <button onClick={() => nav("/tutoring")} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "13px 24px", cursor: "pointer" }}>Browse Tutors</button>
      </div>
    </div>
  );
}

// ─── Page ─────────────────────────────────────────────────────────────────────
export default function TutorOnboarding() {
  const nav = useNavigate();
  const [step, setStep] = useState(0);
  const [submitted, setSubmitted] = useState(false);
  const [state, setState] = useState<OnboardingState>(initial);
  const [newCert, setNewCert] = useState("");

  const next = () => step < STEPS.length - 1 ? setStep(step + 1) : setSubmitted(true);
  const back = () => step > 0 ? setStep(step - 1) : nav("/tutoring");

  const toggleArr = (arr: string[], val: string): string[] =>
    arr.includes(val) ? arr.filter((x) => x !== val) : [...arr, val];

  const subjectsForSpecialty = state.specialty ? (SUBJECTS_MAP[state.specialty] ?? []) : Object.values(SUBJECTS_MAP).flat();

  if (submitted) {
    return (
      <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
        <div style={{ maxWidth: 760, margin: "0 auto", padding: "40px 24px" }}>
          <Submitted onDone={() => nav("/tutoring")} />
        </div>
      </div>
    );
  }

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      <div style={{ maxWidth: 1060, margin: "0 auto", padding: "28px 24px" }}>
        <button onClick={back} style={{ background: "none", border: "none", cursor: "pointer", color: brand.warmGray, fontFamily: "Inter", fontSize: 13, display: "flex", alignItems: "center", gap: 5, marginBottom: 24 }}>
          <ChevronLeft size={15} /> {step === 0 ? "Back to Tutoring" : "Previous Step"}
        </button>

        <div style={{ display: "flex", gap: 28, alignItems: "flex-start", flexWrap: "wrap" }}>
          {/* Main content */}
          <div style={{ flex: 1, minWidth: 300 }}>
            {/* Progress header */}
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "22px 26px", marginBottom: 22 }}>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 12 }}>
                <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal }}>
                  Step {step + 1} of {STEPS.length} — <span style={{ color: brand.orange }}>{STEPS[step].label}</span>
                </div>
                <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>{Math.round(((step + 1) / STEPS.length) * 100)}% complete</div>
              </div>
              {/* Progress bar */}
              <div style={{ display: "flex", gap: 4 }}>
                {STEPS.map((_, i) => (
                  <div key={i} style={{ flex: 1, height: 4, borderRadius: 2, background: i < step ? brand.orange : i === step ? brand.amber : brand.borderGray, transition: "background 0.3s" }} />
                ))}
              </div>
              {/* Step dots */}
              <div style={{ display: "flex", marginTop: 10, gap: 0 }}>
                {STEPS.map((s, i) => (
                  <div key={s.id} style={{ flex: 1, textAlign: "center" as const }}>
                    <div style={{ fontSize: 14 }}>{s.icon}</div>
                    <div style={{ fontFamily: "Inter", fontSize: 9, color: i <= step ? brand.orange : brand.borderGray, fontWeight: i === step ? 700 : 400, marginTop: 2 }}>{s.label}</div>
                  </div>
                ))}
              </div>
            </div>

            {/* Step content */}
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "32px 32px" }}>

              {/* ─ Step 1: Personal Info ─ */}
              {step === 0 && (
                <div>
                  <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 26, color: brand.charcoal, marginBottom: 6 }}>Personal Information</h2>
                  <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, marginBottom: 28 }}>Tell us about yourself. This forms the foundation of your tutor profile.</p>
                  <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 16, marginBottom: 16 }}>
                    <div><Label>First Name *</Label><Input value={state.firstName} onChange={(v) => setState({ ...state, firstName: v })} placeholder="Ahmed" /></div>
                    <div><Label>Last Name *</Label><Input value={state.lastName} onChange={(v) => setState({ ...state, lastName: v })} placeholder="Mostafa" /></div>
                  </div>
                  <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 16, marginBottom: 16 }}>
                    <div><Label>Email Address *</Label><Input value={state.email} onChange={(v) => setState({ ...state, email: v })} placeholder="dr.ahmed@example.com" type="email" /></div>
                    <div><Label>Phone Number *</Label><Input value={state.phone} onChange={(v) => setState({ ...state, phone: v })} placeholder="+20 100 000 0000" /></div>
                  </div>
                  <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 16, marginBottom: 16 }}>
                    <div>
                      <Label>Country *</Label>
                      <select value={state.country} onChange={(e) => setState({ ...state, country: e.target.value })} style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 16px", outline: "none", appearance: "none" as const }}>
                        {["Egypt", "Saudi Arabia", "UAE", "United Kingdom", "United States", "Australia", "Canada", "Germany"].map((c) => <option key={c}>{c}</option>)}
                      </select>
                    </div>
                    <div><Label>City *</Label><Input value={state.city} onChange={(v) => setState({ ...state, city: v })} placeholder="Cairo" /></div>
                  </div>
                  <div style={{ marginBottom: 16 }}>
                    <Label>Professional Title *</Label>
                    <Input value={state.title} onChange={(v) => setState({ ...state, title: v })} placeholder="e.g. Consultant Endodontist · PhD Cairo University" />
                  </div>
                  <div>
                    <Label>Short Bio * <span style={{ fontWeight: 400, color: brand.warmGray }}>(shown on your profile — min 100 characters)</span></Label>
                    <Textarea value={state.bio} onChange={(v) => setState({ ...state, bio: v })} placeholder="Tell students about your clinical background, teaching philosophy, and what makes your sessions unique…" rows={5} />
                    <div style={{ textAlign: "right" as const, fontFamily: "Inter", fontSize: 11, color: state.bio.length >= 100 ? "#2D9B68" : brand.warmGray, marginTop: 5 }}>{state.bio.length} / 100 min</div>
                  </div>
                </div>
              )}

              {/* ─ Step 2: Qualifications ─ */}
              {step === 1 && (
                <div>
                  <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 26, color: brand.charcoal, marginBottom: 6 }}>Qualifications & Experience</h2>
                  <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, marginBottom: 28 }}>Your academic background builds trust with students. Be thorough and accurate.</p>
                  <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 16, marginBottom: 16 }}>
                    <div><Label>Primary Degree *</Label><Input value={state.degree} onChange={(v) => setState({ ...state, degree: v })} placeholder="BDS / DMD / DDS" /></div>
                    <div><Label>University *</Label><Input value={state.university} onChange={(v) => setState({ ...state, university: v })} placeholder="Cairo University" /></div>
                  </div>
                  <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 16, marginBottom: 16 }}>
                    <div><Label>Graduation Year *</Label><Input value={state.graduationYear} onChange={(v) => setState({ ...state, graduationYear: v })} placeholder="2012" /></div>
                    <div>
                      <Label>Main Specialty *</Label>
                      <select value={state.specialty} onChange={(e) => setState({ ...state, specialty: e.target.value, subjects: [] })} style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 16px", outline: "none", appearance: "none" as const }}>
                        <option value="">Select specialty…</option>
                        {SPECIALTIES.map((s) => <option key={s}>{s}</option>)}
                      </select>
                    </div>
                  </div>
                  <div style={{ marginBottom: 16 }}>
                    <Label>Postgraduate Qualifications</Label>
                    <Textarea value={state.postgrad} onChange={(v) => setState({ ...state, postgrad: v })} placeholder="e.g. MSc Endodontics — Alexandria University (2016), Fellowship in Implantology — EDA (2018)…" rows={3} />
                  </div>
                  <div style={{ marginBottom: 20 }}>
                    <Label>Publications & Research</Label>
                    <Textarea value={state.publications} onChange={(v) => setState({ ...state, publications: v })} placeholder="List any published papers, research, or books (optional)…" rows={3} />
                  </div>
                  <div>
                    <Label>Certifications & Memberships</Label>
                    <div style={{ display: "flex", gap: 8, marginBottom: 10 }}>
                      <input value={newCert} onChange={(e) => setNewCert(e.target.value)} placeholder="Add a certification…" onKeyDown={(e) => { if (e.key === "Enter" && newCert.trim()) { setState({ ...state, certifications: [...state.certifications, newCert.trim()] }); setNewCert(""); } }}
                        style={{ flex: 1, fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "11px 16px", outline: "none" }} />
                      <button onClick={() => { if (newCert.trim()) { setState({ ...state, certifications: [...state.certifications, newCert.trim()] }); setNewCert(""); } }} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "11px 16px", cursor: "pointer", display: "flex", alignItems: "center", gap: 5 }}>
                        <Plus size={14} /> Add
                      </button>
                    </div>
                    <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
                      {state.certifications.map((c) => (
                        <span key={c} style={{ fontFamily: "Inter", fontSize: 12, color: brand.charcoal, background: brand.offWhite, border: `1px solid ${brand.borderGray}`, borderRadius: 8, padding: "5px 10px", display: "flex", alignItems: "center", gap: 6 }}>
                          {c}
                          <button onClick={() => setState({ ...state, certifications: state.certifications.filter((x) => x !== c) })} style={{ background: "none", border: "none", cursor: "pointer", color: brand.warmGray, display: "flex", padding: 0 }}><X size={12} /></button>
                        </span>
                      ))}
                    </div>
                  </div>
                </div>
              )}

              {/* ─ Step 3: Subjects ─ */}
              {step === 2 && (
                <div>
                  <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 26, color: brand.charcoal, marginBottom: 6 }}>Subjects & Languages</h2>
                  <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, marginBottom: 24 }}>Select the specific topics you can teach. Students search by subject, so choose carefully.</p>

                  <div style={{ marginBottom: 24 }}>
                    <Label>Teaching Subjects * <span style={{ fontWeight: 400, color: brand.warmGray }}>(select all that apply)</span></Label>
                    <div style={{ display: "flex", flexWrap: "wrap", gap: 8, marginTop: 8 }}>
                      {subjectsForSpecialty.map((s) => (
                        <ChipToggle key={s} label={s} selected={state.subjects.includes(s)} onToggle={() => setState({ ...state, subjects: toggleArr(state.subjects, s) })} />
                      ))}
                    </div>
                    {state.subjects.length > 0 && <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.orange, marginTop: 8 }}>{state.subjects.length} selected</div>}
                  </div>

                  <div style={{ marginBottom: 24 }}>
                    <Label>Teaching Languages *</Label>
                    <div style={{ display: "flex", flexWrap: "wrap", gap: 8, marginTop: 8 }}>
                      {LANGUAGES.map((l) => (
                        <ChipToggle key={l} label={l} selected={state.languages.includes(l)} onToggle={() => setState({ ...state, languages: toggleArr(state.languages, l) })} />
                      ))}
                    </div>
                  </div>

                  <div>
                    <Label>Session Format</Label>
                    <div style={{ display: "flex", gap: 12, marginTop: 8 }}>
                      {[
                        { v: "online" as const, label: "Online Only", icon: <Video size={16} color={state.teachingMode === "online" ? "#fff" : brand.orange} /> },
                        { v: "offline" as const, label: "In-Person Only", icon: <MapPin size={16} color={state.teachingMode === "offline" ? "#fff" : brand.warmGray} /> },
                        { v: "both" as const, label: "Both", icon: <Globe size={16} color={state.teachingMode === "both" ? "#fff" : brand.charcoal} /> },
                      ].map((opt) => (
                        <button key={opt.v} onClick={() => setState({ ...state, teachingMode: opt.v })} style={{ flex: 1, fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: state.teachingMode === opt.v ? "#fff" : brand.charcoal, background: state.teachingMode === opt.v ? gradientFlow : brand.offWhite, border: `1.5px solid ${state.teachingMode === opt.v ? "transparent" : brand.borderGray}`, borderRadius: 12, padding: "12px 8px", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 6, transition: "all 0.15s" }}>
                          {opt.icon} {opt.label}
                        </button>
                      ))}
                    </div>
                  </div>
                </div>
              )}

              {/* ─ Step 4: Pricing ─ */}
              {step === 3 && (
                <div>
                  <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 26, color: brand.charcoal, marginBottom: 6 }}>Set Your Pricing</h2>
                  <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, marginBottom: 28 }}>You keep 70% of every session. Set competitive rates — most Egypt-based tutors charge EGP 300–700/hour, international tutors $40–100/hour.</p>

                  <div style={{ display: "flex", gap: 12, marginBottom: 20 }}>
                    {["EGP", "USD"].map((c) => (
                      <button key={c} onClick={() => setState({ ...state, currency: c })} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: state.currency === c ? "#fff" : brand.charcoal, background: state.currency === c ? gradientFlow : brand.offWhite, border: `1.5px solid ${state.currency === c ? "transparent" : brand.borderGray}`, borderRadius: 10, padding: "10px 24px", cursor: "pointer", transition: "all 0.15s" }}>{c}</button>
                    ))}
                  </div>

                  <div style={{ display: "flex", flexDirection: "column" as const, gap: 14, marginBottom: 20 }}>
                    {[
                      { label: "60-minute session *", key: "price60" as const, placeholder: "e.g. 400", note: "Standard full session" },
                      { label: "30-minute session", key: "price30" as const, placeholder: "e.g. 225", note: "Typically ~55–60% of 60-min rate" },
                      { label: "15-minute session", key: "price15" as const, placeholder: "e.g. 125", note: "Quick check-in / single question" },
                    ].map((field) => (
                      <div key={field.key}>
                        <Label>{field.label}</Label>
                        <div style={{ display: "flex", gap: 12, alignItems: "center" }}>
                          <div style={{ position: "relative", flex: 1 }}>
                            <span style={{ position: "absolute", left: 14, top: "50%", transform: "translateY(-50%)", fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.warmGray }}>{state.currency}</span>
                            <input value={(state as any)[field.key]} onChange={(e) => setState({ ...state, [field.key]: e.target.value })} placeholder={field.placeholder} type="number" min="0"
                              style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 16px 12px 52px", outline: "none", boxSizing: "border-box" as const }} />
                          </div>
                          <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, whiteSpace: "nowrap" as const }}>{field.note}</span>
                        </div>
                      </div>
                    ))}
                  </div>

                  <EarningsPreview price60={state.price60} currency={state.currency} />
                </div>
              )}

              {/* ─ Step 5: Availability ─ */}
              {step === 4 && (
                <div>
                  <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 26, color: brand.charcoal, marginBottom: 6 }}>Your Availability</h2>
                  <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, marginBottom: 24 }}>Choose your typical available days and times. You can fine-tune this anytime from your dashboard.</p>

                  <div style={{ marginBottom: 24 }}>
                    <Label>Available Days *</Label>
                    <div style={{ display: "flex", flexWrap: "wrap", gap: 8, marginTop: 8 }}>
                      {DAYS.map((d) => (
                        <ChipToggle key={d} label={d} selected={state.availableDays.includes(d)} onToggle={() => setState({ ...state, availableDays: toggleArr(state.availableDays, d) })} />
                      ))}
                    </div>
                  </div>

                  <div style={{ marginBottom: 24 }}>
                    <Label>Preferred Time Slots *</Label>
                    <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(120px, 1fr))", gap: 8, marginTop: 8 }}>
                      {TIME_SLOTS.map((t) => (
                        <ChipToggle key={t} label={t} selected={state.availableSlots.includes(t)} onToggle={() => setState({ ...state, availableSlots: toggleArr(state.availableSlots, t) })} />
                      ))}
                    </div>
                  </div>

                  {/* Availability summary */}
                  {(state.availableDays.length > 0 || state.availableSlots.length > 0) && (
                    <div style={{ background: "rgba(255,107,26,0.05)", border: `1px solid rgba(255,107,26,0.2)`, borderRadius: 14, padding: "16px 18px" }}>
                      <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.orange, marginBottom: 8 }}>Your availability summary</div>
                      {state.availableDays.length > 0 && <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, marginBottom: 4 }}>📅 {state.availableDays.join(", ")}</div>}
                      {state.availableSlots.length > 0 && <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal }}>🕐 {state.availableSlots.join(", ")}</div>}
                    </div>
                  )}
                </div>
              )}

              {/* ─ Step 6: Media ─ */}
              {step === 5 && (
                <div>
                  <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 26, color: brand.charcoal, marginBottom: 6 }}>Profile Media</h2>
                  <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, marginBottom: 28 }}>Tutors with a photo and intro video get <strong>3× more bookings</strong>. The intro video is 2–3 minutes — just introduce yourself and your teaching style.</p>

                  <div style={{ display: "flex", flexDirection: "column" as const, gap: 16 }}>
                    <UploadZone
                      label="Profile Photo"
                      desc="JPG or PNG · Min 400×400px · Professional headshot"
                      uploaded={state.uploadedPhoto}
                      onUpload={() => setState({ ...state, uploadedPhoto: !state.uploadedPhoto })}
                    />
                    <UploadZone
                      label="Introduction Video"
                      desc="MP4 or MOV · Max 5 min · Introduce yourself and your teaching approach"
                      uploaded={state.hasIntroVideo}
                      onUpload={() => setState({ ...state, hasIntroVideo: !state.hasIntroVideo })}
                    />
                    <UploadZone
                      label="CV / Resume"
                      desc="PDF · Include qualifications, experience, and publications"
                      uploaded={state.uploadedCV}
                      onUpload={() => setState({ ...state, uploadedCV: !state.uploadedCV })}
                    />
                  </div>

                  <div style={{ marginTop: 20, background: brand.offWhite, borderRadius: 14, padding: "14px 16px", fontFamily: "Inter", fontSize: 12, color: brand.warmGray, lineHeight: 1.6 }}>
                    💡 <strong>Tip:</strong> Record your video in a quiet, well-lit room. Speak clearly and mention the subjects you teach and the types of students you work best with.
                  </div>
                </div>
              )}

              {/* ─ Step 7: Verification ─ */}
              {step === 6 && (
                <div>
                  <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 26, color: brand.charcoal, marginBottom: 6 }}>Identity Verification</h2>
                  <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, marginBottom: 28 }}>We verify every tutor to protect our students. Your information is stored securely and never shared with third parties.</p>

                  <div style={{ background: brand.white, border: `1px solid ${brand.borderGray}`, borderRadius: 18, padding: "24px", marginBottom: 20 }}>
                    <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: brand.charcoal, marginBottom: 16 }}>Required documents</div>
                    <div style={{ display: "flex", flexDirection: "column" as const, gap: 12 }}>
                      {[
                        { label: "National ID or Passport", desc: "Clear photo of the front side" },
                        { label: "Dental Degree Certificate", desc: "Scanned copy of your official degree" },
                        { label: "Syndicate Membership", desc: "Current Egyptian Dental Syndicate card (or equivalent)" },
                      ].map((doc) => (
                        <div key={doc.label} onClick={() => setState({ ...state, idVerified: !state.idVerified })} style={{ display: "flex", gap: 14, alignItems: "flex-start", background: brand.offWhite, borderRadius: 12, padding: "14px 16px", cursor: "pointer", border: `1.5px solid ${state.idVerified ? brand.orange : brand.borderGray}`, transition: "border-color 0.15s" }}>
                          <div style={{ width: 36, height: 36, borderRadius: 10, background: "rgba(255,107,26,0.08)", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                            <Upload size={16} color={brand.orange} />
                          </div>
                          <div style={{ flex: 1 }}>
                            <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.charcoal }}>{doc.label}</div>
                            <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginTop: 2 }}>{doc.desc}</div>
                          </div>
                          {state.idVerified && <CheckCircle size={18} color="#2D9B68" />}
                        </div>
                      ))}
                    </div>
                  </div>

                  {/* Terms */}
                  <div style={{ display: "flex", flexDirection: "column" as const, gap: 12 }}>
                    {[
                      { key: "agreedTerms" as const, label: "I agree to Ejadah's Tutor Terms of Service and understand the service fee structure (70% to tutor, 30% platform fee covering payments, marketing, booking, video, support, and trust services)." },
                      { key: "agreedCode" as const, label: "I agree to uphold Ejadah's professional code of conduct, including patient privacy, academic honesty, and respectful communication." },
                    ].map((item) => (
                      <div key={item.key} onClick={() => setState({ ...state, [item.key]: !state[item.key] })} style={{ display: "flex", gap: 12, alignItems: "flex-start", cursor: "pointer" }}>
                        <div style={{ width: 22, height: 22, borderRadius: 6, border: `2px solid ${state[item.key] ? brand.orange : brand.borderGray}`, background: state[item.key] ? "rgba(255,107,26,0.08)" : "transparent", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0, marginTop: 1, transition: "all 0.15s" }}>
                          {state[item.key] && <CheckCircle size={13} color={brand.orange} />}
                        </div>
                        <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, lineHeight: 1.55 }}>{item.label}</span>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* ─ Step 8: Review & Submit ─ */}
              {step === 7 && (
                <div>
                  <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 26, color: brand.charcoal, marginBottom: 6 }}>Review & Submit</h2>
                  <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, marginBottom: 24 }}>Review your application before submitting. You can go back to edit any section.</p>

                  {[
                    {
                      title: "Personal Info", step: 0,
                      rows: [["Name", `${state.firstName} ${state.lastName}`.trim() || "—"], ["Location", [state.city, state.country].filter(Boolean).join(", ") || "—"], ["Title", state.title || "—"]],
                    },
                    {
                      title: "Qualifications", step: 1,
                      rows: [["Degree", state.degree || "—"], ["University", state.university || "—"], ["Specialty", state.specialty || "—"], ["Certifications", state.certifications.length > 0 ? `${state.certifications.length} added` : "None"]],
                    },
                    {
                      title: "Subjects", step: 2,
                      rows: [["Subjects", state.subjects.length > 0 ? `${state.subjects.length} selected` : "None"], ["Languages", state.languages.join(", ") || "—"], ["Format", state.teachingMode]],
                    },
                    {
                      title: "Pricing", step: 3,
                      rows: [["60 min", state.price60 ? `${state.currency} ${state.price60}` : "—"], ["30 min", state.price30 ? `${state.currency} ${state.price30}` : "—"], ["15 min", state.price15 ? `${state.currency} ${state.price15}` : "—"]],
                    },
                    {
                      title: "Availability", step: 4,
                      rows: [["Days", state.availableDays.length > 0 ? `${state.availableDays.length} days` : "None"], ["Slots", state.availableSlots.length > 0 ? `${state.availableSlots.length} time slots` : "None"]],
                    },
                    {
                      title: "Media", step: 5,
                      rows: [["Photo", state.uploadedPhoto ? "✓ Uploaded" : "Not uploaded"], ["Intro Video", state.hasIntroVideo ? "✓ Uploaded" : "Not uploaded"], ["CV", state.uploadedCV ? "✓ Uploaded" : "Not uploaded"]],
                    },
                  ].map((section) => (
                    <div key={section.title} style={{ background: brand.offWhite, borderRadius: 16, border: `1px solid ${brand.borderGray}`, padding: "18px 20px", marginBottom: 14 }}>
                      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 12 }}>
                        <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal }}>{section.title}</div>
                        <button onClick={() => setStep(section.step)} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.orange, background: "none", border: "none", cursor: "pointer" }}>Edit</button>
                      </div>
                      {section.rows.map(([l, v]) => (
                        <div key={l as string} style={{ display: "flex", justifyContent: "space-between", marginBottom: 6 }}>
                          <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray }}>{l as string}</span>
                          <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal }}>{v as string}</span>
                        </div>
                      ))}
                    </div>
                  ))}

                  <div style={{ background: "rgba(45,155,104,0.05)", border: "1px solid rgba(45,155,104,0.2)", borderRadius: 14, padding: "14px 18px", display: "flex", gap: 10, alignItems: "flex-start" }}>
                    <Shield size={16} color="#2D9B68" style={{ marginTop: 1, flexShrink: 0 }} />
                    <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, lineHeight: 1.55 }}>Your application will be reviewed by our team within <strong>3–5 business days</strong>. We'll contact you at <strong>{state.email || "your email"}</strong> with next steps.</span>
                  </div>
                </div>
              )}

              {/* Navigation */}
              <div style={{ display: "flex", justifyContent: "space-between", marginTop: 32, paddingTop: 24, borderTop: `1px solid ${brand.borderGray}` }}>
                <button onClick={back} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 14, color: brand.charcoal, background: "none", border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 22px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}>
                  <ChevronLeft size={15} /> Back
                </button>
                <button onClick={next} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "12px 28px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6, boxShadow: "0 3px 12px rgba(255,107,26,0.3)" }}>
                  {step === STEPS.length - 1 ? "Submit Application" : "Continue"} <ChevronRight size={15} />
                </button>
              </div>
            </div>
          </div>

          {/* Sidebar */}
          <div style={{ width: 280, flexShrink: 0 }}>
            <div style={{ position: "sticky", top: 88, display: "flex", flexDirection: "column" as const, gap: 16 }}>
              {/* Why join */}
              <div style={{ background: brand.charcoal, borderRadius: 20, padding: "22px 20px" }}>
                <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: "#fff", marginBottom: 16 }}>Why teach on Ejadah?</div>
                {[
                  { icon: <DollarSign size={15} color={brand.gold} />, text: "Earn EGP 7,000–30,000/month easily, on your schedule" },
                  { icon: <Users size={15} color={brand.amber} />, text: "Access to 40,000+ verified dental professionals" },
                  { icon: <Zap size={15} color={brand.orange} />, text: "Instant booking — no chasing students for payment" },
                  { icon: <Shield size={15} color={brand.red} />, text: "Secure payments with weekly payout" },
                  { icon: <Star size={15} color={brand.gold} />, text: "Build your reputation and expand your network" },
                  { icon: <Globe size={15} color={brand.amber} />, text: "Teach students from Egypt and across the world" },
                ].map((item, i) => (
                  <div key={i} style={{ display: "flex", gap: 10, alignItems: "flex-start", marginBottom: 12 }}>
                    <div style={{ width: 28, height: 28, borderRadius: 8, background: "rgba(255,255,255,0.06)", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>{item.icon}</div>
                    <span style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.65)", lineHeight: 1.5 }}>{item.text}</span>
                  </div>
                ))}
              </div>

              {/* Step checklist */}
              <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "20px" }}>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal, marginBottom: 14 }}>Application checklist</div>
                {STEPS.map((s, i) => (
                  <div key={s.id} style={{ display: "flex", gap: 10, alignItems: "center", padding: "6px 0", borderBottom: i < STEPS.length - 1 ? `1px solid ${brand.borderGray}` : "none" }}>
                    <div style={{ width: 22, height: 22, borderRadius: "50%", background: i < step ? gradientFlow : i === step ? brand.amber : brand.paleGray, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0, transition: "background 0.2s" }}>
                      {i < step ? <CheckCircle size={11} color="#fff" /> : <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 9, color: i === step ? brand.charcoal : brand.warmGray }}>{i + 1}</span>}
                    </div>
                    <span style={{ fontFamily: "Inter", fontSize: 12, color: i === step ? brand.charcoal : i < step ? brand.orange : brand.warmGray, fontWeight: i === step ? 600 : 400 }}>{s.icon} {s.label}</span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
