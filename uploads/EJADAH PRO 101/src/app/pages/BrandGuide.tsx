import { brand, gradientFlow, gradientGlow, EjadahMark, EjadahWordmark } from "@/app/shared";

function Swatch({ color, name, hex }: { color: string; name: string; hex: string }) {
  return (
    <div style={{ display: "flex", flexDirection: "column" as const, gap: 6 }}>
      <div style={{ height: 64, borderRadius: 14, background: color, border: color === "#fff" || color === brand.offWhite ? `1px solid ${brand.borderGray}` : "none" }} />
      <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal }}>{name}</div>
      <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{hex}</div>
    </div>
  );
}

export default function BrandGuide() {
  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      <div style={{ background: brand.charcoal, padding: "56px 24px 48px" }}>
        <div style={{ maxWidth: 1100, margin: "0 auto" }}>
          <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: brand.amber, letterSpacing: "0.1em", textTransform: "uppercase" as const, marginBottom: 10 }}>Internal Reference</div>
          <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 40, color: "#fff", marginBottom: 10 }}>Brand Style Guide</h1>
          <p style={{ fontFamily: "Inter", fontSize: 16, color: "rgba(255,255,255,0.6)", maxWidth: 480 }}>Ejadah International Academy · Visual identity system and design language</p>
        </div>
      </div>

      <div style={{ maxWidth: 1100, margin: "0 auto", padding: "40px 24px" }}>
        {/* Logo */}
        <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "32px", marginBottom: 28 }}>
          <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.charcoal, marginBottom: 20 }}>Logo</div>
          <div style={{ display: "flex", gap: 32, flexWrap: "wrap", alignItems: "center" }}>
            <div style={{ textAlign: "center" as const }}>
              <div style={{ background: brand.offWhite, borderRadius: 14, padding: "24px", marginBottom: 8 }}><EjadahMark size={64} /></div>
              <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>Icon Mark</div>
            </div>
            <div style={{ textAlign: "center" as const }}>
              <div style={{ background: brand.offWhite, borderRadius: 14, padding: "24px", marginBottom: 8 }}><EjadahWordmark /></div>
              <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>Full Wordmark (Light BG)</div>
            </div>
            <div style={{ textAlign: "center" as const }}>
              <div style={{ background: brand.charcoal, borderRadius: 14, padding: "24px", marginBottom: 8 }}><EjadahWordmark light /></div>
              <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>Full Wordmark (Dark BG)</div>
            </div>
          </div>
        </div>

        {/* Colors */}
        <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "32px", marginBottom: 28 }}>
          <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.charcoal, marginBottom: 6 }}>Colour System</div>
          <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, marginBottom: 20 }}>The Ejadah Flow gradient — #FF2D32 → #FF6B1A → #FFC62E — is the primary brand signature.</p>
          <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.08em", marginBottom: 12 }}>Primary Brand</div>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(120px, 1fr))", gap: 16, marginBottom: 24 }}>
            <Swatch color={brand.red} name="Ejadah Red" hex="#FF2D32" />
            <Swatch color={brand.orange} name="Sunset Orange" hex="#FF6B1A" />
            <Swatch color={brand.amber} name="Ejadah Amber" hex="#FFAA18" />
            <Swatch color={brand.gold} name="Golden Yellow" hex="#FFC62E" />
          </div>
          <div style={{ height: 40, borderRadius: 10, background: gradientFlow, marginBottom: 8 }} />
          <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginBottom: 24 }}>Ejadah Flow — Primary Brand Gradient</div>
          <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.08em", marginBottom: 12 }}>Neutrals</div>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(120px, 1fr))", gap: 16 }}>
            <Swatch color={brand.offWhite} name="Warm Off-White" hex="#FFF9EF" />
            <Swatch color="#fff" name="Pure White" hex="#FFFFFF" />
            <Swatch color={brand.paleGray} name="Pale Gray" hex="#F5F2EC" />
            <Swatch color={brand.borderGray} name="Border Gray" hex="#E7E2DA" />
            <Swatch color={brand.warmGray} name="Warm Gray" hex="#716D67" />
            <Swatch color={brand.charcoal} name="Charcoal" hex="#1B1B1B" />
            <Swatch color={brand.deepCharcoal} name="Deep Charcoal" hex="#121212" />
          </div>
        </div>

        {/* Typography */}
        <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "32px", marginBottom: 28 }}>
          <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.charcoal, marginBottom: 20 }}>Typography</div>
          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 32 }}>
            <div>
              <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: brand.orange, letterSpacing: "0.08em", textTransform: "uppercase" as const, marginBottom: 12 }}>Display — Playfair Display</div>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 40, color: brand.charcoal, lineHeight: 1.1, marginBottom: 8 }}>Bridging the Gap</div>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 28, color: brand.charcoal, marginBottom: 8 }}>Section Heading</div>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 400, fontSize: 20, color: brand.charcoal }}>Article Title Style</div>
            </div>
            <div>
              <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: brand.orange, letterSpacing: "0.08em", textTransform: "uppercase" as const, marginBottom: 12 }}>Interface — Inter</div>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 18, color: brand.charcoal, marginBottom: 6 }}>Navigation Label</div>
              <div style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 15, color: brand.charcoal, marginBottom: 6 }}>Body Text — Regular weight</div>
              <div style={{ fontFamily: "Inter", fontWeight: 400, fontSize: 13, color: brand.warmGray, marginBottom: 6 }}>Secondary / Metadata text</div>
              <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: brand.orange, letterSpacing: "0.08em", textTransform: "uppercase" as const }}>LABEL / TAG TEXT</div>
            </div>
          </div>
        </div>

        {/* Shape language */}
        <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "32px", marginBottom: 28 }}>
          <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.charcoal, marginBottom: 6 }}>Shape Language — The Ejadah Learning Path</div>
          <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, marginBottom: 20 }}>Rounded paths, soft turns, and connected modular shapes — inspired by the logo geometry.</p>
          <div style={{ display: "flex", gap: 16, flexWrap: "wrap" }}>
            {[{ r: 10, label: "10px — Controls" }, { r: 14, label: "14px — Inputs" }, { r: 20, label: "20px — Cards" }, { r: 28, label: "28px — Feature Cards" }].map((s) => (
              <div key={s.r} style={{ textAlign: "center" as const }}>
                <div style={{ width: 80, height: 80, borderRadius: s.r, background: `${brand.orange}12`, border: `2px solid ${brand.orange}`, marginBottom: 6 }} />
                <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{s.label}</div>
              </div>
            ))}
          </div>
        </div>

        {/* Gradients */}
        <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "32px" }}>
          <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.charcoal, marginBottom: 20 }}>Signature Gradients</div>
          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 16 }}>
            {[["Ejadah Flow", gradientFlow, "Primary — CTAs, badges, progress"], ["Ejadah Glow", gradientGlow, "Secondary — rewards, achievements"]].map(([name, gradient, use]) => (
              <div key={name as string}>
                <div style={{ height: 56, borderRadius: 14, background: gradient as string, marginBottom: 8 }} />
                <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal }}>{name as string}</div>
                <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginTop: 3 }}>{use as string}</div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
