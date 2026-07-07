import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:provider/provider.dart";
import "theme.dart";
import "provider_app.dart";
import "widget_progress_bar_row.dart";

class BudgetScreen extends StatefulWidget {
  final bool embedded;
  const BudgetScreen({super.key, this.embedded = false});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  bool _percentageMode = true;

  final Map<String, double> _percents = {
    "مصاريف الأسرة": 58.6,
    "الأقساط": 11.4,
    "سداد الدين": 18.0,
    "الادخار": 4.5,
    "الاحتياطي": 7.5,
  };

  final _colors = {
    "مصاريف الأسرة": AppColors.emerald,
    "الأقساط": AppColors.emeraldDark,
    "سداد الدين": AppColors.brick,
    "الادخار": AppColors.gold,
    "الاحتياطي": Colors.blueGrey,
  };

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final fmt = NumberFormat("#,##0", "en_US");
    final salary = app.currentMonth?.salary ?? 0;
    final base = salary - app.motherAmount - app.alimony;
    final percentTotal = _percents.values.fold(0.0, (a, b) => a + b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text("طريقة التوزيع", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              ChoiceChip(
                label: const Text("نسبة %"),
                selected: _percentageMode,
                onSelected: (_) => setState(() => _percentageMode = true),
              ),
              const SizedBox(width: 6),
              ChoiceChip(
                label: const Text("مبلغ ثابت"),
                selected: !_percentageMode,
                onSelected: (_) => setState(() => _percentageMode = false),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (percentTotal != 100 && _percentageMode)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.brick.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "تنبيه: مجموع النسب ${percentTotal.toStringAsFixed(1)}% وليس 100%",
                style: const TextStyle(color: AppColors.brick, fontSize: 12.5),
              ),
            ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: _percents.keys.map((label) {
                  final percent = _percents[label]!;
                  final amount = base * percent / 100;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        Expanded(
                          child: _percentageMode
                              ? Row(
                                  children: [
                                    SizedBox(
                                      width: 56,
                                      child: TextFormField(
                                        initialValue: percent.toString(),
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        onChanged: (v) => setState(
                                          () => _percents[label] = double.tryParse(v) ?? 0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text("%"),
                                  ],
                                )
                              : const SizedBox(),
                        ),
                        Expanded(
                          child: Text(
                            "${fmt.format(amount)} ${app.currency}",
                            textAlign: TextAlign.end,
                            style: TextStyle(color: _colors[label], fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text("تتبّع الإنفاق (تجريبي)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: _percents.keys.map((label) {
                  final percent = _percents[label]!;
                  final planned = base * percent / 100;
                  return ProgressBarRow(
                    label: label,
                    progress: 0, // سيتم ربطه بالمصروفات الفعلية في مرحلة لاحقة
                    subtitle:
                        "المخطط: ${fmt.format(planned)} ${app.currency} · المصروف: 0 ${app.currency}",
                    color: _colors[label] ?? AppColors.emerald,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
