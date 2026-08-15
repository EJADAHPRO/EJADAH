import '../common/localized_text.dart';
import '../common/value.dart';
import '../roadmap/roadmap.dart';

/// Server-enforced roles.
///
/// Frontend visibility is never authorization — every protected route checks
/// the role again on the server (brief §30).
enum UserRole {
  student('student'),
  professional('professional'),
  admin('admin');

  const UserRole(this.wire);

  final String wire;

  static UserRole fromWire(String? value) => UserRole.values.firstWhere(
    (role) => role.wire == value,
    orElse: () => UserRole.student,
  );
}

/// Whether a supply-side application has been approved.
enum ProfessionalStatus {
  none('none'),
  draft('draft'),
  underReview('under_review'),
  approved('approved'),
  rejected('rejected');

  const ProfessionalStatus(this.wire);

  final String wire;

  static ProfessionalStatus fromWire(String? value) =>
      ProfessionalStatus.values.firstWhere(
        (status) => status.wire == value,
        orElse: () => ProfessionalStatus.none,
      );
}

/// The signed-in user as the client needs them.
///
/// Deliberately not the `users` row: no password hash, no internal flags
/// (brief §33 — no raw tables over the wire).
class AuthUser extends ValueObject {
  const AuthUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.stage,
    required this.language,
    required this.emailVerified,
    required this.professionalStatus,
    required this.isPremium,
    required this.premiumRenewsOn,
    this.publicSlug,
    this.avatarUrl,
  });

  final String id;
  final String email;
  final LocalizedText fullName;
  final UserRole role;
  final CareerStage stage;
  final AppLanguage language;
  final bool emailVerified;
  final ProfessionalStatus professionalStatus;

  /// Premium is read-only in Phase 1 — status and renewal date, never prices.
  final bool isPremium;
  final DateTime? premiumRenewsOn;
  final String? publicSlug;
  final String? avatarUrl;

  bool get isAdmin => role == UserRole.admin;

  bool get isApprovedProfessional =>
      professionalStatus == ProfessionalStatus.approved;

  /// Initials for the avatar fallback. Placeholder people photos are never
  /// shipped and a broken image is never shown (`BRAND_GUIDE.md` §6).
  String initials(AppLanguage language) {
    final name = fullName.resolve(language).trim();
    if (name.isEmpty) return '';
    final parts = name
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.length == 1) return _firstLetter(parts.first);
    return '${_firstLetter(parts.first)}${_firstLetter(parts.last)}';
  }

  static String _firstLetter(String word) =>
      word.isEmpty ? '' : word.substring(0, 1).toUpperCase();

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: jsonRequire<String>(json, 'id'),
    email: jsonRequire<String>(json, 'email'),
    fullName: LocalizedText.fromJson(json['full_name'])!,
    role: UserRole.fromWire(json['role'] as String?),
    stage: CareerStage.fromWire(json['stage'] as String?),
    language: AppLanguage.fromCode(json['language'] as String?),
    emailVerified: jsonBool(json['email_verified']) ?? false,
    professionalStatus: ProfessionalStatus.fromWire(
      json['professional_status'] as String?,
    ),
    isPremium: jsonBool(json['is_premium']) ?? false,
    premiumRenewsOn: jsonDate(json['premium_renews_on']),
    publicSlug: json['public_slug'] as String?,
    avatarUrl: json['avatar_url'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'full_name': fullName.toJson(),
    'role': role.wire,
    'stage': stage.wire,
    'language': language.code,
    'email_verified': emailVerified,
    'professional_status': professionalStatus.wire,
    'is_premium': isPremium,
    'premium_renews_on': premiumRenewsOn?.toIso8601String(),
    'public_slug': publicSlug,
    'avatar_url': avatarUrl,
  };

  @override
  List<Object?> get props => [
    id,
    role,
    emailVerified,
    professionalStatus,
    isPremium,
  ];
}

/// An access/refresh token pair.
///
/// Access tokens are short-lived JWTs; refresh tokens are opaque, rotated on
/// every use, and revoked wholesale if a used token is replayed.
class AuthTokens extends ValueObject {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().toUtc().isAfter(expiresAt);

  /// Refresh a little early so a request never races the expiry boundary.
  bool get needsRefresh => DateTime.now().toUtc().isAfter(
    expiresAt.subtract(const Duration(seconds: 60)),
  );

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
    accessToken: jsonRequire<String>(json, 'access_token'),
    refreshToken: jsonRequire<String>(json, 'refresh_token'),
    expiresAt: jsonDate(json['expires_at'])!,
  );

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'refresh_token': refreshToken,
    'expires_at': expiresAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresAt];
}

/// The result of a successful sign-in or sign-up.
class AuthSession extends ValueObject {
  const AuthSession({required this.user, required this.tokens});

  final AuthUser user;
  final AuthTokens tokens;

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
    user: AuthUser.fromJson(Map<String, dynamic>.from(json['user'] as Map)),
    tokens: AuthTokens.fromJson(
      Map<String, dynamic>.from(json['tokens'] as Map),
    ),
  );

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'tokens': tokens.toJson(),
  };

  @override
  List<Object?> get props => [user, tokens];
}
