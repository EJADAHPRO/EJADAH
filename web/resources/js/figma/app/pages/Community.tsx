import { useState } from "react";
import { useNavigate } from "react-router";
import { Heart, MessageSquare, Share2, Bookmark, TrendingUp, Users, CheckCircle, Plus } from "lucide-react";
import { brand, gradientFlow, GradientBadge, SectionHeader } from "@/figma/app/shared";

const posts = [
  { id: 1, type: "Clinical Case", author: "Dr. Hany Ibrahim", role: "Oral Surgeon · Verified Dentist", avatar: "https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=80&q=80", specialty: "Oral Surgery", time: "2h ago", title: "Complex periapical cyst enucleation — intraoperative challenge", content: "Encountered a surprisingly large periapical cyst associated with #46 (estimated 3×2 cm on CBCT). Sharing the flap design and step-by-step approach I used. Patient privacy: CBCT anonymized, no identifying information included. Would love input on your preferred closure technique in this anatomy.", likes: 142, comments: 38, saved: false, verified: true },
  { id: 2, type: "Exam Discussion", author: "Nour Khalil", role: "Dental Student · Cairo University", avatar: "https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=80&q=80", specialty: "EDLE Prep", time: "5h ago", title: "Pharmacology questions — what topics are repeating most in 2025?", content: "Just finished reviewing the last 3 years of EDLE pharmacology questions. NSAIDs mechanism, antibiotic choice for dental infections, and epinephrine contraindications appear in almost every exam. I'm creating a summary flashcard deck — anyone want to collaborate?", likes: 89, comments: 24, saved: true, verified: false },
  { id: 3, type: "Question", author: "Dr. Sara Mahmoud", role: "Endodontist · Assiut", avatar: "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=80&q=80", specialty: "Endodontics", time: "1d ago", title: "Preferred irrigation protocol for C-shaped canals?", content: "Working through a mandibular second molar with a classic C-shaped configuration. I typically use passive ultrasonic irrigation but struggling to get reliable debridement in the isthmus area. What's your go-to approach? Sodium hypochlorite concentration?", likes: 67, comments: 31, saved: false, verified: true },
];

const groups = [
  { name: "EDLE Study Group 2025", members: 4280, posts: 2100, icon: "🇪🇬" },
  { name: "ORE Candidates UK", members: 1840, posts: 890, icon: "🇬🇧" },
  { name: "Implantology Collective", members: 3100, posts: 1560, icon: "🦷" },
  { name: "Digital Dentistry Network", members: 2400, posts: 980, icon: "💻" },
];

const typeColors: Record<string, string> = { "Clinical Case": brand.orange, "Exam Discussion": brand.amber, "Question": brand.red };

function PostCard({ post }: { post: typeof posts[0] }) {
  const [liked, setLiked] = useState(false);
  const [saved, setSaved] = useState(post.saved);

  return (
    <div style={{ background: "#fff", borderRadius: 22, border: `1px solid ${brand.borderGray}`, padding: "24px", marginBottom: 16, boxShadow: "0 2px 10px rgba(27,27,27,0.04)" }}>
      {/* Header */}
      <div style={{ display: "flex", gap: 12, alignItems: "flex-start", marginBottom: 16 }}>
        <div style={{ position: "relative", flexShrink: 0 }}>
          <img src={post.avatar} alt={post.author} style={{ width: 46, height: 46, borderRadius: "50%", objectFit: "cover" }} />
          {post.verified && <div style={{ position: "absolute", bottom: 0, right: 0, width: 16, height: 16, borderRadius: "50%", background: gradientFlow, border: "2px solid #fff", display: "flex", alignItems: "center", justifyContent: "center" }}><CheckCircle size={8} color="#fff" /></div>}
        </div>
        <div style={{ flex: 1 }}>
          <div style={{ display: "flex", gap: 8, alignItems: "center", flexWrap: "wrap" }}>
            <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal }}>{post.author}</span>
            <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>· {post.role}</span>
          </div>
          <div style={{ display: "flex", gap: 8, marginTop: 4, flexWrap: "wrap" }}>
            <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 10, color: "#fff", background: typeColors[post.type] ?? brand.orange, borderRadius: 4, padding: "2px 7px" }}>{post.type.toUpperCase()}</span>
            <GradientBadge small>{post.specialty}</GradientBadge>
            <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{post.time}</span>
          </div>
        </div>
        <button onClick={() => setSaved(!saved)} style={{ background: "none", border: "none", cursor: "pointer", color: saved ? brand.amber : brand.warmGray }}>
          <Bookmark size={18} fill={saved ? brand.amber : "none"} />
        </button>
      </div>

      {/* Content */}
      <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 16, color: brand.charcoal, marginBottom: 8, lineHeight: 1.3 }}>{post.title}</div>
      <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, lineHeight: 1.65, marginBottom: 16 }}>{post.content}</p>

      {/* Actions */}
      <div style={{ display: "flex", gap: 20, paddingTop: 16, borderTop: `1px solid ${brand.borderGray}` }}>
        <button onClick={() => setLiked(!liked)} style={{ background: "none", border: "none", cursor: "pointer", color: liked ? brand.red : brand.warmGray, display: "flex", alignItems: "center", gap: 6, fontFamily: "Inter", fontSize: 13 }}>
          <Heart size={16} fill={liked ? brand.red : "none"} /> {post.likes + (liked ? 1 : 0)}
        </button>
        <button style={{ background: "none", border: "none", cursor: "pointer", color: brand.warmGray, display: "flex", alignItems: "center", gap: 6, fontFamily: "Inter", fontSize: 13 }}>
          <MessageSquare size={16} /> {post.comments}
        </button>
        <button style={{ background: "none", border: "none", cursor: "pointer", color: brand.warmGray, display: "flex", alignItems: "center", gap: 6, fontFamily: "Inter", fontSize: 13 }}>
          <Share2 size={16} /> Share
        </button>
      </div>
    </div>
  );
}

export default function Community() {
  const nav = useNavigate();
  const [activeFilter, setActiveFilter] = useState("All");
  const filters = ["All", "Clinical Cases", "Exam Discussions", "Questions", "Research", "Announcements"];

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Header */}
      <div style={{ background: brand.charcoal, padding: "48px 24px 40px" }}>
        <div style={{ maxWidth: 1280, margin: "0 auto" }}>
          <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, letterSpacing: "0.1em", color: brand.amber, textTransform: "uppercase" as const, marginBottom: 10 }}>Community</div>
          <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(26px,4vw,40px)", color: "#fff", marginBottom: 10 }}>Ejadah Dental Community</h1>
          <p style={{ fontFamily: "Inter", fontSize: 15, color: "rgba(255,255,255,0.6)", maxWidth: 500 }}>Clinical cases, exam discussions, research, and peer connections — all in one professional space.</p>
        </div>
      </div>

      <div style={{ maxWidth: 1280, margin: "0 auto", padding: "32px 24px", display: "flex", gap: 28, flexWrap: "wrap" }}>
        {/* Feed */}
        <div style={{ flex: "1 1 480px" }}>
          {/* Create post */}
          <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "16px 20px", marginBottom: 20, display: "flex", gap: 12, alignItems: "center" }}>
            <div style={{ width: 38, height: 38, borderRadius: "50%", background: gradientFlow, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
              <span style={{ color: "#fff", fontFamily: "Inter", fontWeight: 700, fontSize: 14 }}>Y</span>
            </div>
            <div style={{ flex: 1, background: brand.offWhite, borderRadius: 10, padding: "10px 16px", fontFamily: "Inter", fontSize: 14, color: brand.warmGray, cursor: "pointer" }}>Share a case, question, or discussion…</div>
            <button onClick={() => nav("/login")} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 8, padding: "8px 14px", cursor: "pointer", display: "flex", alignItems: "center", gap: 5 }}>
              <Plus size={14} /> Post
            </button>
          </div>

          {/* Filter chips */}
          <div style={{ display: "flex", gap: 8, flexWrap: "wrap", marginBottom: 20 }}>
            {filters.map((f) => (
              <button key={f} onClick={() => setActiveFilter(f)} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 12, color: activeFilter === f ? "#fff" : brand.charcoal, background: activeFilter === f ? gradientFlow : brand.white, border: `1.5px solid ${activeFilter === f ? "transparent" : brand.borderGray}`, borderRadius: 20, padding: "5px 14px", cursor: "pointer", transition: "all 0.15s" }}>{f}</button>
            ))}
          </div>

          {posts.map((post) => <PostCard key={post.id} post={post} />)}
        </div>

        {/* Sidebar */}
        <div style={{ flex: "0 1 300px" }}>
          {/* Trending */}
          <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "22px 20px", marginBottom: 20 }}>
            <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 16, fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal }}>
              <TrendingUp size={16} color={brand.orange} /> Trending This Week
            </div>
            {["EDLE 2025 question patterns", "All-on-4 vs All-on-6 debate", "Digital vs analog impressions", "Best rotary system for calcified canals", "ORE Part 1 resources 2025"].map((t, i) => (
              <div key={t} style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, padding: "8px 0", borderBottom: i < 4 ? `1px solid ${brand.borderGray}` : "none", cursor: "pointer", display: "flex", gap: 10, alignItems: "flex-start" }}>
                <span style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 16, color: brand.borderGray, flexShrink: 0 }}>{i + 1}</span>
                <span>{t}</span>
              </div>
            ))}
          </div>

          {/* Groups */}
          <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "22px 20px" }}>
            <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal, marginBottom: 16, display: "flex", alignItems: "center", gap: 8 }}>
              <Users size={16} color={brand.orange} /> Active Study Groups
            </div>
            {groups.map((g) => (
              <div key={g.name} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "10px 0", borderBottom: `1px solid ${brand.borderGray}`, cursor: "pointer" }}>
                <div style={{ display: "flex", gap: 10, alignItems: "center" }}>
                  <div style={{ width: 36, height: 36, borderRadius: 10, background: brand.offWhite, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 18 }}>{g.icon}</div>
                  <div>
                    <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal }}>{g.name}</div>
                    <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{g.members.toLocaleString()} members</div>
                  </div>
                </div>
                <button style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: brand.orange, background: "rgba(255,107,26,0.08)", border: "none", borderRadius: 6, padding: "5px 10px", cursor: "pointer" }}>Join</button>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
