class Debt {
  final int? id;
  final String creditor;
  final double totalAmount;
  final double monthlyPayment;
  final double paid;
  final String notes;
  final String lastPaymentDate;

  Debt({
    this.id,
    required this.creditor,
    required this.totalAmount,
    required this.monthlyPayment,
    required this.paid,
    this.notes = "",
    this.lastPaymentDate = "",
  });

  double get remaining => totalAmount - paid;
  double get progress => totalAmount == 0 ? 0 : paid / totalAmount;
  bool get isCompleted => remaining <= 0;

  Debt copyWith({
    String? creditor,
    double? totalAmount,
    double? monthlyPayment,
    double? paid,
    String? notes,
    String? lastPaymentDate,
  }) {
    return Debt(
      id: id,
      creditor: creditor ?? this.creditor,
      totalAmount: totalAmount ?? this.totalAmount,
      monthlyPayment: monthlyPayment ?? this.monthlyPayment,
      paid: paid ?? this.paid,
      notes: notes ?? this.notes,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
    );
  }

  Map<String, dynamic> toMap() => {
        "id": id,
        "creditor": creditor,
        "totalAmount": totalAmount,
        "monthlyPayment": monthlyPayment,
        "paid": paid,
        "notes": notes,
        "lastPaymentDate": lastPaymentDate,
      };

  factory Debt.fromMap(Map<String, dynamic> map) => Debt(
        id: map["id"] as int?,
        creditor: map["creditor"] as String,
        totalAmount: (map["totalAmount"] as num).toDouble(),
        monthlyPayment: (map["monthlyPayment"] as num).toDouble(),
        paid: (map["paid"] as num).toDouble(),
        notes: map["notes"] as String? ?? "",
        lastPaymentDate: map["lastPaymentDate"] as String? ?? "",
      );
}
