import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "provider_app.dart";
import "screen_home.dart";

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameCtrl = TextEditingController();
  final _motherCtrl = TextEditingController(text: "10000");
  final _alimonyCtrl = TextEditingController(text: "5000");
  String _currency = "دج";
  int _salaryDay = 1;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _motherCtrl.dispose();
    _alimonyCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final app = context.read<AppProvider>();
    await app.completeOnboarding(
      name: _nameCtrl.text.trim(),
      currencyValue: _currency,
      day: _salaryDay,
      mother: double.tryParse(_motherCtrl.text) ?? 10000,
      alimonyValue: double.tryParse(_alimonyCtrl.text) ?? 5000,
    );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إعداد التطبيق")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "مرحبًا بك 👋",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              "لنقم بإعداد بياناتك الأساسية قبل البدء",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),

            const Text("الاسم (اختياري)", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(hintText: "اسمك")),
            const SizedBox(height: 18),

            const Text("العملة", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: TextEditingController(text: _currency),
              onChanged: (v) => _currency = v,
              decoration: const InputDecoration(hintText: "دج"),
            ),
            const SizedBox(height: 18),

            const Text("يوم استلام الراتب", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            DropdownButtonFormField<int>(
              initialValue: _salaryDay,
              items: List.generate(28, (i) => i + 1)
                  .map((d) => DropdownMenuItem(value: d, child: Text("يوم $d")))
                  .toList(),
              onChanged: (v) => setState(() => _salaryDay = v ?? 1),
            ),
            const SizedBox(height: 18),

            const Text("مبلغ الأم (الافتراضي)", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _motherCtrl,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 18),

            const Text("مبلغ النفقة (الافتراضي)", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _alimonyCtrl,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _finish,
                child: const Text("بدء الاستخدام"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
