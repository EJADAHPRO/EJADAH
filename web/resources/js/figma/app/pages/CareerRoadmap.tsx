import { useState, useEffect } from "react";
import { useNavigate } from "react-router";
import { ArrowRight, ArrowLeft, ChevronRight, BookOpen, MapPin, Zap, CheckCircle, Clock, DollarSign, Shield, Users, Star, Target } from "lucide-react";
import { brand, gradientFlow } from "@/figma/app/shared";

// ─── Types ────────────────────────────────────────────────────────────────────

interface Profile {
  stage: string;
  specialty: string;
  goal: string;
  country: string;
  timeline: string;
  budget: string;
  englishLevel: string;
  languages: string[];
  hasMasters: boolean;
  hasArabBoard: boolean;
}

interface Phase {
  phase: string;
  title: string;
  icon: string;
  color: string;
  duration: string;
  tasks: string[];
  tip?: string;
  cta?: string;
  ctaLabel?: string;
}

interface MastersRec {
  id: string;
  name: string;
  country: string;
  flag: string;
  specialty: string;
  why: string;
}

interface GeneratedRoadmap {
  headline: string;
  subtitle: string;
  totalMonths: string;
  estimatedCost: string;
  resolvedCountry: string;
  countrySlug: string;
  phases: Phase[];
  mastersRecs: MastersRec[];
  challenges: string[];
  altPath: string;
}

// ─── Generation Engine ────────────────────────────────────────────────────────

function resolveCountry(p: Profile): { name: string; slug: string } {
  if (p.country !== "Suggest best for me") {
    const slugMap: Record<string, string> = {
      "United Kingdom": "uk", "United Arab Emirates": "uae", "Saudi Arabia": "ksa",
      "Australia": "australia", "Canada": "canada", "Germany": "germany",
      "Ireland": "ireland", "Qatar": "qatar", "Kuwait": "kuwait",
      "Oman": "oman", "Bahrain": "bahrain", "Jordan": "jordan",
      "New Zealand": "new-zealand", "France": "france", "United States": "usa",
      "Malaysia": "malaysia", "Singapore": "singapore", "South Africa": "south-africa",
    };
    return { name: p.country, slug: slugMap[p.country] ?? p.country.toLowerCase().split(" ")[0] };
  }
  // Smart suggestion logic
  if (p.timeline === "ASAP — within 12 months" || p.budget === "Limited (< €10k)")
    return { name: "United Arab Emirates", slug: "uae" };
  if (p.languages.includes("German"))
    return { name: "Germany", slug: "germany" };
  if (p.budget === "Premium (€30k+)" && p.englishLevel.includes("7.0"))
    return { name: "Australia", slug: "australia" };
  if (p.goal === "Postgraduate Masters" && p.englishLevel.includes("7.0"))
    return { name: "United Kingdom", slug: "uk" };
  return { name: "United Arab Emirates", slug: "uae" };
}

const GULF = ["United Arab Emirates", "Saudi Arabia", "Qatar", "Kuwait", "Oman", "Bahrain"];
const isGulf = (c: string) => GULF.includes(c);

function generateRoadmap(p: Profile): GeneratedRoadmap {
  const { name: rc, slug: cs } = resolveCountry(p);
  const phases: Phase[] = [];

  // ── Stage-specific opening phase ────────────────────────────────────────────
  if (p.stage === "Student") {
    phases.push({ phase: "Right Now — While Studying", title: "Build Your International Profile During Your Degree", icon: "🎓", color: brand.amber, duration: "Ongoing during studies",
      tasks: [
        "Choose clinical electives in your target specialty — document every case with photos and consent forms",
        "Aim for 200+ clinical cases across general and specialty areas before graduation",
        `Start IELTS preparation now — target 7.0+ by your final year${isGulf(rc) ? " (UAE/Gulf doesn't require IELTS for most positions)" : ""}`,
        "Begin Egyptian Dental Syndicate membership process from Year 4 — required for all international pathways",
        `Research ${rc} licensing requirements now — it shapes which electives and case types to prioritise`,
        p.goal.includes("Masters") ? `Identify your target Masters programs and note their deadlines — most open applications 12 months in advance` : "Shadow or connect with Egyptian dentists currently working in your target country",
      ],
      tip: "Students who plan their international pathway from Year 3 are typically licensed abroad 12–18 months earlier than peers who start after graduation." });
  } else if (p.stage === "Intern") {
    phases.push({ phase: "During Your Internship Year", title: "Make Your Internship Count for Your International Plan", icon: "🏥", color: brand.amber, duration: "12 months",
      tasks: [
        "Start IELTS preparation immediately — complete and pass it before internship ends",
        "Document every clinical case category carefully — many countries require minimum case numbers per type",
        "Begin the Egyptian Dental Syndicate membership process and obtain your membership card",
        `Research ${rc} specific requirements: eligibility criteria, exam format, fees, and timelines`,
        p.goal.includes("Masters") ? "Identify target Masters programs — note their deadlines, requirements, and application windows" : "Connect with Egyptian dentist communities in your target country via LinkedIn or Facebook groups",
        "Use slower internship periods to start exam prep materials (ORE/Prometric/ADC as applicable)",
      ],
      tip: "Your internship is the ideal preparation window — you have clinical access and a lighter academic load than during your degree." });
  } else if (p.stage === "General Dentist (1–2 yr exp)") {
    phases.push({ phase: "Starting Point", title: "Organise Your Credentials & Set Direction", icon: "📋", color: brand.amber, duration: "2–4 weeks",
      tasks: [
        "Obtain a current Good Standing Letter from the Egyptian Dental Syndicate — dated within 3 months",
        "Gather certified copies of your degree, transcript, and work experience letters",
        `English assessment: ${isGulf(rc) ? "UAE/Gulf doesn't require a formal English test for most positions" : "book an IELTS Academic test — target 7.0+"}`,
        "Document your clinical case numbers by type: restorative, surgical, endodontic, orthodontic, etc.",
        `1–2 years of experience is strong — you qualify for most ${rc} licensing pathways`,
        p.goal.includes("Masters") ? "With 1–2 years post-graduation, you meet minimum experience requirements for most specialty Masters programs" : "",
      ].filter(Boolean) });
  } else if (p.stage === "General Dentist (3–5 yr exp)") {
    phases.push({ phase: "Leverage Your Experience", title: "Your 3–5 Years Is a Competitive Advantage", icon: "💼", color: "#2D9B68", duration: "2–3 weeks",
      tasks: [
        "Request a current Good Standing Letter from EDS — this formally documents your years of recognised practice",
        "Obtain detailed experience letters from each clinic/hospital, listing your case volume by specialty",
        `With ${p.specialty !== "General Dentistry" ? p.specialty + " experience" : "your clinical depth"}, you may qualify for specialist-track licensing in some countries`,
        "Gather case documentation and clinical photos — specialist Masters and referral positions require a portfolio",
        "Verify your CPD/continuing education certificates — some countries require proof of ongoing education",
        p.goal.includes("Masters") ? `3–5 years of experience significantly strengthens specialist Masters applications — your clinical case numbers are a key selection factor` : "",
      ].filter(Boolean),
      tip: "3–5 years of verifiable experience is a major competitive edge internationally — many specialist Masters programs explicitly prefer applicants with this level of background." });
  } else if (p.stage === "Specialist" || p.stage === "Master's Holder") {
    phases.push({ phase: "Specialist Assessment", title: "Map Your Specialist Credentials to Your Target Market", icon: "⭐", color: "#2D9B68", duration: "1–2 weeks",
      tasks: [
        `Check whether your specialty qualification is directly recognised in ${rc} — some countries have specialist registers`,
        isGulf(rc) ? "DHA/DOH/SCFHS have specialist registration tracks — your Egyptian specialist degree or Arab Board may qualify for faster registration" : `${rc} maintains a specialist register — check whether your specialty qualifies for direct admission`,
        "Apostille and officially translate your specialist certificate, Masters diploma, and degree",
        p.hasArabBoard ? "Your Arab Board qualification strengthens any international specialist application considerably" : "Consider obtaining Arab Board qualification if you're still in the planning phase — it adds international credibility",
        "Explore Fellowship and clinical doctorate programs as the next career step (fellowship programs run in UK, Ireland, USA)",
        "Specialist holders typically access faster licensing tracks and salary scales 30–50% above general dentist rates",
      ],
      tip: "Specialist registration in Gulf countries (UAE/KSA) often fast-tracks to consultant-level positions at significantly higher salaries than general dentist licensing." });
  } else {
    // Fresh Graduate
    phases.push({ phase: "Foundation", title: "Build Your International Application Profile", icon: "📋", color: brand.amber, duration: "2–4 weeks",
      tasks: [
        "Join the Egyptian Dental Syndicate and obtain your membership certificate — this is the first step for every pathway",
        "Request a Good Standing Letter from EDS — required by every licensing authority worldwide",
        "Gather certified copies of your BDS degree and official transcripts",
        `English level check: ${isGulf(rc) ? "Gulf countries generally don't require a formal English test — strong clinical English suffices" : "Book IELTS Academic, target 7.0+ (no band below 6.5) or OET Grade B"}`,
        "Create a professional CV in the format used in your target country (UK, Australian, Gulf formats differ)",
        "Research the specific licensing authority website and read the full requirements document",
      ] });
  }

  // ── Language phase ──────────────────────────────────────────────────────────
  if (rc === "Germany" || p.languages.includes("German")) {
    phases.push({ phase: "German Language Certification", title: "German B2 Proficiency — Your Biggest Hurdle", icon: "🗣️", color: brand.orange, duration: "8–18 months",
      tasks: [
        "Enrol at Goethe-Institut Cairo — structured A1 → B2 pathway with recognised certification",
        "Study intensively: 15–20+ hours per week for 12-month completion target",
        "Combine methods: Goethe-Institut classes + Anki flashcards for dental vocabulary + tandem language exchange",
        "Target the Goethe-Institut B2 Zertifikat — the most widely accepted credential for German health authorities",
        "Simultaneously contact German dental practices and state dental chambers — many will sponsor a strong candidate",
        "C1 (medical German / Fachsprachenprüfung) comes later and is tested after you're working in Germany",
      ],
      tip: "The German pathway has a 30% dropout rate after starting language learning. Join an Egyptian dentist Germany group on Facebook for accountability and tips." });
  } else if (!isGulf(rc) && rc !== "Jordan" && !p.englishLevel.includes("7.0") && !p.englishLevel.includes("OET")) {
    const engMonths = p.englishLevel === "Not started" ? "6–10 months" : p.englishLevel === "Basic" ? "5–8 months" : "2–4 months";
    phases.push({ phase: "Language Certification", title: "IELTS Academic / OET — Clear This First", icon: "🗣️", color: brand.orange, duration: engMonths,
      tasks: [
        `Target: IELTS Academic ${rc === "Australia" || rc === "New Zealand" ? "7.0 in ALL four bands (stricter than UK)" : "7.0 overall, no band below 6.5"} — or OET Grade B in all components`,
        "Book through British Council Cairo or IDP — IELTS is offered multiple times per month",
        "OET (Occupational English Test) is dental-context focused — many dentists find it easier than IELTS",
        "Allow dedicated study time: 30 minutes daily minimum. Use official Cambridge/British Council prep materials",
        "Book your exam date before you feel fully ready — exam deadlines create productive pressure",
        "Your IELTS result is valid for 2 years — plan subsequent steps around this validity window",
      ],
      cta: "/exams", ctaLabel: "Language preparation resources on Ejadah" });
  }

  // ── Masters phase ────────────────────────────────────────────────────────────
  if (p.goal === "Postgraduate Masters" || p.goal === "Both — Work & Postgrad") {
    const specLabel = p.specialty !== "General Dentistry" ? p.specialty : "dental";
    phases.push({ phase: "Masters Preparation", title: `${specLabel} Postgraduate Program — Research & Apply`, icon: "🎓", color: brand.gold, duration: "3–6 months to apply",
      tasks: [
        `Search Ejadah's Masters Database — filter by "${p.specialty}", "${rc}", and "Recognized Egypt" to shortlist 3–5 programs`,
        "UK programs: typical deadline December–March for September intake. Australian: August deadline for February intake.",
        "Personal statement: connect your Egyptian clinical experience directly to your chosen specialty — be specific about case numbers",
        "Request 2 professional references — ideally a respected Egyptian academic and a senior clinical supervisor",
        "Calculate total cost: tuition + living + travel. Cross-reference with Egyptian government scholarships (ECEB) and DAAD/British Council grants",
        "Apply to 3–5 programs simultaneously — acceptance rates range from 10% (top UK) to 35% (regional programs)",
      ],
      cta: "/masters", ctaLabel: "Browse 200+ Masters Programs on Ejadah" });
  }

  // ── Country-specific licensing phases ───────────────────────────────────────
  if (isGulf(rc)) {
    const gulfAuth: Record<string, string> = { "United Arab Emirates": "DHA / DOH / MOH", "Saudi Arabia": "SCFHS", "Qatar": "QCHP", "Kuwait": "MOH Kuwait", "Oman": "OMSB / MOH Oman", "Bahrain": "NHRA" };
    const auth = gulfAuth[rc] ?? "MOH";
    const salary: Record<string, string> = { "United Arab Emirates": "AED 12,000–25,000/month (tax-free)", "Saudi Arabia": "SAR 12,000–30,000/month (tax-free)", "Qatar": "QAR 10,000–22,000/month (tax-free)", "Kuwait": "KWD 600–1,400/month (tax-free)", "Oman": "OMR 500–1,000/month", "Bahrain": "BHD 600–1,300/month" };

    phases.push({ phase: "Verification", title: "DataFlow Primary Source Verification", icon: "📬", color: brand.orange, duration: "4–8 weeks",
      tasks: [
        "Create an account on dataflowgroup.com — DataFlow verifies your Egyptian degree directly with Cairo University and EDS",
        "Upload: degree certificate, official transcript, Good Standing Letter, passport, and professional photo",
        "Pay the DataFlow fee (~$140–200 USD) — processing takes 4–8 weeks",
        "Apply to the licensing exam in parallel — you can start exam prep while DataFlow processes",
        "Download your completed DataFlow report — this is a permanent record, reusable for multiple Gulf countries",
      ] });

    phases.push({ phase: "Licensing Exam", title: `${auth} Prometric Exam — Preparation & Sitting`, icon: "📚", color: brand.red, duration: "6–10 weeks study",
      tasks: [
        `Register on the Prometric portal — select ${rc}${rc === "United Arab Emirates" ? " and choose the emirate: DHA (Dubai), DOH (Abu Dhabi), or MOH (other emirates)" : ""} dental examination`,
        "Exam content: General dentistry MCQs + dental ethics + local health regulations. 100–150 questions. Pass mark ~60–65%.",
        "Use Ejadah's Gulf Prometric question bank — 9,000+ questions calibrated for DHA/DOH/SCFHS/QCHP/NHRA",
        "Most candidates who prepare with 6–10 weeks of structured study pass on the first attempt",
        "Prometric centres are available in Cairo — you don't need to travel to the Gulf for the exam",
      ],
      cta: "/exams", ctaLabel: `${rc} Prometric prep on Ejadah` });

    phases.push({ phase: "License + Employment + Visa", title: `${rc} Registration, Job Offer & Visa`, icon: "🎉", color: "#2D9B68", duration: "4–8 weeks",
      tasks: [
        `Submit your license application to ${auth} with your DataFlow report and Prometric exam certificate`,
        `License processing: 2–6 weeks. The ${rc === "United Arab Emirates" ? "UAE" : rc} license is typically valid for 2–3 years and renewable`,
        p.goal === "Postgraduate Masters" || p.goal === "Both — Work & Postgrad" ? "Look for positions near universities — some Gulf employers support (and partially fund) postgraduate study" : `Job search: target dental groups, hospital networks, and premium private clinics. Negotiate salary + housing + flight allowances`,
        `Expected package: ${salary[rc] ?? "varies"}, plus typically housing + transportation + annual return flight`,
        "Employer sponsors your employment visa and residency permit — allow 3–6 weeks after job offer",
      ],
      cta: `/career/${cs}`, ctaLabel: `Full ${rc} pathway guide with costs & requirements` });

  } else if (rc === "United Kingdom") {
    phases.push({ phase: "GDC Eligibility", title: "GDC Application — Confirm Your Eligibility", icon: "📬", color: brand.orange, duration: "4–8 weeks processing",
      tasks: [
        "Apply at gdc-uk.org — submit your Egyptian BDS degree for GDC eligibility assessment. Fee: £105.",
        "Include: EDS Good Standing Letter, degree certificate, official transcript, IELTS/OET score",
        "GDC confirms you are eligible to sit the ORE — this takes 4–8 weeks to process",
        "While waiting: begin ORE Part 1 study. Don't let the processing time go to waste.",
        "Join ORE Facebook/WhatsApp groups for Egyptian dentists — active communities share resources and sit-together strategies",
      ] });

    phases.push({ phase: "ORE Part 1", title: "ORE Part 1 — Written Examination", icon: "📚", color: brand.red, duration: "4–6 months preparation",
      tasks: [
        "Two papers: Dental Materials & Human Disease (100 MCQs) + Clinical Dentistry (100 MCQs). Pass mark ~55%.",
        "Ejadah's ORE question bank: 6,200+ questions in GDC exam format with detailed explanations",
        "Structured study plan: 8–10 weeks of intensive revision before booking. Minimum 2 full mock exams.",
        "Offered March, June, and October — book your target sitting 8–12 weeks before the date",
        "Pass rate improves significantly with structured group preparation — consider joining or forming a study group",
      ],
      cta: "/exams", ctaLabel: "ORE Part 1 preparation on Ejadah" });

    phases.push({ phase: "ORE Part 2", title: "ORE Part 2 — Clinical OSCE", icon: "🏥", color: brand.amber, duration: "3–5 months after Part 1",
      tasks: [
        "Clinical OSCE stations at GDC-approved UK centres — covers patient management, clinical skills, ethics, medical emergencies",
        "Must travel to the UK for Part 2 — plan flights and accommodation. Fee: £1,045.",
        "Consider a 3–5 day OSCE preparation intensive course in the UK — several Egyptian dentist-led courses exist",
        "Communication skills are assessed as carefully as clinical knowledge — practice explaining procedures in clear English",
        "Book as soon as Part 1 result arrives — Part 2 has fewer annual dates than Part 1",
      ] });

    phases.push({ phase: "GDC Registration & Employment", title: "Full GDC Registration + UK Associate Position", icon: "🎉", color: "#2D9B68", duration: "4–8 weeks + job search",
      tasks: [
        "Apply for GDC Full Registration: £743. Processing takes 4–6 weeks. Annual retention fee: £743.",
        "Obtain professional indemnity insurance (MDU, MPS, or MDDUS) — required before seeing any patient",
        "Apply for a Skilled Worker visa — your employer will sponsor this. Processing: 3–8 weeks.",
        p.goal.includes("Masters") ? `Apply to UK Masters programs in ${p.specialty} — GDC registration makes you an extremely competitive candidate for UK programs` : "Apply for associate roles — London, Birmingham, Manchester, and Leeds have highest vacancy rates. NHS and private both offer strong starting salaries",
        "Starting associate salary: £35,000–55,000. With 3+ years UK experience: £55,000–£80,000+",
      ],
      cta: "/career/uk", ctaLabel: "Full UK pathway guide with costs" });

  } else if (rc === "Australia") {
    phases.push({ phase: "ADC Application", title: "Australian Dental Council — Eligibility Assessment", icon: "📬", color: brand.orange, duration: "8–12 weeks",
      tasks: [
        "Apply at adc.org.au — submit your degree, academic transcripts, and EDS Good Standing Letter. Fee: AUD 800.",
        "IELTS 7.0 required in ALL four bands (stricter than UK) — or OET Grade B in all components",
        "ADC assessment: most Egyptian dentists are directed to the full ADC Examination (written + practical)",
        "Begin written exam preparation immediately — don't wait for the assessment result",
        "Connect with Australian Egyptian dentist groups — active communities with ADC resources and study schedules",
      ] });

    phases.push({ phase: "ADC Written Exam", title: "ADC Written Examination — Your First Major Hurdle", icon: "📚", color: brand.red, duration: "6–12 months preparation",
      tasks: [
        "Offered February and August — book 4–6 months in advance. Fee: AUD 1,850 per attempt.",
        "Covers all dental sciences comprehensively: anatomy, physiology, pathology, pharmacology, microbiology, clinical dentistry",
        "Pass rate ~55% for international candidates. Thorough preparation (6–12 months) is the key differentiator.",
        "Join an ADC written exam study group — structured peer groups consistently outperform solo study",
        "Use Ejadah's ADC preparation materials — content aligned with ADC exam blueprint",
      ],
      cta: "/exams", ctaLabel: "ADC exam preparation on Ejadah" });

    phases.push({ phase: "ADC Practical + AHPRA", title: "ADC Practical Examination + AHPRA Registration", icon: "🎉", color: "#2D9B68", duration: "6–12 months",
      tasks: [
        "ADC Practical: clinical OSCE — held once per year. Fee: AUD 4,500. You must travel to Australia.",
        "Book flights and accommodation for the 5–7 day exam period — budget AUD 2,000–4,000 for the trip",
        "Apply for AHPRA registration after passing the ADC. Annual fee: AUD 375.",
        "Skilled Migrant visa (subclass 190): dentistry is on Australia's skilled occupation list — excellent migration prospects",
        "Consider regional Australia for your first position — faster visa sponsorship, rural incentives, and employer eagerness to hire",
      ],
      cta: "/career/australia", ctaLabel: "Full Australia pathway guide" });

  } else if (rc === "Germany") {
    phases.push({ phase: "Credential Recognition", title: "Apply for Approbation — State Health Authority", icon: "📬", color: brand.red, duration: "3–6 months",
      tasks: [
        "Apply to the state health authority (Landesgesundheitsamt) of your target German state",
        "Bavaria and Baden-Württemberg are most internationally experienced — they handle more non-EU applications",
        "Submit: Apostilled degree + certified German translation + EDS Good Standing Letter + B2 language certificate + CV in German",
        "Most Egyptian dentists receive a direction to complete a Kenntnisprüfung (knowledge examination) — this is normal",
        "Apply for a Berufserlaubnis (provisional licence) simultaneously — allows supervised practice while awaiting full licence",
      ] });

    phases.push({ phase: "Medical German + Full Licence", title: "Fachsprachenprüfung + Full Approbation", icon: "🎉", color: "#2D9B68", duration: "6–12 months",
      tasks: [
        "Work in a German dental practice under a Berufserlaubnis — your employer must be an Approbierter Zahnarzt",
        "Attend medical German courses — aim for C1 and the Fachsprachenprüfung (clinical language exam with patient role-play)",
        "Many German employers offer paid study time and support for Fachsprachenprüfung preparation",
        "Pass Fachsprachenprüfung → receive full Approbation → practise independently",
        "Zahnarzt associate salary: €50,000–€80,000/year. Senior positions and practice ownership: €80,000–€150,000+",
      ],
      cta: "/career/germany", ctaLabel: "Full Germany pathway guide" });

  } else if (rc === "Canada") {
    phases.push({ phase: "NDEB Pathway", title: "National Dental Examining Board — Assessment", icon: "📬", color: brand.orange, duration: "8–12 weeks",
      tasks: [
        "Apply to ndeb.ca — submit degree, transcripts, and Good Standing Letter. NDEB determines your exact pathway.",
        "Most international dentists need: AFK (Assessment of Fundamental Knowledge) → Written Exam → OSCE",
        "IELTS 7.0+ or French equivalent (French required in Quebec). Choose your province strategically.",
        "Ontario (Toronto) and British Columbia (Vancouver) have the most dental job opportunities",
        "Some candidates are directed to a 2-year bridging program at a Canadian dental school — less common but possible",
      ] });

    phases.push({ phase: "NDEB Examinations", title: "AFK + Written Exam + OSCE", icon: "📚", color: brand.red, duration: "12–24 months",
      tasks: [
        "NDEB AFK: 150 MCQs on dental sciences. Pass mark ~70%. Multiple attempts allowed. Fee: CAD 400.",
        "NDEB Written: 200 MCQs on clinical dentistry — sits after AFK pass. Fee: CAD 600.",
        "NDEB OSCE: practical clinical examination — the hardest and final hurdle. Fee: CAD 1,800.",
        "Allow 6–9 months of structured preparation per exam. NDEB study groups (online) are essential.",
        "Use Ejadah's NDEB materials and join Canadian-focused Egyptian dentist preparation communities",
      ],
      cta: "/exams", ctaLabel: "NDEB preparation resources on Ejadah" });

    phases.push({ phase: "Provincial Licence & Immigration", title: "Provincial Registration + Canadian PR", icon: "🎉", color: "#2D9B68", duration: "3–6 months",
      tasks: [
        "Apply to the provincial dental regulatory authority of your target province (RCDSO for Ontario, CDSBC for BC)",
        "Apply via Express Entry (Federal Skilled Worker) or Provincial Nominee Program. Dentistry is NOC 31110.",
        "A confirmed job offer from a Canadian dental practice significantly boosts your immigration points score",
        p.goal.includes("Masters") ? `After 2+ years of Canadian practice, apply for specialist programs in ${p.specialty} — Canadian specialist qualifications are internationally prestigious` : "Starting associate salary: CAD 100,000–150,000/year. Senior: CAD 150,000–220,000+",
      ],
      cta: "/career/canada", ctaLabel: "Full Canada pathway guide" });

  } else if (rc === "Ireland") {
    phases.push({ phase: "Dental Council Assessment", title: "Dental Council of Ireland — Qualification Assessment", icon: "📬", color: brand.orange, duration: "4–8 weeks",
      tasks: [
        "Apply to the Dental Council of Ireland (dentalcouncil.ie) for formal qualification assessment",
        "IELTS 7.0 (no band below 6.5) or OET Grade B — same requirement as UK",
        "Dental Council assesses your Egyptian degree and confirms whether RCSI qualifying exam is required",
        "Critical Skills Employment Permit: dentistry is on Ireland's critical skills list — employer-sponsored visa",
        "Irish registration may be mutually recognised across EU/EEA states — a strategic long-term advantage",
      ] });

    phases.push({ phase: "RCSI Exam + Dental Register", title: "RCSI Qualifying Examination + Registration", icon: "🎉", color: "#2D9B68", duration: "6–12 months",
      tasks: [
        "RCSI Qualifying Exam: written and practical components. Offered 1–2× per year. Fee: €800–1,200.",
        "Pass mark ~60%. Preparation materials similar to UK ORE — Ejadah's question bank is applicable.",
        "Apply for Dental Register admission upon passing — admission fee ~€500",
        "Apply for Critical Skills Employment Permit with a job offer. HSE (public service) is a major employer.",
        "Ireland salary: €55,000–€85,000. EU mutual recognition opens Germany, Netherlands, and other EU markets long-term.",
      ],
      cta: "/career/ireland", ctaLabel: "Full Ireland pathway guide" });

  } else if (rc === "Jordan") {
    phases.push({ phase: "JDA Registration", title: "Jordanian Dental Association — Fast Track for Egyptians", icon: "📬", color: "#2D9B68", duration: "2–4 weeks",
      tasks: [
        "Submit your Egyptian BDS to the JDA — Egyptian degrees are directly accepted. No major exam required.",
        "Documents: degree + EDS Good Standing Letter + EDS membership card + passport + photos",
        "JDA registration + Ministry of Health clearance. Processing: 2–4 weeks.",
        "Jordan is the fastest and most accessible Arabic-speaking international market for Egyptian dentists",
        "Simultaneously prepare Gulf Prometric exam — Jordan experience makes UAE/KSA applications significantly stronger",
      ] });

    phases.push({ phase: "Jordan Practice + Gulf Pipeline", title: "Establish in Jordan → Gulf Progression", icon: "🎉", color: "#2D9B68", duration: "1–3 years",
      tasks: [
        "Target private clinics in Amman's premium areas: Abdoun, Sweifieh, Wadi Saqra — highest salary zones",
        "Build a verifiable clinical track record: Jordanian experience certificates are respected across the Gulf",
        "Use this period to pass the Gulf Prometric exam (study with Ejadah's Q-bank) — your Jordan income funds exam fees",
        p.goal.includes("Masters") ? "Jordanian income is moderate — plan Masters application after 2+ years once savings allow" : "Gulf recruitment agencies in Amman actively place experienced Jordanian-registered dentists in UAE/KSA",
        "Expected Jordan salary: JOD 800–1,800/month. UAE move can immediately triple your income.",
      ],
      cta: "/career/jordan", ctaLabel: "Full Jordan pathway guide" });

  } else {
    // Generic fallback
    phases.push({ phase: "Credential Assessment & Exam", title: "Official Assessment + Licensing Examination", icon: "📬", color: brand.orange, duration: "4–16 weeks",
      tasks: [
        "Contact the relevant regulatory authority in your target country and confirm the full requirements",
        "Submit your degree, EDS Good Standing Letter, and certified translations for formal assessment",
        "Prepare for the required licensing examination — allow 3–9 months of structured study",
        "Use Ejadah's question banks and study resources — content is calibrated for international licensing exams",
        "Join online communities of Egyptian dentists in your target country for firsthand advice",
      ],
      cta: "/exams", ctaLabel: "Exam preparation on Ejadah" });

    phases.push({ phase: "Registration + Employment", title: "Professional Registration + First Position", icon: "🎉", color: "#2D9B68", duration: "2–6 months",
      tasks: [
        "Apply for professional registration with required fees and documentation",
        "Begin job applications 2–3 months before completing your licensing process",
        "Negotiate your contract: salary, visa sponsorship, housing, continuing education allowance",
        "Obtain professional indemnity insurance before seeing your first patient",
        "Connect with Ejadah career mentors who've completed this exact pathway",
      ] });
  }

  // ── Research addition ─────────────────────────────────────────────────────
  if (p.goal === "Research Career") {
    phases.push({ phase: "Academic Research Track", title: "PhD / Research Fellowship Pathway", icon: "🔬", color: brand.amber, duration: "Parallel track — 3–5 years",
      tasks: [
        "Target universities with strong dental research departments: King's College London, Melbourne, Toronto, Charité Berlin",
        "Build your publication record before applying — aim for 1–2 peer-reviewed papers indexed in PubMed",
        "Apply for funded PhD programs or research fellowships — many include a full stipend (£15,000–£25,000/year)",
        "Scholarships to pursue: DAAD (Germany), British Council, Chevening, Islamic Development Bank",
        "Connect with Egyptian dental academics already at international universities — they are often key supervisors and reference contacts",
        "Egyptian Cultural Educational Bureau (ECEB) channels funding for Egyptian academics pursuing qualifications abroad",
      ],
      cta: "/masters", ctaLabel: "Research and Masters programs on Ejadah" });
  }

  // ── Masters recommendations ───────────────────────────────────────────────
  const allRecs: MastersRec[] = [];

  const specMasters: Record<string, MastersRec[]> = {
    "Orthodontics": [
      { id: "1", name: "King's College London", country: "United Kingdom", flag: "🇬🇧", specialty: "Orthodontics MSc", why: "Full program page with scholarships, curriculum & timeline on Ejadah. GDC + Gulf-recognised." },
      { id: "2", name: "University of Manchester", country: "United Kingdom", flag: "🇬🇧", specialty: "Orthodontics", why: "Strong NHS hospital attachment. GDC-recognised. Regional UK pathway." },
      { id: "171", name: "University of Western Australia", country: "Australia", flag: "🇦🇺", specialty: "Orthodontics", why: "ADC-recognised. QS Top 100. Excellent clinical volume." },
    ],
    "Implantology": [
      { id: "5", name: "UCL Eastman Dental Institute", country: "United Kingdom", flag: "🇬🇧", specialty: "Implantology", why: "Europe's leading implant program. GDC, UAE, and KSA-recognised." },
      { id: "172", name: "University of Sydney", country: "Australia", flag: "🇦🇺", specialty: "Implantology", why: "QS Top 20 globally. ADC-recognised. Outstanding surgical training." },
      { id: "189", name: "Università Vita-Salute San Raffaele", country: "Italy", flag: "🇮🇹", specialty: "Implantology", why: "Italy/EU-recognised. Excellent implantology reputation. Milan base." },
    ],
    "Oral Surgery": [
      { id: "167", name: "University of Birmingham", country: "United Kingdom", flag: "🇬🇧", specialty: "Oral Surgery MClinDent", why: "GDC, UAE, KSA, and Qatar-recognised. 3-year specialist pathway." },
      { id: "185", name: "Chulalongkorn University", country: "Thailand", flag: "🇹🇭", specialty: "Oral Surgery", why: "QS Top 65. Excellent surgical case volume. Lower cost than UK." },
      { id: "190", name: "KU Leuven", country: "Belgium", flag: "🇧🇪", specialty: "Oral Surgery", why: "QS Top 42. KU Leuven scholarship available. EU-recognised." },
    ],
    "Periodontology": [
      { id: "168", name: "Queen Mary University of London", country: "United Kingdom", flag: "🇬🇧", specialty: "Periodontology MClinDent", why: "GDC, UAE, KSA, Qatar-recognised. Scholarship available." },
      { id: "170", name: "Monash University", country: "Australia", flag: "🇦🇺", specialty: "Periodontology", why: "QS Top 42 globally. ADC-recognised. Exceptional research facilities." },
      { id: "191", name: "University of Geneva", country: "Switzerland", flag: "🇨🇭", specialty: "Periodontology", why: "QS Top 30. Switzerland-based. Highest European salary on completion." },
    ],
    "Endodontics": [
      { id: "173", name: "Dalhousie University", country: "Canada", flag: "🇨🇦", specialty: "Endodontics MSD", why: "NDEB-recognised specialist qualification. Canadian pathway." },
      { id: "175", name: "UCLA School of Dentistry", country: "United States", flag: "🇺🇸", specialty: "Endodontics MS", why: "QS Top 35. ADA specialist qualification. Highest international prestige." },
      { id: "3", name: "University of Bristol", country: "United Kingdom", flag: "🇬🇧", specialty: "Endodontics", why: "GDC-recognised. Strong UK specialist registration track." },
    ],
    "Prosthodontics": [
      { id: "174", name: "University of Alberta", country: "Canada", flag: "🇨🇦", specialty: "Prosthodontics MSD", why: "NDEB specialist-recognised. UAE-recognised. Strong clinical faculty." },
      { id: "176", name: "University of Washington", country: "United States", flag: "🇺🇸", specialty: "Prosthodontics MSD", why: "QS Top 52. World-leading prosthodontics. ADA specialist." },
      { id: "4", name: "University of Leeds", country: "United Kingdom", flag: "🇬🇧", specialty: "Prosthodontics", why: "GDC-recognised. NHS specialist training pathway." },
    ],
  };

  if (p.goal === "Postgraduate Masters" || p.goal === "Both — Work & Postgrad" || p.goal === "Research Career") {
    const recs = specMasters[p.specialty] ?? [
      { id: "1", name: "King's College London", country: "United Kingdom", flag: "🇬🇧", specialty: "Orthodontics", why: "Most comprehensive program page on Ejadah — full scholarships, curriculum & contact details." },
      { id: "168", name: "Queen Mary University London", country: "United Kingdom", flag: "🇬🇧", specialty: "Periodontology", why: "GDC and Gulf-recognised. QMUL scholarship available." },
    ];
    allRecs.push(...recs);
  }

  // Add a Gulf-relevant Masters recommendation
  if (isGulf(rc) && (p.goal === "Both — Work & Postgrad")) {
    allRecs.push({ id: "5", name: "UCL Eastman Dental Institute", country: "United Kingdom", flag: "🇬🇧", specialty: "Implantology", why: "UAE and KSA-recognised. Pursuing this while working in Gulf maximises dual benefit." });
  }

  // Deduplicate
  const seen = new Set<string>();
  const mastersRecs = allRecs.filter(r => { if (seen.has(r.id)) return false; seen.add(r.id); return true; }).slice(0, 3);

  // ── Challenges ────────────────────────────────────────────────────────────
  const challenges: string[] = [];
  if (!p.englishLevel.includes("7.0") && !p.englishLevel.includes("OET") && !isGulf(rc) && rc !== "Jordan" && rc !== "Germany")
    challenges.push(`IELTS 7.0+ is your first real gate — everything else waits on this. Allow ${p.englishLevel === "Not started" ? "6–9 months" : "3–5 months"} and treat it as urgent.`);
  if (rc === "Germany")
    challenges.push("German C1 fluency takes most Egyptian dentists 14–20 months. This is the biggest single investment of the pathway — commit fully or consider a parallel Gulf start.");
  if (rc === "USA")
    challenges.push("The Advanced Standing DDS costs USD 120,000–180,000 and takes 2+ years after acceptance. Ensure you have a realistic financial plan before committing to this pathway.");
  if (p.budget === "Limited (< €10k)" && !isGulf(rc) && rc !== "Jordan")
    challenges.push("Your budget is best matched to a Gulf pathway first (UAE/KSA cost < $600 total fees). Build Gulf savings for 1–2 years, then fund the more expensive UK/Australia pathway.");
  if (p.goal === "Both — Work & Postgrad")
    challenges.push("Combining work and Masters is fully realistic — many UK, Australian, and Irish programs are part-time specifically for working dentists. Plan a 2-year overlap period.");
  if (p.stage === "Specialist" || p.stage === "Master's Holder")
    challenges.push("Specialist credential portability is uneven — UAE/KSA have fast-track specialist registration, UK needs GDC specialist list verification. Check your specific specialty before planning.");

  // ── Timelines & costs ─────────────────────────────────────────────────────
  const tlMap: Record<string, string> = {
    "United Arab Emirates": "3–6 months", "Saudi Arabia": "2–5 months", "Qatar": "2–4 months",
    "Kuwait": "3–6 months", "Oman": "3–6 months", "Bahrain": "2–4 months",
    "Jordan": "1–3 months", "United Kingdom": "18–24 months",
    "Australia": "24–36 months", "Canada": "24–36 months",
    "Germany": "20–32 months", "Ireland": "10–18 months",
    "New Zealand": "18–30 months", "United States": "36–60 months",
  };

  const costMap: Record<string, string> = {
    "United Arab Emirates": "~$300–600 in fees", "Saudi Arabia": "~$300–500 in fees",
    "Qatar": "~$300–500 in fees", "Kuwait": "~$300–500 in fees",
    "Jordan": "~$100–300 in fees", "United Kingdom": "~£3,500–5,000 in fees (excl. living)",
    "Australia": "~AUD 10,000–12,000 in exam & registration fees",
    "Canada": "~CAD 3,500–5,000 in exam fees", "Germany": "~€3,000–8,000 (language + admin)",
    "Ireland": "~€1,500–2,500 in fees", "United States": "~USD 130,000–200,000 total",
  };

  const altMap: Record<string, string> = {
    "United Kingdom": "If ORE preparation feels overwhelming initially, start with UAE (3–6 months, income begins fast) then return to ORE with financial stability and an international salary behind you.",
    "Australia": "If the ADC two-stage process is too long, Ireland via RCSI (6–18 months, English-speaking) or UAE (3–6 months) are strong alternatives with comparable long-term potential.",
    "Germany": "If German language progress stalls after 6 months, pivot to Ireland (English, 10–18 months) or UAE (3–6 months). German can remain a longer-term goal while you earn abroad.",
    "United States": "If the Advanced Standing DDS is cost-prohibitive, Canada via NDEB (24–36 months, CAD 100k–180k/yr) offers comparable income with much lower barriers.",
    "Canada": "If NDEB takes longer than expected, Australia (ADC, similar income) or UK (ORE, faster) are strong parallel options. All three ultimately lead to comparable careers.",
    "France": "France's quota system can mean waiting 2–3 cycles. Belgium (similar language, smoother process) or Germany (German required) are better European alternatives.",
  };

  return {
    headline: `${p.stage} → ${isGulf(rc) ? rc + " Dentist" : p.goal === "Postgraduate Masters" ? p.specialty + " Masters" : rc + " Registered Dentist"}`,
    subtitle: `${p.specialty !== "General Dentistry" ? p.specialty + " · " : ""}${p.budget} · ${p.englishLevel}${p.hasMasters ? " · Masters holder" : ""}`,
    totalMonths: tlMap[rc] ?? "12–24 months",
    estimatedCost: costMap[rc] ?? "Varies by pathway",
    resolvedCountry: rc,
    countrySlug: cs,
    phases,
    mastersRecs,
    challenges,
    altPath: altMap[rc] ?? "If this pathway faces delays, the UAE Fast Track (3–6 months, under $600 fees) is always the most accessible fallback to begin earning internationally.",
  };
}

// ─── Sub-components ───────────────────────────────────────────────────────────

const STEP_COLOR = [brand.amber, brand.orange, brand.red, "#2D9B68"];

function StepBar({ current, total }: { current: number; total: number }) {
  return (
    <div style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 28 }}>
      {Array.from({ length: total }).map((_, i) => (
        <div key={i} style={{ flex: 1, height: 4, borderRadius: 2, background: i < current ? STEP_COLOR[i] : brand.borderGray, transition: "background 0.3s" }} />
      ))}
      <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, whiteSpace: "nowrap" as const }}>{current} / {total}</span>
    </div>
  );
}

function ChipGroup({ label, options, value, onChange, multi, multiValue, onMultiChange }: {
  label: string; options: string[];
  value?: string; onChange?: (v: string) => void;
  multi?: boolean; multiValue?: string[]; onMultiChange?: (v: string[]) => void;
}) {
  return (
    <div style={{ marginBottom: 20 }}>
      <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal, marginBottom: 10 }}>{label}</div>
      <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
        {options.map((opt) => {
          const active = multi ? (multiValue ?? []).includes(opt) : value === opt;
          return (
            <button key={opt} onClick={() => {
              if (multi && onMultiChange) {
                const cur = multiValue ?? [];
                onMultiChange(cur.includes(opt) ? cur.filter(x => x !== opt) : [...cur, opt]);
              } else onChange?.(opt);
            }} style={{ fontFamily: "Inter", fontWeight: active ? 600 : 400, fontSize: 13, color: active ? "#fff" : brand.charcoal, background: active ? gradientFlow : brand.offWhite, border: `1.5px solid ${active ? "transparent" : brand.borderGray}`, borderRadius: 10, padding: "8px 16px", cursor: "pointer", transition: "all 0.15s" }}>
              {opt}
            </button>
          );
        })}
      </div>
    </div>
  );
}

function GeneratingAnimation({ stage }: { stage: number }) {
  const steps = ["Analysing your profile…", "Mapping licensing requirements…", "Selecting optimal timeline…", "Integrating Masters programs…", "Personalising your roadmap…"];
  return (
    <div style={{ textAlign: "center" as const, padding: "60px 24px" }}>
      <div style={{ width: 64, height: 64, borderRadius: "50%", background: `${brand.orange}15`, border: `2px solid ${brand.orange}30`, display: "flex", alignItems: "center", justifyContent: "center", margin: "0 auto 24px", animation: "spin 2s linear infinite" }}>
        <Zap size={28} color={brand.orange} />
      </div>
      <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.charcoal, marginBottom: 8 }}>Ejadah AI is building your roadmap</div>
      <div style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, marginBottom: 32 }}>Personalising based on your profile and goals…</div>
      <div style={{ maxWidth: 380, margin: "0 auto" }}>
        {steps.map((s, i) => (
          <div key={s} style={{ display: "flex", gap: 12, alignItems: "center", marginBottom: 12, opacity: i <= stage ? 1 : 0.3, transition: "opacity 0.5s" }}>
            <div style={{ width: 20, height: 20, borderRadius: "50%", background: i <= stage ? "#2D9B68" : brand.borderGray, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0, transition: "background 0.5s" }}>
              {i <= stage ? <CheckCircle size={12} color="#fff" /> : <div style={{ width: 6, height: 6, borderRadius: "50%", background: brand.warmGray }} />}
            </div>
            <span style={{ fontFamily: "Inter", fontSize: 13, color: i <= stage ? brand.charcoal : brand.warmGray, textAlign: "left" as const }}>{s}</span>
          </div>
        ))}
      </div>
      <style>{`@keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }`}</style>
    </div>
  );
}

// ─── Main Component ───────────────────────────────────────────────────────────

export default function CareerRoadmap() {
  const nav = useNavigate();
  const [step, setStep] = useState(1);
  const [generating, setGenerating] = useState(false);
  const [genStage, setGenStage] = useState(0);
  const [roadmap, setRoadmap] = useState<GeneratedRoadmap | null>(null);

  const [profile, setProfile] = useState<Profile>({
    stage: "Fresh Graduate",
    specialty: "General Dentistry",
    goal: "Work abroad",
    country: "United Arab Emirates",
    timeline: "1–2 years",
    budget: "Standard (€10–30k)",
    englishLevel: "Upper Intermediate",
    languages: [],
    hasMasters: false,
    hasArabBoard: false,
  });

  const set = (key: keyof Profile) => (v: any) => setProfile(prev => ({ ...prev, [key]: v }));

  const handleGenerate = () => {
    setGenerating(true);
    setGenStage(0);
    let s = 0;
    const interval = setInterval(() => {
      s++;
      setGenStage(s);
      if (s >= 4) {
        clearInterval(interval);
        setTimeout(() => {
          setRoadmap(generateRoadmap(profile));
          setGenerating(false);
        }, 600);
      }
    }, 450);
  };

  const reset = () => { setRoadmap(null); setStep(1); setGenerating(false); };

  // ── Roadmap output ──────────────────────────────────────────────────────────
  if (roadmap) {
    return (
      <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
        {/* Header */}
        <div style={{ background: `linear-gradient(135deg, ${brand.charcoal} 0%, #24201D 100%)`, padding: "48px 24px 40px", position: "relative", overflow: "hidden" }}>
          <div style={{ position: "absolute", inset: 0, background: "radial-gradient(ellipse at 70% 40%, rgba(255,107,26,0.08) 0%, transparent 55%)", pointerEvents: "none" }} />
          <div style={{ maxWidth: 900, margin: "0 auto", position: "relative" }}>
            <button onClick={reset} style={{ background: "none", border: "none", cursor: "pointer", color: "rgba(255,255,255,0.5)", fontFamily: "Inter", fontSize: 13, display: "flex", alignItems: "center", gap: 5, marginBottom: 18 }}>
              <ArrowLeft size={14} /> New Roadmap
            </button>
            <div style={{ display: "inline-flex", alignItems: "center", gap: 6, background: `${brand.amber}20`, border: `1px solid ${brand.amber}30`, borderRadius: 8, padding: "4px 12px", marginBottom: 14 }}>
              <Zap size={12} color={brand.amber} />
              <span style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 700, color: brand.amber, letterSpacing: "0.08em" }}>AI-GENERATED ROADMAP</span>
            </div>
            <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(22px,3.5vw,36px)", color: "#fff", marginBottom: 8 }}>{roadmap.headline}</h1>
            <p style={{ fontFamily: "Inter", fontSize: 14, color: "rgba(255,255,255,0.55)", marginBottom: 24 }}>{roadmap.subtitle}</p>
            <div style={{ display: "flex", gap: 20, flexWrap: "wrap" }}>
              {[
                { icon: <Clock size={14} />, label: "Timeline to License", value: roadmap.totalMonths },
                { icon: <DollarSign size={14} />, label: "Estimated Fees", value: roadmap.estimatedCost },
                { icon: <Target size={14} />, label: "Phases", value: `${roadmap.phases.length} steps` },
                { icon: <Star size={14} />, label: "Tailored for", value: profile.stage },
              ].map(f => (
                <div key={f.label} style={{ background: "rgba(255,255,255,0.06)", border: "1px solid rgba(255,255,255,0.1)", borderRadius: 12, padding: "10px 14px" }}>
                  <div style={{ display: "flex", gap: 5, alignItems: "center", fontFamily: "Inter", fontSize: 10, color: "rgba(255,255,255,0.4)", marginBottom: 4 }}>{f.icon} {f.label}</div>
                  <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff" }}>{f.value}</div>
                </div>
              ))}
            </div>
          </div>
        </div>

        <div style={{ maxWidth: 900, margin: "0 auto", padding: "32px 24px" }}>
          <div style={{ display: "flex", gap: 28, flexWrap: "wrap" }}>
            {/* Main timeline */}
            <div style={{ flex: 1, minWidth: 300 }}>
              <div style={{ display: "flex", flexDirection: "column" as const, gap: 16 }}>
                {roadmap.phases.map((phase, i) => (
                  <div key={i} style={{ display: "flex", gap: 18 }}>
                    <div style={{ display: "flex", flexDirection: "column" as const, alignItems: "center" }}>
                      <div style={{ width: 44, height: 44, borderRadius: "50%", background: `${phase.color}14`, border: `2px solid ${phase.color}`, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 20, flexShrink: 0 }}>{phase.icon}</div>
                      {i < roadmap.phases.length - 1 && <div style={{ width: 2, flex: 1, background: brand.borderGray, minHeight: 20, marginTop: 6 }} />}
                    </div>
                    <div style={{ flex: 1, paddingBottom: i < roadmap.phases.length - 1 ? 8 : 0 }}>
                      <div style={{ background: brand.white, borderRadius: 16, border: `1px solid ${brand.borderGray}`, padding: "18px 20px" }}>
                        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 12 }}>
                          <div>
                            <div style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 700, color: phase.color, letterSpacing: "0.07em", marginBottom: 3 }}>{phase.phase}</div>
                            <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: brand.charcoal }}>{phase.title}</div>
                          </div>
                          <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, background: brand.offWhite, borderRadius: 6, padding: "3px 9px", flexShrink: 0, marginLeft: 8 }}>{phase.duration}</span>
                        </div>
                        <div style={{ display: "flex", flexDirection: "column" as const, gap: 6, marginBottom: phase.tip || phase.cta ? 12 : 0 }}>
                          {phase.tasks.map((task, ti) => (
                            <div key={ti} style={{ display: "flex", gap: 8, alignItems: "flex-start" }}>
                              <div style={{ width: 5, height: 5, borderRadius: "50%", background: phase.color, flexShrink: 0, marginTop: 7 }} />
                              <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, lineHeight: 1.55 }}>{task}</span>
                            </div>
                          ))}
                        </div>
                        {phase.tip && (
                          <div style={{ background: `${brand.amber}08`, border: `1px solid ${brand.amber}20`, borderRadius: 10, padding: "10px 14px", marginTop: 10, marginBottom: phase.cta ? 10 : 0 }}>
                            <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.charcoal, lineHeight: 1.5 }}>💡 {phase.tip}</span>
                          </div>
                        )}
                        {phase.cta && (
                          <button onClick={() => nav(phase.cta!)} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: phase.color, background: `${phase.color}10`, border: "none", borderRadius: 8, padding: "8px 14px", cursor: "pointer", display: "flex", alignItems: "center", gap: 5, marginTop: 4 }}>
                            {phase.ctaLabel} <ChevronRight size={12} />
                          </button>
                        )}
                      </div>
                    </div>
                  </div>
                ))}
              </div>

              {/* Challenges */}
              {roadmap.challenges.length > 0 && (
                <div style={{ background: `${brand.red}06`, border: `1px solid ${brand.red}15`, borderRadius: 18, padding: "20px 22px", marginTop: 24 }}>
                  <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.red, marginBottom: 12, display: "flex", alignItems: "center", gap: 6 }}>
                    <Shield size={14} /> Key Challenges for Your Profile
                  </div>
                  {roadmap.challenges.map((c, i) => (
                    <div key={i} style={{ display: "flex", gap: 8, marginBottom: 10 }}>
                      <span style={{ color: brand.red, flexShrink: 0 }}>→</span>
                      <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, lineHeight: 1.55 }}>{c}</span>
                    </div>
                  ))}
                </div>
              )}

              {/* Alternative path */}
              <div style={{ background: `${brand.amber}08`, border: `1px solid ${brand.amber}20`, borderRadius: 18, padding: "20px 22px", marginTop: 16 }}>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.amber, marginBottom: 8 }}>Alternative Path</div>
                <p style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, lineHeight: 1.6, margin: 0 }}>{roadmap.altPath}</p>
              </div>
            </div>

            {/* Sidebar */}
            <div style={{ width: 260, flexShrink: 0 }}>
              <div style={{ position: "sticky", top: 88, display: "flex", flexDirection: "column" as const, gap: 14 }}>
                {/* Country guide */}
                <div style={{ background: brand.charcoal, borderRadius: 18, padding: "18px" }}>
                  <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff", marginBottom: 6 }}>Full Country Guide</div>
                  <div style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.55)", marginBottom: 14, lineHeight: 1.5 }}>{roadmap.resolvedCountry} — detailed licensing steps, costs, exams, documents, and recognition status.</div>
                  <button onClick={() => nav(`/career/${roadmap.countrySlug}`)} style={{ width: "100%", fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "10px", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 6 }}>
                    <MapPin size={13} /> {roadmap.resolvedCountry} Guide <ArrowRight size={12} />
                  </button>
                </div>

                {/* Masters recommendations */}
                {roadmap.mastersRecs.length > 0 && (
                  <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "18px" }}>
                    <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal, marginBottom: 4 }}>Recommended Masters Programs</div>
                    <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginBottom: 14 }}>Matched to your specialty & country</div>
                    {roadmap.mastersRecs.map(rec => (
                      <div key={rec.id} style={{ background: brand.offWhite, borderRadius: 10, padding: "12px", marginBottom: 8, cursor: "pointer" }} onClick={() => nav(`/masters/${rec.id}`)}>
                        <div style={{ display: "flex", gap: 8, alignItems: "flex-start" }}>
                          <span style={{ fontSize: 18 }}>{rec.flag}</span>
                          <div>
                            <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.charcoal }}>{rec.name}</div>
                            <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.orange, marginBottom: 4 }}>{rec.specialty}</div>
                            <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, lineHeight: 1.45 }}>{rec.why}</div>
                          </div>
                        </div>
                        <button onClick={(e) => { e.stopPropagation(); nav(`/masters/${rec.id}`); }} style={{ marginTop: 8, width: "100%", fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: brand.orange, background: `${brand.orange}08`, border: "none", borderRadius: 7, padding: "6px", cursor: "pointer" }}>
                          View Program →
                        </button>
                      </div>
                    ))}
                    <button onClick={() => nav("/masters")} style={{ width: "100%", fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal, background: brand.offWhite, border: `1px solid ${brand.borderGray}`, borderRadius: 8, padding: "8px", cursor: "pointer", marginTop: 4 }}>
                      Browse All 200+ Programs
                    </button>
                  </div>
                )}

                {/* Expert support */}
                <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "18px" }}>
                  <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal, marginBottom: 12 }}>Expert Support</div>
                  {[
                    { icon: <Users size={14} color={brand.orange} />, label: `Career Mentor — ${roadmap.resolvedCountry}`, desc: "Speak with an Egyptian dentist who's completed this pathway", path: "/mentoring" },
                    { icon: <BookOpen size={14} color={brand.amber} />, label: "Exam Preparation", desc: "ORE, Prometric, ADC, NDEB question banks", path: "/exams" },
                    { icon: <Shield size={14} color={brand.red} />, label: "Career Consultant", desc: "Personalised 1:1 career planning session", path: "/consulting" },
                  ].map(r => (
                    <button key={r.label} onClick={() => nav(r.path)} style={{ display: "flex", gap: 10, width: "100%", background: brand.offWhite, border: "none", borderRadius: 10, padding: "10px 12px", cursor: "pointer", marginBottom: 6, textAlign: "left" as const }}>
                      <div style={{ width: 30, height: 30, borderRadius: 8, background: brand.white, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>{r.icon}</div>
                      <div>
                        <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: brand.charcoal }}>{r.label}</div>
                        <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, marginTop: 2, lineHeight: 1.4 }}>{r.desc}</div>
                      </div>
                    </button>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // ── Wizard form ─────────────────────────────────────────────────────────────
  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>
      {/* Hero */}
      <div style={{ background: `linear-gradient(135deg, ${brand.charcoal} 0%, #24201D 100%)`, padding: "56px 24px 48px", position: "relative", overflow: "hidden" }}>
        <div style={{ position: "absolute", inset: 0, background: "radial-gradient(ellipse at 70% 40%, rgba(255,107,26,0.08) 0%, transparent 55%)", pointerEvents: "none" }} />
        <div style={{ maxWidth: 720, margin: "0 auto", position: "relative", textAlign: "center" as const }}>
          <div style={{ display: "inline-flex", alignItems: "center", gap: 6, background: `${brand.orange}20`, border: `1px solid ${brand.orange}30`, borderRadius: 8, padding: "4px 14px", marginBottom: 14 }}>
            <Zap size={12} color={brand.orange} />
            <span style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 700, color: brand.orange, letterSpacing: "0.08em" }}>AI-POWERED</span>
          </div>
          <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(26px,4vw,40px)", color: "#fff", marginBottom: 12 }}>Your Personalised Career Roadmap</h1>
          <p style={{ fontFamily: "Inter", fontSize: 16, color: "rgba(255,255,255,0.6)", maxWidth: 480, margin: "0 auto" }}>
            Answer 3 quick steps and Ejadah AI builds a tailored, phase-by-phase plan — connecting your profile to the right Masters programs, licensing exams, and country pathways.
          </p>
        </div>
      </div>

      <div style={{ maxWidth: 720, margin: "0 auto", padding: "32px 24px" }}>
        <div style={{ background: brand.white, borderRadius: 24, border: `1px solid ${brand.borderGray}`, padding: "36px", boxShadow: "0 4px 24px rgba(27,27,27,0.06)" }}>

          {generating ? (
            <GeneratingAnimation stage={genStage} />
          ) : (
            <>
              <StepBar current={step} total={3} />

              {/* Step 1: Who are you? */}
              {step === 1 && (
                <div>
                  <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.charcoal, marginBottom: 6 }}>Who are you?</h2>
                  <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, marginBottom: 24 }}>Your current career stage shapes your entire roadmap.</p>

                  <ChipGroup label="I am currently a…" options={["Student (Years 1–4)", "Intern", "Fresh Graduate", "General Dentist (1–2 yr exp)", "General Dentist (3–5 yr exp)", "Specialist", "Master's Holder"]} value={profile.stage} onChange={(v) => setProfile(p => ({ ...p, stage: v }))} />

                  <ChipGroup label="My specialty focus" options={["General Dentistry", "Orthodontics", "Implantology", "Oral Surgery", "Periodontology", "Endodontics", "Prosthodontics", "Digital Dentistry", "Oral Pathology"]} value={profile.specialty} onChange={set("specialty")} />

                  <div style={{ display: "flex", gap: 12, marginTop: 8 }}>
                    {[
                      { label: "I hold a Masters degree", key: "hasMasters" as const, active: profile.hasMasters },
                      { label: "I hold an Arab Board", key: "hasArabBoard" as const, active: profile.hasArabBoard },
                    ].map(({ label, key, active }) => (
                      <button key={label} onClick={() => setProfile(p => ({ ...p, [key]: !active }))} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 12, color: active ? "#2D9B68" : brand.charcoal, background: active ? "rgba(45,155,104,0.08)" : brand.offWhite, border: `1.5px solid ${active ? "#2D9B68" : brand.borderGray}`, borderRadius: 10, padding: "8px 14px", cursor: "pointer" }}>
                        {active ? "✓ " : ""}{label}
                      </button>
                    ))}
                  </div>
                </div>
              )}

              {/* Step 2: Goal + Country */}
              {step === 2 && (
                <div>
                  <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.charcoal, marginBottom: 6 }}>What's your goal?</h2>
                  <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, marginBottom: 24 }}>Your goal determines which phases appear in your roadmap.</p>

                  <ChipGroup label="My primary goal" options={["Work abroad", "Postgraduate Masters", "Research Career", "Both — Work & Postgrad"]} value={profile.goal} onChange={set("goal")} />

                  <div style={{ marginBottom: 20 }}>
                    <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal, marginBottom: 10 }}>Target country</div>
                    <select value={profile.country} onChange={(e) => set("country")(e.target.value)} style={{ width: "100%", fontFamily: "Inter", fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "11px 14px", outline: "none" }}>
                      <option>Suggest best for me</option>
                      <optgroup label="Gulf (Fast Track 2–6 months)">
                        {["United Arab Emirates", "Saudi Arabia", "Qatar", "Kuwait", "Oman", "Bahrain"].map(c => <option key={c}>{c}</option>)}
                      </optgroup>
                      <optgroup label="Arab World">
                        <option>Jordan</option>
                      </optgroup>
                      <optgroup label="English-speaking (6–30 months)">
                        {["United Kingdom", "Ireland", "Australia", "Canada", "New Zealand", "Singapore", "Malaysia", "South Africa"].map(c => <option key={c}>{c}</option>)}
                      </optgroup>
                      <optgroup label="Europe — Language required (12–30 months)">
                        {["Germany", "France", "Netherlands", "Sweden", "Switzerland", "Norway", "Denmark"].map(c => <option key={c}>{c}</option>)}
                      </optgroup>
                      <optgroup label="Americas (24–48 months)">
                        {["United States"].map(c => <option key={c}>{c}</option>)}
                      </optgroup>
                    </select>
                  </div>

                  <ChipGroup label="My target timeline" options={["ASAP — within 12 months", "1–2 years", "2–3 years", "No rush — planning ahead"]} value={profile.timeline} onChange={set("timeline")} />
                </div>
              )}

              {/* Step 3: Resources */}
              {step === 3 && (
                <div>
                  <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.charcoal, marginBottom: 6 }}>Your resources & situation</h2>
                  <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, marginBottom: 24 }}>This helps calibrate your roadmap to what's actually achievable for you.</p>

                  <ChipGroup label="Budget for the full pathway" options={["Limited (< €10k)", "Standard (€10–30k)", "Premium (€30k+)"]} value={profile.budget} onChange={set("budget")} />

                  <ChipGroup label="Current English level" options={["Not started", "Basic", "Upper Intermediate", "IELTS < 7.0", "IELTS 7.0+ or OET B"]} value={profile.englishLevel} onChange={set("englishLevel")} />

                  <ChipGroup label="Other languages you speak" options={["French", "German", "Spanish", "Italian", "None"]} multi multiValue={profile.languages} onMultiChange={set("languages")} />
                </div>
              )}

              {/* Navigation */}
              <div style={{ display: "flex", gap: 12, marginTop: 32 }}>
                {step > 1 && (
                  <button onClick={() => setStep(s => s - 1)} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.charcoal, background: brand.offWhite, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "13px 20px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}>
                    <ArrowLeft size={15} /> Back
                  </button>
                )}
                {step < 3 ? (
                  <button onClick={() => setStep(s => s + 1)} style={{ flex: 1, fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "13px", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 8, boxShadow: "0 4px 16px rgba(255,107,26,0.3)" }}>
                    Continue <ArrowRight size={16} />
                  </button>
                ) : (
                  <button onClick={handleGenerate} style={{ flex: 1, fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "13px", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 8, boxShadow: "0 4px 20px rgba(255,107,26,0.4)" }}>
                    <Zap size={16} /> Generate My Personalised Roadmap
                  </button>
                )}
              </div>
            </>
          )}
        </div>

        {/* Sample profiles */}
        {!generating && !roadmap && (
          <div style={{ marginTop: 24 }}>
            <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, marginBottom: 12, textAlign: "center" as const }}>Try a sample profile</div>
            <div style={{ display: "flex", gap: 10, flexWrap: "wrap", justifyContent: "center" }}>
              {[
                { label: "🎓 Student → UK Masters", stage: "Student", specialty: "Orthodontics", goal: "Postgraduate Masters", country: "United Kingdom", timeline: "2–3 years", budget: "Standard (€10–30k)", englishLevel: "Upper Intermediate", languages: [], hasMasters: false, hasArabBoard: false },
                { label: "🏥 Fresh Grad → UAE Fast Track", stage: "Fresh Graduate", specialty: "General Dentistry", goal: "Work abroad", country: "United Arab Emirates", timeline: "ASAP — within 12 months", budget: "Limited (< €10k)", englishLevel: "Upper Intermediate", languages: [], hasMasters: false, hasArabBoard: false },
                { label: "💼 3yr Dentist → Australia", stage: "General Dentist (3–5 yr exp)", specialty: "Periodontology", goal: "Work abroad", country: "Australia", timeline: "2–3 years", budget: "Standard (€10–30k)", englishLevel: "IELTS < 7.0", languages: [], hasMasters: false, hasArabBoard: false },
                { label: "⭐ Specialist → Germany", stage: "Specialist", specialty: "Oral Surgery", goal: "Work abroad", country: "Germany", timeline: "2–3 years", budget: "Standard (€10–30k)", englishLevel: "IELTS 7.0+ or OET B", languages: ["German"], hasMasters: true, hasArabBoard: true },
              ].map(sample => (
                <button key={sample.label} onClick={() => { setProfile(sample); setTimeout(() => handleGenerate(), 100); }} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 13, color: brand.charcoal, background: brand.white, border: `1.5px solid ${brand.borderGray}`, borderRadius: 20, padding: "8px 18px", cursor: "pointer", transition: "all 0.15s" }}
                  onMouseEnter={e => { (e.currentTarget as HTMLElement).style.borderColor = brand.orange; }}
                  onMouseLeave={e => { (e.currentTarget as HTMLElement).style.borderColor = brand.borderGray; }}>
                  {sample.label}
                </button>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
