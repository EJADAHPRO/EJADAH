import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/system/system.dart';
import 'providers.dart';
import 'router.dart';

/// The Ejadah application.
///
/// Direction, typography and every visual constant follow from the active
/// language, resolved here once. Switching language rebuilds this subtree in
/// place — instantly, with no reload and no lost form state, because only the
/// locale changes.
class EjadahApp extends ConsumerWidget {
  const EjadahApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final reduceMotion = ref.watch(reduceMotionProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Fluid breakpoints, never device models.
        final windowClass = EjadahBreakpoints.of(constraints.maxWidth);

        return MaterialApp.router(
          onGenerateTitle: (context) => context.strings.appName,
          debugShowCheckedModeBanner: false,
          routerConfig: ref.watch(routerProvider),
          locale: Locale(language.code),
          supportedLocales: ejadahSupportedLocales,
          localizationsDelegates: EjadahStrings.localizationsDelegates,
          theme: buildEjadahTheme(
            language: language,
            windowClass: windowClass,
            reduceMotion: reduceMotion,
          ),
          builder: (context, child) {
            // Directionality follows the language; no screen sets it by hand,
            // and no widget reasons about left and right.
            return Directionality(
              textDirection: language.isRtl
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: MediaQuery(
                // Text scaling up to 200% must not clip. Beyond that the layout
                // stops being usable, so it is capped rather than allowed to
                // break silently.
                data: MediaQuery.of(context).copyWith(
                  textScaler: MediaQuery.textScalerOf(
                    context,
                  ).clamp(minScaleFactor: 0.85, maxScaleFactor: 2.0),
                ),
                // SY-08. Flutter's own answer to a widget that throws is a red
                // box with a stack trace, which is right in development and
                // indefensible in front of a dentist. One boundary at the root
                // turns any build failure into a state that says what happened
                // and routes to Home.
                child: SystemErrorBoundary(
                  child: _WebPreviewBanner(
                    child: child ?? const SizedBox.shrink(),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Marks Flutter Web as a preview surface, in debug builds only.
///
/// The web build keeps its refresh token in `localStorage`, which any script in
/// the origin can read — native builds use secure storage. Web is therefore not
/// a distribution channel yet, and anyone poking at it in development should
/// know that before they type a real password into it.
///
/// Debug only, and web only: this is a warning to us, not a banner on a
/// shipped product. If web ever becomes a real channel, the fix is an HttpOnly
/// refresh cookie and this widget goes away.
class _WebPreviewBanner extends StatelessWidget {
  const _WebPreviewBanner({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || !kDebugMode) return child;

    return Stack(
      children: [
        child,
        // Ignores pointers so it never blocks what is being tested.
        PositionedDirectional(
          start: 0,
          end: 0,
          bottom: 0,
          child: IgnorePointer(
            child: ColoredBox(
              color: EjadahColors.danger,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(EjadahSpacing.xxs),
                  child: Text(
                    context.strings.webPreviewWarning,
                    textAlign: TextAlign.center,
                    style: context.type.micro(color: EjadahColors.onDark),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
