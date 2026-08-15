import { useNavigate } from "react-router";
import { Zap, Star, Flame, Award, TrendingUp, ArrowRight, Users, Lock } from "lucide-react";
import { brand, gradientFlow, gradientGlow, GradientBadge } from "@/app/shared";

const levels = [
  { name: "Explorer", min: 0, max: 500, icon: "🔭", color: brand.warmGray },
  { name: "Learner", min: 500, max: 1500, icon: "📖", color: brand.amber },
  { name: "Practitioner", min: 1500, max: 3500, icon: "🦷", color: brand.orange },
  { name: "Advanced", min: 3500, max: 7000, icon: "⚙️", color: brand.red },
  { name: "Expert", min: 7000, max: 12000, icon: "🏆", color: "#8B5CF6" },
  { name: "Mentor", min: 12000, max: Infinity, icon: "🌟", color: brand.gold },
];

const currentXP = 2340;
const currentLevel = levels.find((l) => currentXP >= l.min && currentXP < l.max) ?? levels[2];
const nextLevel = levels[levels.indexOf(currentLevel) + 1];
const progress = nextLevel ? Math.round(((currentXP - currentLevel.min) / (nextLevel.min - currentLevel.min)) * 100) : 100;

const badges = [
  { name: "First Course", icon: "🎓", desc: "Completed your first Ejadah course", earned: true, date: "Jan 2025", xp: 50, rarity: "Common" },
  { name: "Clinical Explorer", icon: "🔬", desc: "Watched 5 live clinical demonstrations", earned: true, date: "Feb 2025", xp: 75, rarity: "Common" },
  { name: "Exam Ready", icon: "📝", desc: "Completed 100 EDLE practice questions", earned: true, date: "Mar 2025", xp: 100, rarity: "Uncommon" },
  { name: "7-Day Streak", icon: "🔥", desc: "Studied 7 days in a row", earned: true, date: "Apr 2025", xp: 150, rarity: "Uncommon" },
  { name: "Community Contributor", icon: "💬", desc: "Posted 10 answers in the dental community", earned: true, date: "May 2025", xp: 100, rarity: "Common" },
  { name: "Research Reader", icon: "📊", desc: "Read 20 research papers", earned: true, date: "Jun 2025", xp: 200, rarity: "Rare" },
  { name: "Live Learning Member", icon: "📡", desc: "Attended 5 live academy sessions", earned: true, date: "Jun 2025", xp: 175, rarity: "Uncommon" },
  { name: "Mastery Badge", icon: "⭐", desc: "Mastered all flashcards in a course", earned: false, xp: 300, rarity: "Rare" },
  { name: "30-Day Streak", icon: "⚡", desc: "Study every day for a month", earned: false, xp: 500, rarity: "Epic" },
  { name: "Top Contributor", icon: "🏅", desc: "Rank in top 50 community contributors", earned: false, xp: 400, rarity: "Rare" },
  { name: "Certified Expert", icon: "🎯", desc: "Earn 5 accredited CPD certificates", earned: false, xp: 600, rarity: "Epic" },
  { name: "Mentor Badge", icon: "🌟", desc: "Reach Mentor level (12,000+ XP)", earned: false, xp: 1000, rarity: "Legendary" },
];

const xpSources = [
  { action: "Complete a lesson", xp: "+5 XP" },
  { action: "Finish a course", xp: "+50 XP" },
  { action: "Pass a quiz (>80%)", xp: "+30 XP" },
  { action: "Attend live session", xp: "+40 XP" },
  { action: "Answer community question", xp: "+10 XP" },
  { action: "Read a research paper", xp: "+15 XP" },
  { action: "Daily study streak", xp: "+10 XP/day" },
  { action: "Master flashcard deck", xp: "+25 XP" },
];

const rarityColors: Record<string, string> = {
  Common: brand.warmGray, Uncommon: "#2D9B68", Rare: "#496FA8", Epic: "#8B5CF6", Legendary: brand.gold,
};

const leaderboard = [
  { rank: 1, name: "Dr. Sara Mahmoud", xp: 8420, level: "Expert", avatar: "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=40&q=80" },
  { rank: 2, name: "Dr. Khaled Ahmed", xp: 7890, level: "Expert", avatar: "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=40&q=80" },
  { rank: 3, name: "Dr. Nour Ali", xp: 6540, level: "Advanced", avatar: "https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=40&q=80" },
  { rank: 12, name: "You", xp: 2340, level: "Practitioner", avatar: null, isUser: true },
];

export default function Achievements() {
  const nav = useNavigate();

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Hero */}
      <div style={{ background: `linear-gradient(135deg, ${brand.deepCharcoal} 0%, #1e1a17 100%)`, padding: "56px 24px 48px", position: "relative", overflow: "hidden" }}>
        <div style={{ position: "absolute", inset: 0, background: `radial-gradient(ellipse at 60% 30%, ${brand.amber}12 0%, transparent 55%)`, pointerEvents: "none" }} />
        <div style={{ maxWidth: 1280, margin: "0 auto", position: "relative" }}>
          <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, letterSpacing: "0.1em", color: brand.amber, textTransform: "uppercase" as const, marginBottom: 10 }}>Gamification</div>
          <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(26px,4vw,40px)", color: "#fff", marginBottom: 10 }}>Achievements & Progress</h1>

          {/* Level card */}
          <div style={{ background: "rgba(255,255,255,0.05)", border: `1px solid rgba(255,255,255,0.1)`, borderRadius: 24, padding: "28px 28px", maxWidth: 700, marginTop: 24 }}>
            <div style={{ display: "flex", gap: 20, alignItems: "center", marginBottom: 20 }}>
              <div style={{ fontSize: 52 }}>{currentLevel.icon}</div>
              <div style={{ flex: 1 }}>
                <div style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.5)", marginBottom: 4 }}>Current Level</div>
                <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 28, color: currentLevel.color }}>{currentLevel.name}</div>
                <div style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.55)", marginTop: 2 }}>{currentXP.toLocaleString()} XP{nextLevel ? ` · ${(nextLevel.min - currentXP).toLocaleString()} XP to ${nextLevel.name}` : " · Max level!"}</div>
              </div>
              <div style={{ textAlign: "right" as const }}>
                <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 36, color: brand.gold }}>{currentXP.toLocaleString()}</div>
                <div style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.4)" }}>Total XP</div>
              </div>
            </div>
            <div style={{ height: 10, background: "rgba(255,255,255,0.1)", borderRadius: 5, overflow: "hidden", marginBottom: 8 }}>
              <div style={{ height: "100%", width: `${progress}%`, background: gradientGlow, borderRadius: 5, transition: "width 0.6s ease" }} />
            </div>
            <div style={{ display: "flex", justifyContent: "space-between", fontFamily: "Inter", fontSize: 11, color: "rgba(255,255,255,0.4)" }}>
              <span>{currentLevel.name} ({currentLevel.min.toLocaleString()} XP)</span>
              {nextLevel && <span>{nextLevel.name} ({nextLevel.min.toLocaleString()} XP)</span>}
            </div>

            {/* Level progression dots */}
            <div style={{ display: "flex", gap: 0, marginTop: 20, alignItems: "center" }}>
              {levels.map((l, i) => {
                const reached = currentXP >= l.min;
                const isCurrent = l.name === currentLevel.name;
                return (
                  <div key={l.name} style={{ display: "flex", alignItems: "center", flex: i < levels.length - 1 ? 1 : 0 }}>
                    <div style={{ display: "flex", flexDirection: "column" as const, alignItems: "center", gap: 4 }}>
                      <div style={{ width: isCurrent ? 32 : 24, height: isCurrent ? 32 : 24, borderRadius: "50%", background: reached ? l.color : "rgba(255,255,255,0.1)", display: "flex", alignItems: "center", justifyContent: "center", fontSize: isCurrent ? 16 : 12, transition: "all 0.3s", border: isCurrent ? `3px solid ${brand.gold}` : "none" }}>{l.icon}</div>
                      <div style={{ fontFamily: "Inter", fontSize: 8, color: reached ? "rgba(255,255,255,0.7)" : "rgba(255,255,255,0.25)" }}>{l.name}</div>
                    </div>
                    {i < levels.length - 1 && <div style={{ flex: 1, height: 2, background: reached ? l.color : "rgba(255,255,255,0.1)", margin: "0 4px", marginBottom: 14 }} />}
                  </div>
                );
              })}
            </div>
          </div>

          {/* Quick stats */}
          <div style={{ display: "flex", gap: 20, marginTop: 24, flexWrap: "wrap" }}>
            {[["🔥 12 days", "Study Streak"], ["🎓 5", "Courses Done"], ["📜 3", "Certificates"], ["✅ 324", "Questions Answered"]].map(([v, l]) => (
              <div key={l}><div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 16, color: brand.gold }}>{v}</div><div style={{ fontFamily: "Inter", fontSize: 11, color: "rgba(255,255,255,0.45)", marginTop: 2 }}>{l}</div></div>
            ))}
          </div>
        </div>
      </div>

      <div style={{ maxWidth: 1280, margin: "0 auto", padding: "32px 24px" }}>
        <div style={{ display: "flex", gap: 24, flexWrap: "wrap" }}>
          {/* Main: badges */}
          <div style={{ flex: 1, minWidth: 300 }}>
            <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.charcoal, marginBottom: 20 }}>Badges</div>
            {/* Earned */}
            <div style={{ marginBottom: 28 }}>
              <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: "#2D9B68", letterSpacing: "0.08em", textTransform: "uppercase" as const, marginBottom: 14 }}>✓ Earned ({badges.filter((b) => b.earned).length})</div>
              <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(200px, 1fr))", gap: 12 }}>
                {badges.filter((b) => b.earned).map((badge) => (
                  <div key={badge.name} style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "18px 16px", textAlign: "center" as const }}>
                    <div style={{ fontSize: 36, marginBottom: 8 }}>{badge.icon}</div>
                    <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal, marginBottom: 4 }}>{badge.name}</div>
                    <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, lineHeight: 1.4, marginBottom: 8 }}>{badge.desc}</div>
                    <div style={{ display: "flex", justifyContent: "center", gap: 8 }}>
                      <span style={{ fontFamily: "Inter", fontSize: 10, fontWeight: 700, color: rarityColors[badge.rarity], background: `${rarityColors[badge.rarity]}15`, borderRadius: 5, padding: "2px 7px" }}>{badge.rarity}</span>
                      <span style={{ fontFamily: "Inter", fontSize: 10, color: brand.amber, background: `${brand.amber}12`, borderRadius: 5, padding: "2px 7px" }}>+{badge.xp} XP</span>
                    </div>
                    {badge.date && <div style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray, marginTop: 6 }}>{badge.date}</div>}
                  </div>
                ))}
              </div>
            </div>

            {/* Locked */}
            <div>
              <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.warmGray, letterSpacing: "0.08em", textTransform: "uppercase" as const, marginBottom: 14 }}>🔒 Not Yet Earned ({badges.filter((b) => !b.earned).length})</div>
              <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(200px, 1fr))", gap: 12 }}>
                {badges.filter((b) => !b.earned).map((badge) => (
                  <div key={badge.name} style={{ background: brand.paleGray, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "18px 16px", textAlign: "center" as const, opacity: 0.7 }}>
                    <div style={{ fontSize: 36, marginBottom: 8, filter: "grayscale(1)" }}>{badge.icon}</div>
                    <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.warmGray, marginBottom: 4 }}>{badge.name}</div>
                    <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, lineHeight: 1.4, marginBottom: 8 }}>{badge.desc}</div>
                    <div style={{ display: "flex", justifyContent: "center", gap: 8 }}>
                      <span style={{ fontFamily: "Inter", fontSize: 10, fontWeight: 700, color: rarityColors[badge.rarity], background: `${rarityColors[badge.rarity]}15`, borderRadius: 5, padding: "2px 7px" }}>{badge.rarity}</span>
                      <span style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray, background: brand.borderGray, borderRadius: 5, padding: "2px 7px" }}>+{badge.xp} XP</span>
                    </div>
                    <div style={{ display: "flex", alignItems: "center", justifyContent: "center", gap: 4, marginTop: 6 }}>
                      <Lock size={10} color={brand.warmGray} /><span style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray }}>Locked</span>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Sidebar */}
          <div style={{ width: 290, flexShrink: 0 }}>
            <div style={{ display: "flex", flexDirection: "column" as const, gap: 16 }}>
              {/* Leaderboard */}
              <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "20px" }}>
                <div style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 16 }}>
                  <Users size={15} color={brand.orange} />
                  <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal }}>Leaderboard</div>
                </div>
                {leaderboard.map((entry) => (
                  <div key={entry.rank} style={{ display: "flex", gap: 10, alignItems: "center", padding: "9px 0", borderBottom: `1px solid ${brand.borderGray}`, background: entry.isUser ? "rgba(255,107,26,0.04)" : "transparent", borderRadius: entry.isUser ? 8 : 0 }}>
                    <div style={{ width: 24, fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 15, color: entry.rank <= 3 ? brand.gold : brand.warmGray, textAlign: "center" as const }}>{entry.rank <= 3 ? ["🥇","🥈","🥉"][entry.rank - 1] : `#${entry.rank}`}</div>
                    {entry.avatar ? <img src={entry.avatar} alt={entry.name} style={{ width: 30, height: 30, borderRadius: "50%", objectFit: "cover" }} /> : <div style={{ width: 30, height: 30, borderRadius: "50%", background: gradientFlow, display: "flex", alignItems: "center", justifyContent: "center", fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: "#fff" }}>Y</div>}
                    <div style={{ flex: 1 }}>
                      <div style={{ fontFamily: "Inter", fontWeight: entry.isUser ? 700 : 500, fontSize: 13, color: entry.isUser ? brand.orange : brand.charcoal }}>{entry.name}</div>
                      <div style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray }}>{entry.xp.toLocaleString()} XP</div>
                    </div>
                  </div>
                ))}
              </div>

              {/* XP sources */}
              <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "20px" }}>
                <div style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 14 }}>
                  <Zap size={15} color={brand.amber} />
                  <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal }}>How to Earn XP</div>
                </div>
                {xpSources.map((s) => (
                  <div key={s.action} style={{ display: "flex", justifyContent: "space-between", padding: "7px 0", borderBottom: `1px solid ${brand.borderGray}` }}>
                    <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>{s.action}</span>
                    <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.amber }}>{s.xp}</span>
                  </div>
                ))}
              </div>

              <button onClick={() => nav("/courses")} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "13px", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 8 }}>
                Earn More XP <ArrowRight size={14} />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
