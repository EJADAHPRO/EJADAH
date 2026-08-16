import { brand, gradientFlow, GradientBadge, LiveBadge } from "@/figma/app/shared";
import { Star, Clock, Users, CheckCircle } from "lucide-react";

const rtlStyle: React.CSSProperties = { direction: "rtl", fontFamily: "IBM Plex Sans Arabic, Tajawal, Arial, sans-serif" };

export default function RTLDemo() {
  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* RTL Header */}
      <div style={{ background: brand.charcoal, padding: "40px 24px 32px", direction: "rtl" }}>
        <div style={{ maxWidth: 1100, margin: "0 auto" }}>
          <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: brand.amber, letterSpacing: "0.08em", marginBottom: 10 }}>عربي RTL</div>
          <h1 style={{ fontFamily: "IBM Plex Sans Arabic, serif", fontWeight: 700, fontSize: "clamp(26px,4vw,40px)", color: "#fff", marginBottom: 8 }}>
            أمثلة العرض العربي من اليمين إلى اليسار
          </h1>
          <p style={{ fontFamily: "IBM Plex Sans Arabic, sans-serif", fontSize: 15, color: "rgba(255,255,255,0.6)", maxWidth: 540 }}>
            أكاديمية إجادة الدولية — التعليم الدولي لطب الأسنان، التطوير السريري، والفرص المهنية في منصة واحدة متكاملة.
          </p>
        </div>
      </div>

      <div style={{ maxWidth: 1100, margin: "0 auto", padding: "32px 24px" }}>
        {/* RTL Navigation example */}
        <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "16px 24px", marginBottom: 24, ...rtlStyle }}>
          <div style={{ display: "flex", gap: 24, alignItems: "center" }}>
            <div style={{ fontFamily: "Inter", fontWeight: 800, fontSize: 14, color: brand.charcoal, letterSpacing: "0.06em" }}>إجادة</div>
            {["تعلم", "الامتحانات", "الأكاديمية المباشرة", "المجتمع", "المسيرة المهنية"].map((item) => (
              <span key={item} style={{ fontFamily: "IBM Plex Sans Arabic, sans-serif", fontSize: 13, color: brand.charcoal, cursor: "pointer" }}>{item}</span>
            ))}
            <div style={{ marginRight: "auto" }}>
              <button style={{ fontFamily: "IBM Plex Sans Arabic, sans-serif", fontWeight: 700, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "7px 16px", cursor: "pointer" }}>انضم لإجادة</button>
            </div>
          </div>
        </div>

        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 20, marginBottom: 24 }}>
          {/* RTL Course Card */}
          <div style={{ background: brand.white, borderRadius: 22, border: `1px solid ${brand.borderGray}`, overflow: "hidden", ...rtlStyle }}>
            <div style={{ height: 150, background: `linear-gradient(135deg, ${brand.charcoal}, #24201D)`, display: "flex", alignItems: "center", justifyContent: "center" }}>
              <div style={{ fontFamily: "IBM Plex Sans Arabic, sans-serif", fontSize: 14, color: "rgba(255,255,255,0.5)" }}>صورة الدورة</div>
            </div>
            <div style={{ padding: "16px 18px" }}>
              <GradientBadge small>طب الأعصاب</GradientBadge>
              <div style={{ fontFamily: "IBM Plex Sans Arabic, sans-serif", fontWeight: 700, fontSize: 15, color: brand.charcoal, margin: "10px 0 5px", lineHeight: 1.4 }}>
                علاج قناة الجذر الشامل: من الأساسيات إلى المتقدم
              </div>
              <div style={{ fontFamily: "IBM Plex Sans Arabic, sans-serif", fontSize: 12, color: brand.warmGray, marginBottom: 10 }}>
                د. أميرة سليمان · دكتوراه من جامعة القاهرة
              </div>
              <div style={{ display: "flex", gap: 12, marginBottom: 12 }}>
                <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, display: "flex", alignItems: "center", gap: 4 }}><Clock size={11} /> 22 ساعة</span>
                <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, display: "flex", alignItems: "center", gap: 4 }}><Users size={11} /> 3,420 طالب</span>
              </div>
              <div style={{ display: "flex", gap: 2 }}>{[1,2,3,4,5].map((i) => <Star key={i} size={12} fill={brand.amber} color={brand.amber} />)}</div>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginTop: 12, paddingTop: 12, borderTop: `1px solid ${brand.borderGray}` }}>
                <span style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 16, color: brand.charcoal }}>1,200 جنيه</span>
                <button style={{ fontFamily: "IBM Plex Sans Arabic, sans-serif", fontWeight: 700, fontSize: 12, color: "#fff", background: gradientFlow, border: "none", borderRadius: 8, padding: "8px 14px", cursor: "pointer" }}>سجّل الآن</button>
              </div>
            </div>
          </div>

          {/* RTL Live Session Card */}
          <div style={{ background: brand.deepCharcoal, borderRadius: 22, border: `1px solid rgba(255,45,50,0.3)`, padding: "22px", ...rtlStyle }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 16 }}>
              <LiveBadge />
              <span style={{ fontFamily: "IBM Plex Sans Arabic, sans-serif", fontSize: 12, color: "rgba(255,255,255,0.5)", display: "flex", alignItems: "center", gap: 4 }}><Users size={12} /> 342 يشاهدون</span>
            </div>
            <GradientBadge small>جراحة الفم</GradientBadge>
            <div style={{ fontFamily: "IBM Plex Sans Arabic, sans-serif", fontWeight: 700, fontSize: 17, color: "#fff", margin: "10px 0 6px", lineHeight: 1.4 }}>
              قلع الأسنان الجراحي: الضروس المضمورة
            </div>
            <div style={{ fontFamily: "IBM Plex Sans Arabic, sans-serif", fontSize: 12, color: "rgba(255,255,255,0.55)", marginBottom: 16 }}>
              د. هاني إبراهيم · جامعة الإسكندرية
            </div>
            <button style={{ width: "100%", fontFamily: "IBM Plex Sans Arabic, sans-serif", fontWeight: 700, fontSize: 14, color: "#fff", background: brand.red, border: "none", borderRadius: 12, padding: "13px", cursor: "pointer" }}>
              انضم للجلسة المباشرة
            </button>
          </div>
        </div>

        {/* RTL Exam Card */}
        <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px", marginBottom: 20, ...rtlStyle }}>
          <div style={{ display: "flex", gap: 16, alignItems: "flex-start" }}>
            <span style={{ fontSize: 40 }}>🇪🇬</span>
            <div style={{ flex: 1 }}>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 20, color: brand.gold, marginBottom: 3 }}>EDLE</div>
              <div style={{ fontFamily: "IBM Plex Sans Arabic, sans-serif", fontWeight: 700, fontSize: 16, color: brand.charcoal, marginBottom: 6 }}>امتحان ترخيص طب الأسنان المصري</div>
              <div style={{ fontFamily: "IBM Plex Sans Arabic, sans-serif", fontSize: 13, color: brand.warmGray, lineHeight: 1.6 }}>
                أكثر من 14,000 سؤال · 16 مادة · بنك أسئلة شامل مع شرح مفصل وتتبع الأداء
              </div>
              <div style={{ display: "flex", gap: 10, marginTop: 12 }}>
                <button style={{ fontFamily: "IBM Plex Sans Arabic, sans-serif", fontWeight: 700, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "10px 18px", cursor: "pointer" }}>ابدأ الاستعداد</button>
                <button style={{ fontFamily: "IBM Plex Sans Arabic, sans-serif", fontWeight: 500, fontSize: 13, color: brand.charcoal, background: brand.offWhite, border: `1px solid ${brand.borderGray}`, borderRadius: 10, padding: "10px 16px", cursor: "pointer" }}>اختبار مجاني</button>
              </div>
            </div>
          </div>
        </div>

        {/* RTL Community Post */}
        <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "22px", ...rtlStyle }}>
          <div style={{ display: "flex", gap: 12, alignItems: "flex-start", marginBottom: 12 }}>
            <div style={{ width: 42, height: 42, borderRadius: 12, background: gradientFlow, display: "flex", alignItems: "center", justifyContent: "center", fontFamily: "Inter", fontWeight: 700, fontSize: 16, color: "#fff", flexShrink: 0 }}>س</div>
            <div>
              <div style={{ fontFamily: "IBM Plex Sans Arabic, sans-serif", fontWeight: 700, fontSize: 14, color: brand.charcoal }}>د. سارة محمود</div>
              <div style={{ fontFamily: "IBM Plex Sans Arabic, sans-serif", fontSize: 11, color: brand.warmGray }}>طبيبة أسنان عامة · الإسكندرية</div>
            </div>
          </div>
          <div style={{ fontFamily: "IBM Plex Sans Arabic, sans-serif", fontWeight: 700, fontSize: 16, color: brand.charcoal, marginBottom: 8, lineHeight: 1.4 }}>
            ما هو البروتوكول المفضل للري في قنوات الجذر ذات الشكل C؟
          </div>
          <div style={{ fontFamily: "IBM Plex Sans Arabic, sans-serif", fontSize: 13, color: brand.warmGray, lineHeight: 1.7, marginBottom: 14 }}>
            أتعامل مع ضرس ثانٍ في الفك السفلي بتكوين C-shaped. أستخدم عادةً الري بالموجات فوق الصوتية السلبي لكنني أجد صعوبة في الحصول على تنظيف موثوق به في منطقة البرزخ. ما هو نهجكم المفضل؟
          </div>
          <div style={{ display: "flex", gap: 16 }}>
            <button style={{ fontFamily: "IBM Plex Sans Arabic, sans-serif", fontSize: 12, color: brand.warmGray, background: "none", border: "none", cursor: "pointer" }}>❤️ 67</button>
            <button style={{ fontFamily: "IBM Plex Sans Arabic, sans-serif", fontSize: 12, color: brand.warmGray, background: "none", border: "none", cursor: "pointer" }}>💬 31 إجابة</button>
            <button style={{ fontFamily: "IBM Plex Sans Arabic, sans-serif", fontSize: 12, color: brand.warmGray, background: "none", border: "none", cursor: "pointer" }}>🔗 مشاركة</button>
          </div>
        </div>

        <div style={{ marginTop: 24, background: `${brand.amber}08`, border: `1px solid ${brand.amber}25`, borderRadius: 14, padding: "14px 18px", direction: "ltr" }}>
          <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.amber, marginBottom: 4 }}>Note</div>
          <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal }}>Full Arabic RTL support requires adding <code style={{ background: brand.paleGray, borderRadius: 4, padding: "1px 5px" }}>IBM Plex Sans Arabic</code> and <code style={{ background: brand.paleGray, borderRadius: 4, padding: "1px 5px" }}>Tajawal</code> to <code>fonts.css</code>, and setting <code>dir="rtl"</code> on the HTML root when Arabic is selected.</div>
        </div>
      </div>
    </div>
  );
}
