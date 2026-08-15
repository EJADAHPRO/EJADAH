/// Cross-cutting client infrastructure for Ejadah.
///
/// Typed failures, the one HTTP client, local persistence and the analytics
/// abstraction. Features depend on this; it depends on no feature.
library;

export 'src/analytics/analytics.dart';
export 'src/error/failures.dart';
export 'src/network/api_client.dart';
export 'src/network/token_store.dart';
export 'src/storage/local_store.dart';
