import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of EjadahStrings
/// returned by `EjadahStrings.of(context)`.
///
/// Applications need to include `EjadahStrings.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: EjadahStrings.localizationsDelegates,
///   supportedLocales: EjadahStrings.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the EjadahStrings.supportedLocales
/// property.
abstract class EjadahStrings {
  EjadahStrings(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static EjadahStrings of(BuildContext context) {
    return Localizations.of<EjadahStrings>(context, EjadahStrings)!;
  }

  static const LocalizationsDelegate<EjadahStrings> delegate =
      _EjadahStringsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @aboutTutor.
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get aboutTutor;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get account;

  /// No description provided for @addCertificate.
  ///
  /// In en, this message translates to:
  /// **'Add a certificate'**
  String get addCertificate;

  /// No description provided for @again.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get again;

  /// No description provided for @alertsOff.
  ///
  /// In en, this message translates to:
  /// **'Alerts off'**
  String get alertsOff;

  /// No description provided for @alertsOn.
  ///
  /// In en, this message translates to:
  /// **'Alerts on'**
  String get alertsOn;

  /// No description provided for @allowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Turn reminders on'**
  String get allowNotifications;

  /// No description provided for @alsoWorth.
  ///
  /// In en, this message translates to:
  /// **'ALSO WORTH CONSIDERING'**
  String get alsoWorth;

  /// No description provided for @alsoWorthLabel.
  ///
  /// In en, this message translates to:
  /// **'ALSO WORTH CONSIDERING'**
  String get alsoWorthLabel;

  /// No description provided for @answerToContinue.
  ///
  /// In en, this message translates to:
  /// **'Answer this question to continue.'**
  String get answerToContinue;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Ejadah International Academy'**
  String get appName;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Open application'**
  String get apply;

  /// No description provided for @applyToTeach.
  ///
  /// In en, this message translates to:
  /// **'Apply to teach'**
  String get applyToTeach;

  /// No description provided for @authorityLabel.
  ///
  /// In en, this message translates to:
  /// **'REGULATOR'**
  String get authorityLabel;

  /// No description provided for @availabilityLabel.
  ///
  /// In en, this message translates to:
  /// **'AVAILABILITY'**
  String get availabilityLabel;

  /// No description provided for @availableBalance.
  ///
  /// In en, this message translates to:
  /// **'AVAILABLE BALANCE'**
  String get availableBalance;

  /// No description provided for @avgCompletion.
  ///
  /// In en, this message translates to:
  /// **'avg completion'**
  String get avgCompletion;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @backHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backHome;

  /// No description provided for @backToCourse.
  ///
  /// In en, this message translates to:
  /// **'Start the course'**
  String get backToCourse;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToSignIn;

  /// No description provided for @becomeBlurb.
  ///
  /// In en, this message translates to:
  /// **'Apply as a tutor or mentor. You set your rate and hours; the 70/30 split is shown before you commit.'**
  String get becomeBlurb;

  /// No description provided for @becomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Teach on Ejadah'**
  String get becomeTitle;

  /// No description provided for @bestRoute.
  ///
  /// In en, this message translates to:
  /// **'YOUR BEST ROUTE'**
  String get bestRoute;

  /// No description provided for @bookNow.
  ///
  /// In en, this message translates to:
  /// **'Book a session'**
  String get bookNow;

  /// No description provided for @bookSession.
  ///
  /// In en, this message translates to:
  /// **'Book a session'**
  String get bookSession;

  /// No description provided for @bookedBody.
  ///
  /// In en, this message translates to:
  /// **'Payment confirmed on ejadah.com. Your tutor has been notified and the session is in My bookings.'**
  String get bookedBody;

  /// No description provided for @bookedTitle.
  ///
  /// In en, this message translates to:
  /// **'Session booked'**
  String get bookedTitle;

  /// No description provided for @bookedToast.
  ///
  /// In en, this message translates to:
  /// **'Session request sent'**
  String get bookedToast;

  /// No description provided for @bookingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Booking confirmed'**
  String get bookingConfirmed;

  /// No description provided for @bookingsBlurb.
  ///
  /// In en, this message translates to:
  /// **'Upcoming, past and cancelled sessions.'**
  String get bookingsBlurb;

  /// No description provided for @bookingsCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get bookingsCancelled;

  /// No description provided for @bookingsPast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get bookingsPast;

  /// No description provided for @bookingsTitle.
  ///
  /// In en, this message translates to:
  /// **'My bookings'**
  String get bookingsTitle;

  /// No description provided for @bookingsUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get bookingsUpcoming;

  /// No description provided for @browseProgrammes.
  ///
  /// In en, this message translates to:
  /// **'Browse programmes'**
  String get browseProgrammes;

  /// No description provided for @budgetLabel.
  ///
  /// In en, this message translates to:
  /// **'BUDGET'**
  String get budgetLabel;

  /// No description provided for @buildRoute.
  ///
  /// In en, this message translates to:
  /// **'Build my route'**
  String get buildRoute;

  /// No description provided for @buyCourse.
  ///
  /// In en, this message translates to:
  /// **'Buy this course'**
  String get buyCourse;

  /// No description provided for @cairoTime.
  ///
  /// In en, this message translates to:
  /// **'Cairo time'**
  String get cairoTime;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cancelBody.
  ///
  /// In en, this message translates to:
  /// **'Nothing was charged. Your place is not held — the price may change if you come back later.'**
  String get cancelBody;

  /// No description provided for @cancelTermsLabel.
  ///
  /// In en, this message translates to:
  /// **'CANCELLATION'**
  String get cancelTermsLabel;

  /// No description provided for @cancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment cancelled'**
  String get cancelTitle;

  /// No description provided for @cardsDue.
  ///
  /// In en, this message translates to:
  /// **'{count} cards due'**
  String cardsDue(Object count);

  /// No description provided for @careerEyebrow.
  ///
  /// In en, this message translates to:
  /// **'CAREER'**
  String get careerEyebrow;

  /// No description provided for @careerSub.
  ///
  /// In en, this message translates to:
  /// **'Four routes out of the same qualification. Pick one and see the whole path — cost, time and difficulty included.'**
  String get careerSub;

  /// No description provided for @careerTitle.
  ///
  /// In en, this message translates to:
  /// **'Your degree opens more doors than you think'**
  String get careerTitle;

  /// No description provided for @certCode.
  ///
  /// In en, this message translates to:
  /// **'Certificate code'**
  String get certCode;

  /// No description provided for @certTitleSample.
  ///
  /// In en, this message translates to:
  /// **'Rotary & reciprocating endodontics · 11 lessons'**
  String get certTitleSample;

  /// No description provided for @certificatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Certificates'**
  String get certificatesTitle;

  /// No description provided for @choosePlan.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get choosePlan;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get clearCache;

  /// No description provided for @clearField.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearField;

  /// No description provided for @clearFiltersAction.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFiltersAction;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Past deadline'**
  String get closed;

  /// No description provided for @cmpEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap + on up to three programmes in the list, then come back here.'**
  String get cmpEmptyBody;

  /// No description provided for @cmpEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing selected yet'**
  String get cmpEmptyTitle;

  /// No description provided for @codeRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the code from your email.'**
  String get codeRequired;

  /// No description provided for @communityLabel.
  ///
  /// In en, this message translates to:
  /// **'FROM THE COMMUNITY'**
  String get communityLabel;

  /// No description provided for @compareCount.
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get compareCount;

  /// No description provided for @compareCta.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get compareCta;

  /// No description provided for @compareLimit.
  ///
  /// In en, this message translates to:
  /// **'Compare up to {count} at a time.'**
  String compareLimit(Object count);

  /// No description provided for @compareMode.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get compareMode;

  /// No description provided for @compareNeedsTwo.
  ///
  /// In en, this message translates to:
  /// **'Pick one more to compare.'**
  String get compareNeedsTwo;

  /// No description provided for @compareTitle.
  ///
  /// In en, this message translates to:
  /// **'Side by side'**
  String get compareTitle;

  /// No description provided for @connectEyebrow.
  ///
  /// In en, this message translates to:
  /// **'CONNECT'**
  String get connectEyebrow;

  /// No description provided for @connectSub.
  ///
  /// In en, this message translates to:
  /// **'Three kinds of conversation. Pick by what you need, not by job title.'**
  String get connectSub;

  /// No description provided for @connectTitle.
  ///
  /// In en, this message translates to:
  /// **'Time with someone who has already done it'**
  String get connectTitle;

  /// No description provided for @consultingBlurb.
  ///
  /// In en, this message translates to:
  /// **'Clinic and business advisory for owners and partners.'**
  String get consultingBlurb;

  /// No description provided for @consultingTitle.
  ///
  /// In en, this message translates to:
  /// **'Consulting'**
  String get consultingTitle;

  /// No description provided for @contentUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'This is no longer available — often the intake closed.'**
  String get contentUnavailableBody;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @continueCourse.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueCourse;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get continueLabel;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLink;

  /// No description provided for @countriesBlurb.
  ///
  /// In en, this message translates to:
  /// **'Exam, regulator, visa route and real costs for 23 countries.'**
  String get countriesBlurb;

  /// No description provided for @coursesEyebrow.
  ///
  /// In en, this message translates to:
  /// **'COURSES'**
  String get coursesEyebrow;

  /// No description provided for @coursesTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn from dentists who teach for a living'**
  String get coursesTitle;

  /// No description provided for @cpdTitle.
  ///
  /// In en, this message translates to:
  /// **'CPD ledger'**
  String get cpdTitle;

  /// No description provided for @cpdTotal.
  ///
  /// In en, this message translates to:
  /// **'Total credits'**
  String get cpdTotal;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @crossingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Where next'**
  String get crossingsLabel;

  /// No description provided for @ctaContinueRoadmap.
  ///
  /// In en, this message translates to:
  /// **'Continue my roadmap'**
  String get ctaContinueRoadmap;

  /// No description provided for @ctaFindConsulting.
  ///
  /// In en, this message translates to:
  /// **'Find a consultant'**
  String get ctaFindConsulting;

  /// No description provided for @ctaSetUpCard.
  ///
  /// In en, this message translates to:
  /// **'Set up your professional card'**
  String get ctaSetUpCard;

  /// No description provided for @ctaStudyPlan.
  ///
  /// In en, this message translates to:
  /// **'Open my study plan'**
  String get ctaStudyPlan;

  /// No description provided for @ctaTeaching.
  ///
  /// In en, this message translates to:
  /// **'Open teaching dashboard'**
  String get ctaTeaching;

  /// No description provided for @currentPlan.
  ///
  /// In en, this message translates to:
  /// **'CURRENT PLAN'**
  String get currentPlan;

  /// No description provided for @currentPlanShort.
  ///
  /// In en, this message translates to:
  /// **'Your plan'**
  String get currentPlanShort;

  /// No description provided for @currentStage.
  ///
  /// In en, this message translates to:
  /// **'CURRENT STAGE'**
  String get currentStage;

  /// No description provided for @curriculum.
  ///
  /// In en, this message translates to:
  /// **'Curriculum'**
  String get curriculum;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'days left'**
  String get daysLeft;

  /// No description provided for @daysLeftCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day left} other{{count} days left}}'**
  String daysLeftCount(num count);

  /// No description provided for @deadlinesAction.
  ///
  /// In en, this message translates to:
  /// **'Open the database'**
  String get deadlinesAction;

  /// No description provided for @deadlinesBody.
  ///
  /// In en, this message translates to:
  /// **'32 more close within 60 days. Expired intakes are hidden until you ask for them.'**
  String get deadlinesBody;

  /// No description provided for @deadlinesLabel.
  ///
  /// In en, this message translates to:
  /// **'PROGRAMME DEADLINES'**
  String get deadlinesLabel;

  /// No description provided for @deadlinesTitle.
  ///
  /// In en, this message translates to:
  /// **'17 programmes are open right now'**
  String get deadlinesTitle;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'You have 30 days to change your mind. Invoices are kept for tax.'**
  String get deleteAccountBody;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteStepTwo.
  ///
  /// In en, this message translates to:
  /// **'Continue to step 2'**
  String get deleteStepTwo;

  /// No description provided for @departmentBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business & Paradental'**
  String get departmentBusiness;

  /// No description provided for @departmentDigital.
  ///
  /// In en, this message translates to:
  /// **'Digital'**
  String get departmentDigital;

  /// No description provided for @departmentOrtho.
  ///
  /// In en, this message translates to:
  /// **'Orthodontics'**
  String get departmentOrtho;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'difficulty'**
  String get difficulty;

  /// No description provided for @difficultyLabel.
  ///
  /// In en, this message translates to:
  /// **'DIFFICULTY'**
  String get difficultyLabel;

  /// No description provided for @disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Always confirm fees, visa rules and registration requirements with the relevant authority before committing money.'**
  String get disclaimer;

  /// No description provided for @documentsTab.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documentsTab;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'SESSION LENGTH'**
  String get durationLabel;

  /// No description provided for @earningsLink.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earningsLink;

  /// No description provided for @editCard.
  ///
  /// In en, this message translates to:
  /// **'Edit card details'**
  String get editCard;

  /// No description provided for @editCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit your card'**
  String get editCardTitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address.'**
  String get emailRequired;

  /// No description provided for @emptyBookBody.
  ///
  /// In en, this message translates to:
  /// **'Sessions you book or cancel will show up in this tab.'**
  String get emptyBookBody;

  /// No description provided for @emptyBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyBookTitle;

  /// No description provided for @emptyMastersBody.
  ///
  /// In en, this message translates to:
  /// **'Try a broader specialty, or show expired intakes.'**
  String get emptyMastersBody;

  /// No description provided for @emptyMastersTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches those filters'**
  String get emptyMastersTitle;

  /// No description provided for @emptyNotifBody.
  ///
  /// In en, this message translates to:
  /// **'Deadline warnings and session reminders land here. Save a programme and the first one is on its way.'**
  String get emptyNotifBody;

  /// No description provided for @emptyNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get emptyNotifTitle;

  /// No description provided for @emptySavedBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on any programme to keep it here with its deadline.'**
  String get emptySavedBody;

  /// No description provided for @emptySavedRelaxed.
  ///
  /// In en, this message translates to:
  /// **'No saved programmes yet — {count} are open right now.'**
  String emptySavedRelaxed(Object count);

  /// No description provided for @emptySavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet'**
  String get emptySavedTitle;

  /// No description provided for @enrol.
  ///
  /// In en, this message translates to:
  /// **'Enrol'**
  String get enrol;

  /// No description provided for @enrolNow.
  ///
  /// In en, this message translates to:
  /// **'Enrol now'**
  String get enrolNow;

  /// No description provided for @enrolled.
  ///
  /// In en, this message translates to:
  /// **'enrolled'**
  String get enrolled;

  /// No description provided for @errBody.
  ///
  /// In en, this message translates to:
  /// **'Your saved work is safe on this device. Try again in a moment.'**
  String get errBody;

  /// No description provided for @errGeneric.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t do that just now. Nothing you entered is lost.'**
  String get errGeneric;

  /// No description provided for @errServer.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our side. Nothing you saved is affected.'**
  String get errServer;

  /// No description provided for @errTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your feed'**
  String get errTitle;

  /// No description provided for @estCost.
  ///
  /// In en, this message translates to:
  /// **'estimated cost'**
  String get estCost;

  /// No description provided for @examFee.
  ///
  /// In en, this message translates to:
  /// **'Exam fee'**
  String get examFee;

  /// No description provided for @examLabel.
  ///
  /// In en, this message translates to:
  /// **'EXAM'**
  String get examLabel;

  /// No description provided for @exploreLabel.
  ///
  /// In en, this message translates to:
  /// **'EXPLORE'**
  String get exploreLabel;

  /// No description provided for @fBudget.
  ///
  /// In en, this message translates to:
  /// **'BUDGET (USD ESTIMATE)'**
  String get fBudget;

  /// No description provided for @fDeadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get fDeadline;

  /// No description provided for @fDegreeType.
  ///
  /// In en, this message translates to:
  /// **'DEGREE'**
  String get fDegreeType;

  /// No description provided for @fDestination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get fDestination;

  /// No description provided for @fDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get fDuration;

  /// No description provided for @fGpa.
  ///
  /// In en, this message translates to:
  /// **'GPA'**
  String get fGpa;

  /// No description provided for @fIelts.
  ///
  /// In en, this message translates to:
  /// **'IELTS'**
  String get fIelts;

  /// No description provided for @fIntake.
  ///
  /// In en, this message translates to:
  /// **'Intake'**
  String get fIntake;

  /// No description provided for @fInterview.
  ///
  /// In en, this message translates to:
  /// **'Interview'**
  String get fInterview;

  /// No description provided for @fLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get fLanguage;

  /// No description provided for @fMaxRate.
  ///
  /// In en, this message translates to:
  /// **'Maximum rate'**
  String get fMaxRate;

  /// No description provided for @fRank.
  ///
  /// In en, this message translates to:
  /// **'QS rank'**
  String get fRank;

  /// No description provided for @fRegion.
  ///
  /// In en, this message translates to:
  /// **'REGION'**
  String get fRegion;

  /// No description provided for @fScholarship.
  ///
  /// In en, this message translates to:
  /// **'Scholarship'**
  String get fScholarship;

  /// No description provided for @fSpecialty.
  ///
  /// In en, this message translates to:
  /// **'SPECIALTY'**
  String get fSpecialty;

  /// No description provided for @fThesis.
  ///
  /// In en, this message translates to:
  /// **'Thesis'**
  String get fThesis;

  /// No description provided for @fTuition.
  ///
  /// In en, this message translates to:
  /// **'Tuition'**
  String get fTuition;

  /// No description provided for @fieldBio.
  ///
  /// In en, this message translates to:
  /// **'Short bio'**
  String get fieldBio;

  /// No description provided for @fieldClinic.
  ///
  /// In en, this message translates to:
  /// **'Clinic'**
  String get fieldClinic;

  /// No description provided for @fieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get fieldTitle;

  /// No description provided for @filterBy.
  ///
  /// In en, this message translates to:
  /// **'FORMAT'**
  String get filterBy;

  /// No description provided for @filterSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filterSheetTitle;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @firstRunBody.
  ///
  /// In en, this message translates to:
  /// **'Answer four short questions and get a route built around your real budget and time.'**
  String get firstRunBody;

  /// No description provided for @firstRunTitle.
  ///
  /// In en, this message translates to:
  /// **'Start where it matters'**
  String get firstRunTitle;

  /// No description provided for @fitLabel.
  ///
  /// In en, this message translates to:
  /// **'Fit'**
  String get fitLabel;

  /// No description provided for @flashcards.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get flashcards;

  /// No description provided for @flipCard.
  ///
  /// In en, this message translates to:
  /// **'Tap to flip'**
  String get flipCard;

  /// No description provided for @forgotBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the email on your account and we\'ll send a reset link.'**
  String get forgotBody;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @forgotSent.
  ///
  /// In en, this message translates to:
  /// **'If that email is registered, a reset link is on its way. Check spam before asking us.'**
  String get forgotSent;

  /// No description provided for @forgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get forgotTitle;

  /// No description provided for @freeIntroCall.
  ///
  /// In en, this message translates to:
  /// **'Free intro call'**
  String get freeIntroCall;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @gateBody.
  ///
  /// In en, this message translates to:
  /// **'{count} more stages, your costs and the exact dates — free, no card.'**
  String gateBody(Object count);

  /// No description provided for @gateTitle.
  ///
  /// In en, this message translates to:
  /// **'See your full route'**
  String get gateTitle;

  /// No description provided for @getBullet1.
  ///
  /// In en, this message translates to:
  /// **'You bring the case — radiographs, notes, the bit that went wrong.'**
  String get getBullet1;

  /// No description provided for @getBullet2.
  ///
  /// In en, this message translates to:
  /// **'Screen share on your own CBCT and photos, recorded if you want it.'**
  String get getBullet2;

  /// No description provided for @getBullet3.
  ///
  /// In en, this message translates to:
  /// **'A written summary and next-case checklist within 24 hours.'**
  String get getBullet3;

  /// No description provided for @goalLabel.
  ///
  /// In en, this message translates to:
  /// **'What do you need from this session?'**
  String get goalLabel;

  /// No description provided for @goalTooShort.
  ///
  /// In en, this message translates to:
  /// **'Write a line or two about what you need — it makes the session far more useful.'**
  String get goalTooShort;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @greetingEyebrow.
  ///
  /// In en, this message translates to:
  /// **'MONDAY · 28 JULY'**
  String get greetingEyebrow;

  /// No description provided for @guidesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 guide} other{{count} guides}}'**
  String guidesCount(num count);

  /// No description provided for @handouts.
  ///
  /// In en, this message translates to:
  /// **'Handouts'**
  String get handouts;

  /// No description provided for @handoutsTitle.
  ///
  /// In en, this message translates to:
  /// **'Handouts'**
  String get handoutsTitle;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get haveAccount;

  /// No description provided for @hideExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired hidden'**
  String get hideExpired;

  /// No description provided for @holdCountdown.
  ///
  /// In en, this message translates to:
  /// **'Held for you {time}'**
  String holdCountdown(Object time);

  /// No description provided for @holdExpiredBody.
  ///
  /// In en, this message translates to:
  /// **'That hold ran out and the time was released. Pick another — nothing was charged.'**
  String get holdExpiredBody;

  /// No description provided for @holdExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'That hold ran out'**
  String get holdExpiredTitle;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get homeGreetingEvening;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get homeGreetingMorning;

  /// No description provided for @incCert.
  ///
  /// In en, this message translates to:
  /// **'Certificate of completion'**
  String get incCert;

  /// No description provided for @incCpd.
  ///
  /// In en, this message translates to:
  /// **'CPD credits included'**
  String get incCpd;

  /// No description provided for @incHandouts.
  ///
  /// In en, this message translates to:
  /// **'Downloadable handouts'**
  String get incHandouts;

  /// No description provided for @incLifetime.
  ///
  /// In en, this message translates to:
  /// **'Full lifetime access'**
  String get incLifetime;

  /// No description provided for @included.
  ///
  /// In en, this message translates to:
  /// **'WHAT\'S INCLUDED'**
  String get included;

  /// No description provided for @includes.
  ///
  /// In en, this message translates to:
  /// **'WHAT\'S INCLUDED'**
  String get includes;

  /// No description provided for @initials.
  ///
  /// In en, this message translates to:
  /// **'YH'**
  String get initials;

  /// No description provided for @installEjadah.
  ///
  /// In en, this message translates to:
  /// **'Get Ejadah'**
  String get installEjadah;

  /// No description provided for @instructorBio.
  ///
  /// In en, this message translates to:
  /// **'Consultant endodontist, teaches microscope-assisted retreatment at Cairo University.'**
  String get instructorBio;

  /// No description provided for @instructorLabel.
  ///
  /// In en, this message translates to:
  /// **'YOUR INSTRUCTOR'**
  String get instructorLabel;

  /// No description provided for @instructorLink.
  ///
  /// In en, this message translates to:
  /// **'My courses'**
  String get instructorLink;

  /// No description provided for @instructorTitle.
  ///
  /// In en, this message translates to:
  /// **'Your courses'**
  String get instructorTitle;

  /// No description provided for @issuedBy.
  ///
  /// In en, this message translates to:
  /// **'Issued by'**
  String get issuedBy;

  /// No description provided for @issuedDate.
  ///
  /// In en, this message translates to:
  /// **'12 May 2026'**
  String get issuedDate;

  /// No description provided for @issuedOn.
  ///
  /// In en, this message translates to:
  /// **'Issued on'**
  String get issuedOn;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @keyFacts.
  ///
  /// In en, this message translates to:
  /// **'KEY FACTS'**
  String get keyFacts;

  /// No description provided for @kingsBlurb.
  ///
  /// In en, this message translates to:
  /// **'Nine sections: curriculum, requirements, application coaching, five funding routes, salary reality, Gulf and Egyptian recognition, London costs and the visa.'**
  String get kingsBlurb;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get languageLabel;

  /// No description provided for @lastSixMonths.
  ///
  /// In en, this message translates to:
  /// **'LAST SIX MONTHS'**
  String get lastSixMonths;

  /// No description provided for @learnEyebrow.
  ///
  /// In en, this message translates to:
  /// **'LEARN'**
  String get learnEyebrow;

  /// No description provided for @lessonOneFree.
  ///
  /// In en, this message translates to:
  /// **'Lesson 1 is free'**
  String get lessonOneFree;

  /// No description provided for @lessons.
  ///
  /// In en, this message translates to:
  /// **'lessons'**
  String get lessons;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @licensingRoute.
  ///
  /// In en, this message translates to:
  /// **'LICENSING ROUTE'**
  String get licensingRoute;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linkCopied;

  /// No description provided for @linksLabel.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get linksLabel;

  /// No description provided for @manageOnWeb.
  ///
  /// In en, this message translates to:
  /// **'Manage on ejadah.com'**
  String get manageOnWeb;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @mastersEyebrow.
  ///
  /// In en, this message translates to:
  /// **'POSTGRADUATE · 123 COUNTRIES'**
  String get mastersEyebrow;

  /// No description provided for @mastersTitle.
  ///
  /// In en, this message translates to:
  /// **'199 programmes, honestly described'**
  String get mastersTitle;

  /// No description provided for @maybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get maybeLater;

  /// No description provided for @mediaNote.
  ///
  /// In en, this message translates to:
  /// **'Tutors with a photo and intro video get 3× more bookings. The intro video is 2–3 minutes — introduce yourself and your teaching style.'**
  String get mediaNote;

  /// No description provided for @mentoringBlurb.
  ///
  /// In en, this message translates to:
  /// **'Dentists who already made the move — matched on route, not specialty.'**
  String get mentoringBlurb;

  /// No description provided for @mentoringTitle.
  ///
  /// In en, this message translates to:
  /// **'Mentoring'**
  String get mentoringTitle;

  /// No description provided for @mentorsWhoMoved.
  ///
  /// In en, this message translates to:
  /// **'Mentors who made this move'**
  String get mentorsWhoMoved;

  /// No description provided for @monthsTypical.
  ///
  /// In en, this message translates to:
  /// **'months, typical'**
  String get monthsTypical;

  /// No description provided for @myCareer.
  ///
  /// In en, this message translates to:
  /// **'MY CAREER'**
  String get myCareer;

  /// No description provided for @myLearning.
  ///
  /// In en, this message translates to:
  /// **'MY LEARNING'**
  String get myLearning;

  /// No description provided for @myShortlist.
  ///
  /// In en, this message translates to:
  /// **'My shortlist'**
  String get myShortlist;

  /// No description provided for @namePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'As it appears on your degree'**
  String get namePlaceholder;

  /// No description provided for @newThisMonth.
  ///
  /// In en, this message translates to:
  /// **'New this month'**
  String get newThisMonth;

  /// No description provided for @nextAvailable.
  ///
  /// In en, this message translates to:
  /// **'NEXT AVAILABLE'**
  String get nextAvailable;

  /// No description provided for @nextMentor.
  ///
  /// In en, this message translates to:
  /// **'Talk to someone who did it'**
  String get nextMentor;

  /// No description provided for @nextMentorSub.
  ///
  /// In en, this message translates to:
  /// **'Mentors matched on this exact route.'**
  String get nextMentorSub;

  /// No description provided for @nextPage.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get nextPage;

  /// No description provided for @nextProgrammes.
  ///
  /// In en, this message translates to:
  /// **'Postgraduate programmes'**
  String get nextProgrammes;

  /// No description provided for @nextProgrammesSub.
  ///
  /// In en, this message translates to:
  /// **'Filtered to your specialty and destination.'**
  String get nextProgrammesSub;

  /// No description provided for @nextQuestion.
  ///
  /// In en, this message translates to:
  /// **'Next question'**
  String get nextQuestion;

  /// No description provided for @nfcClinic.
  ///
  /// In en, this message translates to:
  /// **'Nile Dental Studio, Zamalek, Cairo'**
  String get nfcClinic;

  /// No description provided for @nfcNote.
  ///
  /// In en, this message translates to:
  /// **'Your public profile lives at ejadah.com/p/yasmine-hassan — anyone can open it from the QR or a tap, with no app required.'**
  String get nfcNote;

  /// No description provided for @nfcTitle.
  ///
  /// In en, this message translates to:
  /// **'Endodontics · Digital dentistry'**
  String get nfcTitle;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'Not required'**
  String get no;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'New to Ejadah?'**
  String get noAccount;

  /// No description provided for @noProfessionals.
  ///
  /// In en, this message translates to:
  /// **'No one matches those filters yet.'**
  String get noProfessionals;

  /// No description provided for @noResultsNearest.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches those filters. Nearest match: {relaxation}.'**
  String noResultsNearest(Object relaxation);

  /// No description provided for @noSlots.
  ///
  /// In en, this message translates to:
  /// **'No open times this week.'**
  String get noSlots;

  /// No description provided for @notIncluded.
  ///
  /// In en, this message translates to:
  /// **'Not included'**
  String get notIncluded;

  /// No description provided for @notListed.
  ///
  /// In en, this message translates to:
  /// **'Not listed'**
  String get notListed;

  /// No description provided for @notVerified.
  ///
  /// In en, this message translates to:
  /// **'Not verified'**
  String get notVerified;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'NOTES FOR THE TUTOR'**
  String get notesLabel;

  /// No description provided for @notesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Bring the case you want to discuss — radiographs help.'**
  String get notesPlaceholder;

  /// No description provided for @notifBooking.
  ///
  /// In en, this message translates to:
  /// **'Session reminders'**
  String get notifBooking;

  /// No description provided for @notifDeadline.
  ///
  /// In en, this message translates to:
  /// **'Programme deadlines'**
  String get notifDeadline;

  /// No description provided for @notifPrefs.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATIONS'**
  String get notifPrefs;

  /// No description provided for @notifStudy.
  ///
  /// In en, this message translates to:
  /// **'Study reminders'**
  String get notifStudy;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @nowPlaying.
  ///
  /// In en, this message translates to:
  /// **'NOW PLAYING'**
  String get nowPlaying;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'Offline — showing your saved content'**
  String get offlineBanner;

  /// No description provided for @openGuide.
  ///
  /// In en, this message translates to:
  /// **'Open the guide'**
  String get openGuide;

  /// No description provided for @openNow.
  ///
  /// In en, this message translates to:
  /// **'Open now'**
  String get openNow;

  /// No description provided for @openRoadmap.
  ///
  /// In en, this message translates to:
  /// **'Open roadmap'**
  String get openRoadmap;

  /// No description provided for @orderPhysical.
  ///
  /// In en, this message translates to:
  /// **'Order the physical card'**
  String get orderPhysical;

  /// No description provided for @ownedCourse.
  ///
  /// In en, this message translates to:
  /// **'Yours for good'**
  String get ownedCourse;

  /// No description provided for @pGoal.
  ///
  /// In en, this message translates to:
  /// **'What are you aiming for?'**
  String get pGoal;

  /// No description provided for @pNotify.
  ///
  /// In en, this message translates to:
  /// **'Can we send you reminders?'**
  String get pNotify;

  /// No description provided for @pNotifyWhy.
  ///
  /// In en, this message translates to:
  /// **'Two a day maximum, never between 22:00 and 08:00 Cairo time, and you choose the categories.'**
  String get pNotifyWhy;

  /// No description provided for @pRegion.
  ///
  /// In en, this message translates to:
  /// **'Where would you go?'**
  String get pRegion;

  /// No description provided for @pRegionSub.
  ///
  /// In en, this message translates to:
  /// **'Pick as many as apply — it only shapes what we show you first.'**
  String get pRegionSub;

  /// No description provided for @pSpec.
  ///
  /// In en, this message translates to:
  /// **'Which field interests you?'**
  String get pSpec;

  /// No description provided for @packagesLabel.
  ///
  /// In en, this message translates to:
  /// **'PACKAGES'**
  String get packagesLabel;

  /// No description provided for @paidBody.
  ///
  /// In en, this message translates to:
  /// **'Payment confirmed on ejadah.com. Your access is active on this device.'**
  String get paidBody;

  /// No description provided for @paidTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re enrolled'**
  String get paidTitle;

  /// No description provided for @partialBody.
  ///
  /// In en, this message translates to:
  /// **'The rest of your feed is up to date.'**
  String get partialBody;

  /// No description provided for @partialSectionNote.
  ///
  /// In en, this message translates to:
  /// **'This part of your feed didn’t load. The rest is up to date.'**
  String get partialSectionNote;

  /// No description provided for @partialTitle.
  ///
  /// In en, this message translates to:
  /// **'Tutors didn\'t load'**
  String get partialTitle;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @pathBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business & industry'**
  String get pathBusiness;

  /// No description provided for @pathDigital.
  ///
  /// In en, this message translates to:
  /// **'Digital & freelance'**
  String get pathDigital;

  /// No description provided for @pathGpAbroad.
  ///
  /// In en, this message translates to:
  /// **'Work abroad as a GP'**
  String get pathGpAbroad;

  /// No description provided for @pathSpecialise.
  ///
  /// In en, this message translates to:
  /// **'Specialise clinically'**
  String get pathSpecialise;

  /// No description provided for @pathsLabel.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE A DIRECTION'**
  String get pathsLabel;

  /// No description provided for @pathwayLabel.
  ///
  /// In en, this message translates to:
  /// **'PATHWAY'**
  String get pathwayLabel;

  /// No description provided for @patientDataWarning.
  ///
  /// In en, this message translates to:
  /// **'Please don\'t include patient names or identifying details.'**
  String get patientDataWarning;

  /// No description provided for @payCta.
  ///
  /// In en, this message translates to:
  /// **'Pay on ejadah.com'**
  String get payCta;

  /// No description provided for @payExternally.
  ///
  /// In en, this message translates to:
  /// **'Continue to payment'**
  String get payExternally;

  /// No description provided for @payNote.
  ///
  /// In en, this message translates to:
  /// **'Payments are completed securely on ejadah.com — the app never handles card details.'**
  String get payNote;

  /// No description provided for @payNoteExternal.
  ///
  /// In en, this message translates to:
  /// **'Completed securely on ejadah.international'**
  String get payNoteExternal;

  /// No description provided for @pendingClearing.
  ///
  /// In en, this message translates to:
  /// **'Pending clearance:'**
  String get pendingClearing;

  /// No description provided for @pendingSource.
  ///
  /// In en, this message translates to:
  /// **'Pending source'**
  String get pendingSource;

  /// No description provided for @peopleConsultingDoor.
  ///
  /// In en, this message translates to:
  /// **'Consulting'**
  String get peopleConsultingDoor;

  /// No description provided for @peopleEyebrow.
  ///
  /// In en, this message translates to:
  /// **'PEOPLE'**
  String get peopleEyebrow;

  /// No description provided for @peopleMentoringDoor.
  ///
  /// In en, this message translates to:
  /// **'Mentoring'**
  String get peopleMentoringDoor;

  /// No description provided for @peopleTutoringDoor.
  ///
  /// In en, this message translates to:
  /// **'Tutoring'**
  String get peopleTutoringDoor;

  /// No description provided for @perHour.
  ///
  /// In en, this message translates to:
  /// **'/ hour'**
  String get perHour;

  /// No description provided for @perHourRate.
  ///
  /// In en, this message translates to:
  /// **'per hour'**
  String get perHourRate;

  /// No description provided for @perSession.
  ///
  /// In en, this message translates to:
  /// **'PER SESSION — FEE ITEMISED'**
  String get perSession;

  /// No description provided for @photoSlot.
  ///
  /// In en, this message translates to:
  /// **'profile photo'**
  String get photoSlot;

  /// No description provided for @pickAnotherWeek.
  ///
  /// In en, this message translates to:
  /// **'Try another week'**
  String get pickAnotherWeek;

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date and time'**
  String get pickDate;

  /// No description provided for @pickDept.
  ///
  /// In en, this message translates to:
  /// **'Three departments in this release. Pick one to see its courses.'**
  String get pickDept;

  /// No description provided for @pickSlot.
  ///
  /// In en, this message translates to:
  /// **'AVAILABLE SLOTS'**
  String get pickSlot;

  /// No description provided for @pickSlotFirst.
  ///
  /// In en, this message translates to:
  /// **'Pick a time to continue'**
  String get pickSlotFirst;

  /// No description provided for @plansTitle.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get plansTitle;

  /// No description provided for @platformFee.
  ///
  /// In en, this message translates to:
  /// **'Ejadah fee (30%)'**
  String get platformFee;

  /// No description provided for @premiumRenews.
  ///
  /// In en, this message translates to:
  /// **'Renews {date}'**
  String premiumRenews(Object date);

  /// No description provided for @previewAvailable.
  ///
  /// In en, this message translates to:
  /// **'Preview available'**
  String get previewAvailable;

  /// No description provided for @previousPage.
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get previousPage;

  /// No description provided for @priorityLabel.
  ///
  /// In en, this message translates to:
  /// **'WHAT MATTERS MOST'**
  String get priorityLabel;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacy;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @profileEyebrow.
  ///
  /// In en, this message translates to:
  /// **'PROFILE'**
  String get profileEyebrow;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Dr. Yasmine Hassan'**
  String get profileName;

  /// No description provided for @profileStage.
  ///
  /// In en, this message translates to:
  /// **'General dentist · 3 years since qualifying'**
  String get profileStage;

  /// No description provided for @programmeCount.
  ///
  /// In en, this message translates to:
  /// **'199 records'**
  String get programmeCount;

  /// No description provided for @programmesBlurb.
  ///
  /// In en, this message translates to:
  /// **'Filter by specialty, country, tuition, intake and deadline. Compare up to three.'**
  String get programmesBlurb;

  /// No description provided for @programmesHere.
  ///
  /// In en, this message translates to:
  /// **'Programmes in {country}'**
  String programmesHere(Object country);

  /// No description provided for @publicCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Public profile'**
  String get publicCardTitle;

  /// No description provided for @publicPageNote.
  ///
  /// In en, this message translates to:
  /// **'This page is public — a clinic or registrar can open it from the QR code without an Ejadah account.'**
  String get publicPageNote;

  /// No description provided for @pwRule.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters with a letter and a number'**
  String get pwRule;

  /// No description provided for @q1.
  ///
  /// In en, this message translates to:
  /// **'Do you want to keep treating patients?'**
  String get q1;

  /// No description provided for @q2.
  ///
  /// In en, this message translates to:
  /// **'Which path fits you?'**
  String get q2;

  /// No description provided for @q3.
  ///
  /// In en, this message translates to:
  /// **'About you'**
  String get q3;

  /// No description provided for @q4.
  ///
  /// In en, this message translates to:
  /// **'What can you actually afford?'**
  String get q4;

  /// No description provided for @q4sub.
  ///
  /// In en, this message translates to:
  /// **'Be honest — the plan is built around these, not around what looks impressive.'**
  String get q4sub;

  /// No description provided for @q5.
  ///
  /// In en, this message translates to:
  /// **'Where and why'**
  String get q5;

  /// No description provided for @qualificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'QUALIFICATIONS'**
  String get qualificationsLabel;

  /// No description provided for @quiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get quiz;

  /// No description provided for @quizOfferSession.
  ///
  /// In en, this message translates to:
  /// **'Below 60%. One session on this topic often fixes it.'**
  String get quizOfferSession;

  /// No description provided for @quizScore.
  ///
  /// In en, this message translates to:
  /// **'{score}% — {correct} of {total}'**
  String quizScore(Object correct, Object score, Object total);

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'rating'**
  String get rating;

  /// No description provided for @recognitionBody.
  ///
  /// In en, this message translates to:
  /// **'Egypt, UAE, Saudi Arabia and Qatar labels exist in the source data but their status was lost in extraction. We show nothing rather than guess.'**
  String get recognitionBody;

  /// No description provided for @recognitionLabel.
  ///
  /// In en, this message translates to:
  /// **'RECOGNITION'**
  String get recognitionLabel;

  /// No description provided for @recognitionNotice.
  ///
  /// In en, this message translates to:
  /// **'Recognition status not yet verified per country'**
  String get recognitionNotice;

  /// No description provided for @refundIfCancelled.
  ///
  /// In en, this message translates to:
  /// **'You\'ll be refunded {amount} of {total}.'**
  String refundIfCancelled(Object amount, Object total);

  /// No description provided for @regionEurope.
  ///
  /// In en, this message translates to:
  /// **'Europe'**
  String get regionEurope;

  /// No description provided for @regionGulf.
  ///
  /// In en, this message translates to:
  /// **'Gulf'**
  String get regionGulf;

  /// No description provided for @regionLabel.
  ///
  /// In en, this message translates to:
  /// **'REGION'**
  String get regionLabel;

  /// No description provided for @regionNorthAmerica.
  ///
  /// In en, this message translates to:
  /// **'North America'**
  String get regionNorthAmerica;

  /// No description provided for @regionStayEgypt.
  ///
  /// In en, this message translates to:
  /// **'Stay in Egypt'**
  String get regionStayEgypt;

  /// No description provided for @regionUkIreland.
  ///
  /// In en, this message translates to:
  /// **'UK & Ireland'**
  String get regionUkIreland;

  /// No description provided for @registerSub.
  ///
  /// In en, this message translates to:
  /// **'Two minutes now saves you a month of guessing later.'**
  String get registerSub;

  /// No description provided for @requestsLink.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requestsLink;

  /// No description provided for @reschedule.
  ///
  /// In en, this message translates to:
  /// **'Reschedule'**
  String get reschedule;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Send it again'**
  String get resendCode;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Send again in {seconds}s'**
  String resendIn(Object seconds);

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// No description provided for @resultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} programmes'**
  String resultsCount(Object count);

  /// No description provided for @resumeLesson.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resumeLesson;

  /// No description provided for @retakeQuiz.
  ///
  /// In en, this message translates to:
  /// **'Try the quiz again'**
  String get retakeQuiz;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @reviewBooking.
  ///
  /// In en, this message translates to:
  /// **'Review your booking'**
  String get reviewBooking;

  /// No description provided for @reviewBookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Review your booking'**
  String get reviewBookingTitle;

  /// No description provided for @reviewTimeline.
  ///
  /// In en, this message translates to:
  /// **'We review applications within five working days and reply either way.'**
  String get reviewTimeline;

  /// No description provided for @reviewsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} reviews'**
  String reviewsCount(Object count);

  /// No description provided for @reviewsLabel.
  ///
  /// In en, this message translates to:
  /// **'REVIEWS'**
  String get reviewsLabel;

  /// No description provided for @roadmapCtaAction.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get roadmapCtaAction;

  /// No description provided for @roadmapCtaBody.
  ///
  /// In en, this message translates to:
  /// **'Answer five short questions and get a route built around your real budget and time — not around a Master\'s you never asked for.'**
  String get roadmapCtaBody;

  /// No description provided for @roadmapCtaEyebrow.
  ///
  /// In en, this message translates to:
  /// **'TAKES 3 MINUTES'**
  String get roadmapCtaEyebrow;

  /// No description provided for @roadmapCtaTitle.
  ///
  /// In en, this message translates to:
  /// **'Build your career roadmap'**
  String get roadmapCtaTitle;

  /// No description provided for @roadmapFunnelBody.
  ///
  /// In en, this message translates to:
  /// **'Five short questions. Your real budget and time are hard limits, and remote work from Egypt counts as a destination.'**
  String get roadmapFunnelBody;

  /// No description provided for @roadmapLabel.
  ///
  /// In en, this message translates to:
  /// **'YOUR ROADMAP'**
  String get roadmapLabel;

  /// No description provided for @roadmapProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} stages done'**
  String roadmapProgress(Object done, Object total);

  /// No description provided for @roadmapStageLabel.
  ///
  /// In en, this message translates to:
  /// **'STAGE 2 OF 5'**
  String get roadmapStageLabel;

  /// No description provided for @routeToHere.
  ///
  /// In en, this message translates to:
  /// **'Is this my best route?'**
  String get routeToHere;

  /// No description provided for @rowBilling.
  ///
  /// In en, this message translates to:
  /// **'Billing'**
  String get rowBilling;

  /// No description provided for @rowBookings.
  ///
  /// In en, this message translates to:
  /// **'My bookings'**
  String get rowBookings;

  /// No description provided for @rowCertificates.
  ///
  /// In en, this message translates to:
  /// **'Certificates'**
  String get rowCertificates;

  /// No description provided for @rowMembership.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get rowMembership;

  /// No description provided for @rowNfc.
  ///
  /// In en, this message translates to:
  /// **'NFC card'**
  String get rowNfc;

  /// No description provided for @rowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get rowNotifications;

  /// No description provided for @rowRoadmap.
  ///
  /// In en, this message translates to:
  /// **'My roadmap'**
  String get rowRoadmap;

  /// No description provided for @rowSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get rowSettings;

  /// No description provided for @rowShortlist.
  ///
  /// In en, this message translates to:
  /// **'My shortlist'**
  String get rowShortlist;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @saveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save as draft'**
  String get saveDraft;

  /// No description provided for @saveProg.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveProg;

  /// No description provided for @saveSearch.
  ///
  /// In en, this message translates to:
  /// **'Save this search'**
  String get saveSearch;

  /// No description provided for @saveSearchName.
  ///
  /// In en, this message translates to:
  /// **'Name it'**
  String get saveSearchName;

  /// No description provided for @savedProg.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedProg;

  /// No description provided for @savedSearchDone.
  ///
  /// In en, this message translates to:
  /// **'Saved. We\'ll tell you when new programmes match.'**
  String get savedSearchDone;

  /// No description provided for @savedSearchLimit.
  ///
  /// In en, this message translates to:
  /// **'You can watch up to {count} searches.'**
  String savedSearchLimit(Object count);

  /// No description provided for @savedSearches.
  ///
  /// In en, this message translates to:
  /// **'Saved searches'**
  String get savedSearches;

  /// No description provided for @savedToast.
  ///
  /// In en, this message translates to:
  /// **'Saved to your shortlist'**
  String get savedToast;

  /// No description provided for @schNo.
  ///
  /// In en, this message translates to:
  /// **'None listed'**
  String get schNo;

  /// No description provided for @schYes.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get schYes;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'University, programme or city'**
  String get searchPlaceholder;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @seeAllDeadlines.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAllDeadlines;

  /// No description provided for @seeBookings.
  ///
  /// In en, this message translates to:
  /// **'See my bookings'**
  String get seeBookings;

  /// No description provided for @seeProgrammesHere.
  ///
  /// In en, this message translates to:
  /// **'See programmes here'**
  String get seeProgrammesHere;

  /// No description provided for @sendLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendLink;

  /// No description provided for @sessionDetails.
  ///
  /// In en, this message translates to:
  /// **'Session details'**
  String get sessionDetails;

  /// No description provided for @sessionFee.
  ///
  /// In en, this message translates to:
  /// **'Session fee'**
  String get sessionFee;

  /// No description provided for @sessionUpcoming.
  ///
  /// In en, this message translates to:
  /// **'YOUR NEXT SESSION'**
  String get sessionUpcoming;

  /// No description provided for @sessionsLabel.
  ///
  /// In en, this message translates to:
  /// **'sessions'**
  String get sessionsLabel;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share card'**
  String get share;

  /// No description provided for @shareCard.
  ///
  /// In en, this message translates to:
  /// **'Share my card'**
  String get shareCard;

  /// No description provided for @shareRoadmap.
  ///
  /// In en, this message translates to:
  /// **'Share my route'**
  String get shareRoadmap;

  /// No description provided for @shareRoadmapMessage.
  ///
  /// In en, this message translates to:
  /// **'My route to {destination}, mapped on Ejadah.'**
  String shareRoadmapMessage(Object destination);

  /// No description provided for @shareVerify.
  ///
  /// In en, this message translates to:
  /// **'Share verification'**
  String get shareVerify;

  /// No description provided for @shareWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Share on WhatsApp'**
  String get shareWhatsapp;

  /// No description provided for @shortlistTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved programmes'**
  String get shortlistTitle;

  /// No description provided for @showExpired.
  ///
  /// In en, this message translates to:
  /// **'Show expired'**
  String get showExpired;

  /// No description provided for @showResults.
  ///
  /// In en, this message translates to:
  /// **'Show results'**
  String get showResults;

  /// No description provided for @showingRange.
  ///
  /// In en, this message translates to:
  /// **'{first}–{last} of {total}'**
  String showingRange(Object first, Object last, Object total);

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signInToSave.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save'**
  String get signInToSave;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUp;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @slotTakenBody.
  ///
  /// In en, this message translates to:
  /// **'Someone booked that time a moment ago. Here\'s what\'s still open.'**
  String get slotTakenBody;

  /// No description provided for @slotTakenTitle.
  ///
  /// In en, this message translates to:
  /// **'That time just went'**
  String get slotTakenTitle;

  /// No description provided for @slotUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Already booked'**
  String get slotUnavailable;

  /// No description provided for @sourceMissing.
  ///
  /// In en, this message translates to:
  /// **'No official source URL in this record — verify before applying.'**
  String get sourceMissing;

  /// No description provided for @sourcesLabel.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get sourcesLabel;

  /// No description provided for @specAll.
  ///
  /// In en, this message translates to:
  /// **'All specialties'**
  String get specAll;

  /// No description provided for @specDigital.
  ///
  /// In en, this message translates to:
  /// **'DIGITAL'**
  String get specDigital;

  /// No description provided for @specEndo.
  ///
  /// In en, this message translates to:
  /// **'ENDODONTICS'**
  String get specEndo;

  /// No description provided for @splitNote.
  ///
  /// In en, this message translates to:
  /// **'Every session shows the gross fee, the 30% platform fee and your 70% net. Payouts are processed on the website.'**
  String get splitNote;

  /// No description provided for @stageConsultantOwner.
  ///
  /// In en, this message translates to:
  /// **'Consultant or owner'**
  String get stageConsultantOwner;

  /// No description provided for @stageFreshGraduate.
  ///
  /// In en, this message translates to:
  /// **'Fresh graduate'**
  String get stageFreshGraduate;

  /// No description provided for @stageGeneralDentist.
  ///
  /// In en, this message translates to:
  /// **'GP dentist'**
  String get stageGeneralDentist;

  /// No description provided for @stageOf.
  ///
  /// In en, this message translates to:
  /// **'Stage {n} of {total}'**
  String stageOf(Object n, Object total);

  /// No description provided for @stageSpecialist.
  ///
  /// In en, this message translates to:
  /// **'Specialist'**
  String get stageSpecialist;

  /// No description provided for @stageStudent.
  ///
  /// In en, this message translates to:
  /// **'Dental student'**
  String get stageStudent;

  /// No description provided for @startCourse.
  ///
  /// In en, this message translates to:
  /// **'Start course'**
  String get startCourse;

  /// No description provided for @startNow.
  ///
  /// In en, this message translates to:
  /// **'START THIS MONTH'**
  String get startNow;

  /// No description provided for @startOver.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get startOver;

  /// No description provided for @statedByTutor.
  ///
  /// In en, this message translates to:
  /// **'Stated by the tutor'**
  String get statedByTutor;

  /// No description provided for @stepOfSteps.
  ///
  /// In en, this message translates to:
  /// **'Step {n} of {total}'**
  String stepOfSteps(Object n, Object total);

  /// No description provided for @storePurchaseNote.
  ///
  /// In en, this message translates to:
  /// **'Charged by the app store. Restore purchases any time.'**
  String get storePurchaseNote;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'12-day streak'**
  String get streak;

  /// No description provided for @stubBody.
  ///
  /// In en, this message translates to:
  /// **'This tab is next in the build order. The shell, tab bar and language switching are already wired.'**
  String get stubBody;

  /// No description provided for @subjectsLabel.
  ///
  /// In en, this message translates to:
  /// **'SUBJECTS'**
  String get subjectsLabel;

  /// No description provided for @submitApplication.
  ///
  /// In en, this message translates to:
  /// **'Submit application'**
  String get submitApplication;

  /// No description provided for @sysCameraDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'Scanning a card needs the camera. You can turn it on in Settings.'**
  String get sysCameraDeniedBody;

  /// No description provided for @sysCameraDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera is off'**
  String get sysCameraDeniedTitle;

  /// No description provided for @sysContentUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'This is no longer available'**
  String get sysContentUnavailableTitle;

  /// No description provided for @sysErrorBoundaryBody.
  ///
  /// In en, this message translates to:
  /// **'This screen stopped working. Going back to Home is the quickest way on.'**
  String get sysErrorBoundaryBody;

  /// No description provided for @sysErrorBoundaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Something broke on this screen'**
  String get sysErrorBoundaryTitle;

  /// No description provided for @sysForceUpdateBody.
  ///
  /// In en, this message translates to:
  /// **'This version can no longer talk to our servers.'**
  String get sysForceUpdateBody;

  /// No description provided for @sysForceUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update to continue'**
  String get sysForceUpdateTitle;

  /// No description provided for @sysMaintenanceBody.
  ///
  /// In en, this message translates to:
  /// **'We are back shortly. Nothing you saved is affected.'**
  String get sysMaintenanceBody;

  /// No description provided for @sysMaintenanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Ejadah is being updated'**
  String get sysMaintenanceTitle;

  /// No description provided for @sysNotifDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'Deadline warnings need permission. You can turn it on in Settings.'**
  String get sysNotifDeniedBody;

  /// No description provided for @sysNotifDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off'**
  String get sysNotifDeniedTitle;

  /// No description provided for @sysOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. We\'ll retry as soon as the connection is back.'**
  String get sysOfflineBody;

  /// No description provided for @sysOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'You are offline'**
  String get sysOfflineTitle;

  /// No description provided for @sysOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get sysOpenSettings;

  /// No description provided for @sysRateLimitedBody.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in two minutes.'**
  String get sysRateLimitedBody;

  /// No description provided for @sysRateLimitedTitle.
  ///
  /// In en, this message translates to:
  /// **'Take a short break'**
  String get sysRateLimitedTitle;

  /// No description provided for @sysServerErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our side'**
  String get sysServerErrorTitle;

  /// No description provided for @sysSessionExpiredBody.
  ///
  /// In en, this message translates to:
  /// **'Sign in again and you\'ll come straight back to where you were.'**
  String get sysSessionExpiredBody;

  /// No description provided for @sysSessionExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again'**
  String get sysSessionExpiredTitle;

  /// No description provided for @sysUpdateAction.
  ///
  /// In en, this message translates to:
  /// **'Update the app'**
  String get sysUpdateAction;

  /// No description provided for @tabCareer.
  ///
  /// In en, this message translates to:
  /// **'Career'**
  String get tabCareer;

  /// No description provided for @tabConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get tabConnect;

  /// No description provided for @tabCourses.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get tabCourses;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get tabLearn;

  /// No description provided for @tabMasters.
  ///
  /// In en, this message translates to:
  /// **'Postgrad'**
  String get tabMasters;

  /// No description provided for @tabPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get tabPeople;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @tapToFlip.
  ///
  /// In en, this message translates to:
  /// **'Tap to flip'**
  String get tapToFlip;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get terms;

  /// No description provided for @theRoute.
  ///
  /// In en, this message translates to:
  /// **'THE ROUTE, STAGE BY STAGE'**
  String get theRoute;

  /// No description provided for @tileCertificates.
  ///
  /// In en, this message translates to:
  /// **'Certificates'**
  String get tileCertificates;

  /// No description provided for @tileCertificatesMeta.
  ///
  /// In en, this message translates to:
  /// **'Download & share'**
  String get tileCertificatesMeta;

  /// No description provided for @tileCountries.
  ///
  /// In en, this message translates to:
  /// **'Country guides'**
  String get tileCountries;

  /// No description provided for @tileCountriesMeta.
  ///
  /// In en, this message translates to:
  /// **'23 licensing routes'**
  String get tileCountriesMeta;

  /// No description provided for @tileProgrammes.
  ///
  /// In en, this message translates to:
  /// **'Postgraduate programmes'**
  String get tileProgrammes;

  /// No description provided for @tileProgrammesMeta.
  ///
  /// In en, this message translates to:
  /// **'199 records · 6 regions'**
  String get tileProgrammesMeta;

  /// No description provided for @tileShortlist.
  ///
  /// In en, this message translates to:
  /// **'My shortlist'**
  String get tileShortlist;

  /// No description provided for @tileShortlistMeta.
  ///
  /// In en, this message translates to:
  /// **'4 programmes saved'**
  String get tileShortlistMeta;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'STUDY TIME'**
  String get timeLabel;

  /// No description provided for @timezoneNote.
  ///
  /// In en, this message translates to:
  /// **'Times shown in Cairo time (GMT+2).'**
  String get timezoneNote;

  /// No description provided for @toolsLabel.
  ///
  /// In en, this message translates to:
  /// **'TOOLS'**
  String get toolsLabel;

  /// No description provided for @topic.
  ///
  /// In en, this message translates to:
  /// **'TOPIC'**
  String get topic;

  /// No description provided for @totalTime.
  ///
  /// In en, this message translates to:
  /// **'total time'**
  String get totalTime;

  /// No description provided for @tryPayAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryPayAgain;

  /// No description provided for @tutorBio.
  ///
  /// In en, this message translates to:
  /// **'Consultant endodontist at a Cairo referral practice, teaching microscope-assisted retreatment. Sessions run on real cases you bring — radiographs, working lengths and all.'**
  String get tutorBio;

  /// No description provided for @tutoringBlurb.
  ///
  /// In en, this message translates to:
  /// **'For students — TAs, lecturers and top grads teach a subject or a whole year, weekly or as exam prep.'**
  String get tutoringBlurb;

  /// No description provided for @tutoringTitle.
  ///
  /// In en, this message translates to:
  /// **'Tutoring'**
  String get tutoringTitle;

  /// No description provided for @tutorsLabel.
  ///
  /// In en, this message translates to:
  /// **'TUTORS FOR YOU'**
  String get tutorsLabel;

  /// No description provided for @tutorsSub.
  ///
  /// In en, this message translates to:
  /// **'Matched to endodontics, your saved specialty.'**
  String get tutorsSub;

  /// No description provided for @typeDeleteToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE to confirm'**
  String get typeDeleteToConfirm;

  /// No description provided for @typicalCost.
  ///
  /// In en, this message translates to:
  /// **'typical cost'**
  String get typicalCost;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @undoRemove.
  ///
  /// In en, this message translates to:
  /// **'Removed from your shortlist'**
  String get undoRemove;

  /// No description provided for @upcomingLabel.
  ///
  /// In en, this message translates to:
  /// **'UPCOMING'**
  String get upcomingLabel;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'Good morning, Yasmine'**
  String get userName;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get verificationCode;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'VERIFIED CERTIFICATE'**
  String get verified;

  /// No description provided for @verifiedByEjadah.
  ///
  /// In en, this message translates to:
  /// **'Verified by Ejadah'**
  String get verifiedByEjadah;

  /// No description provided for @verifiedTutor.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verifiedTutor;

  /// No description provided for @verifyEmailAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get verifyEmailAction;

  /// No description provided for @verifyEmailBody.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to {email}. Enter it to finish setting up your account.'**
  String verifyEmailBody(Object email);

  /// No description provided for @verifyEmailDone.
  ///
  /// In en, this message translates to:
  /// **'Email confirmed'**
  String get verifyEmailDone;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyLater.
  ///
  /// In en, this message translates to:
  /// **'Do this later'**
  String get verifyLater;

  /// No description provided for @verifyNotFound.
  ///
  /// In en, this message translates to:
  /// **'No certificate with that code'**
  String get verifyNotFound;

  /// No description provided for @verifyNote.
  ///
  /// In en, this message translates to:
  /// **'Every certificate carries a public verification page a clinic or registrar can check without an account.'**
  String get verifyNote;

  /// No description provided for @verifyRevoked.
  ///
  /// In en, this message translates to:
  /// **'This certificate was revoked'**
  String get verifyRevoked;

  /// No description provided for @verifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Certificate check'**
  String get verifyTitle;

  /// No description provided for @verifyValid.
  ///
  /// In en, this message translates to:
  /// **'This certificate is valid'**
  String get verifyValid;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionLabel;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get viewDetails;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get viewProfile;

  /// No description provided for @visaRoute.
  ///
  /// In en, this message translates to:
  /// **'VISA ROUTE'**
  String get visaRoute;

  /// No description provided for @watchOut.
  ///
  /// In en, this message translates to:
  /// **'WATCH OUT'**
  String get watchOut;

  /// No description provided for @webOnly.
  ///
  /// In en, this message translates to:
  /// **'Opens ejadah.com'**
  String get webOnly;

  /// No description provided for @weekLabel.
  ///
  /// In en, this message translates to:
  /// **'Week {n}'**
  String weekLabel(Object n);

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @whatIf.
  ///
  /// In en, this message translates to:
  /// **'WHAT IF'**
  String get whatIf;

  /// No description provided for @whatIfSub.
  ///
  /// In en, this message translates to:
  /// **'Change one variable and the whole route recalculates.'**
  String get whatIfSub;

  /// No description provided for @whatYouGet.
  ///
  /// In en, this message translates to:
  /// **'WHAT YOU GET'**
  String get whatYouGet;

  /// No description provided for @whatYouLearn.
  ///
  /// In en, this message translates to:
  /// **'WHAT YOU WILL LEARN'**
  String get whatYouLearn;

  /// No description provided for @wifiOnlyDownloads.
  ///
  /// In en, this message translates to:
  /// **'Download over Wi-Fi only'**
  String get wifiOnlyDownloads;

  /// No description provided for @withdrawWeb.
  ///
  /// In en, this message translates to:
  /// **'Withdraw on ejadah.com'**
  String get withdrawWeb;

  /// No description provided for @writeNfc.
  ///
  /// In en, this message translates to:
  /// **'Write to NFC'**
  String get writeNfc;

  /// No description provided for @yearsLabel.
  ///
  /// In en, this message translates to:
  /// **'yrs qualified'**
  String get yearsLabel;

  /// No description provided for @yearsSince.
  ///
  /// In en, this message translates to:
  /// **'YEARS SINCE QUALIFYING'**
  String get yearsSince;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get yes;

  /// No description provided for @youKeep.
  ///
  /// In en, this message translates to:
  /// **'You keep (70%)'**
  String get youKeep;

  /// No description provided for @yourRate.
  ///
  /// In en, this message translates to:
  /// **'YOUR HOURLY RATE'**
  String get yourRate;

  /// No description provided for @yourStage.
  ///
  /// In en, this message translates to:
  /// **'WHERE YOU ARE NOW'**
  String get yourStage;
}

class _EjadahStringsDelegate extends LocalizationsDelegate<EjadahStrings> {
  const _EjadahStringsDelegate();

  @override
  Future<EjadahStrings> load(Locale locale) {
    return SynchronousFuture<EjadahStrings>(lookupEjadahStrings(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_EjadahStringsDelegate old) => false;
}

EjadahStrings lookupEjadahStrings(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return EjadahStringsAr();
    case 'en':
      return EjadahStringsEn();
  }

  throw FlutterError(
    'EjadahStrings.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
