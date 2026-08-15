import { useState } from "react";
import { useNavigate, useParams } from "react-router";
import {
  Star, Clock, Globe, Video, MapPin, CheckCircle, ArrowRight,
  Play, MessageSquare, Bookmark, Share2, Users, Award,
  ChevronLeft, ThumbsUp, Shield,
} from "lucide-react";
import { brand, gradientFlow, GradientBadge } from "@/app/shared";

const tutorData: Record<string, {
  name: string; title: string; specialty: string; country: string;
  languages: string[]; rating: number; reviews: number; sessions: number;
  priceHour: number; price30: number; price15: number;
  online: boolean; offline: boolean; available: boolean;
  avatar: string;
  bio: string; teaching: string;
  subjects: string[]; qualifications: string[];
  packages: { label: string; sessions: number; price: number; saving?: string }[];
  reviewsList: { name: string; avatar: string; rating: number; date: string; text: string; specialty: string }[];
}> = {
  "1": {
    name: "Dr. Amira Soliman",
    title: "Endodontist · PhD Cairo University",
    specialty: "Endodontics",
    country: "Egypt",
    languages: ["Arabic", "English"],
    rating: 4.9, reviews: 284, sessions: 1240,
    priceHour: 350, price30: 195, price15: 110,
    online: true, offline: false, available: true,
    avatar: "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=300&q=80",
    bio: "I am a consultant endodontist with over 12 years of clinical and academic experience, holding a PhD in Endodontics from Cairo University. I have taught at the undergraduate and postgraduate levels and have helped hundreds of dentists build genuine clinical understanding — not just pass exams.\n\nMy approach is evidence-based and clinically focused. I believe in teaching the 'why' behind every decision, so you can apply knowledge confidently in real cases, not just recall it under exam pressure.",
    teaching: "My sessions are structured around your specific goal — whether that's EDLE preparation, clinical skill development, or understanding complex cases. I use real clinical images, CBCT scans, and case discussions. I don't just talk at you; I work through problems with you.",
    subjects: ["Root Canal Treatment", "Retreatment", "Calcified Canals", "EDLE Endodontics", "INBDE Endodontics", "Pulp Biology", "Rotary Systems", "Irrigation Protocols", "Obturation Techniques"],
    qualifications: ["PhD Endodontics — Cairo University", "BDS — Ain Shams University (Distinction)", "Diploma, Advanced Endodontics — EDA", "Member, Egyptian Endodontic Society", "Published: 14 peer-reviewed papers"],
    packages: [
      { label: "Single Session", sessions: 1, price: 350 },
      { label: "Starter Pack", sessions: 4, price: 1260, saving: "Save 10%" },
      { label: "Intensive Pack", sessions: 10, price: 2975, saving: "Save 15%" },
      { label: "Exam Accelerator", sessions: 20, price: 5250, saving: "Save 25%" },
    ],
    reviewsList: [
      { name: "Dr. Khaled Mahmoud", avatar: "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=60&q=80", rating: 5, date: "Jun 2025", specialty: "EDLE Candidate", text: "Dr. Amira's sessions are unlike any online resource I've used. She went through 3 calcified molar cases with me in one session and I finally understood what I was doing wrong. Passed EDLE endodontics section with 91%." },
      { name: "Dr. Sara Adel", avatar: "https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=60&q=80", rating: 5, date: "May 2025", specialty: "Intern, Cairo", text: "Booked 10 sessions before my internship started. Best investment I made. She teaches you how to think, not just what to memorize." },
      { name: "Dr. Youssef Nabil", avatar: "https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=60&q=80", rating: 5, date: "Apr 2025", specialty: "ORE Candidate", text: "Three sessions with Dr. Amira gave me the framework I needed. She shared real clinical photos and walked me through the decision process step by step." },
      { name: "Nour Hassan", avatar: "https://images.unsplash.com/photo-1657470179447-0f5aa16daa91?w=60&q=80", rating: 4, date: "Mar 2025", specialty: "Dental Student", text: "Very knowledgeable and patient. Sometimes goes into a lot of detail which is great if you have time, but I needed more focused exam revision. Would still recommend highly." },
    ],
  },
  "2": {
    name: "Dr. Hany Ibrahim",
    title: "Oral & Maxillofacial Surgeon",
    specialty: "Oral Surgery",
    country: "Egypt",
    languages: ["Arabic", "English"],
    rating: 4.8, reviews: 196, sessions: 870,
    priceHour: 500, price30: 275, price15: 150,
    online: true, offline: true, available: true,
    avatar: "https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=300&q=80",
    bio: "Oral and maxillofacial surgeon with 15 years of clinical and teaching experience at Alexandria University. I combine deep academic knowledge with practical clinical insight — my sessions are grounded in real surgical decision-making, not just textbook answers.",
    teaching: "I use a case-based approach. Every session starts with a clinical scenario, and we work through the diagnosis, treatment plan, surgical technique, and potential complications together.",
    subjects: ["Exodontia", "Surgical Flap Design", "Impacted Third Molars", "EDLE Oral Surgery", "ORE Surgery", "Biopsy Techniques", "Surgical Anatomy"],
    qualifications: ["MSc Oral & Maxillofacial Surgery — Alexandria University", "BDS — Alexandria University (Honour Roll)", "Fellowship, Egyptian Surgical Academy", "Associate Professor — Alexandria University", "Published: 22 peer-reviewed papers"],
    packages: [
      { label: "Single Session", sessions: 1, price: 500 },
      { label: "Starter Pack", sessions: 4, price: 1800, saving: "Save 10%" },
      { label: "Intensive Pack", sessions: 10, price: 4250, saving: "Save 15%" },
      { label: "Exam Accelerator", sessions: 20, price: 7500, saving: "Save 25%" },
    ],
    reviewsList: [
      { name: "Dr. Maha Sami", avatar: "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=60&q=80", rating: 5, date: "Jun 2025", specialty: "ORE Candidate", text: "Dr. Hany's teaching is extraordinarily clear. He walked me through flap designs with diagrams he drew live on screen." },
      { name: "Dr. Tarek Fouad", avatar: "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=60&q=80", rating: 5, date: "May 2025", specialty: "EDLE Candidate", text: "The best tutor on Ejadah, full stop. He doesn't just answer your questions — he teaches you how to answer any question." },
      { name: "Dr. Reem Saleh", avatar: "https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=60&q=80", rating: 4, date: "Apr 2025", specialty: "Fresh Graduate", text: "Fantastic depth of knowledge. Sometimes sessions run over time which I didn't mind. Very responsive to messages between sessions." },
    ],
  },
};

const calDates = [
  { d: 23, day: "Mon", slots: ["9:00 AM", "5:00 PM", "7:00 PM"] },
  { d: 24, day: "Tue", slots: ["11:00 AM", "3:00 PM", "9:00 PM"] },
  { d: 25, day: "Wed", slots: [] },
  { d: 26, day: "Thu", slots: ["9:00 AM", "1:00 PM", "7:00 PM"] },
  { d: 27, day: "Fri", slots: ["11:00 AM", "5:00 PM"] },
  { d: 28, day: "Sat", slots: ["1:00 PM", "3:00 PM", "9:00 PM"] },
  { d: 29, day: "Sun", slots: ["9:00 AM", "11:00 AM"] },
];

function RatingBar({ stars, percent }: { stars: number; percent: number }) {
  return (
    <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
      <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, width: 14, textAlign: "right" as const }}>{stars}</span>
      <Star size={11} fill={brand.amber} color={brand.amber} />
      <div style={{ flex: 1, height: 6, background: brand.borderGray, borderRadius: 3, overflow: "hidden" }}>
        <div style={{ height: "100%", width: `${percent}%`, background: gradientFlow, borderRadius: 3 }} />
      </div>
      <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, width: 30 }}>{percent}%</span>
    </div>
  );
}

function CalendarStrip({ onSelect }: { onSelect: (day: string, slot: string) => void }) {
  const [selectedDate, setSelectedDate] = useState<number | null>(null);
  const [selectedSlot, setSelectedSlot] = useState<string | null>(null);

  return (
    <div>
      <div style={{ display: "flex", gap: 6, marginBottom: 14 }}>
        {calDates.map((c) => {
          const hasSlots = c.slots.length > 0;
          const isSelected = selectedDate === c.d;
          return (
            <button key={c.d} onClick={() => { if (hasSlots) { setSelectedDate(c.d); setSelectedSlot(null); } }}
              style={{ flex: 1, fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: isSelected ? "#fff" : hasSlots ? brand.charcoal : brand.borderGray, background: isSelected ? gradientFlow : hasSlots ? brand.offWhite : "transparent", border: `1.5px solid ${isSelected ? "transparent" : hasSlots ? brand.borderGray : brand.borderGray}`, borderRadius: 10, padding: "8px 2px", cursor: hasSlots ? "pointer" : "default", opacity: hasSlots ? 1 : 0.4, textAlign: "center" as const }}>
              <div style={{ fontSize: 9, marginBottom: 3, opacity: 0.7 }}>{c.day}</div>
              <div>{c.d}</div>
            </button>
          );
        })}
      </div>
      {selectedDate && (
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 8 }}>
          {(calDates.find((c) => c.d === selectedDate)?.slots ?? []).map((slot) => {
            const isSel = selectedSlot === slot;
            return (
              <button key={slot} onClick={() => { setSelectedSlot(slot); onSelect(String(selectedDate), slot); }}
                style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 13, color: isSel ? "#fff" : brand.charcoal, background: isSel ? gradientFlow : brand.offWhite, border: `1.5px solid ${isSel ? "transparent" : brand.borderGray}`, borderRadius: 10, padding: "10px", cursor: "pointer", transition: "all 0.15s" }}>
                {slot}
              </button>
            );
          })}
        </div>
      )}
      {!selectedDate && <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, textAlign: "center" as const, padding: "12px 0" }}>Select a date to see available slots</div>}
    </div>
  );
}

export default function TutorProfile() {
  const { id } = useParams();
  const nav = useNavigate();
  const tutor = tutorData[id ?? "1"] ?? tutorData["1"];

  const [selectedPackage, setSelectedPackage] = useState(0);
  const [selectedDuration, setSelectedDuration] = useState<15 | 30 | 60>(60);
  const [activeTab, setActiveTab] = useState<"about" | "reviews" | "packages">("about");
  const [saved, setSaved] = useState(false);
  const [selectedDay, setSelectedDay] = useState("");
  const [selectedSlot, setSelectedSlot] = useState("");

  const durationPrice = selectedDuration === 60 ? tutor.priceHour : selectedDuration === 30 ? tutor.price30 : tutor.price15;

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      <div style={{ maxWidth: 1280, margin: "0 auto", padding: "20px 24px 0" }}>
        <button onClick={() => nav("/tutoring")} style={{ background: "none", border: "none", cursor: "pointer", color: brand.warmGray, fontFamily: "Inter", fontSize: 13, display: "flex", alignItems: "center", gap: 5 }}>
          <ChevronLeft size={15} /> Back to Tutors
        </button>
      </div>

      {/* Hero */}
      <div style={{ background: brand.charcoal, marginTop: 16 }}>
        <div style={{ height: 6, background: gradientFlow }} />
        <div style={{ maxWidth: 1280, margin: "0 auto", padding: "40px 24px 36px", display: "flex", gap: 28, alignItems: "flex-start", flexWrap: "wrap" }}>
          <div style={{ display: "flex", gap: 22, alignItems: "flex-start", flex: 1 }}>
            <div style={{ position: "relative", flexShrink: 0 }}>
              <img src={tutor.avatar} alt={tutor.name} style={{ width: 100, height: 100, borderRadius: 20, objectFit: "cover", border: "3px solid rgba(255,255,255,0.12)" }} />
              <div style={{ position: "absolute", bottom: -3, right: -3, width: 20, height: 20, borderRadius: "50%", background: tutor.available ? "#2D9B68" : brand.warmGray, border: "3px solid #1B1B1B" }} />
            </div>
            <div>
              <div style={{ display: "flex", gap: 10, alignItems: "center", flexWrap: "wrap", marginBottom: 6 }}>
                <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(20px,3vw,28px)", color: "#fff" }}>{tutor.name}</h1>
                <div style={{ width: 20, height: 20, borderRadius: "50%", background: gradientFlow, display: "flex", alignItems: "center", justifyContent: "center" }}>
                  <CheckCircle size={11} color="#fff" />
                </div>
              </div>
              <div style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.55)", marginBottom: 12 }}>{tutor.title}</div>
              <div style={{ display: "flex", gap: 10, flexWrap: "wrap", marginBottom: 14 }}>
                <GradientBadge small>{tutor.specialty}</GradientBadge>
                <span style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.5)", display: "flex", alignItems: "center", gap: 4 }}><MapPin size={12} /> {tutor.country}</span>
                <span style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.5)", display: "flex", alignItems: "center", gap: 4 }}><Globe size={12} /> {tutor.languages.join(" · ")}</span>
              </div>
              <div style={{ display: "flex", gap: 20, flexWrap: "wrap" }}>
                <div style={{ display: "flex", alignItems: "center", gap: 5 }}>
                  <Star size={13} fill={brand.amber} color={brand.amber} />
                  <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: "#fff" }}>{tutor.rating}</span>
                  <span style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.4)" }}>({tutor.reviews})</span>
                </div>
                <span style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.5)" }}>{tutor.sessions.toLocaleString()} sessions</span>
                <div style={{ display: "flex", gap: 6 }}>
                  {tutor.online && <span style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 600, color: brand.orange, background: "rgba(255,107,26,0.15)", borderRadius: 6, padding: "3px 8px", display: "flex", alignItems: "center", gap: 4 }}><Video size={10} /> Online</span>}
                  {tutor.offline && <span style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 600, color: "rgba(255,255,255,0.7)", background: "rgba(255,255,255,0.08)", borderRadius: 6, padding: "3px 8px", display: "flex", alignItems: "center", gap: 4 }}><MapPin size={10} /> In-Person</span>}
                </div>
              </div>
            </div>
          </div>
          <div style={{ display: "flex", gap: 10, flexShrink: 0 }}>
            <button onClick={() => setSaved(!saved)} style={{ width: 42, height: 42, borderRadius: 12, background: "rgba(255,255,255,0.08)", border: "1px solid rgba(255,255,255,0.12)", display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer", color: saved ? brand.amber : "rgba(255,255,255,0.6)" }}>
              <Bookmark size={17} fill={saved ? brand.amber : "none"} />
            </button>
            <button style={{ width: 42, height: 42, borderRadius: 12, background: "rgba(255,255,255,0.08)", border: "1px solid rgba(255,255,255,0.12)", display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer", color: "rgba(255,255,255,0.6)" }}><Share2 size={17} /></button>
            <button style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: "#fff", background: "rgba(255,255,255,0.1)", border: "1px solid rgba(255,255,255,0.15)", borderRadius: 12, padding: "10px 18px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}>
              <MessageSquare size={14} /> Message
            </button>
          </div>
        </div>
      </div>

      {/* Body */}
      <div style={{ maxWidth: 1280, margin: "0 auto", padding: "32px 24px", display: "flex", gap: 28, alignItems: "flex-start", flexWrap: "wrap" }}>
        {/* Left */}
        <div style={{ flex: 1, minWidth: 300 }}>
          {/* Tabs */}
          <div style={{ display: "flex", borderBottom: `2px solid ${brand.borderGray}`, marginBottom: 28 }}>
            {(["about", "reviews", "packages"] as const).map((tab) => (
              <button key={tab} onClick={() => setActiveTab(tab)} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: activeTab === tab ? brand.orange : brand.warmGray, background: "none", border: "none", borderBottom: `2px solid ${activeTab === tab ? brand.orange : "transparent"}`, marginBottom: -2, padding: "10px 20px", cursor: "pointer", textTransform: "capitalize" as const, transition: "color 0.15s" }}>
                {tab === "reviews" ? `Reviews (${tutor.reviews})` : tab === "packages" ? "Packages" : "About"}
              </button>
            ))}
          </div>

          {/* About */}
          {activeTab === "about" && (
            <div>
              {/* Video placeholder */}
              <div style={{ background: brand.charcoal, borderRadius: 18, height: 200, marginBottom: 24, display: "flex", alignItems: "center", justifyContent: "center", position: "relative", overflow: "hidden", cursor: "pointer" }}>
                <img src={tutor.avatar} alt="" style={{ position: "absolute", inset: 0, width: "100%", height: "100%", objectFit: "cover", opacity: 0.3 }} />
                <div style={{ position: "relative", textAlign: "center" as const }}>
                  <div style={{ width: 56, height: 56, borderRadius: "50%", background: "rgba(255,255,255,0.15)", border: "2px solid rgba(255,255,255,0.3)", display: "flex", alignItems: "center", justifyContent: "center", margin: "0 auto 10px" }}>
                    <Play size={22} fill="#fff" color="#fff" style={{ marginLeft: 3 }} />
                  </div>
                  <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: "#fff" }}>Watch Introduction · 3 min</div>
                </div>
              </div>

              {[
                { title: "About", content: tutor.bio.split("\n\n").map((p, i) => <p key={i} style={{ fontFamily: "Inter", fontSize: 14, color: brand.charcoal, lineHeight: 1.75, marginBottom: 12 }}>{p}</p>) },
                { title: "Teaching Style", content: <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.charcoal, lineHeight: 1.75 }}>{tutor.teaching}</p> },
              ].map((sec) => (
                <div key={sec.title} style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px 26px", marginBottom: 18 }}>
                  <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 14 }}>{sec.title}</h2>
                  {sec.content}
                </div>
              ))}

              <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px 26px", marginBottom: 18 }}>
                <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 14 }}>Subjects Covered</h2>
                <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
                  {tutor.subjects.map((s) => <span key={s} style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, background: brand.offWhite, border: `1px solid ${brand.borderGray}`, borderRadius: 8, padding: "6px 12px" }}>{s}</span>)}
                </div>
              </div>

              <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px 26px", marginBottom: 18 }}>
                <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 14 }}>Qualifications</h2>
                {tutor.qualifications.map((q) => (
                  <div key={q} style={{ display: "flex", gap: 10, alignItems: "flex-start", marginBottom: 10 }}>
                    <CheckCircle size={14} color={brand.orange} style={{ marginTop: 1, flexShrink: 0 }} />
                    <span style={{ fontFamily: "Inter", fontSize: 14, color: brand.charcoal }}>{q}</span>
                  </div>
                ))}
              </div>

              <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px 26px" }}>
                <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 14 }}>Policies</h2>
                {[["Cancellation", "Free up to 24h before. Within 24h: 50% refund. No-show: no refund."], ["Rescheduling", "Free up to 12h before booking time."], ["Trial Session", "First 15-min session available at reduced rate — message tutor to arrange."]].map(([t, d]) => (
                  <div key={t as string} style={{ marginBottom: 12 }}>
                    <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal, marginBottom: 3 }}>{t as string}</div>
                    <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, lineHeight: 1.55 }}>{d as string}</div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Reviews */}
          {activeTab === "reviews" && (
            <div>
              <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px 26px", marginBottom: 18 }}>
                <div style={{ display: "flex", gap: 28, alignItems: "center", flexWrap: "wrap" }}>
                  <div style={{ textAlign: "center" as const }}>
                    <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 52, color: brand.charcoal, lineHeight: 1 }}>{tutor.rating}</div>
                    <div style={{ display: "flex", justifyContent: "center", gap: 3, margin: "8px 0 4px" }}>{[1,2,3,4,5].map((i) => <Star key={i} size={15} fill={brand.amber} color={brand.amber} />)}</div>
                    <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>{tutor.reviews} reviews</div>
                  </div>
                  <div style={{ flex: 1, minWidth: 160 }}>
                    {[[5,82],[4,12],[3,4],[2,1],[1,1]].map(([s,p]) => <div key={s} style={{ marginBottom: 6 }}><RatingBar stars={s} percent={p} /></div>)}
                  </div>
                  <div>
                    {[["Communication","4.9"],["Knowledge","5.0"],["Punctuality","4.8"],["Value","4.8"]].map(([l,v]) => (
                      <div key={l as string} style={{ display: "flex", justifyContent: "space-between", gap: 20, marginBottom: 8 }}>
                        <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray }}>{l as string}</span>
                        <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal }}>{v as string}</span>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
              {tutor.reviewsList.map((r) => (
                <div key={r.name} style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "20px 22px", marginBottom: 12 }}>
                  <div style={{ display: "flex", gap: 12, alignItems: "flex-start", marginBottom: 10 }}>
                    <img src={r.avatar} alt={r.name} style={{ width: 42, height: 42, borderRadius: "50%", objectFit: "cover", flexShrink: 0 }} />
                    <div style={{ flex: 1 }}>
                      <div style={{ display: "flex", justifyContent: "space-between", flexWrap: "wrap" }}>
                        <div>
                          <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal }}>{r.name}</div>
                          <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>{r.specialty}</div>
                        </div>
                        <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>{r.date}</span>
                      </div>
                      <div style={{ display: "flex", gap: 2, marginTop: 5 }}>{[1,2,3,4,5].map((i) => <Star key={i} size={11} fill={i<=r.rating?brand.amber:"none"} color={i<=r.rating?brand.amber:brand.borderGray} />)}</div>
                    </div>
                  </div>
                  <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.charcoal, lineHeight: 1.65 }}>{r.text}</p>
                  <button style={{ marginTop: 8, background: "none", border: "none", cursor: "pointer", color: brand.warmGray, fontFamily: "Inter", fontSize: 12, display: "flex", alignItems: "center", gap: 4 }}><ThumbsUp size={12} /> Helpful</button>
                </div>
              ))}
            </div>
          )}

          {/* Packages */}
          {activeTab === "packages" && (
            <div>
              <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px 26px", marginBottom: 18 }}>
                <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 18 }}>Session Packages</h2>
                <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(200px, 1fr))", gap: 12 }}>
                  {tutor.packages.map((pkg, i) => {
                    const isSel = selectedPackage === i;
                    return (
                      <div key={pkg.label} onClick={() => setSelectedPackage(i)} style={{ borderRadius: 14, border: `2px solid ${isSel ? brand.orange : brand.borderGray}`, padding: "18px 16px", cursor: "pointer", background: isSel ? "rgba(255,107,26,0.04)" : brand.offWhite, position: "relative", transition: "all 0.15s" }}>
                        {pkg.saving && <div style={{ position: "absolute", top: -10, right: 10, background: gradientFlow, color: "#fff", fontFamily: "Inter", fontWeight: 700, fontSize: 10, borderRadius: 6, padding: "2px 8px" }}>{pkg.saving}</div>}
                        <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal, marginBottom: 3 }}>{pkg.label}</div>
                        <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginBottom: 12 }}>{pkg.sessions} session{pkg.sessions > 1 ? "s" : ""}</div>
                        <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: isSel ? brand.orange : brand.charcoal }}>EGP {pkg.price.toLocaleString()}</div>
                        {pkg.sessions > 1 && <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginTop: 3 }}>EGP {Math.round(pkg.price / pkg.sessions)} / session</div>}
                      </div>
                    );
                  })}
                </div>
                <button onClick={() => nav(`/tutoring/${id}/book`)} style={{ marginTop: 18, width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "13px", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 8, boxShadow: "0 4px 16px rgba(255,107,26,0.35)" }}>
                  Book {tutor.packages[selectedPackage].label} <ArrowRight size={15} />
                </button>
              </div>
              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>
                {[
                  { icon: <Shield size={17} color={brand.orange} />, title: "Verified Tutor", desc: "Identity & qualifications confirmed by Ejadah" },
                  { icon: <Award size={17} color={brand.amber} />, title: "Money-Back Guarantee", desc: "Full refund if cancelled 24h before session" },
                  { icon: <Users size={17} color={brand.red} />, title: `${tutor.sessions.toLocaleString()} Sessions`, desc: "Experienced across all levels & exam types" },
                  { icon: <Star size={17} color={brand.gold} />, title: "Top-Rated", desc: `${tutor.rating}★ across ${tutor.reviews} verified reviews` },
                ].map((b) => (
                  <div key={b.title} style={{ background: brand.white, borderRadius: 14, border: `1px solid ${brand.borderGray}`, padding: "14px 14px", display: "flex", gap: 10, alignItems: "flex-start" }}>
                    <div style={{ width: 34, height: 34, borderRadius: 10, background: brand.offWhite, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>{b.icon}</div>
                    <div>
                      <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal }}>{b.title}</div>
                      <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginTop: 2, lineHeight: 1.4 }}>{b.desc}</div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>

        {/* Sticky sidebar */}
        <div style={{ width: 310, flexShrink: 0 }}>
          <div style={{ position: "sticky", top: 88 }}>
            <div style={{ background: brand.white, borderRadius: 22, border: `1px solid ${brand.borderGray}`, overflow: "hidden", boxShadow: "0 8px 32px rgba(27,27,27,0.1)" }}>
              <div style={{ height: 5, background: gradientFlow }} />
              <div style={{ padding: "22px 20px" }}>
                <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.warmGray, marginBottom: 10 }}>Session duration</div>
                <div style={{ display: "flex", gap: 8, marginBottom: 18 }}>
                  {([15, 30, 60] as const).map((d) => (
                    <button key={d} onClick={() => setSelectedDuration(d)} style={{ flex: 1, fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: selectedDuration === d ? "#fff" : brand.charcoal, background: selectedDuration === d ? gradientFlow : brand.offWhite, border: `1.5px solid ${selectedDuration === d ? "transparent" : brand.borderGray}`, borderRadius: 10, padding: "9px 4px", cursor: "pointer", transition: "all 0.15s" }}>
                      {d} min
                    </button>
                  ))}
                </div>
                <div style={{ display: "flex", alignItems: "baseline", gap: 6, marginBottom: 18 }}>
                  <span style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 28, color: brand.charcoal }}>EGP {durationPrice}</span>
                  <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>/ {selectedDuration} min</span>
                </div>
                <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.warmGray, marginBottom: 10 }}>Available slots</div>
                <CalendarStrip onSelect={(d, s) => { setSelectedDay(d); setSelectedSlot(s); }} />
                <button onClick={() => nav(`/tutoring/${id}/book`)} style={{ width: "100%", marginTop: 18, fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "13px", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 8, boxShadow: "0 4px 16px rgba(255,107,26,0.35)" }}>
                  {selectedSlot ? `Book at ${selectedSlot}` : "Book a Session"} <ArrowRight size={14} />
                </button>
                <button style={{ width: "100%", marginTop: 10, fontFamily: "Inter", fontWeight: 500, fontSize: 13, color: brand.charcoal, background: "none", border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "11px", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 6 }}>
                  <MessageSquare size={13} /> Send a Message First
                </button>
                <div style={{ marginTop: 14, display: "flex", gap: 6, alignItems: "flex-start" }}>
                  <Shield size={12} color={brand.warmGray} style={{ marginTop: 1, flexShrink: 0 }} />
                  <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, lineHeight: 1.5 }}>Free cancellation up to 24h before. Payment held securely until session is complete.</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
