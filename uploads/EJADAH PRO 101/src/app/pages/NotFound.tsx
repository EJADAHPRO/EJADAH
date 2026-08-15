import { useNavigate } from "react-router";
import { brand, gradientFlow, EjadahMark } from "@/app/shared";
import { ArrowRight } from "lucide-react";

export default function NotFound() {
  const nav = useNavigate();
  return (
    <div style={{ minHeight: "60vh", display: "flex", alignItems: "center", justifyContent: "center", padding: "60px 24px", textAlign: "center" as const }}>
      <div>
        <div style={{ display: "flex", justifyContent: "center", marginBottom: 24 }}><EjadahMark size={64} /></div>
        <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 72, color: brand.borderGray, lineHeight: 1, marginBottom: 16 }}>404</div>
        <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 26, color: brand.charcoal, marginBottom: 12 }}>Page Not Found</div>
        <p style={{ fontFamily: "Inter", fontSize: 15, color: brand.warmGray, marginBottom: 32, maxWidth: 380 }}>This page doesn't exist or has been moved. Let's get you back on track.</p>
        <button onClick={() => nav("/")} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 15, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "13px 28px", cursor: "pointer", display: "inline-flex", alignItems: "center", gap: 8 }}>
          Back to Home <ArrowRight size={16} />
        </button>
      </div>
    </div>
  );
}
