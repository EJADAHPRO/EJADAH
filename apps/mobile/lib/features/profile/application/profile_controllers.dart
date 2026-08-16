import 'package:ejadah_models/ejadah_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/profile_repository.dart';

/// The public card at `/dr/{slug}`.
///
/// Keyed by slug and deliberately unauthenticated: a signed-out visitor
/// resolves it exactly as a signed-in one does.
final publicProfileProvider =
    FutureProvider.family<PublicProfileView, String>(
      (ref, slug) => ref.watch(profileRepositoryProvider).publicProfile(slug),
    );

/// The public certificate check at `/verify/{code}`.
///
/// Always resolves to an outcome. "No certificate with that code" is data, not
/// an error, so the screen renders it as an answer rather than as a failure.
final certificateVerificationProvider =
    FutureProvider.family<CertificateVerification, String>(
      (ref, code) =>
          ref.watch(profileRepositoryProvider).verifyCertificate(code),
    );

/// The signed-in user's own card.
final myCardProvider = FutureProvider<MyProfileCard>(
  (ref) => ref.watch(profileRepositoryProvider).myCard(),
);

final myCertificatesProvider = FutureProvider<List<Certificate>>(
  (ref) => ref.watch(profileRepositoryProvider).certificates(),
);

final cpdLedgerProvider = FutureProvider<CpdLedger>(
  (ref) => ref.watch(profileRepositoryProvider).cpdLedger(),
);

final notificationPreferencesProvider = FutureProvider<NotificationPreferences>(
  (ref) => ref.watch(profileRepositoryProvider).notificationPreferences(),
);

