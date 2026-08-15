import { useState } from "react";
import { useNavigate } from "react-router";
import {
  CheckCircle, ArrowRight, Upload, X, Users, Globe,
  Video, MapPin, Clock, Building2, GraduationCap, Briefcase, User,
} from "lucide-react";
import { brand, gradientFlow, GradientBadge } from "@/app/shared";

const SPECIALTIES = ["Endodontics", "Implantology", "Prosthodontics", "Orthodontics", "Oral Surgery", "Periodontics", "Digital Dentistry", "Dental Photography", "Practice Management", "Research Methods", "Exam Preparation", "Other"];
const LEVELS = ["Beginner", "Intermediate", "Advanced", "Mixed Levels"];
const FORMATS = [
  { value: "online", label: "Online", icon: <Video size={16} />, desc: "Live video sessions — anywhere in the world" },
  { value: "offline", label: "In-Person", icon: <MapPin size={16} />, desc: "On-site at your clinic, university, or our Cairo center" },
  { value: "hybrid", label: "Hybrid", icon: <Globe size={16} />, desc: "Mix of online theory and in-person practical" },
];
const USE_CASES = [
  { value: "clinic", icon: <Building2 size={20} />, label: "Clinic Team Training", desc: "Upskill your dental team on a specific procedure or workflow" },
  { value: "university", icon: <GraduationCap size={20} />, label: "University Program", desc: "Custom academic program for a department or cohort" },
  { value: "corporate", icon: <Briefcase size={20} />, label: "Corporate Training", desc: "Enterprise training for dental corporates or groups" },
  { value: "private", icon: <User size={20} />, label: "Private Course", desc: "1-on-1 or small group tailored entirely to you" },
  { value: "workshop", icon: <Users size={20} />, label: "Private Workshop", desc: "Intensive hands-on workshop — your topic, your team" },
  { value: "exam", icon: <CheckCircle size={20} />, label: "Custom Exam Prep", desc: "Structured program built around a specific licensing exam" },
];

interface TrainingState {
  useCase: string; topic: string; specialty: string; level: string;
  outcome: string; format: string; participants: string;
  preferredInstructor: string; language: string; country: string;
  budget: string; hours: string; startDate: string; files: string[];
  requirements: string; name: string; email: string; phone: string; org: string;
}

const initial: TrainingState = {
  useCase: "", topic: "", specialty: "", level: "", outcome: "",
  format: "", participants: "", preferredInstructor: "", language: "Arabic & English",
  country: "Egypt", budget: "", hours: "", startDate: "", files: [],
  requirements: "", name: "", email: "", phone: "", org: "",
};

function Label({ children }: { children: React.ReactNode }) {
  return <label style={{ display: "block", fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal, marginBottom: 6 }}>{children}</label>;
}

function FieldInput({ value, onChange, placeholder, type = "text" }: { value: string; onChange: (v: string) => void; placeholder?: string; type?: string }) {
  return (
    <input type={type} value={value} onChange={(e) => onChange(e.target.value)} placeholder={placeholder}
      style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 16px", outline: "none", boxSizing: "border-box" as const }}
      onFocus={(e) => (e.target.style.borderColor = brand.orange)}
      onBlur={(e) => (e.target.style.borderColor = brand.borderGray)}
    />
  );
}

function Submitted({ state }: { state: TrainingState }) {
  const nav = useNavigate();
  return (
    <div style={{ textAlign: "center" as const, padding: "60px 24px" }}>
      <div style={{ width: 80, height: 80, borderRadius: "50%", background: gradientFlow, display: "flex", alignItems: "center", justifyContent: "center", margin: "0 auto 24px", boxShadow: "0 8px 28px rgba(255,107,26,0.35)" }}>
        <CheckCircle size={38} color="#fff" />
      </div>
      <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 30, color: brand.charcoal, marginBottom: 10 }}>Proposal Request Submitted</h2>
      <p style={{ fontFamily: "Inter", fontSize: 15, color: brand.warmGray, marginBottom: 36, maxWidth: 440, margin: "0 auto 36px", lineHeight: 1.65 }}>
        Our private training team will review your request and send a customised proposal to <strong>{state.email || "your email"}</strong> within <strong>48 hours</strong>.
      </p>
      <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "28px 24px", maxWidth: 480, margin: "0 auto 32px", textAlign: "left" as const }}>
        <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal, marginBottom: 16 }}>What happens next</div>
        {[
          { n: "1", title: "Proposal Review", desc: "Our team reviews your request and matches you with the right instructor(s)." },
          { n: "2", title: "Custom Quotation", desc: "You receive a tailored proposal with program outline, dates, and pricing." },
          { n: "3", title: "Approve & Plan", desc: "Review the proposal, request adjustments, and confirm the program." },
          { n: "4", title: "Pay & Schedule", desc: "Confirm payment and lock in your training dates." },
        ].map((s) => (
          <div key={s.n} style={{ display: "flex", gap: 12, alignItems: "flex-start", marginBottom: 14 }}>
            <div style={{ width: 28, height: 28, borderRadius: "50%", background: gradientFlow, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
              <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: "#fff" }}>{s.n}</span>
            </div>
            <div>
              <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.charcoal }}>{s.title}</div>
              <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, marginTop: 2, lineHeight: 1.5 }}>{s.desc}</div>
            </div>
          </div>
        ))}
      </div>
      <div style={{ display: "flex", gap: 12, justifyContent: "center", flexWrap: "wrap" }}>
        <button onClick={() => nav("/dashboard")} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "13px 28px", cursor: "pointer" }}>Go to Dashboard</button>
        <button onClick={() => nav("/tutoring")} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "13px 24px", cursor: "pointer" }}>Browse Tutoring</button>
      </div>
    </div>
  );
}

export default function PrivateTraining() {
  const nav = useNavigate();
  const [state, setState] = useState<TrainingState>(initial);
  const [submitted, setSubmitted] = useState(false);
  const [fileCount, setFileCount] = useState(0);

  if (submitted) {
    return (
      <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
        <Submitted state={state} />
      </div>
    );
  }

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Hero */}
      <div style={{ background: brand.charcoal, padding: "56px 24px 48px", position: "relative", overflow: "hidden" }}>
        <div style={{ position: "absolute", inset: 0, background: `radial-gradient(ellipse at 60% 40%, rgba(255,198,46,0.08) 0%, transparent 55%)`, pointerEvents: "none" }} />
        <div style={{ maxWidth: 1280, margin: "0 auto", position: "relative" }}>
          <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, letterSpacing: "0.1em", color: brand.gold, textTransform: "uppercase" as const, marginBottom: 10 }}>Professional Services</div>
          <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(28px,4vw,44px)", color: "#fff", marginBottom: 14 }}>Private & Tailored Training</h1>
          <p style={{ fontFamily: "Inter", fontSize: 16, color: "rgba(255,255,255,0.6)", maxWidth: 560, marginBottom: 28 }}>
            Fully customised dental education programs built around your team, timeline, and goals. For clinics, universities, corporates, and individuals.
          </p>
          <div style={{ display: "flex", gap: 28, flexWrap: "wrap" }}>
            {[["200+", "Custom Programs Delivered"], ["40+", "Specialties Covered"], ["24h", "Proposal Turnaround"], ["100%", "Custom Curriculum"]].map(([v, l]) => (
              <div key={l}><div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.gold }}>{v}</div><div style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.45)", marginTop: 2 }}>{l}</div></div>
            ))}
          </div>
        </div>
      </div>

      <div style={{ maxWidth: 1100, margin: "0 auto", padding: "40px 24px" }}>
        {/* Use cases */}
        <div style={{ marginBottom: 36 }}>
          <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 24, color: brand.charcoal, marginBottom: 6 }}>What type of training do you need?</h2>
          <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, marginBottom: 20 }}>Select the option that best describes your situation — we'll tailor the form to your needs.</p>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(240px, 1fr))", gap: 12 }}>
            {USE_CASES.map((uc) => {
              const isSel = state.useCase === uc.value;
              return (
                <div key={uc.value} onClick={() => setState({ ...state, useCase: uc.value })} style={{ background: isSel ? "rgba(255,107,26,0.04)" : brand.white, border: `2px solid ${isSel ? brand.orange : brand.borderGray}`, borderRadius: 16, padding: "18px 18px", cursor: "pointer", transition: "all 0.15s" }}>
                  <div style={{ display: "flex", gap: 12, alignItems: "flex-start" }}>
                    <div style={{ width: 40, height: 40, borderRadius: 12, background: isSel ? "rgba(255,107,26,0.12)" : brand.offWhite, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0, color: isSel ? brand.orange : brand.warmGray, transition: "all 0.15s" }}>{uc.icon}</div>
                    <div>
                      <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: isSel ? brand.orange : brand.charcoal }}>{uc.label}</div>
                      <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginTop: 3, lineHeight: 1.45 }}>{uc.desc}</div>
                    </div>
                    {isSel && <CheckCircle size={16} color={brand.orange} style={{ marginLeft: "auto", flexShrink: 0, marginTop: 2 }} />}
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        <div style={{ display: "flex", gap: 28, flexWrap: "wrap" }}>
          {/* Main form */}
          <div style={{ flex: 1, minWidth: 300 }}>
            <div style={{ background: brand.white, borderRadius: 22, border: `1px solid ${brand.borderGray}`, padding: "32px 32px", marginBottom: 20 }}>
              <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.charcoal, marginBottom: 24 }}>Training Details</h2>

              {/* Topic */}
              <div style={{ marginBottom: 18 }}>
                <Label>Training Topic / Subject *</Label>
                <FieldInput value={state.topic} onChange={(v) => setState({ ...state, topic: v })} placeholder="e.g. Advanced Rotary Endodontics, Full-Arch Implant Rehabilitation, Digital Photography Workflow…" />
              </div>

              {/* Specialty + Level */}
              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 16, marginBottom: 18 }}>
                <div>
                  <Label>Specialty *</Label>
                  <select value={state.specialty} onChange={(e) => setState({ ...state, specialty: e.target.value })} style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 16px", outline: "none", appearance: "none" as const }}>
                    <option value="">Select…</option>
                    {SPECIALTIES.map((s) => <option key={s}>{s}</option>)}
                  </select>
                </div>
                <div>
                  <Label>Level *</Label>
                  <select value={state.level} onChange={(e) => setState({ ...state, level: e.target.value })} style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 16px", outline: "none", appearance: "none" as const }}>
                    <option value="">Select…</option>
                    {LEVELS.map((l) => <option key={l}>{l}</option>)}
                  </select>
                </div>
              </div>

              {/* Outcome */}
              <div style={{ marginBottom: 18 }}>
                <Label>Desired Outcome * <span style={{ fontWeight: 400, color: brand.warmGray }}>(What should participants be able to do after this training?)</span></Label>
                <textarea value={state.outcome} onChange={(e) => setState({ ...state, outcome: e.target.value })} placeholder="e.g. Participants should be able to confidently perform rotary instrumentation on molar teeth, select appropriate file systems, and manage separated instruments…" rows={4}
                  style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 16px", outline: "none", resize: "vertical", lineHeight: 1.6, boxSizing: "border-box" as const }} />
              </div>

              {/* Format */}
              <div style={{ marginBottom: 18 }}>
                <Label>Preferred Format *</Label>
                <div style={{ display: "flex", gap: 10, marginTop: 4 }}>
                  {FORMATS.map((f) => {
                    const isSel = state.format === f.value;
                    return (
                      <button key={f.value} onClick={() => setState({ ...state, format: f.value })} style={{ flex: 1, fontFamily: "Inter", fontWeight: isSel ? 600 : 400, fontSize: 13, color: isSel ? "#fff" : brand.charcoal, background: isSel ? gradientFlow : brand.offWhite, border: `1.5px solid ${isSel ? "transparent" : brand.borderGray}`, borderRadius: 12, padding: "12px 8px", cursor: "pointer", display: "flex", flexDirection: "column" as const, alignItems: "center", gap: 5, transition: "all 0.15s" }}>
                        {f.icon}
                        <span>{f.label}</span>
                        <span style={{ fontSize: 10, opacity: 0.75, textAlign: "center" as const, lineHeight: 1.3 }}>{f.desc}</span>
                      </button>
                    );
                  })}
                </div>
              </div>

              {/* Participants + Hours */}
              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 16, marginBottom: 18 }}>
                <div>
                  <Label>Participants *</Label>
                  <FieldInput value={state.participants} onChange={(v) => setState({ ...state, participants: v })} placeholder="e.g. 5–10" />
                </div>
                <div>
                  <Label>Total Hours *</Label>
                  <FieldInput value={state.hours} onChange={(v) => setState({ ...state, hours: v })} placeholder="e.g. 20h" />
                </div>
                <div>
                  <Label>Target Start Date</Label>
                  <FieldInput value={state.startDate} onChange={(v) => setState({ ...state, startDate: v })} placeholder="e.g. July 2025" />
                </div>
              </div>

              {/* Language + Country */}
              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 16, marginBottom: 18 }}>
                <div>
                  <Label>Language of Instruction</Label>
                  <select value={state.language} onChange={(e) => setState({ ...state, language: e.target.value })} style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 16px", outline: "none", appearance: "none" as const }}>
                    {["Arabic & English", "Arabic only", "English only", "French", "German"].map((l) => <option key={l}>{l}</option>)}
                  </select>
                </div>
                <div>
                  <Label>Country / Location</Label>
                  <FieldInput value={state.country} onChange={(v) => setState({ ...state, country: v })} placeholder="Egypt" />
                </div>
              </div>

              {/* Budget */}
              <div style={{ marginBottom: 18 }}>
                <Label>Approximate Budget <span style={{ fontWeight: 400, color: brand.warmGray }}>(optional — helps us match the right instructor)</span></Label>
                <FieldInput value={state.budget} onChange={(v) => setState({ ...state, budget: v })} placeholder="e.g. EGP 15,000 – 25,000 total" />
              </div>

              {/* Preferred instructor */}
              <div style={{ marginBottom: 18 }}>
                <Label>Preferred Instructor <span style={{ fontWeight: 400, color: brand.warmGray }}>(optional)</span></Label>
                <FieldInput value={state.preferredInstructor} onChange={(v) => setState({ ...state, preferredInstructor: v })} placeholder="e.g. Dr. Amira Soliman, or leave blank for us to match" />
              </div>

              {/* Special requirements */}
              <div style={{ marginBottom: 18 }}>
                <Label>Special Requirements or Notes</Label>
                <textarea value={state.requirements} onChange={(e) => setState({ ...state, requirements: e.target.value })} placeholder="Any equipment available, specific case types to cover, accessibility requirements, scheduling constraints…" rows={3}
                  style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 16px", outline: "none", resize: "vertical", lineHeight: 1.6, boxSizing: "border-box" as const }} />
              </div>

              {/* File upload */}
              <div style={{ marginBottom: 18 }}>
                <Label>Supporting Files <span style={{ fontWeight: 400, color: brand.warmGray }}>(optional — curriculum drafts, case lists, references)</span></Label>
                <div onClick={() => setFileCount((n) => n + 1)} style={{ border: `2px dashed ${brand.borderGray}`, borderRadius: 14, padding: "24px", textAlign: "center" as const, cursor: "pointer", transition: "border-color 0.2s" }}
                  onMouseEnter={(e) => ((e.currentTarget as HTMLElement).style.borderColor = brand.orange)}
                  onMouseLeave={(e) => ((e.currentTarget as HTMLElement).style.borderColor = brand.borderGray)}
                >
                  <Upload size={20} color={brand.orange} style={{ marginBottom: 8 }} />
                  <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.charcoal }}>Click to upload files</div>
                  <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginTop: 3 }}>PDF, DOCX, PPTX · Max 20 MB per file</div>
                </div>
                {fileCount > 0 && (
                  <div style={{ marginTop: 10, fontFamily: "Inter", fontSize: 13, color: "#2D9B68" }}>
                    ✓ {fileCount} file{fileCount > 1 ? "s" : ""} attached
                  </div>
                )}
              </div>
            </div>

            {/* Contact details */}
            <div style={{ background: brand.white, borderRadius: 22, border: `1px solid ${brand.borderGray}`, padding: "32px 32px", marginBottom: 20 }}>
              <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.charcoal, marginBottom: 24 }}>Your Contact Details</h2>
              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 16, marginBottom: 16 }}>
                <div><Label>Full Name *</Label><FieldInput value={state.name} onChange={(v) => setState({ ...state, name: v })} placeholder="Dr. Ahmed Mostafa" /></div>
                <div><Label>Email Address *</Label><FieldInput value={state.email} onChange={(v) => setState({ ...state, email: v })} placeholder="dr.ahmed@clinic.com" type="email" /></div>
              </div>
              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 16 }}>
                <div><Label>Phone Number *</Label><FieldInput value={state.phone} onChange={(v) => setState({ ...state, phone: v })} placeholder="+20 100 000 0000" /></div>
                <div><Label>Organization / Clinic</Label><FieldInput value={state.org} onChange={(v) => setState({ ...state, org: v })} placeholder="Cairo Dental Center" /></div>
              </div>
            </div>

            <button onClick={() => setSubmitted(true)} style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 16, color: "#fff", background: gradientFlow, border: "none", borderRadius: 14, padding: "16px", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 10, boxShadow: "0 4px 20px rgba(255,107,26,0.35)" }}>
              Request Proposal <ArrowRight size={18} />
            </button>
            <div style={{ textAlign: "center" as const, fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginTop: 10 }}>
              No commitment required. You'll receive a tailored proposal within 48 hours.
            </div>
          </div>

          {/* Sidebar */}
          <div style={{ width: 280, flexShrink: 0 }}>
            <div style={{ position: "sticky", top: 88, display: "flex", flexDirection: "column" as const, gap: 16 }}>
              {/* Why private training */}
              <div style={{ background: brand.charcoal, borderRadius: 20, padding: "22px 20px" }}>
                <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 17, color: "#fff", marginBottom: 14 }}>Why choose private training?</div>
                {[
                  "100% customised to your curriculum and goals",
                  "Flexible dates and delivery format",
                  "Exclusive access to Ejadah's expert instructor network",
                  "Group discounts available for teams of 5+",
                  "Certificate of completion for all participants",
                  "Follow-up support included after delivery",
                ].map((item, i) => (
                  <div key={i} style={{ display: "flex", gap: 8, alignItems: "flex-start", marginBottom: 10 }}>
                    <CheckCircle size={13} color={brand.orange} style={{ marginTop: 1, flexShrink: 0 }} />
                    <span style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.65)", lineHeight: 1.5 }}>{item}</span>
                  </div>
                ))}
              </div>

              {/* Sample programs */}
              <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "20px" }}>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal, marginBottom: 14 }}>Sample programs delivered</div>
                {[
                  { label: "Implantology Masterclass", detail: "5 doctors · 3 days · Hybrid" },
                  { label: "EDLE Prep Intensive", detail: "20 students · 6 weeks · Online" },
                  { label: "Digital Workflow Training", detail: "Clinic team · 2 days · On-site" },
                  { label: "Endodontics Refresher", detail: "8 dentists · 1 day · Cairo" },
                ].map((p) => (
                  <div key={p.label} style={{ background: brand.offWhite, borderRadius: 10, padding: "10px 12px", marginBottom: 8 }}>
                    <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal }}>{p.label}</div>
                    <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginTop: 2 }}>{p.detail}</div>
                  </div>
                ))}
              </div>

              {/* Contact */}
              <div style={{ background: `rgba(255,107,26,0.06)`, border: `1px solid rgba(255,107,26,0.2)`, borderRadius: 16, padding: "18px 16px" }}>
                <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal, marginBottom: 6 }}>Prefer to talk first?</div>
                <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginBottom: 12, lineHeight: 1.5 }}>Call our private training team and we'll help scope your program before you fill the form.</div>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.orange }}>+20 1080818704</div>
                <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginTop: 4 }}>training@ejadah.international</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
