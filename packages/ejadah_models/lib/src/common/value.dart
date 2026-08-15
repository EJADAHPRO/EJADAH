import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

const _deepEquality = DeepCollectionEquality();

/// Base for immutable value types.
///
/// Models are compared by [props] rather than identity so that controller
/// state, cache reads and test expectations all behave the same way.
@immutable
abstract class ValueObject {
  const ValueObject();

  /// The fields that define this value's identity.
  List<Object?> get props;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValueObject &&
          other.runtimeType == runtimeType &&
          _deepEquality.equals(other.props, props);

  @override
  int get hashCode => Object.hash(runtimeType, _deepEquality.hash(props));

  @override
  String toString() => '$runtimeType${props.toString()}';
}

/// Reads a required value of type [T] from a decoded JSON map.
T jsonRequire<T>(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! T) {
    throw FormatException(
      'Expected "$key" to be $T but found ${value.runtimeType}',
    );
  }
  return value;
}

/// Reads an integer that a source may encode as a number or a string.
int? jsonInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

/// Reads a double that a source may encode as a number or a string.
double? jsonDouble(Object? value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim());
  return null;
}

/// Reads a boolean that a source may encode as a bool, "Yes"/"No" or 0/1.
bool? jsonBool(Object? value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    return const {'yes', 'true', '1', 'y'}.contains(normalized);
  }
  return null;
}

/// Reads a UTC [DateTime] from an ISO-8601 string.
DateTime? jsonDate(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value.toUtc();
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value.trim())?.toUtc();
  }
  return null;
}
