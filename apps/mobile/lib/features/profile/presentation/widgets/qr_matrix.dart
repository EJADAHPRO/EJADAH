import 'dart:convert';

import 'package:flutter/foundation.dart';

/// A real, scannable QR code.
///
/// Written here rather than pulled in as a dependency because the app's
/// dependency set is fixed — and a decorative pattern that does not scan would
/// be the same class of defect as a broken image: it looks like it works right
/// up until a stranger points a phone at a printed card.
///
/// Scope is exactly what the product needs and no more: byte mode, error
/// correction level L, versions 1–5 (up to 106 bytes). Every card URL and
/// verification URL fits inside that, and staying under version 6 means one
/// error-correction block, so there is no interleaving to get subtly wrong.
/// `qr_code_test.dart` checks the produced matrix module-for-module against a
/// reference encoder, for every mask and every version in range.
@immutable
class QrMatrix {
  const QrMatrix._(this.size, this._modules, this.version, this.mask);

  final int size;
  final int version;
  final int mask;
  final List<bool> _modules;

  bool isDark(int x, int y) => _modules[y * size + x];

  /// The longest payload this encoder handles: version 5 at level L holds 108
  /// data codewords, less the twelve header bits.
  static const int maxBytes = 106;

  /// Encodes [text], or returns null when it is empty or too long to fit
  /// versions 1–5 — the caller then shows the link as text rather than a code
  /// that cannot be produced.
  static QrMatrix? encode(String text) {
    if (text.isEmpty) return null;
    final data = utf8.encode(text);
    final version = _versionFor(data.length);
    if (version == null) return null;

    final codewords = _codewords(data, version);
    final builder = _Builder(version)
      ..drawFunctionPatterns()
      ..drawCodewords(codewords);
    final mask = builder.chooseMask();
    builder.applyMask(mask);
    builder.drawFormatBits(mask);
    return QrMatrix._(builder.size, builder.modules, version, mask);
  }

  /// Encodes with a fixed mask. Used by the tests to compare against a
  /// reference encoder one mask at a time.
  @visibleForTesting
  static QrMatrix? encodeWithMask(String text, int mask) {
    if (text.isEmpty) return null;
    final data = utf8.encode(text);
    final version = _versionFor(data.length);
    if (version == null) return null;

    final builder = _Builder(version)
      ..drawFunctionPatterns()
      ..drawCodewords(_codewords(data, version));
    builder.applyMask(mask);
    builder.drawFormatBits(mask);
    return QrMatrix._(builder.size, builder.modules, version, mask);
  }

  /// The data plus error-correction codewords for [text]. Exposed so the test
  /// can compare the encoding against a reference before the matrix is drawn,
  /// which localises a failure to encoding rather than to placement.
  @visibleForTesting
  static List<int>? debugCodewords(String text) {
    final data = utf8.encode(text);
    final version = _versionFor(data.length);
    if (version == null) return null;
    return _codewords(data, version);
  }

  /// Data codewords per version at error-correction level L, versions 1–5.
  /// Each of these versions uses a single block, which is why the range stops
  /// at 5.
  static const List<int> _dataCodewords = [19, 34, 55, 80, 108];

  /// Error-correction codewords per version at level L, versions 1–5.
  static const List<int> _eccCodewords = [7, 10, 15, 20, 26];

  static int? _versionFor(int byteLength) {
    for (var version = 1; version <= 5; version++) {
      // 4 mode bits + 8 character-count bits + the payload.
      final bitsNeeded = 4 + 8 + byteLength * 8;
      if (bitsNeeded <= _dataCodewords[version - 1] * 8) return version;
    }
    return null;
  }

  /// Data codewords plus their error-correction codewords, ready to place.
  static List<int> _codewords(List<int> data, int version) {
    final capacity = _dataCodewords[version - 1];
    final bits = _BitBuffer()
      // Byte mode.
      ..append(0x4, 4)
      ..append(data.length, 8);
    for (final byte in data) {
      bits.append(byte, 8);
    }

    // Terminator, then pad to a whole codeword, then the two alternating pad
    // bytes the specification names.
    final capacityBits = capacity * 8;
    bits.append(0, (capacityBits - bits.length).clamp(0, 4));
    bits.append(0, (8 - bits.length % 8) % 8);
    var padIsEc = true;
    while (bits.length < capacityBits) {
      bits.append(padIsEc ? 0xEC : 0x11, 8);
      padIsEc = !padIsEc;
    }

    final message = bits.toBytes();
    return [...message, ..._reedSolomon(message, _eccCodewords[version - 1])];
  }

  /// Reed–Solomon remainder over GF(256) with the QR primitive polynomial.
  static List<int> _reedSolomon(List<int> data, int degree) {
    final generator = _generatorPolynomial(degree);
    final result = List<int>.filled(degree, 0, growable: true);
    for (final byte in data) {
      final factor = byte ^ result.first;
      result
        ..removeAt(0)
        ..add(0);
      for (var i = 0; i < degree; i++) {
        result[i] ^= _multiply(generator[i], factor);
      }
    }
    return result;
  }

  static List<int> _generatorPolynomial(int degree) {
    var result = <int>[1];
    var root = 1;
    for (var i = 0; i < degree; i++) {
      final next = List<int>.filled(result.length + 1, 0);
      for (var j = 0; j < result.length; j++) {
        // Multiplying by (x + root): the x term shifts each coefficient up a
        // degree, the constant term scales it by the root.
        next[j] ^= result[j];
        next[j + 1] ^= _multiply(result[j], root);
      }
      result = next;
      root = _multiply(root, 0x02);
    }
    // Drop the leading coefficient: it is always 1 and the division does not
    // use it.
    return result.sublist(1);
  }

  static int _multiply(int x, int y) {
    var z = 0;
    for (var i = 7; i >= 0; i--) {
      z = (z << 1) ^ ((z >> 7) * 0x11D);
      z ^= ((y >> i) & 1) * x;
    }
    return z & 0xFF;
  }
}

class _BitBuffer {
  final List<bool> _bits = [];

  int get length => _bits.length;

  void append(int value, int bitCount) {
    for (var i = bitCount - 1; i >= 0; i--) {
      _bits.add(((value >> i) & 1) == 1);
    }
  }

  List<int> toBytes() {
    final bytes = List<int>.filled(_bits.length ~/ 8, 0);
    for (var i = 0; i < _bits.length; i++) {
      if (_bits[i]) bytes[i >> 3] |= 1 << (7 - (i & 7));
    }
    return bytes;
  }
}

/// Module placement. Coordinates are `(x = column, y = row)` throughout, which
/// is the convention the specification's diagrams use.
class _Builder {
  _Builder(this.version)
    : size = version * 4 + 17,
      modules = List<bool>.filled(
        (version * 4 + 17) * (version * 4 + 17),
        false,
      ),
      _isFunction = List<bool>.filled(
        (version * 4 + 17) * (version * 4 + 17),
        false,
      );

  final int version;
  final int size;
  final List<bool> modules;
  final List<bool> _isFunction;

  bool get(int x, int y) => modules[y * size + x];

  void set(int x, int y, bool dark) => modules[y * size + x] = dark;

  bool isFunction(int x, int y) => _isFunction[y * size + x];

  void _setFunction(int x, int y, bool dark) {
    set(x, y, dark);
    _isFunction[y * size + x] = true;
  }

  void drawFunctionPatterns() {
    for (var i = 0; i < size; i++) {
      _setFunction(6, i, i.isEven);
      _setFunction(i, 6, i.isEven);
    }

    _drawFinder(3, 3);
    _drawFinder(size - 4, 3);
    _drawFinder(3, size - 4);

    // Versions 2–5 carry exactly one alignment pattern; the other three
    // candidate positions collide with the finders.
    if (version >= 2) {
      _drawAlignment(size - 7, size - 7);
    }

    // Reserve the format-information areas, and set the one module that is
    // always dark.
    drawFormatBits(0);
  }

  void _drawFinder(int cx, int cy) {
    for (var dy = -4; dy <= 4; dy++) {
      for (var dx = -4; dx <= 4; dx++) {
        final x = cx + dx;
        final y = cy + dy;
        if (x < 0 || x >= size || y < 0 || y >= size) continue;
        final distance = dx.abs() > dy.abs() ? dx.abs() : dy.abs();
        _setFunction(x, y, distance != 2 && distance != 4);
      }
    }
  }

  void _drawAlignment(int cx, int cy) {
    for (var dy = -2; dy <= 2; dy++) {
      for (var dx = -2; dx <= 2; dx++) {
        final distance = dx.abs() > dy.abs() ? dx.abs() : dy.abs();
        _setFunction(cx + dx, cy + dy, distance != 1);
      }
    }
  }

  /// The 15 format bits, twice, with the BCH check and the 0x5412 mask.
  void drawFormatBits(int mask) {
    // Level L is `01`.
    final data = 0x1 << 3 | mask;
    var remainder = data;
    for (var i = 0; i < 10; i++) {
      remainder = (remainder << 1) ^ ((remainder >> 9) * 0x537);
    }
    final bits = ((data << 10) | remainder) ^ 0x5412;

    for (var i = 0; i <= 5; i++) {
      _setFunction(8, i, _bit(bits, i));
    }
    _setFunction(8, 7, _bit(bits, 6));
    _setFunction(8, 8, _bit(bits, 7));
    _setFunction(7, 8, _bit(bits, 8));
    for (var i = 9; i < 15; i++) {
      _setFunction(14 - i, 8, _bit(bits, i));
    }

    for (var i = 0; i < 8; i++) {
      _setFunction(size - 1 - i, 8, _bit(bits, i));
    }
    for (var i = 8; i < 15; i++) {
      _setFunction(8, size - 15 + i, _bit(bits, i));
    }
    _setFunction(8, size - 8, true);
  }

  /// Zigzag placement, two columns at a time from the bottom-right, skipping
  /// the vertical timing column.
  void drawCodewords(List<int> codewords) {
    var index = 0;
    for (var right = size - 1; right >= 1; right -= 2) {
      if (right == 6) right = 5;
      for (var vertical = 0; vertical < size; vertical++) {
        for (var j = 0; j < 2; j++) {
          final x = right - j;
          final upward = ((right + 1) & 2) == 0;
          final y = upward ? size - 1 - vertical : vertical;
          if (!isFunction(x, y) && index < codewords.length * 8) {
            set(x, y, _bit(codewords[index >> 3], 7 - (index & 7)));
            index++;
          }
        }
      }
    }
  }

  void applyMask(int mask) {
    for (var y = 0; y < size; y++) {
      for (var x = 0; x < size; x++) {
        if (isFunction(x, y)) continue;
        if (_maskAt(mask, x, y)) set(x, y, !get(x, y));
      }
    }
  }

  static bool _maskAt(int mask, int x, int y) => switch (mask) {
    0 => (x + y) % 2 == 0,
    1 => y % 2 == 0,
    2 => x % 3 == 0,
    3 => (x + y) % 3 == 0,
    4 => (x ~/ 3 + y ~/ 2) % 2 == 0,
    5 => x * y % 2 + x * y % 3 == 0,
    6 => (x * y % 2 + x * y % 3) % 2 == 0,
    _ => ((x + y) % 2 + x * y % 3) % 2 == 0,
  };

  /// The mask with the lowest penalty, exactly as the specification scores it.
  int chooseMask() {
    var best = 0;
    var bestPenalty = -1;
    for (var mask = 0; mask < 8; mask++) {
      applyMask(mask);
      drawFormatBits(mask);
      final penalty = _penalty();
      applyMask(mask);
      if (bestPenalty < 0 || penalty < bestPenalty) {
        bestPenalty = penalty;
        best = mask;
      }
    }
    return best;
  }

  /// The four penalty rules from the specification.
  int _penalty() =>
      _penaltyRuns() +
      _penaltyBlocks() +
      _penaltyFinderLike() +
      _penaltyRatio();

  /// Rule 1: five or more identical modules in a row or column.
  int _penaltyRuns() {
    var penalty = 0;
    for (var y = 0; y < size; y++) {
      penalty += _runPenaltyAlong((i) => get(i, y));
    }
    for (var x = 0; x < size; x++) {
      penalty += _runPenaltyAlong((i) => get(x, i));
    }
    return penalty;
  }

  int _runPenaltyAlong(bool Function(int) at) {
    var penalty = 0;
    var previous = at(0);
    var length = 0;
    for (var i = 0; i < size; i++) {
      if (at(i) == previous) {
        length++;
      } else {
        if (length >= 5) penalty += length - 2;
        length = 1;
        previous = at(i);
      }
    }
    if (length >= 5) penalty += length - 2;
    return penalty;
  }

  /// Rule 2: 2x2 blocks of a single colour.
  int _penaltyBlocks() {
    var penalty = 0;
    for (var y = 0; y < size - 1; y++) {
      for (var x = 0; x < size - 1; x++) {
        final colour = get(x, y);
        if (colour == get(x + 1, y) &&
            colour == get(x, y + 1) &&
            colour == get(x + 1, y + 1)) {
          penalty += 3;
        }
      }
    }
    return penalty;
  }

  /// Rule 3: the 1:1:3:1:1 finder-like ratio with four light modules on one
  /// side — `10111010000` or `00001011101` — scored 40 each.
  int _penaltyFinderLike() {
    var penalty = 0;
    for (var y = 0; y < size; y++) {
      for (var x = 0; x + 10 < size; x++) {
        if (_isFinderLike((i) => get(x + i, y))) penalty += 40;
      }
    }
    for (var x = 0; x < size; x++) {
      for (var y = 0; y + 10 < size; y++) {
        if (_isFinderLike((i) => get(x, y + i))) penalty += 40;
      }
    }
    return penalty;
  }

  static bool _isFinderLike(bool Function(int) at) {
    if (at(1) || !at(4) || at(5) || !at(6) || at(9)) return false;
    final trailingLight =
        at(0) && at(2) && at(3) && !at(7) && !at(8) && !at(10);
    final leadingLight = !at(0) && !at(2) && !at(3) && at(7) && at(8) && at(10);
    return trailingLight || leadingLight;
  }

  /// Rule 4: every five percentage points the dark ratio departs from half.
  int _penaltyRatio() {
    var dark = 0;
    for (final module in modules) {
      if (module) dark++;
    }
    final total = size * size;
    return ((dark * 20 - total * 10).abs() ~/ total) * 10;
  }

  static bool _bit(int value, int index) => ((value >> index) & 1) != 0;
}
