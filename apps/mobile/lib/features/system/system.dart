/// The ten system states, the failure registry and the error boundary.
///
/// One template (`EjadahSystemState`), ten thin compositions over it, and one
/// place that decides which of them a typed failure deserves. Every state
/// routes somewhere real: story E6-02 — "Failures speak human. All 10 system
/// states route to action; no status codes."
library;

export 'error_boundary.dart';
export 'presentation/camera_permission_screen.dart';
export 'presentation/content_unavailable_screen.dart';
export 'presentation/error_boundary_screen.dart';
export 'presentation/force_update_screen.dart';
export 'presentation/maintenance_screen.dart';
export 'presentation/notification_permission_screen.dart';
export 'presentation/offline_screen.dart';
export 'presentation/rate_limited_screen.dart';
export 'presentation/server_error_screen.dart';
export 'presentation/session_expired_screen.dart';
export 'presentation/system_state_scaffold.dart';
export 'system_state_registry.dart';
