import 'package:ejadah_models/ejadah_models.dart';

/// A destination the generator may consider, assembled from Ejadah's own rows.
class RoadmapCandidate {
  const RoadmapCandidate({
    required this.iso,
    required this.name,
    required this.region,
    required this.pathwayClass,
    required this.examCode,
    required this.minMonths,
    required this.maxMonths,
    required this.floorCostUsd,
    required this.floorCostComplete,
    required this.requiredLanguages,
    required this.steps,
    required this.stepCosts,
    required this.authority,
  });

  final String iso;
  final LocalizedText name;
  final String region;
  final PathwayClass pathwayClass;
  final String examCode;
  final int minMonths;
  final int maxMonths;

  /// Null where the guide's cost table is entirely unsourced — a real state,
  /// never treated as zero.
  final int? floorCostUsd;

  /// Whether every cost row behind [floorCostUsd] was sourced. A partial floor
  /// understates the true cost, so it must not win a tie-break against a
  /// fully-documented one.
  final bool floorCostComplete;
  final List<String> requiredLanguages;

  /// The guide's own steps, in order. Stages are copied from these verbatim.
  final List<CountryStep> steps;

  /// Per-step cost, by step position. Absent entries print "Pending source".
  final Map<int, Sourced<String>> stepCosts;
  final LocalizedText authority;
}

/// The scoring constants.
///
/// Named, in one place, and covered by tests. The formula is fixed: changing a
/// number here changes every roadmap the product will ever produce, which is
/// exactly why they are not scattered through the code.
abstract final class RoadmapConstants {
  /// Every candidate starts here.
  ///
  /// The bonuses below sum to a maximum of 90, deliberately short of the 100
  /// clamp: a screen full of identical "100% fit" scores tells the user
  /// nothing, and claiming a perfect fit is not a claim this product's voice
  /// would make. [maxAttainableScore] asserts that arithmetic in a test.
  static const int baseScore = 30;

  /// The destination's region is one the user asked for.
  static const int regionMatchBonus = 16;

  /// The user speaks everything the route requires.
  static const int languageMatchBonus = 9;

  /// The route needs a language the user did not list. Not disqualifying — the
  /// guide's own first step is usually "reach B2" — but honestly costly.
  static const int languageGapPenalty = 18;

  /// Route shape. A recognition-only pathway is genuinely easier than one that
  /// stacks a language qualification on top of a clinical exam.
  static const Map<PathwayClass, int> pathwayWeights = {
    PathwayClass.fast: 11,
    PathwayClass.exam: 7,
    PathwayClass.language: -4,
    PathwayClass.complex: -10,
  };

  /// The user's chosen direction lines up with what this destination offers.
  static const int pathAlignmentBonus = 7;

  /// Speed within the user's own time budget, worth up to this much.
  ///
  /// Without it every affordable Gulf route scores identically and the ordering
  /// falls entirely to the tie-break. A route that finishes in a third of the
  /// available time is genuinely a better answer than one that just fits.
  static const int speedBonusMax = 10;

  /// Room left in the user's budget, worth up to this much, on the same
  /// reasoning as [speedBonusMax].
  static const int headroomBonusMax = 7;

  /// A hard ceiling for any destination the user cannot afford.
  ///
  /// "An unaffordable destination is mathematically incapable of scoring above
  /// 60" — enforced by clamping, not by hoping the penalties add up.
  static const int unaffordableCeiling = 60;

  /// Applied on top of the ceiling, one step per 25% over budget.
  static const int budgetOverageStepPenalty = 8;

  /// Same idea for time: over the user's stated months, capped like budget.
  static const int timeOverageStepPenalty = 6;

  /// Below this, a destination is not offered as an alternative at all.
  static const int minimumAlternativeScore = 25;

  /// How many runners-up the result shows.
  static const int alternativeCount = 3;

  /// The highest score the formula can actually produce.
  ///
  /// Kept below 100 on purpose so the clamp is never what decides a winner. A
  /// test pins this against the constants above, so raising a bonus without
  /// re-checking the ceiling fails the build rather than silently flattening
  /// every score to 100.
  static int get maxAttainableScore =>
      baseScore +
      regionMatchBonus +
      languageMatchBonus +
      pathAlignmentBonus +
      speedBonusMax +
      headroomBonusMax +
      pathwayWeights.values.reduce((a, b) => a > b ? a : b);
}

/// A scored candidate, with the reasons attached.
class ScoredCandidate implements Comparable<ScoredCandidate> {
  const ScoredCandidate({
    required this.candidate,
    required this.score,
    required this.overBudgetBy,
    required this.overTimeBy,
    required this.regionMatched,
    required this.languageMatched,
  });

  final RoadmapCandidate candidate;
  final int score;

  /// USD above the user's ceiling, or 0.
  final int overBudgetBy;

  /// Months above the user's ceiling, or 0.
  final int overTimeBy;
  final bool regionMatched;
  final bool languageMatched;

  bool get isAffordable => overBudgetBy == 0;

  bool get fitsTime => overTimeBy == 0;

  /// The deterministic ordering.
  ///
  /// Score descending, then fully-sourced costs, then the lower cost floor, then
  /// the country code. Never insertion order and never an unordered query
  /// result — "same inputs, same output" must not quietly depend on undefined
  /// behaviour.
  @override
  int compareTo(ScoredCandidate other) {
    final byScore = other.score.compareTo(score);
    if (byScore != 0) return byScore;

    // A guide whose cost table has gaps has an artificially low floor, because
    // unsourced rows contribute nothing to it. Preferring the fully-documented
    // destination at equal score stops missing data from reading as cheapness.
    final byCompleteness = _completenessRank.compareTo(other._completenessRank);
    if (byCompleteness != 0) return byCompleteness;

    // A missing cost floor sorts last: an unknown cost cannot win a tie-break
    // against a known one.
    final mine = candidate.floorCostUsd ?? 1 << 30;
    final theirs = other.candidate.floorCostUsd ?? 1 << 30;
    final byCost = mine.compareTo(theirs);
    if (byCost != 0) return byCost;

    return candidate.iso.compareTo(other.candidate.iso);
  }

  /// 0 = every cost row sourced, 1 = partially sourced, 2 = nothing sourced.
  int get _completenessRank => candidate.floorCostUsd == null
      ? 2
      : candidate.floorCostComplete
      ? 0
      : 1;
}

/// The scored field, in two views.
///
/// [eligible] is what the winner may be drawn from after the preference tiers
/// are applied; [all] keeps every scored destination so the runners-up can
/// still be shown, including ones a tier ruled out.
class ScoredCandidates {
  const ScoredCandidates({required this.all, required this.eligible});

  /// Every applicable destination, best first.
  final List<ScoredCandidate> all;

  /// The destinations that survived the preference tiers, best first.
  final List<ScoredCandidate> eligible;

  ScoredCandidate get winner => eligible.first;
}

/// The generated result, before it is persisted.
class GeneratedRoadmap {
  const GeneratedRoadmap({
    required this.destinationIso,
    required this.destinationName,
    required this.fitScore,
    required this.headline,
    required this.summary,
    required this.watchOut,
    required this.thisMonthAction,
    required this.stages,
    required this.alternatives,
  });

  final String? destinationIso;
  final LocalizedText destinationName;
  final int fitScore;
  final LocalizedText headline;
  final LocalizedText summary;
  final LocalizedText watchOut;
  final LocalizedText thisMonthAction;
  final List<RoadmapStage> stages;
  final List<RoadmapAlternative> alternatives;
}

/// The deterministic roadmap generator.
///
/// filter → score → assemble, over Ejadah's own rows. No model call, no
/// inference, no external lookup: the same answers against the same reference
/// data always produce the same roadmap, and that reproducibility is the trust
/// claim the whole feature rests on.
///
/// [today] is a parameter rather than a call to `DateTime.now()` so the output
/// is a pure function of its inputs and can be asserted in a test.
class RoadmapEngine {
  const RoadmapEngine();

  GeneratedRoadmap generate({
    required RoadmapAnswers answers,
    required List<RoadmapCandidate> candidates,
    required DateTime today,
    Map<String, int> courseIdByExamCode = const {},
  }) {
    final scored = _filterAndScore(answers, candidates);

    if (scored.all.isEmpty) {
      // Only reachable with an empty reference dataset. Rather than invent a
      // destination, the generator says so plainly.
      return _noDestinationResult(answers, today);
    }

    final winner = scored.winner;
    final alternatives = scored.all
        .where((c) => c.candidate.iso != winner.candidate.iso)
        .where((c) => c.score >= RoadmapConstants.minimumAlternativeScore)
        .take(RoadmapConstants.alternativeCount)
        .map(
          (c) => RoadmapAlternative(
            countryIso: c.candidate.iso,
            countryName: c.candidate.name,
            fitScore: c.score,
            reason: _alternativeReason(c),
          ),
        )
        .toList();

    return GeneratedRoadmap(
      destinationIso: winner.candidate.iso,
      destinationName: winner.candidate.name,
      fitScore: winner.score,
      headline: _headline(winner, answers),
      summary: _summary(winner, answers),
      watchOut: _watchOut(winner, answers),
      thisMonthAction: _thisMonthAction(winner),
      stages: _stages(winner, today, courseIdByExamCode),
      alternatives: alternatives,
    );
  }

  /// Exposed for tests and for the what-if comparison view.
  ScoredCandidates scoreAll(
    RoadmapAnswers answers,
    List<RoadmapCandidate> candidates,
  ) => _filterAndScore(answers, candidates);

  // --- 1 · FILTER -----------------------------------------------------------

  /// Narrows the field in tiers, most binding first.
  ///
  /// Each tier is only applied when it leaves something behind, so the
  /// generator always has an answer and never silently drops the user's stated
  /// constraints without saying so in the watch-out.
  ScoredCandidates _filterAndScore(
    RoadmapAnswers answers,
    List<RoadmapCandidate> candidates,
  ) {
    final scored = candidates
        .where((candidate) => _isApplicableToPath(candidate, answers))
        .map((candidate) => _score(candidate, answers))
        .toList()
      ..sort();

    if (scored.isEmpty) {
      return const ScoredCandidates(all: [], eligible: []);
    }

    // Tier 1 — budget and study time are ceilings, not preferences. A route the
    // user cannot afford is a wrong answer, so anything inside both wins over
    // anything outside either. The rest survive only as flagged last resorts.
    var eligible = scored.where((c) => c.isAffordable && c.fitsTime).toList();
    if (eligible.isEmpty) eligible = scored;

    // Tier 2 — the user named their regions. A destination they did not ask for
    // must not beat one they did, however well it scores on speed or cost;
    // answering an unasked question is not a better answer. Out-of-region
    // destinations still appear as alternatives, so nothing is hidden.
    final inRegion = eligible.where((c) => c.regionMatched).toList();
    if (inRegion.isNotEmpty) eligible = inRegion;

    return ScoredCandidates(all: scored, eligible: eligible);
  }

  /// Direction gates which destinations may be recommended at all.
  ///
  /// A user who chose digital or business work must never be handed a licensing
  /// exam or a clinical Master's — that is the wrong answer to the question they
  /// asked, no matter how well it scores.
  bool _isApplicableToPath(RoadmapCandidate candidate, RoadmapAnswers answers) {
    if (!answers.path.allowsLicensingRoute) {
      // Digital and business routes are done from Egypt; the destination
      // question is about where the work is, not where the licence is.
      return candidate.iso == 'eg';
    }

    // The user asked to work abroad. Staying in Egypt only belongs in that
    // answer set if they also picked it as a region — otherwise the generator
    // would answer a question they did not ask, however well it scores.
    if (candidate.iso == 'eg') {
      return answers.regions.contains(RoadmapRegion.stayEgypt);
    }
    return true;
  }

  // --- 2 · SCORE ------------------------------------------------------------

  ScoredCandidate _score(RoadmapCandidate candidate, RoadmapAnswers answers) {
    final regionMatched = _regionMatches(candidate, answers.regions);
    final languageMatched = candidate.requiredLanguages.every(
      (required) => answers.languages.contains(required),
    );

    var score = RoadmapConstants.baseScore;
    if (regionMatched) score += RoadmapConstants.regionMatchBonus;
    score += RoadmapConstants.pathwayWeights[candidate.pathwayClass] ?? 0;
    score += languageMatched
        ? RoadmapConstants.languageMatchBonus
        : -RoadmapConstants.languageGapPenalty;

    if (_pathAligns(candidate, answers)) {
      score += RoadmapConstants.pathAlignmentBonus;
    }

    final floorCost = candidate.floorCostUsd;
    final overBudgetBy = floorCost == null || floorCost <= answers.budgetUsd
        ? 0
        : floorCost - answers.budgetUsd;
    final overTimeBy = candidate.minMonths <= answers.monthsAvailable
        ? 0
        : candidate.minMonths - answers.monthsAvailable;

    // Finishing well inside the user's own ceilings is a real advantage, and
    // scoring it is what separates six otherwise-identical Gulf routes.
    if (overTimeBy == 0 && answers.monthsAvailable > 0) {
      final used = candidate.minMonths / answers.monthsAvailable;
      score +=
          ((1 - used.clamp(0.0, 1.0)) * RoadmapConstants.speedBonusMax).round();
    }
    if (overBudgetBy == 0 && floorCost != null && answers.budgetUsd > 0) {
      final used = floorCost / answers.budgetUsd;
      score +=
          ((1 - used.clamp(0.0, 1.0)) * RoadmapConstants.headroomBonusMax)
              .round();
    }

    if (overBudgetBy > 0) {
      // Clamp first, then penalise: the ceiling is guaranteed by construction
      // rather than by the penalties happening to be large enough.
      score = score.clamp(0, RoadmapConstants.unaffordableCeiling);
      final quartersOver = (overBudgetBy * 4 / answers.budgetUsd).ceil();
      score -= quartersOver * RoadmapConstants.budgetOverageStepPenalty;
    }

    if (overTimeBy > 0) {
      score = score.clamp(0, RoadmapConstants.unaffordableCeiling);
      final quartersOver =
          (overTimeBy * 4 / answers.monthsAvailable).ceil();
      score -= quartersOver * RoadmapConstants.timeOverageStepPenalty;
    }

    return ScoredCandidate(
      candidate: candidate,
      score: score.clamp(0, 100),
      overBudgetBy: overBudgetBy,
      overTimeBy: overTimeBy,
      regionMatched: regionMatched,
      languageMatched: languageMatched,
    );
  }

  bool _regionMatches(RoadmapCandidate candidate, List<RoadmapRegion> regions) {
    if (regions.isEmpty) return false;
    return regions.any(
      (region) => _regionIsoSets[region]?.contains(candidate.iso) ?? false,
    );
  }

  /// Which country guides sit under each funnel region option.
  ///
  /// Derived from the 23 guides themselves; "Stay in Egypt" maps to Egypt's own
  /// guide, because staying is a route with its own steps, not an absence of one.
  static const Map<RoadmapRegion, Set<String>> _regionIsoSets = {
    RoadmapRegion.gulf: {'ae', 'sa', 'qa', 'kw', 'om', 'bh'},
    RoadmapRegion.ukIreland: {'gb', 'ie'},
    RoadmapRegion.europe: {'de', 'nl', 'se', 'ch', 'es', 'tr'},
    RoadmapRegion.northAmerica: {'us', 'ca'},
    RoadmapRegion.stayEgypt: {'eg'},
  };

  bool _pathAligns(RoadmapCandidate candidate, RoadmapAnswers answers) =>
      switch (answers.path) {
        // A GP wants to practise soonest: recognition-only and exam routes beat
        // routes that require a language qualification first.
        RoadmapPath.generalPractice =>
          candidate.pathwayClass == PathwayClass.fast ||
              candidate.pathwayClass == PathwayClass.exam,
        // Specialising means a taught programme, which the complex and language
        // markets are precisely the ones that offer.
        RoadmapPath.specialise =>
          candidate.pathwayClass == PathwayClass.complex ||
              candidate.pathwayClass == PathwayClass.language,
        RoadmapPath.digital || RoadmapPath.business => candidate.iso == 'eg',
      };

  // --- 3 · ASSEMBLE ---------------------------------------------------------

  /// Stages are copies of the winning guide's own step rows.
  ///
  /// The generator decides which steps appear and when; it never rewrites their
  /// text. Dates are projected forward from [today] across the guide's own
  /// stated duration.
  List<RoadmapStage> _stages(
    ScoredCandidate winner,
    DateTime today,
    Map<String, int> courseIdByExamCode,
  ) {
    final steps = winner.candidate.steps;
    if (steps.isEmpty) return const [];

    final totalMonths = winner.candidate.minMonths.clamp(1, 240);
    // Integer arithmetic throughout, so the projection cannot drift between
    // runs on different platforms.
    final daysTotal = totalMonths * 30;
    final perStep = (daysTotal / steps.length).floor().clamp(1, daysTotal);
    final start = DateTime.utc(today.year, today.month, today.day);

    return [
      for (var index = 0; index < steps.length; index++)
        RoadmapStage(
          position: index + 1,
          title: steps[index].title,
          detail: steps[index].detail,
          projectedStart: start.add(Duration(days: perStep * index)),
          projectedEnd: start.add(Duration(days: perStep * (index + 1))),
          isOptional: steps[index].isOptional,
          cost:
              winner.candidate.stepCosts[steps[index].position] ??
              const Sourced<String>.pending(),
          isComplete: false,
          sourceCountryIso: winner.candidate.iso,
          // Where Ejadah has a course for this exam, the stage links to it. It
          // never opens a practice question — exams are a cut feature.
          linkedCourseId: courseIdByExamCode[winner.candidate.examCode],
        ),
    ];
  }

  LocalizedText _headline(ScoredCandidate winner, RoadmapAnswers answers) {
    final name = winner.candidate.name;
    if (answers.path == RoadmapPath.digital) {
      return const LocalizedText(
        en: 'Digital work from Cairo, paid in USD',
        ar: 'العمل الرقمي من القاهرة بالدولار',
      );
    }
    if (answers.path == RoadmapPath.business) {
      return const LocalizedText(
        en: 'Business and industry, without a clinical Master’s',
        ar: 'الأعمال والصناعة بدون ماجستير إكليني',
      );
    }
    return LocalizedText(
      en: '${name.en} is your strongest route',
      ar: '${name.ar} أقوى مسار لك',
    );
  }

  LocalizedText _summary(ScoredCandidate winner, RoadmapAnswers answers) {
    final candidate = winner.candidate;
    final months = candidate.monthsLabelFor();
    return LocalizedText(
      en:
          '${candidate.examCode} through ${candidate.authority.en}. '
          'The guide puts this at $months months, and you gave yourself '
          '${answers.monthsAvailable}.',
      ar:
          '${candidate.examCode} عبر ${candidate.authority.ar}. '
          'يقدّر الدليل هذا بـ $months شهرًا، وأنت حددت '
          '${answers.monthsAvailable}.',
    );
  }

  /// Names the cost in plain figures. Never soft hedging.
  LocalizedText _watchOut(ScoredCandidate winner, RoadmapAnswers answers) {
    if (winner.overBudgetBy > 0) {
      return LocalizedText(
        en:
            'The typical cost runs about USD ${_thousands(winner.overBudgetBy)} '
            'above your stated budget.',
        ar:
            'التكلفة المعتادة تتجاوز ميزانيتك المعلنة بنحو '
            '${_thousands(winner.overBudgetBy)} دولار.',
      );
    }
    if (winner.overTimeBy > 0) {
      return LocalizedText(
        en:
            'This route typically takes ${winner.overTimeBy} months longer than '
            'the time you gave yourself.',
        ar:
            'يستغرق هذا المسار عادة ${winner.overTimeBy} شهرًا أكثر من الوقت '
            'الذي حددته.',
      );
    }
    // A destination outside the regions the user asked for is the bigger
    // surprise, so it is named before the language gap.
    if (!winner.regionMatched) {
      return LocalizedText(
        en:
            '${winner.candidate.name.en} was not among the regions you picked. '
            'It scored highest on your budget and time.',
        ar:
            '${winner.candidate.name.ar} ليست ضمن المناطق التي اخترتها. '
            'لكنها الأعلى ملاءمة لميزانيتك ووقتك.',
      );
    }
    if (!winner.languageMatched) {
      final missing = winner.candidate.requiredLanguages
          .where((code) => !answers.languages.contains(code))
          .toList();
      final names = _languageNames(missing);
      return LocalizedText(
        en:
            'This route requires ${names.en} before clinical work. '
            'The language stage is the one that slips.',
        ar:
            'يتطلب هذا المسار ${names.ar} قبل العمل الإكليني. '
            'مرحلة اللغة هي التي تتأخر عادة.',
      );
    }
    return LocalizedText(
      en:
          'Fees and registration rules change. Confirm every figure with '
          '${winner.candidate.authority.en} before you commit money.',
      ar:
          'تتغير الرسوم وقواعد التسجيل. تأكّد من كل رقم لدى '
          '${winner.candidate.authority.ar} قبل دفع أي مبلغ.',
    );
  }

  LocalizedText _thisMonthAction(ScoredCandidate winner) {
    final first = winner.candidate.steps.isEmpty
        ? null
        : winner.candidate.steps.first;
    if (first == null) {
      return LocalizedText(
        en: 'Open the ${winner.candidate.name.en} guide and read the pathway.',
        ar: 'افتح دليل ${winner.candidate.name.ar} واقرأ المسار.',
      );
    }
    return LocalizedText(
      en: 'Start stage 1: ${first.title.en}.',
      ar: 'ابدأ المرحلة 1: ${first.title.ar}.',
    );
  }

  LocalizedText _alternativeReason(ScoredCandidate candidate) {
    if (candidate.overBudgetBy > 0) {
      return LocalizedText(
        en: 'About USD ${_thousands(candidate.overBudgetBy)} over budget',
        ar: 'يتجاوز الميزانية بنحو ${_thousands(candidate.overBudgetBy)} دولار',
      );
    }
    if (!candidate.languageMatched) {
      return const LocalizedText(
        en: 'Needs a language qualification first',
        ar: 'يتطلب مؤهلًا لغويًا أولًا',
      );
    }

    if (candidate.overTimeBy > 0) {
      return LocalizedText(
        en: '${candidate.overTimeBy} months longer than you have',
        ar: 'أطول من وقتك بـ ${candidate.overTimeBy} شهرًا',
      );
    }
    return LocalizedText(
      en: '${candidate.candidate.minMonths} months, '
          '${candidate.candidate.examCode}',
      ar: '${candidate.candidate.minMonths} شهرًا، '
          '${candidate.candidate.examCode}',
    );
  }

  GeneratedRoadmap _noDestinationResult(
    RoadmapAnswers answers,
    DateTime today,
  ) => GeneratedRoadmap(
    destinationIso: null,
    destinationName: const LocalizedText(en: 'No route yet', ar: 'لا مسار بعد'),
    fitScore: 0,
    headline: const LocalizedText(
      en: 'We could not build a route from these answers',
      ar: 'تعذّر بناء مسار من هذه الإجابات',
    ),
    summary: const LocalizedText(
      en: 'Nothing in our guides matches what you told us. '
          'Nothing you entered is lost.',
      ar: 'لا شيء في أدلتنا يطابق ما ذكرته. لم يُفقد ما أدخلته.',
    ),
    watchOut: const LocalizedText(
      en: 'Widening your regions or your time is usually what opens this up.',
      ar: 'توسيع المناطق أو الوقت هو ما يفتح الخيارات عادة.',
    ),
    thisMonthAction: const LocalizedText(
      en: 'Try the what-if with more time.',
      ar: 'جرّب "ماذا لو" بوقت أطول.',
    ),
    stages: const [],
    alternatives: const [],
  );

  /// Language names for display.
  ///
  /// A language *code* must never reach the screen: "This route requires de"
  /// is not a sentence, and the copy rules require plain words in the active
  /// language. An unknown code falls back to itself rather than being dropped,
  /// so a gap is visible rather than silently swallowed.
  static const Map<String, LocalizedText> _languageDisplayNames = {
    'de': LocalizedText(en: 'German', ar: 'الألمانية'),
    'nl': LocalizedText(en: 'Dutch', ar: 'الهولندية'),
    'sv': LocalizedText(en: 'Swedish', ar: 'السويدية'),
    'es': LocalizedText(en: 'Spanish', ar: 'الإسبانية'),
    'tr': LocalizedText(en: 'Turkish', ar: 'التركية'),
    'fr': LocalizedText(en: 'French', ar: 'الفرنسية'),
    'en': LocalizedText(en: 'English', ar: 'الإنجليزية'),
    'ar': LocalizedText(en: 'Arabic', ar: 'العربية'),
  };

  static LocalizedText _languageNames(List<String> codes) {
    if (codes.isEmpty) {
      return const LocalizedText(en: 'another language', ar: 'لغة أخرى');
    }
    final names = codes
        .map(
          (code) =>
              _languageDisplayNames[code] ?? LocalizedText.same(code),
        )
        .toList();
    return LocalizedText(
      en: names.map((n) => n.en).join(' and '),
      ar: names.map((n) => n.ar).join(' و'),
    );
  }

  /// Groups thousands with a comma. Western digits in both languages, always.
  static String _thousands(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}

extension on RoadmapCandidate {
  /// The guide's own duration wording, e.g. "12–24" or "18".
  String monthsLabelFor() =>
      minMonths == maxMonths ? '$minMonths' : '$minMonths–$maxMonths';
}
