import { useState, useMemo } from "react";
import { useNavigate, useParams } from "react-router";
import {
  ChevronLeft, CheckCircle, Clock, ArrowRight,
  BookOpen, FileText, MapPin, DollarSign, Calendar,
  ExternalLink, AlertTriangle, Shield, Plane, BarChart2, X,
} from "lucide-react";
import { brand, gradientFlow, EG_DENTAL_UNIVERSITIES } from "@/figma/app/shared";

// Per-country recognition of Egyptian dental degrees
const COUNTRY_RECOGNITION: Record<string, { status: string; note: string }> = {
  "United Arab Emirates": { status: "✅ Accepted", note: "All Egyptian dental schools recognized by DHA/DOH/MOH." },
  "Saudi Arabia": { status: "✅ Accepted", note: "SCFHS accepts all Egyptian BDS degrees for exam eligibility." },
  "Qatar": { status: "✅ Accepted", note: "QCHP accepts all Egyptian BDS degrees." },
  "Kuwait": { status: "✅ Accepted", note: "MOH Kuwait accepts Egyptian BDS." },
  "Bahrain": { status: "✅ Accepted", note: "MOH Bahrain accepts Egyptian BDS." },
  "Oman": { status: "✅ Accepted", note: "MOH Oman accepts Egyptian BDS." },
  "Jordan": { status: "✅ Accepted (bilateral)", note: "Egypt–Jordan bilateral recognition. Direct JDA registration pathway." },
  "United Kingdom": { status: "⚠️ Conditionally", note: "Egyptian BDS accepted for GDC ORE eligibility. BUE & MIU may face additional scrutiny — verify with GDC." },
  "Ireland": { status: "⚠️ Conditionally", note: "Dental Council assesses each case. Most Egyptian schools accepted for RCSI exam eligibility." },
  "Australia": { status: "⚠️ Via ADC exam", note: "Egyptian BDS not directly recognized. Must pass ADC Written + Practical. All schools treated equally." },
  "New Zealand": { status: "⚠️ Via ADC exam", note: "Same as Australia — ADC pathway applies regardless of school." },
  "Canada": { status: "⚠️ Via NDEB", note: "NDEB accepts Egyptian BDS for equivalency process. School does not affect pathway significantly." },
  "Germany": { status: "⚠️ State-by-state", note: "Recognition varies by Bundesland. Most accept Egyptian BDS for Kenntnisprüfung pathway. Newer private unis may face extra scrutiny." },
  "Singapore": { status: "❌ Not on approved list", note: "Egyptian BDS schools not on SDC approved list. Must sit SDC Qualifying Exam regardless of university." },
  "United States": { status: "❌ Not recognized", note: "Egyptian BDS not recognized. Advanced Standing DDS program required at any US school." },
};

const COMPARISON_COUNTRIES = [
  { key: "uk", name: "UK 🇬🇧", timeline: "12–24 mo", difficulty: "High", salary: "£35–60K/yr", tier: "Via Exam" },
  { key: "uae", name: "UAE 🇦🇪", timeline: "3–6 mo", difficulty: "Medium", salary: "AED 12–25K/mo", tier: "Fast Track" },
  { key: "australia", name: "Australia 🇦🇺", timeline: "18–30 mo", difficulty: "High", salary: "AUD 85–150K/yr", tier: "Via Exam" },
  { key: "germany", name: "Germany 🇩🇪", timeline: "12–24 mo", difficulty: "High", salary: "€50–80K/yr", tier: "Lang+Exam" },
  { key: "canada", name: "Canada 🇨🇦", timeline: "24–36 mo", difficulty: "High", salary: "CAD 100–180K/yr", tier: "Via Exam" },
  { key: "ksa", name: "KSA 🇸🇦", timeline: "2–5 mo", difficulty: "Medium", salary: "SAR 12–30K/mo", tier: "Fast Track" },
];

function estimateLicensedDate(timeline: string, stepIndex: number, totalSteps: number): string {
  const m = timeline.match(/(\d+)[–\-](\d+)/);
  if (!m) return "";
  const avgMonths = (parseInt(m[1]) + parseInt(m[2])) / 2;
  const fraction = (stepIndex + 1) / totalSteps;
  const months = Math.round(avgMonths * fraction);
  const date = new Date();
  date.setMonth(date.getMonth() + months);
  return date.toLocaleDateString("en-US", { month: "short", year: "numeric" });
}

function toUSD(cost: string): string {
  const rates: Record<string, number> = {
    "£": 1.27, "€": 1.09, "AUD": 0.66, "NZD": 0.61, "CAD": 0.74,
    "SGD": 0.74, "AED": 0.27, "CHF": 1.12, "MYR": 0.22, "THB": 0.028,
    "ZAR": 0.055, "RM": 0.22,
  };
  if (/^\$/.test(cost) || /^USD/.test(cost)) return "";
  for (const [sym, rate] of Object.entries(rates)) {
    const re = new RegExp(`${sym.replace(".", "\\.")}\\s*([\\d,]+)`);
    const m = cost.match(re);
    if (m) {
      const num = parseFloat(m[1].replace(/,/g, ""));
      if (isNaN(num)) continue;
      const usd = Math.round((num * rate) / 10) * 10;
      return `≈ $${usd.toLocaleString()}`;
    }
  }
  return "";
}

const recognitionBg: Record<string, string> = {
  "Fast Track": "rgba(45,155,104,0.12)",
  "Via Licensing Exam": `${brand.amber}18`,
  "Language + Exam": `${brand.orange}12`,
  "Complex Pathway": `${brand.red}10`,
};
const recognitionFg: Record<string, string> = {
  "Fast Track": "#2D9B68",
  "Via Licensing Exam": brand.amber,
  "Language + Exam": brand.orange,
  "Complex Pathway": brand.red,
};

const countryData: Record<string, any> = {
  uk: {
    name: "United Kingdom", flag: "🇬🇧", exam: "ORE (Overseas Registration Exam)",
    authority: "General Dental Council (GDC)", website: "gdc-uk.org",
    timeline: "12–24 months", difficulty: "High", marketDemand: "Strong",
    avgSalary: "£35,000–£60,000 / year (associate)", currency: "GBP",
    language: "IELTS Academic 7.0+ overall (no band < 6.5) or OET Grade B",
    egyptianRecognition: "Via Licensing Exam",
    recognitionNote: "Egyptian BDS degree is accepted for ORE eligibility. You must pass both ORE parts before GDC registration — there is no direct recognition pathway.",
    visaCategory: "Skilled Worker visa (employer sponsors) or Self-sponsored Skilled Worker",
    lastUpdated: "July 2025",
    overview: "The UK pathway requires passing the GDC's Overseas Registration Exam (ORE) — two parts covering written theory and clinical/OSCE stations. Once registered, dentists typically work as associates in NHS or private practices.",
    steps: [
      { n: "1", title: "Language Proficiency", desc: "Pass IELTS Academic (overall 7.0, no band below 6.5) or OET (Grade B in all components). Results valid 2 years.", required: true },
      { n: "2", title: "GDC Eligibility Check", desc: "Submit your dental degree for GDC eligibility assessment. Processing 4–8 weeks. Fee: £105.", required: true },
      { n: "3", title: "ORE Part 1 (Written)", desc: "Two papers: Dental Materials & Human Disease + Clinical Dentistry. 100 MCQs each. Pass mark ~55%. Offered 3×/year.", required: true },
      { n: "4", title: "ORE Part 2 (OSCE + Clinical)", desc: "Clinical examination and OSCE stations at a GDC-approved centre. Tests clinical skills, patient management, and ethics.", required: true },
      { n: "5", title: "GDC Full Registration", desc: "Apply with certificates, proof of ID, and payment (£743). Processing 4–6 weeks. Annual retention fee: £743.", required: true },
      { n: "6", title: "Professional Indemnity", desc: "Obtain indemnity from MDU, MPS, or MDDUS before seeing patients. Annual cost: ~£1,500–£3,000.", required: true },
      { n: "7", title: "Associate Position", desc: "Apply for associate roles. NHS contracts use Units of Dental Activity (UDAs). Private work pays 45–50% of gross fee.", required: false },
    ],
    exams: [
      { name: "ORE Part 1", desc: "Written: Dental Materials & Human Disease + Clinical Dentistry", timing: "3 dates/year: Mar, Jun, Oct", fee: "£570", passMark: "~55%" },
      { name: "ORE Part 2", desc: "Clinical OSCE stations — patient management, clinical skills, ethics", timing: "After passing Part 1", fee: "£1,045", passMark: "Component-based" },
    ],
    documents: [
      "Dental degree (original + certified translation)",
      "Transcript of clinical hours",
      "Good Standing Letter from Egyptian Dental Syndicate",
      "Passport copy",
      "Language test certificate (IELTS/OET)",
      "2 professional references",
    ],
    costs: [
      { item: "GDC Eligibility Assessment", cost: "£105" },
      { item: "ORE Part 1 (per attempt)", cost: "£570" },
      { item: "ORE Part 2 (per attempt)", cost: "£1,045" },
      { item: "GDC Registration", cost: "£743" },
      { item: "Language Test (IELTS)", cost: "~£180" },
      { item: "Professional Indemnity (year 1)", cost: "~£1,500" },
    ],
    tips: [
      "Start ORE Part 1 preparation 6–9 months before your target date",
      "Ejadah's ORE question bank has 6,200+ questions with exam-format explanations",
      "The LDS RCS (Licentiate in Dental Surgery) via the Royal Colleges is a recognised alternative pathway",
      "GDC graduates of any approved UK dental school are exempt from ORE — relevant if you pursued a UK Masters",
    ],
  },

  uae: {
    name: "United Arab Emirates", flag: "🇦🇪", exam: "DHA / DOH / MOH Prometric",
    authority: "Dubai Health Authority / Dept. of Health Abu Dhabi / MOH", website: "dha.gov.ae",
    timeline: "3–6 months", difficulty: "Medium", marketDemand: "Very Strong",
    avgSalary: "AED 12,000–25,000 / month", currency: "AED",
    language: "English proficiency (no formal test required for most dentists)",
    egyptianRecognition: "Via Licensing Exam",
    recognitionNote: "Egyptian BDS is widely accepted. DataFlow verification is required. Prometric CBT is straightforward and can be prepared in 6–10 weeks. This is the most popular first international step for Egyptian dentists.",
    visaCategory: "Employment visa sponsored by the hiring dental facility",
    lastUpdated: "July 2025",
    overview: "The UAE offers multiple regulatory pathways depending on the emirate. DHA licenses dentists for Dubai, DOH for Abu Dhabi, MOH for other emirates. All use Prometric CBT exams and accept Egyptian BDS degrees.",
    steps: [
      { n: "1", title: "Choose Your Emirate", desc: "Dubai (DHA), Abu Dhabi (DOH), or other emirates (MOH). Each authority requires separate licensing.", required: true },
      { n: "2", title: "Primary Source Verification", desc: "Degree verified through DataFlow Group. Cost: ~$140–200. Takes 4–8 weeks.", required: true },
      { n: "3", title: "Prometric Exam Registration", desc: "Register on the Prometric portal. Subjects: Dentistry, Ethics, UAE health law.", required: true },
      { n: "4", title: "Pass the CBT Exam", desc: "Computer-based test. Pass mark: ~60–65%. Multiple attempts allowed.", required: true },
      { n: "5", title: "License Application", desc: "Submit documents and exam certificate to the relevant authority. Processing: 2–6 weeks.", required: true },
      { n: "6", title: "Job Offer & Visa", desc: "Secure a position at a licensed UAE dental facility. Employer processes work visa and Emirates ID.", required: false },
    ],
    exams: [
      { name: "DHA Dental Exam", desc: "100 MCQs covering general dentistry, ethics, and UAE health regulations", timing: "Year-round at Prometric centres", fee: "$115", passMark: "~60%" },
      { name: "DOH Dental Exam", desc: "Similar to DHA — dental sciences and DOH-specific regulations", timing: "Year-round", fee: "$100", passMark: "~65%" },
    ],
    documents: [
      "Dental degree (DataFlow verified)",
      "Good Standing Certificate from Egyptian Dental Syndicate",
      "Passport copy",
      "Personal photo (white background)",
      "Work experience certificate(s)",
      "Medical fitness certificate",
    ],
    costs: [
      { item: "DataFlow Verification", cost: "$140–200" },
      { item: "Prometric Exam Fee", cost: "$100–115" },
      { item: "License Application Fee", cost: "AED 500–1,500" },
      { item: "Emirates ID Fee", cost: "AED 100–300" },
    ],
    tips: [
      "UAE Prometric is significantly more accessible than European pathways — prepare with 6–10 weeks of focused study",
      "DHA license is Dubai-only — you need DOH separately for Abu Dhabi",
      "Many Egyptian dentists use UAE as a stepping stone before attempting UK or Australia",
      "Ejadah's Prometric question bank has 9,000+ DHA/DOH/MOH questions",
    ],
  },

  australia: {
    name: "Australia", flag: "🇦🇺", exam: "ADC (Australian Dental Council) Examination",
    authority: "Dental Board of Australia / AHPRA", website: "dentalboard.gov.au",
    timeline: "18–30 months", difficulty: "High", marketDemand: "Strong",
    avgSalary: "AUD 85,000–150,000 / year", currency: "AUD",
    language: "IELTS Academic 7.0 (no band < 7.0) or OET Grade B in all four components",
    egyptianRecognition: "Via Licensing Exam",
    recognitionNote: "Egyptian BDS degree is not directly recognised. Candidates must pass the ADC Exam (two parts: Written + Practical), which is considered one of the world's most rigorous dental licensing pathways. Success rate is ~55% for written and ~65% for practical.",
    visaCategory: "Skilled Nominated visa (subclass 190) or Employer Sponsored (482/186). Dentistry is on the skilled occupation list.",
    lastUpdated: "July 2025",
    overview: "Australia requires passing the ADC Examination — a two-stage process including a written component and a practical clinical examination. Both are highly competitive. Registration with AHPRA follows successful completion.",
    steps: [
      { n: "1", title: "Language Proficiency", desc: "IELTS 7.0 in all four bands or OET Grade B. Australia has stricter band requirements than the UK.", required: true },
      { n: "2", title: "ADC Application & Eligibility", desc: "Submit your degree and transcripts to the ADC for eligibility assessment. Fee: AUD 800. Takes 8–12 weeks.", required: true },
      { n: "3", title: "ADC Written Exam", desc: "MCQ-based exam covering all dental sciences and clinical knowledge. Offered twice per year. Fee: AUD 1,850.", required: true },
      { n: "4", title: "ADC Practical Examination", desc: "Clinical OSCE at an ADC-approved site in Australia. Covers restorative, endo, perio, ortho, and patient management. Fee: AUD 4,500.", required: true },
      { n: "5", title: "AHPRA Registration", desc: "Register with the Australian Health Practitioner Regulation Agency. Annual fee: AUD 375.", required: true },
      { n: "6", title: "Skilled Visa Application", desc: "Apply for a Skilled Nominated, Employer Sponsored, or State-nominated visa. Dentistry is on the MLTSSL.", required: false },
      { n: "7", title: "Employment", desc: "Work as an associate in private practice, community dental clinic, or government service.", required: false },
    ],
    exams: [
      { name: "ADC Written Exam", desc: "MCQs across all dental science and clinical areas. Offered Feb and Aug.", timing: "February & August", fee: "AUD 1,850", passMark: "~55%" },
      { name: "ADC Practical Examination", desc: "Clinical OSCE — restorative, endo, perio, prosthodontics, ortho, patient management", timing: "Once per year", fee: "AUD 4,500", passMark: "Component-based" },
    ],
    documents: [
      "Dental degree and academic transcripts",
      "Good Standing Certificate from Egyptian Dental Syndicate",
      "Certified English translations of all documents",
      "Passport copy",
      "IELTS/OET certificate",
      "Evidence of clinical experience (if applicable)",
    ],
    costs: [
      { item: "ADC Eligibility Assessment", cost: "AUD 800" },
      { item: "ADC Written Exam (per attempt)", cost: "AUD 1,850" },
      { item: "ADC Practical Exam (per attempt)", cost: "AUD 4,500" },
      { item: "AHPRA Annual Registration", cost: "AUD 375/year" },
      { item: "Language Test (IELTS)", cost: "~AUD 380" },
    ],
    tips: [
      "The ADC practical exam requires you to travel to Australia — budget for flights, accommodation, and living costs during the exam period",
      "Most candidates take 12–18 months to prepare for the written exam — join a structured ADC prep group",
      "Dentistry is on Australia's Medium and Long-term Strategic Skills List (MLTSSL) — strong migration prospects",
      "Some candidates work in New Zealand first to build savings before attempting the ADC",
    ],
  },

  canada: {
    name: "Canada", flag: "🇨🇦", exam: "NDEB (National Dental Examining Board of Canada)",
    authority: "NDEB / Provincial Dental Regulatory Authorities", website: "ndeb.ca",
    timeline: "24–36 months", difficulty: "High", marketDemand: "Strong",
    avgSalary: "CAD 100,000–180,000 / year", currency: "CAD",
    language: "IELTS 7.0+ or French equivalent (Quebec requires French)",
    egyptianRecognition: "Via Licensing Exam",
    recognitionNote: "Egyptian BDS is accepted by NDEB for the equivalency process. Most international dentists must complete the NDEB's Assessment of Fundamental Knowledge (AFK), Written Examination, and Objective Structured Clinical Examination (OSCE). Some candidates are directed to a bridging program at a Canadian dental school.",
    visaCategory: "Express Entry (Canadian Experience Class / Federal Skilled Worker) or Provincial Nominee Program (PNP). Dentistry is NOC 31110.",
    lastUpdated: "July 2025",
    overview: "Canada uses a multi-step NDEB equivalency process for internationally trained dentists. The pathway is rigorous but leads to one of the highest-paying dental markets globally. Provincial regulatory bodies issue the actual license after NDEB success.",
    steps: [
      { n: "1", title: "NDEB Application & Credential Review", desc: "Submit degree and transcripts to NDEB. They determine which assessment pathway applies to you.", required: true },
      { n: "2", title: "Assessment of Fundamental Knowledge (AFK)", desc: "150-question MCQ exam covering dental sciences. Pass mark ~70%. Multiple attempts allowed.", required: true },
      { n: "3", title: "NDEB Written Examination", desc: "200-question MCQ exam on clinical dentistry and patient management. More clinically focused than AFK.", required: true },
      { n: "4", title: "NDEB OSCE", desc: "Objective Structured Clinical Examination. Practical stations assessing clinical competence.", required: true },
      { n: "5", title: "Provincial License Application", desc: "Apply to the provincial regulatory authority (e.g., RCDSO in Ontario, CDSBC in BC). Each has its own requirements.", required: true },
      { n: "6", title: "Immigration Pathway", desc: "Apply via Express Entry or a Provincial Nominee Program. Having a job offer significantly improves your score.", required: false },
    ],
    exams: [
      { name: "NDEB AFK", desc: "150 MCQs on dental sciences — anatomy, physiology, pathology, pharmacology", timing: "Multiple dates per year", fee: "CAD 400", passMark: "~70%" },
      { name: "NDEB Written Exam", desc: "200 MCQs on clinical dentistry and patient management", timing: "Multiple dates per year", fee: "CAD 600", passMark: "~70%" },
      { name: "NDEB OSCE", desc: "Practical OSCE stations assessing clinical competence", timing: "Twice per year", fee: "CAD 1,800", passMark: "Component-based" },
    ],
    documents: [
      "Dental degree and notarised transcripts",
      "Good Standing Certificate from Egyptian Dental Syndicate",
      "Certified translations of all Arabic documents",
      "Passport copy",
      "IELTS/language certificate",
      "2 professional references",
    ],
    costs: [
      { item: "NDEB Application & Assessment", cost: "CAD 500" },
      { item: "NDEB AFK (per attempt)", cost: "CAD 400" },
      { item: "NDEB Written Exam (per attempt)", cost: "CAD 600" },
      { item: "NDEB OSCE (per attempt)", cost: "CAD 1,800" },
      { item: "Provincial License Fee", cost: "CAD 500–1,000" },
    ],
    tips: [
      "Ontario (Toronto) and British Columbia (Vancouver) have the highest demand for dentists",
      "Some NDEB candidates are directed to a 2-year bridging program at a Canadian dental school — this adds significant time and cost",
      "Quebec requires French proficiency — consider other provinces if you're not a French speaker",
      "Canadian dentists earn among the highest salaries globally — the long pathway is considered worthwhile by most who complete it",
    ],
  },

  usa: {
    name: "United States", flag: "🇺🇸", exam: "INBDE + State Dental Board Licensing",
    authority: "State Dental Boards / CODA", website: "ada.org",
    timeline: "24–48 months", difficulty: "Very High", marketDemand: "Selective",
    avgSalary: "USD 130,000–250,000 / year", currency: "USD",
    language: "TOEFL iBT 100+ or IELTS 7.0 (varies by dental school/state)",
    egyptianRecognition: "Complex Pathway",
    recognitionNote: "Egyptian BDS is not directly recognised. Most international dentists must complete a 2-year CODA-accredited Advanced Standing DDS/DMD program at a US dental school (highly competitive, ~USD 120,000–180,000 tuition). A few states allow alternative pathways via state board exams only.",
    visaCategory: "F-1 (student visa for dental school), then H-1B or O-1 for employment. Green card via EB-2/EB-3.",
    lastUpdated: "July 2025",
    overview: "The USA is the hardest and most expensive pathway for international dentists, but offers the highest earning potential. Most candidates enrol in a 2-year Advanced Standing DDS program at an accredited dental school before sitting state licensing exams.",
    steps: [
      { n: "1", title: "INBDE (Integrated National Board Dental Examination)", desc: "The new national board exam. Required by most states. Covers all dental sciences and clinical knowledge.", required: true },
      { n: "2", title: "Advanced Standing DDS Program", desc: "Apply to 2-year CODA-accredited DDS/DMD programs. Only ~20 schools offer this. Acceptance rate: 3–10%. Tuition: ~USD 150,000 total.", required: true },
      { n: "3", title: "State Clinical Board Examination", desc: "After dental school, sit the relevant state board clinical exam. Most states now accept CDCA (regional board).", required: true },
      { n: "4", title: "State License Application", desc: "Apply to the dental board of the state where you intend to practice. Requirements vary by state.", required: true },
      { n: "5", title: "Malpractice Insurance", desc: "Obtain professional liability insurance before treating patients. Annual cost: ~USD 3,000–8,000.", required: true },
      { n: "6", title: "Employment / Practice Ownership", desc: "Work as an associate in a private practice, DSO, or community health centre, or open your own practice.", required: false },
    ],
    exams: [
      { name: "INBDE", desc: "Integrated National Board Dental Examination — two-day computer-based exam covering all dental sciences", timing: "Multiple times per year at Prometric centres", fee: "USD 515", passMark: "~75 scaled score" },
      { name: "State Clinical Board (CDCA/WREB)", desc: "Clinical competency examination — patient-based or simulation-based depending on state", timing: "Multiple times per year", fee: "USD 700–1,500", passMark: "State-dependent" },
    ],
    documents: [
      "Dental degree (with NACES/WES credential evaluation)",
      "Academic transcripts",
      "TOEFL/IELTS certificate",
      "INBDE score report",
      "Dental school diploma (US DDS/DMD after Advanced Standing program)",
      "State-specific application forms and background check",
    ],
    costs: [
      { item: "WES/NACES Credential Evaluation", cost: "USD 200–350" },
      { item: "Advanced Standing DDS Program (total)", cost: "USD 120,000–180,000" },
      { item: "INBDE Exam Fee", cost: "USD 515" },
      { item: "State Clinical Board Exam", cost: "USD 700–1,500" },
      { item: "State License Application", cost: "USD 200–600" },
      { item: "Malpractice Insurance (year 1)", cost: "~USD 4,000" },
    ],
    tips: [
      "Target dental schools known for strong Advanced Standing programs: NYU, Nova Southeastern, USC, Midwestern, Roseman",
      "Your GPA, TOEFL, and evidence of US clinical exposure are key selection factors for Advanced Standing programs",
      "Some Egyptian dentists pursue a US Masters first to build US academic credentials before applying for Advanced Standing",
      "The investment is substantial but US dentists earn significantly more than any other English-speaking country",
    ],
  },

  germany: {
    name: "Germany", flag: "🇩🇪", exam: "Approbation (Kenntnisprüfung if required)",
    authority: "State Health Authorities (Landesgesundheitsämter)", website: "bzaek.de",
    timeline: "12–24 months", difficulty: "High", marketDemand: "Very Strong (dentist shortage)",
    avgSalary: "€50,000–80,000 / year", currency: "EUR",
    language: "German B2 mandatory (C1 strongly recommended for clinical work)",
    egyptianRecognition: "Language + Exam",
    recognitionNote: "Egyptian BDS is assessed state-by-state (Bundesland). Most states require a Kenntnisprüfung (knowledge examination) plus German language proficiency. Some states offer direct Approbation if the degree is deemed equivalent, but this is rare for non-EU dentists.",
    visaCategory: "Job Seeker Visa (6 months to find a job), then Skilled Worker Visa (Blue Card). Dentists qualify for the EU Blue Card.",
    lastUpdated: "July 2025",
    overview: "Germany has a significant dentist shortage and actively recruits internationally trained dentists. The main barrier is German language proficiency. Once qualified, Germany offers excellent working conditions, strong salaries, and a pathway to EU permanent residence.",
    steps: [
      { n: "1", title: "German Language — B2 Level", desc: "Enrol in a German language course and achieve B2 (Goethe-Institut or TestDaF). C1 is required before starting clinical work in most states.", required: true },
      { n: "2", title: "Credential Recognition Application", desc: "Apply to the relevant state health authority (e.g., Regierung von Oberbayern in Bavaria). Submit degree, transcripts, and translations.", required: true },
      { n: "3", title: "Kenntnisprüfung (if required)", desc: "A knowledge examination covering dentistry and German dental law. Not all states require it — depends on assessment.", required: true },
      { n: "4", title: "Berufserlaubnis (Provisional Licence)", desc: "Obtain a provisional licence to work under supervision while language skills are assessed.", required: false },
      { n: "5", title: "German Language — C1 Fachsprache", desc: "Pass the medical German language examination (Fachsprachenprüfung) administered by the state dental chamber.", required: true },
      { n: "6", title: "Approbation (Full Licence)", desc: "Receive the Approbation — the permanent licence to practise dentistry independently in Germany.", required: true },
      { n: "7", title: "Employment", desc: "Work as an Assistenzzahnarzt (associate) or open your own Zahnarztpraxis. Self-employment is very common in Germany.", required: false },
    ],
    exams: [
      { name: "Kenntnisprüfung", desc: "State-level dental knowledge exam — may include written MCQs, viva, and practical components depending on the state", timing: "Varies by state (typically 1–3× per year)", fee: "€200–600", passMark: "State-dependent" },
      { name: "Fachsprachenprüfung (Medical German)", desc: "Medical German language examination — practical assessment of patient communication, documentation, and terminology", timing: "Varies by state dental chamber", fee: "€100–300", passMark: "Pass/Fail" },
    ],
    documents: [
      "Dental degree (Apostilled + certified German translation)",
      "Academic transcripts (with German translation)",
      "Good Standing Certificate from Egyptian Dental Syndicate (translated)",
      "German language certificate (B2 minimum)",
      "Passport copy",
      "Curriculum Vitae (in German)",
    ],
    costs: [
      { item: "German Language Courses (B2→C1)", cost: "€1,500–4,000" },
      { item: "Credential Recognition Fee", cost: "€200–500" },
      { item: "Kenntnisprüfung (per attempt)", cost: "€200–600" },
      { item: "Document translation & Apostille", cost: "€300–800" },
      { item: "Fachsprachenprüfung", cost: "€100–300" },
    ],
    tips: [
      "Bavaria and Baden-Württemberg have the most streamlined pathways for non-EU dentists",
      "Many German dental clinics will sponsor your visa and help with the recognition process if you demonstrate German proficiency",
      "The Goethe-Institut has centres in Cairo — start German lessons early, before you leave Egypt",
      "DAAD scholarships are available for Egyptian dentists pursuing postgraduate qualifications in Germany — check daad.de",
    ],
  },

  ireland: {
    name: "Ireland", flag: "🇮🇪", exam: "RCSI Qualifying Examination or IDA Pathway",
    authority: "Dental Council of Ireland", website: "dentalcouncil.ie",
    timeline: "6–18 months", difficulty: "Medium", marketDemand: "Growing",
    avgSalary: "€55,000–85,000 / year", currency: "EUR",
    language: "IELTS Academic 7.0+ or OET Grade B",
    egyptianRecognition: "Via Licensing Exam",
    recognitionNote: "Egyptian BDS is assessed by the Dental Council. Most non-EU/EEA dentists must sit the RCSI qualifying examination. Ireland's pathway is considered slightly easier than the UK ORE, and registration in Ireland also facilitates recognition in other EU states.",
    visaCategory: "Employment Permit (Critical Skills Employment Permit — dentistry is on the critical skills list)",
    lastUpdated: "July 2025",
    overview: "Ireland faces a significant dental workforce shortage, making it one of the more accessible European pathways. The Dental Council assesses international qualifications and may require the RCSI qualifying exam. Successful candidates join the Dental Register and can work in HSE clinics or private practice.",
    steps: [
      { n: "1", title: "Language Proficiency", desc: "IELTS Academic 7.0 (no band below 6.5) or OET Grade B. Certificate valid 2 years.", required: true },
      { n: "2", title: "Dental Council Application", desc: "Apply to the Dental Council of Ireland for qualification assessment. Processing: 6–12 weeks.", required: true },
      { n: "3", title: "RCSI Qualifying Exam (if directed)", desc: "Examination run by the Royal College of Surgeons in Ireland. Covers dental sciences and clinical practice.", required: true },
      { n: "4", title: "Dental Register Admission", desc: "Upon successful completion, you're admitted to the Dental Register. Annual retention fee applies.", required: true },
      { n: "5", title: "Employment & Visa", desc: "Obtain a job offer and apply for a Critical Skills Employment Permit (dentistry is on the critical skills list).", required: false },
    ],
    exams: [
      { name: "RCSI Qualifying Examination", desc: "Written and practical components covering dental sciences and clinical dentistry", timing: "Once or twice per year", fee: "€800–1,200", passMark: "~60%" },
    ],
    documents: [
      "Dental degree (original + certified translation if in Arabic)",
      "Transcripts of clinical training",
      "Good Standing Letter from Egyptian Dental Syndicate",
      "Passport copy",
      "IELTS/OET certificate",
      "2 references from dental supervisors",
    ],
    costs: [
      { item: "Dental Council Assessment Fee", cost: "€500" },
      { item: "RCSI Qualifying Exam (per attempt)", cost: "€800–1,200" },
      { item: "Dental Register Annual Fee", cost: "€600" },
      { item: "Language Test (IELTS)", cost: "~€250" },
    ],
    tips: [
      "Ireland is an excellent stepping stone — EU registration in Ireland facilitates mutual recognition across EU states",
      "HSE (Health Service Executive) often sponsors international dentists for the Critical Skills permit",
      "Dublin, Cork, and Galway have high demand for associate dentists",
      "Ejadah's ORE preparation materials are highly relevant for the RCSI qualifying exam",
    ],
  },

  ksa: {
    name: "Saudi Arabia", flag: "🇸🇦", exam: "MOH / SLE (Saudi Licensing Exam) — Prometric",
    authority: "Saudi Commission for Health Specialties (SCFHS) / Ministry of Health", website: "scfhs.org.sa",
    timeline: "2–5 months", difficulty: "Medium", marketDemand: "Very Strong",
    avgSalary: "SAR 12,000–30,000 / month (tax-free)", currency: "SAR",
    language: "Arabic (official language) — English widely used in clinical settings",
    egyptianRecognition: "Fast Track",
    recognitionNote: "Egyptian BDS degree is highly respected in Saudi Arabia and directly recognised by SCFHS for licensing eligibility. The Prometric SLE is straightforward and the Egyptian dental curriculum aligns closely with Saudi requirements.",
    visaCategory: "Work visa sponsored by employer (hospital, clinic, or private group). Iqama (residency permit) follows.",
    lastUpdated: "July 2025",
    overview: "Saudi Arabia is the largest and highest-paying Gulf market for Egyptian dentists. The SCFHS oversees licensing via the Saudi Licensing Exam (Prometric CBT). Egyptian BDS is accepted, and the process from application to license can be completed in 2–5 months.",
    steps: [
      { n: "1", title: "SCFHS Registration & Credential Verification", desc: "Create account on scfhs.org.sa. Submit your degree for DataFlow/primary source verification. Takes 4–6 weeks.", required: true },
      { n: "2", title: "Saudi Licensing Exam (SLE)", desc: "Prometric CBT covering dentistry, ethics, and Saudi health law. 150 MCQs. Pass mark ~60%.", required: true },
      { n: "3", title: "License Issuance", desc: "SCFHS issues your Saudi dental license upon passing the exam. The license is valid for 2–3 years and renewable.", required: true },
      { n: "4", title: "Job Offer & Contract", desc: "Secure a position with a Saudi hospital, polyclinic, or private dental group. Negotiate tax-free salary + benefits.", required: false },
      { n: "5", title: "Work Visa & Iqama", desc: "Employer processes your work visa and Iqama (residency permit). Family visas can follow.", required: false },
    ],
    exams: [
      { name: "Saudi Licensing Exam (SLE)", desc: "150 MCQs covering dentistry, ethics, and Saudi health regulations", timing: "Year-round at Prometric centres in Egypt and Saudi Arabia", fee: "$100–150", passMark: "~60%" },
    ],
    documents: [
      "Dental degree (DataFlow verified)",
      "Good Standing Certificate from Egyptian Dental Syndicate",
      "Passport copy",
      "Personal photo",
      "Work experience certificates",
      "Medical fitness certificate",
    ],
    costs: [
      { item: "DataFlow Verification", cost: "$140–200" },
      { item: "SLE Exam Fee", cost: "$100–150" },
      { item: "SCFHS License Fee", cost: "SAR 500–1,000" },
    ],
    tips: [
      "Riyadh, Jeddah, and Khobar offer the highest concentrations of private dental groups",
      "Saudi Arabia offers tax-free salaries plus housing, transportation, and flight allowances in many contracts",
      "Arabic language proficiency gives you a strong advantage — most patients prefer Arabic-speaking dentists",
      "Ejadah's Prometric question bank covers SLE-specific content with Saudi health regulation questions",
    ],
  },

  qatar: {
    name: "Qatar", flag: "🇶🇦", exam: "QCHP (Qatar Council for Healthcare Practitioners) Prometric",
    authority: "Qatar Council for Healthcare Practitioners (QCHP)", website: "qchp.org.qa",
    timeline: "2–4 months", difficulty: "Medium", marketDemand: "Strong",
    avgSalary: "QAR 10,000–22,000 / month (tax-free)", currency: "QAR",
    language: "Arabic (official) — English widely used. No formal test usually required.",
    egyptianRecognition: "Fast Track",
    recognitionNote: "Egyptian BDS is recognised by QCHP. Dataflow verification and Prometric CBT are the main requirements. Qatar has a small but well-paying dental market, particularly in Doha's private sector.",
    visaCategory: "Work visa sponsored by Qatari employer. Qatar ID (QID) follows.",
    lastUpdated: "July 2025",
    overview: "Qatar uses the QCHP to regulate all healthcare professionals. Egyptian dentists follow a streamlined Prometric pathway. The market is smaller than UAE/KSA but offers excellent salaries and a very high standard of living.",
    steps: [
      { n: "1", title: "DataFlow Primary Source Verification", desc: "Submit degree to DataFlow Group for PSV. Takes 4–8 weeks. Cost: ~$150.", required: true },
      { n: "2", title: "QCHP Prometric Exam", desc: "CBT covering dentistry and Qatar health law. Pass mark ~60–65%. Year-round at Prometric centres.", required: true },
      { n: "3", title: "QCHP License Application", desc: "Submit documents, exam certificate, and application. License issued within 2–4 weeks.", required: true },
      { n: "4", title: "Job Offer & Visa", desc: "Secure a position at a QCHP-licensed facility. Employer sponsors work visa and QID.", required: false },
    ],
    exams: [
      { name: "QCHP Prometric Dental Exam", desc: "100–150 MCQs on general dentistry, ethics, and Qatar health regulations", timing: "Year-round at Prometric centres", fee: "$100–120", passMark: "~60–65%" },
    ],
    documents: [
      "Dental degree (DataFlow verified)",
      "Good Standing Certificate from Egyptian Dental Syndicate",
      "Passport copy",
      "Work experience certificates",
      "Medical fitness certificate",
    ],
    costs: [
      { item: "DataFlow Verification", cost: "$150" },
      { item: "QCHP Prometric Exam", cost: "$100–120" },
      { item: "QCHP License Fee", cost: "QAR 500–1,000" },
    ],
    tips: [
      "Doha's private dental market is competitive but pays extremely well for experienced dentists",
      "Qatar's cost of living is high — negotiate housing and transport allowances into your contract",
      "QCHP license holders can explore Bahrain and Oman mutual recognition in some cases",
      "Hamad Medical Corporation is the main public employer — competitive but offers excellent career development",
    ],
  },

  kuwait: {
    name: "Kuwait", flag: "🇰🇼", exam: "MOH Kuwait Prometric",
    authority: "Ministry of Health Kuwait", website: "moh.gov.kw",
    timeline: "3–6 months", difficulty: "Medium", marketDemand: "Strong",
    avgSalary: "KWD 600–1,400 / month (tax-free)", currency: "KWD",
    language: "Arabic (official) — English widely used in dental clinics",
    egyptianRecognition: "Fast Track",
    recognitionNote: "Egyptian BDS is recognised by Kuwait MOH. The Prometric pathway is straightforward. Kuwait has a significant expatriate dental community, with Egyptian dentists well-represented in both public and private sectors.",
    visaCategory: "Work visa sponsored by Kuwaiti employer. Civil ID follows.",
    lastUpdated: "July 2025",
    overview: "Kuwait MOH licenses international dentists through a Prometric CBT examination. Egyptian dentists are well-regarded in Kuwait's healthcare system. Public sector positions offer generous government benefits.",
    steps: [
      { n: "1", title: "DataFlow / MOH Credential Verification", desc: "Submit degree for primary source verification. Takes 4–8 weeks.", required: true },
      { n: "2", title: "MOH Kuwait Prometric Exam", desc: "CBT covering dentistry and Kuwait health regulations. 100–150 MCQs. Pass mark ~60%.", required: true },
      { n: "3", title: "MOH License Application", desc: "Submit exam results and documents to MOH Kuwait. Processing: 2–4 weeks.", required: true },
      { n: "4", title: "Job Offer, Visa & Civil ID", desc: "Secure a position in a licensed facility. Employer processes work visa and Civil ID.", required: false },
    ],
    exams: [
      { name: "MOH Kuwait Prometric Exam", desc: "100–150 MCQs on general dentistry, ethics, and Kuwait health regulations", timing: "Year-round at Prometric centres", fee: "$100–120", passMark: "~60%" },
    ],
    documents: [
      "Dental degree (DataFlow verified)",
      "Good Standing Certificate from Egyptian Dental Syndicate",
      "Passport copy",
      "Work experience certificates",
      "Medical fitness certificate",
    ],
    costs: [
      { item: "DataFlow Verification", cost: "$140–200" },
      { item: "Prometric Exam Fee", cost: "$100–120" },
      { item: "MOH License Fee", cost: "KWD 50–100" },
    ],
    tips: [
      "Kuwait's public sector dental positions come with government pay scales that can be very competitive",
      "Private dental groups (IbnSina, Al-Seef) offer flexible contracts with good salaries",
      "Ejadah's Gulf Prometric question bank is directly applicable to Kuwait MOH content",
      "Many Egyptian dentists work in Kuwait for 3–5 years before moving to UAE or KSA for higher earning potential",
    ],
  },

  oman: {
    name: "Oman", flag: "🇴🇲", exam: "OMSB / Oman MOH Prometric",
    authority: "Oman Medical Specialty Board (OMSB) / Ministry of Health Oman", website: "omsb.org",
    timeline: "3–6 months", difficulty: "Medium", marketDemand: "Moderate",
    avgSalary: "OMR 500–1,000 / month (tax-free)", currency: "OMR",
    language: "Arabic (official) — English used in many clinical settings",
    egyptianRecognition: "Fast Track",
    recognitionNote: "Egyptian BDS is recognised by Oman MOH and OMSB. The Prometric exam pathway is standard. Oman is a quieter market than UAE/KSA but offers a high quality of life and tax-free income.",
    visaCategory: "Work visa (No Objection Certificate from MOH required before employment)",
    lastUpdated: "July 2025",
    overview: "Oman licenses international dentists via the OMSB and MOH. The Prometric pathway mirrors other Gulf countries. Oman has a growing private dental sector and a peaceful working environment.",
    steps: [
      { n: "1", title: "DataFlow Credential Verification", desc: "Submit degree for primary source verification. Takes 4–8 weeks.", required: true },
      { n: "2", title: "Prometric Exam (OMSB/MOH)", desc: "CBT covering dentistry and Oman health regulations. Pass mark ~60%.", required: true },
      { n: "3", title: "MOH License Application", desc: "Submit documents and exam results to Oman MOH. Processing: 2–4 weeks.", required: true },
      { n: "4", title: "Job Offer & Work Visa", desc: "Secure a position at a licensed facility. MOH No Objection Certificate required.", required: false },
    ],
    exams: [
      { name: "OMSB / MOH Oman Prometric", desc: "100–150 MCQs on dentistry, ethics, and Oman health regulations", timing: "Year-round at Prometric centres", fee: "$100–120", passMark: "~60%" },
    ],
    documents: [
      "Dental degree (DataFlow verified)",
      "Good Standing Certificate from Egyptian Dental Syndicate",
      "Passport copy",
      "Work experience certificates",
      "Medical fitness certificate",
    ],
    costs: [
      { item: "DataFlow Verification", cost: "$140–200" },
      { item: "Prometric Exam Fee", cost: "$100–120" },
      { item: "MOH License Fee", cost: "OMR 50–100" },
    ],
    tips: [
      "Muscat's private dental clinics offer the best salaries — target the Al-Khuwair and Al-Qurum areas",
      "Oman's relaxed lifestyle and safety make it very popular among Egyptian families relocating",
      "The OMSB specialist pathway allows dentists to register as specialists after passing a specialist exam",
    ],
  },

  bahrain: {
    name: "Bahrain", flag: "🇧🇭", exam: "NHRA Prometric",
    authority: "National Health Regulatory Authority (NHRA)", website: "nhra.bh",
    timeline: "2–4 months", difficulty: "Medium", marketDemand: "Moderate",
    avgSalary: "BHD 600–1,300 / month (tax-free)", currency: "BHD",
    language: "Arabic (official) — English widely used",
    egyptianRecognition: "Fast Track",
    recognitionNote: "Egyptian BDS is recognised by NHRA Bahrain. The Prometric pathway is the standard route. Bahrain is the smallest of the major Gulf dental markets but offers straightforward licensing and proximity to Saudi Arabia.",
    visaCategory: "Work visa sponsored by employer. CPR (Central Population Register) card follows.",
    lastUpdated: "July 2025",
    overview: "Bahrain's NHRA licenses dentists via a Prometric CBT exam. The process is quick and straightforward. Many dentists choose Bahrain as a secondary Gulf registration to complement UAE/KSA licences.",
    steps: [
      { n: "1", title: "DataFlow Credential Verification", desc: "Submit degree for primary source verification. Takes 4–8 weeks.", required: true },
      { n: "2", title: "NHRA Prometric Exam", desc: "CBT covering dentistry and Bahrain health regulations. Pass mark ~60%.", required: true },
      { n: "3", title: "NHRA License Application", desc: "Submit documents and exam results. Processing: 1–3 weeks.", required: true },
      { n: "4", title: "Job Offer & Visa", desc: "Secure a position in a licensed Bahraini facility. Employer sponsors visa.", required: false },
    ],
    exams: [
      { name: "NHRA Prometric Dental Exam", desc: "100 MCQs on general dentistry, ethics, and Bahrain health law", timing: "Year-round at Prometric centres", fee: "$100–115", passMark: "~60%" },
    ],
    documents: [
      "Dental degree (DataFlow verified)",
      "Good Standing Certificate from Egyptian Dental Syndicate",
      "Passport copy",
      "Work experience certificates",
      "Medical fitness certificate",
    ],
    costs: [
      { item: "DataFlow Verification", cost: "$140–200" },
      { item: "NHRA Prometric Exam", cost: "$100–115" },
      { item: "NHRA License Fee", cost: "BHD 50–100" },
    ],
    tips: [
      "Bahrain has no income tax and lower living costs than UAE/KSA",
      "The Bahrain Bay and Juffair areas have the highest concentration of private dental clinics",
      "A Bahrain license is sometimes used as a backup while waiting for UAE or KSA clearance",
    ],
  },

  france: {
    name: "France", flag: "🇫🇷", exam: "PAE (Procédure d'Autorisation d'Exercice)",
    authority: "Conseil National de l'Ordre des Chirurgiens-Dentistes", website: "ordre-chirurgiens-dentistes.fr",
    timeline: "18–36 months", difficulty: "High", marketDemand: "Moderate",
    avgSalary: "€45,000–75,000 / year", currency: "EUR",
    language: "French C1 mandatory (medical French required for clinical registration)",
    egyptianRecognition: "Complex Pathway",
    recognitionNote: "French law limits the number of non-EU dentists who can practice each year through a quota system (PAE). Egyptian dentists must pass a written exam and a dossier selection process, then complete a supervised internship. The quota makes this pathway competitive and slow.",
    visaCategory: "Long Stay Visa / Talent Passport (Passeport Talent) for healthcare professionals",
    lastUpdated: "July 2025",
    overview: "France has one of the most restrictive pathways in Europe for non-EU dentists due to an annual quota system. The PAE process includes a dossier-based pre-selection, written examination, and a mandatory supervised clinical period. French C1 is non-negotiable.",
    steps: [
      { n: "1", title: "French Language — C1 Level", desc: "Achieve C1 French proficiency (DELF/DALF or TCF examinations). Medical French is specifically assessed.", required: true },
      { n: "2", title: "PAE Dossier Application", desc: "Submit your degree, CV, and supporting documents during the annual application window (usually Feb–Apr). Selection is competitive within the annual quota.", required: true },
      { n: "3", title: "PAE Written Examination", desc: "Written exam in French covering dental sciences and French dental law. Held once per year.", required: true },
      { n: "4", title: "Supervised Clinical Period", desc: "Complete 1–2 years of supervised clinical practice in an authorised French dental clinic or hospital.", required: true },
      { n: "5", title: "DCEM Inscription & Ordre Registration", desc: "Register with the Conseil de l'Ordre des Chirurgiens-Dentistes and receive authorisation to practice independently.", required: true },
    ],
    exams: [
      { name: "PAE Written Exam", desc: "Written examination in French — dental sciences, clinical cases, and French dental law", timing: "Once per year (typically June)", fee: "€200–400", passMark: "~50–60%" },
    ],
    documents: [
      "Dental degree (Apostilled + certified French translation)",
      "Academic transcripts (with French translation)",
      "Good Standing Certificate (translated to French)",
      "French language certificate (DELF C1 or equivalent)",
      "Curriculum Vitae (in French)",
      "Cover letter and motivation statement",
    ],
    costs: [
      { item: "French Language Courses (B2→C1)", cost: "€2,000–5,000" },
      { item: "Document translation & Apostille", cost: "€400–1,000" },
      { item: "PAE Application Fee", cost: "€200–400" },
      { item: "Living costs during supervised period", cost: "€12,000–18,000/year" },
    ],
    tips: [
      "France's quota system means many qualified candidates are rejected in any given year — persistence over multiple years is often needed",
      "Lyon, Marseille, and Bordeaux have more dental job openings than Paris",
      "Some Egyptian dentists pursue a French university Masters program first to improve their chances in the PAE dossier",
      "Alliance Française in Cairo offers French language courses — start as early as possible",
    ],
  },

  netherlands: {
    name: "Netherlands", flag: "🇳🇱", exam: "BIG-register Assessment",
    authority: "BIG-register (Beroepen in de Individuele Gezondheidszorg)", website: "bigregister.nl",
    timeline: "6–18 months", difficulty: "High", marketDemand: "Strong",
    avgSalary: "€60,000–95,000 / year", currency: "EUR",
    language: "Dutch B2 (mandatory for clinical registration and patient communication)",
    egyptianRecognition: "Language + Exam",
    recognitionNote: "Egyptian BDS is assessed by the BIG-register. Most non-EU dentists must pass a knowledge test and Dutch language examination. The process can lead to full registration, but Dutch proficiency is the biggest barrier.",
    visaCategory: "Highly Skilled Migrant visa (Kennismigrant) — dentists qualify. Holland Expat Center can assist.",
    lastUpdated: "July 2025",
    overview: "The Netherlands has a strong demand for dentists. BIG registration is required for all healthcare professionals. Non-EU dentists typically need to complete a knowledge assessment and demonstrate Dutch language proficiency before receiving authorisation to practice.",
    steps: [
      { n: "1", title: "Dutch Language — B2 Level", desc: "Learn Dutch to at least B2 level. CNaVT or NT2 examinations are the standard tests.", required: true },
      { n: "2", title: "BIG Application & Credential Assessment", desc: "Submit your degree and transcripts to the BIG-register. They assess equivalency and determine what additional requirements apply.", required: true },
      { n: "3", title: "Knowledge Assessment / Examination", desc: "Complete any required knowledge examination or practical assessment as directed by BIG.", required: true },
      { n: "4", title: "Supervised Period (if required)", desc: "Some candidates must complete a supervised clinical period before full registration.", required: false },
      { n: "5", title: "BIG Registration", desc: "Receive your BIG number — the Dutch licence to practise dentistry. Annual registration maintenance required.", required: true },
      { n: "6", title: "Employment & Visa", desc: "Apply for a Highly Skilled Migrant visa with a job offer from a Dutch dental practice.", required: false },
    ],
    exams: [
      { name: "BIG Knowledge Assessment", desc: "Varies by candidate — may include MCQ, practical assessment, or both depending on credential evaluation outcome", timing: "As required by BIG", fee: "€500–1,500", passMark: "Determined by BIG" },
    ],
    documents: [
      "Dental degree (with certified Dutch or English translation)",
      "Academic transcripts",
      "Good Standing Certificate (translated)",
      "Dutch language certificate (B2)",
      "Passport copy",
      "Curriculum Vitae",
    ],
    costs: [
      { item: "Dutch Language Courses", cost: "€1,500–3,500" },
      { item: "BIG Application & Assessment", cost: "€500–1,500" },
      { item: "Document translation & Apostille", cost: "€300–700" },
    ],
    tips: [
      "Many Dutch dental practices will partially fund your Dutch language courses — negotiate this in your contract",
      "Amsterdam and Randstad region have the highest concentration of private dental practices",
      "The Netherlands has good bilateral relations with Egypt — document verification is relatively smooth",
    ],
  },

  sweden: {
    name: "Sweden", flag: "🇸🇪", exam: "Socialstyrelsen Knowledge Test",
    authority: "National Board of Health and Welfare (Socialstyrelsen)", website: "socialstyrelsen.se",
    timeline: "12–24 months", difficulty: "High", marketDemand: "Strong",
    avgSalary: "SEK 420,000–650,000 / year (~€37,000–57,000)", currency: "SEK",
    language: "Swedish C1 (mandatory — no English-only clinical pathway exists)",
    egyptianRecognition: "Language + Exam",
    recognitionNote: "Swedish dental registration requires Swedish language proficiency and a knowledge examination. Non-EU dentists must also demonstrate clinical competence through a supervised period. The process is long but leads to excellent long-term career prospects in a high-quality healthcare system.",
    visaCategory: "Work permit (AT-UND) — sponsored by Swedish employer. Dentistry is on the shortage list.",
    lastUpdated: "July 2025",
    overview: "Sweden has one of the world's best dental healthcare systems and a growing shortage of dentists. The main challenge is Swedish language — C1 level is required. The Socialstyrelsen pathway involves a knowledge test and supervised clinical period.",
    steps: [
      { n: "1", title: "Swedish Language — SFI to C1", desc: "Start SFI (Swedish for Immigrants) upon arrival or online. Progress to TISUS or equivalent C1 certificate.", required: true },
      { n: "2", title: "Socialstyrelsen Application", desc: "Apply for recognition of your dental qualification. Submit degree, transcripts, and CV.", required: true },
      { n: "3", title: "Knowledge Test (Kunskapsprov)", desc: "Written knowledge examination in Swedish. Tests dental science and Swedish dental law.", required: true },
      { n: "4", title: "Supervised Clinical Period", desc: "Work under supervision at an approved Swedish dental clinic for a specified period.", required: true },
      { n: "5", title: "Legitimation (Full Licence)", desc: "Receive your Swedish dental legitimation from Socialstyrelsen.", required: true },
    ],
    exams: [
      { name: "Kunskapsprov (Knowledge Test)", desc: "Written examination in Swedish covering dental sciences and Swedish dental regulations", timing: "Twice per year", fee: "SEK 2,000–4,000", passMark: "~60%" },
    ],
    documents: [
      "Dental degree (Apostilled + certified Swedish or English translation)",
      "Academic transcripts",
      "Good Standing Certificate",
      "Swedish language certificate (C1)",
      "Passport copy",
      "CV in Swedish",
    ],
    costs: [
      { item: "Swedish Language Courses (to C1)", cost: "SEK 5,000–20,000 (SFI is free in Sweden)" },
      { item: "Socialstyrelsen Application Fee", cost: "SEK 3,200" },
      { item: "Knowledge Test Fee", cost: "SEK 2,000–4,000" },
    ],
    tips: [
      "SFI (Swedish for Immigrants) is free for residents — you must be in Sweden to access it",
      "Folktandvården (public dental service) often sponsors international dentists through the supervised period",
      "Stockholm, Gothenburg, and Malmö have the most dental job vacancies",
      "Some candidates learn Swedish in Egypt through online courses before emigrating",
    ],
  },

  switzerland: {
    name: "Switzerland", flag: "🇨🇭", exam: "Cantonal Recognition / Federal Examination",
    authority: "Medizinalberufekommission (MEBEKO) / Cantonal Health Departments", website: "bag.admin.ch",
    timeline: "6–18 months", difficulty: "High", marketDemand: "Strong",
    avgSalary: "CHF 80,000–140,000 / year (~€85,000–150,000)", currency: "CHF",
    language: "German, French, or Italian (depending on canton) — B2 required, C1 preferred",
    egyptianRecognition: "Via Licensing Exam",
    recognitionNote: "Egyptian BDS requires assessment by MEBEKO (the federal medical professions commission). Non-EU dentists typically need to complete a cantonal examination or supervised period. Switzerland is expensive to live in but offers the highest dental salaries in Europe.",
    visaCategory: "Work permit B — employer-sponsored. Non-EU nationals need a confirmed job offer.",
    lastUpdated: "July 2025",
    overview: "Switzerland has exceptional earning potential for dentists — among the highest in Europe. Cantonal health authorities and the federal MEBEKO jointly manage recognition. German-speaking cantons (Zurich, Bern) have the most opportunities.",
    steps: [
      { n: "1", title: "Language Proficiency (German/French/Italian)", desc: "Achieve B2 in the language of the canton you target. C1 recommended for patient communication.", required: true },
      { n: "2", title: "MEBEKO Application", desc: "Apply to MEBEKO for recognition of your dental qualification. They determine what examination is required.", required: true },
      { n: "3", title: "Cantonal or Federal Examination", desc: "Complete any required cantonal knowledge examination or practical assessment.", required: true },
      { n: "4", title: "Cantonal Practice Licence", desc: "Apply to the cantonal health authority for a practice licence (Berufsausübungsbewilligung).", required: true },
      { n: "5", title: "Work Permit & Employment", desc: "Secure a Swiss employer who will sponsor your B permit. Work as an associate or open your own practice.", required: false },
    ],
    exams: [
      { name: "MEBEKO / Cantonal Assessment", desc: "Knowledge examination or competency assessment — content and format vary by canton", timing: "Varies by canton", fee: "CHF 500–2,000", passMark: "Cantonal standard" },
    ],
    documents: [
      "Dental degree (Apostilled + certified translation into German/French)",
      "Academic transcripts",
      "Good Standing Certificate (translated)",
      "Language certificate (B2+)",
      "Passport copy",
      "CV in German/French",
    ],
    costs: [
      { item: "Language Courses (to B2/C1)", cost: "CHF 2,000–6,000" },
      { item: "MEBEKO Recognition Fee", cost: "CHF 700–1,500" },
      { item: "Cantonal Exam Fee", cost: "CHF 500–2,000" },
      { item: "Document translation & Apostille", cost: "CHF 400–900" },
    ],
    tips: [
      "Zurich and Geneva offer the highest private practice incomes in Switzerland",
      "Swiss cantonal dental associations can help connect you with sponsoring practices",
      "Cost of living is very high — CHF 80,000+ salary is needed to live comfortably",
    ],
  },

  "new-zealand": {
    name: "New Zealand", flag: "🇳🇿", exam: "DCNZ / ADC Pathway",
    authority: "Dental Council of New Zealand (DCNZ)", website: "dcnz.org.nz",
    timeline: "12–24 months", difficulty: "High", marketDemand: "Strong",
    avgSalary: "NZD 90,000–160,000 / year", currency: "NZD",
    language: "IELTS Academic 7.0+ (no band below 7.0) or OET Grade B",
    egyptianRecognition: "Via Licensing Exam",
    recognitionNote: "New Zealand accepts the Australian ADC examination as a pathway to DCNZ registration. Egyptian dentists who pass the ADC can apply for DCNZ registration without additional examination. Alternatively, direct DCNZ assessment is available but requires a supervised period.",
    visaCategory: "Skilled Migrant Category (points-based) — dentists score well. Also Accredited Employer Work Visa.",
    lastUpdated: "July 2025",
    overview: "New Zealand has a significant rural and regional dentist shortage. DCNZ accepts ADC-qualified dentists for streamlined registration. The country offers excellent quality of life and a clear migration pathway to permanent residency.",
    steps: [
      { n: "1", title: "Language Proficiency", desc: "IELTS Academic 7.0 in all bands or OET Grade B. New Zealand has strict requirements.", required: true },
      { n: "2", title: "DCNZ Credential Assessment", desc: "Apply to DCNZ for assessment. They determine whether ADC pathway or direct assessment applies.", required: true },
      { n: "3", title: "ADC Examination (if not already passed)", desc: "Pass the Australian Dental Council Written and Practical examinations.", required: true },
      { n: "4", title: "DCNZ Registration", desc: "Apply for Annual Practising Certificate from DCNZ upon passing ADC or completing supervised period.", required: true },
      { n: "5", title: "Skilled Migrant Visa", desc: "Apply for Skilled Migrant residency visa. Dentists working in regional areas get bonus points.", required: false },
    ],
    exams: [
      { name: "ADC Written Exam", desc: "MCQs across dental sciences — taken in Australia (accepted by DCNZ)", timing: "February & August", fee: "AUD 1,850", passMark: "~55%" },
      { name: "ADC Practical Examination", desc: "Clinical OSCE accepted by DCNZ for registration", timing: "Once per year", fee: "AUD 4,500", passMark: "Component-based" },
    ],
    documents: [
      "Dental degree and academic transcripts",
      "Good Standing Certificate from Egyptian Dental Syndicate",
      "IELTS/OET certificate",
      "ADC exam results (if applicable)",
      "Passport copy",
      "Police clearance certificate",
    ],
    costs: [
      { item: "DCNZ Assessment Fee", cost: "NZD 500–800" },
      { item: "ADC Written Exam", cost: "AUD 1,850" },
      { item: "ADC Practical Exam", cost: "AUD 4,500" },
      { item: "DCNZ Annual Practising Certificate", cost: "NZD 450/year" },
    ],
    tips: [
      "Regional New Zealand (Whanganui, Gisborne, Invercargill) has critical dentist shortages — employers here often sponsor visas faster",
      "New Zealand permanent residency through the Skilled Migrant Category is among the most accessible globally",
      "NZ and Australia have the closest dental licensing reciprocity — passing ADC opens both markets",
    ],
  },

  singapore: {
    name: "Singapore", flag: "🇸🇬", exam: "SDC Qualifying Examination",
    authority: "Singapore Dental Council (SDC)", website: "healthprofessionals.gov.sg",
    timeline: "6–18 months", difficulty: "High", marketDemand: "Selective",
    avgSalary: "SGD 80,000–150,000 / year", currency: "SGD",
    language: "English (Singapore is English-medium — IELTS typically not required for dentists)",
    egyptianRecognition: "Via Licensing Exam",
    recognitionNote: "Egyptian BDS is not on SDC's approved dental qualification list. Candidates must pass the SDC Qualifying Examination — a competitive two-part exam. Singapore's small size limits vacancies but salaries are excellent.",
    visaCategory: "Employment Pass (EP) sponsored by a registered Singapore dental practice. Points-based EP system.",
    lastUpdated: "July 2025",
    overview: "Singapore requires passing the SDC Qualifying Examination for non-approved dental degrees. The exam is rigorous but the resulting registration allows high-earning private practice in one of Asia's most developed cities.",
    steps: [
      { n: "1", title: "SDC Eligibility Assessment", desc: "Submit your degree to the SDC for assessment. They confirm whether the Qualifying Examination applies.", required: true },
      { n: "2", title: "SDC Qualifying Exam — Part 1", desc: "Written MCQ examination covering all dental sciences.", required: true },
      { n: "3", title: "SDC Qualifying Exam — Part 2", desc: "Clinical examination at an SDC-approved institution.", required: true },
      { n: "4", title: "Provisional Registration", desc: "Receive provisional registration for supervised practice (usually 1 year).", required: true },
      { n: "5", title: "Full Registration", desc: "Apply for full SDC registration after completing supervised period.", required: true },
      { n: "6", title: "Employment Pass", desc: "Secure a job offer and apply for Employment Pass through MOM.", required: false },
    ],
    exams: [
      { name: "SDC Qualifying Exam Part 1", desc: "Written MCQs on dental sciences and clinical knowledge", timing: "Once per year", fee: "SGD 500–800", passMark: "~60%" },
      { name: "SDC Qualifying Exam Part 2", desc: "Clinical examination at SDC-approved centre", timing: "After passing Part 1", fee: "SGD 1,000–1,500", passMark: "Component-based" },
    ],
    documents: [
      "Dental degree and academic transcripts",
      "Good Standing Certificate",
      "Passport copy",
      "Curriculum Vitae",
      "2 professional references",
    ],
    costs: [
      { item: "SDC Assessment Fee", cost: "SGD 200–400" },
      { item: "SDC Qualifying Exam Part 1", cost: "SGD 500–800" },
      { item: "SDC Qualifying Exam Part 2", cost: "SGD 1,000–1,500" },
      { item: "Annual Registration Fee", cost: "SGD 200/year" },
    ],
    tips: [
      "Singapore's Orchard Road and Raffles Place have the highest concentration of premium private dental practices",
      "Specialist registration (orthodontics, oral surgery, etc.) requires additional specialist exams",
      "Singapore is an excellent base for dentists wanting to work across ASEAN — regional clinics value Singapore registration",
    ],
  },

  jordan: {
    name: "Jordan", flag: "🇯🇴", exam: "JDA Licensing Exam (minimal requirements for Egyptians)",
    authority: "Jordanian Dental Association (JDA) / Ministry of Health Jordan", website: "jda.org.jo",
    timeline: "1–3 months", difficulty: "Medium", marketDemand: "Moderate",
    avgSalary: "JOD 800–2,000 / month", currency: "JOD",
    language: "Arabic (official) — Egyptian Arabic is well understood",
    egyptianRecognition: "Fast Track",
    recognitionNote: "Jordan has bilateral recognition arrangements with Egypt. Egyptian BDS is directly accepted by the JDA. Egyptian dentists enjoy a particularly smooth pathway due to cultural and linguistic proximity. Jordan is often used as a stepping stone to Gulf countries.",
    visaCategory: "Work permit sponsored by employer. Egyptian nationals have relatively simplified visa procedures for Jordan.",
    lastUpdated: "July 2025",
    overview: "Jordan is one of the easiest markets for Egyptian dentists to enter. The JDA accepts Egyptian BDS degrees with minimal examination requirements. Amman has a growing private dental sector and serves as a gateway to Gulf contract work.",
    steps: [
      { n: "1", title: "JDA Registration Application", desc: "Submit your Egyptian degree and good standing letter to the JDA. Processing: 2–4 weeks.", required: true },
      { n: "2", title: "JDA Licensing Exam (if required)", desc: "Some candidates may be directed to a short licensing exam covering Jordanian dental law.", required: false },
      { n: "3", title: "Ministry of Health Clearance", desc: "Obtain MOH clearance for private practice or employment.", required: true },
      { n: "4", title: "Employment & Work Permit", desc: "Secure a position in a Jordanian dental clinic or hospital. Employer processes work permit.", required: false },
    ],
    exams: [
      { name: "JDA Licensing Exam", desc: "Short exam covering Jordanian dental regulations and professional ethics (not always required for Egyptians)", timing: "As needed", fee: "JOD 50–150", passMark: "~60%" },
    ],
    documents: [
      "Egyptian dental degree",
      "Good Standing Certificate from Egyptian Dental Syndicate",
      "Egyptian Dental Syndicate membership card",
      "Passport copy",
      "Personal photos",
      "Work experience certificates",
    ],
    costs: [
      { item: "JDA Registration Fee", cost: "JOD 100–200" },
      { item: "MOH Clearance Fee", cost: "JOD 50–100" },
      { item: "Work Permit (employer-covered typically)", cost: "JOD 100–200" },
    ],
    tips: [
      "Amman's private clinics in Abdoun and Sweifieh pay the best salaries in Jordan",
      "Jordan can fast-track you to Gulf contracts — many recruitment agencies in Amman place dentists in KSA and UAE",
      "Egyptian dentists are highly regarded in Jordan — Arab Board specialisations done in Egypt are recognised",
    ],
  },

  malaysia: {
    name: "Malaysia", flag: "🇲🇾", exam: "MMC / MIDA Registration Process",
    authority: "Malaysian Dental Council (MDC) / Ministry of Health Malaysia", website: "mdc.gov.my",
    timeline: "3–8 months", difficulty: "Medium", marketDemand: "Moderate",
    avgSalary: "MYR 5,000–12,000 / month", currency: "MYR",
    language: "English widely used in clinical settings (Bahasa Malaysia is official)",
    egyptianRecognition: "Via Licensing Exam",
    recognitionNote: "Egyptian BDS is assessed by the Malaysian Dental Council. Not all Egyptian dental schools are automatically recognised — candidates from recognised schools may follow a simplified pathway. A dental knowledge examination may be required.",
    visaCategory: "Employment Pass sponsored by employer (dental practice or hospital)",
    lastUpdated: "July 2025",
    overview: "Malaysia has a growing private dental market driven by medical tourism. Egyptian dentists need MDC registration. The process is moderate in difficulty and Malaysia offers a good quality of life at a reasonable cost.",
    steps: [
      { n: "1", title: "MDC Credential Verification", desc: "Submit your degree to the Malaysian Dental Council. They verify whether your university is on the recognised list.", required: true },
      { n: "2", title: "Knowledge Examination (if required)", desc: "Sit the MDC dental knowledge examination if directed. Covers dental sciences and Malaysian health law.", required: false },
      { n: "3", title: "MDC Registration", desc: "Apply for MDC registration upon successful assessment.", required: true },
      { n: "4", title: "Annual Practising Certificate", desc: "Obtain an Annual Practising Certificate (APC) — renewed each year.", required: true },
      { n: "5", title: "Employment Pass", desc: "Secure a job offer and apply for an Employment Pass through the Ministry of Human Resources.", required: false },
    ],
    exams: [
      { name: "MDC Dental Knowledge Exam", desc: "MCQ examination on dental sciences and Malaysian health regulations (if required)", timing: "As scheduled by MDC", fee: "MYR 500–1,000", passMark: "~60%" },
    ],
    documents: [
      "Dental degree and academic transcripts",
      "Good Standing Certificate",
      "Passport copy",
      "Curriculum Vitae",
      "Medical fitness certificate",
    ],
    costs: [
      { item: "MDC Registration Fee", cost: "MYR 500–1,000" },
      { item: "Annual Practising Certificate", cost: "MYR 200/year" },
      { item: "Knowledge Exam Fee (if required)", cost: "MYR 500–1,000" },
    ],
    tips: [
      "Kuala Lumpur's Bukit Bintang and KLCC areas have the highest-density private dental practices",
      "Malaysia's medical tourism sector means dental clinics often seek English-speaking international dentists",
      "Cost of living in Malaysia is significantly lower than Gulf countries — a good option for family relocation",
    ],
  },

  "south-africa": {
    name: "South Africa", flag: "🇿🇦", exam: "HPCSA Registration + Equivalency Assessment",
    authority: "Health Professions Council of South Africa (HPCSA)", website: "hpcsa.co.za",
    timeline: "6–12 months", difficulty: "Medium", marketDemand: "Moderate",
    avgSalary: "ZAR 40,000–90,000 / month", currency: "ZAR",
    language: "English (one of the 11 official languages — the primary language of dentistry)",
    egyptianRecognition: "Via Licensing Exam",
    recognitionNote: "HPCSA assesses Egyptian dental qualifications through an equivalency process. A knowledge examination may be required depending on the assessment outcome. South Africa has a dual public/private dental sector with very different salary scales.",
    visaCategory: "Critical Skills Work Visa — dentistry is on the Critical Skills list",
    lastUpdated: "July 2025",
    overview: "South Africa has a shortage of dentists, particularly in rural areas. HPCSA registration is required for all practice. The equivalency process is manageable, and the Critical Skills visa makes immigration relatively straightforward.",
    steps: [
      { n: "1", title: "HPCSA Credential Assessment", desc: "Submit your degree and transcripts to the HPCSA for equivalency assessment.", required: true },
      { n: "2", title: "Knowledge Examination (if required)", desc: "HPCSA may require a dental knowledge examination. Covers dental sciences and South African health law.", required: false },
      { n: "3", title: "HPCSA Registration", desc: "Register with the HPCSA Dental Therapy and Oral Hygiene Board.", required: true },
      { n: "4", title: "Critical Skills Work Visa", desc: "Apply for a Critical Skills Work Visa — dentists qualify directly. Processing: 4–8 weeks.", required: false },
      { n: "5", title: "Employment", desc: "Work in a private practice, state hospital, or community health centre.", required: false },
    ],
    exams: [
      { name: "HPCSA Dental Knowledge Examination", desc: "Written examination on dental sciences and South African health regulations (if directed)", timing: "As scheduled by HPCSA", fee: "ZAR 2,000–4,000", passMark: "~60%" },
    ],
    documents: [
      "Dental degree and academic transcripts",
      "Good Standing Certificate",
      "Certified English translations (if documents are in Arabic)",
      "Passport copy",
      "2 professional references",
    ],
    costs: [
      { item: "HPCSA Assessment Fee", cost: "ZAR 2,000–5,000" },
      { item: "Knowledge Exam Fee (if required)", cost: "ZAR 2,000–4,000" },
      { item: "HPCSA Registration Fee", cost: "ZAR 1,500/year" },
    ],
    tips: [
      "Cape Town and Johannesburg have the strongest private practice markets",
      "Rural dentists in SA earn government bonuses of up to 20% — rural practice accelerates critical skills visa approval",
      "South Africa is an English-speaking country with a familiar dental curriculum — cultural transition is relatively smooth",
    ],
  },

  norway: {
    name: "Norway", flag: "🇳🇴", exam: "Helsedirektoratet Recognition / Tilsynseksamen",
    authority: "Norwegian Directorate of Health (Helsedirektoratet)", website: "helsedirektoratet.no",
    timeline: "12–24 months", difficulty: "High", marketDemand: "Strong",
    avgSalary: "NOK 650,000–950,000 / year (~€57,000–83,000)", currency: "NOK",
    language: "Norwegian B2 (mandatory for clinical practice and authorisation)",
    egyptianRecognition: "Language + Exam",
    recognitionNote: "Norwegian authorisation requires Norwegian language proficiency and an assessment of your dental qualification by Helsedirektoratet. A supervised period or knowledge examination may be required for non-EU dentists.",
    visaCategory: "Skilled Worker permit (Norwegian Immigration Directorate — UDI). Dentists are in shortage occupations.",
    lastUpdated: "July 2025",
    overview: "Norway has a shortage of dentists, particularly in rural and northern regions. Norwegian language is the main hurdle — C1 is effectively required for full authorisation. The long-term reward is excellent salaries and Scandinavian work-life balance.",
    steps: [
      { n: "1", title: "Norwegian Language — B2 to C1", desc: "Learn Norwegian through Norskkurs courses. The Bergen Test or Norskprøve is the standard certification.", required: true },
      { n: "2", title: "Helsedirektoratet Application", desc: "Apply for authorisation. Submit degree, transcripts, and good standing letter.", required: true },
      { n: "3", title: "Knowledge Assessment / Tilsynseksamen", desc: "Helsedirektoratet may direct you to a supervised period or knowledge examination.", required: false },
      { n: "4", title: "Autorisasjon (Full Authorisation)", desc: "Receive the Autorisasjon — the Norwegian dental licence.", required: true },
      { n: "5", title: "Employment & Work Permit", desc: "Secure a job offer in Norway. Apply for a skilled worker permit through UDI.", required: false },
    ],
    exams: [
      { name: "Tilsynseksamen (Supervisory Exam)", desc: "Knowledge examination in Norwegian — if directed by Helsedirektoratet", timing: "As required", fee: "NOK 3,000–6,000", passMark: "~60%" },
    ],
    documents: [
      "Dental degree (Apostilled + certified Norwegian or English translation)",
      "Academic transcripts",
      "Good Standing Certificate",
      "Norwegian language certificate (B2+)",
      "Passport copy",
    ],
    costs: [
      { item: "Norwegian Language Courses", cost: "NOK 5,000–20,000" },
      { item: "Helsedirektoratet Application Fee", cost: "NOK 2,000–4,000" },
      { item: "Document translation & Apostille", cost: "NOK 2,000–5,000" },
    ],
    tips: [
      "Norwegian language courses (Norskkurs) are free for registered immigrants in Norway",
      "Northern Norway (Tromsø, Bodø) has the highest dentist shortage — and employers here actively recruit internationally",
      "Norwegian State Housing Bank offers subsidised loans to healthcare workers — excellent benefit",
    ],
  },

  denmark: {
    name: "Denmark", flag: "🇩🇰", exam: "Sundhedsstyrelsen Recognition Assessment",
    authority: "Danish Health Authority (Sundhedsstyrelsen)", website: "stps.dk",
    timeline: "12–18 months", difficulty: "High", marketDemand: "Strong",
    avgSalary: "DKK 550,000–800,000 / year (~€74,000–107,000)", currency: "DKK",
    language: "Danish B2 (C1 required for full authorisation to practise)",
    egyptianRecognition: "Language + Exam",
    recognitionNote: "Danish authorisation requires assessment by Sundhedsstyrelsen and Danish language proficiency. Non-EU dentists typically need a knowledge test and supervised period. Denmark has one of Europe's highest dental salaries.",
    visaCategory: "Work and residence permit (through the Positive List — dentists qualify) or Pay Limit Scheme",
    lastUpdated: "July 2025",
    overview: "Denmark has a strong demand for dentists. Sundhedsstyrelsen assesses non-EU qualifications and may require an examination and supervised period. Danish language is the major barrier but the country offers exceptional career prospects.",
    steps: [
      { n: "1", title: "Danish Language — B2 to C1", desc: "Learn Danish. Danskuddannelse (Danish for immigrants) is free if you are resident in Denmark.", required: true },
      { n: "2", title: "Sundhedsstyrelsen Application", desc: "Apply for authorisation of your dental qualification.", required: true },
      { n: "3", title: "Knowledge Test (if required)", desc: "Assessment of dental science and Danish health law knowledge.", required: false },
      { n: "4", title: "Supervised Clinical Period", desc: "Complete a supervised period at an approved Danish dental clinic.", required: false },
      { n: "5", title: "Autorisation (Full Licence)", desc: "Receive Danish dental autorisation from Sundhedsstyrelsen.", required: true },
      { n: "6", title: "Work Permit", desc: "Apply for a Danish work and residence permit (Positive List pathway).", required: false },
    ],
    exams: [
      { name: "Sundhedsstyrelsen Knowledge Test", desc: "Written test on dental sciences and Danish health regulations (if directed)", timing: "As required", fee: "DKK 3,000–6,000", passMark: "~60%" },
    ],
    documents: [
      "Dental degree (Apostilled + certified Danish or English translation)",
      "Academic transcripts",
      "Good Standing Certificate",
      "Danish language certificate (B2+)",
      "Passport copy",
      "CV in Danish or English",
    ],
    costs: [
      { item: "Danskuddannelse (language — free for residents)", cost: "Free" },
      { item: "Sundhedsstyrelsen Application Fee", cost: "DKK 2,500–5,000" },
      { item: "Knowledge Test Fee (if required)", cost: "DKK 3,000–6,000" },
    ],
    tips: [
      "Copenhagen has Denmark's highest private dental practice concentration",
      "Denmark's public dental system employs many international dentists with stable contracts",
      "Danish is grammatically close to Norwegian and Swedish — learning any one of the three helps with the others",
    ],
  },
};

export default function CountryDetails() {
  const { country } = useParams();
  const nav = useNavigate();
  const data = countryData[country ?? "uk"] ?? countryData.uk;
  const [activeTab, setActiveTab] = useState<"pathway" | "exams" | "documents" | "costs" | "recognition">("pathway");
  const [checkedDocs, setCheckedDocs] = useState<Record<number, boolean>>({});
  const [showComparison, setShowComparison] = useState(false);
  const [selectedUni, setSelectedUni] = useState("");

  const difficultyColor: Record<string, string> = { "Medium": brand.amber, "High": brand.orange, "Very High": brand.red };
  const recFg = recognitionFg[data.egyptianRecognition] ?? brand.amber;
  const recBg = recognitionBg[data.egyptianRecognition] ?? `${brand.amber}18`;

  const checkedCount = Object.values(checkedDocs).filter(Boolean).length;
  const uniRecognition = useMemo(() => COUNTRY_RECOGNITION[data.name] ?? null, [data.name]);

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Hero */}
      <div style={{ background: `linear-gradient(135deg, ${brand.charcoal} 0%, #24201D 100%)`, padding: "48px 24px 40px", position: "relative", overflow: "hidden" }}>
        <div style={{ position: "absolute", inset: 0, background: "radial-gradient(ellipse at 30% 50%, rgba(255,107,26,0.07) 0%, transparent 55%)", pointerEvents: "none" }} />
        <div style={{ maxWidth: 1100, margin: "0 auto", position: "relative" }}>
          <button onClick={() => nav("/career")} style={{ background: "none", border: "none", cursor: "pointer", color: "rgba(255,255,255,0.5)", fontFamily: "Inter", fontSize: 13, display: "flex", alignItems: "center", gap: 5, marginBottom: 18 }}>
            <ChevronLeft size={15} /> Career Abroad
          </button>
          <div style={{ display: "flex", gap: 20, alignItems: "flex-start", flexWrap: "wrap" }}>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 52, marginBottom: 14 }}>{data.flag}</div>
              <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(26px,4vw,40px)", color: "#fff", marginBottom: 6 }}>{data.name}</h1>
              <div style={{ fontFamily: "Inter", fontSize: 15, color: "rgba(255,255,255,0.6)", marginBottom: 16 }}>{data.exam}</div>
              <div style={{ display: "flex", gap: 10, flexWrap: "wrap" }}>
                <span style={{ fontFamily: "Inter", fontSize: 12, fontWeight: 600, color: difficultyColor[data.difficulty], background: `${difficultyColor[data.difficulty]}15`, borderRadius: 8, padding: "4px 12px" }}>{data.difficulty} Difficulty</span>
                <span style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.5)", display: "flex", alignItems: "center", gap: 4 }}><Clock size={12} /> {data.timeline}</span>
                <span style={{ fontFamily: "Inter", fontSize: 12, color: "#2D9B68", background: "rgba(45,155,104,0.12)", borderRadius: 8, padding: "4px 12px" }}>Market: {data.marketDemand}</span>
                <span style={{ fontFamily: "Inter", fontSize: 12, fontWeight: 700, color: recFg, background: recBg, borderRadius: 8, padding: "4px 12px" }}>🇪🇬 {data.egyptianRecognition}</span>
              </div>
            </div>
            <div style={{ display: "flex", gap: 10, flexShrink: 0 }}>
              <button onClick={() => nav("/career/roadmap")} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "11px 20px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6, boxShadow: "0 4px 14px rgba(255,107,26,0.3)" }}>
                My Roadmap <ArrowRight size={13} />
              </button>
            </div>
          </div>
          {/* Salary reality card */}
          <div style={{ marginTop: 24, background: "rgba(255,255,255,0.06)", border: "1px solid rgba(255,255,255,0.12)", borderRadius: 16, padding: "18px 20px" }}>
            <div style={{ display: "flex", gap: 14, alignItems: "center", flexWrap: "wrap" }}>
              <div style={{ flex: 1 }}>
                <div style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 600, color: "rgba(255,255,255,0.45)", letterSpacing: "0.08em", textTransform: "uppercase" as const, marginBottom: 4 }}>🇪🇬 Egyptian dentists in {data.name} earn</div>
                <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.gold }}>{data.avgSalary}</div>
                <div style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.5)", marginTop: 4 }}>
                  {data.currency !== "USD" && data.currency !== "EGP" ? `Paid in ${data.currency} · ` : ""}{data.marketDemand} demand · {data.egyptianRecognition}
                </div>
              </div>
              <button onClick={() => setShowComparison(true)} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.amber, background: `${brand.amber}15`, border: `1px solid ${brand.amber}30`, borderRadius: 10, padding: "10px 18px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6, whiteSpace: "nowrap" as const }}>
                <BarChart2 size={14} /> Compare Countries
              </button>
            </div>
          </div>

          {/* Quick facts */}
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(180px, 1fr))", gap: 12, marginTop: 16 }}>
            {[
              { icon: <MapPin size={14} />, label: "Authority", value: data.authority },
              { icon: <Plane size={14} />, label: "Visa Category", value: data.visaCategory },
              { icon: <Calendar size={14} />, label: "Last Updated", value: data.lastUpdated },
            ].map((f) => (
              <div key={f.label} style={{ background: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.08)", borderRadius: 12, padding: "12px 14px" }}>
                <div style={{ display: "flex", gap: 5, alignItems: "center", fontFamily: "Inter", fontSize: 10, color: "rgba(255,255,255,0.4)", marginBottom: 4 }}>{f.icon} {f.label}</div>
                <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: "#fff", lineHeight: 1.3 }}>{f.value}</div>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div style={{ maxWidth: 1100, margin: "0 auto", padding: "32px 24px" }}>
        {/* Tabs */}
        <div style={{ display: "flex", borderBottom: `2px solid ${brand.borderGray}`, marginBottom: 28, overflowX: "auto" }}>
          {(["pathway", "exams", "documents", "costs", "recognition"] as const).map((tab) => {
            const labels: Record<string, string> = { pathway: "Step-by-Step Pathway", exams: "Exams", documents: "Documents", costs: "Costs", recognition: "🇪🇬 Recognition" };
            return (
              <button key={tab} onClick={() => setActiveTab(tab)} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: activeTab === tab ? brand.orange : brand.warmGray, background: "none", border: "none", borderBottom: `2px solid ${activeTab === tab ? brand.orange : "transparent"}`, marginBottom: -2, padding: "10px 18px", cursor: "pointer", whiteSpace: "nowrap" as const, transition: "color 0.15s" }}>
                {labels[tab]}
              </button>
            );
          })}
        </div>

        <div style={{ display: "flex", gap: 28, flexWrap: "wrap" }}>
          <div style={{ flex: 1, minWidth: 300 }}>

            {/* Pathway */}
            {activeTab === "pathway" && (
              <div>
                <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px 26px", marginBottom: 20 }}>
                  <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 12 }}>Overview</h2>
                  <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.charcoal, lineHeight: 1.75 }}>{data.overview}</p>
                </div>
                <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px 26px", marginBottom: 20 }}>
                  <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 20 }}>
                    <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, margin: 0 }}>Step-by-Step Pathway</h2>
                    <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, background: brand.offWhite, borderRadius: 8, padding: "5px 10px" }}>
                      ⏱ If you start today, <strong style={{ color: brand.orange }}>licensed by {estimateLicensedDate(data.timeline, data.steps.length - 1, data.steps.length)}</strong>
                    </div>
                  </div>
                  {data.steps.map((step: any, i: number) => {
                    const targetDate = estimateLicensedDate(data.timeline, i, data.steps.length);
                    return (
                      <div key={step.n} style={{ display: "flex", gap: 16, marginBottom: 20, position: "relative" }}>
                        {i < data.steps.length - 1 && <div style={{ position: "absolute", left: 16, top: 32, width: 2, height: "calc(100% - 8px)", background: brand.borderGray }} />}
                        <div style={{ width: 32, height: 32, borderRadius: "50%", background: brand.white, border: `2px solid ${brand.orange}`, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0, zIndex: 1 }}>
                          <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.orange }}>{step.n}</span>
                        </div>
                        <div style={{ flex: 1, paddingBottom: i < data.steps.length - 1 ? 8 : 0 }}>
                          <div style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 4, flexWrap: "wrap" }}>
                            <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: brand.charcoal }}>{step.title}</span>
                            {!step.required && <span style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray, background: brand.offWhite, borderRadius: 4, padding: "2px 6px" }}>Optional</span>}
                            {targetDate && <span style={{ fontFamily: "Inter", fontSize: 10, color: brand.orange, background: `${brand.orange}10`, borderRadius: 4, padding: "2px 7px" }}>~ {targetDate}</span>}
                          </div>
                          <p style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, lineHeight: 1.6, margin: 0 }}>{step.desc}</p>
                        </div>
                      </div>
                    );
                  })}
                </div>
                <div style={{ background: `${brand.amber}08`, border: `1px solid ${brand.amber}25`, borderRadius: 18, padding: "20px 22px" }}>
                  <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.amber, marginBottom: 12 }}>Ejadah Tips for {data.name}</div>
                  {data.tips.map((tip: string, i: number) => (
                    <div key={i} style={{ display: "flex", gap: 8, marginBottom: 8 }}>
                      <span style={{ color: brand.orange, flexShrink: 0 }}>→</span>
                      <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, lineHeight: 1.55 }}>{tip}</span>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Exams */}
            {activeTab === "exams" && (
              <div>
                {data.exams.map((exam: any) => (
                  <div key={exam.name} style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px 26px", marginBottom: 16 }}>
                    <h3 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 10 }}>{exam.name}</h3>
                    <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, lineHeight: 1.6, marginBottom: 16 }}>{exam.desc}</p>
                    {[["Exam Dates", exam.timing], ["Registration Fee", exam.fee], ["Pass Mark", exam.passMark]].map(([l, v]) => (
                      <div key={l as string} style={{ display: "flex", justifyContent: "space-between", padding: "10px 0", borderBottom: `1px solid ${brand.borderGray}` }}>
                        <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray }}>{l as string}</span>
                        <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal }}>{v as string}</span>
                      </div>
                    ))}
                    <button onClick={() => nav("/exams")} style={{ marginTop: 14, fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "10px 20px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}>
                      Prepare with Ejadah <ArrowRight size={13} />
                    </button>
                  </div>
                ))}
              </div>
            )}

            {/* Documents */}
            {activeTab === "documents" && (
              <div>
                <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px 26px", marginBottom: 16 }}>
                  <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 18 }}>
                    <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, margin: 0 }}>Document Checklist</h2>
                    <div style={{ display: "flex", gap: 8, alignItems: "center" }}>
                      <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>
                        <span style={{ fontWeight: 700, color: checkedCount > 0 ? "#2D9B68" : brand.charcoal }}>{checkedCount}</span>/{data.documents.length} ready
                      </div>
                      {checkedCount > 0 && (
                        <button onClick={() => setCheckedDocs({})} style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, background: brand.offWhite, border: `1px solid ${brand.borderGray}`, borderRadius: 6, padding: "3px 8px", cursor: "pointer" }}>Reset</button>
                      )}
                    </div>
                  </div>
                  {/* Progress bar */}
                  <div style={{ height: 5, background: brand.borderGray, borderRadius: 3, marginBottom: 20 }}>
                    <div style={{ height: "100%", borderRadius: 3, background: "#2D9B68", width: `${(checkedCount / data.documents.length) * 100}%`, transition: "width 0.3s" }} />
                  </div>
                  {data.documents.map((doc: string, i: number) => {
                    const checked = checkedDocs[i] ?? false;
                    return (
                      <div key={i} onClick={() => setCheckedDocs((prev) => ({ ...prev, [i]: !checked }))}
                        style={{ display: "flex", gap: 12, alignItems: "center", padding: "13px 0", borderBottom: `1px solid ${brand.borderGray}`, cursor: "pointer", transition: "background 0.1s" }}>
                        <div style={{ width: 22, height: 22, borderRadius: 6, border: `2px solid ${checked ? "#2D9B68" : brand.borderGray}`, background: checked ? "#2D9B68" : "transparent", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0, transition: "all 0.15s" }}>
                          {checked && <CheckCircle size={13} color="#fff" />}
                        </div>
                        <span style={{ fontFamily: "Inter", fontSize: 14, color: checked ? brand.warmGray : brand.charcoal, textDecoration: checked ? "line-through" : "none" }}>{doc}</span>
                        {checked && <span style={{ fontFamily: "Inter", fontSize: 11, color: "#2D9B68", marginLeft: "auto" }}>✓ Ready</span>}
                      </div>
                    );
                  })}
                  <div style={{ marginTop: 16, background: "rgba(255,45,50,0.04)", border: `1px solid rgba(255,45,50,0.12)`, borderRadius: 12, padding: "12px 16px", display: "flex", gap: 8 }}>
                    <AlertTriangle size={13} color={brand.red} style={{ marginTop: 1, flexShrink: 0 }} />
                    <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.charcoal, lineHeight: 1.5 }}>All foreign-language documents must be Apostilled and certified-translated before submission to {data.name} authorities.</span>
                  </div>
                </div>
                {checkedCount === data.documents.length && (
                  <div style={{ background: "rgba(45,155,104,0.08)", border: "1px solid rgba(45,155,104,0.2)", borderRadius: 16, padding: "16px 20px", display: "flex", gap: 10, alignItems: "center" }}>
                    <CheckCircle size={18} color="#2D9B68" />
                    <div>
                      <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#2D9B68", marginBottom: 2 }}>All documents ready!</div>
                      <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray }}>You're prepared to begin your {data.name} application. Book a consultant to review your documents.</div>
                    </div>
                    <button onClick={() => nav("/consulting")} style={{ marginLeft: "auto", fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: "#fff", background: "#2D9B68", border: "none", borderRadius: 10, padding: "10px 16px", cursor: "pointer", whiteSpace: "nowrap" as const }}>Book Consultant</button>
                  </div>
                )}
              </div>
            )}

            {/* Costs */}
            {activeTab === "costs" && (
              <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px 26px" }}>
                <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 16 }}>Estimated Costs</h2>
                {data.costs.map((c: any, i: number) => {
                  const usd = toUSD(c.cost);
                  return (
                    <div key={i} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "12px 0", borderBottom: `1px solid ${brand.borderGray}` }}>
                      <span style={{ fontFamily: "Inter", fontSize: 14, color: brand.charcoal }}>{c.item}</span>
                      <div style={{ textAlign: "right" as const }}>
                        <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal }}>{c.cost}</span>
                        {usd && <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginTop: 1 }}>{usd}</div>}
                      </div>
                    </div>
                  );
                })}
                <div style={{ marginTop: 16, padding: "12px 0", display: "flex", justifyContent: "space-between" }}>
                  <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal }}>Estimated Total</span>
                  <span style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.orange }}>Varies by attempts</span>
                </div>
                <div style={{ marginTop: 10, fontFamily: "Inter", fontSize: 12, color: brand.warmGray, lineHeight: 1.5 }}>Does not include relocation, accommodation, or living expenses. Costs vary by number of exam attempts and individual circumstances.</div>
              </div>
            )}

            {/* Recognition */}
            {activeTab === "recognition" && (
              <div>
                {/* Status card */}
                <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "28px 26px", marginBottom: 16 }}>
                  <div style={{ display: "flex", gap: 16, alignItems: "flex-start", marginBottom: 20 }}>
                    <div style={{ width: 48, height: 48, borderRadius: 14, background: recBg, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                      <Shield size={22} color={recFg} />
                    </div>
                    <div>
                      <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginBottom: 4 }}>Egyptian BDS Recognition Status</div>
                      <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: recFg }}>{data.egyptianRecognition}</div>
                    </div>
                  </div>
                  <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.charcoal, lineHeight: 1.75, margin: 0 }}>{data.recognitionNote}</p>
                </div>

                {/* Recognition comparison matrix */}
                <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px 26px", marginBottom: 16 }}>
                  <h3 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal, marginBottom: 16 }}>Recognition Tier Comparison</h3>
                  {[
                    { tier: "Fast Track", desc: "Egyptian BDS accepted with no or minimal exam. Licensed within 2–6 months.", countries: "UAE, KSA, Qatar, Kuwait, Oman, Bahrain, Jordan", color: "#2D9B68" },
                    { tier: "Via Licensing Exam", desc: "Degree accepted for exam eligibility. Must pass 1–2 licensing exams. 6–24 months.", countries: "UK, Ireland, Australia, Canada, New Zealand, Singapore, Malaysia, South Africa", color: brand.amber },
                    { tier: "Language + Exam", desc: "Degree accepted but language proficiency certificate + knowledge exam required. 12–24 months.", countries: "Germany, Netherlands, Sweden, Switzerland, Belgium, Norway, Denmark", color: brand.orange },
                    { tier: "Complex Pathway", desc: "Degree not directly recognised. Requires advanced study or quota-based competitive process. 24–48+ months.", countries: "USA, France", color: brand.red },
                  ].map((row) => (
                    <div key={row.tier} style={{ display: "flex", gap: 14, padding: "14px 0", borderBottom: `1px solid ${brand.borderGray}`, alignItems: "flex-start" }}>
                      <div style={{ width: 10, height: 10, borderRadius: "50%", background: row.color, flexShrink: 0, marginTop: 5 }} />
                      <div style={{ flex: 1 }}>
                        <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: row.color, marginBottom: 2 }}>{row.tier}</div>
                        <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, marginBottom: 4 }}>{row.desc}</div>
                        <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>{row.countries}</div>
                      </div>
                    </div>
                  ))}
                </div>

                {/* Language requirement */}
                <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px 26px", marginBottom: 16 }}>
                  <h3 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal, marginBottom: 16 }}>Language Requirement for {data.name}</h3>
                  <div style={{ fontFamily: "Inter", fontSize: 14, color: brand.charcoal, lineHeight: 1.7 }}>{data.language}</div>
                  <div style={{ marginTop: 16 }}>
                    <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal, marginBottom: 8 }}>Visa Pathway</div>
                    <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, lineHeight: 1.6 }}>{data.visaCategory}</div>
                  </div>
                </div>

                {/* Degree recognition checker */}
                <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px 26px" }}>
                  <h3 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal, marginBottom: 6 }}>Is My Degree Recognised?</h3>
                  <p style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, marginBottom: 16 }}>Select your Egyptian dental school to check recognition status in {data.name}.</p>
                  <select value={selectedUni} onChange={(e) => setSelectedUni(e.target.value)}
                    style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "11px 14px", outline: "none", marginBottom: 14 }}>
                    <option value="">— Select your university —</option>
                    <optgroup label="── Government Universities ──">
                      {EG_DENTAL_UNIVERSITIES.slice(0, 16).map((u) => <option key={u} value={u}>{u}</option>)}
                    </optgroup>
                    <optgroup label="── Al-Azhar University ──">
                      {EG_DENTAL_UNIVERSITIES.slice(16, 19).map((u) => <option key={u} value={u}>{u}</option>)}
                    </optgroup>
                    <optgroup label="── Private Universities ──">
                      {EG_DENTAL_UNIVERSITIES.slice(19, 41).map((u) => <option key={u} value={u}>{u}</option>)}
                    </optgroup>
                    <optgroup label="── New Universities ──">
                      {EG_DENTAL_UNIVERSITIES.slice(41).map((u) => <option key={u} value={u}>{u}</option>)}
                    </optgroup>
                    <option value="Other / International">Other / International</option>
                  </select>
                  {selectedUni && uniRecognition && (
                    <div style={{ background: uniRecognition.status.startsWith("✅") ? "rgba(45,155,104,0.07)" : uniRecognition.status.startsWith("⚠") ? `${brand.amber}0A` : `${brand.red}07`, border: `1px solid ${uniRecognition.status.startsWith("✅") ? "rgba(45,155,104,0.2)" : uniRecognition.status.startsWith("⚠") ? `${brand.amber}25` : `${brand.red}20`}`, borderRadius: 14, padding: "16px 18px" }}>
                      <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 16, color: uniRecognition.status.startsWith("✅") ? "#2D9B68" : uniRecognition.status.startsWith("⚠") ? brand.amber : brand.red, marginBottom: 6 }}>{uniRecognition.status}</div>
                      <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, lineHeight: 1.6 }}>{uniRecognition.note}</div>
                    </div>
                  )}
                  {selectedUni && !uniRecognition && (
                    <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, background: brand.offWhite, borderRadius: 12, padding: "14px 16px" }}>Recognition data for {data.name} is not yet in our database. Contact an Ejadah consultant for a personalised assessment.</div>
                  )}
                </div>
              </div>
            )}
          </div>

          {/* Sidebar */}
          <div style={{ width: 270, flexShrink: 0 }}>
            <div style={{ position: "sticky", top: 88, display: "flex", flexDirection: "column" as const, gap: 14 }}>
              {/* Recognition badge */}
              <div style={{ background: recBg, border: `1px solid ${recFg}25`, borderRadius: 16, padding: "16px" }}>
                <div style={{ fontFamily: "Inter", fontSize: 10, color: recFg, fontWeight: 700, letterSpacing: "0.08em", textTransform: "uppercase" as const, marginBottom: 6 }}>Egyptian Degree Recognition</div>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: recFg }}>{data.egyptianRecognition}</div>
                <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.charcoal, marginTop: 6, lineHeight: 1.5 }}>Timeline: {data.timeline}</div>
              </div>

              <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "18px" }}>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal, marginBottom: 12 }}>Ejadah Resources</div>
                {[
                  { label: "Question Bank & Exam Prep", path: "/exams" },
                  { label: `Career Mentors — ${data.name}`, path: "/mentoring" },
                  { label: "Career Consultant", path: "/consulting" },
                  { label: "Masters Programs in " + data.name, path: "/masters" },
                  { label: "My Personalised Roadmap", path: "/career/roadmap" },
                ].map((r) => (
                  <button key={r.label} onClick={() => nav(r.path)} style={{ display: "flex", width: "100%", justifyContent: "space-between", alignItems: "center", fontFamily: "Inter", fontSize: 12, color: brand.charcoal, background: brand.offWhite, border: "none", borderRadius: 8, padding: "9px 12px", cursor: "pointer", marginBottom: 6, textAlign: "left" as const }}>
                    <span>{r.label}</span>
                    <ArrowRight size={12} color={brand.orange} />
                  </button>
                ))}
              </div>

              <div style={{ background: brand.charcoal, borderRadius: 18, padding: "18px" }}>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff", marginBottom: 8 }}>Official Authority</div>
                <div style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.6)", marginBottom: 12 }}>{data.authority}</div>
                <a href={`https://${data.website}`} target="_blank" rel="noreferrer" style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.amber, textDecoration: "none", display: "flex", alignItems: "center", gap: 5 }}>
                  {data.website} <ExternalLink size={11} />
                </a>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Country comparison modal */}
      {showComparison && (
        <div style={{ position: "fixed", inset: 0, zIndex: 9999, display: "flex", alignItems: "center", justifyContent: "center", background: "rgba(18,18,18,0.75)", backdropFilter: "blur(4px)" }} onClick={() => setShowComparison(false)}>
          <div onClick={(e) => e.stopPropagation()} style={{ background: brand.white, borderRadius: 24, padding: "36px", width: "100%", maxWidth: 720, maxHeight: "85vh", overflow: "auto", boxShadow: "0 32px 80px rgba(0,0,0,0.25)", position: "relative" }}>
            <button onClick={() => setShowComparison(false)} style={{ position: "absolute", top: 16, right: 18, background: "none", border: "none", cursor: "pointer", color: brand.warmGray }}><X size={20} /></button>
            <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.charcoal, marginBottom: 6 }}>Country Comparison</h2>
            <p style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, marginBottom: 24 }}>How does {data.name} compare to other popular destinations for Egyptian dentists?</p>
            <div style={{ overflowX: "auto" }}>
              <table style={{ width: "100%", borderCollapse: "collapse" as const }}>
                <thead>
                  <tr style={{ borderBottom: `2px solid ${brand.borderGray}` }}>
                    {["", "Timeline", "Difficulty", "Avg. Salary", "Recognition Tier"].map((h) => (
                      <th key={h} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em", padding: "8px 12px", textAlign: "left" as const }}>{h}</th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {COMPARISON_COUNTRIES.map((c) => {
                    const isCurrent = c.name.includes(data.name.split(" ")[0]);
                    return (
                      <tr key={c.key} style={{ borderBottom: `1px solid ${brand.borderGray}`, background: isCurrent ? `${brand.orange}07` : "transparent" }}>
                        <td style={{ padding: "12px 12px", fontFamily: "Inter", fontWeight: isCurrent ? 700 : 400, fontSize: 14, color: isCurrent ? brand.orange : brand.charcoal }}>
                          {c.name}{isCurrent ? " ←" : ""}
                        </td>
                        <td style={{ padding: "12px 12px", fontFamily: "Inter", fontSize: 13, color: brand.charcoal }}>{c.timeline}</td>
                        <td style={{ padding: "12px 12px" }}>
                          <span style={{ fontFamily: "Inter", fontSize: 12, fontWeight: 600, color: c.difficulty === "High" ? brand.orange : brand.amber, background: c.difficulty === "High" ? `${brand.orange}10` : `${brand.amber}10`, borderRadius: 6, padding: "2px 8px" }}>{c.difficulty}</span>
                        </td>
                        <td style={{ padding: "12px 12px", fontFamily: "Inter", fontSize: 13, color: brand.charcoal }}>{c.salary}</td>
                        <td style={{ padding: "12px 12px" }}>
                          <span style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 600, color: c.tier === "Fast Track" ? "#2D9B68" : c.tier === "Lang+Exam" ? brand.orange : brand.amber, background: c.tier === "Fast Track" ? "rgba(45,155,104,0.08)" : c.tier === "Lang+Exam" ? `${brand.orange}10` : `${brand.amber}10`, borderRadius: 6, padding: "3px 8px" }}>{c.tier}</span>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
            <p style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginTop: 20, lineHeight: 1.5 }}>Salary data is approximate and varies by city, experience, and practice type. Timelines assume no prior preparation. Click a country in the Career Abroad section to view its full pathway.</p>
          </div>
        </div>
      )}
    </div>
  );
}
