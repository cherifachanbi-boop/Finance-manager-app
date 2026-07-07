import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "provider_app.dart";

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _motherCtrl;
  late TextEditingController _alimonyCtrl;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppProvider>();
    _motherCtrl = TextEditingController(text: app.motherAmount.toStringAsFixed(0));
    _alimonyCtrl = TextEditingController(text: app.alimony.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _motherCtrl.dispose();
    _alimonyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("الإعدادات")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text("الوضع الداكن"),
            value: app.themeMode == ThemeMode.dark,
            onChanged: (v) => app.toggleDarkMode(v),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text("الالتزامات الثابتة الافتراضية",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          TextField(
            controller: _motherCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "مبلغ الأم"),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _alimonyCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "مبلغ النفقة"),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              app.updateFixedObligations(
                double.tryParse(_motherCtrl.text) ?? app.motherAmount,
                double.tryParse(_alimonyCtrl.text) ?? app.alimony,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("تم الحفظ")),
              );
            },
            child: const Text("حفظ التغييرات"),
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("عن التطبيق"),
            subtitle: const Text("مدير الراتب الذكي — الإصدار 1.0.0 (المرحلة 1)"),
          ),
        ],
      ),
    );
  }
}
