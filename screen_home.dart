import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:provider/provider.dart";
import "theme.dart";
import "provider_app.dart";
import "provider_debts.dart";
import "provider_installments.dart";
import "widget_dashboard_card.dart";
import "screen_salary.dart";
import "screen_budget.dart";
import "screen_installments.dart";
import "screen_debts.dart";
import "screen_settings.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  final _pages = const [
    _DashboardTab(),
    SalaryScreen(embedded: true),
    BudgetScreen(embedded: true),
    InstallmentsScreen(embedded: true),
    DebtsScreen(embedded: true),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<InstallmentsProvider>().load();
      context.read<DebtsProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    const titles = ["الرئيسية", "الراتب", "الميزانية", "الأقساط", "الديون"];
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_tab]),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: _pages[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: "الرئيسية"),
          NavigationDestination(icon: Icon(Icons.payments_outlined), label: "الراتب"),
          NavigationDestination(icon: Icon(Icons.pie_chart_outline), label: "الميزانية"),
          NavigationDestination(icon: Icon(Icons.credit_card_outlined), label: "الأقساط"),
          NavigationDestination(icon: Icon(Icons.account_balance_outlined), label: "الديون"),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final installments = context.watch<InstallmentsProvider>();
    final debts = context.watch<DebtsProvider>();
    final fmt = NumberFormat("#,##0", "en_US");

    final month = app.currentMonth;
    final salary = month?.salary ?? 0;
    final dist = month?.distribution() ?? {};
    final saving = dist["الادخار"] ?? 0;
    final reserve = dist["الاحتياطي"] ?? 0;
    final finalBalance = month?.finalBalance ?? 0;

    final totalCommitments = app.motherAmount +
        app.alimony +
        installments.monthlyTotal +
        debts.monthlyTotal;
    final commitmentRatio = salary == 0 ? 0.0 : (totalCommitments / salary) * 100;

    String status;
    Color statusColor;
    if (salary == 0) {
      status = "لم يبدأ الشهر بعد";
      statusColor = Colors.grey;
    } else if (commitmentRatio < 60) {
      status = "وضع مالي ممتاز";
      statusColor = AppColors.emerald;
    } else if (commitmentRatio < 85) {
      status = "وضع مالي جيد";
      statusColor = AppColors.gold;
    } else {
      status = "يحتاج انتباه";
      statusColor = AppColors.brick;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (app.userName.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text("أهلًا، ${app.userName} 👋",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(Icons.insights, color: statusColor),
              const SizedBox(width: 10),
              Text(status,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text("${commitmentRatio.toStringAsFixed(0)}% التزام"),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.4,
          children: [
            DashboardCard(
              title: "الراتب الحالي",
              value: "${fmt.format(salary)} ${app.currency}",
              icon: Icons.payments,
              color: AppColors.emerald,
            ),
            DashboardCard(
              title: "الرصيد المتبقي",
              value: "${fmt.format(finalBalance)} ${app.currency}",
              icon: Icons.account_balance_wallet,
              color: AppColors.gold,
            ),
            DashboardCard(
              title: "إجمالي الديون",
              value: "${fmt.format(debts.totalRemaining)} ${app.currency}",
              icon: Icons.account_balance,
              color: AppColors.brick,
            ),
            DashboardCard(
              title: "إجمالي الأقساط الشهرية",
              value: "${fmt.format(installments.monthlyTotal)} ${app.currency}",
              icon: Icons.credit_card,
              color: AppColors.emeraldDark,
            ),
            DashboardCard(
              title: "الادخار الشهري",
              value: "${fmt.format(saving)} ${app.currency}",
              icon: Icons.savings,
              color: AppColors.emerald,
            ),
            DashboardCard(
              title: "الاحتياطي الشهري",
              value: "${fmt.format(reserve)} ${app.currency}",
              icon: Icons.shield_outlined,
              color: AppColors.gold,
            ),
          ],
        ),
      ],
    );
  }
}
