import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:provider/provider.dart";
import "theme.dart";
import "model_month_data.dart";
import "provider_app.dart";

class SalaryScreen extends StatefulWidget {
  final bool embedded;
  const SalaryScreen({super.key, this.embedded = false});

  @override
  State<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen> {
  final _salaryCtrl = TextEditingController();
  bool _started = false;
  MonthData? _preview;

  @override
  void dispose() {
    _salaryCtrl.dispose();
    super.dispose();
  }

  void _startMonth() {
    final app = context.read<AppProvider>();
    final salary = double.tryParse(_salaryCtrl.text) ?? 0;
    if (salary <= 0) return;

    final month = MonthData(
      monthLabel: DateFormat("yyyy-MM").format(DateTime.now()),
      salary: salary,
      motherAmount: app.motherAmount,
      alimony: app.alimony,
      distributionMode: "percentage",
    );

    app.startNewMonth(month);
    setState(() {
      _preview = month;
      _started = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final fmt = NumberFormat("#,##0", "en_US");
    final month = _preview ?? app.currentMonth;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("أدخل الراتب الشهري", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          TextField(
            controller: _salaryCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            decoration: InputDecoration(suffixText: app.currency),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _startMonth,
              icon: const Icon(Icons.play_circle_outline),
              label: const Text("بدء الشهر"),
            ),
          ),
          const SizedBox(height: 24),
          if (month != null) ...[
            const Divider(),
            const SizedBox(height: 12),
            const Text("توزيع الراتب", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _row("مبلغ الأم", month.motherAmount, fmt, app.currency, AppColors.gold),
            _row("النفقة", month.alimony, fmt, app.currency, AppColors.brick),
            const Divider(height: 24),
            ...month.distribution().entries.map(
              (e) => _row(e.key, e.value, fmt, app.currency, AppColors.emerald),
            ),
            const Divider(height: 24),
            _row("الرصيد النهائي", month.finalBalance, fmt, app.currency,
                month.finalBalance >= 0 ? AppColors.emerald : AppColors.brick,
                bold: true),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, double value, NumberFormat fmt, String currency, Color color,
      {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.w500)),
          Text(
            "${fmt.format(value)} $currency",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: bold ? 17 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
