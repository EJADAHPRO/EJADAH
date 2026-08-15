import 'value.dart';

/// A page of results plus the counts the UI actually shows.
///
/// The pagination control reads "1–12 of 199", so [total] is required, not
/// optional — a list that cannot state its own size looks broken.
class Paginated<T> extends ValueObject {
  const Paginated({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  const Paginated.empty()
    : items = const [],
      total = 0,
      page = 1,
      pageSize = 12;

  final List<T> items;
  final int total;
  final int page;
  final int pageSize;

  int get pageCount => total == 0 ? 1 : ((total - 1) ~/ pageSize) + 1;

  bool get hasMore => page < pageCount;

  bool get isEmpty => items.isEmpty;

  /// 1-based index of the first item on this page, for "1–12 of 199".
  int get firstIndex => total == 0 ? 0 : ((page - 1) * pageSize) + 1;

  int get lastIndex => total == 0 ? 0 : firstIndex + items.length - 1;

  Paginated<T> copyWith({List<T>? items, int? total}) => Paginated<T>(
    items: items ?? this.items,
    total: total ?? this.total,
    page: page,
    pageSize: pageSize,
  );

  Paginated<R> map<R>(R Function(T item) transform) => Paginated<R>(
    items: items.map(transform).toList(),
    total: total,
    page: page,
    pageSize: pageSize,
  );

  factory Paginated.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) parseItem,
  ) => Paginated<T>(
    items: (json['items'] as List<dynamic>? ?? const [])
        .map((item) => parseItem(Map<String, dynamic>.from(item as Map)))
        .toList(),
    total: jsonInt(json['total']) ?? 0,
    page: jsonInt(json['page']) ?? 1,
    pageSize: jsonInt(json['page_size']) ?? 12,
  );

  Map<String, dynamic> toJson(
    Map<String, dynamic> Function(T item) encodeItem,
  ) => {
    'items': items.map(encodeItem).toList(),
    'total': total,
    'page': page,
    'page_size': pageSize,
  };

  @override
  List<Object?> get props => [items, total, page, pageSize];
}
