class Pagination {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? shown;
  int? total;

  Pagination({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.shown,
    this.total,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        currentPage: json['current_page'] as int?,
        lastPage: json['last_page'] as int?,
        perPage: json['per_page'] as int?,
        shown: json['shown'] as int?,
        total: json['total'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'current_page': currentPage,
        'last_page': lastPage,
        'per_page': perPage,
        'shown': shown,
        'total': total,
      };
}
