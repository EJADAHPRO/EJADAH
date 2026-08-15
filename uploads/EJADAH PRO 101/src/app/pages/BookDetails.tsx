import { useState } from "react";
import { useNavigate, useParams, useSearchParams } from "react-router";
import { ChevronLeft, CheckCircle, Headphones, BookMarked, ClipboardList, Layers, Play, Pause, SkipForward, Bookmark, ArrowRight, Lock, Search, Star, BarChart2, ZapIcon, ChevronDown, ChevronRight } from "lucide-react";
import { brand, gradientFlow } from "@/app/shared";

// 20 books per companion — full data for Endodontics, summarised stubs for others
const allBooks: Record<string, { name: string; authors: string; edition: string; modules: number; audioDuration: string; flashcards: number; quizzes: number; progress: number; status: "done" | "in-progress" | "not-started" }[]> = {
  "1": [
    { name: "Cohen's Pathways of the Pulp", authors: "Hargreaves & Berman", edition: "12th Ed.", modules: 10, audioDuration: "4h 20min", flashcards: 280, quizzes: 6, progress: 100, status: "done" },
    { name: "Ingle's Endodontics", authors: "Rotstein & Ingle", edition: "7th Ed.", modules: 12, audioDuration: "5h 10min", flashcards: 310, quizzes: 7, progress: 65, status: "in-progress" },
    { name: "Torabinejad's Endodontics", authors: "Torabinejad et al.", edition: "5th Ed.", modules: 9, audioDuration: "3h 50min", flashcards: 240, quizzes: 5, progress: 0, status: "not-started" },
    { name: "Hargreaves' Seltzer & Bender's Dental Pulp", authors: "Hargreaves & Goodis", edition: "2nd Ed.", modules: 8, audioDuration: "3h 20min", flashcards: 210, quizzes: 4, progress: 0, status: "not-started" },
    { name: "Clinical Endodontics", authors: "Tronstad", edition: "3rd Ed.", modules: 7, audioDuration: "2h 55min", flashcards: 190, quizzes: 4, progress: 0, status: "not-started" },
    { name: "Grossman's Endodontic Practice", authors: "Grossman", edition: "13th Ed.", modules: 9, audioDuration: "3h 45min", flashcards: 230, quizzes: 5, progress: 0, status: "not-started" },
    { name: "Problem Solving in Endodontics", authors: "Gutmann & Lovdahl", edition: "5th Ed.", modules: 8, audioDuration: "3h 10min", flashcards: 200, quizzes: 4, progress: 0, status: "not-started" },
    { name: "Endodontic Diagnosis, Pathology & Treatment Planning", authors: "Rosenthal et al.", edition: "1st Ed.", modules: 7, audioDuration: "2h 50min", flashcards: 180, quizzes: 4, progress: 0, status: "not-started" },
    { name: "Color Atlas of Endodontics", authors: "Baumann & Beer", edition: "2nd Ed.", modules: 6, audioDuration: "2h 20min", flashcards: 150, quizzes: 3, progress: 0, status: "not-started" },
    { name: "Endodontic Radiology", authors: "Farman", edition: "2nd Ed.", modules: 6, audioDuration: "2h 30min", flashcards: 160, quizzes: 3, progress: 0, status: "not-started" },
    { name: "Regenerative Endodontics", authors: "Fouad", edition: "1st Ed.", modules: 7, audioDuration: "2h 55min", flashcards: 180, quizzes: 4, progress: 0, status: "not-started" },
    { name: "Management of Endodontic Emergencies", authors: "Hasselgren", edition: "1st Ed.", modules: 5, audioDuration: "1h 55min", flashcards: 130, quizzes: 3, progress: 0, status: "not-started" },
    { name: "Root Canal Morphology", authors: "Vertucci et al.", edition: "1st Ed.", modules: 6, audioDuration: "2h 20min", flashcards: 155, quizzes: 3, progress: 0, status: "not-started" },
    { name: "Surgical Endodontics", authors: "Rubinstein", edition: "1st Ed.", modules: 7, audioDuration: "2h 50min", flashcards: 175, quizzes: 4, progress: 0, status: "not-started" },
    { name: "Endodontic Retreatment Handbook", authors: "Friedman", edition: "1st Ed.", modules: 6, audioDuration: "2h 25min", flashcards: 160, quizzes: 3, progress: 0, status: "not-started" },
    { name: "Vital Pulp Therapy", authors: "Bogen & Chandler", edition: "1st Ed.", modules: 5, audioDuration: "2h 00min", flashcards: 130, quizzes: 3, progress: 0, status: "not-started" },
    { name: "Endodontics: Colleagues for Excellence", authors: "AAE", edition: "2023", modules: 4, audioDuration: "1h 30min", flashcards: 110, quizzes: 2, progress: 0, status: "not-started" },
    { name: "The Dental Pulp: Biology, Pathology & Regenerative Therapies", authors: "Goldberg", edition: "1st Ed.", modules: 7, audioDuration: "2h 45min", flashcards: 180, quizzes: 4, progress: 0, status: "not-started" },
    { name: "Lasers in Endodontics", authors: "de Almeida et al.", edition: "1st Ed.", modules: 5, audioDuration: "1h 55min", flashcards: 125, quizzes: 3, progress: 0, status: "not-started" },
    { name: "Contemporary Endodontics for Children", authors: "Fuks & Peretz", edition: "2nd Ed.", modules: 6, audioDuration: "2h 20min", flashcards: 155, quizzes: 3, progress: 0, status: "not-started" },
  ],
};

// Generate stub books for companions 2–8 from their book name lists
const bookNameLists: Record<string, string[]> = {
  "2": ["Clinical Periodontology & Implant Dentistry — Lindhe","Carranza's Clinical Periodontology — Newman","Periodontics: Medicine, Surgery & Implants — Rose & Mealey","Fundamentals of Periodontal Instrumentation — Nield-Gehrig","Rationale of Periodontal Treatment — Ramfjord & Ash","Periodontal Therapy — Schluger et al.","Implant Dentistry — Misch","Contemporary Implant Dentistry — Misch","Peri-Implant Therapy — Wingrove","Color Atlas: Periodontology — Wolf & Rateitschak","Surgical Manual of Implant Dentistry — Buser","The Periodontium — Bartold & Narayanan","Esthetic Soft Tissue Management — Zucchelli","Oral Biofilms & Plaque Control — Newman","Furcation: Involvement & Treatment — Cattabriga","Bone Augmentation in Oral Implantology — Buser","Mucogingival Esthetic Surgery — Cairo","Supportive Periodontal Therapy — Lang & Bartold","Periodontal Medicine — Rose, Genco & Mealey","Clinical Practice of the Dental Hygienist — Wilkins"],
  "3": ["Contemporary Orthodontics — Proffit","Orthodontics: Current Principles — Graber","Biomechanics & Esthetic Strategies — Nanda","Clinical Management of Skeletal Discrepancies — Pancherz","A Textbook of Orthodontics — Houston & Tulley","Orthodontic Cephalometry — Athanasiou","Essentials of Orthodontics — Bishara","Orthodontic Retreatment — Joondeph","Invisible Orthodontics — Echarri","The Invisalign System — Tuncay","Temporary Anchorage Devices — Papadopoulos","Interdisciplinary Treatment Planning — Cohen","Surgical-Orthodontic Treatment — Proffit, White & Sarver","Early Orthodontic Treatment — Tollaro & Baccetti","Bone-borne Orthodontic Appliances — Cornelis","Orthodontic Materials — O'Brien","Lingual Orthodontics — Harradine","MEAW Technique — Kim","Functional Appliances — Graber et al.","Orthodontic Radiographs — Hellman"],
  "4": ["Oral & Maxillofacial Pathology — Neville","Shafer's Textbook of Oral Pathology — Sivapathasundharam","Color Atlas of Oral Diseases — Laskaris","Cawson's Essentials — Odell","Oral Pathology: Clinical-Pathologic Correlations — Regezi","Surgical Pathology of Mouth & Jaws — Jones & Franklin","Oral Cancer — Shah","Salivary Gland Diseases — Speight & Barrett","Temporomandibular Disorders — Katzberg","Bone Diseases of the Jaws — Marx & Stern","Odontogenic Cysts & Tumors — Barnes et al.","Ulcerative Conditions — Scully","Oral Manifestations of Systemic Diseases — Greenberg","Dermatology for the Oral Physician — Scully","Head & Neck Pathology — Gnepp","Atlas of Oral Lesions — Lozada-Nur","Forensic Odontology — Senn & Stimson","Pigmented Lesions of the Oral Mucosa — Buchner","Viral Infections of the Oral Cavity — Scully","Granulomatous Diseases — Van der Waal"],
  "5": ["Handbook of Local Anesthesia — Malamed","Pharmacology & Therapeutics for Dentistry — Dowd","Medical Emergencies in the Dental Office — Malamed","Drug Prescribing for Dentistry — SDCEP","Mosby's Dental Drug Reference — Jeske","Conscious Sedation for Dentistry — Hallonsten","Nitrous Oxide in Dentistry — Clark & Brunick","Pharmacology in Dental Hygiene — Pickett","Analgesics in Dentistry — Moore","Antibiotic Prescribing in Dentistry — BNF","Dental Pharmacology — Squier & Hall","Adverse Drug Reactions — Scully & Cawson","Sedation in Dentistry — Craig & Skelly","Orofacial Pain Guidelines — ADA","Herbal Medicine in Dentistry — Burt","Fluoride in Dentistry — Fejerskov","Antifungal Therapy — Cannon","Antiviral Therapy — Slots","Bisphosphonates & ONJ — Marx","Drug-Induced Oral Disorders — Scully"],
  "6": ["Textbook of Oral Medicine — Greenberg","Burket's Oral Medicine — Glick","Scully's Oral & Maxillofacial Medicine — Scully","Oral Medicine at a Glance — Dios & Lodi","Clinician's Guide — Yellowitz","Orofacial Pain — Sessle et al.","Temporomandibular Disorders — de Leeuw","Dry Mouth — Edgar, Dawes & O'Mullane","Salivary Gland Diseases — Speight","Oral Mucosal Diseases — Lodi & Sardella","HIV & the Mouth — Greenspan","Sjögren's Syndrome — Fox","Burning Mouth Syndrome — Patton","Oral Dysesthesia — Grushka","Medically Compromised Patient — Little","Haematological Disorders & the Mouth — Scully","Endocrine Disorders & Oral Health — Ship","Gastrointestinal Diseases & the Mouth — Scully","Neurological Disorders — Zakrzewska","Immunological Diseases — Porter"],
  "7": ["Sturdevant's Art & Science of Operative Dentistry — Ritter","Pickard's Manual of Operative Dentistry — Kidd","Operative Dentistry — Mondelli","Caries Management by Risk Assessment — Featherstone","Cariology — Fejerskov & Kidd","Minimally Invasive Dentistry — Frencken","Dental Materials — Craig","Restorative Dental Materials — O'Brien","Esthetic Dentistry — Goldstein","Fundamentals of Operative Dentistry — Summitt","Adhesive Dentistry — Ritter","Direct Composite Restorations — Baratieri","Tooth-Colored Restoratives — Alexander","Pulp Biology & Pathology — Tronstad","ART: Atraumatic Restorative Treatment — Frencken","Glass Ionomer Cements — McLean & Wilson","Ceramic Inlays — Mörmann","Silver Diamine Fluoride — Horst","Cavity Disinfection — Hauman & Love","Dentin Hypersensitivity — Addy, Embery & Edgar"],
  "8": ["Principles of Oral & Maxillofacial Surgery — Hupp","Peterson's Principles of Oral & Maxillofacial Surgery — Miloro","Oral & Maxillofacial Surgery — Fonseca","Minor Oral Surgery — Fragiskos","Essentials of Oral & Maxillofacial Surgery — Pedlar & Frame","Handbook of Local Anesthesia — Malamed","Maxillofacial Trauma — Kruger","Management of Impacted Third Molars — Pogrel","Dentoalveolar Surgery — Koerner","Flap Design in Oral Surgery — Mörmann","Complications in Oral Surgery — Peñarrocha","Pre-Prosthetic & Implant Surgery — Lew","Oral Surgery for the General Dentist — Nwoku","Surgical Guide for Dental Implant Placement — Buser","Jaw Cysts — Browne","Bisphosphonate-Related Osteonecrosis — Marx","Facial Pain — Grushka & Sessle","Dry Socket & Healing — Alexander","Bleeding Disorders & Oral Surgery — Scully","Antibiotic Prophylaxis — Scottish Guidelines"],
};

// Build stub entries for companions 2–8
for (const [id, names] of Object.entries(bookNameLists)) {
  allBooks[id] = names.map((name, i) => ({
    name: name.split(" — ")[0],
    authors: name.includes(" — ") ? name.split(" — ")[1] : "",
    edition: "",
    modules: 6 + (i % 5),
    audioDuration: `${2 + (i % 3)}h ${["00", "20", "40"][i % 3]}min`,
    flashcards: 150 + (i % 8) * 20,
    quizzes: 3 + (i % 3),
    progress: 0,
    status: "not-started" as const,
  }));
}

const companionMeta: Record<string, { department: string; title: string; emoji: string; color: string; level: string; totalModules: number; totalAudio: string; totalFlashcards: number; totalQuizzes: number; lastUpdated: string; reviewerName: string; subscriptionStatus: string; price: string; progressPct: number; studyStreak: number; description: string }> = {
  "1": { department: "Endodontics", title: "Endodontics Study Companion", emoji: "🦷", color: brand.orange, level: "Student · Intern · Postgraduate", totalModules: 180, totalAudio: "62h", totalFlashcards: 4200, totalQuizzes: 80, lastUpdated: "July 2026", reviewerName: "Dr. Amira Soliman, MSc Endo", subscriptionStatus: "subscribed", price: "EGP 499/month", progressPct: 9, studyStreak: 7, description: "Cohen's, Ingle's, Torabinejad's and 17 more of the most important endodontic references — each one summarized into focused daily modules, voice notes, and flashcards. Go through any book in any order." },
  "2": { department: "Periodontics", title: "Periodontics Study Companion", emoji: "🩺", color: "#2D9B68", level: "Student · Intern · Postgraduate", totalModules: 160, totalAudio: "55h", totalFlashcards: 3800, totalQuizzes: 72, lastUpdated: "July 2026", reviewerName: "Dr. Hana El-Gohary, MSc Perio", subscriptionStatus: "locked", price: "EGP 499/month", progressPct: 0, studyStreak: 0, description: "Lindhe's, Carranza's and 18 more periodontic references — all summarized into daily study modules, voice explanations, and flashcard sets you can go through at your own pace." },
  "3": { department: "Orthodontics", title: "Orthodontics Study Companion", emoji: "🔬", color: "#496FA8", level: "Student · Intern", totalModules: 144, totalAudio: "48h", totalFlashcards: 3400, totalQuizzes: 60, lastUpdated: "June 2026", reviewerName: "Dr. Karim Adly, MSc Ortho", subscriptionStatus: "free-preview", price: "EGP 499/month", progressPct: 1, studyStreak: 2, description: "Proffit's, Graber's and 18 more orthodontic texts — summarized and organized so you can pick any book and start studying it right now, without reading 800 pages." },
  "4": { department: "Oral Pathology", title: "Oral Pathology Study Companion", emoji: "🧫", color: "#8B5CF6", level: "Student · Intern · Postgraduate", totalModules: 192, totalAudio: "66h", totalFlashcards: 4800, totalQuizzes: 90, lastUpdated: "July 2026", reviewerName: "Dr. Sara Mostafa, MSc Path", subscriptionStatus: "locked", price: "EGP 499/month", progressPct: 0, studyStreak: 0, description: "Neville's, Shafer's and 18 more oral pathology texts — distilled into visual-first daily summaries, audio explanations, and high-yield flashcards for EDLE and postgrad prep." },
  "5": { department: "Oral Pharmacology", title: "Oral Pharmacology Study Companion", emoji: "💊", color: "#FF2D32", level: "Student · Intern", totalModules: 120, totalAudio: "40h", totalFlashcards: 2800, totalQuizzes: 54, lastUpdated: "June 2026", reviewerName: "Dr. Youssef Naguib, PhD Pharma", subscriptionStatus: "locked", price: "EGP 499/month", progressPct: 0, studyStreak: 0, description: "Malamed's, Dowd's and 18 more pharmacology texts — simplified into focused voice-led modules covering mechanisms, dosages, and drug interactions for clinical and exam readiness." },
  "6": { department: "Oral Medicine", title: "Oral Medicine Study Companion", emoji: "🩹", color: brand.amber, level: "Student · Intern · Postgraduate", totalModules: 128, totalAudio: "44h", totalFlashcards: 3100, totalQuizzes: 58, lastUpdated: "May 2026", reviewerName: "Dr. Dina Rashad, MSc Oral Med", subscriptionStatus: "free-preview", price: "EGP 499/month", progressPct: 0, studyStreak: 0, description: "Burket's, Greenberg's and 18 more oral medicine references — summarized into daily modules covering systemic disease manifestations, ulcerative conditions, and diagnostic reasoning." },
  "7": { department: "Conservative Dentistry", title: "Conservative Dentistry Study Companion", emoji: "🪥", color: "#2D9B68", level: "Student · Intern", totalModules: 160, totalAudio: "54h", totalFlashcards: 3700, totalQuizzes: 68, lastUpdated: "July 2026", reviewerName: "Dr. Mariam Lotfy, MSc Operative", subscriptionStatus: "locked", price: "EGP 499/month", progressPct: 0, studyStreak: 0, description: "Sturdevant's, Pickard's and 18 more operative dentistry references — broken down into daily modules covering caries management, adhesive systems, and composite placement." },
  "8": { department: "Oral Surgery", title: "Oral Surgery Study Companion", emoji: "⚕️", color: "#496FA8", level: "Student · Intern", totalModules: 136, totalAudio: "46h", totalFlashcards: 3200, totalQuizzes: 60, lastUpdated: "June 2026", reviewerName: "Dr. Ahmed Badr, MSc OMS", subscriptionStatus: "locked", price: "EGP 499/month", progressPct: 0, studyStreak: 0, description: "Hupp's, Peterson's and 18 more oral surgery references — summarized into step-by-step modules covering extraction techniques, flap design, impacted teeth, and complication management." },
};

const statusColors = { "done": "#2D9B68", "in-progress": brand.orange, "not-started": brand.warmGray };
const statusLabels = { "done": "✓ Completed", "in-progress": "In Progress", "not-started": "Not Started" };

export default function BookDetails() {
  const { id } = useParams();
  const [searchParams] = useSearchParams();
  const nav = useNavigate();

  const companionId = id ?? "1";
  const meta = companionMeta[companionId] ?? companionMeta["1"];
  const books = allBooks[companionId] ?? allBooks["1"];

  const initialBook = parseInt(searchParams.get("book") ?? "0");

  const [activeTab, setActiveTab] = useState<"books" | "progress" | "plan">("books");
  const [selectedBook, setSelectedBook] = useState<number | null>(initialBook);
  const [bookSearch, setBookSearch] = useState("");
  const [filterStatus, setFilterStatus] = useState<"all" | "done" | "in-progress" | "not-started">("all");
  const [studyHours, setStudyHours] = useState("");
  const [studyPref, setStudyPref] = useState("");
  const [playing, setPlaying] = useState(false);

  const isSubscribed = meta.subscriptionStatus === "subscribed";
  const isFreePreview = meta.subscriptionStatus === "free-preview";
  const isLocked = meta.subscriptionStatus === "locked";

  const filteredBooks = books.filter((b, i) => {
    const q = bookSearch.toLowerCase();
    const matchSearch = b.name.toLowerCase().includes(q) || b.authors.toLowerCase().includes(q);
    const matchStatus = filterStatus === "all" || b.status === filterStatus;
    return matchSearch && matchStatus;
  });

  const selectedBookData = selectedBook !== null ? books[selectedBook] : null;

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>

      {/* Header */}
      <div style={{ background: brand.charcoal, padding: "36px 24px 28px", position: "relative", overflow: "hidden" }}>
        <div style={{ position: "absolute", inset: 0, background: `radial-gradient(ellipse at 80% 40%, ${meta.color}10 0%, transparent 55%)`, pointerEvents: "none" }} />
        <div style={{ maxWidth: 1100, margin: "0 auto", position: "relative" }}>
          <button onClick={() => nav("/library")} style={{ background: "none", border: "none", cursor: "pointer", color: "rgba(255,255,255,0.4)", fontFamily: "Inter", fontSize: 13, display: "flex", alignItems: "center", gap: 5, marginBottom: 18 }}>
            <ChevronLeft size={14} /> All Study Companions
          </button>

          <div style={{ display: "flex", gap: 20, alignItems: "flex-start", flexWrap: "wrap" }}>
            <div style={{ width: 72, height: 72, borderRadius: 18, background: `${meta.color}18`, border: `2px solid ${meta.color}30`, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0, fontSize: 34 }}>
              {meta.emoji}
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 10, color: meta.color, textTransform: "uppercase" as const, letterSpacing: "0.08em", marginBottom: 5 }}>{meta.department}</div>
              <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(20px,3vw,26px)", color: "#fff", marginBottom: 8, lineHeight: 1.2 }}>{meta.title}</h1>
              <p style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.45)", lineHeight: 1.7, maxWidth: 560, marginBottom: 10 }}>{meta.description}</p>
              <div style={{ display: "flex", gap: 16, flexWrap: "wrap" }}>
                {[
                  { icon: <Layers size={12} />, label: `${books.length} textbooks` },
                  { icon: <Layers size={12} />, label: `${meta.totalModules} modules` },
                  { icon: <Headphones size={12} />, label: `${meta.totalAudio} voice` },
                  { icon: <BookMarked size={12} />, label: `${meta.totalFlashcards.toLocaleString()} flashcards` },
                  { icon: <ClipboardList size={12} />, label: `${meta.totalQuizzes} quizzes` },
                ].map((s) => (
                  <div key={s.label} style={{ display: "flex", gap: 5, alignItems: "center", fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.45)" }}>
                    <span style={{ color: meta.color }}>{s.icon}</span>{s.label}
                  </div>
                ))}
              </div>
            </div>
            <div style={{ flexShrink: 0, textAlign: "right" as const }}>
              {isSubscribed && <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: "#2D9B68", background: "#2D9B6814", border: "1px solid #2D9B6830", borderRadius: 8, padding: "5px 12px", marginBottom: 8 }}>✓ Active</div>}
              {isFreePreview && <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: meta.color, background: `${meta.color}14`, border: `1px solid ${meta.color}30`, borderRadius: 8, padding: "5px 12px", marginBottom: 8 }}>Free Preview</div>}
              {isLocked && <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: brand.warmGray, background: "rgba(255,255,255,0.06)", border: "1px solid rgba(255,255,255,0.1)", borderRadius: 8, padding: "5px 12px", marginBottom: 8 }}>🔒 Locked</div>}
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 800, fontSize: 18, color: meta.color }}>{meta.price}</div>
            </div>
          </div>
        </div>
      </div>

      <div style={{ maxWidth: 1100, margin: "0 auto", padding: "24px 24px 60px", display: "flex", gap: 22, flexWrap: "wrap", alignItems: "flex-start" }}>

        {/* LEFT — book browser */}
        <div style={{ flex: 1, minWidth: 300 }}>

          {/* Tabs */}
          <div style={{ display: "flex", borderBottom: `2px solid ${brand.borderGray}`, marginBottom: 22 }}>
            {([["books", `📚 ${books.length} Textbooks`], ["progress", "📈 Progress"], ["plan", "📅 Study Plan"]] as const).map(([key, label]) => (
              <button key={key} onClick={() => setActiveTab(key)}
                style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: activeTab === key ? meta.color : brand.warmGray, background: "none", border: "none", borderBottom: `2px solid ${activeTab === key ? meta.color : "transparent"}`, marginBottom: -2, padding: "10px 16px", cursor: "pointer", whiteSpace: "nowrap" as const }}>
                {label}
              </button>
            ))}
          </div>

          {/* BOOKS TAB */}
          {activeTab === "books" && (
            <div style={{ display: "flex", gap: 18, flexWrap: "wrap", alignItems: "flex-start" }}>

              {/* Book list */}
              <div style={{ flex: 1, minWidth: 260 }}>
                {/* Search + filter */}
                <div style={{ display: "flex", gap: 8, marginBottom: 14, flexWrap: "wrap" }}>
                  <div style={{ position: "relative", flex: 1, minWidth: 160 }}>
                    <Search size={13} style={{ position: "absolute", left: 10, top: "50%", transform: "translateY(-50%)", color: brand.warmGray }} />
                    <input value={bookSearch} onChange={(e) => setBookSearch(e.target.value)} placeholder="Search books…"
                      style={{ width: "100%", fontFamily: "Inter", fontSize: 13, background: brand.white, border: `1.5px solid ${brand.borderGray}`, borderRadius: 10, padding: "8px 10px 8px 30px", outline: "none", color: brand.charcoal, boxSizing: "border-box" as const }}
                      onFocus={(e) => (e.target.style.borderColor = meta.color)} onBlur={(e) => (e.target.style.borderColor = brand.borderGray)} />
                  </div>
                  {(["all", "done", "in-progress", "not-started"] as const).map((f) => (
                    <button key={f} onClick={() => setFilterStatus(f)}
                      style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: filterStatus === f ? "#fff" : brand.warmGray, background: filterStatus === f ? meta.color : brand.white, border: `1.5px solid ${filterStatus === f ? meta.color : brand.borderGray}`, borderRadius: 20, padding: "5px 11px", cursor: "pointer" }}>
                      {f === "all" ? "All" : f === "done" ? "✓ Done" : f === "in-progress" ? "In Progress" : "Not Started"}
                    </button>
                  ))}
                </div>

                {/* Book entries */}
                <div style={{ display: "flex", flexDirection: "column" as const, gap: 8 }}>
                  {filteredBooks.map((book, rawIdx) => {
                    const realIdx = books.indexOf(book);
                    const isSelected = selectedBook === realIdx;
                    const canAccess = isSubscribed || (isFreePreview && realIdx < 2) || (isLocked && realIdx < 1);
                    return (
                      <div key={rawIdx} onClick={() => canAccess ? setSelectedBook(realIdx) : null}
                        style={{ background: isSelected ? `${meta.color}08` : brand.white, border: `1.5px solid ${isSelected ? meta.color : brand.borderGray}`, borderRadius: 14, padding: "14px 16px", cursor: canAccess ? "pointer" : "default", opacity: !canAccess && !isLocked ? 0.7 : 1, transition: "border-color 0.15s, background 0.15s" }}>
                        <div style={{ display: "flex", gap: 12, alignItems: "flex-start" }}>
                          <div style={{ width: 32, height: 32, borderRadius: 9, background: canAccess ? `${meta.color}14` : brand.offWhite, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                            {canAccess ? (
                              <span style={{ fontFamily: "Inter", fontWeight: 800, fontSize: 11, color: meta.color }}>{books.indexOf(book) + 1}</span>
                            ) : (
                              <Lock size={13} color={brand.warmGray} />
                            )}
                          </div>
                          <div style={{ flex: 1, minWidth: 0 }}>
                            <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal, lineHeight: 1.3, marginBottom: 2 }}>{book.name}</div>
                            {book.authors && <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginBottom: 4 }}>{book.authors}{book.edition ? ` · ${book.edition}` : ""}</div>}
                            <div style={{ display: "flex", gap: 10, flexWrap: "wrap" as const }}>
                              <span style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray }}>{book.modules} modules</span>
                              <span style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray }}>· {book.audioDuration}</span>
                              <span style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray }}>· {book.flashcards} cards</span>
                            </div>
                          </div>
                          <div style={{ flexShrink: 0, textAlign: "right" as const }}>
                            <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 10, color: statusColors[book.status], background: `${statusColors[book.status]}12`, borderRadius: 5, padding: "2px 7px", marginBottom: 6 }}>{statusLabels[book.status]}</div>
                            {book.progress > 0 && (
                              <div style={{ width: 50, height: 3, background: brand.borderGray, borderRadius: 10, overflow: "hidden", marginLeft: "auto" }}>
                                <div style={{ height: "100%", width: `${book.progress}%`, background: meta.color, borderRadius: 10 }} />
                              </div>
                            )}
                          </div>
                        </div>
                      </div>
                    );
                  })}
                </div>

                {!isSubscribed && (
                  <div style={{ marginTop: 14, textAlign: "center" as const, padding: "20px", background: brand.white, borderRadius: 14, border: `1.5px dashed ${brand.borderGray}` }}>
                    <Lock size={20} color={brand.warmGray} style={{ marginBottom: 8 }} />
                    <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal, marginBottom: 4 }}>Subscribe to unlock all {books.length} books</div>
                    <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginBottom: 14 }}>Go through any textbook, in any order, at your own pace.</div>
                    <button onClick={() => nav("/checkout/subscription?plan=student-pass")}
                      style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 11, padding: "11px 22px", cursor: "pointer" }}>
                      Unlock Companion — {meta.price}
                    </button>
                  </div>
                )}
              </div>

              {/* Book detail panel */}
              {selectedBookData && (
                <div style={{ width: 280, flexShrink: 0 }}>
                  <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "20px", position: "sticky", top: 90 }}>
                    <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 10, color: meta.color, textTransform: "uppercase" as const, letterSpacing: "0.07em", marginBottom: 6 }}>Book {selectedBook! + 1} of {books.length}</div>
                    <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 16, color: brand.charcoal, lineHeight: 1.3, marginBottom: 4 }}>{selectedBookData.name}</div>
                    {selectedBookData.authors && <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginBottom: 12 }}>{selectedBookData.authors}{selectedBookData.edition ? ` · ${selectedBookData.edition}` : ""}</div>}

                    {/* Stats */}
                    {[
                      ["Summary modules", selectedBookData.modules],
                      ["Voice notes", selectedBookData.audioDuration],
                      ["Flashcards", selectedBookData.flashcards],
                      ["Quizzes", selectedBookData.quizzes],
                    ].map(([label, value]) => (
                      <div key={label as string} style={{ display: "flex", justifyContent: "space-between", padding: "8px 0", borderBottom: `1px solid ${brand.borderGray}` }}>
                        <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>{label as string}</span>
                        <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.charcoal }}>{String(value)}</span>
                      </div>
                    ))}

                    {selectedBookData.progress > 0 && (
                      <div style={{ marginTop: 14 }}>
                        <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 5 }}>
                          <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>Progress</span>
                          <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: meta.color }}>{selectedBookData.progress}%</span>
                        </div>
                        <div style={{ height: 6, background: brand.offWhite, borderRadius: 20, overflow: "hidden" }}>
                          <div style={{ height: "100%", width: `${selectedBookData.progress}%`, background: meta.color, borderRadius: 20 }} />
                        </div>
                      </div>
                    )}

                    <div style={{ marginTop: 16, display: "flex", flexDirection: "column" as const, gap: 8 }}>
                      {/* Voice note player mock */}
                      <div style={{ background: brand.offWhite, borderRadius: 12, padding: "12px" }}>
                        <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: brand.charcoal, marginBottom: 8 }}>🎧 Voice Explanation</div>
                        <div style={{ display: "flex", gap: 8, alignItems: "center" }}>
                          <button onClick={() => setPlaying(!playing)}
                            style={{ width: 34, height: 34, borderRadius: "50%", background: `linear-gradient(135deg, ${meta.color}, ${meta.color}CC)`, border: "none", display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer", flexShrink: 0 }}>
                            {playing ? <Pause size={13} color="#fff" /> : <Play size={13} color="#fff" />}
                          </button>
                          <div style={{ flex: 1 }}>
                            <div style={{ height: 3, background: brand.borderGray, borderRadius: 10, overflow: "hidden" }}>
                              <div style={{ height: "100%", width: playing ? "35%" : "0%", background: meta.color, borderRadius: 10, transition: "width 0.5s" }} />
                            </div>
                            <div style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray, marginTop: 4 }}>{selectedBookData.audioDuration} total</div>
                          </div>
                          <SkipForward size={13} color={brand.warmGray} style={{ cursor: "pointer" }} />
                        </div>
                      </div>

                      <button style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff", background: `linear-gradient(135deg, ${meta.color}, ${meta.color}CC)`, border: "none", borderRadius: 12, padding: "12px", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 7 }}>
                        Start Studying <ArrowRight size={13} />
                      </button>
                      <button style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: "#2D9B68", background: "#2D9B6810", border: "none", borderRadius: 12, padding: "10px", cursor: "pointer" }}>
                        🃏 Practice Flashcards
                      </button>
                    </div>

                    {/* Navigate between books */}
                    <div style={{ display: "flex", justifyContent: "space-between", marginTop: 14 }}>
                      <button onClick={() => selectedBook! > 0 && setSelectedBook(selectedBook! - 1)} disabled={selectedBook === 0}
                        style={{ fontFamily: "Inter", fontSize: 11, color: selectedBook === 0 ? brand.borderGray : brand.orange, background: "none", border: "none", cursor: selectedBook === 0 ? "default" : "pointer" }}>
                        ← Previous
                      </button>
                      <button onClick={() => selectedBook! < books.length - 1 && setSelectedBook(selectedBook! + 1)} disabled={selectedBook === books.length - 1}
                        style={{ fontFamily: "Inter", fontSize: 11, color: selectedBook === books.length - 1 ? brand.borderGray : brand.orange, background: "none", border: "none", cursor: selectedBook === books.length - 1 ? "default" : "pointer" }}>
                        Next →
                      </button>
                    </div>
                  </div>
                </div>
              )}
            </div>
          )}

          {/* PROGRESS TAB */}
          {activeTab === "progress" && (
            <div style={{ display: "flex", flexDirection: "column" as const, gap: 16 }}>
              {isLocked ? (
                <div style={{ textAlign: "center" as const, padding: "40px", background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}` }}>
                  <Lock size={24} color={brand.warmGray} style={{ marginBottom: 10 }} />
                  <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal, marginBottom: 8 }}>Subscribe to track progress</div>
                  <button onClick={() => nav("/checkout/subscription?plan=student-pass")} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "12px 24px", cursor: "pointer" }}>
                    Unlock Companion
                  </button>
                </div>
              ) : (
                <>
                  <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "22px" }}>
                    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 10 }}>
                      <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal }}>Overall Progress</div>
                      <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 800, fontSize: 24, color: meta.color }}>{meta.progressPct}%</div>
                    </div>
                    <div style={{ height: 8, background: brand.offWhite, borderRadius: 20, overflow: "hidden", marginBottom: 18 }}>
                      <div style={{ height: "100%", width: `${meta.progressPct}%`, background: `linear-gradient(90deg, ${meta.color}, ${meta.color}99)`, borderRadius: 20 }} />
                    </div>
                    <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(110px, 1fr))", gap: 10 }}>
                      {[
                        { label: "Books started", value: `${books.filter(b => b.status !== "not-started").length}/${books.length}` },
                        { label: "Books completed", value: `${books.filter(b => b.status === "done").length}/${books.length}` },
                        { label: "Study streak", value: `${meta.studyStreak} days 🔥` },
                      ].map((s) => (
                        <div key={s.label} style={{ padding: "12px", background: brand.offWhite, borderRadius: 11, textAlign: "center" as const }}>
                          <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 800, fontSize: 18, color: meta.color, marginBottom: 3 }}>{s.value}</div>
                          <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{s.label}</div>
                        </div>
                      ))}
                    </div>
                  </div>
                  {/* Per-book progress */}
                  <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "20px" }}>
                    <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em", marginBottom: 14 }}>Progress per book</div>
                    {books.map((book, i) => (
                      <div key={i} style={{ display: "flex", gap: 10, alignItems: "center", marginBottom: 10 }}>
                        <div style={{ width: 18, fontFamily: "Inter", fontWeight: 700, fontSize: 10, color: brand.warmGray, textAlign: "right" as const, flexShrink: 0 }}>{i + 1}.</div>
                        <div style={{ flex: 1, minWidth: 0 }}>
                          <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.charcoal, marginBottom: 3, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{book.name}</div>
                          <div style={{ height: 4, background: brand.offWhite, borderRadius: 10, overflow: "hidden" }}>
                            <div style={{ height: "100%", width: `${book.progress}%`, background: meta.color, borderRadius: 10 }} />
                          </div>
                        </div>
                        <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: statusColors[book.status], flexShrink: 0, width: 28, textAlign: "right" as const }}>{book.progress}%</div>
                      </div>
                    ))}
                  </div>
                </>
              )}
            </div>
          )}

          {/* STUDY PLAN TAB */}
          {activeTab === "plan" && (
            <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "24px" }}>
              <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 6 }}>Build your study plan</div>
              <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, marginBottom: 22, lineHeight: 1.65 }}>Tell us how much time you have and which books to prioritize — we'll build a daily plan across your chosen textbooks.</div>

              <div style={{ marginBottom: 18 }}>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal, marginBottom: 10 }}>Weekly study time</div>
                <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
                  {["Under 2 hours", "2–4 hours", "4–6 hours", "6–10 hours", "Custom"].map((opt) => (
                    <button key={opt} onClick={() => setStudyHours(opt)}
                      style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: studyHours === opt ? "#fff" : brand.charcoal, background: studyHours === opt ? gradientFlow : brand.offWhite, border: `1.5px solid ${studyHours === opt ? "transparent" : brand.borderGray}`, borderRadius: 20, padding: "7px 14px", cursor: "pointer" }}>
                      {opt}
                    </button>
                  ))}
                </div>
              </div>

              <div style={{ marginBottom: 22 }}>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal, marginBottom: 10 }}>Preferred study mode</div>
                <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
                  {["Read summaries", "Listen to voice notes", "Practice flashcards", "Mixed"].map((opt) => (
                    <button key={opt} onClick={() => setStudyPref(opt)}
                      style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: studyPref === opt ? "#fff" : brand.charcoal, background: studyPref === opt ? `linear-gradient(135deg, ${meta.color}, ${meta.color}CC)` : brand.offWhite, border: `1.5px solid ${studyPref === opt ? meta.color : brand.borderGray}`, borderRadius: 20, padding: "7px 14px", cursor: "pointer" }}>
                      {opt}
                    </button>
                  ))}
                </div>
              </div>

              <button disabled={!studyHours || !studyPref || isLocked}
                style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: studyHours && studyPref && !isLocked ? gradientFlow : brand.borderGray, border: "none", borderRadius: 12, padding: "13px 24px", cursor: studyHours && studyPref && !isLocked ? "pointer" : "not-allowed", marginBottom: 20 }}>
                {isLocked ? "Subscribe to Generate Your Plan" : "Generate My Study Plan →"}
              </button>

              {/* Sample plan preview */}
              {!isLocked && (
                <div style={{ background: brand.offWhite, borderRadius: 14, padding: "16px" }}>
                  <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em", marginBottom: 12 }}>Sample daily plan — Cohen's Pathways</div>
                  {[
                    { day: "Day 1", task: "Read Summary — Pulp Biology & Morphology", time: "25 min", icon: "📖" },
                    { day: "Day 2", task: "Listen to Voice Explanation — Pulp Biology", time: "18 min", icon: "🎧" },
                    { day: "Day 3", task: "Practice 40 flashcards from Module 1", time: "20 min", icon: "🃏" },
                    { day: "Day 4", task: "Read Summary — AAE Diagnosis Classification", time: "22 min", icon: "📖" },
                    { day: "Day 5", task: "Take Checkpoint Quiz — Module 1", time: "15 min", icon: "📝" },
                  ].map((task, i) => (
                    <div key={i} style={{ display: "flex", gap: 10, alignItems: "center", padding: "10px 0", borderBottom: i < 4 ? `1px solid ${brand.borderGray}` : "none" }}>
                      <span style={{ fontSize: 16, flexShrink: 0 }}>{task.icon}</span>
                      <div style={{ flex: 1 }}>
                        <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: meta.color }}>{task.day}: </span>
                        <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.charcoal }}>{task.task}</span>
                      </div>
                      <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, flexShrink: 0 }}>{task.time}</span>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}
        </div>

        {/* RIGHT SIDEBAR */}
        <div style={{ width: 230, flexShrink: 0 }}>
          <div style={{ position: "sticky", top: 90, display: "flex", flexDirection: "column" as const, gap: 14 }}>

            {/* CTA */}
            {!isSubscribed ? (
              <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "18px" }}>
                <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 15, color: brand.charcoal, marginBottom: 6, lineHeight: 1.3 }}>Unlock All {books.length} Books</div>
                <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, lineHeight: 1.6, marginBottom: 12 }}>Go through any textbook in any order. Summaries, voice notes, flashcards, and a daily plan — all included.</div>
                <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 800, fontSize: 20, color: meta.color, marginBottom: 12 }}>{meta.price}</div>
                <button onClick={() => nav("/checkout/subscription?plan=student-pass")}
                  style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "12px", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 7 }}>
                  <ZapIcon size={13} /> Unlock Companion
                </button>
                <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, textAlign: "center" as const, marginTop: 8 }}>Cancel anytime · No lock-in</div>
              </div>
            ) : (
              <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "18px" }}>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: "#2D9B68", marginBottom: 6 }}>✓ Full access — {books.length} books</div>
                <button onClick={() => setActiveTab("books")} style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff", background: `linear-gradient(135deg, ${meta.color}, ${meta.color}CC)`, border: "none", borderRadius: 12, padding: "11px", cursor: "pointer" }}>
                  Continue Studying →
                </button>
              </div>
            )}

            {/* Companion stats */}
            <div style={{ background: brand.white, borderRadius: 16, border: `1px solid ${brand.borderGray}`, padding: "16px" }}>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 10, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em", marginBottom: 10 }}>This companion</div>
              {[
                ["Textbooks covered", books.length],
                ["Total modules", meta.totalModules],
                ["Total voice", meta.totalAudio],
                ["Flashcards", meta.totalFlashcards.toLocaleString()],
                ["Quizzes", meta.totalQuizzes],
                ["Reviewed by", meta.reviewerName.split(",")[0]],
              ].map(([l, v]) => (
                <div key={l as string} style={{ display: "flex", justifyContent: "space-between", padding: "7px 0", borderBottom: `1px solid ${brand.borderGray}` }}>
                  <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{l as string}</span>
                  <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: brand.charcoal }}>{String(v)}</span>
                </div>
              ))}
            </div>

            <button onClick={() => nav("/library")} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: meta.color, background: `${meta.color}08`, border: "none", borderRadius: 12, padding: "11px", cursor: "pointer" }}>
              ← All Companions
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
