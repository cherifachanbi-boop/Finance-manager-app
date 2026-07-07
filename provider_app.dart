import "package:flutter/material.dart";
import "db_helper.dart" show DBHelper;
import "model_month_data.dart";

class AppProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper.instance;

  bool onboardingDone = false;
  ThemeMode themeMode = ThemeMode.light;

  String userName = "";
  String currency = "دج";
  int salaryDay = 1;
  double motherAmount = 10000;
  double alimony = 5000;

  MonthData? currentMonth;

  Future<void> loadSettings() async {
    final done = await _db.getSetting("onboarding_done");
    onboardingDone = done == "true";

    userName = await _db.getSetting("user_name") ?? "";
    currency = await _db.getSetting("currency") ?? "دج";
    salaryDay = int.tryParse(await _db.getSetting("salary_day") ?? "1") ?? 1;
    motherAmount =
        double.tryParse(await _db.getSetting("mother_amount") ?? "10000") ?? 10000;
    alimony = double.tryParse(await _db.getSetting("alimony") ?? "5000") ?? 5000;

    final darkMode = await _db.getSetting("dark_mode");
    themeMode = darkMode == "true" ? ThemeMode.dark : ThemeMode.light;

    final latest = await _db.fetchLatestMonth();
    if (latest != null) {
      currentMonth = MonthData.fromMap(latest);
    }

    notifyListeners();
  }

  Future<void> completeOnboarding({
    required String name,
    required String currencyValue,
    required int day,
    required double mother,
    required double alimonyValue,
  }) async {
    userName = name;
    currency = currencyValue;
    salaryDay = day;
    motherAmount = mother;
    alimony = alimonyValue;
    onboardingDone = true;

    await _db.setSetting("user_name", name);
    await _db.setSetting("currency", currencyValue);
    await _db.setSetting("salary_day", day.toString());
    await _db.setSetting("mother_amount", mother.toString());
    await _db.setSetting("alimony", alimonyValue.toString());
    await _db.setSetting("onboarding_done", "true");

    notifyListeners();
  }

  Future<void> toggleDarkMode(bool isDark) async {
    themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    await _db.setSetting("dark_mode", isDark.toString());
    notifyListeners();
  }

  Future<void> updateFixedObligations(double mother, double alimonyValue) async {
    motherAmount = mother;
    alimony = alimonyValue;
    await _db.setSetting("mother_amount", mother.toString());
    await _db.setSetting("alimony", alimonyValue.toString());
    notifyListeners();
  }

  Future<void> startNewMonth(MonthData month) async {
    await _db.insertMonth(month.toMap());
    currentMonth = month;
    notifyListeners();
  }
}
