import { useState } from "react";
import { useNavigate } from "react-router";
import {
  Search, Filter, BookOpen, Clock, Globe, DollarSign,
  Bookmark, Calendar, ChevronDown, ChevronUp, Users,
  GraduationCap, FileText, MapPin, Award, TrendingUp,
} from "lucide-react";
import { brand, gradientFlow, GradientBadge } from "@/app/shared";

const COUNTRY_ISO: Record<string, string> = {
  "United Kingdom": "gb", "Australia": "au", "Germany": "de", "Canada": "ca",
  "United States": "us", "New Zealand": "nz", "France": "fr", "Italy": "it",
  "Spain": "es", "Ireland": "ie", "Japan": "jp", "South Korea": "kr",
  "Singapore": "sg", "United Arab Emirates": "ae", "Saudi Arabia": "sa",
  "South Africa": "za", "Netherlands": "nl", "Sweden": "se", "Switzerland": "ch",
  "Norway": "no", "Denmark": "dk", "Belgium": "be", "Portugal": "pt",
  "Austria": "at", "Finland": "fi", "Malaysia": "my", "Thailand": "th",
  "Qatar": "qa", "Kuwait": "kw",
};

function FlagImg({ country, size = 28 }: { country: string; size?: number }) {
  const iso = COUNTRY_ISO[country] || "un";
  return (
    <img
      src={`https://flagcdn.com/w40/${iso}.png`}
      width={Math.round(size * 1.4)}
      height={size}
      alt={country}
      style={{ borderRadius: 4, objectFit: "cover", display: "block", flexShrink: 0 }}
    />
  );
}

function toUSD(cost: string): string {
  const rates: Record<string, number> = {
    "£": 1.27, "€": 1.09, "AUD": 0.66, "NZD": 0.61, "CAD": 0.74,
    "SGD": 0.74, "AED": 0.27, "CHF": 1.12, "MYR": 0.22, "THB": 0.028,
    "ZAR": 0.055, "HUF": 0.0028, "CZK": 0.044, "PLN": 0.25,
  };
  if (/^\$/.test(cost) || /^USD/.test(cost)) return cost; // already USD
  for (const [sym, rate] of Object.entries(rates)) {
    const re = new RegExp(`${sym.replace(".", "\\.")}\\s*([\\d,]+)`);
    const m = cost.match(re);
    if (m) {
      const num = parseFloat(m[1].replace(/,/g, ""));
      if (isNaN(num)) continue;
      const usd = Math.round((num * rate) / 100) * 100;
      return `~$${usd.toLocaleString()}`;
    }
  }
  return "";
}

const programs = [
  {
    id: "1",
    university: "King's College London",
    country: "United Kingdom", flag: "🇬🇧", city: "London",
    specialty: "Endodontics", degree: "MSc",
    duration: "1 year FT / 2 years PT", format: "Clinical",
    tuition: "£26,000/year", totalCost: "~£32,000",
    livingCost: "~£1,800/mo", language: "English",
    ielts: "7.0 overall", gpa: "Upper second (2:1)",
    clinicalExp: "2+ years post-qualification",
    deadline: "Jan 31, 2026", intake: "September",
    classSize: "8–12 students", acceptanceRate: "~15%",
    casesRequired: "150 clinical cases",
    thesisRequired: true, interviewRequired: true,
    scholarship: true, scholarshipDetail: "King's International Scholarship — up to £10,000",
    egyptianGovtFunding: false,
    recognizedEgypt: true, recognizedUAE: true, recognizedKSA: true, recognizedQatar: true,
    qsRanking: 8, satisfactionScore: 4.7,
    careerOutcome: "Specialist license (Egypt Syndicate), private practice, academia",
    modules: ["Biological basis of endodontics", "Rotary instrumentation & obturation", "Microscope-assisted endodontics", "Endodontic surgery", "Case presentation & evidence-based practice"],
    docsRequired: ["Dental degree certificate", "2 references", "CV", "Personal statement", "IELTS certificate", "Proof of clinical experience"],
    applicationLink: "https://www.kcl.ac.uk",
    accredited: true,
  },
  {
    id: "2",
    university: "University of Melbourne",
    country: "Australia", flag: "🇦🇺", city: "Melbourne",
    specialty: "Implantology", degree: "MClinDent",
    duration: "2 years FT", format: "Clinical",
    tuition: "AUD 55,000/year", totalCost: "~AUD 130,000",
    livingCost: "~AUD 2,200/mo", language: "English",
    ielts: "7.0 overall", gpa: "H2A equivalent",
    clinicalExp: "3+ years post-qualification",
    deadline: "Aug 15, 2025", intake: "February",
    classSize: "6–10 students", acceptanceRate: "~12%",
    casesRequired: "200+ implant placements",
    thesisRequired: true, interviewRequired: true,
    scholarship: false, scholarshipDetail: "",
    egyptianGovtFunding: false,
    recognizedEgypt: true, recognizedUAE: true, recognizedKSA: false, recognizedQatar: false,
    qsRanking: 14, satisfactionScore: 4.8,
    careerOutcome: "Implantology specialist, maxillofacial surgery collaboration, academic research",
    modules: ["Osseointegration science", "Surgical anatomy", "Implant planning (CBCT + software)", "Complex rehabilitation", "Complications management", "Research methods"],
    docsRequired: ["Degree + transcripts", "AHPRA registration (or equivalent)", "3 references", "IELTS", "Portfolio of cases"],
    applicationLink: "https://www.unimelb.edu.au",
    accredited: true,
  },
  {
    id: "3",
    university: "University of Cologne",
    country: "Germany", flag: "🇩🇪", city: "Cologne",
    specialty: "Orthodontics", degree: "MSc",
    duration: "2 years PT", format: "Academic + Clinical",
    tuition: "€3,800/year", totalCost: "~€12,000",
    livingCost: "~€1,100/mo", language: "German / English",
    ielts: "6.5 (English track)", gpa: "Good standing",
    clinicalExp: "1+ year post-qualification",
    deadline: "Mar 1, 2026", intake: "October",
    classSize: "15–20 students", acceptanceRate: "~30%",
    casesRequired: "80 orthodontic cases",
    thesisRequired: true, interviewRequired: false,
    scholarship: true, scholarshipDetail: "DAAD scholarship available — full tuition + €934/mo stipend",
    egyptianGovtFunding: true,
    recognizedEgypt: true, recognizedUAE: true, recognizedKSA: true, recognizedQatar: true,
    qsRanking: 22, satisfactionScore: 4.5,
    careerOutcome: "Orthodontics specialist, academic post, Gulf specialist practice",
    modules: ["Cephalometric analysis", "Fixed & removable appliances", "Digital orthodontics & aligners", "Orthognathic surgery planning", "Retention & relapse"],
    docsRequired: ["Degree certificate", "DAAD application form", "Language certificate", "2 academic references", "Research proposal"],
    applicationLink: "https://www.uni-koeln.de",
    accredited: true,
  },
  {
    id: "4",
    university: "University of Toronto",
    country: "Canada", flag: "🇨🇦", city: "Toronto",
    specialty: "Prosthodontics", degree: "MSD",
    duration: "3 years FT", format: "Clinical",
    tuition: "CAD 28,000/year", totalCost: "~CAD 120,000",
    livingCost: "~CAD 2,500/mo", language: "English",
    ielts: "7.0 overall", gpa: "B+ or above",
    clinicalExp: "2+ years post-qualification",
    deadline: "Dec 1, 2025", intake: "July",
    classSize: "4–6 students", acceptanceRate: "~8%",
    casesRequired: "250+ prosthetic cases",
    thesisRequired: true, interviewRequired: true,
    scholarship: false, scholarshipDetail: "",
    egyptianGovtFunding: false,
    recognizedEgypt: true, recognizedUAE: true, recognizedKSA: true, recognizedQatar: false,
    qsRanking: 18, satisfactionScore: 4.9,
    careerOutcome: "Prosthodontist, implant-supported prosthetics, maxillofacial prosthetics",
    modules: ["Complete & removable prosthodontics", "Implant prosthetics", "Maxillofacial prosthetics", "Occlusion science", "Esthetic dentistry", "Research seminar"],
    docsRequired: ["Degree + transcripts", "3 letters of reference", "Personal statement", "CV with case portfolio", "TOEFL/IELTS"],
    applicationLink: "https://www.utoronto.ca",
    accredited: true,
  },
  {
    id: "5",
    university: "University of Sheffield",
    country: "United Kingdom", flag: "🇬🇧", city: "Sheffield",
    specialty: "Oral Surgery", degree: "MClinDent",
    duration: "3 years FT", format: "Clinical",
    tuition: "£23,000/year", totalCost: "~£78,000",
    livingCost: "~£1,100/mo", language: "English",
    ielts: "7.0 overall", gpa: "Upper second (2:1)",
    clinicalExp: "2+ years post-qualification",
    deadline: "Feb 28, 2026", intake: "September",
    classSize: "6–8 students", acceptanceRate: "~18%",
    casesRequired: "300+ surgical cases",
    thesisRequired: true, interviewRequired: true,
    scholarship: true, scholarshipDetail: "Sheffield International Excellence Scholarship — £4,000",
    egyptianGovtFunding: false,
    recognizedEgypt: true, recognizedUAE: true, recognizedKSA: true, recognizedQatar: true,
    qsRanking: 35, satisfactionScore: 4.6,
    careerOutcome: "Oral surgeon, hospital specialist post, maxillofacial unit collaboration",
    modules: ["Dentoalveolar surgery", "Impacted teeth management", "Cysts & pathology", "Preprosthetic surgery", "Sedation & pain management", "Surgical anatomy"],
    docsRequired: ["Degree certificate", "GDC-equivalent registration", "2 references", "IELTS", "Statement of intent"],
    applicationLink: "https://www.sheffield.ac.uk",
    accredited: true,
  },
  {
    id: "6",
    university: "New York University",
    country: "United States", flag: "🇺🇸", city: "New York",
    specialty: "Periodontology", degree: "MS",
    duration: "3 years FT", format: "Clinical",
    tuition: "$60,000/year", totalCost: "~$220,000",
    livingCost: "~$3,500/mo", language: "English",
    ielts: "7.5 overall", gpa: "3.5/4.0 GPA",
    clinicalExp: "No specific requirement",
    deadline: "Oct 15, 2025", intake: "July",
    classSize: "10–14 students", acceptanceRate: "~10%",
    casesRequired: "180+ periodontal & implant cases",
    thesisRequired: true, interviewRequired: true,
    scholarship: false, scholarshipDetail: "",
    egyptianGovtFunding: false,
    recognizedEgypt: false, recognizedUAE: false, recognizedKSA: false, recognizedQatar: false,
    qsRanking: 11, satisfactionScore: 4.7,
    careerOutcome: "US board-certified periodontist, academic faculty, private specialist practice",
    modules: ["Periodontal medicine", "Implant surgery & prosthetics", "Plastic periodontal surgery", "Laser therapy", "Evidence-based practice"],
    docsRequired: ["Dental degree", "NBDE scores or INBDE", "3 letters", "TOEFL 100+", "CV + personal statement"],
    applicationLink: "https://www.nyu.edu",
    accredited: true,
  },
  {
    id: "7",
    university: "Charité – Berlin",
    country: "Germany", flag: "🇩🇪", city: "Berlin",
    specialty: "Digital Dentistry", degree: "MSc",
    duration: "2 years PT", format: "Academic",
    tuition: "€4,200/year", totalCost: "~€10,000",
    livingCost: "~€1,300/mo", language: "English",
    ielts: "6.5", gpa: "Good standing",
    clinicalExp: "1+ year post-qualification",
    deadline: "Apr 30, 2026", intake: "October",
    classSize: "20–25 students", acceptanceRate: "~40%",
    casesRequired: "Portfolio-based assessment",
    thesisRequired: true, interviewRequired: false,
    scholarship: false, scholarshipDetail: "",
    egyptianGovtFunding: false,
    recognizedEgypt: false, recognizedUAE: true, recognizedKSA: false, recognizedQatar: false,
    qsRanking: 28, satisfactionScore: 4.4,
    careerOutcome: "Digital workflow specialist, dental tech companies, academic researcher",
    modules: ["CAD/CAM technology", "Digital impressions & workflows", "3D printing in dentistry", "AI in diagnosis", "Practice digitisation"],
    docsRequired: ["Degree certificate", "English proficiency", "1 reference", "Motivation letter", "Portfolio of digital work"],
    applicationLink: "https://www.charite.de",
    accredited: true,
  },
  {
    id: "8",
    university: "University of Otago",
    country: "New Zealand", flag: "🇳🇿", city: "Dunedin",
    specialty: "Oral Pathology", degree: "MDS",
    duration: "2 years FT", format: "Clinical + Research",
    tuition: "NZD 35,000/year", totalCost: "~NZD 80,000",
    livingCost: "~NZD 1,500/mo", language: "English",
    ielts: "7.0", gpa: "B+ equivalent",
    clinicalExp: "1+ year post-qualification",
    deadline: "Jul 1, 2025", intake: "February",
    classSize: "4–6 students", acceptanceRate: "~20%",
    casesRequired: "Research thesis + case series",
    thesisRequired: true, interviewRequired: true,
    scholarship: true, scholarshipDetail: "University of Otago Doctoral Scholarship — NZD 27,000/year",
    egyptianGovtFunding: false,
    recognizedEgypt: true, recognizedUAE: false, recognizedKSA: false, recognizedQatar: false,
    qsRanking: 42, satisfactionScore: 4.5,
    careerOutcome: "Oral pathologist, hospital diagnostic unit, academic researcher",
    modules: ["Oral mucosal disease", "Salivary gland pathology", "Head & neck oncology", "Histopathology techniques", "Research methods & statistics"],
    docsRequired: ["Degree + transcripts", "Research proposal", "2 academic references", "IELTS", "CV"],
    applicationLink: "https://www.otago.ac.nz",
    accredited: true,
  },
  {
    id: "11",
    university: "Paris Descartes University (Université Paris Cité)",
    country: "France", flag: "🇫🇷", city: "Paris",
    specialty: "Oral Surgery", degree: "DU / MSc",
    duration: "2 years PT", format: "Clinical + Academic",
    tuition: "€4,500/year", totalCost: "~€12,000",
    livingCost: "~€1,400/mo", language: "French (some English tracks)",
    ielts: "B2 French or 6.5 English", gpa: "Good standing",
    clinicalExp: "1+ year post-qualification",
    deadline: "May 31, 2026", intake: "October",
    classSize: "15–20 students", acceptanceRate: "~35%",
    casesRequired: "120 surgical cases",
    thesisRequired: true, interviewRequired: false,
    scholarship: true, scholarshipDetail: "Campus France Excellence Scholarship — €800/mo stipend for 12 months",
    egyptianGovtFunding: true,
    recognizedEgypt: true, recognizedUAE: false, recognizedKSA: false, recognizedQatar: false,
    qsRanking: 45, satisfactionScore: 4.3,
    careerOutcome: "Oral surgery specialist, hospital faculty post, academic career in Francophone Africa/MENA",
    modules: ["Dentoalveolar surgery", "Preprosthetic surgery", "Cysts & jaw pathology", "Implant surgery basics", "Anaesthesia & sedation", "Research & dissertation"],
    docsRequired: ["Degree + transcripts", "French proficiency certificate or IELTS", "2 references", "CV", "Motivation letter"],
    applicationLink: "https://www.u-paris.fr",
    accredited: true,
  },
  {
    id: "12",
    university: "University of Bologna",
    country: "Italy", flag: "🇮🇹", city: "Bologna",
    specialty: "Orthodontics", degree: "MSc",
    duration: "2 years FT", format: "Clinical + Academic",
    tuition: "€6,000/year", totalCost: "~€15,000",
    livingCost: "~€900/mo", language: "Italian / English",
    ielts: "6.0 (English track)", gpa: "Good standing",
    clinicalExp: "1+ year post-qualification",
    deadline: "Apr 15, 2026", intake: "October",
    classSize: "10–14 students", acceptanceRate: "~28%",
    casesRequired: "100 orthodontic cases",
    thesisRequired: true, interviewRequired: true,
    scholarship: false, scholarshipDetail: "",
    egyptianGovtFunding: false,
    recognizedEgypt: true, recognizedUAE: false, recognizedKSA: false, recognizedQatar: false,
    qsRanking: 60, satisfactionScore: 4.2,
    careerOutcome: "Orthodontics specialist, private referral practice, academic post",
    modules: ["Cephalometric analysis", "Fixed appliances", "Aligners & digital orthodontics", "Orthognathic surgery co-planning", "Retention protocols", "Clinical research"],
    docsRequired: ["Degree", "2 references", "IELTS or Italian B2", "CV", "Motivation letter", "Interview"],
    applicationLink: "https://www.unibo.it",
    accredited: true,
  },
  {
    id: "13",
    university: "University of Barcelona (UB)",
    country: "Spain", flag: "🇪🇸", city: "Barcelona",
    specialty: "Implantology", degree: "MSc",
    duration: "2 years PT", format: "Clinical + Academic",
    tuition: "€7,500/year", totalCost: "~€18,000",
    livingCost: "~€1,100/mo", language: "Spanish / English",
    ielts: "6.0", gpa: "Good standing",
    clinicalExp: "2+ years post-qualification",
    deadline: "Jun 30, 2026", intake: "October",
    classSize: "12–18 students", acceptanceRate: "~30%",
    casesRequired: "80 implant placements",
    thesisRequired: true, interviewRequired: false,
    scholarship: false, scholarshipDetail: "",
    egyptianGovtFunding: false,
    recognizedEgypt: true, recognizedUAE: true, recognizedKSA: false, recognizedQatar: false,
    qsRanking: 70, satisfactionScore: 4.4,
    careerOutcome: "Implant specialist, private clinic, Gulf specialist practice",
    modules: ["Implant biology", "Bone augmentation", "Guided surgery", "Prosthetic rehabilitation", "Digital workflow", "Research methods"],
    docsRequired: ["Degree + transcripts", "IELTS or Spanish B2", "CV", "2 references", "Motivation letter"],
    applicationLink: "https://www.ub.edu",
    accredited: true,
  },
  {
    id: "14",
    university: "University College Dublin (UCD)",
    country: "Ireland", flag: "🇮🇪", city: "Dublin",
    specialty: "Prosthodontics", degree: "MClinDent",
    duration: "3 years FT", format: "Clinical",
    tuition: "€22,000/year", totalCost: "~€72,000",
    livingCost: "~€1,600/mo", language: "English",
    ielts: "6.5", gpa: "Upper second (2:1)",
    clinicalExp: "2+ years post-qualification",
    deadline: "Feb 28, 2026", intake: "September",
    classSize: "6–8 students", acceptanceRate: "~15%",
    casesRequired: "200+ prosthetic cases",
    thesisRequired: true, interviewRequired: true,
    scholarship: true, scholarshipDetail: "UCD Ad Astra Excellence Scholarship — up to €5,000",
    egyptianGovtFunding: false,
    recognizedEgypt: true, recognizedUAE: true, recognizedKSA: true, recognizedQatar: false,
    qsRanking: 50, satisfactionScore: 4.5,
    careerOutcome: "Prosthodontist, implant-supported prosthetics, UK/Ireland specialist pathway",
    modules: ["Fixed & removable prosthodontics", "Implant prosthetics", "Digital prosthetic workflow", "Esthetic dentistry", "Occlusion", "Clinical research"],
    docsRequired: ["Degree + transcripts", "IELTS 6.5", "2 professional references", "Personal statement", "CV", "Interview"],
    applicationLink: "https://www.ucd.ie",
    accredited: true,
  },
  {
    id: "15",
    university: "Tokyo Medical and Dental University (TMDU)",
    country: "Japan", flag: "🇯🇵", city: "Tokyo",
    specialty: "Endodontics", degree: "PhD / MSc",
    duration: "2–4 years FT", format: "Research + Clinical",
    tuition: "¥535,800/year (~€3,300)", totalCost: "~€8,000",
    livingCost: "~€1,200/mo", language: "Japanese / English (research track)",
    ielts: "6.5 (English track)", gpa: "Distinction equivalent",
    clinicalExp: "2+ years post-qualification",
    deadline: "Dec 1, 2025", intake: "April",
    classSize: "4–8 students", acceptanceRate: "~20%",
    casesRequired: "Research-based — no fixed case count",
    thesisRequired: true, interviewRequired: true,
    scholarship: true, scholarshipDetail: "MEXT Japanese Government Scholarship — full tuition + ¥148,000/mo stipend",
    egyptianGovtFunding: false,
    recognizedEgypt: true, recognizedUAE: false, recognizedKSA: false, recognizedQatar: false,
    qsRanking: 30, satisfactionScore: 4.6,
    careerOutcome: "Research-focused specialist, academic career, dental innovation / biomaterials industry",
    modules: ["Pulp biology & regeneration", "Biomaterials science", "CBCT & imaging research", "Endodontic microbiology", "Research methodology", "Dissertation / PhD thesis"],
    docsRequired: ["Degree + transcripts", "Research proposal", "Supervisor agreement letter", "IELTS or JLPT N2", "2 academic references", "MEXT application form"],
    applicationLink: "https://www.tmd.ac.jp/english",
    accredited: true,
  },
  {
    id: "16",
    university: "Seoul National University",
    country: "South Korea", flag: "🇰🇷", city: "Seoul",
    specialty: "Implantology", degree: "MS / PhD",
    duration: "2 years FT (MS)", format: "Research + Clinical",
    tuition: "₩4,500,000/semester (~€3,100/year)", totalCost: "~€7,500",
    livingCost: "~€900/mo", language: "Korean / English (research track)",
    ielts: "6.0 (English track)", gpa: "B+ equivalent",
    clinicalExp: "1+ year post-qualification",
    deadline: "Oct 31, 2025", intake: "March",
    classSize: "5–10 students", acceptanceRate: "~25%",
    casesRequired: "50+ implant cases + research project",
    thesisRequired: true, interviewRequired: true,
    scholarship: true, scholarshipDetail: "Korean Government Scholarship (KGSP) — full tuition + KRW 900,000/mo living allowance",
    egyptianGovtFunding: false,
    recognizedEgypt: false, recognizedUAE: false, recognizedKSA: false, recognizedQatar: false,
    qsRanking: 36, satisfactionScore: 4.4,
    careerOutcome: "Research-focused implantologist, biomaterials academia, dental industry R&D",
    modules: ["Osseointegration biology", "Surface technology", "Digital implant planning", "Bone biology & augmentation", "Biomechanics", "Research & thesis"],
    docsRequired: ["Degree + transcripts", "TOPIK certificate or English proficiency", "Research proposal", "2 references", "KGSP application (if scholarship)"],
    applicationLink: "https://www.snu.ac.kr/en",
    accredited: true,
  },
  {
    id: "17",
    university: "National University of Singapore (NUS)",
    country: "Singapore", flag: "🇸🇬", city: "Singapore",
    specialty: "Periodontics", degree: "MMed (Dent)",
    duration: "3 years FT", format: "Clinical",
    tuition: "SGD 25,000/year (~€17,000)", totalCost: "~SGD 80,000",
    livingCost: "~SGD 2,000/mo", language: "English",
    ielts: "7.0", gpa: "Upper second (2:1)",
    clinicalExp: "2+ years post-qualification",
    deadline: "Nov 30, 2025", intake: "January",
    classSize: "4–6 students", acceptanceRate: "~12%",
    casesRequired: "150+ periodontal & implant cases",
    thesisRequired: true, interviewRequired: true,
    scholarship: false, scholarshipDetail: "",
    egyptianGovtFunding: false,
    recognizedEgypt: false, recognizedUAE: true, recognizedKSA: false, recognizedQatar: false,
    qsRanking: 25, satisfactionScore: 4.7,
    careerOutcome: "Periodontics specialist, South-East Asia specialist pathway, academic post at NUS or NTU",
    modules: ["Periodontal medicine & systemic links", "Implant surgery", "Plastic periodontal surgery", "Laser & photobiomodulation", "Evidence-based practice", "Clinical research"],
    docsRequired: ["Dental degree", "SMC registration (or equivalent)", "IELTS 7.0", "3 references", "Personal statement", "Interview"],
    applicationLink: "https://medicine.nus.edu.sg/dentistry",
    accredited: true,
  },
  {
    id: "18",
    university: "Hamdan Bin Mohammed College of Dental Medicine (HBMCDM)",
    country: "United Arab Emirates", flag: "🇦🇪", city: "Dubai",
    specialty: "Orthodontics", degree: "MSc",
    duration: "2 years FT", format: "Clinical + Academic",
    tuition: "AED 75,000/year (~€18,500)", totalCost: "~AED 160,000",
    livingCost: "~AED 5,000/mo", language: "English",
    ielts: "6.5", gpa: "Good standing",
    clinicalExp: "2+ years post-qualification",
    deadline: "Mar 31, 2026", intake: "September",
    classSize: "8–12 students", acceptanceRate: "~30%",
    casesRequired: "100 orthodontic cases",
    thesisRequired: true, interviewRequired: true,
    scholarship: false, scholarshipDetail: "",
    egyptianGovtFunding: false,
    recognizedEgypt: true, recognizedUAE: true, recognizedKSA: true, recognizedQatar: true,
    qsRanking: 90, satisfactionScore: 4.3,
    careerOutcome: "Orthodontics specialist in Gulf private practice — DHA/DOH recognition path straightforward from same institution",
    modules: ["Fixed appliances", "Clear aligner therapy", "Digital orthodontics", "Orthognathic surgery planning", "Retention", "Clinical audit & research"],
    docsRequired: ["Dental degree", "DHA/DOH or MOH registration", "IELTS 6.5", "2 references", "CV + personal statement", "Interview"],
    applicationLink: "https://www.hbmcdm.ac.ae",
    accredited: true,
  },
  {
    id: "19",
    university: "King Abdulaziz University (KAU)",
    country: "Saudi Arabia", flag: "🇸🇦", city: "Jeddah",
    specialty: "Endodontics", degree: "MSc",
    duration: "2 years FT", format: "Clinical + Academic",
    tuition: "SAR 0 (Saudi nationals) / SAR 40,000/year (international)", totalCost: "~SAR 80,000 (international)",
    livingCost: "~SAR 3,500/mo", language: "Arabic / English",
    ielts: "6.0", gpa: "Good standing",
    clinicalExp: "1+ year post-qualification",
    deadline: "Feb 28, 2026", intake: "September",
    classSize: "6–10 students", acceptanceRate: "~25%",
    casesRequired: "120 endodontic cases",
    thesisRequired: true, interviewRequired: true,
    scholarship: true, scholarshipDetail: "Saudi Ministry of Education sponsored seats for GCC & Arab nationals",
    egyptianGovtFunding: false,
    recognizedEgypt: true, recognizedUAE: true, recognizedKSA: true, recognizedQatar: true,
    qsRanking: 80, satisfactionScore: 4.2,
    careerOutcome: "KSA SCHS specialist classification, Gulf specialist practice, academic post at Saudi dental schools",
    modules: ["Endodontic biology", "Rotary instrumentation", "Surgical endodontics", "Digital endo workflows", "Research methods", "Thesis"],
    docsRequired: ["Dental degree", "SCHS registration", "Arabic/English proficiency", "2 references", "CV", "Interview"],
    applicationLink: "https://www.kau.edu.sa",
    accredited: true,
  },
  {
    id: "20",
    university: "University of Pretoria",
    country: "South Africa", flag: "🇿🇦", city: "Pretoria",
    specialty: "Oral Surgery", degree: "MChD",
    duration: "4 years FT", format: "Clinical + Research",
    tuition: "ZAR 55,000/year (~€2,700)", totalCost: "~ZAR 220,000",
    livingCost: "~ZAR 8,000/mo", language: "English",
    ielts: "6.5", gpa: "Good standing",
    clinicalExp: "2+ years post-qualification",
    deadline: "Sep 30, 2025", intake: "February",
    classSize: "4–6 students", acceptanceRate: "~20%",
    casesRequired: "300+ surgical cases",
    thesisRequired: true, interviewRequired: true,
    scholarship: true, scholarshipDetail: "UP Postgraduate Merit Bursary — up to ZAR 30,000/year",
    egyptianGovtFunding: false,
    recognizedEgypt: true, recognizedUAE: false, recognizedKSA: false, recognizedQatar: false,
    qsRanking: 110, satisfactionScore: 4.1,
    careerOutcome: "Oral & maxillofacial surgeon, academic post, Africa-wide specialist practice",
    modules: ["Dentoalveolar surgery", "Facial trauma", "Pathology & cysts", "Preprosthetic surgery", "Sedation & GA", "Research thesis"],
    docsRequired: ["Dental degree", "HPCSA registration", "IELTS 6.5", "2 clinical references", "Research proposal", "Interview"],
    applicationLink: "https://www.up.ac.za",
    accredited: true,
  },
  {
    id: "9",
    university: "University of Amsterdam",
    country: "Netherlands", flag: "🇳🇱", city: "Amsterdam",
    specialty: "Endodontics", degree: "MSc",
    duration: "2 years PT", format: "Clinical + Academic",
    tuition: "€18,000/year", totalCost: "~€40,000",
    livingCost: "~€1,600/mo", language: "English",
    ielts: "6.5", gpa: "Good standing",
    clinicalExp: "2+ years post-qualification",
    deadline: "Mar 15, 2026", intake: "September",
    classSize: "10–15 students", acceptanceRate: "~25%",
    casesRequired: "120 endodontic cases",
    thesisRequired: true, interviewRequired: false,
    scholarship: false, scholarshipDetail: "",
    egyptianGovtFunding: false,
    recognizedEgypt: true, recognizedUAE: true, recognizedKSA: false, recognizedQatar: true,
    qsRanking: 55, satisfactionScore: 4.3,
    careerOutcome: "Endodontics specialist, private referral practice",
    modules: ["Canal morphology & access", "Regenerative endodontics", "Surgical endodontics", "Digital endo workflows", "Evidence-based seminars"],
    docsRequired: ["Degree", "BIG registration (or equivalent)", "2 references", "IELTS", "Motivation letter"],
    applicationLink: "https://www.uva.nl",
    accredited: true,
  },
  {
    id: "10",
    university: "Karolinska Institutet",
    country: "Sweden", flag: "🇸🇪", city: "Stockholm",
    specialty: "Implantology", degree: "MSc",
    duration: "2 years PT", format: "Academic + Clinical",
    tuition: "€12,000 total", totalCost: "~€18,000",
    livingCost: "~€1,700/mo", language: "English",
    ielts: "6.5", gpa: "Good standing",
    clinicalExp: "2+ years post-qualification",
    deadline: "Jan 15, 2026", intake: "August",
    classSize: "12–16 students", acceptanceRate: "~22%",
    casesRequired: "100+ implant cases",
    thesisRequired: true, interviewRequired: false,
    scholarship: false, scholarshipDetail: "",
    egyptianGovtFunding: false,
    recognizedEgypt: true, recognizedUAE: true, recognizedKSA: true, recognizedQatar: false,
    qsRanking: 40, satisfactionScore: 4.6,
    careerOutcome: "Implant specialist, Scandinavian specialist pathway, research",
    modules: ["Implant biology & osseointegration", "Bone augmentation", "Immediate loading protocols", "Digital planning & guided surgery", "Complications & maintenance"],
    docsRequired: ["Degree certificate", "Clinical CV", "2 references", "IELTS", "Motivation letter"],
    applicationLink: "https://www.ki.se",
    accredited: true,
  },

  // --- Europe ---
  { id:"21", university:"University of Lisbon (ULisboa)", country:"Portugal", flag:"🇵🇹", city:"Lisbon", specialty:"Implantology", degree:"MSc", duration:"2 years PT", format:"Clinical + Academic", tuition:"€4,000/year", totalCost:"~€10,000", livingCost:"~€900/mo", language:"Portuguese / English", ielts:"6.5", gpa:"Good standing", clinicalExp:"2+ years", deadline:"May 15, 2026", intake:"October", classSize:"10–15", acceptanceRate:"~30%", casesRequired:"80 implant cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:95, satisfactionScore:4.2, careerOutcome:"Implant specialist, private practice, Gulf pathway", modules:["Implant biology","Surgical placement","Bone augmentation","Guided surgery","Prosthetic rehabilitation","Research"], docsRequired:["Degree","IELTS","2 references","CV","Motivation letter"], applicationLink:"https://www.ulisboa.pt", accredited:true },
  { id:"22", university:"KU Leuven", country:"Belgium", flag:"🇧🇪", city:"Leuven", specialty:"Orthodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"€8,500/year", totalCost:"~€20,000", livingCost:"~€1,100/mo", language:"English / Dutch", ielts:"6.5", gpa:"Upper second", clinicalExp:"1+ year", deadline:"Mar 1, 2026", intake:"September", classSize:"8–12", acceptanceRate:"~20%", casesRequired:"100 orthodontic cases", thesisRequired:true, interviewRequired:true, scholarship:true, scholarshipDetail:"KU Leuven Excellence Scholarship — up to €5,000", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:true, recognizedKSA:false, recognizedQatar:false, qsRanking:42, satisfactionScore:4.6, careerOutcome:"Orthodontics specialist, academic post, Gulf practice", modules:["Fixed appliances","Aligners","Cephalometrics","Orthognathic co-planning","Digital orthodontics","Thesis"], docsRequired:["Degree","IELTS","2 references","Personal statement","Interview"], applicationLink:"https://www.kuleuven.be", accredited:true },
  { id:"23", university:"University of Zurich", country:"Switzerland", flag:"🇨🇭", city:"Zurich", specialty:"Periodontology", degree:"MSc", duration:"3 years PT", format:"Clinical + Academic", tuition:"CHF 2,000/year (~€2,100)", totalCost:"~CHF 8,000", livingCost:"~CHF 2,400/mo", language:"German / English", ielts:"7.0", gpa:"Good standing", clinicalExp:"2+ years", deadline:"Feb 28, 2026", intake:"September", classSize:"6–10", acceptanceRate:"~18%", casesRequired:"150 periodontal cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:true, recognizedKSA:true, recognizedQatar:false, qsRanking:20, satisfactionScore:4.8, careerOutcome:"Periodontics specialist, private referral, Gulf specialist post", modules:["Periodontal medicine","Implant surgery","Regenerative surgery","Laser therapy","Occlusion","Research"], docsRequired:["Degree","German B2 or IELTS 7.0","2 references","CV","Interview"], applicationLink:"https://www.uzh.ch", accredited:true },
  { id:"24", university:"Medical University of Vienna", country:"Austria", flag:"🇦🇹", city:"Vienna", specialty:"Prosthodontics", degree:"MSc", duration:"2 years PT", format:"Clinical", tuition:"€3,600/year", totalCost:"~€9,000", livingCost:"~€1,200/mo", language:"German / English", ielts:"6.5", gpa:"Good standing", clinicalExp:"2+ years", deadline:"Apr 30, 2026", intake:"October", classSize:"10–14", acceptanceRate:"~25%", casesRequired:"180 prosthetic cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:55, satisfactionScore:4.4, careerOutcome:"Prosthodontist, implant prosthetics, private specialist clinic", modules:["Complete prosthodontics","Implant prosthetics","Digital prosthetics","Esthetics","Occlusion","Thesis"], docsRequired:["Degree","German B2 or IELTS","1 reference","CV","Motivation letter"], applicationLink:"https://www.meduniwien.ac.at", accredited:true },
  { id:"25", university:"University of Copenhagen", country:"Denmark", flag:"🇩🇰", city:"Copenhagen", specialty:"Implantology", degree:"MSc", duration:"2 years PT", format:"Clinical + Academic", tuition:"DKK 85,000/year (~€11,400)", totalCost:"~DKK 180,000", livingCost:"~DKK 10,000/mo", language:"Danish / English", ielts:"6.5", gpa:"Good standing", clinicalExp:"2+ years", deadline:"Mar 15, 2026", intake:"September", classSize:"10–15", acceptanceRate:"~22%", casesRequired:"100 implant cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:true, recognizedKSA:false, recognizedQatar:false, qsRanking:48, satisfactionScore:4.5, careerOutcome:"Implant specialist, Scandinavian specialist pathway, academic post", modules:["Osseointegration","Surgical placement","Bone grafting","Digital workflow","Prosthetic rehabilitation","Research"], docsRequired:["Degree","IELTS 6.5","2 references","CV","Motivation letter"], applicationLink:"https://www.ku.dk", accredited:true },
  { id:"26", university:"University of Oslo", country:"Norway", flag:"🇳🇴", city:"Oslo", specialty:"Endodontics", degree:"MSc", duration:"2 years FT", format:"Clinical", tuition:"NOK 0 (EU/EEA) / NOK 120,000 (international)", totalCost:"~NOK 130,000", livingCost:"~NOK 15,000/mo", language:"Norwegian / English", ielts:"6.5", gpa:"Good standing", clinicalExp:"2+ years", deadline:"Jan 15, 2026", intake:"August", classSize:"6–8", acceptanceRate:"~20%", casesRequired:"120 endodontic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:62, satisfactionScore:4.4, careerOutcome:"Endodontics specialist, Scandinavian specialist pathway", modules:["Endodontic biology","Advanced RCT","Endodontic surgery","Traumatology","Regenerative endo","Thesis"], docsRequired:["Degree","IELTS 6.5","Norwegian B2 (or exemption)","2 references","CV"], applicationLink:"https://www.uio.no", accredited:true },
  { id:"27", university:"University of Helsinki", country:"Finland", flag:"🇫🇮", city:"Helsinki", specialty:"Oral Surgery", degree:"MSc", duration:"2 years FT", format:"Clinical + Research", tuition:"€5,000/year", totalCost:"~€13,000", livingCost:"~€1,200/mo", language:"Finnish / English", ielts:"6.5", gpa:"Good standing", clinicalExp:"2+ years", deadline:"Feb 15, 2026", intake:"September", classSize:"8–10", acceptanceRate:"~25%", casesRequired:"200 surgical cases", thesisRequired:true, interviewRequired:true, scholarship:true, scholarshipDetail:"University of Helsinki scholarship — €5,000 one-time award", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:75, satisfactionScore:4.3, careerOutcome:"Oral surgeon, hospital specialist post, academic career", modules:["Dentoalveolar surgery","Cysts & pathology","Facial trauma","Implant surgery","Sedation","Research"], docsRequired:["Degree","IELTS 6.5","2 references","CV","Motivation letter","Interview"], applicationLink:"https://www.helsinki.fi", accredited:true },
  { id:"28", university:"Jagiellonian University", country:"Poland", flag:"🇵🇱", city:"Kraków", specialty:"Orthodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"€3,500/year", totalCost:"~€9,000", livingCost:"~€700/mo", language:"Polish / English", ielts:"6.0", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Jun 30, 2026", intake:"October", classSize:"12–16", acceptanceRate:"~35%", casesRequired:"80 cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:115, satisfactionScore:4.1, careerOutcome:"Orthodontist, Eastern European specialist pathway", modules:["Fixed appliances","Removable appliances","Cephalometrics","Retention","Digital endo","Thesis"], docsRequired:["Degree","IELTS 6.0 or Polish B2","2 references","CV"], applicationLink:"https://www.uj.edu.pl", accredited:true },
  { id:"29", university:"Charles University Prague", country:"Czech Republic", flag:"🇨🇿", city:"Prague", specialty:"Prosthodontics", degree:"MSc", duration:"2 years PT", format:"Clinical", tuition:"€4,000/year", totalCost:"~€10,000", livingCost:"~€800/mo", language:"Czech / English", ielts:"6.0", gpa:"Good standing", clinicalExp:"2+ years", deadline:"Apr 30, 2026", intake:"October", classSize:"10–15", acceptanceRate:"~30%", casesRequired:"150 prosthetic cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:105, satisfactionScore:4.2, careerOutcome:"Prosthodontist, Central European specialist", modules:["Complete prosthodontics","Fixed prosthodontics","Implant prosthetics","Esthetic dentistry","Digital workflow","Thesis"], docsRequired:["Degree","IELTS 6.0","2 references","CV","Motivation letter"], applicationLink:"https://www.cuni.cz", accredited:true },
  { id:"30", university:"Semmelweis University", country:"Hungary", flag:"🇭🇺", city:"Budapest", specialty:"Implantology", degree:"MSc", duration:"2 years PT", format:"Clinical + Academic", tuition:"€5,500/year", totalCost:"~€13,000", livingCost:"~€700/mo", language:"Hungarian / English", ielts:"6.0", gpa:"Good standing", clinicalExp:"1+ year", deadline:"May 31, 2026", intake:"September", classSize:"12–18", acceptanceRate:"~35%", casesRequired:"80 implant cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:120, satisfactionScore:4.1, careerOutcome:"Implant specialist, private practice, Eastern Europe", modules:["Implant biology","Surgical placement","Bone augmentation","Digital planning","Prosthetics","Research"], docsRequired:["Degree","IELTS 6.0","2 references","CV"], applicationLink:"https://www.semmelweis.hu", accredited:true },
  { id:"31", university:"National and Kapodistrian University of Athens", country:"Greece", flag:"🇬🇷", city:"Athens", specialty:"Endodontics", degree:"MSc", duration:"2 years PT", format:"Clinical + Academic", tuition:"€3,000/year", totalCost:"~€8,000", livingCost:"~€900/mo", language:"Greek / English", ielts:"6.0", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Jul 15, 2026", intake:"October", classSize:"10–15", acceptanceRate:"~40%", casesRequired:"100 endodontic cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:130, satisfactionScore:4.0, careerOutcome:"Endodontist, private specialist clinic, Mediterranean region", modules:["Endodontic biology","Rotary instrumentation","Surgical endo","Traumatology","Regenerative endo","Thesis"], docsRequired:["Degree","IELTS 6.0 or Greek B2","2 references","CV"], applicationLink:"https://en.uoa.gr", accredited:true },
  { id:"32", university:"Ghent University", country:"Belgium", flag:"🇧🇪", city:"Ghent", specialty:"Digital Dentistry", degree:"MSc", duration:"1 year FT", format:"Academic + Practical", tuition:"€7,800/year", totalCost:"~€10,000", livingCost:"~€1,000/mo", language:"English", ielts:"6.5", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Mar 31, 2026", intake:"September", classSize:"15–20", acceptanceRate:"~38%", casesRequired:"Portfolio-based", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:true, recognizedKSA:false, recognizedQatar:false, qsRanking:65, satisfactionScore:4.5, careerOutcome:"Digital workflow specialist, CAD/CAM lab, academic post", modules:["CAD/CAM design","Digital impressions","3D printing","AI diagnostics","Practice digitisation","Thesis"], docsRequired:["Degree","IELTS 6.5","1 reference","Portfolio","Motivation letter"], applicationLink:"https://www.ugent.be", accredited:true },
  { id:"33", university:"University of Porto", country:"Portugal", flag:"🇵🇹", city:"Porto", specialty:"Periodontology", degree:"MSc", duration:"2 years PT", format:"Clinical + Academic", tuition:"€3,800/year", totalCost:"~€9,500", livingCost:"~€850/mo", language:"Portuguese / English", ielts:"6.0", gpa:"Good standing", clinicalExp:"2+ years", deadline:"Jun 15, 2026", intake:"October", classSize:"10–14", acceptanceRate:"~32%", casesRequired:"120 periodontal cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:100, satisfactionScore:4.2, careerOutcome:"Periodontics specialist, private referral, academic career", modules:["Periodontal medicine","Implant surgery","Regenerative therapy","Laser periodontology","Occlusion","Research"], docsRequired:["Degree","IELTS 6.0 or Portuguese B2","2 references","CV"], applicationLink:"https://www.up.pt", accredited:true },
  { id:"34", university:"Complutense University of Madrid", country:"Spain", flag:"🇪🇸", city:"Madrid", specialty:"Endodontics", degree:"MSc", duration:"2 years PT", format:"Clinical + Academic", tuition:"€6,500/year", totalCost:"~€15,000", livingCost:"~€1,100/mo", language:"Spanish / English", ielts:"6.0", gpa:"Good standing", clinicalExp:"1+ year", deadline:"May 31, 2026", intake:"October", classSize:"12–16", acceptanceRate:"~30%", casesRequired:"100 endodontic cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:85, satisfactionScore:4.3, careerOutcome:"Endodontist, private specialist clinic, Latin America pathway", modules:["Endodontic biology","Rotary systems","Surgical endo","Regenerative endo","Digital endo","Thesis"], docsRequired:["Degree","IELTS or Spanish B2","2 references","CV"], applicationLink:"https://www.ucm.es", accredited:true },
  { id:"35", university:"University of Padova", country:"Italy", flag:"🇮🇹", city:"Padova", specialty:"Digital Dentistry", degree:"MSc", duration:"2 years PT", format:"Academic + Practical", tuition:"€5,500/year", totalCost:"~€13,000", livingCost:"~€850/mo", language:"Italian / English", ielts:"6.0", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Apr 30, 2026", intake:"October", classSize:"15–20", acceptanceRate:"~35%", casesRequired:"Portfolio-based", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:true, recognizedKSA:false, recognizedQatar:false, qsRanking:88, satisfactionScore:4.3, careerOutcome:"Digital specialist, lab collaboration, academic post", modules:["CAD/CAM","3D printing","Digital impressions","AI in diagnosis","Workflow integration","Thesis"], docsRequired:["Degree","IELTS 6.0 or Italian B2","1 reference","Portfolio"], applicationLink:"https://www.unipd.it", accredited:true },
  { id:"36", university:"University of Geneva", country:"Switzerland", flag:"🇨🇭", city:"Geneva", specialty:"Implantology", degree:"MSc", duration:"2 years PT", format:"Clinical + Academic", tuition:"CHF 3,500/year (~€3,700)", totalCost:"~CHF 10,000", livingCost:"~CHF 2,600/mo", language:"French / English", ielts:"6.5", gpa:"Good standing", clinicalExp:"2+ years", deadline:"Jan 31, 2026", intake:"September", classSize:"8–12", acceptanceRate:"~20%", casesRequired:"100 implant cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:true, recognizedKSA:false, recognizedQatar:false, qsRanking:30, satisfactionScore:4.7, careerOutcome:"Implant specialist, Swiss/Gulf specialist pathway, academic post", modules:["Implant biology","Bone augmentation","Digital planning","Guided surgery","Prosthetic rehabilitation","Research"], docsRequired:["Degree","IELTS 6.5 or French B2","2 references","CV","Interview"], applicationLink:"https://www.unige.ch", accredited:true },
  { id:"37", university:"Aarhus University", country:"Denmark", flag:"🇩🇰", city:"Aarhus", specialty:"Oral Surgery", degree:"MSc", duration:"2 years FT", format:"Clinical", tuition:"DKK 90,000/year (~€12,000)", totalCost:"~DKK 195,000", livingCost:"~DKK 9,000/mo", language:"Danish / English", ielts:"6.5", gpa:"Good standing", clinicalExp:"2+ years", deadline:"Feb 28, 2026", intake:"September", classSize:"6–8", acceptanceRate:"~18%", casesRequired:"250 surgical cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:58, satisfactionScore:4.4, careerOutcome:"Oral surgeon, hospital post, Scandinavian specialist pathway", modules:["Dentoalveolar surgery","Facial trauma","Cysts & pathology","Implant surgery","Sedation","Research"], docsRequired:["Degree","IELTS 6.5","2 references","CV","Interview"], applicationLink:"https://www.au.dk", accredited:true },
  { id:"38", university:"Trinity College Dublin", country:"Ireland", flag:"🇮🇪", city:"Dublin", specialty:"Oral Surgery", degree:"MClinDent", duration:"3 years FT", format:"Clinical", tuition:"€20,000/year", totalCost:"~€65,000", livingCost:"~€1,700/mo", language:"English", ielts:"6.5", gpa:"Upper second", clinicalExp:"2+ years", deadline:"Mar 31, 2026", intake:"September", classSize:"4–6", acceptanceRate:"~15%", casesRequired:"280 surgical cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:true, recognizedKSA:true, recognizedQatar:false, qsRanking:60, satisfactionScore:4.5, careerOutcome:"Oral surgeon, UK/Ireland specialist list, Gulf specialist post", modules:["Dentoalveolar surgery","Facial trauma","Cysts & pathology","Preprosthetic surgery","Sedation & GA","Research"], docsRequired:["Degree","IELTS 6.5","2 references","Personal statement","CV","Interview"], applicationLink:"https://www.tcd.ie", accredited:true },
  { id:"39", university:"University of Gothenburg", country:"Sweden", flag:"🇸🇪", city:"Gothenburg", specialty:"Endodontics", degree:"MSc", duration:"2 years PT", format:"Clinical + Academic", tuition:"€10,000 total", totalCost:"~€14,000", livingCost:"~€1,500/mo", language:"Swedish / English", ielts:"6.5", gpa:"Good standing", clinicalExp:"2+ years", deadline:"Feb 15, 2026", intake:"August", classSize:"8–12", acceptanceRate:"~22%", casesRequired:"110 endodontic cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:52, satisfactionScore:4.5, careerOutcome:"Endodontist, Scandinavian specialist list, private referral", modules:["Endodontic biology","Advanced RCT","Surgical endo","Traumatology","Regenerative endo","Thesis"], docsRequired:["Degree","IELTS 6.5","2 references","CV"], applicationLink:"https://www.gu.se", accredited:true },
  { id:"40", university:"University of Manchester", country:"United Kingdom", flag:"🇬🇧", city:"Manchester", specialty:"Prosthodontics", degree:"MClinDent", duration:"3 years FT", format:"Clinical", tuition:"£22,000/year", totalCost:"~£70,000", livingCost:"~£1,000/mo", language:"English", ielts:"7.0", gpa:"Upper second (2:1)", clinicalExp:"2+ years", deadline:"Mar 15, 2026", intake:"September", classSize:"4–6", acceptanceRate:"~12%", casesRequired:"220 prosthetic cases", thesisRequired:true, interviewRequired:true, scholarship:true, scholarshipDetail:"Manchester International Scholarship — £3,000", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:true, recognizedKSA:true, recognizedQatar:true, qsRanking:28, satisfactionScore:4.6, careerOutcome:"Prosthodontist, UK GDC specialist list, Gulf specialist post", modules:["Complete prosthodontics","Implant prosthetics","Maxillofacial prosthetics","Digital workflow","Esthetics","Thesis"], docsRequired:["Degree","IELTS 7.0","2 references","Personal statement","CV","Interview"], applicationLink:"https://www.manchester.ac.uk", accredited:true },
  { id:"41", university:"University of Edinburgh", country:"United Kingdom", flag:"🇬🇧", city:"Edinburgh", specialty:"Implantology", degree:"MSc", duration:"2 years PT", format:"Clinical + Academic", tuition:"£18,000/year", totalCost:"~£40,000", livingCost:"~£1,100/mo", language:"English", ielts:"6.5", gpa:"Upper second", clinicalExp:"2+ years", deadline:"Apr 30, 2026", intake:"September", classSize:"10–14", acceptanceRate:"~20%", casesRequired:"100 implant cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:true, recognizedKSA:true, recognizedQatar:false, qsRanking:20, satisfactionScore:4.6, careerOutcome:"Implant specialist, GDC specialist pathway, Gulf post", modules:["Implant biology","Surgical placement","Bone augmentation","Digital workflow","Prosthetic rehabilitation","Research"], docsRequired:["Degree","IELTS 6.5","2 references","CV","Motivation letter"], applicationLink:"https://www.ed.ac.uk", accredited:true },
  { id:"42", university:"University of Leeds", country:"United Kingdom", flag:"🇬🇧", city:"Leeds", specialty:"Implantology", degree:"MSc", duration:"2 years PT", format:"Clinical + Academic", tuition:"£17,500/year", totalCost:"~£38,000", livingCost:"~£900/mo", language:"English", ielts:"6.5", gpa:"Upper second", clinicalExp:"2+ years", deadline:"May 31, 2026", intake:"September", classSize:"12–16", acceptanceRate:"~22%", casesRequired:"90 implant cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:true, recognizedKSA:false, recognizedQatar:false, qsRanking:90, satisfactionScore:4.4, careerOutcome:"Implant specialist, private practice, GDC specialist pathway", modules:["Osseointegration","Bone augmentation","Guided surgery","Digital planning","Prosthetics","Thesis"], docsRequired:["Degree","IELTS 6.5","2 references","CV"], applicationLink:"https://www.leeds.ac.uk", accredited:true },
  { id:"43", university:"University of Glasgow", country:"United Kingdom", flag:"🇬🇧", city:"Glasgow", specialty:"Orthodontics", degree:"MClinDent", duration:"3 years FT", format:"Clinical", tuition:"£21,000/year", totalCost:"~£67,000", livingCost:"~£950/mo", language:"English", ielts:"7.0", gpa:"Upper second", clinicalExp:"2+ years", deadline:"Jan 31, 2026", intake:"September", classSize:"4–6", acceptanceRate:"~12%", casesRequired:"120 orthodontic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:true, recognizedKSA:true, recognizedQatar:true, qsRanking:75, satisfactionScore:4.5, careerOutcome:"Orthodontics specialist, GDC list, Gulf specialist pathway", modules:["Fixed appliances","Removable appliances","Aligners","Orthognathic planning","Digital orthodontics","Thesis"], docsRequired:["Degree","IELTS 7.0","2 references","Personal statement","Interview"], applicationLink:"https://www.gla.ac.uk", accredited:true },
  { id:"44", university:"University of Bristol", country:"United Kingdom", flag:"🇬🇧", city:"Bristol", specialty:"Periodontology", degree:"MClinDent", duration:"3 years FT", format:"Clinical", tuition:"£23,000/year", totalCost:"~£73,000", livingCost:"~£1,000/mo", language:"English", ielts:"7.0", gpa:"Upper second", clinicalExp:"2+ years", deadline:"Feb 28, 2026", intake:"September", classSize:"4–6", acceptanceRate:"~14%", casesRequired:"160 periodontal cases", thesisRequired:true, interviewRequired:true, scholarship:true, scholarshipDetail:"Bristol Dental Excellence Award — £2,500", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:true, recognizedKSA:true, recognizedQatar:true, qsRanking:38, satisfactionScore:4.6, careerOutcome:"Periodontist, GDC specialist list, Gulf specialist post", modules:["Periodontal medicine","Implant surgery","Plastic periodontal surgery","Laser therapy","Evidence-based practice","Thesis"], docsRequired:["Degree","IELTS 7.0","2 references","Personal statement","Interview"], applicationLink:"https://www.bristol.ac.uk", accredited:true },
  // --- MENA ---
  { id:"45", university:"University of Jordan", country:"Jordan", flag:"🇯🇴", city:"Amman", specialty:"Orthodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"JOD 3,500/year (~€4,500)", totalCost:"~JOD 8,000", livingCost:"~€600/mo", language:"Arabic / English", ielts:"5.5", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Jul 31, 2026", intake:"September", classSize:"10–15", acceptanceRate:"~35%", casesRequired:"80 orthodontic cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:true, recognizedKSA:true, recognizedQatar:true, qsRanking:170, satisfactionScore:4.0, careerOutcome:"Orthodontics specialist, Jordan/Gulf private practice", modules:["Fixed appliances","Removable appliances","Cephalometrics","Aligners","Retention","Thesis"], docsRequired:["Degree","English proficiency","2 references","CV"], applicationLink:"https://www.ju.edu.jo", accredited:true },
  { id:"46", university:"American University of Beirut (AUB)", country:"Lebanon", flag:"🇱🇧", city:"Beirut", specialty:"Implantology", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"USD 18,000/year", totalCost:"~USD 42,000", livingCost:"~USD 800/mo", language:"English / Arabic", ielts:"6.5", gpa:"B+ equivalent", clinicalExp:"2+ years", deadline:"Mar 1, 2026", intake:"September", classSize:"6–10", acceptanceRate:"~20%", casesRequired:"100 implant cases", thesisRequired:true, interviewRequired:true, scholarship:true, scholarshipDetail:"AUB Financial Aid — up to 40% tuition reduction based on need", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:true, recognizedKSA:true, recognizedQatar:true, qsRanking:140, satisfactionScore:4.3, careerOutcome:"Implant specialist, MENA regional specialist practice", modules:["Implant biology","Surgical placement","Bone augmentation","Digital planning","Prosthetics","Research"], docsRequired:["Degree","IELTS 6.5","2 references","Personal statement","Interview"], applicationLink:"https://www.aub.edu.lb", accredited:true },
  { id:"47", university:"Kuwait University", country:"Kuwait", flag:"🇰🇼", city:"Kuwait City", specialty:"Endodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"KWD 0 (Kuwait nationals) / KWD 5,000/year (international)", totalCost:"~KWD 11,000", livingCost:"~KWD 600/mo", language:"Arabic / English", ielts:"6.0", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Apr 30, 2026", intake:"September", classSize:"6–8", acceptanceRate:"~25%", casesRequired:"100 endodontic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:true, recognizedKSA:true, recognizedQatar:true, qsRanking:195, satisfactionScore:4.0, careerOutcome:"Endodontist, MOH Kuwait specialist pathway, Gulf practice", modules:["Endodontic biology","Advanced RCT","Surgical endo","Traumatology","Regenerative endo","Thesis"], docsRequired:["Degree","IELTS 6.0","2 references","CV"], applicationLink:"https://www.ku.edu.kw", accredited:true },
  { id:"48", university:"Sultan Qaboos University", country:"Oman", flag:"🇴🇲", city:"Muscat", specialty:"Prosthodontics", degree:"MSc", duration:"2 years FT", format:"Clinical", tuition:"OMR 0 (Omani nationals) / OMR 4,000/year (international)", totalCost:"~OMR 9,000", livingCost:"~OMR 400/mo", language:"Arabic / English", ielts:"6.0", gpa:"Good standing", clinicalExp:"2+ years", deadline:"Mar 31, 2026", intake:"September", classSize:"4–6", acceptanceRate:"~20%", casesRequired:"180 prosthetic cases", thesisRequired:true, interviewRequired:true, scholarship:true, scholarshipDetail:"SQU Postgraduate Scholarship for GCC nationals", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:true, recognizedKSA:true, recognizedQatar:true, qsRanking:215, satisfactionScore:4.1, careerOutcome:"Prosthodontist, Oman MOH specialist pathway, Gulf practice", modules:["Complete prosthodontics","Fixed prosthodontics","Implant prosthetics","Esthetics","Occlusion","Thesis"], docsRequired:["Degree","IELTS 6.0","2 references","CV","Interview"], applicationLink:"https://www.squ.edu.om", accredited:true },
  { id:"49", university:"Mohammed V University – Rabat", country:"Morocco", flag:"🇲🇦", city:"Rabat", specialty:"Orthodontics", degree:"DES / MSc", duration:"3 years FT", format:"Clinical + Academic", tuition:"MAD 15,000/year (~€1,400)", totalCost:"~MAD 48,000", livingCost:"~€500/mo", language:"French / Arabic", ielts:"N/A – French required", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Jul 31, 2026", intake:"October", classSize:"10–15", acceptanceRate:"~40%", casesRequired:"100 orthodontic cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:250, satisfactionScore:3.9, careerOutcome:"Orthodontist, North Africa / Francophone Africa specialist", modules:["Fixed appliances","Removable appliances","Cephalometrics","Orthognathic planning","Retention","Thesis"], docsRequired:["Degree","French B2","2 references","CV"], applicationLink:"https://www.um5.ac.ma", accredited:true },
  { id:"50", university:"University of Tunis El Manar", country:"Tunisia", flag:"🇹🇳", city:"Tunis", specialty:"Endodontics", degree:"DES", duration:"3 years FT", format:"Clinical + Academic", tuition:"TND 3,000/year (~€900)", totalCost:"~TND 10,000", livingCost:"~€400/mo", language:"French / Arabic", ielts:"N/A – French required", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Jun 30, 2026", intake:"October", classSize:"8–12", acceptanceRate:"~40%", casesRequired:"100 endodontic cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:290, satisfactionScore:3.8, careerOutcome:"Endodontist, North Africa regional specialist", modules:["Endodontic biology","Rotary instrumentation","Surgical endo","Regenerative endo","Research","Thesis"], docsRequired:["Degree","French B2","2 references","CV"], applicationLink:"https://www.utm.rnu.tn", accredited:true },
  { id:"51", university:"Cairo University", country:"Egypt", flag:"🇪🇬", city:"Cairo", specialty:"Implantology", degree:"MSc", duration:"2 years FT", format:"Clinical + Research", tuition:"EGP 30,000/year (~€600)", totalCost:"~EGP 70,000", livingCost:"~€300/mo", language:"Arabic / English", ielts:"N/A", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Sep 30, 2026", intake:"October", classSize:"8–12", acceptanceRate:"~35%", casesRequired:"80 implant cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:220, satisfactionScore:4.0, careerOutcome:"Implant specialist, Egyptian Syndicate registration, private clinic", modules:["Implant biology","Surgical placement","Bone augmentation","Digital workflow","Prosthetics","Thesis"], docsRequired:["Degree","2 references","CV"], applicationLink:"https://www.cu.edu.eg", accredited:true },
  { id:"52", university:"King Saud University", country:"Saudi Arabia", flag:"🇸🇦", city:"Riyadh", specialty:"Orthodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"SAR 0 (Saudi) / SAR 38,000/year (international)", totalCost:"~SAR 80,000", livingCost:"~SAR 3,000/mo", language:"Arabic / English", ielts:"6.0", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Mar 15, 2026", intake:"September", classSize:"6–10", acceptanceRate:"~22%", casesRequired:"100 orthodontic cases", thesisRequired:true, interviewRequired:true, scholarship:true, scholarshipDetail:"Saudi Ministry of Education sponsored seats for Arab nationals", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:true, recognizedKSA:true, recognizedQatar:true, qsRanking:98, satisfactionScore:4.2, careerOutcome:"Orthodontics specialist, SCHS classification, Gulf practice", modules:["Fixed appliances","Aligners","Cephalometrics","Orthognathic co-planning","Digital orthodontics","Thesis"], docsRequired:["Degree","SCHS registration","IELTS 6.0","2 references","Interview"], applicationLink:"https://www.ksu.edu.sa", accredited:true },
  { id:"53", university:"Qatar University – College of Dental Medicine", country:"Qatar", flag:"🇶🇦", city:"Doha", specialty:"Implantology", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"QAR 0 (Qatar nationals) / QAR 60,000/year (international)", totalCost:"~QAR 130,000", livingCost:"~QAR 6,000/mo", language:"English / Arabic", ielts:"6.5", gpa:"Good standing", clinicalExp:"2+ years", deadline:"Apr 30, 2026", intake:"September", classSize:"6–8", acceptanceRate:"~20%", casesRequired:"100 implant cases", thesisRequired:true, interviewRequired:true, scholarship:true, scholarshipDetail:"Qatar Foundation Graduate Scholarship — full tuition + QAR 7,000/mo stipend", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:true, recognizedKSA:true, recognizedQatar:true, qsRanking:180, satisfactionScore:4.1, careerOutcome:"Implant specialist, QCHP specialist pathway, Gulf practice", modules:["Implant biology","Surgical placement","Bone augmentation","Digital planning","Prosthetics","Research"], docsRequired:["Degree","IELTS 6.5","2 references","CV","Interview"], applicationLink:"https://www.qu.edu.qa", accredited:true },
  // --- Asia Pacific ---
  { id:"54", university:"Manipal Academy of Higher Education", country:"India", flag:"🇮🇳", city:"Manipal", specialty:"Orthodontics", degree:"MDS", duration:"3 years FT", format:"Clinical + Academic", tuition:"INR 350,000/year (~€3,900)", totalCost:"~INR 1,100,000", livingCost:"~€350/mo", language:"English", ielts:"N/A (English medium)", gpa:"Good standing", clinicalExp:"None required (post-BDS direct)", deadline:"May 31, 2026", intake:"August", classSize:"4–6", acceptanceRate:"~20%", casesRequired:"150 orthodontic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:200, satisfactionScore:4.0, careerOutcome:"MDS Orthodontist, Indian private specialist practice", modules:["Fixed appliances","Removable appliances","Aligners","Cephalometrics","Orthognathic planning","Thesis"], docsRequired:["BDS degree","NEET PG score (India)","2 references","CV"], applicationLink:"https://www.manipal.edu", accredited:true },
  { id:"55", university:"Peking University School of Stomatology", country:"China", flag:"🇨🇳", city:"Beijing", specialty:"Implantology", degree:"PhD / MSc", duration:"3 years FT", format:"Clinical + Research", tuition:"CNY 30,000/year (~€3,900)", totalCost:"~CNY 100,000", livingCost:"~€700/mo", language:"Chinese / English track", ielts:"6.0 (English track)", gpa:"Good standing", clinicalExp:"2+ years", deadline:"Mar 1, 2026", intake:"September", classSize:"8–12", acceptanceRate:"~20%", casesRequired:"80 implant cases + research", thesisRequired:true, interviewRequired:true, scholarship:true, scholarshipDetail:"Chinese Government Scholarship (CSC) — full tuition + CNY 3,000/mo stipend", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:45, satisfactionScore:4.4, careerOutcome:"Research-focused implantologist, academic career, dental industry", modules:["Osseointegration","Bone biology","Digital planning","Guided surgery","Prosthetics","Research & thesis"], docsRequired:["Degree","IELTS 6.0 or HSK4","Research proposal","2 references","CSC application (if scholarship)"], applicationLink:"https://www.pkuss.bjmu.edu.cn", accredited:true },
  { id:"56", university:"University of Hong Kong (HKU)", country:"Hong Kong", flag:"🇭🇰", city:"Hong Kong", specialty:"Endodontics", degree:"MSc", duration:"2 years PT", format:"Clinical + Academic", tuition:"HKD 115,000/year (~€13,500)", totalCost:"~HKD 240,000", livingCost:"~HKD 12,000/mo", language:"English / Cantonese", ielts:"6.5", gpa:"Upper second", clinicalExp:"2+ years", deadline:"Dec 1, 2025", intake:"September", classSize:"8–12", acceptanceRate:"~18%", casesRequired:"120 endodontic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:true, recognizedKSA:false, recognizedQatar:false, qsRanking:22, satisfactionScore:4.6, careerOutcome:"Endodontist, HK specialist registration, Asia-Pacific academic", modules:["Endodontic biology","Advanced RCT","Surgical endo","Traumatology","Regenerative endo","Thesis"], docsRequired:["Degree","IELTS 6.5","2 references","Personal statement","Interview"], applicationLink:"https://www.hku.hk", accredited:true },
  { id:"57", university:"Mahidol University", country:"Thailand", flag:"🇹🇭", city:"Bangkok", specialty:"Orthodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"THB 200,000/year (~€5,200)", totalCost:"~THB 450,000", livingCost:"~€700/mo", language:"Thai / English", ielts:"6.0", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Jan 31, 2026", intake:"May", classSize:"6–10", acceptanceRate:"~25%", casesRequired:"80 orthodontic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:88, satisfactionScore:4.3, careerOutcome:"Orthodontist, South-East Asia specialist practice", modules:["Fixed appliances","Aligners","Cephalometrics","Digital orthodontics","Orthognathic planning","Thesis"], docsRequired:["Degree","IELTS 6.0","2 references","CV","Interview"], applicationLink:"https://www.mahidol.ac.th", accredited:true },
  { id:"58", university:"University of Malaya", country:"Malaysia", flag:"🇲🇾", city:"Kuala Lumpur", specialty:"Implantology", degree:"MSc", duration:"2 years FT", format:"Clinical + Research", tuition:"MYR 25,000/year (~€5,000)", totalCost:"~MYR 55,000", livingCost:"~€700/mo", language:"English / Malay", ielts:"6.0", gpa:"Good standing", clinicalExp:"2+ years", deadline:"Feb 28, 2026", intake:"July", classSize:"6–8", acceptanceRate:"~20%", casesRequired:"80 implant cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:95, satisfactionScore:4.2, careerOutcome:"Implant specialist, Malaysia/ASEAN private practice", modules:["Implant biology","Surgical placement","Bone augmentation","Digital planning","Prosthetics","Research"], docsRequired:["Degree","IELTS 6.0","2 references","CV","Interview"], applicationLink:"https://www.um.edu.my", accredited:true },
  { id:"59", university:"Griffith University", country:"Australia", flag:"🇦🇺", city:"Brisbane", specialty:"Digital Dentistry", degree:"MSc", duration:"2 years PT", format:"Academic + Online", tuition:"AUD 22,000/year", totalCost:"~AUD 48,000", livingCost:"~AUD 1,800/mo", language:"English", ielts:"6.5", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Nov 30, 2025", intake:"March", classSize:"20–30", acceptanceRate:"~45%", casesRequired:"Portfolio-based", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:true, recognizedKSA:false, recognizedQatar:false, qsRanking:130, satisfactionScore:4.2, careerOutcome:"Digital dentistry specialist, CAD/CAM integration, tech industry", modules:["CAD/CAM workflow","3D printing","Digital impressions","AI diagnostics","Practice management tech","Thesis"], docsRequired:["Degree","IELTS 6.5","1 reference","Portfolio"], applicationLink:"https://www.griffith.edu.au", accredited:true },
  { id:"60", university:"University of Queensland", country:"Australia", flag:"🇦🇺", city:"Brisbane", specialty:"Endodontics", degree:"MClinDent", duration:"3 years FT", format:"Clinical", tuition:"AUD 50,000/year", totalCost:"~AUD 160,000", livingCost:"~AUD 1,900/mo", language:"English", ielts:"7.0", gpa:"Upper second", clinicalExp:"3+ years", deadline:"Aug 1, 2025", intake:"February", classSize:"4–6", acceptanceRate:"~12%", casesRequired:"180 endodontic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:48, satisfactionScore:4.7, careerOutcome:"Endodontist, ADC specialist recognition, academic post", modules:["Endodontic biology","Advanced RCT","Surgical endo","Traumatology","Regenerative endo","Thesis"], docsRequired:["Degree","ADC recognition","IELTS 7.0","3 references","Portfolio","Interview"], applicationLink:"https://www.uq.edu.au", accredited:true },
  { id:"61", university:"University of Adelaide", country:"Australia", flag:"🇦🇺", city:"Adelaide", specialty:"Prosthodontics", degree:"MClinDent", duration:"3 years FT", format:"Clinical", tuition:"AUD 48,000/year", totalCost:"~AUD 152,000", livingCost:"~AUD 1,600/mo", language:"English", ielts:"7.0", gpa:"Upper second", clinicalExp:"2+ years", deadline:"Sep 30, 2025", intake:"February", classSize:"4–6", acceptanceRate:"~12%", casesRequired:"200+ prosthetic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:90, satisfactionScore:4.5, careerOutcome:"Prosthodontist, ADC specialist, academic post", modules:["Complete prosthodontics","Implant prosthetics","Digital prosthetics","Maxillofacial","Esthetics","Thesis"], docsRequired:["Degree","ADC recognition","IELTS 7.0","2 references","Interview"], applicationLink:"https://www.adelaide.edu.au", accredited:true },
  // --- Americas ---
  { id:"62", university:"University of São Paulo (USP)", country:"Brazil", flag:"🇧🇷", city:"São Paulo", specialty:"Implantology", degree:"MSc", duration:"2 years FT", format:"Clinical + Research", tuition:"BRL 0 (public university)", totalCost:"~BRL 20,000 (living + fees)", livingCost:"~€600/mo", language:"Portuguese", ielts:"N/A – Portuguese required", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Oct 31, 2025", intake:"March", classSize:"6–10", acceptanceRate:"~20%", casesRequired:"80 implant cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:92, satisfactionScore:4.3, careerOutcome:"Implant specialist, Brazil/Latin America specialist practice, academic", modules:["Implant biology","Bone augmentation","Digital planning","Guided surgery","Prosthetics","Thesis"], docsRequired:["Degree","Portuguese B2","2 references","Research proposal","CV"], applicationLink:"https://www.usp.br", accredited:true },
  { id:"63", university:"UNAM – National Autonomous University of Mexico", country:"Mexico", flag:"🇲🇽", city:"Mexico City", specialty:"Orthodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"MXN 0 (public university)", totalCost:"~MXN 50,000 (living)", livingCost:"~€500/mo", language:"Spanish", ielts:"N/A – Spanish required", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Mar 31, 2026", intake:"August", classSize:"8–12", acceptanceRate:"~25%", casesRequired:"80 orthodontic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:105, satisfactionScore:4.1, careerOutcome:"Orthodontist, Mexico/Latin America specialist practice", modules:["Fixed appliances","Removable appliances","Aligners","Cephalometrics","Orthognathic planning","Thesis"], docsRequired:["Degree","2 references","CV","Research proposal"], applicationLink:"https://www.unam.mx", accredited:true },
  { id:"64", university:"Pontificia Universidad Católica de Chile", country:"Chile", flag:"🇨🇱", city:"Santiago", specialty:"Prosthodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"CLP 4,500,000/year (~€4,700)", totalCost:"~CLP 10,000,000", livingCost:"~€700/mo", language:"Spanish", ielts:"N/A – Spanish required", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Nov 30, 2025", intake:"March", classSize:"6–8", acceptanceRate:"~22%", casesRequired:"150 prosthetic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:110, satisfactionScore:4.2, careerOutcome:"Prosthodontist, Chile/Latin America specialist practice", modules:["Complete prosthodontics","Implant prosthetics","Digital workflow","Esthetics","Occlusion","Thesis"], docsRequired:["Degree","2 references","CV","Interview"], applicationLink:"https://www.uc.cl", accredited:true },
  { id:"65", university:"University of Buenos Aires (UBA)", country:"Argentina", flag:"🇦🇷", city:"Buenos Aires", specialty:"Endodontics", degree:"Especialización", duration:"2 years PT", format:"Clinical", tuition:"ARS 0 (public university)", totalCost:"~ARS 200,000 (fees)", livingCost:"~€350/mo", language:"Spanish", ielts:"N/A – Spanish required", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Apr 30, 2026", intake:"September", classSize:"15–20", acceptanceRate:"~40%", casesRequired:"100 endodontic cases", thesisRequired:false, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:150, satisfactionScore:3.9, careerOutcome:"Endodontist, Argentina/Latin America specialist", modules:["Endodontic biology","Rotary instrumentation","Surgical endo","Traumatology","Regenerative endo","Clinical evaluation"], docsRequired:["Degree","2 references","CV"], applicationLink:"https://www.uba.ar", accredited:true },
  { id:"66", university:"Universidad de Antioquia", country:"Colombia", flag:"🇨🇴", city:"Medellín", specialty:"Oral Surgery", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"COP 8,000,000/year (~€1,800)", totalCost:"~COP 18,000,000", livingCost:"~€400/mo", language:"Spanish", ielts:"N/A – Spanish required", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Jun 30, 2026", intake:"February", classSize:"8–12", acceptanceRate:"~30%", casesRequired:"200 surgical cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:200, satisfactionScore:4.0, careerOutcome:"Oral surgeon, Colombia/Andean region specialist practice", modules:["Dentoalveolar surgery","Cysts & pathology","Facial trauma","Implant surgery","Sedation","Thesis"], docsRequired:["Degree","2 references","CV","Interview"], applicationLink:"https://www.udea.edu.co", accredited:true },
  { id:"67", university:"University of British Columbia (UBC)", country:"Canada", flag:"🇨🇦", city:"Vancouver", specialty:"Endodontics", degree:"MSD", duration:"3 years FT", format:"Clinical", tuition:"CAD 25,000/year", totalCost:"~CAD 85,000", livingCost:"~CAD 2,800/mo", language:"English", ielts:"7.0", gpa:"B+ or above", clinicalExp:"2+ years", deadline:"Nov 1, 2025", intake:"July", classSize:"4–5", acceptanceRate:"~8%", casesRequired:"200 endodontic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:true, recognizedKSA:true, recognizedQatar:false, qsRanking:34, satisfactionScore:4.8, careerOutcome:"Endodontist, NDEB recognized, Canadian specialist pathway", modules:["Endodontic biology","Advanced RCT","Surgical endo","Traumatology","Regenerative endo","Research seminar"], docsRequired:["Degree","NDEB assessment","3 references","Personal statement","IELTS 7.0","Interview"], applicationLink:"https://www.ubc.ca", accredited:true },
  { id:"68", university:"McGill University", country:"Canada", flag:"🇨🇦", city:"Montreal", specialty:"Implantology", degree:"MSc", duration:"2 years FT", format:"Clinical + Research", tuition:"CAD 18,000/year", totalCost:"~CAD 42,000", livingCost:"~CAD 2,000/mo", language:"English / French", ielts:"6.5", gpa:"B+ or above", clinicalExp:"2+ years", deadline:"Jan 15, 2026", intake:"September", classSize:"4–6", acceptanceRate:"~12%", casesRequired:"100 implant cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:true, recognizedKSA:false, recognizedQatar:false, qsRanking:26, satisfactionScore:4.7, careerOutcome:"Implant specialist, Canadian specialist pathway, academic post", modules:["Implant biology","Bone augmentation","Guided surgery","Digital planning","Prosthetics","Thesis"], docsRequired:["Degree","IELTS 6.5","2 references","Research proposal","Interview"], applicationLink:"https://www.mcgill.ca", accredited:true },
  { id:"69", university:"Harvard School of Dental Medicine", country:"United States", flag:"🇺🇸", city:"Boston", specialty:"Periodontology", degree:"DMSc / Certificate", duration:"3 years FT", format:"Clinical", tuition:"$75,000/year", totalCost:"~$240,000", livingCost:"~$3,800/mo", language:"English", ielts:"7.5", gpa:"3.7/4.0", clinicalExp:"2+ years post-qualification", deadline:"Sep 1, 2025", intake:"July", classSize:"3–5", acceptanceRate:"~5%", casesRequired:"200+ periodontal cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:4, satisfactionScore:4.9, careerOutcome:"ADA specialist, academic faculty, private specialist practice globally", modules:["Periodontal medicine","Implant surgery","Plastic surgery","Laser therapy","Research design","Clinical research"], docsRequired:["Degree","NBDE/INBDE","3 references","Personal statement","TOEFL 100+","Interview"], applicationLink:"https://hsdm.harvard.edu", accredited:true },
  { id:"70", university:"Columbia University College of Dental Medicine", country:"United States", flag:"🇺🇸", city:"New York", specialty:"Prosthodontics", degree:"MS", duration:"3 years FT", format:"Clinical", tuition:"$68,000/year", totalCost:"~$215,000", livingCost:"~$3,500/mo", language:"English", ielts:"7.5", gpa:"3.5/4.0", clinicalExp:"No specific requirement", deadline:"Oct 1, 2025", intake:"July", classSize:"5–8", acceptanceRate:"~7%", casesRequired:"250+ prosthetic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:15, satisfactionScore:4.8, careerOutcome:"ADA specialist, academic faculty, private specialist", modules:["Complete prosthodontics","Implant prosthetics","Maxillofacial prosthetics","Digital workflow","Esthetics","Research"], docsRequired:["Degree","NBDE/INBDE","3 references","Personal statement","TOEFL 100+","Interview"], applicationLink:"https://www.dental.columbia.edu", accredited:true },
  { id:"71", university:"University of Michigan School of Dentistry", country:"United States", flag:"🇺🇸", city:"Ann Arbor", specialty:"Orthodontics", degree:"MSD", duration:"2 years FT", format:"Clinical", tuition:"$52,000/year", totalCost:"~$115,000", livingCost:"~$2,200/mo", language:"English", ielts:"7.0", gpa:"3.5/4.0", clinicalExp:"No specific requirement", deadline:"Oct 15, 2025", intake:"July", classSize:"8–10", acceptanceRate:"~10%", casesRequired:"100+ orthodontic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:22, satisfactionScore:4.8, careerOutcome:"ADA orthodontics specialist, private practice, academic faculty", modules:["Fixed appliances","Aligners","Cephalometrics","Orthognathic planning","Digital orthodontics","Research & thesis"], docsRequired:["Degree","NBDE/INBDE","3 references","Personal statement","TOEFL","Interview"], applicationLink:"https://www.dent.umich.edu", accredited:true },
  { id:"72", university:"Indiana University School of Dentistry", country:"United States", flag:"🇺🇸", city:"Indianapolis", specialty:"Endodontics", degree:"MS", duration:"2 years FT", format:"Clinical", tuition:"$40,000/year", totalCost:"~$90,000", livingCost:"~$1,800/mo", language:"English", ielts:"6.5", gpa:"3.2/4.0", clinicalExp:"No specific requirement", deadline:"Dec 1, 2025", intake:"July", classSize:"6–8", acceptanceRate:"~15%", casesRequired:"180 endodontic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:55, satisfactionScore:4.6, careerOutcome:"ADA endodontics specialist, private practice, academic", modules:["Endodontic biology","Advanced RCT","Surgical endo","Traumatology","Regenerative endo","Thesis"], docsRequired:["Degree","NBDE/INBDE","2 references","Personal statement","TOEFL","Interview"], applicationLink:"https://www.dentistry.iu.edu", accredited:true },
  { id:"73", university:"University of North Carolina (UNC)", country:"United States", flag:"🇺🇸", city:"Chapel Hill", specialty:"Periodontology", degree:"MS", duration:"3 years FT", format:"Clinical", tuition:"$38,000/year", totalCost:"~$120,000", livingCost:"~$1,900/mo", language:"English", ielts:"6.5", gpa:"3.3/4.0", clinicalExp:"No specific requirement", deadline:"Nov 1, 2025", intake:"July", classSize:"6–8", acceptanceRate:"~10%", casesRequired:"160 periodontal cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:44, satisfactionScore:4.7, careerOutcome:"ADA periodontist, academic faculty, private specialist", modules:["Periodontal medicine","Implant surgery","Plastic surgery","Laser therapy","Occlusion","Research"], docsRequired:["Degree","NBDE/INBDE","2 references","Personal statement","TOEFL","Interview"], applicationLink:"https://www.dentistry.unc.edu", accredited:true },
  { id:"74", university:"University of Texas Health Science Center", country:"United States", flag:"🇺🇸", city:"San Antonio", specialty:"Implantology", degree:"MS", duration:"2 years FT", format:"Clinical + Research", tuition:"$35,000/year", totalCost:"~$80,000", livingCost:"~$1,700/mo", language:"English", ielts:"6.5", gpa:"3.2/4.0", clinicalExp:"1+ year", deadline:"Jan 15, 2026", intake:"July", classSize:"6–8", acceptanceRate:"~18%", casesRequired:"120 implant cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:65, satisfactionScore:4.5, careerOutcome:"Implant specialist, private practice, ADA pathway", modules:["Implant biology","Surgical placement","Bone augmentation","Digital planning","Prosthetics","Thesis"], docsRequired:["Degree","NBDE/INBDE","2 references","Personal statement","TOEFL","Interview"], applicationLink:"https://www.uthscsa.edu", accredited:true },
  // --- Africa ---
  { id:"75", university:"University of Nairobi", country:"Kenya", flag:"🇰🇪", city:"Nairobi", specialty:"Oral Surgery", degree:"MMed (Dental Surgery)", duration:"3 years FT", format:"Clinical + Research", tuition:"KES 250,000/year (~€1,700)", totalCost:"~KES 800,000", livingCost:"~€500/mo", language:"English / Swahili", ielts:"N/A (English medium)", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Jul 31, 2026", intake:"September", classSize:"4–6", acceptanceRate:"~25%", casesRequired:"250 surgical cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:350, satisfactionScore:3.8, careerOutcome:"Oral surgeon, East African specialist practice, hospital post", modules:["Dentoalveolar surgery","Cysts & pathology","Facial trauma","Preprosthetic surgery","Sedation","Thesis"], docsRequired:["Degree","Kenya Medical Practitioners registration","2 references","CV","Interview"], applicationLink:"https://www.uonbi.ac.ke", accredited:true },
  { id:"76", university:"University of Lagos (UNILAG)", country:"Nigeria", flag:"🇳🇬", city:"Lagos", specialty:"Orthodontics", degree:"FWACS / MSc", duration:"3 years FT", format:"Clinical + Academic", tuition:"NGN 500,000/year (~€600)", totalCost:"~NGN 1,600,000", livingCost:"~€400/mo", language:"English", ielts:"N/A (English medium)", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Aug 31, 2026", intake:"October", classSize:"4–6", acceptanceRate:"~30%", casesRequired:"80 orthodontic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:400, satisfactionScore:3.7, careerOutcome:"Orthodontist, West Africa specialist practice", modules:["Fixed appliances","Removable appliances","Cephalometrics","Retention","Clinical audit","Thesis"], docsRequired:["Degree","MDCN registration","2 references","CV","Interview"], applicationLink:"https://www.unilag.edu.ng", accredited:true },
  { id:"77", university:"University of Cape Town (UCT)", country:"South Africa", flag:"🇿🇦", city:"Cape Town", specialty:"Endodontics", degree:"MChD", duration:"3 years FT", format:"Clinical + Research", tuition:"ZAR 50,000/year (~€2,500)", totalCost:"~ZAR 160,000", livingCost:"~ZAR 9,000/mo", language:"English", ielts:"6.5", gpa:"Good standing", clinicalExp:"2+ years", deadline:"Oct 31, 2025", intake:"February", classSize:"4–6", acceptanceRate:"~18%", casesRequired:"150 endodontic cases", thesisRequired:true, interviewRequired:true, scholarship:true, scholarshipDetail:"UCT Postgraduate Merit Bursary — up to ZAR 25,000/year", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:160, satisfactionScore:4.2, careerOutcome:"Endodontist, HPCSA specialist, academic post at UCT or Stellenbosch", modules:["Endodontic biology","Advanced RCT","Surgical endo","Traumatology","Regenerative endo","Thesis"], docsRequired:["Degree","HPCSA registration","IELTS 6.5","2 references","Research proposal","Interview"], applicationLink:"https://www.uct.ac.za", accredited:true },
  { id:"78", university:"University of the Witwatersrand", country:"South Africa", flag:"🇿🇦", city:"Johannesburg", specialty:"Oral Pathology", degree:"MChD", duration:"2 years FT", format:"Clinical + Research", tuition:"ZAR 45,000/year (~€2,200)", totalCost:"~ZAR 95,000", livingCost:"~ZAR 8,500/mo", language:"English", ielts:"6.5", gpa:"Good standing", clinicalExp:"2+ years", deadline:"Sep 30, 2025", intake:"February", classSize:"2–4", acceptanceRate:"~20%", casesRequired:"Research & histopathology case series", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:185, satisfactionScore:4.1, careerOutcome:"Oral pathologist, diagnostic service, academic post", modules:["Oral mucosal disease","Salivary gland pathology","Head & neck oncology","Histopathology","Research methods","Thesis"], docsRequired:["Degree","HPCSA registration","2 references","Research proposal","Interview"], applicationLink:"https://www.wits.ac.za", accredited:true },
  // --- Rest of World ---
  { id:"79", university:"Hacettepe University", country:"Turkey", flag:"🇹🇷", city:"Ankara", specialty:"Implantology", degree:"MSc", duration:"2 years FT", format:"Clinical + Research", tuition:"TRY 25,000/year (~€700)", totalCost:"~TRY 55,000", livingCost:"~€500/mo", language:"Turkish / English", ielts:"6.0", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Jun 30, 2026", intake:"September", classSize:"6–10", acceptanceRate:"~30%", casesRequired:"80 implant cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:175, satisfactionScore:4.1, careerOutcome:"Implant specialist, Turkey/MENA private practice", modules:["Implant biology","Bone augmentation","Digital planning","Guided surgery","Prosthetics","Thesis"], docsRequired:["Degree","2 references","English proficiency","CV","Interview"], applicationLink:"https://www.hacettepe.edu.tr", accredited:true },
  { id:"80", university:"Istanbul University", country:"Turkey", flag:"🇹🇷", city:"Istanbul", specialty:"Orthodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"TRY 20,000/year (~€550)", totalCost:"~TRY 45,000", livingCost:"~€550/mo", language:"Turkish / English", ielts:"6.0", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Jul 15, 2026", intake:"October", classSize:"8–12", acceptanceRate:"~32%", casesRequired:"100 orthodontic cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:210, satisfactionScore:4.0, careerOutcome:"Orthodontist, Turkey/MENA private practice", modules:["Fixed appliances","Aligners","Cephalometrics","Digital orthodontics","Retention","Thesis"], docsRequired:["Degree","2 references","Turkish B2 or IELTS 6.0","CV"], applicationLink:"https://www.istanbul.edu.tr", accredited:true },
  { id:"82", university:"University of Belgrade", country:"Serbia", flag:"🇷🇸", city:"Belgrade", specialty:"Endodontics", degree:"MSc", duration:"2 years PT", format:"Clinical + Academic", tuition:"€3,000/year", totalCost:"~€8,000", livingCost:"~€600/mo", language:"Serbian / English", ielts:"6.0", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Sep 30, 2026", intake:"October", classSize:"10–15", acceptanceRate:"~40%", casesRequired:"80 endodontic cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:260, satisfactionScore:3.9, careerOutcome:"Endodontist, Balkan region specialist practice", modules:["Endodontic biology","Rotary systems","Surgical endo","Traumatology","Regenerative endo","Thesis"], docsRequired:["Degree","IELTS 6.0 or Serbian B2","2 references","CV"], applicationLink:"https://www.bg.ac.rs", accredited:true },
  { id:"83", university:"Tbilisi State Medical University", country:"Georgia", flag:"🇬🇪", city:"Tbilisi", specialty:"Implantology", degree:"MSc", duration:"2 years PT", format:"Clinical + Academic", tuition:"GEL 8,000/year (~€2,700)", totalCost:"~GEL 18,000", livingCost:"~€500/mo", language:"Georgian / English", ielts:"5.5", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Aug 31, 2026", intake:"October", classSize:"10–16", acceptanceRate:"~45%", casesRequired:"60 implant cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:350, satisfactionScore:3.8, careerOutcome:"Implant specialist, Caucasus / Eastern Europe private practice", modules:["Implant biology","Surgical placement","Bone grafting","Digital planning","Prosthetics","Thesis"], docsRequired:["Degree","IELTS 5.5","2 references","CV"], applicationLink:"https://www.tsmu.edu", accredited:true },
  { id:"84", university:"Ludwig Maximilian University Munich (LMU)", country:"Germany", flag:"🇩🇪", city:"Munich", specialty:"Implantology", degree:"MSc", duration:"2 years PT", format:"Clinical + Academic", tuition:"€5,000/year", totalCost:"~€12,000", livingCost:"~€1,400/mo", language:"German / English", ielts:"6.5", gpa:"Good standing", clinicalExp:"2+ years", deadline:"Apr 15, 2026", intake:"October", classSize:"12–16", acceptanceRate:"~25%", casesRequired:"100 implant cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:true, recognizedKSA:true, recognizedQatar:true, qsRanking:32, satisfactionScore:4.6, careerOutcome:"Implant specialist, DAAD alumni network, Gulf specialist pathway", modules:["Osseointegration","Bone augmentation","Digital workflow","Guided surgery","Prosthetics","Research"], docsRequired:["Degree","German B2 or IELTS 6.5","2 references","CV","Motivation letter"], applicationLink:"https://www.lmu.de", accredited:true },
  { id:"85", university:"University of Heidelberg", country:"Germany", flag:"🇩🇪", city:"Heidelberg", specialty:"Oral Surgery", degree:"MSc", duration:"2 years PT", format:"Clinical + Academic", tuition:"€4,800/year", totalCost:"~€11,500", livingCost:"~€1,200/mo", language:"German / English", ielts:"6.5", gpa:"Good standing", clinicalExp:"2+ years", deadline:"Mar 31, 2026", intake:"October", classSize:"10–14", acceptanceRate:"~22%", casesRequired:"200 surgical cases", thesisRequired:true, interviewRequired:false, scholarship:true, scholarshipDetail:"DAAD scholarship available — full tuition + €934/mo stipend", egyptianGovtFunding:true, recognizedEgypt:true, recognizedUAE:true, recognizedKSA:true, recognizedQatar:true, qsRanking:58, satisfactionScore:4.5, careerOutcome:"Oral surgeon, DAAD alumni network, Gulf/Egyptian specialist", modules:["Dentoalveolar surgery","Facial trauma","Cysts & pathology","Implant surgery","Sedation","Thesis"], docsRequired:["Degree","German B2 or IELTS 6.5","2 references","DAAD application","CV"], applicationLink:"https://www.uni-heidelberg.de", accredited:true },
  { id:"86", university:"Erasmus University Rotterdam (EUR)", country:"Netherlands", flag:"🇳🇱", city:"Rotterdam", specialty:"Periodontology", degree:"MSc", duration:"2 years PT", format:"Clinical + Academic", tuition:"€16,000/year", totalCost:"~€35,000", livingCost:"~€1,500/mo", language:"English", ielts:"6.5", gpa:"Good standing", clinicalExp:"2+ years", deadline:"Apr 30, 2026", intake:"September", classSize:"12–16", acceptanceRate:"~28%", casesRequired:"120 periodontal cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:true, recognizedKSA:false, recognizedQatar:false, qsRanking:50, satisfactionScore:4.4, careerOutcome:"Periodontist, BIG registration, private referral practice", modules:["Periodontal medicine","Implant surgery","Regenerative therapy","Laser periodontology","Research","Thesis"], docsRequired:["Degree","IELTS 6.5","BIG registration (or equivalent)","2 references","Motivation letter"], applicationLink:"https://www.eur.nl", accredited:true },
  { id:"87", university:"University of the Philippines Manila", country:"Philippines", flag:"🇵🇭", city:"Manila", specialty:"Endodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"PHP 80,000/year (~€1,300)", totalCost:"~PHP 180,000", livingCost:"~€500/mo", language:"English / Filipino", ielts:"N/A (English medium)", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Apr 30, 2026", intake:"June", classSize:"4–6", acceptanceRate:"~30%", casesRequired:"100 endodontic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:310, satisfactionScore:3.9, careerOutcome:"Endodontist, Philippines/ASEAN specialist practice", modules:["Endodontic biology","Rotary instrumentation","Surgical endo","Traumatology","Regenerative endo","Thesis"], docsRequired:["Degree","PRC registration","2 references","CV","Interview"], applicationLink:"https://www.upm.edu.ph", accredited:true },
  { id:"88", university:"Aga Khan University", country:"Pakistan", flag:"🇵🇰", city:"Karachi", specialty:"Prosthodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"PKR 500,000/year (~€1,600)", totalCost:"~PKR 1,100,000", livingCost:"~€400/mo", language:"English / Urdu", ielts:"6.0", gpa:"Good standing", clinicalExp:"2+ years", deadline:"Mar 31, 2026", intake:"August", classSize:"4–6", acceptanceRate:"~20%", casesRequired:"150 prosthetic cases", thesisRequired:true, interviewRequired:true, scholarship:true, scholarshipDetail:"AKU Financial Aid available on merit-cum-need basis", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:true, recognizedKSA:false, recognizedQatar:false, qsRanking:290, satisfactionScore:4.1, careerOutcome:"Prosthodontist, Pakistan/Gulf private practice", modules:["Complete prosthodontics","Implant prosthetics","Digital workflow","Esthetics","Occlusion","Thesis"], docsRequired:["Degree","PMDC registration","IELTS 6.0","2 references","Interview"], applicationLink:"https://www.aku.edu", accredited:true },
  { id:"89", university:"National Yang Ming Chiao Tung University", country:"Taiwan", flag:"🇹🇼", city:"Taipei", specialty:"Prosthodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Research", tuition:"TWD 50,000/year (~€1,500)", totalCost:"~TWD 110,000", livingCost:"~€600/mo", language:"Mandarin / English", ielts:"6.0 (English track)", gpa:"Good standing", clinicalExp:"2+ years", deadline:"Mar 31, 2026", intake:"September", classSize:"6–8", acceptanceRate:"~22%", casesRequired:"150 prosthetic cases", thesisRequired:true, interviewRequired:true, scholarship:true, scholarshipDetail:"Taiwan ICDF Scholarship — full tuition + NTD 15,000/mo stipend", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:150, satisfactionScore:4.3, careerOutcome:"Prosthodontist, Taiwan/Asia-Pacific specialist, research career", modules:["Complete prosthodontics","Implant prosthetics","Digital workflow","Esthetics","Biomechanics","Thesis"], docsRequired:["Degree","IELTS 6.0 or TOCFL","2 references","Research proposal","ICDF application (if scholarship)"], applicationLink:"https://www.nycu.edu.tw", accredited:true },
  { id:"90", university:"American University of Sharjah", country:"United Arab Emirates", flag:"🇦🇪", city:"Sharjah", specialty:"Digital Dentistry", degree:"MSc", duration:"2 years PT", format:"Academic + Practical", tuition:"AED 65,000/year (~€16,000)", totalCost:"~AED 140,000", livingCost:"~AED 4,500/mo", language:"English", ielts:"6.5", gpa:"Good standing", clinicalExp:"1+ year", deadline:"May 31, 2026", intake:"September", classSize:"15–20", acceptanceRate:"~35%", casesRequired:"Portfolio-based", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:true, recognizedKSA:true, recognizedQatar:true, qsRanking:210, satisfactionScore:4.1, careerOutcome:"Digital specialist, Gulf lab/clinic integration, tech career", modules:["CAD/CAM","3D printing","Digital impressions","AI diagnostics","Workflow integration","Thesis"], docsRequired:["Degree","IELTS 6.5","DHA/DOH registration","1 reference","Portfolio"], applicationLink:"https://www.aus.edu", accredited:true },
  { id:"91", university:"University of Bahrain", country:"Bahrain", flag:"🇧🇭", city:"Manama", specialty:"Prosthodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"BHD 4,000/year (~€9,700)", totalCost:"~BHD 9,000", livingCost:"~BHD 500/mo", language:"English / Arabic", ielts:"6.0", gpa:"Good standing", clinicalExp:"2+ years", deadline:"Apr 30, 2026", intake:"September", classSize:"4–6", acceptanceRate:"~25%", casesRequired:"160 prosthetic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:true, recognizedKSA:true, recognizedQatar:true, qsRanking:300, satisfactionScore:4.0, careerOutcome:"Prosthodontist, Gulf specialist practice, NHRA Bahrain pathway", modules:["Complete prosthodontics","Implant prosthetics","Digital workflow","Esthetics","Occlusion","Thesis"], docsRequired:["Degree","NHRA registration","IELTS 6.0","2 references","CV","Interview"], applicationLink:"https://www.uob.edu.bh", accredited:true },
  { id:"92", university:"Universitas Indonesia", country:"Indonesia", flag:"🇮🇩", city:"Jakarta", specialty:"Oral Surgery", degree:"SpBM (Specialist)", duration:"3 years FT", format:"Clinical + Research", tuition:"IDR 25,000,000/year (~€1,500)", totalCost:"~IDR 80,000,000", livingCost:"~€500/mo", language:"Indonesian / English", ielts:"N/A", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Jul 31, 2026", intake:"September", classSize:"6–8", acceptanceRate:"~30%", casesRequired:"250+ surgical cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:195, satisfactionScore:4.0, careerOutcome:"Oral surgeon, Indonesia specialist practice, academic post", modules:["Dentoalveolar surgery","Cysts & pathology","Facial trauma","Implant surgery","Sedation","Thesis"], docsRequired:["Degree","STR registration","2 references","CV","Interview"], applicationLink:"https://www.ui.ac.id", accredited:true },
  { id:"93", university:"University of Ghana – Korle Bu", country:"Ghana", flag:"🇬🇭", city:"Accra", specialty:"Prosthodontics", degree:"Fellowship / MSc", duration:"3 years FT", format:"Clinical + Academic", tuition:"GHS 10,000/year (~€700)", totalCost:"~GHS 32,000", livingCost:"~€400/mo", language:"English", ielts:"N/A (English medium)", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Aug 31, 2026", intake:"October", classSize:"2–4", acceptanceRate:"~25%", casesRequired:"150 prosthetic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:450, satisfactionScore:3.7, careerOutcome:"Prosthodontist, West Africa specialist practice", modules:["Complete prosthodontics","Removable prosthetics","Implant introduction","Esthetics","Occlusion","Thesis"], docsRequired:["Degree","MDC registration","2 references","CV","Interview"], applicationLink:"https://www.ug.edu.gh", accredited:true },
  { id:"94", university:"University of Nairobi – Advanced Prosthodontics", country:"Kenya", flag:"🇰🇪", city:"Nairobi", specialty:"Prosthodontics", degree:"MMed (Dent)", duration:"3 years FT", format:"Clinical + Research", tuition:"KES 220,000/year (~€1,500)", totalCost:"~KES 700,000", livingCost:"~€480/mo", language:"English", ielts:"N/A (English medium)", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Jun 30, 2026", intake:"September", classSize:"2–4", acceptanceRate:"~20%", casesRequired:"180 prosthetic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:380, satisfactionScore:3.8, careerOutcome:"Prosthodontist, East Africa specialist, hospital post", modules:["Complete prosthodontics","Implant prosthetics","Esthetics","Occlusion","Maxillofacial intro","Thesis"], docsRequired:["Degree","Kenya registration","2 references","CV","Interview"], applicationLink:"https://www.uonbi.ac.ke", accredited:true },
  { id:"95", university:"University of Toronto – Orthodontics", country:"Canada", flag:"🇨🇦", city:"Toronto", specialty:"Orthodontics", degree:"MSD", duration:"3 years FT", format:"Clinical", tuition:"CAD 30,000/year", totalCost:"~CAD 100,000", livingCost:"~CAD 2,500/mo", language:"English", ielts:"7.0", gpa:"B+ or above", clinicalExp:"2+ years", deadline:"Nov 15, 2025", intake:"July", classSize:"4–5", acceptanceRate:"~8%", casesRequired:"120 orthodontic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:true, recognizedKSA:true, recognizedQatar:false, qsRanking:18, satisfactionScore:4.9, careerOutcome:"Orthodontist, RCDC specialist, Canadian and Gulf pathway", modules:["Fixed appliances","Aligners","Cephalometrics","Orthognathic planning","Digital orthodontics","Research seminar"], docsRequired:["Degree","NDEB assessment","3 references","Personal statement","IELTS 7.0","Interview"], applicationLink:"https://www.utoronto.ca", accredited:true },
  { id:"96", university:"Universidade Nova de Lisboa – NOVA Medical School", country:"Portugal", flag:"🇵🇹", city:"Lisbon", specialty:"Digital Dentistry", degree:"MSc", duration:"1.5 years PT", format:"Academic + Online", tuition:"€5,500 total", totalCost:"~€7,000", livingCost:"~€900/mo", language:"Portuguese / English", ielts:"6.0", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Jul 31, 2026", intake:"October", classSize:"20–25", acceptanceRate:"~45%", casesRequired:"Portfolio-based", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:155, satisfactionScore:4.2, careerOutcome:"Digital specialist, CAD/CAM workflow, lab integration", modules:["CAD/CAM","3D printing","Digital impressions","AI tools","Workflow management","Thesis"], docsRequired:["Degree","IELTS 6.0 or Portuguese B2","1 reference","Portfolio"], applicationLink:"https://www.nms.unl.pt", accredited:true },
  { id:"97", university:"Universiti Kebangsaan Malaysia (UKM)", country:"Malaysia", flag:"🇲🇾", city:"Kuala Lumpur", specialty:"Endodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Research", tuition:"MYR 20,000/year (~€4,000)", totalCost:"~MYR 45,000", livingCost:"~€650/mo", language:"English / Malay", ielts:"6.0", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Mar 31, 2026", intake:"July", classSize:"4–6", acceptanceRate:"~22%", casesRequired:"100 endodontic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:140, satisfactionScore:4.2, careerOutcome:"Endodontist, Malaysia/ASEAN specialist practice", modules:["Endodontic biology","Advanced RCT","Surgical endo","Traumatology","Regenerative endo","Thesis"], docsRequired:["Degree","MMC registration","IELTS 6.0","2 references","Interview"], applicationLink:"https://www.ukm.my", accredited:true },
  { id:"98", university:"Universidad Peruana Cayetano Heredia (UPCH)", country:"Peru", flag:"🇵🇪", city:"Lima", specialty:"Implantology", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"PEN 15,000/year (~€3,700)", totalCost:"~PEN 35,000", livingCost:"~€550/mo", language:"Spanish", ielts:"N/A – Spanish required", gpa:"Good standing", clinicalExp:"1+ year", deadline:"May 31, 2026", intake:"March", classSize:"6–10", acceptanceRate:"~30%", casesRequired:"80 implant cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:320, satisfactionScore:4.0, careerOutcome:"Implant specialist, Peru/Latin America practice", modules:["Implant biology","Surgical placement","Bone grafting","Digital planning","Prosthetics","Thesis"], docsRequired:["Degree","2 references","CV","Interview"], applicationLink:"https://www.upch.edu.pe", accredited:true },
  { id:"99", university:"Ain Shams University", country:"Egypt", flag:"🇪🇬", city:"Cairo", specialty:"Orthodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Research", tuition:"EGP 25,000/year (~€500)", totalCost:"~EGP 55,000", livingCost:"~€280/mo", language:"Arabic / English", ielts:"N/A", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Oct 31, 2026", intake:"October", classSize:"6–10", acceptanceRate:"~30%", casesRequired:"80 orthodontic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:230, satisfactionScore:4.0, careerOutcome:"Orthodontist, Egyptian Syndicate specialist, private clinic", modules:["Fixed appliances","Removable appliances","Cephalometrics","Digital orthodontics","Retention","Thesis"], docsRequired:["Degree","2 references","CV","Interview"], applicationLink:"https://www.asu.edu.eg", accredited:true },
  { id:"100", university:"Alexandria University", country:"Egypt", flag:"🇪🇬", city:"Alexandria", specialty:"Oral Surgery", degree:"MSc", duration:"2 years FT", format:"Clinical + Research", tuition:"EGP 20,000/year (~€400)", totalCost:"~EGP 45,000", livingCost:"~€250/mo", language:"Arabic / English", ielts:"N/A", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Sep 30, 2026", intake:"October", classSize:"6–8", acceptanceRate:"~35%", casesRequired:"200 surgical cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:280, satisfactionScore:3.9, careerOutcome:"Oral surgeon, Egyptian Syndicate specialist, hospital post", modules:["Dentoalveolar surgery","Cysts & pathology","Facial trauma","Preprosthetic surgery","Sedation","Thesis"], docsRequired:["Degree","2 references","CV","Interview"], applicationLink:"https://www.alexu.edu.eg", accredited:true },

  // === BATCH 2: 100 NEW COUNTRIES ===

  // --- Eastern & Southern Europe ---
  { id:"101", university:"Carol Davila University of Medicine", country:"Romania", flag:"🇷🇴", city:"Bucharest", specialty:"Orthodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"€4,500/year", totalCost:"~€11,000", livingCost:"~€650/mo", language:"Romanian / English", ielts:"6.0", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Jul 31, 2026", intake:"October", classSize:"10–15", acceptanceRate:"~35%", casesRequired:"80 orthodontic cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:300, satisfactionScore:3.9, careerOutcome:"Orthodontist, Eastern Europe specialist, EU practice pathway", modules:["Fixed appliances","Aligners","Cephalometrics","Digital orthodontics","Retention","Thesis"], docsRequired:["Degree","IELTS 6.0 or Romanian B2","2 references","CV"], applicationLink:"https://www.umfcd.ro", accredited:true },
  { id:"102", university:"University of Zagreb", country:"Croatia", flag:"🇭🇷", city:"Zagreb", specialty:"Implantology", degree:"MSc", duration:"2 years PT", format:"Clinical + Academic", tuition:"€5,000/year", totalCost:"~€12,000", livingCost:"~€800/mo", language:"Croatian / English", ielts:"6.0", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Jun 30, 2026", intake:"October", classSize:"10–14", acceptanceRate:"~32%", casesRequired:"80 implant cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:320, satisfactionScore:3.9, careerOutcome:"Implant specialist, Croatia/EU private practice", modules:["Implant biology","Surgical placement","Bone augmentation","Digital planning","Prosthetics","Thesis"], docsRequired:["Degree","IELTS 6.0 or Croatian B2","2 references","CV"], applicationLink:"https://www.unizg.hr", accredited:true },
  { id:"103", university:"Medical University of Sofia", country:"Bulgaria", flag:"🇧🇬", city:"Sofia", specialty:"Endodontics", degree:"MSc", duration:"2 years PT", format:"Clinical + Academic", tuition:"€3,500/year", totalCost:"~€9,000", livingCost:"~€600/mo", language:"Bulgarian / English", ielts:"6.0", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Aug 31, 2026", intake:"October", classSize:"10–16", acceptanceRate:"~38%", casesRequired:"80 endodontic cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:340, satisfactionScore:3.8, careerOutcome:"Endodontist, Bulgaria/EU specialist practice", modules:["Endodontic biology","Rotary instrumentation","Surgical endo","Traumatology","Regenerative endo","Thesis"], docsRequired:["Degree","IELTS 6.0 or Bulgarian B2","2 references","CV"], applicationLink:"https://www.mu-sofia.bg", accredited:true },
  { id:"104", university:"Bogomolets National Medical University", country:"Ukraine", flag:"🇺🇦", city:"Kyiv", specialty:"Prosthodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"USD 4,000/year", totalCost:"~USD 10,000", livingCost:"~€400/mo", language:"Ukrainian / English", ielts:"5.5", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Aug 1, 2026", intake:"September", classSize:"10–15", acceptanceRate:"~40%", casesRequired:"150 prosthetic cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:360, satisfactionScore:3.7, careerOutcome:"Prosthodontist, Ukraine/Eastern Europe specialist", modules:["Complete prosthodontics","Implant prosthetics","Digital workflow","Esthetics","Occlusion","Thesis"], docsRequired:["Degree","IELTS 5.5 or Ukrainian B2","2 references","CV"], applicationLink:"https://www.nmu.ua", accredited:true },
  { id:"105", university:"Comenius University Bratislava", country:"Slovakia", flag:"🇸🇰", city:"Bratislava", specialty:"Oral Surgery", degree:"MSc", duration:"2 years FT", format:"Clinical", tuition:"€4,200/year", totalCost:"~€10,500", livingCost:"~€750/mo", language:"Slovak / English", ielts:"6.0", gpa:"Good standing", clinicalExp:"2+ years", deadline:"May 31, 2026", intake:"September", classSize:"8–12", acceptanceRate:"~28%", casesRequired:"200 surgical cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:330, satisfactionScore:3.9, careerOutcome:"Oral surgeon, Slovakia/Central Europe specialist", modules:["Dentoalveolar surgery","Cysts & pathology","Facial trauma","Implant surgery","Sedation","Thesis"], docsRequired:["Degree","IELTS 6.0 or Slovak B2","2 references","CV","Interview"], applicationLink:"https://www.uniba.sk", accredited:true },
  { id:"106", university:"University of Ljubljana", country:"Slovenia", flag:"🇸🇮", city:"Ljubljana", specialty:"Implantology", degree:"MSc", duration:"2 years PT", format:"Clinical + Academic", tuition:"€4,800/year", totalCost:"~€11,500", livingCost:"~€900/mo", language:"Slovenian / English", ielts:"6.0", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Jun 15, 2026", intake:"October", classSize:"8–12", acceptanceRate:"~30%", casesRequired:"80 implant cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:310, satisfactionScore:4.0, careerOutcome:"Implant specialist, Slovenia/EU practice", modules:["Implant biology","Surgical placement","Bone grafting","Digital planning","Prosthetics","Thesis"], docsRequired:["Degree","IELTS 6.0 or Slovenian B2","2 references","CV"], applicationLink:"https://www.uni-lj.si", accredited:true },
  { id:"107", university:"University of Tartu", country:"Estonia", flag:"🇪🇪", city:"Tartu", specialty:"Endodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Research", tuition:"€5,000/year", totalCost:"~€12,000", livingCost:"~€800/mo", language:"Estonian / English", ielts:"6.5", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Apr 30, 2026", intake:"September", classSize:"6–10", acceptanceRate:"~28%", casesRequired:"100 endodontic cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:285, satisfactionScore:4.1, careerOutcome:"Endodontist, Baltic states specialist, EU practice", modules:["Endodontic biology","Advanced RCT","Surgical endo","Traumatology","Regenerative endo","Thesis"], docsRequired:["Degree","IELTS 6.5","2 references","CV"], applicationLink:"https://www.ut.ee", accredited:true },
  { id:"108", university:"Riga Stradins University", country:"Latvia", flag:"🇱🇻", city:"Riga", specialty:"Orthodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"€5,500/year", totalCost:"~€13,000", livingCost:"~€750/mo", language:"Latvian / English", ielts:"6.0", gpa:"Good standing", clinicalExp:"1+ year", deadline:"May 15, 2026", intake:"September", classSize:"8–12", acceptanceRate:"~30%", casesRequired:"80 orthodontic cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:295, satisfactionScore:4.0, careerOutcome:"Orthodontist, Baltic / EU specialist pathway", modules:["Fixed appliances","Aligners","Cephalometrics","Digital orthodontics","Retention","Thesis"], docsRequired:["Degree","IELTS 6.0","2 references","CV"], applicationLink:"https://www.rsu.lv", accredited:true },
  { id:"109", university:"Lithuanian University of Health Sciences", country:"Lithuania", flag:"🇱🇹", city:"Kaunas", specialty:"Prosthodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"€5,200/year", totalCost:"~€12,500", livingCost:"~€700/mo", language:"Lithuanian / English", ielts:"6.0", gpa:"Good standing", clinicalExp:"2+ years", deadline:"May 31, 2026", intake:"September", classSize:"8–12", acceptanceRate:"~30%", casesRequired:"150 prosthetic cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:290, satisfactionScore:4.0, careerOutcome:"Prosthodontist, Baltic / EU private practice", modules:["Complete prosthodontics","Implant prosthetics","Digital workflow","Esthetics","Occlusion","Thesis"], docsRequired:["Degree","IELTS 6.0","2 references","CV"], applicationLink:"https://www.lsmuni.lt", accredited:true },
  { id:"110", university:"University of Cyprus", country:"Cyprus", flag:"🇨🇾", city:"Nicosia", specialty:"Implantology", degree:"MSc", duration:"2 years PT", format:"Clinical + Academic", tuition:"€7,000/year", totalCost:"~€16,000", livingCost:"~€1,000/mo", language:"Greek / English", ielts:"6.5", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Apr 30, 2026", intake:"September", classSize:"10–14", acceptanceRate:"~32%", casesRequired:"80 implant cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:280, satisfactionScore:4.1, careerOutcome:"Implant specialist, Cyprus/EU specialist pathway, MENA practice", modules:["Implant biology","Bone augmentation","Guided surgery","Digital planning","Prosthetics","Thesis"], docsRequired:["Degree","IELTS 6.5 or Greek B2","2 references","CV"], applicationLink:"https://www.ucy.ac.cy", accredited:true },
  { id:"111", university:"University of Malta", country:"Malta", flag:"🇲🇹", city:"Valletta", specialty:"Oral Surgery", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"€8,000/year", totalCost:"~€20,000", livingCost:"~€1,100/mo", language:"English / Maltese", ielts:"6.5", gpa:"Good standing", clinicalExp:"2+ years", deadline:"Mar 31, 2026", intake:"October", classSize:"6–10", acceptanceRate:"~25%", casesRequired:"200 surgical cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:true, recognizedKSA:false, recognizedQatar:false, qsRanking:320, satisfactionScore:4.0, careerOutcome:"Oral surgeon, Malta/UK specialist pathway, EU practice", modules:["Dentoalveolar surgery","Cysts & pathology","Facial trauma","Implant surgery","Sedation","Thesis"], docsRequired:["Degree","IELTS 6.5","2 references","CV","Interview"], applicationLink:"https://www.um.edu.mt", accredited:true },
  { id:"112", university:"Yerevan State Medical University", country:"Armenia", flag:"🇦🇲", city:"Yerevan", specialty:"Orthodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"USD 3,500/year", totalCost:"~USD 8,500", livingCost:"~€450/mo", language:"Armenian / English", ielts:"5.5", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Jul 31, 2026", intake:"September", classSize:"8–14", acceptanceRate:"~40%", casesRequired:"80 orthodontic cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:400, satisfactionScore:3.7, careerOutcome:"Orthodontist, Armenia/Caucasus private practice", modules:["Fixed appliances","Removable appliances","Cephalometrics","Aligners","Retention","Thesis"], docsRequired:["Degree","IELTS 5.5 or Armenian B2","2 references","CV"], applicationLink:"https://www.ysmu.am", accredited:true },
  { id:"113", university:"Azerbaijan Medical University", country:"Azerbaijan", flag:"🇦🇿", city:"Baku", specialty:"Implantology", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"AZN 4,000/year (~€2,200)", totalCost:"~AZN 9,500", livingCost:"~€500/mo", language:"Azerbaijani / English", ielts:"5.5", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Jul 15, 2026", intake:"September", classSize:"8–12", acceptanceRate:"~38%", casesRequired:"60 implant cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:420, satisfactionScore:3.7, careerOutcome:"Implant specialist, Azerbaijan/Caucasus private practice", modules:["Implant biology","Surgical placement","Bone grafting","Digital planning","Prosthetics","Thesis"], docsRequired:["Degree","IELTS 5.5","2 references","CV"], applicationLink:"https://www.amu.edu.az", accredited:true },
  { id:"114", university:"University of Iceland (HÍ)", country:"Iceland", flag:"🇮🇸", city:"Reykjavik", specialty:"Oral Surgery", degree:"MSc", duration:"2 years FT", format:"Clinical + Research", tuition:"ISK 0 (Nordic citizens) / ISK 800,000/year (international)", totalCost:"~ISK 1,700,000", livingCost:"~€2,000/mo", language:"Icelandic / English", ielts:"6.5", gpa:"Good standing", clinicalExp:"2+ years", deadline:"Feb 15, 2026", intake:"August", classSize:"4–6", acceptanceRate:"~20%", casesRequired:"200 surgical cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:260, satisfactionScore:4.2, careerOutcome:"Oral surgeon, Nordic specialist pathway", modules:["Dentoalveolar surgery","Cysts & pathology","Facial trauma","Implant surgery","Sedation","Research"], docsRequired:["Degree","IELTS 6.5","2 references","CV","Interview"], applicationLink:"https://english.hi.is", accredited:true },
  { id:"115", university:"University of Tirana", country:"Albania", flag:"🇦🇱", city:"Tirana", specialty:"Endodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"€3,000/year", totalCost:"~€7,500", livingCost:"~€500/mo", language:"Albanian / English", ielts:"5.5", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Aug 31, 2026", intake:"October", classSize:"10–15", acceptanceRate:"~45%", casesRequired:"80 endodontic cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:450, satisfactionScore:3.6, careerOutcome:"Endodontist, Albania/Balkan specialist practice", modules:["Endodontic biology","Rotary instrumentation","Surgical endo","Traumatology","Regenerative endo","Thesis"], docsRequired:["Degree","IELTS 5.5 or Albanian B2","2 references","CV"], applicationLink:"https://www.unitir.edu.al", accredited:true },
  { id:"116", university:"University of Sarajevo", country:"Bosnia & Herzegovina", flag:"🇧🇦", city:"Sarajevo", specialty:"Prosthodontics", degree:"MSc", duration:"2 years PT", format:"Clinical + Academic", tuition:"€3,200/year", totalCost:"~€8,000", livingCost:"~€550/mo", language:"Bosnian / English", ielts:"5.5", gpa:"Good standing", clinicalExp:"2+ years", deadline:"Sep 15, 2026", intake:"October", classSize:"8–12", acceptanceRate:"~40%", casesRequired:"120 prosthetic cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:430, satisfactionScore:3.7, careerOutcome:"Prosthodontist, Balkans specialist, EU practice pathway", modules:["Complete prosthodontics","Implant prosthetics","Digital workflow","Esthetics","Occlusion","Thesis"], docsRequired:["Degree","IELTS 5.5 or Bosnian B2","2 references","CV"], applicationLink:"https://www.unsa.ba", accredited:true },
  { id:"117", university:"Ss. Cyril and Methodius University", country:"North Macedonia", flag:"🇲🇰", city:"Skopje", specialty:"Oral Surgery", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"€3,000/year", totalCost:"~€7,500", livingCost:"~€500/mo", language:"Macedonian / English", ielts:"5.5", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Aug 31, 2026", intake:"October", classSize:"8–12", acceptanceRate:"~42%", casesRequired:"150 surgical cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:460, satisfactionScore:3.6, careerOutcome:"Oral surgeon, North Macedonia/Balkans specialist", modules:["Dentoalveolar surgery","Cysts & pathology","Implant surgery","Facial trauma","Sedation","Thesis"], docsRequired:["Degree","IELTS 5.5","2 references","CV"], applicationLink:"https://www.ukim.edu.mk", accredited:true },
  { id:"118", university:"University of Montenegro", country:"Montenegro", flag:"🇲🇪", city:"Podgorica", specialty:"Implantology", degree:"MSc", duration:"2 years PT", format:"Clinical + Academic", tuition:"€3,500/year", totalCost:"~€9,000", livingCost:"~€600/mo", language:"Montenegrin / English", ielts:"5.5", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Sep 30, 2026", intake:"October", classSize:"8–12", acceptanceRate:"~44%", casesRequired:"60 implant cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:470, satisfactionScore:3.6, careerOutcome:"Implant specialist, Montenegro/Balkan private practice", modules:["Implant biology","Surgical placement","Bone grafting","Digital workflow","Prosthetics","Thesis"], docsRequired:["Degree","IELTS 5.5","2 references","CV"], applicationLink:"https://www.ucg.ac.me", accredited:true },
  { id:"119", university:"Belarusian State Medical University", country:"Belarus", flag:"🇧🇾", city:"Minsk", specialty:"Endodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Research", tuition:"USD 3,800/year", totalCost:"~USD 9,000", livingCost:"~€450/mo", language:"Russian / English", ielts:"5.5", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Jul 31, 2026", intake:"September", classSize:"8–14", acceptanceRate:"~42%", casesRequired:"80 endodontic cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:440, satisfactionScore:3.7, careerOutcome:"Endodontist, Belarus/CIS specialist practice", modules:["Endodontic biology","Rotary instrumentation","Surgical endo","Traumatology","Regenerative endo","Thesis"], docsRequired:["Degree","IELTS 5.5 or Russian B2","2 references","CV"], applicationLink:"https://www.bsmu.by", accredited:true },
  { id:"120", university:"State Medical University of Moldova", country:"Moldova", flag:"🇲🇩", city:"Chișinău", specialty:"Prosthodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"€2,800/year", totalCost:"~€7,000", livingCost:"~€380/mo", language:"Romanian / English", ielts:"5.5", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Aug 31, 2026", intake:"October", classSize:"8–14", acceptanceRate:"~45%", casesRequired:"120 prosthetic cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:460, satisfactionScore:3.6, careerOutcome:"Prosthodontist, Moldova/Romania specialist pathway", modules:["Complete prosthodontics","Implant prosthetics","Esthetics","Occlusion","Digital intro","Thesis"], docsRequired:["Degree","IELTS 5.5 or Romanian B2","2 references","CV"], applicationLink:"https://usmf.md", accredited:true },

  // --- MENA & North Africa (new countries) ---
  { id:"121", university:"University of Algiers 1 (Ben Youcef Benkhedda)", country:"Algeria", flag:"🇩🇿", city:"Algiers", specialty:"Implantology", degree:"DES", duration:"3 years FT", format:"Clinical + Academic", tuition:"DZD 0 (nationals) / DZD 80,000/year (international)", totalCost:"~DZD 250,000", livingCost:"~€350/mo", language:"French / Arabic", ielts:"N/A – French required", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Sep 30, 2026", intake:"October", classSize:"8–12", acceptanceRate:"~35%", casesRequired:"80 implant cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:480, satisfactionScore:3.6, careerOutcome:"Implant specialist, Algeria/Maghreb private practice", modules:["Implant biology","Surgical placement","Bone augmentation","Digital planning","Prosthetics","Thesis"], docsRequired:["Degree","French B2","2 references","CV"], applicationLink:"https://www.univ-alger.dz", accredited:true },
  { id:"122", university:"Al-Fateh University (University of Tripoli)", country:"Libya", flag:"🇱🇾", city:"Tripoli", specialty:"Orthodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"LYD 500/year (~€100)", totalCost:"~LYD 1,200", livingCost:"~€300/mo", language:"Arabic / English", ielts:"N/A", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Sep 30, 2026", intake:"October", classSize:"6–10", acceptanceRate:"~40%", casesRequired:"80 orthodontic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:500, satisfactionScore:3.5, careerOutcome:"Orthodontist, Libya/North Africa specialist practice", modules:["Fixed appliances","Removable appliances","Cephalometrics","Retention","Clinical audit","Thesis"], docsRequired:["Degree","2 references","CV","Interview"], applicationLink:"https://www.uot.edu.ly", accredited:true },
  { id:"123", university:"University of Khartoum", country:"Sudan", flag:"🇸🇩", city:"Khartoum", specialty:"Prosthodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Research", tuition:"SDG 50,000/year (~€400)", totalCost:"~SDG 120,000", livingCost:"~€300/mo", language:"Arabic / English", ielts:"N/A", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Aug 31, 2026", intake:"October", classSize:"4–8", acceptanceRate:"~30%", casesRequired:"150 prosthetic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:500, satisfactionScore:3.5, careerOutcome:"Prosthodontist, Sudan/East Africa specialist", modules:["Complete prosthodontics","Fixed prosthodontics","Implant intro","Esthetics","Occlusion","Thesis"], docsRequired:["Degree","2 references","CV","Interview"], applicationLink:"https://www.uofk.edu", accredited:true },
  { id:"124", university:"College of Dentistry – University of Baghdad", country:"Iraq", flag:"🇮🇶", city:"Baghdad", specialty:"Endodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Research", tuition:"IQD 0 (nationals) / IQD 3,000,000/year (international)", totalCost:"~IQD 7,000,000", livingCost:"~€400/mo", language:"Arabic / English", ielts:"N/A", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Aug 31, 2026", intake:"October", classSize:"6–10", acceptanceRate:"~30%", casesRequired:"100 endodontic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:500, satisfactionScore:3.5, careerOutcome:"Endodontist, Iraq/Gulf private practice", modules:["Endodontic biology","Rotary instrumentation","Surgical endo","Traumatology","Regenerative endo","Thesis"], docsRequired:["Degree","2 references","CV","Interview"], applicationLink:"https://www.uobaghdad.edu.iq", accredited:true },
  { id:"125", university:"Tehran University of Medical Sciences", country:"Iran", flag:"🇮🇷", city:"Tehran", specialty:"Implantology", degree:"MSc", duration:"2 years FT", format:"Clinical + Research", tuition:"IRR 0 (nationals) / USD 5,000/year (international)", totalCost:"~USD 12,000", livingCost:"~€400/mo", language:"Persian / English", ielts:"6.0", gpa:"Good standing", clinicalExp:"2+ years", deadline:"Jul 31, 2026", intake:"September", classSize:"6–10", acceptanceRate:"~25%", casesRequired:"80 implant cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:200, satisfactionScore:4.0, careerOutcome:"Implant specialist, Iran/regional private practice", modules:["Implant biology","Bone augmentation","Digital planning","Guided surgery","Prosthetics","Thesis"], docsRequired:["Degree","IELTS 6.0 or Persian B2","2 references","CV","Interview"], applicationLink:"https://tums.ac.ir", accredited:true },

  // --- Sub-Saharan Africa ---
  { id:"126", university:"Addis Ababa University", country:"Ethiopia", flag:"🇪🇹", city:"Addis Ababa", specialty:"Oral Surgery", degree:"MSc", duration:"2 years FT", format:"Clinical + Research", tuition:"ETB 30,000/year (~€550)", totalCost:"~ETB 70,000", livingCost:"~€300/mo", language:"Amharic / English", ielts:"N/A (English medium)", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Aug 31, 2026", intake:"October", classSize:"4–6", acceptanceRate:"~25%", casesRequired:"200 surgical cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:500, satisfactionScore:3.6, careerOutcome:"Oral surgeon, Ethiopia/East Africa hospital specialist", modules:["Dentoalveolar surgery","Cysts & pathology","Facial trauma","Preprosthetic surgery","Sedation","Thesis"], docsRequired:["Degree","2 references","CV","Interview"], applicationLink:"https://www.aau.edu.et", accredited:true },
  { id:"127", university:"Muhimbili University of Health and Allied Sciences", country:"Tanzania", flag:"🇹🇿", city:"Dar es Salaam", specialty:"Prosthodontics", degree:"MMed (Dent)", duration:"3 years FT", format:"Clinical + Research", tuition:"TZS 3,000,000/year (~€1,100)", totalCost:"~TZS 9,500,000", livingCost:"~€350/mo", language:"Swahili / English", ielts:"N/A (English medium)", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Sep 30, 2026", intake:"January", classSize:"2–4", acceptanceRate:"~25%", casesRequired:"150 prosthetic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:500, satisfactionScore:3.5, careerOutcome:"Prosthodontist, East Africa hospital post, academic", modules:["Complete prosthodontics","Implant intro","Esthetics","Occlusion","Maxillofacial intro","Thesis"], docsRequired:["Degree","Tanzania medical council registration","2 references","CV"], applicationLink:"https://www.muhas.ac.tz", accredited:true },
  { id:"128", university:"Makerere University", country:"Uganda", flag:"🇺🇬", city:"Kampala", specialty:"Endodontics", degree:"MMed (Oral Surgery / Dentistry)", duration:"3 years FT", format:"Clinical + Research", tuition:"UGX 8,000,000/year (~€2,000)", totalCost:"~UGX 25,000,000", livingCost:"~€350/mo", language:"English", ielts:"N/A (English medium)", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Aug 31, 2026", intake:"August", classSize:"2–4", acceptanceRate:"~25%", casesRequired:"100 endodontic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:500, satisfactionScore:3.6, careerOutcome:"Endodontist, Uganda/East Africa hospital specialist", modules:["Endodontic biology","Advanced RCT","Surgical endo","Traumatology","Regenerative endo","Thesis"], docsRequired:["Degree","Uganda Medical & Dental Practitioners Council reg.","2 references","CV"], applicationLink:"https://www.mak.ac.ug", accredited:true },
  { id:"129", university:"University of Yaoundé I", country:"Cameroon", flag:"🇨🇲", city:"Yaoundé", specialty:"Implantology", degree:"DES", duration:"3 years FT", format:"Clinical + Academic", tuition:"XAF 600,000/year (~€900)", totalCost:"~XAF 2,000,000", livingCost:"~€350/mo", language:"French / English", ielts:"N/A", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Sep 30, 2026", intake:"October", classSize:"4–8", acceptanceRate:"~35%", casesRequired:"60 implant cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:500, satisfactionScore:3.5, careerOutcome:"Implant specialist, Cameroon/Central Africa private practice", modules:["Implant biology","Surgical placement","Bone grafting","Digital intro","Prosthetics","Thesis"], docsRequired:["Degree","French B2","2 references","CV"], applicationLink:"https://www.uy1.uninet.cm", accredited:true },
  { id:"130", university:"Cheikh Anta Diop University (UCAD)", country:"Senegal", flag:"🇸🇳", city:"Dakar", specialty:"Orthodontics", degree:"DES", duration:"3 years FT", format:"Clinical + Academic", tuition:"XOF 500,000/year (~€760)", totalCost:"~XOF 1,700,000", livingCost:"~€400/mo", language:"French", ielts:"N/A – French required", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Sep 30, 2026", intake:"October", classSize:"4–8", acceptanceRate:"~35%", casesRequired:"80 orthodontic cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:500, satisfactionScore:3.5, careerOutcome:"Orthodontist, Senegal/West Africa specialist", modules:["Fixed appliances","Removable appliances","Cephalometrics","Retention","Research","Thesis"], docsRequired:["Degree","French B2","2 references","CV"], applicationLink:"https://www.ucad.sn", accredited:true },
  { id:"131", university:"Félix Houphouët-Boigny University", country:"Ivory Coast", flag:"🇨🇮", city:"Abidjan", specialty:"Endodontics", degree:"DES", duration:"3 years FT", format:"Clinical + Academic", tuition:"XOF 450,000/year (~€685)", totalCost:"~XOF 1,500,000", livingCost:"~€400/mo", language:"French", ielts:"N/A – French required", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Sep 30, 2026", intake:"October", classSize:"4–8", acceptanceRate:"~38%", casesRequired:"80 endodontic cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:500, satisfactionScore:3.5, careerOutcome:"Endodontist, Ivory Coast/West Africa specialist", modules:["Endodontic biology","Rotary instrumentation","Surgical endo","Traumatology","Regenerative endo","Thesis"], docsRequired:["Degree","French B2","2 references","CV"], applicationLink:"https://www.univ-fhb.edu.ci", accredited:true },
  { id:"132", university:"University of Zimbabwe", country:"Zimbabwe", flag:"🇿🇼", city:"Harare", specialty:"Oral Surgery", degree:"MMed (Oral Surgery)", duration:"3 years FT", format:"Clinical + Research", tuition:"USD 3,000/year", totalCost:"~USD 9,500", livingCost:"~€350/mo", language:"English", ielts:"N/A (English medium)", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Aug 31, 2026", intake:"March", classSize:"2–4", acceptanceRate:"~22%", casesRequired:"250 surgical cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:500, satisfactionScore:3.6, careerOutcome:"Oral surgeon, Zimbabwe/Southern Africa hospital post", modules:["Dentoalveolar surgery","Cysts & pathology","Facial trauma","Preprosthetic surgery","Sedation","Thesis"], docsRequired:["Degree","Medical & Dental Practitioners Council reg.","2 references","CV"], applicationLink:"https://www.uz.ac.zw", accredited:true },
  { id:"133", university:"University of Zambia", country:"Zambia", flag:"🇿🇲", city:"Lusaka", specialty:"Implantology", degree:"MMed (Dent)", duration:"2 years FT", format:"Clinical + Research", tuition:"ZMW 25,000/year (~€1,100)", totalCost:"~ZMW 55,000", livingCost:"~€350/mo", language:"English", ielts:"N/A (English medium)", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Sep 30, 2026", intake:"January", classSize:"2–4", acceptanceRate:"~25%", casesRequired:"60 implant cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:500, satisfactionScore:3.5, careerOutcome:"Implant specialist, Zambia/Southern Africa hospital", modules:["Implant biology","Surgical placement","Bone grafting","Prosthetics","Research","Thesis"], docsRequired:["Degree","Health Professions Council Zambia reg.","2 references","CV"], applicationLink:"https://www.unza.zm", accredited:true },
  { id:"134", university:"Eduardo Mondlane University", country:"Mozambique", flag:"🇲🇿", city:"Maputo", specialty:"Prosthodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"MZN 50,000/year (~€700)", totalCost:"~MZN 110,000", livingCost:"~€320/mo", language:"Portuguese / English", ielts:"N/A", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Sep 30, 2026", intake:"February", classSize:"2–4", acceptanceRate:"~30%", casesRequired:"120 prosthetic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:500, satisfactionScore:3.5, careerOutcome:"Prosthodontist, Mozambique/Southern Africa specialist", modules:["Complete prosthodontics","Implant intro","Esthetics","Occlusion","Research","Thesis"], docsRequired:["Degree","Portuguese B2","2 references","CV"], applicationLink:"https://www.uem.mz", accredited:true },
  { id:"135", university:"University of Botswana", country:"Botswana", flag:"🇧🇼", city:"Gaborone", specialty:"Oral Surgery", degree:"MMed (Dent)", duration:"3 years FT", format:"Clinical + Research", tuition:"BWP 25,000/year (~€1,700)", totalCost:"~BWP 80,000", livingCost:"~€500/mo", language:"English / Setswana", ielts:"N/A (English medium)", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Aug 31, 2026", intake:"August", classSize:"2–3", acceptanceRate:"~25%", casesRequired:"200 surgical cases", thesisRequired:true, interviewRequired:true, scholarship:true, scholarshipDetail:"Government of Botswana scholarship for citizens — full tuition + stipend", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:500, satisfactionScore:3.5, careerOutcome:"Oral surgeon, Botswana/Southern Africa hospital post", modules:["Dentoalveolar surgery","Cysts & pathology","Facial trauma","Implant intro","Sedation","Thesis"], docsRequired:["Degree","Botswana Health Professions Council reg.","2 references","CV"], applicationLink:"https://www.ub.bw", accredited:true },
  { id:"136", university:"University of Namibia (UNAM)", country:"Namibia", flag:"🇳🇦", city:"Windhoek", specialty:"Endodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Research", tuition:"NAD 40,000/year (~€2,000)", totalCost:"~NAD 85,000", livingCost:"~€500/mo", language:"English", ielts:"N/A (English medium)", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Aug 31, 2026", intake:"February", classSize:"2–4", acceptanceRate:"~25%", casesRequired:"100 endodontic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:500, satisfactionScore:3.6, careerOutcome:"Endodontist, Namibia/Southern Africa specialist", modules:["Endodontic biology","Advanced RCT","Surgical endo","Traumatology","Regenerative endo","Thesis"], docsRequired:["Degree","Health Professions Councils of Namibia reg.","2 references","CV"], applicationLink:"https://www.unam.edu.na", accredited:true },
  { id:"137", university:"University of Mauritius", country:"Mauritius", flag:"🇲🇺", city:"Réduit", specialty:"Digital Dentistry", degree:"MSc", duration:"1.5 years PT", format:"Academic + Online", tuition:"MUR 120,000/year (~€2,400)", totalCost:"~MUR 200,000", livingCost:"~€800/mo", language:"English / French", ielts:"6.0", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Jun 30, 2026", intake:"September", classSize:"15–20", acceptanceRate:"~45%", casesRequired:"Portfolio-based", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:400, satisfactionScore:3.8, careerOutcome:"Digital specialist, Mauritius/African island tech pathway", modules:["CAD/CAM","3D printing","Digital impressions","AI tools","Workflow","Thesis"], docsRequired:["Degree","IELTS 6.0","1 reference","Portfolio"], applicationLink:"https://www.uom.ac.mu", accredited:true },
  { id:"138", university:"University of Rwanda – College of Medicine", country:"Rwanda", flag:"🇷🇼", city:"Kigali", specialty:"Oral Surgery", degree:"MMed (Oral Surgery)", duration:"3 years FT", format:"Clinical + Research", tuition:"RWF 1,200,000/year (~€900)", totalCost:"~RWF 3,800,000", livingCost:"~€400/mo", language:"English / Kinyarwanda / French", ielts:"N/A", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Sep 30, 2026", intake:"October", classSize:"2–4", acceptanceRate:"~25%", casesRequired:"200 surgical cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:500, satisfactionScore:3.5, careerOutcome:"Oral surgeon, Rwanda/East Africa hospital specialist", modules:["Dentoalveolar surgery","Cysts & pathology","Facial trauma","Preprosthetic surgery","Sedation","Thesis"], docsRequired:["Degree","Rwanda Medical Council reg.","2 references","CV"], applicationLink:"https://www.ur.ac.rw", accredited:true },
  { id:"139", university:"Agostinho Neto University", country:"Angola", flag:"🇦🇴", city:"Luanda", specialty:"Prosthodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"AOA 200,000/year (~€400)", totalCost:"~AOA 500,000", livingCost:"~€600/mo", language:"Portuguese", ielts:"N/A – Portuguese required", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Sep 30, 2026", intake:"March", classSize:"4–8", acceptanceRate:"~40%", casesRequired:"120 prosthetic cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:500, satisfactionScore:3.4, careerOutcome:"Prosthodontist, Angola/Portuguese-speaking Africa specialist", modules:["Complete prosthodontics","Implant intro","Esthetics","Occlusion","Research","Thesis"], docsRequired:["Degree","Portuguese B2","2 references","CV"], applicationLink:"https://www.uan.ao", accredited:true },
  { id:"140", university:"University of Abomey-Calavi", country:"Benin", flag:"🇧🇯", city:"Cotonou", specialty:"Endodontics", degree:"DES", duration:"3 years FT", format:"Clinical + Academic", tuition:"XOF 400,000/year (~€610)", totalCost:"~XOF 1,300,000", livingCost:"~€350/mo", language:"French", ielts:"N/A – French required", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Sep 30, 2026", intake:"October", classSize:"4–6", acceptanceRate:"~40%", casesRequired:"80 endodontic cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:500, satisfactionScore:3.4, careerOutcome:"Endodontist, Benin/West Africa specialist", modules:["Endodontic biology","Rotary instrumentation","Surgical endo","Traumatology","Regenerative endo","Thesis"], docsRequired:["Degree","French B2","2 references","CV"], applicationLink:"https://www.uac.bj", accredited:true },

  // --- Asia (new countries) ---
  { id:"141", university:"Hanoi Medical University", country:"Vietnam", flag:"🇻🇳", city:"Hanoi", specialty:"Implantology", degree:"MSc", duration:"2 years FT", format:"Clinical + Research", tuition:"VND 25,000,000/year (~€950)", totalCost:"~VND 55,000,000", livingCost:"~€450/mo", language:"Vietnamese / English", ielts:"6.0", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Mar 31, 2026", intake:"September", classSize:"6–10", acceptanceRate:"~30%", casesRequired:"80 implant cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:380, satisfactionScore:4.0, careerOutcome:"Implant specialist, Vietnam/ASEAN private practice", modules:["Implant biology","Surgical placement","Bone augmentation","Digital planning","Prosthetics","Thesis"], docsRequired:["Degree","IELTS 6.0 or Vietnamese proficiency","2 references","CV","Interview"], applicationLink:"https://www.hmu.edu.vn", accredited:true },
  { id:"142", university:"University of Dhaka – Faculty of Dentistry", country:"Bangladesh", flag:"🇧🇩", city:"Dhaka", specialty:"Orthodontics", degree:"MDS", duration:"3 years FT", format:"Clinical + Academic", tuition:"BDT 200,000/year (~€1,700)", totalCost:"~BDT 650,000", livingCost:"~€350/mo", language:"Bengali / English", ielts:"N/A (English medium)", gpa:"Good standing", clinicalExp:"Post-BDS direct", deadline:"May 31, 2026", intake:"July", classSize:"4–6", acceptanceRate:"~25%", casesRequired:"100 orthodontic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:450, satisfactionScore:3.8, careerOutcome:"MDS Orthodontist, Bangladesh private specialist practice", modules:["Fixed appliances","Removable appliances","Aligners","Cephalometrics","Retention","Thesis"], docsRequired:["BDS degree","BMDC registration","2 references","CV"], applicationLink:"https://www.du.ac.bd", accredited:true },
  { id:"143", university:"University of Peradeniya", country:"Sri Lanka", flag:"🇱🇰", city:"Kandy", specialty:"Endodontics", degree:"MDS", duration:"3 years FT", format:"Clinical + Research", tuition:"LKR 500,000/year (~€1,500)", totalCost:"~LKR 1,600,000", livingCost:"~€400/mo", language:"Sinhala / English", ielts:"N/A (English medium)", gpa:"Good standing", clinicalExp:"Post-BDS direct", deadline:"Mar 31, 2026", intake:"July", classSize:"2–4", acceptanceRate:"~20%", casesRequired:"100 endodontic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:420, satisfactionScore:3.9, careerOutcome:"Endodontist, Sri Lanka/South Asia specialist", modules:["Endodontic biology","Advanced RCT","Surgical endo","Traumatology","Regenerative endo","Thesis"], docsRequired:["BDS degree","SLMC registration","2 references","CV","Interview"], applicationLink:"https://www.pdn.ac.lk", accredited:true },
  { id:"144", university:"BP Koirala Institute of Health Sciences", country:"Nepal", flag:"🇳🇵", city:"Dharan", specialty:"Prosthodontics", degree:"MDS", duration:"3 years FT", format:"Clinical + Academic", tuition:"NPR 500,000/year (~€3,500)", totalCost:"~NPR 1,600,000", livingCost:"~€300/mo", language:"Nepali / English", ielts:"N/A (English medium)", gpa:"Good standing", clinicalExp:"Post-BDS direct", deadline:"Apr 30, 2026", intake:"August", classSize:"2–4", acceptanceRate:"~22%", casesRequired:"150 prosthetic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:440, satisfactionScore:3.8, careerOutcome:"Prosthodontist, Nepal/South Asia specialist", modules:["Complete prosthodontics","Implant intro","Esthetics","Occlusion","Digital intro","Thesis"], docsRequired:["BDS degree","Nepal Medical Council reg.","2 references","CV","Interview"], applicationLink:"https://www.bpkihs.edu", accredited:true },
  { id:"145", university:"University of Health Sciences Phnom Penh", country:"Cambodia", flag:"🇰🇭", city:"Phnom Penh", specialty:"Oral Surgery", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"USD 4,500/year", totalCost:"~USD 10,500", livingCost:"~€450/mo", language:"Khmer / English", ielts:"5.5", gpa:"Good standing", clinicalExp:"1+ year", deadline:"May 31, 2026", intake:"October", classSize:"4–8", acceptanceRate:"~35%", casesRequired:"150 surgical cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:480, satisfactionScore:3.7, careerOutcome:"Oral surgeon, Cambodia/ASEAN specialist practice", modules:["Dentoalveolar surgery","Cysts & pathology","Facial trauma","Implant intro","Sedation","Thesis"], docsRequired:["Degree","2 references","CV","Interview"], applicationLink:"https://www.uhs.edu.kh", accredited:true },
  { id:"146", university:"University of Medicine 1 Yangon", country:"Myanmar", flag:"🇲🇲", city:"Yangon", specialty:"Endodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Research", tuition:"MMK 500,000/year (~€220)", totalCost:"~MMK 1,200,000", livingCost:"~€350/mo", language:"Burmese / English", ielts:"N/A", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Aug 31, 2026", intake:"December", classSize:"4–6", acceptanceRate:"~30%", casesRequired:"80 endodontic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:500, satisfactionScore:3.6, careerOutcome:"Endodontist, Myanmar/ASEAN specialist", modules:["Endodontic biology","Rotary instrumentation","Surgical endo","Traumatology","Regenerative endo","Thesis"], docsRequired:["Degree","Myanmar Medical Council reg.","2 references","CV"], applicationLink:"https://www.um1ygn.edu.mm", accredited:true },
  { id:"147", university:"Mongolian National University of Medical Sciences", country:"Mongolia", flag:"🇲🇳", city:"Ulaanbaatar", specialty:"Prosthodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"MNT 3,000,000/year (~€800)", totalCost:"~MNT 7,000,000", livingCost:"~€500/mo", language:"Mongolian / English", ielts:"5.5", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Jun 30, 2026", intake:"September", classSize:"4–8", acceptanceRate:"~35%", casesRequired:"120 prosthetic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:480, satisfactionScore:3.7, careerOutcome:"Prosthodontist, Mongolia specialist practice", modules:["Complete prosthodontics","Implant intro","Esthetics","Occlusion","Research","Thesis"], docsRequired:["Degree","2 references","CV","Interview"], applicationLink:"https://www.mnums.edu.mn", accredited:true },
  { id:"148", university:"Kazakh National Medical University (KazNMU)", country:"Kazakhstan", flag:"🇰🇿", city:"Almaty", specialty:"Implantology", degree:"MSc", duration:"2 years FT", format:"Clinical + Research", tuition:"KZT 800,000/year (~€1,600)", totalCost:"~KZT 2,000,000", livingCost:"~€500/mo", language:"Kazakh / Russian / English", ielts:"5.5", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Jul 31, 2026", intake:"September", classSize:"6–10", acceptanceRate:"~35%", casesRequired:"60 implant cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:390, satisfactionScore:3.8, careerOutcome:"Implant specialist, Kazakhstan/Central Asia private practice", modules:["Implant biology","Surgical placement","Bone grafting","Digital planning","Prosthetics","Thesis"], docsRequired:["Degree","IELTS 5.5 or Russian B2","2 references","CV"], applicationLink:"https://www.kaznmu.kz", accredited:true },
  { id:"149", university:"Tashkent State Dental Institute", country:"Uzbekistan", flag:"🇺🇿", city:"Tashkent", specialty:"Orthodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"USD 3,500/year", totalCost:"~USD 8,500", livingCost:"~€400/mo", language:"Uzbek / Russian / English", ielts:"5.5", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Jul 31, 2026", intake:"September", classSize:"8–14", acceptanceRate:"~40%", casesRequired:"80 orthodontic cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:410, satisfactionScore:3.7, careerOutcome:"Orthodontist, Uzbekistan/Central Asia specialist", modules:["Fixed appliances","Removable appliances","Cephalometrics","Digital orthodontics","Retention","Thesis"], docsRequired:["Degree","IELTS 5.5 or Russian B2","2 references","CV"], applicationLink:"https://tsdi.uz", accredited:true },
  { id:"150", university:"Kyrgyz State Medical Academy", country:"Kyrgyzstan", flag:"🇰🇬", city:"Bishkek", specialty:"Endodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"USD 2,800/year", totalCost:"~USD 6,500", livingCost:"~€350/mo", language:"Kyrgyz / Russian / English", ielts:"5.5", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Aug 31, 2026", intake:"September", classSize:"6–12", acceptanceRate:"~42%", casesRequired:"80 endodontic cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:430, satisfactionScore:3.6, careerOutcome:"Endodontist, Kyrgyzstan/Central Asia specialist", modules:["Endodontic biology","Rotary instrumentation","Surgical endo","Traumatology","Regenerative endo","Thesis"], docsRequired:["Degree","IELTS 5.5 or Russian B2","2 references","CV"], applicationLink:"https://www.ksma.kg", accredited:true },

  // --- Americas (new countries) ---
  { id:"151", university:"University of Havana – Dental Faculty", country:"Cuba", flag:"🇨🇺", city:"Havana", specialty:"Endodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Research", tuition:"CUP 0 (nationals) / USD 5,000/year (international)", totalCost:"~USD 11,000", livingCost:"~€350/mo", language:"Spanish", ielts:"N/A – Spanish required", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Aug 31, 2026", intake:"September", classSize:"6–10", acceptanceRate:"~35%", casesRequired:"100 endodontic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:440, satisfactionScore:3.7, careerOutcome:"Endodontist, Cuba/Caribbean specialist", modules:["Endodontic biology","Rotary instrumentation","Surgical endo","Traumatology","Regenerative endo","Thesis"], docsRequired:["Degree","2 references","CV","Interview"], applicationLink:"https://www.uh.cu", accredited:true },
  { id:"152", university:"Central University of Venezuela (UCV)", country:"Venezuela", flag:"🇻🇪", city:"Caracas", specialty:"Implantology", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"VES 500/year (~€200)", totalCost:"~VES 1,200", livingCost:"~€300/mo", language:"Spanish", ielts:"N/A – Spanish required", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Mar 31, 2026", intake:"September", classSize:"6–10", acceptanceRate:"~35%", casesRequired:"60 implant cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:420, satisfactionScore:3.6, careerOutcome:"Implant specialist, Venezuela/Latin America private practice", modules:["Implant biology","Surgical placement","Bone grafting","Digital planning","Prosthetics","Thesis"], docsRequired:["Degree","2 references","CV","Interview"], applicationLink:"https://www.ucv.ve", accredited:true },
  { id:"153", university:"Central University of Ecuador", country:"Ecuador", flag:"🇪🇨", city:"Quito", specialty:"Orthodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"USD 5,000/year", totalCost:"~USD 12,000", livingCost:"~€500/mo", language:"Spanish", ielts:"N/A – Spanish required", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Apr 30, 2026", intake:"October", classSize:"6–10", acceptanceRate:"~30%", casesRequired:"80 orthodontic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:360, satisfactionScore:3.9, careerOutcome:"Orthodontist, Ecuador/Andean region specialist", modules:["Fixed appliances","Aligners","Cephalometrics","Digital orthodontics","Retention","Thesis"], docsRequired:["Degree","2 references","CV","Interview"], applicationLink:"https://www.uce.edu.ec", accredited:true },
  { id:"154", university:"University of San Francisco Xavier de Chuquisaca", country:"Bolivia", flag:"🇧🇴", city:"Sucre", specialty:"Prosthodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"BOB 5,000/year (~€650)", totalCost:"~BOB 12,000", livingCost:"~€350/mo", language:"Spanish", ielts:"N/A – Spanish required", gpa:"Good standing", clinicalExp:"1+ year", deadline:"May 31, 2026", intake:"February", classSize:"4–8", acceptanceRate:"~38%", casesRequired:"120 prosthetic cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:450, satisfactionScore:3.7, careerOutcome:"Prosthodontist, Bolivia/South America specialist", modules:["Complete prosthodontics","Implant intro","Esthetics","Occlusion","Research","Thesis"], docsRequired:["Degree","2 references","CV"], applicationLink:"https://www.usfx.bo", accredited:true },
  { id:"155", university:"National University of Asunción", country:"Paraguay", flag:"🇵🇾", city:"Asunción", specialty:"Endodontics", degree:"MSc", duration:"2 years PT", format:"Clinical + Academic", tuition:"PYG 4,000,000/year (~€500)", totalCost:"~PYG 10,000,000", livingCost:"~€400/mo", language:"Spanish / Guaraní", ielts:"N/A – Spanish required", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Jun 30, 2026", intake:"March", classSize:"6–10", acceptanceRate:"~40%", casesRequired:"80 endodontic cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:460, satisfactionScore:3.7, careerOutcome:"Endodontist, Paraguay/South America specialist", modules:["Endodontic biology","Rotary instrumentation","Surgical endo","Traumatology","Regenerative endo","Thesis"], docsRequired:["Degree","2 references","CV"], applicationLink:"https://www.una.py", accredited:true },
  { id:"156", university:"University of the Republic (UdelaR)", country:"Uruguay", flag:"🇺🇾", city:"Montevideo", specialty:"Implantology", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"UYU 0 (public university)", totalCost:"~UYU 30,000 (fees)", livingCost:"~€700/mo", language:"Spanish", ielts:"N/A – Spanish required", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Apr 30, 2026", intake:"March", classSize:"6–10", acceptanceRate:"~32%", casesRequired:"80 implant cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:340, satisfactionScore:3.9, careerOutcome:"Implant specialist, Uruguay/Río de la Plata region", modules:["Implant biology","Surgical placement","Bone augmentation","Digital planning","Prosthetics","Thesis"], docsRequired:["Degree","2 references","CV","Interview"], applicationLink:"https://www.udelar.edu.uy", accredited:true },
  { id:"157", university:"University of Costa Rica (UCR)", country:"Costa Rica", flag:"🇨🇷", city:"San José", specialty:"Orthodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"CRC 1,500,000/year (~€2,700)", totalCost:"~CRC 4,000,000", livingCost:"~€700/mo", language:"Spanish", ielts:"N/A – Spanish required", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Mar 31, 2026", intake:"March", classSize:"6–8", acceptanceRate:"~28%", casesRequired:"80 orthodontic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:350, satisfactionScore:4.0, careerOutcome:"Orthodontist, Costa Rica/Central America specialist", modules:["Fixed appliances","Aligners","Cephalometrics","Digital orthodontics","Retention","Thesis"], docsRequired:["Degree","2 references","CV","Interview"], applicationLink:"https://www.ucr.ac.cr", accredited:true },
  { id:"158", university:"University of Panama", country:"Panama", flag:"🇵🇦", city:"Panama City", specialty:"Prosthodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"PAB 4,000/year (~€4,000)", totalCost:"~PAB 10,000", livingCost:"~€700/mo", language:"Spanish", ielts:"N/A – Spanish required", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Apr 30, 2026", intake:"March", classSize:"4–8", acceptanceRate:"~30%", casesRequired:"120 prosthetic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:380, satisfactionScore:3.9, careerOutcome:"Prosthodontist, Panama/Central America specialist", modules:["Complete prosthodontics","Implant intro","Esthetics","Occlusion","Digital intro","Thesis"], docsRequired:["Degree","2 references","CV","Interview"], applicationLink:"https://www.up.ac.pa", accredited:true },
  { id:"159", university:"Autonomous University of Santo Domingo (UASD)", country:"Dominican Republic", flag:"🇩🇴", city:"Santo Domingo", specialty:"Endodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"DOP 50,000/year (~€800)", totalCost:"~DOP 130,000", livingCost:"~€500/mo", language:"Spanish", ielts:"N/A – Spanish required", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Jul 31, 2026", intake:"August", classSize:"6–10", acceptanceRate:"~38%", casesRequired:"80 endodontic cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:430, satisfactionScore:3.7, careerOutcome:"Endodontist, Dominican Republic/Caribbean specialist", modules:["Endodontic biology","Rotary instrumentation","Surgical endo","Traumatology","Regenerative endo","Thesis"], docsRequired:["Degree","2 references","CV"], applicationLink:"https://www.uasd.edu.do", accredited:true },
  { id:"160", university:"University of San Carlos of Guatemala (USAC)", country:"Guatemala", flag:"🇬🇹", city:"Guatemala City", specialty:"Oral Surgery", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"GTQ 10,000/year (~€1,200)", totalCost:"~GTQ 25,000", livingCost:"~€450/mo", language:"Spanish", ielts:"N/A – Spanish required", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Jun 30, 2026", intake:"January", classSize:"4–8", acceptanceRate:"~35%", casesRequired:"180 surgical cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:420, satisfactionScore:3.8, careerOutcome:"Oral surgeon, Guatemala/Central America specialist", modules:["Dentoalveolar surgery","Cysts & pathology","Facial trauma","Implant intro","Sedation","Thesis"], docsRequired:["Degree","2 references","CV","Interview"], applicationLink:"https://www.usac.edu.gt", accredited:true },
  { id:"161", university:"University of the West Indies (UWI) – Mona", country:"Jamaica", flag:"🇯🇲", city:"Kingston", specialty:"Prosthodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"JMD 1,200,000/year (~€7,200)", totalCost:"~JMD 3,000,000", livingCost:"~€700/mo", language:"English", ielts:"N/A (English medium)", gpa:"Good standing", clinicalExp:"2+ years", deadline:"Mar 31, 2026", intake:"September", classSize:"2–4", acceptanceRate:"~20%", casesRequired:"150 prosthetic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:310, satisfactionScore:4.0, careerOutcome:"Prosthodontist, Caribbean/UK specialist pathway", modules:["Complete prosthodontics","Implant prosthetics","Digital workflow","Esthetics","Occlusion","Thesis"], docsRequired:["Degree","2 references","CV","Interview"], applicationLink:"https://www.mona.uwi.edu", accredited:true },
  { id:"162", university:"National Autonomous University of Honduras (UNAH)", country:"Honduras", flag:"🇭🇳", city:"Tegucigalpa", specialty:"Endodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"HNL 20,000/year (~€750)", totalCost:"~HNL 50,000", livingCost:"~€400/mo", language:"Spanish", ielts:"N/A – Spanish required", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Jun 30, 2026", intake:"February", classSize:"4–8", acceptanceRate:"~38%", casesRequired:"80 endodontic cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:460, satisfactionScore:3.6, careerOutcome:"Endodontist, Honduras/Central America specialist", modules:["Endodontic biology","Rotary instrumentation","Surgical endo","Traumatology","Regenerative endo","Thesis"], docsRequired:["Degree","2 references","CV"], applicationLink:"https://www.unah.edu.hn", accredited:true },
  { id:"163", university:"Federal University of Rio de Janeiro (UFRJ)", country:"Brazil", flag:"🇧🇷", city:"Rio de Janeiro", specialty:"Orthodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Research", tuition:"BRL 0 (public university)", totalCost:"~BRL 15,000 (fees + living)", livingCost:"~€550/mo", language:"Portuguese", ielts:"N/A – Portuguese required", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Nov 30, 2025", intake:"March", classSize:"4–6", acceptanceRate:"~18%", casesRequired:"100 orthodontic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:140, satisfactionScore:4.3, careerOutcome:"Orthodontist, Brazil/Latin America specialist practice", modules:["Fixed appliances","Aligners","Cephalometrics","Orthognathic planning","Digital orthodontics","Thesis"], docsRequired:["Degree","Portuguese B2","2 references","Research proposal","Interview"], applicationLink:"https://www.ufrj.br", accredited:true },
  { id:"164", university:"UNICAMP – State University of Campinas", country:"Brazil", flag:"🇧🇷", city:"Campinas", specialty:"Periodontology", degree:"MSc", duration:"2 years FT", format:"Clinical + Research", tuition:"BRL 0 (public university)", totalCost:"~BRL 18,000 (fees)", livingCost:"~€600/mo", language:"Portuguese", ielts:"N/A – Portuguese required", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Oct 31, 2025", intake:"March", classSize:"4–6", acceptanceRate:"~15%", casesRequired:"130 periodontal cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:110, satisfactionScore:4.4, careerOutcome:"Periodontist, Brazil/LATAM specialist, academic career", modules:["Periodontal medicine","Implant surgery","Regenerative therapy","Laser","Research methods","Thesis"], docsRequired:["Degree","Portuguese B2","Research proposal","2 references","Interview"], applicationLink:"https://www.unicamp.br", accredited:true },

  // --- Russia & Former Soviet ---
  { id:"165", university:"I.M. Sechenov First Moscow State Medical University", country:"Russia", flag:"🇷🇺", city:"Moscow", specialty:"Implantology", degree:"PhD / MSc", duration:"2 years FT", format:"Clinical + Research", tuition:"RUB 250,000/year (~€2,500)", totalCost:"~RUB 600,000", livingCost:"~€700/mo", language:"Russian / English", ielts:"6.0 (English track)", gpa:"Good standing", clinicalExp:"2+ years", deadline:"Jun 30, 2026", intake:"September", classSize:"8–14", acceptanceRate:"~30%", casesRequired:"80 implant cases", thesisRequired:true, interviewRequired:true, scholarship:true, scholarshipDetail:"Russian Government Scholarship for foreign nationals — full tuition + RUB 1,500/mo stipend", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:155, satisfactionScore:4.1, careerOutcome:"Implant specialist, Russia/CIS specialist practice", modules:["Implant biology","Bone augmentation","Digital planning","Guided surgery","Prosthetics","Thesis"], docsRequired:["Degree","IELTS 6.0 or Russian B2","2 references","Research proposal"], applicationLink:"https://www.sechenov.ru", accredited:true },
  { id:"166", university:"Saint Petersburg State Medical University", country:"Russia", flag:"🇷🇺", city:"Saint Petersburg", specialty:"Orthodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"RUB 220,000/year (~€2,200)", totalCost:"~RUB 520,000", livingCost:"~€650/mo", language:"Russian / English", ielts:"6.0 (English track)", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Jun 30, 2026", intake:"September", classSize:"8–12", acceptanceRate:"~32%", casesRequired:"80 orthodontic cases", thesisRequired:true, interviewRequired:true, scholarship:true, scholarshipDetail:"Russian Government Scholarship available for foreign nationals", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:180, satisfactionScore:4.0, careerOutcome:"Orthodontist, Russia/CIS specialist practice, academic", modules:["Fixed appliances","Aligners","Cephalometrics","Digital orthodontics","Retention","Thesis"], docsRequired:["Degree","IELTS 6.0 or Russian B2","2 references","CV"], applicationLink:"https://www.spbgmu.ru", accredited:true },

  // --- More top universities (different specialties) ---
  { id:"167", university:"University of Birmingham", country:"United Kingdom", flag:"🇬🇧", city:"Birmingham", specialty:"Oral Surgery", degree:"MClinDent", duration:"3 years FT", format:"Clinical", tuition:"£22,500/year", totalCost:"~£71,500", livingCost:"~£950/mo", language:"English", ielts:"7.0", gpa:"Upper second (2:1)", clinicalExp:"2+ years", deadline:"Feb 28, 2026", intake:"September", classSize:"4–6", acceptanceRate:"~13%", casesRequired:"280 surgical cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:true, recognizedKSA:true, recognizedQatar:true, qsRanking:80, satisfactionScore:4.5, careerOutcome:"Oral surgeon, GDC specialist list, Gulf specialist post", modules:["Dentoalveolar surgery","Facial trauma","Cysts & pathology","Implant surgery","Sedation & GA","Research"], docsRequired:["Degree","IELTS 7.0","2 references","Personal statement","Interview"], applicationLink:"https://www.birmingham.ac.uk", accredited:true },
  { id:"168", university:"Queen Mary University of London", country:"United Kingdom", flag:"🇬🇧", city:"London", specialty:"Periodontology", degree:"MClinDent", duration:"3 years FT", format:"Clinical", tuition:"£24,000/year", totalCost:"~£76,000", livingCost:"~£1,700/mo", language:"English", ielts:"7.0", gpa:"Upper second (2:1)", clinicalExp:"2+ years", deadline:"Jan 31, 2026", intake:"September", classSize:"4–6", acceptanceRate:"~12%", casesRequired:"160 periodontal cases", thesisRequired:true, interviewRequired:true, scholarship:true, scholarshipDetail:"QMUL International Scholarship — £3,500", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:true, recognizedKSA:true, recognizedQatar:true, qsRanking:95, satisfactionScore:4.6, careerOutcome:"Periodontist, GDC specialist list, Gulf specialist post", modules:["Periodontal medicine","Implant surgery","Plastic surgery","Laser therapy","Evidence-based practice","Thesis"], docsRequired:["Degree","IELTS 7.0","2 references","Personal statement","Interview"], applicationLink:"https://www.qmul.ac.uk", accredited:true },
  { id:"169", university:"University of Dundee", country:"United Kingdom", flag:"🇬🇧", city:"Dundee", specialty:"Restorative Dentistry", degree:"MClinDent", duration:"3 years FT", format:"Clinical", tuition:"£21,500/year", totalCost:"~£68,000", livingCost:"~£850/mo", language:"English", ielts:"7.0", gpa:"Upper second (2:1)", clinicalExp:"2+ years", deadline:"Mar 31, 2026", intake:"September", classSize:"4–6", acceptanceRate:"~15%", casesRequired:"200 restorative cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:true, recognizedKSA:false, recognizedQatar:false, qsRanking:110, satisfactionScore:4.4, careerOutcome:"Restorative dentistry specialist, GDC specialist list", modules:["Restorative dentistry","Endodontics","Periodontology","Prosthodontics","Digital workflow","Thesis"], docsRequired:["Degree","IELTS 7.0","2 references","Personal statement","Interview"], applicationLink:"https://www.dundee.ac.uk", accredited:true },
  { id:"170", university:"Monash University", country:"Australia", flag:"🇦🇺", city:"Melbourne", specialty:"Periodontology", degree:"MClinDent", duration:"3 years FT", format:"Clinical", tuition:"AUD 52,000/year", totalCost:"~AUD 165,000", livingCost:"~AUD 2,100/mo", language:"English", ielts:"7.0", gpa:"Upper second", clinicalExp:"3+ years", deadline:"Aug 1, 2025", intake:"February", classSize:"4–6", acceptanceRate:"~12%", casesRequired:"160 periodontal cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:42, satisfactionScore:4.7, careerOutcome:"Periodontist, ADC specialist recognition, academic post", modules:["Periodontal medicine","Implant surgery","Plastic surgery","Laser therapy","Research","Thesis"], docsRequired:["Degree","ADC recognition","IELTS 7.0","3 references","Portfolio","Interview"], applicationLink:"https://www.monash.edu", accredited:true },
  { id:"171", university:"University of Western Australia (UWA)", country:"Australia", flag:"🇦🇺", city:"Perth", specialty:"Orthodontics", degree:"MClinDent", duration:"3 years FT", format:"Clinical", tuition:"AUD 49,000/year", totalCost:"~AUD 155,000", livingCost:"~AUD 1,800/mo", language:"English", ielts:"7.0", gpa:"Upper second", clinicalExp:"2+ years", deadline:"Aug 1, 2025", intake:"February", classSize:"4–5", acceptanceRate:"~12%", casesRequired:"120 orthodontic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:86, satisfactionScore:4.6, careerOutcome:"Orthodontist, ADC specialist recognition, academic post", modules:["Fixed appliances","Aligners","Cephalometrics","Digital orthodontics","Orthognathic planning","Thesis"], docsRequired:["Degree","ADC recognition","IELTS 7.0","2 references","Interview"], applicationLink:"https://www.uwa.edu.au", accredited:true },
  { id:"172", university:"University of Sydney", country:"Australia", flag:"🇦🇺", city:"Sydney", specialty:"Implantology", degree:"MClinDent", duration:"3 years FT", format:"Clinical", tuition:"AUD 53,000/year", totalCost:"~AUD 168,000", livingCost:"~AUD 2,300/mo", language:"English", ielts:"7.0", gpa:"Upper second", clinicalExp:"3+ years", deadline:"Aug 1, 2025", intake:"February", classSize:"4–6", acceptanceRate:"~10%", casesRequired:"200 implant cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:true, recognizedKSA:false, recognizedQatar:false, qsRanking:16, satisfactionScore:4.8, careerOutcome:"Implant specialist, ADC recognition, academic post", modules:["Implant biology","Bone augmentation","Guided surgery","Digital planning","Prosthetics","Thesis"], docsRequired:["Degree","ADC recognition","IELTS 7.0","3 references","Portfolio","Interview"], applicationLink:"https://www.sydney.edu.au", accredited:true },
  { id:"173", university:"Dalhousie University", country:"Canada", flag:"🇨🇦", city:"Halifax", specialty:"Endodontics", degree:"MSD", duration:"3 years FT", format:"Clinical", tuition:"CAD 22,000/year", totalCost:"~CAD 72,000", livingCost:"~CAD 1,800/mo", language:"English", ielts:"6.5", gpa:"B+ or above", clinicalExp:"2+ years", deadline:"Nov 15, 2025", intake:"July", classSize:"2–3", acceptanceRate:"~10%", casesRequired:"200 endodontic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:250, satisfactionScore:4.6, careerOutcome:"Endodontist, NDEB recognized, Canadian specialist pathway", modules:["Endodontic biology","Advanced RCT","Surgical endo","Traumatology","Regenerative endo","Research seminar"], docsRequired:["Degree","NDEB assessment","2 references","Personal statement","IELTS 6.5","Interview"], applicationLink:"https://www.dal.ca", accredited:true },
  { id:"174", university:"University of Alberta", country:"Canada", flag:"🇨🇦", city:"Edmonton", specialty:"Prosthodontics", degree:"MSD", duration:"3 years FT", format:"Clinical", tuition:"CAD 26,000/year", totalCost:"~CAD 85,000", livingCost:"~CAD 1,900/mo", language:"English", ielts:"7.0", gpa:"B+ or above", clinicalExp:"2+ years", deadline:"Dec 1, 2025", intake:"July", classSize:"2–3", acceptanceRate:"~8%", casesRequired:"220 prosthetic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:true, recognizedKSA:false, recognizedQatar:false, qsRanking:110, satisfactionScore:4.7, careerOutcome:"Prosthodontist, NDEB specialist, Canadian and Gulf pathway", modules:["Complete prosthodontics","Implant prosthetics","Maxillofacial","Digital workflow","Esthetics","Research seminar"], docsRequired:["Degree","NDEB assessment","2 references","Personal statement","IELTS 7.0","Interview"], applicationLink:"https://www.ualberta.ca", accredited:true },
  { id:"175", university:"UCLA School of Dentistry", country:"United States", flag:"🇺🇸", city:"Los Angeles", specialty:"Endodontics", degree:"MS", duration:"2 years FT", format:"Clinical", tuition:"$55,000/year", totalCost:"~$125,000", livingCost:"~$3,200/mo", language:"English", ielts:"7.0", gpa:"3.5/4.0", clinicalExp:"No specific requirement", deadline:"Nov 1, 2025", intake:"July", classSize:"4–6", acceptanceRate:"~8%", casesRequired:"180 endodontic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:35, satisfactionScore:4.8, careerOutcome:"ADA endodontics specialist, private practice, academic faculty", modules:["Endodontic biology","Advanced RCT","Surgical endo","Traumatology","Regenerative endo","Research"], docsRequired:["Degree","NBDE/INBDE","2 references","Personal statement","TOEFL 100+","Interview"], applicationLink:"https://www.dentistry.ucla.edu", accredited:true },
  { id:"176", university:"University of Washington", country:"United States", flag:"🇺🇸", city:"Seattle", specialty:"Prosthodontics", degree:"MSD", duration:"3 years FT", format:"Clinical", tuition:"$45,000/year", totalCost:"~$145,000", livingCost:"~$2,800/mo", language:"English", ielts:"7.0", gpa:"3.4/4.0", clinicalExp:"No specific requirement", deadline:"Nov 15, 2025", intake:"July", classSize:"3–5", acceptanceRate:"~8%", casesRequired:"230 prosthetic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:52, satisfactionScore:4.7, careerOutcome:"ADA prosthodontics specialist, academic faculty", modules:["Complete prosthodontics","Implant prosthetics","Maxillofacial","Digital workflow","Esthetics","Research"], docsRequired:["Degree","NBDE/INBDE","2 references","Personal statement","TOEFL","Interview"], applicationLink:"https://dental.washington.edu", accredited:true },
  { id:"177", university:"Boston University Henry M. Goldman School", country:"United States", flag:"🇺🇸", city:"Boston", specialty:"Periodontology", degree:"MS", duration:"3 years FT", format:"Clinical", tuition:"$58,000/year", totalCost:"~$185,000", livingCost:"~$3,000/mo", language:"English", ielts:"7.0", gpa:"3.4/4.0", clinicalExp:"No specific requirement", deadline:"Oct 15, 2025", intake:"July", classSize:"4–6", acceptanceRate:"~9%", casesRequired:"160 periodontal cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:70, satisfactionScore:4.7, careerOutcome:"ADA periodontist, academic faculty, private specialist", modules:["Periodontal medicine","Implant surgery","Plastic surgery","Laser","Evidence-based practice","Research"], docsRequired:["Degree","NBDE/INBDE","3 references","Personal statement","TOEFL","Interview"], applicationLink:"https://www.bu.edu/dental", accredited:true },
  { id:"178", university:"University of Southern California (USC)", country:"United States", flag:"🇺🇸", city:"Los Angeles", specialty:"Implantology", degree:"MS", duration:"2 years FT", format:"Clinical", tuition:"$62,000/year", totalCost:"~$140,000", livingCost:"~$3,000/mo", language:"English", ielts:"7.0", gpa:"3.4/4.0", clinicalExp:"No specific requirement", deadline:"Dec 1, 2025", intake:"July", classSize:"4–6", acceptanceRate:"~10%", casesRequired:"150 implant cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:90, satisfactionScore:4.6, careerOutcome:"ADA implant specialist, private practice, academic faculty", modules:["Implant biology","Bone augmentation","Guided surgery","Digital planning","Prosthetics","Research"], docsRequired:["Degree","NBDE/INBDE","2 references","Personal statement","TOEFL","Interview"], applicationLink:"https://dentistry.usc.edu", accredited:true },
  { id:"179", university:"Case Western Reserve University", country:"United States", flag:"🇺🇸", city:"Cleveland", specialty:"Orthodontics", degree:"MSD", duration:"2 years FT", format:"Clinical", tuition:"$48,000/year", totalCost:"~$108,000", livingCost:"~$2,000/mo", language:"English", ielts:"7.0", gpa:"3.3/4.0", clinicalExp:"No specific requirement", deadline:"Dec 15, 2025", intake:"July", classSize:"4–6", acceptanceRate:"~10%", casesRequired:"100 orthodontic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:120, satisfactionScore:4.6, careerOutcome:"ADA orthodontics specialist, private practice, academic", modules:["Fixed appliances","Aligners","Cephalometrics","Digital orthodontics","Orthognathic planning","Thesis"], docsRequired:["Degree","NBDE/INBDE","2 references","Personal statement","TOEFL","Interview"], applicationLink:"https://case.edu/dental", accredited:true },
  { id:"180", university:"University of Pennsylvania (Penn Dental)", country:"United States", flag:"🇺🇸", city:"Philadelphia", specialty:"Periodontology", degree:"DMSc", duration:"3 years FT", format:"Clinical", tuition:"$65,000/year", totalCost:"~$205,000", livingCost:"~$2,800/mo", language:"English", ielts:"7.5", gpa:"3.6/4.0", clinicalExp:"No specific requirement", deadline:"Sep 15, 2025", intake:"July", classSize:"3–5", acceptanceRate:"~7%", casesRequired:"180 periodontal cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:12, satisfactionScore:4.9, careerOutcome:"ADA periodontist, Ivy League academic faculty, global specialist", modules:["Periodontal medicine","Implant surgery","Plastic surgery","Laser","Research design","Clinical research"], docsRequired:["Degree","NBDE/INBDE","3 references","Personal statement","TOEFL 100+","Interview"], applicationLink:"https://www.dental.upenn.edu", accredited:true },
  { id:"181", university:"University of Pittsburgh School of Dental Medicine", country:"United States", flag:"🇺🇸", city:"Pittsburgh", specialty:"Implantology", degree:"MS", duration:"2 years FT", format:"Clinical + Research", tuition:"$42,000/year", totalCost:"~$95,000", livingCost:"~$2,000/mo", language:"English", ielts:"6.5", gpa:"3.3/4.0", clinicalExp:"No specific requirement", deadline:"Dec 15, 2025", intake:"July", classSize:"4–6", acceptanceRate:"~12%", casesRequired:"130 implant cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:145, satisfactionScore:4.5, careerOutcome:"ADA implant specialist, private practice, academic post", modules:["Implant biology","Surgical placement","Bone augmentation","Digital planning","Prosthetics","Thesis"], docsRequired:["Degree","NBDE/INBDE","2 references","Personal statement","TOEFL","Interview"], applicationLink:"https://www.dental.pitt.edu", accredited:true },
  { id:"182", university:"Ohio State University College of Dentistry", country:"United States", flag:"🇺🇸", city:"Columbus", specialty:"Endodontics", degree:"MS", duration:"2 years FT", format:"Clinical", tuition:"$38,000/year", totalCost:"~$87,000", livingCost:"~$1,900/mo", language:"English", ielts:"6.5", gpa:"3.2/4.0", clinicalExp:"No specific requirement", deadline:"Dec 1, 2025", intake:"July", classSize:"4–6", acceptanceRate:"~14%", casesRequired:"180 endodontic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:130, satisfactionScore:4.5, careerOutcome:"ADA endodontics specialist, private practice, academic", modules:["Endodontic biology","Advanced RCT","Surgical endo","Traumatology","Regenerative endo","Thesis"], docsRequired:["Degree","NBDE/INBDE","2 references","Personal statement","TOEFL","Interview"], applicationLink:"https://dentistry.osu.edu", accredited:true },
  { id:"183", university:"Khon Kaen University", country:"Thailand", flag:"🇹🇭", city:"Khon Kaen", specialty:"Endodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Research", tuition:"THB 180,000/year (~€4,700)", totalCost:"~THB 400,000", livingCost:"~€550/mo", language:"Thai / English", ielts:"6.0", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Feb 28, 2026", intake:"June", classSize:"4–6", acceptanceRate:"~28%", casesRequired:"100 endodontic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:200, satisfactionScore:4.1, careerOutcome:"Endodontist, Thailand/ASEAN specialist practice", modules:["Endodontic biology","Advanced RCT","Surgical endo","Traumatology","Regenerative endo","Thesis"], docsRequired:["Degree","IELTS 6.0","2 references","CV","Interview"], applicationLink:"https://www.kku.ac.th", accredited:true },
  { id:"184", university:"Universiti Sains Malaysia (USM)", country:"Malaysia", flag:"🇲🇾", city:"Penang", specialty:"Periodontology", degree:"MSc", duration:"2 years FT", format:"Clinical + Research", tuition:"MYR 22,000/year (~€4,400)", totalCost:"~MYR 48,000", livingCost:"~€600/mo", language:"English / Malay", ielts:"6.0", gpa:"Good standing", clinicalExp:"2+ years", deadline:"Apr 30, 2026", intake:"September", classSize:"4–6", acceptanceRate:"~22%", casesRequired:"130 periodontal cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:150, satisfactionScore:4.2, careerOutcome:"Periodontist, Malaysia/ASEAN specialist practice", modules:["Periodontal medicine","Implant surgery","Regenerative therapy","Laser","Research","Thesis"], docsRequired:["Degree","MMC registration","IELTS 6.0","2 references","Interview"], applicationLink:"https://www.usm.my", accredited:true },
  { id:"185", university:"Chulalongkorn University", country:"Thailand", flag:"🇹🇭", city:"Bangkok", specialty:"Oral Surgery", degree:"MSc", duration:"2 years FT", format:"Clinical + Research", tuition:"THB 220,000/year (~€5,700)", totalCost:"~THB 480,000", livingCost:"~€700/mo", language:"Thai / English", ielts:"6.0", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Jan 31, 2026", intake:"May", classSize:"4–6", acceptanceRate:"~22%", casesRequired:"200 surgical cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:65, satisfactionScore:4.4, careerOutcome:"Oral surgeon, Thailand/ASEAN specialist, academic post", modules:["Dentoalveolar surgery","Cysts & pathology","Facial trauma","Implant surgery","Sedation","Thesis"], docsRequired:["Degree","IELTS 6.0","2 references","CV","Interview"], applicationLink:"https://www.chula.ac.th", accredited:true },
  { id:"186", university:"Ludwig Maximilian University Munich – Oral Medicine", country:"Germany", flag:"🇩🇪", city:"Munich", specialty:"Oral Pathology", degree:"MSc", duration:"2 years PT", format:"Research + Clinical", tuition:"€4,500/year", totalCost:"~€11,000", livingCost:"~€1,400/mo", language:"German / English", ielts:"6.5", gpa:"Good standing", clinicalExp:"2+ years", deadline:"Apr 1, 2026", intake:"October", classSize:"8–12", acceptanceRate:"~25%", casesRequired:"Research-based case series", thesisRequired:true, interviewRequired:false, scholarship:true, scholarshipDetail:"DAAD scholarship available — full tuition + €934/mo stipend", egyptianGovtFunding:true, recognizedEgypt:true, recognizedUAE:true, recognizedKSA:true, recognizedQatar:false, qsRanking:32, satisfactionScore:4.6, careerOutcome:"Oral pathologist, academic post, diagnostic unit, research career", modules:["Oral mucosal disease","Salivary gland pathology","Head & neck oncology","Histopathology","Research methods","Thesis"], docsRequired:["Degree","German B2 or IELTS 6.5","2 references","Research proposal","DAAD application"], applicationLink:"https://www.lmu.de", accredited:true },
  { id:"187", university:"Universidade Nova de Lisboa – Periodontology", country:"Portugal", flag:"🇵🇹", city:"Lisbon", specialty:"Periodontology", degree:"MSc", duration:"2 years PT", format:"Clinical + Academic", tuition:"€5,800/year", totalCost:"~€14,000", livingCost:"~€900/mo", language:"Portuguese / English", ielts:"6.0", gpa:"Good standing", clinicalExp:"2+ years", deadline:"Jun 30, 2026", intake:"October", classSize:"10–14", acceptanceRate:"~32%", casesRequired:"120 periodontal cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:155, satisfactionScore:4.3, careerOutcome:"Periodontist, Portugal/EU specialist, private referral", modules:["Periodontal medicine","Implant surgery","Regenerative therapy","Laser","Research","Thesis"], docsRequired:["Degree","IELTS 6.0 or Portuguese B2","2 references","CV"], applicationLink:"https://www.nms.unl.pt", accredited:true },
  { id:"188", university:"University of Barcelona – Oral Surgery", country:"Spain", flag:"🇪🇸", city:"Barcelona", specialty:"Oral Surgery", degree:"MSc", duration:"2 years PT", format:"Clinical + Academic", tuition:"€7,800/year", totalCost:"~€18,000", livingCost:"~€1,100/mo", language:"Spanish / English", ielts:"6.0", gpa:"Good standing", clinicalExp:"2+ years", deadline:"Jun 15, 2026", intake:"October", classSize:"10–14", acceptanceRate:"~28%", casesRequired:"200 surgical cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:70, satisfactionScore:4.3, careerOutcome:"Oral surgeon, Spain/EU specialist, Latin America pathway", modules:["Dentoalveolar surgery","Cysts & pathology","Facial trauma","Implant surgery","Sedation","Thesis"], docsRequired:["Degree","IELTS 6.0 or Spanish B2","2 references","CV"], applicationLink:"https://www.ub.edu", accredited:true },
  { id:"189", university:"Università Vita-Salute San Raffaele", country:"Italy", flag:"🇮🇹", city:"Milan", specialty:"Implantology", degree:"MSc", duration:"2 years PT", format:"Clinical + Academic", tuition:"€9,500/year", totalCost:"~€22,000", livingCost:"~€1,200/mo", language:"Italian / English", ielts:"6.0", gpa:"Good standing", clinicalExp:"2+ years", deadline:"Mar 31, 2026", intake:"October", classSize:"10–14", acceptanceRate:"~30%", casesRequired:"100 implant cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:true, recognizedKSA:false, recognizedQatar:false, qsRanking:120, satisfactionScore:4.4, careerOutcome:"Implant specialist, Italy/EU specialist, Gulf practice", modules:["Implant biology","Bone augmentation","Digital planning","Guided surgery","Prosthetics","Thesis"], docsRequired:["Degree","IELTS 6.0 or Italian B2","2 references","CV","Interview"], applicationLink:"https://www.unisr.it", accredited:true },
  { id:"190", university:"KU Leuven – Oral Surgery", country:"Belgium", flag:"🇧🇪", city:"Leuven", specialty:"Oral Surgery", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"€9,000/year", totalCost:"~€21,000", livingCost:"~€1,100/mo", language:"English / Dutch", ielts:"6.5", gpa:"Upper second", clinicalExp:"2+ years", deadline:"Feb 28, 2026", intake:"September", classSize:"6–10", acceptanceRate:"~18%", casesRequired:"250 surgical cases", thesisRequired:true, interviewRequired:true, scholarship:true, scholarshipDetail:"KU Leuven Excellence Scholarship — up to €5,000", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:true, recognizedKSA:false, recognizedQatar:false, qsRanking:42, satisfactionScore:4.6, careerOutcome:"Oral surgeon, Belgium/EU specialist, academic post", modules:["Dentoalveolar surgery","Cysts & pathology","Facial trauma","Implant surgery","Sedation","Research"], docsRequired:["Degree","IELTS 6.5","2 references","Personal statement","Interview"], applicationLink:"https://www.kuleuven.be", accredited:true },
  { id:"191", university:"University of Geneva – Periodontology", country:"Switzerland", flag:"🇨🇭", city:"Geneva", specialty:"Periodontology", degree:"MSc", duration:"3 years PT", format:"Clinical + Academic", tuition:"CHF 3,800/year (~€4,000)", totalCost:"~CHF 14,000", livingCost:"~CHF 2,600/mo", language:"French / English", ielts:"6.5", gpa:"Good standing", clinicalExp:"2+ years", deadline:"Feb 28, 2026", intake:"September", classSize:"6–10", acceptanceRate:"~18%", casesRequired:"150 periodontal cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:true, recognizedKSA:false, recognizedQatar:false, qsRanking:30, satisfactionScore:4.7, careerOutcome:"Periodontist, Swiss/EU specialist pathway, Gulf practice", modules:["Periodontal medicine","Implant surgery","Regenerative surgery","Laser therapy","Research","Thesis"], docsRequired:["Degree","IELTS 6.5 or French B2","2 references","CV","Interview"], applicationLink:"https://www.unige.ch", accredited:true },
  { id:"192", university:"Western University – Schulich Dentistry", country:"Canada", flag:"🇨🇦", city:"London, Ontario", specialty:"Orthodontics", degree:"MSD", duration:"3 years FT", format:"Clinical", tuition:"CAD 28,000/year", totalCost:"~CAD 92,000", livingCost:"~CAD 1,800/mo", language:"English", ielts:"7.0", gpa:"B+ or above", clinicalExp:"2+ years", deadline:"Dec 1, 2025", intake:"July", classSize:"3–4", acceptanceRate:"~8%", casesRequired:"120 orthodontic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:true, recognizedKSA:false, recognizedQatar:false, qsRanking:190, satisfactionScore:4.7, careerOutcome:"Orthodontist, RCDC specialist, Canadian and Gulf pathway", modules:["Fixed appliances","Aligners","Cephalometrics","Orthognathic planning","Digital orthodontics","Research"], docsRequired:["Degree","NDEB assessment","2 references","Personal statement","IELTS 7.0","Interview"], applicationLink:"https://www.schulich.uwo.ca/dentistry", accredited:true },
  { id:"193", university:"University of Auckland", country:"New Zealand", flag:"🇳🇿", city:"Auckland", specialty:"Oral Surgery", degree:"MDS", duration:"3 years FT", format:"Clinical + Research", tuition:"NZD 38,000/year (~€21,000)", totalCost:"~NZD 120,000", livingCost:"~NZD 1,600/mo", language:"English", ielts:"7.0", gpa:"Upper second", clinicalExp:"2+ years", deadline:"Jul 1, 2025", intake:"February", classSize:"3–5", acceptanceRate:"~20%", casesRequired:"280 surgical cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:true, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:55, satisfactionScore:4.6, careerOutcome:"Oral surgeon, NZ/Australia specialist pathway, academic post", modules:["Dentoalveolar surgery","Facial trauma","Cysts & pathology","Implant surgery","Sedation & GA","Research"], docsRequired:["Degree","NZDCR recognition","IELTS 7.0","2 references","Interview"], applicationLink:"https://www.auckland.ac.nz", accredited:true },
  { id:"194", university:"University of Colombo – Faculty of Dental Sciences", country:"Sri Lanka", flag:"🇱🇰", city:"Colombo", specialty:"Oral Surgery", degree:"MDS", duration:"3 years FT", format:"Clinical + Research", tuition:"LKR 600,000/year (~€1,800)", totalCost:"~LKR 1,900,000", livingCost:"~€380/mo", language:"English / Sinhala / Tamil", ielts:"N/A (English medium)", gpa:"Good standing", clinicalExp:"Post-BDS direct", deadline:"Apr 30, 2026", intake:"July", classSize:"2–4", acceptanceRate:"~20%", casesRequired:"220 surgical cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:400, satisfactionScore:3.9, careerOutcome:"Oral surgeon, Sri Lanka/South Asia specialist", modules:["Dentoalveolar surgery","Cysts & pathology","Facial trauma","Implant intro","Sedation","Thesis"], docsRequired:["BDS degree","SLMC registration","2 references","CV","Interview"], applicationLink:"https://www.cmb.ac.lk", accredited:true },
  { id:"195", university:"University of Cape Verde (Uni-CV)", country:"Cape Verde", flag:"🇨🇻", city:"Praia", specialty:"Prosthodontics", degree:"MSc", duration:"2 years PT", format:"Clinical + Academic", tuition:"CVE 100,000/year (~€900)", totalCost:"~CVE 220,000", livingCost:"~€600/mo", language:"Portuguese / English", ielts:"6.0", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Aug 31, 2026", intake:"October", classSize:"4–8", acceptanceRate:"~40%", casesRequired:"100 prosthetic cases", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:500, satisfactionScore:3.5, careerOutcome:"Prosthodontist, Cape Verde/Lusophone Africa specialist", modules:["Complete prosthodontics","Implant intro","Esthetics","Occlusion","Research","Thesis"], docsRequired:["Degree","Portuguese B2","2 references","CV"], applicationLink:"https://www.unicv.edu.cv", accredited:true },
  { id:"196", university:"Universidad Nacional de Colombia", country:"Colombia", flag:"🇨🇴", city:"Bogotá", specialty:"Implantology", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"COP 0 (public university)", totalCost:"~COP 5,000,000 (fees)", livingCost:"~€500/mo", language:"Spanish", ielts:"N/A – Spanish required", gpa:"Good standing", clinicalExp:"1+ year", deadline:"May 31, 2026", intake:"February", classSize:"6–10", acceptanceRate:"~25%", casesRequired:"80 implant cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:210, satisfactionScore:4.1, careerOutcome:"Implant specialist, Colombia/Andean region specialist practice", modules:["Implant biology","Surgical placement","Bone augmentation","Digital planning","Prosthetics","Thesis"], docsRequired:["Degree","2 references","Research proposal","CV"], applicationLink:"https://www.unal.edu.co", accredited:true },
  { id:"197", university:"Tecnológico de Monterrey (ITESM)", country:"Mexico", flag:"🇲🇽", city:"Monterrey", specialty:"Digital Dentistry", degree:"MSc", duration:"2 years PT", format:"Academic + Online", tuition:"MXN 80,000/year (~€4,000)", totalCost:"~MXN 175,000", livingCost:"~€700/mo", language:"Spanish / English", ielts:"6.0", gpa:"Good standing", clinicalExp:"1+ year", deadline:"May 31, 2026", intake:"August", classSize:"20–30", acceptanceRate:"~40%", casesRequired:"Portfolio-based", thesisRequired:true, interviewRequired:false, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:150, satisfactionScore:4.2, careerOutcome:"Digital specialist, Mexico/Latin America practice, tech career", modules:["CAD/CAM","3D printing","Digital impressions","AI tools","Workflow","Thesis"], docsRequired:["Degree","IELTS 6.0 or Spanish B2","1 reference","Portfolio"], applicationLink:"https://tec.mx", accredited:true },
  { id:"198", university:"Universidad Peruana Cayetano Heredia – Orthodontics", country:"Peru", flag:"🇵🇪", city:"Lima", specialty:"Orthodontics", degree:"MSc", duration:"2 years FT", format:"Clinical + Academic", tuition:"PEN 18,000/year (~€4,500)", totalCost:"~PEN 40,000", livingCost:"~€530/mo", language:"Spanish", ielts:"N/A – Spanish required", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Apr 30, 2026", intake:"March", classSize:"4–8", acceptanceRate:"~28%", casesRequired:"80 orthodontic cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:320, satisfactionScore:4.0, careerOutcome:"Orthodontist, Peru/Latin America specialist", modules:["Fixed appliances","Aligners","Cephalometrics","Digital orthodontics","Retention","Thesis"], docsRequired:["Degree","2 references","CV","Interview"], applicationLink:"https://www.upch.edu.pe", accredited:true },
  { id:"199", university:"University of Rwanda – Oral Pathology", country:"Rwanda", flag:"🇷🇼", city:"Kigali", specialty:"Oral Pathology", degree:"MMed (Dent)", duration:"3 years FT", format:"Clinical + Research", tuition:"RWF 1,000,000/year (~€750)", totalCost:"~RWF 3,200,000", livingCost:"~€400/mo", language:"English / Kinyarwanda", ielts:"N/A", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Sep 30, 2026", intake:"October", classSize:"2–3", acceptanceRate:"~25%", casesRequired:"Research-based case series", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:500, satisfactionScore:3.5, careerOutcome:"Oral pathologist, Rwanda/East Africa diagnostic service, academic", modules:["Oral mucosal disease","Salivary gland pathology","Head & neck oncology","Histopathology","Research methods","Thesis"], docsRequired:["Degree","Rwanda Medical Council reg.","2 references","Research proposal"], applicationLink:"https://www.ur.ac.rw", accredited:true },
  { id:"200", university:"Universidade Federal do Rio Grande do Sul (UFRGS)", country:"Brazil", flag:"🇧🇷", city:"Porto Alegre", specialty:"Oral Surgery", degree:"MSc", duration:"2 years FT", format:"Clinical + Research", tuition:"BRL 0 (public university)", totalCost:"~BRL 12,000 (fees)", livingCost:"~€450/mo", language:"Portuguese", ielts:"N/A – Portuguese required", gpa:"Good standing", clinicalExp:"1+ year", deadline:"Nov 30, 2025", intake:"March", classSize:"4–6", acceptanceRate:"~20%", casesRequired:"200 surgical cases", thesisRequired:true, interviewRequired:true, scholarship:false, scholarshipDetail:"", egyptianGovtFunding:false, recognizedEgypt:false, recognizedUAE:false, recognizedKSA:false, recognizedQatar:false, qsRanking:200, satisfactionScore:4.2, careerOutcome:"Oral surgeon, Brazil/LATAM specialist practice, academic", modules:["Dentoalveolar surgery","Cysts & pathology","Facial trauma","Implant surgery","Sedation","Thesis"], docsRequired:["Degree","Portuguese B2","2 references","Research proposal","Interview"], applicationLink:"https://www.ufrgs.br", accredited:true },
];

const specialties = ["All Specialties", "Endodontics", "Implantology", "Orthodontics", "Prosthodontics", "Oral Surgery", "Periodontology", "Digital Dentistry", "Oral Pathology"];
const countries_list = ["All Countries", "United Kingdom", "Australia", "Germany", "Canada", "United States", "New Zealand", "Netherlands", "Sweden", "France", "Italy", "Spain", "Ireland", "Japan", "South Korea", "Singapore", "United Arab Emirates", "Saudi Arabia", "South Africa", "Portugal", "Belgium", "Switzerland", "Austria", "Denmark", "Norway", "Finland", "Poland", "Czech Republic", "Hungary", "Greece", "Jordan", "Lebanon", "Kuwait", "Oman", "Morocco", "Tunisia", "Egypt", "Qatar", "Bahrain", "India", "China", "Hong Kong", "Thailand", "Malaysia", "Philippines", "Pakistan", "Taiwan", "Indonesia", "Brazil", "Mexico", "Chile", "Argentina", "Colombia", "Peru", "Kenya", "Nigeria", "Turkey", "Serbia", "Georgia", "Romania", "Croatia", "Bulgaria", "Ukraine", "Slovakia", "Slovenia", "Estonia", "Latvia", "Lithuania", "Cyprus", "Malta", "Armenia", "Azerbaijan", "Iceland", "Albania", "Bosnia & Herzegovina", "North Macedonia", "Montenegro", "Belarus", "Moldova", "Algeria", "Libya", "Sudan", "Iraq", "Iran", "Ethiopia", "Tanzania", "Uganda", "Cameroon", "Senegal", "Ivory Coast", "Zimbabwe", "Zambia", "Mozambique", "Botswana", "Namibia", "Mauritius", "Rwanda", "Angola", "Benin", "Vietnam", "Bangladesh", "Sri Lanka", "Nepal", "Cambodia", "Myanmar", "Mongolia", "Kazakhstan", "Uzbekistan", "Kyrgyzstan", "Cuba", "Venezuela", "Ecuador", "Bolivia", "Paraguay", "Uruguay", "Costa Rica", "Panama", "Dominican Republic", "Guatemala", "Jamaica", "Honduras", "Russia", "Cape Verde"];
const sortOptions = ["Deadline (Soonest)", "Ranking (Best)", "Tuition (Lowest)", "Acceptance Rate"];

type Program = typeof programs[0];

function RecognitionDot({ active, label }: { active: boolean; label: string }) {
  return (
    <div style={{ display: "flex", flexDirection: "column" as const, alignItems: "center", gap: 3 }}>
      <div style={{ width: 10, height: 10, borderRadius: "50%", background: active ? "#2D9B68" : brand.borderGray }} />
      <span style={{ fontFamily: "Inter", fontSize: 9, color: active ? "#2D9B68" : brand.warmGray, fontWeight: active ? 600 : 400 }}>{label}</span>
    </div>
  );
}

function ProgramCard({ p, isSaved, isComparing, onSave, onCompare, onView }: {
  p: Program; isSaved: boolean; isComparing: boolean;
  onSave: () => void; onCompare: () => void; onView: () => void;
}) {
  const [expanded, setExpanded] = useState(false);

  const daysToDeadline = Math.ceil((new Date(p.deadline).getTime() - Date.now()) / 86400000);
  const deadlineUrgent = daysToDeadline > 0 && daysToDeadline < 60;
  const deadlinePassed = daysToDeadline <= 0;

  return (
    <div style={{ background: brand.white, borderRadius: 22, border: `2px solid ${isComparing ? brand.orange : brand.borderGray}`, overflow: "hidden", transition: "transform 0.2s, box-shadow 0.2s" }}
      onMouseEnter={(e) => { (e.currentTarget as HTMLElement).style.transform = "translateY(-3px)"; (e.currentTarget as HTMLElement).style.boxShadow = "0 10px 28px rgba(27,27,27,0.09)"; }}
      onMouseLeave={(e) => { (e.currentTarget as HTMLElement).style.transform = "none"; (e.currentTarget as HTMLElement).style.boxShadow = "none"; }}
    >
      {/* Top stripe */}
      <div style={{ height: 4, background: isComparing ? gradientFlow : deadlineUrgent ? brand.red : brand.borderGray }} />

      {deadlineUrgent && (
        <div style={{ background: `${brand.red}12`, borderBottom: `1px solid ${brand.red}25`, padding: "6px 20px", display: "flex", gap: 6, alignItems: "center" }}>
          <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: brand.red }}>⚠ CLOSING SOON</span>
          <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.red }}>— only {daysToDeadline} days left to apply</span>
        </div>
      )}
      {p.scholarship && (
        <div style={{ background: "rgba(45,155,104,0.07)", borderBottom: "1px solid rgba(45,155,104,0.12)", padding: "5px 20px", display: "flex", gap: 5, alignItems: "center" }}>
          <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: "#2D9B68" }}>🎓 SCHOLARSHIP AVAILABLE</span>
        </div>
      )}

      <div style={{ padding: "20px 20px 16px" }}>
        {/* Header row */}
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 12 }}>
          <div style={{ display: "flex", gap: 10, alignItems: "center" }}>
            <FlagImg country={p.country} size={26} />
            <div>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal, lineHeight: 1.3 }}>{p.university}</div>
              <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, display: "flex", alignItems: "center", gap: 3 }}>
                <MapPin size={10} /> {p.city}, {p.country}
              </div>
            </div>
          </div>
          <div style={{ display: "flex", gap: 6, alignItems: "center" }}>
            {/* QS Ranking badge */}
            <div style={{ background: brand.deepCharcoal, borderRadius: 8, padding: "3px 8px", display: "flex", flexDirection: "column" as const, alignItems: "center" }}>
              <span style={{ fontFamily: "Inter", fontWeight: 800, fontSize: 13, color: brand.gold }}>#{p.qsRanking}</span>
              <span style={{ fontFamily: "Inter", fontSize: 8, color: "rgba(255,255,255,0.4)", letterSpacing: "0.05em" }}>QS</span>
            </div>
            <button onClick={onSave} style={{ background: "none", border: "none", cursor: "pointer", color: isSaved ? brand.amber : brand.borderGray }}>
              <Bookmark size={16} fill={isSaved ? brand.amber : "none"} />
            </button>
          </div>
        </div>

        {/* Degree + specialty */}
        <GradientBadge small>{p.specialty}</GradientBadge>
        <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 17, color: brand.charcoal, margin: "8px 0 4px", lineHeight: 1.3 }}>{p.degree} in {p.specialty}</div>
        <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginBottom: 12 }}>{p.format} · {p.intake} intake · {p.classSize}</div>

        {/* Key stats grid */}
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 8, marginBottom: 12 }}>
          {[
            { icon: <Clock size={11} />, label: "Duration", value: p.duration },
            { icon: <DollarSign size={11} />, label: "Total Cost", value: (() => { const usd = toUSD(p.totalCost); return usd && usd !== p.totalCost ? `${p.totalCost} (${usd})` : p.totalCost; })() },
            { icon: <Globe size={11} />, label: "Language", value: p.language },
            { icon: <Users size={11} />, label: "Acceptance", value: p.acceptanceRate },
          ].map(({ icon, label, value }) => (
            <div key={label} style={{ background: brand.offWhite, borderRadius: 10, padding: "9px 11px" }}>
              <div style={{ display: "flex", gap: 4, alignItems: "center", fontFamily: "Inter", fontSize: 9, color: brand.warmGray, marginBottom: 2, textTransform: "uppercase" as const, letterSpacing: "0.05em" }}>{icon} {label}</div>
              <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal }}>{value}</div>
            </div>
          ))}
        </div>

        {/* Entry requirements row */}
        <div style={{ background: `${brand.amber}0C`, border: `1px solid ${brand.amber}25`, borderRadius: 10, padding: "9px 12px", marginBottom: 12 }}>
          <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 10, color: brand.amber, textTransform: "uppercase" as const, letterSpacing: "0.06em", marginBottom: 5 }}>Entry Requirements</div>
          <div style={{ display: "flex", gap: 14, flexWrap: "wrap" }}>
            <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.charcoal }}><strong>IELTS:</strong> {p.ielts}</span>
            <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.charcoal }}><strong>GPA:</strong> {p.gpa}</span>
            <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.charcoal }}><strong>Exp:</strong> {p.clinicalExp}</span>
          </div>
        </div>

        {/* Recognition row */}
        <div style={{ marginBottom: 12 }}>
          <div style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em", marginBottom: 6 }}>Recognition</div>
          <div style={{ display: "flex", gap: 14 }}>
            <RecognitionDot active={p.recognizedEgypt} label="Egypt" />
            <RecognitionDot active={p.recognizedUAE} label="UAE" />
            <RecognitionDot active={p.recognizedKSA} label="KSA" />
            <RecognitionDot active={p.recognizedQatar} label="Qatar" />
          </div>
        </div>

        {/* Badges row */}
        <div style={{ display: "flex", gap: 6, flexWrap: "wrap", marginBottom: 12 }}>
          {p.scholarship && <span style={{ fontFamily: "Inter", fontSize: 10, fontWeight: 600, color: "#2D9B68", background: "rgba(45,155,104,0.08)", borderRadius: 5, padding: "2px 7px" }}>🎓 Scholarship</span>}
          {p.egyptianGovtFunding && <span style={{ fontFamily: "Inter", fontSize: 10, fontWeight: 600, color: brand.orange, background: `${brand.orange}10`, borderRadius: 5, padding: "2px 7px" }}>🇪🇬 Govt Funding</span>}
          {p.thesisRequired && <span style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray, background: brand.paleGray, borderRadius: 5, padding: "2px 7px" }}>Thesis Required</span>}
          {p.interviewRequired && <span style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray, background: brand.paleGray, borderRadius: 5, padding: "2px 7px" }}>Interview</span>}
          <span style={{ fontFamily: "Inter", fontSize: 10, color: "#496FA8", background: "rgba(73,111,168,0.08)", borderRadius: 5, padding: "2px 7px" }}>★ {p.satisfactionScore}</span>
        </div>

        {/* Expandable section */}
        {expanded && (
          <div style={{ borderTop: `1px solid ${brand.borderGray}`, paddingTop: 14, marginBottom: 12 }}>
            {/* Modules */}
            <div style={{ marginBottom: 12 }}>
              <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: brand.charcoal, marginBottom: 7, display: "flex", alignItems: "center", gap: 5 }}>
                <BookOpen size={11} color={brand.orange} /> Curriculum Highlights
              </div>
              <div style={{ display: "flex", flexDirection: "column" as const, gap: 4 }}>
                {p.modules.map((m) => (
                  <div key={m} style={{ display: "flex", gap: 6, alignItems: "flex-start" }}>
                    <div style={{ width: 4, height: 4, borderRadius: "50%", background: brand.orange, flexShrink: 0, marginTop: 5 }} />
                    <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, lineHeight: 1.5 }}>{m}</span>
                  </div>
                ))}
              </div>
            </div>
            {/* Docs required */}
            <div style={{ marginBottom: 12 }}>
              <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: brand.charcoal, marginBottom: 7, display: "flex", alignItems: "center", gap: 5 }}>
                <FileText size={11} color={brand.orange} /> Documents Required
              </div>
              <div style={{ display: "flex", flexWrap: "wrap", gap: 5 }}>
                {p.docsRequired.map((d) => (
                  <span key={d} style={{ fontFamily: "Inter", fontSize: 10, color: brand.charcoal, background: brand.offWhite, border: `1px solid ${brand.borderGray}`, borderRadius: 6, padding: "3px 8px" }}>{d}</span>
                ))}
              </div>
            </div>
            {/* Career outcome */}
            <div style={{ background: `${brand.orange}08`, borderRadius: 10, padding: "10px 12px" }}>
              <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 10, color: brand.orange, textTransform: "uppercase" as const, letterSpacing: "0.06em", marginBottom: 4 }}>Career Outcome</div>
              <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.charcoal, lineHeight: 1.5 }}>{p.careerOutcome}</div>
            </div>
            {/* Scholarship detail */}
            {p.scholarship && p.scholarshipDetail && (
              <div style={{ background: "rgba(45,155,104,0.06)", borderRadius: 10, padding: "10px 12px", marginTop: 8 }}>
                <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 10, color: "#2D9B68", textTransform: "uppercase" as const, letterSpacing: "0.06em", marginBottom: 4 }}>Scholarship</div>
                <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.charcoal }}>{p.scholarshipDetail}</div>
              </div>
            )}
            {/* Living cost */}
            <div style={{ marginTop: 8, fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>
              <strong style={{ color: brand.charcoal }}>Living cost:</strong> {p.livingCost} · <strong style={{ color: brand.charcoal }}>Cases:</strong> {p.casesRequired}
            </div>
          </div>
        )}

        {/* Deadline */}
        <div style={{ display: "flex", alignItems: "center", gap: 6, marginBottom: 14, fontFamily: "Inter", fontSize: 12, color: deadlinePassed ? brand.warmGray : deadlineUrgent ? brand.red : brand.charcoal }}>
          <Calendar size={12} color={deadlinePassed ? brand.borderGray : deadlineUrgent ? brand.red : brand.orange} />
          {deadlinePassed
            ? <span>Deadline passed · {p.deadline}</span>
            : deadlineUrgent
              ? <span><strong>⚠ {daysToDeadline} days left</strong> · {p.deadline}</span>
              : <span>Deadline: <strong>{p.deadline}</strong></span>
          }
        </div>

        {/* Actions */}
        <div style={{ display: "flex", gap: 8 }}>
          <button onClick={onView} style={{ flex: 1, fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "10px", cursor: "pointer" }}>View Full Details</button>
          <button onClick={() => setExpanded(!expanded)} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 12, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 10, padding: "10px 12px", cursor: "pointer", display: "flex", alignItems: "center", gap: 4 }}>
            {expanded ? <ChevronUp size={14} /> : <ChevronDown size={14} />}
            {expanded ? "Less" : "More"}
          </button>
          <button onClick={onCompare} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 12, color: isComparing ? brand.orange : brand.warmGray, background: isComparing ? "rgba(255,107,26,0.08)" : brand.offWhite, border: `1.5px solid ${isComparing ? brand.orange : brand.borderGray}`, borderRadius: 10, padding: "10px 12px", cursor: "pointer" }}>
            {isComparing ? "✓" : "Compare"}
          </button>
        </div>
      </div>
    </div>
  );
}

function parseTotalCostUSD(_totalCost: string, tuitionStr: string, years: number): number {
  const rates: Record<string, number> = { "£": 1.27, "€": 1.09, "AUD": 0.66, "NZD": 0.61, "CAD": 0.74, "SGD": 0.74, "AED": 0.27, "CHF": 1.12 };
  for (const [sym, rate] of Object.entries(rates)) {
    const re = new RegExp(`${sym.replace(".", "\\.")}\\s*([\\d,]+)`);
    const m = tuitionStr.match(re);
    if (m) return Math.round(parseFloat(m[1].replace(/,/g, "")) * rate * years);
  }
  const mUSD = tuitionStr.match(/\$([\d,]+)/);
  if (mUSD) return parseFloat(mUSD[1].replace(/,/g, "")) * years;
  return 0;
}

function parseLivingCostMonthlyUSD(livingCost: string): number {
  const rates: Record<string, number> = { "£": 1.27, "€": 1.09, "AUD": 0.66, "NZD": 0.61, "CAD": 0.74, "SGD": 0.74, "AED": 0.27, "CHF": 1.12 };
  for (const [sym, rate] of Object.entries(rates)) {
    const re = new RegExp(`${sym.replace(".", "\\.")}\\s*([\\d,]+)`);
    const m = livingCost.match(re);
    if (m) return Math.round(parseFloat(m[1].replace(/,/g, "")) * rate);
  }
  const mUSD = livingCost.match(/\$([\d,]+)/);
  if (mUSD) return parseFloat(mUSD[1].replace(/,/g, ""));
  return 0;
}

const BFM_SPECIALTIES = ["Any", ...["Endodontics", "Implantology", "Orthodontics", "Prosthodontics", "Oral Surgery", "Periodontology", "Digital Dentistry", "Oral Pathology"]];
const BFM_BUDGETS = [
  { label: "Under $20,000", max: 20000 },
  { label: "$20,000 – $60,000", max: 60000 },
  { label: "$60,000 – $150,000", max: 150000 },
  { label: "No limit", max: Infinity },
];
const BFM_ENGLISH = [
  { label: "Native / Near-native (IELTS 8+)", min: 8.0 },
  { label: "Advanced (IELTS 7.0–7.5)", min: 7.0 },
  { label: "Upper-intermediate (IELTS 6.0–6.5)", min: 6.0 },
  { label: "No English required (French/German/etc.)", min: 0 },
];

function BestForMeQuiz({ onClose, onApply }: { onClose: () => void; onApply: (spec: string, maxBudget: number, minIelts: number) => void }) {
  const [step, setStep] = useState(0);
  const [spec, setSpec] = useState("Any");
  const [budget, setBudget] = useState(BFM_BUDGETS[3]);
  const [english, setEnglish] = useState(BFM_ENGLISH[1]);

  const questions = [
    {
      q: "Which specialty are you aiming for?",
      sub: "We'll filter programs to match your clinical goals.",
      render: () => (
        <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
          {BFM_SPECIALTIES.map((s) => (
            <button key={s} onClick={() => setSpec(s)}
              style={{ fontFamily: "Inter", fontWeight: spec === s ? 700 : 400, fontSize: 14, color: spec === s ? "#fff" : brand.charcoal, background: spec === s ? gradientFlow : brand.offWhite, border: `1.5px solid ${spec === s ? "transparent" : brand.borderGray}`, borderRadius: 10, padding: "9px 16px", cursor: "pointer" }}>
              {s}
            </button>
          ))}
        </div>
      ),
    },
    {
      q: "What is your total budget? (tuition + living)",
      sub: "All costs converted to USD for easy comparison.",
      render: () => (
        <div style={{ display: "flex", flexDirection: "column" as const, gap: 8 }}>
          {BFM_BUDGETS.map((b) => (
            <button key={b.label} onClick={() => setBudget(b)}
              style={{ fontFamily: "Inter", fontWeight: budget.label === b.label ? 700 : 400, fontSize: 14, color: budget.label === b.label ? "#fff" : brand.charcoal, background: budget.label === b.label ? gradientFlow : brand.offWhite, border: `1.5px solid ${budget.label === b.label ? "transparent" : brand.borderGray}`, borderRadius: 12, padding: "13px 18px", cursor: "pointer", textAlign: "left" as const }}>
              {b.label}
            </button>
          ))}
        </div>
      ),
    },
    {
      q: "What is your English proficiency level?",
      sub: "We'll hide programs whose IELTS requirement is too high.",
      render: () => (
        <div style={{ display: "flex", flexDirection: "column" as const, gap: 8 }}>
          {BFM_ENGLISH.map((e) => (
            <button key={e.label} onClick={() => setEnglish(e)}
              style={{ fontFamily: "Inter", fontWeight: english.label === e.label ? 700 : 400, fontSize: 14, color: english.label === e.label ? "#fff" : brand.charcoal, background: english.label === e.label ? gradientFlow : brand.offWhite, border: `1.5px solid ${english.label === e.label ? "transparent" : brand.borderGray}`, borderRadius: 12, padding: "13px 18px", cursor: "pointer", textAlign: "left" as const }}>
              {e.label}
            </button>
          ))}
        </div>
      ),
    },
  ];

  const isLast = step === questions.length - 1;

  return (
    <div style={{ position: "fixed", inset: 0, zIndex: 9999, display: "flex", alignItems: "center", justifyContent: "center", background: "rgba(18,18,18,0.7)", backdropFilter: "blur(4px)" }} onClick={onClose}>
      <div onClick={(e) => e.stopPropagation()} style={{ background: brand.white, borderRadius: 24, padding: "40px 36px", width: "100%", maxWidth: 520, boxShadow: "0 32px 80px rgba(0,0,0,0.25)", position: "relative" }}>
        <button onClick={onClose} style={{ position: "absolute", top: 16, right: 18, background: "none", border: "none", cursor: "pointer", fontFamily: "Inter", fontSize: 22, color: brand.warmGray }}>×</button>
        {/* Progress */}
        <div style={{ display: "flex", gap: 6, marginBottom: 28 }}>
          {questions.map((_, i) => (
            <div key={i} style={{ flex: 1, height: 4, borderRadius: 2, background: i <= step ? brand.orange : brand.borderGray, transition: "background 0.3s" }} />
          ))}
        </div>
        <div style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 600, color: brand.orange, textTransform: "uppercase" as const, letterSpacing: "0.1em", marginBottom: 6 }}>Question {step + 1} of {questions.length}</div>
        <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.charcoal, marginBottom: 6, lineHeight: 1.3 }}>{questions[step].q}</h2>
        <p style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, marginBottom: 22 }}>{questions[step].sub}</p>
        {questions[step].render()}
        <div style={{ display: "flex", justifyContent: "space-between", marginTop: 28 }}>
          <button onClick={() => step > 0 ? setStep(step - 1) : onClose()}
            style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, background: "none", border: `1.5px solid ${brand.borderGray}`, borderRadius: 10, padding: "10px 20px", cursor: "pointer" }}>
            {step === 0 ? "Cancel" : "← Back"}
          </button>
          <button onClick={() => isLast ? onApply(spec, budget.max, english.min) : setStep(step + 1)}
            style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "10px 24px", cursor: "pointer", boxShadow: "0 4px 16px rgba(255,107,26,0.3)" }}>
            {isLast ? "✨ Show My Programs" : "Next →"}
          </button>
        </div>
      </div>
    </div>
  );
}

function CostEstimator({ onClose }: { onClose: () => void }) {
  const [tuitionPerYear, setTuitionPerYear] = useState(20000);
  const [years, setYears] = useState(2);
  const [livingPerMonth, setLivingPerMonth] = useState(1500);
  const [months, setMonths] = useState(24);
  const totalTuition = tuitionPerYear * years;
  const totalLiving = livingPerMonth * months;
  const totalVisa = 800;
  const totalExam = 600;
  const grandTotal = totalTuition + totalLiving + totalVisa + totalExam;

  return (
    <div style={{ position: "fixed", inset: 0, zIndex: 9998, display: "flex", alignItems: "center", justifyContent: "center", padding: "16px", background: "rgba(18,18,18,0.6)", backdropFilter: "blur(4px)" }} onClick={onClose}>
      <div onClick={(e) => e.stopPropagation()} style={{ background: brand.white, borderRadius: 24, width: "100%", maxWidth: 480, maxHeight: "90vh", display: "flex", flexDirection: "column" as const, boxShadow: "0 24px 60px rgba(0,0,0,0.2)", position: "relative" }}>
        {/* Fixed header */}
        <div style={{ padding: "24px 28px 16px", borderBottom: `1px solid ${brand.borderGray}`, flexShrink: 0 }}>
          <button onClick={onClose} style={{ position: "absolute", top: 14, right: 18, background: "none", border: "none", cursor: "pointer", fontFamily: "Inter", fontSize: 22, color: brand.warmGray }}>×</button>
          <div style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 600, color: brand.amber, textTransform: "uppercase" as const, letterSpacing: "0.1em", marginBottom: 4 }}>Budget Planner</div>
          <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, margin: 0 }}>Total Cost Estimator (USD)</h2>
        </div>

        {/* Scrollable body */}
        <div style={{ overflowY: "auto", padding: "20px 28px 24px", flex: 1 }}>
          {[
            { label: "Tuition per year", value: tuitionPerYear, set: setTuitionPerYear, min: 0, max: 80000, step: 500, format: (v: number) => `$${v.toLocaleString()}` },
            { label: "Program length (years)", value: years, set: setYears, min: 1, max: 5, step: 1, format: (v: number) => `${v} yr` },
            { label: "Living cost per month", value: livingPerMonth, set: setLivingPerMonth, min: 400, max: 5000, step: 100, format: (v: number) => `$${v.toLocaleString()}` },
            { label: "Duration (months)", value: months, set: setMonths, min: 12, max: 60, step: 6, format: (v: number) => `${v} mo` },
          ].map(({ label, value, set, min, max, step, format }) => (
            <div key={label} style={{ marginBottom: 16 }}>
              <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 5 }}>
                <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal }}>{label}</span>
                <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.orange }}>{format(value)}</span>
              </div>
              <input type="range" min={min} max={max} step={step} value={value} onChange={(e) => set(Number(e.target.value))}
                style={{ width: "100%", accentColor: brand.orange }} />
            </div>
          ))}

          <div style={{ background: brand.offWhite, borderRadius: 14, padding: "16px 18px", marginTop: 6 }}>
            {[
              { label: "Tuition total", val: totalTuition },
              { label: "Living expenses", val: totalLiving },
              { label: "Visa & admin fees (est.)", val: totalVisa },
              { label: "Exam & licensing fees (est.)", val: totalExam },
            ].map(({ label, val }) => (
              <div key={label} style={{ display: "flex", justifyContent: "space-between", fontFamily: "Inter", fontSize: 13, color: brand.warmGray, marginBottom: 5 }}>
                <span>{label}</span><span style={{ color: brand.charcoal }}>${val.toLocaleString()}</span>
              </div>
            ))}
            <div style={{ height: 1, background: brand.borderGray, margin: "10px 0" }} />
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
              <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal }}>Estimated Total</span>
              <span style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.orange }}>${grandTotal.toLocaleString()}</span>
            </div>
          </div>

          <p style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginTop: 10, lineHeight: 1.5 }}>Estimate only. Actual costs vary by program, exchange rates, and lifestyle. Always verify with the university.</p>
        </div>
      </div>
    </div>
  );
}

export default function MastersDatabase() {
  const nav = useNavigate();
  const [search, setSearch] = useState("");
  const [specialty, setSpecialty] = useState("All Specialties");
  const [country, setCountry] = useState("All Countries");
  const [scholarshipOnly, setScholarshipOnly] = useState(false);
  const [recognizedOnly, setRecognizedOnly] = useState(false);
  const [egyptianFundingOnly, setEgyptianFundingOnly] = useState(false);
  const [sortBy, setSortBy] = useState(sortOptions[0]);
  const [savedPrograms, setSavedPrograms] = useState<string[]>([]);
  const [compareList, setCompareList] = useState<string[]>([]);
  // New filters
  const [formatFilter, setFormatFilter] = useState("All");
  const [durationFilter, setDurationFilter] = useState("Any");
  const [qsFilter, setQsFilter] = useState("Any");
  const [recognizedUAE, setRecognizedUAE] = useState(false);
  const [recognizedKSA, setRecognizedKSA] = useState(false);
  const [recognizedQatarOnly, setRecognizedQatarOnly] = useState(false);
  const [noIeltsOnly, setNoIeltsOnly] = useState(false);
  const [noInterviewOnly, setNoInterviewOnly] = useState(false);
  const [thesisFilter, setThesisFilter] = useState("Any");
  const [intakeFilter, setIntakeFilter] = useState("Any");
  // New: quiz + estimator
  const [showBFMQuiz, setShowBFMQuiz] = useState(false);
  const [showEstimator, setShowEstimator] = useState(false);
  const [bfmBudgetMax, setBfmBudgetMax] = useState(Infinity);
  const [bfmMinIelts, setBfmMinIelts] = useState(0);

  const clearAllFilters = () => {
    setSpecialty("All Specialties"); setCountry("All Countries"); setSearch("");
    setScholarshipOnly(false); setRecognizedOnly(false); setEgyptianFundingOnly(false);
    setFormatFilter("All"); setDurationFilter("Any"); setQsFilter("Any");
    setRecognizedUAE(false); setRecognizedKSA(false); setRecognizedQatarOnly(false);
    setNoIeltsOnly(false); setNoInterviewOnly(false); setThesisFilter("Any"); setIntakeFilter("Any");
    setBfmBudgetMax(Infinity); setBfmMinIelts(0);
  };

  const activeFilterCount = [
    specialty !== "All Specialties", country !== "All Countries", search !== "",
    scholarshipOnly, recognizedOnly, egyptianFundingOnly,
    formatFilter !== "All", durationFilter !== "Any", qsFilter !== "Any",
    recognizedUAE, recognizedKSA, recognizedQatarOnly,
    noIeltsOnly, noInterviewOnly, thesisFilter !== "Any", intakeFilter !== "Any",
    bfmBudgetMax !== Infinity, bfmMinIelts > 0,
  ].filter(Boolean).length;

  const filtered = programs
    .filter((p) => {
      const matchSearch = p.university.toLowerCase().includes(search.toLowerCase()) || p.specialty.toLowerCase().includes(search.toLowerCase()) || p.city.toLowerCase().includes(search.toLowerCase());
      const matchSpec = specialty === "All Specialties" || p.specialty === specialty;
      const matchCountry = country === "All Countries" || p.country === country;
      const matchScholarship = !scholarshipOnly || p.scholarship;
      const matchRecognized = !recognizedOnly || p.recognizedEgypt;
      const matchFunding = !egyptianFundingOnly || p.egyptianGovtFunding;
      const matchFormat = formatFilter === "All" || (formatFilter === "FT" ? (p.duration.includes("FT") || p.format.includes("FT")) : (p.duration.includes("PT") || p.format.includes("PT")));
      const matchDuration = durationFilter === "Any" || p.duration.startsWith(durationFilter === "1 Year" ? "1" : durationFilter === "2 Years" ? "2" : "3");
      const matchQs = qsFilter === "Any" || (qsFilter === "Top 50" ? p.qsRanking <= 50 : qsFilter === "Top 100" ? p.qsRanking <= 100 : p.qsRanking <= 200);
      const matchUAE = !recognizedUAE || p.recognizedUAE;
      const matchKSA = !recognizedKSA || p.recognizedKSA;
      const matchQatarOnly = !recognizedQatarOnly || p.recognizedQatar;
      const matchNoIelts = !noIeltsOnly || p.ielts === "N/A" || p.ielts.startsWith("N/A");
      const matchNoInterview = !noInterviewOnly || !p.interviewRequired;
      const matchThesis = thesisFilter === "Any" || (thesisFilter === "Thesis" ? p.thesisRequired : !p.thesisRequired);
      const matchIntake = intakeFilter === "Any" || (p.intake ?? "").toLowerCase().includes(intakeFilter.toLowerCase());
      // BFM filters
      const tuitionUSD = parseTotalCostUSD(p.totalCost, p.tuition, parseInt(p.duration) || 2);
      const livingMonthlyUSD = parseLivingCostMonthlyUSD(p.livingCost);
      const programMonths = (parseInt(p.duration) || 2) * 12;
      const totalUSD = tuitionUSD + livingMonthlyUSD * programMonths;
      const matchBudget = bfmBudgetMax === Infinity || totalUSD <= bfmBudgetMax;
      const ieltsNum = parseFloat(p.ielts);
      const matchIelts = bfmMinIelts === 0 || isNaN(ieltsNum) || ieltsNum <= bfmMinIelts + 0.5;
      return matchSearch && matchSpec && matchCountry && matchScholarship && matchRecognized && matchFunding &&
        matchFormat && matchDuration && matchQs && matchUAE && matchKSA && matchQatarOnly &&
        matchNoIelts && matchNoInterview && matchThesis && matchIntake && matchBudget && matchIelts;
    })
    .sort((a, b) => {
      if (sortBy === "Ranking (Best)") return a.qsRanking - b.qsRanking;
      if (sortBy === "Tuition (Lowest)") return parseFloat(a.totalCost.replace(/[^0-9.]/g, "")) - parseFloat(b.totalCost.replace(/[^0-9.]/g, ""));
      if (sortBy === "Acceptance Rate") return parseFloat(a.acceptanceRate) - parseFloat(b.acceptanceRate);
      // Deadline soonest
      return new Date(a.deadline).getTime() - new Date(b.deadline).getTime();
    });

  const toggleSave = (id: string) => setSavedPrograms((prev) => prev.includes(id) ? prev.filter((x) => x !== id) : [...prev, id]);
  const toggleCompare = (id: string) => setCompareList((prev) => prev.includes(id) ? prev.filter((x) => x !== id) : prev.length < 4 ? [...prev, id] : prev);

  const comparePrograms = programs.filter((p) => compareList.includes(p.id));

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Hero */}
      <div style={{ background: brand.charcoal, padding: "56px 24px 48px", position: "relative", overflow: "hidden" }}>
        <div style={{ position: "absolute", inset: 0, background: "radial-gradient(ellipse at 65% 40%, rgba(255,198,46,0.07) 0%, transparent 55%)", pointerEvents: "none" }} />
        <div style={{ maxWidth: 1280, margin: "0 auto", position: "relative" }}>
          <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, letterSpacing: "0.1em", color: brand.amber, textTransform: "uppercase" as const, marginBottom: 10 }}>Career · Postgraduate</div>
          <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(28px,4vw,42px)", color: "#fff", marginBottom: 12 }}>Master's Programs Database</h1>
          <p style={{ fontFamily: "Inter", fontSize: 15, color: "rgba(255,255,255,0.6)", maxWidth: 560, marginBottom: 28, lineHeight: 1.65 }}>
            Searchable database of postgraduate dental programs worldwide — with Egyptian Syndicate recognition, Gulf country status, curriculum details, scholarship info, and application deadlines.
          </p>
          <div style={{ position: "relative", maxWidth: 520 }}>
            <Search size={16} style={{ position: "absolute", left: 14, top: "50%", transform: "translateY(-50%)", color: "rgba(255,255,255,0.4)" }} />
            <input value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Search university, specialty, city…"
              style={{ width: "100%", fontFamily: "Inter", fontSize: 14, background: "rgba(255,255,255,0.1)", border: "1px solid rgba(255,255,255,0.15)", borderRadius: 12, padding: "13px 16px 13px 42px", color: "#fff", outline: "none", boxSizing: "border-box" as const }} />
          </div>
          <div style={{ display: "flex", gap: 12, marginTop: 20, flexWrap: "wrap" }}>
            <button onClick={() => setShowBFMQuiz(true)}
              style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "12px 22px", cursor: "pointer", boxShadow: "0 4px 18px rgba(255,107,26,0.4)", display: "flex", alignItems: "center", gap: 8 }}>
              ✨ Best Program For Me
            </button>
            <button onClick={() => setShowEstimator(true)}
              style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: "#fff", background: "rgba(255,255,255,0.12)", border: "1px solid rgba(255,255,255,0.2)", borderRadius: 12, padding: "12px 20px", cursor: "pointer", display: "flex", alignItems: "center", gap: 8 }}>
              🧮 Cost Estimator
            </button>
          </div>
          <div style={{ display: "flex", gap: 28, marginTop: 20, flexWrap: "wrap" }}>
            {[["200+", "Programs"], ["119", "Countries"], ["6 Regions", "Global Coverage"], ["Free", "To Search"]].map(([v, l]) => (
              <div key={l}><div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 16, color: brand.gold }}>{v}</div><div style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.45)", marginTop: 2 }}>{l}</div></div>
            ))}
          </div>
        </div>
      </div>

      <div style={{ maxWidth: 1280, margin: "0 auto", padding: "32px 24px" }}>
        {/* Filters */}
        <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "18px 20px", marginBottom: 20 }}>
          {/* Row 1: dropdowns + count */}
          <div style={{ display: "flex", gap: 10, flexWrap: "wrap", alignItems: "center", marginBottom: 14 }}>
            <Filter size={14} color={brand.warmGray} />
            <select value={specialty} onChange={(e) => setSpecialty(e.target.value)} style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${specialty !== "All Specialties" ? brand.orange : brand.borderGray}`, borderRadius: 10, padding: "7px 12px", outline: "none" }}>
              {specialties.map((s) => <option key={s}>{s}</option>)}
            </select>
            <select value={country} onChange={(e) => setCountry(e.target.value)} style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${country !== "All Countries" ? brand.orange : brand.borderGray}`, borderRadius: 10, padding: "7px 12px", outline: "none" }}>
              {countries_list.map((c) => <option key={c}>{c}</option>)}
            </select>
            <select value={sortBy} onChange={(e) => setSortBy(e.target.value)} style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 10, padding: "7px 12px", outline: "none" }}>
              {sortOptions.map((s) => <option key={s}>{s}</option>)}
            </select>
            <select value={intakeFilter} onChange={(e) => setIntakeFilter(e.target.value)} style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${intakeFilter !== "Any" ? brand.orange : brand.borderGray}`, borderRadius: 10, padding: "7px 12px", outline: "none" }}>
              {["Any", "September", "October", "January", "February", "March", "July", "August"].map((s) => <option key={s}>{s}</option>)}
            </select>
            <div style={{ marginLeft: "auto", display: "flex", gap: 8, alignItems: "center" }}>
              {activeFilterCount > 0 && (
                <button onClick={clearAllFilters} style={{ fontFamily: "Inter", fontSize: 12, fontWeight: 600, color: brand.red, background: `${brand.red}08`, border: `1px solid ${brand.red}20`, borderRadius: 8, padding: "5px 10px", cursor: "pointer" }}>Clear {activeFilterCount}</button>
              )}
              <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, fontWeight: 600 }}>{filtered.length} <span style={{ fontWeight: 400 }}>of {programs.length}</span></span>
            </div>
          </div>

          <div style={{ height: 1, background: brand.borderGray, margin: "0 0 14px" }} />

          {/* Row 2: chip filters grouped by category */}
          <div style={{ display: "flex", gap: 20, flexWrap: "wrap", alignItems: "flex-start" }}>
            {/* Format */}
            <div style={{ display: "flex", gap: 6, alignItems: "center" }}>
              <span style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 600, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em", whiteSpace: "nowrap" as const }}>Format</span>
              {["All", "FT", "PT"].map((f) => (
                <button key={f} onClick={() => setFormatFilter(f)} style={{ fontFamily: "Inter", fontSize: 12, fontWeight: 500, color: formatFilter === f ? "#fff" : brand.charcoal, background: formatFilter === f ? brand.orange : brand.offWhite, border: `1.5px solid ${formatFilter === f ? brand.orange : brand.borderGray}`, borderRadius: 8, padding: "4px 11px", cursor: "pointer" }}>{f === "FT" ? "Full-time" : f === "PT" ? "Part-time" : "All"}</button>
              ))}
            </div>

            <div style={{ width: 1, background: brand.borderGray, alignSelf: "stretch" }} />

            {/* Duration */}
            <div style={{ display: "flex", gap: 6, alignItems: "center" }}>
              <span style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 600, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em", whiteSpace: "nowrap" as const }}>Duration</span>
              {["Any", "1 Year", "2 Years", "3 Years"].map((d) => (
                <button key={d} onClick={() => setDurationFilter(d)} style={{ fontFamily: "Inter", fontSize: 12, fontWeight: 500, color: durationFilter === d ? "#fff" : brand.charcoal, background: durationFilter === d ? brand.orange : brand.offWhite, border: `1.5px solid ${durationFilter === d ? brand.orange : brand.borderGray}`, borderRadius: 8, padding: "4px 11px", cursor: "pointer" }}>{d}</button>
              ))}
            </div>

            <div style={{ width: 1, background: brand.borderGray, alignSelf: "stretch" }} />

            {/* QS Rank */}
            <div style={{ display: "flex", gap: 6, alignItems: "center" }}>
              <span style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 600, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em", whiteSpace: "nowrap" as const }}>QS Rank</span>
              {["Any", "Top 50", "Top 100", "Top 200"].map((q) => (
                <button key={q} onClick={() => setQsFilter(q)} style={{ fontFamily: "Inter", fontSize: 12, fontWeight: 500, color: qsFilter === q ? "#fff" : brand.charcoal, background: qsFilter === q ? brand.gold : brand.offWhite, border: `1.5px solid ${qsFilter === q ? brand.gold : brand.borderGray}`, borderRadius: 8, padding: "4px 11px", cursor: "pointer" }}>{q}</button>
              ))}
            </div>

            <div style={{ width: 1, background: brand.borderGray, alignSelf: "stretch" }} />

            {/* Thesis */}
            <div style={{ display: "flex", gap: 6, alignItems: "center" }}>
              <span style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 600, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em", whiteSpace: "nowrap" as const }}>Thesis</span>
              {["Any", "Thesis", "No Thesis"].map((t) => (
                <button key={t} onClick={() => setThesisFilter(t)} style={{ fontFamily: "Inter", fontSize: 12, fontWeight: 500, color: thesisFilter === t ? "#fff" : brand.charcoal, background: thesisFilter === t ? brand.amber : brand.offWhite, border: `1.5px solid ${thesisFilter === t ? brand.amber : brand.borderGray}`, borderRadius: 8, padding: "4px 11px", cursor: "pointer" }}>{t}</button>
              ))}
            </div>
          </div>

          {/* Row 3: toggle buttons */}
          <div style={{ display: "flex", gap: 8, flexWrap: "wrap", marginTop: 12 }}>
            {[
              { label: "🎓 Scholarship", active: scholarshipOnly, toggle: () => setScholarshipOnly(!scholarshipOnly), color: "#2D9B68" },
              { label: "🇪🇬 Recognized Egypt", active: recognizedOnly, toggle: () => setRecognizedOnly(!recognizedOnly), color: "#2D9B68" },
              { label: "🇦🇪 Recognized UAE", active: recognizedUAE, toggle: () => setRecognizedUAE(!recognizedUAE), color: brand.amber },
              { label: "🇸🇦 Recognized KSA", active: recognizedKSA, toggle: () => setRecognizedKSA(!recognizedKSA), color: brand.amber },
              { label: "🇶🇦 Recognized Qatar", active: recognizedQatarOnly, toggle: () => setRecognizedQatarOnly(!recognizedQatarOnly), color: brand.amber },
              { label: "No IELTS Required", active: noIeltsOnly, toggle: () => setNoIeltsOnly(!noIeltsOnly), color: brand.orange },
              { label: "No Interview", active: noInterviewOnly, toggle: () => setNoInterviewOnly(!noInterviewOnly), color: brand.orange },
              { label: "🇪🇬 Govt Funding", active: egyptianFundingOnly, toggle: () => setEgyptianFundingOnly(!egyptianFundingOnly), color: brand.red },
            ].map(({ label, active, toggle, color }) => (
              <button key={label} onClick={toggle} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 12, color: active ? color : brand.charcoal, background: active ? `${color}12` : brand.offWhite, border: `1.5px solid ${active ? color : brand.borderGray}`, borderRadius: 20, padding: "5px 13px", cursor: "pointer", transition: "all 0.15s" }}>{label}</button>
            ))}
          </div>
        </div>

        {/* BFM active banner */}
        {(bfmBudgetMax !== Infinity || bfmMinIelts > 0) && (
          <div style={{ background: `linear-gradient(90deg, ${brand.orange}18, ${brand.amber}12)`, border: `1.5px solid ${brand.orange}30`, borderRadius: 12, padding: "12px 18px", marginBottom: 16, display: "flex", gap: 10, alignItems: "center" }}>
            <span style={{ fontSize: 18 }}>✨</span>
            <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal }}>Best For Me filters active</span>
            <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>— Showing programs matched to your specialty, budget & English level</span>
            <button onClick={() => { setBfmBudgetMax(Infinity); setBfmMinIelts(0); setSpecialty("All Specialties"); }}
              style={{ marginLeft: "auto", fontFamily: "Inter", fontSize: 12, color: brand.red, background: `${brand.red}08`, border: `1px solid ${brand.red}20`, borderRadius: 8, padding: "4px 10px", cursor: "pointer" }}>
              Clear quiz
            </button>
          </div>
        )}

        {/* Recognition legend */}
        <div style={{ background: brand.white, borderRadius: 12, border: `1px solid ${brand.borderGray}`, padding: "10px 16px", marginBottom: 20, display: "flex", gap: 20, flexWrap: "wrap", alignItems: "center" }}>
          <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, fontWeight: 600 }}>Recognition legend:</span>
          <span style={{ fontFamily: "Inter", fontSize: 11, color: "#2D9B68" }}>● Recognized</span>
          <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.borderGray }}>● Not recognized</span>
          <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>· Egypt · UAE · KSA · Qatar shown on each card</span>
          <div style={{ marginLeft: "auto" }}>
            <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.red }}>⚠ Red deadline = &lt;60 days remaining</span>
          </div>
        </div>

        {/* Grid */}
        {filtered.length === 0 ? (
          <div style={{ textAlign: "center" as const, padding: "60px 24px" }}>
            <div style={{ fontSize: 40, marginBottom: 16 }}>🔍</div>
            <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 16, color: brand.charcoal, marginBottom: 8 }}>No programs match your filters</div>
            <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray }}>Try removing a filter or broadening your search.</div>
          </div>
        ) : (
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(360px, 1fr))", gap: 20, paddingBottom: compareList.length > 0 ? 90 : 0 }}>
            {filtered.map((p) => (
              <ProgramCard
                key={p.id} p={p}
                isSaved={savedPrograms.includes(p.id)}
                isComparing={compareList.includes(p.id)}
                onSave={() => toggleSave(p.id)}
                onCompare={() => toggleCompare(p.id)}
                onView={() => nav(`/masters/${p.id}`)}
              />
            ))}
          </div>
        )}
      </div>

      {/* Sticky compare tray */}
      {compareList.length > 0 && (
        <div style={{ position: "fixed", bottom: 0, left: 0, right: 0, zIndex: 9000, background: brand.deepCharcoal, borderTop: `2px solid ${brand.orange}`, padding: "14px 24px", display: "flex", gap: 12, alignItems: "center", flexWrap: "wrap", boxShadow: "0 -8px 32px rgba(0,0,0,0.3)" }}>
          <GraduationCap size={18} color={brand.gold} />
          <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff" }}>Compare tray ({compareList.length}/4)</span>
          <div style={{ display: "flex", gap: 8, flex: 1, flexWrap: "wrap" }}>
            {comparePrograms.map((p) => (
              <div key={p.id} style={{ display: "flex", gap: 6, alignItems: "center", fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.8)", background: "rgba(255,255,255,0.1)", borderRadius: 8, padding: "5px 10px" }}>
                <FlagImg country={p.country} size={16} /> {p.university.split(" ").slice(0, 3).join(" ")}
                <button onClick={() => toggleCompare(p.id)} style={{ background: "none", border: "none", cursor: "pointer", color: "rgba(255,255,255,0.4)", fontSize: 14, lineHeight: 1, padding: 0 }}>×</button>
              </div>
            ))}
            {compareList.length < 4 && (
              <div style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.35)", padding: "5px 10px", border: "1px dashed rgba(255,255,255,0.2)", borderRadius: 8 }}>+ Add up to {4 - compareList.length} more</div>
            )}
          </div>
          <button onClick={() => nav("/masters/compare")} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "10px 22px", cursor: "pointer", boxShadow: "0 2px 12px rgba(255,107,26,0.4)" }}>Compare Now →</button>
          <button onClick={() => setCompareList([])} style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.4)", background: "none", border: "1px solid rgba(255,255,255,0.15)", borderRadius: 8, padding: "8px 14px", cursor: "pointer" }}>Clear all</button>
        </div>
      )}

      {/* Modals */}
      {showBFMQuiz && (
        <BestForMeQuiz
          onClose={() => setShowBFMQuiz(false)}
          onApply={(spec, maxBudget, minIelts) => {
            if (spec !== "Any") setSpecialty(spec);
            setBfmBudgetMax(maxBudget);
            setBfmMinIelts(minIelts);
            setShowBFMQuiz(false);
          }}
        />
      )}
      {showEstimator && <CostEstimator onClose={() => setShowEstimator(false)} />}
    </div>
  );
}
