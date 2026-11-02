import 'package:flutter_test/flutter_test.dart';
import 'package:starapp/core/models/money.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/features/scout/data/models/application.dart';
import 'package:starapp/features/scout/data/models/budget_range.dart';
import 'package:starapp/features/scout/data/models/company.dart';
import 'package:starapp/features/scout/data/models/open_call.dart';
import 'package:starapp/features/scout/data/models/open_call_filters.dart';
import 'package:starapp/features/scout/data/models/scout_request.dart';
import 'package:starapp/features/scout/data/models/talent_category.dart';
import 'package:starapp/features/scout/data/repositories/mock_scout_repository.dart';
import 'package:starapp/features/scout/presentation/widgets/scout_style.dart';

void main() {
  late MockScoutRepository repository;

  setUp(() => repository = MockScoutRepository(latency: Duration.zero));

  group('fixtures parse and cover the designed states', () {
    test('marketplace: featured, applied, not eligible', () async {
      final page = await repository.listOpenCalls(const OpenCallFilters());
      final calls = page.items;

      expect(calls.first.isFeatured, isTrue, reason: 'featured first');
      expect(calls.first.title, 'Lead Vocalist, "Gold Coast" Summer Tour 2027');
      expect(calls.first.company.name, 'Afrowave Records');
      expect(calls.any((c) => c.myStatus != null), isTrue, reason: 'Applied');
      expect(calls.any((c) => !c.isEligible), isTrue, reason: 'Not eligible');
      expect(calls.any((c) => c.company.name == 'Kora Studios'), isTrue);
      expect(
        calls.every((c) => c.closesAt.isAfter(DateTime.now())),
        isTrue,
        reason: 'only open calls are listed',
      );
    });

    test('a call page has its details and requirements', () async {
      final call = await repository.getOpenCall('gold-coast-tour');

      expect(call.summary.budget.unit, BudgetUnit.perShow);
      expect(call.summary.budget.max, isNotNull);
      expect(call.summary.cities, hasLength(7));
      expect(call.scheduleNote, '12 shows');
      expect(call.requirements, hasLength(4));
      expect(call.unmetRequirement, isNull);

      final blocked = await repository.getOpenCall('nova-halftime');
      expect(blocked.summary.isEligible, isFalse);
      expect(blocked.unmetRequirement?.label, 'Stellar tier or above');

      final closed = await repository.getOpenCall('pulse-brand-voice');
      expect(closed.summary.isClosedAt(DateTime.now()), isTrue);
    });

    test('applications cover active and closed statuses', () async {
      final active = await repository.listMyApplications(active: true);
      final closed = await repository.listMyApplications(active: false);
      final statuses = {
        for (final a in [...active.items, ...closed.items]) a.status,
      };

      expect(active.items.every((a) => a.isActive), isTrue);
      expect(closed.items.every((a) => !a.isActive), isTrue);
      expect(
        statuses,
        containsAll([
          ApplicationStatus.sent,
          ApplicationStatus.inReview,
          ApplicationStatus.shortlisted,
          ApplicationStatus.offer,
          ApplicationStatus.completed,
        ]),
      );
      final offer = active.items.firstWhere(
        (a) => a.status == ApplicationStatus.offer,
      );
      expect(offer.conversationId, isNotNull);
      expect(closed.items.single.transactionId, isNotNull);
    });

    test('the summary counts the active applications', () async {
      final summary = await repository.getApplicationsSummary();

      expect(summary.sent, 1);
      expect(summary.inReview, 1);
      expect(summary.shortlisted, 1);
      expect(summary.total, 4);
    });

    test('Afrowave fills every company section; Kora hides some', () async {
      final afrowave = await repository.getCompany('afrowave-records');
      expect(afrowave.rating, 4.8);
      expect(afrowave.openRoles, isNotEmpty);
      expect(afrowave.testimonials.single.authorName, 'Kofi M.');
      expect(afrowave.coverUrl, isNotNull);

      final kora = await repository.getCompany('kora-studios');
      expect(kora.rating, isNull);
      expect(kora.testimonials, isEmpty);

      expect(
        () => repository.getCompany('nobody'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('two pending requests, one Afrowave\'s "Gbedu" video', () async {
      final requests = await repository.listScoutRequests();

      expect(requests, hasLength(2));
      expect(requests.every((r) => r.isPending), isTrue);
      final gbedu = requests.firstWhere((r) => r.id == 'sr-gbedu');
      expect(gbedu.company.name, 'Afrowave Records');
      expect(gbedu.roleTitle, 'Featured Dancer, "Gbedu" Music Video');
      expect(gbedu.budget, const Money(85000000, Currency.ngn));
      expect(gbedu.isNew, isTrue);
      expect(gbedu.starsBonus, 200);
      expect(gbedu.attachments.single.fileName, 'Gbedu_brief.pdf');
    });
  });

  group('the mock remembers what the user did', () {
    test('applying shows in the list, the summary and applications', () async {
      final app = await repository.applyToOpenCall('gold-coast-tour');
      expect(app.status, ApplicationStatus.sent);

      final page = await repository.listOpenCalls(const OpenCallFilters());
      expect(page.items.first.myStatus, ApplicationStatus.sent);
      expect((await repository.getApplicationsSummary()).total, 5);
      final active = await repository.listMyApplications(active: true);
      expect(active.items.first.openCallId, 'gold-coast-tour');
    });

    test('answered requests leave the pending list', () async {
      final conversation = await repository.acceptScoutRequest('sr-gbedu');
      final accepted = await repository.getScoutRequest('sr-gbedu');

      expect(accepted.status, ScoutRequestStatus.accepted);
      expect(accepted.conversationId, conversation);
      await repository.declineScoutRequest('sr-kora-live');
      expect(await repository.listScoutRequests(), isEmpty);
    });
  });

  group('filters', () {
    test('narrow the mock list and its count', () async {
      Future<int> count(OpenCallFilters f) => repository.countOpenCalls(f);

      final all = await count(const OpenCallFilters());
      expect(
        await count(const OpenCallFilters(category: TalentCategory.music)),
        1,
      );
      expect(await count(const OpenCallFilters(remoteOnly: true)), 1);
      expect(await count(const OpenCallFilters(query: 'kora')), 1);
      expect(await count(const OpenCallFilters(city: 'Accra')), 2);
      expect(
        await count(
          const OpenCallFilters(window: OpenCallWindow.closingThisWeek),
        ),
        lessThan(all),
      );
    });

    test('toQuery drops unset filters and copyWith clears with null', () {
      const filters = OpenCallFilters(
        query: '  vocal ',
        category: TalentCategory.dance,
        city: 'Lagos',
        matchMyTalents: true,
      );

      expect(filters.toQuery(), {
        'q': 'vocal',
        'category': 'dance',
        'window': null,
        'city': 'Lagos',
        'remoteOnly': null,
        'matchMyTalents': true,
      });
      final cleared = filters.copyWith(category: null, city: null);
      expect(cleared.category, isNull);
      expect(cleared.city, isNull);
      expect(cleared.query, '  vocal ');
      expect(filters.resetSheet(), const OpenCallFilters(query: '  vocal '));
      expect(filters.copyWith(), filters);
    });
  });

  test('toJson round-trips every model', () async {
    final calls = await repository.listOpenCalls(const OpenCallFilters());
    for (final c in calls.items) {
      expect(OpenCallSummary.fromJson(c.toJson()).toJson(), c.toJson());
    }

    for (final id in ['gold-coast-tour', 'nova-halftime']) {
      final call = await repository.getOpenCall(id);
      expect(OpenCall.fromJson(call.toJson()).toJson(), call.toJson());
    }

    final applications = [
      ...(await repository.listMyApplications(active: true)).items,
      ...(await repository.listMyApplications(active: false)).items,
    ];
    for (final a in applications) {
      expect(Application.fromJson(a.toJson()).toJson(), a.toJson());
    }

    final summary = await repository.getApplicationsSummary();
    expect(
      ApplicationsSummary.fromJson(summary.toJson()).toJson(),
      summary.toJson(),
    );

    for (final id in ['afrowave-records', 'kora-studios']) {
      final company = await repository.getCompany(id);
      expect(Company.fromJson(company.toJson()).toJson(), company.toJson());
    }

    for (final r in await repository.listScoutRequests()) {
      expect(ScoutRequest.fromJson(r.toJson()).toJson(), r.toJson());
    }
  });

  test('unknown enums and missing fields fall back instead of throwing', () {
    final application = Application.fromJson({
      'id': 'x',
      'title': 'Role',
      'company': {'id': 'c', 'name': 'Co'},
      'status': 'somethingNew',
      'category': 'mime',
    });
    expect(application.status, ApplicationStatus.sent);
    expect(application.category, isNull);

    final request = ScoutRequest.fromJson({
      'id': 'r',
      'company': {'id': 'c', 'name': 'Co'},
      'roleTitle': 'Role',
      'budget': {'amountMinor': 100, 'currency': 'NGN'},
      'senderName': 'Ada',
      'status': 'archived',
    });
    expect(request.status, ScoutRequestStatus.pending);
    expect(request.attachments, isEmpty);
  });

  group('display formatting', () {
    test('budgets', () {
      expect(
        formatBudget(
          const BudgetRange(
            min: Money(250000000, Currency.ngn),
            max: Money(400000000, Currency.ngn),
            unit: BudgetUnit.perShow,
          ),
        ),
        '₦2.5M – ₦4M',
      );
      expect(
        formatBudget(
          const BudgetRange(
            min: Money(18000000, Currency.ngn),
            unit: BudgetUnit.perDay,
          ),
          withUnit: true,
        ),
        '₦180K / day',
      );
      expect(
        formatBudget(const BudgetRange(min: Money(120000, Currency.usd))),
        r'$1,200',
      );
    });

    test('date ranges', () {
      expect(
        formatDateRange(DateTime(2026, 11, 14), DateTime(2026, 11, 16)),
        'Nov 14 – 16',
      );
      expect(
        formatDateRange(DateTime(2027, 6, 6), DateTime(2027, 8, 29)),
        'Jun – Aug 2027',
      );
      expect(
        formatDateRange(DateTime(2026, 11, 30), DateTime(2026, 12, 2)),
        'Nov 30 – Dec 2',
      );
    });

    test('days left round up', () {
      final now = DateTime(2026, 11, 1, 12);
      expect(formatDaysLeft(DateTime(2026, 11, 7, 12), now: now), '6 days');
      expect(formatDaysLeft(DateTime(2026, 11, 2, 1), now: now), '1 day');
      expect(formatDaysLeft(DateTime(2026, 10, 30), now: now), 'today');
    });
  });
}
