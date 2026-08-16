import { useState } from "react";
import { useNavigate, useParams } from "react-router";
import {
  ChevronLeft, ChevronRight, RotateCcw, Star, Flag,
  EyeOff, Plus, Shuffle, Brain, CheckCircle, X,
  BookOpen, Zap, ArrowRight, Settings,
} from "lucide-react";
import { brand, gradientFlow, gradientGlow } from "@/figma/app/shared";

type Mastery = "new" | "learning" | "difficult" | "reviewing" | "mastered";

const masteryConfig: Record<Mastery, { label: string; color: string; bg: string }> = {
  new:       { label: "New",       color: brand.warmGray, bg: brand.paleGray },
  learning:  { label: "Learning",  color: brand.amber,    bg: `${brand.amber}15` },
  difficult: { label: "Difficult", color: brand.red,      bg: `${brand.red}12` },
  reviewing: { label: "Reviewing", color: brand.orange,   bg: `${brand.orange}12` },
  mastered:  { label: "Mastered",  color: "#2D9B68",      bg: "rgba(45,155,104,0.1)" },
};

interface Card {
  id: number; front: string; back: string; mastery: Mastery;
  flagged: boolean; hidden: boolean;
}

const initialCards: Card[] = [
  { id: 1, front: "What is the most common canal configuration in mandibular first molars?", back: "Type IV (Vertucci) — 2 separate canals at the apex. The mesial root typically has 2 canals, the distal 1 or 2. A middle mesial canal is present in ~40% of cases.", mastery: "mastered", flagged: false, hidden: false },
  { id: 2, front: "Define 'symptomatic irreversible pulpitis'", back: "A clinical diagnosis based on subjective and objective findings indicating inflamed pulp that is incapable of healing. Characterised by: spontaneous pain, lingering pain to cold (>30 sec), normal periapical radiograph.", mastery: "reviewing", flagged: false, hidden: false },
  { id: 3, front: "What is the purpose of the glide path in rotary endodontics?", back: "A glide path is a smooth, reproducible, minimally sized, continuously tapering preparation from the canal orifice to the apical terminus. It prevents rotary file fracture by eliminating restrictive regions before instrument insertion.", mastery: "learning", flagged: true, hidden: false },
  { id: 4, front: "Name the 5 steps of the AAE periapical diagnosis classification", back: "1. Normal apical tissues\n2. Symptomatic apical periodontitis\n3. Asymptomatic apical periodontitis\n4. Acute apical abscess\n5. Chronic apical abscess", mastery: "new", flagged: false, hidden: false },
  { id: 5, front: "What is the primary irrigation solution in endodontics and why?", back: "Sodium hypochlorite (NaOCl) — 1–5.25% concentration. Properties: antimicrobial, dissolves organic tissue (vital and necrotic), lubricates canal. Limitation: cannot dissolve inorganic smear layer. Combined with EDTA for complete smear layer removal.", mastery: "difficult", flagged: true, hidden: false },
  { id: 6, front: "What does 'working length' refer to?", back: "The distance from a reference point on the crown of the tooth to the position at which canal preparation and obturation should terminate. Typically 0.5–1.0 mm short of the radiographic apex (at the CDJ — cemento-dentinal junction).", mastery: "learning", flagged: false, hidden: false },
  { id: 7, front: "Describe the ProTaper Gold file system sequence", back: "SX (shaping): orifice opener\nS1 (shaping 1): 17/.02\nS2 (shaping 2): 20/.04\nF1 (finishing 1): 20/.07\nF2 (finishing 2): 25/.08\nF3 (finishing 3): 30/.09\nEach used with in-and-out brushing motion, never forced.", mastery: "new", flagged: false, hidden: false },
  { id: 8, front: "What is 'apical transportation' and how is it prevented?", back: "Apical transportation is the deviation of the prepared canal from its original path at the apical region, resulting in a zip or elbow shape. Prevented by: establishing glide path first, using NiTi files with memory, crown-down technique, frequent irrigation.", mastery: "reviewing", flagged: false, hidden: false },
];

const stats = { new: 2, learning: 2, difficult: 1, reviewing: 2, mastered: 1 };

export default function Flashcards() {
  const { id } = useParams();
  const nav = useNavigate();
  const [cards, setCards] = useState<Card[]>(initialCards);
  const [idx, setIdx] = useState(0);
  const [flipped, setFlipped] = useState(false);
  const [mode, setMode] = useState<"study" | "browse">("study");
  const [filter, setFilter] = useState<Mastery | "all">("all");

  const visible = cards.filter((c) => !c.hidden && (filter === "all" || c.mastery === filter));
  const card = visible[idx % Math.max(visible.length, 1)];

  const setMastery = (m: Mastery) => {
    setCards((prev) => prev.map((c) => c.id === card.id ? { ...c, mastery: m } : c));
    setFlipped(false);
    setIdx((i) => (i + 1) % Math.max(visible.length, 1));
  };

  const toggleFlag = () => setCards((prev) => prev.map((c) => c.id === card.id ? { ...c, flagged: !c.flagged } : c));

  const total = cards.filter((c) => !c.hidden).length;
  const masteredCount = cards.filter((c) => c.mastery === "mastered").length;
  const progress = Math.round((masteredCount / total) * 100);

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Top bar */}
      <div style={{ background: brand.white, borderBottom: `1px solid ${brand.borderGray}`, position: "sticky", top: 0, zIndex: 50 }}>
        <div style={{ maxWidth: 900, margin: "0 auto", padding: "0 24px", height: 56, display: "flex", alignItems: "center", gap: 14 }}>
          <button onClick={() => nav(`/courses/${id}`)} style={{ background: "none", border: "none", cursor: "pointer", color: brand.warmGray, display: "flex", alignItems: "center", gap: 5, fontFamily: "Inter", fontSize: 13 }}>
            <ChevronLeft size={15} /> Back
          </button>
          <div style={{ height: 20, width: 1, background: brand.borderGray }} />
          <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.charcoal }}>Flashcards · {total} cards</div>
          <div style={{ flex: 1 }} />
          {/* Mode toggle */}
          <div style={{ display: "flex", background: brand.offWhite, border: `1px solid ${brand.borderGray}`, borderRadius: 8, overflow: "hidden" }}>
            {(["study", "browse"] as const).map((m) => (
              <button key={m} onClick={() => { setMode(m); setIdx(0); setFlipped(false); }}
                style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 12, color: mode === m ? "#fff" : brand.charcoal, background: mode === m ? gradientFlow : "transparent", border: "none", padding: "6px 14px", cursor: "pointer", textTransform: "capitalize" as const }}>
                {m}
              </button>
            ))}
          </div>
          <button style={{ background: "none", border: `1px solid ${brand.borderGray}`, borderRadius: 8, padding: "6px 10px", cursor: "pointer", color: brand.warmGray }}>
            <Settings size={15} />
          </button>
          <button style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: "#fff", background: gradientFlow, border: "none", borderRadius: 8, padding: "7px 14px", cursor: "pointer", display: "flex", alignItems: "center", gap: 5 }}>
            <Zap size={13} /> AI Generate
          </button>
        </div>
      </div>

      <div style={{ maxWidth: 900, margin: "0 auto", padding: "28px 24px" }}>
        {/* Progress + mastery stats */}
        <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "18px 22px", marginBottom: 24 }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 10 }}>
            <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal }}>Deck Mastery</div>
            <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.orange }}>{progress}% mastered</div>
          </div>
          <div style={{ height: 8, background: brand.borderGray, borderRadius: 4, overflow: "hidden", marginBottom: 14 }}>
            <div style={{ height: "100%", width: `${progress}%`, background: gradientFlow, borderRadius: 4, transition: "width 0.4s ease" }} />
          </div>
          <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
            {(Object.entries(masteryConfig) as [Mastery, typeof masteryConfig[Mastery]][]).map(([m, cfg]) => (
              <button key={m} onClick={() => { setFilter(filter === m ? "all" : m); setIdx(0); setFlipped(false); }}
                style={{ fontFamily: "Inter", fontWeight: filter === m ? 700 : 500, fontSize: 12, color: cfg.color, background: filter === m ? cfg.bg : brand.offWhite, border: `1.5px solid ${filter === m ? cfg.color : brand.borderGray}`, borderRadius: 8, padding: "5px 12px", cursor: "pointer", transition: "all 0.15s" }}>
                {cfg.label} ({stats[m] ?? cards.filter((c) => c.mastery === m).length})
              </button>
            ))}
            <button onClick={() => { setFilter("all"); setIdx(0); setFlipped(false); }}
              style={{ fontFamily: "Inter", fontWeight: filter === "all" ? 700 : 500, fontSize: 12, color: filter === "all" ? brand.charcoal : brand.warmGray, background: filter === "all" ? brand.paleGray : "transparent", border: `1.5px solid ${filter === "all" ? brand.charcoal : brand.borderGray}`, borderRadius: 8, padding: "5px 12px", cursor: "pointer" }}>
              All ({total})
            </button>
          </div>
        </div>

        {visible.length === 0 ? (
          <div style={{ textAlign: "center" as const, padding: "60px 0" }}>
            <div style={{ fontSize: 48, marginBottom: 12 }}>🎉</div>
            <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 24, color: brand.charcoal }}>No cards in this filter!</div>
          </div>
        ) : mode === "study" ? (
          /* ── Study mode ── */
          <div>
            {/* Counter */}
            <div style={{ textAlign: "center" as const, fontFamily: "Inter", fontSize: 13, color: brand.warmGray, marginBottom: 16 }}>
              Card {(idx % visible.length) + 1} of {visible.length}
            </div>

            {/* Flashcard */}
            <div
              onClick={() => setFlipped(!flipped)}
              style={{
                perspective: 1000,
                cursor: "pointer",
                maxWidth: 680,
                margin: "0 auto 24px",
              }}
            >
              <div style={{
                position: "relative",
                height: 320,
                transformStyle: "preserve-3d",
                transform: flipped ? "rotateY(180deg)" : "none",
                transition: "transform 0.45s ease",
              }}>
                {/* Front */}
                <div style={{
                  position: "absolute", inset: 0,
                  backfaceVisibility: "hidden",
                  background: brand.white,
                  borderRadius: 24,
                  border: `2px solid ${card.flagged ? brand.amber : brand.borderGray}`,
                  boxShadow: "0 8px 32px rgba(27,27,27,0.08)",
                  display: "flex", flexDirection: "column" as const, alignItems: "center", justifyContent: "center",
                  padding: "40px 48px",
                }}>
                  <div style={{ position: "absolute", top: 16, left: 20, display: "flex", gap: 8 }}>
                    <span style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 600, color: masteryConfig[card.mastery].color, background: masteryConfig[card.mastery].bg, borderRadius: 6, padding: "3px 8px" }}>
                      {masteryConfig[card.mastery].label}
                    </span>
                    {card.flagged && <Flag size={14} color={brand.amber} fill={brand.amber} />}
                  </div>
                  <div style={{ position: "absolute", bottom: 16, right: 20, fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>Tap to reveal answer</div>
                  <p style={{ fontFamily: "Playfair Display, serif", fontWeight: 600, fontSize: 20, color: brand.charcoal, textAlign: "center" as const, lineHeight: 1.4, margin: 0 }}>
                    {card.front}
                  </p>
                </div>

                {/* Back */}
                <div style={{
                  position: "absolute", inset: 0,
                  backfaceVisibility: "hidden",
                  transform: "rotateY(180deg)",
                  background: `linear-gradient(135deg, rgba(255,45,50,0.03), rgba(255,198,46,0.04))`,
                  borderRadius: 24,
                  border: `2px solid ${brand.orange}`,
                  boxShadow: "0 8px 32px rgba(255,107,26,0.12)",
                  display: "flex", flexDirection: "column" as const, alignItems: "center", justifyContent: "center",
                  padding: "40px 48px",
                }}>
                  <div style={{ position: "absolute", top: 16, left: 20 }}>
                    <span style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 700, color: brand.orange }}>ANSWER</span>
                  </div>
                  <p style={{ fontFamily: "Inter", fontSize: 15, color: brand.charcoal, textAlign: "center" as const, lineHeight: 1.7, margin: 0, whiteSpace: "pre-line" as const }}>
                    {card.back}
                  </p>
                </div>
              </div>
            </div>

            {/* Actions when flipped */}
            {flipped && (
              <div style={{ display: "flex", gap: 10, justifyContent: "center", flexWrap: "wrap", marginBottom: 20 }}>
                <button onClick={() => setMastery("difficult")} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: "#fff", background: brand.red, border: "none", borderRadius: 12, padding: "11px 20px", cursor: "pointer" }}>
                  <X size={13} style={{ marginRight: 5 }} />Still Difficult
                </button>
                <button onClick={() => setMastery("learning")} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: "#fff", background: brand.amber, border: "none", borderRadius: 12, padding: "11px 20px", cursor: "pointer" }}>
                  Learning
                </button>
                <button onClick={() => setMastery("reviewing")} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: "#fff", background: brand.orange, border: "none", borderRadius: 12, padding: "11px 20px", cursor: "pointer" }}>
                  Almost There
                </button>
                <button onClick={() => setMastery("mastered")} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff", background: "#2D9B68", border: "none", borderRadius: 12, padding: "11px 20px", cursor: "pointer" }}>
                  <CheckCircle size={13} style={{ marginRight: 5 }} />Mastered!
                </button>
              </div>
            )}

            {/* Nav controls */}
            <div style={{ display: "flex", gap: 14, justifyContent: "center", alignItems: "center" }}>
              <button onClick={() => { setIdx((i) => (i - 1 + visible.length) % visible.length); setFlipped(false); }}
                style={{ width: 44, height: 44, borderRadius: "50%", background: brand.white, border: `1.5px solid ${brand.borderGray}`, display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer" }}>
                <ChevronLeft size={18} color={brand.charcoal} />
              </button>
              <button onClick={toggleFlag} style={{ background: "none", border: "none", cursor: "pointer", color: card.flagged ? brand.amber : brand.warmGray }}>
                <Flag size={18} fill={card.flagged ? brand.amber : "none"} />
              </button>
              <button onClick={() => { setFlipped(false); setIdx(Math.floor(Math.random() * visible.length)); }}
                style={{ background: "none", border: "none", cursor: "pointer", color: brand.warmGray }}>
                <Shuffle size={18} />
              </button>
              <button onClick={() => { setFlipped(false); setIdx(0); }}
                style={{ background: "none", border: "none", cursor: "pointer", color: brand.warmGray }}>
                <RotateCcw size={16} />
              </button>
              <button onClick={() => { setIdx((i) => (i + 1) % visible.length); setFlipped(false); }}
                style={{ width: 44, height: 44, borderRadius: "50%", background: brand.white, border: `1.5px solid ${brand.borderGray}`, display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer" }}>
                <ChevronRight size={18} color={brand.charcoal} />
              </button>
            </div>
          </div>
        ) : (
          /* ── Browse mode ── */
          <div style={{ display: "flex", flexDirection: "column" as const, gap: 12 }}>
            {visible.map((c) => (
              <div key={c.id} style={{ background: brand.white, borderRadius: 16, border: `1px solid ${brand.borderGray}`, padding: "18px 20px", display: "flex", gap: 16, alignItems: "flex-start" }}>
                <div style={{ flex: 1 }}>
                  <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.charcoal, marginBottom: 6 }}>{c.front}</div>
                  <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, lineHeight: 1.55, whiteSpace: "pre-line" as const }}>{c.back}</div>
                </div>
                <div style={{ display: "flex", flexDirection: "column" as const, gap: 6, alignItems: "flex-end", flexShrink: 0 }}>
                  <span style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 600, color: masteryConfig[c.mastery].color, background: masteryConfig[c.mastery].bg, borderRadius: 6, padding: "3px 8px" }}>
                    {masteryConfig[c.mastery].label}
                  </span>
                  {c.flagged && <Flag size={13} color={brand.amber} fill={brand.amber} />}
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Add card + next nav */}
        <div style={{ display: "flex", gap: 12, justifyContent: "center", marginTop: 28 }}>
          <button style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 13, color: brand.charcoal, background: brand.white, border: `1.5px solid ${brand.borderGray}`, borderRadius: 10, padding: "10px 18px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}>
            <Plus size={14} /> Add Card
          </button>
          <button onClick={() => nav(`/courses/${id}/quiz`)} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "10px 20px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}>
            Take Quiz <ArrowRight size={14} />
          </button>
        </div>
      </div>
    </div>
  );
}
