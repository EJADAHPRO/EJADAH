import { useState } from "react";
import { useNavigate } from "react-router";
import {
  Star, Clock, Globe, Video, MapPin, Search, Filter,
  ChevronDown, Zap, MessageSquare, CheckCircle, ArrowRight, Users, BookOpen,
} from "lucide-react";
import { brand, gradientFlow, GradientBadge, EG_DENTAL_UNIVERSITIES } from "@/app/shared";

// ─── Types ────────────────────────────────────────────────────────────────────

interface Tutor {
  id: string;
  name: string;
  title: string;
  specialty: string;
  subjects: string[];
  category: "Pre-Clinical" | "Clinical" | "Exam Prep";
  level: string;            // e.g. "Years 1–3" | "Years 4–6" | "Postgraduate"
  country: string;
  languages: string[];
  rating: number;
  reviews: number;
  sessions: number;
  priceHour: number;
  currency: "EGP" | "USD";
  available: boolean;
  online: boolean;
  offline: boolean;
  avatar: string;
  intro: string;
  nextSlot: string;
  verified: boolean;
  featured: boolean;
  // University staff
  university?: string;
  position?: string;
}

// ─── Data ─────────────────────────────────────────────────────────────────────

const tutors: Tutor[] = [

  // ── University Faculty (EGP) ──────────────────────────────────────────────

  {
    id: "u1",
    name: "Prof. Sherif Kamel",
    title: "Professor of Oral Biology · Head of Dept",
    specialty: "Oral Biology & Histology",
    subjects: ["Oral Histology", "Dental Embryology", "Tooth Development", "Salivary Gland Histology", "Bone & Periodontium Histology"],
    category: "Pre-Clinical",
    level: "Years 1–3",
    country: "Egypt",
    languages: ["Arabic", "English"],
    rating: 4.9,
    reviews: 187,
    sessions: 820,
    priceHour: 900,
    currency: "EGP",
    available: true,
    online: true,
    offline: true,
    avatar: "https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=200&q=80",
    intro: "Head of Department at Cairo University Faculty of Dentistry. My sessions are built around slides and histological images — the way the exam will actually ask you.",
    nextSlot: "Today, 7:00 PM",
    verified: true,
    featured: true,
    university: "Cairo University",
    position: "Professor & Head of Oral Biology",
  },
  {
    id: "u2",
    name: "Dr. Yasmine Nour",
    title: "Lecturer in Dental Anatomy · BUE Faculty",
    specialty: "Dental Anatomy",
    subjects: ["Tooth Morphology", "Dental Anatomy Carving Prep", "Occlusion Basics", "Root Anatomy", "Pulp Chamber Anatomy"],
    category: "Pre-Clinical",
    level: "Years 1–2",
    country: "Egypt",
    languages: ["Arabic", "English"],
    rating: 4.8,
    reviews: 143,
    sessions: 560,
    priceHour: 500,
    currency: "EGP",
    available: true,
    online: true,
    offline: true,
    avatar: "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=200&q=80",
    intro: "BUE Faculty lecturer specialising in helping Year 1 and 2 students who struggle with carving practicals and the logic of dental morphology. Highly exam-focused sessions.",
    nextSlot: "Today, 5:00 PM",
    verified: true,
    featured: true,
    university: "British University in Egypt (BUE)",
    position: "Lecturer, Dental Anatomy & Morphology",
  },
  {
    id: "u3",
    name: "Dr. Mohamed El-Sherif",
    title: "Lecturer · Oral Physiology & Biochemistry",
    specialty: "Oral Physiology",
    subjects: ["Salivary Functions & Composition", "Mastication Biomechanics", "Taste Physiology", "Pain Pathways", "Oral Biochemistry MCQs"],
    category: "Pre-Clinical",
    level: "Years 1–3",
    country: "Egypt",
    languages: ["Arabic"],
    rating: 4.7,
    reviews: 98,
    sessions: 380,
    priceHour: 420,
    currency: "EGP",
    available: false,
    online: true,
    offline: false,
    avatar: "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=200&q=80",
    intro: "Ain Shams lecturer with a reputation for making physiology actually make sense. My sessions link physiological concepts directly to clinical applications.",
    nextSlot: "Wed, 6:00 PM",
    verified: true,
    featured: false,
    university: "Ain Shams University",
    position: "Lecturer, Oral Physiology Department",
  },
  {
    id: "u4",
    name: "Dr. Hana Ibrahim",
    title: "Faculty Lecturer · Oral Microbiology",
    specialty: "Oral Microbiology",
    subjects: ["Oral Microbiome", "Caries Microbiology", "Periodontal Pathogens", "Sterilisation & Infection Control", "Microbiology MCQ Prep"],
    category: "Pre-Clinical",
    level: "Years 2–3",
    country: "Egypt",
    languages: ["Arabic", "English"],
    rating: 4.8,
    reviews: 112,
    sessions: 440,
    priceHour: 450,
    currency: "EGP",
    available: true,
    online: true,
    offline: false,
    avatar: "https://images.unsplash.com/photo-1619450565660-2a93ba8603fd?w=200&q=80",
    intro: "MIU Faculty with a focus on exam technique. Microbiology looks like memorisation but has underlying logic — once you see it, the MCQs become predictable.",
    nextSlot: "Tomorrow, 4:00 PM",
    verified: false,
    featured: false,
    university: "Misr International University (MIU)",
    position: "Lecturer, Oral Microbiology & Immunology",
  },
  {
    id: "u5",
    name: "Dr. Karim Fouad",
    title: "Anatomy Demonstrator · Faculty of Dentistry",
    specialty: "Head & Neck Anatomy",
    subjects: ["Triangles of the Neck", "Facial Nerve & Branches", "TMJ Anatomy", "Nerve Block Anatomy", "Cranial Nerves for Dentists"],
    category: "Pre-Clinical",
    level: "Years 1–2",
    country: "Egypt",
    languages: ["Arabic", "English"],
    rating: 4.7,
    reviews: 86,
    sessions: 310,
    priceHour: 380,
    currency: "EGP",
    available: true,
    online: true,
    offline: true,
    avatar: "https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=200&q=80",
    intro: "October University demonstrator who makes head and neck anatomy visual and clinically relevant. I use 3D models and illustrations — no more rote memorisation.",
    nextSlot: "Today, 8:00 PM",
    verified: false,
    featured: false,
    university: "October University (MUST)",
    position: "Anatomy Demonstrator, Faculty of Dentistry",
  },
  {
    id: "u6",
    name: "Prof. Rasha El-Gohary",
    title: "Professor of Oral Medicine · Alexandria University",
    specialty: "Oral Medicine & Diagnosis",
    subjects: ["Oral Mucosal Lesions", "Differential Diagnosis", "Systemic Disease Oral Manifestations", "Case Presentation Technique", "Biopsy Interpretation"],
    category: "Clinical",
    level: "Years 4–6",
    country: "Egypt",
    languages: ["Arabic", "English"],
    rating: 4.9,
    reviews: 201,
    sessions: 890,
    priceHour: 750,
    currency: "EGP",
    available: false,
    online: true,
    offline: true,
    avatar: "https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=200&q=80",
    intro: "Professor with 22 years of oral medicine teaching. I run case-based sessions that are identical in format to how oral medicine OSCEs and clinical exams are structured.",
    nextSlot: "Thu, 6:00 PM",
    verified: true,
    featured: true,
    university: "Alexandria University",
    position: "Professor of Oral Medicine & Periodontology",
  },
  {
    id: "u7",
    name: "Dr. Khaled Abbas",
    title: "Senior Lecturer · Oral Radiology & CBCT",
    specialty: "Oral Radiology",
    subjects: ["Periapical & Bitewing Interpretation", "OPG Reading", "CBCT Analysis", "Radiation Safety & Protection", "Radiographic Pathology"],
    category: "Clinical",
    level: "Years 3–5",
    country: "Egypt",
    languages: ["Arabic", "English"],
    rating: 4.8,
    reviews: 154,
    sessions: 620,
    priceHour: 580,
    currency: "EGP",
    available: true,
    online: true,
    offline: true,
    avatar: "https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=200&q=80",
    intro: "Cairo University senior lecturer in oral radiology. CBCT and digital imaging are increasingly examined — my sessions cover both interpretation and the clinical decisions that follow.",
    nextSlot: "Today, 9:00 PM",
    verified: true,
    featured: false,
    university: "Cairo University",
    position: "Senior Lecturer, Oral Radiology",
  },
  {
    id: "u8",
    name: "Prof. Ahmed Salah",
    title: "Professor of Public Health Dentistry · Mansoura",
    specialty: "Community Dentistry",
    subjects: ["Epidemiology of Dental Disease", "Fluoride & Prevention", "Public Health Policies", "Statistics for Dentists", "Community Dentistry Exam Prep"],
    category: "Clinical",
    level: "Years 4–6",
    country: "Egypt",
    languages: ["Arabic"],
    rating: 4.7,
    reviews: 119,
    sessions: 470,
    priceHour: 700,
    currency: "EGP",
    available: true,
    online: true,
    offline: false,
    avatar: "https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=200&q=80",
    intro: "Mansoura University Professor. Community dentistry is highly scoreable once you understand the exam's logic — it rewards systematic, framework-based answers over factual recall.",
    nextSlot: "Tomorrow, 5:00 PM",
    verified: true,
    featured: false,
    university: "Mansoura University",
    position: "Professor of Community & Preventive Dentistry",
  },
  {
    id: "u9",
    name: "Dr. Nour Badran",
    title: "Lecturer · Dental Materials · MSA University",
    specialty: "Dental Materials",
    subjects: ["Composite Resin Properties", "Impression Materials", "Luting Cements", "Alloy Composition & Uses", "Dental Materials MCQ Bank"],
    category: "Pre-Clinical",
    level: "Years 2–4",
    country: "Egypt",
    languages: ["Arabic", "English"],
    rating: 4.6,
    reviews: 88,
    sessions: 340,
    priceHour: 360,
    currency: "EGP",
    available: true,
    online: true,
    offline: false,
    avatar: "https://images.unsplash.com/photo-1657470179447-0f5aa16daa91?w=200&q=80",
    intro: "MSA University lecturer who turns dental materials from a memorisation subject into a logical framework. Once you understand WHY a material has certain properties, the exams become manageable.",
    nextSlot: "Today, 6:30 PM",
    verified: false,
    featured: false,
    university: "MSA University",
    position: "Lecturer, Dental Materials Department",
  },

  // ── Clinical Specialists (EGP) ─────────────────────────────────────────────

  {
    id: "c1",
    name: "Dr. Amira Soliman",
    title: "Endodontist · PhD Cairo University",
    specialty: "Endodontics",
    subjects: ["Root Canal Treatment", "Retreatment", "Rotary Systems", "Irrigation Protocols", "Endodontic Emergency Management"],
    category: "Clinical",
    level: "Years 4–6 & Postgraduate",
    country: "Egypt",
    languages: ["Arabic", "English"],
    rating: 4.9,
    reviews: 284,
    sessions: 1240,
    priceHour: 350,
    currency: "EGP",
    available: true,
    online: true,
    offline: false,
    avatar: "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=200&q=80",
    intro: "I help students and dentists build genuine clinical understanding — not just pass exams. Specialised in rotary systems, complex anatomy, and retreatment cases.",
    nextSlot: "Today, 6:00 PM",
    verified: true,
    featured: false,
  },
  {
    id: "c2",
    name: "Dr. Hany Ibrahim",
    title: "Oral & Maxillofacial Surgeon · PhD",
    specialty: "Oral Surgery",
    subjects: ["Exodontia", "Surgical Flap Design", "Surgical Anatomy", "Complications Management", "Oral Surgery OSCE Prep"],
    category: "Clinical",
    level: "Years 4–6 & Postgraduate",
    country: "Egypt",
    languages: ["Arabic", "English"],
    rating: 4.8,
    reviews: 196,
    sessions: 870,
    priceHour: 500,
    currency: "EGP",
    available: true,
    online: true,
    offline: true,
    avatar: "https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=200&q=80",
    intro: "Practical surgical teaching backed by 15 years of clinical and academic experience. I make complex anatomy understandable and help candidates prepare for high-stakes practical exams.",
    nextSlot: "Tomorrow, 7:00 PM",
    verified: true,
    featured: false,
  },
  {
    id: "c3",
    name: "Dr. Rania Hassan",
    title: "Periodontist · MSc Ain Shams",
    specialty: "Periodontics",
    subjects: ["Periodontal Classification", "Surgical Periodontics", "Implant-Perio Nexus", "Scaling & Root Planing", "Perio Exam Prep"],
    category: "Clinical",
    level: "Years 4–6 & Postgraduate",
    country: "Egypt",
    languages: ["Arabic", "English"],
    rating: 4.8,
    reviews: 221,
    sessions: 960,
    priceHour: 380,
    currency: "EGP",
    available: false,
    online: true,
    offline: true,
    avatar: "https://images.unsplash.com/photo-1657470179447-0f5aa16daa91?w=200&q=80",
    intro: "Periodontics teaching focused on clinical application and exam technique. Strong track record with Year 5–6 students and postgraduate candidates over 7 years.",
    nextSlot: "Thu, 6:00 PM",
    verified: true,
    featured: false,
  },
  {
    id: "c4",
    name: "Dr. Ahmed Nour",
    title: "Operative Dentist · Lecturer Ain Shams",
    specialty: "Operative Dentistry",
    subjects: ["Cavity Design & Preparation", "Composite Layering", "Tooth Preparation for Crown", "Pre-clinical Operative", "Class I–V Restorations"],
    category: "Clinical",
    level: "Years 3–5",
    country: "Egypt",
    languages: ["Arabic", "English"],
    rating: 4.8,
    reviews: 167,
    sessions: 730,
    priceHour: 300,
    currency: "EGP",
    available: true,
    online: true,
    offline: true,
    avatar: "https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=200&q=80",
    intro: "Lecturer with 10 years of teaching pre-clinical and clinical operative dentistry. I know exactly where students lose marks and how to fix it before their practical exams.",
    nextSlot: "Today, 5:00 PM",
    verified: true,
    featured: false,
  },
  {
    id: "c5",
    name: "Dr. Mona Khalil",
    title: "Orthodontist · Cairo & Riyadh",
    specialty: "Orthodontics",
    subjects: ["Orthodontic Mechanics & Force Systems", "Cephalometric Analysis", "Case Selection & Planning", "Bracket Systems", "Retainer Types"],
    category: "Clinical",
    level: "Years 4–6 & Postgraduate",
    country: "Egypt / Saudi Arabia",
    languages: ["Arabic", "English"],
    rating: 4.7,
    reviews: 143,
    sessions: 580,
    priceHour: 400,
    currency: "EGP",
    available: true,
    online: true,
    offline: false,
    avatar: "https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=200&q=80",
    intro: "I teach the orthodontic fundamentals students most often get wrong — force systems, anchorage, and case analysis. Structured, example-driven sessions.",
    nextSlot: "Today, 8:00 PM",
    verified: true,
    featured: false,
  },
  {
    id: "c6",
    name: "Dr. Youssef Badran",
    title: "Endodontist · Clinical Director",
    specialty: "Endodontics",
    subjects: ["Canal Morphology & Navigation", "Single-Visit vs Multi-Visit RCT", "Obturation Techniques", "Trauma Management", "Endo Emergency Cases"],
    category: "Clinical",
    level: "Years 4–6 & Postgraduate",
    country: "Egypt",
    languages: ["Arabic", "English"],
    rating: 4.9,
    reviews: 241,
    sessions: 1080,
    priceHour: 400,
    currency: "EGP",
    available: true,
    online: true,
    offline: true,
    avatar: "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=200&q=80",
    intro: "Clinical director offering both phantom-head sessions for pre-clinical students and clinical case review for Year 5–6 and internship. Case-based, not lecture-based.",
    nextSlot: "Today, 8:00 PM",
    verified: true,
    featured: false,
  },
  {
    id: "c7",
    name: "Dr. Heba Mostafa",
    title: "Paediatric Dentist · PhD",
    specialty: "Paediatric Dentistry",
    subjects: ["Child Behaviour Management", "Pulp Therapy in Primary Teeth", "Space Maintainers", "Fluoride Protocols", "Paediatric Dental Emergency"],
    category: "Clinical",
    level: "Years 4–6",
    country: "Egypt",
    languages: ["Arabic", "English"],
    rating: 4.7,
    reviews: 119,
    sessions: 460,
    priceHour: 280,
    currency: "EGP",
    available: true,
    online: true,
    offline: false,
    avatar: "https://images.unsplash.com/photo-1619450565660-2a93ba8603fd?w=200&q=80",
    intro: "Clinical sessions built around real case scenarios rather than theory. I help students build the confidence to work with children from their very first paediatric clinic session.",
    nextSlot: "Tomorrow, 4:00 PM",
    verified: false,
    featured: false,
  },
  {
    id: "c8",
    name: "Dr. Tarek Samir",
    title: "Oral Pathologist · Faculty of Dentistry Cairo",
    specialty: "Oral Pathology",
    subjects: ["Lesion Identification & Differential Diagnosis", "Histopathology Images", "Salivary Gland Pathology", "Cysts & Tumours", "Oral Cancer Recognition"],
    category: "Clinical",
    level: "Years 3–6",
    country: "Egypt",
    languages: ["Arabic", "English"],
    rating: 4.9,
    reviews: 203,
    sessions: 890,
    priceHour: 320,
    currency: "EGP",
    available: false,
    online: true,
    offline: true,
    avatar: "https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=200&q=80",
    intro: "Oral pathology is one of the most scoreable subjects in dental exams — once you know how to look at images systematically. My sessions focus on pattern recognition, not memorisation.",
    nextSlot: "Wed, 7:00 PM",
    verified: true,
    featured: false,
  },

  // ── Exam Prep (EGP) ───────────────────────────────────────────────────────

  {
    id: "e1",
    name: "Dr. Laila Shawki",
    title: "Prosthodontist · EDLE & International Exams",
    specialty: "Prosthodontics",
    subjects: ["Fixed Prosthodontics", "Digital Workflow", "EDLE Prosthodontics", "Occlusion Theory", "Case Presentations"],
    category: "Exam Prep",
    level: "Postgraduate & Exam Prep",
    country: "Egypt / Germany",
    languages: ["Arabic", "English", "German"],
    rating: 4.9,
    reviews: 312,
    sessions: 1540,
    priceHour: 600,
    currency: "EGP",
    available: false,
    online: true,
    offline: false,
    avatar: "https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=200&q=80",
    intro: "I bridge the gap between textbook prosthodontics and modern digital workflows, and help candidates who are preparing for the EDLE and international examinations.",
    nextSlot: "Jun 24, 5:00 PM",
    verified: true,
    featured: false,
  },
  {
    id: "e2",
    name: "Dr. Fatma Kamel",
    title: "EDLE Comprehensive Prep Specialist",
    specialty: "Exam Preparation",
    subjects: ["EDLE Full Curriculum Review", "MCQ Strategy & Time Management", "Weak Subject Diagnosis", "Past Paper Analysis", "Mock Exam Sessions"],
    category: "Exam Prep",
    level: "Exam Prep",
    country: "Egypt",
    languages: ["Arabic", "English"],
    rating: 4.8,
    reviews: 176,
    sessions: 720,
    priceHour: 350,
    currency: "EGP",
    available: true,
    online: true,
    offline: false,
    avatar: "https://images.unsplash.com/photo-1619450565660-2a93ba8603fd?w=200&q=80",
    intro: "EDLE preparation requires a different approach than studying for university exams. I diagnose your weak areas first, then build a structured 6–10 week plan around them.",
    nextSlot: "Today, 4:00 PM",
    verified: true,
    featured: false,
  },

  // ── International / USD ───────────────────────────────────────────────────

  {
    id: "i1",
    name: "Dr. Omar Farid",
    title: "Implant Specialist · MSc King's College London",
    specialty: "Implantology",
    subjects: ["Implant Planning & Protocols", "Bone Grafting", "Digital Implantology", "ORE Implant Module", "Masters Application Coaching"],
    category: "Clinical",
    level: "Postgraduate",
    country: "UK",
    languages: ["Arabic", "English"],
    rating: 4.8,
    reviews: 178,
    sessions: 720,
    priceHour: 70,
    currency: "USD",
    available: true,
    online: true,
    offline: false,
    avatar: "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=200&q=80",
    intro: "MSc Implantology from King's College London, GDC registered. Specialising in clinical implantology training and Masters application coaching for Egyptian dentists.",
    nextSlot: "Today, 9:00 PM",
    verified: true,
    featured: false,
  },
  {
    id: "i2",
    name: "Dr. Khaled Mansour",
    title: "Prosthodontist · Fixed & Implant",
    specialty: "Prosthodontics",
    subjects: ["Complete Dentures", "RPD Design & Framework", "Occlusal Records", "Post-Core Restorations", "Implant-Supported Prosthetics"],
    category: "Clinical",
    level: "Postgraduate",
    country: "Egypt / UAE",
    languages: ["Arabic", "English"],
    rating: 4.8,
    reviews: 156,
    sessions: 640,
    priceHour: 45,
    currency: "USD",
    available: true,
    online: true,
    offline: true,
    avatar: "https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=200&q=80",
    intro: "Postgraduate prosthodontics teaching at a level that prepares you for real clinical complexity. Sessions focus on the clinical decisions faculty rarely teach directly.",
    nextSlot: "Tomorrow, 6:00 PM",
    verified: true,
    featured: false,
  },
  {
    id: "i3",
    name: "Dr. Sara El-Deeb",
    title: "Operative Dentistry · Clinical Demonstrator",
    specialty: "Operative Dentistry",
    subjects: ["Direct Composite Restorations", "Class II Box Preparations", "Posterior Composite Technique", "Pulp Protection Protocols", "Clinical Assessment Prep"],
    category: "Clinical",
    level: "Years 4–6",
    country: "Egypt",
    languages: ["Arabic"],
    rating: 4.7,
    reviews: 134,
    sessions: 510,
    priceHour: 250,
    currency: "EGP",
    available: false,
    online: true,
    offline: true,
    avatar: "https://images.unsplash.com/photo-1657470179447-0f5aa16daa91?w=200&q=80",
    intro: "Clinical demonstrator — I work alongside students in the clinic daily. I know exactly what faculty mark and the technical habits that separate distinction from a bare pass.",
    nextSlot: "Thu, 5:00 PM",
    verified: false,
    featured: false,
  },
];

// ─── Filter options ───────────────────────────────────────────────────────────

const CATEGORIES = ["All", "Pre-Clinical", "Clinical", "Exam Prep"];

const SPECIALTIES = [
  "All Specialties",
  // Pre-clinical
  "Oral Biology & Histology", "Dental Anatomy", "Oral Physiology", "Oral Microbiology", "Head & Neck Anatomy", "Dental Materials",
  // Clinical
  "Endodontics", "Oral Surgery", "Prosthodontics", "Orthodontics", "Periodontics", "Operative Dentistry",
  "Paediatric Dentistry", "Oral Pathology", "Oral Medicine & Diagnosis", "Oral Radiology", "Community Dentistry",
  "Implantology",
  // Exam
  "Exam Preparation",
];

const UNIVERSITIES = ["All", ...EG_DENTAL_UNIVERSITIES, "Independent"];
const LEVELS = ["All Levels", "Years 1–2", "Years 1–3", "Years 2–4", "Years 3–5", "Years 3–6", "Years 4–6", "Years 4–6 & Postgraduate", "Postgraduate", "Exam Prep"];
const FORMATS = ["Any Format", "Online", "In-Person", "Both"];
const PRICE_EGP = ["Any Price", "Under EGP 400", "EGP 400–600", "EGP 600+"];
const PRICE_USD = ["Any Price", "Under $50", "$50–100", "$100+"];

// ─── Helpers ──────────────────────────────────────────────────────────────────

function displayPrice(t: Tutor) {
  return t.currency === "EGP" ? `EGP ${t.priceHour}` : `$${t.priceHour}`;
}

// ─── University badge ─────────────────────────────────────────────────────────

function UniBadge({ name }: { name: string }) {
  const shortMap: Record<string, string> = {
    "Cairo University": "Cairo Uni",
    "British University in Egypt (BUE)": "BUE",
    "Ain Shams University": "Ain Shams",
    "Misr International University (MIU)": "MIU",
    "Alexandria University": "Alexandria Uni",
    "Mansoura University": "Mansoura Uni",
    "MSA University": "MSA",
    "October University (MUST)": "MUST",
  };
  return (
    <span style={{ display: "inline-flex", alignItems: "center", gap: 4, fontFamily: "Inter", fontWeight: 700, fontSize: 10, color: "#1A4FBE", background: "rgba(26,79,190,0.08)", border: "1px solid rgba(26,79,190,0.2)", borderRadius: 6, padding: "2px 8px", letterSpacing: "0.03em" }}>
      <BookOpen size={9} /> {shortMap[name] ?? name}
    </span>
  );
}

// ─── Tutor card ───────────────────────────────────────────────────────────────

function TutorCard({ tutor }: { tutor: Tutor }) {
  const nav = useNavigate();

  return (
    <div
      onClick={() => nav(`/tutoring/${tutor.id}`)}
      style={{ background: brand.white, borderRadius: 22, border: `1px solid ${brand.borderGray}`, overflow: "hidden", boxShadow: "0 2px 12px rgba(27,27,27,0.05)", cursor: "pointer", transition: "transform 0.2s, box-shadow 0.2s" }}
      onMouseEnter={e => { const el = e.currentTarget as HTMLElement; el.style.transform = "translateY(-4px)"; el.style.boxShadow = "0 12px 32px rgba(27,27,27,0.1)"; }}
      onMouseLeave={e => { const el = e.currentTarget as HTMLElement; el.style.transform = "none"; el.style.boxShadow = "0 2px 12px rgba(27,27,27,0.05)"; }}
    >
      <div style={{ height: 5, background: gradientFlow }} />

      <div style={{ padding: "22px 22px 18px" }}>
        {/* Header */}
        <div style={{ display: "flex", gap: 14, alignItems: "flex-start", marginBottom: 12 }}>
          <div style={{ position: "relative", flexShrink: 0 }}>
            <img src={tutor.avatar} alt={tutor.name} style={{ width: 64, height: 64, borderRadius: 14, objectFit: "cover" }} />
            <div style={{ position: "absolute", bottom: 4, right: 4, width: 12, height: 12, borderRadius: "50%", background: tutor.available ? "#2D9B68" : brand.warmGray, border: "2px solid #fff" }} />
          </div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ display: "flex", gap: 6, alignItems: "center", marginBottom: 2 }}>
              <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal }}>{tutor.name}</span>
              {tutor.verified && (
                <div style={{ width: 15, height: 15, borderRadius: "50%", background: gradientFlow, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                  <CheckCircle size={8} color="#fff" />
                </div>
              )}
            </div>
            <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginBottom: 7 }}>{tutor.title}</div>
            <div style={{ display: "flex", gap: 5, flexWrap: "wrap", alignItems: "center" }}>
              <GradientBadge small>{tutor.specialty}</GradientBadge>
              {tutor.university && <UniBadge name={tutor.university} />}
            </div>
          </div>
        </div>

        {/* Level tag + location */}
        <div style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 10 }}>
          <span style={{ fontFamily: "Inter", fontSize: 10, fontWeight: 600, color: brand.charcoal, background: brand.offWhite, border: `1px solid ${brand.borderGray}`, borderRadius: 5, padding: "2px 8px" }}>{tutor.level}</span>
          <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, display: "flex", alignItems: "center", gap: 3 }}>
            <MapPin size={10} /> {tutor.country}
          </span>
        </div>

        {/* Intro */}
        <p style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, lineHeight: 1.6, marginBottom: 12, display: "-webkit-box", WebkitLineClamp: 2, WebkitBoxOrient: "vertical" as const, overflow: "hidden" }}>
          {tutor.intro}
        </p>

        {/* Subjects */}
        <div style={{ display: "flex", gap: 5, flexWrap: "wrap", marginBottom: 14 }}>
          {tutor.subjects.slice(0, 3).map(s => (
            <span key={s} style={{ fontFamily: "Inter", fontSize: 10, color: brand.charcoal, background: brand.offWhite, border: `1px solid ${brand.borderGray}`, borderRadius: 5, padding: "2px 7px" }}>{s}</span>
          ))}
          {tutor.subjects.length > 3 && <span style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray, padding: "2px 4px" }}>+{tutor.subjects.length - 3}</span>}
        </div>

        {/* Stats */}
        <div style={{ display: "flex", gap: 14, marginBottom: 12, flexWrap: "wrap" }}>
          <div style={{ display: "flex", alignItems: "center", gap: 3 }}>
            <Star size={12} fill={brand.amber} color={brand.amber} />
            <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.charcoal }}>{tutor.rating}</span>
            <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>({tutor.reviews})</span>
          </div>
          <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, display: "flex", alignItems: "center", gap: 3 }}>
            <Clock size={11} /> {tutor.sessions.toLocaleString()} sessions
          </span>
          <div style={{ display: "flex", gap: 5 }}>
            {tutor.online && <span style={{ fontFamily: "Inter", fontSize: 10, fontWeight: 600, color: brand.orange, background: "rgba(255,107,26,0.08)", borderRadius: 5, padding: "2px 7px", display: "flex", alignItems: "center", gap: 3 }}><Video size={9} /> Online</span>}
            {tutor.offline && <span style={{ fontFamily: "Inter", fontSize: 10, fontWeight: 600, color: brand.charcoal, background: brand.paleGray, borderRadius: 5, padding: "2px 7px", display: "flex", alignItems: "center", gap: 3 }}><MapPin size={9} /> In-Person</span>}
          </div>
        </div>

        {/* Languages */}
        <div style={{ display: "flex", gap: 4, alignItems: "center", marginBottom: 16 }}>
          <Globe size={11} color={brand.warmGray} />
          <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{tutor.languages.join(" · ")}</span>
        </div>

        <div style={{ height: 1, background: brand.borderGray, marginBottom: 14 }} />

        {/* Pricing + CTA */}
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
          <div>
            <span style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal }}>{displayPrice(tutor)}</span>
            <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}> / hour</span>
            <div style={{ fontFamily: "Inter", fontSize: 10, color: tutor.available ? "#2D9B68" : brand.warmGray, marginTop: 2 }}>
              {tutor.available ? "⚡ Available now" : `Next: ${tutor.nextSlot}`}
            </div>
          </div>
          <div style={{ display: "flex", gap: 7 }}>
            <button onClick={e => { e.stopPropagation(); nav(`/tutoring/${tutor.id}`); }} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 12, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 9, padding: "8px 12px", cursor: "pointer" }}>
              <MessageSquare size={12} />
            </button>
            <button onClick={e => { e.stopPropagation(); nav(`/tutoring/${tutor.id}/book`); }} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: "#fff", background: gradientFlow, border: "none", borderRadius: 9, padding: "8px 16px", cursor: "pointer", display: "flex", alignItems: "center", gap: 5, boxShadow: "0 3px 10px rgba(255,107,26,0.28)" }}>
              Book <ArrowRight size={11} />
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

// ─── Featured card ────────────────────────────────────────────────────────────

function FeaturedCard({ tutor }: { tutor: Tutor }) {
  const nav = useNavigate();
  return (
    <div onClick={() => nav(`/tutoring/${tutor.id}`)} style={{ background: brand.white, borderRadius: 20, border: `1.5px solid ${brand.borderGray}`, padding: "22px", cursor: "pointer", transition: "all 0.2s", boxShadow: "0 4px 18px rgba(27,27,27,0.06)", display: "flex", gap: 18, alignItems: "flex-start" }}
      onMouseEnter={e => { const el = e.currentTarget as HTMLElement; el.style.transform = "translateY(-3px)"; el.style.boxShadow = "0 12px 30px rgba(27,27,27,0.1)"; }}
      onMouseLeave={e => { const el = e.currentTarget as HTMLElement; el.style.transform = "none"; el.style.boxShadow = "0 4px 18px rgba(27,27,27,0.06)"; }}>
      <div style={{ position: "relative", flexShrink: 0 }}>
        <img src={tutor.avatar} alt={tutor.name} style={{ width: 72, height: 72, borderRadius: 16, objectFit: "cover" }} />
        <div style={{ position: "absolute", bottom: 4, right: 4, width: 13, height: 13, borderRadius: "50%", background: tutor.available ? "#2D9B68" : brand.warmGray, border: "2px solid #fff" }} />
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 4 }}>
          <div style={{ display: "flex", gap: 6, alignItems: "center" }}>
            <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: brand.charcoal }}>{tutor.name}</span>
            {tutor.verified && <div style={{ width: 16, height: 16, borderRadius: "50%", background: gradientFlow, display: "flex", alignItems: "center", justifyContent: "center" }}><CheckCircle size={9} color="#fff" /></div>}
          </div>
          <span style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.charcoal, flexShrink: 0, marginLeft: 12 }}>{displayPrice(tutor)}<span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, fontWeight: 400 }}>/hr</span></span>
        </div>
        <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginBottom: 8 }}>{tutor.title}</div>
        <div style={{ display: "flex", gap: 6, alignItems: "center", marginBottom: 10, flexWrap: "wrap" }}>
          <GradientBadge small>{tutor.specialty}</GradientBadge>
          {tutor.university && <UniBadge name={tutor.university} />}
          <span style={{ fontFamily: "Inter", fontSize: 10, fontWeight: 600, color: brand.charcoal, background: brand.offWhite, border: `1px solid ${brand.borderGray}`, borderRadius: 5, padding: "2px 7px" }}>{tutor.level}</span>
        </div>
        <p style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, lineHeight: 1.6, margin: "0 0 12px", display: "-webkit-box", WebkitLineClamp: 2, WebkitBoxOrient: "vertical" as const, overflow: "hidden" }}>{tutor.intro}</p>
        <div style={{ display: "flex", gap: 14, alignItems: "center", flexWrap: "wrap" }}>
          <div style={{ display: "flex", gap: 3, alignItems: "center" }}>
            <Star size={12} fill={brand.amber} color={brand.amber} />
            <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.charcoal }}>{tutor.rating}</span>
            <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>({tutor.reviews} reviews)</span>
          </div>
          <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{tutor.sessions.toLocaleString()} sessions</span>
          <button onClick={e => { e.stopPropagation(); nav(`/tutoring/${tutor.id}/book`); }} style={{ marginLeft: "auto", fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: "#fff", background: gradientFlow, border: "none", borderRadius: 9, padding: "8px 18px", cursor: "pointer", display: "flex", alignItems: "center", gap: 5, boxShadow: "0 2px 10px rgba(255,107,26,0.28)", flexShrink: 0 }}>
            Book <ArrowRight size={12} />
          </button>
        </div>
      </div>
    </div>
  );
}

// ─── Page ─────────────────────────────────────────────────────────────────────

export default function Tutoring() {
  const nav = useNavigate();
  const [search, setSearch] = useState("");
  const [category, setCategory] = useState("All");
  const [specialty, setSpecialty] = useState("All Specialties");
  const [uniFilter, setUniFilter] = useState("All");
  const [level, setLevel] = useState("All Levels");
  const [format, setFormat] = useState("Any Format");
  const [priceFilter, setPriceFilter] = useState("Any Price");
  const [currencyView, setCurrencyView] = useState<"both" | "EGP" | "USD">("both");
  const [availableNow, setAvailableNow] = useState(false);
  const [uniOnly, setUniOnly] = useState(false);
  const [showFilters, setShowFilters] = useState(false);

  const filtered = tutors.filter(t => {
    const q = search.toLowerCase();
    const matchSearch = !q || t.name.toLowerCase().includes(q) || t.specialty.toLowerCase().includes(q) || t.subjects.some(s => s.toLowerCase().includes(q)) || (t.university ?? "").toLowerCase().includes(q);
    const matchCat = category === "All" || t.category === category;
    const matchSpec = specialty === "All Specialties" || t.specialty === specialty;
    const matchUni = uniFilter === "All" || (uniFilter === "Independent" ? !t.university : t.university === uniFilter);
    const matchLevel = level === "All Levels" || t.level === level || t.level.includes(level);
    const matchFormat = format === "Any Format" || (format === "Online" && t.online) || (format === "In-Person" && t.offline) || (format === "Both" && t.online && t.offline);
    const matchCurrency = currencyView === "both" || t.currency === currencyView;
    const matchPrice = priceFilter === "Any Price" || (() => {
      if (t.currency === "EGP") {
        return (priceFilter === "Under EGP 400" && t.priceHour < 400) || (priceFilter === "EGP 400–600" && t.priceHour >= 400 && t.priceHour <= 600) || (priceFilter === "EGP 600+" && t.priceHour > 600);
      } else {
        return (priceFilter === "Under $50" && t.priceHour < 50) || (priceFilter === "$50–100" && t.priceHour >= 50 && t.priceHour <= 100) || (priceFilter === "$100+" && t.priceHour > 100);
      }
    })();
    const matchAvail = !availableNow || t.available;
    const matchUniOnly = !uniOnly || !!t.university;
    return matchSearch && matchCat && matchSpec && matchUni && matchLevel && matchFormat && matchCurrency && matchPrice && matchAvail && matchUniOnly;
  });

  const featuredTutors = tutors.filter(t => t.featured);
  const showFeatured = !search && category === "All" && specialty === "All Specialties";

  const activeCount = [
    specialty !== "All Specialties", uniFilter !== "All", level !== "All Levels",
    format !== "Any Format", priceFilter !== "Any Price", currencyView !== "both", availableNow, uniOnly,
  ].filter(Boolean).length;

  const priceOptions = currencyView === "USD" ? PRICE_USD : PRICE_EGP;

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>

      {/* ── Hero ─────────────────────────────────────────────────────── */}
      <div style={{ background: `linear-gradient(135deg, ${brand.charcoal} 0%, #201C19 100%)`, padding: "56px 24px 48px", position: "relative", overflow: "hidden" }}>
        <div style={{ position: "absolute", inset: 0, background: "radial-gradient(ellipse at 72% 40%, rgba(255,107,26,0.09) 0%, transparent 58%)", pointerEvents: "none" }} />
        <div style={{ maxWidth: 1280, margin: "0 auto", position: "relative" }}>
          <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, letterSpacing: "0.12em", color: brand.amber, textTransform: "uppercase" as const, marginBottom: 10 }}>Professional Tutoring</div>
          <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(28px,4vw,46px)", color: "#fff", marginBottom: 14, lineHeight: 1.18 }}>Dental Tutoring</h1>
          <p style={{ fontFamily: "Inter", fontSize: 16, color: "rgba(255,255,255,0.6)", maxWidth: 560, marginBottom: 32, lineHeight: 1.65 }}>
            1-on-1 sessions with verified dental specialists and university faculty — for clinical skills, pre-clinical sciences, exam preparation, and professional development.
          </p>

          {/* Search */}
          <div style={{ display: "flex", gap: 10, flexWrap: "wrap", maxWidth: 700, marginBottom: 36 }}>
            <div style={{ flex: 1, minWidth: 240, position: "relative" }}>
              <Search size={16} style={{ position: "absolute", left: 15, top: "50%", transform: "translateY(-50%)", color: "rgba(255,255,255,0.4)" }} />
              <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search by name, subject, or university…" style={{ width: "100%", fontFamily: "Inter", fontSize: 14, background: "rgba(255,255,255,0.1)", border: "1px solid rgba(255,255,255,0.14)", borderRadius: 13, padding: "13px 16px 13px 44px", color: "#fff", outline: "none", boxSizing: "border-box" as const }} />
            </div>
            <button onClick={() => setAvailableNow(s => !s)} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: availableNow ? "#fff" : "rgba(255,255,255,0.7)", background: availableNow ? "#2D9B68" : "rgba(255,255,255,0.1)", border: `1.5px solid ${availableNow ? "#2D9B68" : "rgba(255,255,255,0.15)"}`, borderRadius: 13, padding: "13px 18px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6, transition: "all 0.15s" }}>
              <Zap size={14} fill={availableNow ? "#fff" : "none"} /> Available Now
            </button>
          </div>

          {/* Category tabs */}
          <div style={{ display: "flex", gap: 6, overflowX: "auto", scrollbarWidth: "none" }}>
            {CATEGORIES.map(cat => (
              <button key={cat} onClick={() => setCategory(cat)} style={{ fontFamily: "Inter", fontWeight: category === cat ? 700 : 500, fontSize: 13, color: category === cat ? brand.charcoal : "rgba(255,255,255,0.65)", background: category === cat ? "#fff" : "rgba(255,255,255,0.08)", border: category === cat ? "none" : "1px solid rgba(255,255,255,0.12)", borderRadius: "11px 11px 0 0", padding: "10px 20px 14px", cursor: "pointer", whiteSpace: "nowrap" as const, transition: "all 0.15s" }}>
                {cat === "All" ? "All Subjects" : cat}
                <span style={{ marginLeft: 6, fontFamily: "Inter", fontSize: 11, fontWeight: 400, opacity: 0.6 }}>({tutors.filter(t => cat === "All" || t.category === cat).length})</span>
              </button>
            ))}
          </div>

          {/* Stats */}
          <div style={{ display: "flex", gap: 32, paddingTop: 24, flexWrap: "wrap" }}>
            {[["150+", "Verified Tutors"], ["14,000+", "Sessions Delivered"], ["4.8★", "Average Rating"], ["12", "Subjects Covered"]].map(([v, l]) => (
              <div key={l}><div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.gold }}>{v}</div><div style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.45)", marginTop: 2 }}>{l}</div></div>
            ))}
          </div>
        </div>
      </div>

      <div style={{ maxWidth: 1280, margin: "0 auto", padding: "28px 24px" }}>

        {/* ── Filter panel ─────────────────────────────────────────────── */}
        <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "14px 18px", marginBottom: 28 }}>
          <div style={{ display: "flex", gap: 10, flexWrap: "wrap", alignItems: "center" }}>
            {/* Currency toggle */}
            <div style={{ display: "flex", background: brand.offWhite, borderRadius: 10, border: `1.5px solid ${brand.borderGray}`, overflow: "hidden" }}>
              {(["both", "EGP", "USD"] as const).map(c => (
                <button key={c} onClick={() => { setCurrencyView(c); setPriceFilter("Any Price"); }} style={{ fontFamily: "Inter", fontWeight: currencyView === c ? 700 : 400, fontSize: 12, color: currencyView === c ? "#fff" : brand.charcoal, background: currencyView === c ? gradientFlow : "transparent", border: "none", padding: "8px 14px", cursor: "pointer", transition: "all 0.15s" }}>
                  {c === "both" ? "All" : c}
                </button>
              ))}
            </div>

            {/* University staff toggle */}
            <button onClick={() => setUniOnly(s => !s)} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: uniOnly ? "#1A4FBE" : brand.charcoal, background: uniOnly ? "rgba(26,79,190,0.08)" : brand.offWhite, border: `1.5px solid ${uniOnly ? "#1A4FBE" : brand.borderGray}`, borderRadius: 10, padding: "8px 14px", cursor: "pointer", display: "flex", alignItems: "center", gap: 5, transition: "all 0.15s" }}>
              <BookOpen size={13} /> University Staff Only
            </button>

            <button onClick={() => setShowFilters(s => !s)} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: showFilters ? brand.orange : brand.charcoal, background: showFilters ? `${brand.orange}10` : brand.offWhite, border: `1.5px solid ${showFilters ? brand.orange : brand.borderGray}`, borderRadius: 10, padding: "8px 14px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}>
              <Filter size={13} /> Filters
              {activeCount > 0 && <span style={{ background: gradientFlow, color: "#fff", borderRadius: "50%", width: 17, height: 17, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 10, fontWeight: 700 }}>{activeCount}</span>}
            </button>

            <span style={{ marginLeft: "auto", fontFamily: "Inter", fontSize: 13, color: brand.warmGray }}>{filtered.length} tutor{filtered.length !== 1 ? "s" : ""}</span>
          </div>

          {showFilters && (
            <div style={{ display: "flex", gap: 14, flexWrap: "wrap", marginTop: 14, paddingTop: 14, borderTop: `1px solid ${brand.borderGray}` }}>
              {[
                { label: "Specialty / Subject", value: specialty, options: SPECIALTIES, set: setSpecialty },
                { label: "University", value: uniFilter, options: UNIVERSITIES, set: setUniFilter },
                { label: "Level", value: level, options: LEVELS, set: setLevel },
                { label: "Format", value: format, options: FORMATS, set: setFormat },
                { label: "Price Range", value: priceFilter, options: priceOptions, set: setPriceFilter },
              ].map(f => (
                <div key={f.label} style={{ position: "relative" }}>
                  <label style={{ fontFamily: "Inter", fontSize: 10, color: brand.warmGray, display: "block", marginBottom: 4 }}>{f.label}</label>
                  <select value={f.value} onChange={e => f.set(e.target.value)} style={{ fontFamily: "Inter", fontSize: 12, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${f.value !== f.options[0] ? brand.orange : brand.borderGray}`, borderRadius: 9, padding: "7px 28px 7px 10px", cursor: "pointer", outline: "none", appearance: "none" as const }}>
                    {f.options.map(o => <option key={o}>{o}</option>)}
                  </select>
                  <ChevronDown size={11} style={{ position: "absolute", right: 8, bottom: 9, color: brand.warmGray, pointerEvents: "none" }} />
                </div>
              ))}
              {activeCount > 0 && (
                <div style={{ display: "flex", alignItems: "flex-end" }}>
                  <button onClick={() => { setSpecialty("All Specialties"); setUniFilter("All"); setLevel("All Levels"); setFormat("Any Format"); setPriceFilter("Any Price"); setCurrencyView("both"); setAvailableNow(false); setUniOnly(false); }} style={{ fontFamily: "Inter", fontSize: 12, color: brand.red, background: "none", border: "none", cursor: "pointer", padding: "7px 4px" }}>Clear all</button>
                </div>
              )}
            </div>
          )}
        </div>

        {/* ── How it works ─────────────────────────────────────────────── */}
        <div style={{ background: `linear-gradient(135deg, rgba(255,107,26,0.05), rgba(255,198,46,0.05))`, border: `1px solid ${brand.borderGray}`, borderRadius: 18, padding: "20px 0", marginBottom: 32, display: "flex" }}>
          {[
            { n: "1", label: "Choose a tutor", desc: "Browse by subject, level, or university" },
            { n: "2", label: "Pick a time", desc: "See their calendar and book instantly" },
            { n: "3", label: "Define your goal", desc: "Share what you need before the session" },
            { n: "4", label: "Attend & learn", desc: "Online or in-person — you choose" },
          ].map((step, i) => (
            <div key={step.n} style={{ flex: 1, display: "flex", gap: 12, alignItems: "flex-start", padding: "0 22px", borderRight: i < 3 ? `1px solid ${brand.borderGray}` : "none" }}>
              <div style={{ width: 32, height: 32, borderRadius: "50%", background: gradientFlow, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff" }}>{step.n}</span>
              </div>
              <div>
                <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal }}>{step.label}</div>
                <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginTop: 2 }}>{step.desc}</div>
              </div>
            </div>
          ))}
        </div>

        {/* ── Featured ────────────────────────────────────────────────── */}
        {showFeatured && (
          <div style={{ marginBottom: 36 }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline", marginBottom: 16 }}>
              <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.charcoal }}>Featured Tutors</h2>
              <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray }}>Top-rated · Verified</span>
            </div>
            <div style={{ display: "flex", flexDirection: "column" as const, gap: 14 }}>
              {featuredTutors.map(t => <FeaturedCard key={t.id} tutor={t} />)}
            </div>
          </div>
        )}

        {/* ── University Staff banner ─────────────────────────────────── */}
        {showFeatured && !uniOnly && (
          <div style={{ background: "rgba(26,79,190,0.04)", border: "1px solid rgba(26,79,190,0.14)", borderRadius: 16, padding: "18px 22px", marginBottom: 28, display: "flex", gap: 16, alignItems: "center", flexWrap: "wrap" }}>
            <div style={{ width: 40, height: 40, borderRadius: 10, background: "rgba(26,79,190,0.1)", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
              <BookOpen size={18} color="#1A4FBE" />
            </div>
            <div style={{ flex: 1, minWidth: 200 }}>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal }}>University Faculty on Ejadah</div>
              <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginTop: 2 }}>Tutors from Cairo University, BUE, Ain Shams, MIU, Alexandria, Mansoura & more — teaching the exact curriculum you're studying.</div>
            </div>
            <button onClick={() => { setUniOnly(true); setShowFilters(false); }} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: "#1A4FBE", background: "rgba(26,79,190,0.08)", border: "1.5px solid rgba(26,79,190,0.2)", borderRadius: 9, padding: "9px 16px", cursor: "pointer", flexShrink: 0 }}>
              Browse Faculty Tutors
            </button>
          </div>
        )}

        {/* ── Grid ────────────────────────────────────────────────────── */}
        {showFeatured && <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 16 }}>All Tutors</h2>}

        {filtered.length > 0 ? (
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(330px, 1fr))", gap: 18 }}>
            {filtered.map(t => <TutorCard key={t.id} tutor={t} />)}
          </div>
        ) : (
          <div style={{ textAlign: "center" as const, padding: "80px 0" }}>
            <div style={{ fontSize: 48, marginBottom: 16 }}>🔍</div>
            <div style={{ fontFamily: "Playfair Display, serif", fontSize: 22, color: brand.charcoal, marginBottom: 8 }}>No tutors match your filters</div>
            <div style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, marginBottom: 20 }}>Try adjusting the subject, university, or level.</div>
            <button onClick={() => { setCategory("All"); setSpecialty("All Specialties"); setUniFilter("All"); setLevel("All Levels"); setFormat("Any Format"); setPriceFilter("Any Price"); setCurrencyView("both"); setAvailableNow(false); setUniOnly(false); }} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "12px 24px", cursor: "pointer" }}>Clear Filters</button>
          </div>
        )}

        {/* ── Group sessions ───────────────────────────────────────────── */}
        <div style={{ marginTop: 48, background: brand.white, border: `1px solid ${brand.borderGray}`, borderRadius: 20, padding: "24px 28px", display: "flex", gap: 20, alignItems: "center", flexWrap: "wrap" }}>
          <div style={{ width: 44, height: 44, borderRadius: 12, background: "rgba(255,107,26,0.08)", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
            <Users size={20} color={brand.orange} />
          </div>
          <div style={{ flex: 1, minWidth: 200 }}>
            <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal, marginBottom: 4 }}>Study in a group — 40% less per person</div>
            <p style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, margin: 0, lineHeight: 1.55 }}>Several tutors offer group sessions for 3–6 students on the same topic. Share costs, ask more questions, and learn with peers at your level.</p>
          </div>
          <button onClick={() => window.scrollTo({ top: 0, behavior: "smooth" })} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.orange, background: "rgba(255,107,26,0.08)", border: `1.5px solid rgba(255,107,26,0.2)`, borderRadius: 10, padding: "10px 16px", cursor: "pointer", flexShrink: 0 }}>Browse All Tutors</button>
        </div>

        {/* ── Become a tutor ───────────────────────────────────────────── */}
        <div style={{ marginTop: 18, background: brand.charcoal, borderRadius: 22, padding: "36px 32px", display: "flex", gap: 28, alignItems: "center", flexWrap: "wrap" }}>
          <div style={{ flex: 1, minWidth: 260 }}>
            <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, letterSpacing: "0.1em", color: brand.amber, textTransform: "uppercase" as const, marginBottom: 10 }}>For Tutors</div>
            <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 26, color: "#fff", marginBottom: 10 }}>Share Your Expertise. Earn on Your Schedule.</h2>
            <p style={{ fontFamily: "Inter", fontSize: 14, color: "rgba(255,255,255,0.55)", lineHeight: 1.65, maxWidth: 480, margin: 0 }}>Join 150+ dental professionals and university faculty teaching on Ejadah. Set your own hours, subjects, and pricing.</p>
          </div>
          <button onClick={() => nav("/tutoring/become-a-tutor")} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "14px 28px", cursor: "pointer", display: "flex", alignItems: "center", gap: 8, flexShrink: 0, boxShadow: "0 4px 18px rgba(255,107,26,0.4)" }}>
            Become a Tutor <ArrowRight size={15} />
          </button>
        </div>
      </div>
    </div>
  );
}
