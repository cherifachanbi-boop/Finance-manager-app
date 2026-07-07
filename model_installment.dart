class Installment {
  final int? id;
  final String entity;
  final double monthlyAmount;
  final int totalCount;
  final int remainingCount;
  final String startDate;

  Installment({
    this.id,
    required this.entity,
    required this.monthlyAmount,
    required this.totalCount,
    required this.remainingCount,
    required this.startDate,
  });

  double get progress =>
      totalCount == 0 ? 0 : (totalCount - remainingCount) / totalCount;

  bool get isCompleted => remainingCount <= 0;

  Installment copyWith({
    String? entity,
    double? monthlyAmount,
    int? totalCount,
    int? remainingCount,
  }) {
    return Installment(
      id: id,
      entity: entity ?? this.entity,
      monthlyAmount: monthlyAmount ?? this.monthlyAmount,
      totalCount: totalCount ?? this.totalCount,
      remainingCount: remainingCount ?? this.remainingCount,
      startDate: startDate,
    );
  }

  Map<String, dynamic> toMap() => {
        "id": id,
        "entity": entity,
        "monthlyAmount": monthlyAmount,
        "totalCount": totalCount,
        "remainingCount": remainingCount,
        "startDate": startDate,
      };

  factory Installment.fromMap(Map<String, dynamic> map) => Installment(
        id: map["id"] as int?,
        entity: map["entity"] as String,
        monthlyAmount: (map["monthlyAmount"] as num).toDouble(),
        totalCount: map["totalCount"] as int,
        remainingCount: map["remainingCount"] as int,
        startDate: map["startDate"] as String,
      );
}
