import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:provider/provider.dart";
import "theme.dart";
import "model_installment.dart";
import "provider_app.dart";
import "provider_installments.dart";
import "widget_progress_bar_row.dart";

class InstallmentsScreen extends StatefulWidget {
  final bool embedded;
  const InstallmentsScreen({super.key, this.embedded = false});

  @override
  State<InstallmentsScreen> createState() => _InstallmentsScreenState();
}

class _InstallmentsScreenState extends State<InstallmentsScreen> {
  Future<void> _openForm({Installment? existing}) async {
    final entityCtrl = TextEditingController(text: existing?.entity ?? "");
    final amountCtrl = TextEditingController(
        text: existing != null ? existing.monthlyAmount.toStringAsFixed(0) : "");
    final totalCtrl =
        TextEditingController(text: existing != null ? existing.totalCount.toString() : "");
    final remainingCtrl =
        TextEditingController(text: existing != null ? existing.remainingCount.toString() : "");

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 20 + MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(existing == null ? "إضافة قسط" : "تعديل القسط",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              TextField(controller: entityCtrl, decoration: const InputDecoration(labelText: "اسم الجهة")),
              const SizedBox(height: 10),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "القسط الشهري"),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: totalCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "عدد الأقساط الإجمالي"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: remainingCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "المتبقي"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final provider = context.read<InstallmentsProvider>();
                    final data = Installment(
                      id: existing?.id,
                      entity: entityCtrl.text.trim().isEmpty ? "بدون اسم" : entityCtrl.text.trim(),
                      monthlyAmount: double.tryParse(amountCtrl.text) ?? 0,
                      totalCount: int.tryParse(totalCtrl.text) ?? 0,
                      remainingCount: int.tryParse(remainingCtrl.text) ?? 0,
                      startDate: existing?.startDate ??
                          DateTime.now().toIso8601String().split("T").first,
                    );
                    if (existing == null) {
                      await provider.add(data);
                    } else {
                      await provider.update(data);
                    }
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                  child: const Text("حفظ"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InstallmentsProvider>();
    final app = context.watch<AppProvider>();
    final fmt = NumberFormat("#,##0", "en_US");

    return Scaffold(
      body: provider.items.isEmpty
          ? const Center(child: Text("لا توجد أقساط مسجّلة"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.items.length,
              itemBuilder: (ctx, i) {
                final it = provider.items[i];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(it.entity,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (v) {
                                if (v == "edit") _openForm(existing: it);
                                if (v == "delete") provider.remove(it.id!);
                                if (v == "pay") provider.registerPayment(it);
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: "pay", child: Text("تسجيل دفعة")),
                                const PopupMenuItem(value: "edit", child: Text("تعديل")),
                                const PopupMenuItem(value: "delete", child: Text("حذف")),
                              ],
                            ),
                          ],
                        ),
                        ProgressBarRow(
                          label: "القسط الشهري: ${fmt.format(it.monthlyAmount)} ${app.currency}",
                          progress: it.progress,
                          subtitle: it.isCompleted
                              ? "مكتمل ✅"
                              : "متبقٍ ${it.remainingCount} من ${it.totalCount}",
                          color: it.isCompleted ? AppColors.emerald : AppColors.gold,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
