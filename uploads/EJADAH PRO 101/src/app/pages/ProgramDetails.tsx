import { useState } from "react";
import { useNavigate, useParams } from "react-router";
import {
  ChevronLeft, CheckCircle, Clock, DollarSign,
  Calendar, ExternalLink, Bookmark,
  Award, Users, FileText, AlertTriangle, MapPin,
  GraduationCap, Plane, Mail, Star, Microscope,
  TrendingUp, BookOpen, Shield, Zap, MessageCircle,
  ChevronDown, ChevronUp, Building,
} from "lucide-react";
import { brand, gradientFlow, GradientBadge } from "@/app/shared";

// ─── Program Data ─────────────────────────────────────────────────────────────
const kingsData = {
  id: "1",
  university: "King's College London",
  school: "Faculty of Dentistry, Oral & Craniofacial Sciences",
  country: "United Kingdom",
  city: "London",
  flag: "🇬🇧",
  specialty: "Endodontics",
  degree: "MSc Endodontology",
  duration: "1 year Full-Time / 2 years Part-Time",
  format: "Clinical + Academic",
  tuition: "£26,000/year",
  totalCostFT: "~£52,000 (tuition only, FT)",
  totalCostPT: "~£52,000 (tuition over 2 yrs, PT)",
  totalWithLiving: "~£78,000–£95,000 (all-in, FT)",
  livingCostLow: "£1,530/mo",
  livingCostHigh: "£2,220/mo",
  language: "English",
  ielts: "7.0 overall (min 6.5 each band)",
  oet: "Grade B in all four components",
  deadline: "January 31, 2026",
  daysToDeadline: Math.ceil((new Date("2026-01-31").getTime() - Date.now()) / 86400000),
  intake: "September 2026",
  classSize: "8–12 students per cohort",
  acceptanceRate: "~15%",
  casesRequired: "150 supervised clinical cases",
  thesisRequired: true,
  interviewRequired: true,
  qsRanking: 8,
  satisfactionScore: 4.7,
  recognizedEgypt: true,
  recognizedUAE: true,
  recognizedKSA: true,
  recognizedQatar: true,
  egyptianGovtFunding: false,
  website: "kcl.ac.uk/dentistry",
  contact: "dentaladmissions@kcl.ac.uk",
  phone: "+44 20 7848 3040",
  admissionsPortal: "https://www.kcl.ac.uk/study/postgraduate-taught/courses/endodontology-msc",

  overview: `The MSc in Endodontology at King's College London is one of Europe's most respected postgraduate endodontic programmes — delivered entirely at Guy's Hospital, one of the UK's oldest and most active dental teaching hospitals. The department handles over 4,000 complex referral cases per year, giving students direct exposure to a case volume and complexity that most specialist training programmes cannot match.

The programme blends intensive supervised clinical work with a rigorous academic curriculum, culminating in an original research dissertation. Students operate under the mentorship of GDC-registered Consultant Endodontists, all of whom hold active specialist practice alongside their academic roles — meaning the teaching is grounded in current real-world practice, not just theory.

King's is consistently ranked in the global top 10 for Dentistry (QS 2024: #8). The programme is designed explicitly for dentists aiming to become recognised endodontic specialists in the UK, Gulf, or their home country — with a track record of graduates securing positions in specialist referral practices, Gulf hospitals, and Egyptian academic institutions.`,

  highlights: [
    "4,000+ complex referral endodontic cases handled annually at Guy's Hospital — one of the highest volumes in Europe",
    "Operating microscopes (Zeiss OPMI, KAPS) in every clinical bay — microscope use is embedded, not optional",
    "CBCT scanning (Carestream CS9300) available on-site for all programme cases with supervised interpretation",
    "Cohort of 8–12 ensures every student gets direct consultant supervision — not lost in large groups",
    "King's BRC (Biomedical Research Centre) affiliation — access to lab research and collaborative publications",
    "Strong Egyptian alumni network: graduates currently practising in Cairo, Dubai, Riyadh, and Abu Dhabi",
    "GDC-registered supervisors hold active specialist lists — direct mentorship for post-MSc career planning",
  ],

  weekInTheLife: [
    { day: "Monday", schedule: "08:30 Clinical sessions at Guy's Endodontic Unit — 3–4 complex root canal cases under microscope supervision. Case notes and CBCT review with consultant." },
    { day: "Tuesday", schedule: "09:00 Academic seminar: journal club, guest lectures from GDC-listed specialists. Afternoon: case presentation preparation and dissertation research time." },
    { day: "Wednesday", schedule: "Library/research day. Supervised dissertation work, systematic review sessions, biostatistics tutorials. Online module for international students." },
    { day: "Thursday", schedule: "08:30 Clinical — endodontic surgery (apicectomy) cases, microsurgical technique practice, irrigation protocol practical. Peer case review 4pm." },
    { day: "Friday", schedule: "Self-directed study. Case write-up for portfolio, radiograph analysis, reading list. Optional research lab access. Many students use this day for part-time PT clinical work." },
  ],

  equipment: [
    { name: "Zeiss OPMI pico + KAPS 900", category: "Microscopy", desc: "Clinical-grade operating microscopes in every treatment bay — students perform all root canal treatment under magnification from day one." },
    { name: "Carestream CS9300 CBCT", category: "Imaging", desc: "Cone-beam CT scanner on site. Students take, interpret, and present CBCT for their own cases as part of clinical assessment." },
    { name: "VDW Gold Reciproc & RECIPROC Blue", category: "Instrumentation", desc: "Reciprocating single-file systems used for primary treatment. Students also trained on WaveOne, ProTaper Ultimate, and HyFlex EDM." },
    { name: "Satelec P5 Newtron XS Ultrasonic", category: "Microsurgery", desc: "Ultrasonic units for root-end preparation in endodontic surgery — microsurgical technique practiced on extracted teeth before clinical cases." },
    { name: "Dentsply Sirona Schick 33 Digital Sensors", category: "Radiography", desc: "All intraoral radiography is digital. Students trained in periapical paralleling, working length confirmation, and outcome radiographs." },
    { name: "ProRoot MTA + Biodentine", category: "Materials", desc: "Bioceramic sealer (AH Plus, BioRoot RCS) and repair material protocols. Students complete material handling practicals before patient use." },
  ],

  modules: [
    { title: "Endodontic Biology & Pathology", weeks: "Weeks 1–6", desc: "Pulpal and periapical disease — diagnosis, classification, microbiology, and histopathology of endodontic infections. Assessment: written MCQ examination.", credits: 15 },
    { title: "Advanced Root Canal Treatment", weeks: "Weeks 7–16", desc: "Rotary and reciprocating instrumentation, irrigation protocols, NaOCl concentration evidence base, obturation techniques, and magnification-assisted treatment. Heavily clinical.", credits: 20 },
    { title: "Endodontic Surgery", weeks: "Weeks 17–22", desc: "Apicectomy, root-end preparation and filling, microsurgical technique, guided bone regeneration adjacent to endodontic lesions. Pre-clinical phantom before patients.", credits: 15 },
    { title: "Dental Traumatology", weeks: "Weeks 23–26", desc: "Crown and root fractures, avulsion and replantation, luxation injuries — protocols based on current IADT guidelines. Case-based seminars.", credits: 10 },
    { title: "Regenerative Endodontics", weeks: "Weeks 27–32", desc: "Stem cell biology, revascularisation/revitalisation protocols, bioceramic materials, MTA applications in immature teeth.", credits: 10 },
    { title: "Digital Endodontics & CBCT", weeks: "Weeks 33–36", desc: "CBCT interpretation (CBCT-guided diagnosis, case selection criteria), 3D-printed endodontic guides, software-assisted treatment planning.", credits: 10 },
    { title: "Research Methods & Biostatistics", weeks: "Throughout Year 1", desc: "Study design, systematic reviews, meta-analysis, statistical analysis (SPSS/R), and preparation for MSc dissertation proposal.", credits: 10 },
    { title: "MSc Dissertation", weeks: "Year 1 (PT: Year 2)", desc: "Original research project, 15,000–20,000 words, supervised by a faculty member. Submitted and viva voce examined by an external examiner.", credits: 60 },
  ],

  assessment: [
    { type: "Clinical Portfolio", weight: "Pass/Fail gate", desc: "150 documented endodontic cases with pre/post radiographs, treatment notes, and outcome assessments. Must be signed off by supervising consultant." },
    { type: "Written Examinations", weight: "40%", desc: "2 written papers per year — MCQ and short-answer format. Covers all taught modules. Minimum 50% required in each." },
    { type: "Case Presentations", weight: "20%", desc: "Formal presentation of 3 complex cases to faculty panel — assessed on diagnosis, treatment planning, execution, and outcome analysis." },
    { type: "Seminar Participation", weight: "10%", desc: "Journal clubs, guest lecture Q&A, peer case review sessions — formative but tracked." },
    { type: "MSc Dissertation", weight: "30%", desc: "15,000–20,000 word original research thesis, viva voce examination with internal and external examiner." },
  ],

  requirements: [
    { item: "BDS or equivalent dental degree", detail: "Minimum upper second-class honours (2:1) equivalent from a recognised university. Lower second (2:2) may be considered with exceptional clinical experience.", mustHave: true },
    { item: "2+ years post-qualification clinical experience", detail: "Post-BDS clinical work in general practice or specialist referral setting. King's want to see that you handle complex cases — not just routine dentistry.", mustHave: true },
    { item: "IELTS 7.0 overall / OET Grade B", detail: "No individual band below 6.5 for IELTS. For OET: Grade B in all four components (Listening, Reading, Writing, Speaking). Results valid 2 years.", mustHave: true },
    { item: "Personal statement — 1,000 words", detail: "Your strongest document. Must include: why endodontics specifically, 2–3 clinical cases that shaped your decision, career goals (be specific about country/context), and why King's over other programmes.", mustHave: true },
    { item: "Portfolio of 20+ endodontic cases", detail: "Not just a list — each case needs pre/post radiographs, treatment summary, and outcome comment. Cases showing difficulty (calcified canals, retreatment, trauma) score higher than routine molars.", mustHave: true },
    { item: "2 references", detail: "At least one from a specialist clinician who has seen your endodontic work. Academic references alone are weak. A reference from a GDC-listed Endodontist carries significant weight.", mustHave: true },
    { item: "Online interview with programme team", detail: "30–45 minute interview with Programme Director + one other faculty member. Covers clinical reasoning, motivation, career goals, and a brief case discussion.", mustHave: true },
    { item: "Current dental registration", detail: "Must hold a valid dental licence in your country of practice at the time of application. GDC registration is not required at application stage.", mustHave: false },
  ],

  applicationGuide: {
    personalStatement: [
      "Open with a specific clinical case that crystallised your interest in endodontics — not a general statement about dentistry.",
      "Name the microscope work, complex retreatments, or traumatology cases you've handled — King's want to see you already think like a specialist.",
      "Be explicit about your career goal: 'I intend to return to Egypt and establish a specialist endodontic referral practice' is stronger than 'I want to help patients'.",
      "Address why you chose King's specifically: mention Guy's Hospital volume, the microscope-first approach, and a specific faculty member's research if relevant.",
      "End with how the MSc fits your 5-year plan — the panel wants to see strategic thinking.",
    ],
    casePortfolio: [
      "20 cases minimum — aim for 30+ if you have them. Quality over quantity after 25.",
      "Include at least 3 retreatment cases, 2 calcified canal cases, 1 trauma case, and 1 case requiring CBCT.",
      "Every case: pre-treatment radiograph, working length film, post-obturation film, and 6-month+ recall if available.",
      "Write a 3–4 line comment per case: chief complaint, diagnosis, challenge encountered, technique used, outcome.",
      "Present cases chronologically to show progression — your most recent cases should be your most technically confident.",
    ],
    interviewPrep: [
      { q: "Why endodontics, and why now?", tip: "Have a specific clinical turning point. Mention a case you couldn't resolve or that fascinated you — don't say 'I enjoy precision work' without a story behind it." },
      { q: "Walk me through a difficult case you've managed.", tip: "Prepare 2 cases thoroughly: one retreatment, one traumatology. Know your working lengths, instruments used, sealer, recall outcome. They will probe the detail." },
      { q: "What do you know about regenerative endodontics?", tip: "They want to see you read current literature. Mention a specific paper or trial — AAE position statement on regeneration is a minimum baseline." },
      { q: "Where do you see yourself 5 years after graduating?", tip: "Be honest and specific. 'Return to Egypt and set up an endodontic referral practice in Cairo, with Egyptian Syndicate specialist registration' is the right level of specificity." },
      { q: "Why King's over Sheffield or Birmingham?", tip: "Mention Guy's Hospital volume (4,000+ referral cases/year), the microscope-integrated approach, and the specific research strengths of the faculty if you've researched them." },
      { q: "What's your research interest for the dissertation?", tip: "Have 2–3 ideas prepared. Doesn't need to be refined — they want to see intellectual curiosity and awareness of current gaps in endodontic research." },
    ],
    rejectionReasons: [
      "Personal statement is generic — no clinical specificity, reads like it could be for any MSc programme",
      "Case portfolio has fewer than 20 cases, or cases are undocumented (no radiographs, no outcome data)",
      "Reference from general practitioner only — no specialist or academic endorsement of clinical skill",
      "IELTS below threshold — even 6.5 overall with a 6.0 in Speaking will disqualify the application",
      "Application submitted in the final week — references not received in time, portal incomplete",
      "No clear career narrative — 'I want to learn more' is not a plan. They want to know what you'll do with the degree",
    ],
  },

  applicationTimeline: [
    { date: "Sep–Oct 2025", label: "Prepare Documents", detail: "Write your personal statement (allow 3–4 drafts). Start building your case portfolio now — don't try to document 20 cases in a week.", status: "prep" },
    { date: "Oct–Nov 2025", label: "Request References", detail: "Contact both referees 6–8 weeks before the deadline. Give them your CV, personal statement draft, and a note on why you're applying.", status: "prep" },
    { date: "Nov 2025", label: "Applications Open", detail: "Portal opens on King's Admissions portal. Fill in all sections carefully — incomplete applications are not reviewed.", status: "open" },
    { date: "Jan 31, 2026", label: "Application Deadline", detail: "All documents and references must be submitted by 23:59 GMT. References submitted after this date are typically not accepted.", status: "deadline" },
    { date: "Feb–Mar 2026", label: "Shortlisting & Interview", detail: "Shortlisted candidates (typically ~50 from 300+ applications) invited to online interview via Teams or Zoom. 30–45 minutes.", status: "interview" },
    { date: "Apr–May 2026", label: "Offers Issued", detail: "Conditional or unconditional offers via King's applicant portal. Conditional offers typically require updated IELTS or final degree certificate.", status: "offer" },
    { date: "Jun 2026", label: "Accept & CAS", detail: "Accept your offer, pay £1,000 deposit to secure place. Receive CAS (Confirmation of Acceptance for Studies) number for visa application.", status: "accept" },
    { date: "Jul–Aug 2026", label: "Visa Application", detail: "Apply for UK Student Visa using CAS. Apply online — processing takes 3–4 weeks if biometrics done in Egypt (VFS Global centres in Cairo).", status: "visa" },
    { date: "Sep 2026", label: "Induction Week", detail: "Orientation at Guy's Hospital, clinical bay allocation, equipment familiarisation, supervisor introductions. Programme formally begins.", status: "start" },
  ],

  scholarships: [
    {
      name: "King's College London International Scholarship",
      value: "£5,000",
      type: "Tuition reduction",
      difficulty: "Auto-assessed",
      eligibility: "International students (non-UK) with a first-class or distinction equivalent in undergraduate degree. No separate application — assessed automatically at offer stage. ~30% of international offers receive this.",
      deadline: "Automatic — assessed when offer is made",
      renewable: false,
      url: "kcl.ac.uk/study/postgraduate/fees-and-funding",
      tip: "Ensure your transcript shows exact GPA/classification — 'good standing' is not enough for this scholarship to be assessed correctly.",
    },
    {
      name: "Faculty of Dentistry Dean's Excellence Award",
      value: "£3,000",
      type: "Tuition reduction",
      difficulty: "Competitive",
      eligibility: "Applicants with exceptional academic and clinical track record — assessed by interview panel. Maximum 2 awards per cohort of 8–12 students.",
      deadline: "Awarded at interview stage — no separate application",
      renewable: false,
      url: "kcl.ac.uk/dentistry/postgraduate",
      tip: "Your interview performance directly determines this award. Prepare your case portfolio and clinical CV to the highest standard.",
    },
    {
      name: "FGDP(UK) Endodontic Scholarship",
      value: "£3,000",
      type: "Cash award",
      difficulty: "Separate application",
      eligibility: "Associate or full members of the Faculty of General Dental Practitioners (UK). Requires separate application to FGDP including a 500-word research proposal.",
      deadline: "March 31 annually — apply after receiving your King's offer",
      renewable: false,
      url: "fgdp.org.uk/scholarships",
      tip: "Join FGDP as an overseas associate member (£90/year) before applying — membership is required for eligibility.",
    },
    {
      name: "Egyptian Cultural & Educational Bureau (ECEB)",
      value: "Full tuition + £1,100/mo stipend",
      type: "Egyptian government sponsorship",
      difficulty: "Very competitive",
      eligibility: "Egyptian nationals affiliated with an Egyptian university faculty (academic post required). Must submit a research plan and have institutional nomination. Typically takes 12–18 months from application to funding confirmation.",
      deadline: "Varies — check eceb.org.uk annually. Apply simultaneously with King's — conditional ECEB placement on a confirmed King's offer.",
      renewable: true,
      url: "eceb.org.uk",
      tip: "The ECEB scholarship requires you to be a teaching assistant (Mu'id) or above at an Egyptian dental faculty. If you're not currently in academia, this route is closed to you.",
    },
    {
      name: "Islamic Development Bank (IsDB) Merit Scholarship",
      value: "Full tuition + living allowance",
      type: "Multilateral government",
      difficulty: "Highly competitive",
      eligibility: "Citizens of IsDB member countries (Egypt, KSA, UAE, Jordan, etc.). Must be 35 or under at time of application. Requires institutional endorsement from your home country employer.",
      deadline: "January annually — must have a confirmed offer from King's before applying",
      renewable: true,
      url: "isdb.org/scholarships",
      tip: "Strong research background significantly improves IsDB chances. Published papers or conference presentations are a major differentiator.",
    },
  ],

  salaryReality: {
    uk: {
      title: "UK — as a Specialist Endodontist",
      range: "£80,000 – £150,000/year",
      note: "Private specialist referral practice. NHS endodontic specialist (hospital post): £55,000–£80,000. Most King's graduates enter private referral practice within 2–3 years of GDC listing.",
      timeline: "2–4 years after MSc (need CCT or CESR first)",
      tax: "After tax (~40% bracket): £48,000–£90,000 net",
    },
    gulf: {
      title: "Gulf — Endodontist (UAE/KSA)",
      range: "AED 30,000–55,000/month (UAE) · SAR 25,000–45,000/month (KSA)",
      note: "Tax-free. Most positions include housing allowance (AED 3,000–5,000/mo), flights home 2×/year, and health insurance. King's degree opens DHA/DOH Specialist category directly.",
      timeline: "Immediately after MSc — no further qualifying exam needed for specialist category",
      tax: "Tax-free",
    },
    egypt: {
      title: "Egypt — Endodontic Specialist Referral",
      range: "EGP 60,000–200,000/month (private specialist practice)",
      note: "Highly variable depending on location, reputation, and volume. King's MSc + UK experience commands a strong premium in Cairo's private sector. Syndicate specialist registration required.",
      timeline: "6–12 months after return (Syndicate registration process)",
      tax: "Income tax applies (Egyptian rates)",
    },
  },

  afterMSc: {
    gdcSpecialistList: {
      title: "GDC Specialist List — What the MSc Alone Does NOT Give You",
      content: "This is the most misunderstood aspect of UK specialist training. The King's MSc Endodontology is a postgraduate academic qualification — it does NOT by itself place you on the GDC Specialist List in Endodontics. To be listed, you must complete one of two pathways:",
      pathways: [
        {
          name: "Certificate of Completion of Specialist Training (CCST) via NHS Training Number",
          desc: "Apply for an NHS specialty training post in Endodontics (ST1–ST4). These are highly competitive — ~12 posts per year across the UK. The MSc significantly strengthens your application. Duration: 4 years. At the end, you are awarded a CCST and added to the GDC Specialist List.",
          effort: "4 years post-MSc",
          difficulty: "Very competitive — ~12 NHS posts nationally per year",
        },
        {
          name: "CESR (Certificate of Eligibility for Specialist Registration)",
          desc: "Portfolio route for those who completed specialist training outside the UK or in non-NHS settings. Submit comprehensive portfolio of 200+ complex cases, evidence of peer review, teaching, and research. Assessed by GDC Specialist Advisory Committee. King's MSc + Gulf/private specialist practice experience is a valid CESR pathway.",
          effort: "Portfolio compilation: 1–2 years. Assessment: 6–12 months",
          difficulty: "Demanding portfolio — many applicants need 2+ attempts",
        },
      ],
      gulfNote: "For Gulf practice: King's MSc is sufficient for DHA/DOH/SCHS Specialist category registration — no GDC listing required. This is why many King's graduates move to UAE or KSA directly after the MSc.",
    },
    careerPaths: [
      { icon: "🏥", title: "UK Specialist Referral Practice", desc: "After CCST or CESR — open or join an endodontic specialist referral practice. High earning potential. Requires GDC specialist listing.", timeline: "4–6 years post-MSc" },
      { icon: "🇦🇪", title: "Gulf Specialist Practice (Direct)", desc: "MSc alone qualifies for DHA/DOH/SCHS Specialist category. No waiting period. High tax-free salaries immediately after graduating.", timeline: "Immediately post-MSc" },
      { icon: "🇪🇬", title: "Egyptian Syndicate Specialist", desc: "Submit degree + Apostille + GDC Good Standing to Egyptian Medical Syndicate. Processing 6–12 months. Enables specialist-only referral practice in Egypt.", timeline: "6–12 months after returning" },
      { icon: "🎓", title: "Academic / Lecturer Route", desc: "MSc + dissertation opens doors to PhD applications or dental school lectureship at Egyptian universities. Strong research profile essential.", timeline: "Concurrent or post-MSc" },
      { icon: "🔬", title: "PhD / Research Career", desc: "King's dissertation can be the foundation of a funded PhD. Several MSc graduates have continued to King's or UCL PhD programmes in endodontic biology.", timeline: "1–2 years post-MSc" },
    ],
  },

  egyptSyndicateProcess: [
    { step: "1", title: "Obtain Apostille on King's Degree Certificate", desc: "Send original MSc certificate to FCDO (Foreign, Commonwealth & Development Office) in the UK. Cost: £30. Processing: 2–3 days via registered post. Apostille confirms the document is genuine for use abroad." },
    { step: "2", title: "Obtain GDC Certificate of Good Standing", desc: "Apply to the General Dental Council for a Certificate of Good Standing — confirms you were registered and had no fitness to practise proceedings. Cost: £75. Processing: 5–10 working days." },
    { step: "3", title: "Certified Arabic Translation", desc: "Have your MSc certificate and transcripts officially translated into Arabic by a certified translator (must be Egyptian Ministry of Justice certified). Cost: £150–300. Available through Egyptian consulate in London." },
    { step: "4", title: "Submit to Egyptian Syndicate", desc: "Submit all documents (Apostilled degree, Arabic translation, Good Standing, original Egyptian BDS, passport) to the Egyptian Dental Syndicate (Niqabat Al-Asnan) in Cairo. In-person submission required or via authorised representative." },
    { step: "5", title: "Syndicate Review & Specialist Registration", desc: "Syndicate reviews the qualification — King's (QS top 10 Dentistry) is well-known and accepted. Processing: 3–6 months. Upon approval, you are issued a Specialist Certificate in Endodontics." },
    { step: "6", title: "Ministry of Health Notification", desc: "After Syndicate specialist registration, notify the Ministry of Health (if working in a government or university-affiliated setting). Private practice does not require MoH registration." },
  ],

  recognition: {
    egypt: { recognised: true, body: "Egyptian Dental Syndicate (Niqabat Al-Asnan)", note: "MSc from QS top-10 Dentistry institutions are well established in Egyptian Syndicate practice. King's is highly regarded. Expect 3–6 months processing. You will be registered as a Specialist in Endodontics." },
    uae: { recognised: true, body: "Dubai Health Authority (DHA) / Dept. of Health Abu Dhabi (DOH)", note: "King's MSc Endodontology is on the DHA/DOH specialist approved qualification list. Apply for Specialist license (not General Dentist) — higher base salary bracket (AED 30,000–55,000/month)." },
    ksa: { recognised: true, body: "Saudi Commission for Health Specialties (SCHS)", note: "King's graduates typically receive SCHS Grade 10–11 Specialist classification. DataFlow verification + SCHS exam required but specialist track is significantly faster than standard dentist pathway." },
    qatar: { recognised: true, body: "Qatar Council for Healthcare Practitioners (QCHP)", note: "Recognised for QCHP Specialist license in Endodontics. DataFlow verification + QCHP assessment, but specialist category bypasses standard Prometric exam route." },
  },

  livingCosts: [
    { item: "Accommodation — Zone 2/3 shared flat", range: "£900–£1,400/mo" },
    { item: "Accommodation — Zone 1/2 (near Guy's)", range: "£1,200–£1,800/mo" },
    { item: "Food & groceries", range: "£250–£400/mo" },
    { item: "Transport (Zone 1–3 Travelcard)", range: "£165–£200/mo" },
    { item: "Utilities (incl. in most HMOs)", range: "£0–£120/mo" },
    { item: "Mobile phone (SIM-only)", range: "£10–£25/mo" },
    { item: "Social / miscellaneous", range: "£150–£300/mo" },
    { item: "Total estimate", range: "£1,530–£2,220/mo" },
  ],

  neighbourhoods: [
    { name: "Bermondsey / Borough", commute: "5–10 min walk to Guy's", rent: "£1,100–£1,500/mo (shared)", vibe: "Closest to Guy's Hospital. Trendy food market, good cafes. Best for FT students wanting zero commute stress." },
    { name: "Elephant & Castle", commute: "10 min walk or 5 min bus", rent: "£900–£1,200/mo (shared)", vibe: "More affordable, rapidly improving area. Direct Northern Line to Euston/King's Cross. Popular with international students." },
    { name: "Peckham / Nunhead", commute: "20 min bus or 15 min overground", rent: "£800–£1,100/mo (shared)", vibe: "Best value in inner SE London. Vibrant food scene, large African-Arabic community. Many Egyptian students choose this area." },
    { name: "London Bridge / Southwark", commute: "8–12 min walk", rent: "£1,300–£1,900/mo (shared)", vibe: "Premium location with excellent transport links. More expensive but maximum convenience — walk to Guy's, walk to City." },
    { name: "New Cross / Deptford", commute: "20 min bus or overground", rent: "£750–£1,000/mo (shared)", vibe: "Budget-friendly, large student population (Goldsmiths University nearby). 3 stops on overground to London Bridge." },
  ],

  practicalSetup: [
    { title: "Bank Account", detail: "Open a Monzo or Starling account online before arriving — they accept Egyptian passport holders with a CAS letter as proof of address. Avoid waiting weeks for a traditional bank account." },
    { title: "SIM Card", detail: "Three UK or giffgaff offer the best value unlimited data plans (£15–25/mo). Pick up a SIM at Heathrow or any supermarket on arrival." },
    { title: "NHS Registration", detail: "Register with a GP surgery near your accommodation on arrival. As a student, you are entitled to free NHS primary care. Ask King's student services for a nearby surgery recommendation." },
    { title: "BRP (Biometric Residence Permit)", detail: "Collect your BRP from the Post Office branch listed in your visa approval letter — usually within 10 days of arriving. You need it for banking and many admin processes." },
    { title: "Egypt Consulate Registration", detail: "Register with the Egyptian Consulate in London (2 Lowndes St, Knightsbridge). Essential for passport renewal, notarisation, and emergency assistance. Takes 30 minutes." },
    { title: "Council Tax Exemption", detail: "Full-time students are fully exempt from Council Tax. Request a Council Tax exemption certificate from King's Student Records and submit to your local council (Southwark Borough)." },
  ],

  visaInfo: {
    type: "UK Student Visa (formerly Tier 4)",
    processingTime: "3–4 weeks (online/VFS Global in Cairo)",
    fee: "£490 visa fee + £776/year Immigration Health Surcharge",
    ihs: "£776 × 1 year = £776 (FT) or £776 × 2 = £1,552 (PT) — paid upfront at application",
    biometric: "VFS Global centres in Cairo (Heliopolis) or Alexandria. Book 4–6 weeks in advance.",
    financialProof: "Must show ability to cover first year tuition (£26,000) + 9 months London living (£13,050) = at least £39,050 in a bank account, held for 28 consecutive days before application.",
    notes: "You receive your CAS number from King's after accepting the offer and paying the £1,000 deposit. Apply for the visa no earlier than 6 months before your programme start date.",
    egVFSLocations: "Cairo: VFS Global Maadi (11 Road 253, Digla). Alexandria: VFS Global Smouha. Both require appointment booking online. Appointment slots book up fast in June–August.",
  },

  faqs: [
    { q: "Can I do the part-time route while based outside the UK?", a: "No. Both full-time and part-time students must be physically present at Guy's Hospital for all clinical sessions. Part-time students attend 3 days/week versus 5 days/week for full-time. You must be based in London for the full 2-year duration of the part-time route." },
    { q: "Does the MSc alone get me on the GDC Specialist List in Endodontics?", a: "No — and this is the most common misconception. The King's MSc is an academic qualification. To be listed on the GDC Specialist Register, you must complete a CCST (via an NHS training post, 4 years) or CESR (portfolio route). However, for Gulf countries, the MSc alone qualifies for Specialist licensing — no GDC listing required." },
    { q: "Can the Egyptian government scholarship (ECEB) cover this degree?", a: "Yes — the ECEB scholarship covers King's programmes for Egyptian academics who hold a faculty position (Mu'id or above) at an Egyptian university. You need a research plan, institutional nomination, and a confirmed offer from King's. The process takes 12–18 months so apply for both simultaneously." },
    { q: "What is the exact Egyptian Syndicate process after returning?", a: "6 steps: (1) Apostille on King's MSc certificate via FCDO UK. (2) GDC Certificate of Good Standing. (3) Certified Arabic translation of degree and transcript. (4) Submit package to Egyptian Dental Syndicate in Cairo. (5) Syndicate review — 3–6 months. (6) Specialist Certificate issued in Endodontics. You can then practise as a specialist referral dentist and set your own fees." },
    { q: "What IELTS score do I actually need — is 6.5 overall accepted?", a: "No. King's requires 7.0 overall with no individual band below 6.5. A 6.5 overall score will disqualify your application. If your speaking is 6.5 but overall is 7.0, the application is technically valid — but aim for 7.0 in all bands. OET Grade B in all four components is the alternative." },
    { q: "How competitive is the application really?", a: "Approximately 300+ applications for 8–12 places — a roughly 3–4% offer rate. However, King's shortlist for interview approximately 50 candidates, so reaching interview means you're in the top 17%. Strong personal statement, specific case portfolio, and good references are the real differentiators. Generic applications are rejected at the first sift." },
    { q: "Can I work part-time during the full-time programme?", a: "UK Student Visa allows up to 20 hours of work per week during term time. However, the FT clinical schedule at Guy's is demanding — most FT students find it very difficult to work more than a few hours tutoring or research assistance. PT students have more flexibility but must still meet 3 clinical days/week." },
    { q: "What if I'm rejected — can I reapply next year?", a: "Yes. Many successful applicants applied 2–3 times. If you receive feedback from the panel (ask for it if not offered), address the specific gaps — typically: strengthen your case portfolio, improve IELTS, or get a specialist reference. Applying with a stronger portfolio the following year is a viable strategy." },
  ],

  alumniNotes: [
    { name: "Dr. Amr F.", year: "2021", location: "Dubai, UAE", now: "Endodontist — private specialist practice, Dubai Healthcare City", note: "The microscope training at Guy's is the real differentiator. I use a KAPS microscope on every case now. DHA Specialist license was straightforward with King's MSc — DataFlow verification took 6 weeks, license in hand within 3 months of returning." },
    { name: "Dr. Nour H.", year: "2019", location: "Cairo, Egypt", now: "Specialist Endodontist + Lecturer, Cairo University", note: "The Syndicate took 5 months to process my specialist registration. I used that time to set up my referral practice contacts. ECEB fully funded my MSc — the key was having my university nomination done 8 months before the deadline." },
    { name: "Dr. Karim S.", year: "2022", location: "Riyadh, KSA", now: "Endodontic Specialist, Saudi German Hospital Group", note: "SCHS gave me Grade 10 Specialist classification immediately on the King's certificate. Salary is SAR 38,000/month with housing. The referral volume in Riyadh is comparable to Guy's — I do 3–4 complex cases daily." },
  ],
};

// ─── Sub-components ───────────────────────────────────────────────────────────
function InfoCard({ children, style = {} }: { children: React.ReactNode; style?: React.CSSProperties }) {
  return (
    <div style={{ background: brand.white, borderRadius: 20, border: `1px solid ${brand.borderGray}`, padding: "24px 26px", ...style }}>
      {children}
    </div>
  );
}

function SectionTitle({ children }: { children: React.ReactNode }) {
  return <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 20, color: brand.charcoal, marginBottom: 16, marginTop: 0 }}>{children}</h2>;
}

function Pill({ children, color = brand.orange }: { children: React.ReactNode; color?: string }) {
  return <span style={{ fontFamily: "Inter", fontSize: 10, fontWeight: 700, color, background: `${color}12`, borderRadius: 5, padding: "2px 8px" }}>{children}</span>;
}

function FAQItem({ faq }: { faq: { q: string; a: string } }) {
  const [open, setOpen] = useState(false);
  return (
    <div style={{ background: brand.white, borderRadius: 16, border: `1px solid ${brand.borderGray}`, overflow: "hidden" }}>
      <button onClick={() => setOpen(!open)} style={{ width: "100%", display: "flex", justifyContent: "space-between", alignItems: "flex-start", gap: 12, padding: "18px 20px", background: "none", border: "none", cursor: "pointer", textAlign: "left" as const }}>
        <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.charcoal, lineHeight: 1.45, flex: 1 }}>{faq.q}</span>
        {open ? <ChevronUp size={16} color={brand.orange} style={{ flexShrink: 0, marginTop: 2 }} /> : <ChevronDown size={16} color={brand.warmGray} style={{ flexShrink: 0, marginTop: 2 }} />}
      </button>
      {open && (
        <div style={{ padding: "0 20px 18px", fontFamily: "Inter", fontSize: 13, color: brand.warmGray, lineHeight: 1.75, borderTop: `1px solid ${brand.borderGray}`, paddingTop: 14, marginTop: 0 }}>
          {faq.a}
        </div>
      )}
    </div>
  );
}

type TabType = "overview" | "curriculum" | "requirements" | "application" | "scholarships" | "after" | "recognition" | "living" | "faqs";

// ─── Main Component ───────────────────────────────────────────────────────────
export default function ProgramDetails() {
  const { id } = useParams();
  const nav = useNavigate();
  const [saved, setSaved] = useState(false);
  const [activeTab, setActiveTab] = useState<TabType>("overview");

  if (id !== "1") {
    return (
      <div style={{ background: brand.offWhite, minHeight: "100vh", display: "flex", flexDirection: "column" as const, alignItems: "center", justifyContent: "center", padding: "60px 24px", textAlign: "center" as const }}>
        <GraduationCap size={48} color={brand.borderGray} style={{ marginBottom: 20 }} />
        <h2 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 26, color: brand.charcoal, marginBottom: 10 }}>Full Profile Coming Soon</h2>
        <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.warmGray, maxWidth: 440, lineHeight: 1.7, marginBottom: 28 }}>
          We're building comprehensive profiles for every program. King's College London MSc Endodontology is our flagship entry — explore it to see what's coming for every program.
        </p>
        <div style={{ display: "flex", gap: 12, flexWrap: "wrap", justifyContent: "center" }}>
          <button onClick={() => nav("/masters/1")} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "12px 24px", cursor: "pointer" }}>
            View King's Full Profile
          </button>
          <button onClick={() => nav("/masters")} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 14, color: brand.charcoal, background: brand.white, border: `1.5px solid ${brand.borderGray}`, borderRadius: 12, padding: "12px 20px", cursor: "pointer" }}>
            Back to Database
          </button>
        </div>
      </div>
    );
  }

  const prog = kingsData;
  const urgent = prog.daysToDeadline > 0 && prog.daysToDeadline < 60;

  const tabs: { key: TabType; label: string; icon: string }[] = [
    { key: "overview", label: "Overview", icon: "🏛" },
    { key: "curriculum", label: "Curriculum", icon: "📚" },
    { key: "requirements", label: "Requirements", icon: "✅" },
    { key: "application", label: "Application Guide", icon: "📝" },
    { key: "scholarships", label: "Scholarships", icon: "🎓" },
    { key: "after", label: "After the MSc", icon: "🚀" },
    { key: "recognition", label: "Recognition", icon: "🛡" },
    { key: "living", label: "Living & Visa", icon: "🏠" },
    { key: "faqs", label: "FAQs", icon: "💬" },
  ];

  return (
    <div style={{ background: brand.offWhite, minHeight: "100vh" }}>

      {/* ── Hero ── */}
      <div style={{ background: `linear-gradient(135deg, ${brand.deepCharcoal} 0%, #1E1B17 100%)`, padding: "40px 24px 0", position: "relative", overflow: "hidden" }}>
        <div style={{ position: "absolute", inset: 0, background: "radial-gradient(ellipse at 75% 20%, rgba(255,198,46,0.07) 0%, transparent 55%)", pointerEvents: "none" }} />
        <div style={{ position: "absolute", bottom: -60, left: -60, width: 320, height: 320, borderRadius: "50%", background: "radial-gradient(circle, rgba(255,107,26,0.07) 0%, transparent 70%)", pointerEvents: "none" }} />

        <div style={{ maxWidth: 1200, margin: "0 auto", position: "relative" }}>
          <button onClick={() => nav("/masters")} style={{ background: "none", border: "none", cursor: "pointer", color: "rgba(255,255,255,0.45)", fontFamily: "Inter", fontSize: 13, display: "flex", alignItems: "center", gap: 5, marginBottom: 22 }}>
            <ChevronLeft size={14} /> Master's Database
          </button>

          {urgent && (
            <div style={{ display: "inline-flex", gap: 7, alignItems: "center", background: `${brand.red}18`, border: `1px solid ${brand.red}30`, borderRadius: 8, padding: "6px 14px", marginBottom: 18 }}>
              <span style={{ width: 6, height: 6, borderRadius: "50%", background: brand.red, display: "inline-block" }} />
              <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.red }}>DEADLINE IN {prog.daysToDeadline} DAYS — January 31, 2026</span>
            </div>
          )}

          <div style={{ display: "flex", gap: 36, alignItems: "flex-start", flexWrap: "wrap", paddingBottom: 36 }}>
            {/* Left: identity + headline */}
            <div style={{ flex: 1, minWidth: 300 }}>
              <div style={{ display: "flex", gap: 14, alignItems: "center", marginBottom: 16 }}>
                <div style={{ width: 52, height: 52, borderRadius: 14, background: "rgba(255,255,255,0.08)", border: "1px solid rgba(255,255,255,0.12)", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 28, flexShrink: 0 }}>
                  {prog.flag}
                </div>
                <div>
                  <div style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.38)", marginBottom: 2 }}>Guy's Hospital · London, UK</div>
                  <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: "#fff", lineHeight: 1.2 }}>{prog.university}</div>
                  <div style={{ fontFamily: "Inter", fontSize: 11, color: "rgba(255,255,255,0.38)", marginTop: 1 }}>{prog.school}</div>
                </div>
              </div>

              <h1 style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: "clamp(24px,3.5vw,36px)", color: "#fff", lineHeight: 1.15, marginBottom: 16, maxWidth: 560 }}>
                {prog.degree}
              </h1>

              {/* Badge row */}
              <div style={{ display: "flex", gap: 7, flexWrap: "wrap", marginBottom: 20 }}>
                <GradientBadge small>{prog.specialty}</GradientBadge>
                <span style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 700, color: brand.gold, background: `${brand.gold}18`, borderRadius: 6, padding: "3px 9px" }}>#{prog.qsRanking} QS World Dentistry</span>
                <span style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 700, color: "#2D9B68", background: "rgba(45,155,104,0.14)", borderRadius: 6, padding: "3px 9px" }}>🇪🇬 Recognised Egypt</span>
                <span style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 700, color: "#2D9B68", background: "rgba(45,155,104,0.14)", borderRadius: 6, padding: "3px 9px" }}>🇦🇪 🇸🇦 🇶🇦 Gulf Specialist</span>
                <span style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 700, color: brand.amber, background: `${brand.amber}18`, borderRadius: 6, padding: "3px 9px" }}>🎓 5 Scholarships</span>
                <span style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 700, color: brand.orange, background: `${brand.orange}12`, borderRadius: 6, padding: "3px 9px" }}>🔬 Microscope Every Session</span>
              </div>

              {/* Stat row */}
              <div style={{ display: "flex", gap: 24, flexWrap: "wrap" }}>
                {[
                  ["£26,000/yr", "Tuition"],
                  [prog.duration.split(" / ")[0], "Full-time"],
                  [prog.acceptanceRate, "Acceptance rate"],
                  [prog.classSize.split(" ")[0] + " students", "Cohort size"],
                  ["Sep 2026", "Next intake"],
                ].map(([val, label]) => (
                  <div key={label}>
                    <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 17, color: "#fff" }}>{val}</div>
                    <div style={{ fontFamily: "Inter", fontSize: 10, color: "rgba(255,255,255,0.38)", marginTop: 2 }}>{label}</div>
                  </div>
                ))}
              </div>
            </div>

            {/* Right: actions */}
            <div style={{ display: "flex", flexDirection: "column" as const, gap: 10, minWidth: 210, paddingTop: 4 }}>
              <a href={prog.admissionsPortal} target="_blank" rel="noreferrer" style={{ textDecoration: "none", fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: gradientFlow, border: "none", borderRadius: 12, padding: "14px 20px", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 7, boxShadow: "0 4px 20px rgba(255,107,26,0.4)" }}>
                Apply on King's Website <ExternalLink size={14} />
              </a>
              <button onClick={() => setSaved(!saved)} style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: saved ? brand.amber : "rgba(255,255,255,0.7)", background: "rgba(255,255,255,0.07)", border: `1.5px solid ${saved ? brand.amber : "rgba(255,255,255,0.15)"}`, borderRadius: 12, padding: "13px 20px", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 7 }}>
                <Bookmark size={14} fill={saved ? brand.amber : "none"} /> {saved ? "Saved" : "Save Program"}
              </button>
              <button onClick={() => nav("/consulting")} style={{ fontFamily: "Inter", fontWeight: 500, fontSize: 13, color: "rgba(255,255,255,0.45)", background: "rgba(255,255,255,0.04)", border: "1px solid rgba(255,255,255,0.1)", borderRadius: 10, padding: "11px", cursor: "pointer" }}>
                Get Application Help →
              </button>
              <div style={{ background: "rgba(255,255,255,0.04)", border: "1px solid rgba(255,255,255,0.08)", borderRadius: 10, padding: "12px 14px" }}>
                <div style={{ fontFamily: "Inter", fontSize: 10, color: "rgba(255,255,255,0.35)", marginBottom: 5 }}>UNIVERSITY CONTACT</div>
                <a href={`mailto:${prog.contact}`} style={{ fontFamily: "Inter", fontSize: 11, color: brand.amber, textDecoration: "none", display: "flex", alignItems: "center", gap: 5 }}>
                  <Mail size={11} /> {prog.contact}
                </a>
                <div style={{ fontFamily: "Inter", fontSize: 11, color: "rgba(255,255,255,0.35)", marginTop: 5 }}>{prog.phone}</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* ── Satisfaction sub-bar ── */}
      <div style={{ background: brand.deepCharcoal, borderBottom: "1px solid rgba(255,255,255,0.06)" }}>
        <div style={{ maxWidth: 1200, margin: "0 auto", padding: "10px 24px", display: "flex", gap: 24, flexWrap: "wrap", alignItems: "center" }}>
          <div style={{ display: "flex", gap: 3, alignItems: "center" }}>
            {[1,2,3,4,5].map((i) => <Star key={i} size={12} fill={i <= Math.round(prog.satisfactionScore) ? brand.amber : "none"} color={brand.amber} />)}
            <span style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.5)", marginLeft: 6 }}>{prog.satisfactionScore} / 5 satisfaction</span>
          </div>
          {[
            `Acceptance: ${prog.acceptanceRate}`,
            `${prog.casesRequired}`,
            `Thesis + viva required`,
            `Interview: online 30–45 min`,
            `4,000+ referral cases/year at Guy's`,
          ].map((item) => (
            <span key={item} style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.4)", display: "flex", alignItems: "center", gap: 6 }}>
              <span style={{ color: "rgba(255,255,255,0.15)" }}>·</span> {item}
            </span>
          ))}
        </div>
      </div>

      {/* ── Tab bar ── */}
      <div style={{ background: brand.white, borderBottom: `2px solid ${brand.borderGray}`, position: "sticky", top: 64, zIndex: 100 }}>
        <div style={{ maxWidth: 1200, margin: "0 auto", padding: "0 24px", display: "flex", overflowX: "auto" as const }}>
          {tabs.map((tab) => (
            <button key={tab.key} onClick={() => setActiveTab(tab.key)}
              style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: activeTab === tab.key ? brand.orange : brand.warmGray, background: "none", border: "none", borderBottom: `2px solid ${activeTab === tab.key ? brand.orange : "transparent"}`, marginBottom: -2, padding: "13px 16px", cursor: "pointer", whiteSpace: "nowrap" as const, transition: "color 0.15s", display: "flex", alignItems: "center", gap: 5 }}>
              <span style={{ fontSize: 12 }}>{tab.icon}</span> {tab.label}
            </button>
          ))}
        </div>
      </div>

      {/* ── Body ── */}
      <div style={{ maxWidth: 1200, margin: "0 auto", padding: "28px 24px 60px", display: "flex", gap: 28, flexWrap: "wrap", alignItems: "flex-start" }}>
        <div style={{ flex: 1, minWidth: 300, display: "flex", flexDirection: "column" as const, gap: 18 }}>

          {/* ────────── OVERVIEW ────────── */}
          {activeTab === "overview" && (<>
            <InfoCard>
              <SectionTitle>About the Programme</SectionTitle>
              {prog.overview.split("\n\n").map((para, i) => (
                <p key={i} style={{ fontFamily: "Inter", fontSize: 14, color: brand.charcoal, lineHeight: 1.85, marginBottom: 12 }}>{para.trim()}</p>
              ))}
            </InfoCard>

            <InfoCard>
              <SectionTitle>Why King's — The Real Differentiators</SectionTitle>
              <div style={{ display: "flex", flexDirection: "column" as const, gap: 10 }}>
                {prog.highlights.map((h) => (
                  <div key={h} style={{ display: "flex", gap: 10, alignItems: "flex-start", padding: "10px 12px", background: brand.offWhite, borderRadius: 10 }}>
                    <CheckCircle size={15} color="#2D9B68" style={{ flexShrink: 0, marginTop: 1 }} />
                    <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, lineHeight: 1.55 }}>{h}</span>
                  </div>
                ))}
              </div>
            </InfoCard>

            {/* Equipment */}
            <InfoCard>
              <div style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 6 }}>
                <Microscope size={18} color={brand.orange} />
                <SectionTitle>Equipment You Will Use</SectionTitle>
              </div>
              <p style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, marginBottom: 18, lineHeight: 1.6 }}>You don't get to use this equipment after the MSc — you use it from week one. This is the practical training most Egyptian graduates never get at home.</p>
              <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(280px, 1fr))", gap: 12 }}>
                {prog.equipment.map((eq) => (
                  <div key={eq.name} style={{ background: brand.offWhite, borderRadius: 14, padding: "14px 16px", border: `1px solid ${brand.borderGray}` }}>
                    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 6 }}>
                      <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal }}>{eq.name}</div>
                      <Pill color={brand.orange}>{eq.category}</Pill>
                    </div>
                    <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, lineHeight: 1.55 }}>{eq.desc}</div>
                  </div>
                ))}
              </div>
            </InfoCard>

            {/* Week in the life */}
            <InfoCard>
              <SectionTitle>A Week in the Life — Full-Time Student</SectionTitle>
              <div style={{ display: "flex", flexDirection: "column" as const, gap: 2 }}>
                {prog.weekInTheLife.map((d, i) => (
                  <div key={d.day} style={{ display: "flex", gap: 14, padding: "13px 0", borderBottom: i < prog.weekInTheLife.length - 1 ? `1px solid ${brand.borderGray}` : "none" }}>
                    <div style={{ width: 90, flexShrink: 0, fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.orange }}>{d.day}</div>
                    <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, lineHeight: 1.6 }}>{d.schedule}</div>
                  </div>
                ))}
              </div>
            </InfoCard>

            {/* Application timeline */}
            <InfoCard>
              <SectionTitle>Application Timeline — September 2026 Intake</SectionTitle>
              <div style={{ position: "relative" }}>
                <div style={{ position: "absolute", left: 11, top: 0, bottom: 0, width: 2, background: brand.borderGray }} />
                {prog.applicationTimeline.map((step, i) => {
                  const statusColor = step.status === "deadline" ? brand.red : step.status === "open" ? "#2D9B68" : step.status === "start" ? brand.gold : brand.orange;
                  return (
                    <div key={i} style={{ display: "flex", gap: 16, alignItems: "flex-start", marginBottom: 22, position: "relative" }}>
                      <div style={{ width: 24, height: 24, borderRadius: "50%", background: step.status === "start" ? gradientFlow : brand.white, border: `2px solid ${statusColor}`, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0, zIndex: 1 }}>
                        <span style={{ fontFamily: "Inter", fontWeight: 800, fontSize: 9, color: step.status === "start" ? "#fff" : statusColor }}>{i + 1}</span>
                      </div>
                      <div style={{ flex: 1, paddingTop: 1 }}>
                        <div style={{ display: "flex", gap: 8, alignItems: "center", flexWrap: "wrap", marginBottom: 3 }}>
                          <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal }}>{step.label}</span>
                          <span style={{ fontFamily: "Inter", fontSize: 11, fontWeight: 700, color: statusColor, background: `${statusColor}12`, borderRadius: 5, padding: "1px 7px" }}>{step.date}</span>
                          {step.status === "deadline" && <span style={{ fontFamily: "Inter", fontSize: 10, fontWeight: 700, color: brand.red }}>⚠ HARD DEADLINE</span>}
                        </div>
                        <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, lineHeight: 1.55 }}>{step.detail}</div>
                      </div>
                    </div>
                  );
                })}
              </div>
            </InfoCard>

            {/* Alumni notes */}
            <InfoCard>
              <SectionTitle>Egyptian Alumni — Where Are They Now?</SectionTitle>
              <div style={{ display: "flex", flexDirection: "column" as const, gap: 14 }}>
                {prog.alumniNotes.map((a) => (
                  <div key={a.name} style={{ background: brand.offWhite, borderRadius: 14, padding: "16px 18px", border: `1px solid ${brand.borderGray}` }}>
                    <div style={{ display: "flex", gap: 10, alignItems: "flex-start", marginBottom: 8 }}>
                      <div style={{ width: 36, height: 36, borderRadius: "50%", background: gradientFlow, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                        <span style={{ fontFamily: "Inter", fontWeight: 800, fontSize: 12, color: "#fff" }}>{a.name.split(" ")[1][0]}</span>
                      </div>
                      <div>
                        <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal }}>{a.name} · Class of {a.year}</div>
                        <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.orange }}>{a.now}</div>
                        <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{a.location}</div>
                      </div>
                    </div>
                    <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, lineHeight: 1.65, fontStyle: "italic" }}>"{a.note}"</div>
                  </div>
                ))}
              </div>
            </InfoCard>
          </>)}

          {/* ────────── CURRICULUM ────────── */}
          {activeTab === "curriculum" && (<>
            <InfoCard>
              <SectionTitle>Modules & Teaching Schedule</SectionTitle>
              <p style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, marginBottom: 20, lineHeight: 1.65 }}>8 core modules across the programme. FT students complete all taught modules in Year 1, dissertation concurrent. PT students spread modules across 2 years with 3 clinical days/week.</p>
              <div style={{ display: "flex", flexDirection: "column" as const, gap: 12 }}>
                {prog.modules.map((m, i) => (
                  <div key={m.title} style={{ display: "flex", gap: 14, alignItems: "flex-start", background: brand.offWhite, borderRadius: 14, padding: "16px 18px" }}>
                    <div style={{ width: 34, height: 34, borderRadius: 10, background: i === prog.modules.length - 1 ? brand.charcoal : gradientFlow, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                      <span style={{ fontFamily: "Inter", fontWeight: 800, fontSize: 12, color: "#fff" }}>{i + 1}</span>
                    </div>
                    <div style={{ flex: 1 }}>
                      <div style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 5, flexWrap: "wrap" }}>
                        <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal }}>{m.title}</span>
                        <Pill color={brand.warmGray}>{m.weeks}</Pill>
                        <Pill color={brand.orange}>{m.credits} credits</Pill>
                      </div>
                      <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, lineHeight: 1.6 }}>{m.desc}</div>
                    </div>
                  </div>
                ))}
              </div>
            </InfoCard>

            <InfoCard>
              <SectionTitle>Assessment Breakdown</SectionTitle>
              <p style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, marginBottom: 18, lineHeight: 1.6 }}>Assessment is multi-modal — you are evaluated on clinical performance, written knowledge, case presentation, and research quality. There is no single final exam.</p>
              <div style={{ display: "flex", flexDirection: "column" as const, gap: 0 }}>
                {prog.assessment.map((a, i) => (
                  <div key={a.type} style={{ display: "flex", gap: 14, padding: "14px 0", borderBottom: i < prog.assessment.length - 1 ? `1px solid ${brand.borderGray}` : "none" }}>
                    <div style={{ width: 64, flexShrink: 0, fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 16, color: brand.orange }}>{a.weight}</div>
                    <div>
                      <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal, marginBottom: 3 }}>{a.type}</div>
                      <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, lineHeight: 1.55 }}>{a.desc}</div>
                    </div>
                  </div>
                ))}
              </div>
            </InfoCard>
          </>)}

          {/* ────────── REQUIREMENTS ────────── */}
          {activeTab === "requirements" && (<>
            <InfoCard>
              <SectionTitle>Admission Requirements</SectionTitle>
              <div style={{ display: "flex", flexDirection: "column" as const, gap: 0 }}>
                {prog.requirements.map((req, i) => (
                  <div key={i} style={{ display: "flex", gap: 14, alignItems: "flex-start", padding: "16px 0", borderBottom: `1px solid ${brand.borderGray}` }}>
                    <div style={{ width: 30, height: 30, borderRadius: "50%", background: req.mustHave ? gradientFlow : brand.paleGray, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0, marginTop: 1 }}>
                      <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 11, color: req.mustHave ? "#fff" : brand.warmGray }}>{i + 1}</span>
                    </div>
                    <div style={{ flex: 1 }}>
                      <div style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 4, flexWrap: "wrap" }}>
                        <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 14, color: brand.charcoal }}>{req.item}</span>
                        {req.mustHave && <Pill color={brand.red}>Mandatory</Pill>}
                      </div>
                      <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, lineHeight: 1.55 }}>{req.detail}</div>
                    </div>
                  </div>
                ))}
              </div>
            </InfoCard>
            <div style={{ background: `${brand.amber}08`, border: `1px solid ${brand.amber}28`, borderRadius: 16, padding: "16px 18px", display: "flex", gap: 10 }}>
              <AlertTriangle size={16} color={brand.amber} style={{ flexShrink: 0, marginTop: 1 }} />
              <div>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal, marginBottom: 3 }}>Requirements change annually — always verify</div>
                <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, lineHeight: 1.55 }}>Contact King's admissions directly before applying: <strong>{prog.contact}</strong></div>
              </div>
            </div>
          </>)}

          {/* ────────── APPLICATION GUIDE ────────── */}
          {activeTab === "application" && (<>
            <InfoCard>
              <div style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 16 }}>
                <FileText size={18} color={brand.orange} />
                <SectionTitle>Personal Statement — What King's Actually Wants</SectionTitle>
              </div>
              <p style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, marginBottom: 16, lineHeight: 1.65 }}>This is the document that gets you shortlisted for interview. Generic statements are rejected at the first sift. Here's what the admissions panel actually looks for:</p>
              <div style={{ display: "flex", flexDirection: "column" as const, gap: 8 }}>
                {prog.applicationGuide.personalStatement.map((tip, i) => (
                  <div key={i} style={{ display: "flex", gap: 10, alignItems: "flex-start", padding: "10px 12px", background: brand.offWhite, borderRadius: 10 }}>
                    <span style={{ fontFamily: "Inter", fontWeight: 800, fontSize: 13, color: brand.orange, flexShrink: 0 }}>{i + 1}</span>
                    <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, lineHeight: 1.6 }}>{tip}</span>
                  </div>
                ))}
              </div>
            </InfoCard>

            <InfoCard>
              <SectionTitle>Case Portfolio Guide — How to Build a Strong One</SectionTitle>
              <p style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, marginBottom: 16, lineHeight: 1.65 }}>A portfolio of "20 cases" means nothing if poorly documented. Here's how to make yours stand out:</p>
              <div style={{ display: "flex", flexDirection: "column" as const, gap: 8 }}>
                {prog.applicationGuide.casePortfolio.map((tip, i) => (
                  <div key={i} style={{ display: "flex", gap: 10, alignItems: "flex-start", padding: "10px 12px", background: `${brand.amber}07`, border: `1px solid ${brand.amber}20`, borderRadius: 10 }}>
                    <span style={{ color: brand.amber, flexShrink: 0, fontWeight: 700 }}>→</span>
                    <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, lineHeight: 1.6 }}>{tip}</span>
                  </div>
                ))}
              </div>
            </InfoCard>

            <InfoCard>
              <div style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 16 }}>
                <MessageCircle size={18} color={brand.orange} />
                <SectionTitle>Interview Preparation — Real Questions & Strategies</SectionTitle>
              </div>
              <p style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, marginBottom: 16, lineHeight: 1.65 }}>30–45 minutes online with the Programme Director + one faculty member. They probe your clinical reasoning, motivation, and fit. These are the questions that come up most:</p>
              <div style={{ display: "flex", flexDirection: "column" as const, gap: 12 }}>
                {prog.applicationGuide.interviewPrep.map((item) => (
                  <div key={item.q} style={{ background: brand.offWhite, borderRadius: 14, padding: "16px 18px" }}>
                    <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal, marginBottom: 6 }}>"{item.q}"</div>
                    <div style={{ display: "flex", gap: 8, alignItems: "flex-start" }}>
                      <Zap size={13} color={brand.orange} style={{ flexShrink: 0, marginTop: 1 }} />
                      <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, lineHeight: 1.65 }}>{item.tip}</div>
                    </div>
                  </div>
                ))}
              </div>
            </InfoCard>

            <div style={{ background: `${brand.red}07`, border: `1px solid ${brand.red}20`, borderRadius: 18, padding: "22px 24px" }}>
              <div style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 12 }}>
                <AlertTriangle size={16} color={brand.red} />
                <span style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.red }}>The 6 Reasons Applications Are Rejected</span>
              </div>
              <div style={{ display: "flex", flexDirection: "column" as const, gap: 8 }}>
                {prog.applicationGuide.rejectionReasons.map((r, i) => (
                  <div key={i} style={{ display: "flex", gap: 10, fontFamily: "Inter", fontSize: 13, color: brand.charcoal, lineHeight: 1.55 }}>
                    <span style={{ color: brand.red, fontWeight: 700, flexShrink: 0 }}>{i + 1}.</span> {r}
                  </div>
                ))}
              </div>
            </div>
          </>)}

          {/* ────────── SCHOLARSHIPS ────────── */}
          {activeTab === "scholarships" && (<>
            <div style={{ background: `${brand.amber}08`, border: `1px solid ${brand.amber}25`, borderRadius: 14, padding: "14px 18px", marginBottom: 4 }}>
              <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: brand.charcoal, marginBottom: 3 }}>5 funding options identified for Egyptian applicants</div>
              <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray }}>Two are automatic (no extra application). Three require separate processes. Deadlines differ — read each carefully and act early.</div>
            </div>
            {prog.scholarships.map((s) => (
              <InfoCard key={s.name}>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", gap: 12, marginBottom: 12 }}>
                  <div style={{ display: "flex", gap: 10, alignItems: "flex-start" }}>
                    <Award size={18} color={brand.amber} style={{ flexShrink: 0, marginTop: 2 }} />
                    <div>
                      <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: brand.charcoal, marginBottom: 5 }}>{s.name}</div>
                      <div style={{ display: "flex", gap: 6 }}>
                        <Pill color={brand.orange}>{s.type}</Pill>
                        <Pill color={s.difficulty === "Auto-assessed" ? "#2D9B68" : s.difficulty === "Separate application" ? brand.amber : brand.red}>{s.difficulty}</Pill>
                        {s.renewable && <Pill color="#2D9B68">Renewable</Pill>}
                      </div>
                    </div>
                  </div>
                  <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 22, color: brand.amber, flexShrink: 0 }}>{s.value}</div>
                </div>
                <div style={{ background: brand.offWhite, borderRadius: 12, padding: "12px 14px", marginBottom: 10 }}>
                  <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 10, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em", marginBottom: 4 }}>Eligibility</div>
                  <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, lineHeight: 1.6 }}>{s.eligibility}</div>
                </div>
                <div style={{ background: `${brand.orange}07`, borderRadius: 10, padding: "10px 12px", marginBottom: 12 }}>
                  <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 10, color: brand.orange, textTransform: "uppercase" as const, letterSpacing: "0.06em", marginBottom: 3 }}>Ejadah Tip</div>
                  <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.charcoal, lineHeight: 1.6 }}>{s.tip}</div>
                </div>
                <div style={{ display: "flex", gap: 16, flexWrap: "wrap", alignItems: "center" }}>
                  <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray }}>
                    <Calendar size={11} style={{ display: "inline", marginRight: 4 }} /><strong>Deadline:</strong> {s.deadline}
                  </div>
                  <a href={`https://${s.url}`} target="_blank" rel="noreferrer" style={{ fontFamily: "Inter", fontSize: 12, fontWeight: 600, color: brand.orange, textDecoration: "none", display: "flex", alignItems: "center", gap: 4 }}>
                    <ExternalLink size={11} /> Official Page
                  </a>
                </div>
              </InfoCard>
            ))}
          </>)}

          {/* ────────── AFTER THE MSC ────────── */}
          {activeTab === "after" && (<>
            {/* Salary reality */}
            <InfoCard>
              <div style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 6 }}>
                <TrendingUp size={18} color={brand.orange} />
                <SectionTitle>Salary Reality — What King's Graduates Earn</SectionTitle>
              </div>
              <p style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, marginBottom: 18, lineHeight: 1.6 }}>These are real market ranges — not aspirational figures. Your actual salary will depend on how quickly you build a specialist reputation, your country of practice, and whether you work in a referral-only practice or mixed setting.</p>
              <div style={{ display: "flex", flexDirection: "column" as const, gap: 12 }}>
                {Object.values(prog.salaryReality).map((s) => (
                  <div key={s.title} style={{ background: brand.offWhite, borderRadius: 14, padding: "18px 20px", border: `1px solid ${brand.borderGray}` }}>
                    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", flexWrap: "wrap", gap: 8, marginBottom: 8 }}>
                      <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal }}>{s.title}</div>
                      <div style={{ fontFamily: "Playfair Display, serif", fontWeight: 700, fontSize: 18, color: brand.orange }}>{s.range}</div>
                    </div>
                    <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, lineHeight: 1.65, marginBottom: 6 }}>{s.note}</div>
                    <div style={{ display: "flex", gap: 10, flexWrap: "wrap" }}>
                      <Pill color={brand.amber}>Timeline to this salary: {s.timeline}</Pill>
                      {s.tax && <Pill color={s.tax.includes("free") ? "#2D9B68" : brand.warmGray}>{s.tax}</Pill>}
                    </div>
                  </div>
                ))}
              </div>
            </InfoCard>

            {/* GDC Specialist List */}
            <InfoCard>
              <div style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 6 }}>
                <Shield size={18} color={brand.red} />
                <SectionTitle>{prog.afterMSc.gdcSpecialistList.title}</SectionTitle>
              </div>
              <p style={{ fontFamily: "Inter", fontSize: 14, color: brand.charcoal, lineHeight: 1.75, marginBottom: 18 }}>{prog.afterMSc.gdcSpecialistList.content}</p>
              <div style={{ display: "flex", flexDirection: "column" as const, gap: 12 }}>
                {prog.afterMSc.gdcSpecialistList.pathways.map((p) => (
                  <div key={p.name} style={{ background: brand.offWhite, borderRadius: 14, padding: "16px 18px" }}>
                    <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal, marginBottom: 5 }}>{p.name}</div>
                    <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, lineHeight: 1.6, marginBottom: 8 }}>{p.desc}</div>
                    <div style={{ display: "flex", gap: 8 }}>
                      <Pill color={brand.orange}>{p.effort}</Pill>
                      <Pill color={brand.red}>{p.difficulty}</Pill>
                    </div>
                  </div>
                ))}
              </div>
              <div style={{ marginTop: 14, background: "rgba(45,155,104,0.07)", border: "1px solid rgba(45,155,104,0.2)", borderRadius: 12, padding: "12px 16px" }}>
                <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: "#2D9B68", marginBottom: 3 }}>For Gulf practice</div>
                <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.charcoal, lineHeight: 1.6 }}>{prog.afterMSc.gdcSpecialistList.gulfNote}</div>
              </div>
            </InfoCard>

            {/* Egyptian Syndicate Process */}
            <InfoCard>
              <SectionTitle>Egyptian Syndicate Registration — The Exact 6-Step Process</SectionTitle>
              <p style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, marginBottom: 18, lineHeight: 1.6 }}>This is the information most people piece together from 5 different sources. Here's the complete process in order — so you know exactly what to do when you return.</p>
              <div style={{ position: "relative" }}>
                <div style={{ position: "absolute", left: 14, top: 0, bottom: 0, width: 2, background: brand.borderGray }} />
                {prog.egyptSyndicateProcess.map((s, i) => (
                  <div key={s.step} style={{ display: "flex", gap: 16, marginBottom: 20, position: "relative" }}>
                    <div style={{ width: 30, height: 30, borderRadius: "50%", background: gradientFlow, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0, zIndex: 1 }}>
                      <span style={{ fontFamily: "Inter", fontWeight: 800, fontSize: 11, color: "#fff" }}>{s.step}</span>
                    </div>
                    <div style={{ flex: 1, paddingTop: 4 }}>
                      <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal, marginBottom: 3 }}>{s.title}</div>
                      <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, lineHeight: 1.6 }}>{s.desc}</div>
                    </div>
                  </div>
                ))}
              </div>
            </InfoCard>

            {/* Career paths */}
            <InfoCard>
              <SectionTitle>5 Career Paths After King's</SectionTitle>
              <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(260px, 1fr))", gap: 12 }}>
                {prog.afterMSc.careerPaths.map((c) => (
                  <div key={c.title} style={{ background: brand.offWhite, borderRadius: 14, padding: "16px", border: `1px solid ${brand.borderGray}` }}>
                    <div style={{ fontSize: 24, marginBottom: 8 }}>{c.icon}</div>
                    <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal, marginBottom: 5 }}>{c.title}</div>
                    <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, lineHeight: 1.6, marginBottom: 8 }}>{c.desc}</div>
                    <Pill color={brand.orange}>{c.timeline}</Pill>
                  </div>
                ))}
              </div>
            </InfoCard>
          </>)}

          {/* ────────── RECOGNITION ────────── */}
          {activeTab === "recognition" && (<>
            {Object.entries(prog.recognition).map(([key, val]) => {
              const flags: Record<string, string> = { egypt: "🇪🇬", uae: "🇦🇪", ksa: "🇸🇦", qatar: "🇶🇦" };
              const names: Record<string, string> = { egypt: "Egypt", uae: "United Arab Emirates", ksa: "Saudi Arabia", qatar: "Qatar" };
              return (
                <InfoCard key={key}>
                  <div style={{ display: "flex", gap: 12, alignItems: "center", marginBottom: 12 }}>
                    <span style={{ fontSize: 32 }}>{flags[key]}</span>
                    <div>
                      <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 16, color: brand.charcoal }}>{names[key]}</div>
                      <div style={{ fontFamily: "Inter", fontSize: 12, color: "#2D9B68", fontWeight: 700 }}>✓ Recognised · {val.body}</div>
                    </div>
                  </div>
                  <div style={{ fontFamily: "Inter", fontSize: 14, color: brand.charcoal, lineHeight: 1.75 }}>{val.note}</div>
                </InfoCard>
              );
            })}
            <div style={{ background: `${brand.orange}07`, border: `1px solid ${brand.orange}22`, borderRadius: 16, padding: "14px 18px" }}>
              <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, lineHeight: 1.65 }}>
                <strong>Important:</strong> Recognition status can change. Always verify with the relevant health authority before committing. Ejadah's consulting team can advise on current status for Egyptian applicants.
              </div>
            </div>
          </>)}

          {/* ────────── LIVING & VISA ────────── */}
          {activeTab === "living" && (<>
            <InfoCard>
              <SectionTitle>Monthly Living Costs — London (near Guy's)</SectionTitle>
              <p style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, marginBottom: 18 }}>Based on shared accommodation in Zone 2–3. Budget toward the higher end — London prices increased significantly in 2023–2024.</p>
              {prog.livingCosts.map((row, i) => (
                <div key={row.item} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "11px 0", borderBottom: `1px solid ${brand.borderGray}`, background: i === prog.livingCosts.length - 1 ? `${brand.amber}05` : "transparent" }}>
                  <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, fontWeight: i === prog.livingCosts.length - 1 ? 700 : 400 }}>{row.item}</span>
                  <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 13, color: i === prog.livingCosts.length - 1 ? brand.orange : brand.warmGray }}>{row.range}</span>
                </div>
              ))}
            </InfoCard>

            <InfoCard>
              <div style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 16 }}>
                <MapPin size={18} color={brand.orange} />
                <SectionTitle>Where to Live — Neighbourhood Guide</SectionTitle>
              </div>
              <p style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, marginBottom: 18 }}>Guy's Hospital is in London Bridge (SE1). Here are the most popular areas for King's Dentistry students:</p>
              <div style={{ display: "flex", flexDirection: "column" as const, gap: 12 }}>
                {prog.neighbourhoods.map((n) => (
                  <div key={n.name} style={{ background: brand.offWhite, borderRadius: 14, padding: "16px 18px" }}>
                    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", flexWrap: "wrap", gap: 6, marginBottom: 6 }}>
                      <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: brand.charcoal }}>{n.name}</div>
                      <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.orange }}>{n.rent}</div>
                    </div>
                    <div style={{ display: "flex", gap: 8, marginBottom: 6 }}>
                      <Pill color="#2D9B68">🚶 {n.commute}</Pill>
                    </div>
                    <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, lineHeight: 1.55 }}>{n.vibe}</div>
                  </div>
                ))}
              </div>
            </InfoCard>

            <InfoCard>
              <div style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 16 }}>
                <Building size={18} color={brand.orange} />
                <SectionTitle>Practical Setup — First 2 Weeks</SectionTitle>
              </div>
              <div style={{ display: "flex", flexDirection: "column" as const, gap: 12 }}>
                {prog.practicalSetup.map((item) => (
                  <div key={item.title} style={{ display: "flex", gap: 14, padding: "12px 0", borderBottom: `1px solid ${brand.borderGray}` }}>
                    <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: brand.charcoal, width: 130, flexShrink: 0 }}>{item.title}</div>
                    <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.warmGray, lineHeight: 1.6 }}>{item.detail}</div>
                  </div>
                ))}
              </div>
            </InfoCard>

            <InfoCard>
              <div style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 16 }}>
                <Plane size={18} color={brand.orange} />
                <SectionTitle>UK Student Visa — Complete Breakdown</SectionTitle>
              </div>
              <div style={{ display: "flex", flexDirection: "column" as const, gap: 0 }}>
                {[
                  ["Visa type", prog.visaInfo.type],
                  ["Processing time (Egypt)", prog.visaInfo.processingTime],
                  ["Visa application fee", prog.visaInfo.fee],
                  ["Immigration Health Surcharge", prog.visaInfo.ihs],
                  ["Biometrics", prog.visaInfo.biometric],
                  ["Financial proof required", prog.visaInfo.financialProof],
                  ["VFS Global in Egypt", prog.visaInfo.egVFSLocations],
                ].map(([label, value]) => (
                  <div key={label} style={{ display: "flex", gap: 14, alignItems: "flex-start", padding: "12px 0", borderBottom: `1px solid ${brand.borderGray}` }}>
                    <span style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, minWidth: 170, flexShrink: 0 }}>{label}</span>
                    <span style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, lineHeight: 1.55 }}>{value}</span>
                  </div>
                ))}
              </div>
              <div style={{ marginTop: 14, background: brand.offWhite, borderRadius: 12, padding: "12px 14px" }}>
                <div style={{ fontFamily: "Inter", fontSize: 13, color: brand.charcoal, lineHeight: 1.65 }}>{prog.visaInfo.notes}</div>
              </div>
            </InfoCard>
          </>)}

          {/* ────────── FAQS ────────── */}
          {activeTab === "faqs" && (<>
            <div style={{ display: "flex", flexDirection: "column" as const, gap: 10 }}>
              {prog.faqs.map((faq, i) => <FAQItem key={i} faq={faq} />)}
            </div>
            <InfoCard style={{ background: brand.charcoal, border: "none" }}>
              <div style={{ textAlign: "center" as const }}>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 15, color: "#fff", marginBottom: 8 }}>Have a question not covered here?</div>
                <p style={{ fontFamily: "Inter", fontSize: 13, color: "rgba(255,255,255,0.5)", marginBottom: 18, lineHeight: 1.6 }}>Book a free 20-minute consultation with our postgraduate advisory team — Egyptian dentists who have been through this process.</p>
                <button onClick={() => nav("/consulting")} style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff", background: gradientFlow, border: "none", borderRadius: 10, padding: "12px 28px", cursor: "pointer", boxShadow: "0 4px 16px rgba(255,107,26,0.35)" }}>
                  Book Free Consultation
                </button>
              </div>
            </InfoCard>
          </>)}

        </div>

        {/* ── Sidebar ── */}
        <div style={{ width: 280, flexShrink: 0 }}>
          <div style={{ position: "sticky", top: 116, display: "flex", flexDirection: "column" as const, gap: 14 }}>
            {/* Quick facts */}
            <div style={{ background: brand.white, borderRadius: 18, border: `1px solid ${brand.borderGray}`, padding: "18px 20px" }}>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 12, color: brand.charcoal, marginBottom: 14, textTransform: "uppercase" as const, letterSpacing: "0.06em" }}>Programme Facts</div>
              {[
                ["QS Ranking", `#${prog.qsRanking} Dentistry`],
                ["Format", prog.format],
                ["Duration (FT)", "1 year"],
                ["Duration (PT)", "2 years"],
                ["Tuition/year", prog.tuition],
                ["All-in cost (FT)", prog.totalWithLiving],
                ["Living cost", `${prog.livingCostLow}–${prog.livingCostHigh}`],
                ["IELTS", "7.0 overall"],
                ["Class size", prog.classSize],
                ["Acceptance rate", prog.acceptanceRate],
                ["Cases required", "150"],
                ["Interview", "Required"],
                ["Thesis + viva", "Required"],
                ["Intake", prog.intake],
                ["Deadline", prog.deadline],
              ].map(([l, v]) => (
                <div key={l as string} style={{ display: "flex", justifyContent: "space-between", padding: "6px 0", borderBottom: `1px solid ${brand.borderGray}` }}>
                  <span style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{l as string}</span>
                  <span style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: brand.charcoal, textAlign: "right" as const, maxWidth: 130 }}>{v as string}</span>
                </div>
              ))}
            </div>

            {/* Deadline urgency */}
            {prog.daysToDeadline > 0 && (
              <div style={{ background: prog.daysToDeadline < 60 ? `${brand.red}08` : `${brand.amber}08`, border: `1px solid ${prog.daysToDeadline < 60 ? brand.red : brand.amber}25`, borderRadius: 14, padding: "14px 16px" }}>
                <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 22, color: prog.daysToDeadline < 60 ? brand.red : brand.charcoal, textAlign: "center" as const }}>{prog.daysToDeadline}</div>
                <div style={{ fontFamily: "Inter", fontSize: 12, color: brand.warmGray, textAlign: "center" as const }}>days until deadline</div>
                <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray, textAlign: "center" as const, marginTop: 3 }}>Jan 31, 2026 · 23:59 GMT</div>
              </div>
            )}

            {/* Apply CTA */}
            <a href={prog.admissionsPortal} target="_blank" rel="noreferrer" style={{ textDecoration: "none", display: "block", fontFamily: "Inter", fontWeight: 700, fontSize: 14, color: "#fff", background: gradientFlow, borderRadius: 12, padding: "13px", textAlign: "center" as const, boxShadow: "0 4px 16px rgba(255,107,26,0.35)" }}>
              Apply on King's Website ↗
            </a>

            {/* Consulting */}
            <div style={{ background: brand.charcoal, borderRadius: 16, padding: "18px" }}>
              <div style={{ fontFamily: "Inter", fontWeight: 700, fontSize: 13, color: "#fff", marginBottom: 8 }}>Need Application Help?</div>
              <p style={{ fontFamily: "Inter", fontSize: 12, color: "rgba(255,255,255,0.5)", lineHeight: 1.6, marginBottom: 14 }}>CV review, personal statement coaching, case portfolio structuring, and full application support from Ejadah consultants who've done this pathway.</p>
              <button onClick={() => nav("/consulting")} style={{ width: "100%", fontFamily: "Inter", fontWeight: 600, fontSize: 12, color: "#fff", background: gradientFlow, border: "none", borderRadius: 8, padding: "10px", cursor: "pointer", marginBottom: 8 }}>
                Book Consultation
              </button>
              <div style={{ fontFamily: "Inter", fontSize: 11, color: "rgba(255,255,255,0.35)", textAlign: "center" as const }}>Free 20-min intro call</div>
            </div>

            {/* Quick contact */}
            <div style={{ background: brand.white, borderRadius: 14, border: `1px solid ${brand.borderGray}`, padding: "14px 16px" }}>
              <div style={{ fontFamily: "Inter", fontWeight: 600, fontSize: 11, color: brand.warmGray, textTransform: "uppercase" as const, letterSpacing: "0.06em", marginBottom: 10 }}>King's Admissions</div>
              <a href={`mailto:${prog.contact}`} style={{ fontFamily: "Inter", fontSize: 12, color: brand.orange, textDecoration: "none", display: "flex", alignItems: "center", gap: 5, marginBottom: 6 }}>
                <Mail size={11} /> {prog.contact}
              </a>
              <div style={{ fontFamily: "Inter", fontSize: 11, color: brand.warmGray }}>{prog.phone}</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
