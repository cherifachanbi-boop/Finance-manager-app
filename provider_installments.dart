import "package:flutter/material.dart";
import "db_helper.dart" show DBHelper;
import "model_installment.dart";

class InstallmentsProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper.instance;
  List<Installment> items = [];

  double get monthlyTotal =>
      items.fold(0, (sum, i) => sum + (i.isCompleted ? 0 : i.monthlyAmount));

  Future<void> load() async {
    final rows = await _db.fetchInstallments();
    items = rows.map((r) => Installment.fromMap(r)).toList();
    notifyListeners();
  }

  Future<void> add(Installment installment) async {
    final id = await _db.insertInstallment(installment.toMap());
    items.insert(0, Installment.fromMap({...installment.toMap(), "id": id}));
    notifyListeners();
  }

  Future<void> update(Installment installment) async {
    await _db.updateInstallment(installment.id!, installment.toMap());
    final idx = items.indexWhere((i) => i.id == installment.id);
    if (idx != -1) items[idx] = installment;
    notifyListeners();
  }

  Future<void> remove(int id) async {
    await _db.deleteInstallment(id);
    items.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  Future<void> registerPayment(Installment installment) async {
    if (installment.remainingCount <= 0) return;
    final updated = installment.copyWith(
      remainingCount: installment.remainingCount - 1,
    );
    await update(updated);
  }
}
