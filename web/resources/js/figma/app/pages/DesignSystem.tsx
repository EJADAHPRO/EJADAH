import { useState } from "react";
import { brand, gradientFlow, GradientBadge, LiveBadge, StarRating, ProgressPath } from "@/figma/app/shared";
import { CheckCircle, Bookmark, Bell, Search, ChevronDown, X } from "lucide-react";

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div style={{ marginBottom: 40 }}>
      <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: brand.orange, letterSpacing: "0.1em", textTransform: "uppercase" as const, marginBottom: 16 }}>{title}</div>
      {children}
    </div>
  );
}

function Label({ text }: { text: string }) {
  return <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginBottom: 6 }}>{text}</div>;
}

export default function DesignSystem() {
  const [inputVal, setInputVal] = useState("");
  const [checked, setChecked] = useState(false);

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      <div style={{ background: brand.charcoal, padding: "40px 24px 32px" }}>
        <div style={{ maxWidth: 1100, margin: "0 auto" }}>
          <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: brand.amber, letterSpacing: "0.1em", textTransform: "uppercase" as const, marginBottom: 10 }}>Internal Reference</div>
          <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 36, color: "#fff", marginBottom: 6 }}>Design System</h1>
          <p style={{ fontFamily: "Inter", fontSize: 14, color: "rgba(255,255,255,0.55)" }}>Component library · Ejadah International Academy</p>
        </div>
      </div>

      <div style={{ maxWidth: 1100, margin: "0 auto", padding: "40px 24px" }}>
        {/* Buttons */}
        <Section title="Buttons">
          <div style={{ display: "flex", gap: 12, flexWrap: "wrap", marginBottom: 16 }}>
            <div><Label text="Primary" /><button style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "12px 22px", cursor: "pointer" }}>Primary Button</button></div>
            <div><Label text="Secondary" /><button style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 14, color: brand.charcoal, background: brand.white, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 22px", cursor: "pointer" }}>Secondary</button></div>
            <div><Label text="Ghost" /><button style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 14, color: brand.orange, background: "rgba(255,107,26,0.08)", border: "none", borderRadius: 12, padding: "12px 22px", cursor: "pointer" }}>Ghost</button></div>
            <div><Label text="Destructive" /><button style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: "#fff", background: brand.red, border: "none", borderRadius: 12, padding: "12px 22px", cursor: "pointer" }}>Destructive</button></div>
            <div><Label text="Disabled" /><button disabled style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 14, color: brand.warmGray, background: brand.borderGray, border: "none", borderRadius: 12, padding: "12px 22px", cursor: "default" }}>Disabled</button></div>
          </div>
          <div style={{ display: "flex", gap: 12, flexWrap: "wrap" }}>
            <div><Label text="Small" /><button style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: "#fff", background: gradientFlow, border: "none", borderRadius: 8, padding: "7px 14px", cursor: "pointer" }}>Small</button></div>
            <div><Label text="Large" /><button style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 16, color: "#fff", background: gradientFlow, border: "none", borderRadius: 14, padding: "16px 32px", cursor: "pointer" }}>Large Button</button></div>
          </div>
        </Section>

        {/* Badges */}
        <Section title="Badges & Labels">
          <div style={{ display: "flex", gap: 12, flexWrap: "wrap", alignItems: "center" }}>
            <div><Label text="Gradient Badge" /><GradientBadge>Endodontics</GradientBadge></div>
            <div><Label text="Gradient Badge Small" /><GradientBadge small>Endodontics</GradientBadge></div>
            <div><Label text="Live Badge" /><LiveBadge /></div>
            {[["Recorded", brand.warmGray], ["Hybrid", brand.orange], ["Accredited", brand.amber], ["Free", brand.gold]].map(([l, c]) => (
              <div key={l as string}><Label text={l as string} /><span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: "#fff", background: c as string, borderRadius: 5, padding: "3px 9px" }}>{l as string}</span></div>
            ))}
          </div>
        </Section>

        {/* Progress */}
        <Section title="Progress Indicators">
          <div style={{ display: "flex", flexDirection: "column" as const, gap: 12, maxWidth: 400 }}>
            <div><Label text="22% (new)" /><ProgressPath percent={22} /></div>
            <div><Label text="68% (in progress)" /><ProgressPath percent={68} /></div>
            <div><Label text="100% (complete)" /><ProgressPath percent={100} /></div>
          </div>
        </Section>

        {/* Star Rating */}
        <Section title="Star Rating">
          <div style={{ display: "flex", gap: 20 }}>
            <div><Label text="4.8 with count" /><StarRating rating={4.8} count={1284} /></div>
            <div><Label text="5.0 no count" /><StarRating rating={5} /></div>
            <div><Label text="3.2" /><StarRating rating={3.2} count={42} /></div>
          </div>
        </Section>

        {/* Inputs */}
        <Section title="Form Controls">
          <div style={{ display: "flex", gap: 20, flexWrap: "wrap" }}>
            <div style={{ flex: 1, minWidth: 220 }}>
              <Label text="Text Input" />
              <input value={inputVal} onChange={(e) => setInputVal(e.target.value)} placeholder="Type something…"
                style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.white, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 14px", outline: "none", boxSizing: "border-box" as const }} />
            </div>
            <div style={{ flex: 1, minWidth: 220 }}>
              <Label text="Search Input" />
              <div style={{ position: "relative" }}>
                <Search size={15} style={{ position: "absolute", left: 13, top: "50%", transform: "translateY(-50%)", color: brand.warmGray }} />
                <input placeholder="Search…" style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 14px 12px 38px", outline: "none", boxSizing: "border-box" as const }} />
              </div>
            </div>
            <div style={{ flex: 1, minWidth: 220 }}>
              <Label text="Select" />
              <div style={{ position: "relative" }}>
                <select style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.white, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 36px 12px 14px", outline: "none", appearance: "none" as const }}>
                  <option>Select option…</option><option>Endodontics</option><option>Implantology</option>
                </select>
                <ChevronDown size={14} style={{ position: "absolute", right: 12, top: "50%", transform: "translateY(-50%)", color: brand.warmGray, pointerEvents: "none" }} />
              </div>
            </div>
          </div>
        </Section>

        {/* Cards */}
        <Section title="Card Variants">
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(240px, 1fr))", gap: 14 }}>
            {[["Standard Card", brand.white, brand.borderGray, brand.charcoal], ["Highlighted Card", `${brand.orange}06`, brand.orange, brand.charcoal], ["Dark Card", brand.charcoal, "transparent", "#fff"]].map(([label, bg, border, text]) => (
              <div key={label as string} style={{ background: bg as string, borderRadius: 18, border: `1.5px solid ${border as string}`, padding: "20px" }}>
                <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 16, color: text as string, marginBottom: 6 }}>{label as string}</div>
                <div style={{ fontFamily: "Inter", fontSize: 13, color: text === "#fff" ? "rgba(255,255,255,0.6)" : brand.warmGray }}>A sample card component with standard padding and border radius.</div>
              </div>
            ))}
          </div>
        </Section>

        {/* Toasts */}
        <Section title="Notification Toast States">
          <div style={{ display: "flex", gap: 12, flexDirection: "column" as const, maxWidth: 400 }}>
            {[["Success", "#2D9B68", "rgba(45,155,104,0.08)", "✓ Certificate issued successfully"], ["Error", brand.red, "rgba(255,45,50,0.07)", "✗ Payment failed — please try again"], ["Warning", brand.amber, "rgba(255,170,24,0.08)", "⚠ Session expires in 5 minutes"], ["Info", "#496FA8", "rgba(73,111,168,0.08)", "ℹ New courses added in Endodontics"]].map(([label, color, bg, msg]) => (
              <div key={label as string} style={{ background: bg as string, border: `1px solid ${color as string}30`, borderRadius: 12, padding: "12px 16px", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal }}>{msg as string}</div>
                <button style={{ background: "none", border: "none", cursor: "pointer", color: brand.warmGray }}><X size={14} /></button>
              </div>
            ))}
          </div>
        </Section>

        {/* Skeleton */}
        <Section title="Skeleton Loaders">
          <div style={{ display: "flex", gap: 16, flexWrap: "wrap" }}>
            <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "16px", width: 260 }}>
              <div style={{ height: 120, background: `linear-gradient(90deg, ${brand.borderGray} 25%, ${brand.paleGray} 50%, ${brand.borderGray} 75%)`, borderRadius: 10, marginBottom: 12, animation: "pulse 1.5s infinite" }} />
              <div style={{ height: 14, background: brand.borderGray, borderRadius: 6, marginBottom: 8, width: "80%" }} />
              <div style={{ height: 12, background: brand.borderGray, borderRadius: 6, width: "60%" }} />
            </div>
          </div>
        </Section>
      </div>
    </div>
  );
}
