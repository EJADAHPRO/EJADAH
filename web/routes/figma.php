<?php

/*
|--------------------------------------------------------------------------
| Ported design routes
|--------------------------------------------------------------------------
|
| The URL table from the Figma export's own `resources/js/figma/app/routes.ts`,
| re-expressed as Laravel routes. The design's links are absolute — `/courses`,
| `/career/uk`, `/search` — so the site has to sit at the root for them to
| resolve at all.
|
| Every page is public. This is the marketing and discovery surface, and the
| export contains no authenticated behaviour to protect.
|
| Three paths are deliberately NOT claimed here — `/login`, `/register` and
| `/dashboard`. The starter kit's working authentication already owns them, and
| a static mock that cannot actually sign anyone in is worth less than a form
| that can. The design's versions of those three are mounted under `/design/`
| instead, so nothing in the export is unreachable.
|
*/

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

/**
 * Renders one ported page, handing its route parameters to the client.
 *
 * The shim's `useParams()` reads them from the `routeParams` prop, because
 * Laravel resolved the route — there is no client-side pattern to match against.
 */
$page = function (string $component): Closure {
    return function (Request $request) use ($component) {
        return Inertia::render("figma/{$component}", [
            'routeParams' => (object) $request->route()->parameters(),
        ]);
    };
};

// --- Full-screen layouts (no shared navbar or footer) ------------------------

Route::get('/courses/{id}/play', $page('CoursePlayer'))->name('figma.course.play');
Route::get('/live/{id}/classroom', $page('LiveClassroom'))->name('figma.live.classroom');

Route::prefix('admin')->name('figma.admin.')->group(function () use ($page) {
    Route::get('/', $page('AdminDashboard'))->name('dashboard');
    Route::get('/users', $page('AdminUsers'))->name('users');
    Route::get('/content', $page('AdminContent'))->name('content');
    Route::get('/analytics', $page('AdminAnalytics'))->name('analytics');
    Route::get('/billing', $page('AdminBilling'))->name('billing');
});

// The three the starter kit's authentication owns at their canonical paths.
Route::prefix('design')->name('figma.design.')->group(function () use ($page) {
    Route::get('/login', $page('Login'))->name('login');
    Route::get('/register', $page('Register'))->name('register');
    Route::get('/dashboard', $page('Dashboard'))->name('dashboard');
});

Route::get('/onboarding', $page('Onboarding'))->name('figma.onboarding');

// --- Pages inside the shared chrome -----------------------------------------

Route::get('/', $page('Home'))->name('figma.home');

// Courses
Route::get('/courses', $page('Courses'))->name('figma.courses');
Route::get('/courses/{id}', $page('CourseDetail'))->name('figma.course');
Route::get('/courses/{id}/handouts', $page('Handouts'))->name('figma.course.handouts');
Route::get('/courses/{id}/flashcards', $page('Flashcards'))->name('figma.course.flashcards');
Route::get('/courses/{id}/quiz', $page('Quiz'))->name('figma.course.quiz');
Route::get('/courses/{id}/ai', $page('CourseAI'))->name('figma.course.ai');

// Live
Route::get('/live', $page('LiveAcademy'))->name('figma.live');
Route::get('/live/clinical', $page('ClinicalDemos'))->name('figma.live.clinical');

// Exams
Route::get('/exams', $page('Exams'))->name('figma.exams');
Route::get('/exams/edle', $page('ELDEDashboard'))->name('figma.exams.edle');
Route::get('/exams/edle/practice', $page('QuestionBank'))->name('figma.exams.practice');
Route::get('/exams/edle/mock', $page('MockExam'))->name('figma.exams.mock');
Route::get('/exams/analytics', $page('ExamAnalytics'))->name('figma.exams.analytics');
Route::get('/exams/free', $page('FreeTests'))->name('figma.exams.free');

// Community, AI
Route::get('/community', $page('Community'))->name('figma.community');
Route::get('/ai', $page('DentalAI'))->name('figma.ai');

// Career
Route::get('/career', $page('Career'))->name('figma.career');
Route::get('/career/roadmap', $page('CareerRoadmap'))->name('figma.career.roadmap');
Route::get('/career/{country}', $page('CountryDetails'))->name('figma.career.country');

// Master's database
Route::get('/masters', $page('MastersDatabase'))->name('figma.masters');
Route::get('/masters/compare', $page('ProgramComparison'))->name('figma.masters.compare');
Route::get('/masters/{id}', $page('ProgramDetails'))->name('figma.masters.detail');

// Certificates
Route::get('/certificates', $page('Certificates'))->name('figma.certificates');
Route::get('/verify', $page('CertificateVerify'))->name('figma.verify');
Route::get('/verify/{id}', $page('CertificateVerify'))->name('figma.verify.code');

// Tutoring
Route::get('/bookings', $page('MyBookings'))->name('figma.bookings');
Route::get('/tutoring', $page('Tutoring'))->name('figma.tutoring');
Route::get('/tutoring/become-a-tutor', $page('TutorOnboarding'))->name('figma.tutoring.apply');
Route::get('/tutoring/{id}', $page('TutorProfile'))->name('figma.tutor');
Route::get('/tutoring/{id}/book', $page('TutorBooking'))->name('figma.tutor.book');

// Mentoring and consulting
Route::get('/mentoring', $page('Mentoring'))->name('figma.mentoring');
Route::get('/mentoring/{id}', $page('MentorProfile'))->name('figma.mentor');
Route::get('/consulting', $page('Consulting'))->name('figma.consulting');
Route::get('/consulting/{id}', $page('ConsultantProfile'))->name('figma.consultant');
Route::get('/private-training', $page('PrivateTraining'))->name('figma.private-training');

// Research and library
Route::get('/research', $page('ResearchHub'))->name('figma.research');
Route::get('/research/{id}', $page('ResearchDetails'))->name('figma.research.detail');
Route::get('/library', $page('DentalLibrary'))->name('figma.library');
Route::get('/library/{id}', $page('BookDetails'))->name('figma.library.book');

// Supply-side dashboards
Route::get('/achievements', $page('Achievements'))->name('figma.achievements');
Route::get('/instructor', $page('InstructorDashboard'))->name('figma.instructor');
Route::get('/tutor/earnings', $page('TutorEarnings'))->name('figma.tutor.earnings');

// Pricing
Route::get('/pricing', $page('Pricing'))->name('figma.pricing');
Route::get('/pricing/compare', $page('PlanCompare'))->name('figma.pricing.compare');
Route::get('/pricing/{planId}', $page('PlanDetail'))->name('figma.pricing.plan');

// Checkout
Route::get('/checkout', $page('Checkout'))->name('figma.checkout');
Route::get('/checkout/subscription', $page('CheckoutSubscription'))->name('figma.checkout.subscription');
Route::get('/checkout/course', $page('CheckoutCourse'))->name('figma.checkout.course');
Route::get('/checkout/service', $page('CheckoutService'))->name('figma.checkout.service');
Route::get('/checkout/success', $page('CheckoutSuccess'))->name('figma.checkout.success');

// Billing
Route::get('/billing', $page('Billing'))->name('figma.billing');
Route::get('/billing/cancel', $page('BillingCancel'))->name('figma.billing.cancel');
Route::get('/billing/failed', $page('BillingFailed'))->name('figma.billing.failed');

// Membership and utility
Route::get('/membership', $page('Membership'))->name('figma.membership');
Route::get('/notifications', $page('Notifications'))->name('figma.notifications');
Route::get('/search', $page('SearchResults'))->name('figma.search');
Route::get('/accreditations', $page('Accreditations'))->name('figma.accreditations');

// NFC profile — the static paths are declared before `{id}` so they win.
Route::get('/profile/edit', $page('NFCProfileEdit'))->name('figma.profile.edit');
Route::get('/profile/card', $page('NFCCard'))->name('figma.profile.card');
Route::get('/profile/{id}', $page('NFCProfile'))->name('figma.profile');

// Design references
Route::get('/brand', $page('BrandGuide'))->name('figma.brand');
Route::get('/design-system', $page('DesignSystem'))->name('figma.design-system');
Route::get('/rtl-demo', $page('RTLDemo'))->name('figma.rtl-demo');
