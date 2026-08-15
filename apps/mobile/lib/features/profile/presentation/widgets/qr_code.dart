import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/widgets.dart';

import 'qr_matrix.dart';

/// Paints a [QrMatrix] as square modules.
///
/// Dark on the card surface, with a quiet zone, because a QR printed edge-to-
/// edge does not scan. Colours come from the tokens like everything else.
class QrCodeView extends StatelessWidget {
  const QrCodeView({
    required this.data,
    required this.semanticLabel,
    this.size = 160,
    super.key,
  });

  final String data;
  final String semanticLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final matrix = QrMatrix.encode(data);
    if (matrix == null) {
      // Nothing to encode: show nothing rather than a pattern that will not
      // scan. The caller always prints the link as text alongside.
      return const SizedBox.shrink();
    }
    return Semantics(
      label: semanticLabel,
      image: true,
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(EjadahSpacing.xs),
        decoration: BoxDecoration(
          color: EjadahColors.card,
          borderRadius: EjadahRadius.all(EjadahRadius.md),
          border: Border.all(color: EjadahColors.border),
        ),
        child: CustomPaint(
          painter: _QrPainter(matrix),
          // The code is a Latin-context island; direction must not mirror it.
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  const _QrPainter(this.matrix);

  final QrMatrix matrix;

  @override
  void paint(Canvas canvas, Size size) {
    final module = size.width / matrix.size;
    final paint = Paint()..color = EjadahColors.textPrimary;
    for (var y = 0; y < matrix.size; y++) {
      for (var x = 0; x < matrix.size; x++) {
        if (!matrix.isDark(x, y)) continue;
        canvas.drawRect(
          Rect.fromLTWH(
            x * module,
            y * module,
            // A hair of overlap, so anti-aliasing cannot open hairline gaps
            // between adjacent dark modules and break the scan.
            module + 0.5,
            module + 0.5,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_QrPainter oldDelegate) =>
      oldDelegate.matrix.version != matrix.version ||
      oldDelegate.matrix.mask != matrix.mask ||
      !_sameModules(oldDelegate.matrix);

  bool _sameModules(QrMatrix other) {
    if (other.size != matrix.size) return false;
    for (var y = 0; y < matrix.size; y++) {
      for (var x = 0; x < matrix.size; x++) {
        if (other.isDark(x, y) != matrix.isDark(x, y)) return false;
      }
    }
    return true;
  }
}
