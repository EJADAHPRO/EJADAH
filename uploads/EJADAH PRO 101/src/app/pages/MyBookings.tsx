import { useState } from "react";
import { useNavigate } from "react-router";
import {
  Calendar, Clock, Video, MapPin, Star, ChevronRight,
  CheckCircle, XCircle, AlertCircle, RefreshCw, MessageSquare,
  Filter, BookOpen, Users, Briefcase, X, Send,
} from "lucide-react";
import { brand, gradientFlow } from "@/app/shared";

// ─── Types ────────────────────────────────────────────────────────────────────
type BookingStatus = "upcoming" | "completed" | "cancelled" | "pending";
type ServiceType = "Tutoring" | "Mentoring" | "Consulting";

interface Booking {
  id: string;
  type: ServiceType;
  providerName: string;
  providerTitle: string;
  providerInitials: string;
  subject: string;
  date: string;
  time: string;
  duration: string;
  format: "Online" | "In-Person";
  status: BookingStatus;
  price: string;
  currency: "EGP" | "USD";
  zoomLink?: string;
  location?: string;
  rating?: number;
  reviewLeft?: boolean;
  package?: string;
  sessionNumber?: string;
}

// ─── Mock booking data ────────────────────────────────────────────────────────
const ALL_BOOKINGS: Booking[] = [
  // Upcoming
  {
    id: "B001",
    type: "Tutoring",
    providerName: "Prof. Sherif Kamel",
    providerTitle: "Oral Biology · Cairo University",
    providerInitials: "SK",
    subject: "Oral Biology — Cell Signalling & Pulp Regeneration",
    date: "Tomorrow",
    time: "7:00 PM",
    duration: "60 min",
    format: "Online",
    status: "upcoming",
    price: "900",
    currency: "EGP",
    zoomLink: "https://zoom.us/j/ejadah-001",
    package: "Exam Accelerator · Session 3 of 8",
  },
  {
    id: "B002",
    type: "Mentoring",
    providerName: "Dr. Nadia Rashwan",
    providerTitle: "Specialist Endodontist · Dubai",
    providerInitials: "NR",
    subject: "UK Career Roadmap — GDC ORE Strategy & Timeline",
    date: "Aug 2, 2026",
    time: "5:30 PM",
    duration: "90 min",
    format: "Online",
    status: "upcoming",
    price: "180",
    currency: "USD",
    zoomLink: "https://zoom.us/j/ejadah-002",
    package: "3-Month Career Programme · Month 1",
  },
  {
    id: "B003",
    type: "Consulting",
    providerName: "Dr. Layla Mansour",
    providerTitle: "Postgraduate Admissions Consultant",
    providerInitials: "LM",
    subject: "King's College London MSc Application — Personal Statement Review",
    date: "Aug 5, 2026",
    time: "3:00 PM",
    duration: "60 min",
    format: "Online",
    status: "pending",
    price: "120",
    currency: "USD",
    zoomLink: undefined,
    package: "UK MSc Full Application Package · Session 1 of 3",
  },
  {
    id: "B004",
    type: "Tutoring",
    providerName: "Dr. Yasmine Nour",
    providerTitle: "Orthodontics · BUE",
    providerInitials: "YN",
    subject: "Fixed Appliance Mechanics — Wire Bending & Bracket Placement",
    date: "Aug 8, 2026",
    time: "6:00 PM",
    duration: "45 min",
    format: "In-Person",
    status: "upcoming",
    price: "450",
    currency: "EGP",
    location: "BUE Campus, New Cairo",
    package: "Single Session",
  },
  // Completed
  {
    id: "B005",
    type: "Tutoring",
    providerName: "Dr. Omar Farid",
    providerTitle: "Implantology · MIU",
    providerInitials: "OF",
    subject: "Implant Planning — CBCT Analysis & Prosthetic Options",
    date: "Jul 18, 2026",
    time: "8:00 PM",
    duration: "60 min",
    format: "Online",
    status: "completed",
    price: "55",
    currency: "USD",
    reviewLeft: false,
    package: "Starter Pack · Session 4 of 4",
  },
  {
    id: "B006",
    type: "Mentoring",
    providerName: "Dr. Ahmed El-Sayed",
    providerTitle: "Career Mentor · Riyadh",
    providerInitials: "AE",
    subject: "SCHS Registration Strategy & Saudi Job Market",
    date: "Jul 14, 2026",
    time: "7:00 PM",
    duration: "60 min",
    format: "Online",
    status: "completed",
    price: "150",
    currency: "USD",
    reviewLeft: true,
    rating: 5,
    package: "Single Mentoring Session",
  },
  {
    id: "B007",
    type: "Consulting",
    providerName: "Dr. Layla Mansour",
    providerTitle: "Postgraduate Admissions Consultant",
    providerInitials: "LM",
    subject: "CV & Academic Profile Review for UK MSc Applications",
    date: "Jul 10, 2026",
    time: "4:00 PM",
    duration: "45 min",
    format: "Online",
    status: "completed",
    price: "95",
    currency: "USD",
    reviewLeft: false,
    package: "UK MSc Full Application Package · Session 2 of 3",
  },
  {
    id: "B008",
    type: "Tutoring",
    providerName: "Prof. Rasha El-Gohary",
    providerTitle: "Oral Pathology · Ain Shams",
    providerInitials: "RE",
    subject: "EDLE Oral Pathology — High-Yield Revision",
    date: "Jul 5, 2026",
    time: "9:00 PM",
    duration: "90 min",
    format: "Online",
    status: "completed",
    price: "750",
    currency: "EGP",
    reviewLeft: true,
    rating: 5,
    package: "Exam Accelerator · Session 6 of 8",
  },
  // Cancelled
  {
    id: "B009",
    type: "Tutoring",
    providerName: "Dr. Sara Mahmoud",
    providerTitle: "Periodontics · Cairo University",
    providerInitials: "SM",
    subject: "Periodontal Surgery — Flap Techniques",
    date: "Jun 28, 2026",
    time: "6:00 PM",
    duration: "60 min",
    format: "Online",
    status: "cancelled",
    price: "600",
    currency: "EGP",
    package: "Single Session",
  },
];

// ─── Helpers ──────────────────────────────────────────────────────────────────
const STATUS_META: Record<BookingStatus, { label: string; color: string; bg: string; icon: React.ReactNode }> = {
  upcoming:  { label: "Confirmed",  color: "#2D9B68", bg: "rgba(45,155,104,0.1)",  icon: <CheckCircle size={13} /> },
  pending:   { label: "Pending Confirmation", color: brand.amber, bg: `${brand.amber}15`, icon: <AlertCircle size={13} /> },
  completed: { label: "Completed",  color: brand.warmGray, bg: `${brand.warmGray}12`, icon: <CheckCircle size={13} /> },
  cancelled: { label: "Cancelled",  color: brand.red, bg: `${brand.red}10`,  icon: <XCircle size={13} /> },
};

const TYPE_META: Record<ServiceType, { color: string; icon: React.ReactNode }> = {
  Tutoring:   { color: brand.orange, icon: <BookOpen size={13} /> },
  Mentoring:  { color: brand.amber,  icon: <Users size={13} /> },
  Consulting: { color: brand.red,    icon: <Briefcase size={13} /> },
};

// ─── Review Modal ─────────────────────────────────────────────────────────────
function ReviewModal({ booking, onClose, onSubmit }: { booking: Booking; onClose: () => void; onSubmit: (id: string, rating: number, text: string) => void }) {
  const [rating, setRating] = useState(5);
  const [hovered, setHovered] = useState(0);
  const [text, setText] = useState("");
  const [submitted, setSubmitted] = useState(false);

  const subRatings = ["Knowledge", "Communication", "Punctuality", "Value"];
  const [subs, setSubs] = useState([5, 5, 5, 5]);

  function handleSubmit() {
    if (text.trim().length < 20) return;
    setSubmitted(true);
    setTimeout(() => { onSubmit(booking.id, rating, text); onClose(); }, 1400);
  }

  return (
    <div style={{ position: "fixed", inset: 0, zIndex: 9999, display: "flex", alignItems: "center", justifyContent: "center", padding: 16, background: "rgba(18,18,18,0.6)", backdropFilter: "blur(4px)" }} onClick={onClose}>
      <div onClick={(e) => e.stopPropagation()} style={{ background: brand.white, borderRadius: 24, width: "100%", maxWidth: 480, maxHeight: "92vh", display: "flex", flexDirection: "column", boxShadow: "0 24px 60px rgba(0,0,0,0.2)", overflow: "hidden" }}>

        {/* Header */}
        <div style={{ padding: "22px 24px 18px", borderBottom: `1px solid ${brand.borderGray}`, display: "flex", justifyContent: "space-between", alignItems: "flex-start", flexShrink: 0 }}>
          <div>
            <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal, marginBottom: 3 }}>Leave a Review</div>
            <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>{booking.providerName} · {booking.subject.slice(0, 40)}…</div>
          </div>
          <button onClick={onClose} style={{ background: brand.offWhite, border: "none", borderRadius: 8, cursor: "pointer", padding: 6, display: "flex" }}><X size={16} color={brand.warmGray} /></button>
        </div>

        {submitted ? (
          <div style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: 40 }}>
            <div style={{ fontSize: 48, marginBottom: 16 }}>🎉</div>
            <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 8 }}>Review Submitted!</div>
            <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, textAlign: "center" }}>Thank you — your feedback helps other students choose the right tutor.</div>
          </div>
        ) : (
          <div style={{ overflowY: "auto", padding: "20px 24px 24px", flex: 1 }}>
            {/* Overall star rating */}
            <div style={{ marginBottom: 22 }}>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.warmGray, textTransform: "uppercase", letterSpacing: "0.06em", marginBottom: 10 }}>Overall Rating</div>
              <div style={{ display: "flex", gap: 8, alignItems: "center" }}>
                {[1,2,3,4,5].map((i) => (
                  <button key={i} onMouseEnter={() => setHovered(i)} onMouseLeave={() => setHovered(0)} onClick={() => setRating(i)}
                    style={{ background: "none", border: "none", cursor: "pointer", padding: 2, fontSize: 28, lineHeight: 1, color: i <= (hovered || rating) ? brand.amber : brand.borderGray, transition: "color 0.1s" }}>
                    ★
                  </button>
                ))}
                <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal, marginLeft: 4 }}>
                  {["", "Poor", "Fair", "Good", "Great", "Excellent"][hovered || rating]}
                </span>
              </div>
            </div>

            {/* Sub-ratings */}
            <div style={{ marginBottom: 22 }}>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.warmGray, textTransform: "uppercase", letterSpacing: "0.06em", marginBottom: 10 }}>Detailed Ratings</div>
              <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
                {subRatings.map((label, i) => (
                  <div key={label} style={{ display: "flex", alignItems: "center", gap: 12 }}>
                    <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, width: 120, flexShrink: 0 }}>{label}</span>
                    <div style={{ display: "flex", gap: 4 }}>
                      {[1,2,3,4,5].map((s) => (
                        <button key={s} onClick={() => setSubs(prev => prev.map((v, idx) => idx === i ? s : v))}
                          style={{ background: "none", border: "none", cursor: "pointer", padding: 0, fontSize: 18, color: s <= subs[i] ? brand.amber : brand.borderGray, transition: "color 0.1s" }}>★</button>
                      ))}
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Written review */}
            <div style={{ marginBottom: 20 }}>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.warmGray, textTransform: "uppercase", letterSpacing: "0.06em", marginBottom: 8 }}>Written Review</div>
              <textarea
                value={text}
                onChange={(e) => setText(e.target.value)}
                placeholder="Share your experience — what did the session cover, how did the tutor explain concepts, would you recommend them? (min. 20 characters)"
                rows={4}
                style={{ width: "100%", fontFamily: "Inter", fontSize: 13, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 14px", outline: "none", resize: "vertical", boxSizing: "border-box", lineHeight: 1.6 }}
                onFocus={(e) => (e.target.style.borderColor = brand.orange)}
                onBlur={(e) => (e.target.style.borderColor = brand.borderGray)}
              />
              <div style={{ fontFamily: "Inter", fontSize: 11, color: text.length < 20 ? brand.red : brand.warmGray, marginTop: 4, textAlign: "right" }}>
                {text.length} / 20 minimum
              </div>
            </div>

            <button onClick={handleSubmit} disabled={text.trim().length < 20}
              style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: text.trim().length >= 20 ? gradientFlow : brand.borderGray, border: "none", borderRadius: 12, padding: "13px", cursor: text.trim().length >= 20 ? "pointer" : "not-allowed", display: "flex", alignItems: "center", justifyContent: "center", gap: 8, transition: "background 0.2s" }}>
              <Send size={15} /> Submit Review
            </button>
          </div>
        )}
      </div>
    </div>
  );
}

// ─── Cancel Modal ─────────────────────────────────────────────────────────────
function CancelModal({ booking, onClose, onConfirm }: { booking: Booking; onClose: () => void; onConfirm: (id: string) => void }) {
  const [reason, setReason] = useState("");
  return (
    <div style={{ position: "fixed", inset: 0, zIndex: 9999, display: "flex", alignItems: "center", justifyContent: "center", padding: 16, background: "rgba(18,18,18,0.6)", backdropFilter: "blur(4px)" }} onClick={onClose}>
      <div onClick={(e) => e.stopPropagation()} style={{ background: brand.white, borderRadius: 20, width: "100%", maxWidth: 420, boxShadow: "0 24px 60px rgba(0,0,0,0.2)", overflow: "hidden" }}>
        <div style={{ padding: "22px 24px 0" }}>
          <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal, marginBottom: 6 }}>Cancel Session</div>
          <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, lineHeight: 1.6, marginBottom: 18 }}>
            Are you sure you want to cancel your session with <strong>{booking.providerName}</strong> on <strong>{booking.date} at {booking.time}</strong>?
          </div>
          <div style={{ background: `${brand.amber}10`, border: `1px solid ${brand.amber}30`, borderRadius: 12, padding: "12px 14px", marginBottom: 18 }}>
            <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.amber, marginBottom: 3 }}>Cancellation Policy</div>
            <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.charcoal, lineHeight: 1.6 }}>Cancellations made 24+ hours before the session receive a full refund. Within 24 hours — 50% refund. No refund for no-shows.</div>
          </div>
          <div style={{ marginBottom: 18 }}>
            <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.warmGray, marginBottom: 8 }}>Reason (optional)</div>
            <select value={reason} onChange={(e) => setReason(e.target.value)}
              style={{ width: "100%", fontFamily: "Inter", fontSize: 13, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 10, padding: "10px 12px", outline: "none", boxSizing: "border-box" as const }}>
              <option value="">Select a reason…</option>
              <option>Schedule conflict</option>
              <option>Found another tutor</option>
              <option>Personal emergency</option>
              <option>Financial reasons</option>
              <option>Other</option>
            </select>
          </div>
        </div>
        <div style={{ padding: "0 24px 22px", display: "flex", gap: 10 }}>
          <button onClick={onClose} style={{ flex: 1, fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 10, padding: "11px", cursor: "pointer" }}>Keep Session</button>
          <button onClick={() => { onConfirm(booking.id); onClose(); }} style={{ flex: 1, fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff", background: brand.red, border: "none", borderRadius: 10, padding: "11px", cursor: "pointer" }}>Cancel Session</button>
        </div>
      </div>
    </div>
  );
}

// ─── Booking Card ─────────────────────────────────────────────────────────────
function BookingCard({ booking, onReview, onCancel }: { booking: Booking; onReview: (b: Booking) => void; onCancel: (b: Booking) => void }) {
  const status = STATUS_META[booking.status];
  const type = TYPE_META[booking.type];
  const isUpcoming = booking.status === "upcoming" || booking.status === "pending";
  const isCompleted = booking.status === "completed";

  return (
    <div style={{ background: brand.white, borderRadius: 18, border: `1.5px solid ${booking.status === "pending" ? brand.amber + "50" : brand.borderGray}`, padding: "20px 22px", display: "flex", flexDirection: "column", gap: 14 }}>

      {/* Top row */}
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", gap: 12, flexWrap: "wrap" }}>
        <div style={{ display: "flex", gap: 12, alignItems: "flex-start" }}>
          {/* Avatar */}
          <div style={{ width: 44, height: 44, borderRadius: 13, background: gradientFlow, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
            <span style={{ fontFamily: "Inter", fontWeight: 800, fontSize: 14, color: "#fff" }}>{booking.providerInitials}</span>
          </div>
          <div>
            <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: brand.charcoal, marginBottom: 2 }}>{booking.providerName}</div>
            <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>{booking.providerTitle}</div>
          </div>
        </div>

        {/* Badges */}
        <div style={{ display: "flex", gap: 6, alignItems: "center", flexWrap: "wrap" }}>
          <span style={{ fontFamily: "Inter", fontSize: 10, fontWeight: 700, color: type.color, background: `${type.color}12`, borderRadius: 5, padding: "2px 8px", display: "flex", alignItems: "center", gap: 4 }}>
            {type.icon} {booking.type}
          </span>
          <span style={{ fontFamily: "Inter", fontSize: 10, fontWeight: 700, color: status.color, background: status.bg, borderRadius: 5, padding: "2px 8px", display: "flex", alignItems: "center", gap: 4 }}>
            {status.icon} {status.label}
          </span>
        </div>
      </div>

      {/* Subject */}
      <div style={{ background: brand.offWhite, borderRadius: 12, padding: "12px 14px" }}>
        <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal, marginBottom: 4 }}>{booking.subject}</div>
        {booking.package && <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.orange }}>{booking.package}</div>}
      </div>

      {/* Meta row */}
      <div style={{ display: "flex", gap: 16, flexWrap: "wrap" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 5, fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>
          <Calendar size={13} color={brand.orange} /> {booking.date}
        </div>
        <div style={{ display: "flex", alignItems: "center", gap: 5, fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>
          <Clock size={13} color={brand.orange} /> {booking.time} · {booking.duration}
        </div>
        <div style={{ display: "flex", alignItems: "center", gap: 5, fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>
          {booking.format === "Online" ? <Video size={13} color={brand.orange} /> : <MapPin size={13} color={brand.orange} />}
          {booking.format === "Online" ? "Online (Zoom)" : booking.location ?? "In-Person"}
        </div>
        <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.charcoal, marginLeft: "auto" }}>
          {booking.currency === "EGP" ? "EGP " : "$"}{booking.price}
        </div>
      </div>

      {/* Completed — review left or rating shown */}
      {isCompleted && booking.reviewLeft && booking.rating && (
        <div style={{ display: "flex", alignItems: "center", gap: 6, background: `${brand.amber}08`, borderRadius: 10, padding: "8px 12px" }}>
          <span style={{ color: brand.amber, fontSize: 14 }}>{"★".repeat(booking.rating)}</span>
          <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>You reviewed this session</span>
        </div>
      )}

      {/* Actions */}
      <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
        {/* Join (upcoming + online) */}
        {isUpcoming && booking.status === "upcoming" && booking.format === "Online" && booking.zoomLink && (
          <a href={booking.zoomLink} target="_blank" rel="noreferrer"
            style={{ flex: 1, minWidth: 120, fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "11px 16px", cursor: "pointer", textDecoration: "none", display: "flex", alignItems: "center", justifyContent: "center", gap: 7, boxShadow: "0 3px 12px rgba(255,107,26,0.3)" }}>
            <Video size={14} /> Join Session
          </a>
        )}

        {/* Pending — waiting message */}
        {booking.status === "pending" && (
          <div style={{ flex: 1, fontFamily: "Inter", fontSize: 12, color: brand.amber, background: `${brand.amber}10`, borderRadius: 10, padding: "11px 14px", display: "flex", alignItems: "center", gap: 7 }}>
            <AlertCircle size={14} /> Awaiting confirmation from {booking.providerName.split(" ")[1]}
          </div>
        )}

        {/* Message */}
        {booking.status !== "cancelled" && (
          <button style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 10, padding: "10px 14px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}>
            <MessageSquare size={14} /> Message
          </button>
        )}

        {/* Reschedule */}
        {isUpcoming && (
          <button style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.warmGray, background: "none", border: `1.5px solid ${brand.borderGray}`, borderRadius: 10, padding: "10px 14px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}>
            <RefreshCw size={14} /> Reschedule
          </button>
        )}

        {/* Cancel */}
        {isUpcoming && (
          <button onClick={() => onCancel(booking)} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.red, background: `${brand.red}08`, border: `1.5px solid ${brand.red}25`, borderRadius: 10, padding: "10px 14px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}>
            <XCircle size={14} /> Cancel
          </button>
        )}

        {/* Leave a review */}
        {isCompleted && !booking.reviewLeft && (
          <button onClick={() => onReview(booking)}
            style={{ flex: 1, minWidth: 120, fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "11px 16px", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 7 }}>
            <Star size={14} fill="#fff" /> Leave a Review
          </button>
        )}

        {/* Rebook */}
        {(isCompleted || booking.status === "cancelled") && (
          <button style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.orange, background: `${brand.orange}08`, border: `1.5px solid ${brand.orange}25`, borderRadius: 10, padding: "10px 14px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}>
            <ChevronRight size={14} /> Book Again
          </button>
        )}
      </div>

      {/* Booking ref */}
      <div style={{ fontFamily: "Inter", fontSize: 10, color: brand.borderGray, textAlign: "right" }}>
        Ref: EJD-{booking.id}
      </div>
    </div>
  );
}

// ─── Main Page ────────────────────────────────────────────────────────────────
export default function MyBookings() {
  const nav = useNavigate();
  const [tab, setTab] = useState<"upcoming" | "completed" | "cancelled">("upcoming");
  const [typeFilter, setTypeFilter] = useState<"All" | ServiceType>("All");
  const [bookings, setBookings] = useState(ALL_BOOKINGS);
  const [reviewTarget, setReviewTarget] = useState<Booking | null>(null);
  const [cancelTarget, setCancelTarget] = useState<Booking | null>(null);

  const tabBookings = bookings.filter((b) => {
    if (tab === "upcoming") return b.status === "upcoming" || b.status === "pending";
    return b.status === tab;
  }).filter((b) => typeFilter === "All" || b.type === typeFilter);

  const upcomingCount = bookings.filter((b) => b.status === "upcoming" || b.status === "pending").length;
  const pendingReviews = bookings.filter((b) => b.status === "completed" && !b.reviewLeft).length;

  function handleReviewSubmit(id: string, _rating: number, _text: string) {
    setBookings((prev) => prev.map((b) => b.id === id ? { ...b, reviewLeft: true, rating: _rating } : b));
  }

  function handleCancel(id: string) {
    setBookings((prev) => prev.map((b) => b.id === id ? { ...b, status: "cancelled" as BookingStatus } : b));
  }

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>

      {/* ── Hero ── */}
      <div style={{ background: brand.charcoal, padding: "36px 24px 32px" }}>
        <div style={{ maxWidth: 900, margin: "0 auto" }}>
          <div style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.35)", marginBottom: 6, letterSpacing: "0.05em" }}>MY ACCOUNT</div>
          <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(22px,3vw,30px)", color: "#fff", marginBottom: 20 }}>My Bookings</h1>

          {/* Summary stats */}
          <div style={{ display: "flex", gap: 12, flexWrap: "wrap" }}>
            {[
              { label: "Upcoming sessions", value: upcomingCount, color: "#2D9B68" },
              { label: "Sessions completed", value: bookings.filter((b) => b.status === "completed").length, color: brand.amber },
              { label: "Reviews pending", value: pendingReviews, color: pendingReviews > 0 ? brand.orange : brand.warmGray },
              { label: "Total spent", value: "USD 545 + EGP 2,700", color: brand.gold },
            ].map((s) => (
              <div key={s.label} style={{ background: "rgba(255,255,255,0.07)", border: "1px solid rgba(255,255,255,0.1)", borderRadius: 14, padding: "12px 18px" }}>
                <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: s.color }}>{s.value}</div>
                <div style={{ fontFamily: "Inter", fontSize: 11, color: "rgba(255,255,255,0.4)", marginTop: 2 }}>{s.label}</div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* ── Pending reviews banner ── */}
      {pendingReviews > 0 && (
        <div style={{ background: `${brand.orange}10`, borderBottom: `2px solid ${brand.orange}30`, padding: "12px 24px" }}>
          <div style={{ maxWidth: 900, margin: "0 auto", display: "flex", alignItems: "center", gap: 10, flexWrap: "wrap" }}>
            <Star size={15} color={brand.orange} fill={brand.orange} />
            <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal }}>
              You have {pendingReviews} completed session{pendingReviews > 1 ? "s" : ""} awaiting a review
            </span>
            <button onClick={() => setTab("completed")} style={{ fontFamily: "Inter", fontSize: 12, fontWeight: 700, color: brand.orange, background: "none", border: "none", cursor: "pointer", textDecoration: "underline", padding: 0 }}>
              Leave a review →
            </button>
          </div>
        </div>
      )}

      <div style={{ maxWidth: 900, margin: "0 auto", padding: "24px 24px 60px" }}>

        {/* ── Filters ── */}
        <div style={{ display: "flex", gap: 10, marginBottom: 20, flexWrap: "wrap", alignItems: "center" }}>
          {/* Tab toggle */}
          <div style={{ display: "flex", background: brand.white, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: 4, gap: 2 }}>
            {(["upcoming", "completed", "cancelled"] as const).map((t) => {
              const count = bookings.filter((b) => {
                if (t === "upcoming") return b.status === "upcoming" || b.status === "pending";
                return b.status === t;
              }).length;
              return (
                <button key={t} onClick={() => setTab(t)}
                  style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: tab === t ? "#fff" : brand.warmGray, background: tab === t ? brand.charcoal : "transparent", border: "none", borderRadius: 9, padding: "7px 14px", cursor: "pointer", transition: "all 0.15s", textTransform: "capitalize" }}>
                  {t} {count > 0 && <span style={{ fontFamily: "Inter", fontSize: 10, background: tab === t ? "rgba(255,255,255,0.2)" : brand.borderGray, borderRadius: 10, padding: "1px 6px", marginLeft: 4, color: tab === t ? "#fff" : brand.warmGray }}>{count}</span>}
                </button>
              );
            })}
          </div>

          {/* Type filter */}
          <div style={{ display: "flex", gap: 6, marginLeft: "auto", flexWrap: "wrap" }}>
            <Filter size={14} color={brand.warmGray} style={{ alignSelf: "center" }} />
            {(["All", "Tutoring", "Mentoring", "Consulting"] as const).map((t) => (
              <button key={t} onClick={() => setTypeFilter(t)}
                style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 12, color: typeFilter === t ? "#fff" : brand.charcoal, background: typeFilter === t ? gradientFlow : brand.white, border: `1.5px solid ${typeFilter === t ? "transparent" : brand.borderGray}`, borderRadius: 20, padding: "5px 13px", cursor: "pointer", transition: "all 0.15s" }}>
                {t}
              </button>
            ))}
          </div>
        </div>

        {/* ── Booking list ── */}
        {tabBookings.length === 0 ? (
          <div style={{ textAlign: "center", padding: "80px 0" }}>
            <div style={{ fontSize: 48, marginBottom: 16 }}>
              {tab === "upcoming" ? "📅" : tab === "completed" ? "✅" : "❌"}
            </div>
            <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.charcoal, marginBottom: 8 }}>
              No {tab} {typeFilter !== "All" ? typeFilter.toLowerCase() : ""} sessions
            </div>
            <div style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, marginBottom: 28 }}>
              {tab === "upcoming" ? "Book your first session with a tutor, mentor, or consultant." : `No ${tab} sessions yet.`}
            </div>
            {tab === "upcoming" && (
              <div style={{ display: "flex", gap: 10, justifyContent: "center", flexWrap: "wrap" }}>
                {[["Find a Tutor", "/tutoring"], ["Find a Mentor", "/mentoring"], ["Find a Consultant", "/consulting"]].map(([label, path]) => (
                  <button key={path} onClick={() => nav(path)} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal, background: brand.white, border: `1.5px solid ${brand.borderGray}`, borderRadius: 10, padding: "10px 18px", cursor: "pointer" }}>{label}</button>
                ))}
              </div>
            )}
          </div>
        ) : (
          <div style={{ display: "flex", flexDirection: "column", gap: 14 }}>
            {tabBookings.map((b) => (
              <BookingCard key={b.id} booking={b} onReview={setReviewTarget} onCancel={setCancelTarget} />
            ))}
          </div>
        )}

        {/* ── CTA strip ── */}
        <div style={{ marginTop: 36, background: brand.charcoal, borderRadius: 20, padding: "24px 28px", display: "flex", alignItems: "center", justifyContent: "space-between", gap: 20, flexWrap: "wrap" }}>
          <div>
            <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: "#fff", marginBottom: 4 }}>Need another session?</div>
            <div style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.5)" }}>150+ tutors, 80+ mentors, 120+ consultants available now.</div>
          </div>
          <div style={{ display: "flex", gap: 10, flexWrap: "wrap" }}>
            {[["Tutoring", "/tutoring"], ["Mentoring", "/mentoring"], ["Consulting", "/consulting"]].map(([label, path]) => (
              <button key={path} onClick={() => nav(path)} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: "#fff", background: "rgba(255,255,255,0.1)", border: "1px solid rgba(255,255,255,0.15)", borderRadius: 10, padding: "10px 16px", cursor: "pointer" }}>{label}</button>
            ))}
          </div>
        </div>
      </div>

      {/* ── Modals ── */}
      {reviewTarget && (
        <ReviewModal booking={reviewTarget} onClose={() => setReviewTarget(null)} onSubmit={handleReviewSubmit} />
      )}
      {cancelTarget && (
        <CancelModal booking={cancelTarget} onClose={() => setCancelTarget(null)} onConfirm={handleCancel} />
      )}
    </div>
  );
}
