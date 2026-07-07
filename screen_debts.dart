import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:provider/provider.dart";
import "theme.dart";
import "model_debt.dart";
import "provider_app.dart";
import "provider_debts.dart";
import "widget_progress_bar_row.dart";

class DebtsScreen extends StatefulWidget {
  final bool embedded;
  const DebtsScreen({super.key, this.embedded = false});

  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen> {
  Future<void> _openForm({Debt? existing}) async {
    final creditorCtrl = TextEditingController(text: existing?.creditor ?? "");
    final totalCtrl =
        TextEditingController(text: existing != null ? existing.totalAmount.toStringAsFixed(0) : "");
    final monthlyCtrl = TextEditingController(
        text: existing != null ? existing.monthlyPayment.toStringAsFixed(0) : "");
    final notesCtrl = TextEditingController(text: existing?.notes ?? "");

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
              Text(existing == null ? "إضافة دين" : "تعديل الدين",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              TextField(
                  controller: creditorCtrl,
                  decoration: const InputDecoration(labelText: "اسم الجهة المدينة")),
              const SizedBox(height: 10),
              TextField(
                controller: totalCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "المبلغ الإجمالي"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: monthlyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "دفعة السداد الشهرية"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: notesCtrl,
                decoration: const InputDecoration(labelText: "ملاحظات"),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final provider = context.read<DebtsProvider>();
                    final data = Debt(
                      id: existing?.id,
                      creditor:
                          creditorCtrl.text.trim().isEmpty ? "بدون اسم" : creditorCtrl.text.trim(),
                      totalAmount: double.tryParse(totalCtrl.text) ?? 0,
                      monthlyPayment: double.tryParse(monthlyCtrl.text) ?? 0,
                      paid: existing?.paid ?? 0,
                      notes: notesCtrl.text.trim(),
                      lastPaymentDate: existing?.lastPaymentDate ?? "",
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

  Future<void> _registerPayment(Debt debt) async {
    final ctrl = TextEditingController(text: debt.monthlyPayment.toStringAsFixed(0));
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("تسجيل دفعة"),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "المبلغ المدفوع"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(ctrl.text) ?? 0;
              await context.read<DebtsProvider>().registerPayment(debt, amount);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text("تأكيد"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DebtsProvider>();
    final app = context.watch<AppProvider>();
    final fmt = NumberFormat("#,##0", "en_US");

    return Scaffold(
      body: provider.items.isEmpty
          ? const Center(child: Text("لا توجد ديون مسجّلة"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.items.length,
              itemBuilder: (ctx, i) {
                final d = provider.items[i];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(d.creditor,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (v) {
                                if (v == "edit") _openForm(existing: d);
                                if (v == "delete") provider.remove(d.id!);
                                if (v == "pay") _registerPayment(d);
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
                          label: "الإجمالي: ${fmt.format(d.totalAmount)} ${app.currency}",
                          progress: d.progress,
                          subtitle: d.isCompleted
                              ? "مكتمل السداد ✅"
                              : "المتبقي ${fmt.format(d.remaining)} ${app.currency}",
                          color: d.isCompleted ? AppColors.emerald : AppColors.brick,
                        ),
                        if (d.notes.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(d.notes,
                                style: TextStyle(
                                    fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
