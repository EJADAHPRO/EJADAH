import { useNavigate } from "react-router";
import { Radio, Calendar, Clock, Users, MapPin, ArrowRight, Play } from "lucide-react";
import { brand, gradientFlow, GradientBadge, LiveBadge, SectionHeader } from "@/app/shared";

const liveNow = {
  title: "Surgical Exodontia: Impacted Third Molars",
  instructor: "Dr. Hany Ibrahim",
  affiliation: "Alexandria University",
  specialty: "Oral Surgery",
  watching: 342,
  thumb: "https://images.unsplash.com/photo-1619450565660-2a93ba8603fd?w=900&q=80",
};

const upcoming = [
  { title: "Orthodontic Finishing & Retention Protocols", instructor: "Dr. Mona Khalil", date: "Today", time: "8:00 PM GMT+2", seats: 23, total: 80, price: "EGP 450", rec: false, specialty: "Orthodontics" },
  { title: "All-on-4 Treatment Planning: Clinical & Prosthetic", instructor: "Dr. Youssef Ramadan", date: "Tomorrow", time: "7:00 PM GMT+2", seats: 41, total: 100, price: "EGP 700", rec: true, specialty: "Implantology" },
  { title: "Periodontal Surgery: Flap Design & Suturing", instructor: "Dr. Rania Hassan", date: "Jun 24", time: "6:00 PM GMT+2", seats: 12, total: 60, price: "EGP 500", rec: false, specialty: "Periodontics" },
  { title: "Digital Occlusion Analysis in Daily Practice", instructor: "Dr. Laila Shawki", date: "Jun 25", time: "8:00 PM GMT+2", seats: 55, total: 80, price: "EGP 650", rec: true, specialty: "Prosthodontics" },
  { title: "Pediatric Pulp Therapy: Evidence Update 2025", instructor: "Dr. Yasmine Adel", date: "Jun 26", time: "7:00 PM GMT+2", seats: 38, total: 60, price: "EGP 350", rec: false, specialty: "Pediatric Dentistry" },
  { title: "Bone Grafting for Implant Site Development", instructor: "Dr. Omar Farid", date: "Jun 28", time: "6:30 PM GMT+2", seats: 20, total: 50, price: "EGP 800", rec: false, specialty: "Implantology" },
];

export default function LiveAcademy() {
  const nav = useNavigate();

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Header */}
      <div style={{ background: brand.deepCharcoal, padding: "56px 24px 48px", position: "relative", overflow: "hidden" }}>
        <div style={{ position: "absolute", inset: 0, background: "radial-gradient(ellipse at 60% 50%, rgba(255,45,50,0.1) 0%, transparent 60%)", pointerEvents: "none" }} />
        <div style={{ maxWidth: 1280, margin: "0 auto", position: "relative" }}>
          <div style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: 12 }}>
            <LiveBadge />
            <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, letterSpacing: "0.1em", color: brand.amber, textTransform: "uppercase" as const }}>Live Academy</span>
          </div>
          <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(28px,4vw,42px)", color: "#fff", marginBottom: 12 }}>Real-Time Dental Education</h1>
          <p style={{ fontFamily: "Inter", fontSize: 16, color: "rgba(255,255,255,0.6)", maxWidth: 560 }}>Live sessions with global dental educators. Some courses are live-only with no recordings — attend at the scheduled time to earn your certificate.</p>
        </div>
      </div>

      <div style={{ maxWidth: 1280, margin: "0 auto", padding: "40px 24px" }}>
        {/* Live Now */}
        <div style={{ marginBottom: 48 }}>
          <SectionHeader label="Happening Now" title="Live Session In Progress" />
          <div style={{ background: brand.charcoal, borderRadius: 24, overflow: "hidden", display: "flex", flexWrap: "wrap", position: "relative" }}>
            <div style={{ flex: "1 1 420px", position: "relative", minHeight: 300 }}>
              <img src={liveNow.thumb} alt="Live session" style={{ width: "100%", height: "100%", objectFit: "cover", opacity: 0.75 }} />
              <div style={{ position: "absolute", inset: 0, background: "linear-gradient(to right, rgba(18,18,18,0.5), transparent)" }} />
              <div style={{ position: "absolute", top: 20, left: 20 }}><LiveBadge /></div>
              <div style={{ position: "absolute", top: 20, right: 20, fontFamily: "Inter", fontSize: 12, color: "#fff", background: "rgba(0,0,0,0.5)", borderRadius: 8, padding: "4px 12px", display: "flex", alignItems: "center", gap: 5 }}><Users size={12} /> {liveNow.watching} watching</div>
              <div style={{ position: "absolute", inset: 0, display: "flex", alignItems: "center", justifyContent: "center" }}>
                <div style={{ width: 64, height: 64, borderRadius: "50%", background: brand.red, display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer", boxShadow: "0 0 0 12px rgba(255,45,50,0.2)" }}>
                  <Play size={24} fill="#fff" color="#fff" style={{ marginLeft: 4 }} />
                </div>
              </div>
            </div>
            <div style={{ flex: "1 1 320px", padding: "32px 28px", display: "flex", flexDirection: "column", justifyContent: "center" }}>
              <GradientBadge small>{liveNow.specialty}</GradientBadge>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: "#fff", margin: "14px 0 8px", lineHeight: 1.25 }}>{liveNow.title}</div>
              <div style={{ fontFamily: "Inter", fontSize: 14, color: "rgba(255,255,255,0.6)", marginBottom: 20 }}>{liveNow.instructor} · {liveNow.affiliation}</div>
              <div style={{ display: "inline-block", fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: brand.red, border: `1px solid ${brand.red}`, borderRadius: 6, padding: "3px 10px", marginBottom: 20, letterSpacing: "0.05em" }}>LIVE ONLY — NO RECORDING</div>
              <button style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: "#fff", background: brand.red, border: "none", borderRadius: 12, padding: "14px 28px", cursor: "pointer", display: "flex", alignItems: "center", gap: 8, width: "fit-content", boxShadow: "0 4px 16px rgba(255,45,50,0.4)" }}>
                <Radio size={16} /> Join Now
              </button>
            </div>
          </div>
        </div>

        {/* Upcoming */}
        <div>
          <SectionHeader label="Schedule" title="Upcoming Live Sessions" />
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(340px, 1fr))", gap: 18 }}>
            {upcoming.map((s) => (
              <div key={s.title} style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "22px 22px", cursor: "pointer", transition: "transform 0.2s, box-shadow 0.2s" }}
                onMouseEnter={(e) => { (e.currentTarget as HTMLElement).style.transform = "translateY(-4px)"; (e.currentTarget as HTMLElement).style.boxShadow = "0 10px 28px rgba(27,27,27,0.1)"; }}
                onMouseLeave={(e) => { (e.currentTarget as HTMLElement).style.transform = "none"; (e.currentTarget as HTMLElement).style.boxShadow = "none"; }}
              >
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 12 }}>
                  <GradientBadge small>{s.specialty}</GradientBadge>
                  {!s.rec && <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 9, color: brand.red, border: `1px solid ${brand.red}`, borderRadius: 4, padding: "2px 6px", letterSpacing: "0.05em" }}>NO RECORDING</span>}
                </div>
                <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 15, color: brand.charcoal, marginBottom: 6, lineHeight: 1.35 }}>{s.title}</div>
                <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, marginBottom: 14 }}>{s.instructor}</div>
                <div style={{ display: "flex", gap: 16, marginBottom: 14, flexWrap: "wrap" }}>
                  <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.charcoal, display: "flex", alignItems: "center", gap: 5 }}><Calendar size={12} color={brand.amber} /> {s.date}</span>
                  <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.charcoal, display: "flex", alignItems: "center", gap: 5 }}><Clock size={12} color={brand.amber} /> {s.time}</span>
                  <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.charcoal, display: "flex", alignItems: "center", gap: 5 }}><Users size={12} color={brand.amber} /> {s.seats} of {s.total} seats</span>
                </div>
                {/* Seats bar */}
                <div style={{ background: brand.borderGray, borderRadius: 4, height: 5, overflow: "hidden", marginBottom: 16 }}>
                  <div style={{ height: "100%", width: `${((s.total - s.seats) / s.total) * 100}%`, background: s.seats < 20 ? brand.red : gradientFlow, borderRadius: 4 }} />
                </div>
                {s.seats < 20 && <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.red, fontWeight: 600, marginBottom: 12 }}>⚡ Only {s.seats} seats remaining</div>}
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                  <span style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal }}>{s.price}</span>
                  <button style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "10px 20px", cursor: "pointer" }}>Reserve Seat</button>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
