import { useNavigate, useParams } from "react-router";
import { Play, Star, Clock, Users, Award, Bookmark, Share2, ChevronDown, CheckCircle, Lock, ArrowRight } from "lucide-react";
import { brand, gradientFlow, GradientBadge, StarRating } from "@/figma/app/shared";

const courseData: Record<string, { title: string; instructor: string; specialty: string; rating: number; students: number; duration: string; price: string; type: string; accredited: boolean; thumb: string; about: string; }> = {
  "1": { title: "Comprehensive Endodontics: From Basic to Advanced", instructor: "Dr. Amira Soliman", specialty: "Endodontics", rating: 4.8, students: 3420, duration: "22h", price: "EGP 1,200", type: "Recorded", accredited: true, thumb: "https://images.unsplash.com/photo-1588776814546-daab30f310ce?w=800&q=80", about: "A complete clinical endodontics program covering access cavity preparation, working length determination, canal shaping, obturation, retreatment, and complex case management. Built on current evidence and clinical excellence." },
  "2": { title: "Implantology Foundation: Evidence-Based Approach", instructor: "Dr. Omar Farid", specialty: "Implantology", rating: 4.9, students: 2100, duration: "30h", price: "EGP 1,800", type: "Live", accredited: true, thumb: "https://images.unsplash.com/photo-1619450565660-2a93ba8603fd?w=800&q=80", about: "From diagnosis and treatment planning to surgical placement and prosthetic restoration — a rigorous, clinically grounded implant program with live surgical demonstrations." },
  "3": { title: "Digital Workflow in Prosthodontics", instructor: "Dr. Laila Shawki", specialty: "Prosthodontics", rating: 4.7, students: 1850, duration: "18h", price: "EGP 950", type: "Hybrid", accredited: false, thumb: "https://images.unsplash.com/photo-1681939282781-341ac4f61996?w=800&q=80", about: "Integrate digital scanning, CAD/CAM design, and digital smile design into your prosthodontic workflow. Practical, hands-on, and built for modern dental practice." },
};

const curriculum = [
  { section: "Module 1: Foundations", lessons: [{ title: "Introduction & Course Overview", duration: "12 min", free: true }, { title: "Anatomy of the Root Canal System", duration: "28 min", free: true }, { title: "Pulp Biology & Diagnosis", duration: "35 min", free: false }] },
  { section: "Module 2: Access & Negotiation", lessons: [{ title: "Access Cavity Design — Anterior Teeth", duration: "40 min", free: false }, { title: "Access Cavity Design — Posterior Teeth", duration: "45 min", free: false }, { title: "Canal Negotiation & Glide Path", duration: "30 min", free: false }] },
  { section: "Module 3: Shaping & Obturation", lessons: [{ title: "Rotary Instrumentation Systems", duration: "52 min", free: false }, { title: "Irrigation Protocols", duration: "38 min", free: false }, { title: "Obturation Techniques", duration: "44 min", free: false }] },
  { section: "Module 4: Complex Cases", lessons: [{ title: "Calcified Canals", duration: "36 min", free: false }, { title: "Retreatment: Gutta-Percha Removal", duration: "42 min", free: false }, { title: "Separated Instrument Management", duration: "48 min", free: false }] },
];

export default function CourseDetail() {
  const { id } = useParams();
  const nav = useNavigate();
  const course = courseData[id ?? "1"] ?? courseData["1"];

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Hero */}
      <div style={{ background: brand.charcoal, padding: "0 0 0" }}>
        <div style={{ maxWidth: 1280, margin: "0 auto", padding: "48px 24px", display: "flex", gap: 48, alignItems: "flex-start", flexWrap: "wrap" }}>
          {/* Left */}
          <div style={{ flex: 1, minWidth: 280 }}>
            <div style={{ marginBottom: 12 }}><GradientBadge small>{course.specialty}</GradientBadge></div>
            <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(24px,3.5vw,36px)", color: "#fff", lineHeight: 1.2, marginBottom: 16 }}>{course.title}</h1>
            <p style={{ fontFamily: "Inter", fontSize: 15, color: "rgba(255,255,255,0.7)", lineHeight: 1.6, marginBottom: 20, maxWidth: 560 }}>{course.about}</p>
            <StarRating rating={course.rating} count={course.students} />
            <div style={{ display: "flex", gap: 20, marginTop: 12, flexWrap: "wrap" }}>
              <span style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.55)", display: "flex", alignItems: "center", gap: 5 }}><Clock size={13} /> {course.duration}</span>
              <span style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.55)", display: "flex", alignItems: "center", gap: 5 }}><Users size={13} /> {course.students.toLocaleString()} enrolled</span>
              {course.accredited && <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.amber, display: "flex", alignItems: "center", gap: 5 }}><Award size={13} /> CPD Accredited</span>}
            </div>
            <div style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.5)", marginTop: 10 }}>Instructor: <span style={{ color: "rgba(255,255,255,0.8)", fontWeight: 500 }}>{course.instructor}</span></div>
          </div>

          {/* Purchase card */}
          <div style={{ background: brand.white, borderRadius: 22, padding: 24, width: 320, flexShrink: 0, boxShadow: "0 12px 40px rgba(0,0,0,0.25)" }}>
            <div style={{ position: "relative", borderRadius: 14, overflow: "hidden", marginBottom: 18, height: 170 }}>
              <img src={course.thumb} alt={course.title} style={{ width: "100%", height: "100%", objectFit: "cover" }} />
              <div style={{ position: "absolute", inset: 0, background: "rgba(0,0,0,0.35)", display: "flex", alignItems: "center", justifyContent: "center" }}>
                <div style={{ width: 52, height: 52, borderRadius: "50%", background: "rgba(255,255,255,0.92)", display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer" }}>
                  <Play size={20} fill={brand.orange} color={brand.orange} style={{ marginLeft: 3 }} />
                </div>
              </div>
              <div style={{ position: "absolute", bottom: 10, left: 10, fontFamily: "Inter", fontSize: 11, color: "#fff", background: "rgba(0,0,0,0.6)", borderRadius: 6, padding: "3px 8px" }}>Preview Available</div>
            </div>
            <div style={{ display: "flex", alignItems: "baseline", gap: 8, marginBottom: 16 }}>
              <span style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 28, color: brand.charcoal }}>{course.price}</span>
              <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, textDecoration: "line-through" }}>EGP 2,400</span>
              <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.red }}>50% OFF</span>
            </div>
            <button onClick={() => nav("/checkout")} style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "14px", cursor: "pointer", marginBottom: 10, boxShadow: "0 4px 16px rgba(255,107,26,0.35)" }}>
              Enroll Now
            </button>
            <div style={{ display: "flex", gap: 8 }}>
              <button style={{ flex: 1, fontFamily: "Inter", fontWeight: 500, fontSize: 13, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 10, padding: "10px", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 5 }}><Bookmark size={13} /> Save</button>
              <button style={{ flex: 1, fontFamily: "Inter", fontWeight: 500, fontSize: 13, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 10, padding: "10px", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 5 }}><Share2 size={13} /> Share</button>
            </div>
            <div style={{ marginTop: 16, paddingTop: 16, borderTop: `1px solid ${brand.borderGray}` }}>
              {["Full lifetime access", "Downloadable handouts", "Certificate of completion", "CPD credits included"].map((f) => (
                <div key={f} style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 8 }}>
                  <CheckCircle size={13} color={brand.orange} />
                  <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.charcoal }}>{f}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* Body */}
      <div style={{ maxWidth: 1280, margin: "0 auto", padding: "40px 24px", display: "flex", gap: 40, flexWrap: "wrap" }}>
        <div style={{ flex: 1, minWidth: 280 }}>
          {/* Outcomes */}
          <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "28px 28px", marginBottom: 24 }}>
            <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 18 }}>What You Will Learn</h2>
            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>
              {["Diagnose pulpal & periapical pathology accurately", "Master rotary & reciprocating file systems", "Execute evidence-based irrigation protocols", "Manage calcified & complex canal anatomy", "Perform orthograde retreatment confidently", "Apply obturation techniques across multiple systems"].map((o) => (
                <div key={o} style={{ display: "flex", gap: 10, alignItems: "flex-start" }}>
                  <CheckCircle size={14} color={brand.orange} style={{ flexShrink: 0, marginTop: 2 }} />
                  <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, lineHeight: 1.5 }}>{o}</span>
                </div>
              ))}
            </div>
          </div>

          {/* Curriculum */}
          <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "28px", marginBottom: 24 }}>
            <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 18 }}>Course Curriculum</h2>
            {curriculum.map((module, mi) => (
              <div key={module.section} style={{ marginBottom: 16 }}>
                <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.charcoal, background: brand.paleGray, borderRadius: 10, padding: "12px 16px", marginBottom: 8 }}>
                  {module.section}
                </div>
                {module.lessons.map((lesson, li) => (
                  <div key={lesson.title} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "10px 16px", borderRadius: 8, background: li % 2 === 0 ? brand.offWhite : "transparent" }}>
                    <div style={{ display: "flex", gap: 10, alignItems: "center" }}>
                      {lesson.free ? <Play size={13} color={brand.orange} /> : <Lock size={13} color={brand.borderGray} />}
                      <span style={{ fontFamily: "Inter", fontSize: 13, color: lesson.free ? brand.charcoal : brand.warmGray }}>{lesson.title}</span>
                      {lesson.free && <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 10, color: brand.orange, background: "rgba(255,107,26,0.1)", borderRadius: 4, padding: "2px 6px" }}>FREE</span>}
                    </div>
                    <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>{lesson.duration}</span>
                  </div>
                ))}
              </div>
            ))}
            <button onClick={() => nav(`/courses/${id}/play`)} style={{ marginTop: 8, width: "100%", fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "13px", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 8 }}>
              <Play size={15} fill="#fff" /> Start Course <ArrowRight size={14} />
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
