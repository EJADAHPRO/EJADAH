import { useState } from "react";
import { useNavigate, useParams } from "react-router";
import {
  CheckCircle, ChevronLeft, ChevronRight, Video, MapPin,
  Clock, Upload, CreditCard, Shield, Calendar, Star,
  ArrowRight, Zap, FileText, X,
} from "lucide-react";
import { brand, gradientFlow, GradientBadge } from "@/figma/app/shared";

// ─── Step config ──────────────────────────────────────────────────────────────
const STEPS = [
  { id: 1, label: "Subject" },
  { id: 2, label: "Duration" },
  { id: 3, label: "Date & Time" },
  { id: 4, label: "Your Goal" },
  { id: 5, label: "Files" },
  { id: 6, label: "Format" },
  { id: 7, label: "Review" },
  { id: 8, label: "Payment" },
];

// ─── Tutor stub ───────────────────────────────────────────────────────────────
const tutorStubs: Record<string, { name: string; specialty: string; avatar: string; rating: number; priceHour: number; price30: number; price15: number; subjects: string[] }> = {
  "1": { name: "Dr. Amira Soliman", specialty: "Endodontics", avatar: "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=120&q=80", rating: 4.9, priceHour: 350, price30: 195, price15: 110, subjects: ["Root Canal Treatment", "Retreatment", "Calcified Canals", "EDLE Endodontics", "INBDE Endodontics", "Pulp Biology", "Rotary Systems", "Irrigation Protocols", "Obturation Techniques"] },
  "2": { name: "Dr. Hany Ibrahim", specialty: "Oral Surgery", avatar: "https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=120&q=80", rating: 4.8, priceHour: 500, price30: 275, price15: 150, subjects: ["Exodontia", "Surgical Flap Design", "Impacted Third Molars", "EDLE Oral Surgery", "ORE Surgery", "Biopsy Techniques", "Surgical Anatomy"] },
};

// ─── Calendar ─────────────────────────────────────────────────────────────────
const calDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
const calDates = [
  { d: 22, day: "Sun", slots: [] },
  { d: 23, day: "Mon", slots: ["9:00 AM", "5:00 PM", "7:00 PM"] },
  { d: 24, day: "Tue", slots: ["11:00 AM", "3:00 PM", "9:00 PM"] },
  { d: 25, day: "Wed", slots: [] },
  { d: 26, day: "Thu", slots: ["9:00 AM", "1:00 PM", "7:00 PM"] },
  { d: 27, day: "Fri", slots: ["11:00 AM", "5:00 PM"] },
  { d: 28, day: "Sat", slots: ["1:00 PM", "3:00 PM", "9:00 PM"] },
];

// ─── Progress bar ─────────────────────────────────────────────────────────────
function StepProgress({ current, total }: { current: number; total: number }) {
  return (
    <div style={{ display: "flex", gap: 4 }}>
      {Array.from({ length: total }).map((_, i) => (
        <div
          key={i}
          style={{
            flex: 1, height: 4, borderRadius: 2,
            background: i < current ? brand.orange : i === current ? brand.amber : brand.borderGray,
            transition: "background 0.3s",
          }}
        />
      ))}
    </div>
  );
}

// ─── Section wrapper ──────────────────────────────────────────────────────────
function StepSection({ title, subtitle, children }: { title: string; subtitle?: string; children: React.ReactNode }) {
  return (
    <div>
      <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 26, color: brand.charcoal, marginBottom: subtitle ? 8 : 24 }}>{title}</h2>
      {subtitle && <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, marginBottom: 24, lineHeight: 1.6 }}>{subtitle}</p>}
      {children}
    </div>
  );
}

// ─── Confirmation screen ──────────────────────────────────────────────────────
function Confirmed({ tutor, state, onDone }: { tutor: typeof tutorStubs["1"]; state: BookingState; onDone: () => void }) {
  const nav = useNavigate();
  return (
    <div style={{ textAlign: "center" as const, padding: "40px 0" }}>
      {/* Animated checkmark */}
      <div style={{ width: 80, height: 80, borderRadius: "50%", background: gradientFlow, display: "flex", alignItems: "center", justifyContent: "center", margin: "0 auto 24px", boxShadow: "0 8px 28px rgba(255,107,26,0.35)" }}>
        <CheckCircle size={38} color="#fff" />
      </div>
      <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 30, color: brand.charcoal, marginBottom: 10 }}>Booking Confirmed!</h2>
      <p style={{ fontFamily: "Inter", fontSize: 15, color: brand.warmGray, marginBottom: 32, maxWidth: 420, margin: "0 auto 32px" }}>
        Your session with {tutor.name} has been booked. You'll receive a confirmation email with the meeting link.
      </p>

      {/* Booking summary card */}
      <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "28px 24px", maxWidth: 460, margin: "0 auto 32px", textAlign: "left" as const, boxShadow: "0 4px 20px rgba(27,27,27,0.06)" }}>
        <div style={{ display: "flex", gap: 14, alignItems: "center", marginBottom: 20, paddingBottom: 20, borderBottom: `1px solid ${brand.borderGray}` }}>
          <img src={tutor.avatar} alt={tutor.name} style={{ width: 52, height: 52, borderRadius: 14, objectFit: "cover" }} />
          <div>
            <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: brand.charcoal }}>{tutor.name}</div>
            <GradientBadge small>{tutor.specialty}</GradientBadge>
          </div>
        </div>
        {[
          ["Subject", state.subject],
          ["Date & Time", state.date ? `Jun ${state.date}, 2025 · ${state.slot}` : "—"],
          ["Duration", `${state.duration} minutes`],
          ["Format", state.format === "online" ? "Online (Video Call)" : "In-Person"],
          ["Reference", "#EJT-20250622-0041"],
        ].map(([label, value]) => (
          <div key={label as string} style={{ display: "flex", justifyContent: "space-between", marginBottom: 10 }}>
            <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray }}>{label as string}</span>
            <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal }}>{value as string}</span>
          </div>
        ))}
        <div style={{ height: 1, background: brand.borderGray, margin: "12px 0" }} />
        <div style={{ display: "flex", justifyContent: "space-between" }}>
          <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: brand.charcoal }}>Total Paid</span>
          <span style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.orange }}>EGP {state.duration === 60 ? tutor.priceHour : state.duration === 30 ? tutor.price30 : tutor.price15}</span>
        </div>
      </div>

      <div style={{ display: "flex", gap: 12, justifyContent: "center", flexWrap: "wrap" }}>
        <button onClick={() => nav("/dashboard")} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "13px 28px", cursor: "pointer" }}>Go to Dashboard</button>
        <button onClick={() => nav("/tutoring")} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "13px 24px", cursor: "pointer" }}>Browse More Tutors</button>
      </div>
    </div>
  );
}

// ─── Types ────────────────────────────────────────────────────────────────────
interface BookingState {
  subject: string;
  duration: 15 | 30 | 60;
  date: number | null;
  slot: string;
  goal: string;
  files: string[];
  format: "online" | "offline";
  cardNumber: string;
  cardName: string;
  cardExpiry: string;
  cardCvv: string;
}

// ─── Page ─────────────────────────────────────────────────────────────────────
export default function TutorBooking() {
  const { id } = useParams();
  const nav = useNavigate();
  const tutor = tutorStubs[id ?? "1"] ?? tutorStubs["1"];

  const [step, setStep] = useState(0); // 0-indexed
  const [confirmed, setConfirmed] = useState(false);
  const [state, setState] = useState<BookingState>({
    subject: "",
    duration: 60,
    date: null,
    slot: "",
    goal: "",
    files: [],
    format: "online",
    cardNumber: "",
    cardName: "",
    cardExpiry: "",
    cardCvv: "",
  });

  const price = state.duration === 60 ? tutor.priceHour : state.duration === 30 ? tutor.price30 : tutor.price15;

  const canProceed = () => {
    if (step === 0) return !!state.subject;
    if (step === 2) return !!state.date && !!state.slot;
    if (step === 3) return state.goal.length >= 20;
    if (step === 7) return state.cardNumber.length >= 16 && state.cardName && state.cardExpiry && state.cardCvv.length === 3;
    return true;
  };

  const next = () => { if (step < STEPS.length - 1) setStep(step + 1); else setConfirmed(true); };
  const back = () => { if (step > 0) setStep(step - 1); };

  if (confirmed) {
    return (
      <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
        <div style={{ maxWidth: 760, margin: "0 auto", padding: "40px 24px" }}>
          <Confirmed tutor={tutor} state={state} onDone={() => nav("/dashboard")} />
        </div>
      </div>
    );
  }

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      <div style={{ maxWidth: 1060, margin: "0 auto", padding: "28px 24px" }}>
        {/* Back */}
        <button onClick={() => step === 0 ? nav(`/tutoring/${id}`) : back()} style={{ background: "none", border: "none", cursor: "pointer", color: brand.warmGray, fontFamily: "Inter", fontSize: 13, display: "flex", alignItems: "center", gap: 5, marginBottom: 24 }}>
          <ChevronLeft size={15} /> {step === 0 ? "Back to Profile" : "Previous Step"}
        </button>

        <div style={{ display: "flex", gap: 28, alignItems: "flex-start", flexWrap: "wrap" }}>
          {/* Main form */}
          <div style={{ flex: 1, minWidth: 300 }}>
            {/* Progress */}
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px 26px", marginBottom: 24 }}>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 12 }}>
                <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal }}>
                  Step {step + 1} of {STEPS.length} — <span style={{ color: brand.orange }}>{STEPS[step].label}</span>
                </div>
                <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>{Math.round(((step + 1) / STEPS.length) * 100)}% complete</div>
              </div>
              <StepProgress current={step + 1} total={STEPS.length} />
              {/* Step labels */}
              <div style={{ display: "flex", gap: 0, marginTop: 10 }}>
                {STEPS.map((s, i) => (
                  <div key={s.id} style={{ flex: 1, textAlign: "center" as const }}>
                    <div style={{ fontFamily: "Inter", fontSize: 9, color: i <= step ? brand.orange : brand.borderGray, fontWeight: i === step ? 700 : 400, transition: "color 0.2s" }}>{s.label}</div>
                  </div>
                ))}
              </div>
            </div>

            {/* Step content */}
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "32px 32px" }}>

              {/* Step 1 — Subject */}
              {step === 0 && (
                <StepSection title="What do you need help with?" subtitle="Choose the subject or topic you'd like to cover in this session.">
                  <div style={{ display: "flex", flexDirection: "column" as const, gap: 10 }}>
                    {tutor.subjects.map((s) => (
                      <button
                        key={s}
                        onClick={() => setState({ ...state, subject: s })}
                        style={{ fontFamily: "Inter", fontWeight: state.subject === s ? 600 : 400, fontSize: 14, color: state.subject === s ? "#fff" : brand.charcoal, background: state.subject === s ? gradientFlow : brand.offWhite, border: `1.5px solid ${state.subject === s ? "transparent" : brand.borderGray}`, borderRadius: 12, padding: "13px 18px", cursor: "pointer", textAlign: "left" as const, transition: "all 0.15s", display: "flex", alignItems: "center", justifyContent: "space-between", boxShadow: state.subject === s ? "0 3px 12px rgba(255,107,26,0.25)" : "none" }}
                      >
                        {s}
                        {state.subject === s && <CheckCircle size={16} color="#fff" />}
                      </button>
                    ))}
                    <div style={{ marginTop: 8 }}>
                      <input
                        placeholder="Or describe your own topic…"
                        value={tutor.subjects.includes(state.subject) ? "" : state.subject}
                        onChange={(e) => setState({ ...state, subject: e.target.value })}
                        style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 16px", outline: "none", boxSizing: "border-box" as const }}
                      />
                    </div>
                  </div>
                </StepSection>
              )}

              {/* Step 2 — Duration */}
              {step === 1 && (
                <StepSection title="Session duration" subtitle="Choose how long you'd like the session to be.">
                  <div style={{ display: "flex", flexDirection: "column" as const, gap: 14 }}>
                    {([
                      { duration: 15 as const, price: tutor.price15, label: "Quick check-in", desc: "Best for a single focused question or concept." },
                      { duration: 30 as const, price: tutor.price30, label: "Standard session", desc: "Cover 1–2 topics with time for Q&A." },
                      { duration: 60 as const, price: tutor.priceHour, label: "Full session", desc: "Deep-dive into a subject or exam topic area. Most popular." },
                    ] as const).map((opt) => {
                      const isSelected = state.duration === opt.duration;
                      return (
                        <button
                          key={opt.duration}
                          onClick={() => setState({ ...state, duration: opt.duration })}
                          style={{ background: isSelected ? "rgba(255,107,26,0.04)" : brand.offWhite, border: `2px solid ${isSelected ? brand.orange : brand.borderGray}`, borderRadius: 14, padding: "18px 20px", cursor: "pointer", textAlign: "left" as const, display: "flex", justifyContent: "space-between", alignItems: "center", transition: "all 0.15s" }}
                        >
                          <div>
                            <div style={{ display: "flex", gap: 10, alignItems: "center", marginBottom: 4 }}>
                              <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 16, color: isSelected ? brand.orange : brand.charcoal }}>{opt.duration} minutes</span>
                              <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>— {opt.label}</span>
                              {opt.duration === 60 && <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 10, color: "#fff", background: gradientFlow, borderRadius: 4, padding: "2px 7px" }}>POPULAR</span>}
                            </div>
                            <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray }}>{opt.desc}</div>
                          </div>
                          <div style={{ textAlign: "right" as const, flexShrink: 0, marginLeft: 16 }}>
                            <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: isSelected ? brand.orange : brand.charcoal }}>EGP {opt.price}</div>
                            {isSelected && <CheckCircle size={16} color={brand.orange} style={{ marginTop: 4 }} />}
                          </div>
                        </button>
                      );
                    })}
                  </div>
                </StepSection>
              )}

              {/* Step 3 — Date & Time */}
              {step === 2 && (
                <StepSection title="Choose a date & time" subtitle="All times shown in GMT+2 (Cairo). The tutor will confirm within 2 hours.">
                  {/* Date picker */}
                  <div style={{ display: "grid", gridTemplateColumns: "repeat(7, 1fr)", gap: 8, marginBottom: 24 }}>
                    {calDates.map((cal) => {
                      const hasSlots = cal.slots.length > 0;
                      const isSelected = state.date === cal.d;
                      return (
                        <button
                          key={cal.d}
                          onClick={() => hasSlots && setState({ ...state, date: cal.d, slot: "" })}
                          style={{ borderRadius: 12, padding: "10px 4px", background: isSelected ? gradientFlow : hasSlots ? brand.white : brand.paleGray, border: `1.5px solid ${isSelected ? "transparent" : hasSlots ? brand.borderGray : "transparent"}`, cursor: hasSlots ? "pointer" : "default", opacity: hasSlots ? 1 : 0.4, textAlign: "center" as const, transition: "all 0.15s" }}
                        >
                          <div style={{ fontFamily: "Inter", fontSize: 10, color: isSelected ? "rgba(255,255,255,0.7)" : brand.warmGray, marginBottom: 4 }}>{cal.day}</div>
                          <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 16, color: isSelected ? "#fff" : hasSlots ? brand.charcoal : brand.warmGray }}>Jun {cal.d}</div>
                          {hasSlots && !isSelected && <div style={{ width: 5, height: 5, borderRadius: "50%", background: brand.orange, margin: "4px auto 0" }} />}
                        </button>
                      );
                    })}
                  </div>

                  {/* Time slots */}
                  {state.date && (
                    <div>
                      <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal, marginBottom: 12 }}>Available times for Jun {state.date}:</div>
                      <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(120px, 1fr))", gap: 10 }}>
                        {(calDates.find((c) => c.d === state.date)?.slots ?? []).map((slot) => {
                          const isSelected = state.slot === slot;
                          return (
                            <button
                              key={slot}
                              onClick={() => setState({ ...state, slot })}
                              style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: isSelected ? "#fff" : brand.charcoal, background: isSelected ? gradientFlow : brand.offWhite, border: `1.5px solid ${isSelected ? "transparent" : brand.borderGray}`, borderRadius: 10, padding: "11px", cursor: "pointer", transition: "all 0.15s", boxShadow: isSelected ? "0 3px 10px rgba(255,107,26,0.25)" : "none" }}
                            >
                              {slot}
                            </button>
                          );
                        })}
                      </div>
                    </div>
                  )}
                  {!state.date && (
                    <div style={{ textAlign: "center" as const, padding: "20px 0", color: brand.warmGray, fontFamily: "Inter", fontSize: 13 }}>Select a date above to see available time slots</div>
                  )}
                </StepSection>
              )}

              {/* Step 4 — Goal */}
              {step === 3 && (
                <StepSection title="Define your learning goal" subtitle="Tell the tutor exactly what you want to achieve. This helps them prepare and tailor the session to your level.">
                  <textarea
                    value={state.goal}
                    onChange={(e) => setState({ ...state, goal: e.target.value })}
                    placeholder="Example: I'm preparing for the EDLE exam in August. I struggle most with retreatment cases and calcified canals. I'd like to go through 5–6 clinical scenarios and understand the decision-making process step by step…"
                    rows={7}
                    style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${state.goal.length >= 20 ? brand.orange : brand.borderGray}`, borderRadius: 14, padding: "16px 18px", outline: "none", resize: "vertical", lineHeight: 1.65, boxSizing: "border-box" as const, transition: "border-color 0.15s" }}
                  />
                  <div style={{ display: "flex", justifyContent: "space-between", marginTop: 8 }}>
                    <span style={{ fontFamily: "Inter", fontSize: 12, color: state.goal.length >= 20 ? "#2D9B68" : brand.warmGray }}>
                      {state.goal.length < 20 ? `${20 - state.goal.length} more characters needed` : "✓ Looks good"}
                    </span>
                    <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>{state.goal.length} / 500</span>
                  </div>

                  {/* Prompt suggestions */}
                  <div style={{ marginTop: 20 }}>
                    <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.warmGray, marginBottom: 10 }}>Suggestions to get you started:</div>
                    <div style={{ display: "flex", flexDirection: "column" as const, gap: 8 }}>
                      {[
                        "I'm preparing for the EDLE and need help with rotary instrumentation technique.",
                        "I'm a fresh graduate struggling with case selection and treatment planning.",
                        "I need to understand the pharmacology of local anaesthetics for my ORE exam.",
                      ].map((s) => (
                        <button key={s} onClick={() => setState({ ...state, goal: s })} style={{ fontFamily: "Inter", fontSize: 12, color: brand.orange, background: "rgba(255,107,26,0.06)", border: `1px solid rgba(255,107,26,0.2)`, borderRadius: 8, padding: "8px 12px", cursor: "pointer", textAlign: "left" as const }}>
                          → {s}
                        </button>
                      ))}
                    </div>
                  </div>
                </StepSection>
              )}

              {/* Step 5 — Files */}
              {step === 4 && (
                <StepSection title="Upload files (optional)" subtitle="Share any relevant materials — exam questions, notes, X-rays, or a book chapter you'd like to discuss.">
                  {/* Drop zone */}
                  <div style={{ border: `2px dashed ${brand.borderGray}`, borderRadius: 16, padding: "40px 24px", textAlign: "center" as const, marginBottom: 20, cursor: "pointer", transition: "border-color 0.2s, background 0.2s" }}
                    onMouseEnter={(e) => { (e.currentTarget as HTMLElement).style.borderColor = brand.orange; (e.currentTarget as HTMLElement).style.background = "rgba(255,107,26,0.03)"; }}
                    onMouseLeave={(e) => { (e.currentTarget as HTMLElement).style.borderColor = brand.borderGray; (e.currentTarget as HTMLElement).style.background = "transparent"; }}
                  >
                    <div style={{ width: 52, height: 52, borderRadius: 14, background: "rgba(255,107,26,0.08)", display: "flex", alignItems: "center", justifyContent: "center", margin: "0 auto 14px" }}>
                      <Upload size={22} color={brand.orange} />
                    </div>
                    <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 15, color: brand.charcoal, marginBottom: 6 }}>Drop files here or click to browse</div>
                    <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray }}>PDF, DOCX, JPG, PNG · Max 20 MB per file</div>
                    <button
                      onClick={() => setState({ ...state, files: [...state.files, `File_${state.files.length + 1}.pdf`] })}
                      style={{ marginTop: 16, fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.orange, background: "rgba(255,107,26,0.08)", border: "none", borderRadius: 10, padding: "10px 20px", cursor: "pointer" }}
                    >
                      Browse Files
                    </button>
                  </div>

                  {/* File list */}
                  {state.files.length > 0 && (
                    <div>
                      <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal, marginBottom: 10 }}>Uploaded files:</div>
                      {state.files.map((f, i) => (
                        <div key={f} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", background: brand.offWhite, border: `1px solid ${brand.borderGray}`, borderRadius: 10, padding: "11px 14px", marginBottom: 8 }}>
                          <div style={{ display: "flex", gap: 10, alignItems: "center" }}>
                            <FileText size={15} color={brand.orange} />
                            <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal }}>{f}</span>
                          </div>
                          <button onClick={() => setState({ ...state, files: state.files.filter((_, j) => j !== i) })} style={{ background: "none", border: "none", cursor: "pointer", color: brand.warmGray }}>
                            <X size={14} />
                          </button>
                        </div>
                      ))}
                    </div>
                  )}

                  <div style={{ marginTop: 12, fontFamily: "Inter", fontSize: 12, color: brand.warmGray, lineHeight: 1.5 }}>
                    Do not upload files containing identifiable patient information. Anonymize all clinical images before sharing.
                  </div>
                </StepSection>
              )}

              {/* Step 6 — Format */}
              {step === 5 && (
                <StepSection title="Session format" subtitle="Choose how you'd like to attend the session.">
                  <div style={{ display: "flex", flexDirection: "column" as const, gap: 14 }}>
                    {[
                      { value: "online" as const, icon: <Video size={22} color={state.format === "online" ? "#fff" : brand.orange} />, title: "Online — Video Call", desc: "Zoom or Google Meet link sent after booking. Available from anywhere." },
                      { value: "offline" as const, icon: <MapPin size={22} color={state.format === "offline" ? "#fff" : brand.warmGray} />, title: "In-Person — Cairo", desc: "Meet at the tutor's clinic or a mutually agreed location. Location shared after confirmation.", disabled: false },
                    ].map((opt) => {
                      const isSelected = state.format === opt.value;
                      return (
                        <button
                          key={opt.value}
                          onClick={() => setState({ ...state, format: opt.value })}
                          style={{ background: isSelected ? gradientFlow : brand.offWhite, border: `2px solid ${isSelected ? "transparent" : brand.borderGray}`, borderRadius: 16, padding: "22px 22px", cursor: "pointer", textAlign: "left" as const, display: "flex", gap: 18, alignItems: "center", transition: "all 0.2s", boxShadow: isSelected ? "0 4px 16px rgba(255,107,26,0.3)" : "none" }}
                        >
                          <div style={{ width: 52, height: 52, borderRadius: 14, background: isSelected ? "rgba(255,255,255,0.18)" : "rgba(255,107,26,0.08)", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                            {opt.icon}
                          </div>
                          <div style={{ flex: 1 }}>
                            <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 16, color: isSelected ? "#fff" : brand.charcoal, marginBottom: 4 }}>{opt.title}</div>
                            <div style={{ fontFamily: "Inter", fontSize: 13, color: isSelected ? "rgba(255,255,255,0.75)" : brand.warmGray }}>{opt.desc}</div>
                          </div>
                          {isSelected && <CheckCircle size={22} color="#fff" style={{ flexShrink: 0 }} />}
                        </button>
                      );
                    })}
                  </div>
                </StepSection>
              )}

              {/* Step 7 — Review */}
              {step === 6 && (
                <StepSection title="Review your booking">
                  {/* Tutor mini card */}
                  <div style={{ background: brand.offWhite, borderRadius: 16, border: `1px solid ${brand.borderGray}`, padding: "18px 20px", marginBottom: 24, display: "flex", gap: 14, alignItems: "center" }}>
                    <img src={tutor.avatar} alt={tutor.name} style={{ width: 56, height: 56, borderRadius: 14, objectFit: "cover" }} />
                    <div>
                      <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: brand.charcoal }}>{tutor.name}</div>
                      <GradientBadge small>{tutor.specialty}</GradientBadge>
                      <div style={{ display: "flex", gap: 4, marginTop: 5, alignItems: "center" }}>
                        <Star size={11} fill={brand.amber} color={brand.amber} />
                        <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>{tutor.rating}</span>
                      </div>
                    </div>
                  </div>

                  {/* Summary table */}
                  <div style={{ background: brand.white, borderRadius: 16, border: `1px solid ${brand.borderGray}`, overflow: "hidden", marginBottom: 20 }}>
                    {[
                      ["Subject", state.subject || "—"],
                      ["Duration", `${state.duration} minutes`],
                      ["Date", state.date ? `Jun ${state.date}, 2025` : "—"],
                      ["Time", state.slot || "—"],
                      ["Format", state.format === "online" ? "Online (Video Call)" : "In-Person"],
                      ["Files Uploaded", state.files.length > 0 ? `${state.files.length} file(s)` : "None"],
                    ].map(([label, value], i) => (
                      <div key={label as string} style={{ display: "flex", justifyContent: "space-between", padding: "13px 20px", background: i % 2 === 0 ? brand.offWhite : brand.white }}>
                        <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray }}>{label as string}</span>
                        <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal }}>{value as string}</span>
                      </div>
                    ))}
                    <div style={{ display: "flex", justifyContent: "space-between", padding: "16px 20px", background: "rgba(255,107,26,0.04)", borderTop: `2px solid ${brand.borderGray}` }}>
                      <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: brand.charcoal }}>Total</span>
                      <span style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.orange }}>EGP {price}</span>
                    </div>
                  </div>

                  {/* Goal preview */}
                  {state.goal && (
                    <div style={{ background: "rgba(255,107,26,0.04)", border: `1px solid rgba(255,107,26,0.15)`, borderRadius: 14, padding: "16px 18px" }}>
                      <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.orange, marginBottom: 6 }}>Your Goal</div>
                      <p style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, lineHeight: 1.6 }}>{state.goal}</p>
                    </div>
                  )}
                </StepSection>
              )}

              {/* Step 8 — Payment */}
              {step === 7 && (
                <StepSection title="Payment" subtitle="Your session is secured. Payment is held until the session is complete.">
                  {/* Order total */}
                  <div style={{ background: `linear-gradient(135deg, rgba(255,107,26,0.06), rgba(255,198,46,0.06))`, border: `1px solid ${brand.borderGray}`, borderRadius: 14, padding: "16px 20px", marginBottom: 24, display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                    <div>
                      <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>Total to pay</div>
                      <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 26, color: brand.charcoal }}>EGP {price}</div>
                    </div>
                    <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, textAlign: "right" as const }}>
                      <div>{state.duration} min · {tutor.name.split(" ")[1]}</div>
                      {state.date && <div>Jun {state.date} · {state.slot}</div>}
                    </div>
                  </div>

                  {/* Card form */}
                  <div style={{ display: "flex", flexDirection: "column" as const, gap: 14 }}>
                    <div>
                      <label style={{ display: "block", fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal, marginBottom: 6 }}>Card Number</label>
                      <div style={{ position: "relative" }}>
                        <CreditCard size={16} style={{ position: "absolute", left: 14, top: "50%", transform: "translateY(-50%)", color: brand.warmGray }} />
                        <input
                          placeholder="1234 5678 9012 3456"
                          maxLength={19}
                          value={state.cardNumber}
                          onChange={(e) => {
                            const raw = e.target.value.replace(/\D/g, "").slice(0, 16);
                            const formatted = raw.match(/.{1,4}/g)?.join(" ") ?? raw;
                            setState({ ...state, cardNumber: formatted });
                          }}
                          style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 16px 12px 42px", outline: "none", boxSizing: "border-box" as const, letterSpacing: "0.05em" }}
                        />
                      </div>
                    </div>
                    <div>
                      <label style={{ display: "block", fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal, marginBottom: 6 }}>Cardholder Name</label>
                      <input
                        placeholder="Name as it appears on card"
                        value={state.cardName}
                        onChange={(e) => setState({ ...state, cardName: e.target.value })}
                        style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 16px", outline: "none", boxSizing: "border-box" as const }}
                      />
                    </div>
                    <div style={{ display: "flex", gap: 14 }}>
                      <div style={{ flex: 1 }}>
                        <label style={{ display: "block", fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal, marginBottom: 6 }}>Expiry Date</label>
                        <input
                          placeholder="MM / YY"
                          maxLength={7}
                          value={state.cardExpiry}
                          onChange={(e) => {
                            const raw = e.target.value.replace(/\D/g, "").slice(0, 4);
                            const formatted = raw.length > 2 ? `${raw.slice(0, 2)} / ${raw.slice(2)}` : raw;
                            setState({ ...state, cardExpiry: formatted });
                          }}
                          style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 16px", outline: "none", boxSizing: "border-box" as const }}
                        />
                      </div>
                      <div style={{ flex: 1 }}>
                        <label style={{ display: "block", fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal, marginBottom: 6 }}>CVV</label>
                        <input
                          placeholder="•••"
                          maxLength={3}
                          value={state.cardCvv}
                          type="password"
                          onChange={(e) => setState({ ...state, cardCvv: e.target.value.replace(/\D/g, "").slice(0, 3) })}
                          style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 16px", outline: "none", boxSizing: "border-box" as const }}
                        />
                      </div>
                    </div>
                  </div>

                  {/* Alternative payment */}
                  <div style={{ marginTop: 20, borderTop: `1px solid ${brand.borderGray}`, paddingTop: 18 }}>
                    <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.warmGray, marginBottom: 12 }}>Or pay with</div>
                    <div style={{ display: "flex", gap: 10 }}>
                      {["Fawry", "Vodafone Cash", "InstaPay"].map((p) => (
                        <button key={p} style={{ flex: 1, fontFamily: "Inter", fontWeight: 500, fontSize: 12, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 10, padding: "10px", cursor: "pointer" }}>{p}</button>
                      ))}
                    </div>
                  </div>

                  {/* Trust */}
                  <div style={{ marginTop: 20, display: "flex", gap: 8, alignItems: "flex-start" }}>
                    <Shield size={14} color={brand.warmGray} style={{ marginTop: 1, flexShrink: 0 }} />
                    <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, lineHeight: 1.55 }}>Your payment is encrypted and held securely. It is released to the tutor only after the session is complete. Full refund if cancelled 24h before.</span>
                  </div>
                </StepSection>
              )}

              {/* Navigation */}
              <div style={{ display: "flex", justifyContent: "space-between", marginTop: 32, paddingTop: 24, borderTop: `1px solid ${brand.borderGray}` }}>
                <button
                  onClick={back}
                  style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 14, color: step === 0 ? brand.borderGray : brand.charcoal, background: "none", border: `1.5px solid ${step === 0 ? brand.borderGray : brand.borderGray}`, borderRadius: 12, padding: "12px 22px", cursor: step === 0 ? "default" : "pointer", display: "flex", alignItems: "center", gap: 6 }}
                  disabled={step === 0}
                >
                  <ChevronLeft size={15} /> Back
                </button>
                <button
                  onClick={next}
                  disabled={!canProceed()}
                  style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: canProceed() ? gradientFlow : brand.borderGray, border: "none", borderRadius: 12, padding: "12px 28px", cursor: canProceed() ? "pointer" : "default", display: "flex", alignItems: "center", gap: 6, boxShadow: canProceed() ? "0 3px 12px rgba(255,107,26,0.3)" : "none", transition: "all 0.2s" }}
                >
                  {step === STEPS.length - 1 ? "Confirm & Pay" : "Continue"} <ChevronRight size={15} />
                </button>
              </div>
            </div>
          </div>

          {/* Sidebar summary */}
          <div style={{ width: 280, flexShrink: 0 }}>
            <div style={{ position: "sticky", top: 88, background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, overflow: "hidden", boxShadow: "0 4px 20px rgba(27,27,27,0.07)" }}>
              <div style={{ height: 4, background: gradientFlow }} />
              <div style={{ padding: "20px 20px" }}>
                {/* Tutor */}
                <div style={{ display: "flex", gap: 10, alignItems: "center", marginBottom: 16, paddingBottom: 16, borderBottom: `1px solid ${brand.borderGray}` }}>
                  <img src={tutor.avatar} alt={tutor.name} style={{ width: 44, height: 44, borderRadius: 12, objectFit: "cover" }} />
                  <div>
                    <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal }}>{tutor.name}</div>
                    <div style={{ display: "flex", gap: 3, marginTop: 3 }}>
                      <Star size={10} fill={brand.amber} color={brand.amber} />
                      <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{tutor.rating}</span>
                    </div>
                  </div>
                </div>

                {/* Summary rows */}
                {[
                  ["Subject", state.subject || "Not set"],
                  ["Duration", `${state.duration} min`],
                  ["Date", state.date ? `Jun ${state.date}` : "Not set"],
                  ["Time", state.slot || "Not set"],
                  ["Format", state.format === "online" ? "Online" : "In-Person"],
                ].map(([label, value]) => (
                  <div key={label as string} style={{ display: "flex", justifyContent: "space-between", marginBottom: 8 }}>
                    <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>{label as string}</span>
                    <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: (value as string).includes("Not") ? brand.borderGray : brand.charcoal }}>{value as string}</span>
                  </div>
                ))}

                <div style={{ height: 1, background: brand.borderGray, margin: "14px 0" }} />
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                  <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal }}>Total</span>
                  <span style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.orange }}>EGP {price}</span>
                </div>

                {/* Step indicators */}
                <div style={{ marginTop: 16 }}>
                  {STEPS.map((s, i) => (
                    <div key={s.id} style={{ display: "flex", gap: 8, alignItems: "center", padding: "5px 0" }}>
                      <div style={{ width: 18, height: 18, borderRadius: "50%", background: i < step ? gradientFlow : i === step ? brand.amber : brand.borderGray, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0, transition: "background 0.2s" }}>
                        {i < step ? <CheckCircle size={10} color="#fff" /> : <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 9, color: i === step ? brand.charcoal : brand.warmGray }}>{i + 1}</span>}
                      </div>
                      <span style={{ fontFamily: "Inter", fontSize: 12, color: i === step ? brand.charcoal : i < step ? brand.orange : brand.warmGray, fontWeight: i === step ? 600 : 400 }}>{s.label}</span>
                    </div>
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
