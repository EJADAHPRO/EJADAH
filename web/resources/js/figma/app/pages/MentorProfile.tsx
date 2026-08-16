import { useState } from "react";
import { useNavigate, useParams } from "react-router";
import {
  Star, MapPin, Globe, CheckCircle, ArrowRight, MessageSquare,
  Bookmark, Share2, ChevronLeft, Users, Calendar, Clock,
  ThumbsUp, Shield, Award, Target,
} from "lucide-react";
import { brand, gradientFlow, GradientBadge } from "@/figma/app/shared";

const mentorData: Record<string, any> = {
  "1": {
    name: "Dr. Youssef Ramadan",
    title: "Implant Specialist · MSc King's College London",
    specialty: "Implantology",
    country: "Egypt / UK",
    languages: ["Arabic", "English"],
    rating: 4.9, reviewCount: 142, mentees: 58, successRate: 94,
    avatar: "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=300&q=80",
    available: true,
    areas: ["International Career Planning", "Specialty Selection", "Portfolio Building", "Postgraduate Applications", "Clinical Development", "ORE / ADC Pathway", "UK Dental Career"],
    bio: "I guide Egyptian dentists through the entire journey of building an international career — from exam preparation and CV writing to relocation and beyond. Having done this myself via the ORE and King's College London MSc, I understand every step of the process personally.\n\nI've mentored 58 dentists across different career stages. Some passed the ORE and are now working in the NHS. Others secured MSc placements in the UK and Europe. A few completely pivoted their career direction after our sessions together — and they tell me it was the best decision they ever made.",
    approach: "I don't give generic advice. In our first session, I map out where you are, where you want to go, and what's actually standing in your way. Then I build a realistic, personalised plan — with milestones, timelines, and accountability built in. I'm direct and honest. If your plan isn't feasible, I'll tell you — and I'll help you find one that is.",
    outcomes: ["58 mentees guided", "94% achieved primary goal", "32 now working internationally", "12 secured UK/European MSc placements", "Average ORE pass rate: 88%"],
    packages: [
      { label: "Single Session", sessions: 1, price: 600, duration: "60 min", desc: "One-off career consultation. Great for a second opinion or a focused question." },
      { label: "1 Month", sessions: 4, price: 2000, duration: "4 × 60 min", desc: "Foundation month — assessment, goal-setting, and first action plan.", popular: false },
      { label: "3 Months", sessions: 12, price: 5500, duration: "12 × 60 min", desc: "The most popular option. Real traction on your career goal with ongoing support.", popular: true },
      { label: "6 Months", sessions: 24, price: 9500, duration: "24 × 60 min", desc: "Full transformation program. For those committed to a major career shift.", popular: false },
    ],
    reviewsList: [
      { name: "Dr. Nour Abdelfattah", avatar: "https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=60&q=80", rating: 5, date: "Jun 2025", role: "Now working in UK", text: "Dr. Youssef didn't just help me prepare for the ORE — he completely reframed how I thought about my career. By month 3, I had a job offer in Manchester. This is the most valuable thing I've invested in as a dentist." },
      { name: "Dr. Tarek Fouad", avatar: "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=60&q=80", rating: 5, date: "Apr 2025", role: "MSc Student, London", text: "I came to Dr. Youssef completely lost about how to get into a UK MSc program. He reviewed my portfolio, told me exactly what was missing, and coached me through the application. I got into King's on my first attempt." },
      { name: "Dr. Sara Kamel", avatar: "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=60&q=80", rating: 5, date: "Feb 2025", role: "General Dentist, Cairo", text: "Even the single session was worth every pound. He gave me a clear picture of what the ORE actually involves and whether my timeline was realistic. Saved me months of misdirected preparation." },
    ],
  },
};

const calDates = [
  { d: 23, day: "Mon", slots: ["9:00 AM", "5:00 PM"] },
  { d: 24, day: "Tue", slots: ["11:00 AM", "7:00 PM"] },
  { d: 25, day: "Wed", slots: [] },
  { d: 26, day: "Thu", slots: ["9:00 AM", "3:00 PM"] },
  { d: 27, day: "Fri", slots: ["11:00 AM"] },
  { d: 28, day: "Sat", slots: ["1:00 PM", "5:00 PM"] },
  { d: 29, day: "Sun", slots: ["10:00 AM"] },
];

export default function MentorProfile() {
  const { id } = useParams();
  const nav = useNavigate();
  const mentor = mentorData[id ?? "1"] ?? mentorData["1"];

  const [activeTab, setActiveTab] = useState<"about" | "packages" | "reviews">("about");
  const [selectedPkg, setSelectedPkg] = useState(2);
  const [saved, setSaved] = useState(false);
  const [selectedDate, setSelectedDate] = useState<number | null>(null);
  const [selectedSlot, setSelectedSlot] = useState("");

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      <div style={{ maxWidth: 1280, margin: "0 auto", padding: "20px 24px 0" }}>
        <button onClick={() => nav("/mentoring")} style={{ background: "none", border: "none", cursor: "pointer", color: brand.warmGray, fontFamily: "Inter", fontSize: 13, display: "flex", alignItems: "center", gap: 5 }}>
          <ChevronLeft size={15} /> Back to Mentors
        </button>
      </div>

      {/* Hero */}
      <div style={{ background: `linear-gradient(135deg, ${brand.charcoal} 0%, #24201D 100%)`, marginTop: 16 }}>
        <div style={{ height: 6, background: `linear-gradient(90deg, ${brand.amber}, ${brand.gold})` }} />
        <div style={{ maxWidth: 1280, margin: "0 auto", padding: "40px 24px 36px", display: "flex", gap: 28, alignItems: "flex-start", flexWrap: "wrap" }}>
          <div style={{ display: "flex", gap: 22, alignItems: "flex-start", flex: 1 }}>
            <div style={{ position: "relative", flexShrink: 0 }}>
              <img src={mentor.avatar} alt={mentor.name} style={{ width: 100, height: 100, borderRadius: 20, objectFit: "cover", border: "3px solid rgba(255,255,255,0.12)" }} />
              <div style={{ position: "absolute", bottom: -3, right: -3, width: 20, height: 20, borderRadius: "50%", background: mentor.available ? "#2D9B68" : brand.warmGray, border: "3px solid #1B1B1B" }} />
            </div>
            <div>
              <div style={{ display: "flex", gap: 10, alignItems: "center", flexWrap: "wrap", marginBottom: 6 }}>
                <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(20px,3vw,28px)", color: "#fff" }}>{mentor.name}</h1>
                <div style={{ width: 20, height: 20, borderRadius: "50%", background: `linear-gradient(135deg, ${brand.amber}, ${brand.gold})`, display: "flex", alignItems: "center", justifyContent: "center" }}>
                  <CheckCircle size={11} color="#fff" />
                </div>
              </div>
              <div style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.55)", marginBottom: 12 }}>{mentor.title}</div>
              <div style={{ display: "flex", gap: 10, flexWrap: "wrap", marginBottom: 14 }}>
                <GradientBadge small>{mentor.specialty}</GradientBadge>
                <span style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.5)", display: "flex", alignItems: "center", gap: 4 }}><MapPin size={12} /> {mentor.country}</span>
                <span style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.5)", display: "flex", alignItems: "center", gap: 4 }}><Globe size={12} /> {mentor.languages.join(" · ")}</span>
              </div>
              <div style={{ display: "flex", gap: 20, flexWrap: "wrap" }}>
                {[
                  [`${mentor.rating}★`, `${mentor.reviewCount} reviews`],
                  [`${mentor.mentees}`, "mentees guided"],
                  [`${mentor.successRate}%`, "goal achievement rate"],
                ].map(([v, l]) => (
                  <div key={l}>
                    <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 16, color: brand.gold }}>{v}</span>
                    <span style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.45)", marginLeft: 6 }}>{l}</span>
                  </div>
                ))}
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
        <div style={{ flex: 1, minWidth: 300 }}>
          {/* Tabs */}
          <div style={{ display: "flex", borderBottom: `2px solid ${brand.borderGray}`, marginBottom: 28 }}>
            {(["about", "packages", "reviews"] as const).map((tab) => (
              <button key={tab} onClick={() => setActiveTab(tab)} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: activeTab === tab ? brand.amber : brand.warmGray, background: "none", border: "none", borderBottom: `2px solid ${activeTab === tab ? brand.amber : "transparent"}`, marginBottom: -2, padding: "10px 20px", cursor: "pointer", textTransform: "capitalize" as const }}>
                {tab === "reviews" ? `Reviews (${mentor.reviewCount})` : tab === "packages" ? "Programs" : "About"}
              </button>
            ))}
          </div>

          {activeTab === "about" && (
            <div>
              {[{ title: "About", content: mentor.bio }, { title: "Mentoring Approach", content: mentor.approach }].map((sec) => (
                <div key={sec.title} style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px 26px", marginBottom: 18 }}>
                  <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 14 }}>{sec.title}</h2>
                  {sec.content.split("\n\n").map((p: string, i: number) => <p key={i} style={{ fontFamily: "Inter", fontSize: 14, color: brand.charcoal, lineHeight: 1.75, marginBottom: 10 }}>{p}</p>)}
                </div>
              ))}
              <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px 26px", marginBottom: 18 }}>
                <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 14 }}>Mentoring Areas</h2>
                <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
                  {mentor.areas.map((a: string) => <span key={a} style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, background: `${brand.amber}10`, border: `1px solid ${brand.amber}30`, borderRadius: 8, padding: "6px 12px" }}>{a}</span>)}
                </div>
              </div>
              <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px 26px" }}>
                <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 14 }}>Proven Outcomes</h2>
                {mentor.outcomes.map((o: string) => (
                  <div key={o} style={{ display: "flex", gap: 10, alignItems: "center", marginBottom: 10 }}>
                    <Target size={14} color={brand.amber} style={{ flexShrink: 0 }} />
                    <span style={{ fontFamily: "Inter", fontSize: 14, color: brand.charcoal }}>{o}</span>
                  </div>
                ))}
              </div>
            </div>
          )}

          {activeTab === "packages" && (
            <div>
              <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px 26px", marginBottom: 18 }}>
                <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 20 }}>Mentoring Programs</h2>
                <div style={{ display: "flex", flexDirection: "column" as const, gap: 14 }}>
                  {mentor.packages.map((pkg: any, i: number) => {
                    const isSel = selectedPkg === i;
                    return (
                      <div key={pkg.label} onClick={() => setSelectedPkg(i)} style={{ borderRadius: 16, border: `2px solid ${isSel ? brand.amber : brand.borderGray}`, padding: "20px 20px", cursor: "pointer", background: isSel ? `${brand.amber}06` : brand.offWhite, position: "relative", transition: "all 0.15s" }}>
                        {pkg.popular && <div style={{ position: "absolute", top: -10, right: 14, background: `linear-gradient(135deg, ${brand.amber}, ${brand.gold})`, color: "#fff", fontFamily: "Inter", fontWeight: 700, fontSize: 10, borderRadius: 6, padding: "3px 10px" }}>MOST POPULAR</div>}
                        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
                          <div style={{ flex: 1 }}>
                            <div style={{ display: "flex", gap: 10, alignItems: "center", marginBottom: 4 }}>
                              <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 16, color: isSel ? brand.amber : brand.charcoal }}>{pkg.label}</span>
                              <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>· {pkg.duration}</span>
                            </div>
                            <p style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, lineHeight: 1.5, marginBottom: 0 }}>{pkg.desc}</p>
                          </div>
                          <div style={{ textAlign: "right" as const, flexShrink: 0, marginLeft: 20 }}>
                            <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: isSel ? brand.amber : brand.charcoal }}>EGP {pkg.price.toLocaleString()}</div>
                            {pkg.sessions > 1 && <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>EGP {Math.round(pkg.price / pkg.sessions)}/session</div>}
                            {isSel && <CheckCircle size={16} color={brand.amber} style={{ marginTop: 6 }} />}
                          </div>
                        </div>
                      </div>
                    );
                  })}
                </div>
                <button onClick={() => nav(`/mentoring/${id}`)} style={{ marginTop: 20, width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: "#fff", background: `linear-gradient(135deg, ${brand.amber}, ${brand.gold})`, border: "none", borderRadius: 12, padding: "14px", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 8, boxShadow: `0 4px 16px ${brand.amber}40` }}>
                  Book {mentor.packages[selectedPkg].label} <ArrowRight size={15} />
                </button>
              </div>
              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>
                {[
                  { icon: <Shield size={16} color={brand.amber} />, title: "Verified Mentor", desc: "Background and credentials confirmed by Ejadah" },
                  { icon: <Target size={16} color={brand.gold} />, title: `${mentor.successRate}% Success Rate`, desc: "Mentees who achieved their primary career goal" },
                  { icon: <Users size={16} color={brand.orange} />, title: `${mentor.mentees} Mentees`, desc: "Experienced with all stages and career types" },
                  { icon: <Award size={16} color={brand.red} />, title: "Satisfaction Guarantee", desc: "Full refund on first session if not satisfied" },
                ].map((b) => (
                  <div key={b.title} style={{ background: brand.white, borderRadius: 14, border: `1px solid ${brand.borderGray}`, padding: "14px 14px", display: "flex", gap: 10, alignItems: "flex-start" }}>
                    <div style={{ width: 34, height: 34, borderRadius: 10, background: brand.offWhite, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>{b.icon}</div>
                    <div><div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal }}>{b.title}</div><div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginTop: 2, lineHeight: 1.4 }}>{b.desc}</div></div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {activeTab === "reviews" && (
            <div>
              <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px 26px", marginBottom: 18 }}>
                <div style={{ display: "flex", gap: 28, alignItems: "center", flexWrap: "wrap" }}>
                  <div style={{ textAlign: "center" as const }}>
                    <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 52, color: brand.charcoal, lineHeight: 1 }}>{mentor.rating}</div>
                    <div style={{ display: "flex", justifyContent: "center", gap: 3, margin: "8px 0 4px" }}>{[1,2,3,4,5].map((i) => <Star key={i} size={15} fill={brand.amber} color={brand.amber} />)}</div>
                    <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>{mentor.reviewCount} reviews</div>
                  </div>
                  <div style={{ flex: 1, minWidth: 180 }}>
                    {[[5,88],[4,8],[3,3],[2,1],[1,0]].map(([s,p]) => (
                      <div key={s} style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 5 }}>
                        <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, width: 12 }}>{s}</span>
                        <Star size={10} fill={brand.amber} color={brand.amber} />
                        <div style={{ flex: 1, height: 5, background: brand.borderGray, borderRadius: 2, overflow: "hidden" }}>
                          <div style={{ height: "100%", width: `${p}%`, background: `linear-gradient(90deg, ${brand.amber}, ${brand.gold})`, borderRadius: 2 }} />
                        </div>
                        <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, width: 28 }}>{p}%</span>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
              {(mentor.reviewsList ?? []).map((r: any) => (
                <div key={r.name} style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "20px 22px", marginBottom: 12 }}>
                  <div style={{ display: "flex", gap: 12, alignItems: "flex-start", marginBottom: 10 }}>
                    <img src={r.avatar} alt={r.name} style={{ width: 42, height: 42, borderRadius: "50%", objectFit: "cover", flexShrink: 0 }} />
                    <div style={{ flex: 1 }}>
                      <div style={{ display: "flex", justifyContent: "space-between", flexWrap: "wrap" }}>
                        <div><div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal }}>{r.name}</div><div style={{ fontFamily: "Inter", fontSize: 12, color: brand.orange }}>{r.role}</div></div>
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
        </div>

        {/* Sticky sidebar */}
        <div style={{ width: 300, flexShrink: 0 }}>
          <div style={{ position: "sticky", top: 88 }}>
            <div style={{ background: brand.white, borderRadius: 22, border: `1px solid ${brand.borderGray}`, overflow: "hidden", boxShadow: "0 8px 32px rgba(27,27,27,0.1)" }}>
              <div style={{ height: 5, background: `linear-gradient(90deg, ${brand.amber}, ${brand.gold})` }} />
              <div style={{ padding: "22px 20px" }}>
                <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.warmGray, marginBottom: 10 }}>Selected program</div>
                <div style={{ background: `${brand.amber}08`, border: `1px solid ${brand.amber}25`, borderRadius: 12, padding: "12px 14px", marginBottom: 16 }}>
                  <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal }}>{mentor.packages[selectedPkg].label}</div>
                  <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginTop: 2 }}>{mentor.packages[selectedPkg].duration}</div>
                  <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.amber, marginTop: 6 }}>EGP {mentor.packages[selectedPkg].price.toLocaleString()}</div>
                </div>

                <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.warmGray, marginBottom: 10 }}>Pick a start date</div>
                <div style={{ display: "flex", gap: 5, marginBottom: 12 }}>
                  {calDates.map((c) => {
                    const has = c.slots.length > 0;
                    const isSel = selectedDate === c.d;
                    return (
                      <button key={c.d} onClick={() => has && setSelectedDate(c.d)} style={{ flex: 1, fontFamily: "Inter", fontWeight: 600, fontSize: 10, color: isSel ? "#fff" : has ? brand.charcoal : brand.borderGray, background: isSel ? `linear-gradient(135deg, ${brand.amber}, ${brand.gold})` : has ? brand.offWhite : "transparent", border: `1px solid ${isSel ? "transparent" : has ? brand.borderGray : brand.borderGray}`, borderRadius: 8, padding: "7px 2px", cursor: has ? "pointer" : "default", opacity: has ? 1 : 0.35, textAlign: "center" as const }}>
                        <div style={{ fontSize: 8, opacity: 0.7 }}>{c.day}</div>
                        <div>{c.d}</div>
                      </button>
                    );
                  })}
                </div>
                {selectedDate && (
                  <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 6, marginBottom: 14 }}>
                    {(calDates.find((c) => c.d === selectedDate)?.slots ?? []).map((slot) => {
                      const isSel = selectedSlot === slot;
                      return <button key={slot} onClick={() => setSelectedSlot(slot)} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 12, color: isSel ? "#fff" : brand.charcoal, background: isSel ? `linear-gradient(135deg, ${brand.amber}, ${brand.gold})` : brand.offWhite, border: `1.5px solid ${isSel ? "transparent" : brand.borderGray}`, borderRadius: 8, padding: "9px 4px", cursor: "pointer" }}>{slot}</button>;
                    })}
                  </div>
                )}

                <button style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: `linear-gradient(135deg, ${brand.amber}, ${brand.gold})`, border: "none", borderRadius: 12, padding: "13px", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 8, boxShadow: `0 4px 16px ${brand.amber}40` }}>
                  {selectedSlot ? `Book Jun ${selectedDate} · ${selectedSlot}` : "Book This Program"} <ArrowRight size={14} />
                </button>
                <button style={{ width: "100%", marginTop: 10, fontFamily: "Inter", fontWeight: 500, fontSize: 13, color: brand.charcoal, background: "none", border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "11px", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 6 }}>
                  <MessageSquare size={13} /> Message First
                </button>
                <div style={{ marginTop: 14, display: "flex", gap: 6, alignItems: "flex-start" }}>
                  <Shield size={12} color={brand.warmGray} style={{ marginTop: 1, flexShrink: 0 }} />
                  <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, lineHeight: 1.5 }}>Full refund on first session if not satisfied. Programs can be paused at any time.</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
