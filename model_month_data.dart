class MonthData {
  final int? id;
  final String monthLabel; // e.g. "2026-07"
  final double salary;
  final double motherAmount;
  final double alimony;
  final String distributionMode; // "percentage" or "fixed"
  final double percentFamily;
  final double percentInstallment;
  final double percentDebt;
  final double percentSaving;
  final double percentReserve;
  final double fixedFamily;
  final double fixedInstallment;
  final double fixedDebt;
  final double fixedSaving;
  final double fixedReserve;

  MonthData({
    this.id,
    required this.monthLabel,
    required this.salary,
    required this.motherAmount,
    required this.alimony,
    required this.distributionMode,
    this.percentFamily = 58.6,
    this.percentInstallment = 11.4,
    this.percentDebt = 18.0,
    this.percentSaving = 4.5,
    this.percentReserve = 7.5,
    this.fixedFamily = 0,
    this.fixedInstallment = 0,
    this.fixedDebt = 0,
    this.fixedSaving = 0,
    this.fixedReserve = 0,
  });

  double get baseAfterFixedObligations => salary - motherAmount - alimony;

  Map<String, double> distribution() {
    final base = baseAfterFixedObligations;
    if (distributionMode == "fixed") {
      return {
        "مصاريف الأسرة": fixedFamily,
        "الأقساط": fixedInstallment,
        "سداد الدين": fixedDebt,
        "الادخار": fixedSaving,
        "الاحتياطي": fixedReserve,
      };
    }
    return {
      "مصاريف الأسرة": base * percentFamily / 100,
      "الأقساط": base * percentInstallment / 100,
      "سداد الدين": base * percentDebt / 100,
      "الادخار": base * percentSaving / 100,
      "الاحتياطي": base * percentReserve / 100,
    };
  }

  double get totalDistributed => distribution().values.fold(0, (a, b) => a + b);

  double get finalBalance => baseAfterFixedObligations - totalDistributed;

  Map<String, dynamic> toMap() => {
        "id": id,
        "monthLabel": monthLabel,
        "salary": salary,
        "motherAmount": motherAmount,
        "alimony": alimony,
        "distributionMode": distributionMode,
        "percentFamily": percentFamily,
        "percentInstallment": percentInstallment,
        "percentDebt": percentDebt,
        "percentSaving": percentSaving,
        "percentReserve": percentReserve,
        "fixedFamily": fixedFamily,
        "fixedInstallment": fixedInstallment,
        "fixedDebt": fixedDebt,
        "fixedSaving": fixedSaving,
        "fixedReserve": fixedReserve,
      };

  factory MonthData.fromMap(Map<String, dynamic> map) => MonthData(
        id: map["id"] as int?,
        monthLabel: map["monthLabel"] as String,
        salary: (map["salary"] as num).toDouble(),
        motherAmount: (map["motherAmount"] as num).toDouble(),
        alimony: (map["alimony"] as num).toDouble(),
        distributionMode: map["distributionMode"] as String,
        percentFamily: (map["percentFamily"] as num).toDouble(),
        percentInstallment: (map["percentInstallment"] as num).toDouble(),
        percentDebt: (map["percentDebt"] as num).toDouble(),
        percentSaving: (map["percentSaving"] as num).toDouble(),
        percentReserve: (map["percentReserve"] as num).toDouble(),
        fixedFamily: (map["fixedFamily"] as num).toDouble(),
        fixedInstallment: (map["fixedInstallment"] as num).toDouble(),
        fixedDebt: (map["fixedDebt"] as num).toDouble(),
        fixedSaving: (map["fixedSaving"] as num).toDouble(),
        fixedReserve: (map["fixedReserve"] as num).toDouble(),
      );
}
