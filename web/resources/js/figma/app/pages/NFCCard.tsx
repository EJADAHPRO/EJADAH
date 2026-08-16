import { useNavigate } from "react-router";
import { QrCode, Download, Share2, Smartphone, ArrowRight } from "lucide-react";
import { brand, gradientFlow, EjadahMark } from "@/figma/app/shared";

export default function NFCCard() {
  const nav = useNavigate();

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      <div style={{ maxWidth: 900, margin: "0 auto", padding: "40px 24px" }}>
        <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 28, color: brand.charcoal, marginBottom: 6 }}>Your NFC Card</h1>
        <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, marginBottom: 36 }}>Your digital professional card — share by tapping, scanning, or link.</p>

        <div style={{ display: "flex", gap: 36, flexWrap: "wrap", alignItems: "flex-start" }}>
          {/* Card preview */}
          <div style={{ flex: "0 0 360px" }}>
            {/* Front */}
            <div style={{ marginBottom: 12, fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: brand.warmGray, letterSpacing: "0.08em", textTransform: "uppercase" as const }}>Front</div>
            <div style={{ width: 360, height: 210, borderRadius: 24, background: `linear-gradient(135deg, ${brand.deepCharcoal} 0%, #24201D 100%)`, position: "relative", overflow: "hidden", boxShadow: "0 20px 60px rgba(0,0,0,0.3)", marginBottom: 20 }}>
              {/* Gradient arc decoration */}
              <div style={{ position: "absolute", top: -60, right: -60, width: 220, height: 220, borderRadius: "50%", background: `radial-gradient(circle, rgba(255,107,26,0.25) 0%, transparent 65%)`, pointerEvents: "none" }} />
              <div style={{ position: "absolute", bottom: -40, left: -40, width: 150, height: 150, borderRadius: "50%", background: `radial-gradient(circle, rgba(255,198,46,0.15) 0%, transparent 65%)`, pointerEvents: "none" }} />
              {/* Gradient top line */}
              <div style={{ position: "absolute", top: 0, left: 0, right: 0, height: 4, background: gradientFlow }} />
              {/* Content */}
              <div style={{ position: "absolute", inset: 0, padding: "22px 24px", display: "flex", flexDirection: "column" as const, justifyContent: "space-between" }}>
                <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
                  <EjadahMark size={32} />
                  <div>
                    <div style={{ fontFamily: "Inter", fontWeight: 800, fontSize: 10, color: "#fff", letterSpacing: "0.08em" }}>EJADAH</div>
                    <div style={{ fontFamily: "Inter", fontSize: 7, color: "rgba(255,255,255,0.5)", letterSpacing: "0.06em" }}>INTERNATIONAL ACADEMY</div>
                  </div>
                  <div style={{ marginLeft: "auto" }}>
                    <Smartphone size={16} color="rgba(255,255,255,0.3)" />
                  </div>
                </div>
                <div>
                  <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: "#fff", marginBottom: 3 }}>Dr. Yousef Al-Rashidi</div>
                  <div style={{ fontFamily: "Inter", fontSize: 11, color: "rgba(255,255,255,0.6)", marginBottom: 10 }}>General Dentist · Cairo, Egypt</div>
                  <div style={{ display: "flex", gap: 16 }}>
                    <div style={{ fontFamily: "Inter", fontSize: 10, color: "rgba(255,255,255,0.45)" }}>ejadah.com/profile/1</div>
                    <div style={{ fontFamily: "Inter", fontSize: 10, color: brand.amber }}>🎓 Ejadah Alumni</div>
                  </div>
                </div>
              </div>
            </div>

            {/* Back */}
            <div style={{ marginBottom: 12, fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: brand.warmGray, letterSpacing: "0.08em", textTransform: "uppercase" as const }}>Back</div>
            <div style={{ width: 360, height: 210, borderRadius: 24, background: brand.offWhite, border: `1px solid ${brand.borderGray}`, position: "relative", overflow: "hidden", boxShadow: "0 8px 24px rgba(0,0,0,0.08)" }}>
              <div style={{ position: "absolute", top: 0, left: 0, right: 0, height: 4, background: gradientFlow }} />
              <div style={{ position: "absolute", inset: 0, padding: "24px", display: "flex", flexDirection: "column" as const, justifyContent: "space-between" }}>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
                  <div>
                    <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal }}>dr.yousef@example.com</div>
                    <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginTop: 4 }}>+20 100 000 0000</div>
                    <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginTop: 4 }}>linkedin.com/in/yousef</div>
                  </div>
                  {/* QR code placeholder */}
                  <div style={{ width: 72, height: 72, background: brand.charcoal, borderRadius: 10, display: "flex", alignItems: "center", justifyContent: "center" }}>
                    <QrCode size={42} color="#fff" />
                  </div>
                </div>
                <div style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray, display: "flex", alignItems: "center", gap: 4 }}>
                  <EjadahMark size={14} /> Powered by Ejadah International Academy
                </div>
              </div>
            </div>

            <div style={{ display: "flex", gap: 10, marginTop: 16 }}>
              <button style={{ flex: 1, fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "11px", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 5 }}><Download size={13} /> Download Card</button>
              <button style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 13, color: brand.charcoal, background: brand.white, border: `1.5px solid ${brand.borderGray}`, borderRadius: 10, padding: "11px 14px", cursor: "pointer" }}><Share2 size={14} /></button>
            </div>
          </div>

          {/* Options panel */}
          <div style={{ flex: 1, minWidth: 260 }}>
            <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px", marginBottom: 16 }}>
              <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 16 }}>Card Options</h2>
              {[
                { label: "Card Theme", options: ["Dark (Default)", "Light", "Gradient"], active: "Dark (Default)" },
                { label: "Show QR Code on back", options: ["Yes", "No"], active: "Yes" },
                { label: "NFC Link", options: ["Full Profile", "Contact Only", "LinkedIn Only"], active: "Full Profile" },
              ].map((opt) => (
                <div key={opt.label} style={{ marginBottom: 16 }}>
                  <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal, marginBottom: 8 }}>{opt.label}</div>
                  <div style={{ display: "flex", gap: 8 }}>
                    {opt.options.map((o) => (
                      <button key={o} style={{ fontFamily: "Inter", fontSize: 12, color: o === opt.active ? "#fff" : brand.charcoal, background: o === opt.active ? gradientFlow : brand.offWhite, border: `1.5px solid ${o === opt.active ? "transparent" : brand.borderGray}`, borderRadius: 8, padding: "6px 12px", cursor: "pointer" }}>{o}</button>
                    ))}
                  </div>
                </div>
              ))}
            </div>
            <div style={{ background: brand.charcoal, borderRadius: 20, padding: "22px" }}>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: "#fff", marginBottom: 8 }}>Order Physical NFC Card</div>
              <p style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.6)", lineHeight: 1.6, marginBottom: 16 }}>Premium black card with Ejadah branding and built-in NFC chip. Ships to Egypt and internationally.</p>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.gold, marginBottom: 14 }}>EGP 299</div>
              <button style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "12px", cursor: "pointer" }}>Order Now</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
