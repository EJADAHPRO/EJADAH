import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_server/src/modules/roadmap/roadmap_engine.dart';
import 'package:test/test.dart';

/// The reproducibility proof.
///
/// "Same inputs, same output, every time" is the trust claim the roadmap rests
/// on — a property no model-backed version could guarantee. These tests hold
/// the engine to it, including the parts that would quietly break it: undefined
/// ordering, wall-clock dates, and a scoring ceiling that flattens every result
/// to the same number.
void main() {
  const engine = RoadmapEngine();
  final today = DateTime.utc(2026, 8, 15);

  const answers = RoadmapAnswers(
    path: RoadmapPath.generalPractice,
    stage: CareerStage.generalDentist,
    yearsQualified: 4,
    budgetUsd: 8000,
    monthsAvailable: 18,
    regions: [RoadmapRegion.gulf, RoadmapRegion.ukIreland],
    languages: ['ar', 'en'],
  );

  group('determinism', () {
    test('the same answers produce a byte-identical roadmap', () {
      final first = engine.generate(
        answers: answers,
        candidates: _candidates(),
        today: today,
      );
      final second = engine.generate(
        answers: answers,
        candidates: _candidates(),
        today: today,
      );

      expect(second.destinationIso, first.destinationIso);
      expect(second.fitScore, first.fitScore);
      expect(second.headline, first.headline);
      expect(second.summary, first.summary);
      expect(second.watchOut, first.watchOut);
      expect(second.thisMonthAction, first.thisMonthAction);
      expect(
        second.stages.map((s) => s.toJson()),
        first.stages.map((s) => s.toJson()),
      );
      expect(
        second.alternatives.map((a) => a.toJson()),
        first.alternatives.map((a) => a.toJson()),
      );
    });

    test('candidate order does not change the winner', () {
      // The reference data arrives from a query. If ordering leaked into the
      // result, reproducibility would silently depend on the planner.
      final forwards = engine.generate(
        answers: answers,
        candidates: _candidates(),
        today: today,
      );
      final backwards = engine.generate(
        answers: answers,
        candidates: _candidates().reversed.toList(),
        today: today,
      );

      expect(backwards.destinationIso, forwards.destinationIso);
      expect(backwards.fitScore, forwards.fitScore);
      expect(
        backwards.alternatives.map((a) => a.countryIso),
        forwards.alternatives.map((a) => a.countryIso),
      );
    });

    test('projected dates come from the supplied date, not the clock', () {
      final result = engine.generate(
        answers: answers,
        candidates: _candidates(),
        today: today,
      );

      expect(result.stages.first.projectedStart, today);
      // A later "today" moves every stage by exactly that much.
      final tomorrow = today.add(const Duration(days: 1));
      final later = engine.generate(
        answers: answers,
        candidates: _candidates(),
        today: tomorrow,
      );
      expect(later.stages.first.projectedStart, tomorrow);
      expect(
        later.stages.last.projectedEnd.difference(
          result.stages.last.projectedEnd,
        ),
        const Duration(days: 1),
      );
    });
  });

  group('tie-breaks', () {
    test('equal scores break on cost, then on country code', () {
      // Three candidates identical but for cost, so only the tie-break can
      // decide. Deliberately supplied out of order.
      final scored = engine.scoreAll(answers, [
        _candidate(iso: 'qa', floorCostUsd: 900),
        _candidate(iso: 'ae', floorCostUsd: 700),
        _candidate(iso: 'bh', floorCostUsd: 700),
      ]);

      // ae and bh tie on score and cost; the country code decides, so 'ae'
      // leads 'bh', and the pricier 'qa' comes last.
      expect(
        scored.eligible.map((c) => c.candidate.iso).toList(),
        ['ae', 'bh', 'qa'],
      );
    });

    test('incomplete cost data never reads as affordability', () {
      // A guide with unsourced cost rows has an artificially low floor, because
      // those rows contribute nothing to it. It must not out-score a
      // fully-documented destination on that basis — the budget-headroom bonus
      // is withheld — and at equal score the tie-break demotes it too.
      final scored = engine.scoreAll(answers, [
        _candidate(iso: 'ae', floorCostUsd: 500, floorCostComplete: false),
        _candidate(iso: 'qa', floorCostUsd: 900, floorCostComplete: true),
      ]);

      expect(
        scored.eligible.first.candidate.iso,
        'qa',
        reason: 'the documented destination wins despite the higher floor',
      );

      // And with both floors equal, the complete one still leads.
      final tied = engine.scoreAll(answers, [
        _candidate(iso: 'ae', floorCostUsd: 700, floorCostComplete: false),
        _candidate(iso: 'qa', floorCostUsd: 700, floorCostComplete: true),
      ]);
      expect(tied.eligible.first.candidate.iso, 'qa');
    });
  });

  group('the rules that must hold', () {
    test('an unaffordable destination cannot score above 60', () {
      const broke = RoadmapAnswers(
        path: RoadmapPath.generalPractice,
        stage: CareerStage.generalDentist,
        yearsQualified: 2,
        budgetUsd: 300,
        monthsAvailable: 6,
        regions: [RoadmapRegion.gulf],
        languages: ['ar', 'en'],
      );

      final result = engine.generate(
        answers: broke,
        candidates: _candidates(),
        today: today,
      );

      expect(
        result.fitScore,
        lessThanOrEqualTo(RoadmapConstants.unaffordableCeiling),
      );
    });

    test('the formula cannot saturate the clamp', () {
      // A perfect match must land short of 100: a screen of identical "100%
      // fit" scores tells the user nothing.
      expect(RoadmapConstants.maxAttainableScore, lessThan(100));
      expect(RoadmapConstants.maxAttainableScore, greaterThan(70));
    });

    test('the watch-out names the gap in figures, not in hedging', () {
      const broke = RoadmapAnswers(
        path: RoadmapPath.generalPractice,
        stage: CareerStage.generalDentist,
        yearsQualified: 2,
        budgetUsd: 300,
        monthsAvailable: 24,
        regions: [RoadmapRegion.gulf],
        languages: ['ar', 'en'],
      );

      final result = engine.generate(
        answers: broke,
        candidates: _candidates(),
        today: today,
      );

      expect(result.watchOut.en, contains('USD'));
      expect(result.watchOut.en, isNot(contains('approximately')));
      expect(result.watchOut.en, isNot(contains('!')));
      expect(result.watchOut.ar, isNotEmpty);
    });

    test('a digital route never recommends a licensing exam abroad', () {
      const digital = RoadmapAnswers(
        path: RoadmapPath.digital,
        stage: CareerStage.generalDentist,
        yearsQualified: 3,
        budgetUsd: 2000,
        monthsAvailable: 12,
        regions: [RoadmapRegion.stayEgypt],
        languages: ['ar', 'en'],
      );

      final result = engine.generate(
        answers: digital,
        candidates: _candidates(),
        today: today,
      );

      expect(result.destinationIso, 'eg');
    });

    test('"work abroad" does not answer with Egypt unless it was asked for', () {
      final result = engine.generate(
        answers: answers,
        candidates: _candidates(),
        today: today,
      );
      expect(result.destinationIso, isNot('eg'));
    });

    test('a region the user picked outranks one they did not', () {
      const ukOnly = RoadmapAnswers(
        path: RoadmapPath.generalPractice,
        stage: CareerStage.generalDentist,
        yearsQualified: 5,
        budgetUsd: 20000,
        monthsAvailable: 36,
        regions: [RoadmapRegion.ukIreland],
        languages: ['ar', 'en'],
      );

      final result = engine.generate(
        answers: ukOnly,
        candidates: _candidates(),
        today: today,
      );

      expect(['gb', 'ie'], contains(result.destinationIso));
      // The faster Gulf routes are still shown, honestly, as alternatives.
      expect(result.alternatives, isNotEmpty);
    });

    test('an unsourced stage cost stays pending rather than becoming zero', () {
      final result = engine.generate(
        answers: answers,
        candidates: [_candidate(iso: 'bh', floorCostUsd: 700, stepCosts: {})],
        today: today,
      );

      expect(result.stages, isNotEmpty);
      for (final stage in result.stages) {
        expect(stage.cost.isPending, isTrue);
        expect(stage.cost.value, isNull);
      }
    });

    test('stages are copies of the guide rows, not rewritten text', () {
      final candidate = _candidate(iso: 'ae', floorCostUsd: 700);
      final result = engine.generate(
        answers: answers,
        candidates: [candidate],
        today: today,
      );

      for (var i = 0; i < result.stages.length; i++) {
        expect(result.stages[i].title, candidate.steps[i].title);
        expect(result.stages[i].detail, candidate.steps[i].detail);
      }
    });
  });
}

List<RoadmapCandidate> _candidates() => [
  _candidate(iso: 'ae', floorCostUsd: 900, minMonths: 3, maxMonths: 6),
  _candidate(iso: 'bh', floorCostUsd: 700, minMonths: 4, maxMonths: 9),
  _candidate(iso: 'qa', floorCostUsd: 800, minMonths: 4, maxMonths: 9),
  _candidate(
    iso: 'gb',
    floorCostUsd: 6200,
    minMonths: 12,
    maxMonths: 24,
    pathwayClass: PathwayClass.exam,
    examCode: 'ORE',
  ),
  _candidate(
    iso: 'ie',
    floorCostUsd: 5000,
    minMonths: 12,
    maxMonths: 30,
    pathwayClass: PathwayClass.exam,
  ),
  _candidate(
    iso: 'de',
    floorCostUsd: 2520,
    minMonths: 12,
    maxMonths: 24,
    pathwayClass: PathwayClass.language,
    requiredLanguages: ['de'],
  ),
  _candidate(
    iso: 'eg',
    floorCostUsd: 300,
    minMonths: 2,
    maxMonths: 5,
    requiredLanguages: ['ar'],
  ),
];

RoadmapCandidate _candidate({
  required String iso,
  required int? floorCostUsd,
  bool floorCostComplete = true,
  int minMonths = 4,
  int maxMonths = 9,
  PathwayClass pathwayClass = PathwayClass.fast,
  String examCode = 'Prometric',
  List<String> requiredLanguages = const ['en'],
  Map<int, Sourced<String>>? stepCosts,
}) => RoadmapCandidate(
  iso: iso,
  name: LocalizedText(en: iso.toUpperCase(), ar: iso),
  region: 'Middle East',
  pathwayClass: pathwayClass,
  examCode: examCode,
  minMonths: minMonths,
  maxMonths: maxMonths,
  floorCostUsd: floorCostUsd,
  floorCostComplete: floorCostComplete,
  requiredLanguages: requiredLanguages,
  steps: const [
    CountryStep(
      position: 1,
      title: LocalizedText(en: 'DataFlow', ar: 'داتا فلو'),
      detail: LocalizedText(en: 'Verify your degree.', ar: 'وثّق شهادتك.'),
      whenLabel: null,
      isOptional: false,
    ),
    CountryStep(
      position: 2,
      title: LocalizedText(en: 'Eligibility', ar: 'الأهلية'),
      detail: LocalizedText(en: 'Apply for the code.', ar: 'اطلب الرمز.'),
      whenLabel: null,
      isOptional: false,
    ),
    CountryStep(
      position: 3,
      title: LocalizedText(en: 'Exam', ar: 'الامتحان'),
      detail: LocalizedText(en: 'Sit the exam.', ar: 'اجتز الامتحان.'),
      whenLabel: null,
      isOptional: false,
    ),
  ],
  stepCosts:
      stepCosts ??
      const {
        1: Sourced<String>(value: r'$250', status: SourceStatus.verified),
      },
  authority: const LocalizedText(en: 'The regulator', ar: 'الجهة المنظِّمة'),
);
