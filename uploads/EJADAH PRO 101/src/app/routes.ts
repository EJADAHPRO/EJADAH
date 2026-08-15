import { createBrowserRouter } from "react-router";

import Root from "./pages/Root";
import Home from "./pages/Home";
import Courses from "./pages/Courses";
import CourseDetail from "./pages/CourseDetail";
import CoursePlayer from "./pages/CoursePlayer";
import Handouts from "./pages/Handouts";
import Flashcards from "./pages/Flashcards";
import Quiz from "./pages/Quiz";
import CourseAI from "./pages/CourseAI";
import LiveAcademy from "./pages/LiveAcademy";
import LiveClassroom from "./pages/LiveClassroom";
import ClinicalDemos from "./pages/ClinicalDemos";
import Exams from "./pages/Exams";
import ELDEDashboard from "./pages/ELDEDashboard";
import QuestionBank from "./pages/QuestionBank";
import MockExam from "./pages/MockExam";
import ExamAnalytics from "./pages/ExamAnalytics";
import FreeTests from "./pages/FreeTests";
import Community from "./pages/Community";
import Career from "./pages/Career";
import CountryDetails from "./pages/CountryDetails";
import CareerRoadmap from "./pages/CareerRoadmap";
import DentalAI from "./pages/DentalAI";
import Dashboard from "./pages/Dashboard";
import Certificates from "./pages/Certificates";
import CertificateVerify from "./pages/CertificateVerify";
import MastersDatabase from "./pages/MastersDatabase";
import MyBookings from "./pages/MyBookings";
import ProgramDetails from "./pages/ProgramDetails";
import ProgramComparison from "./pages/ProgramComparison";
import Tutoring from "./pages/Tutoring";
import TutorProfile from "./pages/TutorProfile";
import TutorBooking from "./pages/TutorBooking";
import TutorOnboarding from "./pages/TutorOnboarding";
import Mentoring from "./pages/Mentoring";
import MentorProfile from "./pages/MentorProfile";
import Consulting from "./pages/Consulting";
import ConsultantProfile from "./pages/ConsultantProfile";
import PrivateTraining from "./pages/PrivateTraining";
import ResearchHub from "./pages/ResearchHub";
import ResearchDetails from "./pages/ResearchDetails";
import DentalLibrary from "./pages/DentalLibrary";
import BookDetails from "./pages/BookDetails";
import Achievements from "./pages/Achievements";
import InstructorDashboard from "./pages/InstructorDashboard";
import TutorEarnings from "./pages/TutorEarnings";
import Login from "./pages/Login";
import Register from "./pages/Register";
import Onboarding from "./pages/Onboarding";
import Membership from "./pages/Membership";
import Checkout from "./pages/Checkout";
import Notifications from "./pages/Notifications";
import SearchResults from "./pages/SearchResults";
import Accreditations from "./pages/Accreditations";
import NFCProfile from "./pages/NFCProfile";
import NFCProfileEdit from "./pages/NFCProfileEdit";
import NFCCard from "./pages/NFCCard";
import AdminDashboard from "./pages/AdminDashboard";
import BrandGuide from "./pages/BrandGuide";
import DesignSystem from "./pages/DesignSystem";
import RTLDemo from "./pages/RTLDemo";
import NotFound from "./pages/NotFound";
import Pricing from "./pages/Pricing";
import PlanDetail from "./pages/PlanDetail";
import PlanCompare from "./pages/PlanCompare";
import CheckoutSubscription from "./pages/CheckoutSubscription";
import CheckoutCourse from "./pages/CheckoutCourse";
import CheckoutService from "./pages/CheckoutService";
import CheckoutSuccess from "./pages/CheckoutSuccess";
import Billing from "./pages/Billing";
import BillingCancel from "./pages/BillingCancel";
import BillingFailed from "./pages/BillingFailed";
import AdminBilling from "./pages/AdminBilling";
import AdminUsers from "./pages/AdminUsers";
import AdminContent from "./pages/AdminContent";
import AdminAnalytics from "./pages/AdminAnalytics";

export const router = createBrowserRouter([
  // Full-screen layouts (no shared nav/footer)
  { path: "/courses/:id/play", Component: CoursePlayer },
  { path: "/live/:id/classroom", Component: LiveClassroom },
  { path: "/login", Component: Login },
  { path: "/register", Component: Register },
  { path: "/onboarding", Component: Onboarding },
  {
    path: "/admin",
    children: [
      { index: true, Component: AdminDashboard },
      { path: "users", Component: AdminUsers },
      { path: "content", Component: AdminContent },
      { path: "analytics", Component: AdminAnalytics },
      { path: "billing", Component: AdminBilling },
    ],
  },

  {
    path: "/",
    Component: Root,
    children: [
      { index: true, Component: Home },
      // Courses
      { path: "courses", Component: Courses },
      { path: "courses/:id", Component: CourseDetail },
      { path: "courses/:id/handouts", Component: Handouts },
      { path: "courses/:id/flashcards", Component: Flashcards },
      { path: "courses/:id/quiz", Component: Quiz },
      { path: "courses/:id/ai", Component: CourseAI },
      // Live
      { path: "live", Component: LiveAcademy },
      { path: "live/clinical", Component: ClinicalDemos },
      // Exams
      { path: "exams", Component: Exams },
      { path: "exams/edle", Component: ELDEDashboard },
      { path: "exams/edle/practice", Component: QuestionBank },
      { path: "exams/edle/mock", Component: MockExam },
      { path: "exams/analytics", Component: ExamAnalytics },
      { path: "exams/free", Component: FreeTests },
      // Community / AI / Dashboard
      { path: "community", Component: Community },
      { path: "ai", Component: DentalAI },
      { path: "dashboard", Component: Dashboard },
      // Career
      { path: "career", Component: Career },
      { path: "career/roadmap", Component: CareerRoadmap },
      { path: "career/:country", Component: CountryDetails },
      // Masters
      { path: "masters", Component: MastersDatabase },
      { path: "masters/compare", Component: ProgramComparison },
      { path: "masters/:id", Component: ProgramDetails },
      // Certificates
      { path: "certificates", Component: Certificates },
      { path: "verify/:id", Component: CertificateVerify },
      { path: "verify", Component: CertificateVerify },
      // Tutoring
      { path: "bookings", Component: MyBookings },
      { path: "tutoring", Component: Tutoring },
      { path: "tutoring/become-a-tutor", Component: TutorOnboarding },
      { path: "tutoring/:id", Component: TutorProfile },
      { path: "tutoring/:id/book", Component: TutorBooking },
      // Mentoring
      { path: "mentoring", Component: Mentoring },
      { path: "mentoring/:id", Component: MentorProfile },
      // Consulting
      { path: "consulting", Component: Consulting },
      { path: "consulting/:id", Component: ConsultantProfile },
      // Private Training
      { path: "private-training", Component: PrivateTraining },
      // Research & Library
      { path: "research", Component: ResearchHub },
      { path: "research/:id", Component: ResearchDetails },
      { path: "library", Component: DentalLibrary },
      { path: "library/:id", Component: BookDetails },
      // Dashboards
      { path: "achievements", Component: Achievements },
      { path: "instructor", Component: InstructorDashboard },
      { path: "tutor/earnings", Component: TutorEarnings },
      // Pricing
      { path: "pricing", Component: Pricing },
      { path: "pricing/compare", Component: PlanCompare },
      { path: "pricing/:planId", Component: PlanDetail },
      // Checkout
      { path: "checkout/subscription", Component: CheckoutSubscription },
      { path: "checkout/course", Component: CheckoutCourse },
      { path: "checkout/service", Component: CheckoutService },
      { path: "checkout/success", Component: CheckoutSuccess },
      // Billing
      { path: "billing", Component: Billing },
      { path: "billing/cancel", Component: BillingCancel },
      { path: "billing/failed", Component: BillingFailed },
      // Commerce & Utility
      { path: "membership", Component: Membership },
      { path: "checkout", Component: Checkout },
      { path: "notifications", Component: Notifications },
      { path: "search", Component: SearchResults },
      { path: "accreditations", Component: Accreditations },
      // NFC Profile — static routes MUST come before :id
      { path: "profile/edit", Component: NFCProfileEdit },
      { path: "profile/card", Component: NFCCard },
      { path: "profile/:id", Component: NFCProfile },
      // System
      { path: "brand", Component: BrandGuide },
      { path: "design-system", Component: DesignSystem },
      { path: "rtl-demo", Component: RTLDemo },
      { path: "*", Component: NotFound },
    ],
  },
]);
