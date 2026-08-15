import { useState } from "react";
import { useNavigate } from "react-router";
import { Search, Filter, Bookmark, Star, Headphones, BookMarked, ClipboardList, Layers, ArrowRight, ChevronDown, ChevronUp } from "lucide-react";
import { brand, gradientFlow } from "@/app/shared";

const companions = [
  {
    id: "1",
    department: "Endodontics",
    title: "Endodontics Study Companion",
    emoji: "🦷",
    color: brand.orange,
    summaryModules: 180,
    audioDuration: "62h",
    flashcardCount: 4200,
    quizCount: 80,
    studyEstimate: "Self-paced",
    lastUpdated: "July 2026",
    tags: ["Root Canal", "Pulp Biology", "Regeneration", "EDLE"],
    rating: 4.9,
    reviews: 1240,
    price: "EGP 499/month",
    access: "subscribed",
    books: [
      "Cohen's Pathways of the Pulp — 12th Ed.",
      "Ingle's Endodontics — 7th Ed.",
      "Torabinejad's Endodontics — 5th Ed.",
      "Endodontic Diagnosis, Pathology & Treatment Planning — Rosenthal",
      "Hargreaves' Seltzer & Bender's Dental Pulp — 2nd Ed.",
      "Clinical Endodontics — Tronstad, 3rd Ed.",
      "Grossman's Endodontic Practice — 13th Ed.",
      "Problem Solving in Endodontics — Gutmann & Lovdahl, 5th Ed.",
      "Color Atlas of Endodontics — Baumann & Beer",
      "Endodontic Radiology — Farman, 2nd Ed.",
      "Regenerative Endodontics — Fouad",
      "Management of Endodontic Emergencies — Hasselgren",
      "Root Canal Morphology — Vertucci et al.",
      "Surgical Endodontics — Rubinstein",
      "Endodontic Retreatment Handbook — Friedman",
      "Vital Pulp Therapy — Bogen & Chandler",
      "Endodontics: Colleagues for Excellence — AAE",
      "The Dental Pulp: Biology, Pathology & Regenerative Therapies — Goldberg",
      "Lasers in Endodontics — de Almeida et al.",
      "Contemporary Endodontics for Children — Fuks & Peretz",
    ],
  },
  {
    id: "2",
    department: "Periodontics",
    title: "Periodontics Study Companion",
    emoji: "🩺",
    color: "#2D9B68",
    summaryModules: 160,
    audioDuration: "55h",
    flashcardCount: 3800,
    quizCount: 72,
    studyEstimate: "Self-paced",
    lastUpdated: "July 2026",
    tags: ["Classification 2017", "Surgical Perio", "Implants", "EDLE"],
    rating: 4.8,
    reviews: 890,
    price: "EGP 499/month",
    access: "locked",
    books: [
      "Clinical Periodontology & Implant Dentistry — Lindhe, 6th Ed.",
      "Carranza's Clinical Periodontology — Newman, 13th Ed.",
      "Periodontics: Medicine, Surgery & Implants — Rose & Mealey",
      "Fundamentals of Periodontal Instrumentation — Nield-Gehrig, 8th Ed.",
      "Clinical Practice of the Dental Hygienist — Wilkins, 12th Ed.",
      "Rationale of Periodontal Treatment — Ramfjord & Ash",
      "Periodontal Therapy — Schluger et al.",
      "Implant Dentistry — Misch, 3rd Ed.",
      "Contemporary Implant Dentistry — Misch",
      "Peri-Implant Therapy for the Dental Hygienist — Wingrove",
      "Color Atlas of Dental Medicine: Periodontology — Wolf & Rateitschak",
      "Surgical Manual of Implant Dentistry — Buser et al.",
      "The Periodontium — Bartold & Narayanan",
      "Esthetic Soft Tissue Management — Zucchelli",
      "Oral Biofilms and Plaque Control — Newman & Wilson",
      "Furcation: Involvement & Treatment — Cattabriga et al.",
      "Bone Augmentation in Oral Implantology — Buser",
      "Mucogingival Esthetic Surgery — Cairo",
      "Supportive Periodontal Therapy — Lang & Bartold",
      "Periodontal Medicine — Rose, Genco & Mealey",
    ],
  },
  {
    id: "3",
    department: "Orthodontics",
    title: "Orthodontics Study Companion",
    emoji: "🔬",
    color: "#496FA8",
    summaryModules: 144,
    audioDuration: "48h",
    flashcardCount: 3400,
    quizCount: 60,
    studyEstimate: "Self-paced",
    lastUpdated: "June 2026",
    tags: ["Cephalometrics", "Mechanics", "Aligners", "EDLE"],
    rating: 4.8,
    reviews: 1100,
    price: "Free Preview",
    access: "free-preview",
    books: [
      "Contemporary Orthodontics — Proffit, 6th Ed.",
      "Orthodontics: Current Principles & Techniques — Graber, 6th Ed.",
      "Biomechanics & Esthetic Strategies in Clinical Orthodontics — Nanda",
      "Clinical Management of Skeletal Discrepancies — Pancherz",
      "A Textbook of Orthodontics — Houston & Tulley",
      "Orthodontic Cephalometry — Athanasiou",
      "Essentials of Orthodontics — Bishara",
      "Orthodontic Retreatment — Joondeph",
      "Invisible Orthodontics — Echarri",
      "The Invisalign System — Tuncay",
      "Temporary Anchorage Devices in Orthodontics — Papadopoulos",
      "Interdisciplinary Treatment Planning Vol. I — Cohen",
      "Surgical-Orthodontic Treatment — Proffit, White & Sarver",
      "Orthodontic Radiographs — Hellman",
      "Early Orthodontic Treatment — Tollaro & Baccetti",
      "Bone-borne Orthodontic Appliances — Cornelis",
      "Orthodontic Materials — O'Brien",
      "Lingual Orthodontics — Harradine",
      "MEAW Technique — Kim",
      "Functional Appliances — Graber et al.",
    ],
  },
  {
    id: "4",
    department: "Oral Pathology",
    title: "Oral Pathology Study Companion",
    emoji: "🧫",
    color: "#8B5CF6",
    summaryModules: 192,
    audioDuration: "66h",
    flashcardCount: 4800,
    quizCount: 90,
    studyEstimate: "Self-paced",
    lastUpdated: "July 2026",
    tags: ["Lesions", "Tumors", "Cysts", "EDLE Pathology"],
    rating: 4.9,
    reviews: 1560,
    price: "EGP 499/month",
    access: "locked",
    books: [
      "Oral & Maxillofacial Pathology — Neville, 4th Ed.",
      "Shafer's Textbook of Oral Pathology — Sivapathasundharam, 8th Ed.",
      "Color Atlas of Oral Diseases — Laskaris, 4th Ed.",
      "Cawson's Essentials of Oral Pathology & Medicine — Odell, 9th Ed.",
      "Oral Pathology: Clinical-Pathologic Correlations — Regezi, 7th Ed.",
      "Surgical Pathology of the Mouth & Jaws — Jones & Franklin",
      "Oral Cancer — Shah",
      "Salivary Gland Diseases — Speight & Barrett",
      "Temporomandibular Disorders — Katzberg",
      "Bone Diseases of the Jaws — Marx & Stern",
      "Odontogenic Cysts & Tumors — Barnes et al.",
      "Ulcerative Conditions — Scully",
      "Oral Manifestations of Systemic Diseases — Greenberg",
      "Dermatology for the Oral Physician — Scully & Porter",
      "Head & Neck Pathology — Gnepp",
      "Atlas of Oral Lesions — Lozada-Nur",
      "Forensic Odontology — Senn & Stimson",
      "Pigmented Lesions of the Oral Mucosa — Buchner",
      "Viral Infections of the Oral Cavity — Scully",
      "Granulomatous Diseases of the Oral Cavity — Van der Waal",
    ],
  },
  {
    id: "5",
    department: "Oral Pharmacology",
    title: "Oral Pharmacology Study Companion",
    emoji: "💊",
    color: "#FF2D32",
    summaryModules: 120,
    audioDuration: "40h",
    flashcardCount: 2800,
    quizCount: 54,
    studyEstimate: "Self-paced",
    lastUpdated: "June 2026",
    tags: ["Local Anesthesia", "Analgesics", "Drug Interactions", "EDLE"],
    rating: 4.8,
    reviews: 980,
    price: "EGP 499/month",
    access: "locked",
    books: [
      "Handbook of Local Anesthesia — Malamed, 7th Ed.",
      "Pharmacology & Therapeutics for Dentistry — Dowd, 7th Ed.",
      "Medical Emergencies in the Dental Office — Malamed, 7th Ed.",
      "Drug Prescribing for Dentistry — Scottish Dental Clinical Effectiveness",
      "Mosby's Dental Drug Reference — Jeske, 12th Ed.",
      "Conscious Sedation for Dentistry — Hallonsten et al.",
      "Nitrous Oxide in Dentistry — Clark & Brunick",
      "Pharmacology in Dental Hygiene — Pickett",
      "Analgesics in Dentistry — Moore",
      "Antibiotic Prescribing in Dentistry — BNF / SDCEP",
      "Dental Pharmacology — Squier & Hall",
      "Adverse Drug Reactions in Dentistry — Scully & Cawson",
      "Sedation in Dentistry — Craig & Skelly",
      "Orofacial Pain: Guidelines — ADA",
      "Herbal Medicine in Dentistry — Burt",
      "Fluoride in Dentistry — Fejerskov, 3rd Ed.",
      "Antifungal Therapy in Dentistry — Cannon",
      "Antiviral Therapy in Dentistry — Slots",
      "Bisphosphonates & Osteonecrosis of the Jaw — Marx",
      "Drug-Induced Oral Disorders — Scully",
    ],
  },
  {
    id: "6",
    department: "Oral Medicine",
    title: "Oral Medicine Study Companion",
    emoji: "🩹",
    color: brand.amber,
    summaryModules: 128,
    audioDuration: "44h",
    flashcardCount: 3100,
    quizCount: 58,
    studyEstimate: "Self-paced",
    lastUpdated: "May 2026",
    tags: ["Systemic Disease", "Ulcers", "Diagnosis", "Salivary Glands"],
    rating: 4.7,
    reviews: 620,
    price: "Free Preview",
    access: "free-preview",
    books: [
      "Textbook of Oral Medicine — Greenberg, 3rd Ed.",
      "Burket's Oral Medicine — Glick, 12th Ed.",
      "Scully's Oral & Maxillofacial Medicine — Scully, 3rd Ed.",
      "Oral Medicine & Pathology at a Glance — Dios & Lodi",
      "Clinician's Guide to Oral Health in Geriatric Patients — Yellowitz",
      "Orofacial Pain — Sessle et al.",
      "Temporomandibular Disorders — de Leeuw & Klasser",
      "Dry Mouth — Edgar, Dawes & O'Mullane",
      "Salivary Gland Diseases — Speight",
      "Oral Mucosal Diseases — Lodi & Sardella",
      "HIV & the Mouth — Greenspan",
      "Sjögren's Syndrome — Fox",
      "Burning Mouth Syndrome — Patton",
      "Oral Dysesthesia — Grushka",
      "Medically Compromised Patient in Dental Practice — Little, 9th Ed.",
      "Haematological Disorders & the Mouth — Scully",
      "Endocrine Disorders & Oral Health — Ship",
      "Gastrointestinal Diseases & the Mouth — Scully",
      "Neurological Disorders & Orofacial Pain — Zakrzewska",
      "Immunological Diseases & the Oral Mucosa — Porter",
    ],
  },
  {
    id: "7",
    department: "Conservative Dentistry",
    title: "Conservative Dentistry Study Companion",
    emoji: "🪥",
    color: "#2D9B68",
    summaryModules: 160,
    audioDuration: "54h",
    flashcardCount: 3700,
    quizCount: 68,
    studyEstimate: "Self-paced",
    lastUpdated: "July 2026",
    tags: ["Composites", "Caries Management", "Cavity Prep", "EDLE"],
    rating: 4.8,
    reviews: 875,
    price: "EGP 499/month",
    access: "locked",
    books: [
      "Sturdevant's Art & Science of Operative Dentistry — Ritter, 7th Ed.",
      "Pickard's Manual of Operative Dentistry — Kidd, 9th Ed.",
      "Operative Dentistry — Mondelli, 5th Ed.",
      "Caries Management by Risk Assessment — Featherstone",
      "Cariology — Fejerskov & Kidd, 3rd Ed.",
      "Minimally Invasive Dentistry — Frencken et al.",
      "Dental Materials: Properties & Manipulation — Craig, 10th Ed.",
      "Restorative Dental Materials — O'Brien, 12th Ed.",
      "Esthetic Dentistry in Clinical Practice — Goldstein",
      "Fundamentals of Operative Dentistry — Summitt, 3rd Ed.",
      "Adhesive Dentistry — Ritter",
      "Direct Composite Restorations — Baratieri",
      "Tooth-Colored Restoratives — Alexander",
      "Pulp Biology & Pathology — Tronstad",
      "ART: Atraumatic Restorative Treatment — Frencken",
      "Glass Ionomer Cements — McLean & Wilson",
      "Ceramic Inlays — Mörmann",
      "Silver Diamine Fluoride — Horst",
      "Cavity Disinfection — Hauman & Love",
      "Dentin Hypersensitivity — Addy, Embery & Edgar",
    ],
  },
  {
    id: "8",
    department: "Oral Surgery",
    title: "Oral Surgery Study Companion",
    emoji: "⚕️",
    color: "#496FA8",
    summaryModules: 136,
    audioDuration: "46h",
    flashcardCount: 3200,
    quizCount: 60,
    studyEstimate: "Self-paced",
    lastUpdated: "June 2026",
    tags: ["Extractions", "Impacted Teeth", "Flaps", "Complications"],
    rating: 4.7,
    reviews: 440,
    price: "EGP 499/month",
    access: "locked",
    books: [
      "Principles of Oral & Maxillofacial Surgery — Hupp, 3rd Ed.",
      "Peterson's Principles of Oral & Maxillofacial Surgery — Miloro, 3rd Ed.",
      "Oral & Maxillofacial Surgery — Fonseca, 3rd Ed.",
      "Minor Oral Surgery — Fragiskos",
      "Essentials of Oral & Maxillofacial Surgery — Pedlar & Frame",
      "Handbook of Local Anesthesia — Malamed, 7th Ed.",
      "Maxillofacial Trauma — Kruger",
      "Management of Impacted Third Molars — Pogrel",
      "Dentoalveolar Surgery — Koerner",
      "Flap Design in Oral Surgery — Mörmann",
      "Complications in Oral Surgery — Peñarrocha",
      "Pre-Prosthetic & Implant Surgery — Lew",
      "Oral Surgery for the General Dentist — Nwoku",
      "Surgical Guide for Dental Implant Placement — Buser",
      "Jaw Cysts — Browne",
      "Bisphosphonate-Related Osteonecrosis — Marx",
      "Facial Pain — Grushka & Sessle",
      "Dry Socket & Healing — Alexander",
      "Bleeding Disorders & Oral Surgery — Scully",
      "Antibiotic Prophylaxis in Oral Surgery — Scottish Guidelines",
    ],
  },
];

const departments = [
  "All Departments",
  "Oral Biology & Histology", "Pharmacology", "Dental Biomaterials", "Operative Dentistry",
  "Endodontics", "Fixed Prosthodontics", "Removable Prosthodontics", "Periodontology & Oral Medicine",
  "Oral Radiology", "Oral Pathology", "Oral & Maxillofacial Surgery", "Orthodontics",
  "Pediatric Dentistry", "Implant Dentistry", "Aesthetic Dentistry", "Digital Dentistry",
];

const accessConfig: Record<string, { label: string; color: string; bg: string }> = {
  subscribed: { label: "✓ Active", color: "#2D9B68", bg: "#2D9B6814" },
  "free-preview": { label: "Free Preview", color: brand.amber, bg: `${brand.amber}14` },
  locked: { label: "Subscribe to Unlock", color: brand.orange, bg: `${brand.orange}10` },
};

function CompanionCard({ c, nav, saved, setSaved }: { c: typeof companions[0]; nav: (p: string) => void; saved: string[]; setSaved: React.Dispatch<React.SetStateAction<string[]>> }) {
  const [showBooks, setShowBooks] = useState(false);
  const access = accessConfig[c.access];
  const isSaved = saved.includes(c.id);

  return (
    <div style={{ background: brand.white, borderRadius: 22, border: `1px solid ${brand.borderGray}`, overflow: "hidden", transition: "box-shadow 0.2s" }}
      onMouseEnter={(e) => (e.currentTarget as HTMLElement).style.boxShadow = "0 8px 28px rgba(0,0,0,0.08)"}
      onMouseLeave={(e) => (e.currentTarget as HTMLElement).style.boxShadow = "none"}
    >
      {/* Top strip — clickable to detail */}
      <div onClick={() => nav(`/library/${c.id}`)} style={{ background: `linear-gradient(135deg, ${brand.charcoal}, #1e1a16)`, padding: "20px 18px 16px", position: "relative", cursor: "pointer" }}>
        <div style={{ position: "absolute", top: 12, left: 12 }}>
          <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 10, color: access.color, background: access.bg, border: `1px solid ${access.color}30`, borderRadius: 6, padding: "3px 8px" }}>{access.label}</span>
        </div>
        <button onClick={(e) => { e.stopPropagation(); setSaved((p) => isSaved ? p.filter((x) => x !== c.id) : [...p, c.id]); }}
          style={{ position: "absolute", top: 10, right: 12, background: "rgba(255,255,255,0.08)", border: "none", borderRadius: 8, width: 30, height: 30, display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer", color: isSaved ? brand.amber : "rgba(255,255,255,0.4)" }}>
          <Bookmark size={14} fill={isSaved ? brand.amber : "none"} />
        </button>
        <div style={{ fontSize: 30, marginBottom: 8, marginTop: 14 }}>{c.emoji}</div>
        <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 10, color: c.color, textTransform: "uppercase" as const, letterSpacing: "0.07em", marginBottom: 3 }}>{c.department}</div>
        <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 15, color: "#fff", lineHeight: 1.25, marginBottom: 10 }}>{c.title}</div>

        {/* Book count badge */}
        <div style={{ display: "inline-flex", gap: 6, alignItems: "center", background: "rgba(255,255,255,0.07)", borderRadius: 8, padding: "5px 10px", border: "1px solid rgba(255,255,255,0.08)" }}>
          <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: "rgba(255,255,255,0.7)" }}>📚 {c.books.length} textbooks summarized</span>
        </div>
      </div>

      <div style={{ padding: "14px 18px" }}>
        {/* Stats */}
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 6, marginBottom: 12 }}>
          {[
            { icon: <Layers size={11} />, label: `${c.summaryModules} summary modules` },
            { icon: <Headphones size={11} />, label: `${c.audioDuration} voice` },
            { icon: <BookMarked size={11} />, label: `${c.flashcardCount.toLocaleString()} flashcards` },
            { icon: <ClipboardList size={11} />, label: `${c.quizCount} quizzes` },
          ].map((stat) => (
            <div key={stat.label} style={{ display: "flex", gap: 5, alignItems: "center", fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>
              <span style={{ color: c.color }}>{stat.icon}</span>{stat.label}
            </div>
          ))}
        </div>

        {/* Books expandable list */}
        <div style={{ marginBottom: 12 }}>
          <button onClick={() => setShowBooks(!showBooks)}
            style={{ width: "100%", display: "flex", justifyContent: "space-between", alignItems: "center", background: brand.offWhite, border: `1px solid ${brand.borderGray}`, borderRadius: 10, padding: "8px 12px", cursor: "pointer" }}>
            <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal }}>Browse all {c.books.length} books</span>
            {showBooks ? <ChevronUp size={14} color={brand.warmGray} /> : <ChevronDown size={14} color={brand.warmGray} />}
          </button>
          {showBooks && (
            <div style={{ marginTop: 8, maxHeight: 220, overflowY: "auto" as const, display: "flex", flexDirection: "column" as const, gap: 4 }}>
              {c.books.map((book, i) => (
                <div key={i} onClick={() => nav(`/library/${c.id}?book=${i}`)}
                  style={{ display: "flex", gap: 8, alignItems: "flex-start", padding: "7px 10px", background: brand.white, border: `1px solid ${brand.borderGray}`, borderRadius: 8, cursor: "pointer", transition: "background 0.12s" }}
                  onMouseEnter={(e) => (e.currentTarget as HTMLElement).style.background = `${c.color}07`}
                  onMouseLeave={(e) => (e.currentTarget as HTMLElement).style.background = brand.white}
                >
                  <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 10, color: brand.warmGray, minWidth: 18, marginTop: 1 }}>{i + 1}.</span>
                  <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.charcoal, lineHeight: 1.4, flex: 1 }}>{book}</span>
                  <ArrowRight size={11} color={c.color} style={{ flexShrink: 0, marginTop: 2 }} />
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Tags */}
        <div style={{ display: "flex", gap: 5, flexWrap: "wrap", marginBottom: 10 }}>
          {c.tags.slice(0, 3).map((tag) => (
            <span key={tag} style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray, background: brand.offWhite, border: `1px solid ${brand.borderGray}`, borderRadius: 5, padding: "2px 7px" }}>{tag}</span>
          ))}
        </div>

        <div style={{ display: "flex", gap: 5, alignItems: "center", marginBottom: 3 }}>
          <Star size={11} fill={brand.amber} color={brand.amber} />
          <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: brand.charcoal }}>{c.rating}</span>
          <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>({c.reviews.toLocaleString()})</span>
        </div>
        <div style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 14 }}>
          <span style={{ fontFamily: "Inter", fontSize: 10, fontWeight: 700, color: "#2D9B68" }}>✓ Educator-reviewed</span>
          <span style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray }}>· Updated {c.lastUpdated}</span>
        </div>

        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
          <span style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 14, color: c.color }}>{c.price}</span>
          <button onClick={() => nav(`/library/${c.id}`)}
            style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "9px 16px", cursor: "pointer" }}>
            Open Companion →
          </button>
        </div>
      </div>
    </div>
  );
}

export default function DentalLibrary() {
  const nav = useNavigate();
  const [search, setSearch] = useState("");
  const [department, setDepartment] = useState("All Departments");
  const [saved, setSaved] = useState<string[]>([]);

  const filtered = companions.filter((c) => {
    const q = search.toLowerCase();
    const matchSearch =
      c.title.toLowerCase().includes(q) ||
      c.department.toLowerCase().includes(q) ||
      c.tags.some((t) => t.toLowerCase().includes(q)) ||
      c.books.some((b) => b.toLowerCase().includes(q));
    const matchDept = department === "All Departments" || c.department === department;
    return matchSearch && matchDept;
  });

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>

      {/* Hero */}
      <div style={{ background: brand.charcoal, padding: "60px 24px 56px", position: "relative", overflow: "hidden" }}>
        <div style={{ position: "absolute", inset: 0, background: "radial-gradient(ellipse at 25% 60%, rgba(255,198,46,0.09) 0%, transparent 55%), radial-gradient(ellipse at 80% 20%, rgba(255,107,26,0.07) 0%, transparent 50%)", pointerEvents: "none" }} />
        <div style={{ maxWidth: 1200, margin: "0 auto", position: "relative" }}>
          <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, letterSpacing: "0.12em", color: brand.amber, textTransform: "uppercase" as const, marginBottom: 14 }}>Ejadah Study Companions</div>

          <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(28px,4.5vw,50px)", color: "#fff", marginBottom: 16, lineHeight: 1.15, maxWidth: 760 }}>
            Turn dental textbooks into daily,<br />
            <span style={{ background: `linear-gradient(90deg, ${brand.amber}, ${brand.orange})`, WebkitBackgroundClip: "text", WebkitTextFillColor: "transparent" }}>
              easy-to-follow study plans.
            </span>
          </h1>

          <p style={{ fontFamily: "Inter", fontSize: 15, color: "rgba(255,255,255,0.55)", maxWidth: 580, marginBottom: 10, lineHeight: 1.78 }}>
            Each companion covers <strong style={{ color: "rgba(255,255,255,0.8)" }}>20 of the most important textbooks</strong> in that department — summarized by Ejadah educators into voice notes, flashcards, and daily study modules. You pick the books you want to go through, in any order, at your own pace.
          </p>
          <p style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.25)", maxWidth: 500, marginBottom: 32, lineHeight: 1.6 }}>
            You don't get the textbooks. You get everything you actually need from them.
          </p>

          <div style={{ display: "flex", gap: 12, flexWrap: "wrap", marginBottom: 34 }}>
            {[
              { label: "Browse Companions", primary: true, action: () => document.getElementById("companions-grid")?.scrollIntoView({ behavior: "smooth" }) },
              { label: "Continue My Companion", primary: false, action: () => nav("/dashboard") },
              { label: "Preview Free Module", primary: false, action: () => nav("/library/3") },
            ].map((btn) => (
              <button key={btn.label} onClick={btn.action}
                style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: btn.primary ? "#fff" : "rgba(255,255,255,0.7)", background: btn.primary ? gradientFlow : "rgba(255,255,255,0.08)", border: btn.primary ? "none" : "1px solid rgba(255,255,255,0.14)", borderRadius: 12, padding: "12px 22px", cursor: "pointer", boxShadow: btn.primary ? "0 4px 16px rgba(255,107,26,0.35)" : "none", display: "flex", alignItems: "center", gap: 7 }}>
                {btn.label}{btn.primary && <ArrowRight size={13} />}
              </button>
            ))}
          </div>

          {/* Scrolling book name strip */}
          <div style={{ display: "flex", gap: 8, flexWrap: "wrap", alignItems: "center", marginBottom: 28 }}>
            <span style={{ fontFamily: "Inter", fontSize: 11, color: "rgba(255,255,255,0.22)" }}>Textbooks covered:</span>
            {["Cohen's", "Lindhe's", "Proffit's", "Neville's", "Malamed's", "Carranza's", "Sturdevant's", "Burket's", "Ingle's", "Misch's", "Graber's", "Shafer's"].map((name) => (
              <span key={name} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: "rgba(255,255,255,0.38)", background: "rgba(255,255,255,0.05)", borderRadius: 6, padding: "3px 10px", border: "1px solid rgba(255,255,255,0.07)" }}>
                {name}
              </span>
            ))}
            <span style={{ fontFamily: "Inter", fontSize: 11, color: "rgba(255,255,255,0.22)" }}>& 148 more</span>
          </div>

          <div style={{ position: "relative", maxWidth: 460 }}>
            <Search size={15} style={{ position: "absolute", left: 14, top: "50%", transform: "translateY(-50%)", color: "rgba(255,255,255,0.3)" }} />
            <input value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Search by textbook name, department, topic…"
              style={{ width: "100%", fontFamily: "Inter", fontSize: 14, background: "rgba(255,255,255,0.09)", border: "1px solid rgba(255,255,255,0.13)", borderRadius: 12, padding: "12px 14px 12px 42px", color: "#fff", outline: "none", boxSizing: "border-box" as const }} />
          </div>
        </div>
      </div>

      {/* How it works strip */}
      <div style={{ background: brand.white, borderBottom: `1px solid ${brand.borderGray}` }}>
        <div style={{ maxWidth: 1200, margin: "0 auto", padding: "32px 24px", display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))", gap: 20 }}>
          {[
            { icon: "📚", title: "Pick a companion", desc: "Choose a department. Each companion covers 20 textbooks, all summarized." },
            { icon: "📖", title: "Browse the books inside", desc: "See every textbook in the companion. Pick whichever you want to go through first." },
            { icon: "⏱️", title: "Set your weekly time", desc: "Tell us how many hours you have. We build a daily plan around your schedule." },
            { icon: "🎧", title: "Go at your own pace", desc: "Read summaries, listen to voice notes, and practice flashcards — any book, any order." },
          ].map((s, i) => (
            <div key={i} style={{ display: "flex", gap: 14, alignItems: "flex-start" }}>
              <div style={{ width: 38, height: 38, borderRadius: 12, background: `${brand.orange}10`, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0, fontSize: 17 }}>{s.icon}</div>
              <div>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal, marginBottom: 3 }}>{s.title}</div>
                <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, lineHeight: 1.6 }}>{s.desc}</div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Companions */}
      <div id="companions-grid" style={{ maxWidth: 1200, margin: "0 auto", padding: "32px 24px 60px" }}>
        <div style={{ display: "flex", gap: 8, flexWrap: "wrap", marginBottom: 28, alignItems: "center" }}>
          <Filter size={13} color={brand.warmGray} />
          {departments.map((d) => (
            <button key={d} onClick={() => setDepartment(d)}
              style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: department === d ? "#fff" : brand.charcoal, background: department === d ? gradientFlow : brand.white, border: `1.5px solid ${department === d ? "transparent" : brand.borderGray}`, borderRadius: 20, padding: "5px 13px", cursor: "pointer" }}>
              {d}
            </button>
          ))}
          <div style={{ marginLeft: "auto", fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>{filtered.length} companions</div>
        </div>

        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(320px, 1fr))", gap: 20, marginBottom: 48 }}>
          {filtered.map((c) => (
            <CompanionCard key={c.id} c={c} nav={nav} saved={saved} setSaved={setSaved} />
          ))}
        </div>

        {/* Bottom CTA */}
        <div style={{ background: brand.charcoal, borderRadius: 24, padding: "36px 32px", display: "flex", gap: 40, flexWrap: "wrap", alignItems: "center" }}>
          <div style={{ flex: 1, minWidth: 240 }}>
            <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: "#fff", marginBottom: 10, lineHeight: 1.3 }}>160+ textbooks. 8 departments. One subscription each.</div>
            <div style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.4)", lineHeight: 1.75, marginBottom: 22 }}>
              You're not buying the textbooks. You're getting Ejadah educators' summaries, voice notes, flashcards, and a daily plan built from them — so you don't have to read 1,000 pages on your own.
            </div>
            <div style={{ display: "flex", gap: 10 }}>
              <button onClick={() => nav("/pricing")} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "12px 22px", cursor: "pointer" }}>
                See Pricing Plans →
              </button>
            </div>
          </div>
          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 8, flex: 1, minWidth: 200 }}>
            {[["📚", "20 textbooks per companion"], ["🎧", "Voice notes for every book"], ["🃏", "Flashcards per textbook"], ["📝", "Quizzes & checkpoints"], ["📅", "Personalized daily plan"], ["📈", "Progress per book"]].map(([icon, label]) => (
              <div key={label} style={{ display: "flex", gap: 7, alignItems: "center" }}>
                <span style={{ fontSize: 14 }}>{icon}</span>
                <span style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.6)" }}>{label}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
