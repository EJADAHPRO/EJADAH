/// Typed domain models shared by the Ejadah Flutter app and the Dart server.
///
/// Both sides parse and encode the same wire format from this one library, so a
/// field renamed on the server cannot silently diverge from the client.
library;

export 'src/auth/auth.dart';
export 'src/career/country_guide.dart';
export 'src/career/programme.dart';
export 'src/common/localized_text.dart';
export 'src/common/paginated.dart';
export 'src/common/sourced.dart';
export 'src/common/value.dart';
export 'src/learn/learn.dart';
export 'src/people/people.dart';
export 'src/profile/profile.dart';
export 'src/roadmap/roadmap.dart';
