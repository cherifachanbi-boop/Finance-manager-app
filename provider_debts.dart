import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "db_helper.dart" show DBHelper;
import "model_debt.dart";

class DebtsProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper.instance;
  List<Debt> items = [];

  double get monthlyTotal =>
      items.fold(0, (sum, d) => sum + (d.isCompleted ? 0 : d.monthlyPayment));

  double get totalRemaining =>
      items.fold(0, (sum, d) => sum + (d.remaining > 0 ? d.remaining : 0));

  Future<void> load() async {
    final rows = await _db.fetchDebts();
    items = rows.map((r) => Debt.fromMap(r)).toList();
    notifyListeners();
  }

  Future<void> add(Debt debt) async {
    final id = await _db.insertDebt(debt.toMap());
    items.insert(0, Debt.fromMap({...debt.toMap(), "id": id}));
    notifyListeners();
  }

  Future<void> update(Debt debt) async {
    await _db.updateDebt(debt.id!, debt.toMap());
    final idx = items.indexWhere((d) => d.id == debt.id);
    if (idx != -1) items[idx] = debt;
    notifyListeners();
  }

  Future<void> remove(int id) async {
    await _db.deleteDebt(id);
    items.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  Future<void> registerPayment(Debt debt, double amount) async {
    final updated = debt.copyWith(
      paid: debt.paid + amount,
      lastPaymentDate: DateFormat("yyyy-MM-dd").format(DateTime.now()),
    );
    await update(updated);
  }
}
